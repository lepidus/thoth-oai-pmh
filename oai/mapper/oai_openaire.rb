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
