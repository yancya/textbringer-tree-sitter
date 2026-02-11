# frozen_string_literal: true

module Textbringer
  module TreeSitter
    module NodeMaps
      SQL_FEATURES = {
        keyword: %i[
          SELECT FROM WHERE JOIN LEFT RIGHT INNER OUTER FULL NATURAL CROSS
          ON AND OR NOT IN IS NULL BETWEEN
          INSERT INTO VALUES UPDATE SET DELETE
          CREATE DROP ALTER TABLE INDEX VIEW SCHEMA DATABASE
          PRIMARY_KEY UNIQUE CHECK CONSTRAINT REFERENCES
          GROUP_BY ORDER_BY HAVING LIMIT OFFSET FETCH
          UNION INTERSECT EXCEPT ALL DISTINCT
          AS ASC DESC NULLS FIRST LAST
          CASE WHEN THEN ELSE END
          BEGIN COMMIT ROLLBACK TRANSACTION
          IF EXISTS
          TRUE FALSE DEFAULT
          WITH RECURSIVE
          GRANT REVOKE PRIVILEGES
          RETURNS RETURN FUNCTION PROCEDURE
          FOR EACH ROW TRIGGER
          CASCADE RESTRICT
          VOLATILE STABLE IMMUTABLE
          DECLARE EXECUTE
          like
        ],
        comment: %i[comment line_comment block_comment],
        string: %i[content],
        number: %i[number],
        type: %i[],
        function_name: %i[],
        variable: %i[identifier],
        operator: %i[],
        punctuation: %i[],
        constant: %i[],
        builtin: %i[],
        property: %i[],
      }.freeze

      SQL = SQL_FEATURES.flat_map { |face, nodes|
        nodes.map { |node| [node, face] }
      }.to_h.freeze
    end
  end
end
