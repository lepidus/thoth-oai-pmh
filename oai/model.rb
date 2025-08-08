# frozen_string_literal: true

require_relative '../api/service'
require 'oai'

module Thoth
  module Oai
    # Model class for the OAI-PMH provider
    class Model < OAI::Provider::Model
      def initialize
        super
        @service = Thoth::Api::Service.new
      end

      def earliest
        @service.earliest
      end

      def latest
        @service.latest
      end

      def sets
        @service.sets.map { |set| OAI::Set.new(spec: set[:spec], name: set[:name]) }
      end

      def find(selector, options = {})
        if selector == :all
          find_all(options)
        else
          find_one(selector)
        end
      end

      private

      def find_one(selector)
        @service.record(selector)
      end

      def find_all(options)
        parse_datetime(options)
        token = build_resumption_token(options)
        publisher_id = publisher_id_from_set(token.set)
        return nil if token.set && publisher_id.nil?

        records = fetch_records(token.last, publisher_id)
        create_partial_result(records, token, publisher_id)
      end

      def fetch_records(offset, publisher_id)
        @service.records(offset, publisher_id)
      end

      def create_partial_result(records, token, publisher_id)
        total = @service.total(publisher_id)
        current_offset = token.last + records.size

        return records if current_offset >= total

        next_token = OAI::Provider::ResumptionToken.parse(token.to_s, nil, total)
        OAI::Provider::PartialResult.new(records, next_token.next(current_offset))
      end

      def parse_datetime(options)
        %i[from until].each do |key|
          next unless options[key]

          datetime = options[key]
          datetime = datetime.to_time if datetime.is_a?(Date)
          options[key] = datetime.utc
        end
      end

      def build_resumption_token(options)
        if options[:resumption_token]
          OAI::Provider::ResumptionToken.parse(options[:resumption_token])
        else
          OAI::Provider::ResumptionToken.new(options.merge(last: 0))
        end
      end

      def publisher_id_from_set(set_spec)
        return nil unless set_spec

        publishers_by_spec[set_spec]
      end

      def publishers_by_spec
        @publishers_by_spec ||= @service.sets.to_h { |p| [p[:spec], p[:id]] }
      end
    end
  end
end
