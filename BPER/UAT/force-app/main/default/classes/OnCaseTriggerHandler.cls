public class OnCaseTriggerHandler {
    public static Boolean skipCustomValidation=false;
    public static Boolean skipExecution=false;  
    public static Boolean trafficLightTrackingTrigger = false;
 

    public static Map<String, Map<String, Object>> fieldMap {
        get{

            if(fieldMap != null){

                return fieldMap;
            }
            StaticResource staticResource = [select id,body from StaticResource Where Name = 'jsonWrapper'];
            String jsonWrapper = staticResource.body.toString();
            fieldMap = new Map<String, Map<String, Object>>();
            Map<String,Object> parsedJsonWrapper = (Map<String,Object>)JSON.deserializeUntyped(jsonWrapper);
            Map<String,Object> parsedJsonElement = (Map<String,Object>)JSON.deserializeUntyped(JSON.serialize(parsedJsonWrapper.get('inserisciEventoContactCenter_Case')));
            Map<String, Object> parsedJsonElementFields = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(parsedJsonElement.get('fields')));
            for(String fieldName : parsedJsonElementFields.keySet()){

                fieldMap.put(fieldName, (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(parsedJsonElementFields.get(fieldName))));
            }
            return fieldMap;
        }set;
    }

    public static void isChildUpdate(List<Case> newCases, Map<Id,Case> oldMap, Boolean isUpdate){
		 system.debug('OnCaseTriggerHandler isChildUpdate start');       
        List<String> ParentIds= new List<String>();
        List<String> childCasesId= new List<String>();
        for(Case cs:newCases){
            if(String.isNotBlank(cs.ParentId) && cs.Status!='Closed' 
                && ((isUpdate && cs.ParentId!= oldMap.get(cs.Id).ParentId) || !isUpdate )){
                ParentIds.add(cs.ParentId);
                childCasesId.add(cs.Id);
            }
        }

        if(childCasesId.size()>0){

            Map<Id,Case> parentMap= new Map<Id,Case>([SELECT Id, CRM_Area__c, CRM_Scope__c,CRM_Level1__c ,
                                                        CRM_Level2__c, CRM_Level3__c, CRM_DigitalServices__c,
                                                        CRM_TicketBhelp__c 
                                                     FROM Case WHERE Id IN:ParentIds]);


           List<Case> childCases=[SELECT Id, ParentId FROM Case WHERE Id IN: childCasesId];                                     
            
            for (Case cs:childCases){
                cs.CRM_Area__c = parentMap.get(cs.ParentId).CRM_Area__c;
                cs.CRM_Scope__c = parentMap.get(cs.ParentId).CRM_Scope__c;
                cs.CRM_Level1__c = parentMap.get(cs.ParentId).CRM_Level1__c;
                cs.CRM_Level2__c = parentMap.get(cs.ParentId).CRM_Level2__c;
                cs.CRM_Level3__c = parentMap.get(cs.ParentId).CRM_Level3__c;
                cs.CRM_DigitalServices__c = parentMap.get(cs.ParentId).CRM_DigitalServices__c;
                cs.CRM_TicketBhelp__c = parentMap.get(cs.ParentId).CRM_TicketBhelp__c;

            }

            
            if(childCases.size()>0){
                skipCustomValidation=true;
                update childCases;
            }
            
        }


    }

    public static void isParentUpdate(List<Case> newCases, Map<Id,Case> newMap, Map<Id,Case> oldMap){
        system.debug('OnCaseTriggerHandler isParentUpdate start');  
        List<Case> childCases= [SELECT Id, ParentId, Status FROM Case WHERE ParentId IN:newMap.keySet()];

        List<CaseHesitationToClose__mdt> hesitationToClose = [SELECT Id, API_Name__c FROM CaseHesitationToClose__mdt];

        List<String> htc = new List<String>();
        for(CaseHesitationToClose__mdt h: hesitationToClose){
            htc.add(h.API_Name__c);
        }
        
        List<Case> caseToUpdate= new List<Case>();

        if(childCases.size()>0){

            for(Case cs:childCases){

                if(cs.Status!='Closed'){

                    if(newMap.get(cs.ParentId).CRM_Area__c!=oldMap.get(cs.ParentId).CRM_Area__c
                        || newMap.get(cs.ParentId).CRM_Scope__c!=oldMap.get(cs.ParentId).CRM_Scope__c
                        || newMap.get(cs.ParentId).CRM_Level1__c!=oldMap.get(cs.ParentId).CRM_Level1__c
                        || newMap.get(cs.ParentId).CRM_Level2__c!=oldMap.get(cs.ParentId).CRM_Level2__c
                        || newMap.get(cs.ParentId).CRM_Level3__c!=oldMap.get(cs.ParentId).CRM_Level3__c
                        || newMap.get(cs.ParentId).CRM_DigitalServices__c!=oldMap.get(cs.ParentId).CRM_DigitalServices__c
                        || newMap.get(cs.ParentId).CRM_TicketBhelp__c!=oldMap.get(cs.ParentId).CRM_TicketBhelp__c
                        || (newMap.get(cs.ParentId).CRM_Hesitation__c!=oldMap.get(cs.ParentId).CRM_Hesitation__c && htc.contains(newMap.get(cs.ParentId).CRM_Hesitation__c))
                        ){
                            cs.CRM_Area__c = newMap.get(cs.ParentId).CRM_Area__c;
                            cs.CRM_Scope__c = newMap.get(cs.ParentId).CRM_Scope__c;
                            cs.CRM_Level1__c = newMap.get(cs.ParentId).CRM_Level1__c;
                            cs.CRM_Level2__c = newMap.get(cs.ParentId).CRM_Level2__c;
                            cs.CRM_Level3__c = newMap.get(cs.ParentId).CRM_Level3__c;
                            cs.CRM_DigitalServices__c = newMap.get(cs.ParentId).CRM_DigitalServices__c;
                            cs.CRM_TicketBhelp__c = newMap.get(cs.ParentId).CRM_TicketBhelp__c;
                            cs.CRM_Hesitation__c = newMap.get(cs.ParentId).CRM_Hesitation__c;
                            caseToUpdate.add(cs);

                        }

 
                }

            }
            if(caseToUpdate.size()>0){
                update caseToUpdate;
            }
            


        }

        
    }
    
   public static void switchOwnerTeam(Map<Id, Case> newCasesMap, Map<Id, Case> oldMap) {
    List<Case> casesToUpdate = new List<Case>();
    Set<String> ownerIdSet = SV_Utilities.keyBy(newCasesMap.values(), 'OwnerId').keySet();
    Map<String, SObject> userMap = SV_Utilities.keyBy([SELECT Id, CRM_Team__c, CRM_Polo__c FROM User WHERE Id = :ownerIdSet], 'Id');
    for (Case c : newCasesMap.values()) {
        if (!String.isBlank(oldMap.get(c.Id).OwnerId) && !String.isBlank(c.OwnerId)) {
            String oldOwner = (String) oldMap.get(c.Id).OwnerId;
            String newOwner = (String) c.OwnerId;
            if (oldMap.get(c.Id).OwnerId != c.OwnerId && (oldOwner.startsWith('005') || newOwner.startsWith('005')) && userMap.containsKey(c.OwnerId)) {
                Case modifiedCase = new Case(
                    Id = c.Id,
                    CRM_OwnerPolo__c = (String) userMap.get(c.OwnerId).get('CRM_Polo__c'),
                    CRM_OwnerTeam__c = (String) userMap.get(c.OwnerId).get('CRM_Team__c')
                );
                if (String.isBlank(modifiedCase.CRM_FirstOwnerPolo__c)) modifiedCase.CRM_FirstOwnerPolo__c = (String) userMap.get(c.OwnerId).get('CRM_Polo__c');
                if (String.isBlank(modifiedCase.CRM_FirstOwnerTeam__c)) modifiedCase.CRM_FirstOwnerTeam__c = (String) userMap.get(c.OwnerId).get('CRM_Team__c');
                casesToUpdate.add(modifiedCase);
            }
        }
    }


    if (!casesToUpdate.isEmpty()) {
        try {
            update casesToUpdate;
        } catch (Exception e) {
            system.debug('Exception occurred: ' + e.getMessage());
        }
    }
}

  /*  public static void switchCaseTeam(List<Case> newCases, Map<Id,Case> oldMap){
            List<String> changedOwnerCaseIds = new List<String>();
            Map<String,List<Case>> newOwnerIdsToCaseMap = new Map<String,List<Case>>();
            for(Case c: newCases){
                if(!String.isBlank(oldMap.get(c.Id).OwnerId) && !String.isBlank(c.OwnerId)){

                    String oldOwner=(String)oldMap.get(c.Id).OwnerId;
                    String newOwner=(String)c.OwnerId;
                    if(oldMap.get(c.Id).OwnerId!=c.OwnerId && (oldOwner.startsWith('005') || newOwner.startsWith('005'))){
                        changedOwnerCaseIds.add(c.Id);
                        if(newOwnerIdsToCaseMap.containsKey(c.OwnerId)){
                            List<Case> listCase=newOwnerIdsToCaseMap.get(c.OwnerId);
                            listCase.add(c);
                            newOwnerIdsToCaseMap.put(c.OwnerId,listCase);
                        }
                        else{
                            List<Case> listCase=new List<Case>();
                            listCase.add(c);
                            newOwnerIdsToCaseMap.put(c.OwnerId,listCase);
                        }
                    }
                }
            }
            List<CaseTeamTemplateRecord> teamToDel=[SELECT
                                                    Id
                                                    FROM CaseTeamTemplateRecord WHERE ParentId IN:changedOwnerCaseIds];
            if(teamToDel.size()>0){
                delete teamToDel;
            }
            
            List<CaseTeamTemplateMember> templateMembers=[SELECT Id,LastModifiedById,LastModifiedDate,MemberId,SystemModstamp,TeamRoleId,TeamTemplateId
                                                        FROM CaseTeamTemplateMember WHERE MemberId IN:newOwnerIdsToCaseMap.keySet()];
            Map<Id,CaseTeamTemplate> templateMap = new Map<Id,CaseTeamTemplate>([SELECT Id, Name FROM CaseTeamTemplate WHERE Id IN (SELECT TeamTemplateId
                                                                                FROM CaseTeamTemplateMember WHERE MemberId IN:newOwnerIdsToCaseMap.keySet())]);
            

            Map<Id,String> caseIdtoTemplateNameMap= new Map<Id,String>();
            List<CaseTeamTemplateRecord> templateRecords= new List<CaseTeamTemplateRecord>();
            if(templateMembers.size()>0){
                for(CaseTeamTemplateMember tm:templateMembers){
                    for(Case c:newOwnerIdsToCaseMap.get(tm.MemberId)){
                        CaseTeamTemplateRecord tr=  new CaseTeamTemplateRecord();
                        tr.ParentId=c.Id;
                        tr.TeamTemplateId=tm.TeamTemplateId;
                        templateRecords.add(tr);
                        caseIdtoTemplateNameMap.put(c.Id, templateMap.get(tm.TeamTemplateId).Name);
                    }
                }
                if (templateRecords.size()>0){
                    insert templateRecords;
                }

                List<Case> caseToUpdate= [SELECT Id, OwnerId, CRM_FirstOwnerPolo__c, CRM_FirstOwnerTeam__c   FROM Case WHERE Id IN: caseIdtoTemplateNameMap.keySet() ];
                for(Case c:caseToUpdate){
                    c.CRM_OwnerPolo__c= caseIdtoTemplateNameMap.get(c.Id).contains('_') ?      caseIdtoTemplateNameMap.get(c.Id).split('_')[0] : null;
                    c.CRM_OwnerTeam__c= caseIdtoTemplateNameMap.get(c.Id).contains('_') ?      caseIdtoTemplateNameMap.get(c.Id).split('_')[1] : null;
                    if(String.isBlank(c.CRM_FirstOwnerPolo__c)) c.CRM_FirstOwnerPolo__c=c.CRM_OwnerPolo__c;
                    if(String.isBlank(c.CRM_FirstOwnerTeam__c)) c.CRM_FirstOwnerTeam__c=c.CRM_OwnerTeam__c;
                }
                if(caseToUpdate.size()>0){
                    update caseToUpdate;
                }
                

            }       
            
    } */
    
    public static void setOwnerTeamPolo (List<Case> newCases, Map<Id,Case> oldMap) {
        List<Case> casesToInsert = new List<Case>();
        // User userInfo = [SELECT Id, CRM_Team__c, CRM_Polo__c  FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];
        Set<String> ownerIdSet = SV_Utilities.keyBy(newCases, 'OwnerId').keySet();
        Map<String, SObject> userMap = SV_Utilities.keyBy([SELECT Id, CRM_Team__c, CRM_Polo__c  FROM User WHERE Id = :ownerIdSet], 'Id') ;
        for(Case c: newCases){
            String newOwner=(String)c.OwnerId;
            if(newOwner != null) {
                if(newOwner.startsWith('005')){
                    Case createdCase = new Case(
                    Id = c.Id,
                    CRM_OwnerPolo__c = (String) userMap.get(c.OwnerId).get('CRM_Polo__c'),
                    CRM_OwnerTeam__c = (String) userMap.get(c.OwnerId).get('CRM_Team__c')
                );
                if (String.isBlank(createdCase.CRM_FirstOwnerPolo__c)) createdCase.CRM_FirstOwnerPolo__c = (String) userMap.get(c.OwnerId).get('CRM_Polo__c');
                if (String.isBlank(createdCase.CRM_FirstOwnerTeam__c)) createdCase.CRM_FirstOwnerTeam__c = (String) userMap.get(c.OwnerId).get('CRM_Team__c');
                casesToInsert.add(createdCase);
                }
                
            }
            
        }
        
		if (!casesToInsert.isEmpty()) {
        try {
            update casesToInsert;
        } catch (Exception e) {
            system.debug('Exception occurred: ' + e.getMessage());
        }
    }        
        /*if(caseToUpdate.size()>0){
            skipCustomValidation=true;
            update caseToUpdate;
        }*/
    }
    
    public static void createCaseTeam(List<Case> newCases, Map<Id,Case> oldMap){
        Map<String,List<Case>> newOwnerIdsToCaseMap = new Map<String,List<Case>>();
        for(Case c: newCases){
            String newOwner=(String)c.OwnerId;
            if(newOwner.startsWith('005')){
                if(newOwnerIdsToCaseMap.containsKey(c.OwnerId)){
                    List<Case> listCase=newOwnerIdsToCaseMap.get(c.OwnerId);
                    listCase.add(c);
                    newOwnerIdsToCaseMap.put(c.OwnerId,listCase);
                }
                else{
                    List<Case> listCase=new List<Case>();
                    listCase.add(c);
                    newOwnerIdsToCaseMap.put(c.OwnerId,listCase);
                }
            }
            
        }

        List<CaseTeamTemplateMember> templateMembers=[SELECT Id,LastModifiedById,LastModifiedDate,MemberId,SystemModstamp,TeamRoleId,TeamTemplateId
                                                        FROM CaseTeamTemplateMember WHERE MemberId IN:newOwnerIdsToCaseMap.keySet()];
        Map<Id,CaseTeamTemplate> templateMap = new Map<Id,CaseTeamTemplate>([SELECT Id, Name FROM CaseTeamTemplate WHERE Id IN (SELECT TeamTemplateId
                                                        FROM CaseTeamTemplateMember WHERE MemberId IN:newOwnerIdsToCaseMap.keySet())]);                                                
        
        Map<Id,String> caseIdtoTemplateNameMap= new Map<Id,String>();
        List<CaseTeamTemplateRecord> templateRecords= new List<CaseTeamTemplateRecord>();
        if(templateMembers.size()>0){
            for(CaseTeamTemplateMember tm:templateMembers){
                for(Case c:newOwnerIdsToCaseMap.get(tm.MemberId)){
                    CaseTeamTemplateRecord tr=  new CaseTeamTemplateRecord();
                    tr.ParentId=c.Id;
                    tr.TeamTemplateId=tm.TeamTemplateId;
                    caseIdtoTemplateNameMap.put(c.Id, templateMap.get(tm.TeamTemplateId).Name);
                    templateRecords.add(tr);
                }
            }
            if (templateRecords.size()>0){
                insert templateRecords;
            }
    
            List<Case> caseToUpdate= [SELECT Id, OwnerId FROM Case WHERE Id IN: caseIdtoTemplateNameMap.keySet() ];

            for(Case c:caseToUpdate){
                c.CRM_OwnerPolo__c= caseIdtoTemplateNameMap.get(c.Id).contains('_') ?      caseIdtoTemplateNameMap.get(c.Id).split('_')[0] : null;
                c.CRM_OwnerTeam__c= caseIdtoTemplateNameMap.get(c.Id).contains('_') ?      caseIdtoTemplateNameMap.get(c.Id).split('_')[1] : null;
                c.CRM_FirstOwnerPolo__c=c.CRM_OwnerPolo__c;
                c.CRM_FirstOwnerTeam__c=c.CRM_OwnerTeam__c;
            }
            if(caseToUpdate.size()>0){
                skipCustomValidation=true;
                update caseToUpdate;
            }
            
        }                                                                  
    }
    //setFirstOwner rinominato in setFields
    public static void setFields(List<Case> newCases, Map<Id,Case> oldMap, Boolean isUpdate){
        system.debug('OnCaseTriggerHandler setFields start');  
        List<User> automatedProcess=[select id from user where Name='Automated Process'];
        List<Id> caseToUpdateIds = new List<Id>();
        if(!isUpdate){
            for(Case c: newCases){
                System.debug('***setFirstOwner owner id: '+ c.OwnerId);
                if(!String.isBlank(c.OwnerId)){
                    String owner=(String) c.OwnerId;
                    if(owner.startsWith('005') && owner!=automatedProcess[0].Id ){
                        c.CRM_FirstOwner__c=c.OwnerId;
                    }
                }
            }
        }
        else if(isUpdate){
            for(Case c: newCases){
                String owner=(String) c.OwnerId;
                if(owner.startsWith('005') && owner!=automatedProcess[0].Id && String.isBlank(c.CRM_FirstOwner__c)){
                    c.CRM_FirstOwner__c=c.OwnerId;
                }
                //alessandro di nardo @ten 24/05/2023
                if(c.Status != oldMap.get(c.Id).Status){
                    c.CC_DataUltimaModificaEsitazione__c= Date.today();
                }
            }
        }

    }

    public static void fromUsertoQueue(List<Case> newCases, Map<Id,Case> oldMap){
        system.debug('OnCaseTriggerHandler fromUsertoQueue start');  
        for(Case c:newCases){
            System.debug('***fromUsertoQueue old owner id: '+ oldMap.get(c.Id).OwnerId);
            System.debug('***fromUsertoQueue owner id: '+ c.OwnerId);
            if(!String.isBlank(oldMap.get(c.Id).OwnerId) && !String.isBlank(c.OwnerId)){
                String oldOwner=(String)oldMap.get(c.Id).OwnerId;
                String newOwner=(String)c.OwnerId;
                if(oldOwner.startsWith('005') && newOwner.startsWith('00G')){
                    c.CRM_OwnerPolo__c= '';
                    c.CRM_OwnerTeam__c= '';
                }
            }
        }
    }

    public static void customValidation(List<Case> newCases, Map<Id,Case> oldMap){
        system.debug('OnCaseTriggerHandler customValidation start');  
        if(!skipCustomValidation){
            List<Profile> profile=[SELECT Id FROM Profile WHERE Name=:Label.System_Administrator];
            List<Profile> profileBrand=[SELECT Id FROM Profile WHERE Name='Brand & Marketing Communication'];
            for(Case c:newCases){
                List<String> errorMessage= new List<String>();    
                if('Whatsapp'.equalsIgnoreCase(c.Origin)){
                    if( (!String.isBlank(c.CRM_Hesitation__c) && !'Attesa azione cliente'.equalsIgnoreCase(c.CRM_Hesitation__c) && !'Non esitato'.equalsIgnoreCase(c.CRM_Hesitation__c) && String.isBlank(c.CRM_Notes__c)) && ( !'Not Classifiable'.equalsIgnoreCase(c.CRM_Area__c) && String.isBlank(c.CRM_Notes__c) ) && !'No feedback cliente'.equalsIgnoreCase(c.CRM_Hesitation__c) )  errorMessage.add(' Valorizzare obbligatoriamente il campo Note');
                }else{
                    if(!c.Check_AgentWork_flow_start__c){
                        if(String.isNotBlank(c.CRM_Scope__c) && String.isBlank(c.CRM_Notes__c ) && UserInfo.getProfileId()!=profile[0].Id && UserInfo.getProfileId()!=profileBrand[0].Id && !c.CRM_IsStartedFlow__c && UserInfo.getName()!='Automated Process' && String.isNotBlank(c.AccountId)) errorMessage.add(' Valorizzare obbligatoriamente il campo Note');
                        if(c.CRM_Hesitation__c=='Ticket' && String.isBlank(c.CRM_TicketBhelp__c ) && UserInfo.getProfileId()!=profile[0].Id && !c.CRM_IsStartedFlow__c && UserInfo.getName()!='Automated Process') errorMessage.add(' Inserire obbligatoriamente un valore nel campo \'Ticket Bhelp\'');
                    } else {
                        c.Check_AgentWork_flow_start__c = false;
                    }
                }
                
                if(errorMessage.size()>0){
                    c.addError(String.join(errorMessage, ','));
                }
            }         
        }  
    }

    public static void makeCalloutCase(Map<Id,Case> newCaseMap, Map<Id,Case> oldCaseMap){

        sYSTEM.DEBUG('DK start makeCalloutCase');
        Set<Id> caseCallIdList = new Set<Id>();
        Set<String> esitiValidi = new Set<String>{'FORNITE INFO', 'ESEGUITA OPERAZIONE'};

        List<Account> clienteAnonimo = [SELECT Id FROM Account WHERE CRM_NDG__c = '000000000' AND name = 'Cliente Anonimo' LIMIT 1];
        
        for (Id caseId : newCaseMap.keyset()){

            sYSTEM.DEBUG('DK newCaseMap.Status: ' + newCaseMap.get(caseId).Status);
            sYSTEM.DEBUG('DK oldCaseMap.Status: ' + oldCaseMap.get(caseId).Status);
            sYSTEM.DEBUG('DK newCaseMap.CRM_Hesitation__c: ' + newCaseMap.get(caseId).CRM_Hesitation__c);
            sYSTEM.DEBUG('DK changed: ' + (oldCaseMap.get(caseId).Status != newCaseMap.get(caseId).Status));

            if(oldCaseMap.get(caseId).Status != newCaseMap.get(caseId).Status &&
                newCaseMap.get(caseId).Status == 'Closed' &&
                esitiValidi.contains(newCaseMap.get(caseId).CRM_Hesitation__c.toUpperCase()) &&
                newCaseMap.get(caseId).AccountId != null &&
                !newCaseMap.get(caseId).Social_IsSocial__c){
                
                if(!clienteAnonimo.isEmpty() && clienteAnonimo[0].Id != newCaseMap.get(caseId).AccountId){

                    caseCallIdList.add(caseId);
                }
            }
        }
        sYSTEM.DEBUG('DK caseCallIdList: ' + caseCallIdList);

        if(!caseCallIdList.isEmpty()){
            
            
            for(Id caseId : caseCallIdList){

                sendRequest(caseId);
            }
        }
    }

    @future(callout=true)
    public static void sendRequest(Id caseId){
       
        Map<String, Object> response = (Map<String, Object>)JSON.deserializeUntyped(MakeRequestController.makeRequest('inserisciEventoContactCenter_Case', caseId, fieldMap, null, 'salesforceprodclient2024', '',false));
        System.debug('DK response: ' + response);
        if((String)response.get('statusCode') != '204'){

            insert new SV_FailedRequest__c(RequestName__c = 'inserisciEventoContactCenter_Case',
                                RecordId__c = caseId,
                                FieldsMap__c = JSON.serialize(fieldMap),
                                CertificationName__c = 'salesforceprodclient2024');
        }
    }

    /*public static void publishEvent(List<Case> newCases, Map<Id,Case> oldMap){
        List<CaseDataTableEvent__e> eventList = new List<CaseDataTableEvent__e>();
        for(Case c:newCases){
            CaseDataTableEvent__e event = new CaseDataTableEvent__e();
            event.CaseId__c=c.Id;
            event.UserId__c=UserInfo.getUserId();
            eventList.add(event);
        }
        EventBus.publish(eventList);
    }*/

    public static void checkFinancialAccountRole(List<Case> newCases, Map<Id,Case> oldMap, Boolean isUpdate){
        if(!isUpdate){
            List<String> productIds = new List<String>();
            for(Case c: newCases){
                if(String.isNotBlank(c.FinServ__FinancialAccount__c)){
                    productIds.add(c.FinServ__FinancialAccount__c);
                }
            }
            List<FinServ__FinancialAccountRole__c> roleList= [SELECT FinServ__FinancialAccount__c, FinServ__RelatedAccount__c FROM FinServ__FinancialAccountRole__c WHERE FinServ__FinancialAccount__c IN:productIds AND FinServ__EndDate__c=null];
            Map<String, Set<String>> productToAccounts= new Map<String, Set<String>>();
            for(FinServ__FinancialAccountRole__c role:roleList){
                String key = role.FinServ__FinancialAccount__c;
                if(!productToAccounts.containsKey(key)){
                    productToAccounts.put(key, new Set<String>());
                }
                productToAccounts.get(role.FinServ__FinancialAccount__c).add(role.FinServ__RelatedAccount__c);
            }
            System.debug('@@@productToAccounts: '+JSON.serialize(productToAccounts));
            for(Case c: newCases){
                if(String.isNotBlank(c.FinServ__FinancialAccount__c) ){
                    if(!productToAccounts.containsKey(c.FinServ__FinancialAccount__c)){
                        System.debug('@@@sonoqui'+c.AccountId+'_'+c.FinServ__FinancialAccount__c);
                        c.addError('Non è possibile associare questo prodotto al caso perché il prodotto fa riferimento ad un altro cliente');
                    }
                    else if(!productToAccounts.get(c.FinServ__FinancialAccount__c).contains(c.AccountId)){
                        System.debug('@@@sonoqui'+c.AccountId+'_'+c.FinServ__FinancialAccount__c);
                        c.addError('Non è possibile associare questo prodotto al caso perché il prodotto fa riferimento ad un altro cliente');
                    }
                }
            }
        }
        else{
            List<String> productIds = new List<String>();
            for(Case c: newCases){
                if(String.isNotBlank(c.FinServ__FinancialAccount__c) && c.FinServ__FinancialAccount__c!=oldMap.get(c.Id).FinServ__FinancialAccount__c){
                    productIds.add(c.FinServ__FinancialAccount__c);
                }
            }
            List<FinServ__FinancialAccountRole__c> roleList= [SELECT FinServ__FinancialAccount__c, FinServ__RelatedAccount__c FROM FinServ__FinancialAccountRole__c WHERE FinServ__FinancialAccount__c IN:productIds AND FinServ__EndDate__c=null];
            Map<String, Set<String>> productToAccounts= new Map<String, Set<String>>();
            for(FinServ__FinancialAccountRole__c role:roleList){
                String key = role.FinServ__FinancialAccount__c;
                if(!productToAccounts.containsKey(key)){
                    productToAccounts.put(key, new Set<String>());
                }
                productToAccounts.get(role.FinServ__FinancialAccount__c).add(role.FinServ__RelatedAccount__c);
            }
            System.debug('@@@productToAccounts: '+JSON.serialize(productToAccounts));
            for(Case c: newCases){
                if(String.isNotBlank(c.FinServ__FinancialAccount__c) && c.FinServ__FinancialAccount__c!=oldMap.get(c.Id).FinServ__FinancialAccount__c) {
                    if(!productToAccounts.containsKey(c.FinServ__FinancialAccount__c)){
                        System.debug('@@@sonoqui'+c.AccountId+'_'+c.FinServ__FinancialAccount__c);
                        c.addError('Non è possibile associare questo prodotto al caso perché il prodotto fa riferimento ad un altro cliente');
                    }
                    else if(!productToAccounts.get(c.FinServ__FinancialAccount__c).contains(c.AccountId)){
                        System.debug('@@@sonoqui'+c.AccountId+'_'+c.FinServ__FinancialAccount__c);
                        c.addError('Non è possibile associare questo prodotto al caso perché il prodotto fa riferimento ad un altro cliente');
                    }
                }
            }
        }
    }

    public static void trackHistory(Map<Id, Case> oldTriggerCaseMap, Map<Id, Case> newTriggerCaseMap){
    
        //Get apiname of object (Case)
        String objApiName = String.valueOf(newTriggerCaseMap.getSObjectType());
        String standardCaseRT = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Standard_Case').getRecordTypeId(); //valerio.salvati 21/06/2022
        String rtToTrack; //valerio.salvati 21/06/2022
        //Get data information from metadata
        TrackingHistoryConfiguration__mdt[] metadataList = [SELECT ParentField__c, TrackingFieldList__c,
                                                            RecordTypeDevName__c, ObjectDevName__c
                                                            FROM TrackingHistoryConfiguration__mdt
                                                            WHERE ObjectDevName__c = :objApiName
                                                            LIMIT 1];
        
        if(metadataList.size() > 0 && !trafficLightTrackingTrigger){
            TrackingHistoryConfiguration__mdt metadataObj = metadataList.get(0);
        
            //For each record, for each field to track, create a tracking object
            String recordTypeIdString = Schema.SObjectType.TrackingHistory__c.getRecordTypeInfosByDeveloperName().get(metadataObj.RecordTypeDevName__c).getRecordTypeId();
            List<String> trackingFieldList = metadataObj.TrackingFieldList__c.split(';');
            List<TrackingHistory__c> trackingObjects = new List<TrackingHistory__c>();
            
            for(Case newTriggerCase : newTriggerCaseMap.values()){
                for(String trackingField : trackingFieldList){
                    String oldValue;
                    String newValue = (String) newTriggerCase.get(trackingField);
                    
                    if(!(oldTriggerCaseMap == null || oldTriggerCaseMap.isEmpty())){
                        Case oldTriggerCase = oldTriggerCaseMap.get(newTriggerCase.id);
                        oldValue = (String) oldTriggerCase.get(trackingField);
                    }

                    if((!String.isBlank(newValue) && String.isBlank(oldValue)) || (!String.isBlank(newValue) && !String.isBlank(oldValue) && !(newValue.equals(oldValue)))){
                        rtToTrack = String.isBlank(newTriggerCase.RecordTypeId) ? standardCaseRT : newTriggerCase.RecordTypeId; //valerio.salvati 21/06/2022
                        TrackingHistory__c trackingObj = new TrackingHistory__c(
                                                        RecordTypeId = recordTypeIdString,
                                                        ParentObject__c = newTriggerCase.Id,
                                                        Cliente__c = newTriggerCase.AccountId,
                                                        Tracking_Field__c = trackingField,
                                                        //Tracking_ObjRecordType__c = Schema.SObjectType.Case.getRecordTypeInfosById().get(newTriggerCase.RecordTypeId).getDeveloperName(),
                                                        Tracking_ObjRecordType__c = Schema.SObjectType.Case.getRecordTypeInfosById().get(rtToTrack).getDeveloperName(), //valerio.salvati 21/06/2022
                                                        OldValue__c = oldValue,
                                                        NewValue__c = newValue);
                        //get dynamically the field API name which contains the record id from metadata
                        trackingObj.put(metadataObj.ParentField__c, newTriggerCase.id);
                        
                        trackingObjects.add(trackingObj);
                    }

                }
            }
            
            insert trackingObjects;
        }
        
        
    }

    /*public static void linkChatInteraction(List<Case> newCases){
        if (newCases.size() == 1 && 'SI'.equalsIgnoreCase(newCases[0].CRM_CasefromNewPrechatForm__c)){
            Case chatCase = newCases[0];
            List<LiveChatTranscript> lctList = [SELECT Id FROM LiveChatTranscript WHERE CaseId =: chatCase.Id ORDER BY CreatedDate DESC];
            if(!lctList.isEmpty()){
                List<External_Routing_Bean__c> beanList = [SELECT Id, Interaction_Id__c FROM External_Routing_Bean__c  WHERE PreChat_Id__c =: lctList[0].Id ORDER BY CreatedDate DESC];
                if(!beanList.isEmpty()){
                    chatCase.CRM_CTIContactId__c = beanList[0].Interaction_Id__c;
                    update chatCase;
                }
            }
            //if(!lctList.isEmpty()) ExternalRoutingChat.CalloutOutbound(lctList[0].Id);
        }
    } */

    public static void linkChatOrWhatsappCase(List<Case> newCases){
        if     (newCases.size() == 1 && 'SI'.equalsIgnoreCase(newCases[0].CRM_CasefromNewPrechatForm__c))   fillChatCase(newCases);
        else if(newCases.size() == 1 && 'WhatsApp'.equalsIgnoreCase(newCases[0].Origin) 
                &&  (!'Cliente autenticato'.equalsIgnoreCase(newCases[0].CRM_CustomerAuthenticationType__c) 
                && String.isBlank(newCases[0].AccountId)) ) findAccountFromPhone(newCases);
                
        if(newCases.size() == 1 && 'Web'.equalsIgnoreCase(newCases[0].Origin)){
            //findAccountFromCfOrPiva(newcases[0]);
            fillChatCase(newcases);
        }
    }
    
    /*public static void findAccountFromCfOrPiva(Case c){
        List<Account> accList = new List<Account>();
        if(!String.isBlank(c.CRM_CodiceFiscalePartitaIva__c)) accList = findChatAccountSosl(c.CRM_CodiceFiscalePartitaIva__c,null,null,'Account');
        if(accList.size() == 1){
            c.AccountId = (String)accList[0].get('Id');
        c.CRM_CustomerAuthenticationType__c = 'Cliente anonimo';
        }
        if (accList.size() > 1) c.CRM_CustomerAuthenticationType__c = 'Cliente da disambiguare';

    }*/

    public static void linkWebCase(List<Case> newCases){
        
    }



    //valerio salvati
    public static void fillChatCase(List<Case> newCases){
        System.debug('fillChatCase START - size:' + newCases.size()  + '; Is prechat: ' + newCases[0].CRM_CasefromNewPrechatForm__c);

        Case chatCase = newCases[0];
        System.debug('fillChatCase chatCase: ' + chatCase);

        List<Account> accList = new List<Account>();
        List<CRM_Channel__c> channelList = new List<CRM_Channel__c>();
        //Account acc;
        try{
            if(String.isBlank(chatCase.CRM_CryptoString__c)){
                if(!String.isBlank(chatCase.Data_di_nascita__c)){
                    if(!String.isBlank(chatCase.CRM_CodiceFiscalePartitaIva__c)){
                        accList = findChatAccountSosl(chatCase.CRM_CodiceFiscalePartitaIva__c,null,null,'Account');
                    }
                    if(accList.isEmpty()){
                        accList = findChatAccountSosl(chatCase.CRM_WebChannelName__c,'CRM_StringBirthDate__c',chatCase.Data_di_nascita__c,'Account');
                    }

                }else{
                    accList = findChatAccountSosl(chatCase.CRM_CodiceFiscalePartitaIva__c,null,null,'Account');
                }
                if(!accList.isEmpty() && accList.size() == 1){
                    chatCase.AccountId = (String)accList[0].get('Id');
                    chatCase.CRM_CustomerAuthenticationType__c = 'Cliente riconosciuto';
                }else if(accList.size() > 1) chatCase.CRM_CustomerAuthenticationType__c = 'Cliente da disambiguare';


            }else{
                ParametriEncryption__c cs = ParametriEncryption__c.getInstance();
                //Blob exampleIv = Blob.valueOf('encryptionIntVec'); 
                //Blob key = Blob.valueOf('aesEncryptionKey'); 
                Blob exampleIv = Blob.valueOf(cs.ExampleIv__c); 
                Blob key = Blob.valueOf(cs.Key__c); 
                Blob decrypted = Crypto.decrypt('AES128', key, exampleIv, EncodingUtil.base64Decode(chatCase.CRM_CryptoString__c)); 
                String decryptedString = decrypted.toString(); 
                System.debug('Data to be dencrypted: ' + decryptedString); 

                chatCase.CRM_DeCryptoString__c = decryptedString;
                Map<String, Object> fieldMap = (Map<String, Object>) JSON.deserializeUntyped(decryptedString);
                String ndgCode = (String)fieldMap.get('ndg');
                String abi = (String)fieldMap.get('cstatus');
                String externalId = abi+'_'+ndgCode;
                accList = [SELECT Id FROM Account WHERE NDW_ExternalId__c  =: externalId];
                if(!accList.isEmpty() && accList.size() == 1){
                    chatCase.AccountId = accList[0].Id;
                    chatCase.CRM_CustomerAuthenticationType__c = 'Cliente autenticato';
                }
            }
            if(accList.isEmpty()) chatCase.CRM_CustomerAuthenticationType__c = 'Cliente anonimo';

        }catch(Exception ex){
            System.debug('fillChatCase Exception: ' + ex  + '; Stacktrace: ' + ex.getStackTraceString());
        }
        

    }

    public static void findAccountFromPhone(List<Case> newCases){
            Case chatCase = newCases[0];
            String phone = chatCase.CRM_TelefonoWhatsApp__c.replace('+39','');
            String QueryString =  'FIND \'' + (!String.isBlank(phone) ? String.escapeSingleQuotes(phone) : '') + '\' IN PHONE FIELDS RETURNING';
            QueryString += ' Account (Id, Name, CRM_SmartWebMobilePhone__c, Phone, CRM_Phone1__c,CRM_Phone2__c, CRM_PhoneBpercard__c, CRM_Cellulare_aziendale_Bpercard__c WHERE Recordtype.DeveloperName != \'Cointestazione\')';
            System.debug('routingWhatsapp query: '+QueryString);
            List<List<SObject>> searchList = search.query(queryString);
            System.debug('searchList: '+searchList);
            System.debug('searchList 0 size: '+searchList[0].size());

            Account accountToOpen = new Account();
            List<Account> list1 = new List<Account>();
            List<Account> list2 = new List<Account>();
            List<Account> list3 = new List<Account>();
            List<Account> list4 = new List<Account>();
            List<Account> list5 = new List<Account>();
            List<Account> list6 = new List<Account>();

            Integer phoneFound = 0;

            for(Account a: (List<Account>) searchList[0]){
            System.debug('searchList size: '+searchList.size());

                if(String.isNotBlank(a.CRM_SmartWebMobilePhone__c) && a.CRM_SmartWebMobilePhone__c.endsWith(phone)){ list1.add(a); phoneFound++;}
                else if(String.isNotBlank(a.Phone) && a.Phone.endsWith(phone)){ list2.add(a); phoneFound++;}
                else if(String.isNotBlank(a.CRM_Phone1__c) && a.CRM_Phone1__c.endsWith(phone)){ list3.add(a); phoneFound++;}
                else if(String.isNotBlank(a.CRM_Phone2__c) && a.CRM_Phone2__c.endsWith(phone)){ list4.add(a); phoneFound++;}
                else if(String.isNotBlank(a.CRM_PhoneBpercard__c) && a.CRM_PhoneBpercard__c.endsWith(phone)){ list5.add(a); phoneFound++;}
                else if(String.isNotBlank(a.CRM_Cellulare_aziendale_Bpercard__c) && a.CRM_Cellulare_aziendale_Bpercard__c.endsWith(phone)){ list6.add(a); phoneFound++;}
            }
            if(phoneFound == 0) chatCase.CRM_CustomerAuthenticationType__c = 'Cliente anonimo';
            else if(phoneFound == 1){
                if (!list1.isEmpty()) chatCase.AccountId = list1[0].Id;
                if (!list2.isEmpty()) chatCase.AccountId = list2[0].Id;
                if (!list3.isEmpty()) chatCase.AccountId = list3[0].Id;
                if (!list4.isEmpty()) chatCase.AccountId = list4[0].Id;
                if (!list5.isEmpty()) chatCase.AccountId = list5[0].Id;
                if (!list6.isEmpty()) chatCase.AccountId = list6[0].Id;

                /*if('De-enrollment'.equalsIgnoreCase(chatCase.CRM_Level2__c)) chatCase.CRM_CustomerAuthenticationType__c = 'Cliente autenticato';
                else */ 
                chatCase.CRM_CustomerAuthenticationType__c = 'Cliente riconosciuto';

            }
            else chatCase.CRM_CustomerAuthenticationType__c = 'Cliente da disambiguare';

            //List<MessagingSession> messagingList = [SELECT Id FROM MessagingSession WHERE CaseId=: chatCase.Id ORDER BY CreatedDate DESC];
            //if(!messagingList.isEmpty() && !Test.isRunningTest()) ExternalRoutingWhatsapp.CalloutOutbound(messagingList[0].Id);
        
    }

    //valerio salvati
    public static List<SObject> findChatAccountSosl(String toSearch, String additionalFilterName, String additionalFilterValue, String objName){
        
        String QueryString =  'FIND \'' + (!String.isBlank(toSearch) ? String.escapeSingleQuotes(toSearch) : '') + '\' IN ALL FIELDS RETURNING';
        if(objName.equalsIgnoreCase('Account')) QueryString += ' Account (Id, Name,CRM_StringBirthDate__c, CRM_VAT__c, CRM_TaxId__c ';
        if(objName.equalsIgnoreCase('CRM_Channel__c')) QueryString += ' CRM_Channel__c (Id, CRM_UserCode__c, CRM_Account__c ';

        if(additionalFilterName != null) QueryString += 'WHERE '+(!String.isBlank(additionalFilterName) ? String.escapeSingleQuotes(additionalFilterName) : '')+' = \''+(!String.isBlank(additionalFilterValue) ? String.escapeSingleQuotes(additionalFilterValue) : '')+'\'';
        if(objName.equalsIgnoreCase('Account')){
            QueryString += additionalFilterName != null ? ' AND Recordtype.DeveloperName != \'Cointestazione\'' : ' WHERE Recordtype.DeveloperName != \'Cointestazione\'';
        }
        QueryString += ' )';
        QueryString += ' WITH SPELL_CORRECTION = false';
        System.debug('findChatAccountSosl: '+QueryString);
        List<List<SObject>> searchList = search.query(queryString);
        System.debug('searchList: '+searchList.size());
        return searchList[0];

    }
}