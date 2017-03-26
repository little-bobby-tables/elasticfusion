# frozen_string_literal: true
require 'test_helper'
require 'active_record_helper'

class SearchWrapperTest < ActiveSupport::TestCase
  test ':scopes' do
    model do
      searchable_fields [:stars]
      scopes do
        {
          starstruck:     ->            { { term: { stars: 1 } } },
          stars:          ->(val)       { { term: { stars: val } } },
          stars_in_range: ->(qual, val) { { range: { stars: { qual => val } } } }
        }
      end
    end

    filter = search_body { |s| s.scope(:starstruck) }[:query][:bool][:filter]
    assert_includes filter, term: { stars: 1 }

    filter = search_body { |s| s.scope(:stars, 42) }[:query][:bool][:filter]
    assert_includes filter, term: { stars: 42 }

    filter = search_body { |s| s.scope(:stars_in_range, :lt, 2) }[:query][:bool][:filter]
    assert_includes filter, range: { stars: { lt: 2 } }

    assert_raises ArgumentError do
      search_body { |s| s.scope(:theres_no_such_scope) }
    end
  end

  test ':searchable_fields' do
    model { searchable_fields [:stars] }

    terms = search_body('stars: 50, date: december 1 2016')[:query][:bool][:filter].first[:bool][:must]
    assert_includes terms, term: { stars: '50' }
    refute_includes terms, term: { date: '2016-12-01T12:00:00+07:00' }

    model { searchable_fields [:date] }

    terms = search_body('stars: 50, date: december 1 2016')[:query][:bool][:filter].first[:bool][:must]
    refute_includes terms, term: { stars: '50' }
    assert_includes terms, term: { date: '2016-12-01T12:00:00+07:00' }
  end

  test ':keyword_field' do
    model { keyword_field :tags }

    terms = search_body('peridot, lapis lazuli')[:query][:bool][:filter].first[:bool][:must]
    assert_includes terms, term: { tags: 'peridot' }
  end

  test ':allowed_sort_fields' do
    model { allowed_sort_fields [:stars] }

    sorts = search_body('pearl') { |s| s.sort_by('stars', 'desc') }[:sort]
    assert_includes sorts, 'stars' => 'desc'

    sorts = search_body('pearl') { |s| s.sort_by(:stars, :desc) }[:sort]
    assert_includes sorts, stars: :desc

    e = assert_raises Elasticfusion::Search::UnknownSortFieldError do
      search_body('pearl') { |s| s.sort_by('decidedly_not_stars', 'desc') }
    end
    assert_equal 'decidedly_not_stars', e.field

    assert_raises Elasticfusion::Search::InvalidSortOrderError do
      search_body('pearl') { |s| s.sort_by('stars', 'spiraling') }
    end
  end

  def search_body(query = nil, &block)
    s = Elasticfusion::Search::Wrapper.new(@model, query, &block)
    s.elasticsearch_payload(size: nil, from: nil)
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
