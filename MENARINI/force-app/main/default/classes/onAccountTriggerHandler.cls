/* 

Created by: Lorenzo Vento 05-12-2022

Last modified by: Lorenzo Vento 05-12-2022

*/

public with sharing class onAccountTriggerHandler {

    public static final String profileNameUserInfo = [SELECT Name FROM Profile WHERE Id =: UserInfo.getProfileId()].Name;
    public static final list<ART_SalesRepProfile__mdt> customMetadataProfileName = [SELECT ART_ProfileName__c FROM ART_SalesRepProfile__mdt];
    public static list<String> fieldList = new List<String>();
    public static map<String, Schema.DescribeFieldResult> accFieldsToTrack = new map<String, Schema.DescribeFieldResult>();
    public static Map<String, Schema.SObjectField> allAccFieldsMap = Schema.SObjectType.Account.fields.getMap();
    
    public static void afterInsert(Map<Id, Account> newMapAccounts) {
        // Se il profilo dell’utente è uguale a quanto configurato nel custom metadata ART_SalesRepProfile.ProfileName, 
        // per ogni nuovo Account va creato un record dell’oggetto DCR legato al nuovo Account.
        set<string> SetProfile=new set<string>();
        for(ART_SalesRepProfile__mdt SRP:customMetadataProfileName){
            SetProfile.add(SRP.ART_ProfileName__c);
        }
        system.debug('SetProfile '+SetProfile);
        system.debug('profileNameUserInfo '+profileNameUserInfo);
        if (SetProfile.contains(profileNameUserInfo)) {//profileNameUserInfo == customMetadataProfileName
            
            List<ART_Data_Change_Request__c> listDCR = new List<ART_Data_Change_Request__c>();
            
            for (Id idAcc : newMapAccounts.keySet()) {
                ART_Data_Change_Request__c DCR = new ART_Data_Change_Request__c();
                DCR.ART_Status__c = 'Open';
                DCR.ART_Account__c = idAcc;
                DCR.ART_Requested_By__c = UserInfo.getUserId();
                DCR.ART_Requested_Date__c = Date.today();
                DCR.ART_Operation_Type__c = 'New Record';
                
                listDCR.add(DCR);
            }
            
            if (!listDCR.isEmpty()) {
                insert listDCR;
            }
        }
    } 

    public static void beforeUpdate(Map<Id, Account> oldMapAccounts, Map<Id, Account> newMapAccounts) {
        // Se il profilo dell’utente è uguale a quanto configurato nel custom metadata ART_SalesRepProfile.ProfileName, 
        // bisogna individuare tutti i campi del record modificati, per ognuno di essi va creato un nuovo record DCR 
        // legato all’account che si sta modificando e infine va resettato il campo modificato con quanto contenuto nell’OldValue.
            
        List<ART_Data_Change_Request__c> listDCR = new List<ART_Data_Change_Request__c>();
        set<string> SetProfile=new set<string>();
        for(ART_SalesRepProfile__mdt SRP:customMetadataProfileName){
            SetProfile.add(SRP.ART_ProfileName__c);
        }
        system.debug('SetProfile '+SetProfile);
        system.debug('profileNameUserInfo '+profileNameUserInfo);

        //alessandro di nardo @ten 
        for(Account accNew : newMapAccounts.values()){

            if(accNew.THR_VATNumber__c != oldMapAccounts.get(accNew.id).THR_VATNumber__c && SetProfile.contains(profileNameUserInfo)){
                accNew.addError(System.Label.ART_VatNumberNotEditable);
                return;
            }

        }
        
        if (SetProfile.contains(profileNameUserInfo)) {
            
            for (Schema.SObjectField accField : allAccFieldsMap.values()) {
                
                Schema.DescribeFieldResult describeResult = accField.getDescribe();
                     
                if (//only add fields that are visible to the current user
                    describeResult.isAccessible() &&
                    //do not add formula fields
                    !describeResult.isCalculated() &&
                    //don't add standard fields that are not necessary
                    describeResult.getName() != 'Id' &&
                    describeResult.getName() != 'CreatedDate' &&
                    describeResult.getName() != 'CreatedById' &&
                    describeResult.getName() != 'LastModifiedDate' &&
                    describeResult.getName() != 'LastModifiedById' &&
                    describeResult.getName() != 'SystemModstamp' &&
                    describeResult.getName() != 'IsDeleted' &&
                    describeResult.getName() != 'LastActivityDate' &&
                    describeResult.getName() != 'LastViewedDate' &&
                    describeResult.getName() != 'LastReferencedDate' 
                )
                {
                    accFieldsToTrack.put(describeResult.getName(), describeResult);
                    system.debug('key: ' + describeResult.getName() + ' value: ' + describeResult);
                }
            }            
            
            for (Id IdAcc : newMapAccounts.keySet()) {     
                Map<String, String> listModifiedFields = new map<String, String>();
                listModifiedFields = getChangedFields(idAcc, accFieldsToTrack);
                if (!listModifiedFields.isEmpty()) {
                    for (String field : listModifiedFields.keySet()) {
                        ART_Data_Change_Request__c DCR = new ART_Data_Change_Request__c();
                        DCR.ART_Status__c = 'Open';
                        DCR.ART_Field__c = listModifiedFields.get(field) + ' - ' + field;
                        DCR.ART_Old_Value__c = String.valueOf(oldMapAccounts.get(IdAcc).get(field));
                        DCR.ART_New_Value__c = String.valueOf(newMapAccounts.get(IdAcc).get(field));
                        DCR.ART_Account__c = idAcc;
                        DCR.ART_Requested_By__c = UserInfo.getUserId();
                        DCR.ART_Requested_Date__c = Date.today();
                        DCR.ART_Operation_Type__c = 'Update Existing';   
                        
                        listDCR.add(DCR);
                        newMapAccounts.get(IdAcc).put(field, oldMapAccounts.get(IdAcc).get(field));
                    }
                }
            }
        
            if (!listDCR.isEmpty()) {
                insert listDCR;
            }        
        }
    }

    public static map<String, String> getChangedFields(ID recordId, map<String, Schema.DescribeFieldResult> accFieldsToTrack) {
        
        map<String, String> changedFields = new map<String, String>();
        Account oldAcc = (Account)Trigger.OldMap.get(recordId);
        Account newAcc = (Account)Trigger.NewMap.get(recordId);
    
        for (Schema.DescribeFieldResult fieldDescribe : accFieldsToTrack.values()) {
            if (oldAcc.get(fieldDescribe.getName()) != newAcc.get(fieldDescribe.getName())) {
                changedFields.put(fieldDescribe.getName(), fieldDescribe.getLabel());
            }
        }
        return changedFields;
    }
}