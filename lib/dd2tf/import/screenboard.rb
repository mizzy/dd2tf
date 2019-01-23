module Dd2tf
  module Import
    class Screenboard < Base
      def resource_type
        "datadog_screenboard"
      end

      def resources
        resources = []
        boards = @client.get_all_screenboards[1]["screenboards"]

        boards.each do |board|
          board_name = board["title"]
                         .underscore.gsub(/\s+/, '_')
                         .gsub(::Dd2tf::UNALLOWED_RESOURCE_TITLE_REGEXP, '')
                         .gsub('&', 'and')
                         .gsub('英単語サプリ', 'eitango_sapuri_')
          resource_id = board["id"]
          resources << { resource_id: resource_id, resource_name: board_name }
        end

        resources
      end
    end
  end
end
