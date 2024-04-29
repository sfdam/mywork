public class WGC_HomePageNew_Portafoglio_Controller {

     
    @AuraEnabled
    public static WrapperData getData(){
        WrapperData vData = new WrapperData();
        try {
            List<Opportunity> oppList = [SELECT StageName,
                                                WGC_Data_Fase_Valutazione__c,
                                                WGC_Data_Fase_Perfezionamento_Contratto__c,
                                                WGC_Data_Fase_In_Istruttoria__c 
                                         FROM Opportunity 
                                         WHERE Tipologia_Opportunit__c='REVI' 
                                         AND RecordType.DeveloperName = 'IFISOpportunitaFactoring' 
                                         AND Account.WGC_Qualifica_Corporate__c IN ('Prospect', 'Debitore inattivo','Debitore dormiente','Debitore in avvio','Debitore non operante','Ex debitore', 'Debitore attivo') 
                                         AND Account.WGC_Specialista_Factoring__c = :UserInfo.getUserId()
                                         AND StageName IN ('In Istruttoria', 'Valutazione Pratica', 'Perfezionamento Contratto', 'Attivazione prodotto')];

            System.debug(LoggingLevel.DEBUG,'## AT oppList: '+oppList);
            vData.faseList = oppList;

            Date dateFerme30gg = Date.today().addDays(-30);
            vData.data30g = dateFerme30gg;

            List<Opportunity> oppFerme = [SELECT WGC_Data_Fase_In_Istruttoria__c, 
                                                 WGC_Data_Fase_Perfezionamento_Contratto__c, 
                                                 WGC_Data_Fase_Valutazione__c, 
                                                 StageName 
                                          FROM Opportunity 
                                          WHERE StageName IN  ('In Istruttoria', 'Valutazione Pratica', 'Perfezionamento Contratto') 
                                          AND (WGC_Data_Fase_In_Istruttoria__c < :dateFerme30gg OR WGC_Data_Fase_Perfezionamento_Contratto__c < : dateFerme30gg OR WGC_Data_Fase_Valutazione__c < :dateFerme30gg)
                                          AND Account.WGC_Specialista_Factoring__c = :UserInfo.getUserId()];

            System.debug(LoggingLevel.DEBUG,'## AT oppFerme: '+oppFerme);
            vData.ferme = oppFerme;

            List<Opportunity> oppVinteList = [SELECT Id
                                              FROM Opportunity 
                                              WHERE StageName = 'Vinta' AND Account.WGC_Qualifica_Corporate_Data__c = THIS_YEAR AND WGC_Data_Fase_Chiusa_Vinta__c = THIS_YEAR AND Account.WGC_Qualifica_Corporate__c = 'Cliente attivo'
                                              AND Account.WGC_Specialista_Factoring__c = :UserInfo.getUserId()];

            System.debug(LoggingLevel.DEBUG,'## AT oppListVinte: '+oppVinteList);

            vData.vinte = oppVinteList.size();
           
            List<Opportunity> oppPerse = [SELECT Id FROM Opportunity WHERE StageName = 'Persa' AND CloseDate = THIS_YEAR AND Account.WGC_Specialista_Factoring__c = :UserInfo.getUserId()];
            System.debug(LoggingLevel.DEBUG,'## AT oppPerse: '+oppPerse);
            vData.perse = oppPerse.size();
        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR,'## WGC_HomePageNew_Portafoglio_Controller|getData error - exception at line: '+e.getLineNumber()+' message: '+e.getMessage());
        }

        return vData;
    }

    public class WrapperData {
        @AuraEnabled
        public List<Opportunity> faseList;
        @AuraEnabled
        public List<Opportunity> ferme;
        @AuraEnabled
        public Integer perse = 0;
        @AuraEnabled 
        public Integer vinte = 0;
        @AuraEnabled
        public Date data30g;
    }
}