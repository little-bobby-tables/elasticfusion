require 'test_helper'
require 'dummy_model'
require 'search/ast_helper'
require 'elasticfusion/search/visitors/es_visitor'

class SearchESVisitorTest < ActiveSupport::TestCase
  MAPPING = DummyModel.properties

  test 'term' do
    assert_equal({ term: { tags: 'peridot' } },
                 from_ast(term('peridot')))
  end

  test 'conjunction' do
    assert_equal({ bool: { must: [{ term: { tags: 'gem' } },
                                  { term: { tags: 'peridot' } },
                                  { term: { tags: 'lapis lazuli' } }] } },
                 from_ast(expression(:and, term('gem'),
                                           expression(:and, term('peridot'),
                                                            term('lapis lazuli')))))
  end

  test 'disjunction' do
    assert_equal({ bool: { should: [{ term: { tags: 'gem' } },
                                    { term: { tags: 'peridot' } },
                                    { term: { tags: 'lapis lazuli' } }] } },
                 from_ast(expression(:or, term('gem'),
                                          expression(:or, term('peridot'),
                                                          term('lapis lazuli')))))
  end

  test 'negated term' do
    assert_equal({ bool: { must_not: [{ term: { tags: 'peridot' } }] } },
                 from_ast(negated(term('peridot'))))
  end

  test 'negated conjunction' do
    assert_equal({ bool: { must_not: [{ term: { tags: 'gem' } },
                                      { term: { tags: 'peridot' } },
                                      { term: { tags: 'lapis lazuli' } }] } },
                 from_ast(negated(expression(:and, term('gem'),
                                                   expression(:and, term('peridot'),
                                                                    term('lapis lazuli'))))))
  end

  test 'negated disjunction' do
    assert_equal({ bool: { must_not: [{ bool: { should: [{ term: { tags: 'gem' } },
                                                         { term: { tags: 'peridot' } },
                                                         { term: { tags: 'lapis lazuli' } }] } }] } },
                 from_ast(negated(expression(:or, term('gem'),
                                             expression(:or, term('peridot'),
                                                        term('lapis lazuli'))))))
  end

  test 'complex boolean expression' do
    ast = expression(:and, expression(:or,
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

    expected = { bool: { must: [{ bool: { should: [{ term: { tags: 'ruby' } },
                                                   { term: { tags: 'sapphire' } },
                                                   { bool: { must: [{ term: { tags: 'pearl' } }, { term: { tags: 'amethyst' } }] } },
                                                   { term: { tags: 'garnet' } }] } },
                                { bool: { should: [{ bool: { must_not: [{ bool: { should: [{ term: { tags: 'peridot' } },
                                                                                           { term: { tags: 'lapis' } },
                                                                                           { term: { tags: 'lazuli' } }] } }] } },
                                                   { term: { tags: 'steven' } },
                                                   { bool: { must_not: [{ term: { tags: 'gem' } }] } },
                                                   { term: { tags: 'diamond' } }] } },
                                { term: { tags: 'too much?' } }] } }

    assert_equal expected, from_ast(ast)
  end

  test 'range queries' do
    assert_equal({ bool: { should: [{ range: { date: { lt: date('a week ago') } } },
                                    { range: { stars: { gt: '50' } } }] } },
                 from_ast(expression(:or, field_term(:date, :lt, 'a week ago'),
                                          field_term(:stars, :gt, '50'))))
  end

  def from_ast(ast)
    visitor.accept(ast)
  end

  def visitor
    Elasticfusion::Search::ESVisitor.new(keyword_field: :tags, mapping: MAPPING)
  end

  def date(string)
    Elasticfusion::Search::ESValueSanitizer.new(MAPPING).value(string, field: :date)
  end
end
