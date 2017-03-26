# frozen_string_literal: true
require 'test_helper'
require 'active_record_helper'

class SearchWrapperTest < ActiveSupport::TestCase
  test ':scopes' do
    @model = tags_stars_date_model do
      searchable_fields [:stars]
      scopes do
        {
          starstruck:     ->            { { term: { stars: 1 } } },
          stars:          ->(val)       { { term: { stars: val } } },
          stars_in_range: ->(qual, val) { { range: { stars: { qual => val } } } }
        }
      end
    end

    filter = search_request { |s| s.scope(:starstruck) }[:query][:bool][:filter]
    assert_includes filter, term: { stars: 1 }

    filter = search_request { |s| s.scope(:stars, 42) }[:query][:bool][:filter]
    assert_includes filter, term: { stars: 42 }

    filter = search_request { |s| s.scope(:stars_in_range, :lt, 2) }[:query][:bool][:filter]
    assert_includes filter, range: { stars: { lt: 2 } }

    assert_raises ArgumentError do
      search_request { |s| s.scope(:theres_no_such_scope) }
    end
  end

  test ':searchable_fields' do
    @model = tags_stars_date_model { searchable_fields [:stars] }

    terms = search_request('stars: 50, date: december 1 2016')[:query][:bool][:filter].first[:bool][:must]
    assert_includes terms, term: { stars: '50' }
    refute_includes terms, term: { date: '2016-12-01T12:00:00+07:00' }

    @model = tags_stars_date_model { searchable_fields [:date] }

    terms = search_request('stars: 50, date: december 1 2016')[:query][:bool][:filter].first[:bool][:must]
    refute_includes terms, term: { stars: '50' }
    assert_includes terms, term: { date: '2016-12-01T12:00:00+07:00' }
  end

  test ':keyword_field' do
    @model = tags_stars_date_model { keyword_field :tags }

    terms = search_request('peridot, lapis lazuli')[:query][:bool][:filter].first[:bool][:must]
    assert_includes terms, term: { tags: 'peridot' }
  end

  def search_request(query = nil, &block)
    Elasticfusion::Search::Wrapper.new(@model, query, &block)
      .elasticsearch_request
  end
end
