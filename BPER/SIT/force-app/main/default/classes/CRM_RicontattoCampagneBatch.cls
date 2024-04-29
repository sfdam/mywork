global class CRM_RicontattoCampagneBatch implements Database.AllowsCallouts, Database.Batchable<sObject>,Database.stateful,IRunner {
    private static final String COD_CLASSE = 'RC001';
    private static final String COD_SVILUPPATORI = 'DEVELOPER';
    private static final String NOME_CLASSE = 'CRM_RicontattoCampagneBatch';

    global List<ScheduledJob__c> sj = new List<ScheduledJob__c>();
    global Debug__mdt debug = (Debug__mdt)MetadataUtility.getRecordByName('Debug__mdt', COD_CLASSE);


    global Datetime currentTime = System.now();
    global Boolean authenticationDone = false;
    global static Map<String,String> outcomeMap = new Map<String,String>{
            'ININ-OUTBOUND-INTERNAL-ERROR-SKIPPED' => 'Cliente non raggiungibile',   
            'ININ-OUTBOUND-INVALID-PHONE-NUMBER' => 'Numero errato',
            'ININ-OUTBOUND-BUSY' => 'Numero errato',
            'ININ-OUTBOUND-NO-ANSWER' => 'Cliente non raggiungibile',        
            'ININ-OUTBOUND-FAX' => 'Numero errato',
            'ININ-OUTBOUND-MACHINE' => 'Numero errato'

            };

    global Id batchJobId;
    global String autToken;

    /***
     * IRunner
     ***/
    global void initRunner(List<ScheduledJob__c> schedules) {
        this.sj.addAll(schedules);
    }


    global Database.QueryLocator start(Database.BatchableContext BC) {
        Datetime halfHourBack = Datetime.now().addMinutes(-30);
        String query =  'SELECT Id,Status,CRM_Esito__c,CRM_NumeroTentativi__c,softphone_it__Gc_Contact_List_Id__c,softphone_it__Gc_Contact_Id_externalId__c FROM CampaignMember WHERE CRM_Esito__c = \'Da contattare\' AND CRM_NumeroTentativi__c = 3 AND Campaign.CRM_TipologiaOutboundContactCenter__c = \'Progressive\' AND lastmodifieddate <=: halfHourBack LIMIT 300';
        //String query =  'SELECT Id,Status,CRM_Esito__c,CRM_NumeroTentativi__c,softphone_it__Gc_Contact_List_Id__c,softphone_it__Gc_Contact_Id_externalId__c FROM CampaignMember WHERE CRM_Esito__c = \'Da contattare\' AND CRM_NumeroTentativi__c = 3 AND Campaign.CRM_TipologiaOutboundContactCenter__c = \'Progressive\'  LIMIT 300';
        System.debug('@@@@@query '+query);
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<CampaignMember> scope) {
        if(!authenticationDone){ 
            HttpResponse response = authVsGenesys();
            try{
                Map<String,Object> deserializedResponse= (Map<String,Object>) JSON.deserializeUntyped(response.getBody());
                String token=(String) deserializedResponse.get('access_token');
                if(!String.isBlank(token)){
                     authenticationDone = true;
                     autToken = token;
                }
                else authVsGenesys();
            }catch(Exception e){ System.debug('@@@@@response '+response.getBody()); }

        }
        List<CampaignMember> cmToUpdateList = new List<CampaignMember>();
        for(CampaignMember cm : scope){
            CampaignMember cmToUpdate = retrieveGenesysOutcome(cm);
            if (cmToUpdate!=null) cmToUpdateList.add(cmToUpdate);
        }
        System.debug('@@@@@cmToUpdateList: '+cmToUpdateList.size());

        if(!cmToUpdateList.isEmpty()){ 
            OnCampaignMemberTriggerHandler.trafficLightAssegnazioneAzione = true;
            update cmToUpdateList;
            OnCampaignMemberTriggerHandler.trafficLightAssegnazioneAzione = false;

        }
    }

    global void finish(Database.BatchableContext BC) {
        if (sj!=null && sj.size()>0) {
            JobRunner.executeNext(sj);
        }

    }

    public HttpResponse authVsGenesys(){

        Endpoint__c apiRequest = Endpoint__c.getInstance('GenesysToken');
        String orgId=UserInfo.getOrganizationId().left(15);
        softphone_it__Connector_Settings__c  cs= softphone_it__Connector_Settings__c.getInstance(orgId);
        String aut = EncodingUtil.base64Encode(Blob.valueof(cs.softphone_it__GC_CLIENT_ID__c+':'+cs.softphone_it__GC_CLIENT_SECRET__c));
        
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(apiRequest.Endpoint__c);
        request.setMethod(apiRequest.Method__c);
        request.setHeader('Authorization', 'Basic '+aut);
        request.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        request.setBody('grant_type=client_credentials');
        HttpResponse response = http.send(request);
        if(!Test.isRunningTest()){
            System.debug('@@@@@tokenResponse'+response.getBody());
            Map<String,Object> deserializedResponse= (Map<String,Object>) JSON.deserializeUntyped(response.getBody());
            String token=(String) deserializedResponse.get('access_token');
            System.debug(token);
            //Cache.OrgPartition orgPart = Cache.Org.getPartition('local.Bper');
            //orgPart.put('genesysToken', token, 86400);
        }
        
        //System.debug((String) orgPart.get('genesysToken'));


        return response;
   }

   public CampaignMember retrieveGenesysOutcome(CampaignMember cm){
       String endpoint = 'https://api.mypurecloud.de/api/v2/outbound/contactlists/'+cm.softphone_it__Gc_Contact_List_Id__c+'/contacts/'+cm.softphone_it__Gc_Contact_Id_externalId__c;
       System.debug('@@@@@endpoint '+endpoint);
       System.debug('@@@@@autToken '+this.autToken);
       Http http = new Http();
       HttpRequest request = new HttpRequest();
       request.setEndpoint(endpoint);
       request.setMethod('GET');
       request.setHeader('Authorization', 'Bearer '+ this.autToken);
       //request.setHeader('Authorization', 'Basic '+ this.autToken);
       request.setHeader('Content-Type', 'application/json');
       //request.setBody('grant_type=client_credentials');

       System.debug('@@@@@retrieveGenesysOutcome request '+request);
       System.debug('@@@@@retrieveGenesysOutcome Authorization '+request.getHeader('Authorization'));

       HttpResponse response = http.send(request);
       System.debug('@@@@@retrieveGenesysOutcome response '+response.getBody()); 
       try{
        Map<String,Object> deserializedResponse= (Map<String,Object>) JSON.deserializeUntyped(response.getBody());
        System.debug('@@@@@retrieveGenesysOutcome deserializedResponse '+deserializedResponse);

        Map<String, Object> callRecords = (Map<String, Object>)deserializedResponse.get('callRecords');
        System.debug('@@@@@retrieveGenesysOutcome callRecords '+callRecords);

        Map<String, Object> phone = (Map<String, Object>)callRecords.get('phone');
        System.debug('@@@@@retrieveGenesysOutcome phone '+phone);

        String lastResult = String.valueof(phone.get('lastResult'));
        System.debug('@@@@@retrieveGenesysOutcome lastResult '+lastResult);

        String cmStatus = outcomeMap.get(lastResult);
        if(!String.isBlank(cmStatus)){
            cm.Status = cmStatus;
            return cm;
        }

       }catch(Exception e){ System.debug('@@@@@retrieveGenesysOutcome error '+e.getStackTraceString());
    }
        return null;
   }


}