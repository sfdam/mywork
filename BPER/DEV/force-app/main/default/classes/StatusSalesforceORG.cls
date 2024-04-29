public with sharing class StatusSalesforceORG {
    
    @AuraEnabled(cacheable=true)
    public static Organization getOrgInfo(){
        System.debug('SV getOrgInfo ');

        return [ Select InstanceName from Organization ];

    }

    @AuraEnabled
    public static String getOrgStatus(String istanceName){
        System.debug('SV getOrgStatus istanceName: ' + istanceName);

        String endpoint = 'https://api.status.salesforce.com/v1/incidents';
        String method = 'GET';
        Decimal timeout = 20000;
        DateTime todaysDate = System.today();
        String todaysDateStr = todaysDate.format('yyyy-MM-dd');

        Http h = new Http();
        
        HttpRequest req = new HttpRequest();
        req.setHeader('Content-Type', 'application/json;charset=UTF-8');
        req.setEndpoint(endpoint + '?limit=10000&locale=it&instance=' + istanceName + '&startTime=' + todaysDateStr);
        req.setMethod('GET');
        
        
        // Send the request, and return a response
        HttpResponse res = h.send(req);

        return res.getBody();

    }
}