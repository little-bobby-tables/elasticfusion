require 'elasticfusion/search/visitors/polyadic_tree_visitor'

module Elasticfusion
  module Search
    class ESVisitor < PolyadicTreeVisitor
      def initialize(mapping:, keyword_field:)
        @mapping = mapping
        @keyword_field = keyword_field
      end

      OPERATORS = { and: :must,
                    or:  :should }.freeze

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

        { bool: { must_not: clause }}
      end

      def visit_Term(node)
        { term: { @keyword_field => node.body } }
      end
    end
  end
end
