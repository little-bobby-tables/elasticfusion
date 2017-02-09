require 'test_helper'
require 'search/ast_helper'

class ESValueSanitizerTest < ActiveSupport::TestCase
  S = Elasticfusion::Search::ESValueSanitizer

  test 'does not alter keywords' do
    assert_equal 'term', S.new({ tags: { type: 'keyword' } }).value('term', field: :tags)
  end

  test 'transforms integers' do
    assert_equal '10', S.new({ stars: { type: 'integer' } }).value('10', field: :stars)
  end

  test 'transforms date into ES-compliant format' do
    assert_equal Chronic.parse('3 days ago').iso8601,
                 S.new({ date: { type: 'date' } }).value('3 days ago', field: :date)
  end

  test 'raises an error for invalid date' do
    e = assert_raises Elasticfusion::Search::InvalidFieldValueError do
      S.new({ date: { type: 'date' } }).value('not a date', field: :date)
    end

    assert_equal :date, e.field
    assert_equal 'not a date', e.value
  end

  test 'raises an error for invalid integers' do
    e = assert_raises Elasticfusion::Search::InvalidFieldValueError do
      S.new({ stars: { type: 'integer' } }).value('not a number', field: :stars)
    end

    assert_equal :stars, e.field
    assert_equal 'not a number', e.value
  end

  test 'raises an error for unknown fields' do
    e = assert_raises Elasticfusion::Search::UnknownFieldError do
      S.new({}).value('1', field: :tags)
    end

    assert_equal :tags, e.field
  end
end
