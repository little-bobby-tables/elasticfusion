require 'test_helper'
require 'active_record_helper'

class CustomSearchTest < ActiveSupport::TestCase
  test ':allowed_search_fields' do
    model { allowed_search_fields [:stars] }

    terms = search_body('stars: 50, date: december 1 2016')[:query][:bool][:filter].first[:bool][:must]
    assert_includes terms, { term: { stars: '50' } }
    refute_includes terms, { term: { date: '2016-12-01T12:00:00+07:00' } }

    model { allowed_search_fields [:date] }

    terms = search_body('stars: 50, date: december 1 2016')[:query][:bool][:filter].first[:bool][:must]
    refute_includes terms, { term: { stars: '50' } }
    assert_includes terms, { term: { date: '2016-12-01T12:00:00+07:00' } }
  end

  test ':keyword_field' do
    model { keyword_field :tags }

    terms = search_body('peridot, lapis lazuli')[:query][:bool][:filter].first[:bool][:must]
    assert_includes terms, { term: { tags: 'peridot' } }
  end

  test ':allowed_sort_fields' do
    model { allowed_sort_fields [:stars] }

    sorts = search_body('pearl') { |s| s.sort_by('stars', 'desc') }[:sort]
    assert_includes sorts, { 'stars' => 'desc' }

    e = assert_raises Elasticfusion::Search::UnknownSortFieldError do
      search_body('pearl') { |s| s.sort_by('decidedly_not_stars', 'desc') }
    end
    assert_equal 'decidedly_not_stars', e.field

    assert_raises Elasticfusion::Search::InvalidSortOrderError do
      search_body('pearl') { |s| s.sort_by('stars', 'spiraling') }
    end
  end

  def search_body(query = nil, &block)
    s = Elasticfusion::CustomSearch.new(@model, query, &block)
    s.elasticsearch_client_request(size: nil, from: nil)
  end

  def model(&block)
    @model = ar_model 'CustomSearchTestModel'
    Elasticfusion.define @model do
      settings index: { number_of_shards: 1 } do
        mappings dynamic: false, _source: { enabled: false }, _all: { enabled: false } do
          indexes :tags, type: 'keyword'
          indexes :stars, type: 'integer'
          indexes :date, type: 'date'
        end
      end

      elasticfusion(&block)
    end
  end
end
