# frozen_string_literal: true
require 'test_helper'

class LexerTest < ActiveSupport::TestCase
  test 'matches safe strings' do
    assert_lex :safe_string,
               expected: 'safe string with - and _ and 20 17',
               source: 'safe string with - and _ and 20 17'
    assert_lex :safe_string,
               expected: 'safe string with - and _ and 20 17',
               source: 'safe string with - and _ and 20 17, irrelevant part',
               should_remain: ', irrelevant part'
    assert_lex :safe_string,
               expected: 'safe string with - and _ and 20 17',
               source: 'safe string with - and _ and 20 17    , irrelevant part',
               should_remain: '    , irrelevant part'
    assert_lex :safe_string,
               expected: 'safe string with - and _ and 20 17',
               source: 'safe string with - and _ and 20 17 OR irrelevant part',
               should_remain: ' OR irrelevant part'
  end

  test 'matches quoted strings' do
    assert_lex :quoted_string,
               expected: 'this is a "quoted" string ) , AND OR ((( ',
               source: '"this is a \"quoted\" string ) , AND OR ((( "'
    assert_lex :quoted_string,
               expected: 'this is a "quoted" string ) , AND OR ((( ',
               source: '"this is a \"quoted\" string ) , AND OR ((( "irrelevant part',
               should_remain: 'irrelevant part'
    assert_lex :quoted_string,
               expected: '"beginning" and ending with a "quote"',
               source: '"\"beginning\" and ending with a \"quote\"", irrelevant part',
               should_remain: ', irrelevant part'
    assert_lex :quoted_string,
               expected: 'one string',
               source: '"one string" BUT WAIT "there\'s more"',
               should_remain: ' BUT WAIT "there\'s more"'
  end

  test 'matches raw strings (safe with balanced parentheses)' do
    assert_lex :string_with_balanced_parentheses,
               expected: '(safe string) with - and _ (and) 20 17 and (balanced)',
               source: '(safe string) with - and _ (and) 20 17 and (balanced)'

    assert_lex :string_with_balanced_parentheses,
               expected: '(safe string) with - and _',
               source: '(safe string) with - and _    '

    assert_lex :string_with_balanced_parentheses,
               expected: '(safe string) (balanced)',
               source: '(safe string) (balanced)) ',
               should_remain: ') '

    assert_lex :string_with_balanced_parentheses,
               expected: 'safe string with - and _ and 20 17',
               source: 'safe string with - and _ and 20 17), irrelevant part',
               should_remain: '), irrelevant part'

    assert_lex :string_with_balanced_parentheses,
               expected: 'safe string with - and _ and 20 17',
               source: 'safe string with - and _ and 20 17 OR irrelevant part',
               should_remain: 'OR irrelevant part'
  end

  def assert_lex(action, expected:, source:, should_remain: '')
    lexer = Elasticfusion::Search::Query::Lexer.new(source, [])
    assert_equal expected, lexer.send(action)
    assert_equal should_remain, lexer.instance_variable_get(:@scanner).rest
  end
end
