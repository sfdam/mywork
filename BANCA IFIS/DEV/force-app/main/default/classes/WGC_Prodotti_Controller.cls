public class WGC_Prodotti_Controller {
    
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


            
            WGC_Posizione__c myPosizione = [SELECT RecordType.DeveloperName, Impiego__c, Outstanding_CED__c, Importo_Finanziabile__c, Data_ultima_cessione__c, Anagrafica__c
                                                FROM WGC_Posizione__c 
                                                WHERE Anagrafica__c =: accountId ];

            Decimal impiego = 0;
            Decimal outstanding = 0;
            Decimal imp_finanziabile = 0;
            Date lastDate_ultima_cessione = Date.newInstance(1900, 1, 1);
            for(WGC_Linea_Prodotto__c lineaCredito : listLineaResponse){
                impiego = impiego + lineaCredito.Impiego__c;
                outstanding = outstanding + lineaCredito.Outstanding__c;
                imp_finanziabile = imp_finanziabile + lineaCredito.Importo_Finanziabile__c;
                if(lineaCredito.Data_ultima_cessione__c >= lastDate_ultima_cessione){
                    lastDate_ultima_cessione = lineaCredito.Data_ultima_cessione__c;
                }
            }     

            myPosizione.Impiego__c = impiego;
            myPosizione.Outstanding_CED__c = outstanding;
            myPosizione.Importo_Finanziabile__c = imp_finanziabile;
            myPosizione.Data_ultima_cessione__c = lastDate_ultima_cessione;

            System.debug('SV Map myPosizione Update: ' + myPosizione);
            upsert myPosizione;


        }

        result.data.add(test);
        return result;
    }

    @AuraEnabled
    public static WrapperProdotti getAllProducts(String accountId){

        //Query per multi-legal entity
        List<Account> a = [SELECT Id, Name, NDGGruppo__c, CodiceIstituto3N__c FROM Account WHERE Id =: accountId LIMIT 1];
        System.debug('@@@ Account '+a);
        Set<Id> accId = new Set<Id>();
        List<Account> listaAccountMulti = new List<Account>();

        if(!a.isEmpty()){
            listaAccountMulti = WGC_LegalEntity_Utility.getLinkLegalEntity(a.get(0).NDGGruppo__c, a.get(0).CodiceIstituto3N__c);
            System.debug('@@@ listaAccountMulti ' + listaAccountMulti);
            if(listaAccountMulti != null){
                if(!listaAccountMulti.isEmpty()){
                    for(Account item : listaAccountMulti){
                        accId.add(item.Id);
                    }
                    System.debug('@@@ set Acc Id ' + accId);
                } 
            } else {
                accId.add(accountId);
            }
            
        }

        //Istanzio una lista per ogni record type di WGC_Linea_Prodotto__c, duplicate per le due legal entity
        //Legal Entity Italia
        List<WGC_Linea_Prodotto__c> listaProdFactoringCedente = new List<WGC_Linea_Prodotto__c>();
        List<WGC_Linea_Prodotto__c> listaProdFactoringDebitore = new List<WGC_Linea_Prodotto__c>();
        List<WGC_Linea_Prodotto__c> listaProdFinanziamenti = new List<WGC_Linea_Prodotto__c>();
        List<WGC_Linea_Prodotto__c> listaProdLeasing = new List<WGC_Linea_Prodotto__c>();
        List<WGC_Linea_Prodotto__c> listaProdAltro = new List<WGC_Linea_Prodotto__c>();
        List<WGC_Linea_Prodotto__c> listaProdCorporateEstero = new List<WGC_Linea_Prodotto__c>();

        //Query per ogni tipo di prodotto
        System.debug('@@@ accountId '+accId);
        
        if(accId != null){
            //FPALUMBO aggiunta logica per FACTORINGFISCALE (24/02/2020)
            listaProdFactoringCedente = [SELECT Id, Name, Numero_Commessa__c, Tipologia_Prodotto__c, Descrizione_Imposta__c, Codice_Origine__c, Tipo_Operazione__c, Valore_Nominale_cer__c, Valore_nominale_esigibile__c, DIP__c, Prezzo_di_acquisto_cer__c, RecordType.Name, RecordType.DeveloperName, Anagrafica__c, Anagrafica__r.CodiceIstituto3N__c, Descrizione_frm__c, toLabel(Divisa__c), Accordato__c, Data_Attivazione_frm__c, Data_Estinzione_frm__c, Data_ultima_cessione__c, MDI_12_Mesi__c, Impiego_12_Mesi__c, Data_Scadenza__c, Importo_Finanziabile__c, Stato__c, LastModifiedDate FROM WGC_Linea_Prodotto__c WHERE Anagrafica__c IN : accId AND (RecordType.DeveloperName = 'FACTORINGCEDENTE' OR RecordType.DeveloperName = 'FACTORINGFISCALE') ORDER BY Ordinamento__c];
            listaProdFactoringDebitore = [SELECT Id, Name, RecordType.Name, RecordType.DeveloperName, Anagrafica__c, Anagrafica__r.CodiceIstituto3N__c, Descrizione_frm__c, toLabel(Divisa__c), Accordato__c, Data_Attivazione_frm__c, Data_Estinzione_frm__c, Data_ultima_cessione__c, MDI_12_Mesi__c, Impiego_12_Mesi__c, Data_Scadenza__c, Importo_Finanziabile__c, Stato__c, Plafond_Debitore__c  FROM WGC_Linea_Prodotto__c WHERE Anagrafica__c IN : accId AND RecordType.DeveloperName = 'FACTORINGDEBITORE' ORDER BY Ordinamento__c];
            listaProdFinanziamenti = [SELECT Id, Name, RecordType.Name, RecordType.DeveloperName, Anagrafica__c, Anagrafica__r.CodiceIstituto3N__c, Descrizione_frm__c, toLabel(Divisa__c), Accordato__c, Data_Attivazione_frm__c, Data_Estinzione_frm__c, Data_ultima_cessione__c, MDI_12_Mesi__c, Impiego_12_Mesi__c, Data_Scadenza__c, Importo_Finanziabile__c, Stato__c  FROM WGC_Linea_Prodotto__c WHERE Anagrafica__c IN : accId AND RecordType.DeveloperName = 'FINANZIAMENTI' ORDER BY Ordinamento__c];
            listaProdLeasing = [SELECT Id, Name, RecordType.Name, RecordType.DeveloperName, Anagrafica__c, Anagrafica__r.CodiceIstituto3N__c, Descrizione_frm__c, toLabel(Divisa__c), Accordato__c, Data_Attivazione_frm__c, Data_Estinzione_frm__c, Data_ultima_cessione__c, MDI_12_Mesi__c, Impiego_12_Mesi__c, Data_Scadenza__c, Importo_Finanziabile__c, Stato__c  FROM WGC_Linea_Prodotto__c WHERE Anagrafica__c IN : accId AND RecordType.DeveloperName = 'LEASING' ORDER BY Ordinamento__c];
            //FPALUMBO aggiunta logica per CREDITIERARIALI (24/02/2020)
            listaProdAltro = [SELECT Id, Name, Numero_Commessa__c, Tipologia_Prodotto__c, Descrizione_Imposta__c, Codice_Origine__c, Tipo_Operazione__c, Valore_Nominale_cer__c, Valore_nominale_esigibile__c, DIP__c, Prezzo_di_acquisto_cer__c, RecordType.Name, RecordType.DeveloperName, Anagrafica__c, Anagrafica__r.CodiceIstituto3N__c, Descrizione_frm__c, toLabel(Divisa__c), Accordato__c, Data_Attivazione_frm__c, Data_Estinzione_frm__c, Data_ultima_cessione__c, MDI_12_Mesi__c, Impiego_12_Mesi__c, Impiego__c, Data_Scadenza__c, Importo_Finanziabile__c, Stato__c  FROM WGC_Linea_Prodotto__c WHERE Anagrafica__c IN : accId AND (RecordType.DeveloperName = 'NPL' OR RecordType.DeveloperName = 'GARANZIE' OR RecordType.DeveloperName = 'SERVIZIBANCARI' OR  RecordType.DeveloperName = 'CREDITIDIFIRMA' OR RecordType.DeveloperName = 'CREDITIPROBLEMATICI' OR RecordType.DeveloperName = 'CREDITIERARIALI' OR RecordType.DeveloperName = 'Portafoglio_Commerciale' OR RecordType.DeveloperName = 'Anticipo_Fatture') ORDER BY Ordinamento__c];
            listaProdCorporateEstero = [SELECT Id, Name, RecordType.Name, RecordType.DeveloperName, Anagrafica__c, Anagrafica__r.CodiceIstituto3N__c, Descrizione_frm__c, toLabel(Divisa__c), Accordato__c, Data_Attivazione_frm__c, Data_Estinzione_frm__c, Data_ultima_cessione__c, MDI_12_Mesi__c, Impiego_12_Mesi__c, Data_Scadenza__c, Importo_Finanziabile__c, Stato__c,Importo_stipulato_originariamente__c  FROM WGC_Linea_Prodotto__c WHERE Anagrafica__c IN : accId AND RecordType.DeveloperName = 'Corporate_Estero' ORDER BY Ordinamento__c];
        }
        else{
            //FPALUMBO aggiunta logica per FACTORINGFISCALE (24/02/2020)
            listaProdFactoringCedente = [SELECT Id, Name, Numero_Commessa__c, Tipologia_Prodotto__c, Descrizione_Imposta__c, Codice_Origine__c, Tipo_Operazione__c, Valore_Nominale_cer__c, Valore_nominale_esigibile__c, DIP__c, Prezzo_di_acquisto_cer__c, RecordType.Name, RecordType.DeveloperName,Anagrafica__c, Anagrafica__r.CodiceIstituto3N__c, Descrizione_frm__c, toLabel(Divisa__c), Accordato__c, Data_Attivazione_frm__c, Data_Estinzione_frm__c, Data_ultima_cessione__c, MDI_12_Mesi__c, Impiego_12_Mesi__c, Data_Scadenza__c, Importo_Finanziabile__c, Stato__c  FROM WGC_Linea_Prodotto__c WHERE Anagrafica__c =: accountId AND (RecordType.DeveloperName = 'FACTORINGCEDENTE' OR RecordType.DeveloperName = 'FACTORINGFISCALE') ORDER BY Ordinamento__c];
            listaProdFactoringDebitore = [SELECT Id, Name, RecordType.Name, RecordType.DeveloperName, Anagrafica__c, Anagrafica__r.CodiceIstituto3N__c, Descrizione_frm__c, toLabel(Divisa__c), Accordato__c, Data_Attivazione_frm__c, Data_Estinzione_frm__c, Data_ultima_cessione__c, MDI_12_Mesi__c, Impiego_12_Mesi__c, Data_Scadenza__c, Importo_Finanziabile__c, Stato__c, Plafond_Debitore__c  FROM WGC_Linea_Prodotto__c WHERE Anagrafica__c =: accountId AND RecordType.DeveloperName = 'FACTORINGDEBITORE' ORDER BY Ordinamento__c];
            listaProdFinanziamenti = [SELECT Id, Name, RecordType.Name, RecordType.DeveloperName, Anagrafica__c, Anagrafica__r.CodiceIstituto3N__c, Descrizione_frm__c, toLabel(Divisa__c), Accordato__c, Data_Attivazione_frm__c, Data_Estinzione_frm__c, Data_ultima_cessione__c, MDI_12_Mesi__c, Impiego_12_Mesi__c, Data_Scadenza__c, Importo_Finanziabile__c, Stato__c  FROM WGC_Linea_Prodotto__c WHERE Anagrafica__c =: accountId AND RecordType.DeveloperName = 'FINANZIAMENTI' ORDER BY Ordinamento__c];
            listaProdLeasing = [SELECT Id, Name, RecordType.Name, RecordType.DeveloperName, Anagrafica__c, Anagrafica__r.CodiceIstituto3N__c, Descrizione_frm__c, toLabel(Divisa__c), Accordato__c, Data_Attivazione_frm__c, Data_Estinzione_frm__c, Data_ultima_cessione__c, MDI_12_Mesi__c, Impiego_12_Mesi__c, Data_Scadenza__c, Importo_Finanziabile__c, Stato__c  FROM WGC_Linea_Prodotto__c WHERE Anagrafica__c =: accountId AND RecordType.DeveloperName = 'LEASING' ORDER BY Ordinamento__c];
            //FPALUMBO aggiunta logica per CREDITIERARIALI (24/02/2020)
            listaProdAltro = [SELECT Id, Name, Numero_Commessa__c, Tipologia_Prodotto__c, Descrizione_Imposta__c, Codice_Origine__c, Tipo_Operazione__c, Valore_Nominale_cer__c, Valore_nominale_esigibile__c, DIP__c, Prezzo_di_acquisto_cer__c, RecordType.Name, RecordType.DeveloperName, Anagrafica__c, Anagrafica__r.CodiceIstituto3N__c, Descrizione_frm__c, toLabel(Divisa__c), Accordato__c, Data_Attivazione_frm__c, Data_Estinzione_frm__c, Data_ultima_cessione__c, MDI_12_Mesi__c, Impiego_12_Mesi__c, Impiego__c, Data_Scadenza__c, Importo_Finanziabile__c, Stato__c  FROM WGC_Linea_Prodotto__c WHERE Anagrafica__c =: accountId AND (RecordType.DeveloperName = 'NPL' OR RecordType.DeveloperName = 'GARANZIE' OR RecordType.DeveloperName = 'SERVIZIBANCARI' OR  RecordType.DeveloperName = 'CREDITIDIFIRMA' OR RecordType.DeveloperName = 'CREDITIPROBLEMATICI' OR RecordType.DeveloperName = 'CREDITIERARIALI' OR RecordType.DeveloperName = 'Portafoglio_Commerciale' OR RecordType.DeveloperName = 'Anticipo_Fatture') ORDER BY Ordinamento__c];
        	listaProdCorporateEstero = [SELECT Id, Name, RecordType.Name, RecordType.DeveloperName, Anagrafica__c, Anagrafica__r.CodiceIstituto3N__c, Descrizione_frm__c, toLabel(Divisa__c), Accordato__c, Data_Attivazione_frm__c, Data_Estinzione_frm__c, Data_ultima_cessione__c, MDI_12_Mesi__c, Impiego_12_Mesi__c, Data_Scadenza__c, Importo_Finanziabile__c, Stato__c  FROM WGC_Linea_Prodotto__c WHERE Anagrafica__c =: accountId AND RecordType.DeveloperName = 'Corporate_Estero' ORDER BY Ordinamento__c];
        }
		
       

        //Creo il wrapper
        WrapperProdotti prodotti = new WrapperProdotti();

        List<Prod> prodFactoringCedente = creaWrapperProd(listaProdFactoringCedente);

        List<Prod> prodFactoringDebitore = creaWrapperProd(listaProdFactoringDebitore);

        List<Prod> prodFinanziamenti = creaWrapperProd(listaProdFinanziamenti);

        List<Prod> prodLeasing = creaWrapperProd(listaProdLeasing);

        List<Prod> prodAltro = creaWrapperProd(listaProdAltro);
        
        List<Prod> prodCorporateEstero = creaWrapperProd(listaProdCorporateEstero);

        prodotti.factoringCedente = prodFactoringCedente;
        prodotti.factoringDebitore = prodFactoringDebitore;
        prodotti.finanziamenti = prodFinanziamenti;
        prodotti.leasing = prodLeasing;
        prodotti.altro = prodAltro;
        prodotti.corporateEstero = prodCorporateEstero;

        System.debug('@@@ prodotti wrapper ' + JSON.serialize(prodotti));

        if(prodotti.factoringCedente != null || prodotti.factoringDebitore != null || 
            prodotti.finanziamenti != null || prodotti.leasing != null || prodotti.altro != null || prodotti.corporateEstero != null){

            prodotti.success = true;
            prodotti.message = 'Prodotti trovati';
            return prodotti;
        }
        else{
            prodotti.success = false;
            prodotti.message = 'L\'anagrafica non possiede prodotti associati';
            return prodotti;
        }

    }

    @AuraEnabled
    public static WrapperProdotti getFacCedente(String accountId){
        System.debug('SV accountId: ' + accountId);
        WrapperResponse result = new WrapperResponse();

        //Query per multi-legal entity
        List<Account> a = [SELECT Id, Name, NDGGruppo__c, CodiceIstituto3N__c FROM Account WHERE Id =: accountId LIMIT 1];
        System.debug('@@@ Account '+a);
        Set<Id> accId = new Set<Id>();
        List<Account> listaAccountMulti = new List<Account>();

        if(!a.isEmpty()){
            listaAccountMulti = WGC_LegalEntity_Utility.getLinkLegalEntity(a.get(0).NDGGruppo__c, a.get(0).CodiceIstituto3N__c);
            System.debug('@@@ listaAccountMulti ' + listaAccountMulti);
            if(listaAccountMulti != null){
                if(!listaAccountMulti.isEmpty()){
                    for(Account item : listaAccountMulti){
                        accId.add(item.Id);
                    }
                    System.debug('@@@ set Acc Id ' + accId);
                } 
            } else {
                accId.add(accountId);
            }
            
        }

        List<WGC_Linea_Prodotto__c> listaProdFactoringCedente = new List<WGC_Linea_Prodotto__c>();

        //Query per ogni tipo di prodotto
        System.debug('@@@ accountId '+accId);
        if(accId != null){
            //FPALUMBO aggiunta logica per FACTORINGFISCALE (24/02/2020)
            listaProdFactoringCedente = [SELECT Id, Name, Numero_Commessa__c, Tipologia_Prodotto__c, Descrizione_Imposta__c, Codice_Origine__c, Tipo_Operazione__c, Valore_Nominale_cer__c, Prezzo_di_acquisto_cer__c, RecordType.Name, RecordType.DeveloperName, Anagrafica__c, Anagrafica__r.CodiceIstituto3N__c, Descrizione_frm__c, toLabel(Divisa__c), Accordato__c, Data_Attivazione_frm__c, Data_Estinzione_frm__c, Data_ultima_cessione__c, Importo_Ultima_Cessione__c, Data_Scadenza__c, Importo_Finanziabile__c, Stato__c, LastModifiedDate FROM WGC_Linea_Prodotto__c WHERE Anagrafica__c IN : accId AND (RecordType.DeveloperName = 'FACTORINGCEDENTE' OR RecordType.DeveloperName = 'FACTORINGFISCALE') ORDER BY Ordinamento__c];
        } else {
            //FPALUMBO aggiunta logica per FACTORINGFISCALE (24/02/2020)
            listaProdFactoringCedente = [SELECT Id, Name, Numero_Commessa__c, Tipologia_Prodotto__c, Descrizione_Imposta__c, Codice_Origine__c, Tipo_Operazione__c, Valore_Nominale_cer__c, Prezzo_di_acquisto_cer__c, RecordType.Name, RecordType.DeveloperName,Anagrafica__c, Anagrafica__r.CodiceIstituto3N__c, Descrizione_frm__c, toLabel(Divisa__c), Accordato__c, Data_Attivazione_frm__c, Data_Estinzione_frm__c, Data_ultima_cessione__c, Importo_Ultima_Cessione__c, Data_Scadenza__c, Importo_Finanziabile__c, Stato__c  FROM WGC_Linea_Prodotto__c WHERE Anagrafica__c =: accountId AND (RecordType.DeveloperName = 'FACTORINGCEDENTE' OR RecordType.DeveloperName = 'FACTORINGFISCALE') ORDER BY Ordinamento__c];
        }
       
       //Creo il wrapper
        WrapperProdotti prodotti = new WrapperProdotti();

        List<Prod> prodFactoringCedente = creaWrapperProd(listaProdFactoringCedente);
        prodotti.factoringCedente = prodFactoringCedente;
        
        if(prodotti.factoringCedente != null){

            prodotti.success = true;
            prodotti.message = 'Prodotti trovati';
        }
        else{
            prodotti.success = false;
            prodotti.message = 'L\'anagrafica non possiede prodotti associati';
        }

        
        return prodotti;

    }

    @TestVisible
    private static List<Prod> creaWrapperProd(List<WGC_Linea_Prodotto__c> listaProd){

        List<Prod> listaWrapProdotto = new List<Prod>();

        for(WGC_Linea_Prodotto__c item : listaProd){
            Prod singleProd = new Prod();
            singleProd.prodotto = item;
            singleProd.codiceIstituto = item.Anagrafica__r.CodiceIstituto3N__c;
            listaWrapProdotto.add(singleProd);
        }

        return listaWrapProdotto;
    }

    public class WrapperProdotti{

        @AuraEnabled
        public List<Prod> factoringCedente;
        @AuraEnabled
        public List<Prod> factoringDebitore;
        @AuraEnabled
        public List<Prod> finanziamenti;
        @AuraEnabled
        public List<Prod> leasing;
        @AuraEnabled
        public List<Prod> altro;
        @AuraEnabled
        public List<Prod> corporateEstero;

        @AuraEnabled
        public String message;
        @AuraEnabled
        public Boolean success;

        public WrapperProdotti(){
            this.factoringCedente = new List<Prod>();
            this.factoringDebitore = new List<Prod>();
            this.finanziamenti = new List<Prod>();
            this.leasing = new List<Prod>();
            this.altro = new List<Prod>();
            this.corporateEstero = new List<Prod>();

            this.message = message;
            this.success = success;
        }
    }

    public class Prod{
        @AuraEnabled
        public WGC_Linea_Prodotto__c prodotto;
        @AuraEnabled
        public String codiceIstituto;

        public Prod(){
            this.prodotto = prodotto;
            this.codiceIstituto = codiceIstituto;
        }
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
        @AuraEnabled public String msg;
        @AuraEnabled public List<Object> data;
        
        public WrapperResponse(){
            success = true;
            msg = '';
            data = new List<Object>();
        }
    }
}