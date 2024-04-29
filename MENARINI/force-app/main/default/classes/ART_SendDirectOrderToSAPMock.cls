global class ART_SendDirectOrderToSAPMock implements WebServiceMock {
    global void doInvoke(
           Object stub,
           Object request,
           Map<String, Object> response,
           String endpoint,
           String soapAction,
           String requestName,
           String responseNS,
           String responseName,
           String responseType) {
        // start - specify the response you want to send
        ART_DirectOrdersWS.DT_SFDC_ORDER_ACKNOWLEDGEMENT response_x = 
            new ART_DirectOrdersWS.DT_SFDC_ORDER_ACKNOWLEDGEMENT();
        response_x.actionCode = '200';
        response_x.message = '';
        // end
        response.put('response_x', response_x); 
   }
}