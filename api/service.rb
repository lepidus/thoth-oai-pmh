# frozen_string_literal: true

require 'rexml/document'
require 'rexml/xpath'
require_relative 'client'
require_relative 'queries'
require_relative '../oai/record'

module Thoth
  module Api
    # Service class for Thoth API interactions
    class Service
      def initialize(client = Thoth::Api::Client.new)
        @client = client
      end

      def latest
        fetch_datestamp('DESC')
      end

      def earliest
        fetch_datestamp('ASC')
      end

      def sets
        result = @client.execute_query(Thoth::Api::Queries::PUBLISHERS_QUERY)
        return [] unless result

        result.dig('data', 'publishers').map { |publisher| create_set(publisher) }
      end

      def total(publisher_id = nil)
        publishers_id = publisher_id ? [publisher_id] : nil
        result = @client.execute_query(Thoth::Api::Queries::WORK_COUNT_QUERY, { publishersId: publishers_id })
        result&.dig('data', 'workCount')
      end

      def records(offset, limit, publisher_id = nil, type = 'works')
        publishers_id = publisher_id ? [publisher_id] : nil
        query = type == 'works' ? Thoth::Api::Queries::WORKS_QUERY : Thoth::Api::Queries::BOOKS_QUERY

        result = @client.execute_query(query, { offset: offset, publishersId: publishers_id, limit: limit })
        return [] unless result

        works = result.dig('data', type) || []
        works = filter_works(works) if type == 'books'
        works.map { |work| Thoth::Oai::Record.new(work) }
      end

      def record(work_id)
        result = @client.execute_query(Thoth::Api::Queries::WORK_QUERY, { workId: work_id })
        work = result&.dig('data', 'work')
        Thoth::Oai::Record.new(work) if work
      end

      def get_marcxml(work_id)
        xml = @client.send_request('marc21xml::thoth', work_id)
        return unless xml

        doc = REXML::Document.new(xml)
        REXML::XPath.first(doc, '//marc:record')&.to_s
      end

      private

      def fetch_datestamp(direction)
        result = @client.execute_query(Thoth::Api::Queries::TIMESTAMP_QUERY, { direction: direction })
        result&.dig('data', 'works', 0, 'updatedAtWithRelations')
      end

      def create_set(publisher)
        {
          id: publisher['publisherId'],
          spec: publisher['publisherName'].downcase.gsub(/[^\w\s]/, '').gsub(' ', '-'),
          name: publisher['publisherName']
        }
      end

      def filter_works(works)
        works.select do |work|
          work['contributions'].any? &&
            work['languages'].any? { |lang| lang['mainLanguage'] } &&
            work['publications'].any? { |pub| pub['isbn'] }
        end
      end
    end
  end
end
