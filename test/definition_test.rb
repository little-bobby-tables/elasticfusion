require 'test_helper'

class Model < ActiveRecord::Base
end

class DefinitionTest < ActiveSupport::TestCase
  test 'adds model extensions' do
    Elasticfusion.define(Model) { }

    assert_includes Model.ancestors, Elasticfusion::Model::InstanceExtensions
    assert_includes Model.singleton_class.ancestors, Elasticfusion::Model::ClassExtensions
  end

  test 'defines model settings with a block' do
    Elasticfusion.define(Model) do
      if self != Model
        raise Minitest::Assertion, 'self is expected to be the model class inside settings block.'
      end

      elasticfusion do
        keyword_field :tags
      end
    end

    assert_equal :tags, Model.elasticfusion[:keyword_field]
  end
end
