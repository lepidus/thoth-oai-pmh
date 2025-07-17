# frozen_string_literal: true

ENV['APP_ENV'] = 'test'

require_relative '../../api/client'
require 'test/unit'
require 'rack/test'
require 'webmock/test_unit'

# Test suite for the Thoth GraphQL API client
class ThothClientTest < Test::Unit::TestCase
  include Rack::Test::Methods

  def test_execute_query
    stub_request(:post, 'https://api.thoth.pub/graphql')
      .to_return(
        status: 200,
        body: '{"data":{"work":{"title": "Test Work"}}}',
        headers: { 'Content-Type' => 'application/json' }
      )

    client = Thoth::Api::Client.new
    response = client.execute(query: '{ work(workId: "f8e84405-c554-4375-bd4f-cb56f382adff") { title } }')
    assert_equal 200, response.status
    assert_includes response.body, 'Test Work'
  end
end
