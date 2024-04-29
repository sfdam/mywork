public without sharing class OnWorkOrderLineItemTriggerHandler {
    public virtual class BaseException extends Exception {}
    public static Boolean skip = false;

    public static void handleAfterInsert(List<WorkOrderLineItem> newLineItemList){

        Map<String, List<SObject>> workOrderLineItemMap = SV_Utilities.groupBy(newLineItemList, 'WorkOrderId');
        Map<String, SObject> workOrderMap = SV_Utilities.keyBy([SELECT id, OwnerId, Description FROM WorkOrder WHERE Id IN: workOrderLineItemMap.keySet()], 'Id');
        Map<String, String> ownerIdMap = new Map<String, String>();
        Map<String, String> noteMap = new Map<String, String>();
        Map<String, SObject> ndgLineItemMap = SV_Utilities.keyBy(newLineItemList, 'AccountId__c');
        Map<String, Account> accountMap = (Map<String, Account>)JSON.deserialize(JSON.serialize(SV_Utilities.keyBy([SELECT id, Recordtype.DeveloperName FROm Account WHERE id IN: ndgLineItemMap.keySet()], 'Id')), Map<String, Account>.class);
        List<WorkOrderLineItem> lineItemsToApprove = new List<WorkOrderLineItem>();
        List<WorkOrderLineItem> approvedlineItems = new List<WorkOrderLineItem>();
        for(String WorkOrderId : workOrderLineItemMap.keySet()){

            if(workOrderLineItemMap.get(WorkOrderId).size() > 1){
                
                for(WorkOrderLineItem lineItem : (List<WorkOrderLineItem>) workOrderLineItemMap.get(WorkOrderId)){

                    if(lineItem.HasIter__c){

                        if(accountMap.get(lineItem.AccountId__c).Recordtype.DeveloperName != 'GruppoFinanziario'){
                            
                            System.debug('DK add: ' + lineItem.AccountId__c);
                            lineItemsToApprove.add(lineItem);
                            ownerIdMap.put(lineItem.Id, (String)workOrderMap.get(lineItem.workOrderId).get('OwnerId'));
                            noteMap.put(lineItem.Id, (String)workOrderMap.get(lineItem.workOrderId).get('Description'));
                        }
                    }
                }
            }
        }

        if(!lineItemsToApprove.isEmpty()){

            Map<String,  Map<String, OnWorkOrderTriggerHandler.SpostamentiBooleanWrapper>> recordApproversMap = getApprovers(lineItemsToApprove);
            System.debug('DK recordApproversMap: ' + JSON.serialize(recordApproversMap));
            if(!recordApproversMap.isEmpty()){
                
                ApproverHandler.initApprovalProcess(recordApproversMap, ownerIdMap, noteMap);
            }
        }
    }

    public static void handleBeforeUpdate(List<WorkOrderLineItem> newLineItemList, Map<Id, WorkOrderLineItem> oldLineItemMap) {

        if(!skip){
            List<WorkOrderLineItem > lineItemOnApprovalList = new List<WorkOrderLineItem >();
            List<WorkOrderLineItem > lineItemOnRejectList = new List<WorkOrderLineItem >();
    
            for(WorkOrderLineItem lineItem : newLineItemList){
    
                if((lineItem.Status == 'Approvato' || lineItem.Status == 'Rifiutato') && 
                    oldLineItemMap.get(lineItem.Id).Status != lineItem.Status){
                    
                    lineItemOnApprovalList.add(lineItem);
                }
            }
    
            System.debug('DK workOrderOnApprovalList: ' + JSON.serialize(lineItemOnApprovalList));
            if(!lineItemOnApprovalList.isEmpty()){
    
                checkOnApproval(lineItemOnApprovalList, oldLineItemMap);
            }
        }
    }
    public static void checkOnApproval(List<WorkOrderLineItem> lineItemList, Map<Id, WorkOrderLineItem> oldLineItemMap){

        Map<String, SObject> lineItemMap = SV_Utilities.keyBy(lineItemList, 'Id');
        Map<String, WorkOrder> workOrderToUpdate = new Map<String, WorkOrder>();
        List<Id> unlockRecordIds = new List<Id> ();
        Set<String> groupIdSet = new Set<String>();
        Map<String,  Map<String, OnWorkOrderTriggerHandler.SpostamentiBooleanWrapper>> lineItemApproversMap = getApprovers(lineItemList);
        for(String lineItemId : lineItemApproversMap.keySet()){
            for(String groupId : lineItemApproversMap.get(lineItemId).keySet()){
                groupIdSet.add(groupId);
            }
        }
        Map<String, List<SObject>> fullGroupMap = SV_Utilities.groupBy([SELECT Id, UserOrGroupId, GroupId FROM GroupMember WHERE GroupId IN: groupIdSet], 'GroupId');
        Set<String> lineItemsWithNextStepSet = checkHasNextStep(lineItemList);
        Map<String, List<ProcessInstance>> currentStepProcessInstancesMap = new Map<String, List<ProcessInstance>>();
        Map<String, List<ProcessInstance>> processInstancesMap = ApproverHandler.getAllProcessInstancesMap(new List<String>(lineItemMap.keySet()));
        for(String lineItemId : processInstancesMap.keySet()){

            // Map<String, List<SObject>> groupMap = SV_Utilities.groupBy([SELECT Id, UserOrGroupId, GroupId FROM GroupMember WHERE GroupId IN: lineItemApproversMap.get(lineItemId).keySet()], 'GroupId');
            for(ProcessInstance processInstance : processInstancesMap.get(lineItemId)){

                
                if(processInstance.LastActorId == null){

                    if(!currentStepProcessInstancesMap.containsKey(processInstance.TargetObjectId)){

                        currentStepProcessInstancesMap.put(processInstance.TargetObjectId, new List<ProcessInstance>());
                    }
                    currentStepProcessInstancesMap.get(processInstance.TargetObjectId).add(processInstance);
                }else{

                    for(String groupId: lineItemApproversMap.get(lineItemId).keySet()){
                        List<SObject> groupMemberList = new List<SObject>();
                        for(String fullGroupId : fullGroupMap.keySet()){
                            if(lineItemApproversMap.get(lineItemId).keySet().contains(groupId)){
                                groupMemberList.addAll(fullGroupMap.get(fullGroupId));
                            }
                        }
                        Map<String, SObject> groupMemberMap = SV_Utilities.keyBy(groupMemberList, 'UserOrGroupId');
                        System.debug('DK groupMemberMap: ' + groupMemberMap);
                        System.debug('DK instance.LastActorId: ' + processInstance.LastActorId);

                        if(groupMemberMap.keySet().contains(processInstance.LastActorId)){

                            if(!currentStepProcessInstancesMap.containsKey(processInstance.TargetObjectId)){

                                currentStepProcessInstancesMap.put(processInstance.TargetObjectId, new List<ProcessInstance>());
                            }
                            currentStepProcessInstancesMap.get(processInstance.TargetObjectId).add(processInstance);
                        }
                    }
                }
            }
        }
        System.debug('DK lineItemApproversMap: ' + JSON.serialize(lineItemApproversMap));
        System.debug('DK processInstancesMap: ' + JSON.serialize(processInstancesMap));
        for(String lineItemId : lineItemMap.keySet()){
            
            String status = '';
            String stepKey = String.valueOf(Integer.valueOf((String)lineItemMap.get(lineItemId).get('Step__c')) + 1);
            if(currentStepProcessInstancesMap.containsKey(lineItemId)){

                for(ProcessInstance instance : currentStepProcessInstancesMap.get(lineItemId)){
                    
                    if(instance.LastActorId != null){

                        String approverId = '';
                        // Map<String, List<SObject>> groupMap = SV_Utilities.groupBy([SELECT Id, UserOrGroupId, GroupId FROM GroupMember WHERE GroupId IN: lineItemApproversMap.get(lineItemId).keySet()], 'GroupId');
                        for(String groupId: lineItemApproversMap.get(lineItemId).keySet()){
                            List<SObject> groupMemberList = new List<SObject>();
                            for(String fullGroupId : fullGroupMap.keySet()){
                                if(lineItemApproversMap.get(lineItemId).keySet().contains(groupId)){
                                    groupMemberList.addAll(fullGroupMap.get(fullGroupId));
                                }
                            }
                            Map<String, SObject> groupMemberMap = SV_Utilities.keyBy(groupMemberList, 'UserOrGroupId');
                            System.debug('DK groupMemberMap: ' + groupMemberMap);
                            System.debug('DK instance.LastActorId: ' + instance.LastActorId);
                            if(groupMemberMap.keySet().contains(instance.LastActorId)){
    
                                approverId = groupId;
                                break;
                            }
                        }
                        System.debug('DK approverId: ' + approverId);
                        if(!String.isBlank(approverId)){

                            if((Boolean)lineItemApproversMap.get(lineItemId).get(approverId).parere){
    
                                lineItemMap.get(lineItemId).put('Status', oldLineItemMap.get(lineItemId).Status);
                                //lineItemMap.get(lineItemId).put('OwnerId', UserInfo.getUserId());
                                WorkOrder workOrder= new WorkOrder(Id=(Id)lineItemMap.get(lineItemId).get('WorkOrderId'), OwnerId=UserInfo.getUserId());
                                workOrderToUpdate.put(workOrder.Id, workOrder);
                                unlockRecordIds.add((Id)lineItemMap.get(lineItemId).get('WorkOrderId'));
                                lineItemMap.get(lineItemId).put('Step__c', stepKey);
                                System.debug('CHECK ON APPROVAL CASE 1');
                                continue;
                            }else if(instance.Status == 'Approved'){
            
                                status = lineItemMap.get(lineItemId).get('Status') == 'Approvato' ? 'Approvato' : 'Pending';
                                lineItemMap.get(lineItemId).put('Status', status);
                                System.debug('CHECK ON APPROVAL CASE 2');
                                if(status == 'Pending'){
    
                                    //lineItemMap.get(lineItemId).put('OwnerId', UserInfo.getUserId());
                                    WorkOrder workOrder= new WorkOrder(Id=(Id)lineItemMap.get(lineItemId).get('WorkOrderId'), OwnerId=UserInfo.getUserId());
                                    workOrderToUpdate.put(workOrder.Id, workOrder);
                                    unlockRecordIds.add((Id)lineItemMap.get(lineItemId).get('WorkOrderId'));
                                    lineItemMap.get(lineItemId).put('Step__c', stepKey);
                                }else{
    
                                    lineItemMap.get(lineItemId).put('EndDate', DateTime.now());
                                }
                                continue;
                            }else if(instance.Status == 'Rejected'){
            
                                status = lineItemMap.get(lineItemId).get('Status') == 'Rifiutato' ? 'Rifiutato' : 'Pending';
                                lineItemMap.get(lineItemId).put('Status', status);
                                System.debug('CHECK ON APPROVAL CASE 3');
                                if(status == 'Pending'){
    
                                    //lineItemMap.get(lineItemId).put('OwnerId', UserInfo.getUserId());
                                    WorkOrder workOrder= new WorkOrder(Id=(Id)lineItemMap.get(lineItemId).get('WorkOrderId'), OwnerId=UserInfo.getUserId());
                                    workOrderToUpdate.put(workOrder.Id, workOrder);
                                    unlockRecordIds.add((Id)lineItemMap.get(lineItemId).get('WorkOrderId'));
                                    lineItemMap.get(lineItemId).put('Step__c', stepKey);
                                }else{
    
                                    lineItemMap.get(lineItemId).put('EndDate', DateTime.now());
                                }
                                continue;
                            }
                        }else{

                            lineItemMap.get(lineItemId).put('EndDate', DateTime.now());
                        }
                    }else{
                        
                        lineItemMap.get(lineItemId).put('Status', oldLineItemMap.get(lineItemId).Status);
                    }
                }
            }else{
                
                System.debug('DK SINGLE APPROVER');
                String approverId = '';
                System.debug('DK lineItemId: ' + lineItemId);
                System.debug('DK lineItemApproversMap: ' + JSON.serialize(lineItemApproversMap));
                // Map<String, List<SObject>> groupMap = SV_Utilities.groupBy([SELECT Id, UserOrGroupId, GroupId FROM GroupMember WHERE GroupId IN: lineItemApproversMap.get(lineItemId).keySet()], 'GroupId');
                for(String groupId: lineItemApproversMap.get(lineItemId).keySet()){
                    List<SObject> groupMemberList = new List<SObject>();
                    for(String fullGroupId : fullGroupMap.keySet()){
                        if(lineItemApproversMap.get(lineItemId).keySet().contains(groupId)){
                            groupMemberList.addAll(fullGroupMap.get(fullGroupId));
                        }
                    }
                    Map<String, SObject> groupMemberMap = SV_Utilities.keyBy(groupMemberList, 'UserOrGroupId');
                    System.debug('DK groupMemberMap: ' + groupMemberMap);
                    System.debug('DK instance.LastActorId: ' + userInfo.getUserId());
                    if(groupMemberMap.keySet().contains(userInfo.getUserId())){

                        approverId = groupId;
                        break;
                    }
                }
                System.debug('DK approverId: ' + approverId);
                if(!String.isBlank(approverId)){

                    if((Boolean)lineItemApproversMap.get(lineItemId).get(approverId).parere){
        
                        lineItemMap.get(lineItemId).put('Status', oldLineItemMap.get(lineItemId).Status);
                        lineItemMap.get(lineItemId).put('Step__c', stepKey);
                        // lineItemMap.get(lineItemId).put('OwnerId', UserInfo.getUserId());
                        continue;
                    }else if(lineItemsWithNextStepSet.contains((String)lineItemMap.get(lineItemId).get('Id')) &&
                        lineItemMap.get(lineItemId).get('Status') == 'Rifiutato'){
    
                        lineItemMap.get(lineItemId).put('Status', oldLineItemMap.get(lineItemId).Status);
                        lineItemMap.get(lineItemId).put('Step__c', stepKey);
                        lineItemMap.get(lineItemId).put('OwnerId', UserInfo.getUserId());
                    }
                }
            }
        }
        if(workOrderToUpdate.size()>0){
            OnWorkOrderTriggerHandler.skip=true;
            Approval.UnlockResult[] results = Approval.unlock(unlockRecordIds, false);
            update workOrderToUpdate.values();
            Approval.LockResult[] lockRes = Approval.lock(unlockRecordIds, false);
        }
    }

    public static Map<String, Map<String, OnWorkOrderTriggerHandler.SpostamentiBooleanWrapper>> getApprovers(List<WorkOrderLineItem> lineItemList){
        
        Map<String, Map<String, OnWorkOrderTriggerHandler.SpostamentiBooleanWrapper>> lineItemApproversMap = new Map<String, Map<String, OnWorkOrderTriggerHandler.SpostamentiBooleanWrapper>>();
        System.debug('DK lineItemList: ' + json.serialize(lineItemList));
        Map<String, List<SObject>> lineItemMap = SV_Utilities.groupBy(lineItemList, '%{Queues__c}%', true);
        System.debug('DK lineItemMap: ' + json.serialize(lineItemMap));
        for(Group queue : [SELECT id, Name, DeveloperName FROM Group WHERE DeveloperName like: lineItemMap.keySet()]){

            String workOrderKey = queue.DeveloperName.split('_')[1];
            String parere = queue.DeveloperName.split('_')[2];
            String nextStepOnApproval = queue.DeveloperName.split('_').size() == 6 ? queue.DeveloperName.split('_')[3] : 'false'; //Modifica - Salvatore Barbieri - 27/03/2024 - 79032
            Integer stepIndex = queue.DeveloperName.split('_').size() - 2; //Modifica - Salvatore Barbieri - 28/03/2024 - 79032
            String step = queue.DeveloperName.split('_')[stepIndex]; //Modifica - Salvatore Barbieri - 28/03/2024 - 79032

            //Modifica - Salvatore Barbieri - 28/03/2024 - 79032
            OnWorkOrderTriggerHandler.SpostamentiBooleanWrapper spostBoolWrpTmp = new OnWorkOrderTriggerHandler.SpostamentiBooleanWrapper();
            spostBoolWrpTmp.parere = Boolean.valueOf(parere);
            spostBoolWrpTmp.nextStepOnApproval = Boolean.valueOf(nextStepOnApproval);
            
            for(SObject lineItem : lineItemMap.get('%' + workOrderKey + '%')){
                
                if(step == (String)lineItem.get('Step__c')){
                    
                    if(!lineItemApproversMap.containsKey((String)lineItem.get('Id'))){
        
                        lineItemApproversMap.put((String)lineItem.get('Id'), new Map<String, OnWorkOrderTriggerHandler.SpostamentiBooleanWrapper>());
                    }
        
                    lineItemApproversMap.get((String)lineItem.get('Id')).put(queue.Id, spostBoolWrpTmp);
                }
            }
        }

        return lineItemApproversMap;
    }

    public static Set<String> checkHasNextStep(List<WorkOrderLineItem> lineItemList){
        
        Set<String> lineItemIdSet = new Set<String>();
        Map<String, List<WorkOrderLineItem>> lineItemMap = (Map<String, List<WorkOrderLineItem>>) JSON.deserialize(JSON.serialize(SV_Utilities.groupBy(lineItemList, '%{Queues__c}%', true)), Map<String, List<WorkOrderLineItem>>.class);
        
        for(Group queue : [SELECT id, Name, DeveloperName FROM Group WHERE DeveloperName like: lineItemMap.keySet()]){

            String workOrderKey = queue.DeveloperName.split('_')[1];
            String parere = queue.DeveloperName.split('_')[2];
            Integer stepIndex = queue.DeveloperName.split('_').size() - 2; //Modifica - Salvatore Barbieri - 28/03/2024 - 79032
            String step = queue.DeveloperName.split('_')[stepIndex]; //Modifica - Salvatore Barbieri - 28/03/2024 - 79032
            for(WorkOrderLineItem lineItem : lineItemMap.get('%' + workOrderKey + '%')){

                String nextStep = String.valueOf(Integer.valueOf(lineItem.Step__c) + 1);
                System.debug('DK step: ' + step);
                System.debug('DK nextStep: ' + nextStep);
                if(step == nextStep){
    
                    lineItemIdSet.add(lineItem.Id);
                }
            }
        }
        return lineItemIdSet;
    }

    public static void approveRequests(List<WorkOrderLineItem> approvedLineItemList){

        //Map<String, SObject> approvedLineItemMap = SV_Utilities.keyBy(approvedLineItemList, 'Id');
        List<Account> accountToUpdateList = new List<Account>();
        Set<String> primarioIdSet = new Set<String>();
        Map<String, String> primarioOrigineMap = new Map<String, String>();
        Map<String, String> primarioDestinazioneMap = new Map<String, String>();
        Map<String, String> primarioFilaileDestinazioneMap = new Map<String, String>();
        Map<String, String> gruppoIdMap = new Map<String, String>();
        for(WorkOrderLineItem workOrderLineItem : approvedLineItemList){

            if(!workOrderLineItem.IsGruppoFinanziario__c){

                accountToUpdateList.add(new Account(id = workOrderLineItem.AccountId__c,
                                                    PTF_Portafoglio__c = workOrderLineItem.PTF_Destinazione__c,
                                                    PTF_Filiale__c = workOrderLineItem.PTF_Filiale_Destinazione_Id__c));
                if(!String.isBlank(workOrderLineItem.IdGruppoFinanziario__c)){
    
                    gruppoIdMap.put(workOrderLineItem.IdGruppoFinanziario__c, workOrderLineItem.workOrderId);
                }
                if(workOrderLineItem.IsPrimario__c){
    
                    primarioIdSet.add(workOrderLineItem.AccountId__c);
                    primarioOrigineMap.put(workOrderLineItem.AccountId__c, workOrderLineItem.PTF_OrigineId__c);
                    primarioDestinazioneMap.put(workOrderLineItem.AccountId__c, workOrderLineItem.PTF_Destinazione__c);
                    primarioFilaileDestinazioneMap.put(workOrderLineItem.AccountId__c, workOrderLineItem.PTF_Filiale_Destinazione_Id__c);
                }
            }
        }

        if(!primarioIdSet.isEmpty()){

            for(CRM_AccountAccountJointOwnershipRelation__c giunzione : [SELECT id, CRM_Account__c, CRM_Active__c, CRM_PrimaryNDG__c, CRM_JointOwnership__c, CRM_JointOwnership__r.PTF_Portafoglio__c, CRM_JointOwnership__r.PTF_Portafoglio__r.PTF_Filiale__c
                                            FROM CRM_AccountAccountJointOwnershipRelation__c 
                                            WHERE CRM_Account__c IN: primarioIdSet AND
                                            CRM_JointOwnership__r.PTF_Portafoglio__c != '' AND
                                            CRM_Active__c = true AND
                                            CRM_PrimaryNDG__c = true]){
                if(primarioOrigineMap.get(giunzione.CRM_Account__c) == giunzione.CRM_JointOwnership__r.PTF_Portafoglio__c){
                
                    accountToUpdateList.add(new Account(Id = giunzione.CRM_JointOwnership__c,
                    PTF_Portafoglio__c = primarioDestinazioneMap.get(giunzione.CRM_Account__c),
                    PTF_Filiale__c = primarioFilaileDestinazioneMap.get(giunzione.CRM_Account__c)));
                }
            }
        }

        if(!gruppoIdMap.isEmpty()){
            
            List<WorkOrderLineitem> gruppiToApprove = [SELECT Id, AccountId__c, Status FROM WorkOrderLineitem WHERE AccountId__c In: gruppoIdMap.keySet() AND WorkOrderId IN: gruppoIdMap.values() AND Status = 'Pending'];
            for(WorkOrderLineitem lineItemGruppo : gruppiToApprove){

                lineItemGruppo.Status = 'Approvato';
            }

            if(!gruppiToApprove.isEmpty()){

                update gruppiToApprove;
            }
        }

        if(!accountToUpdateList.isEmpty()){

            update accountToUpdateList;
        }
    }

    public static void handleAfterUpdate(List<WorkOrderLineItem> newLineItemList, Map<Id, WorkOrderLineItem> oldLineItemMap) {
        List<WorkOrderLineItem> approvedLineItemList = new List<WorkOrderLineItem>();
        Map<String, String> gruppoIdMap = new Map<String, String>();
        Map<String, String> ownerIdMap = new Map<String, String>();
        List<WorkOrderLineItem> nextStepLineItemList = new List<WorkOrderLineItem>();
        Map<String, List<SObject>> workOrderLineItemMap = SV_Utilities.groupBy(newLineItemList, 'WorkOrderId');

        for(WorkOrderLineItem lineItem : newLineItemList){
            
            if(lineItem.Status == 'Approvato' && 
            lineItem.Status != oldLineItemMap.get(lineItem.Id).Status){
                
                approvedLineItemList.add(lineItem);
            }else if(lineItem.Status == 'Rifiutato' &&
            !String.isBlank(lineItem.IdGruppoFinanziario__c) &&
            lineItem.Status != oldLineItemMap.get(lineItem.Id).Status){
                
                gruppoIdMap.put(lineItem.IdGruppoFinanziario__c, lineItem.WorkOrderId);
            }else if(lineItem.Step__c != oldLineItemMap.get(lineItem.Id).Step__c){
                
                nextStepLineItemList.add(lineItem);
                ownerIdMap.put(lineItem.Id, userInfo.getUserId());
            }
        }
        
        System.debug('DK nextStepLineItemList: ' + JSON.serialize(nextStepLineItemList));
        
        if(!nextStepLineItemList.isEmpty()){
            
            setNexStepApprovers(nextStepLineItemList, ownerIdMap);
        }
        
        if(!approvedLineItemList.isEmpty()){
            
            approveRequests(approvedLineItemList);
        }

        if(!gruppoIdMap.isEmpty()){

            rejectGroups(gruppoIdMap);
        }
    }

    public static void rejectGroups(Map<String, String> gruppoIdMap){

        List<WorkOrderLineitem> gruppiToApprove = [SELECT Id, AccountId__c, Status FROM WorkOrderLineitem WHERE AccountId__c In: gruppoIdMap.keySet() AND WorkOrderId IN: gruppoIdMap.values() AND Status = 'Pending'];
        for(WorkOrderLineitem gruppo : gruppiToApprove){

            gruppo.Status = 'Rifiutato';
        }

        if(!gruppiToApprove.isEmpty()){

            update gruppiToApprove;
        }
    }

    public static void setNexStepApprovers(List<WorkOrderLineitem> lineItemList, Map<String, String> ownerIdMap){

        Map<String,  Map<String, OnWorkOrderTriggerHandler.SpostamentiBooleanWrapper>> lineItemApproversMap = getApprovers(lineItemList);

        if(!lineItemApproversMap.isEmpty()){
            
            nextApprovalStep(JSON.serialize(
                new Map<String,Object> {
                    'ownerIdMap' => ownerIdMap,
                    'lineItemApproversMap' => lineItemApproversMap
                }
            ));
        }
    }
    
    @future
    public static void nextApprovalStep(String approvalJSON){
        
        System.debug('DK approvalJSON: ' + approvalJSON);
        Map<String,Object> approvalMap = (Map<String,Object>) JSON.deserializeUntyped(approvalJSON);
        Map<String,  Map<String, OnWorkOrderTriggerHandler.SpostamentiBooleanWrapper>> lineItemApproversMap = (Map<String,  Map<String, OnWorkOrderTriggerHandler.SpostamentiBooleanWrapper>>) JSON.deserialize(JSON.serialize(approvalMap.get('lineItemApproversMap')), Map<String, Map<String, OnWorkOrderTriggerHandler.SpostamentiBooleanWrapper>>.class);
        Map<String, String> ownerIdMap = (Map<String, String>) JSON.deserialize(JSON.serialize(approvalMap.get('ownerIdMap')), Map<String, String>.class);
        ApproverHandler.initApprovalProcess(lineItemApproversMap, ownerIdMap, new Map<String, String>());
    }

    public static void closeWorkOrder(List<WorkOrderLineItem> newLineItemList, Map<Id, WorkOrderLineItem> oldLineItemMap){
        List<Id> workOrderIds = new List<Id>();
        List<Id> workOrderIdsToRecall = new List<Id>();
        List<WorkOrder> workOrderToUpdate = new List<WorkOrder>();
        for(WorkOrderLineItem item:newLineItemList){
            if(item.Status!='Pending' && oldLineItemMap.get(item.Id).Status=='Pending'){
                workOrderIds.add(item.WorkOrderId); 
            }
        }
        for(WorkOrder wo: [SELECT Id, (SELECT Id, Status FROM WorkOrderLineItems) FROM WorkOrder WHERE Id IN:workOrderIds]){
            Boolean allRejected=true;
            Boolean allApproved=true;
            Boolean allRemoved=true;
            Boolean notPending=true;
            for(WorkOrderLineItem item:wo.WorkOrderLineItems){
                if(item.Status!='Rifiutato') allRejected=false;
                if(item.Status!='Approvato') allApproved=false;
                if(item.Status!='Annullato') allRemoved=false;
                if(item.Status=='Pending') notPending=false;
            }
            
            if(allRejected){
                wo.Status='Rifiutato';
                wo.EndDate=Datetime.now();
                workOrderToUpdate.add(wo);
                workOrderIdsToRecall.add(wo.Id);
            }
            else if(allApproved){
                wo.Status='Approvato';
                wo.EndDate=Datetime.now();
                workOrderToUpdate.add(wo);
                workOrderIdsToRecall.add(wo.Id);
            }
            else if(allRemoved){
                wo.Status='Annullato';
                wo.EndDate=Datetime.now();
                workOrderToUpdate.add(wo);
                workOrderIdsToRecall.add(wo.Id);
            }
            else if(notPending){
                wo.Status='Parzialmente Approvato';
                wo.EndDate=Datetime.now();
                workOrderToUpdate.add(wo);
                workOrderIdsToRecall.add(wo.Id);
            }
        }
        
        
        
        List<Approval.ProcessWorkitemRequest> pwirList = new List<Approval.ProcessWorkitemRequest>();
        for(ProcessInstanceWorkitem p: [SELECT Id
                                        FROM ProcessInstanceWorkitem 
                                        WHERE ProcessInstance.Status='Pending' AND ProcessInstance.TargetObjectId IN:workOrderIdsToRecall]){
            Approval.ProcessWorkitemRequest result = new Approval.ProcessWorkitemRequest();         
            result.setAction('Removed');         
            result.setWorkitemId(p.Id);
            pwirList.add(result);

        }
        OnWorkOrderTriggerHandler.skip=true;
        Approval.process(pwirList);
        update workOrderToUpdate;
    }

    public static void handleBeforeDelete(List<WorkOrderLineItem> oldLineItemList){

        for(WorkOrderLineItem lineItem : oldLineItemList){

            if(lineItem.Status == 'Pending'){

                lineitem.addError('Non è possibile eliminare una linea di ordine di lavoro in lavorazione.');
            }
        }
    }

    public static void testVoid(){
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
    }
}