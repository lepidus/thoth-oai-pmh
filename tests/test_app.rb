# frozen_string_literal: true

ENV['APP_ENV'] = 'test'

require_relative '../app'
require 'test/unit'
require 'rack/test'
require 'webmock/test_unit'

# Test suite for the OAI-PMH application
class OaiAppTest < Test::Unit::TestCase
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  def test_root_redirects_to_oai
    get '/'
    assert_equal 302, last_response.status
    assert_equal 'http://example.org/oai', last_response.location
  end

  def test_xsl_stylesheet
    get '/oai2.xsl'
    assert_equal 200, last_response.status
    assert_includes last_response.content_type, 'text/xsl'
  end

  def test_oai_identify_verb
    stub_request(:post, 'https://api.thoth.pub/graphql')
      .to_return(
        status: 200,
        body: '{"data": {"works": [{"updatedAtWithRelations": "2020-05-02T13:37:12.182980Z"}]}}',
        headers: { 'Content-Type' => 'application/json' }
      )
    get '/oai?verb=Identify'
    assert_equal 200, last_response.status
    assert_includes last_response.body, '<repositoryName>Thoth OAI-PMH Repository</repositoryName>'
    assert_includes last_response.body, '<scheme>oai</scheme>' \
                                        '<repositoryIdentifier>thoth</repositoryIdentifier>' \
                                        '<delimiter>:</delimiter>' \
                                        '<sampleIdentifier>' \
                                        'thoth:5a08ff03-7d53-42a9-bfb5-7fc81c099c52' \
                                        '</sampleIdentifier>' \
                                        '</oai-identifier></description>'
  end

  def test_invalid_verb_returns_error
    get '/oai?verb=InvalidVerb'
    assert_equal 200, last_response.status
    assert_includes last_response.body, 'badVerb'
  end

  def test_invalid_page_returns_not_found_with_redirect
    get '/invalid_page'
    assert_equal 404, last_response.status
    assert_includes last_response.body, '404 - Page Not Found'
    assert_includes last_response.body, '<a href="/oai">OAI-PMH Interface</a>'
  end
end
