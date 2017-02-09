require 'test_helper'
require 'model/active_record_helper'

class IndexingTest < ActiveSupport::TestCase
  setup do
    @model = ar_model('IndexingTestModel')
  end

  test 'creates a document for new records' do
    Elasticfusion.define(@model) { }
    record = @model.new

    assert_method_call record.__elasticsearch__, :index_document do
      record.save
    end
  end

  test 'removes the document for deleted records' do
    Elasticfusion.define(@model) { }
    record = @model.create

    assert_method_call record.__elasticsearch__, :delete_document do
      record.destroy
    end
  end

  test 'reindexes records on update with :reindex_when_updated enabled' do
    Elasticfusion.define(@model) do
      elasticfusion { reindex_when_updated [:attr] }
    end
    record = @model.create

    assert_method_call record, :reindex_later do
      record.attr = 1
      record.save
    end
  end

  test 'does not reindex records on update with :reindex_when_updated disabled' do
    Elasticfusion.define(@model) { }
    record = @model.create

    refute_method_call record, :reindex_later do
      record.attr = 1
      record.save
    end
  end

  test 'does not reindex records when :reindex_when_updated excludes the changed attribute' do
    Elasticfusion.define(@model) do
      elasticfusion { reindex_when_updated [:some_other_attr] }
    end
    record = @model.create

    refute_method_call record, :reindex_later do
      record.attr = 1
      record.save
    end
  end
end
