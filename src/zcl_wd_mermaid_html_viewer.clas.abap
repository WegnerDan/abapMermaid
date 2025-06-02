CLASS zcl_wd_mermaid_html_viewer DEFINITION
  PUBLIC
  INHERITING FROM cl_gui_html_viewer
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS:
      dispatch REDEFINITION.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_wd_mermaid_html_viewer IMPLEMENTATION.
  METHOD dispatch.
    super->dispatch( EXPORTING  cargo             = cargo
                                eventid           = eventid
                                is_shellevent     = is_shellevent
                                is_systemdispatch = is_systemdispatch
                     EXCEPTIONS cntl_error        = 1
                                OTHERS            = 2 ).
    " ignore exceptions
  ENDMETHOD.
ENDCLASS.
