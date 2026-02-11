      * COBOL Sample Program
      * Demonstrates all major language features
       IDENTIFICATION DIVISION.
       PROGRAM-ID. SAMPLE-PROGRAM.
       AUTHOR. Sample.

       ENVIRONMENT DIVISION.
       CONFIGURATION SECTION.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT EMPLOYEE-FILE
               ASSIGN TO "employees.dat"
               ORGANIZATION IS SEQUENTIAL
               ACCESS MODE IS SEQUENTIAL
               FILE STATUS IS WS-FILE-STATUS.

       DATA DIVISION.
       FILE SECTION.
       FD EMPLOYEE-FILE.
       01 EMPLOYEE-RECORD.
           05 EMP-ID          PIC 9(5).
           05 EMP-NAME         PIC X(30).
           05 EMP-SALARY       PIC 9(7)V99.
           05 EMP-DEPARTMENT   PIC X(20).

       WORKING-STORAGE SECTION.
      * --- Variables ---
       01 WS-FILE-STATUS       PIC XX.
       01 WS-EOF               PIC 9 VALUE ZERO.
       01 WS-COUNTER           PIC 9(3) VALUE ZEROS.
       01 WS-TOTAL-SALARY      PIC 9(10)V99 VALUE ZEROES.
       01 WS-AVERAGE            PIC 9(7)V99.
       01 WS-NAME              PIC X(30) VALUE SPACES.
       01 WS-MESSAGE           PIC X(80) VALUE LOW-VALUE.

      * --- Numbers ---
       01 WS-INTEGER           PIC 9(5) VALUE 42.
       01 WS-NEGATIVE          PIC S9(5) VALUE -17.
       01 WS-DECIMAL           PIC 9(5)V99 VALUE 3.14.

      * --- String ---
       01 WS-GREETING          PIC X(20) VALUE "Hello, World!".

      * --- Table / Array ---
       01 WS-SCORE-TABLE.
           05 WS-SCORE          PIC 9(3) OCCURS 10 TIMES.

       01 WS-MONTH-TABLE.
           05 WS-MONTH-ENTRY    OCCURS 12 TIMES.
               10 WS-MONTH-NAME PIC X(10).
               10 WS-MONTH-DAYS PIC 99.

      * --- Condition names (88 levels) ---
       01 WS-STATUS            PIC X.
           88 STATUS-ACTIVE    VALUE "A".
           88 STATUS-INACTIVE  VALUE "I".
           88 STATUS-DELETED   VALUE "D".

       01 WS-RESULT            PIC 9(5).
       01 WS-A                 PIC 9(3).
       01 WS-B                 PIC 9(3).
       01 WS-TEMP              PIC 9(5).
       01 WS-INDEX             PIC 9(3).

       PROCEDURE DIVISION.
       MAIN-PROGRAM.
      * --- Display ---
           DISPLAY "=== COBOL Sample Program ===".
           DISPLAY WS-GREETING.

      * --- MOVE ---
           MOVE "Alice" TO WS-NAME.
           MOVE 100 TO WS-A.
           MOVE 200 TO WS-B.
           DISPLAY "Name: " WS-NAME.

      * --- Arithmetic: ADD ---
           ADD WS-A TO WS-B GIVING WS-RESULT.
           DISPLAY "Add: " WS-RESULT.

      * --- Arithmetic: SUBTRACT ---
           SUBTRACT WS-A FROM WS-B GIVING WS-RESULT.
           DISPLAY "Subtract: " WS-RESULT.

      * --- Arithmetic: MULTIPLY ---
           MULTIPLY WS-A BY WS-B GIVING WS-RESULT.
           DISPLAY "Multiply: " WS-RESULT.

      * --- Arithmetic: DIVIDE ---
           DIVIDE WS-B BY WS-A GIVING WS-RESULT.
           DISPLAY "Divide: " WS-RESULT.

      * --- Arithmetic: COMPUTE ---
           COMPUTE WS-RESULT = (WS-A + WS-B) * 2 - 10.
           DISPLAY "Compute: " WS-RESULT.

      * --- IF / ELSE ---
           IF WS-A GREATER THAN WS-B
               DISPLAY "A is greater"
           ELSE IF WS-A LESS THAN WS-B
               DISPLAY "B is greater"
           ELSE IF WS-A EQUAL TO WS-B
               DISPLAY "Equal"
           END-IF.

      * --- IF with AND / OR / NOT ---
           IF WS-A GREATER THAN 0 AND WS-B GREATER THAN 0
               DISPLAY "Both positive"
           END-IF.

           IF WS-A GREATER THAN 100 OR WS-B GREATER THAN 100
               DISPLAY "At least one over 100"
           END-IF.

           IF NOT WS-A EQUAL TO ZERO
               DISPLAY "A is not zero"
           END-IF.

      * --- EVALUATE (switch/case) ---
           EVALUATE WS-INTEGER
               WHEN 1 THRU 10
                   DISPLAY "Small"
               WHEN 11 THRU 100
                   DISPLAY "Medium"
               WHEN OTHER
                   DISPLAY "Large"
           END-EVALUATE.

      * --- PERFORM (loop) ---
           PERFORM DISPLAY-LINE
               VARYING WS-INDEX FROM 1 BY 1
               UNTIL WS-INDEX GREATER THAN 5.

      * --- PERFORM with TIMES ---
           PERFORM DISPLAY-LINE 3 TIMES.

      * --- PERFORM with TEST BEFORE ---
           MOVE 1 TO WS-INDEX.
           PERFORM WITH TEST BEFORE
               UNTIL WS-INDEX GREATER THAN 10
               DISPLAY "Index: " WS-INDEX
               ADD 1 TO WS-INDEX
           END-PERFORM.

      * --- PERFORM with TEST AFTER ---
           MOVE 1 TO WS-INDEX.
           PERFORM WITH TEST AFTER
               UNTIL WS-INDEX GREATER THAN 5
               DISPLAY "After: " WS-INDEX
               ADD 1 TO WS-INDEX
           END-PERFORM.

      * --- Table operations ---
           PERFORM VARYING WS-INDEX FROM 1 BY 1
               UNTIL WS-INDEX GREATER THAN 10
               COMPUTE WS-SCORE(WS-INDEX) = WS-INDEX * 10
           END-PERFORM.

      * --- ACCEPT ---
           ACCEPT WS-NAME FROM COMMAND-LINE.

      * --- String operations ---
           MOVE "Hello, World!" TO WS-GREETING.

      * --- GO TO ---
           GO TO FINAL-SECTION.

       DISPLAY-LINE.
           DISPLAY "Line: " WS-INDEX.

       FINAL-SECTION.
      * --- STOP RUN ---
           DISPLAY "=== Program Complete ===".
           STOP RUN.
