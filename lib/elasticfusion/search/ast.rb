# frozen_string_literal: true
module Elasticfusion
  module Search
    Expression = Struct.new(:op, :left, :right)

    # See visitors/polyadic_tree_visitor.rb
    PolyadicExpression = Struct.new(:op, :children)

    NegatedClause = Struct.new(:body)

    FieldTerm = Struct.new(:field, :qualifier, :value)

    Term = Struct.new(:body)
  end
end
