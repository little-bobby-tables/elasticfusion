# frozen_string_literal: true
require 'elasticfusion/model/settings'
require 'elasticfusion/model/indexing'
require 'elasticfusion/model/searching'

require 'elasticsearch/model'

module Elasticfusion
  def self.define(cls, &block)
    cls.class_eval do
      include Elasticsearch::Model

      def self.elasticfusion(&block)
        @elasticfusion ||= Model::Settings.new(self)
        @elasticfusion.configure_with_block(&block) if block_given?
        @elasticfusion
      end
    end

    cls.class_eval(&block)

    # Model extensions may rely on settings set with a block,
    # include them after evaluating the latter.
    cls.class_eval do
      include Model::Indexing
      include Model::Searching
    end
  end
end
