CLASS zcl_wd_gui_mermaid_js_diagram DEFINITION PUBLIC CREATE PUBLIC.
  PUBLIC SECTION.
    TYPES:
      ty_html_line         TYPE c LENGTH 512,
      ty_html_lines        TYPE STANDARD TABLE OF ty_html_line WITH DEFAULT KEY,
      ty_source_code_lines TYPE STANDARD TABLE OF string WITH DEFAULT KEY.
    CLASS-DATA:
      default_background_color TYPE string READ-ONLY,
      default_font_color       TYPE string READ-ONLY,
      default_font_name        TYPE string READ-ONLY,
      default_font_size        TYPE string READ-ONLY.
    CLASS-METHODS:
      class_constructor.
    METHODS:
      constructor IMPORTING parent      TYPE REF TO cl_gui_container
                            source_code TYPE string OPTIONAL
                  RAISING   zcx_wd_gui_mermaid_js_diagram,
      display RAISING zcx_wd_gui_mermaid_js_diagram,
      get_current_html_lines RETURNING VALUE(result) TYPE ty_html_lines,
      get_html_viewer RETURNING VALUE(result) TYPE REF TO cl_gui_html_viewer,
      set_source_code_string IMPORTING source_code TYPE string,
      set_source_code_table IMPORTING source_code_lines TYPE ty_source_code_lines,
      get_source_code_string RETURNING VALUE(result) TYPE string,
      get_background_color RETURNING VALUE(result) TYPE string,
      set_background_color IMPORTING background_color TYPE string,
      get_font_color RETURNING VALUE(result) TYPE string,
      set_font_color IMPORTING font_color TYPE string,
      get_font_name RETURNING VALUE(result) TYPE string,
      set_font_name IMPORTING font_name TYPE string,
      get_font_size RETURNING VALUE(result) TYPE string,
      set_font_size IMPORTING font_size TYPE string.
  PROTECTED SECTION.
    METHODS:
      generate_html RETURNING VALUE(result) TYPE ty_html_lines.
  PRIVATE SECTION.
    CONSTANTS:
      object_id_mermaid_js_library TYPE w3objid VALUE 'ZWD_MERMAID_JS_LIBRARY' ##NO_TEXT.
    DATA:
      html_viewer      TYPE REF TO cl_gui_html_viewer,
      html_is_current  TYPE abap_bool,
      html_lines       TYPE ty_html_lines,
      mermaid_js_url   TYPE c LENGTH 256,
      background_color TYPE string,
      source_code      TYPE string,
      font_color       TYPE string,
      font_name        TYPE string,
      font_size        TYPE string.
ENDCLASS.



CLASS ZCL_WD_GUI_MERMAID_JS_DIAGRAM IMPLEMENTATION.


  METHOD class_constructor.
* ---------------------------------------------------------------------
    default_background_color =
    zcl_wd_color_util=>get_backgrnd_color_hex_str( cl_gui_resources=>col_background_level1 ).

* ---------------------------------------------------------------------
    default_font_color =
    zcl_wd_color_util=>get_foregrnd_color_hex_str( cl_gui_resources=>col_textarea ).

* ---------------------------------------------------------------------
    cl_gui_resources=>get_fontname( IMPORTING fontname = default_font_name ).

* ---------------------------------------------------------------------
    cl_gui_resources=>get_fontsize( IMPORTING fontsize = DATA(fontsize_i) ).
    DATA(fontsize_str) = condense( CONV string( fontsize_i / 10000 ) ).

* ---------------------------------------------------------------------
  ENDMETHOD.


  METHOD constructor.
* ---------------------------------------------------------------------
    html_viewer = NEW #( parent = parent ).

* ---------------------------------------------------------------------
    set_source_code_string( source_code ).

* ---------------------------------------------------------------------
    background_color = default_background_color.
    font_color = default_font_color.
    font_size = default_font_size.
    font_name = default_font_name.

* ---------------------------------------------------------------------
    html_viewer->load_mime_object( EXPORTING object_id  = object_id_mermaid_js_library
                                             object_url = 'mermaid.min.js'
                                   IMPORTING assigned_url = mermaid_js_url
                                   EXCEPTIONS object_not_found     = 1
                                              dp_invalid_parameter = 2
                                              dp_error_general     = 3
                                              OTHERS               = 4 ).
    IF sy-subrc <> 0.
      RAISE EXCEPTION TYPE zcx_wd_gui_mermaid_js_diagram
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
        WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.

* ---------------------------------------------------------------------
  ENDMETHOD.


  METHOD display.
* ---------------------------------------------------------------------
    IF html_is_current = abap_true.
      RETURN.
    ENDIF.
    html_is_current = abap_true.

* ---------------------------------------------------------------------
    IF source_code IS INITIAL.
      RAISE EXCEPTION TYPE zcx_wd_gui_mermaid_js_diagram
        EXPORTING
          textid = zcx_wd_gui_mermaid_js_diagram=>source_code_initial.
    ENDIF.

* ---------------------------------------------------------------------
    html_lines = generate_html( ).

* ---------------------------------------------------------------------
    DATA assigned_url TYPE cnht_url.
    html_viewer->load_data( IMPORTING assigned_url = assigned_url
                            CHANGING data_table = html_lines
                            EXCEPTIONS dp_invalid_parameter   = 1
                                       dp_error_general       = 2
                                       cntl_error             = 3
                                       html_syntax_notcorrect = 4
                                       OTHERS                 = 5 ).
    IF sy-subrc <> 0.
      RAISE EXCEPTION TYPE zcx_wd_gui_mermaid_js_diagram
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
        WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.

* ---------------------------------------------------------------------
    html_viewer->show_data( EXPORTING url = assigned_url
                            EXCEPTIONS cntl_error             = 1
                                       cnht_error_not_allowed = 2
                                       cnht_error_parameter   = 3
                                       dp_error_general       = 4
                                       OTHERS                 = 5 ).
    IF sy-subrc <> 0.
      RAISE EXCEPTION TYPE zcx_wd_gui_mermaid_js_diagram
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
        WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.

* ---------------------------------------------------------------------
  ENDMETHOD.


  METHOD generate_html.
* ---------------------------------------------------------------------
    DATA(html_stub) =  |<!doctype html><html><head><meta charset="utf-8">\n|    ##NO_TEXT
                    && |<style>\n|                                              ##NO_TEXT
                    &&     |body \{\n|                                          ##NO_TEXT
                    &&         |overflow: hidden;\n|                            ##NO_TEXT
                    &&         |font-size: { font_size }pt;\n|                  ##NO_TEXT
                    &&         |font-family: "{ font_name }";\n|                ##NO_TEXT
                    &&         |color: { font_color };\n|                       ##NO_TEXT
                    &&         |background-color: { background_color };\n|      ##NO_TEXT
                    &&     |\}\n|                                               ##NO_TEXT
                    && |</style>\n|                                             ##NO_TEXT
                    && |<script src="{ mermaid_js_url }"></script>\n|           ##NO_TEXT
                    && |</head><body>\n|                                        ##NO_TEXT
                    &&     |<script>\n|                                         ##NO_TEXT
                    &&         |mermaid.initialize(\{ startOnLoad: true \});\n| ##NO_TEXT
                    &&     |</script>\n|                                        ##NO_TEXT
                    && |<div class="mermaid">\n|                                ##NO_TEXT.

* ---------------------------------------------------------------------
    APPEND html_stub TO result.

* ---------------------------------------------------------------------
    SPLIT source_code AT cl_abap_char_utilities=>newline INTO TABLE DATA(source_code_lines).
    LOOP AT source_code_lines ASSIGNING FIELD-SYMBOL(<source_code_line>).
      <source_code_line> =  replace( val = <source_code_line>
                                     sub = cl_abap_char_utilities=>cr_lf(1)
                                     with = `` )
                         && cl_abap_char_utilities=>newline.
      APPEND <source_code_line> TO result.
    ENDLOOP.


* ---------------------------------------------------------------------
    APPEND |</div></body></html>| TO result ##NO_TEXT.

* ---------------------------------------------------------------------
  ENDMETHOD.


  METHOD get_background_color.
* ---------------------------------------------------------------------
    result = background_color.

* ---------------------------------------------------------------------
  ENDMETHOD.


  METHOD get_current_html_lines.
* ---------------------------------------------------------------------
    result = html_lines.

* ---------------------------------------------------------------------
  ENDMETHOD.


  METHOD get_font_color.
* ---------------------------------------------------------------------
    result = font_color.

* ---------------------------------------------------------------------
  ENDMETHOD.


  METHOD get_font_name.
* ---------------------------------------------------------------------
    result = font_name.

* ---------------------------------------------------------------------
  ENDMETHOD.


  METHOD get_font_size.
* ---------------------------------------------------------------------
    result = font_size.

* ---------------------------------------------------------------------
  ENDMETHOD.


  METHOD get_html_viewer.
* ---------------------------------------------------------------------
    result = html_viewer.

* ---------------------------------------------------------------------
  ENDMETHOD.


  METHOD get_source_code_string.
* ---------------------------------------------------------------------
    result = source_code.

* ---------------------------------------------------------------------
  ENDMETHOD.


  METHOD set_background_color.
* ---------------------------------------------------------------------
    me->background_color = background_color.

* ---------------------------------------------------------------------
  ENDMETHOD.


  METHOD set_font_color.
* ---------------------------------------------------------------------
    me->font_color = font_color.

* ---------------------------------------------------------------------
  ENDMETHOD.


  METHOD set_font_name.
* ---------------------------------------------------------------------
    me->font_name = font_name.

* ---------------------------------------------------------------------
  ENDMETHOD.


  METHOD set_font_size.
* ---------------------------------------------------------------------
    me->font_size = font_size.

* ---------------------------------------------------------------------
  ENDMETHOD.


  METHOD set_source_code_string.
* ---------------------------------------------------------------------
    me->source_code = source_code.
    html_is_current = abap_false.

* ---------------------------------------------------------------------
  ENDMETHOD.


  METHOD set_source_code_table.
* ---------------------------------------------------------------------
    set_source_code_string( concat_lines_of( table = source_code_lines
                                             sep = cl_abap_char_utilities=>newline ) ).

* ---------------------------------------------------------------------
  ENDMETHOD.
ENDCLASS.
