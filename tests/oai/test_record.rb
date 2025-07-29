# frozen_string_literal: true

ENV['APP_ENV'] = 'test'

require_relative '../../oai/record'
require 'test/unit'
require 'rack/test'
require 'webmock/test_unit'

# Test suite for the Thoth OAI-PMH Record
class RecordTest < Test::Unit::TestCase
  include Rack::Test::Methods

  def test_create_new_record
    attributes = {
      id: '4f4a4dcb-2d88-43b6-8400-bd24926903b8',
      doi: 'https://doi.org/10.1234/test-doi',
      publications: [{ 'type' => 'PDF', 'isbn' => '978-3-123456-123-1' }],
      full_title: 'Test Title',
      creators: ['John Doe'],
      contributors: ['Jane Smith'],
      license: 'https://creativecommons.org/licenses/by-nc-sa/4.0/',
      publication_date: '2021-10-26',
      publisher: 'Thoth Publishers',
      languages: ['eng'],
      work_type: 'book',
      keywords: ['test'],
      abstract: 'This is a abstract for the work.',
      relations: [
        'https://doi.org/10.1234/related-work',
        '978-3-123456-123-2'
      ],
      updated_at: '2021-10-26T12:00:00Z'
    }

    record = Thoth::Oai::Record.new(attributes)
    assert_instance_of Thoth::Oai::Record, record
    attributes.each do |name, value|
      assert_equal value, record.send(name)
    end
  end
end
