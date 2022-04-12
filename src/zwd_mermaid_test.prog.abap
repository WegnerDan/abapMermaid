*&---------------------------------------------------------------------*
*& Report zwd_mermaid_test
*&---------------------------------------------------------------------*
*& Use Mermaid Live Editor to design the diagram and this report to
*& test how it looks in a specific SAP GUI Theme
*& https://mermaid-js.github.io/mermaid-live-editor/
*&---------------------------------------------------------------------*
REPORT zwd_mermaid_test.

CLASS lcl_report DEFINITION.
  PUBLIC SECTION.
    CLASS-DATA:
      fcode TYPE sy-ucomm.
    METHODS:
      run,
      pbo_2000,
      pai_2000.
  PRIVATE SECTION.
    DATA:
      parent_container    TYPE REF TO cl_gui_custom_container,
      splitter_container  TYPE REF TO cl_gui_splitter_container,
      splitter_container2 TYPE REF TO cl_gui_splitter_container,
      menu_bar_container  TYPE REF TO cl_gui_container,
      menu_bar            TYPE REF TO cl_gui_container_bar_2,
      diagram_container   TYPE REF TO cl_gui_container,
      source_editor       TYPE REF TO cl_gui_textedit,
      config_editor       TYPE REF TO cl_gui_textedit,
      error_editor        TYPE REF TO cl_gui_textedit,
      diagram             TYPE REF TO zcl_wd_gui_mermaid_js_diagram,
      initial_diagram     TYPE string.
    METHODS:
      pretty_print_json IMPORTING unformatted_json TYPE string
                        RETURNING VALUE(result)    TYPE string,
      handle_parse_error FOR EVENT parse_error_ocurred OF zcl_wd_gui_mermaid_js_diagram
        IMPORTING error,
      create_objects.
ENDCLASS.
DATA report TYPE REF TO lcl_report ##needed.


INITIALIZATION.
  report = NEW #( ).


START-OF-SELECTION.
  report->run( ).


CLASS lcl_report IMPLEMENTATION.

  METHOD run.
* ---------------------------------------------------------------------
    initial_diagram =  `flowchart LR               ` && cl_abap_char_utilities=>cr_lf ##no_text
                    && `A[Hard] -->|Text| B(Round) ` && cl_abap_char_utilities=>cr_lf
                    && `B --> C{Decision}          ` && cl_abap_char_utilities=>cr_lf
                    && `C -->|One| D[Result 1]     ` && cl_abap_char_utilities=>cr_lf
                    && `C -->|Two| E[Result 2]     `.

* ---------------------------------------------------------------------
    CALL SCREEN '2000'.

* ---------------------------------------------------------------------
  ENDMETHOD.


  METHOD pbo_2000.
* ---------------------------------------------------------------------
    SET PF-STATUS 'STATUS_2000'.
    SET TITLEBAR 'TITLE_2000'.

* ---------------------------------------------------------------------
    IF parent_container IS NOT BOUND.
      create_objects( ).
    ENDIF.

* ---------------------------------------------------------------------
    error_editor->set_textstream( `` ).

* ---------------------------------------------------------------------
    diagram->display( ).

* ---------------------------------------------------------------------
  ENDMETHOD.


  METHOD pai_2000.
* ---------------------------------------------------------------------
    CASE fcode.
      WHEN 'BACK' OR 'EXIT'.
        LEAVE TO SCREEN 0.
      WHEN 'EXECUTE'.
        source_editor->get_textstream( IMPORTING text = DATA(source_code) ).
        config_editor->get_textstream( IMPORTING text = DATA(config_json) ).
        cl_gui_cfw=>flush( ).
        diagram->set_source_code_string( source_code ).
        diagram->set_configuration_json( config_json ).
      WHEN 'PRETTY_CFG'.
        config_editor->get_textstream( IMPORTING text = config_json ).
        cl_gui_cfw=>flush( ).
        config_editor->set_textstream( pretty_print_json( config_json ) ).
    ENDCASE.

* ---------------------------------------------------------------------
  ENDMETHOD.


  METHOD create_objects.
* ---------------------------------------------------------------------
    parent_container = NEW #( container_name = 'CUSTOM_CONTROL_1' ).

* ---------------------------------------------------------------------
    splitter_container = NEW #( parent = parent_container
                                columns = 2
                                rows = 1 ).
    splitter_container2 = NEW #( parent = splitter_container->get_container( row    = 1
                                                                             column = 1 )
                                 columns = 1
                                 rows = 2 ).
    splitter_container2->set_row_height( id = 2
                                         height = 20 ).

* ---------------------------------------------------------------------
    error_editor = NEW #( parent =  splitter_container2->get_container( row    = 2
                                                                        column = 1 ) ).
    error_editor->set_readonly_mode( readonly_mode = cl_gui_textedit=>true ).
    error_editor->set_toolbar_mode( toolbar_mode = cl_gui_textedit=>false ).
    error_editor->set_statusbar_mode( statusbar_mode = cl_gui_textedit=>false ).

* ---------------------------------------------------------------------
    menu_bar = NEW #( parent = splitter_container2->get_container( row    = 1
                                                                   column = 1 )
                      captions = VALUE #( ( caption = 'Source Code'(001) )
                                          ( caption = 'Configuration'(002) ) ) ).
    source_editor = NEW #( parent = menu_bar->get_container( id = 1 ) ).
    config_editor = NEW #( parent = menu_bar->get_container( id = 2 ) ).
    source_editor->set_textstream( initial_diagram ).

* ---------------------------------------------------------------------
    diagram = NEW #( parent = splitter_container->get_container( row    = 1
                                                                 column = 2 )
                     allow_empty_control = abap_true ).
    SET HANDLER handle_parse_error FOR diagram.
    config_editor->set_textstream( pretty_print_json( diagram->get_configuration_json( ) ) ).
    diagram->set_source_code_string( initial_diagram ).

* ---------------------------------------------------------------------
  ENDMETHOD.


  METHOD pretty_print_json.
* ---------------------------------------------------------------------
    DATA(reader) = cl_sxml_string_reader=>create( cl_abap_codepage=>convert_to( unformatted_json ) ).
    DATA(writer) = CAST if_sxml_writer( cl_sxml_string_writer=>create( type = if_sxml=>co_xt_json
                                                                       ignore_conversion_errors = abap_true ) ).
    writer->set_option( option = if_sxml_writer=>co_opt_linebreaks ).
    writer->set_option( option = if_sxml_writer=>co_opt_indent ).
    reader->next_node( ).
    reader->skip_node( writer ).
    DATA(json_formatted_string) = cl_abap_codepage=>convert_from( CAST cl_sxml_string_writer( writer )->get_output( ) ).

    result = escape( val = json_formatted_string format = cl_abap_format=>e_xml_text  ).

* ---------------------------------------------------------------------
  ENDMETHOD.


  METHOD handle_parse_error.
* ---------------------------------------------------------------------
    error_editor->set_textstream( error ).

* ---------------------------------------------------------------------
  ENDMETHOD.


ENDCLASS.


MODULE pbo_2000 OUTPUT.
* ---------------------------------------------------------------------
  report->pbo_2000( ).

* ---------------------------------------------------------------------
ENDMODULE.


MODULE pai_2000 INPUT.
* ---------------------------------------------------------------------
  report->pai_2000( ).

* ---------------------------------------------------------------------
ENDMODULE.
