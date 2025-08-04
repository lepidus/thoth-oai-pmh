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

    mapper = Thoth::Oai::Mapper::OaiOpenaire.new(input)
    assert_equal expected_output, mapper.build_title_tag(Builder::XmlMarkup.new)
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

    mapper = Thoth::Oai::Mapper::OaiOpenaire.new(input)
    assert_equal expected_output, mapper.build_creator_tag(Builder::XmlMarkup.new)
  end

  def test_build_contributor_tag
    input = {
      'contributor' => [{
        'contributionType' => 'EDITOR',
        'firstName' => 'Jane',
        'lastName' => 'Smith',
        'fullName' => 'Jane Smith',
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
      '<datacite:contributors>',
      '<datacite:contributor contributorType="Editor">',
      '<datacite:creatorName nameType="Personal">Smith, Jane</datacite:creatorName>',
      '<datacite:givenName>Jane</datacite:givenName>',
      '<datacite:familyName>Smith</datacite:familyName>',
      '<datacite:nameIdentifier nameIdentifierScheme="ORCID" schemeURI="https://orcid.org/">',
      '1234-1234-1234-1234',
      '</datacite:nameIdentifier>',
      '<datacite:affiliation affiliationIdentifier="https://ror.org/03vek6s52">',
      'Harvard University',
      '</datacite:affiliation>',
      '</datacite:contributor>',
      '</datacite:contributors>'
    ].join

    mapper = Thoth::Oai::Mapper::OaiOpenaire.new(input)
    assert_equal expected_output, mapper.build_contributor_tag(Builder::XmlMarkup.new)
  end

  def test_build_funding_reference_tag
    input = {
      'fundings' => [{
        'institution' => {
          'institutionName' => 'National Science Foundation',
          'ror' => 'https://ror.org/03vek6s52'
        },
        'grantNumber' => '123456',
        'projectName' => 'Research Grant'
      }]
    }

    expected_output = [
      '<oaire:fundingReferences>',
      '<oaire:fundingReference>',
      '<oaire:funderName>National Science Foundation</oaire:funderName>',
      '<oaire:funderIdentifier funderIdentifierType="ROR">',
      'https://ror.org/03vek6s52',
      '</oaire:funderIdentifier>',
      '<oaire:awardNumber>123456</oaire:awardNumber>',
      '<oaire:awardTitle>Research Grant</oaire:awardTitle>',
      '</oaire:fundingReference>',
      '</oaire:fundingReferences>'
    ].join

    mapper = Thoth::Oai::Mapper::OaiOpenaire.new(input)
    assert_equal expected_output, mapper.build_funding_reference_tag(Builder::XmlMarkup.new)
  end

  def test_builder_alternative_identifier_tag
    input = {
      'doi' => '10.1234/example.doi',
      'landingPage' => 'https://example.com/landing-page',
      'publications' => [{
        'isbn' => '978-3-16-148410-0'
      }]
    }

    expected_output = [
      '<datacite:alternateIdentifiers>',
      '<datacite:alternateIdentifier alternateIdentifierType="DOI">',
      '10.1234/example.doi',
      '</datacite:alternateIdentifier>',
      '<datacite:alternateIdentifier alternateIdentifierType="URL">',
      'https://example.com/landing-page',
      '</datacite:alternateIdentifier>',
      '<datacite:alternateIdentifier alternateIdentifierType="ISBN">',
      '978-3-16-148410-0',
      '</datacite:alternateIdentifier>',
      '</datacite:alternateIdentifiers>'
    ].join

    mapper = Thoth::Oai::Mapper::OaiOpenaire.new(input)
    assert_equal expected_output, mapper.build_alternate_identifier_tag(Builder::XmlMarkup.new)
  end
end
