# frozen_string_literal: true
require 'test_helper'

class DefinitionTest < ActiveSupport::TestCase
  test 'adds model extensions' do
    class TestModel < ActiveRecord::Base
    end

    with_ar_class do |cls|
      Elasticfusion.define(cls) {}

      assert_includes cls.ancestors, Elasticsearch::Model
      assert_includes cls.ancestors, Elasticfusion::Model::Indexing
      assert_includes cls.ancestors, Elasticfusion::Model::Searching
    end
  end

  test 'defines model settings with a block' do
    with_ar_class do |cls|
      Elasticfusion.define(cls) do
        if self != cls
          raise Minitest::Assertion, 'self is expected to be the model class inside settings block.'
        end

        elasticfusion do
          keyword_field :tags
        end
      end

      assert_equal :tags, cls.elasticfusion[:keyword_field]
    end
  end

  def with_ar_class
    temp_class = Class.new(ActiveRecord::Base)
    Object.send :const_set, :TempClass, temp_class
    yield temp_class
    Object.send :remove_const, :TempClass
  end
end
