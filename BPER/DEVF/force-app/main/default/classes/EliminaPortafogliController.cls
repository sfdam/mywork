public class EliminaPortafogliController {

    // LWC -------------------
    @AuraEnabled
    public static Object init(){
        return new Map<String, Object>{
            'recordList' => [SELECT ID, Name, PTF_ModelloDiServizio__c, PTF_Banca__c, PTF_Banca__r.Name, PTF_Banca__r.FinServ__BankNumber__c, PTF_DirezioneRegionale__c, PTF_DirezioneRegionale__r.Name, PTF_Filiale__c, PTF_Filiale__r.Name, CRM_ReferenteFormula__c, PTF_isPTFTecnico__c FROM Wallet__c WHERE PTF_DeletionDate__c = null AND CRM_numNDG__c = 0 AND 
            Id NOT IN (SELECT PTF_MicroWallet__c FROM Assignment__c WHERE RecordType.DeveloperName = 'Primario' AND PTF_EndDate__c = NULL) AND
            Id NOT IN (SELECT PTF_Destinazione__c FROM WorkOrder WHERE Status = 'Pending') AND (PTF_ModelloDiServizio__c IN ('Personal', 'Small Business', 'Private', 'Consulenti Finanziari', 'Corporate') OR PTF_isPTFTecnico__c = true)]
        };
    }

    @AuraEnabled
    public static void eliminaPortafogli(List<Wallet__c> wallets){
        for (Wallet__c portafoglio : wallets) {
            portafoglio.PTF_DeletionDate__c = Date.today();
        }
        update wallets;
    }
}