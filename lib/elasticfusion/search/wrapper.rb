# frozen_string_literal: true
require 'elasticfusion/search/builder'
require 'elasticfusion/search/errors'
require 'elasticfusion/search/query/parser'
require 'elasticfusion/search/query/visitors/elasticsearch'

# An instance of this class represents a single search.
# It encapsulates all custom search features (advanced query parsing,
# query building, etc.)
module Elasticfusion
  module Search
    class Wrapper
      def initialize(model, query = nil, &block)
        @mapping = searchable_mapping(model)
        @searchable_fields = @mapping.keys
        @keyword_field = model.elasticfusion[:keyword_field]

        @builder = Search::Builder.new(model.elasticfusion)
        @builder.filter query_to_filter(query) if query
        @builder.instance_eval(&block) if block_given?
      end

      def elasticsearch_payload(size:, from:)
        body = { query: { bool: { must: @builder.queries, filter: @builder.filters } },
                 sort: @builder.sorts }
        body[:size] = size if size
        body[:from] = from if from
        body
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

      # The subset of queries that is currently supported can be executed
      # in the filter context, which does not compute _score and can be cached.
      #
      # It cannot be used for relevance sorting.
      def query_to_filter(query)
        ast = Search::Query::Parser.new(query, @searchable_fields).ast
        visitor = Search::Query::Visitors::Elasticsearch.new(@keyword_field, @mapping)
        visitor.accept(ast)
      end
    end
  end
end
