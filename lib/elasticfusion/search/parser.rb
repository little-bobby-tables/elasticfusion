# frozen_string_literal: true
require 'elasticfusion/search/lexer'
require 'elasticfusion/search/ast'

module Elasticfusion
  module Search
    class Parser
      def initialize(query, searchable_fields = [])
        @lexer = Lexer.new(query, searchable_fields)
      end

      delegate :match, :skip,
               :match_field, :left_parentheses, :right_parentheses,
               :safe_string, :quoted_string, :string_with_balanced_parentheses, to: :@lexer

      # query                    = disjunction
      #                          ;
      # disjunction              = conjunction , [ ( "OR" | "|" ) , disjunction ]
      #                          ;
      # conjunction              = boolean clause , [ ( "AND" | "," ) , conjunction ]
      #                          ;
      # boolean clause           = ( "NOT" | "-" ) , boolean clause
      #                          | clause
      #                          ;
      # clause                   = parenthesized expression
      #                          | field term
      #                          | term
      #                          ;
      # parenthesized expression = "(" , disjunction , ")"
      #                          ;
      # field term               = field , ":" , [ field qualifier ] , safe string
      #                          ;
      # term                     = quoted string
      #                          | string with balanced parentheses
      #                          ;

      def ast
        disjunction
      end

      def disjunction
        skip :whitespace
        left = conjunction

        skip :whitespace
        connective = match :or

        skip :whitespace
        right = disjunction if connective

        if right
          Expression.new :or, left, right
        else
          left
        end
      end

      def conjunction
        skip :whitespace
        left = boolean_clause

        skip :whitespace
        connective = match :and

        skip :whitespace
        right = conjunction if connective

        if right
          Expression.new :and, left, right
        else
          left
        end
      end

      def boolean_clause
        negation = match :not
        skip :whitespace

        if negation
          body = boolean_clause
          redundant_negation = body.is_a?(NegatedClause)

          if redundant_negation
            body.body
          else
            NegatedClause.new body
          end
        else
          clause
        end
      end

      def clause
        parenthesized_expression || field_term || term
      end

      def parenthesized_expression
        opening_parens = left_parentheses

        if opening_parens
          body = disjunction
          closing_parens = right_parentheses(opening_parens)

          if opening_parens == closing_parens
            body
          else
            raise ImbalancedParenthesesError
          end
        end
      end

      def field_term
        field = match_field

        if field
          qualifier = field_qualifier

          skip :whitespace if qualifier

          field_query = safe_string

          FieldTerm.new field, qualifier, field_query
        end
      end

      def term
        string = quoted_string || string_with_balanced_parentheses

        Term.new string
      end

      FIELD_QUALIFIERS = { 'less than' => :lt,
                           'more than' => :gt,
                           'earlier than' => :lt,
                           'later than' => :gt }.freeze

      def field_qualifier
        skip :whitespace

        qualifier = match :field_qualifier
        FIELD_QUALIFIERS[qualifier]
      end
    end
  end
end
