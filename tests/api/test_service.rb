# frozen_string_literal: true

ENV['APP_ENV'] = 'test'

require_relative '../../api/service'
require 'test/unit'
require 'rack/test'
require 'webmock/test_unit'

# Test suite for the Thoth API service
class ThothApiServiceTest < Test::Unit::TestCase
  include Rack::Test::Methods

  EXAMPLE_DATA = {
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
  }.freeze

  def test_get_latest
    stub_request(:post, 'https://api.thoth.pub/graphql')
      .to_return(
        status: 200,
        body: '{"data": {"works": [{"updatedAtWithRelations": "2025-05-02T13:37:12.182980Z"}]}}',
        headers: { 'Content-Type' => 'application/json' }
      )

    service = Thoth::Api::Service.new
    latest = service.latest

    assert_equal '2025-05-02T13:37:12.182980Z', latest
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

  def test_get_record
    stub_request(:post, 'https://api.thoth.pub/graphql')
      .to_return(
        status: 200,
        body: "{\"data\": {\"work\":#{EXAMPLE_DATA.to_json}}}",
        headers: { 'Content-Type' => 'application/json' }
      )

    service = Thoth::Api::Service.new
    record = service.record('4f4a4dcb-2d88-43b6-8400-bd24926903b8')

    assert_instance_of Thoth::Oai::Record, record
    assert_equal EXAMPLE_DATA, record.json_record
  end

  def test_get_records
    stub_request(:post, 'https://api.thoth.pub/graphql')
      .to_return(
        status: 200,
        body: "{\"data\": {\"works\": [#{EXAMPLE_DATA.to_json}]}}",
        headers: { 'Content-Type' => 'application/json' }
      )

    service = Thoth::Api::Service.new
    records = service.records(0, 50)

    assert(records.all? { |r| r.instance_of?(Thoth::Oai::Record) })
    assert_equal 1, records.size
    assert_equal EXAMPLE_DATA, records.first.json_record
  end

  def test_get_sets
    stub_request(:post, 'https://api.thoth.pub/graphql')
      .to_return(
        status: 200,
        body: '{"data": {"publishers": [{"publisherId": "1", "publisherName": "Thoth Publishers"}]}}',
        headers: { 'Content-Type' => 'application/json' }
      )

    service = Thoth::Api::Service.new
    sets = service.sets

    assert_equal [{ id: '1', spec: 'thoth-publishers', name: 'Thoth Publishers' }], sets
  end
end
