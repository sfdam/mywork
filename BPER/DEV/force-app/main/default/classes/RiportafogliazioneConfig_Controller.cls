public with sharing class RiportafogliazioneConfig_Controller {
   
    @AuraEnabled
    public static List<Riportafogliazione_Conf__c> getAllData(){
        List<Riportafogliazione_Conf__c> returnList = [SELECT id,  PTF_Direzione_Territoriale__r.Name, PTF_Id_Ced__c, PTF_ABI__c, Perc_Affinamento__c, Tipologia_Spostamento__c, Sottotipologia_Spostamento__c 
                                                       FROM Riportafogliazione_Conf__c ];
        return returnList;
    }

    
    @AuraEnabled
    public static void updatePercent(List<Riportafogliazione_Conf__c> recordsToUpdate) {
        try {
            for(Riportafogliazione_Conf__c rip : recordsToUpdate){
                rip.Perc_Affinamento__c = rip.Perc_Affinamento__c*100;
            }
            update recordsToUpdate;
        } catch (Exception e) {
            System.debug('err: ' + e.getMessage());
        }
    }
}