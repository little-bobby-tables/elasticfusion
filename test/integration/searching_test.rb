# frozen_string_literal: true
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

        scopes do
          {
            tag_expression: -> do
              { bool: { must: [{ term: { tags: 'lapis lazuli' } },
                               { term: { tags: 'peridot' } }] } }
            end,
            stars_in_range: ->(qual, val) do
              { range: { stars: { qual => val } } }
            end
          }
        end
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

  test 'searching by query' do
    record = @model.create tags: ['peridot', 'lapis lazuli'], stars: 30, date: 3.days.ago

    search = @model.custom_search('peridot, stars: 30, date: earlier than 2 days ago')
    assert_equal record, search.perform.records.first

    search = @model.custom_search('peridot, stars: 30, date: 3 hours ago')
    assert_empty search.perform.records
  end

  test 'queries are case-insensitive' do
    record = @model.create tags: ['peridot', 'lapis lazuli'], date: 3.days.ago

    search = @model.custom_search('Peridot AND Lapis Lazuli')
    assert_equal record, search.perform.records.first

    search = @model.custom_search('peRIDOT OR laPIS laZULI')
    assert_equal record, search.perform.records.first
  end

  test 'building the search request manually' do
    record = @model.create tags: ['peridot', 'lapis lazuli'], stars: 50, date: 1.day.ago

    search = @model.custom_search do |s|
      s.scope :tag_expression
      s.filter range: { stars: { lt: 100 } }
    end
    assert_equal record, search.perform.records.first

    search = @model.custom_search do |s|
      s.query term: { tags: 'ruby' }
      s.filter range: { stars: { lt: 100 } }
    end
    assert_empty search.perform.records
  end

  test 'combining queries with manual filters' do
    record = @model.create tags: ['peridot', 'lapis lazuli'], stars: 100, date: 2.days.ago

    search = @model.custom_search('peridot, date: earlier than a day ago') do |s|
      s.scope :stars_in_range, :lte, 100
    end
    assert_equal record, search.perform.records.first

    search = @model.custom_search('peridot, date: earlier than a day ago') do |s|
      s.scope :stars_in_range, :lt, 100
    end
    assert_empty search.perform.records
  end
end
