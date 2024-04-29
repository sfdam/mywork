@isTest
private class RedirectUrlTest {
    
    @isTest static void urlCase() {
        Map<String,Object> fullParameters = new Map<String,Object>();
        fullParameters.put('c__sobjectname','Case');
        fullParameters.put('c__cmdtype','BHELP');
        Endpoint__c ep = new Endpoint__c();
        ep.Endpoint__c = 'http://www.test.it?v=2&o=r';
        ep.Name = 'BHELP';
        insert ep;
        Test.startTest();
        RedirectUrlController.getUrlInfo(fullParameters);
        fullParameters.put('c__cmdtype','Account');
        try {
        	RedirectUrlController.getUrlInfo(fullParameters);
        }
        catch(Exception exc) {}
        fullParameters.put('c__sobjectname','Account');
        try {
        	RedirectUrlController.getUrlInfo(fullParameters);
        }
        catch(Exception exc) {}
        Test.stopTest();
    }
}