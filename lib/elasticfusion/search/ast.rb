module Elasticfusion
  module Search
    class Expression < Struct.new(:op, :left, :right)
    end

    # See visitors/polyadic_tree_visitor.rb
    class PolyadicExpression < Struct.new(:op, :children)
    end

    class NegatedClause < Struct.new(:body)
    end

    class FieldTerm < Struct.new(:field, :qualifier, :query)
    end

    class Term < Struct.new(:body)
    end
  end
end
