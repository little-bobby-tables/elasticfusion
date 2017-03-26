# frozen_string_literal: true
module Elasticfusion
  module Search
    class Builder
      def initialize(settings)
        @scopes        = settings[:scopes]        || {}
        @default_query = settings[:default_query] || { match_all: {} }
        @default_sort  = settings[:default_sort]  || {}

        @queries = []
        @filters = []
        @sorts   = []
      end

      # Attribute writers

      def query(q)
        @queries << q
      end

      def filter(f)
        @filters << f
      end

      def scope(scope, *args)
        scope = @scopes[scope]
        raise ArgumentError, "Unknown scope #{scope}" if scope.nil?

        @filters << scope.call(*args)
      end

      def sort_by(field, direction)
        raise Search::InvalidSortOrderError if %w(desc asc).exclude? direction.to_s
        @sorts << { field => direction }
      end

      # Attribute readers

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
