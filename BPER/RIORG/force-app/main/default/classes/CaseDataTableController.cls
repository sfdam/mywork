/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 10-09-2020
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
 * Modifications Log 
 * Ver   Date         Author                               Modification
 * 1.0   09-29-2020   ChangeMeIn@UserSettingsUnder.SFDoc   Initial Version
**/
public with sharing class CaseDataTableController {
    
    @AuraEnabled
    public static List<Case> getAllData(String recordId, Integer pagina){
        List<Case> cases = new List<Case>();
        if(pagina==1){
            cases=[SELECT Id, CRM_Claim__c, CRM_Complaint__c, CRM_FirstOwner__r.Name, Owner.Name, CRM_BloccoNEW__c, CRM_OwnerPolo__c, CRM_OwnerTeam__c,
            CRM_NotHesitatedCase__c, CaseNumber, CreatedDate, toLabel(CRM_Area__c), toLabel(CRM_Hesitation__c),
                            toLabel(Status), toLabel(Origin), toLabel(CRM_Scope__c), CreatedBy.Name,CRM_IsPresentActivity__c
                          FROM Case 
                          WHERE AccountId=:recordId ORDER BY CaseNumber DESC];
    
           
        }
        if(pagina==3){
            FinServ__FinancialAccount__c prod= [SELECT FinServ__PrimaryOwner__c  FROM FinServ__FinancialAccount__c WHERE Id=:recordId];
            cases=[SELECT Id, CRM_Claim__c, CRM_Complaint__c, CRM_FirstOwner__r.Name, Owner.Name, CRM_BloccoNEW__c, CRM_OwnerPolo__c, CRM_OwnerTeam__c,
                            CRM_NotHesitatedCase__c, CaseNumber, CreatedDate, toLabel(CRM_Area__c), toLabel(CRM_Hesitation__c),
                            toLabel(Status), toLabel(Origin), toLabel(CRM_Scope__c), CreatedBy.Name,CRM_IsPresentActivity__c
                    FROM Case 
                    WHERE AccountId=:prod.FinServ__PrimaryOwner__c ORDER BY CaseNumber DESC]; 
        }
        if(pagina==2){
            CRM_Channel__c channel= [SELECT CRM_Account__c FROM CRM_Channel__c WHERE Id=:recordId];
            cases=[SELECT Id, CRM_Claim__c, CRM_Complaint__c, CRM_FirstOwner__r.Name, Owner.Name, CRM_BloccoNEW__c, CRM_OwnerPolo__c, CRM_OwnerTeam__c,
                        CRM_NotHesitatedCase__c, CaseNumber, CreatedDate, toLabel(CRM_Area__c), toLabel(CRM_Hesitation__c),
                        toLabel(Status), toLabel(Origin), toLabel(CRM_Scope__c), CreatedBy.Name,CRM_IsPresentActivity__c
                    FROM Case 
                    WHERE AccountId=:channel.CRM_Account__c ORDER BY CaseNumber DESC]; 
        }
        if(pagina==4){
            cases=[SELECT Id, CRM_Claim__c, CRM_Complaint__c, CRM_FirstOwner__r.Name, Owner.Name, CRM_BloccoNEW__c, CRM_OwnerPolo__c, CRM_OwnerTeam__c,
                        CRM_NotHesitatedCase__c, CaseNumber, CreatedDate, toLabel(CRM_Area__c), toLabel(CRM_Hesitation__c),
                        toLabel(Status), toLabel(Origin), toLabel(CRM_Scope__c), CreatedBy.Name,CRM_IsPresentActivity__c
                    FROM Case 
                    WHERE FinServ__FinancialAccount__c=:recordId ORDER BY CaseNumber DESC]; 
        }
        return cases;
    }

    @AuraEnabled
    public static string getRecordTypeId(String sObjName,String recTypeDevName) {
        /*String recTypeId = null;
        try {
            recTypeId = SV_Utilities.getRecordTypeByDeveloperName(sObjName, recTypeDevName);
        }
        catch(Exception exc) {
            throw new AuraHandledException(exc.getMessage());
        }
        return recTypeId;
    }*/
    Schema.DescribeSObjectResult dsr = Case.SObjectType.getDescribe();
    Schema.RecordTypeInfo defaultRecordType;
    for(Schema.RecordTypeInfo rti : dsr.getRecordTypeInfos()) {
        if(rti.isDefaultRecordTypeMapping()) {
            defaultRecordType = rti;
        }
    }

    return defaultRecordType.getRecordTypeId();
}

    @AuraEnabled
    public static SObject getInfo(String sObjName, String recId) {
        SObject sObj = null;
        if (('FinServ__FinancialAccount__c').equals(sObjName)) {
            FinServ__FinancialAccount__c fa = [
                SELECT  Id, 
                        FinServ__PrimaryOwner__c 
                FROM FinServ__FinancialAccount__c
                WHERE Id =:recId
            ];
            sObj = fa;
        }
        if (('CRM_Channel__c').equals(sObjName)) {
            CRM_Channel__c ch = [
                SELECT  Id, 
                        CRM_Account__c 
                FROM CRM_Channel__c
                WHERE Id =:recId
            ];
            sObj = ch;
        }
        return sObj;
    }
}