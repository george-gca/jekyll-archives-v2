# frozen_string_literal: true

require "helper"

class TestJekyllArchive < Minitest::Test
  context "the generated archive page" do
    setup do
      @site = fixture_site("collections" => {
          "posts" => {
            "output" => true,
          },
        },
        "jekyll-archives" => {
          "posts" => {
            "enabled" => true,
          },
        }
      )
      @site.read
      Jekyll::ArchivesV2::Archives.new(@site.config).generate(@site)
      @archives = @site.config["archives"]
    end

    should "expose attributes to Liquid templates" do
      archive = @archives.find { |a| a.type == "tags" }
      archive.documents = []
      expected = {
        "collection_name" => "posts",
        "layout"          => "archive",
        "documents"       => [],
        "type"            => "tags",
        "title"           => "Test Tag",
        "date"            => nil,
        "name"            => "index",
        "path"            => "posts/tag/test-tag/index.html",
        "url"             => "/posts/tag/test-tag/",
        "permalink"       => nil,
      }

      assert_equal expected, archive.to_liquid.to_h

      archive = @archives.find { |a| a.type == "categories" }
      archive.documents = []
      expected = {
        "collection_name" => "posts",
        "layout"          => "archive",
        "documents"       => [],
        "type"            => "categories",
        "title"           => "plugins",
        "date"            => nil,
        "name"            => "index",
        "path"            => "posts/category/plugins/index.html",
        "url"             => "/posts/category/plugins/",
        "permalink"       => nil,
      }

      assert_equal expected, archive.to_liquid.to_h

      archive = @archives.find { |a| a.type == "year" }
      archive.documents = []
      expected = {
        "collection_name" => "posts",
        "layout"          => "archive",
        "documents"       => [],
        "type"            => "year",
        "title"           => nil,
        "date"            => archive.date,
        "name"            => "index",
        "path"            => "posts/2013/index.html",
        "url"             => "/posts/2013/",
        "permalink"       => nil,
      }

      assert_equal expected, archive.to_liquid.to_h

      archive = @archives.find { |a| a.type == "month" }
      archive.documents = []
      expected = {
        "collection_name" => "posts",
        "layout"          => "archive",
        "documents"       => [],
        "type"            => "month",
        "title"           => nil,
        "date"            => archive.date,
        "name"            => "index",
        "path"            => "posts/2013/08/index.html",
        "url"             => "/posts/2013/08/",
        "permalink"       => nil,
      }

      assert_equal expected, archive.to_liquid.to_h

      archive = @archives.find { |a| a.type == "day" }
      archive.documents = []
      expected = {
        "collection_name" => "posts",
        "layout"          => "archive",
        "documents"       => [],
        "type"            => "day",
        "title"           => nil,
        "date"            => archive.date,
        "name"            => "index",
        "path"            => "posts/2013/08/16/index.html",
        "url"             => "/posts/2013/08/16/",
        "permalink"       => nil,
      }

      assert_equal expected, archive.to_liquid.to_h
    end
  end
end
