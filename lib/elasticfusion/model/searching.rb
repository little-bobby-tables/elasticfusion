require 'elasticfusion/custom_search'

module Elasticfusion
  module Model
    module Searching
      def self.included(model)
        model.class_eval do
          def self.custom_search(size: nil, from: nil, &block)
            body = CustomSearch.new(self, &block)
              .elasticsearch_client_request(size: size, from: from)
            self.search(body)
          end

          def self.search_by_query(query, size: nil, from: nil, &block)
            body = CustomSearch.new(self, query, &block)
              .elasticsearch_client_request(size: size, from: from)
            self.search(body)
          end
        end
     end
    end
  end
end
