/**
* @author Francesco Palumbo (francesco.palumbo@sideagroup.com)
* @date 15 Jan 2020
* @group controller
* @description controller for WGC_Opportunita_CE_Progress lightning component
**/

public with sharing class WGC_Opportunita_CE_Progress_Controller {

    //CONSTANTS
    public static final String RT_OPPORTUNITY_CE = 'WGC_IFIS_Oppotunita_Crediti_Erariali';
    public static final String RT_OPPORTUNITY_FF = 'IFISOpportunitaFastFinance';
    public static final String CLOSED_WON_STATUS = 'Vinta';
    public enum Opportunity_CE {INBONIS, PROCEDURALI}

    @AuraEnabled
    public static OpportunityCounter getOpportunityInBonis(){
        return getOpportunity(Opportunity_CE.INBONIS);
    }

    @AuraEnabled
    public static OpportunityCounter getOpportunityProcedurali(){
        return getOpportunity(Opportunity_CE.PROCEDURALI);
    }

    @AuraEnabled
    public static String getDashboard(){
        String profileFastFinance = 'IFIS - B/O Valutazione Fast Finance';
        String profileCreditiErariali = 'IFIS - Crediti Erariali';
        Profile userProfile = [SELECT Name FROM Profile WHERE Id = :UserInfo.getProfileId()];
        Dashboard_FF__c dashboard = Dashboard_FF__c.getValues('default');
        if (userProfile.Name.equals(profileFastFinance)){
            return dashboard.IdCommerciali__c;
        }else if (userProfile.Name.equals(profileCreditiErariali)) {
            return dashboard.IdResponsabili__c;
        }

        return dashboard.IdResponsabili__c;
    }

    private static OpportunityCounter getOpportunity(Opportunity_CE oppType){

        OpportunityCounter oppCount = new OpportunityCounter();
        List<AggregateResult> allOpp = new List<AggregateResult>();
        List<Opportunity> allOppCrossSelling = new List<Opportunity>();


        Id idCurrentUser = UserInfo.getUserId();
        Id idCurrentUserProfile = UserInfo.getProfileId();
        Profile currentUserProfile = [SELECT Name from Profile where Id = :idCurrentUserProfile];
        String profileNameToCompare = 'IFIS - B/O Valutazione Fast Finance';
        String queryAllOpp;
        Id recordTypeCE = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get(RT_OPPORTUNITY_CE).getRecordTypeId();
        Id recordTypeFF = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get(RT_OPPORTUNITY_FF).getRecordTypeId();

        String profileQueryCond = currentUserProfile.Name.equals(profileNameToCompare) ? '' : ' AND OwnerId = \'' + idCurrentUser + '\' ';

        switch on oppType {
            when INBONIS {
                // allOpp = [SELECT COUNT(Id) Counter,StageName FROM Opportunity WHERE OwnerId =: UserInfo.getUserId() AND RecordTypeId =: recordTypeCE GROUP BY StageName];  @@ Query b4 modifica "profilo di B/O Fast Finance see all"
                // allOppCrossSelling = [SELECT Id, StageName, CloseDate, WGC_Segnalatore_CrossSelling__c FROM Opportunity WHERE WGC_Opportunit_Personale__c = FALSE AND Created_by_me__c = TRUE AND OwnerId !=: UserInfo.getUserId()];  @@ Query b4 modifica "profilo di B/O Fast Finance see all"

                queryAllOpp = 'SELECT COUNT(Id) Counter, StageName FROM Opportunity WHERE RecordTypeId = \'' + recordTypeCE + '\' ' + profileQueryCond + ' GROUP BY StageName';
                String profileCreatedByMe = currentUserProfile.Name.equals(profileNameToCompare) ? '' : 'AND Created_by_me__c = TRUE ';
                String profilefilter = currentUserProfile.Name.equals(profileNameToCompare) ? 'AND RecordTypeId NOT IN ( \'' + recordTypeCE + '\',  \'' + recordTypeFF + '\' ) AND CreatedBy.Qualifica_Utente__c = \'Crediti Erariali\' ' : 'AND RecordTypeId NOT IN ( \'' + recordTypeCE + '\',  \'' + recordTypeFF + '\' ) AND CreatedBy.Qualifica_Utente__c = \'Crediti Erariali\'';
                String queryallOppCrossSelling = 'SELECT Id, StageName, CloseDate, WGC_Segnalatore_CrossSelling__c FROM Opportunity WHERE WGC_Opportunit_Personale__c = FALSE ' + profileCreatedByMe + profilefilter ;

                allOppCrossSelling = Database.query(queryallOppCrossSelling);
            }
            when PROCEDURALI {
                //allOpp = [SELECT count(Id) Counter, StageName FROM Opportunity WHERE OwnerId =: UserInfo.getUserId() AND RecordTypeId =: recordTypeFF GROUP BY StageName] ;  @@ Query b4 modifica "profilo di B/O Fast Finance see all"
                queryAllOpp = 'SELECT count(Id) Counter, StageName FROM Opportunity WHERE RecordTypeId = \'' + recordTypeFF + '\' ' + profileQueryCond + ' GROUP BY StageName' ;
            }
        }

        allOpp = Database.query(queryAllOpp);

        oppCount = handleOpportunity(allOpp);
        oppCount.countCrossSelling = allOppCrossSelling.size();


        // Integer optyCurrentYear = [SELECT COUNT() FROM Opportunity WHERE OwnerId =: UserInfo.getUserId() AND StageName =: CLOSED_WON_STATUS AND CloseDate = THIS_YEAR]; @@ Query b4 modifica "profilo di B/O Fast Finance see all"
        String queryOptyCurrentYear = 'SELECT COUNT() FROM Opportunity WHERE StageName = \'' + CLOSED_WON_STATUS + '\' AND CloseDate = THIS_YEAR AND RecordTypeId IN ( \'' + recordTypeCE + '\',  \'' + recordTypeFF + '\' )';
        Integer optyCurrentYear = Database.countQuery(queryOptyCurrentYear);
        oppCount.countAvviate = optyCurrentYear;

        // Integer optyClosedYear = [SELECT COUNT() FROM Opportunity WHERE OwnerId =: UserInfo.getUserId() AND isClosed = TRUE AND CloseDate = THIS_YEAR]; @@ Query b4 modifica "profilo di B/O Fast Finance see all"
        String queryOptyClosedYear = 'SELECT COUNT() FROM Opportunity WHERE isClosed = TRUE AND CloseDate = THIS_YEAR AND RecordTypeId IN ( \'' + recordTypeCE + '\',  \'' + recordTypeFF + '\' )';
        Integer optyClosedYear = Database.countQuery(queryOptyClosedYear);
        oppCount.countChiuse = optyClosedYear;

        System.debug('Counter Object: '+oppCount);
        return oppCount;
    }

    private static OpportunityCounter handleOpportunity(List<AggregateResult> allOpp){
        OpportunityCounter counter = new OpportunityCounter();
        for(AggregateResult opp : allOpp){
            switch on String.valueOf(opp.get('StageName')) {
                when 'In Istruttoria' {
                    counter.countIstruttoria = Integer.valueOf(opp.get('Counter'));
                }
                when 'In Lavorazione' {
                    counter.countLavorazione = Integer.valueOf(opp.get('Counter'));
                }
                when 'Valutazione Pratica' {
                    counter.countValutazionePratica = Integer.valueOf(opp.get('Counter'));
                }
                //SM - TEN - CR401 Eliminazione stato Predisposizione Contratto
                // when 'Predisposizione Contratto' {
                //     counter.countPredContratto = Integer.valueOf(opp.get('Counter'));
                // }
                when 'Perfezionamento Contratto' {
                    counter.countPerfContratto = Integer.valueOf(opp.get('Counter'));
                }
                when 'Attivazione' {
                    counter.countAttRapporto = Integer.valueOf(opp.get('Counter'));
                }
            }
        }

        return counter;
    }

    // WRAPPER CLASS
    public class OpportunityCounter{
        @AuraEnabled
        public Integer countIstruttoria;

        @AuraEnabled
        public Integer countLavorazione;

        @AuraEnabled
        public Integer countValutazionePratica;

        // @AuraEnabled
        // public Integer countPredContratto;

        @AuraEnabled
        public Integer countPerfContratto;

        @AuraEnabled
        public Integer countAttRapporto;

        @AuraEnabled
        public Integer countAvviate;

        @AuraEnabled
        public Integer countChiuse;

        @AuraEnabled
        public Integer countCrossSelling;

        public OpportunityCounter(){
            this.countIstruttoria = 0;
            this.countValutazionePratica = 0;
            // this.countPredContratto = 0;
            this.countPerfContratto = 0;
            this.countAttRapporto = 0;
            this.countChiuse = 0;
            this.countCrossSelling = 0;
        }
    }
}