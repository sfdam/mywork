public class MultipleAssignmentCtrl {

    @AuraEnabled
    public static List<Account> getRelatedNDGs(String recordId) {
        return [
            SELECT Id, Name, CRM_NDG__c, CRM_VAT__c, Phone, PTF_GruppoGestionale__c, PTF_NaturaGiuridica__c, Filiale__c, ModelloDiServizio__c
            FROM Account
            WHERE PTF_TechnicalWallet__c = :recordId
        ];
    }

    @AuraEnabled
    public static List<Wallet__c> getMicroWallets(String filiale, String modello) {
        return [
            SELECT Id, Name, PTF_ModelloDiServizio__c, Owner.Name
            FROM Wallet__c
            WHERE RecordType.Name LIKE '%Micro%'
//            AND PTF_Filiale__c =:filiale
            AND PTF_ModelloDiServizio__c = :modello
            ORDER BY CreatedDate DESC
        ];
    }

    @AuraEnabled
    public static void executeAssignment(String params) {
        AssignmentWrapper aw = (AssignmentWrapper) JSON.deserialize(params, AssignmentWrapper.Class);
        List<Account> accList = new List<Account>();
        for (String ndgId : aw.ndgIds) {
            Account acc = new Account(Id=ndgId, PTF_MicroWallet__c=aw.mwId);
            accList.add(acc);
        }
        update accList;
    }

    public class AssignmentWrapper {
        public List<String> ndgIds;
        public String mwId;
    }

}