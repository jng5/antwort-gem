require "spec_helper"

describe Antwort::EmailCollection do

  before :all do
    Dir.chdir(fixtures_root)
  end

  let(:collection) { Antwort::EmailCollection.new }

  describe "has a templates attribute" do
    it "is an array" do
      expect(collection.templates).to be_kind_of(Array)
    end

    it "holds EmailTemplates" do
      expect(collection.templates.first).to be_kind_of(Antwort::EmailTemplate)
    end

    it "loads emails by directory names" do
      result = ['1-demo', '2-no-layout', '3-no-title', '4-custom-layout']
      expect(collection.list).to eq(result)
    end

    describe "filters" do
      it "excludes non-email folders" do
        expect(collection.list).not_to include('.')
        expect(collection.list).not_to include('..')
      end

      it "excludes the shared folder" do
        expect(collection.list).not_to include('shared')
      end
    end

    describe "has a empty? method" do
      context "has templates" do
        it "returns false" do
          expect(collection.empty?).to be false
        end
      end
      context "has no templates" do
        it "returns true" do
          Dir.chdir("#{fixtures_root}/emails")
          c = Antwort::EmailCollection.new
          expect(c.empty?).to be true
        end
      end
    end
  end
end