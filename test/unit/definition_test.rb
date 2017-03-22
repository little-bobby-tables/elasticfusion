# frozen_string_literal: true
require 'test_helper'

class DefinitionTest < ActiveSupport::TestCase
  test 'adds model extensions' do
    @class = Class.new(ActiveRecord::Base)

    Elasticfusion.define(@class) {}

    assert_includes @class.ancestors, Elasticsearch::Model
    assert_includes @class.ancestors, Elasticfusion::Model::Indexing
    assert_includes @class.ancestors, Elasticfusion::Model::Searching
  end

  test 'defines model settings with a block' do
    class TestModel < ActiveRecord::Base
    end

    Elasticfusion.define(TestModel) do
      if self != TestModel
        raise Minitest::Assertion, 'self is expected to be the model class inside settings block.'
      end

      elasticfusion do
        keyword_field :tags
      end
    end

    assert_equal :tags, TestModel.elasticfusion[:keyword_field]
  end
end
