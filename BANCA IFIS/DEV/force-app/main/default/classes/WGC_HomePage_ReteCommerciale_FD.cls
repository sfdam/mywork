public class WGC_HomePage_ReteCommerciale_FD {
    
    @AuraEnabled
    public static WrapperResponse getBestAndBadFiliale(){
        WrapperResponse response = new WrapperResponse();

        try{
            Set<Filiale> filialiSet = new Set<Filiale>();
            List<User> utentiF = new List<User>();
            List<WGC_Dettaglio_Visite__c> dtList = new List<WGC_Dettaglio_Visite__c>();
            Map<String, List<Sobject>> dtXFiliale = new Map<String,List<Sobject>>();

            // utentiF = [SELECT Id, Name, toLabel(Filiale__c) FROM User WHERE Filiale__c != null AND Qualifica_Utente__c = 'Sviluppo_Commerciale_Filiali' ORDER BY Filiale__c];
            // uXFiliale = U.groupBy(utentiF, 'Filiale__c');

            // System.debug('@@@ mappa ' + JSON.serialize(uXFiliale));

            dtList = [SELECT Id, Name, Settorista__c, Filiale__c, Data_Visita_Commerciale__c, Esito_Visita_Livello1__c, Pratica_Presentata__c, Esito_Pratica__c, Rapporto_Avviato__c, toLabel(Ragione_Sociale__r.Filiale__c), toLabel(Filiale_Settorista__c) FROM WGC_Dettaglio_Visite__c WHERE Filiale_Settorista__c != null AND toLabel(Filiale_Settorista__c) != 'TIANTICIPO' AND Data_Visita_Commerciale__c != null AND Data_Visita_Commerciale__c = THIS_YEAR AND RecordType.DeveloperName='Dettaglio_Visita' ];

            dtXFiliale = U.groupBy(dtList, 'Filiale_Settorista__c');

            System.debug('@@@ mappa ' + JSON.serialize(dtXFiliale));

            for(String key : dtXFiliale.keySet()){
                Decimal countVC = 0;
                Decimal praticheAvviate = 0;

                for(Sobject sobj : dtXFiliale.get(key)){
                    if(sobj.get('Data_Visita_Commerciale__c') != null) countVC ++;

                    if(sobj.get('Rapporto_Avviato__c') != null && sobj.get('Rapporto_Avviato__c') == 'SI') praticheAvviate ++;
                }

                Filiale f;

                if(countVC > 0) {
                    f = new Filiale(key, ((praticheAvviate / countVC) * 100).setScale(2), true);
                } else {
                    f = new Filiale(key, 0, true);
                }

                filialiSet.add(f);
            }

            List<Filiale> filiali = new List<Filiale>(filialiSet);

            system.debug('@@@ Filiali ' + JSON.serialize(filiali));

            filiali.sort();

            system.debug('@@@ Filiali after sort ' + JSON.serialize(filiali));

            //Setto la migliore e la peggiore dopo l'ordinamento
            filiali[0].best = true;
            filiali[filiali.size() - 1].best = false;
            Container c = new Container(filiali[0], filiali[filiali.size()-1]);


            response.data.add(c);

        } catch(exception e){
            response.message = e.getMessage();
            response.success = false;
        }   

        return response;  
    }

    public class WrapperResponse{
        @AuraEnabled public List<Object> data;
        @AuraEnabled public String message;
        @AuraEnabled public Boolean success;

        public WrapperResponse(){
            this.data = new List<Object>();
            this.message = '';
            this.success = true;
        }
    }

    public class Container{
        @AuraEnabled public Filiale best;
        @AuraEnabled public Filiale bad;

        public Container(Filiale best, Filiale bad){
            this.best = best;
            this.bad = bad;
        }
    }

    public class Filiale implements Comparable{
        @AuraEnabled public String nomeFiliale;
        @AuraEnabled public Decimal conversion;
        @AuraEnabled public Boolean best;

        public Filiale(String nome, Decimal conversion, Boolean best){
            this.nomeFiliale = nome;
            this.conversion = conversion;
            this.best = best;
        }

        public Integer compareTo(Object compareTo) {
            Filiale compareToFil = (Filiale)compareTo;
            if (conversion == compareToFil.conversion) return 0;
            if (conversion > compareToFil.conversion) return -1;
            return 1;
        }
    }
}