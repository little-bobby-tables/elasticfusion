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
        mappings dynamic: false, _all: { enabled: false } do
          indexes :tags, type: 'keyword'
          indexes :stars, type: 'integer'
          indexes :date, type: 'date'
        end
      end

      elasticfusion do
        keyword_field :tags
      end

      after_commit(on: :create) do
        self.class.__elasticsearch__.refresh_index!
      end

      def as_indexed_json(*)
        { tags: JSON.parse(tags), stars: stars, date: date.iso8601 }
      end

      index_name 'searching_test_model_index'
      __elasticsearch__.create_index!
    end
  end

  test 'searching by parsed query' do
    record = @model.create tags: ['peridot', 'lapis lazuli'], stars: 30, date: 3.days.ago

    search = @model.search_by_query('peridot, stars: 30, date: earlier than 2 days ago')
    assert_equal record, search.records.first

    search = @model.search_by_query('peridot, stars: 30, date: 3 hours ago')
    assert_empty search.records
  end

  test 'searching with a manual query' do
    record = @model.create tags: ['peridot', 'lapis lazuli'], stars: 50, date: 1.day.ago

    search = @model.custom_search do |s|
      s.query term: { tags: 'lapis lazuli' }
      s.filter range: { stars: { lt: 100 } }
    end
    assert_equal record, search.records.first

    search = @model.custom_search do |s|
      s.query term: { tags: 'ruby' }
      s.filter range: { stars: { lt: 100 } }
    end
    assert_empty search.records
  end

  test 'combining parsed query with manual filters' do
    record = @model.create tags: ['peridot', 'lapis lazuli'], stars: 100, date: 2.days.ago

    search = @model.search_by_query('peridot, date: earlier than a day ago') do |s|
      s.filter range: { stars: { lte: 100 } }
    end
    assert_equal record, search.records.first

    search = @model.search_by_query('peridot, date: earlier than a day ago') do |s|
      s.filter range: { stars: { lt: 100 } }
    end
    assert_empty search.records
  end
end
