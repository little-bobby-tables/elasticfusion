module Elasticfusion
  module Jobs
    class ReindexJob < ActiveJob::Base
      queue_as :indexing

      def perform(model_class, id)
        model_class.constantize.find(id).reindex_now
      end
    end
  end
end
