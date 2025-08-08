# frozen_string_literal: true

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
        response = @client.execute(Thoth::Api::Queries::PUBLISHERS_QUERY)
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
        response = @client.execute(Thoth::Api::Queries::WORK_COUNT_QUERY, { publishersId: publishers_id })
        JSON.parse(response.body)['data']['workCount']
      end

      def records(offset = 0, publisher_id = nil)
        publishers_id = [publisher_id].compact if publisher_id
        response = @client.execute(Thoth::Api::Queries::WORKS_QUERY, { offset: offset, publishersId: publishers_id })
        works = JSON.parse(response.body)['data']['works']
        works.map do |work|
          Thoth::Oai::Record.new(work)
        end
      end

      def record(work_id)
        response = @client.execute(Thoth::Api::Queries::WORK_QUERY, { workId: work_id })
        work = JSON.parse(response.body)['data']['work']
        Thoth::Oai::Record.new(work) if work
      end

      private

      def fetch_datestamp(direction)
        response = @client.execute(Thoth::Api::Queries::TIMESTAMP_QUERY, { direction: direction })
        JSON.parse(response.body)['data']['works'].first['updatedAtWithRelations']
      end
    end
  end
end
