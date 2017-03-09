# frozen_string_literal: true
module Elasticfusion
  # Call this method from within an autoloaded file (e.g. models/application_record.rb)
  # to instantiate index definitions and refresh them in development, when Rails
  # autoreloads constants.
  def self.load_index_definitions
    Dir.glob(Rails.root.join('app', 'indexes', '*.rb'), &method(:load))
  end
end
