module Elasticfusion
  module Model
    class ModelSettings
      def initialize(model)
        @model = model
        @settings = {}
      end

      def configure_with_block(&block)
        @settings = DSL.build_settings_hash(&block)
      end

      def [](key)
        @settings[key]
      end

      def mapping
        @model.__elasticsearch__.mapping.to_hash[
          @model.__elasticsearch__.document_type.to_sym][:properties]
      end

      def searchable_mapping
        if self[:allowed_search_fields]
          mapping.select { |field, _| self[:allowed_search_fields].include? field }
        else
          mapping
        end
      end

      class DSL
        def self.build_settings_hash(&block)
          new.tap { |dsl| dsl.instance_eval(&block) }.settings
        end

        def settings
          @settings ||= {}
        end

        OPTIONS = [:allowed_search_fields, :keyword_field, :reindex_when_updated]

        OPTIONS.each do |opt|
          define_method opt do |val|
            settings[opt] = val
          end
        end
      end
    end
  end
end
