resource "datadog_screenboard" "<%= board_name %>" {
  <%- board.each do |k, v| -%>
    <%- if k == "widgets" -%>
      <%- v.each do |widget| -%>
      widget {
          <%- widget.each do |k, v| -%>
            <%- if k == "conditional_formats" -%>
              <%- v.each do |format| -%>
              conditional_format {
                 <%- format.each do |k, v| -%>
                   <%= k %> = <%= v %>
                 <%- end -%>
              }
              <%- end -%>
            <%- elsif k == "tile_def" -%>
             tile_def {
                <%- v.each do |k, v| -%>
                  <%- if k == "markers" -%>
                    <%- v.each do |marker| -%>
                    marker {
                      <%- marker.each do |k, v| -%>
                        <%= k %> = <%= v %>
                      <%- end -%>
                    }
                    <%- end -%>
                  <%- elsif k == "requests" -%>
                    <%- v.each do |request| -%>
                      request {
                      <%- request.each do |k, v| -%>
                         <%- if k == "conditional_formats" -%>
                           <%- v.each do |format| -%>
                           conditional_format {
                             <%- format.each do |k, v| -%>
                               <%= k %> = <%= v %>
                             <%- end -%>
                           }
                           <%- end -%>
                         <%- elsif k == "style" -%>
                           style {
                           <%- v.each do |k, v| -%>
                             <%= k %> = "<%= v %>"
                           <%- end -%>
                           }
                         <%- else -%>
                           <%= k %> = <%= v %>
                         <%- end -%>
                      <%- end -%>
                      }
                    <%- end -%>
                  <%- else -%>
                    <%= k %> = <%= v %>
                  <%- end -%>
                <%- end -%>
             }
           <%- elsif k == "time" -%>
           time {
              <%- v.each do |k, v| -%>
                <%= k %> = "<%= v %>"
              <%- end -%>
           }
             <%- else -%>
               <%= k %> = <%= v %>
             <%- end  -%>
          <%- end -%>
      }
      <%- end -%>
    <%- elsif k == "template_variables" -%>
      <%- v.each do |template| -%>
      template_variable {
        <%- template.each do |k, v| -%>
            <%= k %> = <%= v %>
        <%- end -%>
      }
      <%- end -%>
    <%- else -%>                                     
      <%= k %> = <%= v %>
    <%- end -%>
  <%- end -%>
}
