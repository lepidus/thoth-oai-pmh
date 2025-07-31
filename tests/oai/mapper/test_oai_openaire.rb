# frozen_string_literal: true

ENV['APP_ENV'] = 'test'

require 'builder'
require 'test/unit'
require 'rack/test'
require 'webmock/test_unit'
require_relative '../../../oai/mapper/oai_openaire'

# Test suite for the OAI OpenAIRE Mapper
class OaiOpenaireMapperTest < Test::Unit::TestCase
  include Rack::Test::Methods

  def test_build_title_tag
    input = {
      'title' => 'Sample Title',
      'subtitle' => 'Sample Subtitle'
    }

    expected_output = [
      '<datacite:titles>',
      '<datacite:title>Sample Title</datacite:title>',
      '<datacite:title titleType="Subtitle">Sample Subtitle</datacite:title>',
      '</datacite:titles>'
    ].join

    assert_equal expected_output, Thoth::Oai::Mapper::OaiOpenaire.new(input).build_title_tag(Builder::XmlMarkup.new)
  end

  def test_build_creator_tag
    input = {
      'creator' => [{
        'firstName' => 'John',
        'lastName' => 'Doe',
        'fullName' => 'John Doe',
        'contributor' => {
          'orcid' => '1234-1234-1234-1234'
        },
        'affiliations' => [{
          'institution' => {
            'institutionName' => 'Harvard University',
            'ror' => 'https://ror.org/03vek6s52'
          }
        }]
      }]
    }

    expected_output = [
      '<datacite:creators>',
      '<datacite:creator>',
      '<datacite:creatorName nameType="Personal">Doe, John</datacite:creatorName>',
      '<datacite:givenName>John</datacite:givenName>',
      '<datacite:familyName>Doe</datacite:familyName>',
      '<datacite:nameIdentifier nameIdentifierScheme="ORCID" schemeURI="https://orcid.org/">',
      '1234-1234-1234-1234',
      '</datacite:nameIdentifier>',
      '<datacite:affiliation affiliationIdentifier="https://ror.org/03vek6s52">',
      'Harvard University',
      '</datacite:affiliation>',
      '</datacite:creator>',
      '</datacite:creators>'
    ].join

    assert_equal expected_output, Thoth::Oai::Mapper::OaiOpenaire.new(input).build_creator_tag(Builder::XmlMarkup.new)
  end
end
