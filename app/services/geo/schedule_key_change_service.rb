module Geo
  class ScheduleKeyChangeService
    attr_reader :id, :action

    def initialize(key_change)
      @id = key_change['id']
      @action = key_change['action']
    end

    def execute
      GeoKeyRefreshWorker.perform_async(project['id'], project['clone_url'])
    end
  end
end
