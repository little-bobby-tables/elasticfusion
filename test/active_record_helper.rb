# frozen_string_literal: true
def ar_model(name)
  ActiveRecord::Base.establish_connection(adapter: 'sqlite3', database: ':memory:') unless ActiveRecord::Base.connected?

  ActiveRecord::Migration.verbose = false

  table = name.underscore.pluralize

  unless ActiveRecord::Base.connection.data_sources.include? table
    ActiveRecord::Schema.define(version: 1) do
      create_table table do |t|
        yield t if block_given?
      end
    end
  end

  name = name.to_sym
  Object.send(:remove_const, name) if Object.constants.include?(name)

  Object.const_set(name, Class.new(ActiveRecord::Base))
        .tap(&:delete_all) # Reset records created by previous tests
end

def tags_stars_date_model(&block)
  model = ar_model 'SearchingTestModel' do |t|
    t.string :tags, array: true
    t.integer :stars
    t.datetime :date
  end

  Elasticfusion.define model do
    settings index: { number_of_shards: 1 } do
      mappings dynamic: false, _source: { enabled: false }, _all: { enabled: false } do
        indexes :id, type: 'integer'
        indexes :tags, type: 'keyword'
        indexes :stars, type: 'integer'
        indexes :date, type: 'date'
      end
    end

    elasticfusion(&block)

    after_commit(on: :create) do
      self.class.__elasticsearch__.refresh_index!
    end

    def as_indexed_json(*)
      {
        id: id,
        tags: JSON.parse(tags), # SQLite doesn't handle arrays natively
        stars: stars,
        date: date.iso8601
      }
    end

    index_name 'searching_test_model_index'
    __elasticsearch__.create_index! force: true
  end

  model
end
