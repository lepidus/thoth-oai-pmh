# frozen_string_literal: true

ENV['APP_ENV'] = 'test'

require_relative '../../oai/record'
require 'test/unit'
require 'rack/test'

# Test suite for the Thoth GraphQL API client
class RecordTest < Test::Unit::TestCase
  include Rack::Test::Methods

  def test_record_from_input
    input = {
      'workId' => '4f4a4dcb-2d88-43b6-8400-bd24926903b8',
      'doi' => 'https://doi.org/10.1234/test-doi',
      'publications' => [
        {
          'publicationType' => 'PDF',
          'isbn' => '978-3-123456-123-1'
        }
      ],
      'fullTitle' => 'Test Title',
      'creator' => [
        {
          'fullName' => 'John Doe'
        }
      ],
      'contributor' => [
        {
          'fullName' => 'Jane Smith'
        }
      ],
      'license' => 'https://creativecommons.org/licenses/by-nc-sa/4.0/',
      'publicationDate' => '2021-10-26',
      'imprint' => {
        'publisher' => {
          'publisherName' => 'Thoth Publishers'
        }
      },
      'language' => [
        {
          'languageCode' => 'ENG'
        }
      ],
      'workType' => 'BOOK',
      'keywords' => [
        {
          'subjectCode' => 'test'
        }
      ],
      'longAbstract' => 'This is a abstract for the work.',
      'relations' => [
        {
          'relatedWork' => {
            'doi' => 'https://doi.org/10.12345/related-doi',
            'publications' => [
              {
                'isbn' => '978-1-654321-12-3'
              }
            ]
          }
        }
      ],
      'updatedAtWithRelations' => '2022-05-02T13:37:12.182980Z'
    }

    expected_output = {
      id: '4f4a4dcb-2d88-43b6-8400-bd24926903b8',
      identifiers: [
        'https://thoth.pub/books/4f4a4dcb-2d88-43b6-8400-bd24926903b8',
        'https://doi.org/10.1234/test-doi',
        'info:eu-repo/semantics/altIdentifier/isbn/978-3-123456-123-1'
      ],
      title: 'Test Title',
      creators: ['John Doe'],
      contributors: ['Jane Smith'],
      rights: 'https://creativecommons.org/licenses/by-nc-sa/4.0/',
      date: '2021-10-26',
      publisher: 'Thoth Publishers',
      languages: ['eng'],
      types: 'book',
      subjects: ['test'],
      description: 'This is a abstract for the work.',
      relations: [
        'https://doi.org/10.12345/related-doi',
        'info:eu-repo/semantics/altIdentifier/isbn/978-1-654321-12-3'
      ],
      formats: ['application/pdf'],
      updated_at: Time.parse('2022-05-02T13:37:12.182980Z')
    }

    assert_equal expected_output, Thoth::Oai::Record.new(input).map
  end
end
