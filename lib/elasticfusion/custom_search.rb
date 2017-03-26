# frozen_string_literal: true
require 'elasticfusion/search/builder'
require 'elasticfusion/search/query/parser'
require 'elasticfusion/search/query/visitors/elasticsearch'

# An instance of this class represents a single search.
# It encapsulates all custom search features (advanced query parsing,
# query building, etc.)

# Think of it as a light version of elasticsearch-dsl tailored to specific needs.
module Elasticfusion
  class CustomSearch
    def initialize(model, query = nil, &block)
      @mapping = searchable_mapping(model)
      @searchable_fields = @mapping.keys
      @keyword_field = model.elasticfusion[:keyword_field]

      @builder = Search::Builder.new(*model.elasticfusion.values_at(
        :scopes, :default_query, :default_sort, :allowed_sort_fields))
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
      ast = Search::Query::Parser.new(query, @searchable_fields).ast
      visitor = Search::Query::Visitors::Elasticsearch.new(@keyword_field, @mapping)
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
  end
end
