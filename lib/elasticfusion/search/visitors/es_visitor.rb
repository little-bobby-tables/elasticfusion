require 'elasticfusion/search/visitor'

module Elasticfusion
  module Search
    class ESVisitor < Visitor
      def initialize(mapping:, keyword_field:)
        @mapping = mapping
        @keyword_field = keyword_field
      end

      def ast_to_es_query(ast)
        @query = { query: {} }
        visit ast
        @query
      end

      def visit_Expression(node)
        left = visit(node.left)

        if node.op == :and
          @query[]
        end


        if node.op
          right = visit(node.right)
          { bool: { must: [

          ] } }
        end
      end

      def visit_Term(node)
        { term: { @keyword_field => node.body } }
      end
    end
  end
end
