module Elasticfusion
  module Search
    class SearchError < StandardError
    end

    class ImbalancedParenthesesError < StandardError
      attr_reader :near

      def initialize(near)
        @near = near
      end

      def message
        "Imbalanced parentheses near #{near}"
      end
    end

    class UnknownFieldError < SearchError
      attr_reader :field

      def initialize(field)
        @field = field
      end

      def message
        "\"#{field}\" is not a searchable field."
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
  end
end
