public class SharepointHandler { 
    
    public static void UpdateSharepointLink (Map<Id,SER__c> triggerNewMap, Map<Id,SER__c> triggerOldMap){
        List<Ser__c> sers = new List<Ser__c>();
        //Ciclo SER in triggerNew
        for(Id SER_ID : triggerNewMap.keySet()){
            //Prendo solo i SER con Acc o Opp cambiate
            system.debug('SERACCOUNT:: '+triggerNewMap.get(SER_ID).Account__c);
            system.debug('SERAPPLICATION:: '+triggerNewMap.get(SER_ID).Application_Branch__c);
            if(triggerNewMap.get(SER_ID).Account__c != triggerOldMap.get(SER_ID).Account__c || triggerNewMap.get(SER_ID).Opportunity__c != triggerOldMap.get(SER_ID).Opportunity__c){
                sers.add(triggerNewMap.get(SER_ID));
            }
        }
        if(sers != null && sers.size() > 0){
            for(SER__c singleSer : sers){
                singleSer.Sharepoint_Link__c = singleSer.Account__c+'/'+singleSer.Opportunity__c+'/'+singleSer.Id+'/';
                system.debug('UPDATED LINK:: '+singleSer.Sharepoint_Link__c);
            }
           //update sers;
        }
        
    }
    //Metodo che prende le SER e le manda a SP
    public static void sendSERtoSharepoint (Map<Id,SER__c> triggerNewMap, Map<Id,SER__c> triggerOldMap){
        List<Id> serIds = new List<Id>();
        //Ciclo SER in triggerNew
        for(Id SER_ID : triggerNewMap.keySet()){
            //Prendo solo i SER con application branch passato a popolato
            system.debug('SERACCOUNT:: '+triggerNewMap.get(SER_ID).Account__c);
            system.debug('SERAPPLICATION:: '+triggerNewMap.get(SER_ID).Application_Branch__c);
            if(triggerNewMap.get(SER_ID).Application_Branch__c != null && triggerOldMap.get(SER_ID).Application_Branch__c == null){
                serIds.add(SER_ID);
            }
        }
        List<Ser__c> serToSend = [SELECT Id,Opportunity__r.Sharepoint_Id__c, createddate,Account__c,Opportunity__c,createdBy.Email,Application_Branch__r.Name,SER_Type__c,Country__c,SER_Id_custom__c,Account__r.Name,Account__r.CRM_Code__c FROM SER__c WHERE Id IN :serIds];
        if(serToSend != null && serToSend.size() > 0){
            List<serItem> serItemList = new List<serItem>();
            for(SER__c singleSer : serToSend){
                serItem serItemToSend = new serItem(singleSer.createddate.year(),singleSer.Account__c,singleSer.Opportunity__r.Sharepoint_Id__c,singleSer.Id,singleSer.createdBy.Email, singleSer.Application_Branch__r.Name,singleSer.SER_Type__c, singleSer.Country__c, singleSer.Account__r.Name, singleSer.SER_Id_custom__c,singleSer.Account__r.CRM_Code__c );
        		serItemList.add(serItemToSend);
                system.debug('SERITEM:: '+serItemToSend);
            }
            sendToSP(JSON.serialize(serItemList));
        }
        
    }
    @future(callout =true)
    public static void sendToSP (string SerListJSON){
        
        List<serItem> serToSend = (List<serItem>)JSON.deserialize(SerListJSON, List<serItem>.class);
        //Provo a chiamare il servizio di autenticazione
        string token = AuthSP();
        if(token != 'ERROR'){
            //Inserisco su SP
            CreateSPItem(serToSend, token);
        } 
        else{
            system.debug('ERRORE AUTENTICAZIONE, SER NON CREATI SU SP');
        }
    }

    //Metodo che prende le QUOTE e le manda a SP
    public static void sendQuotestoSharepoint (Map<Id,SBQQ__Quote__c> triggerNewMap){
        List<SBQQ__Quote__c> quotesToSend = [SELECT Id, Name, SBQQ__Opportunity2__r.Sharepoint_Id__c, createddate,SBQQ__Account__c, SBQQ__Opportunity2__c, createdBy.Email,SBQQ__Type__c,SBQQ__BillingCountry__c,Quote_Id_custom__c,SBQQ__Account__r.Name,SBQQ__Account__r.CRM_Code__c 
                                             FROM SBQQ__Quote__c 
                                             WHERE Id IN :triggerNewMap.keySet()];
        if(quotesToSend != null && quotesToSend.size() > 0){
            List<quoteItem> quoteItemList = new List<quoteItem>();
            for(SBQQ__Quote__c singleQuote : quotesToSend){
                if(singleQuote.SBQQ__Type__c != 'Amendment'){
                    quoteItem quoteItemToSend = new quoteItem(singleQuote.createddate.year(),singleQuote.SBQQ__Account__c,singleQuote.SBQQ__Opportunity2__r.Sharepoint_Id__c,singleQuote.Id,singleQuote.createdBy.Email,'',singleQuote.SBQQ__Type__c, singleQuote.SBQQ__BillingCountry__c, singleQuote.SBQQ__Account__r.Name, singleQuote.Name,singleQuote.SBQQ__Account__r.CRM_Code__c );
                    quoteItemList.add(quoteItemToSend);
                    system.debug('quoteItem:: '+quoteItemToSend);
                }
            }
            if(!quoteItemList.isEmpty()){
                sendQuotesToSP(JSON.serialize(quoteItemList));
            } 
        }
        
    }
    @future(callout =true)
    public static void sendQuotesToSP (string QuoteListJSON){
        
        List<quoteItem> quotesToSend = (List<quoteItem>)JSON.deserialize(QuoteListJSON, List<quoteItem>.class);
        //Provo a chiamare il servizio di autenticazione
        string token = AuthSP();
        if(token != 'ERROR'){
            //Inserisco su SP
            CreateSPItemQuote(quotesToSend, token);
        } 
        else{
            system.debug('ERRORE AUTENTICAZIONE, QUOTE NON CREATE SU SP');
        }
    }
    public static string AuthSP(){
        try{ 
            HttpRequest request = new HttpRequest();
			Sharepoint_Endpoints__mdt endpoints = [SELECT ClientId_PRD__c,ClientId_SDX__c,ClientSecret_PRD__c,ClientSecret_SDX__c,Endpoint_Create_item_PRD__c,Endpoint_Create_item_SDX__c,Endpoint_login_PRD__c,Endpoint_login_SDX__c,Resource_PRD__c,Resource_SDX__c,TenantId_PRD__c,TenantId_SDX__c FROM Sharepoint_Endpoints__mdt LIMIT 1];
            string clientId;
            string clientSecret;
            string resource;
            //Setto gli entpoints in base a se siamo in sandbox o no
            if([Select IsSandbox from Organization limit 1].isSandbox){
                clientId = endpoints.ClientId_SDX__c + '@' + endpoints.TenantId_SDX__c;
                System.debug('@@@ clientId ' + endpoints.ClientId_SDX__c);
                clientSecret = endpoints.ClientSecret_SDX__c;
                resource = endpoints.Resource_SDX__c;
                request.setEndpoint(endpoints.Endpoint_login_SDX__c);
            }
            else{
                clientId = endpoints.ClientId_PRD__c + '@' + endpoints.TenantId_PRD__c;
                clientSecret = endpoints.ClientSecret_PRD__c;
                resource = endpoints.Resource_PRD__c; 
                request.setEndpoint(endpoints.Endpoint_login_PRD__c);
            }
            
            //Costruisco il payload e la chiamata
            String payload = 'grant_type=client_credentials'+'&client_id='+clientId+'&client_secret='+clientSecret+'&resource='+EncodingUtil.urlEncode(resource,'UTF-8');
            System.debug('@@@ payload ' + payload);
            request.setMethod('POST');
            request.setBody(payload);
            request.setTimeout(120000);
            request.setHeader('Content-Type', 'application/x-www-form-urlencoded');
            
            //Mando la chiamata
            HttpResponse response = new Http().send(request);

            System.debug('@@@ response ' + response.getBody());
            System.debug('@@@ response ' + response.getStatusCode());
			
            
            //Deserializzo la risposta e mi prendo il token se presente
            Map<String,Object> tokenMap = new Map<String,Object>();
            tokenMap = (Map<String,Object>)JSON.deserializeUntyped(response.getBody());
            String token = String.valueOf(tokenMap.get('access_token'));
            
            if(token == null || response.getStatusCode() != 200){
                System.debug('ERRORE AUTENTICAZIONE ');
            }
            
            System.debug('@@@ token ' + token);
            return token;
            
        } catch (Exception e){
            system.debug('ERRORE: ' + e.getMessage() + ' ' + e.getStackTraceString());
        }
        return 'ERROR';
    }
    
    public static void CreateSPItemQuote (List<quoteItem> quoteList , string authToken){
        try{ 
            HttpRequest request = new HttpRequest();
			Sharepoint_Endpoints__mdt endpoints = [SELECT ClientId_PRD__c,ClientId_SDX__c,ClientSecret_PRD__c,ClientSecret_SDX__c,Endpoint_Create_QUOTE_PRD__c,Endpoint_Create_QUOTE_SDX__c,Endpoint_login_PRD__c,Endpoint_login_SDX__c,Resource_PRD__c,Resource_SDX__c,TenantId_PRD__c,TenantId_SDX__c FROM Sharepoint_Endpoints__mdt LIMIT 1];
            //Setto gli entpoints in base a se siamo in sandbox o no
            if([Select IsSandbox from Organization limit 1].isSandbox){
                request.setEndpoint(endpoints.Endpoint_Create_QUOTE_SDX__c);
            }
            else{
                request.setEndpoint(endpoints.Endpoint_Create_QUOTE_PRD__c);
            }
            //Costruisco la chiamata
            request.setMethod('POST');
            request.setHeader('Authorization', 'Bearer ' + authToken);
            request.setHeader('Accept', 'application/json;odata=verbose');
            request.setHeader('Content-Type', 'application/json;odata=verbose');
            for(quoteItem singleQuote : quoteList){
                system.debug('@@@ quoteItemToSend'+singleQuote);
                string body = JSON.serialize(singleQuote).replace('metadata','__metadata');
                system.debug('@@@ body'+body);
                request.setBody(body);
                HttpResponse response = new Http().send(request);
                system.debug(response);
            }
        }catch (Exception e){
            system.debug('ERRORE: ' + e.getMessage() + ' ' + e.getStackTraceString());
        }
    }
    public static void CreateSPItem (List<serItem> serList , string authToken){
        try{ 
            HttpRequest request = new HttpRequest();
			Sharepoint_Endpoints__mdt endpoints = [SELECT ClientId_PRD__c,ClientId_SDX__c,ClientSecret_PRD__c,ClientSecret_SDX__c,Endpoint_Create_item_PRD__c,Endpoint_Create_item_SDX__c,Endpoint_login_PRD__c,Endpoint_login_SDX__c,Resource_PRD__c,Resource_SDX__c,TenantId_PRD__c,TenantId_SDX__c FROM Sharepoint_Endpoints__mdt LIMIT 1];
            //Setto gli entpoints in base a se siamo in sandbox o no
            if([Select IsSandbox from Organization limit 1].isSandbox){
                request.setEndpoint(endpoints.Endpoint_Create_item_SDX__c);
            }
            else{
                request.setEndpoint(endpoints.Endpoint_Create_item_PRD__c);
            }
            //Costruisco la chiamata
            request.setMethod('POST');
            request.setHeader('Authorization', 'Bearer ' + authToken);
            request.setHeader('Accept', 'application/json;odata=verbose');
            request.setHeader('Content-Type', 'application/json;odata=verbose');
            //Ciclo i ser e per ognuno creo un oggetto serItem e lo mando verso SP (da verificare se così regge o se c'è da farlo async)
            for(serItem singleSer : serList){
                system.debug('@@@ serItemToSend'+singleSer);
                string body = JSON.serialize(singleSer).replace('metadata','__metadata');
                system.debug('@@@ body'+body);
                request.setBody(body);
                HttpResponse response = new Http().send(request);
                system.debug(response);
            }
        }catch (Exception e){
            system.debug('ERRORE: ' + e.getMessage() + ' ' + e.getStackTraceString());
        }
    }
    public static void CreateSPFile (string base64 ,string SPId, string fileName){
        try{ 
            HttpRequest request = new HttpRequest();
			string token  = AuthSP();
            //Costruisco la chiamata
            request.setMethod('POST');
            request.setHeader('Authorization', 'Bearer ' + token);
            request.setHeader('Accept', 'application/json;odata=verbose');
            request.setHeader('Content-Type', 'application/json;odata=verbose');
            request.setEndpoint('https://salvagninigroup.sharepoint.com/sites/SGSalesDocsTS/_api/web/lists/GetByTitle(\'SERRichieste\')/items('+SPId+')/AttachmentFiles/add(FileName=\''+fileName+'\')');
            request.setBody(base64);
            HttpResponse response = new Http().send(request);
            system.debug(response);
        
        }catch (Exception e){
            system.debug('ERRORE: ' + e.getMessage() + ' ' + e.getStackTraceString());
        }
    }
    
    //struttura da mandare verso SP
    public class serItem{
        SPmetadata metadata;
        public integer SerYear;
        public string SerAccountID;
        public string SerOpportunityID;
        public string SerID;
        public string SerCreator;
        public string SERApplicationBranch;
        public string SERType;
        public string SerCountry;
        public string SERAccountName;
        public string SERCrmCode;
        public string AccountCRMCode;
        public serItem (integer SerYear,string SerAccountID,string SerOpportunityID,string SerID,string SerCreator,string SERApplicationBranch, string SERType,string SerCountry,string SERAccountName,string SERCrmCode, string AccountCRMCode){
            this.metadata = new SPmetadata();
            this.SerYear = SerYear;
            //this.SerAccountID = SerAccountID;
            //this.SerOpportunityID = SerOpportunityID;
            //this.SerID = SerID;
            this.SerAccountID = AccountCRMCode;
            this.SerOpportunityID = SerOpportunityID;
            this.SerID = SERCrmCode;
            this.SerCreator = SerCreator;
            this.SERApplicationBranch = SERApplicationBranch;
            this.SERType = SERType;
            this.SerCountry = SerCountry;
            this.SERAccountName = SERAccountName;
            //this.SERCrmCode = SERCrmCode;
            //this.AccountCRMCode = AccountCRMCode;
            this.SERCrmCode = SerID; 
            this.AccountCRMCode = SerAccountID;
            
        }
    }
    
    public class SPmetadata{
        public string type = 'SP.Data.SERRichiesteListItem'; 
    }

    public class quoteItem{
        quoteSPmetadata metadata;
        public integer QuoteYear;
        public string QuoteAccountID;
        public string QuoteOpportunityID;
        public string QuoteID;
        public string QuoteCreator;
        public string QuoteApplicationBranch;
        public string QuoteType;
        public string QuoteCountry;
        public string QuoteAccountName;
        public string QuoteCrmCode;
        public string AccountCRMCode;
        public quoteItem (integer QuoteYear,string QuoteAccountID,string QuoteOpportunityID,string QuoteID,string QuoteCreator,string QuoteApplicationBranch, string QuoteType,string QuoteCountry,string QuoteAccountName,string QuoteCrmCode, string AccountCRMCode){
            this.metadata = new quoteSPmetadata();
            this.QuoteYear = 2022;
            //this.SerAccountID = SerAccountID;
            //this.SerOpportunityID = SerOpportunityID;
            //this.SerID = SerID;
            this.QuoteAccountID = AccountCRMCode;
            this.QuoteOpportunityID = QuoteOpportunityID;
            this.QuoteID = QuoteCrmCode;
            this.QuoteCreator = QuoteCreator;
            this.QuoteApplicationBranch = QuoteApplicationBranch;
            this.QuoteType = QuoteType;
            this.QuoteCountry = QuoteCountry;
            this.QuoteAccountName = QuoteAccountName;
            //this.SERCrmCode = SERCrmCode;
            //this.AccountCRMCode = AccountCRMCode;
            this.QuoteCrmCode = QuoteID; 
            this.AccountCRMCode = QuoteAccountID;
            
        }
    }
    
    public class quoteSPmetadata{
        public string type = 'SP.Data.QuoteRichiesteListItem'; 
    }
   // https://salvagninigroup.sharepoint.com/sites/SGSalesDocsTS/_api/web/lists/GetByTitle('SERRichieste')/items
}