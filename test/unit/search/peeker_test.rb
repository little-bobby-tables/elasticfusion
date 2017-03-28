# frozen_string_literal: true
require 'test_helper'
require 'active_record_helper'

class SearchPeekerTest < ActiveSupport::TestCase
  setup do
    @model = tags_stars_date_model do
      keyword_field :tags
    end
  end

  delegate :reverse!, to: :@records

  test 'finds next records, sorted by integer field' do
    generate_records

    assert_finds_next { |s| s.sort_by :stars, :asc }
    reverse!
    assert_finds_next { |s| s.sort_by :stars, :desc }
  end

  test 'finds next records, sorted by date field' do
    generate_records

    assert_finds_next { |s| s.sort_by :date, :asc }
    reverse!
    assert_finds_next { |s| s.sort_by :date, :desc }
  end

  test 'finds previous records, sorted by integer field' do
    generate_records

    assert_finds_previous { |s| s.sort_by :stars, :asc }
    reverse!
    assert_finds_previous { |s| s.sort_by :stars, :desc }
  end

  test 'finds previous records, sorted by date field' do
    generate_records

    assert_finds_previous { |s| s.sort_by :date, :asc }
    reverse!
    assert_finds_previous { |s| s.sort_by :date, :desc }
  end

  test 'finds next records, sorted by non-unique field' do
    generate_records unique_stars: false

    # id -> stars
    # 2 -> 20, 1 -> 20, 4 -> 21, 3 -> 21, 5 -> 22
    @records.sort_by! { |r| [r.stars, -r.id] }

    assert_finds_next do |s|
      s.sort_by :stars, :asc
      s.ensure_deterministic_order_with_unique_field :id
    end

    # id -> stars
    # 5 -> 22, 4 -> 21, 3 -> 21, 2 -> 20, 1 -> 20
    @records.sort_by! { |r| [-r.stars, -r.id] }

    assert_finds_next do |s|
      s.sort_by :stars, :desc
      s.ensure_deterministic_order_with_unique_field :id
    end
  end

  test 'finds previous records, sorted by non-unique field' do
    generate_records unique_stars: false

    # id -> stars
    # 2 -> 20, 1 -> 20, 4 -> 21, 3 -> 21, 5 -> 22
    @records.sort_by! { |r| [r.stars, -r.id] }

    assert_finds_previous do |s|
      s.sort_by :stars, :asc
      s.ensure_deterministic_order_with_unique_field :id
    end

    # id -> stars
    # 5 -> 22, 4 -> 21, 3 -> 21, 2 -> 20, 1 -> 20
    @records.sort_by! { |r| [-r.stars, -r.id] }

    assert_finds_previous do |s|
      s.sort_by :stars, :desc
      s.ensure_deterministic_order_with_unique_field :id
    end
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

  def generate_records(unique_stars: true)
    @records = @model.create [
      { tags: %w(ruby sapphire), stars: 20, date: 7.day.ago },
      { tags: %w(ruby sapphire), stars: (if unique_stars then 21 else 20 end), date: 5.days.ago - 1.hour },
      { tags: %w(ruby sapphire), stars: (if unique_stars then 22 else 21 end), date: 5.days.ago - 1.second },
      { tags: %w(ruby sapphire), stars: (if unique_stars then 23 else 21 end), date: 10.minutes.ago },
      { tags: %w(ruby sapphire), stars: (if unique_stars then 24 else 22 end), date: 1.minute.ago }
    ]
  end
end
