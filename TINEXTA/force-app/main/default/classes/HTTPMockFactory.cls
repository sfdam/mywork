@isTest
global class HTTPMockFactory implements HttpCalloutMock{
  protected Integer code;
  protected String status;
  protected String body;
  protected Map<String, String> responseHeaders;
  public HTTPMockFactory(Integer code, String status, String body, Map<String, String> responseHeaders) {
    this.code = code;
    this.status = status;
    this.body = body;
    this.responseHeaders = responseHeaders;
  }
  public HttpMockFactory(){
    this.code = 200;
    this.status = 'OK';
    this.body = '{}';
    this.responseHeaders = new Map<String,String>();
  }

  public HTTPResponse respond(HTTPRequest req) {
    HttpResponse res = new HttpResponse();
      if(req.getEndpoint()== EndpointServizi__c.getInstance().WRN_Url_IntegrazioneInfoStore__c){
          res.setHeader('Content-type', 'application/json');
          res.setBody('{"success":true,"message":"Created","data":{"Opportunity":{"Numero_offerta_Infostore__c":10}}}');
          res.setStatusCode(200);
          res.setStatus('OK');
      }else if(req.getEndpoint()== EndpointServizi__c.getInstance().WRT_SharePoint_Create_Folder_Opportunity__c)  {
           res.setHeader('Content-type', 'application/json');
          res.setBody('{"CreatedFolders":["https://warrantgroupsrl.sharepoint.com/sites/ArchivedOldRoot/sandbox/TXT00144024TEST_SPx1803x010011X00000U7ncCQAR/OPPORTUNITY/0061X00000A2VQLQA3"]}');
          res.setStatusCode(200);
          res.setStatus('OK');
      }else if(req.getEndpoint() == EndpointServizi__c.getInstance().WRT_Create_CPQ_Infostore__c){
          res.setHeader('Content-type', 'application/json');
          if(this.body != null)
            res.setBody(this.body);
          else
            res.setBody('{ "data": { "Quote": { "Numero_offerta_Infostore__c": "test2", "WRT_Link_offerta_Infostore__c": "https://test2", "LineItems": [{ "Id": "", "Numero_offerta_Infostore__c": "test2", "WRT_Link_offerta_Infostore__c": "https://test2"}]} }, "success": true, "message": "" }');
          
            res.setStatusCode(200);
          res.setStatus('OK');
      } else if(EndpointServizi__c.getInstance().WRT_IFrame_Infostore__c != null && req.getEndpoint().contains(EndpointServizi__c.getInstance().WRT_IFrame_Infostore__c)){
        res.setHeader('Content-type', 'text/html');
        res.setBody('<div>Test</div>');
        res.setStatusCode(200);
        res.setStatus('OK');
      } else if(EndpointServizi__c.getInstance().WRT_Elimina_Pagamenti_CPQ_Infostore__c != null && req.getEndpoint().contains(EndpointServizi__c.getInstance().WRT_Elimina_Pagamenti_CPQ_Infostore__c)){
        res.setHeader('Content-type', 'application/json');
        res.setBody('{ "data": {}, "success": true, "message": "" }');
        res.setStatusCode(200);
        res.setStatus('OK');
      } else if(EndpointServizi__c.getInstance().WRT_Elimina_Condizioni_CPQ_Infostore__c != null && req.getEndpoint().contains(EndpointServizi__c.getInstance().WRT_Elimina_Condizioni_CPQ_Infostore__c)){
        res.setHeader('Content-type', 'application/json');
        res.setBody('{ "data": {}, "success": true, "message": "" }');
        res.setStatusCode(200);
        res.setStatus('OK');
      } else if(req.getEndpoint() == EndpointServizi__c.getInstance().WRT_Elimina_Bulk_Pricing__c){
        res.setHeader('Content-type', 'application/json');
        res.setBody('{ "data": {}, "success": true, "message": "" }');
        res.setStatusCode(200);
        res.setStatus('OK');
      }
      else{
            for (String key : this.responseHeaders.keySet()) {
      			res.setHeader(key, this.responseHeaders.get(key));
    		}
    		res.setBody(this.body);
    		res.setStatusCode(this.code);
    		res.setStatus(this.status);
    		
      }
      return res;
  }
}