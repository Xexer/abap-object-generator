INTERFACE zif_gen_objects
  PUBLIC.

  TYPES calling_object TYPE sy-repid.

  TYPES: BEGIN OF domain,
           name           TYPE sxco_ad_object_name,
           description    TYPE if_xco_cp_gen_doma_s_form=>tv_short_description,
           base_type      TYPE string,
           length         TYPE i,
           decimals       TYPE i,
           case_sensitive TYPE abap_boolean,
         END OF domain.
  TYPES domains TYPE STANDARD TABLE OF domain WITH EMPTY KEY.

  TYPES: BEGIN OF data_element,
           name        TYPE sxco_ad_object_name,
           description TYPE if_xco_cp_gen_dtel_s_form=>tv_short_description,
           label       TYPE string,
           domain      TYPE sxco_ad_object_name,
         END OF data_element.
  TYPES data_elements TYPE STANDARD TABLE OF data_element WITH EMPTY KEY.

  TYPES: BEGIN OF field,
           name         TYPE sxco_cds_field_name,
           data_element TYPE sxco_ad_object_name,
           currency     TYPE string,
           unit         TYPE string,
         END OF field.
  TYPES fields TYPE STANDARD TABLE OF field WITH EMPTY KEY.

  TYPES: BEGIN OF abstract_entity,
           name        TYPE sxco_cds_object_name,
           description TYPE if_xco_cp_gen_dtel_s_form=>tv_short_description,
           fields      TYPE fields,
         END OF abstract_entity.
  TYPES abstract_entities TYPE STANDARD TABLE OF abstract_entity WITH EMPTY KEY.

  TYPES: BEGIN OF ddic_configuration,
           package           TYPE sxco_package,
           transport         TYPE sxco_transport,
           prefix            TYPE string,
           domains           TYPE domains,
           data_elements     TYPE data_elements,
           abstract_entities TYPE abstract_entities,
         END OF ddic_configuration.

  CONSTANTS:
    BEGIN OF domain_types,
      character     TYPE string VALUE `CHAR`,
      date          TYPE string VALUE `DATN`,
      time          TYPE string VALUE `TIMN`,
      integer       TYPE string VALUE `INT4`,
      integer_long  TYPE string VALUE `INT8`,
      timestamp     TYPE string VALUE `UTCLONG`,
      currency_code TYPE string VALUE `CUKY`,
      currency      TYPE string VALUE `CURR`,
      quantity      TYPE string VALUE `QUAN`,
      unit          TYPE string VALUE `UNIT`,
      decimals      TYPE string VALUE `DEC`,
      raw           TYPE string VALUE `RAW`,
      string        TYPE string VALUE `STRING`,
      short_string  TYPE string VALUE `SSTRING`,
    END OF domain_types.

  CONSTANTS:
    BEGIN OF special_types,
      language TYPE string VALUE `SPRAS`,
      boolean  TYPE string VALUE `ABAP_BOOLEAN`,
    END OF special_types.

  "! Generate DDIC artifacts via configuration
  "! @parameter ddic_configuration | Configuration
  "! @parameter result             | Generation result
  METHODS generate_ddic
    IMPORTING ddic_configuration TYPE ddic_configuration
    RETURNING VALUE(result)      TYPE REF TO if_xco_gen_o_put_result.
ENDINTERFACE.
