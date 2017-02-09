require 'test_helper'
require 'active_record_helper'

class IndexingTest < ActiveSupport::TestCase
  include ActiveJob::TestHelper

  test 'creates a document for new records' do
    setup_model_and_record

    assert_method_call @record.__elasticsearch__, :index_document do
      @record.save
    end
  end

  test 'removes the document for deleted records' do
    setup_model_and_record persisted: true

    assert_method_call @record.__elasticsearch__, :delete_document do
      @record.destroy
    end
  end

  test 'reindexes records on update with :reindex_when_updated enabled' do
    setup_model_and_record_with_string_attr do
      elasticfusion { reindex_when_updated [:attr] }
    end

    assert_method_call @record, :reindex_later do
      @record.attr = 'attr'
      @record.save
    end
  end

  test 'does not reindex records on update with :reindex_when_updated disabled' do
    setup_model_and_record_with_string_attr

    refute_method_call @record, :reindex_later do
      @record.attr = 'attr'
      @record.save
    end
  end

  test 'does not reindex records when :reindex_when_updated excludes the changed attribute' do
    setup_model_and_record_with_string_attr do
      elasticfusion { reindex_when_updated [:some_other_attr] }
    end

    refute_method_call @record, :reindex_later do
      @record.attr = 'attr'
      @record.save
    end
  end

  test '#reindex_later enqueues an indexing job' do
    setup_model_and_record

    assert_enqueued_with(job: Elasticfusion::Jobs::ReindexJob, args: [@model.name, @record.id]) do
      @record.reindex_later
    end
  end

  test '#reindex_now updates the document' do
    setup_model_and_record

    assert_method_call @record.__elasticsearch__, :index_document do
      @record.reindex_now
    end
  end

  def setup_model_and_record(persisted: false, &block)
    @model = ar_model 'IndexingTestModel'
    if block_given?
      Elasticfusion.define(@model, &block)
    else
      Elasticfusion.define(@model) { }
    end
    @record = @model.new
    @record.save if persisted
  end

  def setup_model_and_record_with_string_attr(&block)
    @model = ar_model 'IndexingTestModelWithAttr' do |table|
      table.string :attr
    end
    if block_given?
      Elasticfusion.define(@model, &block)
    else
      Elasticfusion.define(@model) { }
    end
    @record = @model.new
    @record.save
  end
end
