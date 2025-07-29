# frozen_string_literal: true

ENV['APP_ENV'] = 'test'

require_relative '../../oai/record'
require 'test/unit'
require 'rack/test'
require 'webmock/test_unit'

# Test suite for the Thoth OAI-PMH Record
class RecordTest < Test::Unit::TestCase
  include Rack::Test::Methods

  def test_get_id_and_updated_at
    json_record = { id: '58c1832f-d7bc-4f80-8b89-3c91efd1d397', updated_at: '2023-10-01T12:00:00Z' }
    record = Thoth::Oai::Record.new(json_record)

    assert_equal '58c1832f-d7bc-4f80-8b89-3c91efd1d397', record.id
    assert_equal Time.parse('2023-10-01T12:00:00Z'), record.updated_at
  end
end
