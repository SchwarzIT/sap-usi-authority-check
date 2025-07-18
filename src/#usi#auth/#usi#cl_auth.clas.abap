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
      IMPORTING i_tcode            TYPE sytcode
      RETURNING VALUE(r_has_tcode) TYPE xfeld.

  PRIVATE SECTION.
    TYPES: BEGIN OF ty_transaction,
             tcode TYPE tcode,
           END   OF ty_transaction,
           ty_transactions TYPE HASHED TABLE OF ty_transaction WITH UNIQUE KEY tcode.

    CLASS-METHODS read_param_transactions
      IMPORTING i_trcode        TYPE sy-tcode OPTIONAL
      RETURNING VALUE(r_result) TYPE ty_transactions.

    CLASS-METHODS read_transactions
      RETURNING VALUE(r_result) TYPE ty_transactions.

ENDCLASS.


CLASS /usi/cl_auth IMPLEMENTATION.
  METHOD check_tcode.
    DATA error             TYPE string.
    DATA tr_not_authorised TYPE boolean VALUE abap_false.
    DATA transaction       TYPE REF TO ty_transaction.
    DATA transactions      TYPE ty_transactions.
    DATA param_transaction TYPE ty_transactions.

    " The report was started by one of its own transactions
    "   => Check user is authorized for that specific transaction
    transactions = read_transactions( ).
    param_transaction = read_param_transactions( sy-tcode ).
    INSERT LINES OF param_transaction INTO TABLE transactions.

    IF transactions IS NOT INITIAL.
      IF line_exists( transactions[ tcode = sy-tcode ] ).
        IF has_tcode( sy-tcode ) = abap_true.
          RETURN.
        ELSE.
          tr_not_authorised = abap_true.
        ENDIF.
      ENDIF.
    ENDIF.

    IF tr_not_authorised = abap_false.
      " The report was started by something else (e.g. submit report)
      "   => Check user is authorized for at least transaction of the report

      "1st prevent excessive reading of parameter transactions.
      LOOP AT transactions REFERENCE INTO transaction.
        IF has_tcode( transaction->tcode ) = abap_true.
          RETURN.
        ENDIF.
      ENDLOOP.

      "2nd ok we've tried everything now we need to read all other transactions for that object
      param_transaction = read_param_transactions( ).
      INSERT LINES OF param_transaction INTO TABLE transactions.
      IF transactions IS NOT INITIAL.
        IF line_exists( transactions[ tcode = sy-tcode ] ).
          IF has_tcode( sy-tcode ) = abap_true.
            RETURN.
          ENDIF.
        ELSE.
          LOOP AT transactions REFERENCE INTO transaction.
            IF has_tcode( transaction->tcode ) = abap_true.
              RETURN.
            ENDIF.
          ENDLOOP.
        ENDIF.
      ENDIF.
    ENDIF.

    "-- Error message creation
    IF transactions IS INITIAL.
      error = TEXT-001.
      REPLACE '&1' WITH sy-cprog INTO error.
    ELSE.
      error = TEXT-002.
    ENDIF.

    error = condense( error ).
    MESSAGE error TYPE 'S'.
    LEAVE PROGRAM.
  ENDMETHOD.

  METHOD has_tcode.
    AUTHORITY-CHECK OBJECT 'S_TCODE' ID 'TCD' FIELD i_tcode.
    IF sy-subrc = 0.
      r_has_tcode = abap_true.
    ENDIF.
  ENDMETHOD.

  METHOD read_param_transactions.
    CONSTANTS pattern_restriction TYPE string VALUE '/*start_report'.
    DATA search_pattern TYPE tcdparam.

    " Parameter transactions
    CONCATENATE pattern_restriction '%' sy-cprog '%' INTO search_pattern.
    search_pattern = to_upper( search_pattern ).

    IF i_trcode IS SUPPLIED.
      SELECT tcode INTO TABLE r_result
        FROM tstcp
        WHERE tcode = i_trcode AND param LIKE search_pattern
        ORDER BY PRIMARY KEY.
      IF sy-subrc = 0.
        RETURN.
      ENDIF.
    ELSE.

      SELECT tcode INTO TABLE r_result
        FROM tstcp
        WHERE tcode = sy-tcode AND param LIKE search_pattern
        ORDER BY PRIMARY KEY.
      IF sy-subrc <> 0.
        SELECT tcode INTO TABLE r_result FROM tstcp WHERE param LIKE search_pattern ORDER BY PRIMARY KEY.
        IF sy-subrc = 0.
          RETURN.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDMETHOD.

  METHOD read_transactions.
    " Transactions
    SELECT tcode INTO TABLE r_result FROM tstc WHERE pgmna = sy-cprog ORDER BY PRIMARY KEY.
    IF sy-subrc = 0.
      RETURN.
    ENDIF.
  ENDMETHOD.
ENDCLASS.
