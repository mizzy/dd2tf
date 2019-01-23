resource "datadog_screenboard" "<%= board_name %>" {
  <%- board.each do |k, v| -%>
    <%- if k == "widgets" -%>
    <%- elsif k == "template_variables" -%>
      # template_variables
    <%- else -%>                                     
      <%= k %> = <%= v %>
    <%- end -%>
  <%- end -%>
}
