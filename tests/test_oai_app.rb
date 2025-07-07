ENV['APP_ENV'] = 'test'

require_relative '../app.rb'
require 'test/unit'
require 'rack/test'

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
    get '/oai?verb=Identify'
    assert_equal 200, last_response.status
    assert_includes last_response.body, '<repositoryName>Thoth OAI-PMH Repository</repositoryName>'
    assert_includes last_response.body, '<scheme>oai</scheme><repositoryIdentifier>thoth</repositoryIdentifier>'\
      '<delimiter>:</delimiter><sampleIdentifier>thoth:13900</sampleIdentifier></oai-identifier></description>'
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