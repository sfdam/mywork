//Generated by wsdl2apex

public class AsyncART_DirectOrdersWS {
    public class DT_SFDC_ORDER_ACKNOWLEDGEMENTFuture extends System.WebServiceCalloutFuture {
        public ART_DirectOrdersWS.DT_SFDC_ORDER_ACKNOWLEDGEMENT getValue() {
            ART_DirectOrdersWS.DT_SFDC_ORDER_ACKNOWLEDGEMENT response = (ART_DirectOrdersWS.DT_SFDC_ORDER_ACKNOWLEDGEMENT)System.WebServiceCallout.endInvoke(this);
            return response;
        }
    }
    public class AsyncHTTPS_Port {
        public String endpoint_x = 'https://sappod.menarini.net:50001/XISOAPAdapter/MessageServlet?senderParty=&senderService=BC_SFDC_CG_Test&receiverParty=&receiverService=&interface=SI_SFDC_ORDER_out&interfaceNamespace=urn%3ATHOR_SFDC_CG%3AINT05%28OrderToSap%29';
        public Map<String,String> inputHttpHeaders_x;
        public String clientCertName_x;
        public Integer timeout_x;
        private String[] ns_map_type_info = new String[]{'urn:THOR_SFDC_CG:INT05(OrderToSap)', 'ART_DirectOrdersWS'};
        public AsyncART_DirectOrdersWS.DT_SFDC_ORDER_ACKNOWLEDGEMENTFuture beginSI_SFDC_ORDER_out(System.Continuation continuation,ART_DirectOrdersWS.row_element[] row) {
            ART_DirectOrdersWS.DT_SFDC_ORDER request_x = new ART_DirectOrdersWS.DT_SFDC_ORDER();
            request_x.row = row;
            return (AsyncART_DirectOrdersWS.DT_SFDC_ORDER_ACKNOWLEDGEMENTFuture) System.WebServiceCallout.beginInvoke(
              this,
              request_x,
              AsyncART_DirectOrdersWS.DT_SFDC_ORDER_ACKNOWLEDGEMENTFuture.class,
              continuation,
              new String[]{endpoint_x,
              'http://sap.com/xi/WebService/soap1.1',
              'urn:THOR_SFDC_CG:INT05(OrderToSap)',
              'MT_SFDC_ORDER',
              'urn:THOR_SFDC_CG:INT05(OrderToSap)',
              'MT_SFDC_ORDER_ACKNOWLEDGMENT',
              'ART_DirectOrdersWS.DT_SFDC_ORDER_ACKNOWLEDGEMENT'}
            );
        }
    }
}