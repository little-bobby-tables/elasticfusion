module Elasticfusion
  module Model
    class ModelSettings
      delegate :[], :values_at, to: :@settings

      def initialize(model)
        @model = model
        @settings = {}
      end

      def configure_with_block(&block)
        @settings.merge! DSL.build_settings_hash(&block)
      end

      class DSL
        def self.build_settings_hash(&block)
          new.tap { |dsl| dsl.instance_eval(&block) }.settings
        end

        def settings
          @settings ||= {}
        end

        def keyword_field(field)
          settings[:keyword_field] = field
        end

        def allowed_search_fields(ary)
          settings[:allowed_search_fields] = ary
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
