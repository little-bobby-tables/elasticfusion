# frozen_string_literal: true
require 'elasticfusion/jobs/reindex_job'

module Elasticfusion
  module Model
    module Indexing
      def self.included(model)
        model.class_eval do
          after_commit(on: :create) do
            __elasticsearch__.index_document
          end

          after_commit(on: :destroy) do
            __elasticsearch__.delete_document
          end

          if elasticfusion[:reindex_when_updated]
            after_commit(on: :update) do |record|
              if (record.previous_changes.keys.map(&:to_sym) &
                  record.class.elasticfusion[:reindex_when_updated]).any?
                record.reindex_later
              end
            end
          end
        end
      end

      def reindex_later
        Elasticfusion::Jobs::ReindexJob.perform_later(self.class.to_s, self.id)
      end

      def reindex_now
        __elasticsearch__.index_document
      end
    end
  end
end
