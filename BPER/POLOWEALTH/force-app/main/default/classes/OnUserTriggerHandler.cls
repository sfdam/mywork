/**
 * Name         :   OnUserTriggerHandler
 * Create Date  :   2020-09-21
 * Author       :   Ezio Dal Bo @TEN
**/
public class OnUserTriggerHandler {


    public static Boolean skipUpdateMember=false;
    
    /**
     * Name         :   afterUpdate
     * Create Date  :   2020-09-21
     * Author       :   Ezio Dal Bo @TEN
     * Input        :   newRecord (List<User>), oldRecord (Map<Id,User>)
     * Description  :   Metodo utilizzato per gestire i metodi quando il trigger sull'utente viene invocato in after update
     */
    public static void afterUpdate(List<User> newRecord, Map<Id,User> oldRecord) {
        if(!skipUpdateMember){
            updateRuoloUtente(newRecord, oldRecord);
            associaGruppiPubblici(newRecord,oldRecord,'afterUpdate');
            // START DK - REASSIGN USER TO QUEUE
            // DK RIMOZIONEDAQUEUE
            List<User> updatedUserList = new List<User>();
            List<String> refsToDrop = new List<String>();
            for(User user : newRecord){
                if(User.Profilo__c != oldRecord.get(user.Id).Profilo__c ||
                    User.idced__c != oldRecord.get(user.Id).idced__c ||
                    (!User.isActive && oldRecord.get(user.Id).isActive)){
                    updatedUserList.add(user);
                }
                
                if(User.idced__c != oldRecord.get(user.Id).idced__c ||
                    user.PTF_RuoloLDAP__c != oldRecord.get(user.Id).PTF_RuoloLDAP__c ||
                    (!User.isActive && oldRecord.get(user.Id).isActive)){

                    refsToDrop.add(user.id);
                }
            }
            // DK RIMOZIONEDAQUEUE
    
            if(!updatedUserList.isEmpty()){
                updateQueues(updatedUserList);
            }

            if(!refsToDrop.isEmpty()){
                dropRefs(refsToDrop);
            }
            // END DK - REASSIGN USER TO QUEUE
        }
    }
	
    @future
    public static void dropRefs(List<String> userIdList){

        System.debug('STAT dropRefs');
        List<CampaignMember> cmList = [SELECT Id, CRM_Assegnatario__c FROM CampaignMember WHERE CRM_Assegnatario__c IN: userIdList];
        for(CampaignMember cm : cmList){
            cm.CRM_Assegnatario__c = null;
        }
        update cmList;
    }
   
    /**
     * Name         :   afterInsert
     * Create Date  :   2020-11-11
     * Author       :   Ezio Dal Bo @TEN
     * Input        :   newRecord (List<User>)
     * Description  :   Metodo utilizzato per gestire i metodi quando il trigger sull'utente viene invocato in after insert
     */
    public static void afterInsert(List<User> newRecord) {
        impostaPermissionSet(newRecord);
        collegaContatto(newRecord);
        associaGruppiPubblici(newRecord,null,'afterInsert');
    }

    // START DK - REASSIGN USER TO QUEUE
    public static void updateQueues(List<User> updatedUserList){

        Map<String,SObject> userMap = SV_Utilities.keyBy(updatedUserList, 'Id');
        Set<String> profiloSet = SV_Utilities.keyBy(updatedUserList, 'Profilo__c').keySet();
        Set<String> idCedSet = SV_Utilities.keyBy(updatedUserList, 'idced__c').keySet();
        
        Savepoint sp = Database.setSavepoint();
        try {
            
            List<GroupMember> membersToDelete = [SELECT GroupId, Group.Name, Group.DeveloperName FROM GroupMember WHERE UserOrGroupId IN: userMap.keySet() AND Group.Name LIKE '%Approvers Step%'];
            delete membersToDelete;
            List<GroupMember> membersToInsert = new List<GroupMember>();
            List<User> userInQueue = [SELECT id, IdCed__c, Profilo__c FROM User WHERE Profilo__c IN: profiloSet AND IdCed__c IN: idCedSet AND IsActive = true AND Id IN (SELECT UserOrGroupId FROM GroupMember WHERE Group.Name LIKE '%Approvers Step%')];
            Map<String,SObject> userInQueueMap = SV_Utilities.keyBy(userInQueue, '{Profilo__c}_{IdCed__c}', true);
            System.debug('DK userInQueueMap: ' + JSON.serialize(userInQueueMap));  
            Set<String> userInQueueUserSet = SV_Utilities.keyBy(userInQueue, 'Id').keySet();
            System.debug('DK userInQueueUserSet: ' + JSON.serialize(userInQueueUserSet));  
            Map<String,List<SObject>> queueToupdateMap = SV_Utilities.groupBy([SELECT GroupId, Group.Name, Group.DeveloperName, UserOrGroupId FROM GroupMember WHERE UserOrGroupId IN: userInQueueUserSet AND Group.Name LIKE '%Approvers Step%'], 'UserOrGroupId');
            System.debug('DK queueToupdateMap: ' + JSON.serialize(queueToupdateMap));  
            for(String userId : userMap.keySet()){
                
                String key = ((User)userMap.get(userId)).Profilo__c + '_' + ((User)userMap.get(userId)).IdCed__c;
                System.debug('DK key: ' + key);
                System.debug('DK user: ' + userId);
                if(userInQueueMap.containsKey(key) && queueToupdateMap.containsKey((String)userInQueueMap.get(key).get('Id'))){
    
                    for(GroupMember existingMember: (List<GroupMember>)queueToupdateMap.get((String)userInQueueMap.get(key).get('Id'))){
                        
                        GroupMember member = new GroupMember();
                        member.GroupId = existingMember.GroupId;
                        member.UserOrGroupId = userId;
                        membersToInsert.add(member);
                    }
                }
            }
            Set<String> queueToFill = SV_Utilities.keyBy(membersToInsert, 'GroupId').keySet();
            Map<String, List<SObject>> queueMap = SV_Utilities.groupBy(membersToDelete, 'GroupId');
            Map<String, List<SObject>> remainingQueueMap = SV_Utilities.groupBy([SELECT GroupId, Group.Name, Group.DeveloperName FROM GroupMember WHERE UserOrGroupId NOT IN: userMap.keySet() AND GroupId IN: queueMap.keySet()], 'GroupId');

            Set<String> queueCodeSet = new Set<String>();
            Set<String> emptyQueueIdSet = new Set<String>();
            for(String queueId: queueMap.keySet()){
                if(!remainingQueueMap.containsKey(queueId) && !queueToFill.contains(queueId)){
                    
                    queueCodeSet.add(((GroupMember)queueMap.get(queueId)[0]).Group.DeveloperName.split('_')[1]);
                    emptyQueueIdSet.add(queueId);
                }
            }   
            System.debug('DK membersToDelete: ' + JSON.serialize(membersToDelete));  
            List<WorkOrder> woToUpdateList = new List<WorkOrder>();
            if(!emptyQueueIdSet.isEmpty()){
                
                Map<String, SObject> woMap = SV_Utilities.keyBy([SELECT id, Queues__c, StepsApprovers__c, HasNF__c, PTF_Origine__r.PTF_Banca__r.FinServ__BankNumber__c FROM WorkOrder WHERE Queues__c IN: queueCodeSet AND Status = 'Pending'], 'Queues__c');
                System.debug('DK woMap: ' + JSON.serialize(woMap)); 
                List<Contact> BPER = [SELECT Id, PTF_User__c FROM Contact WHERE PTF_User__r.Profilo__c = 'NEC_D.0' AND PTF_User__r.IsActive = true];
                List<user> BDS = [SELECT Id FROM user WHERE Id IN (SELECT UserOrGroupId FROM GroupMember WHERE Group.DeveloperName = 'SUPERUSER_BDS') AND IsActive = true];
                List<user> BCP = [SELECT id FROM user where idced__c ='27786' and abi__c = '03084' AND IsActive = true];//AD CR NEC 78583 25/03/2024
                Map<String, Set<String>> superUserMap = new Map<String, Set<String>>();
                //AD commentato per CR NEC 78583 25/03/2024
                //superUserMap.put('NEC_D.0', SV_Utilities.keyBy(BPER, 'PTF_User__c').keySet());
                //superUserMap.put('NEC_D.2', SV_Utilities.keyBy(BDS, 'Id').keySet());
                //mappa con chiave codice abi per ciascuna banca
                //BPER = 05387 , //BDS = 01015 , //BCP = 03084
                superUserMap.put('05387', SV_Utilities.keyBy(BPER, 'PTF_User__c').keySet());//AD CR NEC 78583 25/03/2024
                superUserMap.put('01015', SV_Utilities.keyBy(BDS, 'Id').keySet());//AD CR NEC 78583 25/03/2024
                superUserMap.put('03084', SV_Utilities.keyBy(BCP, 'Id').keySet());//AD CR NEC 78583 25/03/2024

                for(String queueId: emptyQueueIdSet){
                    
                    String queueDeveloperName = ((GroupMember)queueMap.get(queueId)[0]).Group.DeveloperName;
                    System.debug('DK queueDeveloperName: ' + queueDeveloperName);  
                    String workOrderKey = queueDeveloperName.split('_')[1];
                    if(woMap.containsKey(workOrderKey)){

                        String step = queueDeveloperName.split('_')[3];
                        String approver = queueDeveloperName.split('_')[4];
                        WorkOrder woToUpdate = (WorkOrder)woMap.get(workOrderKey);
                        String profiloSuperUser = woToUpdate.PTF_Origine__r.PTF_Banca__r.FinServ__BankNumber__c == '05387' ? 'NEC_D.0' : 'NEC_D.2';
                        String bankNumberABI = woToUpdate.PTF_Origine__r.PTF_Banca__r.FinServ__BankNumber__c;//AD CR NEC 78583 25/03/2024
                        List<String> stepsApproversList = woToUpdate.StepsApprovers__c.split('\\), ');
                        List<String> stepToUpdateList = stepsApproversList[Integer.valueOf(step) - 1].split(', ');
                        stepToUpdateList[Integer.valueOf(approver) - 1] = stepToUpdateList[Integer.valueOf(approver) - 1].contains(' RS') ? stepToUpdateList[Integer.valueOf(approver) - 1].substringBefore(' RS') : stepToUpdateList[Integer.valueOf(approver) - 1];
                        stepToUpdateList[Integer.valueOf(approver) - 1] = stepToUpdateList[Integer.valueOf(approver) - 1].contains(')') ? stepToUpdateList[Integer.valueOf(approver) - 1].substringBefore(')') : stepToUpdateList[Integer.valueOf(approver) - 1];
                        stepToUpdateList[Integer.valueOf(approver) - 1] = stepToUpdateList[Integer.valueOf(approver) - 1].contains('(') ? stepToUpdateList[Integer.valueOf(approver) - 1].substringAfterLast('(') + ' NF - ' + profiloSuperUser : stepToUpdateList[Integer.valueOf(approver) - 1] + ' NF - ' + profiloSuperUser;
                        String stepToUpdateString = String.join(stepToUpdateList, ', ');
                        stepsApproversList[Integer.valueOf(step) - 1] = stepToUpdateString.contains('(') ? 'STEP' + step + '(' + stepToUpdateString.substringAfterLast('(') : stepToUpdateString;
                        if(Integer.valueOf(step) == stepsApproversList.size()){
    
                            stepsApproversList[Integer.valueOf(step) - 1] += ')';
                        }
                        woToUpdate.StepsApprovers__c = String.join(stepsApproversList, '), ');
                        woToUpdate.HasNF__c = woToUpdate.StepsApprovers__c.contains('NF');
                        woMap.put(workOrderKey, woToUpdate);
                        //for(String userId: superUserMap.get(profiloSuperUser)){//AD commentato per CR NEC 78583 25/03/2024
                        for(String userId: superUserMap.get(bankNumberABI)){//AD CR NEC 78583 25/03/2024
        
                            GroupMember member = new GroupMember();
                            member.GroupId = queueId;
                            member.UserOrGroupId = userId;
                            membersToInsert.add(member);
                        }
                    }
                }
                System.debug('DK woMap: ' + JSON.serialize(woMap)); 
                ID jobID = System.enqueueJob(new WorkOrderQueueableJobs(woMap.values()));
            }

            System.debug('DK membersToInsert: ' + JSON.serialize(membersToInsert));  
            insert membersToInsert;
        } catch (Exception ex) {
            Database.rollback(sp);
            System.debug('DK Exception: ' + ex  + '; Stacktrace: ' + ex.getStackTraceString());
        }
    }
    // END DK - REASSIGN USER TO QUEUE
    
    /**
     * Name         :   beforeInsert
     * Create Date  :   2020-11-11
     * Author       :   Ezio Dal Bo @TEN
     * Input        :   newRecord (List<User>)
     * Description  :   Metodo utilizzato per gestire i metodi quando il trigger sull'utente viene invocato in after insert
     */
    public static void beforeInsert(List<User> newRecord) {
        impostaFlagUtente(newRecord);
        ribaltaCampi(newRecord);
        impostaCallCenter(newRecord);
        associaGruppiPubblici(newRecord,null,'beforeInsert');
        associaPermissionSet(newRecord,null);
    }

    /**
     * Name         :   beforeUpdate
     * Create Date  :   2020-11-26
     * Author       :   Ezio Dal Bo @TEN
     * Input        :   newRecord (List<User>)
     * Description  :   Metodo utilizzato per gestire i metodi quando il trigger sull'utente viene invocato in after update
     */
    public static void beforeUpdate(List<User> newRecord,Map<Id,User> oldRecord) {
        impostaFlagUtente(newRecord);
        ribaltaCampi(newRecord);
        impostaCallCenter(newRecord);
        associaGruppiPubblici(newRecord,oldRecord,'beforeUpdate');
        associaPermissionSet(newRecord,oldRecord);
        //controlloDisattivazione(newRecord,oldRecord);
    }

    /**
     * Name         :   controlloDisattivazione
     * Create Date  :   2022-06-17
     * Author       :   Valerio Salvati @TEN
     * Input        :   newRecord (List<User>), oldRecord (Map<Id,User>)
     * Description  :   Metodo utilizzato per controllare la disattivazione degli utenti
     */
    public static void controlloDisattivazione(List<User> newRecord, Map<Id,User> oldRecord) {
        System.debug('*** controlloDisattivazione start ');

        Map<Id,List<String>> mUserNew = new Map<Id,List<String>>();
        Map<Id,List<String>> mUserOld = new Map<Id,List<String>>();
        User oldUser;
        for(User currentUser : newRecord){
            if('NEC_CC'.equalsIgnoreCase(currentUser.Profilo__c) || 'NEC_CCSV'.equalsIgnoreCase(currentUser.Profilo__c)){
                oldUser = oldRecord.get(currentUser.Id);
                if(!currentUser.IsActive && oldUser.isActive && !oldUser.Da_Disattivare_Batch__c && !currentUser.Da_Disattivare_Batch__c){
                    System.debug('*** controlloDisattivazione deactivate future ');
                    currentUser.Da_Disattivare_Batch__c= true;
                    currentUser.isActive = true;
                }
                else if(oldUser.Da_Disattivare_Batch__c && !currentUser.Da_Disattivare_Batch__c && oldUser.isActive && !currentUser.IsActive){
                    System.debug('*** controlloDisattivazione remove flag ');
                    currentUser.Da_Disattivare_Batch__c = false;
                }
            }
        }
        System.debug('*** controlloDisattivazione end ');
    }


    /**
     * Name         :   associaPermissionSet
     * Create Date  :   2021-10-27
     * Author       :   Dam Kebe @TEN
     * Input        :   newRecord (List<User>), oldRecord (Map<Id,User>)
     * Description  :   Metodo utilizzato per associare i permissionset all'utente
     */
    public static void associaPermissionSet(List<User> newRecord, Map<Id,User> oldRecord){

        List<User> usersToUpdate = new List<User>();
        Set<String> userIdSet = new Set<String>();
        Set<String> newPermisionSetNameSet = new Set<String>();
        Set<String> oldPermisionSetNameSet = new Set<String>();
        Set<String> permissionSetsToDelete = new Set<String>();
        if(oldRecord != null){
            for(User user : newRecord){
                if(user.CRM_PermissionSet__c != oldRecord.get(user.Id).CRM_PermissionSet__c){
                    usersToUpdate.add(user);
                    userIdSet.add(user.Id);
                    newPermisionSetNameSet.add(user.CRM_PermissionSet__c);
                    if(!String.isBlank(oldRecord.get(user.Id).CRM_PermissionSet__c)){
                        oldPermisionSetNameSet.add(oldRecord.get(user.Id).CRM_PermissionSet__c);
                        permissionSetsToDelete.add(''+user.Id+oldRecord.get(user.Id).CRM_PermissionSet__c);
                    }
                }
            }
            if(!oldPermisionSetNameSet.isEmpty()){
                Set<String> oldPermissionSetSet = SV_Utilities.keyBy([SELECT id, Label FROM PermissionSet WHERE Label IN: oldPermisionSetNameSet], 'Id').keySet();
                List<PermissionSetAssignment> psaToDelete = new List<PermissionSetAssignment>();
                for(PermissionSetAssignment permissioNSetAssignment : [SELECT Id, AssigneeId, permissionSet.Label FROM PermissionSetAssignment WHERE AssigneeId IN: userIdSet AND PermissionSetId IN: oldpermissionSetSet]){
                    if(permissionSetsToDelete.contains(''+permissioNSetAssignment.AssigneeId+permissioNSetAssignment.permissionSet.Label)){
                        psaToDelete.add(permissioNSetAssignment);
                    }
                }
                if(!psaToDelete.isEmpty()){
                    delete psaToDelete;
                }
            }
        }else{
            usersToUpdate = newRecord;
            for(User user : usersToUpdate){
                if(!String.isBlank(user.CRM_PermissionSet__c)){
                    newPermisionSetNameSet.add(user.CRM_PermissionSet__c);
                }
            }
        }

        System.debug('DK newPermisionSetNameSet: ' + JSON.serialize(newPermisionSetNameSet));

        Map<String, Sobject> newPermissionSetMap = SV_Utilities.keyBy([SELECT id, Label FROM PermissionSet WHERE Label IN: newPermisionSetNameSet], 'Label');
        System.debug('DK newPermissionSetMap: ' + JSON.serialize(newPermissionSetMap));
        List<PermissionSetAssignment> permissionSetAssignmentToInsert = new List<PermissionSetAssignment>();
        for(User user : usersToUpdate){
            System.debug('DK user.PermissionSet: ' + user.CRM_PermissionSet__c);
            if(newPermissionSetMap.containsKey(user.CRM_PermissionSet__c)){
                permissionSetAssignmentToInsert.add(new PermissionSetAssignment (PermissionSetId = (String)newPermissionSetMap.get(user.CRM_PermissionSet__c).get('Id'), AssigneeId = user.Id));
            }
        }
        System.debug('DK permissionSetAssignmentToInsert: ' + JSON.serialize(permissionSetAssignmentToInsert));
        if(!permissionSetAssignmentToInsert.isEmpty()){
            Database.Insert(permissionSetAssignmentToInsert, false);
        }
    }

    // private methods
    public static void associaGruppiPubblici(List<User> newRecord, Map<Id,User> oldRecord, String operation) {
        Map<Id,List<String>> mUserNew = new Map<Id,List<String>>();
        Map<Id,List<String>> mUserOld = new Map<Id,List<String>>();
        List<GroupMember> groupMemberToInsert = new List<GroupMember>();
        //Change-Account-Sharing Map<String,sObject> mProfili = MetadataUtility.getAllByMetadataName('Profilo_BPER__mdt');
        //Change-Account-Sharing START ---> E' stato creato il campo Ruoli__c sul Custom Settings AbilitazioneGruppi__c per gestire eventuali future differenziazioni in base al Ruolo LDAP
        Map<String, AbilitazioneGruppi__c> totMap= AbilitazioneGruppi__c.getAll();
        Map<String, AbilitazioneGruppi__c> idCedMap= new Map<String, AbilitazioneGruppi__c>();
        Map<String, AbilitazioneGruppi__c> noIdCedMap= new Map<String, AbilitazioneGruppi__c>();
        for(String key:totMap.keySet()){
            if(key.split(';')[1]=='NULL'){
                noIdCedMap.put(key,totMap.get(key));
            }
            else{
                idCedMap.put(key,totMap.get(key));
            }
        }
        //Change-Account-Sharing END
        
        if ('beforeInsert'.equals(operation) || 'beforeUpdate'.equals(operation)) {
            for (User u : newRecord) {
                //Change-Account-Sharing START
                //String profilo = null;
                //if (!String.isEmpty(u.Profilo__c)) {
                    //Change-Account-Sharing START
                    //profilo = u.Profilo__c.replaceAll('\\.','_');
                    //profilo = u.Profilo__c;
                    
                //}
                
                if (String.isBlank(u.Profilo__c) || String.isBlank(u.abi__c) || String.isBlank(u.idced__c)) {
                    u.Gruppi_Pubblici__c = null;
                }
                else {
                    //Change-Account-Sharing START
                    //Profilo_BPER__mdt pBper = (Profilo_BPER__mdt)mProfili.get(profilo);
                    //u.Gruppi_Pubblici__c = (pBper!=null ? pBper.Gruppi_Pubblici__c : null);
                    String key=u.abi__c+';'+u.idced__c+';'+u.Profilo__c;
                    String key2=u.abi__c+';'+'NULL'+';'+u.Profilo__c;
                    if(idCedMap.containsKey(key)){
                        u.Gruppi_Pubblici__c=idCedMap.get(key).Gruppo__c;
                    }
                    else if(noIdCedMap.containsKey(key2)){
                        u.Gruppi_Pubblici__c=noIdCedMap.get(key2).Gruppo__c;
                    }
                    //Change-Account-Sharing END
                }
            }
        }
        else if ('afterInsert'.equals(operation) || 'afterUpdate'.equals(operation)) {
            Set<String> allGroups = new Set<String>();
            Set<Id> userIds = new Set<Id>();
            for (User u : newRecord) {
                userIds.add(u.Id);
                if (!String.isEmpty(u.Gruppi_Pubblici__c)) {
                    List<String> g = u.Gruppi_Pubblici__c.split(';');
                    allGroups.addAll(g);
                    mUserNew.put(u.Id,g);
                }
                if('afterUpdate'.equals(operation)){
                    if (!String.isEmpty(oldRecord.get(u.Id).Gruppi_Pubblici__c)) {
                        List<String> g1 = oldRecord.get(u.Id).Gruppi_Pubblici__c.split(';');
                        allGroups.addAll(g1);
                        mUserOld.put(u.Id,g1);
                    }
                }
            }
            Map<String,sObject>  mGruppi = new Map<String,sObject>();
            Map<String,sObject>  mGruppiById = new Map<String,sObject>();
            if (allGroups.size()>0) {
            	mGruppi = SV_Utilities.keyBy([
                	SELECT 	Id,
                			DeveloperName
                	FROM Group
                	WHERE DeveloperName IN:allGroups
            	], '{DeveloperName}', true);
                for (String key : mGruppi.keySet()) {
                    mGruppiById.put(mGruppi.get(key).Id,mGruppi.get(key));
                }
            }
            
            if ('afterInsert'.equals(operation)) {
                for (User u : newRecord) {
                    if (mUserNew.containsKey(u.Id)) {
                        List<String> groups = mUserNew.get(u.Id);
                        for (String g : groups) {
                            if (mGruppi.containsKey(g)) {
                                Group gr = (Group)mGruppi.get(g);
                                GroupMember gm = new GroupMember();
                                gm.UserOrGroupId = u.Id;
                                gm.GroupId = gr.Id;
                                groupMemberToInsert.add(gm);
                            }
                        }
                    }
                }
                if (groupMemberToInsert.size()>0) {
                    insert groupMemberToInsert;
                }
            }
            if ('afterUpdate'.equals(operation)) {
                List<GroupMember> gmToRemove = new List<GroupMember>();
                Map<String,sObject> mGroupMember = SV_Utilities.keyBy([
                    SELECT Id, GroupId, UserOrGroupId
                    FROM GroupMember
                    WHERE UserOrGroupId IN:userIds
                ], '{UserOrGroupId}_{GroupId}',true);
                for (User u : newRecord) {
                    User oldUser = oldRecord.get(u.Id);
                    if (u.Gruppi_Pubblici__c!=oldUser.Gruppi_Pubblici__c) {
                        // sono stati rimossi i gruppi pubblici
                        if (String.isEmpty(u.Gruppi_Pubblici__c) && !String.isEmpty(oldUser.Gruppi_Pubblici__c)) {
                            if (mUserOld.containsKey(u.Id)) {
                                List<String> groups = mUserOld.get(u.Id);
                                for (String g : groups) {
                                    if (mGruppi.containsKey(g)) {
                                        Group gr = (Group)mGruppi.get(g);
                                        if (mGroupMember.containsKey(u.Id+'_'+gr.Id)) {
                                     	   gmToRemove.add((GroupMember)mGroupMember.get(u.Id+'_'+gr.Id));
                                    	}
                                    }
                                }
                            }
                        } // sono stati aggiunti i gruppi pubblici
                        else if (!String.isEmpty(u.Gruppi_Pubblici__c) && String.isEmpty(oldUser.Gruppi_Pubblici__c)) {
                            if (mUserNew.containsKey(u.Id)) {
                                List<String> groups = mUserNew.get(u.Id);
                                for (String g : groups) {
                                    if (mGruppi.containsKey(g)) {
                                        Group gr = (Group)mGruppi.get(g);
                                        GroupMember gm = new GroupMember();
                                        gm.UserOrGroupId = u.Id;
                                        gm.GroupId = gr.Id;
                                        groupMemberToInsert.add(gm);
                                    }
                                }
                            }
                        } // sono stati variati i gruppi pubblici
                        else if (!String.isEmpty(u.Gruppi_Pubblici__c) && !String.isEmpty(oldUser.Gruppi_Pubblici__c)) {
                            List<String> oldGroups = mUserOld.get(u.Id);
                            List<String> newGroups = mUserNew.get(u.Id);
                            for (String key : newGroups) {
                                if (!oldGroups.contains(key)) {
                                    if (mGruppi.containsKey(key)) {
                                        Group gr = (Group)mGruppi.get(key);
                                        if (!mGroupMember.containsKey(u.Id+'_'+gr.Id)) {
                                        	GroupMember gm = new GroupMember();
                                        	gm.UserOrGroupId = u.Id;
                                        	gm.GroupId = gr.Id;
                                        	groupMemberToInsert.add(gm);
                                        }
                                    }
                                }
                            }
                            for (String key : oldGroups) {
                                if (!newGroups.contains(key)) {
                                    if (mGruppi.containsKey(key)) {
                                        Group gr = (Group)mGruppi.get(key);
                                        if (mGroupMember.containsKey(u.Id+'_'+gr.Id)) {
                                            gmToRemove.add((GroupMember)mGroupMember.get(u.Id+'_'+gr.Id));
                                        }
                                    }
                                }
                            }
                        }
                    }
                } 
                if (FollowUp.invokeFutureGruppi) {
                	updateGruppiPubblici(JSON.serialize(gmToRemove),JSON.serialize(groupMemberToInsert));
                }
                /*if (gmToRemove.size()>0) {
                    delete gmToRemove;
                }
                if (groupMemberToInsert.size()>0) {
                    insert groupMemberToInsert;
                }*/
            }
        }
    }
    
    @future
    private static void updateGruppiPubblici(String recordToDelete, String recordToInsert) {
        List<GroupMember> gmToDelete = (List<GroupMember>)JSON.deserialize(recordToDelete, List<GroupMember>.class);
        List<GroupMember> gmToInsert = (List<GroupMember>)JSON.deserialize(recordToInsert, List<GroupMember>.class);
        if (gmToDelete.size()>0) {
            delete gmToDelete;
        }
        if (gmToInsert.size()>0) {
            insert gmToInsert;
        }
    }
   /**
     * Name         :   impostaPermissionSet
     * Create Date  :   2020-11-11
     * Author       :   Ezio Dal Bo @TEN
     * Description  :   gestisce l'impostazione dei flag
     * Input        :   newRecord (List<User>) 
     */
    public static void impostaPermissionSet(List<User> newRecord) {
        Map<String,sObject> mpBper = MetadataUtility.getAllByMetadataName('Profilo_BPER__mdt');
        List<PermissionSetAssignment> psas = new List<PermissionSetAssignment>();
        Map<String,sObject> mPermissionSet = SV_Utilities.keyBy([
            SELECT	Id,
            		Name
            FROM PermissionSet
        ],'{Name}', true);
        
        for (User u : newRecord) {
            if (mpBper.containsKey(u.Profilo__c) && u.IsActive) {
                Profilo_BPER__mdt pBper = (Profilo_BPER__mdt)mpBper.get(u.Profilo__c);
                if (!String.isEmpty(pBper.PermissionSet__c)) {
                    List<String> ps = pBper.PermissionSet__c.split(';');
                    for (String key : ps) {
                        PermissionSetAssignment psa = new PermissionSetAssignment();
                        System.debug('AAA ps '+key+ ' '+mPermissionSet.get(key));
                        if (mPermissionSet.containsKey(key)) {
                        	psa.AssigneeId = u.Id;
                        	psa.PermissionSetId = mPermissionSet.get(key).Id;
                            psas.add(psa);
                        }
                    }
                }
            }
        }
        
        if (psas.size()>0) {
            Database.insert(psas, false);
        }
    }
    
    /**
     * Name         :   impostaFlagUtente
     * Create Date  :   2020-11-11
     * Author       :   Ezio Dal Bo @TEN
     * Description  :   gestisce l'impostazione dei flag
     * Input        :   newRecord (List<User>) 
     */
    public static void impostaFlagUtente(List<User> newRecord) {
        Map<String,sObject> mpBper = MetadataUtility.getAllByMetadataName('Profilo_BPER__mdt');
        for (User u : newRecord) {
            if (mpBper.containsKey(u.Profilo__c)) {
                Profilo_BPER__mdt pBper = (Profilo_BPER__mdt)mpBper.get(u.Profilo__c);
                if (!String.isBlank(pBper.Flags__c)) {
                    if (pBper.Flags__c.contains(';')) {
                    	List<String> flags = pBper.Flags__c.split(';');
                    	for (String flag : flags) {
                        	u.put(flag,true);
                    	}
                    }
                    else {
                        u.put(pBper.Flags__c,true);
                    }
                }
            }
        }
    }
    
    /**
     * Name         :   ribaltaCampi
     * Create Date  :   2020-11-17
     * Author       :   Ezio Dal Bo @TEN
     * Description  :   gestisce il ribaltamento di alcuni campi
     * Input        :   newRecord (List<User>) 
     */
    public static void ribaltaCampi(List<User> newRecord) {
        for (User u : newRecord) {
            u.PTF_RegistrationNumber__c = u.FederationIdentifier;
        }
    }
    
    /**
     * Name         :   impostaCallCenter
     * Create Date  :   2020-11-26
     * Author       :   Ezio Dal Bo @TEN
     * Description  :   gestisce il ribaltamento di alcuni campi
     * Input        :   newRecord (List<User>) 
     */
    public static void impostaCallCenter(List<User> newRecord) {
        List<CallCenter> cc = [
            SELECT  Id,
            		InternalName
            FROM CallCenter
            WHERE InternalName = 'SoftphoneCTI'
        ];
        for (User u : newRecord) {
            if (!'NEC_CC'.equals(u.Profilo__c) && !'NEC_CCSV'.equals(u.Profilo__c)) {
            	u.CallCenterId = null;
            }
            else {
                if (u.CallCenterId==null && cc.size()>0) {
                    u.CallCenterId = cc.get(0).Id;
                }
            }
        }
    }
    
    /**
     * Name         :   collegaContatto
     * Create Date  :   2020-11-11
     * Author       :   Ezio Dal Bo @TEN
     * Description  :   gestisce il collegamento tra il contatto e l'utente
     * Input        :   newRecord (List<User>) 
     */
    public static void collegaContatto(List<User> newRecord) {
        Map<String,User> mMatricolaUser = new Map<String,User>();
        for (User u : newRecord) {
            if (!String.isEmpty(u.FederationIdentifier)) {
                mMatricolaUser.put(u.FederationIdentifier,u);
            }
        }
        
        List<Contact> contacts = new List<Contact>();
        if (!mMatricolaUser.isEmpty()) {
        	contacts = [
            	SELECT 	Id,
            			PTF_RegistrationNumber__c,
            			PTF_User__c
            	FROM Contact
            	WHERE PTF_RegistrationNumber__c IN : mMatricolaUser.keySet()
        	];
        }
        if (contacts!=null && contacts.size()>0) {
            for (Contact c: contacts) {
                if (mMatricolaUser.containsKey(c.PTF_RegistrationNumber__c)) {
                    c.PTF_User__c = mMatricolaUser.get(c.PTF_RegistrationNumber__c).Id;
                }
            }
            
            if (FollowUp.invokeCollegaContatto) {
            	updateContacts(JSON.serialize(contacts));
            }
        }
    }
    
    @future
    private static void updateContacts(String record) {
        List<Contact> contacts = (List<Contact>)JSON.deserialize(record, List<Contact>.class);
        update contacts;
    }
    
    /**
     * Name         :   updateRuoloUtente
     * Create Date  :   2020-09-21
     * Author       :   Ezio Dal Bo @TEN
     * Description  :   gestisce il cambio di ruolo di un utente
     *                  - al cambio di ruolo dell'utente bisogna eliminare in modo logico tutti i doppi presidi collegati agli ndg di cui l'utnete è titolare di filiale
     * Input        :   newRecord (List<User>) , oldRecord (Map<Id,User>)
     */
    public static void updateRuoloUtente(List<User> newRecord, Map<Id,User> oldRecord) {
        System.debug('MC newRecord '+newRecord);
        System.debug('MC oldRecord '+oldRecord);
        Set<Id> userChangeRole = new Set<Id>();
        for (User cUser : newRecord) {
            User oUser = oldRecord.get(cUser.Id);
            // verifico se l'utente ha subito un cambio di ruolo
            if (cUser.UserRoleId!=oUser.UserRoleId) {
                userChangeRole.add(cUser.Id);
            }
        }
        
        //verifico se ci sono utente che hanno cambiato ruolo
        if (userChangeRole.size()>0) {
            // recupero gli Id di tutti i contatti in cui gli utenti risultano Titolari
            System.debug('MC userChangeRole '+userChangeRole);
            Map<String,SObject> mUserContact = SV_Utilities.keyBy([
                SELECT	Id,
                		PTF_User__c,
                		PTF_TipologiaRuolo__r.Name
                FROM Contact
                WHERE PTF_TipologiaRuolo__r.Name = 'Titolare'
                AND PTF_User__c IN:userChangeRole
            ], '{Id}',true);
            // se ce ne sono recupero tutti i Doppi Presidi
            if (mUserContact!=null && !mUserContact.isEmpty()) {
                System.debug('MC mUserContact '+mUserContact);
                List<NDGManagementMember__c> doppiPresidi = [
                    SELECT	Id,
                    		PTF_Gestore__c,
                    		PTF_EndDate__c,
                            PTF_EndDate_DT__c,
                    		RecordTypeId,
                    		RecordType.DeveloperName
                    FROM NDGManagementMember__c
                    WHERE PTF_EndDate__c = null
                    AND RecordType.DeveloperName = 'DoppioPresidio'
                    AND PTF_Gestore__c IN: mUserContact.keySet()
                ];
                if (doppiPresidi!=null && doppiPresidi.size()>0) {
                    for (NDGManagementMember__c dp : doppiPresidi) {
                        dp.PTF_EndDate__c = Date.today();
                        dp.PTF_EndDate_DT__c = Datetime.now();
                    }
                    if (FollowUp.invokeFutureUpdateUserDoppiPresidi) {
                    	updateDoppiPresidi(JSON.serialize(doppiPresidi));
                    }
                    if (FollowUp.invokeBatchUpdateUserDoppiPresidi) {
                    	Batch_TriggerOperation bto = new Batch_TriggerOperation();
                        bto.sObjList = doppiPresidi;
                        bto.operationType = 'update';
                        bto.sObjectType = 'NDGManagementMember__c';
                        Database.executeBatch(bto,200);
                    }
                    
                    //update doppiPresidi;
                }
            }
        }
    }
    
    @future
    private static void updateDoppiPresidi(String record) {
        List<NDGManagementMember__c> managementMemeber = (List<NDGManagementMember__c>)JSON.deserialize(record, List<NDGManagementMember__c>.class);
        update managementMemeber;
    }
    /** 
    public static void testRun() {
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
    }*/
}