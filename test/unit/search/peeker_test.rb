# frozen_string_literal: true
require 'test_helper'
require 'active_record_helper'

class SearchPeekerTest < ActiveSupport::TestCase
  setup do
    @model = tags_stars_date_model do
      keyword_field :tags
    end
    @records = @model.create [
      { tags: %w(ruby sapphire), stars: 20, date: 1.day.ago },
      { tags: %w(ruby sapphire), stars: 21, date: 2.days.ago },
      { tags: %w(ruby sapphire), stars: 22, date: 3.days.ago },
      { tags: %w(ruby sapphire), stars: 23, date: 4.days.ago },
      { tags: %w(ruby sapphire), stars: 24, date: 5.days.ago }
    ]
  end

  delegate :reverse!, to: :@records

  # TODO: test multiple sort fields

  test 'finds next records, sorted by integer field' do
    assert_finds_next { |s| s.sort_by :stars, :asc }
    reverse!
    assert_finds_next { |s| s.sort_by :stars, :desc }
  end

  test 'finds next records, sorted by date field' do
    assert_finds_next { |s| s.sort_by :date, :desc }
    reverse!
    assert_finds_next { |s| s.sort_by :date, :asc }
  end

  test 'finds previous records, sorted by integer field' do
    assert_finds_previous { |s| s.sort_by :stars, :asc }
    reverse!
    assert_finds_previous { |s| s.sort_by :stars, :desc }
  end

  test 'finds previous records, sorted by date field' do
    assert_finds_previous { |s| s.sort_by :date, :desc }
    reverse!
    assert_finds_previous { |s| s.sort_by :date, :asc }
  end

  def assert_finds_next(&block)
    iterate_with_next do |record, next_record|
      assert_equal next_record,
                   @model.custom_search(&block).next_record(record)
    end
  end

  def assert_finds_previous(&block)
    iterate_with_previous do |record, previous_record|
      assert_equal previous_record,
                   @model.custom_search(&block).previous_record(record)
    end
  end

  def iterate_with_next
    @records[0..-2].each_with_index do |r, i|
      yield r, @records[i + 1]
    end
  end

  def iterate_with_previous
    @records[1..-1].each_with_index do |r, i|
      yield r, @records[i]
    end
  end
end
