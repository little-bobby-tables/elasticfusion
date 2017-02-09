module Elasticfusion
  module Model
    class Settings
      def [](key)
        hash[key]
      end

      def keyword_field(field)
        hash[:keyword_field] = field
      end

      def reindex_when_updated(attributes)
        hash[:reindex_when_updated] = attributes
      end

      def hash
        @hash ||= {}
      end
    end
  end
end
