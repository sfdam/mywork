public without sharing class ApprovalPendingHomeController {

    public static Map<String, IterConfiguration__c> iterConfigMap {
        get{
            if(iterConfigMap != null) return iterConfigMap;
            iterConfigMap = new Map<String, IterConfiguration__c>();
            for(IterConfiguration__c iterConfig : [SELECT UnitaOrganizzativa__c, TipoSpostamento__c, GiorniAnnullamento__c FROM IterConfiguration__c WHERE GiorniAnnullamento__c != NULL AND TipoSpostamento__c != NULL]){
                iterConfigMap.put(iterConfig.UnitaOrganizzativa__c + '_' + iterConfig.TipoSpostamento__c, iterConfig);
            }
            return iterConfigMap;
        }set;
    }
    
    public static FunzionalitaITER__c f = FunzionalitaITER__c.getOrgDefaults();
    
    // public static Integer days = f.TimeLimit__c != null? Integer.valueOf(f.TimeLimit__c): 30;
    public static Integer alertDays = f.AlertDays__c != null? Integer.valueOf(f.AlertDays__c): 5;
    public static Date initialDate = f.StartDate__c;
    public static Set<String> superUserSet = new Set<String>{'NEC_D.0', 'NEC_D.2', 'NEC_D.10'};
    public static Set<String> executiveIdcedSet = SV_Utilities.keyBy([SELECT Id, PTF_IdCED__c FROM Account WHERE Account.CRM_Nome__c LIKE '%Executive%'], 'PTF_IdCED__c').keySet();

    @AuraEnabled
    public static Map<String, Object> getAllData(){

        Boolean hasToClose = false;
        List<Map<String,Object>> aw = new List<Map<String,Object>>();
        Map<String, String> woIdMap = new Map<String, String>();
        Set<String> userSet = new Set<String>{UserInfo.getUserId()};
        for(user user : [SELECT Id FROM User WHERE DelegatedApproverId =: UserInfo.getUserId()]){
            userSet.add(user.Id);
        }
        Map<String, List<SObject>> queueMap = SV_Utilities.groupBy([SELECT Id, UserOrGroupId, GroupId FROM GroupMember WHERE UserOrGroupId IN: userSet], 'GroupId');
        User currentUser = [SELECT id, Profilo__c, IdCed__c FROM User WHERE Id =: UserInfo.getUserId()];
        if(executiveIdcedSet.contains(currentUser.IdCed__c))currentUser.Profilo__c = 'NEC_D.10';
        
        List<ProcessInstanceWorkItem> workItems=[SELECT Id, ActorId,  ProcessInstance.Status, ProcessInstance.TargetObjectId FROM ProcessInstanceWorkItem WHERE ProcessInstance.Status ='Pending' AND ActorId IN:queueMap.keySet()];

        for(ProcessInstanceWorkItem item: workItems){

            if(item.ProcessInstance.targetObjectId.getSObjectType().getDescribe().getName() == 'WorkOrder'){
                
                woIdMap.put(item.id, item.ProcessInstance.TargetObjectId);
                Map<String,Object> deserializedObject = (Map<String,Object>)JSON.deserializeUntyped(JSON.serialize(item));
                deserializedObject.put('TargetObjectId', item.ProcessInstance.TargetObjectId);
                aw.add(deserializedObject);
            }
        }

        System.debug('DK woIdMap: ' + woIdMap);

        List<Map<String,Object>> approvalRequests = new List<Map<String,Object>>();
        List<Map<String,Object>> approvalNFRequests = new List<Map<String,Object>>();
        List<Map<String,Object>> approvalDelegatedRequests = new List<Map<String,Object>>();
        if(!aw.isEmpty()){
            // 56280 - VS 02/09/2022 - Aggiunti campi nella query riga 43
            Map<String, WorkOrder> woMap = (Map<String, WorkOrder>) JSON.deserialize(JSON.serialize(SV_Utilities.keyBy([SELECT id, AccountId, Account.CRM_NDG__c, WorkOrderNumber, PTF_Destinazione__c, PTF_Destinazione__r.Name, PTF_Destinazione__r.PTF_ModelloDiServizio__c, PTF_Destinazione__r.PTF_Filiale__c, PTF_Destinazione__r.PTF_Filiale__r.Name, PTF_Filiale_Destinazione__c, PTF_Filiale_Destinazione_Id__c, StepsApprovers__c, Step__c, CreatedDate, Account.Name, PTF_Origine__c, PTF_Origine__r.Name, PTF_Origine__r.PTF_ModelloDiServizio__c, PTF_Origine__r.PTF_Filiale__c, PTF_Origine__r.PTF_Filiale__r.Name, PTF_Filiale_Origine__c, PTF_Filiale_Origine_Id__c,Description, TipologiaSpostamento__c  FROM WorkOrder WHERE Id IN: woIdMap.values()], 'Id')), Map<String, WorkOrder>.class);
            System.debug('DK woMap: ' + JSON.serialize(woMap));
            for (Integer i = (aw.size()-1) ; i>= 0 ; i--){
                
                if(woMap.containsKey((String)aw[i].get('TargetObjectId'))){
                    String configKey = woMap.get((String)aw[i].get('TargetObjectId')).PTF_Destinazione__r.PTF_FIliale__c + '_' + woMap.get((String)aw[i].get('TargetObjectId')).TipologiaSpostamento__c;
                    Integer days = null;
                    System.debug('Dk configKey: ' + configKey);
                    if(iterConfigMap.containsKey(configKey)){
                        days = Integer.valueOf(iterConfigMap.get(configKey).GiorniAnnullamento__c);
                    }else{
                        days = 15;
                    }
                    List<String> stepsApprovers = woMap.get((String)aw[i].get('TargetObjectId')).StepsApprovers__c.split('\\), ');
                    System.debug('DK stepsApprovers: ' + stepsApprovers);
                    System.debug('DK step: ' + stepsApprovers[Integer.valueOf(woMap.get((String)aw[i].get('TargetObjectId')).Step__c) - 1]);
                    
                    System.debug('DK aw[i]: ' + JSON.serialize(aw[i]));
                    aw[i].put('DestinazioneMMDS', (String)woMap.get((String)aw[i].get('TargetObjectId')).PTF_Destinazione__r.PTF_ModelloDiServizio__c);

                    aw[i].put('PTF_UrlNDG', '/' + (String)woMap.get((String)aw[i].get('TargetObjectId')).AccountId);
                    aw[i].put('NDG', (String)woMap.get((String)aw[i].get('TargetObjectId')).Account.CRM_NDG__c);

                    aw[i].put('PTF_UrlWorkOrder', '/' + (String)aw[i].get('TargetObjectId'));
                    aw[i].put('workOrderName', (String)woMap.get((String)aw[i].get('TargetObjectId')).WorkOrderNumber);
                    
                    aw[i].put('PTF_UrlRequest', '/' + (String)aw[i].get('Id'));

                    aw[i].put('PTF_UrlPTFDestinazione', '/' + (String)woMap.get((String)aw[i].get('TargetObjectId')).PTF_Destinazione__c);
                    aw[i].put('PTFDestinazionename', (String)woMap.get((String)aw[i].get('TargetObjectId')).PTF_Destinazione__r.Name);

                    aw[i].put('PTF_UrlFilialeDestinazione', '/' +  (String)woMap.get((String)aw[i].get('TargetObjectId')).PTF_Filiale_Destinazione_Id__c);
                    aw[i].put('FilialeDestinazioneName', (String)woMap.get((String)aw[i].get('TargetObjectId')).PTF_Filiale_Destinazione__c);
                    // 56280 - VS 02/09/2022
                    aw[i].put('Denominazione', (String)woMap.get((String)aw[i].get('TargetObjectId')).Account.Name);

                    aw[i].put('PTF_UrlPTFOrigine', '/' +  (String)woMap.get((String)aw[i].get('TargetObjectId')).PTF_Origine__c);
                    aw[i].put('PTFOriginename', (String)woMap.get((String)aw[i].get('TargetObjectId')).PTF_Origine__r.Name);

                    aw[i].put('OrigineMMDS', (String)woMap.get((String)aw[i].get('TargetObjectId')). PTF_Origine__r.PTF_ModelloDiServizio__c);

                    aw[i].put('PTF_UrlFilialeOrigine', '/' +  (String)woMap.get((String)aw[i].get('TargetObjectId')).PTF_Filiale_Origine_Id__c);
                    aw[i].put('FilialeOrigineName', (String)woMap.get((String)aw[i].get('TargetObjectId')).PTF_Filiale_Origine__c);
                    aw[i].put('Description', (String)woMap.get((String)aw[i].get('TargetObjectId')).Description);
                    // 56280 - VS 02/09/2022

                    System.debug('DK days: ' + days);
                    System.debug('DK alertDays: ' + alertDays);
                    System.debug('DK daysBetween: ' + Date.today().daysBetween(woMap.get((String)aw[i].get('TargetObjectId')).CreatedDate.Date().addDays(days)));
                    if(Date.today().daysBetween(woMap.get((String)aw[i].get('TargetObjectId')).CreatedDate.Date().addDays(days)) <= alertDays){
                        if(initialDate == null ||
                        woMap.get((String)aw[i].get('TargetObjectId')).CreatedDate >= initialDate){
                            aw[i].put('DKDaysBetween', Date.today().daysBetween(woMap.get((String)aw[i].get('TargetObjectId')).CreatedDate.Date().addDays(days)));
                            aw[i].put('typeCSSClass', 'color-red');
                            hasToClose = true;
                        }
                    }
                    Set<String> memberKeySet = SV_Utilities.keyBy((List<GroupMember>)queueMap.get((String)aw[i].get('ActorId')), 'UserOrGroupId').keySet();
                    if(stepsApprovers[Integer.valueOf(woMap.get((String)aw[i].get('TargetObjectId')).Step__c) - 1].contains('NF') && superUserSet.contains(currentUser.Profilo__c)){
                        approvalNFRequests.add(aw[i]);
                    }else if(!memberKeySet.contains(UserInfo.getUserId())){
                        approvalDelegatedRequests.add(aw[i]);
                    }else{
                        approvalRequests.add(aw[i]);
                    }
                }
            }
        }
        return new Map<String, Object>{

            'approvalRequests' => approvalRequests,
            'approvalNFRequests' => approvalNFRequests,
            'approvalDelegatedRequests' => approvalDelegatedRequests,
            'hasToClose' => hasToClose,
            'alertDays' => alertDays
        };
    }
}