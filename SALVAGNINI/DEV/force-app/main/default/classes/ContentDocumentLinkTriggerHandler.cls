public with sharing class ContentDocumentLinkTriggerHandler {
    
    public static void prepareFilesForSP (List<ContentDocumentLink> triggerNew){
        List<String> DocIdList = new List<String>();
        List<String> QuoteIdList = new List<String>();
        //TEST, verrà rimosso e bulkificato
        ContentDocumentLink cdlTest = new ContentDocumentLink();
        for(ContentDocumentLink CDL : triggerNew){
            system.debug ('@@@ LinkEntityId: '+ CDL.LinkedEntityId);
            if(string.valueof(CDL.LinkedEntityId).startsWith('a2T')){
                DocIdList.add(CDL.Id);
                QuoteIdList.add(CDL.LinkedEntityId);
                cdlTest = CDL;
            }
        }
        if(cdlTest != null && cdlTest != new ContentDocumentLink()){
            system.debug('cdlTest.LinkedEntityId '+cdlTest.LinkedEntityId);
            system.debug('cdlTest.ContentDocumentId '+cdlTest.ContentDocumentId);
            sendFileToSP(cdlTest.LinkedEntityId, cdlTest.ContentDocumentId);
        }   
    }
    @future(callout =true)
    public static void sendFileToSP (string QuoteId, string CVid){
        
        //Provo a chiamare il servizio di autenticazione
        string token = SharepointHandler.AuthSP();
        if(token != 'ERROR'){
            //Inserisco su SP
            HttpRequest request = new HttpRequest();
            Sharepoint_Endpoints__mdt endpoints = [SELECT ClientId_PRD__c,ClientId_SDX__c,ClientSecret_PRD__c,ClientSecret_SDX__c, Endpoint_SEND_FILE_SDX__c, Endpoint_SEND_FILE_PRD__c, Endpoint_Create_item_PRD__c,Endpoint_Create_item_SDX__c,Endpoint_login_PRD__c,Endpoint_login_SDX__c,Resource_PRD__c,Resource_SDX__c,TenantId_PRD__c,TenantId_SDX__c FROM Sharepoint_Endpoints__mdt LIMIT 1];
            //Setto gli entpoints in base a se siamo in sandbox o no
            SBQQ__Quote__c parentQuote = [SELECT Id,Name,SBQQ__Account__r.CRM_Code__c,SBQQ__Opportunity2__r.Sharepoint_Id__c,Quote_Id_Custom__c, SBQQ__Type__c, SBQQ__Source__r.SBQQ__Account__r.CRM_Code__c, SBQQ__Source__r.SBQQ__Opportunity2__r.Sharepoint_Id__c, SBQQ__Source__r.Name  FROM SBQQ__Quote__c WHERE Id = :QuoteId];
            ContentVersion CV = [SELECT Id,PathOnClient , VersionData FROM ContentVersion where ContentDocumentId = :CVid];
            
            
            String endpoint = ([Select IsSandbox from Organization limit 1].isSandbox) ? endpoints.Endpoint_SEND_FILE_SDX__c : endpoints.Endpoint_SEND_FILE_PRD__c;
            //Dall'endpoint, vanno sostituiti alcuni placeholder
            //PH_01 - {!crmCode} => Quote.SBQQ__Account__r.CRM_Code__c
            endpoint = endpoint.replace('{!crmCode}', (parentQuote.SBQQ__Type__c != 'Amendment') ? parentQuote.SBQQ__Account__r.CRM_Code__c : parentQuote.SBQQ__Source__r.SBQQ__Account__r.CRM_Code__c);
            //PH_02 - {!spId} => Quote.SBQQ__Opportunity2__r.Sharepoint_Id__c
            endpoint = endpoint.replace('{!spId}', (parentQuote.SBQQ__Type__c != 'Amendment') ? parentQuote.SBQQ__Opportunity2__r.Sharepoint_Id__c : parentQuote.SBQQ__Source__r.SBQQ__Opportunity2__r.Sharepoint_Id__c);
            //PH_03 - {!quoteName} => Quote.Name
            endpoint = endpoint.replace('{!quoteName}', (parentQuote.SBQQ__Type__c != 'Amendment') ? parentQuote.Name : parentQuote.SBQQ__Source__r.Name);
            //PH_04 - {!pathOnClient} => CV.PathOnClient
            endpoint = endpoint.replace('{!pathOnClient}', CV.PathOnClient);
            //https://salvagninigroup.sharepoint.com/sites/SGSalesDocsTS/2022/_api/web/lists/GetByTitle('SAL')/rootfolder/folders('{!crmCode}')/folders('{!spId}')/folders('{!quoteName}')/files/add(url='{!pathOnClient}',overwrite=true)
            
            //request.setEndpoint('https://salvagninigroup.sharepoint.com/sites/SGSalesDocsTS/2022/_api/web/lists/GetByTitle(\'SAL\')/rootfolder/folders(\''+parentQuote.SBQQ__Account__r.CRM_Code__c+'\')/folders(\''+parentQuote.SBQQ__Opportunity2__r.Sharepoint_Id__c+'\')/folders(\''+parentQuote.Name+'\')/files/add(url=\''+CV.PathOnClient+'\',overwrite=true)');
            request.setEndpoint(endpoint);
            //Costruisco la chiamata
            request.setMethod('POST');
            request.setHeader('Authorization', 'Bearer ' + token);
            request.setHeader('Accept', 'application/json;odata=verbose');
            
            blob bodyBlob = CV.VersionData;
            request.setBodyasBlob(bodyBlob);
            HttpResponse response = new Http().send(request);
            system.debug('request '+request);
            system.debug('response '+response.getBody());
        } 
        else{
            system.debug('ERRORE AUTENTICAZIONE, QUOTE NON CREATE SU SP');
        }
    }
}