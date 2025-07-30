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
          @metadata_format = OAI::Provider::Metadata::DublinCore.instance
        end

        def map
          header_specification = @metadata_format.header_specification
          fields = @metadata_format.fields

          xml = Builder::XmlMarkup.new
          xml.tag!('oai_dc:dc', header_specification) do
            fields.each do |field|
              next unless respond_to?("build_#{field}")

              send("build_#{field}", xml)
            end
          end
          xml.target!
        end

        def build_title(xml)
          xml.tag! 'dc:title', @input['fullTitle'] if @input.key?('fullTitle')
        end

        def build_creator(xml)
          @input['creator'].each do |creator|
            xml.tag! 'dc:creator', creator['fullName'] if creator.key?('fullName')
          end
        end

        def build_subject(xml)
          @input['keywords'].each do |keyword|
            xml.tag! 'dc:subject', keyword['subjectCode'] if keyword.key?('subjectCode')
          end
        end

        def build_description(xml)
          xml.tag! 'dc:description', @input['longAbstract'] if @input.key?('longAbstract')
        end

        def build_publisher(xml)
          xml.tag! 'dc:publisher', @input['imprint']['publisher']['publisherName'] if @input.key?('imprint')
        end

        def build_contributor(xml)
          @input['contributor'].each do |contributor|
            xml.tag! 'dc:contributor', contributor['fullName'] if contributor.key?('fullName')
          end
        end

        def build_date(xml)
          xml.tag! 'dc:date', @input['publicationDate'] if @input.key?('publicationDate')
        end

        def build_type(xml)
          xml.tag! 'dc:type', @input['workType'].downcase if @input.key?('workType')
        end

        def build_format(xml)
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

          @input['publications'].each do |publication|
            next unless types.key?(publication['publicationType'])

            xml.tag! 'dc:format', types[publication['publicationType']]
          end
        end

        def build_identifier(xml)
          identifiers = ["https://thoth.pub/books/#{@input['workId']}", @input['doi']] +
                        @input['publications'].map do |pub|
                          pub['isbn'] ? "urn:isbn:#{pub['isbn']}" : nil
                        end.compact

          identifiers.each do |identifier|
            xml.tag! 'dc:identifier', identifier if identifier
          end
        end

        def build_language(xml)
          @input['language'].each do |lang|
            xml.tag! 'dc:language', lang['languageCode'].downcase if lang.key?('languageCode')
          end
        end

        def build_relation(xml)
          relations = @input['relations'].map do |relation|
            [
              relation['relatedWork']['doi'],
              relation['relatedWork']['publications'].map { |pub| "urn:isbn:#{pub['isbn']}" }
            ].flatten.compact
          end.flatten.compact

          relations.each do |relation|
            xml.tag! 'dc:relation', relation if relation
          end
        end

        def build_rights(xml)
          xml.tag! 'dc:rights', @input['license'] if @input.key?('license')
        end
      end
    end
  end
end
