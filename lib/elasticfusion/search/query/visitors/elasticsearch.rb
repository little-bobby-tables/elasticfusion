# frozen_string_literal: true
require 'elasticfusion/search/query/visitors/polyadic_tree'
require 'elasticfusion/search/query/value_sanitizer'

module Elasticfusion
  module Search
    module Query
      module Visitors
        class Elasticsearch < PolyadicTree
          def initialize(keyword_field, mapping)
            @keyword_field = keyword_field
            @sanitizer = ValueSanitizer.new(mapping)
          end

          OPERATORS = { and: :must,
                        or: :should }.freeze

          def visit_PolyadicExpression(node)
            operator = OPERATORS[node.op]
            operands = node.children.map { |n| visit(n) }

            { bool: { operator => operands } }
          end

          def visit_NegatedClause(node)
            clause = if node.body.respond_to?(:op) && node.body.op == :and
              node.body.children.map { |n| visit(n) }
            else
              [visit(node.body)]
            end

            { bool: { must_not: clause } }
          end

          def visit_FieldTerm(node)
            value = @sanitizer.value(node.value, field: node.field)

            if node.qualifier
              { range: { node.field.to_sym => { node.qualifier => value } } }
            else
              { term: { node.field.to_sym => value } }
            end
          end

          def visit_Term(node)
            { term: { @keyword_field => node.body } }
          end
        end
      end
    end
  end
end
