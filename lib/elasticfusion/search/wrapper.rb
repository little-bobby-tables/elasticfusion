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
        @searchable_fields = model.elasticfusion[:searchable_fields]
        @keyword_field     = model.elasticfusion[:keyword_field]
        @mapping           = model.elasticfusion[:mapping]

        @builder = Search::Builder.new(model.elasticfusion)
        @builder.instance_eval(&block) if block_given?

        # The subset of queries that is currently supported can be executed
        # in the filter context, which does not compute _score and can be cached.
        # It cannot be used for relevance sorting, though.
        @builder.filter parse_query(query) if query.present?
      end

      def elasticsearch_payload(size:, from:)
        body = { query: { bool: { must: @builder.queries, filter: @builder.filters } },
                 sort: @builder.sorts }
        body[:size] = size if size
        body[:from] = from if from
        body
      end

      private

      def parse_query(query)
        ast = Query::Parser.new(query, @searchable_fields).ast
        visitor = Query::Visitors::Elasticsearch.new(@keyword_field, @mapping)
        visitor.accept(ast)
      end
    end
  end
end
