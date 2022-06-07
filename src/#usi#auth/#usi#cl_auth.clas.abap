CLASS /usi/cl_auth DEFINITION PUBLIC FINAL CREATE PUBLIC.
  PUBLIC SECTION.
    TYPE-POOLS abap.

    "! Checks TCode authorization (Leave program, if missing)
    CLASS-METHODS check_tcode.

    "! Checks TCode authorization (Result as flag)
    "!
    "! @parameter i_tcode     | Transaction Code
    "! @parameter r_has_tcode | Flag: Authorized?
    CLASS-METHODS has_tcode
      IMPORTING
        !i_tcode           TYPE sytcode
      RETURNING
        VALUE(r_has_tcode) TYPE xfeld.

  PROTECTED SECTION.

  PRIVATE SECTION.
    TYPES: BEGIN OF ty_transaction,
             tcode TYPE tcode,
           END   OF ty_transaction,
           ty_transactions TYPE HASHED TABLE OF ty_transaction WITH UNIQUE KEY tcode.

    CLASS-METHODS read_transactions
      RETURNING
        VALUE(r_result) TYPE ty_transactions.

ENDCLASS.



CLASS /USI/CL_AUTH IMPLEMENTATION.


  METHOD check_tcode.
    DATA: error        TYPE string,
          transaction  TYPE REF TO ty_transaction,
          transactions TYPE ty_transactions.

    transactions = read_transactions( ).
    IF transactions IS INITIAL.
      error = TEXT-001.
      REPLACE '&1' WITH sy-cprog INTO error.

    ELSE.
      READ TABLE transactions TRANSPORTING NO FIELDS WITH TABLE KEY tcode = sy-tcode.
      IF sy-subrc EQ 0.
        " The report was started by one of its own transactions
        "   => Check user is authorized for that specific transaction
        IF has_tcode( sy-tcode ) = abap_true.
          RETURN.
        ENDIF.

      ELSE.
        " The report was started by something else (e.g. submit report)
        "   => Check user is authorized for at least transaction of the report
        LOOP AT transactions REFERENCE INTO transaction.
          CHECK has_tcode( transaction->tcode ) = abap_true.
          RETURN.
        ENDLOOP.

      ENDIF.

      error = TEXT-002.
    ENDIF.

    CONDENSE error.
    MESSAGE error TYPE 'S'.
    LEAVE PROGRAM.
  ENDMETHOD.


  METHOD has_tcode.
    AUTHORITY-CHECK OBJECT 'S_TCODE' ID 'TCD' FIELD i_tcode.
    IF sy-subrc = 0.
      r_has_tcode = abap_true.
    ENDIF.
  ENDMETHOD.


  METHOD read_transactions.
    DATA: part_result      TYPE ty_transactions,
          part_result_line TYPE REF TO ty_transaction,
          search_pattern   TYPE tcdparam.

    " Transactions
    SELECT tcode INTO TABLE part_result FROM tstc WHERE pgmna = sy-cprog ORDER BY PRIMARY KEY.
    IF sy-subrc = 0.
      LOOP AT part_result REFERENCE INTO part_result_line.
        INSERT part_result_line->* INTO TABLE r_result.
      ENDLOOP.
    ENDIF.

    " Parameter transactions
    CONCATENATE '%' sy-cprog '%' INTO search_pattern.
    SELECT tcode INTO TABLE part_result FROM tstcp WHERE param LIKE search_pattern ORDER BY PRIMARY KEY.
    IF sy-subrc = 0.
      LOOP AT part_result REFERENCE INTO part_result_line.
        INSERT part_result_line->* INTO TABLE r_result.
      ENDLOOP.
    ENDIF.
  ENDMETHOD.
ENDCLASS.
