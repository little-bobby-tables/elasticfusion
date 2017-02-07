require 'test_helper'
require 'search/ast_helper'
require 'elasticfusion/search/visitors/flat_tree_visitor'

class SearchFlatTreeVisitorTest < ActiveSupport::TestCase
  test 'flattens right-leaning conjunction' do
    assert_equal expression(:and, term('pearl'), [term('ruby'), term('sapphire'), negated(term('amethyst'))]),
                 visitor.flatten(expression(:and, term('pearl'),
                                            expression(:and, term('ruby'),
                                                       expression(:and, term('sapphire'),
                                                                  negated(term('amethyst'))))))
  end

  test 'flattens left-leaning conjunction' do
    assert_equal expression(:and, [term('sapphire'), negated(term('amethyst')), term('ruby')], term('pearl')),
                 visitor.flatten(expression(:and, expression(:and, expression(:and, term('sapphire'),
                                                                              negated(term('amethyst'))),
                                                                   term('ruby')),
                                                             term('pearl')))
  end

  test 'flattens nested expressions' do
    expected =  expression(:and, expression(:or,
                                            [term('ruby'),
                                             term('sapphire')],
                                            [expression(:and, term('pearl'), term('amethyst')),
                                             term('garnet')]),
                                 [expression(:or,
                                            [negated(expression(:or,
                                                        term('peridot'),
                                                        [term('lapis'),
                                                         term('lazuli')])),
                                             term('steven')],
                                            [negated(term('gem')),
                                             term('diamond')]),
                                  term('too much?')])

    input = expression(:and, expression(:or,
                                        expression(:or, term('ruby'), term('sapphire')),
                                        expression(:or, expression(:and, term('pearl'), term('amethyst')),
                                                        term('garnet'))),
                             expression(:and,
                                        expression(:or, expression(:or,
                                                                   negated(expression(:or,
                                                                                      term('peridot'),
                                                                                      expression(:or, term('lapis'), term('lazuli')))),
                                                                   term('steven')),
                                                        expression(:or, negated(term('gem')), term('diamond'))),
                                        term('too much?')))
    assert_equal expected, visitor.flatten(input)
  end

  def visitor
    Elasticfusion::Search::FlatTreeVisitor.new
  end
end
