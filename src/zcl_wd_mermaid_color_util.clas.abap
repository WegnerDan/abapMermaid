CLASS zcl_wd_mermaid_color_util DEFINITION PUBLIC FINAL CREATE PRIVATE.
  PUBLIC SECTION.
    TYPES:
      BEGIN OF ty_rgb_hex_char_color,
        r TYPE c LENGTH 2,
        g TYPE c LENGTH 2,
        b TYPE c LENGTH 2,
      END OF ty_rgb_hex_char_color,
      BEGIN OF ty_rgb_int_color,
        r TYPE i,
        g TYPE i,
        b TYPE i,
      END OF ty_rgb_int_color,
      BEGIN OF ty_hsl_int_color,
        h TYPE i,
        s TYPE i,
        l TYPE i,
      END OF ty_hsl_int_color.
    CLASS-METHODS:
      convert_gui2hex IMPORTING gui_color     TYPE i
                      RETURNING VALUE(result) TYPE ty_rgb_hex_char_color,
      convert_gui2hex_string IMPORTING gui_color     TYPE i
                             RETURNING VALUE(result) TYPE string,
      convert_hex2rgb IMPORTING hex           TYPE ty_rgb_hex_char_color
                      RETURNING VALUE(result) TYPE ty_rgb_int_color,
      convert_hex2rgb_string IMPORTING hex           TYPE ty_rgb_hex_char_color
                             RETURNING VALUE(result) TYPE string,
      convert_rgb2hex IMPORTING rgb           TYPE ty_rgb_int_color
                      RETURNING VALUE(result) TYPE ty_rgb_hex_char_color,
      convert_rgb2hex_string IMPORTING rgb           TYPE ty_rgb_int_color
                             RETURNING VALUE(result) TYPE string,
      convert_gui2rgb IMPORTING gui_color     TYPE i
                      RETURNING VALUE(result) TYPE ty_rgb_int_color,
      convert_gui2rgb_string IMPORTING gui_color     TYPE i
                             RETURNING VALUE(result) TYPE string,
      convert_rgb2hsl IMPORTING rgb           TYPE ty_rgb_int_color
                      RETURNING VALUE(result) TYPE ty_hsl_int_color,
      convert_rgb2hsl_string IMPORTING rgb           TYPE ty_rgb_int_color
                             RETURNING VALUE(result) TYPE string,
      convert_hsl2rgb IMPORTING hsl           TYPE ty_hsl_int_color
                      RETURNING VALUE(result) TYPE ty_rgb_int_color,
      convert_gui2hsl IMPORTING gui_color     TYPE i
                      RETURNING VALUE(result) TYPE ty_hsl_int_color,
      get_backgrnd_color_hex_str IMPORTING gui_color_id  TYPE i
                                 RETURNING VALUE(result) TYPE string,
      get_foregrnd_color_hex_str IMPORTING gui_color_id  TYPE i
                                 RETURNING VALUE(result) TYPE string.

  PROTECTED SECTION.
  PRIVATE SECTION.
    CLASS-METHODS:
      get_min IMPORTING val_1         TYPE f
                        val_2         TYPE f
              RETURNING VALUE(result) TYPE f,
      get_max IMPORTING val_1         TYPE f
                        val_2         TYPE f
              RETURNING VALUE(result) TYPE f.
ENDCLASS.



CLASS zcl_wd_mermaid_color_util IMPLEMENTATION.

  METHOD convert_gui2hex.
* ---------------------------------------------------------------------
    DATA:
      color_hex  TYPE x LENGTH 3.

* ---------------------------------------------------------------------
    " convert integer value to binary
    color_hex = gui_color.

    " reverse byte order
    result-r = color_hex+2(1).
    result-g = color_hex+1(1).
    result-b = color_hex+0(1).

* ---------------------------------------------------------------------
  ENDMETHOD.


  METHOD convert_gui2hex_string.
* ---------------------------------------------------------------------
    DATA hex TYPE string.
    hex = convert_gui2hex( gui_color ).
    CONCATENATE '#' hex INTO result.
    CONDENSE result NO-GAPS.

* ---------------------------------------------------------------------
  ENDMETHOD.


  METHOD convert_hex2rgb.
* ---------------------------------------------------------------------
    DATA temp_x TYPE x LENGTH 1.

* ---------------------------------------------------------------------
    result-r = temp_x = hex-r.
    result-g = temp_x = hex-g.
    result-b = temp_x = hex-b.

* ---------------------------------------------------------------------
  ENDMETHOD.


  METHOD convert_rgb2hex.
* ---------------------------------------------------------------------
    DATA temp_x TYPE x LENGTH 1.

* ---------------------------------------------------------------------
    result-r = temp_x = rgb-r.
    result-g = temp_x = rgb-g.
    result-b = temp_x = rgb-b.

* ---------------------------------------------------------------------
  ENDMETHOD.


  METHOD convert_rgb2hex_string.
* ---------------------------------------------------------------------
    DATA hex TYPE string.
    hex = convert_rgb2hex( rgb ).
    CONCATENATE '#' hex INTO result.
    CONDENSE result NO-GAPS.

* ---------------------------------------------------------------------
  ENDMETHOD.


  METHOD convert_hex2rgb_string.
* ---------------------------------------------------------------------
    DATA: temp_rgb TYPE ty_rgb_int_color,
          temp_r   TYPE string,
          temp_g   TYPE string,
          temp_b   TYPE string.

* ---------------------------------------------------------------------
    temp_rgb = convert_hex2rgb( hex ).
    temp_r = temp_rgb-r.
    temp_g = temp_rgb-g.
    temp_b = temp_rgb-b.
    CONCATENATE 'RGB(' temp_r ',' temp_g ',' temp_b ')' INTO result.
    CONDENSE result NO-GAPS.

* ---------------------------------------------------------------------
  ENDMETHOD.


  METHOD convert_gui2rgb.
* ---------------------------------------------------------------------
    DATA temp_hex TYPE ty_rgb_hex_char_color.

* ---------------------------------------------------------------------
    temp_hex = convert_gui2hex( gui_color ).
    result = convert_hex2rgb( temp_hex ).

* ---------------------------------------------------------------------
  ENDMETHOD.


  METHOD convert_gui2rgb_string.
* ---------------------------------------------------------------------
    DATA temp_hex TYPE ty_rgb_hex_char_color.

* ---------------------------------------------------------------------
    temp_hex = convert_gui2hex( gui_color ).
    result = convert_hex2rgb_string( temp_hex ).

* ---------------------------------------------------------------------
  ENDMETHOD.


  METHOD convert_rgb2hsl.
* ---------------------------------------------------------------------
    DATA: r     TYPE f,
          g     TYPE f,
          b     TYPE f,
          min   TYPE f,
          max   TYPE f,
          delta TYPE f,
          h     TYPE f,
          s     TYPE f,
          l     TYPE f.

* ---------------------------------------------------------------------
    r = rgb-r / 255.
    g = rgb-g / 255.
    b = rgb-b / 255.
    min = get_min( val_1 = r
                   val_2 = g ).
    min = get_min( val_1 = min
                   val_2 = b ).
    max = get_max( val_1 = r
                   val_2 = g ).
    max = get_max( val_1 = max
                   val_2 = b ).

    delta = max - min.

    l = ( max + min ) / 2.

    IF delta <> 0.
      IF l < '0.5'.
        s = delta / ( max + min ).
      ELSE.
        s = delta / ( 2 - max - min ).
      ENDIF.

      IF r = max.
        h = ( g - b ) / delta.
      ELSEIF g = max.
        h = 2 + ( b - r ) / delta.
      ELSEIF b = max.
        h = 4 + ( r - g ) / delta.
      ENDIF.
    ENDIF.

* ---------------------------------------------------------------------
    result-h = h * 60.
    IF result-h < 0.
      result-h = 360.
    ENDIF.
    result-s = s * 100.
    result-l = l * 100.

* ---------------------------------------------------------------------
  ENDMETHOD.


  METHOD convert_rgb2hsl_string.
* ---------------------------------------------------------------------
    DATA: temp_hsl TYPE ty_hsl_int_color,
          temp_h   TYPE string,
          temp_s   TYPE string,
          temp_l   TYPE string.

* ---------------------------------------------------------------------
    temp_hsl = convert_rgb2hsl( rgb ).
    temp_h = temp_hsl-h.
    temp_s = temp_hsl-s.
    temp_l = temp_hsl-l.
    CONCATENATE 'HSL(' temp_h ',' temp_s '%,' temp_l '%)' INTO result.
    CONDENSE result NO-GAPS.

* ---------------------------------------------------------------------
  ENDMETHOD.


  METHOD convert_hsl2rgb.
* ---------------------------------------------------------------------
    DATA: temp1 TYPE f,
          temp2 TYPE f,
          h     TYPE f,
          s     TYPE f,
          l     TYPE f,
          r     TYPE f,
          g     TYPE f,
          b     TYPE f.
    FIELD-SYMBOLS: <color> TYPE f.

* ---------------------------------------------------------------------
    IF hsl-s = 0.
      result-r = hsl-l.
      result-g = hsl-l.
      result-b = hsl-l.
      RETURN.
    ENDIF.

* ---------------------------------------------------------------------
    h = hsl-h / 360.
    s = hsl-s / 100.
    l = hsl-l / 100.

* ---------------------------------------------------------------------
    IF hsl-l < '0.5'.
      temp2 = l * ( 1 + s ).
    ELSE.
      temp2 = ( l + s ) - ( l * s ).
    ENDIF.

* ---------------------------------------------------------------------
    temp1 = ( 2 * l ) - temp2.

* ---------------------------------------------------------------------
    r = h + ( 1 / 3 ).
    g = h.
    b = h - ( 1 / 3 ).

* ---------------------------------------------------------------------
    DO 3 TIMES.
      CASE sy-index.
        WHEN 1.
          ASSIGN r TO <color>.
        WHEN 2.
          ASSIGN g TO <color>.
        WHEN 3.
          ASSIGN b TO <color>.
      ENDCASE.

      IF <color> < 0.
        <color> = <color> + 1.
      ENDIF.
      IF <color> > 1.
        <color> = <color> - 1.
      ENDIF.

      IF ( 6 * <color> ) < 1.
        <color> = temp1 + ( temp2 - temp1 ) * 6 * <color>.
      ELSEIF ( 2 * <color> ) < 1.
        <color> = temp2.
      ELSEIF ( 3 * <color> ) < 2.
        <color> = temp1 + ( temp2 - temp1 ) * ( ( 2 / 3 ) - <color> ) * 6.
      ELSE.
        <color> = temp1.
      ENDIF.
    ENDDO.

* ---------------------------------------------------------------------
    result-r = r * 100.
    result-g = g * 100.
    result-b = b * 100.

* ---------------------------------------------------------------------
  ENDMETHOD.


  METHOD convert_gui2hsl.
* ---------------------------------------------------------------------
    DATA: temp_rgb TYPE ty_rgb_int_color.

* ---------------------------------------------------------------------
    temp_rgb = convert_gui2rgb( gui_color ).
    result = convert_rgb2hsl( temp_rgb ).

* ---------------------------------------------------------------------
  ENDMETHOD.


  METHOD get_backgrnd_color_hex_str.
* ---------------------------------------------------------------------
    cl_gui_resources=>get_background_color( EXPORTING  id     = gui_color_id
                                                       state  = 0
                                            IMPORTING  color  = DATA(gui_color)
                                            EXCEPTIONS OTHERS = 1 ).
    IF sy-subrc = 0.
      result = convert_gui2hex_string( gui_color ).
    ENDIF.

* ---------------------------------------------------------------------
  ENDMETHOD.


  METHOD get_foregrnd_color_hex_str.
* ---------------------------------------------------------------------
    cl_gui_resources=>get_foreground_color( EXPORTING  id     = gui_color_id
                                                       state  = 0
                                            IMPORTING  color  = DATA(gui_color)
                                            EXCEPTIONS OTHERS = 1 ).
    IF sy-subrc = 0.
      result = convert_gui2hex_string( gui_color ).
    ENDIF.

* ---------------------------------------------------------------------
  ENDMETHOD.


  METHOD get_min.
* ---------------------------------------------------------------------
    DATA values TYPE TABLE OF f.

* ---------------------------------------------------------------------
    APPEND val_1 TO values.
    APPEND val_2 TO values.
    SORT values BY table_line ASCENDING.
    READ TABLE values INTO result INDEX 1.

* ---------------------------------------------------------------------
  ENDMETHOD.


  METHOD get_max.
* ---------------------------------------------------------------------
    DATA values TYPE TABLE OF f.

* ---------------------------------------------------------------------
    APPEND val_1 TO values.
    APPEND val_2 TO values.
    SORT values BY table_line DESCENDING.
    READ TABLE values INTO result INDEX 1.

* ---------------------------------------------------------------------
  ENDMETHOD.

ENDCLASS.
