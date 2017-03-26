# frozen_string_literal: true
module Elasticfusion
  module Model
    class Settings
      delegate :[], :values_at, to: :@settings

      def initialize(model, &block)
        @model = model

        @settings = DSL.build_settings(&block) if block_given?
        @settings ||= {}

        @settings[:full_mapping] = full_mapping
        @settings[:searchable_mapping] = searchable_mapping
        @settings[:searchable_fields] ||= @settings[:searchable_mapping].keys
      end

      def full_mapping
        @model.__elasticsearch__.mapping.to_hash[
          @model.__elasticsearch__.document_type.to_sym][:properties]
      end

      def searchable_mapping
        if @settings[:searchable_fields]
          full_mapping.select { |field, _| @settings[:searchable_fields].include? field }
        else
          full_mapping
        end
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

        def searchable_fields(ary)
          settings[:searchable_fields] = ary
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
