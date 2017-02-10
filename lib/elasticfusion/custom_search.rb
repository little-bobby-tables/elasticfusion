require 'elasticfusion/search/parser'
require 'elasticfusion/search/visitors/es_visitor'

# An instance of this class represents a single search.
# It encapsulates all custom search features (advanced query parsing,
# query building, etc.)
module Elasticfusion
  class CustomSearch
    def initialize(searchable_mapping:, query: nil, keyword_field: nil, &block)
      @mapping = searchable_mapping
      @keyword_field = keyword_field

      @size = 10

      parse_query(query) if query
      instance_eval(&block) if block_given?
    end

    def size(size)
      @size = size
    end

    def sort_by(sort)
      (@sort_by ||= []) << sort
    end

    def perform
      self.search query: { bool: { must: searchable_options.queries } },
                  filter: { bool: { must: searchable_options.filters } },
                  sort: sorts,
                  size: @size
    end

    def parse_query(query)
      ast = Search::Parser.new(query, searchable_fields)
      visitor = Search::ESVisitor.new(@mapping, @keyword_field)
      @query = visitor.accept(ast)
    end

    private

    def searchable_fields
      @mapping.keys
    end
  end
end
