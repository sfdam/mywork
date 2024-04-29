public class WGC_PosizioneController {
	
    @AuraEnabled
    public static WrapperResponse getRecordData(String recordId){

        //Recupero ndg e codice istituto per cercare le altre legale entity
        List<Account> myAccount = [SELECT Id, NDGGruppo__c, CodiceIstituto3N__c FROM Account WHERE Id =: recordId];

        List<Account> listaLegalEntity = new List<Account>();
        listaLegalEntity = WGC_LegalEntity_Utility.getLinkLegalEntity(myAccount.get(0).NDGGruppo__c , myAccount.get(0).CodiceIstituto3N__c);
        
        WrapperResponse wrap = new WrapperResponse();

        //Se non esiste altro account legal entity utilizzo quello attuale
        if(listaLegalEntity != null){
            wrap = getRecordDataHelp(listaLegalEntity);      
        }
        else{
            wrap = getRecordDataHelp(myAccount);
        }
        return wrap;
    }

    /*
    private static List<String> getLabels(List<WGC_Posizione__c> listaPosizioni){

        for(WGC_Posizione__c item : listaPosizioni){
            Map<String,Object> mappa = item.getPopulatedFieldsAsMap();

            System.debug('@@@ mappa ' + mappa);
        }
    }
    */

    private static WrapperResponse getRecordDataHelp(List<Account> accountList){
        WrapperResponse wrap = new WrapperResponse();

        try{
            //Factoring Cedente
            List<WGC_Posizione__c> posizioneCed = [SELECT Id, Name, Qualifica_Posizione__c, Anagrafica__r.CodiceIstituto3N__c, RecordType.Name, RecordType.DeveloperName, Linee__c,
                Accordato__c, Impiego__c, Outstanding_Ced__c, Turnover_12_Mesi_Ced__c, Data_Ultima_Cessione__c, LastModifiedDate,
                MDI_12_Mesi__c, Impiego_12_Mesi__c, Redditivit_ultimi_12_mesi__c, Finanziabilita__c FROM WGC_Posizione__c 
                WHERE Anagrafica__c IN : accountList AND RecordType.DeveloperName IN ('FACTORINGCEDENTE') ORDER BY Anagrafica__r.CodiceIstituto3N__c];

            //Factoring Piano di Rientro Cedente
            List<WGC_Posizione__c> posizionePDRCed = [SELECT Id, Name, Qualifica_Posizione__c, Anagrafica__r.CodiceIstituto3N__c, RecordType.Name, RecordType.DeveloperName, Linee__c,
                Importo_iniziale__c, Importo_Residuo__c, Data_Scadenza_Ultima_Rata__c, Importo_prossima_rata__c, Rate_Insolute__c,
                Impiego_12_Mesi__c, MDI_12_Mesi__c, Redditivit_ultimi_12_mesi__c FROM WGC_Posizione__c 
                WHERE Anagrafica__c IN : accountList AND RecordType.DeveloperName IN ('FACTORINGPIANIDIRIENTROCEDENTE') ORDER BY Anagrafica__r.CodiceIstituto3N__c];

            //Factoring Debitore
            List<WGC_posizione__c> posizionePDRDeb = [SELECT Id, Name, Qualifica_Posizione__c, Anagrafica__r.CodiceIstituto3N__c, RecordType.Name, RecordType.DeveloperName, Linee__c,
                Importo_iniziale__c, Importo_Residuo__c, Data_Scadenza_Ultima_Rata__c, Importo_prossima_rata__c, Rate_Insolute__c,
                Impiego_12_Mesi__c, MDI_12_Mesi__c, Redditivit_ultimi_12_mesi__c FROM WGC_Posizione__c 
                WHERE Anagrafica__c IN : accountList AND RecordType.DeveloperName IN ('FACTORINGPIANIDIRIENTRODEBITORE') ORDER BY Anagrafica__r.CodiceIstituto3N__c];

            List<WGC_Posizione__c> posizioneConfirmingDebitore = [SELECT Id, Name, Qualifica_Posizione__c, Anagrafica__r.CodiceIstituto3N__c, RecordType.Name, RecordType.DeveloperName,
                Fornitori__c, Accordato__c, Utilizzo_Cassa__c, Utilizzo_Firma__c, Data_Ultima_Cessione__c, 
                MDI_12_Mesi__c, Impiego_12_Mesi__c, Redditivit_ultimi_12_mesi__c FROM WGC_Posizione__c 
                WHERE Anagrafica__c IN : accountList AND RecordType.DeveloperName IN ('CONFIRMINGDEBITORE') ORDER BY Anagrafica__r.CodiceIstituto3N__c];

            List<WGC_Posizione__c> posizionePlafondDebitore = [SELECT Id, Name, Qualifica_Posizione__c, Anagrafica__r.CodiceIstituto3N__c, RecordType.Name, RecordType.DeveloperName,
                Cedenti__c, Plafond__c, Di_cui_prosoluto__c, Outstanding_Deb__c, Di_cui_confermato__c,
                Turnover_12_Mesi_Deb__c, Tempo_medio_pagamento__c, Tempo_medio_riconoscimento__c,
                Ritardo_medio_pagamento__c, Durata_Dilazione__c, Durata_massima_credito__c FROM WGC_Posizione__c 
                WHERE Anagrafica__c IN : accountList AND RecordType.DeveloperName IN ('PLAFONDDEBITORE') ORDER BY Anagrafica__r.CodiceIstituto3N__c];

            //Finanziamenti
            List<WGC_Posizione__c> posizioneLending = [SELECT Id, Name, Qualifica_Posizione__c, Anagrafica__r.CodiceIstituto3N__c, RecordType.Name, RecordType.DeveloperName,
                Piani_Ammortamento_Attivi__c, Importo_Erogato__c, Debito_Residuo__c, Data_Scadenza_Ultima_Rata__c,
                Importo_prossima_rata__c, Rate_Insolute__c, Impiego_12_Mesi__c, MDI_12_Mesi__c, Redditivit_ultimi_12_mesi__c 
                FROM WGC_Posizione__c 
                WHERE Anagrafica__c IN : accountList AND RecordType.DeveloperName IN ('FINANZIAMENTI') ORDER BY Anagrafica__r.CodiceIstituto3N__c];

            //Leasing
            List<WGC_Posizione__c> posizioneLeasing = [SELECT Id, Name, Qualifica_Posizione__c, Anagrafica__r.CodiceIstituto3N__c, RecordType.Name, RecordType.DeveloperName,
                Contratti__c, Importo_iniziale__c, Importo_Residuo__c, Data_Scadenza_Ultima_Rata__c, Num_Contratti_frm__c,
                Importo_prossima_rata__c, Impiego_12_Mesi__c, MDI_12_Mesi__c, Redditivit_ultimi_12_mesi__c
                FROM WGC_Posizione__c 
                WHERE Anagrafica__c IN : accountList AND RecordType.DeveloperName IN ('LEASING') ORDER BY Anagrafica__r.CodiceIstituto3N__c];


            //Conti Correnti
            List<WGC_Posizione__c> posizioneCC = [SELECT Id, Name, Qualifica_Posizione__c, Anagrafica__r.CodiceIstituto3N__c, RecordType.Name, RecordType.DeveloperName,
                Conti__c, Accordato__c, Importo_utilizzato_interrogazione__c, MDI_12_Mesi__c, Impiego_12_Mesi__c, Redditivit_ultimi_12_mesi__c,
                Redditivita_MDI_Volumi__c FROM WGC_Posizione__c 
                WHERE Anagrafica__c IN : accountList AND RecordType.DeveloperName IN ('CONTICORRENTI') ORDER BY Anagrafica__r.CodiceIstituto3N__c];

            //Anticipo PAC/PSR
            List<WGC_Posizione__c> posizioneAnticipoPAC = [SELECT Id, Name, Qualifica_Posizione__c, Anagrafica__r.CodiceIstituto3N__c, RecordType.Name, RecordType.DeveloperName,
                Data_di_scadenza__c, Accordato__c, Saldo__c, MDI_12_Mesi__c, Impiego_12_Mesi__c, Redditivit_ultimi_12_mesi__c,
                Redditivita_MDI_Volumi__c FROM WGC_Posizione__c 
                WHERE Anagrafica__c IN : accountList AND RecordType.DeveloperName IN ('ANTICIPIPACPSR') ORDER BY Anagrafica__r.CodiceIstituto3N__c];
            
            //Conti Deposito
            List<WGC_Posizione__c> posizioneCD = [SELECT Id, Name, Qualifica_Posizione__c, Anagrafica__r.CodiceIstituto3N__c, RecordType.Name, RecordType.DeveloperName, Linee__c, Importo_accordato__c, Importo_utilizzato_interrogazione__c,
                Conti__c, Saldo__c, Scadenza_Ultimo_Vincolo__c 
                FROM WGC_Posizione__c 
                WHERE Anagrafica__c IN : accountList AND RecordType.DeveloperName IN ('CONTIDEPOSITO') ORDER BY Anagrafica__r.CodiceIstituto3N__c];
            
            //Garanzie
            List<WGC_Posizione__c> posizioneGaranzie = [SELECT Id, Name, Qualifica_Posizione__c, Anagrafica__r.CodiceIstituto3N__c, RecordType.Name, RecordType.DeveloperName,
                Garanzie__c, Importo_accordato__c
                FROM WGC_Posizione__c 
                WHERE Anagrafica__c IN : accountList AND RecordType.DeveloperName IN ('GARANZIE') ORDER BY Anagrafica__r.CodiceIstituto3N__c];
            
            //Crediti Problematici
            List<WGC_Posizione__c> posizioneCreditiProb = [SELECT Id, Name, Qualifica_Posizione__c, Anagrafica__r.CodiceIstituto3N__c, RecordType.Name, RecordType.DeveloperName,
                Importo_accordato__c FROM WGC_Posizione__c 
                WHERE Anagrafica__c IN : accountList AND RecordType.DeveloperName IN ('CREDITIPROBLEMATICI') ORDER BY Anagrafica__r.CodiceIstituto3N__c];
            
            //Credito di firma
            List<WGC_Posizione__c> posizioneCDF = [SELECT Id, Name, Qualifica_Posizione__c, Anagrafica__r.CodiceIstituto3N__c, RecordType.Name, RecordType.DeveloperName,
                Linee__c, Accordato__c, Importo_utilizzato_interrogazione__c, Data_di_scadenza__c, MDI_12_Mesi__c 
                FROM WGC_Posizione__c 
                WHERE Anagrafica__c IN : accountList AND RecordType.DeveloperName IN ('CREDITIDIFIRMA') ORDER BY Anagrafica__r.CodiceIstituto3N__c];

            //NPL
            List<WGC_Posizione__c> posizioneNPL = [SELECT Id, Name, Qualifica_Posizione__c, Anagrafica__r.CodiceIstituto3N__c, RecordType.Name, RecordType.DeveloperName, 
                Linee__c, Valore_Nominale_Residuo__c, Impiego_12_Mesi__c, MDI_12_Mesi__c, Redditivit_ultimi_12_mesi__c
                FROM WGC_Posizione__c 
                WHERE Anagrafica__c IN : accountList AND RecordType.DeveloperName IN ('NPL') ORDER BY Anagrafica__r.CodiceIstituto3N__c];

            //FPALUMBO 24/02/2020
            List<WGC_Posizione__c> posizioneCreditiErariali = [SELECT Id, Name, Qualifica_Posizione__c, Linee__c,Anagrafica__r.CodiceIstituto3N__c,
                                                                      Valore_Nominale_cer__c, Prezzo_di_acquisto_cer__c, imp_valore_residuo_cer__c, MDI__c,
                                                                      RecordType.Name, RecordType.DeveloperName
                                                               FROM WGC_Posizione__c
                                                               WHERE Anagrafica__c IN : accountList AND RecordType.DeveloperName IN ('CREDITIERARIALI')
                                                               ORDER BY Anagrafica__r.CodiceIstituto3N__c];

            //FPALUMBO 24/02/2020
            List<WGC_Posizione__c> posizioneAnticipoFatture = [SELECT Id, Name, Qualifica_Posizione__c, Linee__c,Anagrafica__r.CodiceIstituto3N__c,
                                                                      Valore_Nominale_cer__c, Prezzo_di_acquisto_cer__c, imp_valore_residuo_cer__c, MDI__c,
                                                                      RecordType.Name, RecordType.DeveloperName
                                                               FROM WGC_Posizione__c
                                                               WHERE Anagrafica__c IN : accountList AND RecordType.DeveloperName IN ('Anticipo_Fatture')
                                                               ORDER BY Anagrafica__r.CodiceIstituto3N__c];
            
            //FPALUMBO 24/02/2020
            List<WGC_Posizione__c> posizionePortafoglioCommerciale = [SELECT Id, Name, Qualifica_Posizione__c, Linee__c,Anagrafica__r.CodiceIstituto3N__c,
                                                                      Valore_Nominale_cer__c, Prezzo_di_acquisto_cer__c, imp_valore_residuo_cer__c, MDI__c,
                                                                      RecordType.Name, RecordType.DeveloperName
                                                               FROM WGC_Posizione__c
                                                               WHERE Anagrafica__c IN : accountList AND RecordType.DeveloperName IN ('Portafoglio_Commerciale')
                                                               ORDER BY Anagrafica__r.CodiceIstituto3N__c];
            
            //GBAVETTA 06/05/2020
            List<WGC_Posizione__c> posizioneCorporateEstero = [SELECT Id, Name, Qualifica_Posizione__c, Linee__c,Anagrafica__r.CodiceIstituto3N__c,
                                                                      Valore_Nominale_cer__c, Prezzo_di_acquisto_cer__c, imp_valore_residuo_cer__c, MDI__c,
                                                                      RecordType.Name, RecordType.DeveloperName
                                                               FROM WGC_Posizione__c
                                                               WHERE Anagrafica__c IN : accountList AND RecordType.DeveloperName IN ('Corporate_Estero')
                                                               ORDER BY Anagrafica__r.CodiceIstituto3N__c];

                                                               
            //Factoring
            List<PosizioneContainer> listaPosCed = buildWrapperPosizione(posizioneCed);
            //Piani di rientro
            List<PosizioneContainer> listaPosPDRCed = buildWrapperPosizione(posizionePDRCed);
            
            //Debitore
            List<PosizioneContainer> listaPosPDRDeb = buildWrapperPosizione(posizionePDRDeb);
            //Confirming Debitore
            List<PosizioneContainer> listaPosConfirmingDeb = buildWrapperPosizione(posizioneConfirmingDebitore);
            //Plafond Debitore
            List<PosizioneContainer> listaPosPlafondDeb = buildWrapperPosizione(posizionePlafondDebitore);

            //Lending o finanziamenti
            List<PosizioneContainer> listaPosFinanziamenti = buildWrapperPosizione(posizioneLending);

            //Leasing
            List<PosizioneContainer> listaPosLeasing = buildWrapperPosizione(posizioneLeasing);
            
            //Conti Correnti
            List<PosizioneContainer> listaPosCC = buildWrapperPosizione(posizioneCC);

            //Anticipo Pac
            List<PosizioneContainer> listaPosAnticipoPac = buildWrapperPosizione(posizioneAnticipoPAC);

            //Conti Deposito
            List<PosizioneContainer> listaPosCD = buildWrapperPosizione(posizioneCD);

            //Garanzie
            List<PosizioneContainer> listaPosGaranzie = buildWrapperPosizione(posizioneGaranzie);

            //Crediti Problematici
            List<PosizioneContainer> listaPosCreditiProb = buildWrapperPosizione(posizioneCreditiProb);

            //Crediti di firma
            List<PosizioneContainer> listaPosCDF = buildWrapperPosizione(posizioneCDF);

            //NPL
            List<PosizioneContainer> listaPosNPL = buildWrapperPosizione(posizioneNPL);

            //FPALUMBO 24/02/2020
            List<PosizioneContainer> listaCreditiErariali = buildWrapperPosizione(posizioneCreditiErariali);

            //SV posizioneAnticipoFatture
            List<PosizioneContainer> listaAnticipoFatture = buildWrapperPosizione(posizioneAnticipoFatture);

            //SV posizionePortafoglioCommerciale
            List<PosizioneContainer> listaPortafoglioCommerciale = buildWrapperPosizione(posizionePortafoglioCommerciale);
            
            //GB posizioneCorporateEstero
            List<PosizioneContainer> listaCorporateEstero = buildWrapperPosizione(posizioneCorporateEstero);

            WrapperPosizione wrapPos = new WrapperPosizione();

            //Factoring
            wrapPos.factoringCedente = listaPosCed == null ? null : listaPosCed;
            wrapPos.factoringPDRCedente = listaPosPDRCed == null ? null : listaPosPDRCed;

            //Debitore
            wrapPos.factoringPDRDebitore = listaPosPDRDeb == null ? null : listaPosPDRDeb;
            wrapPos.factoringConfirmingDebitore = listaPosConfirmingDeb == null ? null : listaPosConfirmingDeb;
            wrapPos.factoringPlafondDebitore = listaPosPlafondDeb == null ? null : listaPosPlafondDeb;

            //Lending o finanziamenti
            wrapPos.finanziamenti = listaPosFinanziamenti == null ? null : listaPosFinanziamenti;

            //Leasing
            wrapPos.leasing = listaPosLeasing == null ? null : listaPosLeasing;

            //Altri Prodotti
            wrapPos.creditoDiFirma = listaPosCDF == null ? null : listaPosCDF;

            //Servizi Bancari
            wrapPos.contiCorrenti = listaPosCC;
            wrapPos.contiDeposito = listaPosCD;

            //Anticipi PAC
            wrapPos.anticipoPac = listaPosAnticipoPac;

            //Crediti Problematici
            wrapPos.creditiProb = listaPosCreditiProb;

            //NPL
            wrapPos.NPL = listaPosNPL;

            //Garanzie
            wrapPos.garanzie = listaPosGaranzie == null ? null : listaPosGaranzie;

            //FPALUMBO 24/02/2020
            wrapPos.creditiErariali = listaCreditiErariali == null ? null : listaCreditiErariali;

            //SV
            wrapPos.anticipoFatture = listaAnticipoFatture == null ? null : listaAnticipoFatture;

            //SV
            wrapPos.portafoglioCommerciale = listaPortafoglioCommerciale == null ? null : listaPortafoglioCommerciale;
            
            //GB
            wrapPos.portafoglioCorporateEstero = listaCorporateEstero == null ? null : listaCorporateEstero;

            wrap.data.add(wrapPos);

            
        }
        catch(Exception e){
            wrap.success = false;
            wrap.message = e.getMessage();
        }
        return wrap;
    }

    private static List<PosizioneContainer> buildWrapperPosizione(List<WGC_Posizione__c> lista){

        List<PosizioneContainer> returnList = new List<PosizioneContainer>();

        for(WGC_Posizione__c item : lista){
            PosizioneContainer pos = new PosizioneContainer();
            pos.posizione = item;
            pos.codiceIstituto = item.Anagrafica__r.CodiceIstituto3N__c;
            returnList.add(pos);
        }

        return returnList;
    }

    public class WrapperPosizione{

        @AuraEnabled
        public List<PosizioneContainer> factoringCedente;
        @AuraEnabled
        public List<PosizioneContainer> factoringPDRCedente;
        @AuraEnabled
        public List<PosizioneContainer> factoringPDRDebitore;
        @AuraEnabled
        public List<PosizioneContainer> factoringConfirmingDebitore;
        @AuraEnabled
        public List<PosizioneContainer> factoringPlafondDebitore;
        @AuraEnabled
        public List<PosizioneContainer> finanziamenti;
        @AuraEnabled
        public List<PosizioneContainer> leasing;
        @AuraEnabled
        public List<PosizioneContainer> contiCorrenti;
        @AuraEnabled
        public List<PosizioneContainer> anticipoPac;
        @AuraEnabled
        public List<PosizioneContainer> contiDeposito;
        @AuraEnabled
        public List<PosizioneContainer> garanzie;
        @AuraEnabled
        public List<PosizioneContainer> creditiProb;
        @AuraEnabled
        public List<PosizioneContainer> creditoDiFirma;
        @AuraEnabled
        public List<PosizioneContainer> NPL;
        @AuraEnabled
        public List<PosizioneContainer> creditiErariali;

        @AuraEnabled
        public List<PosizioneContainer> portafoglioCommerciale;
        @AuraEnabled
        public List<PosizioneContainer> anticipoFatture;
        
        @AuraEnabled
        public List<PosizioneContainer> portafoglioCorporateEstero;

        public WrapperPosizione(){
            this.factoringCedente = new List<PosizioneContainer>();
            this.factoringPDRCedente = new List<PosizioneContainer>();
            this.factoringPDRDebitore = new List<PosizioneContainer>();
            this.factoringConfirmingDebitore = new List<PosizioneContainer>();
            this.factoringPlafondDebitore = new List<PosizioneContainer>();
            this.finanziamenti = new List<PosizioneContainer>();
            this.leasing = new List<PosizioneContainer>();
            this.contiCorrenti = new List<PosizioneContainer>();
            this.anticipoPac = new List<PosizioneContainer>();
            this.contiDeposito = new List<PosizioneContainer>();
            this.garanzie = new List<PosizioneContainer>();
            this.creditiProb = new List<PosizioneContainer>();
            this.creditoDiFirma = new List<PosizioneContainer>();
            this.NPL = new List<PosizioneContainer>();
            this.creditiErariali = new List<PosizioneContainer>();

            this.portafoglioCommerciale = new List<PosizioneContainer>();
            this.anticipoFatture = new List<PosizioneContainer>();
            
            this.portafoglioCorporateEstero = new List<PosizioneContainer>();
        }
    }

    public class PosizioneContainer{
        @AuraEnabled
        public WGC_Posizione__c posizione;
        @AuraEnabled
        public String codiceIstituto;

        public PosizioneContainer(){
            this.posizione = posizione;
            this.codiceIstituto = codiceIstituto;
        }
    }

    //Metodo per calcolare la percentuale dei vari prodotti
    @AuraEnabled
    public static WrapperResponse getPositionPercent(String accountId){

        List<Account> myAccount = new List<Account>();
        List<Account> listLE = new List<Account>();

        myAccount = [SELECT Id, Name, NDGGruppo__c, CodiceIstituto3N__c FROM Account WHERE Id =: accountId];

        listLE = WGC_LegalEntity_Utility.getLinkLegalEntity(myAccount.get(0).NDGGruppo__c, myAccount.get(0).CodiceIstituto3N__c);

        //Il calcolo delle percentuali deve essere separato in base alla legal entity di appartenenza
        //Quindi se sono IFIS italia conterò solo ifis italia, se appartengo ad entrambe conterò entrambe ma in righe separate
        //Aggiungere inoltre il calcolo percentuale in base all'anno (CHIEDERE A LUCA IN BASE A QUALE CAMPO CAPIRE L'ANNO)

        WrapperResponse wrap = new WrapperResponse();

        if(listLE != null && !listLE.isEmpty()){
            wrap = getPositionPercentHelp(listLE);
        }
        else{
            wrap = getPositionPercentHelp(myAccount);
        }
         return wrap;
    }

    private static WrapperResponse getPositionPercentHelp(List<Account> accountList){
        System.debug('@@@ accountList ' + accountList);
        WrapperResponse wrap = new WrapperResponse();

        try{
            List<WrapperLegalEntity> listWle = new List<WrapperLegalEntity>();

            for(Account a : accountList){
                List<WGC_Posizione__c>  listaFactoringCedente = [SELECT Id, Name, Accordato_puntuale__c, Impiego_puntuale__c, RecordType.DeveloperName FROM WGC_Posizione__c WHERE Anagrafica__c =: a.Id AND RecordType.DeveloperName IN ('FACTORINGCEDENTE' , 'FACTORINGPIANIDIRIENTROCEDENTE')];
                List<WGC_Posizione__c>  listaFactoringDebitore = [SELECT Id, Name, Accordato_puntuale__c, Impiego_puntuale__c, RecordType.DeveloperName FROM WGC_Posizione__c WHERE Anagrafica__c =: a.Id AND RecordType.DeveloperName IN ('PLAFONDDEBITORE' , 'CONFIRMINGDEBITORE' , 'FACTORINGPIANIDIRIENTRODEBITORE')];
                List<WGC_Posizione__c>  listaFinanziamenti = [SELECT Id, Name, Accordato_puntuale__c, Impiego_puntuale__c, RecordType.DeveloperName FROM WGC_Posizione__c WHERE Anagrafica__c =: a.Id AND RecordType.DeveloperName IN ('FINANZIAMENTI')];
                List<WGC_Posizione__c>  listaLeasing = [SELECT Id, Name, Accordato_puntuale__c, Impiego_puntuale__c, RecordType.DeveloperName FROM WGC_Posizione__c WHERE Anagrafica__c =: a.Id AND RecordType.DeveloperName IN ('LEASING')];
                List<WGC_Posizione__c>  listaAltro = [SELECT Id, Name, Accordato_puntuale__c, Impiego_puntuale__c, RecordType.DeveloperName FROM WGC_Posizione__c WHERE Anagrafica__c =: a.Id AND RecordType.DeveloperName IN ('NPL', 'GARANZIE', 'CREDITIDIFIRMA', 'CONTICORRENTI', 'CONTIDEPOSITO', 'ANTICIPOPACPSR', 'CREDITIPROBLEMATICI')];


                WrapperLegalEntity wle = new WrapperLegalEntity();
                wle.codiceIstituto = a.CodiceIstituto3N__c;
                
                //Somma Impiego
                Decimal sumImpiegoFactCed = 0.00;
                Decimal sumImpiegoFactDeb = 0.00;
                Decimal sumImpiegoFinanz = 0.00;
                Decimal sumImpiegoLeasing = 0.00;
                Decimal sumImpiegoAltro = 0.00;
                Decimal sumImpiegoTotale = 0.00;

                //Somma Accordato
                Decimal sumAccordatoFactCed = 0.00;
                Decimal sumAccordatoFactDeb = 0.00;
                Decimal sumAccordatoFinanz = 0.00;
                Decimal sumAccordatoLeasing = 0.00;
                Decimal sumAccordatoAltro = 0.00;
                Decimal sumAccordatoTotale = 0.00;

                for(WGC_Posizione__c item : listaFactoringCedente){
                    sumImpiegoFactCed += item.Impiego_puntuale__c == null ? 0.00 : item.Impiego_puntuale__c;
                    sumAccordatoFactCed += item.Accordato_puntuale__c == null ? 0.00 : item.Accordato_puntuale__c;
                }

                for(WGC_Posizione__c item : listaFactoringDebitore){
                    sumImpiegoFactDeb += item.Impiego_puntuale__c == null ? 0.00 : item.Impiego_puntuale__c;
                    sumAccordatoFactDeb += item.Accordato_puntuale__c == null ? 0.00 : item.Accordato_puntuale__c;
                }

                for(WGC_Posizione__c item : listaFinanziamenti){
                    sumImpiegoFinanz += item.Impiego_puntuale__c == null ? 0.00 : item.Impiego_puntuale__c;
                    sumAccordatoFinanz += item.Accordato_puntuale__c == null ? 0.00 : item.Accordato_puntuale__c;
                }

                for(WGC_Posizione__c item : listaLeasing){
                    sumImpiegoLeasing += item.Impiego_puntuale__c == null ? 0.00 : item.Impiego_puntuale__c;
                    sumAccordatoLeasing += item.Accordato_puntuale__c == null ? 0.00 : item.Accordato_puntuale__c;
                }

                for(WGC_Posizione__c item : listaAltro){
                    sumImpiegoAltro += item.Impiego_puntuale__c == null ? 0.00 : item.Impiego_puntuale__c;
                    sumAccordatoAltro += item.Accordato_puntuale__c == null ? 0.00 : item.Accordato_puntuale__c;
                }

                sumImpiegoTotale = sumImpiegoFactCed + sumImpiegoFactDeb + sumImpiegoFinanz + sumImpiegoLeasing + sumImpiegoAltro;
                sumAccordatoTotale = sumAccordatoFactCed + sumAccordatoFactDeb + sumAccordatoFinanz + sumAccordatoLeasing + sumAccordatoAltro;

                WrapperPercentuale percentualiImpiego = new WrapperPercentuale();
                WrapperPercentuale percentualiAccordato = new WrapperPercentuale();

                if(sumImpiegoTotale != 0){
                    percentualiImpiego.percentFactoringCed = Math.round((sumImpiegoFactCed*100)/sumImpiegoTotale);
                    percentualiImpiego.percentFactoringDeb = Math.round((sumImpiegoFactDeb*100)/sumImpiegoTotale);
                    percentualiImpiego.percentFinanziamenti = Math.round((sumImpiegoFinanz*100)/sumImpiegoTotale);
                    percentualiImpiego.percentLeasing = Math.round((sumImpiegoLeasing*100)/sumImpiegoTotale);
                    percentualiImpiego.percentAltro = Math.round((sumImpiegoAltro*100)/sumImpiegoTotale);
                }

                if(sumAccordatoTotale != 0){
                    percentualiAccordato.percentFactoringCed = Math.round((sumAccordatoFactCed*100)/sumAccordatoTotale);
                    percentualiAccordato.percentFactoringDeb = Math.round((sumAccordatoFactDeb*100)/sumAccordatoTotale);
                    percentualiAccordato.percentFinanziamenti = Math.round((sumAccordatoFinanz*100)/sumAccordatoTotale);
                    percentualiAccordato.percentLeasing = Math.round((sumAccordatoLeasing*100)/sumAccordatoTotale);
                    percentualiAccordato.percentAltro = Math.round((sumAccordatoAltro*100)/sumAccordatoTotale);
                }

                wle.percentualiImpiego = percentualiImpiego;
                wle.percentualiAccordato = percentualiAccordato;
                listWle.add(wle);
            
            }

            wrap.data.add(listWle);  
        }
        catch(Exception e){
            System.debug('@@@ Exception e ' + e);
            System.debug('@@@ line ' + e.getLineNumber());
            wrap.success = false;
            wrap.message = e.getMessage();
        }
        return wrap;
    }

    public class WrapperLegalEntity{
        @AuraEnabled
        public String codiceIstituto;
        @AuraEnabled
        public WrapperPercentuale percentualiImpiego;
        @AuraEnabled
        public WrapperPercentuale percentualiAccordato;

        public WrapperLegalEntity(){
            this.codiceIstituto = codiceIstituto;
            this.percentualiImpiego = new WrapperPercentuale();
            this.percentualiAccordato = new WrapperPercentuale();
        }
    }

    public class WrapperPercentuale{
        @AuraEnabled
        public Integer percentFactoringCed;
        @AuraEnabled
        public Integer percentFactoringDeb;
        @AuraEnabled
        public Integer percentFinanziamenti;
        @AuraEnabled
        public Integer percentLeasing;
        @AuraEnabled
        public Integer percentAltro;
        @AuraEnabled
        public Integer percentTotal;

        public WrapperPercentuale(){
            this.percentFactoringCed = 0;
            this.percentFactoringDeb = 0;
            this.percentFinanziamenti = 0;
            this.percentLeasing = 0;
            this.percentAltro = 0;
            this.percentTotal = 0;
        }
    }

    // PEF37
    @AuraEnabled
    public static WrapperResponse aggiornaCampi_Prodotti_Posizione(String objType, String accountId){
        System.debug('SV objType: ' + objType);
        System.debug('SV accountId: ' + accountId);
        WrapperResponse result = new WrapperResponse();
        WrapperRecords test = new WrapperRecords();

        List<WGC_Linea_Prodotto__c> listLineaAnag = [ SELECT RecordType.DeveloperName, Name, Impiego__c, Outstanding__c, Importo_Finanziabile__c, Data_ultima_cessione__c, Anagrafica__c,
                                                            Descrizione_Posizione__c, Codice_Stato__c
                                                        FROM WGC_Linea_Prodotto__c 
                                                        WHERE Anagrafica__c =: accountId ];

        Set<String> numLineaSet = new Set<String>();
        for (WGC_Linea_Prodotto__c linea : listLineaAnag) {
            if(linea.RecordType.DeveloperName == 'FACTORINGCEDENTE'){
                if(objType == 'Prodotto'){
                    numLineaSet.add(linea.Name);
                } else {
                    if(linea.Descrizione_Posizione__c == 'FACTORING - CEDENTE' && (linea.Codice_Stato__c == '003' || linea.Codice_Stato__c == '0' || linea.Codice_Stato__c == '007')){
                        numLineaSet.add(linea.Name);
                    }
                }
            }
        }                                          

        Account acc = [SELECT Id, Name, CodiceIstituto3N__c, NDGGruppo__c FROM Account WHERE Id =: accountId ];
        System.debug('SV acc: ' + acc);
        
        WGC_WsRest.GetCampiProdottiPosizioneResponse response = WGC_WsRest.aggiornaCampi_Prodotti_Posizione(acc.CodiceIstituto3N__c, acc.NDGGruppo__c, null);

        Map<String, WGC_WsRest.LineeCredito> numLineaCreditoMap = new Map<String, WGC_WsRest.LineeCredito>();
        Set<String> numLineaCreditoSet = new Set<String>();
        List<WGC_Linea_Prodotto__c> listLineaResponse = new List<WGC_Linea_Prodotto__c>();
        for (WGC_WsRest.LineeCredito elemento : response.payload.outputRichiesta.elencoLineeCredito) {
            System.debug('SV elemento LineeCredito: ' + elemento);
                
                if(numLineaSet.contains(String.ValueOf(elemento.numLineaCredito))){
                    
                    WGC_Linea_Prodotto__c elementResponse = new WGC_Linea_Prodotto__c();
                    elementResponse.Impiego__c = elemento.impImpiegoCtv;
                    elementResponse.Outstanding__c = elemento.impOutstandingCtv;
                    elementResponse.Importo_Finanziabile__c = elemento.impFinanziabile;
                    elementResponse.Data_ultima_cessione__c = (elemento.datUltimaCessione != null) ? DateTime.newInstance(elemento.datUltimaCessione).date() : null;
                    
                    numLineaCreditoMap.put(String.valueOf(elemento.numLineaCredito), elemento);
                    numLineaCreditoSet.add(String.valueOf(elemento.numLineaCredito));
                    listLineaResponse.add(elementResponse);
                }
        }

        System.debug('SV Map LineeCredito: ' + numLineaCreditoMap);
        test.lineaCreditoResponse = listLineaResponse;
        System.debug('SV Set LineeCredito: ' + numLineaCreditoSet);

        // impImpiegoCtv --> Impiego__c
        // impOutstandingCtv --> Outstanding__c
        // impFinanziabile --> Importo_Finanziabile__c
        // dataUltimaCessione --> Data_ultima_cessione__c


        if(objType == 'Prodotto'){

            Map<String, WGC_Linea_Prodotto__c[]> lineaCreditoCrmMap = U.groupBy([
                SELECT Name, Impiego__c, Outstanding__c, Importo_Finanziabile__c, Data_ultima_cessione__c
                FROM WGC_Linea_Prodotto__c
                WHERE Name IN : numLineaCreditoSet
            ], 'Name');

            System.debug('SV Map lineaCreditoCrmMap: ' + lineaCreditoCrmMap);

            List<WGC_Linea_Prodotto__c> listLinea = new List<WGC_Linea_Prodotto__c>();
            for(String numLinea : lineaCreditoCrmMap.keySet()){            
                lineaCreditoCrmMap.get(numLinea)[0].Impiego__c              =  numLineaCreditoMap.get(numLinea).impImpiegoCtv;
                lineaCreditoCrmMap.get(numLinea)[0].Outstanding__c          =  numLineaCreditoMap.get(numLinea).impOutstandingCtv;
                lineaCreditoCrmMap.get(numLinea)[0].Importo_Finanziabile__c =  numLineaCreditoMap.get(numLinea).impFinanziabile;
lineaCreditoCrmMap.get(numLinea)[0].Data_ultima_cessione__c =  (numLineaCreditoMap.get(numLinea).datUltimaCessione != null) ? DateTime.newInstance(numLineaCreditoMap.get(numLinea).datUltimaCessione).date() : null;
                listLinea.add(lineaCreditoCrmMap.get(numLinea)[0]);
            }

            System.debug('SV Map LineeCredito Update: ' + lineaCreditoCrmMap);
            upsert listLinea;

        } else {


            
            List<WGC_Posizione__c> myPosizione = [SELECT RecordType.DeveloperName, Impiego__c, Outstanding_CED__c, Importo_Finanziabile__c, Data_ultima_cessione__c, Anagrafica__c
                                                FROM WGC_Posizione__c 
                                                WHERE Anagrafica__c =: accountId AND RecordType.DeveloperName = 'FACTORINGCEDENTE' ];

            Decimal impiego = 0;
            Decimal outstanding = 0;
            Decimal imp_finanziabile = 0;
            Date lastDate_ultima_cessione = Date.newInstance(1900, 1, 1);
            for(WGC_Linea_Prodotto__c lineaCredito : listLineaResponse){
                System.debug('impiego: ' + impiego);
                impiego = impiego + lineaCredito.Impiego__c;
                outstanding = outstanding + lineaCredito.Outstanding__c;
                imp_finanziabile = imp_finanziabile + lineaCredito.Importo_Finanziabile__c;
                if(lineaCredito.Data_ultima_cessione__c >= lastDate_ultima_cessione){
                    lastDate_ultima_cessione = lineaCredito.Data_ultima_cessione__c;
                }
            }     

            if(myPosizione.size() > 0){
                myPosizione.get(0).Impiego__c = impiego;
                myPosizione.get(0).Outstanding_CED__c = outstanding;
                myPosizione.get(0).Importo_Finanziabile__c = imp_finanziabile;
                myPosizione.get(0).Data_ultima_cessione__c = lastDate_ultima_cessione;

                System.debug('SV Map myPosizione Update: ' + myPosizione);
                upsert myPosizione;
            }


        }

        result.data.add(test);
        return result;
    }

    @AuraEnabled
    public static PosizioneContainer getFacCedente(String accountId){
        System.debug('SV accountId: ' + accountId);
        PosizioneContainer result = new PosizioneContainer();

        List<WGC_Posizione__c> myPosizione = [SELECT Id, Name, Qualifica_Posizione__c, Anagrafica__r.CodiceIstituto3N__c, RecordType.Name, RecordType.DeveloperName, Linee__c,
               Accordato__c, Impiego__c, Outstanding_Ced__c, Turnover_12_Mesi_Ced__c, Data_Ultima_Cessione__c, LastModifiedDate,
               MDI_12_Mesi__c, Impiego_12_Mesi__c, Redditivit_ultimi_12_mesi__c, Finanziabilita__c FROM WGC_Posizione__c WHERE Anagrafica__c =: accountId AND RecordType.DeveloperName = 'FACTORINGCEDENTE' ];

        result.posizione = myPosizione.size() > 0 ? myPosizione.get(0) : new WGC_Posizione__c();
        result.codiceIstituto = myPosizione.size() > 0 ? myPosizione.get(0).Anagrafica__r.CodiceIstituto3N__c : '';
        return result;

    }

    /*..........................................*/
    /* Wrapper class to display Position       */
    /*.........................................*/
    
    public class WrapperRecords {
        
        @AuraEnabled public List<WGC_Linea_Prodotto__c> lineaCreditoResponse;
    }

    /*..........................................*/
    /* Wrapper class to display Response       */
    /*.........................................*/
    
    public class WrapperResponse {
        
        @AuraEnabled public Boolean success;
        @AuraEnabled public String message;
        @AuraEnabled public List<Object> data;
        
        public WrapperResponse(){
            success = true;
            message = '';
            data = new List<Object>();
        }
    }
}