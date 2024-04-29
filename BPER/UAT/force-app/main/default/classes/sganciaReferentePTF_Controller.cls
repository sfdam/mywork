public with sharing class sganciaReferentePTF_Controller {

    @AuraEnabled
    public static List<Assignment__c> getWallet(String contactId) {

        System.debug('@@gr contactId: '+ contactId);

        List<Assignment__c> ass = [SELECT RecordType.DeveloperName, PTF_Gestore__r.CRM_NomeReferente__c, PTF_MicroWallet__r.CRM_numNDG__c, PTF_MicroWallet__c, PTF_MicroWallet__r.PTF_Pool__c, PTF_NomePortafoglio__c,PTF_ModelloDiServizio__c, PTF_Filiale__c FROM Assignment__c WHERE PTF_EndDate__c = null AND PTF_Gestore__c =: contactId];

        System.debug('@@gr ass: '+ ass);

        return ass;

    }

    @AuraEnabled
    public static List<Contact> getContact(String contactId) {

        System.debug('@@gr contactId: '+ contactId);

        List<Contact> con = [SELECT CRM_NomeReferente__c, PTF_RegistrationNumber__c, PTF_TipologiaRuolo__r.Name, PTF_MDSConcatList__c,PTF_UnitaOrganizzativaNoEncryption__c, PTF_OFS__c FROM Contact WHERE Id =: contactId];

        System.debug('@@gr ass: '+ con);

        return con;

    }

    @AuraEnabled
    public static void sganciaReferente(List<String> assignmentIds, String nomeReferente, String idReferente) {
        // List<Assignment__c> assignmentList = new List<Assignment__c>();

        //  for (String idAss : assignmentIds) {
        //      Assignment__c ass = new Assignment__c(Id= idAss, PTF_EndDate__c = Date.today());
        //      assignmentList.add(ass);
        //  }
        //  update assignmentList;

        sganciaReferentePTF_Batch batchAss = new sganciaReferentePTF_Batch();
        batchAss.listAssignmentToClose = assignmentIds;
        batchAss.nomeReferente = nomeReferente;
        batchAss.idReferente = idReferente;
        Database.executeBatch(batchAss, 200);
      
       

         
    }


}