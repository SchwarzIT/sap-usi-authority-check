
* HB20151030 - Aufgrund E34 und E78 wieder ausgebaut. Diese Untersützen keine Unit-Tests :(

**"* local class implementation for public class
**"* use this source file for the implementation part of
**"* local helper classes
*CLASS ltcl_tcode_table DEFINITION FOR TESTING DURATION SHORT RISK LEVEL HARMLESS.
*  PRIVATE SECTION.
*    METHODS: one_valid_tcode FOR TESTING.
*    METHODS: one_valid_two_invalid_tcodes FOR TESTING.
*    METHODS: two_invalid_tcodes FOR TESTING.
*
*
*
*ENDCLASS.                    "ltcl_tcode_table DEFINITION
*
*
**----------------------------------------------------------------------*
**       CLASS ltcl_tcode_table IMPLEMENTATION
**----------------------------------------------------------------------*
**
**----------------------------------------------------------------------*
*CLASS ltcl_tcode_table IMPLEMENTATION.
*  METHOD one_valid_tcode.
*    DATA: l_insert TYPE tcode,
*          result TYPE tcode.
*    DATA l_tcode_table TYPE s_tcodes.
*
*    l_insert = 'SE24'.
*
*    INSERT l_insert INTO TABLE l_tcode_table.
*
*    result = /ki000/auth=>get_tcode_to_check( l_tcode_table ).
*
*    cl_abap_unit_assert=>assert_equals(
*        exp                  = 'SE24'
*        act                  = result
*    ).
*
*
*  ENDMETHOD.                    "one_valid_tcode
*
*  METHOD one_valid_two_invalid_tcodes.
*    DATA: l_insert TYPE tcode,
*          result TYPE tcode.
*    DATA l_tcode_table TYPE s_tcodes.
*
*    l_insert = 'SE24'.
*    INSERT l_insert INTO TABLE l_tcode_table.
*    l_insert = 'rz11'.
*    INSERT l_insert INTO TABLE l_tcode_table.
*    l_insert = 'rz12'.
*    INSERT l_insert INTO TABLE l_tcode_table.
*
*
*    result = /ki000/auth=>get_tcode_to_check( l_tcode_table ).
*
*    cl_abap_unit_assert=>assert_equals(
*        exp                  = 'SE24'
*        act                  = result
*    ).
*
*  ENDMETHOD.                    "one_valid_two_invalid_tcodes
*  METHOD two_invalid_tcodes.
*    DATA: l_insert TYPE tcode,
*          result TYPE tcode.
*    DATA l_tcode_table TYPE s_tcodes.
*
*    l_insert = 'rz11'.
*    INSERT l_insert INTO TABLE l_tcode_table.
*    l_insert = 'rz12'.
*    INSERT l_insert INTO TABLE l_tcode_table.
*
*
*    result = /ki000/auth=>get_tcode_to_check( l_tcode_table ).
*
*    cl_abap_unit_assert=>assert_equals(
*        exp                  = 'rz12'
*        act                  = result
*    ).
*
*  ENDMETHOD.                    "two_invalid_tcodes
*
*
*ENDCLASS.                    "ltcl_tcode_table IMPLEMENTATION
