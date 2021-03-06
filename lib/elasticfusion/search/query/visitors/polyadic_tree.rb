# frozen_string_literal: true
require 'elasticfusion/search/query/visitor'
require 'elasticfusion/search/query/ast'

module Elasticfusion
  module Search
    module Query
      module Visitors
        # +PolyadicTree+ is a base class for visitors that accept
        # more than two operands for logical expressions.
        # It converts a binary tree into multi-way tree, replacing all
        # +Expression+ nodes with +PolyadicExpression+ nodes.
        #
        # Given an AST:
        #
        #    and
        #  /     \
        # A      and
        #      /     \
        #     B      and
        #          /     \
        #         C       or
        #               /   \
        #              D     E
        #
        # A polyadic representation would be:
        #
        #      and
        #  /  /   \   \
        # A  B    C   or
        #            /  \
        #           D    E

        class PolyadicTree < Visitor
          def accept(node)
            super(rewrite(node))
          end

          def rewrite(node, parent: nil)
            case node
            when NegatedClause
              node.body = rewrite(node.body)
            when Expression
              flattened = [rewrite(node.left, parent: node),
                           rewrite(node.right, parent: node)].flatten

              if parent && node.op && node.op == parent.op
                return flattened
              else
                return PolyadicExpression.new(node.op, flattened)
              end
            end
            node
          end
        end
      end
    end
  end
end
