CLASS /usi/cl_auth DEFINITION PUBLIC FINAL CREATE PUBLIC.
  PUBLIC SECTION.
    TYPE-POOLS abap.

    "! <p class="shorttext synchronized" lang="en">Checks TCode authorization (Leave program, if missing)</p>
    CLASS-METHODS check_tcode.

    "! <p class="shorttext synchronized" lang="en">Checks TCode authorization (Result as flag)</p>
    "!
    "! @parameter i_tcode     | <p class="shorttext synchronized" lang="en">Transaction Code</p>
    "! @parameter r_has_tcode | <p class="shorttext synchronized" lang="en">Flag: Authorized?</p>
    CLASS-METHODS has_tcode
      IMPORTING
        !i_tcode           TYPE sytcode
      RETURNING
        VALUE(r_has_tcode) TYPE xfeld.

  PROTECTED SECTION.

  PRIVATE SECTION.
    TYPES: BEGIN OF ty_transaction,
             tcode TYPE tcode,
           END OF ty_transaction.

    TYPES ty_transactions TYPE TABLE OF ty_transaction WITH NON-UNIQUE KEY tcode.

    CLASS-DATA error TYPE string.

    CLASS-METHODS read_tcodes
      RETURNING
        VALUE(r_result) TYPE ty_transactions.

ENDCLASS.



CLASS /usi/cl_auth IMPLEMENTATION.
  METHOD check_tcode.
    DATA tcodes TYPE ty_transactions.
    FIELD-SYMBOLS <tcode> TYPE ty_transaction.

    tcodes = read_tcodes( ).
    IF tcodes IS INITIAL.
      error = TEXT-001.
      REPLACE '&1' WITH sy-cprog INTO error.

    ELSE.
      LOOP AT tcodes ASSIGNING <tcode>.
        CHECK has_tcode( <tcode>-tcode ) EQ abap_true.
        RETURN.
      ENDLOOP.

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


  METHOD read_tcodes.
    DATA part_result TYPE ty_transactions.
    DATA search_pattern TYPE tcdparam.

    SELECT tcode INTO TABLE part_result FROM tstc WHERE pgmna = sy-cprog ORDER BY PRIMARY KEY.
    IF sy-subrc = 0.
      APPEND LINES OF part_result TO r_result.
    ENDIF.

    CONCATENATE '%' sy-cprog '%' INTO search_pattern.
    SELECT tcode INTO TABLE part_result FROM tstcp WHERE param LIKE search_pattern ORDER BY PRIMARY KEY.
    IF sy-subrc = 0.
      APPEND LINES OF part_result TO r_result.
    ENDIF.
  ENDMETHOD.
ENDCLASS.
