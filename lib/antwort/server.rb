require 'sinatra/base'
require 'sinatra/partial'
require 'sinatra/content_for'
require 'rack-livereload'
require 'sinatra/reloader'

module Antwort
  class Server < Sinatra::Base
    use Rack::LiveReload
    Tilt.register Tilt::ERBTemplate, 'html.erb'
    register Sinatra::Partial
    register Sinatra::Reloader
    helpers Sinatra::ContentFor
    include Antwort::ApplicationHelpers
    include Antwort::MarkupHelpers

    configure do
      enable :logging
      set :root, Dir.pwd
      set :views, settings.root
      set :templates_dir, settings.root + '/emails'
      set :partial_template_engine, :erb
      enable :partial_underscores
      set :port, 9292
    end

    register Sinatra::Assets # must come after we set root

    get '/' do
      pages = Dir.entries(settings.templates_dir)
      pages.delete_if { |page| page.to_s[0] == '.' }
      @pages = pages.map { |page| page.split('.').first }
      erb :'views/index', layout: :'views/server'
    end

    get '/template/:template' do
      @template = sanitize_param params[:template]

      if template_exists? @template
        content   = get_content @template
        data      = fetch_data @template
        context   = self
        @metadata = content[:metadata] || {}
        render_template(content[:body], data, context)
      else
        status 404
      end
    end

    not_found do
      erb :'views/404', layout: :'views/server'
    end

  end
end
