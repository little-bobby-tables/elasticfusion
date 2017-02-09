require 'test_helper'
require 'ast_helper'

class ParserTest < ActiveSupport::TestCase
  test 'single terms' do
    assert_equal term('peridot'),
                 query('peridot')

    assert_equal negated(term('lapis lazuli')),
                 query('NOT lapis lazuli')
  end

  test 'redundant negation' do
    assert_equal negated(term('peridot')),
                 query('NOT NOT NOT NOT NOT peridot')

    assert_equal term('peridot'),
                 query('NOT NOT NOT NOT NOT NOT peridot')
  end

  test 'single conjunction and disjunction' do
    assert_equal expression(:and, term('peridot'), term('lapis lazuli')),
                 query('peridot, lapis lazuli')

    assert_equal expression(:or, term('peridot'), term('lapis lazuli')),
                 query('peridot OR lapis lazuli')
  end

  test 'operator precedence and associativity' do
    assert_equal expression(:and, term('pearl'), expression(:or, term('ruby'), term('sapphire'))),
                 query('pearl, ruby OR sapphire')

    assert_equal expression(:and, negated(term('pearl')), negated(term('ruby'))),
                 query('NOT pearl, NOT ruby')

    assert_equal expression(:or, negated(term('pearl')), negated(term('ruby'))),
                 query('NOT pearl OR NOT ruby')
  end

  test 'parenthesized expressions' do
    assert_equal expression(:or, term('pearl'), expression(:and, term('ruby'), term('sapphire'))),
                 query('pearl OR (ruby, sapphire)')
  end

  test 'nested parenthesized expressions' do
    assert_equal expression(:or, term('pearl'),
                            expression(:and, term('nested'),
                                       negated(expression(:or, negated((expression(:and, term('ruby'),
                                                                                   term('sapphire')))),
                                                          term('pearl'))))),
                 query('pearl OR (nested, NOT (NOT (ruby, sapphire) OR pearl))')
  end

  test 'complex string terms' do
    # string with balanced parentheses
    assert_equal expression(:or, term('pearl (yellow diamond)'),
                            expression(:and, term('pearl (blue diamond)'), term('pearl'))),
                 query('pearl (yellow diamond) OR (pearl (blue diamond), pearl)')

    # quoted string
    assert_equal expression(:or, term('"quoted" string'),
                            expression(:and, term('pearl'), term('string with special characters =('))),
                 query('"\"quoted\" string" OR (pearl, "string with special characters =(")')
  end

  test 'simple field queries' do
    assert_equal field_term('date', '3 years ago'),
                 query('date:3 years ago', [:date])

    assert_equal negated(field_term('date', '3 years ago')),
                 query('NOT date:3 years ago', [:date])
  end

  test 'field queries require a delimiter' do
    assert_equal expression(:and, term('date'), field_term('date', '3 years ago')),
                 query('date, date:3 years ago', [:date])
  end

  test 'field queries as a part of a complex expression' do
    assert_equal expression(:or, term('pearl'),
                            negated(expression(:and, field_term('date', '3 years ago'),
                                               expression(:and, field_term('stars', '5'), term('ruby'))))),
                 query('pearl OR NOT (date:3 years ago, stars:5, ruby)', [:date, :stars])
  end

  test 'field queries with a qualifier' do
    assert_equal field_term('date', :lt, '3 years ago'),
                 query('date:earlier than 3 years ago', [:date])

    assert_equal field_term('stars', :gt, '50'),
                 query('stars: more than 50', [:stars])

    assert_equal expression(:and, field_term('date', :gt, '2016'),
                            field_term('stars', :lt, '10')),
                 query('date: later than 2016, stars: less than 10', [:date, :stars])
  end

  test 'whitespace' do
    assert_equal expression(:and, term('pearl'), expression(:or, term('ruby'), negated(term('sapphire')))),
                 query('pearl  ,    ruby       OR   NOT    sapphire')
    assert_equal expression(:and, term('pearl'), expression(:or, term('ruby'), negated(term('sapphire')))),
                 query('pearl,rubyORNOTsapphire')

    assert_equal expression(:or, term('pearl ( yellow    diamond )'),
                            expression(:and, term('pearl (blue diamond)'), term('pearl'))),
                 query('pearl ( yellow    diamond )      OR       (    pearl (blue diamond),        pearl    )')

    assert_equal field_term('stars', :gt, '50'),
                 query('stars:more than50', [:stars])

    assert_equal field_term('stars', :gt, '50'),
                 query('stars:      more than         50', [:stars])
  end

  test 'imbalanced parentheses' do
    assert_raises Elasticfusion::Search::ImbalancedParenthesesError do
      query('(peridot OR lapis lazuli')
    end
  end
end
