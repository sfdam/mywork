global without sharing class TXT_Monitoraggi_Scheduled  implements Schedulable, Database.AllowsCallouts {

    global void execute(SchedulableContext ctx){
        // List<Map<String,String>> note_REA = getListaMonitoraggio();
        getListaMonitoraggio();

        // if(!note_REA.isEmpty()){
        //     System.enqueueJob(new TXT_Monitoraggi(note_REA));
        // }
    }

    public static Map<String,String> TXT_CustomSettings() {
        Map<String,String> settings = new Map<String,String>();

        EndpointServizi__c endpoints = EndpointServizi__c.getInstance();
        UtenzeDefault__c credentials = UtenzeDefault__c.getInstance();

        settings.put('endpoint', endpoints.TXT_BusinessInformation__c);
        settings.put('username', credentials.TXT_Innolva_EndPoint_User__c);
        settings.put('password', credentials.TXT_Innolva_EndPoint_Password__c);

        return settings;
    }

    /*List<Map<String,String>>*/ 
    @future(callout=true)
    private static void getListaMonitoraggio(){
        System.debug('@@@ getListMonitoraggi');
        String idTicket = '';
        List<Map<String,String>> note_REA = new List<Map<String,String>>();

        Map<String,String> CSettings = TXT_CustomSettings();
        // REQUEST
        HttpRequest req = new HttpRequest();
        req.setEndpoint(CSettings.get('endpoint'));
        req.setMethod('POST');
        req.setHeader('Content-Type', 'text/xml; charset=UTF-8');
        req.setTimeout(120000);
        Dom.Document doc = new Dom.Document();
        String body = '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:bin="urn:ws.ribes.it/BInformationV4">'+
                    '<soapenv:Header/>'+
                    '<soapenv:Body>'+
                    '<bin:getListaNote>'+
                        '<bin:accountName>'+CSettings.get('username')+'</bin:accountName>'+
                        '<bin:accountPassword>'+CSettings.get('password')+'</bin:accountPassword>'+
                        '<bin:userID>'+CSettings.get('username')+'</bin:userID>'+
                        '<bin:filtroIstituto></bin:filtroIstituto>'+
                        '<bin:filtroFiliale></bin:filtroFiliale>'+
                        '<bin:filtroOperatore></bin:filtroOperatore>'+
                        '<bin:codiciProdotto>BIWKR</bin:codiciProdotto>'+
                        '<bin:campoLibero></bin:campoLibero>'+
                        '<bin:tipiNota></bin:tipiNota>'+
                        '<bin:letto>T</bin:letto>'+
                        '<bin:archiviata>T</bin:archiviata>'+
                        // -1 se faccio girare dalle 00:00 in poi
                        // altrimenti senza -1 se faccio girare prima delle 00:00
                        // TO TEST
                        // '<bin:dataRichiestaDal>2021-10-10</bin:dataRichiestaDal>'+
                        // '<bin:dataRichiestaAl></bin:dataRichiestaAl>'+
                        // PROD
                        '<bin:dataRichiestaDal>'+System.Today().addDays(-3)+'</bin:dataRichiestaDal>'+
                        '<bin:dataRichiestaAl></bin:dataRichiestaAl>'+
                        '<bin:righePerPagina>50</bin:righePerPagina>'+
                        '<bin:campoOrdine></bin:campoOrdine>'+
                        '<bin:versoOrdine></bin:versoOrdine>'+
                    '<bin:raggruppaSoggetti>N</bin:raggruppaSoggetti>'+
                    '</bin:getListaNote>'+
                    '</soapenv:Body>'+
                '</soapenv:Envelope>';

        doc.load(body);
        req.setBodyDocument(doc);
        Http http = new Http();
        HTTPResponse res = http.send(req);

        Log__c logMonit = new Log__c(InputPayload__c = body, Source__c = 'GetListaMonitoraggi', OutputPayload__c = res.getBody().length() > 131072 ? res.getBody().substring(0,131072) : res.getBody());

        if(res.getStatusCode() == 200){
            try{                

                Dom.Document responseDoc = res.getBodyDocument(); //dummydoc; //
                Dom.XMLNode root = responseDoc.getRootElement();

                String nameSpace='http://schemas.xmlsoap.org/soap/envelope/';
                String namespace2 = 'urn:ws.ribes.it/BInformationV4';

                Dom.XMLNode TRANSAZIONE = root.getChildElement('Body',namespace).getChildElement('getListaNoteResponse',namespace2).getChildElement('return',namespace2).getChildElement('WSRBS',null).getChildElement('TRANSAZIONE',null);
                idTicket = TRANSAZIONE.getChildElement('TICKETID', null).getText();
                System.debug('@@@ idTicket ' + idTicket);
                // PARSO L'XML
                Dom.XMLNode RISPOSTA = TRANSAZIONE.getChildElement('RISPOSTA',null);
                Dom.XMLNode ListaMonitoraggi = RISPOSTA.getChildElement('Prodotto',null).getChildElement('Lista',null).getChildElement('ListaNote',null);
                // Verifico se ci sono elementi
                if(ListaMonitoraggi!=null && (ListaMonitoraggi.getAttribute('numeroPosizioniTotali',null)!='0' || ListaMonitoraggi.getChildElements().size()>0)){

                    for(Dom.XmlNode Soggetto :ListaMonitoraggi.getChildElements()){
                        try{
                            
                            String provincia = Soggetto.getChildElement('InfoImpresa', null).getChildElement('KRea',null).getChildElement('Cciaa',null).getAttribute('sigla',null);
                            String rea = Soggetto.getChildElement('InfoImpresa', null).getChildElement('KRea', null).getChildElement('NRea', null).getText();
                            String cf = Soggetto.getChildElement('InfoImpresa', null).getChildElement('CodiceFiscale', null).getText();
                            // String notaId;
                            List<String> noteIds = new List<String>();
                            List<Dom.XmlNode> listaNote = Soggetto.getChildElement('ElencoNote', null).getChildElements();
                            if(listaNote.size() > 0){
                                for(Dom.XmlNode nota : listaNote){
                                    noteIds.add(nota.getChildElement('IDNota', null).getText());
                                }
                                // notaId = listaNote[0].getChildElement('IDNota', null).getText();
                            }


                            // if(rea != null && notaId != null){
                            //     note_REA.add(new Map<String,String>{'rea' => rea, 'notaId' => notaId, 'cf' => cf});
                            // }
                            if(rea != null && !noteIds.isEmpty()){
                                for(String notaId : noteIds){
                                    note_REA.add(new Map<String,String>{'rea' => rea, 'provincia' => provincia, 'notaId' => notaId, 'cf' => cf});
                                }
                            }

                        }catch(Exception e){
                            System.debug('[EXCE] TXT_Monitoraggi '+e.getMessage()+ ' at line: '+e.getLineNumber()+' stack trace: '+e.getStackTraceString());
                            logMonit.ErrorMessage__c = e.getStackTraceString() + ' -- ' + e.getMessage();
                            logMonit.Success__c = false;
                        }
                    }

                }else{
                    System.debug('@@@ Nessun Soggetto!');
                }

            }catch(Exception e){
                System.debug('[EXCE] TXT_Monitoraggi '+e.getMessage()+ ' at line: '+e.getLineNumber()+' stack trace: '+e.getStackTraceString());
                logMonit.ErrorMessage__c = e.getStackTraceString() + ' -- ' + e.getMessage();
                logMonit.Success__c = false;
            }

        }else{
            // IL SERVER HA RISPOSTO MALE O NON HA RISPOSTO
            System.debug('Status code: ' + res.getStatusCode());
            logMonit.ErrorMessage__c = String.valueOf(res.getStatusCode());
            logMonit.Success__c = false;
        }

        insert logMonit;

        if(!note_REA.isEmpty()){
            System.enqueueJob(new TXT_Monitoraggi(note_REA, 1, idTicket));
        }

        // return note_REA;
        return;
    }
}