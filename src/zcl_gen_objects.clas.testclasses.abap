CLASS ltc_generator DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PRIVATE SECTION.
    METHODS generate_first_artifacts FOR TESTING RAISING cx_static_check.
ENDCLASS.


CLASS ltc_generator IMPLEMENTATION.
  METHOD generate_first_artifacts.
    DATA(abstract_entities) = VALUE zif_gen_objects=>abstract_entities(
        ( name        = 'ZGEN_S_TestGeneratedStructure'
          description = 'Automatic generated'
          fields      = VALUE #( ( name = 'KeyField' data_element = 'KEY_FIELD' )
                                 ( name = 'SalesVolume' data_element = 'AMOUNT' currency = 'SalesCurrency' )
                                 ( name = 'SalesCurrency' data_element = 'CURRENCY' ) ) ) ).

    DATA(data_elements) = VALUE zif_gen_objects=>data_elements(
        ( name = 'KEY_FIELD' domain = 'KEY_FIELD' description = 'Key' )
        ( name = 'AMOUNT' domain = 'AMOUNT' description = 'Amount' )
        ( name = 'CURRENCY' domain = 'CURRENCY' description = 'Currency' ) ).

    DATA(domains) = VALUE zif_gen_objects=>domains(
        ( name = 'KEY_FIELD' base_type = zif_gen_objects=>domain_types-character length = 7 )
        ( name = 'AMOUNT' base_type = zif_gen_objects=>domain_types-currency )
        ( name = 'CURRENCY' base_type = zif_gen_objects=>domain_types-currency_code ) ).

    DATA(config) = VALUE zif_gen_objects=>ddic_configuration( prefix            = 'ZGEN_DEMO_'
                                                              domains           = domains
                                                              data_elements     = data_elements
                                                              abstract_entities = abstract_entities ).

    DATA(generator) = zcl_gen_objects_factory=>create_generator( sy-repid ).
    DATA(result) = generator->generate_ddic( config ).

    cl_abap_unit_assert=>assert_false( result->findings->contain_errors( ) ).
  ENDMETHOD.
ENDCLASS.
