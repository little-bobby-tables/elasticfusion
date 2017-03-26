# frozen_string_literal: true
require 'elasticfusion/search/wrapper'

module Elasticfusion
  module Model
    module Searching
      def self.included(model)
        model.class_eval do
          def self.custom_search(query = nil,
                                 size: nil, from: nil,
                                 &block)
            request = Search::Wrapper.new(self, query, &block)
              .elasticsearch_request

            request[:size] = size if size
            request[:from] = from if from

            self.search(request)
          end
        end
      end
    end
  end
end
