class /USI/CL_AUTH definition
  public
  final
  create public .

public section.

  types:
    BEGIN OF ty_tstc,
             tcode TYPE tcode,
           END OF ty_tstc .
  types:
    tty_tstc TYPE TABLE OF ty_tstc WITH NON-UNIQUE KEY tcode.

*"* public components of class /USI/CL_AUTH
*"* do not include other source files here!!!
  class-methods CHECK_TCODE .
  class-methods HAS_TCODE
    importing
      !I_TCODE type SYTCODE
    returning
      value(R_HAS_TCODE) type XFELD .
  PROTECTED SECTION.
*"* private components of class /USI/CL_AUTH
*"* do not include other source files here!!!
  PRIVATE SECTION.
*"* private components of class /USI/CL_AUTH
*"* do not include other source files here!!!
    CLASS-METHODS read_tcodes
      RETURNING VALUE(r_tcodes) TYPE tty_tstc.
    CLASS-DATA:       error       TYPE string.
ENDCLASS.



CLASS /USI/CL_AUTH IMPLEMENTATION.


  METHOD check_tcode.
    DATA:
      tcodes TYPE tty_tstc,
      tcode  TYPE tcode.

    CALL METHOD read_tcodes
      RECEIVING
        r_tcodes = tcodes.

    LOOP AT tcodes INTO tcode.
      AUTHORITY-CHECK OBJECT 'S_TCODE' ID 'TCD' FIELD tcode.
      IF sy-subrc = 0.
        RETURN.
      ENDIF.
    ENDLOOP.

    IF error IS INITIAL.
      error = TEXT-002.
      CONDENSE error.
    ENDIF.

    MESSAGE error TYPE 'S'.
    LEAVE PROGRAM.
  ENDMETHOD.


  METHOD has_tcode.
    AUTHORITY-CHECK OBJECT 'S_TCODE' ID 'TCD' FIELD i_tcode.
    IF sy-subrc = 0.
      r_has_tcode = 'X'.
    ENDIF.
  ENDMETHOD.


  METHOD read_tcodes.
    DATA: tcodes         TYPE tty_tstc,
          tcodes_para    TYPE tty_tstc,
          search_pattern TYPE tcdparam,
          temp_subrc     TYPE sysubrc VALUE 0.

    SELECT tcode INTO TABLE tcodes FROM tstc WHERE pgmna = sy-cprog ORDER BY PRIMARY KEY.
    IF sy-subrc <> 0.
      ADD 1 TO temp_subrc.
    ENDIF.

    CONCATENATE '%' sy-cprog '%' INTO search_pattern.

    SELECT tcode INTO TABLE tcodes_para FROM    tstcp WHERE param LIKE search_pattern ORDER BY PRIMARY KEY.
    IF sy-subrc <> 0.
      ADD 1 TO temp_subrc.
    ENDIF.

    APPEND LINES OF tcodes_para TO tcodes.

    r_tcodes = tcodes.

    IF temp_subrc > 1.
      error = TEXT-001.
      REPLACE '&1' WITH sy-cprog INTO error.
      CONDENSE error.
    ENDIF.

  ENDMETHOD.
ENDCLASS.
