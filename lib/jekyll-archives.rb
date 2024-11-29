# frozen_string_literal: true

require "jekyll"

module Jekyll
  module Archives
    # Internal requires
    autoload :Archive,  "jekyll-archives/archive"
    autoload :PageDrop, "jekyll-archives/page_drop"
    autoload :VERSION,  "jekyll-archives/version"

    class Archives < Jekyll::Generator
      safe true

      def initialize(config = {})
        defaults = {}
        config.fetch("collections", {}).each do |name, collection|
          defaults[name] = {
            "layout"     => "archive",
            "enabled"    => [],
            "permalinks" => {
              "year"     => "/#{name}/:year/",
              "month"    => "/#{name}/:year/:month/",
              "day"      => "/#{name}/:year/:month/:day/",
              "tag"      => "/#{name}/tag/:name/",
              "category" => "/#{name}/category/:name/",
            },
          }
        end
        defaults.freeze
        archives_config = config.fetch("jekyll-archives", {})
        if archives_config.is_a?(Hash)
          @config = Utils.deep_merge_hashes(defaults, archives_config)
        else
          @config = nil
          Jekyll.logger.warn "Archives:", "Expected a hash but got #{archives_config.inspect}"
          Jekyll.logger.warn "", "Archives will not be generated for this site."
        end
      end

      def generate(site)
        return if @config.nil?

        @site = site
        @collections = site.collections
        @archives = []

        @site.config["jekyll-archives"] = @config

        # loop through collections keys and read them
        @config.each do |collection_name, collection_config|
          read(collection_name)
        end

        @site.pages.concat(@archives)
        @site.config["archives"] = @archives
      end

      # Read archive data from collection
      def read(collection_name)
        if enabled?(collection_name, "tags")
          read_tags(collection_name)
        end

        if enabled?(collection_name, "categories")
          read_categories(collection_name)
        end

        if enabled?(collection_name, "year") || enabled?(collection_name, "month") || enabled?(collection_name, "day")
          read_dates(collection_name)
        end
      end

      def read_tags(collection_name)
        tags(@collections[collection_name]).each do |title, documents|
          @archives << Archive.new(@site, title, "tag", collection_name, documents)
        end
      end

      def read_categories(collection_name)
        categories(@collections[collection_name]).each do |title, documents|
          @archives << Archive.new(@site, title, "category", collection_name, documents)
        end
      end

      def read_dates(collection_name)
        years(@collections[collection_name]).each do |year, y_documents|
          append_enabled_date_type({ :year => year }, "year", collection_name, y_posts)
          months(y_documents).each do |month, m_documents|
            append_enabled_date_type({ :year => year, :month => month }, "month", collection_name, m_posts)
            days(m_documents).each do |day, d_documents|
              append_enabled_date_type({ :year => year, :month => month, :day => day }, "day", collection_name, d_posts)
            end
          end
        end
      end

      # Checks if archive type is enabled in config
      def enabled?(collection_name, archive)
        @enabled == true || @enabled == "all" || (@enabled.is_a?(Array) && @enabled.include?(archive))
      end

      def tags(documents)
        doc_attr_hash(documents, "tags")
      end

      def categories(documents)
        doc_attr_hash(documents, "categories")
      end

      # Custom `post_attr_hash` method for years
      def years(documents)
        date_attr_hash(documents, "%Y")
      end

      # Custom `post_attr_hash` method for months
      def months(year_documents)
        date_attr_hash(year_documents, "%m")
      end

      # Custom `post_attr_hash` method for days
      def days(month_documents)
        date_attr_hash(month_documents, "%d")
      end

      private

      # Initialize a new Archive page and append to base array if the associated date `type`
      # has been enabled by configuration.
      #
      # meta            - A Hash of the year / month / day as applicable for date.
      # type            - The type of date archive.
      # collection_name - the name of the collection
      # documents       - The array of documents that belong in the date archive.
      def append_enabled_date_type(meta, type, collection_name, documents)
        @archives << Archive.new(@site, meta, type, collection_name, documents) if enabled?(collection_name, type)
      end

      # Custom `post_attr_hash` for date type archives.
      #
      # documents - Array of documents to be considered for archiving.
      # id        - String used to format post date via `Time.strptime` e.g. %Y, %m, etc.
      def date_attr_hash(documents, id)
        hash = Hash.new { |hsh, key| hsh[key] = [] }
        documents.each { |document| hash[document.date.strftime(id)] << document }
        hash.each_value { |documents| documents.sort!.reverse! }
        hash
      end

      # Custom `post_attr_hash` for any collection.
      #
      # documents - Array of documents to be considered for archiving.
      # doc_attr  - The String name of the Document attribute.
      def doc_attr_hash(documents, doc_attr)
        # Build a hash map based on the specified document attribute ( doc_attr =>
        # array of elements from collection ) then sort each array in reverse order.
        hash = Hash.new { |h, key| h[key] = [] }
        documents.docs.each { |document| document.data[doc_attr]&.each { |t| hash[t] << document } }
        hash.each_value { |documents| documents.sort!.reverse! }
        hash
      end
    end
  end
end
