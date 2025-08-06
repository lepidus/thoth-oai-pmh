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

  def test_build_related_identifier_tag
    input = {
      'relations' => [{
        'relationType' => 'HAS_CHILD',
        'relatedWork' => {
          'doi' => 'https://doi.org/10.1234/related.doi',
          'landingPage' => 'https://example.com/related-landing-page',
          'publications' => [{
            'isbn' => '978-3-16-148410-0'
          }]
        }
      }]
    }

    expected_output = [
      '<datacite:relatedIdentifiers>',
      '<datacite:relatedIdentifier relatedIdentifierType="DOI" relationType="HasPart">',
      'https://doi.org/10.1234/related.doi',
      '</datacite:relatedIdentifier>',
      '<datacite:relatedIdentifier relatedIdentifierType="URL" relationType="HasPart">',
      'https://example.com/related-landing-page',
      '</datacite:relatedIdentifier>',
      '<datacite:relatedIdentifier relatedIdentifierType="ISBN" relationType="HasPart">',
      '978-3-16-148410-0',
      '</datacite:relatedIdentifier>',
      '</datacite:relatedIdentifiers>'
    ].join

    mapper = Thoth::Oai::Mapper::OaiOpenaire.new(input)
    assert_equal expected_output, mapper.build_related_identifier_tag(Builder::XmlMarkup.new)
  end

  def test_build_language_tag
    input = {
      'languages' => [
        {
          'languageCode' => 'eng'
        },
        {
          'languageCode' => 'fra'
        }
      ]
    }

    expected_output = [
      '<dc:language>eng</dc:language>',
      '<dc:language>fra</dc:language>'
    ].join

    mapper = Thoth::Oai::Mapper::OaiOpenaire.new(input)
    xml = Builder::XmlMarkup.new
    mapper.build_language_tag(xml)
    assert_equal expected_output, xml.target!
  end

  def test_build_publisher_tag
    input = {
      'imprint' => {
        'publisher' => {
          'publisherName' => 'Sample Publisher'
        }
      }
    }

    expected_output = '<dc:publisher>Sample Publisher</dc:publisher>'

    mapper = Thoth::Oai::Mapper::OaiOpenaire.new(input)
    xml = Builder::XmlMarkup.new
    mapper.build_publisher_tag(xml)
    assert_equal expected_output, xml.target!
  end

  def test_build_date_tag
    input = {
      'publicationDate' => '2023-10-01'
    }

    expected_output = '<datacite:date dateType="Issued">2023-10-01</datacite:date>'

    mapper = Thoth::Oai::Mapper::OaiOpenaire.new(input)
    xml = Builder::XmlMarkup.new
    mapper.build_date_tag(xml)
    assert_equal expected_output, xml.target!
  end

  def test_build_resource_type_tag
    input = {
      'workType' => 'MONOGRAPH'
    }

    expected_output = [
      '<oaire:resourceType resourceTypeGeneral="literature" ',
      'uri="http://purl.org/coar/resource_type/c_2f33">',
      'book',
      '</oaire:resourceType>'
    ].join

    mapper = Thoth::Oai::Mapper::OaiOpenaire.new(input)
    xml = Builder::XmlMarkup.new
    mapper.build_resource_type_tag(xml)
    assert_equal expected_output, xml.target!
  end

  def test_build_description_tag
    input = {
      'shortAbstract' => 'This is a short abstract.',
      'longAbstract' => 'This is a long abstract.',
      'toc' => 'This is a Table of Contents.'
    }

    expected_output = [
      '<dc:description>This is a short abstract.</dc:description>',
      '<dc:description>This is a long abstract.</dc:description>',
      '<dc:description>This is a Table of Contents.</dc:description>'
    ].join

    mapper = Thoth::Oai::Mapper::OaiOpenaire.new(input)
    xml = Builder::XmlMarkup.new
    mapper.build_description_tag(xml)
    assert_equal expected_output, xml.target!
  end

  def test_build_format_tag
    input = {
      'publications' => [
        {
          'publicationType' => 'PDF'
        },
        {
          'publicationType' => 'HTML'
        }
      ]
    }

    expected_output = [
      '<dc:format>application/pdf</dc:format>',
      '<dc:format>application/html</dc:format>'
    ].join

    mapper = Thoth::Oai::Mapper::OaiOpenaire.new(input)
    xml = Builder::XmlMarkup.new
    mapper.build_format_tag(xml)
    assert_equal expected_output, xml.target!
  end

  def test_build_identifier_tag
    input = {
      'workId' => 'e4ab1c2d3-4567-8901-2345-6789abcdef01'
    }

    expected_output = [
      '<datacite:identifier identifierType="URL">',
      'https://thoth.pub/books/e4ab1c2d3-4567-8901-2345-6789abcdef01',
      '</datacite:identifier>'
    ].join

    mapper = Thoth::Oai::Mapper::OaiOpenaire.new(input)
    xml = Builder::XmlMarkup.new
    mapper.build_identifier_tag(xml)
    assert_equal expected_output, xml.target!
  end

  def test_build_rights_tag
    input = {
      'license' => 'http://creativecommons.org/licenses/by/4.0/'
    }

    expected_output = [
      '<datacite:rights rightsURI="http://purl.org/coar/access_right/c_abf2">',
      'open access',
      '</datacite:rights>'
    ]

    mapper = Thoth::Oai::Mapper::OaiOpenaire.new(input)
    xml = Builder::XmlMarkup.new
    mapper.build_rights_tag(xml)
    assert_equal expected_output.join, xml.target!
  end

  def test_build_subject_tag
    input = {
      'subjects' => [
        {
          'subjectType' => 'BIC',
          'subjectCode' => 'ACND'
        },
        {
          'subjectType' => 'BISAC',
          'subjectCode' => 'ART010000'
        },
        {
          'subjectType' => 'THEMA',
          'subjectCode' => 'AGA'
        },
        {
          'subjectType' => 'LCC',
          'subjectCode' => 'N7480'
        },
        {
          'subjectType' => 'KEYWORD',
          'subjectCode' => 'History of art'
        },
        {
          'subjectType' => 'CUSTOM',
          'subjectCode' => 'Art'
        }
      ]
    }

    expected_output = [
      '<datacite:subject subjectScheme="BIC">ACND</datacite:subject>',
      '<datacite:subject subjectScheme="BISAC">ART010000</datacite:subject>',
      '<datacite:subject subjectScheme="Thema">AGA</datacite:subject>',
      '<datacite:subject subjectScheme="LCC">N7480</datacite:subject>',
      '<datacite:subject>History of art</datacite:subject>',
      '<datacite:subject>Art</datacite:subject>'
    ].join

    mapper = Thoth::Oai::Mapper::OaiOpenaire.new(input)
    xml = Builder::XmlMarkup.new
    mapper.build_subject_tag(xml)
    assert_equal expected_output, xml.target!
  end

  def test_build_license_condition_tag
    input = {
      'license' => 'http://creativecommons.org/licenses/by/4.0/'
    }

    expected_output = [
      '<oaire:licenseCondition uri="http://creativecommons.org/licenses/by/4.0/">',
      'CC BY 4.0',
      '</oaire:licenseCondition>'
    ].join

    mapper = Thoth::Oai::Mapper::OaiOpenaire.new(input)
    xml = Builder::XmlMarkup.new
    mapper.build_license_condition_tag(xml)
    assert_equal expected_output, xml.target!
  end

  def test_build_size_tag
    input = {
      'pageCount' => 300,
      'imageCount' => 50,
      'tableCount' => 10,
      'audioCount' => 5,
      'videoCount' => 2
    }

    expected_output = [
      '<datacite:sizes>',
      '<datacite:size>300 pages</datacite:size>',
      '<datacite:size>50 images</datacite:size>',
      '<datacite:size>10 tables</datacite:size>',
      '<datacite:size>5 audios</datacite:size>',
      '<datacite:size>2 videos</datacite:size>',
      '</datacite:sizes>'
    ].join

    mapper = Thoth::Oai::Mapper::OaiOpenaire.new(input)
    xml = Builder::XmlMarkup.new
    mapper.build_size_tag(xml)
    assert_equal expected_output, xml.target!
  end
end
