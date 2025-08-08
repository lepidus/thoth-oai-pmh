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

  def setup
    @builder = Builder::XmlMarkup.new
  end

  def test_build_title_tag
    input = {
      'title' => 'Sample Title',
      'subtitle' => 'Sample Subtitle'
    }
    expected = <<~XML.gsub(/\n\s*/, '')
      <datacite:titles>
      <datacite:title>Sample Title</datacite:title>
      <datacite:title titleType="Subtitle">Sample Subtitle</datacite:title>
      </datacite:titles>
    XML
    mapper = Thoth::Oai::Mapper::OaiOpenaire.new(input)
    mapper.build_title_tag(@builder)
    assert_equal expected, @builder.target!
  end

  def test_build_creator_tag
    input = {
      'creator' => [{
        'firstName' => 'John',
        'lastName' => 'Doe',
        'fullName' => 'John Doe',
        'contributor' => { 'orcid' => '1234-1234-1234-1234' },
        'affiliations' => [{
          'institution' => {
            'institutionName' => 'Harvard University',
            'ror' => 'https://ror.org/03vek6s52'
          }
        }]
      }]
    }
    expected = <<~XML.gsub(/\n\s*/, '')
      <datacite:creators>
      <datacite:creator>
      <datacite:creatorName nameType="Personal">Doe, John</datacite:creatorName>
      <datacite:givenName>John</datacite:givenName>
      <datacite:familyName>Doe</datacite:familyName>
      <datacite:nameIdentifier nameIdentifierScheme="ORCID" schemeURI="https://orcid.org/">
      1234-1234-1234-1234
      </datacite:nameIdentifier>
      <datacite:affiliation affiliationIdentifier="https://ror.org/03vek6s52">
      Harvard University
      </datacite:affiliation>
      </datacite:creator>
      </datacite:creators>
    XML
    mapper = Thoth::Oai::Mapper::OaiOpenaire.new(input)
    mapper.build_creator_tag(@builder)
    assert_equal expected, @builder.target!
  end

  def test_build_contributor_tag
    input = {
      'contributor' => [{
        'contributionType' => 'EDITOR',
        'firstName' => 'Jane',
        'lastName' => 'Smith',
        'fullName' => 'Jane Smith',
        'contributor' => { 'orcid' => '1234-1234-1234-1234' },
        'affiliations' => [{
          'institution' => {
            'institutionName' => 'Harvard University',
            'ror' => 'https://ror.org/03vek6s52'
          }
        }]
      }]
    }
    expected = <<~XML.gsub(/\n\s*/, '')
      <datacite:contributors>
      <datacite:contributor contributorType="Editor">
      <datacite:creatorName nameType="Personal">Smith, Jane</datacite:creatorName>
      <datacite:givenName>Jane</datacite:givenName>
      <datacite:familyName>Smith</datacite:familyName>
      <datacite:nameIdentifier nameIdentifierScheme="ORCID" schemeURI="https://orcid.org/">
      1234-1234-1234-1234
      </datacite:nameIdentifier>
      <datacite:affiliation affiliationIdentifier="https://ror.org/03vek6s52">
      Harvard University
      </datacite:affiliation>
      </datacite:contributor>
      </datacite:contributors>
    XML
    mapper = Thoth::Oai::Mapper::OaiOpenaire.new(input)
    mapper.build_contributor_tag(@builder)
    assert_equal expected, @builder.target!
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
    expected = <<~XML.gsub(/\n\s*/, '')
      <oaire:fundingReferences>
      <oaire:fundingReference>
      <oaire:funderName>National Science Foundation</oaire:funderName>
      <oaire:funderIdentifier funderIdentifierType="ROR">https://ror.org/03vek6s52</oaire:funderIdentifier>
      <oaire:awardNumber>123456</oaire:awardNumber>
      <oaire:awardTitle>Research Grant</oaire:awardTitle>
      </oaire:fundingReference>
      </oaire:fundingReferences>
    XML
    mapper = Thoth::Oai::Mapper::OaiOpenaire.new(input)
    mapper.build_funding_reference_tag(@builder)
    assert_equal expected, @builder.target!
  end

  def test_builder_alternative_identifier_tag
    input = {
      'doi' => '10.1234/example.doi',
      'landingPage' => 'https://example.com/landing-page',
      'publications' => [{ 'isbn' => '978-3-16-148410-0' }]
    }
    expected = <<~XML.gsub(/\n\s*/, '')
      <datacite:alternateIdentifiers>
      <datacite:alternateIdentifier alternateIdentifierType="DOI">10.1234/example.doi</datacite:alternateIdentifier>
      <datacite:alternateIdentifier alternateIdentifierType="URL">
      https://example.com/landing-page
      </datacite:alternateIdentifier>
      <datacite:alternateIdentifier alternateIdentifierType="ISBN">978-3-16-148410-0</datacite:alternateIdentifier>
      </datacite:alternateIdentifiers>
    XML
    mapper = Thoth::Oai::Mapper::OaiOpenaire.new(input)
    mapper.build_alternate_identifier_tag(@builder)
    assert_equal expected, @builder.target!
  end

  def test_build_related_identifier_tag
    input = {
      'relations' => [{
        'relationType' => 'HAS_CHILD',
        'relatedWork' => {
          'doi' => 'https://doi.org/10.1234/related.doi',
          'landingPage' => 'https://example.com/related-landing-page',
          'publications' => [{ 'isbn' => '978-3-16-148410-0' }]
        }
      }]
    }
    expected = <<~XML.gsub(/\n\s*/, '')
      <datacite:relatedIdentifiers>
      <datacite:relatedIdentifier relatedIdentifierType="DOI" relationType="HasPart">
      https://doi.org/10.1234/related.doi
      </datacite:relatedIdentifier>
      <datacite:relatedIdentifier relatedIdentifierType="URL" relationType="HasPart">
      https://example.com/related-landing-page
      </datacite:relatedIdentifier>
      <datacite:relatedIdentifier relatedIdentifierType="ISBN" relationType="HasPart">
      978-3-16-148410-0
      </datacite:relatedIdentifier>
      </datacite:relatedIdentifiers>
    XML
    mapper = Thoth::Oai::Mapper::OaiOpenaire.new(input)
    mapper.build_related_identifier_tag(@builder)
    assert_equal expected, @builder.target!
  end

  def test_build_language_tag
    input = { 'languages' => [{ 'languageCode' => 'eng' }, { 'languageCode' => 'fra' }] }
    expected = '<dc:language>eng</dc:language><dc:language>fra</dc:language>'
    mapper = Thoth::Oai::Mapper::OaiOpenaire.new(input)
    mapper.build_language_tag(@builder)
    assert_equal expected, @builder.target!
  end

  def test_build_publisher_tag
    input = { 'imprint' => { 'publisher' => { 'publisherName' => 'Sample Publisher' } } }
    expected = '<dc:publisher>Sample Publisher</dc:publisher>'
    mapper = Thoth::Oai::Mapper::OaiOpenaire.new(input)
    mapper.build_publisher_tag(@builder)
    assert_equal expected, @builder.target!
  end

  def test_build_date_tag
    input = { 'publicationDate' => '2023-10-01' }
    expected = '<datacite:date dateType="Issued">2023-10-01</datacite:date>'
    mapper = Thoth::Oai::Mapper::OaiOpenaire.new(input)
    mapper.build_date_tag(@builder)
    assert_equal expected, @builder.target!
  end

  def test_build_resource_type_tag
    input = { 'workType' => 'MONOGRAPH' }
    expected = <<~XML.gsub(/\n\s*/, '')
      <oaire:resourceType resourceTypeGeneral="literature" uri="http://purl.org/coar/resource_type/c_2f33">
      book
      </oaire:resourceType>
    XML
    mapper = Thoth::Oai::Mapper::OaiOpenaire.new(input)
    mapper.build_resource_type_tag(@builder)
    assert_equal expected, @builder.target!
  end

  def test_build_description_tag
    input = {
      'shortAbstract' => 'This is a short abstract.',
      'longAbstract' => 'This is a long abstract.',
      'toc' => 'This is a Table of Contents.'
    }
    expected = <<~XML.gsub(/\n\s*/, '')
      <dc:description>This is a short abstract.</dc:description>
      <dc:description>This is a long abstract.</dc:description>
      <dc:description>This is a Table of Contents.</dc:description>
    XML
    mapper = Thoth::Oai::Mapper::OaiOpenaire.new(input)
    mapper.build_description_tag(@builder)
    assert_equal expected, @builder.target!
  end

  def test_build_format_tag
    input = { 'publications' => [{ 'publicationType' => 'PDF' }, { 'publicationType' => 'HTML' }] }
    expected = '<dc:format>application/pdf</dc:format><dc:format>application/html</dc:format>'
    mapper = Thoth::Oai::Mapper::OaiOpenaire.new(input)
    mapper.build_format_tag(@builder)
    assert_equal expected, @builder.target!
  end

  def test_build_identifier_tag
    input = { 'workId' => 'e4ab1c2d3-4567-8901-2345-6789abcdef01' }
    expected = <<~XML.gsub(/\n\s*/, '')
      <datacite:identifier identifierType="URL">
      https://thoth.pub/books/e4ab1c2d3-4567-8901-2345-6789abcdef01
      </datacite:identifier>
    XML
    mapper = Thoth::Oai::Mapper::OaiOpenaire.new(input)
    mapper.build_identifier_tag(@builder)
    assert_equal expected, @builder.target!
  end

  def test_build_rights_tag
    input = { 'license' => 'http://creativecommons.org/licenses/by/4.0/' }
    expected = <<~XML.gsub(/\n\s*/, '')
      <datacite:rights rightsURI="http://purl.org/coar/access_right/c_abf2">open access</datacite:rights>
    XML
    mapper = Thoth::Oai::Mapper::OaiOpenaire.new(input)
    mapper.build_rights_tag(@builder)
    assert_equal expected, @builder.target!
  end

  def test_build_subject_tag
    input = {
      'subjects' => [
        { 'subjectType' => 'BIC', 'subjectCode' => 'ACND' },
        { 'subjectType' => 'BISAC', 'subjectCode' => 'ART010000' },
        { 'subjectType' => 'THEMA', 'subjectCode' => 'AGA' },
        { 'subjectType' => 'LCC', 'subjectCode' => 'N7480' },
        { 'subjectType' => 'KEYWORD', 'subjectCode' => 'History of art' },
        { 'subjectType' => 'CUSTOM', 'subjectCode' => 'Art' }
      ]
    }
    expected = <<~XML.gsub(/\n\s*/, '')
      <datacite:subject subjectScheme="BIC">ACND</datacite:subject>
      <datacite:subject subjectScheme="BISAC">ART010000</datacite:subject>
      <datacite:subject subjectScheme="Thema">AGA</datacite:subject>
      <datacite:subject subjectScheme="LCC">N7480</datacite:subject>
      <datacite:subject>History of art</datacite:subject>
      <datacite:subject>Art</datacite:subject>
    XML
    mapper = Thoth::Oai::Mapper::OaiOpenaire.new(input)
    mapper.build_subject_tag(@builder)
    assert_equal expected, @builder.target!
  end

  def test_build_license_condition_tag
    input = { 'license' => 'http://creativecommons.org/licenses/by/4.0/' }
    expected = <<~XML.gsub(/\n\s*/, '')
      <oaire:licenseCondition uri="http://creativecommons.org/licenses/by/4.0/">CC BY 4.0</oaire:licenseCondition>
    XML
    mapper = Thoth::Oai::Mapper::OaiOpenaire.new(input)
    mapper.build_license_condition_tag(@builder)
    assert_equal expected, @builder.target!
  end

  def test_build_size_tag
    input = {
      'pageCount' => 300, 'imageCount' => 50, 'tableCount' => 10,
      'audioCount' => 5, 'videoCount' => 2
    }
    expected = <<~XML.gsub(/\n\s*/, '')
      <datacite:sizes>
      <datacite:size>300 pages</datacite:size>
      <datacite:size>50 images</datacite:size>
      <datacite:size>10 tables</datacite:size>
      <datacite:size>5 audios</datacite:size>
      <datacite:size>2 videos</datacite:size>
      </datacite:sizes>
    XML
    mapper = Thoth::Oai::Mapper::OaiOpenaire.new(input)
    mapper.build_size_tag(@builder)
    assert_equal expected, @builder.target!
  end

  def test_build_file_tag
    input = {
      'publications' => [{
        'publicationType' => 'PDF',
        'locations' => [{ 'fullTextUrl' => 'https://example.com/file.pdf' }]
      }]
    }
    expected = <<~XML.gsub(/\n\s*/, '')
      <oaire:file mimeType="application/pdf" objectType="fulltext">https://example.com/file.pdf</oaire:file>
    XML
    mapper = Thoth::Oai::Mapper::OaiOpenaire.new(input)
    mapper.build_file_tag(@builder)
    assert_equal expected, @builder.target!
  end

  def test_build_citation_title_tag
    input_book = {
      'workType' => 'TEXTBOOK',
      'issue' => [{ 'series' => { 'seriesName' => 'Series Name' } }]
    }
    expected_book = '<oaire:citationTitle>Series Name</oaire:citationTitle>'
    mapper_book = Thoth::Oai::Mapper::OaiOpenaire.new(input_book)
    mapper_book.build_citation_title_tag(@builder)
    assert_equal expected_book, @builder.target!

    @builder = Builder::XmlMarkup.new # Reset builder for next assertion
    input_chapter = {
      'workType' => 'BOOK_CHAPTER',
      'parentBook' => [{ 'relatedWork' => { 'fullTitle' => 'Related Book Title' } }]
    }
    expected_chapter = '<oaire:citationTitle>Related Book Title</oaire:citationTitle>'
    mapper_chapter = Thoth::Oai::Mapper::OaiOpenaire.new(input_chapter)
    mapper_chapter.build_citation_title_tag(@builder)
    assert_equal expected_chapter, @builder.target!
  end

  def test_build_citation_issue_tag
    input = {
      'workType' => 'EDITED_BOOK',
      'issue' => [{ 'issueOrdinal' => '12' }]
    }
    expected = '<oaire:citationIssue>12</oaire:citationIssue>'
    mapper = Thoth::Oai::Mapper::OaiOpenaire.new(input)
    mapper.build_citation_issue_tag(@builder)
    assert_equal expected, @builder.target!
  end

  def test_build_citation_start_page_tag
    input = { 'firstPage' => '100', 'workType' => 'BOOK_CHAPTER' }
    expected = '<oaire:citationStartPage>100</oaire:citationStartPage>'
    mapper = Thoth::Oai::Mapper::OaiOpenaire.new(input)
    mapper.build_citation_start_page_tag(@builder)
    assert_equal expected, @builder.target!
  end

  def test_build_citation_end_page_tag
    input = { 'lastPage' => '200', 'workType' => 'BOOK_CHAPTER' }
    expected = '<oaire:citationEndPage>200</oaire:citationEndPage>'
    mapper = Thoth::Oai::Mapper::OaiOpenaire.new(input)
    mapper.build_citation_end_page_tag(@builder)
    assert_equal expected, @builder.target!
  end

  def test_build_citation_edition_tag
    input = {
      'workType' => 'BOOK_CHAPTER',
      'parentBook' => [{ 'relatedWork' => { 'edition' => '2' } }]
    }
    expected = '<oaire:citationEdition>2</oaire:citationEdition>'
    mapper = Thoth::Oai::Mapper::OaiOpenaire.new(input)
    mapper.build_citation_edition_tag(@builder)
    assert_equal expected, @builder.target!
  end

  def test_map
    input = {
      'title' => 'Sample Book Title',
      'subtitle' => 'Sample Book Subtitle',
      'creator' => [{
        'firstName' => 'John', 'lastName' => 'Doe', 'fullName' => 'John Doe',
        'contributor' => { 'orcid' => '1234-1234-1234-1234' },
        'affiliations' => [{
          'institution' => { 'institutionName' => 'Harvard University', 'ror' => 'https://ror.org/03vek6s52' }
        }]
      }],
      'contributor' => [{
        'contributionType' => 'EDITOR', 'firstName' => 'Jane', 'lastName' => 'Smith', 'fullName' => 'Jane Smith',
        'contributor' => { 'orcid' => '1234-1234-1234-1234' },
        'affiliations' => [{
          'institution' => { 'institutionName' => 'Harvard University', 'ror' => 'https://ror.org/03vek6s52' }
        }]
      }],
      'fundings' => [{
        'institution' => { 'institutionName' => 'National Science Foundation', 'ror' => 'https://ror.org/03vek6s52' },
        'grantNumber' => '123456', 'projectName' => 'Research Grant'
      }],
      'doi' => '10.1234/example.doi',
      'landingPage' => 'https://example.com/landing-page',
      'publications' => [{
        'publicationType' => 'PDF', 'isbn' => '978-3-16-148410-0',
        'locations' => [{ 'fullTextUrl' => 'https://example.com/file.pdf' }]
      }],
      'relations' => [{
        'relationType' => 'HAS_CHILD',
        'relatedWork' => {
          'doi' => 'https://doi.org/10.1234/related.doi',
          'landingPage' => 'https://example.com/related-landing-page',
          'publications' => [{ 'isbn' => '978-3-16-148410-0' }]
        }
      }],
      'parentBook' => [],
      'languages' => [{ 'languageCode' => 'eng' }],
      'imprint' => { 'publisher' => { 'publisherName' => 'Sample Publisher' } },
      'publicationDate' => '2023-10-01',
      'workType' => 'MONOGRAPH',
      'shortAbstract' => 'This is a short abstract.',
      'longAbstract' => 'This is a long abstract.',
      'toc' => 'Table of Contents',
      'workId' => '7c997ab7-5800-49db-8696-f2cab84e43d0',
      'subjects' => [
        { 'subjectType' => 'BIC', 'subjectCode' => 'ACND' },
        { 'subjectType' => 'BISAC', 'subjectCode' => 'ART010000' },
        { 'subjectType' => 'THEMA', 'subjectCode' => 'AGA' },
        { 'subjectType' => 'LCC', 'subjectCode' => 'N7480' },
        { 'subjectType' => 'KEYWORD', 'subjectCode' => 'History of art' },
        { 'subjectType' => 'CUSTOM', 'subjectCode' => 'Art' }
      ],
      'license' => 'http://creativecommons.org/licenses/by-nc-nd/4.0',
      'pageCount' => 300, 'imageCount' => 10, 'tableCount' => 5, 'audioCount' => 2, 'videoCount' => 1,
      'issue' => [{ 'issueOrdinal' => '12', 'series' => { 'seriesName' => 'Series Name' } }],
      'firstPage' => nil, 'lastPage' => nil
    }

    expected = <<~XML.gsub(/\n\s*/, '')
      <oaire:resource xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
       xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:dc="http://purl.org/dc/elements/1.1/"
       xmlns:dcterms="http://purl.org/dc/terms/"
       xmlns:datacite="http://datacite.org/schema/kernel-4"
       xmlns:oaire="http://namespace.openaire.eu/schema/oaire/"
       xsi:schemaLocation="http://namespace.openaire.eu/schema/oaire/
       https://www.openaire.eu/schema/repo-lit/4.0/openaire.xsd">
      <datacite:identifier identifierType="URL">
      https://thoth.pub/books/7c997ab7-5800-49db-8696-f2cab84e43d0
      </datacite:identifier>
      <datacite:titles>
      <datacite:title>Sample Book Title</datacite:title>
      <datacite:title titleType="Subtitle">Sample Book Subtitle</datacite:title>
      </datacite:titles>
      <datacite:creators>
      <datacite:creator>
      <datacite:creatorName nameType="Personal">Doe, John</datacite:creatorName>
      <datacite:givenName>John</datacite:givenName>
      <datacite:familyName>Doe</datacite:familyName>
      <datacite:nameIdentifier nameIdentifierScheme="ORCID" schemeURI="https://orcid.org/">
      1234-1234-1234-1234
      </datacite:nameIdentifier>
      <datacite:affiliation affiliationIdentifier="https://ror.org/03vek6s52">Harvard University</datacite:affiliation>
      </datacite:creator>
      </datacite:creators>
      <datacite:contributors>
      <datacite:contributor contributorType="Editor">
      <datacite:creatorName nameType="Personal">Smith, Jane</datacite:creatorName>
      <datacite:givenName>Jane</datacite:givenName>
      <datacite:familyName>Smith</datacite:familyName>
      <datacite:nameIdentifier nameIdentifierScheme="ORCID" schemeURI="https://orcid.org/">
      1234-1234-1234-1234
      </datacite:nameIdentifier>
      <datacite:affiliation affiliationIdentifier="https://ror.org/03vek6s52">Harvard University</datacite:affiliation>
      </datacite:contributor>
      </datacite:contributors>
      <oaire:fundingReferences>
      <oaire:fundingReference>
      <oaire:funderName>National Science Foundation</oaire:funderName>
      <oaire:funderIdentifier funderIdentifierType="ROR">https://ror.org/03vek6s52</oaire:funderIdentifier>
      <oaire:awardNumber>123456</oaire:awardNumber>
      <oaire:awardTitle>Research Grant</oaire:awardTitle>
      </oaire:fundingReference>
      </oaire:fundingReferences>
      <datacite:alternateIdentifiers>
      <datacite:alternateIdentifier alternateIdentifierType="DOI">10.1234/example.doi</datacite:alternateIdentifier>
      <datacite:alternateIdentifier alternateIdentifierType="URL">
      https://example.com/landing-page
      </datacite:alternateIdentifier>
      <datacite:alternateIdentifier alternateIdentifierType="ISBN">978-3-16-148410-0</datacite:alternateIdentifier>
      </datacite:alternateIdentifiers>
      <datacite:relatedIdentifiers>
      <datacite:relatedIdentifier relatedIdentifierType="DOI" relationType="HasPart">
      https://doi.org/10.1234/related.doi
      </datacite:relatedIdentifier>
      <datacite:relatedIdentifier relatedIdentifierType="URL" relationType="HasPart">
      https://example.com/related-landing-page
      </datacite:relatedIdentifier>
      <datacite:relatedIdentifier relatedIdentifierType="ISBN" relationType="HasPart">
      978-3-16-148410-0
      </datacite:relatedIdentifier>
      </datacite:relatedIdentifiers>
      <dc:language>eng</dc:language>
      <dc:publisher>Sample Publisher</dc:publisher>
      <datacite:date dateType="Issued">2023-10-01</datacite:date>
      <oaire:resourceType resourceTypeGeneral="literature" uri="http://purl.org/coar/resource_type/c_2f33">
      book
      </oaire:resourceType>
      <dc:description>This is a short abstract.</dc:description>
      <dc:description>This is a long abstract.</dc:description>
      <dc:description>Table of Contents</dc:description>
      <dc:format>application/pdf</dc:format>
      <datacite:rights rightsURI="http://purl.org/coar/access_right/c_abf2">open access</datacite:rights>
      <oaire:licenseCondition uri="http://creativecommons.org/licenses/by-nc-nd/4.0">
      CC BY-NC-ND 4.0
      </oaire:licenseCondition>
      <datacite:subject subjectScheme="BIC">ACND</datacite:subject>
      <datacite:subject subjectScheme="BISAC">ART010000</datacite:subject>
      <datacite:subject subjectScheme="Thema">AGA</datacite:subject>
      <datacite:subject subjectScheme="LCC">N7480</datacite:subject>
      <datacite:subject>History of art</datacite:subject>
      <datacite:subject>Art</datacite:subject>
      <datacite:sizes>
      <datacite:size>300 pages</datacite:size>
      <datacite:size>10 images</datacite:size>
      <datacite:size>5 tables</datacite:size>
      <datacite:size>2 audios</datacite:size>
      <datacite:size>1 videos</datacite:size>
      </datacite:sizes>
      <oaire:file mimeType="application/pdf" objectType="fulltext">https://example.com/file.pdf</oaire:file>
      <oaire:citationTitle>Series Name</oaire:citationTitle>
      <oaire:citationIssue>12</oaire:citationIssue>
      </oaire:resource>
    XML

    mapper = Thoth::Oai::Mapper::OaiOpenaire.new(input)
    assert_equal expected, mapper.map.gsub(/>\s+</, '><')
  end
end
