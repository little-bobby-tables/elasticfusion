require 'elasticfusion/search/visitors/flat_tree_visitor'

module Elasticfusion
  module Search
    class ESVisitor < FlatTreeVisitor
      def initialize(mapping:, keyword_field:)
        @mapping = mapping
        @keyword_field = keyword_field
      end

      def visit_subtree(leaf)
        if leaf.respond_to?(:map)
          leaf.map { |n| visit(n) }
        else
          visit(leaf)
        end
      end

      def visit_Expression(node)
        left = visit_subtree(node.left)

        if node.op
          right = visit_subtree(node.right)

          if node.op == :and
            { bool: { must: [left, right].flatten }}
          end
          if node.op == :or
            { bool: { should: [left, right].flatten }}
          end
        else
          left
        end
      end

      def visit_Term(node)
        { term: { @keyword_field => node.body } }
      end
    end
  end
end
