module Elasticfusion
  module Jobs
    class ReindexJob < ActiveJob::Base
      queue_as do
        queue = self.arguments.first
        if queue.owner.premium?
          :premium_videojobs
        else
          :videojobs
        end
      end

      def perform(model_class:, id:)
        model_class.constantize.find(id).reindex_now
      end
    end
  end
end
