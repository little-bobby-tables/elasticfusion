require 'test_helper'
require 'search/ast_helper'

class PolyadicTreeVisitorTest < ActiveSupport::TestCase
  test 'flattens right-leaning tree' do
    assert_equal polyadic(:and, [term('pearl'), term('ruby'), term('sapphire'), negated(term('amethyst'))]),
                 visitor.rewrite(expression(:and, term('pearl'),
                                            expression(:and, term('ruby'),
                                                       expression(:and, term('sapphire'),
                                                                  negated(term('amethyst'))))))
  end

  test 'flattens left-leaning tree' do
    assert_equal polyadic(:and, [term('sapphire'), negated(term('amethyst')), term('ruby'), term('pearl')]),
                 visitor.rewrite(expression(:and, expression(:and, expression(:and, term('sapphire'),
                                                                              negated(term('amethyst'))),
                                                                   term('ruby')),
                                                             term('pearl')))
  end

  test 'flattens sub-trees' do
    expected =  polyadic(:and, [polyadic(:or,
                                         [term('ruby'),
                                          term('sapphire'),
                                          polyadic(:and, [term('pearl'), term('amethyst')]),
                                          term('garnet')]),
                                polyadic(:or,
                                         [negated(polyadic(:or,
                                                           [term('peridot'),
                                                            term('lapis'),
                                                            term('lazuli')])),
                                          term('steven'),
                                          negated(term('gem')),
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
    assert_equal expected, visitor.rewrite(input)
  end

  def visitor
    Elasticfusion::Search::PolyadicTreeVisitor.new
  end
end
