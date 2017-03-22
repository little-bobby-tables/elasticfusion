# frozen_string_literal: true
require 'minitest/mock'

def assert_method_call(obj, method)
  mock = MiniTest::Mock.new
  mock.expect :call, nil
  obj.stub method, mock do
    yield
  end

  # Minitest's default mock expectation messages are too cryptic.

  begin
    mock.verify
  rescue MockExpectationError
    raise Minitest::Assertion, "Expected #{method} to be called."
  end
end

def refute_method_call(obj, method)
  mock = MiniTest::Mock.new
  mock.expect :call, nil do
    raise Minitest::Assertion, "Expected #{method} to not be called."
  end
  obj.stub method, mock do
    yield
  end
end
