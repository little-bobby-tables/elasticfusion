module Elasticfusion
  module Model
    module InstanceExtensions
      def reindex_later
        Elasticfusion::Jobs::ReindexJob.perform_later(model_class: self.class.to_s, id: self.id)
      end

      def reindex_now
        __elasticsearch__.index_document
      end
    end
  end
end
