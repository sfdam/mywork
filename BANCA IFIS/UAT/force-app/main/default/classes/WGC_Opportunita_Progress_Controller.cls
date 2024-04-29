public class WGC_Opportunita_Progress_Controller {

    @AuraEnabled
    public static WrapperResponse getOpportunityCountByStatus(){
        
        WrapperResponse wrap = new WrapperResponse();

        String userId = UserInfo.getUserId();

        List<Opportunity> allOpty = [SELECT Id, StageName, CloseDate FROM Opportunity WHERE OwnerId =: userId];

        List<Opportunity> allOptyCrossSelling = [SELECT Id, StageName, CloseDate, WGC_Segnalatore_CrossSelling__c FROM Opportunity WHERE WGC_Opportunit_Personale__c = false and Created_by_me__c = true];

        WrapperCounter counter = countOpty(allOpty);
        counter.countCrossSelling = allOptyCrossSelling.size();

        Integer optyCurrentYear = [SELECT Count() FROM Opportunity WHERE OwnerId =: userId AND StageName = 'Vinta' AND CloseDate = THIS_YEAR];
        counter.countTotalYear = optyCurrentYear;

        Integer optyClosedYear = [SELECT Count() FROM Opportunity WHERE OwnerId =: userId AND isClosed = TRUE AND CloseDate = THIS_YEAR];
        counter.countClosedTotalYear = optyClosedYear;

        wrap.data.add(counter);

        return wrap;
    }

    @TestVisible
    private static WrapperCounter countOpty(List<Opportunity> listaOpty){
        
        WrapperCounter counter = new WrapperCounter();

        for(Opportunity item : ListaOpty){
            switch on item.StageName{
                when ('In Istruttoria') {
                    counter.countIstruttoria ++;
                    if( item.CloseDate > System.Today() ){
                        counter.expiredIstruttoriaOpty = true;
                    }
                }
                when ('Valutazione Pratica'){
                    counter.countValutazionePratica++;
                }
                // when('Predisposizione Contratto'){
                //     counter.countRedazioniContratto++;
                // }
                when('Perfezionamento Contratto'){
                    counter.countPerfContratto++;
                }
                when('Attivazione'){
                    counter.countAttRapporto++;
                }
            }

        }

        return counter;
    }

    public class WrapperResponse{
        @AuraEnabled
        public List<Object> data;
        @AuraEnabled
        public String message;
        @AuraEnabled
        public Boolean success;

        public WrapperResponse(){
            this.data = new List<Object>();
            this.message = message;
            this.success = true;
        }
    }

    public class WrapperCounter{
        @AuraEnabled
        public Integer countIstruttoria;
        @AuraEnabled
        public Boolean expiredIstruttoriaOpty;
        @AuraEnabled
        public Integer countValutazionePratica;
        // @AuraEnabled
        // public Integer countRedazioniContratto;
        @AuraEnabled
        public Integer countPerfContratto;
        @AuraEnabled
        public Integer countAttRapporto;
        @AuraEnabled
        public Integer countCrossSelling;
        @AuraEnabled
        public Integer countTotalYear;
        @AuraEnabled
        public Integer countClosedTotalYear;

        public WrapperCounter(){
            this.countIstruttoria = 0;
            this.countValutazionePratica = 0;
            // this.countRedazioniContratto = 0;
            this.countPerfContratto = 0;
            this.countAttRapporto = 0;
            this.countCrossSelling = 0;
            this.countTotalYear = 0;
            this.expiredIstruttoriaOpty = false;
        }
    }
}