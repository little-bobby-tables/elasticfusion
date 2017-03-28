# frozen_string_literal: true

module Elasticfusion
  module Search
    # An instance of +Peeker+ can return consecutive (previous and next)
    # records for a given record and an instance of +Search::Wrapper+.
    #
    # Under the hood, it uses search_after parameters (see
    # https://www.elastic.co/guide/en/elasticsearch/reference/5.2/search-request-search-after.html).
    class Peeker
      def initialize(wrapper)
        @wrapper = wrapper
      end

      def next_record(current_record)
        request = @wrapper.elasticsearch_request

        first_record_after(current_record, request)
      end

      def previous_record(current_record)
        request = @wrapper.elasticsearch_request
        request[:sort] = reverse_sort request[:sort]

        first_record_after(current_record, request)
      end

      private

      def first_record_after(record, request)
        indexed = record.as_indexed_json

        request[:size] = 1
        request[:search_after] = request[:sort].map do |sort_hash|
          field, _direction = sort_hash.first

          if indexed[field].is_a? Time
            ms_since_epoch = (indexed[field].to_f * 1000).to_i
            ms_since_epoch
          else
            indexed[field]
          end
        end

        @wrapper.perform(request).records.first
      end

      def reverse_sort(sort)
        sort.map do |sort_hash|
          field, direction = sort_hash.first

          inverse_direction = if direction.to_sym == :asc
            :desc
          else
            :asc
          end

          { field => inverse_direction }
        end
      end
    end
  end
end
