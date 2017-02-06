require 'elasticfusion/search/visitor'

module Elasticfusion
  module Search
    # FlatTreeVisitor is a base class for visitors that
    # require leaf nodes with a common operator to be flattened, e.g.
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

      def flatten(node)

      end
    end
  end
end
