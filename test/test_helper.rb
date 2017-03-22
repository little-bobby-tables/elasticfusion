# frozen_string_literal: true
$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)

require 'simplecov'
SimpleCov.start do
  add_filter 'test'
end

require 'minitest/autorun'
require 'minitest/reporters'
require 'rails/all'

require 'mock_helper'

require 'elasticfusion'

Minitest::Reporters.use!
