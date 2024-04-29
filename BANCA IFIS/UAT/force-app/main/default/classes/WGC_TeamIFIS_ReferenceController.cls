public class WGC_TeamIFIS_ReferenceController {
    
    @AuraEnabled
    public static User getAddressInfo(String accountId){
        System.debug('@@@ accountId ' + accountId);
        Account a = new Account();
        a = [SELECT Id, Name, BillingAddress, WGC_Specialista_Factoring__c FROM Account WHERE Id =: accountId];

        if(a != null && a.WGC_Specialista_Factoring__c != null){
            List<User> ulist = new List<User>();
            User u = new User();
            uList = [SELECT Id, FirstName, LastName, Address FROM User WHERE Id=:a.WGC_Specialista_Factoring__c];
            if(!uList.isEmpty()){
                u = uList.get(0);
                return u;
            }
            else{
                return null;
            }
        }
        else{
            return null;
        }
    }

    @AuraEnabled
    public static List<WrapperResponse> getUserReferenceFromAccount(id accId){
        //System.debug('SV accId: ' + accId);
        
        Account acc = [SELECT CodiceIstituto3n__c, NDGGruppo__c,
                              WGC_Specialista_Crediti_Erariali__c, WGC_Crediti_Erariali_Attivo__c,
                              WGC_Specialista_Factoring__c, WGC_Factoring_Attivo__c,
                              WGC_Specialista_IFIS_International__c,
                              WGC_Specialista_Filo_Diretto__c, WGC_Filo_Diretto_Attivo__c,
                              WGC_Specialista_Finanza_Strutturata__c,
                              WGC_Specialista_IFIS_Finance__c,
                              WGC_Specialista_Leasing__c, WGC_Specialista_Leasing_TR__c,
                              WGC_Gestore_Cliente__c, WGC_Gestore_Debitore__c,
                              WGC_Specialista_Pharma__c,
                              Presentatore__c
                       FROM Account
                       WHERE Id =: accId];

        System.debug('@@@ acc ' + acc);

        List<Account> accountLegalEntity = new List<Account>();
        Map<String, String> specialisti = new Map<String, String>();

        accountLegalEntity = WGC_LegalEntity_Utility.getLinkLegalEntity(acc.NDGGruppo__c, acc.CodiceIstituto3n__c);

        System.debug('@@@ accountLegalEntity ' + accountLegalEntity);

        if(acc.CodiceIstituto3n__c == '881'){
            System.debug('@@@ codice 881');
            specialisti.put(Label.WGC_Team_IFIS_Specialista_Crediti_Erariali,acc.WGC_Specialista_Crediti_Erariali__c);
            specialisti.put(Label.WGC_Team_IFIS_Specialista_Factoring,acc.WGC_Specialista_Factoring__c);
            specialisti.put(Label.WGC_Team_IFIS_Specialista_International,acc.WGC_Specialista_IFIS_International__c);
            specialisti.put(Label.WGC_Team_IFIS_Specialista_Filo_Diretto,acc.WGC_Specialista_Filo_Diretto__c);
            specialisti.put(Label.WGC_Team_IFIS_Specialista_Finanza_Strutturata,acc.WGC_Specialista_Finanza_Strutturata__c);
            specialisti.put(Label.WGC_Team_IFIS_Specialista_Leasing_EF,acc.WGC_Specialista_Leasing__c);
            specialisti.put(Label.WGC_Team_IFIS_Specialista_Leasing_TR,acc.WGC_Specialista_Leasing_TR__c);
            specialisti.put(Label.WGC_Team_IFIS_Presentatore, acc.Presentatore__c);
            specialisti.put(Label.WGC_Team_IFIS_Specialista_Pharma, acc.WGC_Specialista_Pharma__c);
            specialisti.put(Label.WGC_Team_IFIS_Gestore_Cliente, acc.WGC_Gestore_Cliente__c);
            specialisti.put(Label.WGC_Team_IFIS_Gestore_Debitore, acc.WGC_Gestore_Debitore__c);
            //se l'anagrafica è 881 utilizzo l'889 per settare lo specialista finance
            if(accountLegalEntity != null){
                for(Account a : accountLegalEntity){
                    if(a.CodiceIstituto3n__c == '889'){
                        specialisti.put(Label.WGC_Team_IFIS_Specialista_IFIS_Finance,a.WGC_Specialista_IFIS_Finance__c);
                    }
                }
            }
        }
        else{
            if(accountLegalEntity != null){
                System.debug('@@@ codice 889 con link legal entity');
                for(Account a : accountLegalEntity){
                    if(a.CodiceIstituto3n__c == '881'){
                        specialisti.put(Label.WGC_Team_IFIS_Specialista_Crediti_Erariali,a.WGC_Specialista_Crediti_Erariali__c);
                        specialisti.put(Label.WGC_Team_IFIS_Specialista_Factoring,a.WGC_Specialista_Factoring__c);
                        specialisti.put(Label.WGC_Team_IFIS_Specialista_International,a.WGC_Specialista_IFIS_International__c);
                        specialisti.put(Label.WGC_Team_IFIS_Specialista_Filo_Diretto,a.WGC_Specialista_Filo_Diretto__c);
                        specialisti.put(Label.WGC_Team_IFIS_Specialista_Finanza_Strutturata,a.WGC_Specialista_Finanza_Strutturata__c);
                        specialisti.put(Label.WGC_Team_IFIS_Specialista_Leasing_EF,a.WGC_Specialista_Leasing__c);
                        specialisti.put(Label.WGC_Team_IFIS_Specialista_Leasing_TR,a.WGC_Specialista_Leasing_TR__c);
                        specialisti.put(Label.WGC_Team_IFIS_Presentatore, a.Presentatore__c);
                        specialisti.put(Label.WGC_Team_IFIS_Specialista_Pharma, a.WGC_Specialista_Pharma__c);
                        specialisti.put(Label.WGC_Team_IFIS_Gestore_Cliente, a.WGC_Gestore_Cliente__c);
                        specialisti.put(Label.WGC_Team_IFIS_Gestore_Debitore, a.WGC_Gestore_Debitore__c);
                    }
                    if(a.CodiceIstituto3n__c == '889'){
                        specialisti.put(Label.WGC_Team_IFIS_Specialista_IFIS_Finance,a.WGC_Specialista_IFIS_Finance__c);
                    }
                }
            }
            else{
                System.debug('@@@ codice 889 senza link legal entity');
                specialisti.put(Label.WGC_Team_IFIS_Specialista_IFIS_Finance, acc.WGC_Specialista_IFIS_Finance__c);
            }
        }
        
        //Set<Id> idSpecialisti = new Set<Id>();



        Map<Id, Boolean> specialistiAttivi = new Map<Id, Boolean>();


        specialistiAttivi.put(acc.WGC_Specialista_Factoring__c, acc.WGC_Factoring_Attivo__c);
        specialistiAttivi.put(acc.WGC_Specialista_Filo_Diretto__c, acc.WGC_Filo_Diretto_Attivo__c);
        specialistiAttivi.put(acc.WGC_Specialista_Crediti_Erariali__c, acc.WGC_Crediti_Erariali_Attivo__c);
        
        System.debug('SV acc: ' + JSON.serialize(acc));
        System.debug('SV specialisti: ' + specialisti);

        //Mappa di referenti esistanti
        Map<Id,User> mappaUtenti = new Map<Id,User>([SELECT Id, FirstName, LastName, Phone, Qualifica_Utente__c
                                                    FROM User 
                                                    WHERE Id IN : specialisti.values()]);
        
        System.debug('@@@ mappaUtenti ' + mappaUtenti);
        //Lista wrapper utilizzata per le info dei referenti da mostrare nel componente
        List<WrapperResponse> wrapperObjList = new List<WrapperResponse>();
        //Lista di appoggio per valutare se esistono tutti gli specialisti o se ne devo aggiungere alcuni fittizzi
        List<String> listaQualifiche = new List<String>();

        List<User> uL = new List<User>();
        for(String key : specialisti.keySet()){
            if(specialisti.get(key) != null){
                //Prendo l'utente in base alla qualifica registrata nella mappa specialisti
                //Utilizzo un oggetto User di appoggio
                User u = mappaUtenti.get(specialisti.get(key));
                //Creo l'oggetto wrapper da aggiungere poi alla lista
                WrapperResponse wr = new WrapperResponse();
                wr.id = u.Id;
                wr.workAs = key;
                wr.attivo = true;
                for(Id itemId : specialistiAttivi.keySet()){
                    if(specialisti.get(key) == itemId){
                        wr.attivo = specialistiAttivi.get(itemId);
                    }
                }
                wr.firstName = u.FirstName;
                wr.lastName = u.LastName;
                wr.phone = u.Phone;
                wr.qualifica = u.Qualifica_Utente__c;
                //Ordino gli elementi in base alle qualifiche
                if(wr.workAs == Label.WGC_Team_IFIS_Specialista_Crediti_Erariali){
                    wr.ordine = 3;
                }
                else if(wr.workAs == Label.WGC_Team_IFIS_Specialista_Factoring){
                    wr.ordine = 1;
                }
                else if(wr.workAs == Label.WGC_Team_IFIS_Specialista_International){
                    wr.ordine = 11;
                }
                else if(wr.workAs == Label.WGC_Team_IFIS_Specialista_Filo_Diretto){
                    wr.ordine = 2;
                }
                else if(wr.workAs == Label.WGC_Team_IFIS_Specialista_Finanza_Strutturata){
                    wr.ordine = 4;
                }
                else if(wr.workAs == Label.WGC_Team_IFIS_Specialista_IFIS_Finance){
                    wr.ordine = 12;
                }
                else if(wr.workAs == Label.WGC_Team_IFIS_Specialista_Leasing_EF){
                    wr.ordine = 10;
                }
                else if(wr.workAs == Label.WGC_Team_IFIS_Specialista_Leasing_TR){
                    wr.ordine = 9;
                }
                else if(wr.workAs == Label.WGC_Team_IFIS_Presentatore){
                    wr.ordine = 8;
                }
                else if(wr.workAs == Label.WGC_Team_IFIS_Specialista_Pharma){
                    wr.ordine = 5;
                }
                else if(wr.workAs == Label.WGC_Team_IFIS_Gestore_Cliente){
                    wr.ordine = 6;
                }
                else if(wr.workAs == Label.WGC_Team_IFIS_Gestore_Debitore){
                    wr.ordine = 7;
                }
                
                listaQualifiche.add(wr.workAs);
                wrapperObjList.add(wr);
            }

        }

        //Serie di controlli per per creare utenti fittizzi e mostrare il tutte le posizioni del team IFIS nel componente

        if(!listaQualifiche.contains(Label.WGC_Team_IFIS_Specialista_Crediti_Erariali)){
            WrapperResponse fakeUser = new WrapperResponse();
            fakeUser.workAs = Label.WGC_Team_IFIS_Specialista_Crediti_Erariali;
            fakeUser.ordine = 3;
            System.debug('@@@ fake ' + fakeUser);
            wrapperObjList.add(fakeUser);
        }
        if(!listaQualifiche.contains(Label.WGC_Team_IFIS_Specialista_Factoring)){
            WrapperResponse fakeUser = new WrapperResponse();
            fakeUser.workAs = Label.WGC_Team_IFIS_Specialista_Factoring;
            fakeUser.ordine = 1;
            System.debug('@@@ fake ' + fakeUser);
            wrapperObjList.add(fakeUser);
        }
        if(!listaQualifiche.contains(Label.WGC_Team_IFIS_Specialista_International)){
            WrapperResponse fakeUser = new WrapperResponse();
            fakeUser.workAs = Label.WGC_Team_IFIS_Specialista_International;
            fakeUser.ordine = 11;
            wrapperObjList.add(fakeUser);
        }
        if(!listaQualifiche.contains(Label.WGC_Team_IFIS_Specialista_Filo_Diretto)){
            WrapperResponse fakeUser = new WrapperResponse();
            fakeUser.workAs = Label.WGC_Team_IFIS_Specialista_Filo_Diretto;
            fakeUser.ordine = 2;
            wrapperObjList.add(fakeUser);
        }
        if(!listaQualifiche.contains(Label.WGC_Team_IFIS_Specialista_Finanza_Strutturata)){
            WrapperResponse fakeUser = new WrapperResponse();
            fakeUser.workAs = Label.WGC_Team_IFIS_Specialista_Finanza_Strutturata;
            fakeUser.ordine = 4;
            wrapperObjList.add(fakeUser);
        }
        if(!listaQualifiche.contains(Label.WGC_Team_IFIS_Specialista_IFIS_Finance)){
            WrapperResponse fakeUser = new WrapperResponse();
            fakeUser.workAs = Label.WGC_Team_IFIS_Specialista_IFIS_Finance;
            fakeUser.ordine = 12;
            wrapperObjList.add(fakeUser);
        }
        if(!listaQualifiche.contains(Label.WGC_Team_IFIS_Specialista_Leasing_EF)){
            WrapperResponse fakeUser = new WrapperResponse();
            fakeUser.workAs = Label.WGC_Team_IFIS_Specialista_Leasing_EF;
            fakeUser.ordine = 10;
            wrapperObjList.add(fakeUser);
        }
        if(!listaQualifiche.contains(Label.WGC_Team_IFIS_Specialista_Leasing_TR)){
            WrapperResponse fakeUser = new WrapperResponse();
            fakeUser.workAs = Label.WGC_Team_IFIS_Specialista_Leasing_TR;
            fakeUser.ordine = 9;
            wrapperObjList.add(fakeUser);
        }
        if(!listaQualifiche.contains(Label.WGC_Team_IFIS_Presentatore)){
            WrapperResponse fakeUser = new WrapperResponse();
            fakeUser.workAs = Label.WGC_Team_IFIS_Presentatore;
            fakeUser.ordine = 8;
            wrapperObjList.add(fakeUser);
        }
        if(!listaQualifiche.contains(Label.WGC_Team_IFIS_Specialista_Pharma)){
            WrapperResponse fakeUser = new WrapperResponse();
            fakeUser.workAs = Label.WGC_Team_IFIS_Specialista_Pharma;
            fakeUser.ordine = 5;
            wrapperObjList.add(fakeUser);
        }
        if(!listaQualifiche.contains(Label.WGC_Team_IFIS_Gestore_Cliente)){
            WrapperResponse fakeUser = new WrapperResponse();
            fakeUser.workAs = Label.WGC_Team_IFIS_Gestore_Cliente;
            fakeUser.ordine = 6;
            wrapperObjList.add(fakeUser);
        }
        if(!listaQualifiche.contains(Label.WGC_Team_IFIS_Gestore_Debitore)){
            WrapperResponse fakeUser = new WrapperResponse();
            fakeUser.workAs = Label.WGC_Team_IFIS_Gestore_Debitore;
            fakeUser.ordine = 7;
            wrapperObjList.add(fakeUser);
        }

        System.debug('@@@ wrapperObjList before sort ' + JSON.serialize(wrapperObjList));
        wrapperObjList.sort();
        System.debug('@@@ after sort ' + wrapperObjList);
        
        return wrapperObjList;
    }

    @AuraEnabled
    public static Account spegniFiloDiretto(String accId){

        Account acc = [ SELECT Id, WGC_Filo_Diretto_Attivo__c FROM Account WHERE Id =: accId ];
        acc.WGC_Filo_Diretto_Attivo__c = false;

        update acc;

        return acc;

    }
    
    @AuraEnabled
    public static Boolean userIsSpecialista(String accId){
        List<String> specialistiApiNames = new List<String>{'WGC_Specialista_Crediti_Erariali__c', 'WGC_Specialista_Filo_Diretto__c', 'WGC_Specialista_Finanza_Strutturata__c', 'WGC_Specialista_IFIS_Finance__c', 'WGC_Specialista_IFIS_International__c', 'WGC_Specialista_Leasing__c', 'WGC_Specialista_Leasing_TR__c', 'WGC_Specialista_Pharma__c'};

        try {
            Account acc = [ SELECT Id, WGC_Specialista_Crediti_Erariali__c, WGC_Specialista_Factoring__c, WGC_Specialista_Filo_Diretto__c, WGC_Specialista_Finanza_Strutturata__c, WGC_Specialista_IFIS_Finance__c, WGC_Specialista_IFIS_International__c, WGC_Specialista_Leasing__c, WGC_Specialista_Leasing_TR__c, WGC_Specialista_Pharma__c FROM Account WHERE Id =: accId ];
            Boolean isSpecialista = false;
            
            for (String apiName : specialistiApiNames) {
                if (acc.get(apiName) == UserInfo.getUserId())
                    isSpecialista = true;
            }

            return isSpecialista;
        } catch (Exception e) {
            System.debug('@@@@ MB TEN: ' + e.getMessage() + ' --- ' + e.getStackTraceString());
            return false;
        }
    }

    /*..........................................*/
    /* Wrapper class Response                  */
    /*.........................................*/
    
    public class WrapperResponse implements Comparable {
        
        @AuraEnabled public String id;
        @AuraEnabled public String workAs;
        @AuraEnabled public Boolean attivo;
        @AuraEnabled public String firstName;
        @AuraEnabled public String lastName;
        @AuraEnabled public String phone;
        @AuraEnabled public String qualifica;
        @AuraEnabled public Integer ordine;

        public WrapperResponse(){
            this.id = id;
            this.workAs = workAs;
            this.attivo = attivo;
            this.firstName = firstName;
            this.lastName = lastName;
            this.phone = phone;
            this.qualifica = qualifica;
            this.ordine = ordine;
        }

        public Integer compareTo(Object obj){
            WrapperResponse wr = (WrapperResponse) obj;

            if( ordine == wr.ordine ){
                return 0;
            }
            else if( ordine > wr.ordine ){
                return 1;
            }
            else{
                return -1;
            }
        }
    }
}