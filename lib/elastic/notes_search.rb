module Elastic
  module NotesSearch
    extend ActiveSupport::Concern

    included do
      include ApplicationSearch

      mappings do
        indexes :id,          type: :integer
        indexes :note,        type: :string,
                              index_options: 'offsets'
        indexes :project_id,  type: :integer
        indexes :created_at,  type: :date

        indexes :updated_at_sort, type: :string, index: 'not_analyzed'
      end

      def as_indexed_json(options = {})
        data = {}

        # We don't use as_json(only: ...) because it calls all virtual and serialized attributtes
        # https://gitlab.com/gitlab-org/gitlab-ee/issues/349
        [:id, :note, :project_id, :created_at].each do |attr|
          data[attr.to_s] = self.send(attr)
        end

        data['updated_at_sort'] = updated_at
        data
      end

      def self.elastic_search(query, options: {})
        options[:in] = ["note"]

        query_hash = {
          query: {
            filtered: {
              query: { match: { note: query } },
            },
          }
        }

        if query.blank?
          query_hash[:query][:filtered][:query] = { match_all: {} }
          query_hash[:track_scores] = true
        end

        query_hash = project_ids_filter(query_hash, options[:project_ids])

        query_hash[:sort] = [
          { updated_at_sort: { order: :desc, mode: :min } },
          :_score
        ]

        query_hash[:highlight] = highlight_options(options[:in])

        self.__elasticsearch__.search(query_hash)
      end
    end
  end
end
