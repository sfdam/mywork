public class OnRelazioneDiCointestazioneHandler {
    public static void UpdateNucleoCointestazione(List<CRM_AccountAccountJointOwnershipRelation__c> TriggerNew ){
        List<Account> cointToUpdate= new List<Account>();
        List<String> primaryNDGIds= new List<String>();
        
        Map<String,String> cointestazioneToPrimaryNDG = new Map<String,String>();
        for(CRM_AccountAccountJointOwnershipRelation__c rel:TriggerNew){
            if(rel.CRM_PrimaryNDG__c == true){
                cointestazioneToPrimaryNDG.put(rel.CRM_JointOwnership__c, rel.CRM_Account__c);
                primaryNDGIds.add(rel.CRM_Account__c);
            }
        }
        Map<Id, Account> primaryNDG =new Map<Id, Account>([SELECT Id, PTF_Nucleo__c FROM Account Where Id IN:primaryNDGIds]);
        //primaryNDG =SV_Utilities.keyBy([SELECT Id, PTF_Nucleo__c FROM Account Where Id IN:primaryNDGIds], 'Id', false);
        for(String cointestazioneId:cointestazioneToPrimaryNDG.keySet()){
            Account cointestazione= new Account();
            cointestazione.Id=cointestazioneId;
            cointestazione.PTF_Nucleo__c=primaryNDG.get(cointestazioneToPrimaryNDG.get(cointestazioneId)).PTF_Nucleo__c;
            cointToUpdate.add(cointestazione);
        }
        update cointToUpdate;
    }
}