# frozen_string_literal: true
require 'elasticfusion/model/settings'
require 'elasticfusion/model/indexing'
require 'elasticfusion/model/searching'

module Elasticfusion
  def self.define(cls, &block)
    cls.class_eval do
      include Elasticsearch::Model

      def self.elasticfusion(&block)
        @elasticfusion ||= Model::Settings.new(self, &block)
      end
    end

    cls.class_eval(&block)

    # Model extensions may rely on settings set with the block
    # and should only be included after evaluating it.
    cls.class_eval do
      include Model::Indexing
      include Model::Searching
    end
  end
end
