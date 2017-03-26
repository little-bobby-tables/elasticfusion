# frozen_string_literal: true

module Elasticfusion
  module Search
    class Builder
      def initialize(scopes, default_query, default_sort, allowed_sort_fields)
        @scopes = scopes || {}
        @default_query = default_query || { match_all: {} }
        @default_sort = default_sort || {}
        @allowed_sort_fields = allowed_sort_fields || []
        @queries = []
        @filters = []
        @sorts = []
      end

      def query(query)
        @queries << query
      end

      def filter(query)
        @filters << query
      end

      def scope(scope, *args)
        scope = @scopes[scope]
        raise ArgumentError, "Unknown scope #{scope}" if scope.nil?

        @filters << scope.call(*args)
      end

      def sort_by(field, direction)
        raise Search::UnknownSortFieldError, field if @allowed_sort_fields.exclude? field.to_s
        raise Search::InvalidSortOrderError if %w(desc asc).exclude? direction.to_s
        @sorts << { field => direction }
      end

      def queries
        return @queries if @queries.any?
        @default_query
      end

      def filters
        @filters
      end

      def sorts
        return @sorts if @sorts.any?
        @default_sort
      end
    end
  end
end
