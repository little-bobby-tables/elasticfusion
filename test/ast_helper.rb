# frozen_string_literal: true
def query(string, fields = [])
  Elasticfusion::Search::Query::Parser.new(string, fields).ast
end

def expression(op, left, right)
  Elasticfusion::Search::Query::Expression.new(op, left, right)
end

def polyadic(op, children)
  Elasticfusion::Search::Query::PolyadicExpression.new(op, children)
end

def term(body)
  Elasticfusion::Search::Query::Term.new(body)
end

def negated(body)
  Elasticfusion::Search::Query::NegatedClause.new(body)
end

def field_term(field, qualifier = nil, query)
  Elasticfusion::Search::Query::FieldTerm.new(field, qualifier, query)
end
