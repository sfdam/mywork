public class THR_CaseTriggerHandler {

    public static Map<String, String> queueRolesMap = new Map<String, String>();
    public static Map<String, String> queueNamesMap = new Map<String, String>();
    public static Map<Id, Group> roleMap = new Map<Id, Group>([SELECT Id, Name, DeveloperName, RelatedId, Type FROM Group WHERE type = 'Role']);
    public static List<GroupMember> queueList = [SELECT Group.Id, Group.Name, Group.DeveloperName, UserOrGroupId FROM GroupMember WHERE Group.Type = 'Queue' AND UserOrGroupId IN :roleMap.keySet()];

    public static void assignEntitlement(List<Case> newCaseList){

        // Get country to entitlement map
        Map<String,ID> countryToEntitlement = new Map<String,ID>();
        List<Entitlement> entitlementist = [SELECT Id, THR_Country__c FROM Entitlement WHERE Status = 'Active'];
        for(Entitlement singleEntitlement: entitlementist){
            countryToEntitlement.put(singleEntitlement.THR_Country__c, singleEntitlement.Id);
        }

        // Set entitlement for each new Case
        for(Case singleCase : newCaseList)
        {
            if(countryToEntitlement.containsKey(singleCase.THR_Country__c)){
                singleCase.EntitlementId = countryToEntitlement.get(singleCase.THR_Country__c);
            }
        }

    }
    
    
      public static void completeMilestone(Map<Id,Case> newCaseMap,Map<Id,Case> oldCaseMap){
          Set<Id> newCaseIdSet = newCaseMap.keyset();
          system.debug('@@@@newCaseMap is '+newCaseMap);
          system.debug('@@@@oldCaseMap is '+oldCaseMap);

          List<CaseMilestone> caseMilList = [SELECT Id,CaseId,Case.Status,Case.CreatedDate, Case.SlaExitDate,
                                             StartDate,TargetDate,CompletionDate,MilestoneTypeId,IsCompleted, 
                                             IsViolated, CreatedDate, LastModifiedDate, LastModifiedById 
                                             FROM CaseMilestone 
                                             WHERE CaseId IN :newCaseIdSet 
                                             AND CompletionDate = NULL];
          system.debug('@@@@caseMilList is '+caseMilList);
		           
          if(!caseMilList.isEmpty()){
              for(CaseMilestone currCaseMil : caseMilList){
                  if(oldCaseMap.get(currCaseMil.CaseId).Status != newCaseMap.get(currCaseMil.CaseId).Status &&
                     'Closed'.equals(newCaseMap.get(currCaseMil.CaseId).Status) /*&&
                     newCaseMap.get(currCaseMil.CaseId).LastModifiedDate < currCaseMil.TargetDate*/){
                         currCaseMil.CompletionDate= System.now();
                     }
              }

              update caseMilList;
          }
          
          
     }
    public static void createNewCaseOwnershipRecords(List<Case> newCaseList){

        //popolo una mappa <Ruolo, Coda> con i ruoli che fanno parte di una coda
        for (GroupMember gm : queueList){
            if(roleMap.containsKey(gm.UserOrGroupId)) {
                queueRolesMap.put(roleMap.get(gm.UserOrGroupId).DeveloperName, gm.Group.DeveloperName);
            }
            queueNamesMap.put(gm.Group.DeveloperName, gm.Group.DeveloperName);
        }
        // Create new Case OwnerShip record for each new Case
        Case_Ownership__c coP;
        List<Case_Ownership__c> caseOwnerList = new List<Case_Ownership__c>();
        for(Case singleCase : newCaseList) {
            coP = createSingleCaseOwnershipRecord(singleCase);
            caseOwnerList.add(coP);
        }
        insert caseOwnerList;

    }

    public static void updateCaseOwnershipRecord(Map<Id,Case> newCaseMap,Map<Id,Case> oldCaseMap){


        for (GroupMember gm : queueList){
            if(roleMap.containsKey(gm.UserOrGroupId)) {
                queueRolesMap.put(roleMap.get(gm.UserOrGroupId).DeveloperName, gm.Group.DeveloperName);
            }
            queueNamesMap.put(gm.Group.DeveloperName, gm.Group.DeveloperName);
        }

        List<Case_Ownership_Partial__c> partialToUpsert = new List<Case_Ownership_Partial__c>();
        List<Case_Ownership__c> ownershipsToUpsert = new List<Case_Ownership__c>();

        Set<String> newOwnerIds = new Set<String>();
        Set<String> oldOwnerIds = new Set<String>();
        Set<String> sameRoleIds = new Set<String>();
        Map <String, Case> newOwnerCasesMap = new Map <String, Case>();
        Map <String, Case> oldOwnerCasesMap = new Map <String, Case>();


        //old version
        /*
        for (Id key : newCaseMap.keyset()) {
            //controllo se nei nuovi casi è cambiato il campo owner
            if(newCaseMap.get(key).OwnerId != oldCaseMap.get(key).OwnerId) {

                System.debug('@@@@@@@@@@@@@@@@@ sono a riga 76, il case id è: '+ key);
                //popolo una mappa <nuovo owner id + | + case Id, case corrispondente>
                newOwnerCasesMap.put(newCaseMap.get(key).Owner_Developer_Name_Formula__c + '|'+ newCaseMap.get(key).Id, newCaseMap.get(key));

                //popolo un set di id con i nuovi e i vecchi owner
                newOwnerIds.add(newCaseMap.get(key).Owner_Developer_Name_Formula__c);
                System.debug('################# nuovo owner developer name formula: '+ newCaseMap.get(key).Owner_Developer_Name_Formula__c);
                oldOwnerIds.add(oldCaseMap.get(key).Owner_Developer_Name_Formula__c);
                System.debug('################# vecchio owner developer name formula: '+ oldCaseMap.get(key).Owner_Developer_Name_Formula__c);

                if(newCaseMap.get(key).Owner_Developer_Name_Formula__c == oldCaseMap.get(key).Owner_Developer_Name_Formula__c) {
                    sameRoleIds.add(oldCaseMap.get(key).Owner_Developer_Name_Formula__c);
                }

                //controllo se il case è stato chiuso
            } else if (newCaseMap.get(key).Status != oldCaseMap.get(key).Status && newCaseMap.get(key).Status == 'Closed') {
                System.debug('@@@@@@@@@@@@@@@@@ sono a riga 86, il case id è: '+ key);
                oldOwnerIds.add(oldCaseMap.get(key).Owner_Developer_Name_Formula__c);
            }
        }*/

       //new version
        Set<String> newQueueNames = new Set<String>();
        Set<String> oldQueueNames = new Set<String>();
        String oldOwner;
        String newOwner;
        for (Id key : newCaseMap.keyset()) {

            //controllo se nei nuovi casi è cambiato il campo owner
            oldOwner = oldCaseMap.get(key).Owner_Developer_Name_Formula__c;
            newOwner = newCaseMap.get(key).Owner_Developer_Name_Formula__c;

            if(newCaseMap.get(key).OwnerId != oldCaseMap.get(key).OwnerId) {
                //popolo una mappa <nuovo owner id, case corrispondente>

                if(queueRolesMap.containsKey(oldOwner)) {
                    oldOwnerCasesMap.put(queueRolesMap.get(oldOwner), oldCaseMap.get(key));
                } else if(queueNamesMap.containsKey(oldOwner)){
                    oldOwnerCasesMap.put(queueNamesMap.get(oldOwner), oldCaseMap.get(key));
                } else {
                    oldOwnerCasesMap.put(oldOwner, oldCaseMap.get(key));
                }

                if(queueRolesMap.containsKey(newOwner)) {
                    newOwnerCasesMap.put(queueRolesMap.get(newOwner), newCaseMap.get(key));
                } else if(queueNamesMap.containsKey(newOwner)){
                    newOwnerCasesMap.put(queueNamesMap.get(newOwner), newCaseMap.get(key));
                } else {
                    newOwnerCasesMap.put(newOwner, newCaseMap.get(key));
                }

                if(queueRolesMap.containsKey(newOwner) && queueRolesMap.containsKey(oldOwner)) {
                    if(queueRolesMap.get(newOwner) == queueRolesMap.get(oldOwner)) {
                        sameRoleIds.add(queueRolesMap.get(oldOwner));
                    }
                } else if(queueNamesMap.containsKey(newOwner) && queueRolesMap.containsKey(oldOwner)) {
                    if(queueNamesMap.get(newOwner) == queueRolesMap.get(oldOwner)) {
                        sameRoleIds.add(queueRolesMap.get(oldOwner));
                    }
                } else if(queueRolesMap.containsKey(newOwner) && queueNamesMap.containsKey(oldOwner)) {
                    if(queueRolesMap.get(newOwner) == queueNamesMap.get(oldOwner)) {
                        sameRoleIds.add(queueNamesMap.get(oldOwner));
                    }
                } else if (newOwner == oldOwner) {
                    sameRoleIds.add(oldOwner);
                }

                //controllo se il case è stato chiuso
            } else if (newCaseMap.get(key).Status != oldCaseMap.get(key).Status && newCaseMap.get(key).Status == 'Closed') {

                if(queueRolesMap.containsKey(oldOwner)) {
                    oldOwnerCasesMap.put(queueRolesMap.get(oldOwner), oldCaseMap.get(key));
                } else if(queueNamesMap.containsKey(oldOwner)){
                    oldOwnerCasesMap.put(queueNamesMap.get(oldOwner), oldCaseMap.get(key));
                } else {
                    oldOwnerCasesMap.put(oldOwner, oldCaseMap.get(key));
                }
            }

        }

        //old version
        /*
        //recupero il parziale rimasto aperto dai CaseOwnership con Id corrispondente all'old OwnerId dei Case modificati o chiusi
        List<Case_Ownership_Partial__c> partialOwnershipsList = [SELECT Id, Partial_Owner_Name__c, Case_Ownership__c, Case_Ownership__r.Case__c, Case_Ownership__r.Case_Owner_User__c, Case_Ownership__r.Case_Owner_Id__c, Case_Ownership__r.Is_Current_Owner__c, Case_Ownership__r.Case__r.Status, Case_Ownership__r.Case__r.THR_Country__c, Days__c, Close_Date__c, CreatedDate from Case_Ownership_Partial__c WHERE Close_Date__c = null and (Case_Ownership__r.Is_Current_Owner__c = false or Case_Ownership__r.Case__r.Status = 'Closed' or (Case_Ownership__r.Is_Current_Owner__c = true and Case_Ownership__r.Case_Owner_Id__c in :sameRoleIds))  and Case_Ownership__r.Case_Owner_Id__c in :oldOwnerIds];
        */

        //new version
        //recupero il parziale rimasto aperto dai CaseOwnership con Id corrispondente all'old OwnerId dei Case modificati o chiusi
        List<Case_Ownership_Partial__c> partialOwnershipsList = [SELECT Id, Partial_Owner_Name__c, Case_Ownership__c, Case_Ownership__r.Case__c, Case_Ownership__r.Case_Owner_User__c, Case_Ownership__r.Case_Owner_Id__c, Case_Ownership__r.Is_Current_Owner__c, Case_Ownership__r.Case__r.Status, Case_Ownership__r.Case__r.THR_Country__c, Days__c, Close_Date__c, CreatedDate from Case_Ownership_Partial__c WHERE Close_Date__c = null and (Case_Ownership__r.Is_Current_Owner__c = false or Case_Ownership__r.Case__r.Status = 'Closed'or (Case_Ownership__r.Is_Current_Owner__c = true and Case_Ownership__r.Case_Owner_Id__c in :sameRoleIds))  and Case_Ownership__r.Case_Owner_Id__c in :oldOwnerCasesMap.keySet()];

        //old version
        /*
        for(Case_Ownership_Partial__c partOwn : partialOwnershipsList) {
            if(newCaseMap.containsKey(partOwn.Case_Ownership__r.Case__c)) {
                System.debug('@@@@@@@@@@@@@@@@@ sono a riga 95, il case ownership id è: '+ partOwn.Id);
                partOwn.Close_Date__c = System.now();
                partOwn.Days__c = THR_DateUtils.getDatesDifference(partOwn.CreatedDate, partOwn.Close_Date__c, partOwn.Case_Ownership__r.Case__r.THR_Country__c);
                partOwn.Is_Current_Partial__c = false;
                System.debug('@@@@@@@@ days: '+partOwn.Days__c);
                partialToUpsert.add(partOwn);
            }
        }*/

        //new version
        for(Case_Ownership_Partial__c partOwn : partialOwnershipsList) {
            if(oldOwnerCasesMap.containsKey(partOwn.Case_Ownership__r.Case_Owner_Id__c)) {
                if(partOwn.Case_Ownership__r.Case__c == oldOwnerCasesMap.get(partOwn.Case_Ownership__r.Case_Owner_Id__c).Id) {
                    partOwn.Close_Date__c = System.now();
                    partOwn.Days__c = THR_DateUtils.getDatesDifference(partOwn.CreatedDate, partOwn.Close_Date__c, partOwn.Case_Ownership__r.Case__r.THR_Country__c);
                    partOwn.Is_Current_Partial__c = false;
                    System.debug('@@@@@@@@ days: '+partOwn.Days__c);
                    partialToUpsert.add(partOwn);
                }
            }
        }

        //recupero i record di CaseOwnerships con Id corrispondente al new OwnerId, per controllare se già ne esistono con quell'OwnerId
        List<Case_Ownership__c> caseOwnershipsList = [SELECT Id, Case__c, Case__r.Status, Case_Owner_Id__c, Case_Owner_Name__c, Case_Owner_User__c from Case_Ownership__c WHERE Case_Owner_Id__c in :newOwnerCasesMap.keySet() and Case__c in :newCaseMap.keySet()];

        Map <String, Case_Ownership__c> ownershipMap = new Map <String, Case_Ownership__c>();
        for(Case_Ownership__c caseOwn : caseOwnershipsList) {
            if(!ownershipMap.containsKey(caseOwn.Case_Owner_Id__c + '|' + caseOwn.Case__c)) {
                ownershipMap.put(caseOwn.Case_Owner_Id__c + '|' + caseOwn.Case__c, caseOwn);
            }
        }
        Case_Ownership_Partial__c newPartial;
        Case_Ownership__c newCaseOwnership;
        Case cs;

        //old version
        /*
        for(String key : newOwnerCasesMap.keySet()) {
            if(ownershipMap.containsKey(key) {
                System.debug('@@@@@@@@@@@@@@@@@ sono a riga 118, il case ownership esiste già ed è: '+ ownershipMap.get(key));
                newCaseOwnership = ownershipMap.get(key);
                cs = newOwnerCasesMap.get(key);
                newCaseOwnership.Case_Owner_Name__c = cs.Owner_Name_Formula__c;
                if(cs.OwnerId.getSObjectType().getDescribe().getName().equals('User')) {
                    newCaseOwnership.Case_Owner_User__c = cs.OwnerId;
                }
                newPartial = new Case_Ownership_Partial__c(Case_Ownership__c = ownershipMap.get(key).Id, Partial_Owner_Name__c = cs.Owner_Name_Formula__c, Is_Current_Partial__c = true);
                ownershipsToUpsert.add(newCaseOwnership);
                partialToUpsert.add(newPartial);
            } else {
                System.debug('@@@@@@@@@@@@@@@@@ sono a riga 122, il case ownership NON esiste già e lowner è: '+ key);
                newCaseOwnership = createSingleCaseOwnershipRecord(newOwnerCasesMap.get(key));
                ownershipsToUpsert.add(newCaseOwnership);
            }
        }
        upsert ownershipsToUpsert;
        upsert partialToUpsert;*/

        //new version
        for(String key : newOwnerCasesMap.keySet()) {
            if(ownershipMap.containsKey(key+'|'+newOwnerCasesMap.get(key).Id)) {
                newCaseOwnership = ownershipMap.get(key+'|'+newOwnerCasesMap.get(key).Id);
                cs = newOwnerCasesMap.get(key);
                newCaseOwnership.Case_Owner_Name__c = cs.Owner_Name_Formula__c;
                if(cs.OwnerId.getSObjectType().getDescribe().getName().equals('User')) {
                    newCaseOwnership.Case_Owner_User__c = cs.OwnerId;
                }
                newPartial = new Case_Ownership_Partial__c(Case_Ownership__c = ownershipMap.get(key+'|'+newOwnerCasesMap.get(key).Id).Id, Partial_Owner_Name__c = cs.Owner_Name_Formula__c, Is_Current_Partial__c = true);
                ownershipsToUpsert.add(newCaseOwnership);
                partialToUpsert.add(newPartial);
            } else {
                newCaseOwnership = createSingleCaseOwnershipRecord(newOwnerCasesMap.get(key));
                ownershipsToUpsert.add(newCaseOwnership);
            }
        }
        upsert ownershipsToUpsert;
        upsert partialToUpsert;

    }


    /*//old version
    public static Case_Ownership__c createSingleCaseOwnershipRecord(Case cs){

        // Create new Case OwnerShip record for each new Case
        Case_Ownership__c caseOwnership = new Case_Ownership__c(Case__c = cs.Id, Case_Owner_Id__c = cs.Owner_Developer_Name_Formula__c, Case_Owner_Name__c = cs.Owner_Name_Formula__c);
        //caseOwnership.Case_Owner_Id__c = String.isNotBlank(cs.Owner_Developer_Name_Formula__c)? cs.Owner_Developer_Name_Formula__c : cs.OwnerId;
        if(cs.OwnerId.getSObjectType().getDescribe().getName().equals('User')) {
            caseOwnership.Case_Owner_User__c = cs.OwnerId;
        }

        return caseOwnership;

    }*/

    //new version
    public static Case_Ownership__c createSingleCaseOwnershipRecord(Case cs){

        // Create new Case OwnerShip record for each new Case
        Case_Ownership__c caseOwnership = new Case_Ownership__c(Case__c = cs.Id, Case_Owner_Name__c = cs.Owner_Name_Formula__c);
        //check if it's a user or a queue
        if(cs.OwnerId.getSObjectType().getDescribe().getName().equals('User')) {
            caseOwnership.Case_Owner_User__c = cs.OwnerId;
            if(queueRolesMap.containsKey(cs.Owner_Developer_Name_Formula__c)) {
                caseOwnership.Case_Owner_Id__c = queueRolesMap.get(cs.Owner_Developer_Name_Formula__c);
            } else {
                caseOwnership.Case_Owner_Id__c = cs.Owner_Developer_Name_Formula__c;
            }
        } else {
            caseOwnership.Case_Owner_Id__c = cs.Owner_Developer_Name_Formula__c;
        }
        return caseOwnership;

    }


}