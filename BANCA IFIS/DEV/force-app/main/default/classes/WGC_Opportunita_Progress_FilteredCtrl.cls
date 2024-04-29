public without sharing class WGC_Opportunita_Progress_FilteredCtrl {

    @AuraEnabled(cacheable=true)
    public static List<Map<String,Object>> getFilialeUtentiOptions(){

        // Schema.DescribeFieldResult F = User.Filiale__c.getDescribe();
        // List<Schema.PicklistEntry> P = F.getPicklistValues();

        List<Map<String,Object>> filiali = new List<Map<String,Object>>();

        User currentUser = [SELECT Id, WGC_La_mia_Filiale__c FROM User WHERE Id =: UserInfo.getUserId() ];
        User currentUserLabel = [SELECT Id, toLabel(WGC_La_mia_Filiale__c) FROM User WHERE Id =: UserInfo.getUserId() ];

        List<String> filiale1 = currentUser.WGC_La_mia_Filiale__c.split(';');
        List<String> filiale2 = currentUserLabel.WGC_La_mia_Filiale__c.split(';');

        for(Integer i = 0; i < filiale1.size(); i ++){
            filiali.add(
                new Map<String,String>{
                    'value' => filiale1[i],
                    'label' => filiale2[i]
                }
            );
        }

        // for(Schema.PicklistEntry pe : P){
        //     filiali.add(
        //         new Map<String,Object>{
        //             'label' => pe.getLabel(),
        //             'value' => pe.getValue()
        //         }
        //     );
        // }


        
        return filiali;
    }

    @AuraEnabled(cacheable=true)
    public static List<Map<String,Object>> getCommercialeOptions(String filiale){
        List<Map<String,Object>> commercialeOptions = new List<Map<String,Object>>();

        if(String.isBlank(filiale))
            return commercialeOptions;
            
        Map<Id,User> users = new Map<Id,User>([SELECT Id, Name FROM User WHERE Filiale__c =: filiale]);

        for(User u : users.values()){
            commercialeOptions.add(
                new Map<String,Object>{
                    'label' => u.Name,
                    'value' => u.Id
                }
            );
        }

        return commercialeOptions;
    }

    @AuraEnabled(cacheable=true)
    public static WrapperResponse getOpportunityCountByStatusFiltered(String filiale, String commerciale){

        WrapperResponse response = new WrapperResponse();

        try{

            System.debug('@@@ params ' + filiale + ' - ' + commerciale);

            //Conteggio di tutte le opportunità
            if(String.isBlank(filiale))
                response.data = countMyOpportunity();
                
            //Conteggio per filiale
            if(String.isNotBlank(filiale) && String.isBlank(commerciale))
                response.data = countOpportunityPerFiliale(filiale);

            //Conteggio per commerciale
            if(String.isNotBlank(filiale) && String.isNotBlank(commerciale))
                response.data = countOpportunityPerCommerciale(commerciale);

        } catch (Exception e){
            response.message = e.getMessage() + ' - ' + e.getLineNumber();
            response.success = false;
        }

        return response;
    }

    static Counter countMyOpportunity(){

        List<Opportunity> allOpty = [SELECT Id, StageName, CloseDate FROM Opportunity WHERE OwnerId =: UserInfo.getUserId()];

        List<Opportunity> allOptyCrossSelling = [SELECT Id, StageName, CloseDate, WGC_Segnalatore_CrossSelling__c FROM Opportunity WHERE WGC_Opportunit_Personale__c = false AND CreatedById =: UserInfo.getUserId()];

        Counter counter = countOpty(allOpty);
        counter.countCrossSelling = allOptyCrossSelling.size();

        Integer optyCurrentYear = [SELECT Count() FROM Opportunity WHERE OwnerId =: UserInfo.getUserId() AND StageName = 'Vinta' AND CloseDate = THIS_YEAR];
        counter.countTotalYear = optyCurrentYear;

        Integer optyClosedYear = [SELECT Count() FROM Opportunity WHERE OwnerId =: UserInfo.getUserId() AND isClosed = TRUE AND CloseDate = THIS_YEAR];
        counter.countClosedTotalYear = optyClosedYear;

        return counter;
    }

    static Counter countOpportunityPerFiliale(String filiale){

        List<Opportunity> allOpty = [SELECT Id, StageName, CloseDate FROM Opportunity WHERE Owner.Filiale__c =: filiale];

        List<Opportunity> allOptyCrossSelling = [SELECT Id, StageName, CloseDate, WGC_Segnalatore_CrossSelling__c FROM Opportunity WHERE WGC_Opportunit_Personale__c = false AND CreatedBy.Filiale__c =: filiale];

        Counter counter = countOpty(allOpty);
        counter.countCrossSelling = allOptyCrossSelling.size();

        Integer optyCurrentYear = [SELECT Count() FROM Opportunity WHERE Owner.Filiale__c =: filiale AND StageName = 'Vinta' AND CloseDate = THIS_YEAR];
        counter.countTotalYear = optyCurrentYear;

        Integer optyClosedYear = [SELECT Count() FROM Opportunity WHERE Owner.Filiale__c =: filiale AND isClosed = TRUE AND CloseDate = THIS_YEAR];
        counter.countClosedTotalYear = optyClosedYear;

        return counter;
    }

    static Counter countOpportunityPerCommerciale(String commercialeId){

        List<Opportunity> allOpty = [SELECT Id, StageName, CloseDate FROM Opportunity WHERE OwnerId =: commercialeId];

        List<Opportunity> allOptyCrossSelling = [SELECT Id, StageName, CloseDate, WGC_Segnalatore_CrossSelling__c FROM Opportunity WHERE WGC_Opportunit_Personale__c = false AND CreatedById =: commercialeId];

        Counter counter = countOpty(allOpty);
        counter.countCrossSelling = allOptyCrossSelling.size();

        Integer optyCurrentYear = [SELECT Count() FROM Opportunity WHERE OwnerId =: commercialeId AND StageName = 'Vinta' AND CloseDate = THIS_YEAR];
        counter.countTotalYear = optyCurrentYear;

        Integer optyClosedYear = [SELECT Count() FROM Opportunity WHERE OwnerId =: commercialeId AND isClosed = TRUE AND CloseDate = THIS_YEAR];
        counter.countClosedTotalYear = optyClosedYear;

        System.debug('@@@ counter ' + counter);
        return counter;
    }

    @TestVisible
    private static Counter countOpty(List<Opportunity> listaOpty){
        
        System.debug('@@@ listaOpty ' + listaOpty);
        Counter counter = new Counter();

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
        @AuraEnabled public Counter data;
        @AuraEnabled public String message;
        @AuraEnabled public Boolean success;

        public WrapperResponse(){
            this.data = null;
            this.message = '';
            this.success = true;
        }
    }

    public class Counter{
        @AuraEnabled
        public Integer countIstruttoria;
        @AuraEnabled
        public Boolean expiredIstruttoriaOpty;
        @AuraEnabled
        public Integer countValutazionePratica;
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

        public Counter(){
            this.countIstruttoria = 0;
            this.countValutazionePratica = 0;
            this.countPerfContratto = 0;
            this.countAttRapporto = 0;
            this.countCrossSelling = 0;
            this.countTotalYear = 0;
            this.expiredIstruttoriaOpty = false;
        }
    }

}