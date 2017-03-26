# frozen_string_literal: true
module Elasticfusion
  module Model
    class Settings
      delegate :[], :values_at, to: :@settings

      def initialize(model, &block)
        @model = model
        @settings = (DSL.build_settings(&block) if block_given?) || {}
      end

      class DSL
        def self.build_settings(&block)
          new.tap { |dsl| dsl.instance_eval(&block) }.settings
        end

        def settings
          @settings ||= {}
        end

        def scopes
          settings[:scopes] = yield
        end

        def keyword_field(field)
          settings[:keyword_field] = field
        end

        def allowed_search_fields(ary)
          settings[:allowed_search_fields] = ary
        end

        def allowed_sort_fields(ary)
          settings[:allowed_sort_fields] = ary.map(&:to_s)
        end

        def default_query(query)
          settings[:default_query] = query
        end

        def default_sort(sort)
          settings[:default_sort] = sort
        end

        def reindex_when_updated(attributes)
          settings[:reindex_when_updated] = attributes
        end
      end
    end
  end
end