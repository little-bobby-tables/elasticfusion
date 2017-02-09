require 'test_helper'
require 'active_record_helper'

class CustomSearchTest < ActiveSupport::TestCase
  setup do
    @model = ar_model 'CustomSearchTestModel' do |t|
      t.string :tags, array: true
      t.integer :stars
      t.date :date
    end
    Elasticfusion.define @model do

    end
  end

  test 'initializes from a query' do
    Elasticfusion::CustomSearch.new
  end
end
