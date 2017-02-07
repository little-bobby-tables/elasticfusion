require 'elasticfusion/search/visitor'

module Elasticfusion
  module Search
    # FlatTreeVisitor is a base class for visitors that require
    # sub-trees with a common operator to be flattened to lists, e.g.
    #
    #    and                     and
    #  /     \                 /     \
    # A      and      --->    A     [B, C, D]
    #      /     \
    #     B      and
    #          /     \
    #         C       D
    class FlatTreeVisitor < Visitor
      def accept(node)
        super(flatten(node))
      end

      def flatten(node, parent: nil)
        case node
          when NegatedClause
            node.body = flatten(node.body)
          when Expression
            node.left = flatten(node.left, parent: node)
            node.right = flatten(node.right, parent: node)
            if parent && node.op && node.op == parent.op
              return [node.left, node.right].flatten
            end
        end
        node
      end
    end
  end
end
