# frozen_string_literal: true

module Textbringer
  module TreeSitter
    module NodeMaps
      # COBOL node types are mostly uppercase
      COBOL_FEATURES = {
        comment: %i[comment],
        string: %i[string_literal],
        keyword: %i[
          PERFORM
          IF
          ELSE
          END
          MOVE
          DISPLAY
          ACCEPT
          ADD
          SUBTRACT
          MULTIPLY
          DIVIDE
          COMPUTE
          EVALUATE
          WHEN
          CALL
          GO
          TO
          STOP
          RUN
          READ
          WRITE
          OPEN
          CLOSE
          SECTION
          DIVISION
          PROGRAM
          DATA
          WORKING
          STORAGE
          FILE
          PROCEDURE
          IDENTIFICATION
          ENVIRONMENT
          CONFIGURATION
          INPUT
          OUTPUT
          SELECT
          ASSIGN
          ORGANIZATION
          ACCESS
          RECORD
          PIC
          PICTURE
          VALUE
          OCCURS
          TIMES
          THRU
          THROUGH
          VARYING
          FROM
          BY
          UNTIL
          WITH
          TEST
          BEFORE
          AFTER
          RETURNING
          GIVING
          USING
          NOT
          AND
          OR
          GREATER
          LESS
          EQUAL
          THAN
        ],
        number: %i[number],
        constant: %i[],
        function_name: %i[],
        variable: %i[identifier],
        type: %i[],
        operator: %i[],
        punctuation: %i[],
        builtin: %i[ZERO ZEROS ZEROES SPACE SPACES LOW-VALUE HIGH-VALUE],
        property: %i[]
      }.freeze

      COBOL = COBOL_FEATURES.flat_map { |face, nodes|
        nodes.map { |node| [node, face] }
      }.to_h.freeze
    end
  end
end
