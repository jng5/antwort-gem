module Antwort
  class EmailBuilder < Builder
    attr_accessor :html_markup

    def post_initialize(*)
      app     ||= Antwort::Server.new
      mock    ||= Rack::MockRequest.new(app)

      request = mock.get("/template/#{template_name}")
      if request.status == 200
        create_build_directories
        @html_markup  = remove_livereload(request.body)
        @inlined_file = "#{build_dir}/#{template_name}.html"
      else
        say 'Error: ', :red
        say "Template '#{template_name}' not found."
      end
    end

    def build
      unless html_markup.nil?
        build_css
        build_html
        inline_css
      end

      until File.exist?(@inlined_file)
        sleep 1
      end
      return true
    end

    def build_html
      markup = html_markup
      markup = markup.gsub("/assets/#{template_name}/inline.css", 'inline.css')
                     .gsub("/assets/#{template_name}/include.css", 'include.css')
      create_file(content: markup, path: "#{markup_dir}/#{template_name}.html")
    end

    def inline_css
      markup   = preserve_nbsps(html_markup)
      document = Roadie::Document.new(markup)

      document.asset_providers << Roadie::NullProvider.new
      document.add_css(css)

      inlined = restore_nbsps(document.transform)
      inlined = cleanup_markup(inlined)
      inlined = remove_excessive_newlines(inlined)
      inlined = flatten_inlined_css(inlined)
      create_file(content: inlined, path: @inlined_file)
    end

    def cleanup_markup(markup)
      content = use_asset_server(markup)
      content = add_included_css(content)
      content
    end
  end
end
