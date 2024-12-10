# frozen_string_literal: true

require "helper"

class TestJekyllArchives < Minitest::Test
  context "the jekyll-archives-v2 plugin" do
    setup do
      @site = fixture_site(
        "collections" => {
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
      @archives = Jekyll::ArchivesV2::Archives.new(@site.config)
    end

    should "generate archive pages by year" do
      @archives.generate(@site)

      assert archive_exists? @site, "posts/2014/index.html"
      assert archive_exists? @site, "posts/2013/index.html"
    end

    should "generate archive pages by month" do
      @archives.generate(@site)

      assert archive_exists? @site, "posts/2014/08/index.html"
      assert archive_exists? @site, "posts/2014/03/index.html"
    end

    should "generate archive pages by day" do
      @archives.generate(@site)

      assert archive_exists? @site, "posts/2014/08/17/index.html"
      assert archive_exists? @site, "posts/2013/08/16/index.html"
    end

    should "generate archive pages by tag" do
      @archives.generate(@site)

      assert archive_exists? @site, "posts/tag/test-tag/index.html"
      assert archive_exists? @site, "posts/tag/tagged/index.html"
      assert archive_exists? @site, "posts/tag/new/index.html"
    end

    should "generate archive pages by category" do
      @archives.generate(@site)

      assert archive_exists? @site, "posts/category/plugins/index.html"
    end

    should "generate archive pages with a layout" do
      @site.process

      assert_equal "Test", read_file("posts/tag/test-tag/index.html")
    end
  end

  context "the jekyll-archives-v2 plugin with a custom slug mode" do
    setup do
      # slug mode other than those expected by Jekyll returns the given string after
      # downcasing it.
      @site = fixture_site(
        "collections" => {
          "posts" => {
            "output" => true,
          },
        },
        "jekyll-archives" => {
          "posts" => {
            "slug_mode" => "raw",
            "enabled" => true,
          },
        }
      )
      @site.read
      @archives = Jekyll::ArchivesV2::Archives.new(@site.config)
    end

    should "generate slugs using the mode specified" do
      @archives.generate(@site)

      assert archive_exists? @site, "posts/category/💎/index.html"
    end
  end

  context "the jekyll-archives-v2 plugin with custom layout path" do
    setup do
      @site = fixture_site(
        "collections" => {
          "posts" => {
            "output" => true,
          },
        },
        "jekyll-archives" => {
          "posts" => {
            "layout"  => "archive-too",
            "enabled" => true,
          },
        }
      )
      @site.process
    end

    should "use custom layout" do
      @site.process

      assert_equal "Test too", read_file("posts/tag/test-tag/index.html")
    end
  end

  context "the jekyll-archives-v2 plugin with type-specific layout" do
    setup do
      @site = fixture_site(
        "collections" => {
          "posts" => {
            "output" => true,
          },
        },
        "jekyll-archives" => {
          "posts" => {
            "enabled" => true,
            "layouts" => {
              "year" => "archive-too",
            },
          },
        }
      )
      @site.process
    end

    should "use custom layout for specific type only" do
      assert_equal "Test too", read_file("/posts/2014/index.html")
      assert_equal "Test too", read_file("/posts/2013/index.html")
      assert_equal "Test", read_file("/posts/tag/test-tag/index.html")
    end
  end

  context "the jekyll-archives-v2 plugin with custom permalinks" do
    setup do
      @site = fixture_site(
        "collections" => {
          "posts" => {
            "output" => true,
          },
        },
        "jekyll-archives" => {
          "posts" => {
            "enabled" => true,
            "permalinks"   => {
              "year"       => "/:collection/year/:year/",
              "tags"       => "/tag-:name.html",
              "categories" => "/category-:name.html",
            },
          },
        }
      )
      @site.process
    end

    should "use the right permalink" do
      assert archive_exists? @site, "posts/year/2014/index.html"
      assert archive_exists? @site, "posts/year/2013/index.html"
      assert archive_exists? @site, "tag-test-tag.html"
      assert archive_exists? @site, "tag-new.html"
      assert archive_exists? @site, "category-plugins.html"
    end
  end

  context "the archives" do
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
      @site.process
    end

    should "populate the {{ site.archives }} tag in Liquid" do
      assert_equal 16, read_file("length.html").to_i
    end
  end

  context "the jekyll-archives-v2 plugin with default config" do
    setup do
      @site = fixture_site
      @site.process
    end

    should "not generate any archives" do
      assert_equal 0, read_file("length.html").to_i
    end
  end

  context "the jekyll-archives-v2 plugin with enabled array" do
    setup do
      @site = fixture_site("collections" => {
          "posts" => {
            "output" => true,
          },
        },
        "jekyll-archives" => {
          "posts" => {
            "enabled" => ["tags"],
          },
        }
      )
      @site.process
    end

    should "generate the enabled archives" do
      assert archive_exists? @site, "posts/tag/test-tag/index.html"
      assert archive_exists? @site, "posts/tag/tagged/index.html"
      assert archive_exists? @site, "posts/tag/new/index.html"
    end

    should "not generate the disabled archives" do
      refute archive_exists?(@site, "posts/2014/index.html")
      refute archive_exists?(@site, "posts/2014/08/index.html")
      refute archive_exists?(@site, "posts/2013/08/16/index.html")
      refute archive_exists?(@site, "posts/category/plugins/index.html")
    end
  end

  context "the jekyll-archives-v2 plugin" do
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
      @site.process
      @archives = @site.config["archives"]
      @tag_archive = @archives.detect { |a| a.type == "tags" }
      @category_archive = @archives.detect { |a| a.type == "categories" }
      @year_archive = @archives.detect { |a| a.type == "year" }
      @month_archive = @archives.detect { |a| a.type == "month" }
      @day_archive = @archives.detect { |a| a.type == "day" }
    end

    should "populate the title field in case of category or tag" do
      assert_kind_of String, @tag_archive.title
      assert_kind_of String, @category_archive.title
    end

    should "use nil for the title field in case of dates" do
      assert_nil @year_archive.title
      assert_nil @month_archive.title
      assert_nil @day_archive.title
    end

    should "use nil for the date field in case of category or tag" do
      assert_nil @tag_archive.date
      assert_nil @category_archive.date
    end

    should "populate the date field with a Date in case of dates" do
      assert_kind_of Date, @year_archive.date
      assert_kind_of Date, @month_archive.date
      assert_kind_of Date, @day_archive.date
    end
  end

  context "the jekyll-archives-v2 plugin with a non-hash config" do
    should "output a warning" do
      output = capture_output do
        site = fixture_site("jekyll-archives" => %w(apples oranges))
        site.read
        site.generate
      end

      assert_includes output, "Archives: Expected a hash but got [\"apples\", \"oranges\"]"
      assert_includes output, "Archives will not be generated for this site."

      output = capture_output do
        site = fixture_site("jekyll-archives" => nil)
        site.read
        site.generate
      end

      assert_includes output, "Archives: Expected a hash but got nil"
      assert_includes output, "Archives will not be generated for this site."
    end

    should "not generate archive pages" do
      capture_output do
        site = fixture_site("jekyll-archives" => nil)
        site.read
        site.generate

        assert_nil(site.pages.find { |p| p.is_a?(Jekyll::ArchivesV2::Archive) })
      end
    end

    should "be fine with a basic config" do
      output = capture_output do
        @site = fixture_site("title" => "Hello World")
        @site.read
        @site.generate
      end

      refute_includes output, "Archives: Expected a hash but got nil"
      assert_nil(@site.pages.find { |p| p.is_a?(Jekyll::ArchivesV2::Archive) })
    end
  end
end
