# frozen_string_literal: true

require "jekyll"

module Jekyll
  module ArchivesV2
    # Internal requires
    autoload :Archive,  "jekyll-archives-v2/archive"
    autoload :PageDrop, "jekyll-archives-v2/page_drop"
    autoload :VERSION,  "jekyll-archives-v2/version"

    class Archives < Jekyll::Generator
      safe true

      def initialize(config = {})
        defaults = {}
        config.fetch("collections", {}).each do |name, collection|
          defaults[name] = {
            "layout"     => "archive",
            "enabled"    => [],
            "permalinks" => {
              "year"     => "/:collection/:year/",
              "month"    => "/:collection/:year/:month/",
              "day"      => "/:collection/:year/:month/:day/",
              "tags"      => "/:collection/:type/:name/",
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
      def read(collection)
        if @config[collection]["enabled"].is_a?(Array)
          if enabled?(collection, "year") || enabled?(collection, "month") || enabled?(collection, "day")
            read_dates(collection)
          end

          # read all attributes that are not year, month, or day
          attributes = @config[collection]["enabled"].select { |attr| !["year", "month", "day"].include?(attr) }

          attributes.each do |attr|
            read_attrs(collection, attr)
          end

        elsif @config[collection]["enabled"] == true || @config[collection]["enabled"] == "all"
          read_dates(collection)

          # create a list of all attributes
          attributes = @collections[collection].docs.flat_map { |doc| doc.data.keys }.uniq
          # discard any attribute that is not an array
          attributes.reject! { |attr| @collections[collection].docs.all? { |doc| !doc.data[attr].is_a?(Array) } }

          attributes.each do |attr|
            read_attrs(collection, attr)
          end
        end
      end

      def read_attrs(collection, attr)
        doc_attr_hash(@collections[collection], attr).each do |title, documents|
          @archives << Archive.new(@site, title, attr, collection, documents)
        end
      end

      def read_dates(collection)
        years(@collections[collection]).each do |year, y_documents|
          append_enabled_date_type({ :year => year }, "year", collection, y_documents)
          months(y_documents).each do |month, m_documents|
            append_enabled_date_type({ :year => year, :month => month }, "month", collection, m_documents)
            days(m_documents).each do |day, d_documents|
              append_enabled_date_type({ :year => year, :month => month, :day => day }, "day", collection, d_documents)
            end
          end
        end
      end

      # Checks if archive type is enabled in config
      def enabled?(collection, archive)
        @config[collection]["enabled"] == true || @config[collection]["enabled"] == "all" || (@config[collection]["enabled"].is_a?(Array) && @config[collection]["enabled"].include?(archive))
      end

      # Custom `post_attr_hash` method for years
      def years(documents)
        date_attr_hash(documents.docs, "%Y")
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
      # meta       - A Hash of the year / month / day as applicable for date.
      # type       - The type of date archive.
      # collection - the name of the collection
      # documents  - The array of documents that belong in the date archive.
      def append_enabled_date_type(meta, type, collection, documents)
        @archives << Archive.new(@site, meta, type, collection, documents) if enabled?(collection, type)
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
