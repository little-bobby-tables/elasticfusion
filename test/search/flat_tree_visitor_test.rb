require 'test_helper'
require 'search/ast_helper'
require 'elasticfusion/search/visitors/flat_tree_visitor'

class SearchFlatTreeVisitorTest < ActiveSupport::TestCase
  test 'node flatenning' do
    assert_equal expression(:and, term('pearl'), [term('ruby'), term('sapphire'), negated(term('amethyst'))]),
                 visitor.flatten(expression(:and, term('pearl'),
                                            expression(:and, term('ruby'),
                                                       expression(:and, term('sapphire'),
                                                                  negated(term('amethyst'))))))
  end
end
