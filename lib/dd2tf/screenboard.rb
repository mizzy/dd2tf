module Dd2tf
  class Screenboard < Base
    def output
      results = []
      board_ids = @client.get_all_screenboards[1]["screenboards"].map{|board| board["id"]}
      board_ids.each do |board_id|
        board = @client.get_screenboard(board_id)[1]
        board_name = board["board_title"]
                       .underscore.gsub(/\s+/, '_')
                       .gsub(::Dd2tf::UNALLOWED_RESOURCE_TITLE_REGEXP, '')
                       .gsub('&', 'and')
                       .gsub('英単語サプリ', 'eitango_sapuri_')

        board = filter_board(board)

        renderer = renderer()
        results << renderer.result(binding)
      end

      results
    end

    def filter_board(board)
      b = {}

      excludes = %w(
        created modified created_by id isIntegration board_bgtype
        originalHeight disableEditing originalWidth disableCog
        title_edited original_title showGlobalTimeOnboarding templated
      )

      keys = {
        "board_title" => "title",
        "isShared" => "shared"
      }
      
      board.each do |k, v|
        if !excludes.include?(k)
          if v != nil
            if keys[k] != nil
              key = keys[k]
            else
              key = k
            end
            if v == true || v == false
              b[key] = v
            elsif v.is_a?(Integer)
              b[key] = v
            elsif v.is_a?(Array)
              b[key] = v
            else
              b[key] = %Q{"#{v}"}
            end
          end
        end
      end

      b
    end
  end
end
