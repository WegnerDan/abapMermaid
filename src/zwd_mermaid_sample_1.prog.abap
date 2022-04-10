*&---------------------------------------------------------------------*
*& Report zwd_mermaid_sample_1
*&---------------------------------------------------------------------*
*&  Simple usage sample
*&---------------------------------------------------------------------*
REPORT zwd_mermaid_sample_1.

TRY.
    DATA(diagram) = NEW zcl_wd_gui_mermaid_js_diagram( parent = cl_gui_container=>default_screen ).
    diagram->set_source_code_string(    |graph TD\n|
                                     && |A[Client] --> B[Load Balancer]\n|
                                     && |B --> C[Server01]\n|
                                     && |B --> D[Server02]\n| ).
    diagram->display( ).
    cl_abap_list_layout=>suppress_toolbar( ).
    WRITE ''. " force output of cl_gui_container=>default_screen
  CATCH zcx_wd_gui_mermaid_js_diagram INTO DATA(error).
    MESSAGE error TYPE 'E'.
ENDTRY.
