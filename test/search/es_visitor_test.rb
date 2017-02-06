require 'test_helper'
require 'search/ast_helper'
require 'elasticfusion/search/visitors/es_visitor'

class SearchESVisitorTest < ActiveSupport::TestCase
  test 'term query' do
    assert_equal({ term: { tags: 'peridot' } },
                 from_ast(term('peridot')))

  end

  test 'conjunction' do

  end

  def from_ast(ast, main_field = :tags, mapping = {})
    visitor(main_field, mapping).ast_to_es_query(ast)
  end

  def visitor(main_field = :tags, mapping = {})
    Elasticfusion::Search::ESVisitor.new(keyword_field: main_field, mapping: mapping)
  end
end
