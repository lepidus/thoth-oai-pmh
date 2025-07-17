# frozen_string_literal: true

module Thoth
  module Api
    # Queries class for Thoth API interactions
    class Queries
      WORK_FIELDS_FRAGMENT = <<~GRAPHQL
        fragment WorkFields on Work {
          workId
          doi
          publications { publicationType, isbn }
          fullTitle
          creator: contributions(contributionTypes: [AUTHOR, EDITOR]) { fullName }
          contributor: contributions(contributionTypes: [
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
          ]) { fullName }
          license
          publicationDate
          imprint { publisher { publisherName } }
          language: languages { languageCode }
          workType
          keywords: subjects(subjectTypes: [KEYWORD]) { subjectCode}
          longAbstract
          relations { relatedWork { doi, publications { isbn } } }
          updatedAtWithRelations
        }
      GRAPHQL

      WORKS_QUERY = <<~GRAPHQL
        query {
          works(
            order: {field: UPDATED_AT_WITH_RELATIONS, direction: DESC}
            workStatuses: [ACTIVE]
            limit: 100
          ) {
            ...WorkFields
          }
        }
        #{WORK_FIELDS_FRAGMENT}
      GRAPHQL

      WORK_QUERY = <<~GRAPHQL
        query($workId: Uuid!) {
          work(workId: $workId) {
            ...WorkFields
          }
        }
        #{WORK_FIELDS_FRAGMENT}
      GRAPHQL

      TIMESTAMP_QUERY = <<~GRAPHQL
        query($direction: Direction!) {
          works(
            order: {field: UPDATED_AT_WITH_RELATIONS, direction: $direction}
            workStatuses: [ACTIVE]
            limit: 1
          ) {
            updatedAtWithRelations
          }
        }
      GRAPHQL
    end
  end
end
