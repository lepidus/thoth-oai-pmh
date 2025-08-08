# frozen_string_literal: true

ENV['APP_ENV'] = 'test'

require_relative '../../../oai/mapper/oai_dc'
require 'test/unit'
require 'rack/test'
require 'webmock/test_unit'

# Test suite for the OAI DC Mapper
class OaiDcMapperTest < Test::Unit::TestCase
  include Rack::Test::Methods

  def setup
    @xml = Builder::XmlMarkup.new
  end

  def test_build_title_tag
    input = { 'fullTitle' => 'Test Title' }
    expected = '<dc:title>Test Title</dc:title>'
    mapper = Thoth::Oai::Mapper::OaiDc.new(input)
    mapper.build_title_tag(@xml)
    assert_equal expected, @xml.target!
  end

  def test_build_creator_tag
    input = { 'creator' => [{ 'fullName' => 'John Doe' }] }
    expected = '<dc:creator>John Doe</dc:creator>'
    mapper = Thoth::Oai::Mapper::OaiDc.new(input)
    mapper.build_creator_tag(@xml)
    assert_equal expected, @xml.target!
  end

  def test_build_subject_tag
    input = { 'subjects' => [{ 'subjectType' => 'KEYWORD', 'subjectCode' => 'test' }] }
    expected = '<dc:subject>test</dc:subject>'
    mapper = Thoth::Oai::Mapper::OaiDc.new(input)
    mapper.build_subject_tag(@xml)
    assert_equal expected, @xml.target!
  end

  def test_build_description_tag
    input = { 'longAbstract' => 'This is a abstract for the work.' }
    expected = '<dc:description>This is a abstract for the work.</dc:description>'
    mapper = Thoth::Oai::Mapper::OaiDc.new(input)
    mapper.build_description_tag(@xml)
    assert_equal expected, @xml.target!
  end

  def test_build_publisher_tag
    input = { 'imprint' => { 'publisher' => { 'publisherName' => 'Thoth Publishers' } } }
    expected = '<dc:publisher>Thoth Publishers</dc:publisher>'
    mapper = Thoth::Oai::Mapper::OaiDc.new(input)
    mapper.build_publisher_tag(@xml)
    assert_equal expected, @xml.target!
  end

  def test_build_contributor_tag
    input = { 'contributor' => [{ 'fullName' => 'Jane Smith' }] }
    expected = '<dc:contributor>Jane Smith</dc:contributor>'
    mapper = Thoth::Oai::Mapper::OaiDc.new(input)
    mapper.build_contributor_tag(@xml)
    assert_equal expected, @xml.target!
  end

  def test_build_date_tag
    input = { 'publicationDate' => '2021-10-26' }
    expected = '<dc:date>2021-10-26</dc:date>'
    mapper = Thoth::Oai::Mapper::OaiDc.new(input)
    mapper.build_date_tag(@xml)
    assert_equal expected, @xml.target!
  end

  def test_build_type_tag
    input = { 'workType' => 'BOOK' }
    expected = '<dc:type>book</dc:type>'
    mapper = Thoth::Oai::Mapper::OaiDc.new(input)
    mapper.build_type_tag(@xml)
    assert_equal expected, @xml.target!
  end

  def test_build_format_tag
    input = { 'publications' => [{ 'publicationType' => 'PDF' }] }
    expected = '<dc:format>application/pdf</dc:format>'
    mapper = Thoth::Oai::Mapper::OaiDc.new(input)
    mapper.build_format_tag(@xml)
    assert_equal expected, @xml.target!
  end

  def test_build_identifier_tags
    input = {
      'workId' => '4f4a4dcb-2d88-43b6-8400-bd24926903b8',
      'doi' => 'https://doi.org/10.1234/test-doi',
      'publications' => [{ 'publicationType' => 'PDF', 'isbn' => '978-3-123456-123-1' }]
    }
    expected = [
      '<dc:identifier>https://thoth.pub/books/4f4a4dcb-2d88-43b6-8400-bd24926903b8</dc:identifier>',
      '<dc:identifier>https://doi.org/10.1234/test-doi</dc:identifier>',
      '<dc:identifier>urn:isbn:978-3-123456-123-1</dc:identifier>'
    ].join
    mapper = Thoth::Oai::Mapper::OaiDc.new(input)
    mapper.build_identifier_tag(@xml)
    assert_equal expected, @xml.target!
  end

  def test_build_language_tag
    input = { 'language' => [{ 'languageCode' => 'ENG' }] }
    expected = '<dc:language>eng</dc:language>'
    mapper = Thoth::Oai::Mapper::OaiDc.new(input)
    mapper.build_language_tag(@xml)
    assert_equal expected, @xml.target!
  end

  def test_build_relation_tag
    input = {
      'relations' => [{ 'relatedWork' => {
        'doi' => 'https://doi.org/10.12345/related-doi',
        'publications' => [{ 'isbn' => '978-1-654321-12-3' }]
      } }]
    }
    expected = [
      '<dc:relation>https://doi.org/10.12345/related-doi</dc:relation>',
      '<dc:relation>urn:isbn:978-1-654321-12-3</dc:relation>'
    ].join
    mapper = Thoth::Oai::Mapper::OaiDc.new(input)
    mapper.build_relation_tag(@xml)
    assert_equal expected, @xml.target!
  end

  def test_map_record
    input = {
      'workId' => '4f4a4dcb-2d88-43b6-8400-bd24926903b8',
      'doi' => 'https://doi.org/10.1234/test-doi',
      'publications' => [{ 'publicationType' => 'PDF', 'isbn' => '978-3-123456-123-1' }],
      'fullTitle' => 'Test Title',
      'creator' => [{ 'fullName' => 'John Doe' }],
      'contributor' => [{ 'fullName' => 'Jane Smith' }],
      'license' => 'https://creativecommons.org/licenses/by-nc-sa/4.0/',
      'publicationDate' => '2021-10-26',
      'imprint' => { 'publisher' => { 'publisherName' => 'Thoth Publishers' } },
      'language' => [{ 'languageCode' => 'ENG' }],
      'workType' => 'BOOK',
      'subjects' => [{ 'subjectType' => 'KEYWORD', 'subjectCode' => 'test' }],
      'longAbstract' => 'This is a abstract for the work.',
      'relations' => [{ 'relatedWork' => {
        'doi' => 'https://doi.org/10.12345/related-doi',
        'publications' => [{ 'isbn' => '978-1-654321-12-3' }]
      } }],
      'updatedAtWithRelations' => '2022-05-02T13:37:12.182980Z'
    }

    expected = <<~XML.gsub(/\n*/, '').strip
      <oai_dc:dc xmlns:oai_dc="http://www.openarchives.org/OAI/2.0/oai_dc/"
       xmlns:dc="http://purl.org/dc/elements/1.1/"
       xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
       xsi:schemaLocation="http://www.openarchives.org/OAI/2.0/oai_dc/
       http://www.openarchives.org/OAI/2.0/oai_dc.xsd">
      <dc:title>Test Title</dc:title>
      <dc:creator>John Doe</dc:creator>
      <dc:subject>test</dc:subject>
      <dc:description>This is a abstract for the work.</dc:description>
      <dc:publisher>Thoth Publishers</dc:publisher>
      <dc:contributor>Jane Smith</dc:contributor>
      <dc:date>2021-10-26</dc:date>
      <dc:type>book</dc:type>
      <dc:format>application/pdf</dc:format>
      <dc:identifier>https://thoth.pub/books/4f4a4dcb-2d88-43b6-8400-bd24926903b8</dc:identifier>
      <dc:identifier>https://doi.org/10.1234/test-doi</dc:identifier>
      <dc:identifier>urn:isbn:978-3-123456-123-1</dc:identifier>
      <dc:language>eng</dc:language>
      <dc:relation>https://doi.org/10.12345/related-doi</dc:relation>
      <dc:relation>urn:isbn:978-1-654321-12-3</dc:relation>
      <dc:rights>https://creativecommons.org/licenses/by-nc-sa/4.0/</dc:rights>
      </oai_dc:dc>
    XML

    assert_equal expected, Thoth::Oai::Mapper::OaiDc.new(input).map
  end
end
