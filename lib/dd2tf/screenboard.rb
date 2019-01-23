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

            if key == "widgets"
              b[key] = filter_widgets(v)
            elsif key == "template_variables"
              b[key] = filter_template_variables(v) if v != []
            else
              b[key] = format_value(v)
            end
          end
        end
      end

      b
    end

    def filter_widgets(widgets)
      excludes = %w(
        monitor
        title
        params
        showTitle
      )
      
      keys = {
        "mustShowErrors" => "must_show_errors",
        "mustShowBreakdown" => "must_show_breadown",
        "hideZeroCounds" => "hide_zero_counts",
        "mustShowResourceList" => "must_show_resource_list",
        "title_text" => "title",
        "mustShowHits" => "must_show_hits",
        "mustShowDistribution" => "must_show_distribution",
        "mustShowLatency" => "must_show_latency",
      }

      filtered_widgets = []
      widgets.each do |widget|
        w = {}
        widget.each do |k, v|
          if !excludes.include?(k)
            if v != nil && v != ""
              if keys[k] != nil
                key = keys[k]
              else
                key = k
              end

              if key == "tile_def"
                w[key] = filter_tile_def(v)
              elsif key == "time"
                w[key] = filter_time(v) if v != {}
              else
                w[key] = format_value(v)
              end
            end
          end
        end        
        filtered_widgets << w
      end
      filtered_widgets
    end

    def filter_template_variables(v)
      template_variables = []
      v.each do |t|
        template_variable = {}
        t.each do |k, v|
          template_variable[k] = format_value(v)
        end
        template_variables << template_variable
      end
      template_variables
    end
    
    def filter_tile_def(v)
      keys = {
        "noMetricHosts" => "no_metric_hosts",
        "noGroupHosts" => "no_group_hosts",
      }
      
      tile_def = {}
      v.each do |k, v|
        if v != "" && v != nil && v != {}
          if keys[k] != nil
              key = keys[k]
          else
            key = k
          end

          if key == "requests"
            tile_def[key] = filter_requests(v)
          else
            tile_def[key] = format_value(v)
          end
        end
      end
      tile_def
    end

    def filter_requests(v)
      requests = []
      v.each do |r|
        request = {}
        r.each do |k, v|
          if k == "conditional_formats"
            request[k] = filter_conditional_formats(v)
          elsif k == "style"
            request[k] = filter_style(v) if v != {}
          elsif v != nil && v != "" && v != [] && v != {}
            request[k] = format_value(v)
          end
        end
        requests << request
      end
      requests
    end

    def filter_conditional_formats(v)
      formats = []
      v.each do |f|
        format = {}
        f.each do |k, v|
          if v != ""
            format[k] = format_value(v)
          end
        end
        formats << format
      end
      formats
    end
    
    def filter_time(v)
      v
    end

    def filter_style(v)
      v
    end
    
    def format_value(v)
      if v == true || v == false
        v
      elsif v.is_a?(Integer)
        v
      elsif v.is_a?(Array)
        v
      else 
        %Q{"#{v}"}
      end
    end
  end
end
