# frozen_string_literal: true

ENV['APP_ENV'] = 'test'

require_relative '../app'
require_relative '../api/client'
require 'test/unit'
require 'rack/test'
require 'webmock/test_unit'

# Test suite for the Thoth API client
class ThothClientTest < Test::Unit::TestCase
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  def test_works_query
    stub_request(:post, 'https://api.thoth.pub/graphql')
      .to_return(
        status: 200,
        body: '{"data":{"works":[]}}',
        headers: { 'Content-Type' => 'application/json' }
      )

    client = Thoth::Api::Client.new
    response = client.works
    assert_equal 200, response.code
    assert_includes response.body, 'works'
  end
end
