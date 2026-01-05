CLASS zcl_gen_objects_factory DEFINITION
  PUBLIC ABSTRACT FINAL
  CREATE PUBLIC
  GLOBAL FRIENDS zcl_gen_objects_injector.

  PUBLIC SECTION.
    CLASS-METHODS create_generator
      IMPORTING calling_object TYPE zif_gen_objects=>calling_object
      RETURNING VALUE(result)  TYPE REF TO zif_gen_objects.

  PRIVATE SECTION.
    CLASS-DATA double_generator TYPE REF TO zif_gen_objects.
ENDCLASS.


CLASS zcl_gen_objects_factory IMPLEMENTATION.
  METHOD create_generator.
    IF double_generator IS BOUND.
      RETURN double_generator.
    ELSE.
      RETURN NEW zcl_gen_objects( calling_object ).
    ENDIF.
  ENDMETHOD.
ENDCLASS.
