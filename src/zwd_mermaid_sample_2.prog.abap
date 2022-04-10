*&---------------------------------------------------------------------*
*& Report zwd_mermaid_sample_2
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zwd_mermaid_sample_2.

CLASS lcl_report DEFINITION.
  PUBLIC SECTION.
    CLASS-DATA:
      fcode TYPE sy-ucomm.
    METHODS:
      run,
      pbo_2000 RAISING zcx_wd_gui_mermaid_js_diagram,
      pai_2000.
  PRIVATE SECTION.
    DATA:
      diagram_source_codes TYPE TABLE OF string,
      last_index           TYPE i,
      diagram_index        TYPE i,
      diagram_container    TYPE REF TO cl_gui_custom_container,
      diagram              TYPE REF TO zcl_wd_gui_mermaid_js_diagram.
ENDCLASS.

DATA report TYPE REF TO lcl_report.



INITIALIZATION.
  report = NEW #( ).


START-OF-SELECTION.
  report->run( ).



CLASS lcl_report IMPLEMENTATION.

  METHOD run.
* ---------------------------------------------------------------------
    CONSTANTS:
      crlf LIKE cl_abap_char_utilities=>cr_lf VALUE cl_abap_char_utilities=>cr_lf.

* ---------------------------------------------------------------------
    diagram_source_codes = VALUE #(
        (    `graph TD                      ` && crlf
          && `A[Client] --> B[Load Balancer]` && crlf
          && `B --> C[Server01]             ` && crlf
          && `B --> D[Server02]             ` )
        (    `erDiagram                                           ` && crlf
          && `          CUSTOMER }|..|{ DELIVERY-ADDRESS : has    ` && crlf
          && `          CUSTOMER ||--o{ ORDER : places            ` && crlf
          && `          CUSTOMER ||--o{ INVOICE : "liable for"    ` && crlf
          && `          DELIVERY-ADDRESS ||--o{ ORDER : receives  ` && crlf
          && `          INVOICE ||--|{ ORDER : covers             ` && crlf
          && `          ORDER ||--|{ ORDER-ITEM : includes        ` && crlf
          && `          PRODUCT-CATEGORY ||--|{ PRODUCT : contains` && crlf
          && `          PRODUCT ||--o{ ORDER-ITEM : "ordered in"  ` )
        (    `pie title Pets adopted by volunteers` && crlf
          && `    "Dogs" : 386` && crlf
          && `    "Cats" : 85` && crlf
          && `    "Rats" : 15` && crlf
          && `` )
    ).
    diagram_index = 1.
    CALL SCREEN '2000'.

* ---------------------------------------------------------------------
  ENDMETHOD.


  METHOD pbo_2000.
* ---------------------------------------------------------------------
    SET PF-STATUS 'STATUS_2000'.
    DATA(diagram_index_str) = condense( CONV string( diagram_index ) ).
    SET TITLEBAR 'TITLE_2000' WITH diagram_index_str.

* ---------------------------------------------------------------------
    IF diagram_container IS NOT BOUND.
      diagram_container = NEW #( container_name = 'CUSTOM_CONTROL_1' ).
      diagram = NEW #( parent = diagram_container ).
    ENDIF.

* ---------------------------------------------------------------------
    IF last_index <> diagram_index.
      last_index = diagram_index.
      diagram->set_source_code_string( diagram_source_codes[ diagram_index ] ).
    ENDIF.

* ---------------------------------------------------------------------
    diagram->display( ).

* ---------------------------------------------------------------------
  ENDMETHOD.


  METHOD pai_2000.
* ---------------------------------------------------------------------
    CASE fcode.
      WHEN 'BACK' OR 'EXIT'.
        LEAVE TO SCREEN 0.
      WHEN 'PREV_DIA'.
        IF diagram_index = 1.
          diagram_index = lines( diagram_source_codes ).
        ELSE.
          diagram_index = diagram_index - 1.
        ENDIF.
      WHEN 'NEXT_DIA'.
        IF diagram_index = lines( diagram_source_codes ).
          diagram_index = 1.
        ELSE.
          diagram_index = diagram_index + 1.
        ENDIF.
    ENDCASE.

* ---------------------------------------------------------------------
  ENDMETHOD.


ENDCLASS.



MODULE pbo_2000 OUTPUT.
* ---------------------------------------------------------------------
  TRY.
      report->pbo_2000( ).
    CATCH zcx_wd_gui_mermaid_js_diagram INTO DATA(diagram_error).
      MESSAGE diagram_error TYPE 'E'.
  ENDTRY.

* ---------------------------------------------------------------------
ENDMODULE.


MODULE pai_2000 INPUT.
* ---------------------------------------------------------------------
  report->pai_2000( ).

* ---------------------------------------------------------------------
ENDMODULE.
