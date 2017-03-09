# frozen_string_literal: true
require 'elasticfusion/search/parser'
require 'elasticfusion/search/visitors/es_visitor'

# An instance of this class represents a single search.
# It encapsulates all custom search features (advanced query parsing,
# query building, etc.)

# Think of it as a light version of https://github.com/elastic/elasticsearch-ruby/tree/master/elasticsearch-dsl,
# tailored to our specific needs.
module Elasticfusion
  class CustomSearch
    def initialize(model, query = nil, &block)
      @mapping = searchable_mapping(model)
      @searchable_fields = @mapping.keys
      @keyword_field = model.elasticfusion[:keyword_field]

      @builder = QueryBuilder.new(*model.elasticfusion.values_at(
        :default_query, :default_sort, :allowed_sort_fields))
      parse_query(query) if query
      @builder.instance_eval(&block) if block_given?
    end

    def elasticsearch_client_request(size:, from:)
      body = { query: { bool: { must: @builder.queries, filter: @builder.filters } },
               sort: @builder.sorts }
      body[:size] = size if size
      body[:from] = from if from
      body
    end

    def parse_query(query)
      ast = Search::Parser.new(query, @searchable_fields).ast
      visitor = Search::ESVisitor.new(@keyword_field, @mapping)
      # All of the queries currently supported by search parser can be executed
      # in the filter context, which is faster than query (does not compute _score)
      # and can be cached.
      @builder.filter visitor.accept(ast)
    end

    def searchable_mapping(model)
      mapping = model.__elasticsearch__.mapping.to_hash[
        model.__elasticsearch__.document_type.to_sym][:properties]

      if model.elasticfusion[:allowed_search_fields]
        mapping.select { |field, _| model.elasticfusion[:allowed_search_fields].include? field }
      else
        mapping
      end
    end

    private

    class QueryBuilder
      def initialize(default_query, default_sort, allowed_sort_fields)
        @default_query = default_query || { match_all: {} }
        @default_sort = default_sort || {}
        @allowed_sort_fields = allowed_sort_fields
        @queries, @filters, @sorts = [], [], []
      end

      def query(query)
        @queries << query
      end

      def filter(query)
        @filters << query
      end

      def sort_by(field, direction)
        raise Search::UnknownSortFieldError.new(field) if @allowed_sort_fields.exclude? field.to_s
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
