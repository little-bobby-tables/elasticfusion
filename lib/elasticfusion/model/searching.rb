# frozen_string_literal: true
require 'elasticfusion/search/wrapper'

module Elasticfusion
  module Model
    module Searching
      def self.included(model)
        model.class_eval do
          def self.custom_search(query = nil, &block)
            Search::Wrapper.new(self, query, &block)
          end
        end
      end
    end
  end
end
