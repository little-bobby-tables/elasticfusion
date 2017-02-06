$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)

# require 'simplecov'
# SimpleCov.start do
#   add_filter 'test'
# end
#

require 'minitest/autorun'
require 'minitest/reporters'
require 'rails/all'

require 'elasticfusion'

require 'dummy_mapping'

Minitest::Reporters.use!
