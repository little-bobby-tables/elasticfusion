module Elasticfusion
  class InstallGenerator < Rails::Generators::Base
    source_root File.expand_path('../templates', __FILE__)

    def copy_initializer
      copy_file 'initializer.rb', 'config/initializers/elasticfusion.rb'
    end
  end
end
