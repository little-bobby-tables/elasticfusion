def query(string, fields = [])
  Elasticfusion::Search::Parser.new(string, fields).ast
end

def expression(op, left, right)
  Elasticfusion::Search::Expression.new(op, left, right)
end

def polyadic(op, children)
  Elasticfusion::Search::PolyadicExpression.new(op, children)
end

def term(body)
  Elasticfusion::Search::Term.new(body)
end

def negated(body)
  Elasticfusion::Search::NegatedClause.new(body)
end

def field_term(field, qualifier = nil, query)
  Elasticfusion::Search::FieldTerm.new(field, qualifier, query)
end
