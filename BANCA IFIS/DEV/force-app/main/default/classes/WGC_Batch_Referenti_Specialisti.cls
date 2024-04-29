global class WGC_Batch_Referenti_Specialisti implements Database.Batchable<sObject> {
    String query;
    Boolean isChangedFactoring = false;
    Boolean isChangedLeasing = false;
    Boolean isChangedLending = false;
    Boolean isChangedCreditiErariali = false;
    Boolean isChangedFarmacie = false;
    Boolean isChangedFD = false;
    Boolean isChangedFS = false;
    Boolean isChangedFinance = false;

    List<WrapperAssegnazione> listaWA = new List<WrapperAssegnazione>();
    List<Account> lstToUpdate = new List<Account>();

    public class WrapperAssegnazione{
        public Account anagrafica {get;set;}
        public Boolean isChangedFactoring {get;set;}
        public Boolean isChangedLeasing {get;set;}
        public Boolean isChangedLending {get;set;}
        public Boolean isChangedCreditiErariali {get;set;}
        public Boolean isChangedFarmacie {get;set;}
        public Boolean isChangedFD {get;set;}
        public Boolean isChangedFS {get;set;}
        public Boolean isChangedFinance {get;set;}

        public WrapperAssegnazione(){
            this.isChangedFactoring = false;
            this.isChangedLeasing = false;
            this.isChangedLending = false;
            this.isChangedCreditiErariali = false;
            this.isChangedFarmacie = false;
            this.isChangedFD = false;
            this.isChangedFS = false;
            this.isChangedFinance = false;
        }
    }

    global WGC_Batch_Referenti_Specialisti(){
        //costruisco la query per recuperare tutti gli account da processare
        query = 'SELECT Id, Name, WGC_Qualifica_Corporate__c, WGC_Factoring_Attivo__c,'+
        //'WGC_Leasing_Attivo__c, '+
        'WGC_Filo_Diretto_Attivo__c, '+
        //WGC_Crediti_Erariali_Attivo__c, 
        //'WGC_IFIS_Finance_Attivo__c, '+
        //WGC_Finanza_Strutturata_Attivo__c,
        'WGC_Giorni_Inattivita_Filo_Diretto__c, WGC_Giorni_Inattivita_SvilCommFiliali__c, '+
        'WGC_Giorni_Ex_cliente_SvilCommFiliali__c, '+
            'Specialista_assegnato_FD__c,'+
        'WGC_Giorni_Ex_cliente_Filo_Diretto__c, '+
        'ShippingPostalCode, ShippingCity, ShippingState, '+
        'BillingPostalCode, BillingCity, BillingState, OwnerId, WGC_Specialista_Leasing__c, '+
        'WGC_Specialista_Factoring__c, WGC_Specialista_Filo_Diretto__c, WGC_Specialista_Crediti_Erariali__c, WGC_Specialista_Finanza_Strutturata__c, '+
        'WGC_Specialista_IFIS_Finance__c, WGC_Specialista_IFIS_International__c, WGC_Specialista_Leasing_TR__c, Presentatore__c FROM Account ' +
        'WHERE ' +
        '(Specialista_assegnato_FD__c=null AND WGC_Giorni_Inattivita_Filo_Diretto__c >= 180) OR (Specialista_assegnato_FD__c=null AND WGC_Giorni_Inattivita_SvilCommFiliali__c >= 180)';

        /*
        */
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Account> scope){
        //inserire logica per modificare i referenti e specialisti di un account
        System.debug('@@@ scope size ' + scope.size());
        //Flag per verificare se viene spento il flag referente commerciale
        List<WrapperAssegnazione> listaWA = new List<WrapperAssegnazione>();
        List<Account> lstAccPresentatore = new List<Account>();
        for(Account sobj : scope){
            WrapperAssegnazione wa = new WrapperAssegnazione();
            //NEW VERSION
            //Controllo che lo specialista filo diretto non abbia eseguito attività da più di 180 giorni
            //Inoltre controllo che la qualifica corporate sia "PROSPECT" e controllo che non ci siano altri specialisti attivi
            //Primo requisito documento (Per Filo Diretto)
            if(sobj.WGC_Giorni_Inattivita_Filo_Diretto__c >= 180 && sobj.WGC_Qualifica_Corporate__c == 'Prospect' 
                && sobj.WGC_Factoring_Attivo__c == false){
                    System.debug('@@@ disattivo il referente filo diretto secondo il primo requisito');
                    sobj.WGC_Filo_Diretto_Attivo__c = false;
                    wa.isChangedFD = true;
                    wa.anagrafica = sobj;
            }
            //Controllo che lo specialista Factoring(Sviluppo Commerciale) non abbia eseguito attività da più di 180 giorni
            //Inoltre controllo che la qualifica corporate sia "PROSPECT" e controllo che non ci siano altri specialisti attivi
            //Primo requisito documento (Per factoring o Sviluppo Commerciale)
            if(sobj.WGC_Giorni_Inattivita_SvilCommFiliali__c >= 180 && sobj.WGC_Qualifica_Corporate__c == 'Prospect' 
                && sobj.WGC_Filo_Diretto_Attivo__c == false){
                    System.debug('@@@ disattivo il referente factoring secondo il primo requisito');
                    sobj.WGC_Factoring_Attivo__c = false;
                    wa.isChangedFactoring = true;
                    wa.anagrafica = sobj;
            }
            //SECONDO REQUISITO
            //Controllo che lo specialista filo diretto non abbia eseguito attività da più di 180 giorni
            //Inoltre controllo che la qualifica prodotto sia "Ex cliente" da più di 24 mesi 
            //e controllo che non ci siano altri specialisti attivi
            //Secondo requisito documento (Per Filo Diretto)
            if(sobj.WGC_Giorni_Inattivita_Filo_Diretto__c >= 180 && sobj.WGC_Giorni_Ex_cliente_Filo_Diretto__c >= 730 
                && sobj.WGC_Factoring_Attivo__c == false){
                    System.debug('@@@ disattivo il referente filo diretto in base al secondo requisito');
                    sobj.WGC_Filo_Diretto_Attivo__c = false;
                    wa.isChangedFD = true;
                    wa.anagrafica = sobj;
            }
            //Controllo che lo specialista Factoring (Sviluppo Commerciale) non abbia eseguito attività da più di 180 giorni
            //Inoltre controllo che la qualifica prodotto sia "Ex cliente" da più di 24 mesi 
            //e controllo che non ci siano altri specialisti attivi
            //Secondo requisito documento (Per Factoring o Sviluppo Commerciale)
            if(sobj.WGC_Giorni_Inattivita_SvilCommFiliali__c >= 180 && sobj.WGC_Giorni_Ex_cliente_SvilCommFiliali__c >= 730 
                && sobj.WGC_Filo_Diretto_Attivo__c == false){
                    System.debug('@@@ disattivo il referente Factoring in base al secondo requisito');
                    sobj.WGC_Factoring_Attivo__c = false;
                    wa.isChangedFactoring = true;
                    wa.anagrafica = sobj;
            }
            /* OLD VERSION 
            //Verifico che gli account selezionati siano prospect e che ci sia inattività per specialista filo diretto da più di 180 giorni
            if(sobj.WGC_Qualifica_Corporate__c == 'Prospect'){
                if(sobj.WGC_Giorni_Inattivita_Filo_Diretto__c >= 180){
                    sobj.WGC_Filo_Diretto_Attivo__c = false;
                    wa.isChangedFD = true;
                }
            }
            //Verifico che i prodotti siano classificati come ex cliente e che ci sia inattività per specialista filo diretto da più di 180 giorni
            if(sobj.WGC_Giorni_Ex_cliente_Filo_Diretto__c >= 730 && sobj.WGC_Giorni_Inattivita_Filo_Diretto__c >= 180){
                sobj.WGC_Filo_Diretto_Attivo__c = false;
                wa.isChangedFD = true;
            }
            //Verifico che tutti i referenti siano disattivi e disattivo anche il referente factoring
            //Azzero anche il presentatore factoring
            if(sobj.WGC_Leasing_Attivo__c == false
                && sobj.WGC_Crediti_Erariali_Attivo__c == false
                && sobj.WGC_Filo_Diretto_Attivo__c == false && sobj.WGC_Finanza_Strutturata_Attivo__c == false
                && sobj.WGC_IFIS_Finance_Attivo__c == false){
                    sobj.WGC_Factoring_Attivo__c = false;
                    sobj.Presentatore__c = null;
                    wa.isChangedFactoring = true;
            }
            //Se c'è stata una modifica aggiungo l'oggetto account alla lista per fare l'update
            if(wa.isChangedFactoring || wa.isChangedLeasing || wa.isChangedLending || wa.isChangedFarmacie || 
                wa.isChangedCreditiErariali || wa.isChangedFD || wa.isChangedFS || wa.isChangedFinance){
                wa.anagrafica = sobj;
                listaWA.add(wa);
            } */
            System.debug('@@@ wa ' + wa);
            //Controllo per vedere se l'anagrafica è stata presentata
            if(wa.isChangedFactoring == true && sobj.Presentatore__c != null){
                sobj.WGC_Specialista_Factoring__c = sobj.Presentatore__c;
                sobj.Presentatore__c = null;
                wa.isChangedFactoring = false;
                wa.anagrafica = sobj;
                System.debug('@@@ controllo il presentatore ' + sobj);
                lstAccPresentatore.add(sobj);
            }
            else if(wa.isChangedFactoring == true || wa.isChangedFD == true){
                listaWA.add(wa);
            }
        }
        System.debug('@@@ list WA to update ' + listaWA);
        //Se la lista non è vuota effettuo l'update
        if(!listaWA.isEmpty()){
            lstToUpdate = AssegnazioneTerritoriale(listaWA);
            update lstToUpdate;
        }
        if(!lstAccPresentatore.isEmpty()){
            System.debug('@@@ lista con presentatore su cui fare update ' + lstAccPresentatore);
            update lstAccPresentatore;
        }
    }

    global void finish(Database.BatchableContext BC){
        AsyncApexJob aaj = [SELECT Id, NumberOfErrors, Status, JobType, JobItemsProcessed, CompletedDate FROM AsyncApexJob WHERE Id =: BC.getJobId()];
        System.debug('@@@ query sul job ' + aaj);
    }

    //Metodo per ri-assegnare gli specialisti degli account modificati
    public List<Account> AssegnazioneTerritoriale(List<WrapperAssegnazione> accs){
        //lista di account per prendere la lista di cap, comuni, provincie
        List<Account> lstGetAssegnazione = new List<Account>();
        for(WrapperAssegnazione item : accs){
            lstGetAssegnazione.add(item.anagrafica);
        }
        Set<String> caps = U.getSet(lstGetAssegnazione, 'ShippingPostalCode');
        Set<String> comuni = U.getSet(lstGetAssegnazione, 'ShippingCity');
        Set<String> provincie = U.getSet(lstGetAssegnazione, 'ShippingState');
        //
        System.debug('@@@ caps ' + caps);
        System.debug('@@@ comuni ' + comuni);
        System.debug('@@@ provincie ' + provincie);
        //
        Map<String, Id> cap2owner = UtilAnagrafiche.getOwners(caps, comuni, provincie, false);
        Map<String, Id> cap2fd = UtilAnagrafiche.getOwners(caps, comuni, provincie, true);
        //
        System.debug('@@@ cap2owner ' + cap2owner);
        System.debug('@@@ cap2fd ' + cap2fd);
        //
        for(WrapperAssegnazione a : accs){
            //La riassegnazione su base territoriale deve essere fatta solo per gli specialisti di filo diretto e factoring o sviluppo commerciale
            //Che hanno perso la qualifica di referente per quell'account
            if(a.isChangedFD){
                System.debug('@@@ se referente commerciale filo diretto disattivato allora effettuo riassegnazione ' + a.isChangedFD);
                checkIndirizzi(a, 'WGC_Specialista_Filo_Diretto__c', null, cap2fd);
            }
            if(a.isChangedFactoring){
                System.debug('@@@ se referente commerciale Factoring o Sviluppo Diretto disattivato allora effettuo riassegnazione ' + a.isChangedFactoring);
                checkIndirizzi(a, 'WGC_Specialista_Factoring__c', cap2owner, null);
            }

            //OLD VERSION
            //Nella vecchia versione ogni specialista poteva essere referente, as-is solo factoring e filo diretto 
            //sono eleggibili come referenti oltre che come specialisti
            /*if(a.isChangedLeasing){
                System.debug('@@@ se referente commerciale leasing disattivato allora effettuo riassegnazione ' + a.isChangedLeasing);
                checkIndirizzi(a, 'WGC_Specialista_Leasing__c', cap2owner, cap2fd);
            }
            if(a.isChangedLending){
                System.debug('@@@ se referente commerciale leasing disattivato allora effettuo riassegnazione ' + a.isChangedLeasing);
                checkIndirizzi(a, 'WGC_Specialista_Lending__c', cap2owner, cap2fd);
            }
            if(a.isChangedFarmacie){
                System.debug('@@@ se referente commerciale leasing disattivato allora effettuo riassegnazione ' + a.isChangedLeasing);
                checkIndirizzi(a, 'WGC_Specialista_Farmacie__c', cap2owner, cap2fd);
            }

            if(a.isChangedFS){
                System.debug('@@@ se referente commerciale leasing disattivato allora effettuo riassegnazione ' + a.isChangedLeasing);
                checkIndirizzi(a, 'WGC_Specialista_Finanza_Strutturata__c', cap2owner, cap2fd);   
            }
            if(a.isChangedFinance){
                System.debug('@@@ se referente commerciale leasing disattivato allora effettuo riassegnazione ' + a.isChangedLeasing);
                checkIndirizzi(a, 'WGC_Specialista_IFIS_Finance__c', cap2owner, cap2fd);
            }
            if(a.isChangedCreditiErariali){
                System.debug('@@@ se referente commerciale leasing disattivato allora effettuo riassegnazione ' + a.isChangedLeasing);
                checkIndirizzi(a, 'WGC_Specialista_Crediti_Erariali__c', cap2owner, cap2fd);   
            }*/
            lstToUpdate.add(a.anagrafica);
        }
        return lstToUpdate;
    }

    //Metodo che verifica la corrispondenza tra indirizzo anagrafica e la lista dell'oggetto assegnazione in base
    public void checkIndirizzi(WrapperAssegnazione wa, String flagToUpdate, Map<String, Id> cap2owner, Map<String, Id> cap2fd){
        //prova
        System.debug('@@@ flag to update ' + flagToUpdate);
        System.debug('@@@ prova get field' + wa.anagrafica.get(flagToUpdate));
        //
        Map<String, Id> cap2Map = (cap2owner == null)? cap2fd : cap2owner;

        if(String.isNotBlank(wa.anagrafica.BillingPostalCode) && cap2Map.containsKey(wa.anagrafica.BillingPostalCode)){
            wa.anagrafica.put(flagToUpdate, cap2Map.get(wa.anagrafica.BillingPostalCode));
        } 
        else if(String.isNotBlank(wa.anagrafica.ShippingPostalCode) && cap2Map.containsKey(wa.anagrafica.ShippingPostalCode)){
            wa.anagrafica.put(flagToUpdate, cap2Map.get(wa.anagrafica.ShippingPostalCode));
        }
        else if(String.isNotBlank(wa.anagrafica.BillingCity) && cap2Map.containsKey(wa.anagrafica.BillingCity)){
            wa.anagrafica.put(flagToUpdate, cap2Map.get(wa.anagrafica.BillingCity));
        } 
        else if(String.isNotBlank(wa.anagrafica.ShippingCity) && cap2Map.containsKey(wa.anagrafica.ShippingCity)){
            wa.anagrafica.put(flagToUpdate, cap2Map.get(wa.anagrafica.ShippingCity));
        } 
        else if(String.isNotBlank(wa.anagrafica.BillingState) && cap2Map.containsKey(wa.anagrafica.BillingState)){
            wa.anagrafica.put(flagToUpdate, cap2Map.get(wa.anagrafica.BillingState));
        } 
        else if(String.isNotBlank(wa.anagrafica.ShippingState) && cap2Map.containsKey(wa.anagrafica.ShippingState)){
            wa.anagrafica.put(flagToUpdate, cap2Map.get(wa.anagrafica.ShippingState));
        }
        else{
            System.debug('@@@ billing address ' + wa.anagrafica.BillingPostalCode + wa.anagrafica.BillingCity + wa.anagrafica.BillingState);
            System.debug('@@@ shipping address ' + wa.anagrafica.ShippingPostalCode + wa.anagrafica.ShippingCity + wa.anagrafica.ShippingState);
        }
        System.debug('@@@ wa.anagrafica ' + wa.anagrafica);
    }
}