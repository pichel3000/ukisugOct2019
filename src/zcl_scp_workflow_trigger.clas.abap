class ZCL_SCP_WORKFLOW_TRIGGER definition
  public
  final
  create public .

public section.

  methods CONSTRUCTOR .
  methods TRIGGER_OAUTH_WF
    importing
      !I_VBELN type VBELN_VA
      !I_POSNR type POSNR
      !I_BMENG type BMENG
      !I_EDATU type EDATU .
protected section.
private section.
ENDCLASS.



CLASS ZCL_SCP_WORKFLOW_TRIGGER IMPLEMENTATION.


  method CONSTRUCTOR.
  endmethod.


  METHOD trigger_oauth_wf.


    DATA: lo_client_oauth TYPE REF TO if_http_client,
          lo_client_wfapi TYPE REF TO if_http_client,
          content         TYPE string,
          xmlstring       TYPE string,
          lv_status       TYPE string,
          lv_code         TYPE i,
          oauth           TYPE string,
          rest            TYPE string,
          subrc           TYPE sy-subrc,
          errortext       TYPE string,
          gv_body         TYPE string,
          i_quantity  type string .
* create oAuth object using destination
    cl_http_client=>create_by_destination( EXPORTING destination = 'SCP_OAUTH_NT'         " SCP OAUTH destination
                                           IMPORTING client      = lo_client_oauth ).
    IF sy-subrc <> 0.
      MESSAGE e001(zmsg_mk) WITH 'Could not create HTTP client. SY-SUB: ' sy-subrc.
    ENDIF.

    lo_client_oauth->request->set_header_field( name  = '~request_method' value = 'POST' ).
    lo_client_oauth->request->set_form_field( name  = 'grant_type' value = 'client_credentials' ).
    lo_client_oauth->request->set_header_field( name = '~request_uri' value = '/api/v1/token' ).

    lo_client_oauth->send( ).
    lo_client_oauth->receive( ).

    IF sy-subrc <> 0.
      lo_client_oauth->get_last_error( IMPORTING code    = subrc
                                                 message = errortext ).
      MESSAGE e001(zmsg_mk) WITH 'communication_error( receive token ): code ' sy-subrc ' - message: ' errortext.
    ENDIF.

    content = lo_client_oauth->response->get_cdata( ).
    lo_client_oauth->response->get_status( IMPORTING code = lv_code reason = lv_status ).
    SPLIT content AT '"access_token":"' INTO rest content.
    SPLIT content AT '"' INTO oauth rest.

    cl_http_client=>create_by_destination( EXPORTING destination = 'SCP_WF'           " SCP workflow destination
                                           IMPORTING client      = lo_client_wfapi ).
    IF sy-subrc <> 0.
      MESSAGE e001(zmsg_mk) WITH 'Could not create WF API destination. Code ' sy-subrc.
    ENDIF.

    lo_client_wfapi->request->set_header_field( name  = '~request_method' value = 'POST' ).
    lo_client_wfapi->request->set_header_field( name  = '~request_uri' value = '/workflow-instances' ).
*     CONCATENATE '{ "definitionId": "myfirstworkflow", "context": { "title": "ABAP_' sy-datum '_' sy-uzeit '", "field1": "' sy-datum '-' sy-uzeit '" } }' INTO gv_body.
*    gv_body = '{ "definitionId": "testworkflow", "context": { "title": "ABAP SD book", "price": "79" } }'.

    i_quantity =  i_bmeng.

    CONCATENATE '{ "definitionId": "myworkflowpoc", "context": { "user": "S0015222409", "SalesOrder": " ' i_vbeln ' ", "DelDate": " ' i_edatu ' " , "Quantity": " '   i_quantity ' " , "Item": " ' i_posnr ' "} }' INTO gv_body.


    lo_client_wfapi->request->set_header_field( name = 'Content-Type' value = 'application/json' ).
    lo_client_wfapi->request->set_cdata( data = gv_body ).
    lo_client_wfapi->request->set_header_field( name  = 'Authorization' value = |Bearer { oauth }| ).

    lo_client_wfapi->send( ).
    lo_client_wfapi->receive( ).

    IF sy-subrc <> 0.
      lo_client_wfapi->get_last_error( IMPORTING code    = subrc
                                                 message = errortext ).
      MESSAGE e001(zmsg_mk) WITH 'communication_error( receive API ): code ' sy-subrc ' - message: ' errortext.
    ENDIF.

    content = lo_client_wfapi->response->get_cdata( ).
    WRITE:/ content.
    lo_client_wfapi->close( ).
  ENDMETHOD.
ENDCLASS.
