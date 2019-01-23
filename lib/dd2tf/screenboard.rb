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
        isShared
        board_id
        autoscale
        add_timeframe
        aggregator
        res_calc_func
        metric_type
        metric
        is_valid_query
        conditional_formats
        calc_func
        aggr
        refresh_every
        wrapped
        padding
      )
      
      keys = {
        "mustShowErrors" => "must_show_errors",
        "mustShowBreakdown" => "must_show_breakdown",
        "hideZeroCounts" => "hide_zero_counts",
        "mustShowResourceList" => "must_show_resource_list",
        "title_text" => "title",
        "mustShowHits" => "must_show_hits",
        "mustShowDistribution" => "must_show_distribution",
        "mustShowLatency" => "must_show_latency",
        "generated_title" => "title",
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
              elsif key == "conditional_formats"
                w[key] = filter_conditional_formats(v)
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
          template_variable[k] = format_value(v) if v != nil
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
          elsif key == "markers"
            tile_def[key] = filter_markers(v)
          elsif key == "events"
            tile_def[key] = filter_events(v)
          else
            tile_def[key] = format_value(v)
          end
        end
      end
      tile_def
    end

    def filter_events(v)
      events = []
      v.each do |e|
        event = {}
        e.each do |k, v|
          event[k] = format_value(v)
        end
        events << event
      end
      events
    end

    def filter_markers(v)
      excludes = %w( val )

      markers = []
      v.each do |m|
        marker = {}
        m.each do |k, v|
          if !excludes.include?(k)
            marker[k] = format_value(v)
          end
        end
        markers << marker
      end
      markers
    end
    
    def filter_requests(v)
      excludes = %w(apm_query)

      requests = []
      v.each do |r|
        request = {}
        r.each do |k, v|
          if !excludes.include?(k)
            if k == "conditional_formats"
              request[k] = filter_conditional_formats(v)
            elsif k == "style"
              request[k] = filter_style(v) if v != {}
            elsif v != nil && v != "" && v != [] && v != {}
              request[k] = format_value(v) if v != nil
            end
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
          if v != "" && v != nil
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
      elsif v.is_a?(Hash)
        v
      else 
        %Q{"#{v.gsub(/^\n/, '')}"}
      end
    end
  end
end
