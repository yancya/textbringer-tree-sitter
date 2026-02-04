# frozen_string_literal: true

module Textbringer
  module TreeSitter
    module NodeMaps
      SQL_FEATURES = {
        keyword: %i[
          SELECT FROM WHERE JOIN LEFT RIGHT INNER OUTER FULL NATURAL CROSS
          ON AND OR NOT IN IS NULL BETWEEN LIKE ILIKE
          INSERT INTO VALUES UPDATE SET DELETE
          CREATE DROP ALTER TABLE INDEX VIEW SCHEMA DATABASE
          PRIMARY_KEY FOREIGN_KEY UNIQUE CHECK CONSTRAINT REFERENCES
          GROUP_BY ORDER_BY HAVING LIMIT OFFSET FETCH
          UNION INTERSECT EXCEPT ALL DISTINCT
          AS ASC DESC NULLS FIRST LAST
          CASE WHEN THEN ELSE END
          BEGIN COMMIT ROLLBACK TRANSACTION
          IF EXISTS IF_EXISTS IF_NOT_EXISTS
          TRUE FALSE DEFAULT
          WITH RECURSIVE
          GRANT REVOKE PRIVILEGES
          RETURNS RETURN FUNCTION PROCEDURE
          FOR EACH ROW TRIGGER
          CASCADE RESTRICT SET_NULL SET_DEFAULT
          VOLATILE STABLE IMMUTABLE
          DECLARE EXECUTE
        ],
        comment: %i[comment line_comment block_comment],
        string: %i[string],
        number: %i[number],
        type: %i[
          type_cast constrained_type array_type
          INTEGER INT SMALLINT BIGINT
          REAL FLOAT DOUBLE DECIMAL NUMERIC
          VARCHAR CHAR TEXT
          BOOLEAN BOOL
          DATE TIME TIMESTAMP TIMESTAMPTZ
          JSON JSONB XML
          UUID BYTEA
          SERIAL BIGSERIAL
        ],
        function_name: %i[function_call],
        variable: %i[identifier dotted_name],
        operator: %i[binary_operator comparison_operator],
        punctuation: %i[delimiter],
        constant: %i[boolean_expression],
      }.freeze

      SQL = SQL_FEATURES.flat_map { |face, nodes|
        nodes.map { |node| [node, face] }
      }.to_h.freeze
    end
  end
end
