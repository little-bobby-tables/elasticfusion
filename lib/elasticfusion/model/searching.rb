require 'elasticfusion/custom_search'

module Elasticfusion
  module Model
    module Searching
      def self.included(model)
        model.class_eval do
          def custom_search(&block)
            CustomSearch.new searchable_mapping: self.class.elasticfusion.searchable_mapping,
                             keyword_field: self.class.elasticfusion[:keyword_field],
                             &block
          end

          def search_by_query(query, &block)
            CustomSearch.new searchable_mapping: self.class.elasticfusion.searchable_mapping,
                             keyword_field: self.class.elasticfusion[:keyword_field],
                             query: query,
                             &block
          end
        end
      end
    end
  end
end
