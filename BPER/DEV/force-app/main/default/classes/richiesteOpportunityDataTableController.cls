public class richiesteOpportunityDataTableController {

    @AuraEnabled
    public static List<Opportunity> getAllData(String recordId) {
        System.debug('recordId: ' + recordId);

        // Recupera il campo CRM_JointOwnership__c dalla query
        List<String> jointOwnershipValues = new List<String>();
        List<CRM_AccountAccountJointOwnershipRelation__c> jointOwnershipRecords = [
            SELECT CRM_JointOwnership__c
            FROM CRM_AccountAccountJointOwnershipRelation__c
            WHERE CRM_Account__c = :recordId
        ];

        for (CRM_AccountAccountJointOwnershipRelation__c record : jointOwnershipRecords) {
            jointOwnershipValues.add(record.CRM_JointOwnership__c);
        }

        List<Id> accountIds = new List<Id>();

        accountIds.add(recordId);
        for (CRM_AccountAccountJointOwnershipRelation__c record : jointOwnershipRecords) {
            accountIds.add(record.CRM_JointOwnership__c);
        }

        // Recupera gli ID degli account associati ai cointestatari e aggiungili agli accountIds
        if (!jointOwnershipValues.isEmpty()) {
            List<CRM_AccountAccountJointOwnershipRelation__c> cointestatariRecords = [
                SELECT CRM_Account__c
                FROM CRM_AccountAccountJointOwnershipRelation__c
                WHERE CRM_JointOwnership__c IN :jointOwnershipValues
            ];

            for (CRM_AccountAccountJointOwnershipRelation__c record : cointestatariRecords) {
                accountIds.add(record.CRM_Account__c);
            }
        }

        System.debug('jointOwnershipValues: ' + jointOwnershipValues);
        System.debug('accountIds: ' + accountIds);

        // Recupera le Opportunity in base agli accountIds
        Id bstoreRtId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Opportunit_Bstore').getRecordTypeId();

        Date TODAY = Date.today();

        List<Opportunity> opps = [
            SELECT Id, RecordTypeId, RecordType.DeveloperName, CreatedDate, Name, Account.CRM_NDG__c, CRM_FaseFormula__c,
                Account.RecordType.Name, CRM_Prodotto__r.CRM_MacroGroup__c, CRM_Canale__c, CRM_Oggetto__c,
                CRM_Prodotto__r.CRM_Bisogno__c, CloseDate, StageName, CRM_EsitoContatto__c, CRM_Autore__c
            FROM Opportunity
            WHERE CRM_Canale__c = 'BSTORE'
                AND RecordTypeId = :bstoreRtId
                AND AccountId IN :accountIds
                AND (StageName != 'Chiuso' OR (StageName = 'Chiuso' AND CRM_Data_Esitazione__c = :TODAY))
        ];

        System.debug('opportunity: ' + opps);

        return opps;
    }
}