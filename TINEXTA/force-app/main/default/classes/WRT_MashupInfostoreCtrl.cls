public without sharing class WRT_MashupInfostoreCtrl {

    public String iframeData {get;set;}
    
    public WRT_MashupInfostoreCtrl() {
        Id RecordId  = ApexPages.currentPage().getParameters().get('id');

        date myDate  = date.today();
        String month = String.valueOf(myDate.month());
        String year  = String.valueOf(myDate.year());
        String day   = String.valueOf(myDate.day());

        String keyIntegrazioneInfoStore = EndpointServizi__c.getInstance().WRN_Key_IntegrazioneInfoStore__c;
        //String endPointIntegrazioneInfoStore = EndpointServizi__c.getInstance().WRN_Url_IntegrazioneInfoStore__c;

        System.debug('SV keyIntegrazioneInfoStore: ' + keyIntegrazioneInfoStore + + year + (month.length() <= 1 ? ('0' + month) : month) + (day.length() <= 1 ? ('0' + day) : day));
        String output = encodingUtil.base64Encode(Blob.valueof(keyIntegrazioneInfoStore + year + (month.length() <= 1 ? ('0' + month) : month) + (day.length() <= 1 ? ('0' + day) : day)));
        System.debug('SV keyIntegrazioneInfoStore Encode: ' + output);

        JWT jwt = new JWT('HS256'); 
        jwt.userEmail = UserInfo.getUserEmail();
        
        jwt.privateKey = output; 
        // jwt.iss = 'your issuer'; 
        // jwt.sub = 'some subject'; 
        // jwt.aud = 'some audience'; 
        String token = jwt.issue();        
        system.debug ('token: '+ token);

        HttpRequest req = new HttpRequest();                            
        req.setEndpoint(EndpointServizi__c.getOrgDefaults().WRT_IFrame_Infostore__c+RecordId);
        // req.setEndpoint('https://putsreq.com/XTQn7WDyrHzb0uSXneQm'); // https://salesforce-test.warranthub.it/api/test	
        req.setMethod('GET');
        req.setHeader('Content-type', 'application/json');
        req.setHeader('Authorization', 'Bearer ' + token);
        //req.setBody(jsonString);

        //Execute web service call here 
        Http http = new Http();               
        HTTPResponse res = http.send(req);

        this.iframeData = res.getBody();
    }

}