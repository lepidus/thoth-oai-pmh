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
      end
    end
  end
end
