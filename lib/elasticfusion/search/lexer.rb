# frozen_string_literal: true
require 'strscan'

module Elasticfusion
  module Search
    class Lexer
      TOKENS = {
        whitespace: /\s+/,
        binary_operator: /,|OR/,
        negation: /NOT/,
        field_query_delimiter: /:/,
        field_qualifier: /less than|more than|earlier than|later than/,

        safe_string_until: /(\s*)(,|OR|NOT|"|\(|\))/,
        quoted_string: /"(?:[^\\]|\\.)*?"/,
        string_with_balanced_parentheses_until: /,|OR|NOT/
      }

      def initialize(string, queryable_fields)
        @scanner = StringScanner.new(string)
        @field_regex = /(#{queryable_fields.join('|')}):/ if queryable_fields.any?
      end

      def match(token)
        @scanner.scan TOKENS[token]
      end

      def skip(token)
        @scanner.skip TOKENS[token]
      end

      def match_field
        return unless @field_regex
        field = @scanner.scan @field_regex
        if field
          field[0..-2] # remove field query delimiter (":")
        end
      end

      def left_parentheses
        @scanner.skip /\(/
      end

      def right_parentheses(expected_count)
        @scanner.skip /\){,#{expected_count}}/
      end

      # May contain words, numbers, spaces, dashes, and underscores.
      def safe_string
        match_until TOKENS[:safe_string_until]
      end

      # May contain any characters except for quotes (the latter are allowed when escaped).
      def quoted_string
        string = match(:quoted_string)

        if string
          string[1..-2] # ignore quotes
            .gsub(/\\"/, '"')
            .gsub(/\\\\/, '\\')
        end
      end

      def string_with_balanced_parentheses
        string = match_until TOKENS[:string_with_balanced_parentheses_until]

        if string
          opening_parens = string.count('(')

          balanced = string.split(')')[0..opening_parens].join(')')
          balanced += ')' if opening_parens > 0 && string.ends_with?(')')

          cutoff = string.length - balanced.length
          @scanner.pos -= cutoff

          balanced.strip
        end
      end

      # StringScanner#scan_until returns everything up to and including the regex.
      # To avoid including the pattern, we use a lookahead.
      def match_until(regex)
        @scanner.scan /.+?(?=#{regex.source}|\z)/
      end
    end
  end
end
