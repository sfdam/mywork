global with sharing class ConnectorEntityController {

    public ConnectorEntityController() { } 
    
     @RemoteAction
    global static Task createTask(Task task,String field, String value) {
        
        try{        
            List<Contact> contacts = Database.query('Select id,AccountId,Birthdate,Email,FirstName,LastName,Phone from Contact where ' + String.escapeSingleQuotes(field) + ' = \'' + String.escapeSingleQuotes(value) + '\'');
            //List<Contact> contacts = Database.query('Select id,AccountId,Birthdate,Email,FirstName,LastName,Phone from Contact where ' + field + ' = \'' + value + '\'');
            System.debug('contacts found : ' + contacts);
            if ( contacts.size() == 1 ){
                task.WhoId = contacts.get(0).Id;
            } 
            } catch(Exception e){
            System.debug('Error in createTask ' + e);     
         }

        try{           
            Database.SaveResult sr =  Database.insert(task);
                System.debug('save result : ' + sr);   
                return task;
            } catch(Exception e){
            System.debug('Error in insert ' + e);
        
         }
        return null;
    }

    @RemoteAction
    global static List<Contact> findContactId(String field, String value) {
        
        try{        
            List<Contact> contacts = Database.query('Select id,name from Contact where ' + String.escapeSingleQuotes(field) + ' = \'' + String.escapeSingleQuotes(value) + '\'');
            //List<Contact> contacts = Database.query('Select id,name from Contact where ' + field + ' = \'' + value + '\'');
            System.debug('contacts found : ' + contacts);
            return contacts;
            } catch(Exception e){
            System.debug('Error in finding contact ' + e);     
         }
    return null;
    }

    @RemoteAction
    global static Case createCase(Case obj,String field, String value) {
        
        try{        
            List<Contact> contacts = Database.query('Select id,AccountId,Birthdate,Email,FirstName,LastName,Phone from Contact where ' + String.escapeSingleQuotes(field) + ' = \'' + String.escapeSingleQuotes(value) + '\'');
            //List<Contact> contacts = Database.query('Select id,name from Contact where ' + field + ' = \'' + value + '\'');
            System.debug('contacts found : ' + contacts);
            if ( contacts.size() == 1 ){
                obj.ContactId = contacts.get(0).Id;
            } 
            } catch(Exception e){
            System.debug('Error in finding contact ' + e);     
         }

        try{           
            Database.SaveResult sr =  Database.insert(obj);
                System.debug('save result : ' + sr);   
                return obj;
            } catch(Exception e){
            System.debug('Error in insert ' + e);
        
         }
        return null;
    }

    @RemoteAction
    global static SObject createSObject(SObject obj) {
        try{           
            Database.SaveResult sr =  Database.insert(obj);
                System.debug('save result : ' + sr);   
                return obj;
            } catch(Exception e){
            System.debug('Error in insert ' + e);
        
         }
        return null;
    }


   @RemoteAction
   global static softphone_it__ConnectorEventTimeLog__c createConnectorEventTimeLog(Map<String, Object> obj) {
        
        try{
            Long callTime = (Long)(Decimal)obj.get('callTime'); 
            if ( callTime == null ){
                callTime = Datetime.now().getTime();
            }
            softphone_it__ConnectorEventTimeLog__c timeLog = new softphone_it__ConnectorEventTimeLog__c();
            timeLog.Name = (String)obj.get('interactionId');
            timeLog.softphone_it__Ringing_Time__c = DateTime.newInstance(callTime);
            //timeLog.Ringing_Time__c = DateTime.now();
            timeLog.softphone_it__Interaction_Id__c = (String)obj.get('interactionId');
            timeLog.softphone_it__Agent_Id__c = (String)obj.get('agentId');
            timeLog.softphone_it__Direction__c = (String)obj.get('callType');
            timeLog.softphone_it__Media_Type__c = (String)obj.get('mediaType');
                        
            Database.SaveResult sr =  Database.insert(timeLog);
            System.debug('save result : ' + sr);   
            return timeLog;
        } catch(Exception e){
            System.debug('Error in createConnectorEventTimeLog ' + e);     
        }
        
        return null;
    }
    
    @RemoteAction
    global static boolean updateConnectorEventTimeLog(Map<String, Object> obj) {
        boolean result = true;
        String interactionId = (String)obj.get('interactionId');
        String field = (String)obj.get('field');
        String state = (String)obj.get('state');
        Long callTime = (Long)(Decimal)obj.get('callTime');
        String disposition = (String)obj.get('disposition');
        DateTime value = DateTime.newInstance(callTime);
        String parentId = (String)obj.get('parentId');
        String caseId = (String)obj.get('caseId');
        String contactId = (String)obj.get('contactId');
        Integer interactionDuration = Integer.valueOf(obj.get('interactionDuration'));
         Integer totalAcdDuration = Integer.valueOf(obj.get('totalAcdDuration'));
         Integer totalIvrDuration = Integer.valueOf(obj.get('totalIvrDuration'));
         Integer dispositionDuration = Integer.valueOf(obj.get('dispositionDuration'));
        System.debug('caseid  : ' + caseId);
        try{ 
            List<softphone_it__ConnectorEventTimeLog__c> timeLogs = [Select id, softphone_it__established_Time__c from softphone_it__ConnectorEventTimeLog__c where softphone_it__Interaction_Id__c = :interactionId  order by softphone_it__ringing_time__c desc limit 1];
            
            System.debug('ConnectorEventTimeLog found : ' + timeLogs);
            
            if ( timelogs == null || timelogs.size() == 0 ){
                return null;
            }
            
            
            softphone_it__ConnectorEventTimeLog__c timelog = timelogs[0];
            timelog.put(field,value);
            if ( caseId != null && caseId != 'a' ){
                timelog.softphone_it__Case__c = caseId; 
            }
            if(contactId != null){
                timelog.softphone_it__Contact__c = contactId; 
            }
            if(parentId != null){
                timelog.softphone_it__Parent_Id__c  = parentId; 
            }
            if(state != null){
                timelog.softphone_it__State__c = state; 
            }
            if(disposition != null){
                timelog.softphone_it__Disposition_Code__c = disposition; 
            }
            if(interactionDuration != null){
                timelog.softphone_it__Interaction_Duration__c = interactionDuration; 
            }
            if(totalAcdDuration != null){
                timelog.softphone_it__Total_Acd_Duration__c = totalAcdDuration; 
            }
            if(totalIvrDuration != null){
                timelog.softphone_it__Total_Ivr_Duration__c = totalIvrDuration; 
            }
            if(dispositionDuration != null){
                timelog.softphone_it__Disposition_Duration__c = dispositionDuration; 
            }
            if(field == 'softphone_it__Released_Time__c' && state == 'answered' && timeLog.softphone_it__Established_Time__c == null){
                timelog.softphone_it__State__c = 'not answered';
            }
        
            update timelog;  
        } catch(Exception e){
            System.debug('Error in updateConnectorEventTimeLog ' + e);
            result = false;
        }
        
        return result;
    }

    @RemoteAction
    global static String ERCOmniUtilsPath {
        get {
           return GetResourceURL('softphoneerc','omniUtils');
        }
    }

    @RemoteAction
    global static String ERCiwsscriptomniPath {
        get {
           return GetResourceURL(null,'iwsscript_omni');
        }
    }

     @RemoteAction
    global static String ERCsyncUtilsPath {
        get {
           return GetResourceURL(null,'syncUtils');
        }
    }


    public static String GetResourceURL(String namespace,String resourceName){

        List<StaticResource> resourceList= namespace != null ? 
        [SELECT Name, NamespacePrefix, SystemModStamp FROM StaticResource WHERE Name = :resourceName AND NamespacePrefix = :namespace] : 
        [SELECT Name, NamespacePrefix, SystemModStamp FROM StaticResource WHERE Name = :resourceName] ;
            if(resourceList.size() == 1){
                String nm = resourceList[0].NamespacePrefix;
               return '/resource/' + resourceList[0].SystemModStamp.getTime() + '/' + (nm != null && nm != '' ? nm + '__' : '') + resourceName; 
            }
            return ''; 
        
        }
    
    @RemoteAction
    global static CustomActionResponseWrapper customAction(CustomActionRequestWrapper data) {
        if(data.transfer=='transfer'){
            return trasferimento(data);
        }
        else{
            Id recordTypeId= SV_Utilities.getRecordTypeByDeveloperName('Case', 'Standard_Case');
            CustomActionResponseWrapper response= new CustomActionResponseWrapper();
            List<Esigenza_SF__mdt> esList= [SELECT Area__c FROM Esigenza_SF__mdt WHERE DeveloperName =:data.esigenza];
            String area;
            OnCaseTriggerHandler.skipCustomValidation=true;
            if(esList.size()>0){
                area=esList[0].Area__c;
            }
            //26/11/2020
            if(data.ndgId!=null && data.ndgId!= ''){
                String extId= data.abi+'_'+data.ndgId;
                List<Account> accountToOpen=[SELECT Id, Name FROM Account WHERE NDW_ExternalId__c=:extId];
                Case c= new Case();
                if(accountToOpen.size()>0){
                    c.CRM_FirstOwner__c=UserInfo.getUserId();
                    c.CRM_CallerPhoneNumber__c=data.phone;
                    c.AccountId=accountToOpen[0].Id;
                    c.RecordTypeId=recordTypeId;
                    c.CRM_CustomerAuthenticationType__c =data.autenticated;
                    c.Origin = 'Phone';
                    c.Status='Assegnato';
                    c.CRM_Area__c=area;
                    c.CRM_CTIContactId__c = data.interactionId;
                    insert c;
                    Case newCase=[SELECT Id, CaseNumber FROM Case WHERE Id=:c.Id];
                    response.accountId= accountToOpen[0].Id;
                    response.AccountName=accountToOpen[0].Name;
                    response.caseId= newCase.Id;
                    response.caseNumber= newCase.CaseNumber;
                    return response;
                }
                else{
                    c.CRM_FirstOwner__c=UserInfo.getUserId();
                    c.CRM_CallerPhoneNumber__c=data.phone;
                    c.RecordTypeId=recordTypeId;
                    c.CRM_CustomerAuthenticationType__c =data.autenticated;
                    c.Origin = 'Phone';
                    c.Status='Assegnato';
                    c.CRM_Area__c=area;
                    c.CRM_CTIContactId__c = data.interactionId;
                    insert c;
                    Case newCase=[SELECT Id, CaseNumber FROM Case WHERE Id=:c.Id];
                    response.caseId= newCase.Id;
                    response.caseNumber= newCase.CaseNumber;
                    return response;
                } 
            }
            //26/11/2020
            else{
                String QueryString =  'FIND \'' + data.phone + '\' IN PHONE FIELDS RETURNING';
                QueryString += ' Account (Id, Name, CRM_SmartWebMobilePhone__c, Phone, CRM_Phone1__c,CRM_Phone2__c, CRM_PhoneBpercard__c, CRM_Cellulare_aziendale_Bpercard__c WHERE Recordtype.DeveloperName != \'Cointestazione\')';
                List<List<SObject>> searchList = search.query(queryString);
                Account accountToOpen = new Account();
                List<Account> list1 = new List<Account>();
                List<Account> list2 = new List<Account>();
                List<Account> list3 = new List<Account>();
                List<Account> list4 = new List<Account>();
                List<Account> list5 = new List<Account>();
                List<Account> list6 = new List<Account>();
                for(Account a: (List<Account>) searchList[0]){
                    if(String.isNotBlank(a.CRM_SmartWebMobilePhone__c) && a.CRM_SmartWebMobilePhone__c.endsWith(data.phone)) list1.add(a);
                    if(String.isNotBlank(a.Phone) && a.Phone.endsWith(data.phone)) list2.add(a);
                    if(String.isNotBlank(a.CRM_Phone1__c) && a.CRM_Phone1__c.endsWith(data.phone)) list3.add(a);
                    if(String.isNotBlank(a.CRM_Phone2__c) && a.CRM_Phone2__c.endsWith(data.phone)) list4.add(a);
                    if(String.isNotBlank(a.CRM_PhoneBpercard__c) && a.CRM_PhoneBpercard__c.endsWith(data.phone)) list5.add(a);
                    if(String.isNotBlank(a.CRM_Cellulare_aziendale_Bpercard__c) && a.CRM_Cellulare_aziendale_Bpercard__c.endsWith(data.phone)) list6.add(a);
                }
                if(list1.size()>0 && list1.size()==1){ accountToOpen=list1[0]; }
                else if(list2.size()>0 && list2.size()==1){ accountToOpen=list2[0]; }
                else if(list3.size()>0 && list3.size()==1){ accountToOpen=list3[0]; }
                else if(list4.size()>0 && list4.size()==1){ accountToOpen=list4[0]; }
                else if(list5.size()>0 && list5.size()==1){ accountToOpen=list5[0]; }
                else if(list6.size()>0 && list6.size()==1){ accountToOpen=list6[0]; }

                Case c = new Case();
                if(String.isNotBlank(accountToOpen.Id)){
                    c.CRM_FirstOwner__c=UserInfo.getUserId();
                    c.CRM_CallerPhoneNumber__c=data.phone;
                    c.AccountId=accountToOpen.Id;
                    c.RecordTypeId=recordTypeId;
                    c.CRM_CustomerAuthenticationType__c =data.autenticated;
                    c.Origin = 'Phone';
                    c.Status='Assegnato';
                    c.CRM_Area__c=area;
                    c.CRM_CTIContactId__c = data.interactionId;
                    insert c;
                    Case newCase=[SELECT Id, CaseNumber FROM Case WHERE Id=:c.Id];
                    response.accountId= accountToOpen.Id;
                    response.AccountName=accountToOpen.Name;
                    response.caseId= newCase.Id;
                    response.caseNumber= newCase.CaseNumber;
                    return response;
                }
                else{
                    c.CRM_FirstOwner__c=UserInfo.getUserId();
                    c.CRM_CallerPhoneNumber__c=data.phone;
                    c.RecordTypeId=recordTypeId;
                    c.CRM_CustomerAuthenticationType__c =data.autenticated;
                    c.Origin = 'Phone';
                    c.Status='Assegnato';
                    c.CRM_Area__c=area;
                    c.CRM_CTIContactId__c = data.interactionId;
                    insert c;
                    Case newCase=[SELECT Id, CaseNumber FROM Case WHERE Id=:c.Id];
                    response.caseId= newCase.Id;
                    response.caseNumber= newCase.CaseNumber;
                    return response;
                }   
            }
        }      
    }
    global class CustomActionResponseWrapper{
        global String accountId;
        global String accountName;
        global String caseId;
        global String caseNumber;
    }
    global class CustomActionRequestWrapper{
        global String ndgId; //Change 26/11/2020
        global String esigenza;
        global String autenticated;
        global String phone;
        global String interactionId;
        global String abi;
        global String transfer;
        global String caseId;
    }

    @RemoteAction
    global static void updateCase(String caseId, String aut, String ndgId, String abi){
        system.debug('caseId '+ caseId);
        system.debug('aut '+ aut);
        system.debug('ndgId '+ ndgId);
        system.debug('abi '+ abi);
        Case c= new Case();
        if(String.isNotBlank(ndgId) && String.isNotBlank(abi)){
            String extId= abi+'_'+ndgId;
            List<Account> accountToOpen=[SELECT Id, Name FROM Account WHERE NDW_ExternalId__c=:extId];
            c.AccountId=accountToOpen[0].Id;
        }
        c.Id=caseId;
        c.CRM_CustomerAuthenticationType__c=aut;
        OnCaseTriggerHandler.skipCustomValidation=true;
        update c;
    }

    global static CustomActionResponseWrapper trasferimento(CustomActionRequestWrapper data){
        OnCaseTriggerHandler.skipCustomValidation=true;
        CustomActionResponseWrapper response= new CustomActionResponseWrapper();
        if(data.caseId!=null){
            List<Case> oldCases= [SELECT Id, CaseNumber, Status, AccountId, Account.Name, CRM_CallerPhoneNumber__c,
                                    CRM_CustomerAuthenticationType__c, RecordTypeId, CRM_Area__c
                                     FROM Case WHERE Id=:data.caseId];
            System.debug('@@@@oldcases'+oldCases[0].Status);                         
            if(oldCases.size()>0 && oldCases[0].Status!='Closed'){
                Case c= new Case();
                c.Id=oldCases[0].Id;
                c.ownerId= UserInfo.getUserId();
                c.CRM_FirstOwner__c= UserInfo.getUserId();
                update c;
                response.caseId=oldCases[0].Id;
                response.caseNumber=oldCases[0].CaseNumber;
                if(String.isNotBlank(oldCases[0].AccountId)){
                    response.accountId=oldCases[0].AccountId;
                    response.accountName=oldCases[0].Account.Name;
                }
            }
            else{
                Case c= new Case();
                c.CRM_FirstOwner__c=UserInfo.getUserId();
                c.CRM_CallerPhoneNumber__c=oldCases[0].CRM_CallerPhoneNumber__c;
                if(String.isNotBlank(oldCases[0].AccountId)){
                    c.AccountId=oldCases[0].AccountId;
                }
                c.RecordTypeId=oldCases[0].RecordTypeId;
                c.CRM_CustomerAuthenticationType__c =oldCases[0].CRM_CustomerAuthenticationType__c;
                c.Origin = 'Phone';
                c.Status='Assegnato';
                c.CRM_Area__c=oldCases[0].CRM_Area__c;
                c.CRM_CTIContactId__c = data.interactionId;
                insert c;
                List<Case> cList = [SELECT Id, CaseNumber, Status, AccountId, Account.Name, CRM_CallerPhoneNumber__c,
                CRM_CustomerAuthenticationType__c, RecordTypeId, CRM_Area__c
                 FROM Case WHERE Id=:c.Id];
                response.caseId=c.Id;
                response.caseNumber=cList[0].CaseNumber;
                if(String.isNotBlank(cList[0].AccountId)){
                    response.accountId=cList[0].AccountId;
                    response.accountName=cList[0].Account.Name;
                } 
            }
        }
        return response;
    }
    
     @RemoteAction
    global static void updateExternalRoutingBean(String id,String agentId){
        External_Routing_Bean__c lct = [SELECT id FROM External_Routing_Bean__c WHERE interaction_Id__c = :id];
        lct.Agent_Id__c  = agentId;
        update lct;     
    }      
    
    @RemoteAction
    global static External_Routing_Bean__c getExternalRoutingBean(String chatId){
        String id = chatId.substring(0, 15);
        return [SELECT id,interaction_Id__c,Agent_Id__c FROM External_Routing_Bean__c WHERE PreChat_Id__c in (:chatId,:id)];
    }      

    @AuraEnabled(cacheable=true)
    public static Boolean isMessageListenerActive() {
        System.debug('isMessageListenerActive');
        GenesysSetting__c settings = [select id, S_MESSAGES_TIMEOUT__c from GenesysSetting__c where G_MEDIA_TYPE__c='whatsapp' limit 1];
        Integer timeout = Integer.valueOf(settings.S_MESSAGES_TIMEOUT__c);
        System.debug('timeout='+timeout);
        return timeout > 0;
    }

    @RemoteAction
    global static Boolean  updateQueue(String campaignMemberId, String queue, String interactionId, String agentId) {
        try{
            System.debug('ConnectorEntityController updateQueue - start');

            CampaignMember cm = [SELECT CRM_AgentId__c, campaignid, CRM_IDConversazione__c FROM CampaignMember WHERE id = : campaignMemberId];
            System.debug('ConnectorEntityController updateQueue - CampaignMember: '+cm);
            User u = [SELECT Id, Name FROM User WHERE Id = :UserInfo.getUserId()];
            System.debug('ConnectorEntityController updateQueue - User: '+u);
            
            cm.CRM_IDConversazione__c = interactionId;
            cm.CRM_AgentId__c= agentId;
            cm.CRM_UtenteCC__c = u.Name;
            cm.CRM_DataOraInterazione__c = dateTime.Now();
            System.debug('ConnectorEntityController updateQueue - CRM_IDConversazione__c: '+cm.CRM_IDConversazione__c);
            System.debug('ConnectorEntityController updateQueue - CRM_UtenteCC__c : '+cm.CRM_UtenteCC__c );
            System.debug('ConnectorEntityController updateQueue - CRM_DataOraInterazione__c : '+cm.CRM_DataOraInterazione__c );

            Campaign camp = [SELECT id,CRM_QueueName__c FROM Campaign where id = : cm.campaignId];
            System.debug('ConnectorEntityController updateQueue - Campaign: '+camp);

            camp.CRM_QueueName__c = queue;
            update camp;
            System.debug('ConnectorEntityController updateQueue - cm: '+cm);
            update cm;
            return true;
        }catch(Exception e){ 
            System.debug('ConnectorEntityController updateQueue - exception: '+e.getStackTraceString());
            return false;}
    }

    @RemoteAction
    global static Boolean  updateCaseOwner(String caseId,String agentId) {
        try{
            System.debug('ConnectorEntityController updateCaseOwner - start');
            Id userId = UserInfo.getUserId();
            Case c = [SELECT id, ownerid, CRM_FirstOwner__c, Status, CRM_Hesitation__c FROM Case WHERE id =: caseId];
            if(c.Status.equalsIgnoreCase('Closed')){
                c.CRM_Hesitation__c = null;
                //c.Status = 'Assigned';
                c.Status = 'Assegnato';
                c.ownerId = userId;
                c.CRM_FirstOwner__c = userId;
            //}else if(c.Status.equalsIgnoreCase('Assigned')){
            }else if(c.Status.equalsIgnoreCase('Assegnato')){
                c.ownerId = userId;
                c.CRM_FirstOwner__c = userId;
            }else if(c.Status.equalsIgnoreCase('Escalated') || c.Status.equalsIgnoreCase('Pending')){
                c.CRM_FirstOwner__c = userId;
            }
            c.G_LastAgentRouted__c = agentId;
            update c;
            return true;
        }catch(Exception e){ 
            System.debug('ConnectorEntityController updateCaseOwner - exception: '+e.getStackTraceString());
            return false;}
    }
    @RemoteAction
    global static Case  updateCaseRoutingStatus(String caseId, Boolean status) {
        Case cs = [select id,CRM_OnQueue__c  from Case where id=:caseId limit 1];
        cs.CRM_OnQueue__c = status;
        update cs;
        return cs;
    }

    @RemoteAction
    global static CampaignMember  findCampaignMember(String id) {
        try{
            return [select Id, Contact.Name, CRM_NumeroTentativi__c from CampaignMember where Id=:id limit 1];
        }catch(Exception e){
            System.debug('error in findCampaignMember :' + e);
        }
        return null;
    }

    @RemoteAction
    global static Event  findEvent(String id) {
        try{
            return [select Id, Subject from Event where Id=:id limit 1];
        }catch(Exception e){
            System.debug('error in findEvent :' + e);
        }
        return null;
    }

    @RemoteAction
    global static Boolean  updateCaseInteraction(String livechatId, String interactionId, String mediaType) {
        try{
            System.debug('ConnectorEntityController updateQueue - start ');
            System.debug('ConnectorEntityController parameters:'+livechatId+'-'+interactionId+'-'+mediaType);
            if(mediaType=='whatsapp'){
                MessagingSession messagingSess = [SELECT Id, CRM_IDinterazione__c FROM MessagingSession WHERE id = : livechatId];
                System.debug('messagingSess : '+messagingSess.Id);
                messagingSess.CRM_IDinterazione__c = interactionId;
                update messagingSess;
            } else if (mediaType=='web') {
                Case caseWeb = [SELECT Id, CRM_CTIContactId__c FROM Case WHERE id = : livechatId];
                caseWeb.CRM_CTIContactId__c = interactionId;
                update caseWeb;
            } else {
                LiveChatTranscript chatTranscript = [SELECT Id, CRM_IDConversazione__c FROM LiveChatTranscript WHERE id = : livechatId];  
                 System.debug('chatTranscript: '+chatTranscript.Id);  
                 //System.debug('caseId: '+chatTranscript.CaseId );   

                //Case caseToUpdate = [SELECT Id, CRM_CTIContactId__c FROM Case where id = : chatTranscript.CaseId ];

                chatTranscript.CRM_IDConversazione__c = interactionId;
                update chatTranscript;
            }
            return true;
        }catch(Exception e){ 
            System.debug('ConnectorEntityController updateQueue - exception: '+e.getStackTraceString());
            return false;}
    }
    
     @RemoteAction
    global static Boolean updateCampaignMember(String campaignMemberId, String agentId){
        
        try{
             System.debug('@@@@agent id '+ agentId);
    
             CampaignMember campMember = [SELECT Id, CRM_AgentId__c FROM CampaignMember WHERE Id = : campaignMemberId LIMIT 1];
    
             campMember.CRM_AgentId__c= agentId;
           
            update campMember;
            system.debug('@@@@campemember: '+ campMember); 
            return true;           
        }catch(Exception e){ 
            System.debug('ConnectorEntityController updateCampaignMember - exception: '+e.getStackTraceString());
            return false;} 
    }
    /*public static void testRun() {
        Integer i = 0;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        
    }*/

    
}