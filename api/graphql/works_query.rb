# frozen_string_literal: true

require_relative 'base'

module Thoth
  module Api
    module Graphql
      # GraphQL query for fetching works
      class WorksQuery < Base
        def self.query
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

        def self.fragment
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
      end
    end
  end
end
