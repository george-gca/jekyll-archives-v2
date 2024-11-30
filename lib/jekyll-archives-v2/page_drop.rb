# frozen_string_literal: true

module Jekyll
  module ArchivesV2
    class PageDrop < Jekyll::Drops::Drop
      extend Forwardable

      mutable false

      def_delegators :@obj, :collection_name, :documents, :type, :title, :date, :name, :path, :url, :permalink
      private def_delegator :@obj, :data, :fallback_data
    end
  end
end
