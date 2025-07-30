# frozen_string_literal: true

require 'builder'
require 'oai'
require 'json'

module Thoth
  module Oai
    module Mapper
      # Maps Thoth records to OAI DC format
      class OaiDc
        def initialize(input)
          @input = input
          metadata_format = OAI::Provider::Metadata::DublinCore.instance
          @header_specification = metadata_format.header_specification
          @fields = metadata_format.fields
        end

        def map
          xml = Builder::XmlMarkup.new
          xml.tag!('oai_dc:dc', @header_specification) do
            @fields.each do |field|
              next unless respond_to?("#{field}_value")

              value = send("#{field}_value")

              next if value.nil? || value.empty?

              value.respond_to?(:each) ? value.each { |v| xml.tag!("dc:#{field}", v) } : xml.tag!("dc:#{field}", value)
            end
          end
          xml.target!
        end

        def title_value
          @input['fullTitle']
        end

        def creator_value
          @input['creator'].map { |creator| creator['fullName'] }.compact
        end

        def subject_value
          @input['keywords'].map { |keyword| keyword['subjectCode'] }.compact
        end

        def description_value
          @input['longAbstract']
        end

        def publisher_value
          @input['imprint']['publisher']['publisherName']
        end

        def contributor_value
          @input['contributor'].map { |contributor| contributor['fullName'] }.compact
        end

        def date_value
          @input['publicationDate']
        end

        def type_value
          @input['workType'].downcase
        end

        def format_value
          types = {
            'HARDBACK' => 'hardback',
            'PAPERBACK' => 'paperback',
            'PDF' => 'application/pdf',
            'EPUB' => 'application/epub+zip',
            'XML' => 'text/xml',
            'HTML' => 'text/html',
            'DOCX' => 'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
            'MP3' => 'audio/mpeg',
            'WAV' => 'audio/wav',
            'MOBI' => 'application/x-mobipocket-ebook',
            'AZW3' => 'application/vnd.amazon.ebook',
            'FICTION_BOOK' => 'application/x-fictionbook+xml'
          }

          @input['publications'].map do |publication|
            next unless types.key?(publication['publicationType'])

            types[publication['publicationType']]
          end.compact
        end

        def identifier_value
          ["https://thoth.pub/books/#{@input['workId']}", @input['doi']] +
            @input['publications'].map do |pub|
              pub['isbn'] ? "urn:isbn:#{pub['isbn']}" : nil
            end.compact
        end

        def language_value
          @input['language'].map { |lang| lang['languageCode'].downcase }.compact
        end

        def relation_value
          @input['relations'].map do |relation|
            [
              relation['relatedWork']['doi'],
              relation['relatedWork']['publications'].map do |pub|
                pub['isbn'] ? "urn:isbn:#{pub['isbn']}" : nil
              end
            ].flatten.compact
          end.flatten.compact
        end

        def rights_value
          @input['license']
        end
      end
    end
  end
end
