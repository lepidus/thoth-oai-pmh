# frozen_string_literal: true

module Thoth
  module Oai
    module Mapper
      # Maps Thoth records to OAI OpenAIRE format
      class OaiOpenaire
        def initialize(input)
          @input = input
        end

        def build_title_tag(xml)
          xml.tag! 'datacite:titles' do
            xml.tag! 'datacite:title', @input['title']
            xml.tag! 'datacite:title', { titleType: 'Subtitle' }, @input['subtitle'] unless @input['subtitle'].nil?
          end
        end

        def build_creator_tag(xml)
          xml.tag! 'datacite:creators' do
            @input['creator'].each do |creator|
              xml.tag! 'datacite:creator' do
                build_creator_name_tag(xml, creator)
                build_name_identifier_tag(xml, creator)
                build_affiliation_tag(xml, creator)
              end
            end
          end
        end

        def build_contributor_tag(xml)
          xml.tag! 'datacite:contributors' do
            @input['contributor'].each do |contributor|
              contributor_type = contributor['contributionType'] == 'EDITOR' ? 'Editor' : 'Other'
              xml.tag! 'datacite:contributor', { contributorType: contributor_type } do
                build_creator_name_tag(xml, contributor)
                build_name_identifier_tag(xml, contributor)
                build_affiliation_tag(xml, contributor)
              end
            end
          end
        end

        def build_funding_reference_tag(xml)
          xml.tag! 'oaire:fundingReferences' do
            @input['fundings'].each do |funding|
              xml.tag! 'oaire:fundingReference' do
                xml.tag! 'oaire:funderName', funding['institution']['institutionName']

                unless funding['institution']['ror'].nil?
                  xml.tag! 'oaire:funderIdentifier', { funderIdentifierType: 'ROR' },
                           funding['institution']['ror']
                end

                xml.tag! 'oaire:awardNumber', funding['grantNumber'] unless funding['grantNumber'].nil?
                xml.tag! 'oaire:awardTitle', funding['projectName'] unless funding['projectName'].nil?
              end
            end
          end
        end

        def build_alternate_identifier_tag(xml)
          xml.tag! 'datacite:alternateIdentifiers' do
            unless @input['doi'].nil?
              xml.tag! 'datacite:alternateIdentifier', { alternateIdentifierType: 'DOI' }, @input['doi']
            end
            unless @input['landingPage'].nil?
              xml.tag! 'datacite:alternateIdentifier', { alternateIdentifierType: 'URL' }, @input['landingPage']
            end
            @input['publications'].each do |publication|
              next if publication['isbn'].nil?

              xml.tag! 'datacite:alternateIdentifier', { alternateIdentifierType: 'ISBN' }, publication['isbn']
            end
          end
        end

        def build_related_identifier_tag(xml)
          xml.tag! 'datacite:relatedIdentifiers' do
            @input['relations'].each do |relation|
              relation_type = %w[HAS_CHILD HAS_PART].include?(relation['relationType']) ? 'HasPart' : 'IsPartOf'
              unless relation['relatedWork']['doi'].nil?
                xml.tag! 'datacite:relatedIdentifier', { relatedIdentifierType: 'DOI', relationType: relation_type },
                         relation['relatedWork']['doi']
              end
              unless relation['relatedWork']['landingPage'].nil?
                xml.tag! 'datacite:relatedIdentifier', { relatedIdentifierType: 'URL', relationType: relation_type },
                         relation['relatedWork']['landingPage']
              end
              relation['relatedWork']['publications'].each do |publication|
                next if publication['isbn'].nil?

                xml.tag! 'datacite:relatedIdentifier', { relatedIdentifierType: 'ISBN', relationType: relation_type },
                         publication['isbn']
              end
            end
          end
        end

        def build_language_tag(xml)
          @input['languages'].each do |language|
            xml.tag! 'dc:language', language['languageCode']
          end
        end

        def build_publisher_tag(xml)
          xml.tag! 'dc:publisher', @input['imprint']['publisher']['publisherName']
        end

        def build_date_tag(xml)
          xml.tag! 'datacite:date', { dateType: 'Issued' }, @input['publicationDate']
        end

        def build_resource_type_tag(xml)
          case @input['workType']
          when 'JOURNAL_ISSUE'
            xml.tag! 'oaire:resourceType',
                     { resourceTypeGeneral: 'literature', uri: 'http://purl.org/coar/resource_type/c_0640' } do
              xml.text! 'journal'
            end
          when 'BOOK_CHAPTER'
            xml.tag! 'oaire:resourceType',
                     { resourceTypeGeneral: 'literature', uri: 'http://purl.org/coar/resource_type/c_3248' } do
              xml.text! 'book part'
            end
          when 'MONOGRAPH', 'TEXTBOOK', 'EDITED_BOOK', 'BOOK_SET'
            xml.tag! 'oaire:resourceType',
                     { resourceTypeGeneral: 'literature', uri: 'http://purl.org/coar/resource_type/c_2f33' } do
              xml.text! 'book'
            end
          end
        end

        def build_description_tag(xml)
          xml.tag! 'dc:description', @input['shortAbstract'] unless @input['shortAbstract'].nil?
          xml.tag! 'dc:description', @input['longAbstract'] unless @input['longAbstract'].nil?
          xml.tag! 'dc:description', @input['toc'] unless @input['toc'].nil?
        end

        def build_format_tag(xml)
          @input['publications'].each do |publication|
            xml.tag! 'dc:format', type_mapping[publication['publicationType']]
          end
        end

        def build_identifier_tag(xml)
          xml.tag! 'datacite:identifier', { identifierType: 'URL' }, "https://thoth.pub/books/#{@input['workId']}"
        end

        def build_rights_tag(xml)
          if @input['license'].nil?
            xml.tag! 'datacite:rights', { rightsURI: 'http://purl.org/coar/access_right/c_16ec' }, 'restricted access'
          else
            xml.tag! 'datacite:rights', { rightsURI: 'http://purl.org/coar/access_right/c_abf2' }, 'open access'
          end
        end

        def build_subject_tag(xml)
          @input['subjects'].each do |subject|
            if %w[KEYWORD CUSTOM].include?(subject['subjectType'])
              xml.tag! 'datacite:subject', subject['subjectCode']
            else
              subject_type = subject['subjectType'] == 'THEMA' ? 'Thema' : subject['subjectType']
              xml.tag! 'datacite:subject', { subjectScheme: subject_type }, subject['subjectCode']
            end
          end
        end

        def build_license_condition_tag(xml)
          return if @input['license'].nil?

          xml.tag! 'oaire:licenseCondition', { uri: @input['license'] } do
            xml.text! cc_license_mapping[@input['license']] || @input['license']
          end
        end

        def build_size_tag(xml)
          size_attributes = {
            'pageCount' => 'pages', 'imageCount' => 'images', 'tableCount' => 'tables',
            'audioCount' => 'audios', 'videoCount' => 'videos'
          }
          sizes = size_attributes.filter_map { |k, v| "#{@input[k]} #{v}" if @input[k] }

          return if sizes.empty?

          xml.tag! 'datacite:sizes' do
            sizes.each { |s| xml.tag! 'datacite:size', s }
          end
        end

        def build_file_tag(xml)
          @input['publications'].each do |publication|
            publication['locations'].each do |location|
              next if location['fullTextUrl'].nil?

              mime_type = type_mapping[publication['publicationType']]
              xml.tag! 'oaire:file', { mimeType: mime_type, objectType: 'fulltext' }, location['fullTextUrl']
            end
          end
        end

        def build_citation_title_tag(xml)
          citation_title =
            if @input['workType'] == 'BOOK_CHAPTER' && (parent_book = @input['parentBook']&.first)
              parent_book['relatedWork']['fullTitle']
            elsif (issue = @input['issue']&.first)
              issue['series']['seriesName']
            end

          xml.tag!('oaire:citationTitle', citation_title) if citation_title
        end

        private

        def build_creator_name_tag(xml, creator)
          xml.tag! 'datacite:creatorName', { nameType: 'Personal' }, "#{creator['lastName']}, #{creator['firstName']}"
          xml.tag! 'datacite:givenName', creator['firstName']
          xml.tag! 'datacite:familyName', creator['lastName']
        end

        def build_name_identifier_tag(xml, creator)
          return if creator['contributor']['orcid'].nil?

          xml.tag! 'datacite:nameIdentifier', { nameIdentifierScheme: 'ORCID', schemeURI: 'https://orcid.org/' } do
            xml.text! creator['contributor']['orcid']
          end
        end

        def build_affiliation_tag(xml, creator)
          creator['affiliations'].each do |affiliation|
            if affiliation['institution']['ror'].nil?
              xml.tag! 'datacite:affiliation', affiliation['institution']['institutionName']
            else
              xml.tag! 'datacite:affiliation', { affiliationIdentifier: affiliation['institution']['ror'] } do
                xml.text! affiliation['institution']['institutionName']
              end
            end
          end
        end

        def type_mapping
          {
            'HARDBACK' => 'hardback',
            'PAPERBACK' => 'paperback',
            'PDF' => 'application/pdf',
            'EPUB' => 'application/epub+zip',
            'XML' => 'application/xml',
            'HTML' => 'application/html',
            'DOCX' => 'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
            'MP3' => 'audio/mpeg',
            'WAV' => 'audio/wav',
            'MOBI' => 'application/x-mobipocket-ebook',
            'AZW3' => 'application/vnd.amazon.ebook',
            'FICTION_BOOK' => 'application/x-fictionbook+xml'
          }
        end

        def cc_license_mapping
          {
            'http://creativecommons.org/publicdomain/zero/1.0/' => 'CC0 1.0 Universal',
            'http://creativecommons.org/licenses/by/4.0/' => 'CC BY 4.0',
            'http://creativecommons.org/licenses/by-sa/4.0/' => 'CC BY-SA 4.0',
            'http://creativecommons.org/licenses/by-nc/4.0/' => 'CC BY-NC 4.0',
            'http://creativecommons.org/licenses/by-nc-sa/4.0/' => 'CC BY-NC-SA 4.0',
            'http://creativecommons.org/licenses/by-nd/4.0/' => 'CC BY-ND 4.0',
            'http://creativecommons.org/licenses/by-nc-nd/4.0/' => 'CC BY-NC-ND 4.0',
            'http://creativecommons.org/licenses/by/3.0/' => 'CC BY 3.0',
            'http://creativecommons.org/licenses/by-sa/3.0/' => 'CC BY-SA 3.0',
            'http://creativecommons.org/licenses/by-nc/3.0/' => 'CC BY-NC 3.0',
            'http://creativecommons.org/licenses/by-nc-sa/3.0/' => 'CC BY-NC-SA 3.0',
            'http://creativecommons.org/licenses/by-nd/3.0/' => 'CC BY-ND 3.0',
            'http://creativecommons.org/licenses/by-nc-nd/3.0/' => 'CC BY-NC-ND 3.0'
          }
        end
      end
    end
  end
end
