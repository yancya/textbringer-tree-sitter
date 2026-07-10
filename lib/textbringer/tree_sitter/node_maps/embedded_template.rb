# frozen_string_literal: true

module Textbringer
  module TreeSitter
    module NodeMaps
      # ERB/embedded-template delimiters. `code` and `content` are
      # intentionally left unmapped here -- they're highlighted via
      # language injection instead (see injection_maps/embedded_template.rb).
      EMBEDDED_TEMPLATE_FEATURES = {
        comment: %i[comment comment_directive],
        keyword: %i[
          <%
          <%=
          <%==
          <%_
          <%|
          <%-
          <%%
          <%#
          %>
          -%>
          _%>
          %%>
          =%>
        ]
      }.freeze

      EMBEDDED_TEMPLATE = EMBEDDED_TEMPLATE_FEATURES.flat_map { |face, nodes|
        nodes.map { |node| [node, face] }
      }.to_h.freeze
    end
  end
end
