*&---------------------------------------------------------------------*
*& Report zwd_mermaid_sample_3
*&---------------------------------------------------------------------*
*&  display UML of class
*&---------------------------------------------------------------------*
REPORT zwd_mermaid_sample_3.

PARAMETERS p_clsnam TYPE seoclsname DEFAULT 'ZCL_WD_GUI_MERMAID_JS_DIAGRAM'.
SELECTION-SCREEN BEGIN OF BLOCK exp WITH FRAME TITLE TEXT-exp.
PARAMETERS p_public AS CHECKBOX DEFAULT 'X'.
PARAMETERS p_protcd AS CHECKBOX DEFAULT ' '.
PARAMETERS p_privat AS CHECKBOX DEFAULT ' '.
SELECTION-SCREEN END OF BLOCK exp.

CLASS helper DEFINITION.
  PUBLIC SECTION.
    CLASS-METHODS exposure
      IMPORTING
                i_exposure    TYPE seoexpose
      RETURNING VALUE(result) TYPE string.
    CLASS-METHODS level
      IMPORTING
                i_level       TYPE seoattdecl
      RETURNING VALUE(result) TYPE string.
ENDCLASS.

CLASS helper IMPLEMENTATION.
  METHOD exposure.
    result = SWITCH #( i_exposure
          WHEN seoc_exposure_protected THEN `#`
          WHEN seoc_exposure_public THEN `+`
          WHEN seoc_exposure_private THEN `-` ).
  ENDMETHOD.

  METHOD level.

    result = SWITCH #( i_level
            WHEN '0' THEN ``   "Instance attribute
            WHEN '1' THEN `*` "Static Attribute
            WHEN '2' THEN ` CONST`  "Constant
            ).
  ENDMETHOD.
ENDCLASS.


START-OF-SELECTION.

  IF p_public IS INITIAL
    AND p_protcd IS INITIAL
    AND p_privat IS INITIAL.
    MESSAGE 'select at lease one visibility type' TYPE 'I'.
    STOP.
  ENDIF.

  DATA r_exposure TYPE RANGE OF seoexpose.
  IF p_public = abap_true.
    APPEND VALUE #( sign = 'I' option = 'EQ' low = seoc_exposure_public ) TO r_exposure.
  ENDIF.
  IF p_protcd = abap_true.
    APPEND VALUE #( sign = 'I' option = 'EQ' low = seoc_exposure_protected ) TO r_exposure.
  ENDIF.
  IF p_privat = abap_true.
    APPEND VALUE #( sign = 'I' option = 'EQ' low = seoc_exposure_private ) TO r_exposure.
  ENDIF.

  DATA code TYPE string_table.

  APPEND |classDiagram\r| TO code.
  APPEND |class { p_clsnam } \{\r| TO code.

  DATA(class) = cl_oo_class=>get_instance( p_clsnam ).
  DATA format TYPE string.

  "Attributes
  DATA(attributes) = class->attributes.
  SORT attributes BY exposure DESCENDING.
  LOOP AT attributes INTO DATA(attr) WHERE exposure IN r_exposure.
    format = helper=>level( attr-attdecltyp ).
    APPEND |\t{ helper=>exposure( attr-exposure ) }{ attr-cmpname }{ format }\r| TO code.
  ENDLOOP.

  "Methods
  DATA(methods) = class->methods.
  SORT methods BY exposure DESCENDING.
  LOOP AT methods INTO DATA(meth) WHERE exposure IN r_exposure.
    format = helper=>level( meth-mtddecltyp ).
    APPEND |\t{ helper=>exposure( attr-exposure ) }{ meth-cmpname }(){ format }\r| TO code.
  ENDLOOP.
  APPEND |\}| TO code.

  TRY.
      DATA(diagram) = NEW zcl_wd_gui_mermaid_js_diagram( parent = cl_gui_container=>default_screen hide_scrollbars = abap_false ).
      diagram->set_source_code_string( REDUCE #( INIT str = `` FOR line IN code NEXT str = str && line ) ).
      diagram->display( ).
      cl_abap_list_layout=>suppress_toolbar( ).
      WRITE ''. " force output of cl_gui_container=>default_screen
    CATCH zcx_wd_gui_mermaid_js_diagram INTO DATA(error).
      MESSAGE error TYPE 'E'.
  ENDTRY.
