# frozen_string_literal: true
module Elasticfusion
  module ActiveRecordAdapterPatch
    # https://github.com/elastic/elasticsearch-rails/issues/608,
    # might be related to https://github.com/elastic/elasticsearch-rails/issues/258,
    # though in my experience it only affects Rails 5+.
    def records
      @_records_sorted ||= super.to_a
    end
  end
end

Elasticsearch::Model::Adapter::ActiveRecord::Records.prepend(
  Elasticfusion::ActiveRecordAdapterPatch)
