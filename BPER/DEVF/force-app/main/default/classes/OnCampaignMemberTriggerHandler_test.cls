@isTest
global class OnCampaignMemberTriggerHandler_test {
    @TestSetup
    static void makeData(){
        User usr = AllDataFactory.getUser('sf', UserInfo.getProfileId(), 'POE');
        usr.isActive = true;   
        insert usr;
    }
    

    @isTest static void testcheckNCS(){
        softphone_it__GcQueuePicklist__c queue = new softphone_it__GcQueuePicklist__c(Name='CC_TEST_BPER_Assicurativo',softphone_it__GC_Id__c ='c4c7b0ea-3ea9-4253-9d7a-5bd5a21bd1d8');
        insert queue;
        softphone_it__GCScriptPicklist__c script = new softphone_it__GCScriptPicklist__c (Name='Default Outbound Script',softphone_it__GC_Id__c ='476c2b71-7429-11e4-9a5b-3f91746bffa3');
        insert script;
        
        Campaign c = new Campaign();
        c.Name = 'testcheckNCS Campaign';
        c.softphone_it__Genesys_Cloud_Sync__c=true;
        c.IsActive=true;
        c.softphone_it__Gc_Contact_List_Id__c='2393bc98-5291-44a7-8025-c5788b68795c';
        c.softphone_it__Gc_Caller_Address__c='+123123';
        c.softphone_it__Gc_Caller_Name__c='test';
        c.softphone_it__Gc_Queue__c = queue.Id;
        c.softphone_it__Gc_Script__c = script.Id;
        c.softphone_it__Gc_Custom_Fields__c='Id,CRM_NumeroTentativi__c';
        insert c;
        
		System.debug('campaign created : ' + c);
       
        {
             Contact con = new Contact(FirstName='Name',LastName='Last');
        	insert con;
            CampaignMember cm = new CampaignMember(CampaignId=c.Id,ContactId=con.Id,CRM_NotCallable__c=false,CRM_NumeroTentativi__c=2,Status='Follow-up');
            insert cm;
            
            cm.CRM_NotCallable__c = true;
            update cm;
        }
        
        {
            Contact con = new Contact(FirstName='Name1',LastName='Last1');
        	insert con;
            CampaignMember cm = new CampaignMember(CampaignId=c.Id,ContactId=con.Id,CRM_NotCallable__c=false,isActive__c=true,CRM_NumeroTentativi__c=2);
            insert cm;
            
            cm.isActive__c = false;
            update cm;
            
            cm.isActive__c = true;
            update cm;
             DateTime myDateTime = DateTime.newInstance(system.currentTimeMillis());
        	myDateTime = myDateTime.addHours(1);
            cm.Status='Responded';
            cm.CRM_DataOraRicontatto__c = myDateTime;
             update cm;
            
          
            OnCampaignMemberTriggerHandler.setFields(new List<CampaignMember>{cm});
        }
      
        
        
    }
    
    @isTest static void testgetCallbackNumber(){
        
        String body = '{"totalHits":1,"conversations":[{"conversationId":"123","participants":[{"sessions":[{"callbackNumbers":["+39123456"]}]}]}]}';
         Campaign c = new Campaign();
        c.Name = 'testgetCallbackNumber Campaign';
        c.softphone_it__Genesys_Cloud_Sync__c=true;
        c.IsActive=true;
        c.softphone_it__Gc_Contact_List_Id__c='2393bc98-5291-44a7-8025-c5788b68795c';
        c.softphone_it__Gc_Caller_Address__c='+123123';
        c.softphone_it__Gc_Caller_Name__c='test';
        c.softphone_it__Gc_Custom_Fields__c='Id,CRM_NumeroTentativi__c';
        insert c;
        Contact con = new Contact(FirstName='Name',LastName='Last',Phone='+39123456');
        	insert con;
        CampaignMember cm = new CampaignMember(CampaignId=c.Id,ContactId=con.Id,CRM_NotCallable__c=false,isActive__c=true,CRM_NumeroTentativi__c=2);
        OnCampaignMemberTriggerHandler.getCallbackNumber(cm, body);
    }    
    
    @isTest static void testcalloutDeleteScheduledCallGenesys(){
        
        Map<String, String> callouts = new Map<String, String> {
            '123456' => '123456'
        };
          OnCampaignMemberTriggerHandler.calloutDeleteScheduledCallGenesys(callouts);
    }    
    
    @isTest static void testcalloutScheduleCallWithPreferredAgent(){
        Campaign c = new Campaign();
        c.Name = 'testcalloutScheduleCallWithPreferredAgent Campaign';
        c.softphone_it__Genesys_Cloud_Sync__c=true;
        c.IsActive=true;
        c.softphone_it__Gc_Custom_Fields__c='Id,CRM_NumeroTentativi__c';
        insert c;
        Contact con = new Contact(FirstName='Name4',LastName='Last4');
        	insert con;
        DateTime myDateTime = DateTime.newInstance(system.currentTimeMillis());
        myDateTime = myDateTime.addHours(1);
       CampaignMember cm = new CampaignMember(CampaignId=c.Id,ContactId=con.Id,CRM_NotCallable__c=false,isActive__c=true,CRM_NumeroTentativi__c=2,Status = 'Follow-up');
            
        OnCampaignMemberTriggerHandler.calloutScheduleCallWithPreferredAgent(myDateTime,cm);
    } 
    
    

     @isTest static void testinsertDebugLog(){
        
       
          OnCampaignMemberTriggerHandler.insertDebugLog('id', 'loglevel', 'action', 'method', 'url', 'body', 'response', 'header');
    }    
    
    @isTest static void testGhost(){
        Campaign c = new Campaign();
        c.Name = 'testcalloutScheduleCallWithPreferredAgent Campaign';
        c.softphone_it__Genesys_Cloud_Sync__c=true;
        c.IsActive=true;
        c.softphone_it__Gc_Custom_Fields__c='Id,CRM_NumeroTentativi__c';
        insert c;
        Funzionalita__c f = Funzionalita__c.getInstance();
        	f.Disable_WalletTrigger__c=true;
            upsert f;
           
            Account a = new Account(Name='test',IsPTF__c=true,PTF_IdCED__c='123'); 
            insert a;
            System.debug('account insert : ' + a);
             Wallet__c w = new Wallet__c( Name='testname',PTF_Filiale__c=a.Id,PTF_ModelloDiServizio__c='Assente');
            insert w;
            System.debug('wallet insert : ' + w);     
            Contact con = new Contact(FirstName='Name3',LastName='Last3');
        	insert con;
            CampaignMember cm = new CampaignMember(CampaignId=c.Id,ContactId=con.Id,CRM_NotCallable__c=false,isActive__c=true,CRM_NumeroTentativi__c=2,Status = 'Follow-up',PTF_idCed__c='123');
            insert cm;
            
             DateTime myDateTime = DateTime.newInstance(system.currentTimeMillis());
        	myDateTime = myDateTime.addHours(1);
            cm.CRM_DataOraRicontatto__c = myDateTime;
            cm.Status = 'Follow-up';
             update cm;
    } 
    
    // Michele Barile - 25/03/2024 - CR 76711
    @isTest 
    static void setFields(){ 
        User usr = [Select Id FROM User WHERE Name LIKE '%sf%' LIMIT 1];
        
        Id camRecordTypeId = Schema.SObjectType.Campaign.getRecordTypeInfosByName().get('Top-Down - Monostep').getRecordTypeId();
        Campaign cam = AllDataFactory.getCampaign('test', usr.Id, camRecordTypeId);
        cam.IsActive = true;
        cam.CRM_CategoriaAttributo_1__c= 'Anagrafica';
        cam.CRM_NomeAttributo1__c = 'Eta';
        cam.CRM_CategoriaAttributo_2__c= 'Anagrafica';
        cam.CRM_NomeAttributo2__c = 'Cittadinanza';
        insert cam;
        
        Account fil = AllDataFactory.getAccount('test', 'FilialeDiRelazione');
        insert fil;
        
        Wallet__c wal = AllDataFactory.getWallet('MicroWallet', null, 'POE');
        insert wal;
         
        Account acc = AllDataFactory.getAccount('test', 'IndustriesBusiness');
        acc.PTF_Portafoglio__c = wal.Id;
        acc.PTF_Filiale__c = fil.Id;
        insert acc;
        
        RoleTypology__c rt = new RoleTypology__c();
        rt.PTF_Code__c = '21';
        insert rt;
  
        Funzionalita__c f = Funzionalita__c.getInstance();
        f.isMC__c = true;
        upsert f;
        
        
        Contact con = AllDataFactory.getContact('test', usr.Id, acc.Id);
        insert con;
        
        Contact con2 = AllDataFactory.getContact('test', usr.Id, fil.Id);
        con2.PTF_TipologiaRuolo__c = rt.Id;
        con2.PTF_Ruolo__c = 'RuoloTest';
        insert con2;
        
        Test.StartTest();
        CampaignMember cm = AllDataFactory.getCampaignMember('test', cam.Id, con.Id, null);
        insert cm;
        Test.stopTest();
        
        
    }   
}