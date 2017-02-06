module Elasticfusion
  module Search
    class Visitor
      def accept(node)
        visit(node)
      end

      protected

      # Roughly based on https://github.com/rails/arel/blob/a04851702b0e8e694a92139c3ee9f3b1622f3f5d/lib/arel/visitors/visitor.rb

      def visit(node)
        send Visitor.visitor_method(node), node
      end

      def self.visitor_method(node)
        (@visitor_methods ||= {})[node.class] ||= "visit_#{node.class.name.demodulize}"
      end
    end
  end
end
