CLASS zcl_gen_objects DEFINITION
  PUBLIC FINAL
  CREATE PRIVATE
  GLOBAL FRIENDS zcl_gen_objects_factory.

  PUBLIC SECTION.
    INTERFACES zif_gen_objects.

    METHODS constructor
      IMPORTING calling_object TYPE zif_gen_objects=>calling_object DEFAULT sy-repid.

  PRIVATE SECTION.
    CONSTANTS default_string_length     TYPE i VALUE 32000.
    CONSTANTS default_unit_length       TYPE i VALUE 3.
    CONSTANTS default_currency_length   TYPE i VALUE 15.
    CONSTANTS default_currency_decimals TYPE i VALUE 2.

    DATA calling_object     TYPE zif_gen_objects=>calling_object.
    DATA ddic_configuration TYPE zif_gen_objects=>ddic_configuration.

    "! Set configuration for DDIC
    "! @parameter configuration | DDIC config
    METHODS set_ddic_configuration
      IMPORTING configuration TYPE zif_gen_objects=>ddic_configuration.

    "! Generate all domains
    "! @parameter operation     | Operation
    METHODS generate_domains
      IMPORTING operation TYPE REF TO if_xco_cp_gen_d_o_put.

    "! Generate all data elements
    "! @parameter operation     | Operation
    METHODS generate_data_elements
      IMPORTING operation TYPE REF TO if_xco_cp_gen_d_o_put.

    "! Generate all abstract entities
    "! @parameter operation     | Operation
    METHODS generate_abstract_entities
      IMPORTING operation TYPE REF TO if_xco_cp_gen_d_o_put.
ENDCLASS.


CLASS zcl_gen_objects IMPLEMENTATION.
  METHOD constructor.
    me->calling_object = substring( val = calling_object
                                    len = find( val = calling_object
                                                sub = '=' ) ).
  ENDMETHOD.


  METHOD zif_gen_objects~generate_ddic.
    set_ddic_configuration( ddic_configuration ).

    DATA(put_operation) = xco_cp_generation=>environment->dev_system( me->ddic_configuration-transport )->create_put_operation( ).

    generate_domains( put_operation ).
    generate_data_elements( put_operation ).
    generate_abstract_entities( put_operation ).

    RETURN put_operation->execute( ).
  ENDMETHOD.


  METHOD set_ddic_configuration.
    DATA special_names TYPE RANGE OF string.

    ddic_configuration = configuration.
    special_names = VALUE #( sign   = 'E'
                             option = 'EQ'
                             ( low = zif_gen_objects=>special_types-language )
                             ( low = zif_gen_objects=>special_types-boolean ) ).

    IF ddic_configuration-package IS INITIAL.
      ddic_configuration-package = xco_cp_abap=>class( CONV #( calling_object ) )->if_xco_ar_object~get_package( )->name.
    ENDIF.

    IF ddic_configuration-prefix IS INITIAL.
      RETURN.
    ENDIF.

    LOOP AT ddic_configuration-abstract_entities REFERENCE INTO DATA(entity).
      LOOP AT entity->fields REFERENCE INTO DATA(field) WHERE data_element IN special_names.
        field->data_element = ddic_configuration-prefix && field->data_element.
      ENDLOOP.
    ENDLOOP.

    LOOP AT ddic_configuration-domains REFERENCE INTO DATA(domain) WHERE name IN special_names.
      domain->name = ddic_configuration-prefix && domain->name.
    ENDLOOP.

    LOOP AT ddic_configuration-data_elements REFERENCE INTO DATA(data_element) WHERE name IN special_names.
      data_element->name   = ddic_configuration-prefix && data_element->name.
      data_element->domain = ddic_configuration-prefix && data_element->domain.
    ENDLOOP.
  ENDMETHOD.


  METHOD generate_domains.
    DATA format   TYPE REF TO if_xco_gen_doma_format.
    DATA length   TYPE i.
    DATA decimals TYPE i.

    LOOP AT ddic_configuration-domains INTO DATA(domain).
      DATA(specification) = operation->for-doma->add_object( domain-name
        )->set_package( ddic_configuration-package
        )->create_form_specification( ).

      DATA(description) = COND if_xco_cp_gen_doma_s_form=>tv_short_description( WHEN domain-description IS INITIAL
                                                                                THEN |Domain: { domain-name }|
                                                                                ELSE domain-description ).
      specification->set_short_description( description ).

      CASE domain-base_type.
        WHEN zif_gen_objects=>domain_types-character.
          format = xco_cp_abap_dictionary=>built_in_type->char( CONV #( domain-length ) ).
        WHEN zif_gen_objects=>domain_types-date.
          format = xco_cp_abap_dictionary=>built_in_type->datn.
        WHEN zif_gen_objects=>domain_types-time.
          format = xco_cp_abap_dictionary=>built_in_type->timn.
        WHEN zif_gen_objects=>domain_types-integer.
          format = xco_cp_abap_dictionary=>built_in_type->int4.
        WHEN zif_gen_objects=>domain_types-integer_long.
          format = xco_cp_abap_dictionary=>built_in_type->int8.
        WHEN zif_gen_objects=>domain_types-timestamp.
          format = xco_cp_abap_dictionary=>built_in_type->utclong.
        WHEN zif_gen_objects=>domain_types-currency_code.
          format = xco_cp_abap_dictionary=>built_in_type->cuky.
        WHEN zif_gen_objects=>domain_types-currency.
          length = COND #( WHEN domain-length IS INITIAL
                           THEN default_currency_length
                           ELSE domain-length ).
          decimals = COND #( WHEN domain-decimals IS INITIAL
                             THEN default_currency_decimals
                             ELSE domain-decimals ).
          format = xco_cp_abap_dictionary=>built_in_type->curr( iv_length   = CONV #( length )
                                                                iv_decimals = CONV #( decimals ) ).
        WHEN zif_gen_objects=>domain_types-quantity.
          format = xco_cp_abap_dictionary=>built_in_type->quan( iv_length   = CONV #( domain-length )
                                                                iv_decimals = CONV #( domain-decimals ) ).
        WHEN zif_gen_objects=>domain_types-unit.
          length = COND #( WHEN domain-length IS INITIAL
                           THEN default_unit_length
                           ELSE domain-length ).
          format = xco_cp_abap_dictionary=>built_in_type->unit( CONV #( length ) ).
        WHEN zif_gen_objects=>domain_types-decimals.
          format = xco_cp_abap_dictionary=>built_in_type->dec( iv_length   = CONV #( domain-length )
                                                               iv_decimals = CONV #( domain-decimals ) ).
        WHEN zif_gen_objects=>domain_types-raw.
          format = xco_cp_abap_dictionary=>built_in_type->lraw( CONV #( default_string_length ) ).
        WHEN zif_gen_objects=>domain_types-string.
          format = xco_cp_abap_dictionary=>built_in_type->string( CONV #( default_string_length ) ).
        WHEN zif_gen_objects=>domain_types-short_string.
          format = xco_cp_abap_dictionary=>built_in_type->sstring( CONV #( domain-length ) ).
        WHEN OTHERS.
          CONTINUE.
      ENDCASE.

      specification->set_format( format ).
      specification->output_characteristics->set_case_sensitive( domain-case_sensitive ).
    ENDLOOP.
  ENDMETHOD.


  METHOD generate_data_elements.
    LOOP AT ddic_configuration-data_elements INTO DATA(data_element).
      DATA(specification) = operation->for-dtel->add_object( data_element-name
        )->set_package( ddic_configuration-package
        )->create_form_specification( ).

      DATA(description) = COND if_xco_cp_gen_dtel_s_form=>tv_short_description( WHEN data_element-description IS INITIAL
                                                                                THEN |Data-Element: { data_element-name }|
                                                                                ELSE data_element-description ).

      specification->set_short_description( description ).
      specification->set_data_type( xco_cp_abap_dictionary=>domain( data_element-domain ) ).

      DATA(label) = COND #( WHEN data_element-label IS INITIAL
                            THEN data_element-name
                            ELSE data_element-label ).

      specification->field_label-short->set_text( CONV #( label ) ).
      specification->field_label-medium->set_text( CONV #( label ) ).
      specification->field_label-long->set_text( CONV #( label ) ).
      specification->field_label-heading->set_text( CONV #( label ) ).
    ENDLOOP.
  ENDMETHOD.


  METHOD generate_abstract_entities.
    LOOP AT ddic_configuration-abstract_entities INTO DATA(entity).
      DATA(specification) = operation->for-ddls->add_object( entity-name
        )->set_package( ddic_configuration-package
        )->create_form_specification( ).

      DATA(description) = COND if_xco_cp_gen_dtel_s_form=>tv_short_description( WHEN entity-description IS INITIAL
                                                                                THEN |Entity: { entity-name }|
                                                                                ELSE entity-description ).

      specification->set_short_description( description ).

      DATA(abstract_entity) = specification->add_abstract_entity( ).

      LOOP AT entity-fields INTO DATA(field).
        DATA(cds_field) = abstract_entity->add_field( xco_cp_ddl=>field( field-name )
          )->set_type( xco_cp_abap_dictionary=>data_element( field-data_element ) ).

        IF field-currency IS NOT INITIAL.
          cds_field->add_annotation( 'Semantics.amount.currencyCode' )->value->build( )->add_string( field-currency ).
        ENDIF.

        IF field-unit IS NOT INITIAL.
          cds_field->add_annotation( 'Semantics.quantity.unitOfMeasure' )->value->build( )->add_string( field-unit ).
        ENDIF.
      ENDLOOP.
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.
