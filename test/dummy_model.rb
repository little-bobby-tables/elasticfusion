require 'active_record'
require 'elasticsearch/model'

class DummyModel < ActiveRecord::Base
  include Elasticsearch::Model

  __elasticsearch__.index_name 'test_models'
  __elasticsearch__.create_index! force: true

  settings index: { number_of_shards: 1 } do
    mappings dynamic: false, _source: { enabled: false }, _all: { enabled: false } do
      indexes :tags, type: 'keyword'
      indexes :stars, type: 'integer'
      indexes :date, type: 'date'
    end
  end

  def self.properties
    __elasticsearch__.mapping.to_hash[__elasticsearch__.document_type.to_sym][:properties]
  end
end
