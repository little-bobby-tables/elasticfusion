# frozen_string_literal: true
module Elasticfusion
  module Search
    class SearchError < StandardError
    end

    class ImbalancedParenthesesError < SearchError
      def message
        'Imbalanced parentheses.'
      end
    end

    class InvalidFieldValueError < SearchError
      attr_reader :field, :value

      def initialize(field, value)
        @field = field
        @value = value
      end

      def message
        "\"#{value}\" is not a valid value for \"#{field}\"."
      end
    end

    class InvalidSortOrderError < SearchError
      def message
        'Invalid sort order. Accepted values: "desc" and "asc".'
      end
    end
  end
end
