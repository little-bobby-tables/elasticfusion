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


end
