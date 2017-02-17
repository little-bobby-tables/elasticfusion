require 'chronic'

module Elasticfusion
  module Search
    class ESValueSanitizer
      def initialize(mapping)
        @mapping = mapping
      end

      def value(value, field:)
        case @mapping[field.to_sym][:type]
          when 'keyword'
            value
          when 'integer'
            es_integer(value, field: field)
          when 'date'
            es_date(value, field: field)
          else
            nil
        end
      end

      private

      def es_integer(string, field:)
        if string =~ /\A[+-]?\d+\z/
          string
        else
          raise InvalidFieldValueError.new(field, string)
        end
      end

      def es_date(string, field:)
        parsed = Chronic.parse(string)

        if parsed.nil?
          raise InvalidFieldValueError.new(field, string)
        else
          parsed.iso8601
        end
      end
    end
  end
end
