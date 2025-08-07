# frozen_string_literal: true

module Thoth
  module Api
    # Queries class for Thoth API interactions
    class Queries
      WORK_FIELDS_FRAGMENT = <<~GRAPHQL
        fragment WorkFields on Work {
          title
    	    subtitle
          creator:contributions(contributionTypes:[AUTHOR]) { ...ContributionFields }
          contributor:contributions(contributionTypes:[
            EDITOR,
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
          ]) { ...ContributionFields }
          fundings { institution { institutionName, ror }, projectName, grantNumber }
          doi
          landingPage
          publications { publicationType, isbn, locations { fullTextUrl } }
          relations(
            relationTypes: [HAS_PART, IS_PART_OF, HAS_CHILD, IS_CHILD_OF]
          ) { relationType, relatedWork { doi, landingPage, publications { isbn } } }
          parentBook:relations(
            relationTypes:[IS_CHILD_OF], limit: 1
          ) { relatedWork { fullTitle, edition } }
          languages { languageCode }
          imprint { publisher { publisherName } }
          publicationDate
          workType
          shortAbstract
          longAbstract
          toc
          workId
          subjects { subjectType, subjectCode }
          license
          pageCount
          imageCount
          tableCount
          audioCount
          videoCount
          issue:issues(limit: 1) { issueOrdinal, series { seriesName } }
          firstPage
          lastPage
          updatedAtWithRelations
        }
      GRAPHQL

      CONTRIBUTION_FIELDS_FRAGMENT = <<~GRAPHQL
        fragment ContributionFields on Contribution {
          contributionType
          firstName
          lastName
          fullName
          contributor { orcid }
          affiliations { institution { institutionName, ror } }
        }
      GRAPHQL

      WORKS_QUERY = <<~GRAPHQL
        query($offset: Int!, $publishersId: [Uuid!]) {
          works(
            order: {field: UPDATED_AT_WITH_RELATIONS, direction: DESC}
            workStatuses: [ACTIVE]
            limit: 100
            offset: $offset
            publishers: $publishersId
          ) {
            ...WorkFields
          }
        }
        #{WORK_FIELDS_FRAGMENT}
        #{CONTRIBUTION_FIELDS_FRAGMENT}
      GRAPHQL

      WORK_QUERY = <<~GRAPHQL
        query($workId: Uuid!) {
          work(workId: $workId) {
            ...WorkFields
          }
        }
        #{WORK_FIELDS_FRAGMENT}
      GRAPHQL

      WORK_COUNT_QUERY = <<~GRAPHQL
        query($publishersId: [Uuid!]) {
          workCount(
            publishers: $publishersId
            workStatuses: [ACTIVE]
          )
        }
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

      PUBLISHERS_QUERY = <<~GRAPHQL
        query {
          publishers {
            publisherId
            publisherName
          }
        }
      GRAPHQL
    end
  end
end
