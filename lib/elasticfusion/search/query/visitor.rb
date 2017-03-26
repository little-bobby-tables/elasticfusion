# frozen_string_literal: true
module Elasticfusion
  module Search
    module Query
      class Visitor
        def accept(node)
          visit(node)
        end

        # Roughly based on https://github.com/rails/arel/blob/7-1-stable/lib/arel/visitors/visitor.rb.

        def visit(node)
          send Visitor.visitor_method(node), node
        end

        def self.visitor_method(node)
          (@visitor_methods ||= {})[node.class] ||= "visit_#{node.class.name.demodulize}"
        end
      end
    end
  end
end
