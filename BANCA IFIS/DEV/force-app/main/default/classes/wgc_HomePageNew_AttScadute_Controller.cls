public with sharing class wgc_HomePageNew_AttScadute_Controller {

    @AuraEnabled
    public static WrapperData getData(){
        List<Task> contattiList = [SELECT id
                                 FROM Task 
                                 WHERE Recordtype.Developername = 'ContattoTelefonicoDiretto' 
                                 AND DataOraEsitazione__C = null 
                                 AND ActivityDate < today 
                                 AND Account.WGC_Specialista_Factoring__c = :UserInfo.getUserId()];
        system.debug(contattiList);

        List<Event> visiteList = [SELECT Id 
                                  FROM Event 
                                  WHERE Recordtype.Developername = 'VisitaCommerciale' 
                                  AND DataOraEsitazione__C = null 
                                  AND ActivityDate < today 
                                  AND Account.WGC_Specialista_Factoring__c = :UserInfo.getUserId()];
        system.debug(visiteList);

        List<Task> promemoriaList = [SELECT Id
                                     FROM Task 
                                     WHERE Recordtype.Developername = 'Promemoria' 
                                     AND Status != 'Chiuso' 
                                     AND ActivityDate < today 
                                     AND Account.WGC_Specialista_Factoring__c = :UserInfo.getUserId()];
        system.debug(promemoriaList);

        WrapperData vData = new WrapperData();
        vData.countContattiNonEistati = contattiList.size();
        vData.countVisiteNonEsitate = visiteList.size();
        vData.countPromemoriaNonEsitati = promemoriaList.size();
        return vData;

    }
   
    public class WrapperData {
        @AuraEnabled
        public Integer countContattiNonEistati = 0;
        @AuraEnabled
        public Integer countVisiteNonEsitate = 0;
        @AuraEnabled
        public Integer countPromemoriaNonEsitati = 0;
    }
}