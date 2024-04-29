public without sharing class TXT_CalloutHandler {

    public TXT_CalloutHandler() {
    }

    public static List<String> TXT_CustomSettings() {
        List<String> CSettings = new List<String>();
        EndpointServizi__c endpoints = EndpointServizi__c.getInstance();
        CSettings.add(endpoints.TXT_BusinessInformation__c);
        CSettings.add(endpoints.TXT_EventiNegativi__c);

        UtenzeDefault__c credentials = UtenzeDefault__c.getInstance();
        CSettings.add(credentials.TXT_Innolva_EndPoint_User__c);
        CSettings.add(credentials.TXT_Innolva_EndPoint_Password__c);

        return CSettings;
    }

    // public static Log__c TXT_Logs(String Input, String OutPut, String Error) {
    //     Log__c singleLog = new Log__c();
    //     singleLog.ErrorMessage__c = Error;
    //     singleLog.InputPayload__c = Input;
    //     singleLog.OutputPayload__c = OutPut;
    //     singleLog.Success__c = false;
    //     return singleLog;
    // }

    public static Log__c TXT_Logs(String Input, String OutPut, String Error, String cciaarea, String accountJSON) {
        Log__c singleLog = new Log__c();
        singleLog.ErrorMessage__c = Error;
        singleLog.InputPayload__c = Input;
        singleLog.OutputPayload__c = OutPut;
        singleLog.Success__c = false;
        singleLog.DuplicateCCIAAREA__c = cciaarea;
        singleLog.Account_JSON__c = accountJSON;
        return singleLog;
    }

    public static Log__c TXT_Logs_Ricerca(String Input, String OutPut, String Error, String searchedParameter, String ricercaJSON) {
        Log__c singleLog = new Log__c();
        singleLog.ErrorMessage__c = Error;
        singleLog.InputPayload__c = Input;
        singleLog.OutputPayload__c = OutPut;
        singleLog.Success__c = false;
        singleLog.Duplicate_Ricerca__c = searchedParameter;
        singleLog.Ricerca_JSON__c = ricercaJSON;
        return singleLog;
    }

    /*
    @AuraEnabled(cacheable=true)
    public static List<Account> executeCallMock(Integer searchType, String searchedParameter){
        List<Account> response = new List<Account>();
        //Mock della risposta provvisoria
        Account newAccount = new Account();
        //newaccount.Name = 'NewAccount';
        //newaccount.CCIAA_CMK__c = '1234567890';
        //newaccount.CCIAA_REA__c = '1234567890';
        newaccount.denosociale__c = 'New Account';
        newaccount.Partita_iva__c = '1234567890';
        newaccount.Codice_fiscale__c = '1234567890';
        newaccount.BillingStreet = 'Via Test';
        newaccount.BillingState = 'TS';


        newaccount.BillingPostalCode = '12345';

        newaccount.BillingCountry = 'Paese Test';
        newaccount.BillingCity = 'Citta Test';
        newaccount.Forma_giuridica__c = 'PERSONA FISICA';

        newaccount.Data_Bilancio__c = System.TODAY();
        newaccount.Acquisti_totali__c = 10;
        newAccount.Data_di_cessazione__c = System.TODAY();
        newaccount.Anno_rilevazione_addetti__c = '2020';
        newaccount.Data_Inizio_Attivita__c = System.TODAY();
        newAccount.AnnualRevenue = 20000;
        newAccount.Livello_attenzione_negativita__c = 'Alto';
        newAccount.Capitale_Sociale__c = 20000;
        newAccount.Crediti_vs_Clienti__c = 2000;
        newaccount.Risultato_Operativo_Lordo__c = 2000;
        newAccount.Phone_Warrant__c = '123456789';
        newAccount.Totale_Patrimonio_Netto_Tinexta__c = 20000;
        newAccount.Fax = '12345679';
        newAccount.Utile_Perdita__c = 20000;
        newAccount.Stato_Attivita__c = 'Attiva';
        newaccount.Fatturato__c = '1. Fino a 1 milione di Euro';
        newAccount.Rating__c = '1';
        newaccount.Dipendenti__c = '1-9';
        newAccount.Codice_Ateco_Innolva__c = '12345';
        newAccount.Descrizione_Ateco_Innolva__c = 'Descrizione';

        response.add(newAccount);
        return response;
    }*/

    //SearchType:  1= Denominazione, 2=CF, 3=P.IVA
    @AuraEnabled
    public static List<Account> executeCall(Integer searchType, String searchedParameter, String siglaEstera){
        List<Log__c> logsToInsert = new List<Log__c>();
        List<String> CSettings = TXT_CustomSettings();
        List<Account> response = new List<Account>();

        Boolean estera = false;
        if(siglaEstera == 'IT'){
            estera = false;
        }else{
            estera = true;
        }

        siglaEstera = siglaEstera.toUpperCase();
        String searchedParameterLog = searchedParameter+siglaEstera;
        List<Log__c> existingLogs = new List<Log__c>([SELECT Id, Ricerca_JSON__c FROM Log__c WHERE Duplicate_Ricerca__c =: searchedParameterLog AND CreatedDate = TODAY]);
        if(!existingLogs.isEmpty()) {
            if(existingLogs[0].Ricerca_JSON__c != null) {
                try {
                    response = (List<Account>)JSON.deserializeStrict(existingLogs[0].Ricerca_JSON__c, List<Account>.Class);
                } catch (Exception e) {
                    System.debug('@@@ recupero log error ' + e.getStackTraceString());
                }
                // return response;
            }
        }

        // boolean estera;
        // if(siglaEstera == 'IT'){
        //     estera = false;
        // }else{
        //     estera = true;
        // }
        //Fine mock

        if(response != null && response.isEmpty()) {
            //Fine mock
            HttpRequest req = new HttpRequest();
            req.setEndpoint(CSettings[0]);
            req.setMethod('POST');
            req.setHeader('Content-Type', 'text/xml;charset=UTF-8');
            req.setTimeout(120000);
            Dom.Document doc = new Dom.Document();
            String denominazione ='';
            String codiceFiscale = '';
            if(searchType == 1){
                denominazione = searchedParameter;
            }else if (searchType == 2){
                codiceFiscale = searchedParameter;
            }
            String inputxml = '';
            //String inputxml = '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:bin="urn:ws.ribes.it/BInformationV4"><soapenv:Header/><soapenv:Body><bin:getProdottoPG><bin:accountName>TINEXTA-WS</bin:accountName><bin:accountPassword>pwdcollaudo</bin:accountPassword><bin:userID>TINEXTA-WS</bin:userID><bin:codiceProdotto>BIWKR</bin:codiceProdotto><bin:tipo>PRD</bin:tipo><bin:formato>XML</bin:formato><bin:tipoRichiesta>RP</bin:tipoRichiesta><bin:codiceFiscale>11142780151</bin:codiceFiscale><bin:tipoMonitoraggio></bin:tipoMonitoraggio><bin:tipoRinnovo></bin:tipoRinnovo><bin:codiceAnagraficaCliente/><bin:idBicLista/><bin:riferimento/><bin:elencoInfo><info nome="?"/></bin:elencoInfo></bin:getProdottoPG></soapenv:Body></soapenv:Envelope>'; doc.load(inputxml);
            if(estera == false){
                denominazione = denominazione.replaceAll('&', 'ampersand');
                inputxml = '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:bin="urn:ws.ribes.it/BInformationV4"><soapenv:Header/>'+
                    '<soapenv:Body>'+
                    '<bin:getListaAziende>'+
                        '<bin:accountName>'+CSettings[2]+'</bin:accountName>'+
                        '<bin:accountPassword>'+CSettings[3]+'</bin:accountPassword>'+
                        '<bin:userID>'+CSettings[2]+'</bin:userID>'+
                        '<bin:codiceProdotto>BICLISAZR</bin:codiceProdotto>'+
                        '<bin:tipo>PRD</bin:tipo><bin:formato>XML</bin:formato>'+
                        '<bin:tipoRichiesta>RP</bin:tipoRichiesta>'+
                        '<bin:denominazione>'+denominazione+'</bin:denominazione>'+
                        '<bin:codiceFiscale>'+codiceFiscale+'</bin:codiceFiscale>'+
                        '<bin:cciaa></bin:cciaa>'+
                        '<bin:tipoMonitoraggio></bin:tipoMonitoraggio>'+
                        '<bin:tipoRinnovo></bin:tipoRinnovo>'+
                        '<bin:codiceAnagraficaCliente/>'+
                        '<bin:idBicLista/>'+
                        '<bin:riferimento/>'+
                        '<bin:elencoInfo>'+
                            '<info nome="?"/>'+
                        '</bin:elencoInfo>'+
                        '</bin:getListaAziende>'+
                    '</soapenv:Body>'+
                '</soapenv:Envelope>'; 
                doc.load(inputxml);
            }else if( estera == true){
                searchedParameter = searchedParameter.replaceAll('&', 'ampersand');
                inputxml = '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:bin="urn:ws.ribes.it/BInformationV4">'+
                '<soapenv:Header/>'+
                '<soapenv:Body>'+
                    '<bin:getListaAziendeEstero>'+
                        '<bin:accountName>'+CSettings[2]+'</bin:accountName>'+
                        '<bin:accountPassword>'+CSettings[3]+'</bin:accountPassword>'+
                        '<bin:userID>'+CSettings[2]+'</bin:userID>'+
                        '<bin:codiceProdotto>BICLISEST</bin:codiceProdotto>'+
                        '<bin:tipo>PRD</bin:tipo>'+
                        '<bin:formato>XML</bin:formato>'+
                        '<!--Optional:-->'+
                        '<bin:idRibes/>'+
                        '<!--Optional:-->'+
                        '<bin:idNazione>' + siglaEstera.toUpperCase() + '</bin:idNazione>'+ //
                        '<!--Optional:-->'+
                        '<bin:denominazione>' +searchedParameter +'</bin:denominazione>'+ //AMAZON FR LOGISTIQUE
                        '<!--Optional:-->'+
                        '<bin:citta></bin:citta>'+
                        '<!--Optional:-->'+
                        '<bin:regione/>'+
                        '<!--Optional:-->'+
                        '<bin:numeroRegistrazione/>'+
                        '<!--Optional:-->'+
                        '<bin:codiceAnagraficaCliente/>'+
                        '<!--Optional:-->'+
                        '<bin:riferimento/>'+
                    '</bin:getListaAziendeEstero>'+
                '</soapenv:Body>'+
            '</soapenv:Envelope>'; 
                doc.load(inputxml);
            }

            // req.setHeader('SOAPAction', '"urn:getListaAziende"');
            req.setBodyDocument(doc);
            Http http = new Http();
            HTTPResponse res = http.send(req);
            System.debug('@@@ localtion ' + res.getHeader('Location'));
            String output;

            if(res.getStatusCode() == 200){
                Dom.Document responseDoc = res.getBodyDocument();
                Dom.XMLNode root = responseDoc.getRootElement();

                String nameSpace='http://schemas.xmlsoap.org/soap/envelope/';
                String namespace2 = 'urn:ws.ribes.it/BInformationV4';


                Dom.XMLNode risposta;
                Dom.XMLNode elencoImprese;
                System.debug('XML: ' + res.getBody());
                try{
                    if(estera==true){
                        risposta = root.getChildElement('Body',namespace).getChildElement('getListaAziendeEsteroResponse',namespace2).getChildElement('return',namespace2).getChildElement('WSRBS',null).getChildElement('TRANSAZIONE',null).getChildElement('RISPOSTA',null);
                        try{
                            elencoImprese = risposta.getChildElement('Prodotto',null).getChildElement('Lista',null).getChildElement('Imprese',null);
                        }catch(Exception e){
                            risposta = null;
                            System.debug('Nessun Risultato / Errore XML');
                        }
                    }else{
                        risposta = root.getChildElement('Body',namespace).getChildElement('getListaAziendeResponse',namespace2).getChildElement('return',namespace2).getChildElement('WSRBS',null).getChildElement('TRANSAZIONE',null).getChildElement('RISPOSTA',null);
                        try{
                            elencoImprese = risposta.getChildElement('Prodotto',null).getChildElement('Lista',null).getChildElement('ElencoImprese',null);
                        }catch(Exception e){
                            risposta = null;
                            System.debug('Nessun Risultato / Errore XML');
                        }
                    }


                    System.debug('RISPOSTA: ' + risposta);
                    if(risposta != null){
                        System.debug('Elenco imprese ' + elencoImprese.getName());
                        if(elencoImprese != null){
                            for(Dom.XMLNode impresa : elencoImprese.getChildElements()){
                                Account acct = new Account();
                                acct.Stato_Attivita__c = '';
                                if(estera == true){
                                    acct = createAccountEstero(impresa);
                                    if(acct.BillingCity == null){
                                        acct.BillingCity = '';
                                    }
                                    if(acct.BillingState == null){
                                        acct.BillingState = '';
                                    }
                                    if(acct.BillingStreet == null){
                                        acct.BillingStreet = '';
                                    }
                                    // if(acct.BillingCity == null || acct.BillingState == null || acct.BillingStreet == null){
                                    //     acct.BillingCity = '';
                                    //     acct.BillingState = '';
                                    //     acct.BillingStreet = '';
                                    // }
                                    response.add(acct);
                                }else{

                                    System.debug('Elenco impresa ' + impresa.getName());
                                    try{
                                        if(impresa.getChildElement('InfoImpresa',null).getChildElement('NaturaGiuridica',null) != null){
                                            acct.Forma_giuridica__c = impresa.getChildElement('InfoImpresa',null).getChildElement('NaturaGiuridica',null).getText();
                                            System.debug('Forma Giuridica: '+acct.Forma_giuridica__c);
                                        }
                                    }catch(Exception e){
                                        System.debug('GPF exception ' + e.getMessage() +' '+e.getLineNumber());
                                    }
                                    
                                    try{
                                        if(risposta.getChildElement('Prodotto',null).getChildElement('ReportXML',null).getChildElement('Dati',null).getChildElement('DatiCameraliImpresa',null) != null){
                                            try{
                                                Dom.XMLNode infoSede = risposta.getChildElement('Prodotto',null).getChildElement('ReportXML',null).getChildElement('Dati',null).getChildElement('DatiCameraliImpresa',null).getChildElement('InfoSede',null);
                                                acct.Partita_iva__c = infoSede.getChildElement('PartitaIva',null).getText();
                                                System.debug('Partita_iva ' + acct.Partita_iva__c);
                                            }catch(Exception e){
                                                System.debug('GPF exception ' + e.getMessage() +' '+e.getLineNumber());
                                            }
                                        }

                                    }catch(Exception e){
                                        System.debug('GPF exception ' + e.getMessage() +' '+e.getLineNumber());
                                    }

                                    if( impresa.getChildElement('InfoImpresa',null).getChildElement('KRea',null) == null ){
                                        if(searchType == 1){
                                            codiceFiscale = impresa.getChildElement('InfoImpresa',null).getChildElement('CodiceFiscale',null).getText();
                                        }
                                        denominazione = impresa.getChildElement('InfoImpresa',null).getChildElement('Denominazione',null).getText();
                                        // response.addall(executeCallNegative(denominazione, codiceFiscale));
                                        response.add(createAccountXML_noREA(impresa, searchType, codiceFiscale));
                                    }else{
                                        acct = createAccountXML(impresa, searchType, codiceFiscale);
                                        if(acct.BillingCity == null || acct.BillingState == null || acct.BillingStreet == null){
                                            acct.BillingCity = '';
                                            acct.BillingState = '';
                                            acct.BillingStreet = '';
                                        }
                                        response.add(acct);
                                    }

                                    
                                }
                                
                            }
                            output = res.getBody().length() > 131072 ? res.getBody().substring(0,131072) : res.getBody().substring(0,res.getBody().length()-1);
                            logsToInsert.add(TXT_Logs_Ricerca(inputxml, output, res.getStatus(), searchedParameter+siglaEstera, JSON.serialize(response)));

                        }else{
                            response = null;
                            output = res.getBody().length() > 131072 ? res.getBody().substring(0,131072) : res.getBody().substring(0,res.getBody().length()-1);
                            logsToInsert.add(TXT_Logs_Ricerca(inputxml, output, 'Errore o XML incompleto', searchedParameter+siglaEstera, JSON.serialize(response)));
                        }
                    }else{
                        response = null;
                        output = res.getBody().length() > 131072 ? res.getBody().substring(0,131072) : res.getBody().substring(0,res.getBody().length()-1);
                        logsToInsert.add(TXT_Logs_Ricerca(inputxml, output, 'Errore o XML incompleto', searchedParameter+siglaEstera, JSON.serialize(response)));
                    }
                }catch(Exception e){
                    response = null;
                    System.debug('Errore: '+e.getMessage()+' Riga: '+e.getLineNumber());
                    output = res.getBody().length() > 131072 ? res.getBody().substring(0,131072) : res.getBody().substring(0,res.getBody().length()-1);
                    logsToInsert.add(TXT_Logs_Ricerca(inputxml, output, e.getMessage()+' Riga: '+e.getLineNumber(), searchedParameter+siglaEstera, JSON.serialize(response)));
                }
                
            }else{
                response = null;
                output = res.getBody().length() > 131072 ? res.getBody().substring(0,131072) : res.getBody().substring(0,res.getBody().length()-1);
                logsToInsert.add(TXT_Logs_Ricerca(inputxml, output, res.getStatus(), searchedParameter+siglaEstera, JSON.serialize(response)));
            }
        }

        if(searchType == 1 && (response != null && response.size()>0)){
            List<Account> innolvaresponse = new List<Account>();
            for(Account crmi :response){
                crmi.Censimento_Manuale__c = false;
                innolvaresponse.add(crmi);
            }
            response = innolvaresponse;
        }

        //if(searchType == 1){ // && (response == null || response.size()<1)){
            
            List<String> pivas = new List<String>();
            List<String> cfs = new List<String>();
            System.debug('RESPONSE XML PRIMA LOOP: '+JSON.serialize(response));
            if(response != null && response.size()>0){
                for(Account r : response){
                    if(r.Partita_iva__c != null)
                        pivas.add(r.Partita_iva__c);
                    if(r.Codice_fiscale__c != null)
                        cfs.add(r.Codice_fiscale__c);
                }
            }

            List<Account> crmresponse = [SELECT Id, Name, CCIAA_REA__c,Forma_giuridica__c,
        denosociale__c, Codice_fiscale__c, Partita_iva__c,
        BillingStreet, BillingCity, BillingState, BillingPostalCode,
        BillingCountry, Data_Bilancio__c, Acquisti_totali__c, Data_di_cessazione__c,
        Anno_rilevazione_addetti__c, Data_Inizio_Attivita__c, AnnualRevenue, 
        Livello_attenzione_negativita__c, Capitale_Sociale__c, Crediti_vs_Clienti__c, 
        Risultato_Operativo_Lordo__c, Phone, Phone_Warrant__c, Totale_Patrimonio_Netto_Tinexta__c,
        Fax, Utile_Perdita__c, Stato_Attivita__c, Fatturato__c, Rating__c, Dipendenti__c, Codice_Ateco_Innolva__c, Descrizione_Ateco_Innolva__c,
        Email_Aziendale_Innolva__c, Data_Ultimo_Arricchimento__c
            FROM Account WHERE (Partita_IVA__c IN: pivas AND Codice_fiscale__c IN: cfs) OR Name LIKE:('%' + searchedParameter.replaceAll(' ', '%') + '%')];
            
            List<Account> sommati = new List<Account>();
            if(response!=null){sommati.addAll(response);}
            if(crmresponse!=null){sommati.addAll(crmresponse);}

            List<Account> tpmresponse = new List<Account>();

            for(integer i=0; i<sommati.size(); i++){
                Boolean esiste = false;
                for(Account crm :crmresponse){
                    if((sommati[i].Partita_iva__c != null && crm.Partita_iva__c != null && sommati[i].Partita_iva__c != '' && crm.Partita_iva__c != '' && sommati[i].Partita_iva__c == crm.Partita_iva__c) || 
                        (sommati[i].Name == crm.Name) || 
                        (sommati[i].Codice_fiscale__c != null && crm.Codice_fiscale__c != null && sommati[i].Codice_fiscale__c != '' && crm.Codice_fiscale__c != '' && sommati[i].Codice_fiscale__c == crm.Codice_fiscale__c)){ 
                        esiste = true;             
                    }
                }
                if(esiste==true){
                    sommati[i].Name = sommati[i].Name + ' #XML';
                }
                tpmresponse.add(sommati[i]);
            }

            
            List<Account> tableresponse = new List<Account>();
            for(Account acclist :tpmresponse){
                if(acclist.Name.indexOf('#XML') !=-1){
                    acclist.Censimento_Manuale__c = false;
                }
                Boolean esiste = false;
                for(Account tacc :tableresponse){

                    if((tacc.Partita_iva__c != null && accList.Partita_Iva__c != null && tacc.Partita_iva__c != '' && accList.Partita_Iva__c != '' && tacc.Partita_iva__c == acclist.Partita_iva__c) || 
                        (tacc.Name == accList.Name) || 
                        (tacc.Codice_fiscale__c != null && accList.Codice_fiscale__c != null && tacc.Codice_fiscale__c != '' && accList.Codice_fiscale__c != '' && tacc.Codice_fiscale__c == accList.Codice_fiscale__c)){ 
                        esiste = true;
                    }
                }
                system.debug('searchedParameter ------ '+ searchedParameter);
                system.debug('accList.name ------ '+accList.name);
                if(esiste==false){
                    system.debug('accList.name.containsIgnoreCase(searchedParameter) '+ accList.name.containsIgnoreCase(searchedParameter));
                    if(accList.Partita_IVA__c == searchedParameter || accList.Codice_fiscale__c == searchedParameter || accList.name.containsIgnoreCase(searchedParameter)) tableresponse.add(acclist);
                }
            }

            response = tableresponse;
            System.debug('@@@ response ' + JSON.serialize(response));
        //}

        try{
            insert logsToInsert;
        }catch(Exception e){
            System.debug('GPF Exception ' + e.getMessage());
        }finally{
            return response;
        }
        
        return response;
    }


    // @AuraEnabled
    // public static List<Account> executeCallNegative(String denominazione, String codiceFiscale){
    //     List<Log__c> logsToInsert = new List<Log__c>();
    //     List<String> CSettings = TXT_CustomSettings();

    //     List<Account> response = new List<Account>();

    //     HttpRequest req = new HttpRequest();
    //     req.setEndpoint(CSettings[1]);
    //     req.setMethod('POST');
    //     req.setHeader('Content-Type', 'text/xml; charset=UTF-8');
    //     req.setTimeout(120000);
    //     Dom.Document doc = new Dom.Document();

    //     //String inputxml = '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:bin="urn:ws.ribes.it/BInformationV4"><soapenv:Header/><soapenv:Body><bin:getProdottoPG><bin:accountName>TINEXTA-WS</bin:accountName><bin:accountPassword>pwdcollaudo</bin:accountPassword><bin:userID>TINEXTA-WS</bin:userID><bin:codiceProdotto>BIWKR</bin:codiceProdotto><bin:tipo>PRD</bin:tipo><bin:formato>XML</bin:formato><bin:tipoRichiesta>RP</bin:tipoRichiesta><bin:codiceFiscale>11142780151</bin:codiceFiscale><bin:tipoMonitoraggio></bin:tipoMonitoraggio><bin:tipoRinnovo></bin:tipoRinnovo><bin:codiceAnagraficaCliente/><bin:idBicLista/><bin:riferimento/><bin:elencoInfo><info nome="?"/></bin:elencoInfo></bin:getProdottoPG></soapenv:Body></soapenv:Envelope>'; doc.load(inputxml);

    //     String inputxml = '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:urn="urn:eventinegativi.wsrbs.ws.ribes.it">'+
    //                 '<soapenv:Header/>'+
    //                 '<soapenv:Body>'+
    //                     '<urn:Richiesta xmlns:urn="urn:eventinegativi.wsrbs.ws.ribes.it">'+
    //                         '<Autenticazione>'+
    //                             '<accountName>'+CSettings[2]+'</accountName>'+
    //                             '<accountPassword>'+CSettings[3]+'</accountPassword>'+
    //                         '</Autenticazione>'+
    //                         '<Servizio>'+
    //                             '<EventiNegativi>'+
    //                                 '<ProdottoAziendeNonIscritte>'+
    //                                     '<userID>'+CSettings[2]+'</userID>'+
    //                                     '<sourceIdRequest/>'+
    //                                     '<codiceProdotto>RGENPNI</codiceProdotto>'+
    //                                     '<tipo>PRD</tipo>'+
    //                                     '<formato>XML</formato>'+
    //                                     '<denominazione>'+ denominazione +'</denominazione>'+
    //                                     '<codiceFiscale>'+ codiceFiscale +'</codiceFiscale>'+
    //                                     '<indirizzi/>'+
    //                                     '<protesti>S</protesti>'+
    //                                     '<pregiudizievoli>S</pregiudizievoli>'+
    //                                     '<cigs>S</cigs>'+
    //                                     '<allarmiQuote>S</allarmiQuote>'+
    //                                     '<tipoMonitoraggio>N</tipoMonitoraggio>'+
    //                                     '<tipoRinnovo/>'+
    //                                 '</ProdottoAziendeNonIscritte>'+
    //                             '</EventiNegativi>'+
    //                         '</Servizio>'+
    //                     '</urn:Richiesta>'+
    //                 '</soapenv:Body>'+
    //             '</soapenv:Envelope>'; doc.load(inputxml);


    //     req.setBodyDocument(doc);
    //     Http http = new Http();
    //     HTTPResponse res = http.send(req);
    //     if(res.getStatusCode() == 200){

    //         Dom.Document responseDoc = res.getBodyDocument();
    //         Dom.XMLNode root = responseDoc.getRootElement();

    //         String nameSpace='http://schemas.xmlsoap.org/soap/envelope/';
    //         String namespace2 = 'urn:eventinegativi.wsrbs.ws.ribes.it';

    //         //Dom.XMLNode richiesta;
    //         Dom.XMLNode risposta;
    //         Dom.XMLNode elencoImprese;
    //         System.debug('XML: ' + res.getBody());

    //         risposta = root.getChildElement('Body',namespace).getChildElement('RichiestaResponse',namespace2).getChildElement('WSRBS',null).getChildElement('TRANSAZIONE',null).getChildElement('RISPOSTA',null);
            
    //         Dom.XMLNode infoimpresa = risposta.getChildElement('Prodotto',null).getChildElement('ReportXML',null).getChildElement('Dati',null).getChildElement('EventiNegativiImpresa',null);

    //         System.debug('RISPOSTA: ' + infoimpresa.getChildElement('InfoImpresa',null).getName());
    //         if(risposta != null){
    //             Account acct;
    //             acct = createAccountXMLNegative(infoimpresa);
    //             acct.Data_di_cessazione__c = null; //Non trovato
    //             acct.BillingCountry = 'ITALIA'; //Non trovato

    //             response.add(acct);
    //         }else{
    //             response = null;
    //             logsToInsert.add(TXT_Logs(inputxml, res.getBody().substring(0,131072), 'Errore o XML incompleto'));
    //         }

            
    //     }else{
    //         response = null;
    //         logsToInsert.add(TXT_Logs(inputxml, res.getBody().substring(0,131072), res.getStatus()));
    //     }

    //     try{
    //         insert logsToInsert;
    //     }catch(Exception e){
    //         System.debug('GPF Exception ' + e.getMessage());
    //     }finally{
    //         return response;
    //     }

    //     return response;
    // }


    // public static Account createAccountXMLNegative(Dom.XMLNode impresa){
    //     Account acct = new Account();
    //     Dom.XMLNode infoImpresa = impresa.getChildElement('InfoImpresa',null);
    //     Dom.XMLNode attivita = impresa.getChildElement('Attivita',null);
    //     try{

    //         if(attivita !=null && attivita.getChildElement('Stato',null) != null){
    //             System.debug('Stato Attivita Impresa: ' + attivita.getChildElement('Stato',null).getText());
    //             acct.Stato_Attivita__c = attivita.getChildElement('Stato',null).getText();
    //         }
    //     }catch(Exception e){
    //         System.debug('GPF exception ' + e.getMessage());
    //     }
    //     try{
    //         if(infoImpresa.getChildElement('Denominazione',null) != null){
    //             System.debug('Impresa: ' + impresa.getChildElement('InfoImpresa',null).getChildElement('Denominazione',null).getText());
    //             String name = infoImpresa.getChildElement('Denominazione',null).getText();
    //             acct.Name = name.length() > 80 ? name.substring(0,80) : name;
    //         }
    //     }catch(Exception e){
    //         System.debug('GPF exception ' + e.getMessage());
    //     }
    //     try{
    //         if(infoImpresa.getChildElement('KRea',null).getChildElement('Cciaa',null) != null){
    //             System.debug('Cciiaa: ' + impresa.getChildElement('InfoImpresa',null).getChildElement('KRea',null).getChildElement('Cciaa',null).getAttribute('sigla',null));
    //             acct.CCIAA_CMK__c = infoImpresa.getChildElement('KRea',null).getChildElement('Cciaa',null).getAttribute('sigla',null);
    //         }
    //     }catch(Exception e){
    //         System.debug('GPF exception ' + e.getMessage());
    //     }
    //     try{
    //         if(infoImpresa.getChildElement('KRea',null).getChildElement('Cciaa',null) != null){
    //             acct.CCIAA_REA__c = infoImpresa.getChildElement('KRea',null).getChildElement('NRea',null).getText();
    //         }
    //     }catch(Exception e){
    //         System.debug('GPF exception ' + e.getMessage());
    //     }
    //     try{
    //         if(infoImpresa.getChildElement('PartitaIva',null) != null){
    //             acct.Partita_iva__c = infoImpresa.getChildElement('PartitaIva',null).getText();
    //             System.debug('Partita_iva ' + acct.Partita_iva__c);
    //         }else{
    //             try{
    //             Dom.XMLNode infoSede = impresa.getChildElement('InfoSede',null);
    //             acct.Partita_iva__c = infoSede.getChildElement('PartitaIva',null).getText();
    //             System.debug('Partita_iva ' + acct.Partita_iva__c);
    //             }catch(Exception e){
    //                 System.debug('GPF exception ' + e.getMessage());
    //             }
    //         }
    //     }catch(Exception e){
    //         System.debug('GPF exception ' + e.getMessage());
    //     }
    //     try{
    //         if(infoImpresa.getChildElement('CodiceFiscale',null) != null){
    //             acct.Codice_fiscale__c = infoImpresa.getChildElement('CodiceFiscale',null).getText();
    //         }
    //     }catch(Exception e){
    //         System.debug('GPF exception ' + e.getMessage());
    //     }
    //     try{
    //         if(infoImpresa.getChildElement('Sede',null).getChildElement('Indirizzo',null) != null){
    //             // System.debug('InfoImpresa: ' + infoImpresa.getChildElement('Sede',null).getChildElement('Indirizzo',null).getAttribute('via',null));
    //             // acct.BillingStreet = infoImpresa.getChildElement('Sede',null).getChildElement('Indirizzo',null).getAttribute('via',null);
    //             String street = infoImpresa.getChildElement('Sede',null).getChildElement('Indirizzo',null).getAttribute('toponimo',null) + ' ' + infoImpresa.getChildElement('Sede',null).getChildElement('Indirizzo',null).getAttribute('via',null) + (infoImpresa.getChildElement('Sede',null).getChildElement('Indirizzo',null).getAttribute('numeroCivico',null) != null ? ', ' + infoImpresa.getChildElement('Sede',null).getChildElement('Indirizzo',null).getAttribute('numeroCivico',null) : '');
    //             acct.BillingStreet = street;
    //         }
    //     }catch(Exception e){
    //         System.debug('GPF exception ' + e.getMessage());
    //     }
    //     try{
    //         if(infoImpresa.getChildElement('Sede',null).getChildElement('Provincia',null) != null){
    //             acct.BillingState = infoImpresa.getChildElement('Sede',null).getChildElement('Provincia',null).getAttribute('sigla',null);
    //         }
    //     }catch(Exception e){
    //         System.debug('GPF exception ' + e.getMessage());
    //     }
    //     try{
    //         if(infoImpresa.getChildElement('Sede',null).getChildElement('Indirizzo',null) != null){
    //             acct.BillingPostalCode = infoImpresa.getChildElement('Sede',null).getChildElement('Indirizzo',null).getAttribute('cap',null);
    //         }
    //     }catch(Exception e){
    //         System.debug('GPF exception ' + e.getMessage());
    //     }
    //     try{
    //         if(infoImpresa.getChildElement('Sede',null).getChildElement('Comune',null) != null){
    //             acct.BillingCity = infoImpresa.getChildElement('Sede',null).getChildElement('Comune',null).getText();
    //         }
    //     }catch(Exception e){
    //         System.debug('GPF exception ' + e.getMessage());
    //     }
        
    //     return acct;
    // }

    @AuraEnabled
    public static Map<String,Object> arricchimentoActionBatch(){

        Map<String,Object> result = new Map<String,Object>{'success' => true};
        try {
            System.enqueueJob(new QbleArricchimentoError());
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }

        return result;
    }

    @AuraEnabled
    public static Map<String,Object> arricchimentoAction(Id accountId){

        Map<String,Object> result = new Map<String,Object>();

        try {
            Account acct = [SELECT Id,Name, CCIAA_CMK__c, CCIAA_REA__c,Forma_giuridica__c,
                Codice_fiscale__c, Partita_iva__c,
                BillingStreet, BillingCity, BillingState, BillingPostalCode,
                BillingCountry, Data_Bilancio__c, Acquisti_totali__c, Data_di_cessazione__c,
                Anno_rilevazione_addetti__c, Data_Inizio_Attivita__c, AnnualRevenue, 
                Livello_attenzione_negativita__c, Capitale_Sociale__c, Crediti_vs_Clienti__c, 
                Risultato_Operativo_Lordo__c, Phone, Email_Aziendale_Innolva__c, Totale_Patrimonio_Netto_Tinexta__c,
                Fax, Utile_Perdita__c, Stato_Attivita__c, Fatturato__c, Rating__c, Dipendenti__c, Codice_Ateco_Innolva__c, Descrizione_Ateco_Innolva__c, 
                Data_Ultimo_Arricchimento__c, Cliente_Estero__c, TXT_Gruppo_IVA__c, TXT_Denominazione_Gruppo_IVA__c, Censimento_Manuale__c
                FROM Account WHERE Id =: accountId];

            if(!Test.isRunningTest()) {
                acct = getProdottoPG(acct);
            }

            // ONLY FOR NEGATIVE TEST
            // acct.Name = 'error';
            if(acct.Name == 'error') {
                throw new CalloutException('ERRORE DURANTE LA CHIAMATA');
            }

            acct.Censimento_Manuale__c = false;
            update acct;
            result.put('success', true);

        } catch (Exception e) {
            if(!System.isQueueable()) {
                throw new AuraHandledException(e.getMessage());
            }
        }

        return result;
    }

    @AuraEnabled
    public static Map<String,Object> handleSessionCacheArricchimento(Account acct) {
        Map<String,Object> result = new Map<String,Object>{'success' => true, 'retry' => false};

        try {
            if(Cache.Org.contains(acct.CCIAA_CMK__c+acct.CCIAA_REA__c)) {
                String duplicateCCIAAREA;
                if(acct.CCIAA_REA__c != null && acct.CCIAA_CMK__c != null){
                    duplicateCCIAAREA = acct.CCIAA_CMK__c+acct.CCIAA_REA__c;
                }
                if(String.isBlank(duplicateCCIAAREA)) {
                    duplicateCCIAAREA = 'nullnull';
                }

                List<Log__c> existingLogs = new List<Log__c>([SELECT Id, Account_JSON__c FROM Log__c WHERE DuplicateCCIAAREA__c =: duplicateCCIAAREA AND CreatedDate = TODAY ORDER BY CreatedDate DESC]);
                if(existingLogs.isEmpty()) {
                    result.put('retry', true);
                }
            } else {
                Cache.Org.put(acct.CCIAA_CMK__c+acct.CCIAA_REA__c, acct.CCIAA_CMK__c+acct.CCIAA_REA__c, 600);
            }
        } catch (Exception e) {
            // result.put('success', false);
            result.put('message', e.getStackTraceString());
        }

        return result;
    }

    @AuraEnabled
    public static Account getProdottoPG(Account acct){
        String duplicateCCIAAREA;
        System.debug('@@@ acct ' + acct.CCIAA_REA__c);
        System.debug('@@@ acct ' + acct.CCIAA_CMK__c);
        if(acct.CCIAA_REA__c != null && acct.CCIAA_CMK__c != null){
            duplicateCCIAAREA = acct.CCIAA_CMK__c+acct.CCIAA_REA__c;
        }
        System.debug('@@@ duplicateCCIAAREA ' + duplicateCCIAAREA);
        if(String.isBlank(duplicateCCIAAREA)) {
            duplicateCCIAAREA = 'nullnull';
        }

        String idSC = UtenzeDefault__c.getInstance().Id_User_Segreteria_Commerciale__c;
        if(UserInfo.getUserId() != idSC && !System.isQueueable()) {
            List<Log__c> existingLogs = new List<Log__c>([SELECT Id, Account_JSON__c FROM Log__c WHERE DuplicateCCIAAREA__c =: duplicateCCIAAREA AND CreatedDate = TODAY ORDER BY CreatedDate DESC]);
            if(!existingLogs.isEmpty()) {
                // return new Account(Name = 'error');
                Account acctLog = new Account(Name = 'error'); 
                if(existingLogs[0].Account_JSON__c != null) {
                    acctLog = (Account)JSON.deserializeStrict(existingLogs[0].Account_JSON__c, Account.Class);
                }
                return acctLog;
            }
        }

        List<Log__c> logsToInsert = new List<Log__c>();
        List<String> CSettings = TXT_CustomSettings();

        System.debug('Account ricevuto: ' + acct);
        //Fine mock
        HttpRequest req = new HttpRequest();
        req.setEndpoint(CSettings[0]);
        req.setMethod('POST');
        req.setHeader('Content-Type', 'text/xml; charset=UTF-8');
        req.setTimeout(120000);
        Dom.Document doc = new Dom.Document();
        //String inputxml = '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:bin="urn:ws.ribes.it/BInformationV4"><soapenv:Header/><soapenv:Body><bin:getProdottoPG><bin:accountName>TINEXTA-WS</bin:accountName><bin:accountPassword>pwdcollaudo</bin:accountPassword><bin:userID>TINEXTA-WS</bin:userID><bin:codiceProdotto>BIWKR</bin:codiceProdotto><bin:tipo>PRD</bin:tipo><bin:formato>XML</bin:formato><bin:tipoRichiesta>RP</bin:tipoRichiesta><bin:codiceFiscale>11142780151</bin:codiceFiscale><bin:tipoMonitoraggio></bin:tipoMonitoraggio><bin:tipoRinnovo></bin:tipoRinnovo><bin:codiceAnagraficaCliente/><bin:idBicLista/><bin:riferimento/><bin:elencoInfo><info nome="?"/></bin:elencoInfo></bin:getProdottoPG></soapenv:Body></soapenv:Envelope>')
        String inputxml = '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:bin="urn:ws.ribes.it/BInformationV4">'+
            '<soapenv:Header/>'+
            '<soapenv:Body>'+
                '<bin:getProdottoPG>'+
                    '<bin:accountName>'+CSettings[2]+'</bin:accountName>'+
                    '<bin:accountPassword>'+CSettings[3]+'</bin:accountPassword>'+
                    '<bin:userID>'+CSettings[2]+'</bin:userID>'+
                    '<bin:codiceProdotto>BIWKR</bin:codiceProdotto>'+
                    '<bin:tipo>PRD</bin:tipo>'+
                    '<bin:formato>XML</bin:formato>'+
                    '<bin:tipoRichiesta>RM</bin:tipoRichiesta>'+
                    '<!--<bin:codiceFiscale></bin:codiceFiscale>-->'+
                    '<!--Optional:-->'+
                    '<bin:cciaa>'+(acct.CCIAA_REA__c != null && acct.CCIAA_REA__c.contains('-') ? acct.CCIAA_REA__c.substringBefore('-') : acct.CCIAA_CMK__c)+'</bin:cciaa>'+//AN
                    '<bin:nrea>'+(acct.CCIAA_REA__c != null && acct.CCIAA_REA__c.contains('-') ? acct.CCIAA_REA__c.substringAfter('-') : acct.CCIAA_REA__c)+'</bin:nrea>'+//156664
                    '<bin:tipoMonitoraggio>A</bin:tipoMonitoraggio>'+
                    '<bin:tipoRinnovo>A</bin:tipoRinnovo>'+
                    '<bin:codiceAnagraficaCliente/>'+
                    '<!--Optional:-->'+
                    '<bin:idBicLista/>'+
                    '<!--Optional:-->'+
                    '<bin:riferimento/>'+
                    '<!--Optional:-->'+
                    '<bin:elencoInfo>'+
                        '<!--1 or more repetitions:-->'+
                        '<info nome="?"/>'+
                    '</bin:elencoInfo>'+
                '</bin:getProdottoPG>'+
            '</soapenv:Body>'+
        '</soapenv:Envelope>';
        doc.load(inputxml);
        
        req.setBodyDocument(doc);
        Http http = new Http();
        HTTPResponse res = http.send(req);

        String output;
        if(res.getStatusCode() == 200){
            Dom.Document responseDoc = res.getBodyDocument();
            Dom.XMLNode root = responseDoc.getRootElement();

            System.debug('XML: ' +res.getBody());
            String nameSpace='http://schemas.xmlsoap.org/soap/envelope/';
            String namespace2 = 'urn:ws.ribes.it/BInformationV4';

    

            Dom.XMLNode risposta = root.getChildElement('Body',namespace).getChildElement('getProdottoPGResponse',namespace2).getChildElement('return',namespace2).getChildElement('WSRBS',null).getChildElement('TRANSAZIONE',null).getChildElement('RISPOSTA',null);
            //System.debug('RISPOSTA: ' + risposta);
            if(risposta != null){
                acct = arricchimento(risposta,acct);
                output = res.getBody().length() > 131072 ? res.getBody().substring(0,131072) : res.getBody().substring(0,res.getBody().length()-1);
                logsToInsert.add(TXT_Logs(inputxml, output, res.getStatus(),acct.CCIAA_CMK__c+acct.CCIAA_REA__c,JSON.serialize(acct)));
            }else{
                Account acctErr = new Account(Name = 'error');
                output = res.getBody().length() > 131072 ? res.getBody().substring(0,131072) : res.getBody().substring(0,res.getBody().length()-1);
                logsToInsert.add(TXT_Logs(inputxml, output, 'Errore o XML incompleto',acct.CCIAA_CMK__c+acct.CCIAA_REA__c,JSON.serialize(acctErr)));
                // SM - FIX
                insert logsToInsert;
                // return new Account(Name = 'error');
                return acctErr;
            }


        }else{
            Account acctErr = new Account(Name = 'error');
            output = res.getBody().length() > 131072 ? res.getBody().substring(0,131072) : res.getBody().substring(0,res.getBody().length()-1);
            logsToInsert.add(TXT_Logs(inputxml, output, res.getStatus(),acct.CCIAA_CMK__c+acct.CCIAA_REA__c, JSON.serialize(acctErr)));
            // SM - FIX
            insert logsToInsert;
            // return new Account(Name = 'error');
            return acctErr;
            
        }

        try{
            insert logsToInsert;
        }catch(Exception e){
            System.debug('GPF Exception ' + e.getMessage());
        }finally{
            return acct;
        }
        return acct;
    }

    public static Account arricchimento(Dom.XMLNode risposta,Account acct){

        Integer day;
        Integer year;
        Integer month;

        //MAPPING MANCANTI:
        acct.Data_di_cessazione__c = null; //Non trovato
        acct.BillingCountry = 'ITALIA'; //Non trovato

        // try {
        //     acct.Errore_Monitoraggio__c = risposta.getChildElement('Prodotto',null).getChildElement('ReportXML',null).getChildElement('Dati',null).getChildElement('Monitoraggio', null).getChildElement('Esito', null).getAttribute('codice', null) != '0';
        // } catch(Exception e) {

        // }
        acct.Errore_Monitoraggio__c = false;

        List<Dom.XMLNode> approfondimentoimprese = risposta.getChildElement('Prodotto',null).getChildElement('ReportXML',null).getChildElement('Dati',null).getChildElement('ApprofondimentiImprese',null).getChildElements(); //[1].getChildElement('BloccoBilanci',null).getChildElement('ElencoBilanci',null).getChildElement('Bilancio',null).getChildElement('ContoEconomico',null);
        //System.debug('APPROFONDIMENTI IMPRESE: '+approfondimentoimprese);

        if(approfondimentoimprese != null){
            System.debug('APPROFONDIMENTI IMPRESE: PRESENTE');
            for(Dom.XMLNode impresa : approfondimentoimprese){
                //System.debug('IMPRESA: '+impresa);
                if(impresa!=null && impresa.getName()=='ApprofondimentoImpresa'){
                    //Name
                    try {
                        Dom.XmlNode nameNode = impresa.getChildElement('InfoImpresa', null).getChildElement('Denominazione', null);
                        if(nameNode != null) {
                            acct.Name = nameNode.getText().left(255);
                        }
                    } catch(Exception e) {
                        System.debug('Name not found');
                    }
                    Dom.XmlNode emailCertificataNode = impresa.getChildElement('InfoImpresa', null).getChildElement('EmailCertificata', null);
                    // System.debug('@@@ emailCertificata ' + emailCertificataNode);
                    try{
                    acct.Email_Aziendale_Innolva__c = emailCertificataNode.getText();
                }catch(Exception e){
                    System.debug('GPF Exception ' + e.getMessage());
                }
                    acct.Data_ultimo_arricchimento__c = System.Today();

                    try {
                        acct.BillingStreet = impresa.getChildElement('InfoImpresa', null)?.getChildElement('Sede', null)?.getChildElement('Indirizzo',null)?.getText();
                        acct.BillingState = impresa.getChildElement('InfoImpresa', null)?.getChildElement('Sede',null).getChildElement('Provincia',null).getAttribute('sigla',null);
                        acct.BillingPostalCode = impresa.getChildElement('InfoImpresa', null)?.getChildElement('Sede', null)?.getChildElement('Indirizzo',null).getAttribute('cap',null).left(20);
                        acct.BillingCity = impresa.getChildElement('InfoImpresa', null)?.getChildElement('Sede', null)?.getChildElement('Comune',null).getText();
                    } catch (Exception e) {
                        System.debug('Address Error ----------- ' + e);
                        System.debug('Address Exception ' + e.getStackTraceString());
                    }

                    if(risposta.getChildElement('Prodotto',null).getChildElement('ReportXML',null).getChildElement('Dati',null).getChildElement('DatiCameraliImpresa',null) != null){
                        try{
                            Dom.XMLNode infoSede = risposta.getChildElement('Prodotto',null).getChildElement('ReportXML',null).getChildElement('Dati',null).getChildElement('DatiCameraliImpresa',null).getChildElement('InfoSede',null);
                            acct.Partita_iva__c = infoSede.getChildElement('PartitaIva',null).getText();
                            System.debug('Partita_iva ' + acct.Partita_iva__c);
                        }catch(Exception e){
                            System.debug('GPF exception ' + e.getMessage() +' '+e.getLineNumber());
                        }
                    }
                    try{
                        if(impresa.getChildElement('InfoImpresa',null).getChildElement('NaturaGiuridica',null) != null){
                            acct.Forma_giuridica__c = impresa.getChildElement('InfoImpresa',null).getChildElement('NaturaGiuridica',null).getText();
                            System.debug('Forma Giuridica: '+acct.Forma_giuridica__c);
                        }
                    }catch(Exception e){
                        System.debug('GPF exception ' + e.getMessage() +' '+e.getLineNumber());
                    }
                    try{
                        if(impresa.getChildElement('InfoImpresa',null).getChildElement('CodiceFiscale',null) != null){
                            acct.Codice_fiscale__c = impresa.getChildElement('InfoImpresa',null).getChildElement('CodiceFiscale',null).getText();
                        }
                    }catch(Exception e){
                        System.debug('GPF exception ' + e.getMessage() +' '+e.getLineNumber());
                    }
                    Dom.XmlNode info = impresa.getChildElement('BloccoBilanci',null).getChildElement('InfoImpresaBilancio',null);
                    //System.debug('INFO: '+info);
                    //String Denominazione = info.getChildElement('Denominazione',null).getText();
                    //System.debug('DENOMINAZIONE IMPRESA: '+Denominazione);
                    /*
                    List<Dom.XmlNode> KReaTag = info.getChildElement('KRea',null).getChildElements();
                    for(Dom.XMLNode KRea : KReaTag){
                        if(KRea.getName()=='Cciaa'){
                            String CCIAA = KRea.getAttribute('sigla',null);
                            System.debug('CCIAA: '+CCIAA);
                        }else if(KRea.getName()=='NRea'){
                            String NRea = KRea.getText();
                            System.debug('NRea: '+NRea);
                        }
                    }
                    */
                    Dom.XmlNode infobilancio = null;
                    System.debug('INFO BILANCIO: ' + impresa.getChildElement('BloccoBilanci',null).getChildElement('ElencoBilanci',null));
                    try{
                        if(impresa.getChildElement('BloccoBilanci',null).getChildElement('ElencoBilanci',null) != null){
                            infobilancio = impresa.getChildElement('BloccoBilanci',null).getChildElement('ElencoBilanci',null).getChildElements()[0];
                        }
                    }catch(Exception e){
                        System.debug('GPF exception ' + e.getMessage());
                    }
                    
                    if(infobilancio != null){
                        Dom.XmlNode ContoEconomico = infobilancio.getChildElement('ContoEconomico', null);
                        for(Dom.XMLNode voce : ContoEconomico.getChildElements()){
                            //System.debug('CODICE VOCE: '+ voce);
                            if(voce != null){
                                if(voce.getChildElement('Descrizione',null).getAttribute('codice',null) == 'IC131' || voce.getChildElement('Descrizione',null).getAttribute('codice',null) == 'PL131'){
                                    //System.debug('VOCE: '+ voce.getChildElement('Valore',null).getAttribute('percentuale',null));
                                    acct.Acquisti_totali__c = double.valueof(voce.getChildElement('Valore',null).getText());
                                    System.debug('VOCE: Acquisti_totali__c: ' + acct.Acquisti_totali__c);
        
                                }else if(voce.getChildElement('Descrizione',null).getAttribute('codice',null) == 'IC124' || voce.getChildElement('Descrizione',null).getAttribute('codice',null) == 'PL124'){
                                    acct.AnnualRevenue = double.valueof(voce.getChildElement('Valore',null).getText());
                                    System.debug('VOCE: AnnualRevenue: ' + acct.AnnualRevenue);
                                    acct.Fatturato__c = TXT_ProcessiLeadAccountUtils.TXT_PickList_Fatturato(acct.AnnualRevenue);
        
                                }else if(voce.getChildElement('Descrizione',null).getAttribute('codice',null) == 'C_IC212' || voce.getChildElement('Descrizione',null).getAttribute('codice',null) == 'C_PL212'){
                                    acct.Risultato_Operativo_Lordo__c = double.valueof(voce.getChildElement('Valore',null).getText());
                                    System.debug('VOCE: Risultato_Operativo_Lordo__c: ' + acct.Risultato_Operativo_Lordo__c);
                                
                                }else if(voce.getChildElement('Descrizione',null).getAttribute('codice',null) == 'IC179' || voce.getChildElement('Descrizione',null).getAttribute('codice',null) == 'PL179'){
                                    acct.Utile_Perdita__c = double.valueof(voce.getChildElement('Valore',null).getText());
                                    System.debug('VOCE: Utile_Perdita__c: ' + acct.Utile_Perdita__c);
                                }
                            }
                        }
    
                        Dom.XmlNode StatoPatrimonialeAttivo = infobilancio.getChildElement('StatoPatrimoniale', null).getChildElement('StatoPatrimonialeAttivo', null);
                        for(Dom.XMLNode voce : StatoPatrimonialeAttivo.getChildElements()){
                            if(voce != null){
                                if(voce.getChildElement('Descrizione',null).getAttribute('codice',null) == 'C_IC201' || voce.getChildElement('Descrizione',null).getAttribute('codice',null) == 'C_PL201'){
                                    acct.Crediti_vs_Clienti__c = double.valueof(voce.getChildElement('Valore',null).getText());
                                    System.debug('VOCE: Crediti_vs_Clienti__c: ' + acct.Crediti_vs_Clienti__c);
                                }
                            }
                        }
    
                        Dom.XmlNode StatoPatrimonialePassivo = infobilancio.getChildElement('StatoPatrimoniale', null).getChildElement('StatoPatrimonialePassivo', null);
                        for(Dom.XMLNode voce : StatoPatrimonialePassivo.getChildElements()){
                            if(voce != null){
                                if(voce.getChildElement('Descrizione',null).getAttribute('codice',null) == 'C_IC221' || voce.getChildElement('Descrizione',null).getAttribute('codice',null) == 'C_PL221'){
                                    acct.Totale_Patrimonio_Netto_Tinexta__c = double.valueof(voce.getChildElement('Valore',null).getText());
                                    System.debug('VOCE: Totale_Patrimonio_Netto_Tinexta__c: ' + acct.Totale_Patrimonio_Netto_Tinexta__c);
                                }
                            }
                        }
    
                        // Dom.XmlNode IndiciRotazioneDurata = infobilancio.getChildElement('IndiciRotazioneDurata', null);
                        // for(Dom.XMLNode voce : IndiciRotazioneDurata.getChildElements()){
                        //     if(voce != null){
                        //         if(voce.getChildElement('Descrizione',null).getAttribute('codice',null) == 'IND109'){
                        //             acct.Fatturato__c = voce.getChildElement('Valore',null).getText(); //MANCANTE
                        //             System.debug('VOCE: Fatturato__c: ' + acct.Fatturato__c);
                        //         }
                        //     }
                        // }
    
                        Dom.XmlNode dataChiusuraBilancio = infobilancio.getChildElement('Testata', null).getChildElement('DataChiusura',null);
                        if(dataChiusuraBilancio != null){
                            year = Integer.valueof(dataChiusuraBilancio.getAttribute('anno',null));
                            month = Integer.valueof(dataChiusuraBilancio.getAttribute('mese',null));
                            day = Integer.valueof(dataChiusuraBilancio.getAttribute('giorno',null));
                            acct.Data_Bilancio__c = date.newInstance(year, month, day);
                        }
                    }
                }
                break;
            }
        }

        if(risposta.getChildElement('Prodotto',null).getChildElement('ReportXML',null).getChildElement('Dati',null).getChildElement('Sintesi',null).getChildElement('SintesiAttivita',null).getChildElement('DataInizioAttivita',null) != null){
            Dom.XMLNode dataInizioAttivita = risposta.getChildElement('Prodotto',null).getChildElement('ReportXML',null).getChildElement('Dati',null).getChildElement('Sintesi',null).getChildElement('SintesiAttivita',null).getChildElement('DataInizioAttivita',null);
            year = Integer.valueof(dataInizioAttivita.getAttribute('anno',null));
            month = Integer.valueof(dataInizioAttivita.getAttribute('mese',null));
            day = Integer.valueof(dataInizioAttivita.getAttribute('giorno',null));
            acct.Data_Inizio_Attivita__c = date.newInstance(year, month, day);
        }

        try{
            if(risposta.getChildElement('Prodotto',null).getChildElement('ReportXML',null).getChildElement('Dati',null).getChildElement('Sintesi',null).getChildElement('SintesiAttivita',null).getChildElement('DataIscrizione',null) != null){
                Dom.XMLNode dataIscrizione = risposta.getChildElement('Prodotto',null).getChildElement('ReportXML',null).getChildElement('Dati',null).getChildElement('Sintesi',null).getChildElement('SintesiAttivita',null).getChildElement('DataIscrizione',null);
                year = Integer.valueof(dataIscrizione.getAttribute('anno',null));
                month = Integer.valueof(dataIscrizione.getAttribute('mese',null));
                day = Integer.valueof(dataIscrizione.getAttribute('giorno',null));
                acct.Data_di_Iscrizione__c = date.newInstance(year, month, day);
            }
            
            if(risposta.getChildElement('Prodotto',null).getChildElement('ReportXML',null).getChildElement('Dati',null).getChildElement('Sintesi',null).getChildElement('SintesiAttivita',null).getChildElement('Addetti',null) != null){
                // String dipendentiStr = risposta.getChildElement('Prodotto',null).getChildElement('ReportXML',null).getChildElement('Dati',null).getChildElement('Sintesi',null).getChildElement('SintesiAttivita',null).getChildElement('Addetti',null).getText();
                // Integer dipendenti = Integer.valueOf(dipendentiStr);
                // if(dipendenti <= 9){
                //     acct.Dipendenti__c = '1-9';
                // } else if(dipendenti >= 10 && dipendenti <= 49){
                //     acct.Dipendenti__c = '10-49';
                // } else if(dipendenti >= 50 && dipendenti <= 249){
                //     acct.Dipendenti__c = '50-249';
                // } else if(dipendenti >= 250){
                //     acct.Dipendenti__c = '250 e oltre';
                // }
                String dipendentiStr = risposta.getChildElement('Prodotto',null).getChildElement('ReportXML',null).getChildElement('Dati',null).getChildElement('Sintesi',null).getChildElement('SintesiAttivita',null).getChildElement('Addetti',null).getText();
                if(System.isQueueable() || UserInfo.getUserId() == UtenzeDefault__c.getInstance().Id_User_Segreteria_Commerciale__c) {
                    acct.Dipendenti__c = TXT_ProcessiLeadAccountUtils.TXT_PickList_Dipendenti(dipendentiStr);
                } else {
                    acct.Dipendenti__c = dipendentiStr; 
                    //risposta.getChildElement('Prodotto',null).getChildElement('ReportXML',null).getChildElement('Dati',null).getChildElement('Sintesi',null).getChildElement('SintesiAttivita',null).getChildElement('Addetti',null).getText();
                }
            }
            
            if(risposta.getChildElement('Prodotto',null).getChildElement('ReportXML',null).getChildElement('Dati',null).getChildElement('Sintesi',null).getChildElement('SintesiAttivita',null).getChildElement('Addetti',null) != null){
                acct.Anno_rilevazione_addetti__c = risposta.getChildElement('Prodotto',null).getChildElement('ReportXML',null).getChildElement('Dati',null).getChildElement('Sintesi',null).getChildElement('SintesiAttivita',null).getChildElement('Addetti',null).getAttribute('anno',null);
            }
            
            if(risposta.getChildElement('Prodotto',null).getChildElement('ReportXML',null).getChildElement('Dati',null).getChildElement('RischioImpresa',null).getChildElement('IndiceEventiPregiudizievoli',null) != null){
                acct.Livello_attenzione_negativita__c = risposta.getChildElement('Prodotto',null).getChildElement('ReportXML',null).getChildElement('Dati',null).getChildElement('RischioImpresa',null).getChildElement('IndiceEventiPregiudizievoli',null).getText();
            }
        }catch(Exception e){
            System.debug('GPF exception ' + e.getMessage());
        }
        
        try{
            Dom.XMLNode capitaleSociale = risposta.getChildElement('Prodotto',null).getChildElement('ReportXML',null).getChildElement('Dati',null).getChildElement('DatiCameraliImpresa',null).getChildElement('InfoPatrimonialiFinanziarie',null).getChildElement('CapitaleSociale',null);
            if(capitaleSociale != null){
                if(capitaleSociale.getChildElement('ImportiEuro',null).getChildElement('Deliberato',null) != null){
                    acct.Capitale_Sociale__c = Decimal.valueof(capitaleSociale.getChildElement('ImportiEuro',null).getChildElement('Deliberato',null).getText());
                }
            }
        }catch(Exception e){
            acct.Capitale_Sociale__c = null;
        }
        
        try{
            if(risposta.getChildElement('Prodotto',null).getChildElement('ReportXML',null).getChildElement('Dati',null).getChildElement('DatiCameraliImpresa',null).getChildElement('InfoSede',null).getChildElement('Telefono',null) != null){
                acct.Phone = risposta.getChildElement('Prodotto',null).getChildElement('ReportXML',null).getChildElement('Dati',null).getChildElement('DatiCameraliImpresa',null).getChildElement('InfoSede',null).getChildElement('Telefono',null).getText();
            }
            
            if(risposta.getChildElement('Prodotto',null).getChildElement('ReportXML',null).getChildElement('Dati',null).getChildElement('DatiCameraliImpresa',null).getChildElement('InfoSede',null).getChildElement('Fax',null) != null){
                acct.Fax = risposta.getChildElement('Prodotto',null).getChildElement('ReportXML',null).getChildElement('Dati',null).getChildElement('DatiCameraliImpresa',null).getChildElement('InfoSede',null).getChildElement('Fax',null).getText();
            }
            
            if(risposta.getChildElement('Prodotto',null).getChildElement('ReportXML',null).getChildElement('Dati',null).getChildElement('ApprofondimentiImprese',null).getChildElement('ApprofondimentoImpresa',null).getChildElement('InfoAttivitaImpresa',null).getChildElement('StatoAttivitaRettificato',null) != null){
                acct.Stato_Attivita__c = risposta.getChildElement('Prodotto',null).getChildElement('ReportXML',null).getChildElement('Dati',null).getChildElement('ApprofondimentiImprese',null).getChildElement('ApprofondimentoImpresa',null).getChildElement('InfoAttivitaImpresa',null).getChildElement('StatoAttivitaRettificato',null).getText();
                if(acct.Stato_Attivita__c != 'CESSATA') {
                    try {
                        acct.Errore_Monitoraggio__c = risposta.getChildElement('Prodotto',null).getChildElement('ReportXML',null).getChildElement('Dati',null).getChildElement('Monitoraggio', null).getChildElement('Esito', null).getAttribute('codice', null) != '0';
                    } catch(Exception e) {

                    }
                }
            }
            
            if(risposta.getChildElement('Prodotto',null).getChildElement('ReportXML',null).getChildElement('Dati',null).getChildElement('RischioImpresa',null).getChildElement('Classe',null) != null){
                acct.Rating__c = risposta.getChildElement('Prodotto',null).getChildElement('ReportXML',null).getChildElement('Dati',null).getChildElement('RischioImpresa',null).getChildElement('Classe',null).getText();
            }

        }catch(Exception e){
            System.debug('GPF exception ' + e.getMessage());
        }
        
        try{
            if(risposta.getChildElement('Prodotto',null).getChildElement('ReportXML',null).getChildElement('Dati',null)?.getChildElement('Sintesi',null)?.getChildElement('SintesiAttivita',null)?.getChildElement('Ateco', null) != null){
                acct.Codice_Ateco_Innolva__c = risposta.getChildElement('Prodotto',null).getChildElement('ReportXML',null).getChildElement('Dati',null)?.getChildElement('Sintesi',null)?.getChildElement('SintesiAttivita',null)?.getChildElement('Ateco', null).getAttribute('codice', null);
            }
            if(risposta.getChildElement('Prodotto',null).getChildElement('ReportXML',null).getChildElement('Dati',null)?.getChildElement('Sintesi',null)?.getChildElement('SintesiAttivita',null)?.getChildElement('Ateco', null) != null){
                acct.Descrizione_Ateco_Innolva__c = risposta.getChildElement('Prodotto',null).getChildElement('ReportXML',null).getChildElement('Dati',null)?.getChildElement('Sintesi',null)?.getChildElement('SintesiAttivita',null)?.getChildElement('Ateco', null).getText();
            }
        } catch (Exception e){

        }

        // SM - Aggiunta campi TXT_Gruppo_IVA__c e TXT_Denominazione_Gruppo_IVA__c
        try {
            if(risposta.getChildElement('Prodotto',null).getChildElement('ReportXML',null).getChildElement('Dati',null)?.getChildElement('DatiCameraliImpresa',null)?.getChildElement('InfoSede',null)?.getChildElement('GruppoIva', null) != null){
                acct.TXT_Gruppo_IVA__c = risposta.getChildElement('Prodotto',null).getChildElement('ReportXML',null).getChildElement('Dati',null)?.getChildElement('DatiCameraliImpresa',null)?.getChildElement('InfoSede',null)?.getChildElement('GruppoIva', null)?.getChildElement('PartitaIvaGruppo', null)?.getText();
                acct.TXT_Denominazione_Gruppo_IVA__c = risposta.getChildElement('Prodotto',null).getChildElement('ReportXML',null).getChildElement('Dati',null)?.getChildElement('DatiCameraliImpresa',null)?.getChildElement('InfoSede',null)?.getChildElement('GruppoIva', null)?.getAttributeValue('denominazione', null);
            }
        } catch (Exception e) {
            System.debug('@@@ gruppo iva not found');
        }

        return acct;
    }


    public static Account createAccountEstero(Dom.XmlNode impresa){
        Account acct = new Account();
        
        try{
            if(impresa.getChildElement('Denominazione',null) != null){
                String name = impresa.getChildElement('Denominazione',null).getText();
                acct.Name = name.length() > 255 ? name.substring(0,255) : name;
                // acct.Name = impresa.getChildElement('Denominazione',null).getText();
                System.debug('DENOMINAZIONE IMPRESA:' + acct.name);
            }
            
            if(impresa.getChildElement('Indirizzo',null).getChildElement('Via',null) != null){
                // acct.BillingStreet = impresa.getChildElement('Indirizzo',null).getChildElement('Via',null).getText();
                // System.debug('Via IMPRESA:' + acct.BillingStreet);
                // String street = impresa.getChildElement('Sede',null).getChildElement('Indirizzo',null).getAttribute('toponimo',null) + ' ' + impresa.getChildElement('Sede',null).getChildElement('Indirizzo',null).getAttribute('via',null) + (impresa.getChildElement('Sede',null).getChildElement('Indirizzo',null).getAttribute('numeroCivico',null) != null ? ', ' + impresa.getChildElement('Sede',null).getChildElement('Indirizzo',null).getAttribute('numeroCivico',null) : '');
                // acct.BillingStreet = street;
                String street = impresa.getChildElement('Indirizzo',null).getChildElement('Via',null).getText();
                acct.BillingStreet = street;
            }
            
            if(impresa.getChildElement('Indirizzo',null).getChildElement('CAP',null) != null){
                acct.BillingPostalCode = impresa.getChildElement('Indirizzo',null).getChildElement('CAP',null).getText().left(20);
                System.debug('CAP IMPRESA:' + acct.BillingPostalCode);
            }
            
            if(impresa.getChildElement('Indirizzo',null).getChildElement('Comune',null) != null){
                acct.BillingCity = impresa.getChildElement('Indirizzo',null).getChildElement('Comune',null).getText();
                System.debug('CITTA IMPRESA:' + acct.BillingCity);
            }
            
            if(impresa.getChildElement('Nazione',null) != null){
                acct.BillingCountry = impresa.getChildElement('Nazione',null).getText();
                System.debug('NAZIONE IMPRESA:' + acct.BillingCountry);
            }
        }catch(Exception e){
            System.debug('GPF exception ' + e.getMessage());
        }

        return acct;
    }

    public static Account createAccountXML(Dom.XMLNode impresa, Integer searchType, String codiceFiscale){
        Account acct = new Account();
        System.debug('Impresa: ' + impresa.getChildElement('InfoImpresa',null).getChildElement('Denominazione',null).getText());
        System.debug('Cciiaa: ' + impresa.getChildElement('InfoImpresa',null).getChildElement('KRea',null).getChildElement('Cciaa',null).getAttribute('sigla',null));
        

        Dom.XMLNode infoImpresa = impresa.getChildElement('InfoImpresa',null);
        // System.debug('InfoImpresa: ' + infoImpresa.getChildElement('Sede',null).getChildElement('Indirizzo',null).getAttribute('via',null));
        Dom.XMLNode attivita = impresa.getChildElement('Attivita',null);

        try{

            if(attivita !=null && attivita.getChildElement('StatoAttivitaRettificato',null) != null){
                System.debug('Stato Attivita Impresa: ' + attivita.getChildElement('StatoAttivitaRettificato',null).getText());
                acct.Stato_Attivita__c = attivita.getChildElement('StatoAttivitaRettificato',null).getText();
            }
        }catch(Exception e){
            System.debug('GPF exception ' + e.getMessage());
        }
        try{
            if(infoImpresa.getChildElement('Denominazione',null) != null){
                // acct.Name = infoImpresa.getChildElement('Denominazione',null).getText();
                String name = infoImpresa.getChildElement('Denominazione',null).getText();
                acct.Name = name.length() > 255 ? name.substring(0,255) : name;
            }
        }catch(Exception e){
            System.debug('GPF exception ' + e.getMessage());
        }
        try{
            if(infoImpresa.getChildElement('KRea',null).getChildElement('Cciaa',null) != null){
                acct.CCIAA_CMK__c = infoImpresa.getChildElement('KRea',null).getChildElement('Cciaa',null).getAttribute('sigla',null);
            }
        }catch(Exception e){
            System.debug('GPF exception ' + e.getMessage());
        }
        try{    
            if(infoImpresa.getChildElement('KRea',null).getChildElement('Cciaa',null) != null){
                acct.CCIAA_REA__c = infoImpresa.getChildElement('KRea',null).getChildElement('NRea',null).getText();
            }
        }catch(Exception e){
            System.debug('GPF exception ' + e.getMessage());
        }
        try{
            //String denosociale =  infoImpresa.getChildElement('NaturaGiuridica',null).getText();
        
            
            if(infoImpresa.getChildElement('PartitaIva',null) != null){
                acct.Partita_iva__c = infoImpresa.getChildElement('PartitaIva',null).getText();
                System.debug('Partita_iva ' + acct.Partita_iva__c);
            }else{
                try{
                Dom.XMLNode infoSede = impresa.getChildElement('InfoSede',null);
                acct.Partita_iva__c = infoSede.getChildElement('PartitaIva',null).getText();
                System.debug('Partita_iva ' + acct.Partita_iva__c);
                }catch(Exception e){
                    System.debug('GPF exception ' + e.getMessage());
                }
            }
        }catch(Exception e){
            System.debug('GPF exception ' + e.getMessage());
        }
        try{
            /*if(searchType == 1){*/
                if(infoImpresa.getChildElement('CodiceFiscale',null) != null){
                    acct.Codice_fiscale__c = infoImpresa.getChildElement('CodiceFiscale',null).getText();
                }
            //} else {
                //acct.Partita_iva__c = codiceFiscale;
                //acct.Codice_fiscale__c = codiceFiscale;
           // }
        }catch(Exception e){
            System.debug('GPF exception ' + e.getMessage());
        }
        try{
            
            if(infoImpresa.getChildElement('Sede',null).getChildElement('Indirizzo',null) != null){
                //OLD
                // if(acct.CCIAA_REA__c != null){
                //     String street = infoImpresa.getChildElement('Sede',null).getChildElement('Indirizzo',null).getAttribute('toponimo',null) + ' ' + infoImpresa.getChildElement('Sede',null).getChildElement('Indirizzo',null).getAttribute('via',null) + (infoImpresa.getChildElement('Sede',null).getChildElement('Indirizzo',null).getAttribute('numeroCivico',null) != null ? ', ' + infoImpresa.getChildElement('Sede',null).getChildElement('Indirizzo',null).getAttribute('numeroCivico',null) : '' );
                //     // acct.BillingStreet = infoImpresa.getChildElement('Sede',null).getChildElement('Indirizzo',null).getAttribute('via',null);
                //     acct.BillingStreet = street;
                // } else {
                //     // String cap = infoImpresa.getChildElement('Sede',null).getChildElement('Indirizzo',null).getAttribute('cap',null);
                //     String street = infoImpresa.getChildElement('Sede',null).getChildElement('Indirizzo',null).getText() != null ? infoImpresa.getChildElement('Sede',null).getChildElement('Indirizzo',null).getText() : '';
                //     // acct.BillingStreet = infoImpresa.getChildElement('Sede',null).getChildElement('Indirizzo',null).getAttribute('via',null);
                //     acct.BillingStreet = street;
                // }
                String street = infoImpresa.getChildElement('Sede',null).getChildElement('Indirizzo',null).getText() != null ? infoImpresa.getChildElement('Sede',null).getChildElement('Indirizzo',null).getText() : '';
                acct.BillingStreet = street;
            }
        
        }catch(Exception e){
            System.debug('GPF exception ' + e.getMessage());
        }
        try{    
            if(infoImpresa.getChildElement('Sede',null).getChildElement('Provincia',null) != null){
                acct.BillingState = infoImpresa.getChildElement('Sede',null).getChildElement('Provincia',null).getAttribute('sigla',null);
            }
        
        }catch(Exception e){
            System.debug('GPF exception ' + e.getMessage());
        }
        try{    
            if(infoImpresa.getChildElement('Sede',null).getChildElement('Indirizzo',null) != null){
                acct.BillingPostalCode = infoImpresa.getChildElement('Sede',null).getChildElement('Indirizzo',null).getAttribute('cap',null).left(20);
            }
        
        }catch(Exception e){
            System.debug('GPF exception ' + e.getMessage());
        }
        try{    
            if(infoImpresa.getChildElement('Sede',null).getChildElement('Comune',null) != null){
                acct.BillingCity = infoImpresa.getChildElement('Sede',null).getChildElement('Comune',null).getText();
            }
        
        }catch(Exception e){
            System.debug('GPF exception ' + e.getMessage());
        }
        try{    
            if(infoImpresa.getChildElement('NaturaGiuridica',null) != null){
                acct.Forma_giuridica__c = infoImpresa.getChildElement('NaturaGiuridica',null).getText();
            }
        
        }catch(Exception e){
            System.debug('GPF exception ' + e.getMessage());
        }
        // try{    
        //     if(impresa.getChildElement('Attivita',null).getChildElement('Ateco07',null) != null){
        //         acct.Codice_Ateco_Innolva__c = impresa.getChildElement('Attivita',null).getChildElement('Ateco07',null).getAttribute('codice',null);
        //     }
        
        // }catch(Exception e){
        //     System.debug('GPF exception ' + e.getMessage());
        // }
        // try{    
        //     if(impresa.getChildElement('Attivita',null).getChildElement('Ateco07',null) != null){
        //         acct.Descrizione_Ateco_Innolva__c = impresa.getChildElement('Attivita',null).getChildElement('Ateco07',null).getText();
        //     }
        // }catch(Exception e){
        //     System.debug('GPF exception ' + e.getMessage());
        // }


        return acct;
    }

    public static Account createAccountXML_noREA(Dom.XMLNode impresa, Integer searchType, String codiceFiscale){
        Account acct = new Account();
        System.debug('Impresa: ' + impresa.getChildElement('InfoImpresa',null).getChildElement('Denominazione',null).getText());        

        Dom.XMLNode infoImpresa = impresa.getChildElement('InfoImpresa',null);
        Dom.XMLNode attivita = impresa.getChildElement('Attivita',null);

        try{

            if(attivita !=null && attivita.getChildElement('StatoAttivitaRettificato',null) != null){
                System.debug('Stato Attivita Impresa: ' + attivita.getChildElement('StatoAttivitaRettificato',null).getText());
                acct.Stato_Attivita__c = attivita.getChildElement('StatoAttivitaRettificato',null).getText();
            }
        }catch(Exception e){
            System.debug('GPF exception ' + e.getMessage());
        }
        try{
            if(infoImpresa.getChildElement('Denominazione',null) != null){
                // acct.Name = infoImpresa.getChildElement('Denominazione',null).getText();
                String name = infoImpresa.getChildElement('Denominazione',null).getText();
                acct.Name = name.length() > 255 ? name.substring(0,255) : name;
            }
        }catch(Exception e){
            System.debug('GPF exception ' + e.getMessage());
        }
        try{
            if(infoImpresa.getChildElement('PartitaIva',null) != null){
                acct.Partita_iva__c = infoImpresa.getChildElement('PartitaIva',null).getText();
                System.debug('Partita_iva ' + acct.Partita_iva__c);
            }else{
                try{
                Dom.XMLNode infoSede = impresa.getChildElement('InfoSede',null);
                acct.Partita_iva__c = infoSede.getChildElement('PartitaIva',null).getText();
                System.debug('Partita_iva ' + acct.Partita_iva__c);
                }catch(Exception e){
                    System.debug('GPF exception ' + e.getMessage());
                }
            }
        }catch(Exception e){
            System.debug('GPF exception ' + e.getMessage());
        }
        try{
            if(searchType == 1){
                if(infoImpresa.getChildElement('CodiceFiscale',null) != null){
                    acct.Codice_fiscale__c = infoImpresa.getChildElement('CodiceFiscale',null).getText();
                }
            } else {
                //acct.Partita_iva__c = codiceFiscale;
                acct.Codice_fiscale__c = codiceFiscale;
            }
        }catch(Exception e){
            System.debug('GPF exception ' + e.getMessage());
        }
        try{
            
            if(infoImpresa.getChildElement('Sede',null).getChildElement('Indirizzo',null) != null){
                //OLD
                // if(acct.CCIAA_REA__c != null){
                //     String street = infoImpresa.getChildElement('Sede',null).getChildElement('Indirizzo',null).getAttribute('toponimo',null) + ' ' + infoImpresa.getChildElement('Sede',null).getChildElement('Indirizzo',null).getAttribute('via',null) + (infoImpresa.getChildElement('Sede',null).getChildElement('Indirizzo',null).getAttribute('numeroCivico',null) != null ? ', ' + infoImpresa.getChildElement('Sede',null).getChildElement('Indirizzo',null).getAttribute('numeroCivico',null) : '' );
                //     // acct.BillingStreet = infoImpresa.getChildElement('Sede',null).getChildElement('Indirizzo',null).getAttribute('via',null);
                //     acct.BillingStreet = street;
                // } else {
                //     // String cap = infoImpresa.getChildElement('Sede',null).getChildElement('Indirizzo',null).getAttribute('cap',null);
                //     String street = infoImpresa.getChildElement('Sede',null).getChildElement('Indirizzo',null).getText() != null ? infoImpresa.getChildElement('Sede',null).getChildElement('Indirizzo',null).getText() : '';
                //     // acct.BillingStreet = infoImpresa.getChildElement('Sede',null).getChildElement('Indirizzo',null).getAttribute('via',null);
                //     acct.BillingStreet = street;
                // }
                String street = infoImpresa.getChildElement('Sede',null).getChildElement('Indirizzo',null).getText() != null ? infoImpresa.getChildElement('Sede',null).getChildElement('Indirizzo',null).getText() : '';
                acct.BillingStreet = street;
                
            }
        
        }catch(Exception e){
            System.debug('GPF exception ' + e.getMessage());
        }
        try{    
            if(infoImpresa.getChildElement('Sede',null).getChildElement('Provincia',null) != null){
                acct.BillingState = infoImpresa.getChildElement('Sede',null).getChildElement('Provincia',null).getAttribute('sigla',null);
            }
        
        }catch(Exception e){
            System.debug('GPF exception ' + e.getMessage());
        }
        try{    
            if(infoImpresa.getChildElement('Sede',null).getChildElement('Indirizzo',null) != null){
                acct.BillingPostalCode = infoImpresa.getChildElement('Sede',null).getChildElement('Indirizzo',null).getAttribute('cap',null);
            }
        
        }catch(Exception e){
            System.debug('GPF exception ' + e.getMessage());
        }
        try{    
            if(infoImpresa.getChildElement('Sede',null).getChildElement('Comune',null) != null){
                acct.BillingCity = infoImpresa.getChildElement('Sede',null).getChildElement('Comune',null).getText();
            }
        
        }catch(Exception e){
            System.debug('GPF exception ' + e.getMessage());
        }
        try{    
            if(infoImpresa.getChildElement('NaturaGiuridica',null) != null){
                acct.Forma_giuridica__c = infoImpresa.getChildElement('NaturaGiuridica',null).getText();
            }
        
        }catch(Exception e){
            System.debug('GPF exception ' + e.getMessage());
        }

        return acct;
    }

    @AuraEnabled
    public static string getVisuraCamerale(string recordId)
    {
        //gestire caso in cui chiamata va in timeout con seconda chiamata per ticketid
        /*try 
        {*/
            system.debug('record id '+recordId);
            List<Log__c> logsToInsert = new List<Log__c>();
            List<String> CSettings = TXT_CustomSettings();
            string response = '';
            Boolean success = false;
            String msg = '';
            Integer statusCode = null;
            String output = '';
            String jsonString = '';
            String inputxml = '';
            EndpointServizi__c endpoints = EndpointServizi__c.getInstance();
            string idRecordLog = '';

            if(recordId != null && recordId != '') 
            {
                try 
                { 

                    account acc = [select id, name, CCIAA_CMK__c, CCIAA_REA__c from account where id = :recordId];
                    idRecordLog = acc.id;
                    HttpRequest req = new HttpRequest();
                    req.setEndpoint(endpoints.TXT_ServiziCamerali__c);
                    //req.setEndpoint('https://collaudo-ws.ribes.it/wsrbs/services/ServiziCameraliV1?wsdl');
                    req.setMethod('POST');
                    req.setHeader('Content-Type', 'text/xml;charset=UTF-8');
                    req.setTimeout(120000);
                    Dom.Document doc = new Dom.Document();
                    
                    
                    //String inputxml = '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:bin="urn:ws.ribes.it/BInformationV4"><soapenv:Header/><soapenv:Body><bin:getProdottoPG><bin:accountName>TINEXTA-WS</bin:accountName><bin:accountPassword>pwdcollaudo</bin:accountPassword><bin:userID>TINEXTA-WS</bin:userID><bin:codiceProdotto>BIWKR</bin:codiceProdotto><bin:tipo>PRD</bin:tipo><bin:formato>XML</bin:formato><bin:tipoRichiesta>RP</bin:tipoRichiesta><bin:codiceFiscale>11142780151</bin:codiceFiscale><bin:tipoMonitoraggio></bin:tipoMonitoraggio><bin:tipoRinnovo></bin:tipoRinnovo><bin:codiceAnagraficaCliente/><bin:idBicLista/><bin:riferimento/><bin:elencoInfo><info nome="?"/></bin:elencoInfo></bin:getProdottoPG></soapenv:Body></soapenv:Envelope>'; doc.load(inputxml);
                    inputxml = '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:ser="urn:ws.ribes.it/ServiziCameraliV1">'+
                        '<soapenv:Header/>'+
                        '<soapenv:Body>'+
                            '<ser:getVisuraCamerale>'+
                                '<ser:accountName>'+CSettings[2]+'</ser:accountName>'+
                                '<ser:accountPassword>'+CSettings[3]+'</ser:accountPassword>'+
                                '<ser:userID>'+CSettings[2]+'</ser:userID>'+
                                '<ser:codiceProdotto>VISORDN</ser:codiceProdotto>'+
                                '<ser:tipo>PRD</ser:tipo>'+
                                '<ser:formato>PDF</ser:formato>'+
                                '<ser:cciaa>'+acc.CCIAA_CMK__c+'</ser:cciaa>'+ //Provincia CCIAA-REA account
                                '<ser:nrea>'+acc.CCIAA_REA__c+'</ser:nrea>'+ //Codice CCIAA-REA account
                            '</ser:getVisuraCamerale>'+
                        '</soapenv:Body>'+
                    '</soapenv:Envelope>';
                    doc.load(inputxml);

                    // req.setHeader('SOAPAction', '"urn:getListaAziende"');
                    req.setBodyDocument(doc);
                    Http http = new Http();
                    HTTPResponse res = http.send(req);
                    System.debug('@@@ localtion ' + res.getHeader('Location'));
                    output = res.getBody().length() > 131072 ? res.getBody().substring(0,131072) : res.getBody();
                    System.debug('res.getStatusCode() '+res.getStatusCode());

                    Dom.Document responseDoc = res.getBodyDocument();
                    Dom.XMLNode root = responseDoc.getRootElement();

                    String nameSpace='http://schemas.xmlsoap.org/soap/envelope/';
                    String namespace2 = 'urn:ws.ribes.it/ServiziCameraliV1';
                    Dom.XMLNode esito = root.getChildElement('Body',namespace).getChildElement('getVisuraCameraleResponse',namespace2).getChildElement('return',namespace2).getChildElement('WSRBS',null).getChildElement('TRANSAZIONE',null).getChildElement('ESITO',null);
                    string esitoCodice = esito.getAttribute('codice', null);
                    system.debug('esito '+esito);
                    if(res.getStatusCode() == 200)
                    {
                        if(esitoCodice == '0')
                        {
                            success = true;
                            response = esito.getText();

                            Dom.XMLNode risposta;
                            Dom.XMLNode elencoImprese;
                            Dom.XMLNode IDTicket; //<TICKETID>
                            string pdf;
                            System.debug('XML: ' + res.getBody());
                            risposta = root.getChildElement('Body',namespace).getChildElement('getVisuraCameraleResponse',namespace2).getChildElement('return',namespace2).getChildElement('WSRBS',null).getChildElement('TRANSAZIONE',null).getChildElement('RISPOSTA',null);
                            try
                            {
                                elencoImprese = risposta.getChildElement('Prodotto',null).getChildElement('ReportPDF',null).getChildElement('FileBase64',null);
                                pdf = elencoImprese.getText();
                                IDTicket = root.getChildElement('Body',namespace).getChildElement('getVisuraCameraleResponse',namespace2).getChildElement('return',namespace2).getChildElement('WSRBS',null).getChildElement('TRANSAZIONE',null).getChildElement('TICKETID',null);
                            
                                system.debug('elencoImprese '+elencoImprese);
                                system.debug('Id ticket '+ IDTicket);
                                
                                /*for(Dom.XMLNode impresa : elencoImprese.getChildElements())
                                {
                                    pdf = impresa.getText();*/
                                    system.debug(pdf);
                                //}


                                /*Attachment attach = new Attachment();
                                attach.contentType = 'application/pdf';
                                attach.name = 'VisuraCamerale - '+acc.name+'.pdf'; //aggiungere nome account
                                attach.parentId = acc.id; //id account
                                attach.body = EncodingUtil.base64Decode(pdf);
                                insert attach;*/

                                //download in locale?
                                //ContentVersion conVer = new ContentVersion(); 
                                //conVer.ContentLocation = 'S'; // to use S specify this document is in Salesforce, to use E for external files 
                                //conVer.PathOnClient = 'VisuraCamerale - '+acc.name+'.pdf'; // The files name, extension is very important here which will help the file in preview. 
                                //conVer.Title = 'VisuraCamerale - '+acc.name+'.pdf'; // Display name of the files 
                                //conVer.VersionData = EncodingUtil.base64Decode(pdf); // converting your binary string to Blog 
                                //insert conVer; //Insert ContentVersion 
                                // First get the Content Document Id from ContentVersion Object 
                                //Id conDoc = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:conVer.Id].ContentDocumentId; 
                                //create ContentDocumentLink record 
                                //ContentDocumentLink conDocLink = New ContentDocumentLink(); 
                                //conDocLink.LinkedEntityId = acc.id; // Specify RECORD ID here i.e Any Object ID (Standard Object/Custom Object) 
                                //conDocLink.ContentDocumentId = conDoc; //ContentDocumentId Id from ContentVersion 
                                //conDocLink.shareType = 'V'; 
                                //insert conDocLink;

                                response += ',' + pdf;
                            }
                            catch(Exception e)
                            {
                                risposta = null;
                                System.debug('Nessun Risultato / Errore XML');
                                success = false; 
                                msg = e.getMessage();
                                response = e.getMessage() + ' - ' + e.getLineNumber();
                            }
                        }
                        else
                        {
                            success = false; 
                            msg = esito.getText();
                            response = esito.getText();
                        }
                    }
                    else
                    {
                        System.debug('Status code: ' + res.getStatusCode());
                        msg = String.valueOf(res.getStatusCode());
                        response = String.valueOf(res.getStatusCode());
                        success = false;
                    }
                }
                catch(System.CalloutException e) 
                { 
                    //Exception handling goes here.... retry the call, whatever 
                    success = false; 
                    msg = e.getMessage();   
                    response = e.getMessage() + ' - ' + e.getLineNumber();
                } 
                catch (system.dmlexception e)
                {
                    success = false; 
                    msg = e.getMessage();   
                    response = e.getMessage() + ' - ' + e.getLineNumber();
                }
                insert new Log__c(
                    Success__c = success,
                    Societa__c = 'WarrantHub',
                    Source__c = 'TXT_CalloutHandler',
                    ID_Record__c = idRecordLog,
                    ErrorMessage__c = msg,
                    InputPayload__c = inputxml,
                    OutputPayload__c = output
                );
            }
            return response;
        /*} 
        catch (Exception e) 
        {
            throw new AuraHandledException(e.getMessage());
        }*/
    }
    @AuraEnabled
    public static Account getAccount(string recordId)
    {
        try 
        {
            /**
                * @description: il metodo esegue una query includendo in automatico tutti i campi dell'oggetto
                * @param objectApiName: nome API oggetto su cui eseguire la query
                * @return: lista di risultati di tipo "sObject" generico. È possibile fare il cast del risulta in una lista dell'oggetto specifico
                */ 
            //reperisco tutti i campi dell'oggetto
            Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
            Map<String, Schema.SObjectField> fieldMap = schemaMap.get('Account').getDescribe().fields.getMap();
            list<string> list_field = new list<string>(fieldMap.keyset());
        
        
            string qrSelect = 'select '+string.join(list_field , ',');//SELECT con tutti i campi dell'oggetto
            string qrFrom = ' from Account';//FROM oggetto
            string qrWhere = ' where id = :recordId'; //WHERE filtri query
            string qrOrder = ' order by '; //ORDER BY ordinamento risultati query
            
            //creo una variabile di tipo "Tipo lista<Oggetto>"
            System.Type listType = System.Type.forName('List<Account>');
            //istanzio una lista vuota del tipo "listType", in modo da poter fare il cast di "result" nel tipo corretto al di fuori del metodo
            List<Account> result = (List<Account>)listType.newInstance();
        
        
            //aggiungere where/order se correttamente valorizzati nelle variabili
            //---(la lista funziona anche con un solo record: se non trova nulla non va in errore ma restituisce una lista vuota)---
            result = database.query(qrSelect + qrFrom + qrWhere /*+ qrOrder*/);
        
            return result[0];
        } 
        catch (Exception e) 
        {
            throw new AuraHandledException(e.getMessage());
        }
    }
}