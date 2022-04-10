*&---------------------------------------------------------------------*
*& Report zwd_mermaid_sample_1
*&---------------------------------------------------------------------*
*&  Simple usage sample
*&---------------------------------------------------------------------*
REPORT zwd_mermaid_sample_1.

TRY.
    DATA(diagram) = NEW zcl_wd_gui_mermaid_js_diagram( parent = cl_gui_container=>screen0 ).
    diagram->set_source_code_string(    |graph TD\n|
                                     && |A[Client] --> B[Load Balancer]\n|
                                     && |B --> C[Server01]\n|
                                     && |B --> D[Server02]\n| ).
    diagram->display( ).
    WRITE ''. " force output of screen0
  CATCH zcx_wd_gui_mermaid_js_diagram INTO DATA(error).
    MESSAGE error TYPE 'E'.
ENDTRY.
