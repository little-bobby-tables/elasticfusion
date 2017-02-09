def ar_model(name)
  ActiveRecord::Base.establish_connection(adapter: 'sqlite3', database: ':memory:') unless ActiveRecord::Base.connected?

  ActiveRecord::Migration.verbose = false

  table = name.underscore.pluralize

  unless ActiveRecord::Base.connection.data_sources.include? table
    ActiveRecord::Schema.define(version: 1) do
      create_table table do |t|
        t.integer :attr
      end
    end
  end

  name = name.to_sym
  Object.send(:remove_const, name) if Object.constants.include?(name)
  Object.const_set name, Class.new(ActiveRecord::Base)
end
