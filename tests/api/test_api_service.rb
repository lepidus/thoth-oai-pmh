# frozen_string_literal: true

ENV['APP_ENV'] = 'test'

require_relative '../../api/service'
require 'test/unit'
require 'rack/test'
require 'webmock/test_unit'

# Test suite for the Thoth API service
class ThothApiServiceTest < Test::Unit::TestCase
  include Rack::Test::Methods

  def test_get_latest
    stub_request(:post, 'https://api.thoth.pub/graphql')
      .to_return(
        status: 200,
        body: '{"data": {"works": [{"updatedAtWithRelations": "2025-05-02T13:37:12.182980Z"}]}}',
        headers: { 'Content-Type' => 'application/json' }
      )

    service = Thoth::Api::Service.new
    latest = service.latest
    assert_equal '2022-05-02T13:37:12.182980Z', latest
  end

  def test_get_earliest
    stub_request(:post, 'https://api.thoth.pub/graphql')
      .to_return(
        status: 200,
        body: '{"data": {"works": [{"updatedAtWithRelations": "2020-05-02T13:37:12.182980Z"}]}}',
        headers: { 'Content-Type' => 'application/json' }
      )

    service = Thoth::Api::Service.new
    earliest = service.earliest
    assert_equal '2020-05-02T13:37:12.182980Z', earliest
  end
end
