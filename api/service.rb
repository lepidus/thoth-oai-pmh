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
        response = @client.execute_query(Thoth::Api::Queries::PUBLISHERS_QUERY)
        publishers = JSON.parse(response.body)['data']['publishers']
        publishers.map do |publisher|
          {
            id: publisher['publisherId'],
            spec: publisher['publisherName'].downcase.gsub(/[^\w\s]/, '').gsub(' ', '-'),
            name: publisher['publisherName']
          }
        end
      end

      def total(publisher_id = nil)
        publishers_id = [publisher_id].compact if publisher_id
        response = @client.execute_query(Thoth::Api::Queries::WORK_COUNT_QUERY, { publishersId: publishers_id })
        JSON.parse(response.body)['data']['workCount']
      end

      def records(offset = 0, publisher_id = nil, type = 'works')
        publishers_id = [publisher_id].compact if publisher_id

        query = type == 'works' ? Thoth::Api::Queries::WORKS_QUERY : Thoth::Api::Queries::BOOKS_QUERY

        response = @client.execute_query(query, { offset: offset, publishersId: publishers_id })

        works = JSON.parse(response.body)['data'][type]

        works = filter_works(works) if type == 'books'

        works.map { |work| Thoth::Oai::Record.new(work) }
      end

      def record(work_id)
        response = @client.execute_query(Thoth::Api::Queries::WORK_QUERY, { workId: work_id })
        work = JSON.parse(response.body)['data']['work']
        Thoth::Oai::Record.new(work) if work
      end

      def get_marcxml(work_id)
        xml = @client.send_request('marc21xml::thoth', work_id)
        return unless xml

        doc = REXML::Document.new(xml)
        REXML::XPath.first(doc, '//marc:record').to_s
      end

      private

      def fetch_datestamp(direction)
        response = @client.execute_query(Thoth::Api::Queries::TIMESTAMP_QUERY, { direction: direction })
        JSON.parse(response.body)['data']['works'].first['updatedAtWithRelations']
      end

      def filter_works(works)
        works = works.reject { |work| work['contributions'].empty? }
        works = works.reject do |work|
          work['languages'].none? { |language| language['mainLanguage'] }
        end
        works.reject do |work|
          work['publications'].none? { |publication| publication['isbn'] }
        end
      end
    end
  end
end
