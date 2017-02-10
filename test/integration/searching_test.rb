require 'test_helper'
require 'active_record_helper'

class SearchingTest < ActiveSupport::TestCase
  setup do
    @model = ar_model 'SearchingTestModel' do |t|
      t.string :tags, array: true
      t.integer :stars
      t.date :date
    end
    Elasticfusion.define @model do
      settings index: { number_of_shards: 1 } do
        mappings dynamic: false, _source: { enabled: false }, _all: { enabled: false } do
          indexes :tags, type: 'keyword'
          indexes :stars, type: 'integer'
          indexes :date, type: 'date'
        end
      end
    end
  end

  test 'search by query' do
    search = @model.search_by_query('peridot, lapis lazuli, date: less than a month ago, score: 50')

  end
end
