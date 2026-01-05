CLASS zcl_gen_objects_injector DEFINITION
  PUBLIC ABSTRACT FINAL
  CREATE PUBLIC
  FOR TESTING.

  PUBLIC SECTION.
    CLASS-METHODS inject_generator
      IMPORTING double TYPE REF TO zif_gen_objects OPTIONAL.
ENDCLASS.


CLASS zcl_gen_objects_injector IMPLEMENTATION.
  METHOD inject_generator.
    zcl_gen_objects_factory=>double_generator = double.
  ENDMETHOD.
ENDCLASS.
