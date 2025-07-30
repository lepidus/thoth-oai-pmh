# frozen_string_literal: true

ENV['APP_ENV'] = 'test'

require_relative '../../../oai/mapper/oai_dc'
require 'test/unit'
require 'rack/test'
require 'webmock/test_unit'

# Test suite for the OAI DC Mapper
class OaiDcMapperTest < Test::Unit::TestCase
  include Rack::Test::Methods

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
      'keywords' => [{ 'subjectCode' => 'test' }],
      'longAbstract' => 'This is a abstract for the work.',
      'relations' => [{ 'relatedWork' => {
        'doi' => 'https://doi.org/10.12345/related-doi',
        'publications' => [{ 'isbn' => '978-1-654321-12-3' }]
      } }],
      'updatedAtWithRelations' => '2022-05-02T13:37:12.182980Z'
    }

    expected_output = [
      '<oai_dc:dc xmlns:oai_dc="http://www.openarchives.org/OAI/2.0/oai_dc/"',
      ' xmlns:dc="http://purl.org/dc/elements/1.1/"',
      ' xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"',
      ' xsi:schemaLocation="http://www.openarchives.org/OAI/2.0/oai_dc/',
      ' http://www.openarchives.org/OAI/2.0/oai_dc.xsd">',
      '<dc:title>Test Title</dc:title>',
      '<dc:creator>John Doe</dc:creator>',
      '<dc:subject>test</dc:subject>',
      '<dc:description>This is a abstract for the work.</dc:description>',
      '<dc:publisher>Thoth Publishers</dc:publisher>',
      '<dc:contributor>Jane Smith</dc:contributor>',
      '<dc:date>2021-10-26</dc:date>',
      '<dc:type>book</dc:type>',
      '<dc:format>application/pdf</dc:format>',
      '<dc:identifier>https://thoth.pub/books/4f4a4dcb-2d88-43b6-8400-bd24926903b8</dc:identifier>',
      '<dc:identifier>https://doi.org/10.1234/test-doi</dc:identifier>',
      '<dc:identifier>urn:isbn:978-3-123456-123-1</dc:identifier>',
      '<dc:language>eng</dc:language>',
      '<dc:relation>https://doi.org/10.12345/related-doi</dc:relation>',
      '<dc:relation>urn:isbn:978-1-654321-12-3</dc:relation>',
      '<dc:rights>https://creativecommons.org/licenses/by-nc-sa/4.0/</dc:rights>',
      '</oai_dc:dc>'
    ].join

    assert_equal expected_output, Thoth::Oai::Mapper::OaiDc.new(input).map
  end
end
