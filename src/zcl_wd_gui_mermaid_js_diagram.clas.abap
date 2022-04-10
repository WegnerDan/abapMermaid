CLASS zcl_wd_gui_mermaid_js_diagram DEFINITION PUBLIC CREATE PUBLIC.
  PUBLIC SECTION.
    CONSTANTS:
      html_line_length TYPE i VALUE 255.
    TYPES:
      BEGIN OF ty_configuration,
        theme                 TYPE string,
        log_level             TYPE string,
        security_level        TYPE string,
        start_on_load         TYPE abap_bool,
        arrow_marker_absolute TYPE abap_bool,
        BEGIN OF er,
          diagram_padding   TYPE i,
          layout_direction  TYPE string,
          min_entity_width  TYPE i,
          min_entity_height TYPE i,
          entity_padding    TYPE i,
          stroke            TYPE string,
          fill              TYPE string,
          font_size         TYPE i,
          use_max_width     TYPE abap_bool,
        END OF er,
        BEGIN OF flowchart,
          diagram_padding TYPE i,
          html_labels     TYPE abap_bool,
          curve           TYPE string,
        END OF flowchart,
        BEGIN OF sequence,
          diagram_margin_x      TYPE i,
          diagram_margin_y      TYPE i,
          actor_margin          TYPE i,
          width                 TYPE i,
          height                TYPE i,
          box_margin            TYPE i,
          box_text_margin       TYPE i,
          note_margin           TYPE i,
          message_margin        TYPE i,
          message_align         TYPE string,
          mirror_actors         TYPE abap_bool,
          bottom_margin_adj     TYPE i,
          use_max_width         TYPE abap_bool,
          right_angles          TYPE abap_bool,
          show_sequence_numbers TYPE abap_bool,
        END OF sequence,
        BEGIN OF gantt,
          title_top_margin        TYPE i,
          bar_height              TYPE i,
          bar_gap                 TYPE i,
          top_padding             TYPE i,
          left_padding            TYPE i,
          grid_line_start_padding TYPE i,
          font_size               TYPE i,
          font_family             TYPE string,
          number_section_styles   TYPE i,
          axis_format             TYPE string,
          top_axis                TYPE abap_bool,
        END OF gantt,
      END OF ty_configuration,
      ty_html_line         TYPE c LENGTH html_line_length,
      ty_html_lines        TYPE STANDARD TABLE OF ty_html_line WITH DEFAULT KEY,
      ty_source_code_lines TYPE STANDARD TABLE OF string WITH DEFAULT KEY.
    CLASS-DATA:
      default_background_color TYPE string READ-ONLY,
      default_font_color       TYPE string READ-ONLY,
      default_font_name        TYPE string READ-ONLY,
      default_font_size        TYPE string READ-ONLY,
      default_config           TYPE ty_configuration READ-ONLY.
    CLASS-METHODS:
      class_constructor.
    METHODS:
      constructor IMPORTING parent        TYPE REF TO cl_gui_container
                            source_code   TYPE string OPTIONAL
                            configuration TYPE ty_configuration OPTIONAL
                  RAISING   zcx_wd_gui_mermaid_js_diagram,
      display RAISING zcx_wd_gui_mermaid_js_diagram,
      get_current_html_table RETURNING VALUE(result) TYPE ty_html_lines,
      get_current_html_string RETURNING VALUE(result) TYPE string,
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
      set_font_size IMPORTING font_size TYPE string,
      get_configuration RETURNING VALUE(result) TYPE ty_configuration,
      set_configuration IMPORTING configuration TYPE ty_configuration.
  PROTECTED SECTION.
    METHODS:
      convert_config2json RETURNING VALUE(result) TYPE string,
      generate_html RETURNING VALUE(result) TYPE ty_html_lines.
  PRIVATE SECTION.
    CONSTANTS:
      object_id_mermaid_js_library TYPE w3objid VALUE 'ZWD_MERMAID_JS_LIBRARY' ##NO_TEXT.
    DATA:
      html_viewer      TYPE REF TO cl_gui_html_viewer,
      html_is_current  TYPE abap_bool,
      html_lines       TYPE ty_html_lines,
      configuration    TYPE ty_configuration,
      config_json      TYPE string,
      mermaid_js_url   TYPE c LENGTH 256,
      background_color TYPE string,
      source_code      TYPE string,
      font_color       TYPE string,
      font_name        TYPE string,
      font_size        TYPE string.
ENDCLASS.



CLASS zcl_wd_gui_mermaid_js_diagram IMPLEMENTATION.


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
    default_config-theme = 'default'.
    default_config-log_level = 'fatal'.
    default_config-security_level = 'strict'.
    default_config-start_on_load = abap_true.
    default_config-arrow_marker_absolute = abap_false.
    default_config-er-diagram_padding = 20.
    default_config-er-layout_direction = 'TB'.
    default_config-er-min_entity_width = 100.
    default_config-er-min_entity_height = 75.
    default_config-er-entity_padding = 15.
    default_config-er-stroke = 'gray'.
    default_config-er-fill = 'honeydew'.
    default_config-er-font_size = 12.
    default_config-er-use_max_width = abap_true.
    default_config-flowchart-diagram_padding = 8.
    default_config-flowchart-html_labels = abap_true.
    default_config-flowchart-curve = 'basis'.
    default_config-sequence-diagram_margin_x = 50.
    default_config-sequence-diagram_margin_y = 10.
    default_config-sequence-actor_margin = 50.
    default_config-sequence-width = 150.
    default_config-sequence-height = 65.
    default_config-sequence-box_margin = 10.
    default_config-sequence-box_text_margin = 5.
    default_config-sequence-note_margin = 10.
    default_config-sequence-message_margin = 35.
    default_config-sequence-message_align = 'center'.
    default_config-sequence-mirror_actors = abap_true.
    default_config-sequence-bottom_margin_adj = 1.
    default_config-sequence-use_max_width = abap_true.
    default_config-sequence-right_angles = abap_false.
    default_config-sequence-show_sequence_numbers = abap_false.
    default_config-gantt-title_top_margin = 25.
    default_config-gantt-bar_height = 20.
    default_config-gantt-bar_gap = 4.
    default_config-gantt-top_padding = 50.
    default_config-gantt-left_padding = 75.
    default_config-gantt-grid_line_start_padding = 35.
    default_config-gantt-font_size = 11.
    default_config-gantt-font_family = '"Open Sans". sans-serif'.
    default_config-gantt-number_section_styles = 4.
    default_config-gantt-axis_format = '%Y-%m-%d'.
    default_config-gantt-top_axis = abap_false.

* ---------------------------------------------------------------------
  ENDMETHOD.


  METHOD constructor.
* ---------------------------------------------------------------------
    html_viewer = NEW #( parent = parent ).

* ---------------------------------------------------------------------
    set_source_code_string( source_code ).

* ---------------------------------------------------------------------
    IF configuration IS SUPPLIED.
      set_configuration( configuration ).
    ELSE.
      set_configuration( default_config ).
    ENDIF.

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


  METHOD convert_config2json.
* ---------------------------------------------------------------------
    result = /ui2/cl_json=>serialize( data = configuration
                                      compress = abap_true
                                      pretty_name = /ui2/cl_json=>pretty_mode-camel_case ).

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
    DATA(html) =  |<!doctype html><html><head>\n|                          ##NO_TEXT
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
               &&         |var config = { config_json };\n|                ##NO_TEXT
               &&         |mermaid.initialize(config);\n|                  ##NO_TEXT
               &&     |</script>\n|                                        ##NO_TEXT
               && |<div class="mermaid">\n|                                ##NO_TEXT
               && source_code
               && |\n</div></body></html>| ##NO_TEXT.

* ---------------------------------------------------------------------
    DATA(pos) = strlen( html ).
    WHILE pos > html_line_length.
      APPEND html(html_line_length) TO result.
      SHIFT html LEFT BY html_line_length PLACES.
      pos = pos - html_line_length.
    ENDWHILE.
    APPEND html(pos) TO result.

* ---------------------------------------------------------------------
  ENDMETHOD.


  METHOD get_background_color.
* ---------------------------------------------------------------------
    result = background_color.

* ---------------------------------------------------------------------
  ENDMETHOD.


  METHOD get_configuration.
* ---------------------------------------------------------------------
    result = me->configuration.

* ---------------------------------------------------------------------
  ENDMETHOD.


  METHOD get_current_html_string.
* ---------------------------------------------------------------------
    result = concat_lines_of( table = html_lines
                              sep = cl_abap_char_utilities=>cr_lf ).

* ---------------------------------------------------------------------
  ENDMETHOD.


  METHOD get_current_html_table.
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


  METHOD set_configuration.
* ---------------------------------------------------------------------
    me->configuration = configuration.
    config_json = convert_config2json( ).

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
                                             sep = cl_abap_char_utilities=>cr_lf ) ).

* ---------------------------------------------------------------------
  ENDMETHOD.


ENDCLASS.
