# frozen_string_literal: true

require 'httparty'

module Thoth
  module Api
    # Client to interact with the Thoth API
    class Client
      def initialize(url = 'https://api.thoth.pub/graphql', http_client: HTTParty)
        @url = url
        @http_client = http_client
      end

      def works
        execute(works_query)
      end

      def execute(query, variables: {})
        body = { query: query }
        body[:variables] = variables if variables.any?

        @http_client.post(
          @url,
          headers: headers,
          body: body.to_json
        )
      end

      private

      def headers
        {
          'Content-Type' => 'application/json'
        }.freeze
      end

      def fragment
        <<-GRAPHQL
        fragment workFields on Work {
          workId
            doi
            publications {
              publicationType
              isbn
            }
            fullTitle
            creator: contributions(contributionTypes: [AUTHOR, EDITOR]) {
              fullName
            }
            contributor: contributions(
              contributionTypes: [
                TRANSLATOR,
                PHOTOGRAPHER,
                ILLUSTRATOR,
                MUSIC_EDITOR,
                FOREWORD_BY,
                INTRODUCTION_BY,
                AFTERWORD_BY,
                PREFACE_BY,
                SOFTWARE_BY,
                RESEARCH_BY,
                CONTRIBUTIONS_BY,
                INDEXER
              ]
            ) {
              fullName
            }
            license
            publicationDate
            imprint {
              publisher {
                publisherName
              }
            }
            language: languages(order: {field: MAIN_LANGUAGE, direction: ASC}, limit: 1) {
              languageCode
            }
            workType
            keywords: subjects(subjectTypes: [KEYWORD]) {
              subjectCode
            }
            longAbstract
            relations {
              relationType
              relatedWork {
                doi
                publications {
                  isbn
                }
              }
            }
        }
        GRAPHQL
      end

      def works_query
        <<-GRAPHQL
        query {
          works(
            order: {field: UPDATED_AT_WITH_RELATIONS, direction: ASC}
            workStatuses: [ACTIVE]
          ) {
            ...workFields
          }
        }
        #{fragment}
        GRAPHQL
      end
    end
  end
end
