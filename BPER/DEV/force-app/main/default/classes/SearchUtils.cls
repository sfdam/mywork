public class SearchUtils {
    public static final String NO_STEP_NAME = 'Richiesta di approvazione sottomessa';

    @AuraEnabled
    public static List<SObject> getReferentePrincipale(String recordId, String refType) {
        List<Account> accs = [SELECT PTF_Portafoglio__c FROM Account WHERE Id = :recordId];
        if (accs.size() > 0) {
            Id mwId = accs[0].PTF_Portafoglio__c;
            List<Assignment__c> ass;
            if (refType == 'Principali') {
                ass = [SELECT Id, PTF_Gestore__c FROM Assignment__c WHERE PTF_MicroWallet__c = :mwId AND RecordType.DeveloperName = 'Primario' AND PTF_EndDate__c = null];
            } else {
                ass = [SELECT Id, PTF_Gestore__c FROM Assignment__c WHERE PTF_MicroWallet__c = :mwId AND RecordType.DeveloperName = 'Backup' AND PTF_EndDate__c = null];
            }
            List<Id> gbIds = new List<Id>();
            for (Assignment__c a : ass) gbIds.add(a.PTF_Gestore__c);
            return [
                SELECT Id, FirstName, LastName, Email, Name, Account.Name, PTF_ModelloDiServizio__c, PTF_MDSConcatList__c, PTF_RegistrationNumber__c
                FROM Contact
                WHERE Id IN :gbIds
            ];
        } else return null;
    }

    @AuraEnabled
    public static Map<String,Object> getApprovalHistory(String recordId) {

        List<SearchUtils.ApprovalWrapper> aw = new List<SearchUtils.ApprovalWrapper>();
        List<string> actorIds = new list<String>();
        WorkOrder wo = [SELECT Id, PTF_StoriaAvocazione__c FROM WorkOrder WHERE Id =: recordId];
        List<ProcessInstance> pi = [SELECT Id, toLabel(Status), CreatedDate, CompletedDate, TargetObjectId, 
                                                (SELECT Id, toLabel(StepStatus), ActorId, Actor.Name, ElapsedTimeInDays, ElapsedTimeInMinutes, 
                                                CreatedDate, ProcessNodeId, ProcessNode.Name, Comments, OriginalActorId, OriginalActor.Name
                                                FROM StepsAndWorkitems ORDER BY CreatedDate DESC) from ProcessInstance 
                                                Where TargetObjectId =: recordId ORDER BY CreatedDate DESC];

        
        Map<String, Contact> avocazioneMap = new Map<String, Contact>();
        Set<String> avocatoriRegistrationNumberSet = new Set<String>();
        if(!String.isBlank(wo.PTF_StoriaAvocazione__c)){
            
            for(String avocazioni : wo.PTF_StoriaAvocazione__c.split(',')){
                avocatoriRegistrationNumberSet.add(avocazioni.substringBefore('_'));
            }
            
            Map<String, SObject> avocatoriMap = (Map<String, SObject>)SV_Utilities.keyBy([SELECT ID, Name, PTF_RegistrationNumber__c, PTF_User__c FROM Contact WHERE PTF_RegistrationNumber__c IN: avocatoriRegistrationNumberSet], 'PTF_RegistrationNumber__c');
            
            for(String avocazioni : wo.PTF_StoriaAvocazione__c.split(',')){
                
                String avocatoreRegistrationNumber = avocazioni.substringBefore('_');
                for(String queueId : avocazioni.substringAfter('_').split('-')){
                    
                    avocazioneMap.put(queueId, (Contact)avocatoriMap.get(avocatoreRegistrationNumber));
                }
            }
        }
        //CR NEC #59062: lo stato "Richiamato" viene sostituito con "Avocato"
        List<String> recalledStatusValues = new List<String> {'Recalled','Richiamato'};

        for(ProcessInstance pr :  pi){
            for(ProcessInstanceHistory  str : pr.StepsAndWorkitems) {
                System.debug('step node name = '+str.ProcessNode.Name);
                SearchUtils.ApprovalWrapper aw1 = new SearchUtils.ApprovalWrapper();
                aw1.stepName = str.ProcessNode.Name == null ? SearchUtils.NO_STEP_NAME : str.ProcessNode.Name;
                aw1.status = recalledStatusValues.contains(str.StepStatus) ? 'Avocato' : str.StepStatus;
                aw1.createdDate = str.CreatedDate.format('dd-MM-yyyy HH:mm');
                aw1.unformattedDate = str.CreatedDate;
                aw1.originalActorName = str.OriginalActor.Name;
                aw1.comments = str.Comments;
                aw1.assignedTo = avocazioneMap.containsKey(str.OriginalActorId) ?  avocazioneMap.get(str.OriginalActorId).Name : str.Actor.Name;
                aw1.actorId = avocazioneMap.containsKey(str.OriginalActorId) ?  avocazioneMap.get(str.OriginalActorId).PTF_User__c : str.ActorId;
                actorIds.add(str.ActorId);
                aw.add(aw1);
            }
        }
       
        Map<String, GroupMember> memberMap = (Map<String, GroupMember>)JSON.deserialize(JSON.serialize(SV_Utilities.keyBy([SELECT Id, GroupId, Group.Name, UserOrGroupId FROM GroupMember WHERE GroupId IN: actorIds], 'UserOrGroupId')), Map<String, groupmember>.class);
        Map<String, SObject> contactMap = SV_Utilities.keyBy([SELECT Id, Name, Account.Name, PTF_User__c FROM Contact WHERE PTF_User__c IN: memberMap.keyset() OR PTF_User__c IN: actorIds OR PTF_RegistrationNumber__c IN: avocatoriRegistrationNumberSet],'PTF_User__c');
        
        return new Map<String,Object> {

            'ApprovalWrapper' => aw,
            'ContactList' => contactMap
        };
    }

    @AuraEnabled // Da refactorare, fatto rapidamente a fini di demo
    public static List<NDGApprovalWrapper> getNDGInSpostamento(String recordId) {
        List<NDGApprovalWrapper> ndgApprovalList = new List<NDGApprovalWrapper>();
        ProcessInstanceWorkItem[] piwiList = [SELECT Id, ProcessInstanceId FROM ProcessInstanceWorkItem WHERE Id =:recordId];
        ProcessInstance pi;
        if (piwiList.size() > 0) {
            ProcessInstanceWorkItem piwi = piwiList[0];
            pi = [SELECT Id, 
                    (SELECT Id, toLabel(StepStatus), Actor.Name, ProcessNodeId, ProcessNode.Name, OriginalActor.Name
                                                FROM StepsAndWorkitems),
            TargetObjectId FROM ProcessInstance WHERE Id =:piwi.ProcessInstanceId];
        } else {
            ProcessInstanceStep procInstStep = [SELECT Id, ProcessInstanceId FROM ProcessInstanceStep WHERE Id =:recordId];
            pi = [SELECT Id, 
                    (SELECT Id, toLabel(StepStatus), Actor.Name, ProcessNodeId, ProcessNode.Name, OriginalActor.Name
                                                FROM StepsAndWorkitems)
            TargetObjectId FROM ProcessInstance WHERE Id =:procInstStep.ProcessInstanceId];
        }
        Set<String> queueIdSet = SV_Utilities.keyBy([SELECT Id, UserOrGroupId, GroupId FROM GroupMember WHERE UserOrGroupId =: UserInfo.getUserId()], 'GroupId').keySet();

        
        List<WorkOrderLineItem> woli = [
                                            SELECT Id,LineItemNumber, Status, WorkOrderId, WorkOrder.WorkOrderNumber, AccountId__c, AccountId__r.Name, AccountId__r.CRM_NDG__c, PTF_NomeNDG__c, PTF_PTFOrigine__c, PTF_PTFDestinazione__c 
                                            FROM WorkOrderLineItem WHERE WorkOrderId =: pi.TargetObjectId 
                                        ];
        Set<Id> itemsId= new Set<Id>();
        for(WorkOrderLineItem w: woli){
            itemsId.add(w.Id);
        }

        Map<String,SObject> workItems=SV_Utilities.keyBy([SELECT Id, ActorId,  ProcessInstance.Status, ProcessInstance.TargetObjectId FROM ProcessInstanceWorkItem WHERE ProcessInstance.TargetObjectId IN:itemsId AND ActorId IN:queueIdSet], 'ProcessInstance.TargetObjectId');
        for (WorkOrderLineItem woliTemp : woli) {
            NDGApprovalWrapper ndgTemp = new NDGApprovalWrapper();
            ndgTemp.richiestaId =workItems.get(woliTemp.Id) != null ? (String) workItems.get(woliTemp.Id).get('Id') : '';
            ndgTemp.statusWOLI = woliTemp.Status;
            ndgTemp.richiestaNumber = woliTemp.LineItemNumber;
            ndgTemp.ndgId = woliTemp.AccountId__c;
            ndgTemp.ndgCode = woliTemp.AccountId__r.CRM_NDG__c;
            ndgTemp.ndgName = woliTemp.AccountId__r.Name;
            ndgTemp.ptfDestinazioneName = woliTemp.PTF_PTFDestinazione__c;
            ndgTemp.ptfOrigineName = woliTemp.PTF_PTFOrigine__c;
            ndgApprovalList.add(ndgTemp);
        }
        System.debug('ndgapprovallist = '+ndgApprovalList);
        return ndgApprovalList;
    }
    
    @AuraEnabled
    public static List<CustomWrapper> getRiferimentiAziendali(String recordId) {
        List<Account> rifAziendali = new List<Account>();
        CRM_Channel__c chnl = [SELECT Id, CRM_Account__c FROM CRM_Channel__c WHERE Id = :recordId][0];

        List<CRM_LinkedNDG__c> linked = [
            SELECT Id, CRM_Account__r.Name, CRM_RelatedAccountNDG__c, CRM_RelatedAccount__c, CRM_RelatedAccount__r.Name, CRM_LinkType__c, CRM_Status__c, CRM_EndDate__c
            FROM CRM_LinkedNDG__c
            WHERE CRM_Account__c = :chnl.CRM_Account__c
        ];

        List<CustomWrapper> cwList = new List<CustomWrapper>();
        for (CRM_LinkedNDG__c lndg : linked) {
            CustomWrapper cw = new CustomWrapper();
            cw.relatedNDG = lndg.CRM_RelatedAccountNDG__c;
            cw.relatedAccountUrl = '/' + lndg.CRM_RelatedAccount__c;
            cw.relatedAccountName = lndg.CRM_RelatedAccount__r.Name;
            cw.linkType = lndg.CRM_LinkType__c;
            cw.status = lndg.CRM_Status__c;
            cw.endDate = lndg.CRM_EndDate__c;
            cwList.add(cw);
        }
        return cwList;
    }

    public class NDGApprovalWrapper {
        @AuraEnabled
        public string richiestaId {get;set;}
        @AuraEnabled
        public string statusWOLI {get;set;}
        @AuraEnabled
        public string richiestaNumber {get;set;}
        @AuraEnabled
        public string ndgId {get;set;}
        @AuraEnabled
        public string ndgCode {get;set;}
        @AuraEnabled
        public String ndgName {get;set;}
        @AuraEnabled
        public string ptfOrigineName {get;set;}
        @AuraEnabled
        public string ptfDestinazioneName {get;set;}
    }
    
    @AuraEnabled
    public static List<ApprovalWrapper> getKnowledgeApprovals(String recordId) {
        List<ApprovalWrapper> aw = new List<ApprovalWrapper>();
        List<ProcessInstance> pi = [SELECT Id, toLabel(Status), CompletedDate, TargetObjectId, 
                                                (SELECT Id, toLabel(StepStatus), Actor.Name, ElapsedTimeInDays, ElapsedTimeInMinutes, 
                                                CreatedDate, ProcessNodeId, ProcessNode.Name, Comments, OriginalActorId, OriginalActor.Name
                                                FROM StepsAndWorkitems ORDER BY CreatedDate DESC) from ProcessInstance 
                                                Where TargetObjectId =: recordId];

        for(ProcessInstance pr :  pi){
            for(ProcessInstanceHistory  str : pr.StepsAndWorkitems) {
                System.debug('step node name = '+str.ProcessNode.Name);
                ApprovalWrapper aw1 = new ApprovalWrapper();
                aw1.stepName = str.ProcessNode.Name == null ? NO_STEP_NAME : str.ProcessNode.Name;
                aw1.createdDate = str.CreatedDate.format();
                aw1.status = str.StepStatus;
                aw1.originalActorName = str.OriginalActor.Name;
                aw1.assignedTo = str.Actor.Name;
                aw1.comments = str.Comments;
                aw.add(aw1);
            }
        }
        
        return aw;
    }
    
    public class ApprovalWrapper {	
        @AuraEnabled	
        public string stepName {get;set;}	
        @AuraEnabled	
        public String createdDate {get;set;}
        @AuraEnabled	
        public Datetime unformattedDate {get;set;}	
        @AuraEnabled	
        public String status {get;set;}	
        @AuraEnabled	
        public String comments {get;set;}	
        @AuraEnabled	
        public String originalActorName {get;set;}	
        @AuraEnabled	
        public String assignedTo {get;set;}
        @AuraEnabled
        public String actorId {get;set;}
    }

    public class SearchWrapper {
        @InvocableVariable
        public String filiale;
        @InvocableVariable
        public String modello;
    }
    
    public class CustomWrapper {
        @AuraEnabled
        public String relatedNDG {get;set;}
        @AuraEnabled
        public String relatedAccountUrl {get;set;}
        @AuraEnabled
        public String relatedAccountName {get;set;}
        @AuraEnabled
        public String linkType {get;set;}
        @AuraEnabled
        public String status {get;set;}
        @AuraEnabled
        public DateTime endDate {get;set;}
    }
}