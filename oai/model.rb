# frozen_string_literal: true

require_relative '../api/service'
require 'oai'
require 'ostruct'

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
        sets = @service.sets
        sets.map do |set|
          OAI::Set.new({ spec: set[:spec], name: set[:name] })
        end
      end

      def find(selector, options = {})
        if selector.is_a?(String)
          record = @service.find(selector)
          return OpenStruct.new(record) if record
        end

        resumption_token = build_resumption_token(options)
        offset = resumption_token.last || 0
        records = @service.records(offset).map { |record| OpenStruct.new(record) }
        OAI::Provider::PartialResult.new(records, resumption_token.next(offset + 1))
      end

      def build_resumption_token(options)
        if options[:resumption_token]
          OAI::Provider::ResumptionToken.parse(options[:resumption_token])
        else
          OAI::Provider::ResumptionToken.new(options.merge({ last: 0 }))
        end
      end
    end
  end
end
