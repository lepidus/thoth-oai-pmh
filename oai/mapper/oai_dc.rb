# frozen_string_literal: true

require 'builder'
require 'oai'
require 'json'

module Thoth
  module Oai
    module Mapper
      # Maps Thoth records to OAI DC format
      class OaiDc
        TYPE_MAPPING = {
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
        }.freeze

        def initialize(input)
          @input = input
          metadata_format = OAI::Provider::Metadata::DublinCore.instance
          @header_specification = metadata_format.header_specification
        end

        def map
          xml = Builder::XmlMarkup.new
          xml.tag!('oai_dc:dc', @header_specification) do
            build_tags(xml)
          end
          xml.target!
        end

        def build_tags(xml)
          build_title_tag(xml)
          build_creator_tag(xml)
          build_subject_tag(xml)
          build_description_tag(xml)
          build_publisher_tag(xml)
          build_contributor_tag(xml)
          build_date_tag(xml)
          build_type_tag(xml)
          build_format_tag(xml)
          build_identifier_tag(xml)
          build_language_tag(xml)
          build_relation_tag(xml)
          build_rights_tag(xml)
        end

        def build_title_tag(xml)
          xml.tag! 'dc:title', @input['fullTitle']
        end

        def build_creator_tag(xml)
          @input['creator']&.each do |creator|
            xml.tag! 'dc:creator', creator['fullName']
          end
        end

        def build_subject_tag(xml)
          @input['subjects']&.each do |subject|
            xml.tag! 'dc:subject', subject['subjectCode'] if subject['subjectType'] == 'KEYWORD'
          end
        end

        def build_description_tag(xml)
          xml.tag! 'dc:description', @input['longAbstract'] if @input['longAbstract']
        end

        def build_publisher_tag(xml)
          publisher = @input.dig('imprint', 'publisher', 'publisherName')
          xml.tag! 'dc:publisher', publisher if publisher
        end

        def build_contributor_tag(xml)
          @input['contributor']&.each do |contributor|
            xml.tag! 'dc:contributor', contributor['fullName']
          end
        end

        def build_date_tag(xml)
          xml.tag! 'dc:date', @input['publicationDate'] if @input['publicationDate']
        end

        def build_type_tag(xml)
          type = case @input['workType']
                 when 'JOURNAL_ISSUE' then 'issue'
                 when 'BOOK_CHAPTER' then 'chapter'
                 else 'book'
                 end
          xml.tag! 'dc:type', type
        end

        def build_format_tag(xml)
          @input['publications']&.each do |format|
            xml.tag! 'dc:format', TYPE_MAPPING[format['publicationType']]
          end
        end

        def build_identifier_tag(xml)
          xml.tag! 'dc:identifier', "https://thoth.pub/books/#{@input['workId']}"
          xml.tag! 'dc:identifier', @input['doi'] if @input['doi']
          @input['publications']&.each do |publication|
            xml.tag! 'dc:identifier', "urn:isbn:#{publication['isbn']}" if publication['isbn']
          end
        end

        def build_language_tag(xml)
          @input['language']&.each do |lang|
            xml.tag! 'dc:language', lang['languageCode'].downcase
          end
        end

        def build_relation_tag(xml)
          @input['relations']&.each do |relation|
            related_work = relation['relatedWork']
            xml.tag! 'dc:relation', related_work['doi'] if related_work['doi']
            related_work['publications']&.each do |pub|
              xml.tag! 'dc:relation', "urn:isbn:#{pub['isbn']}" if pub['isbn']
            end
          end
        end

        def build_rights_tag(xml)
          xml.tag! 'dc:rights', @input['license'] if @input['license']
        end
      end
    end
  end
end
