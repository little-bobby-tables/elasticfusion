require 'elasticfusion/model/settings'
require 'elasticfusion/model/class_extensions'
require 'elasticfusion/model/instance_extensions'

module Elasticfusion
  def self.define(cls, &block)
    cls.class_eval do
      include Model::InstanceExtensions
      extend Model::ClassExtensions

      after_commit(on: :create) do
        __elasticsearch__.index_document
      end

      after_commit(on: :destroy) do
        __elasticsearch__.delete_document
      end

      def self.elasticfusion(&block)
        @_elasticfusion_settings ||= Model::Settings.new
        if block_given?
          @_elasticfusion_settings.instance_eval(&block)
        else
          @_elasticfusion_settings
        end
      end
    end

    cls.class_eval(&block)
  end
end
