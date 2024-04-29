public without sharing class TXT_Monitoraggi_Helper implements Database.Batchable<Integer>, Database.AllowsCallouts {

    public Integer nPag;
    public String ticketId;
    //saleforce case n. 43681804 -- AMS-001144
    public boolean abilita;
    Funzionalita__c f = Funzionalita__c.getOrgDefaults();
    
    public TXT_Monitoraggi_Helper(Integer nPag, String ticketId) {
        this.nPag = nPag;
        this.ticketId = ticketId;
        //saleforce case n. 43681804 -- AMS-001144
        this.abilita = f.TXT_Abilita_monitoraggio__c;
    }

    public Iterable<Integer> start(Database.BatchableContext BC) {
        //saleforce case n. 43681804 -- AMS-001144
        if(abilita) 
        {
            f.TXT_Abilita_monitoraggio__c = false;
            update f;
            return new List<Integer> { nPag };
        }
        else return null;
    }

    public void execute(Database.BatchableContext info, List<Integer> nPags) {
        System.debug('@@@ getPagina: ' + nPag);
        System.debug('@@@ ticketId: ' + this.ticketId);

        Integer nPag = nPags[0];
        // String hour = String.valueOf(Datetime.now().hour());
        // String min = String.valueOf(Datetime.now().minute()); 
        // String ss = Datetime.now().second() + 5 > 59 ? '59' : Datetime.now().second() + 5 < 0 ? '0' : String.valueOf(Datetime.now().second() + 5);
        // //parse to cron expression
        // String schedulazione = ss + ' ' + min + ' ' + hour + ' * * ?';

        // System.schedule('Innolva Monitoraggi - Get Pagina ' + nPag, schedulazione, new TXT_Monitoraggi_GetPagina(nPag, ticketId));

        Log__c logArricchimento = new Log__c(Source__c = 'JOB MONITORAGGIO INNOLVA - GET PAGINA ' + nPag);
        List<Map<String,String>> note_REA = new List<Map<String,String>>();

        Map<String,String> settings = TXT_Monitoraggi.TXT_CustomSettings();

        try{
            
            HttpRequest req = new HttpRequest();
            req.setEndpoint(settings.get('endpoint'));
            req.setMethod('POST');
            req.setHeader('Content-Type', 'text/xml; charset=UTF-8');
            req.setTimeout(120000);
            Dom.Document doc = new Dom.Document();
            doc.load('<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:bin="urn:ws.ribes.it/BInformationV4">'+
            '<soapenv:Header/>'+
            '<soapenv:Body>'+
                '<bin:getPagina>'+
                    '<bin:accountName>'+settings.get('username')+'</bin:accountName>'+
                    '<bin:accountPassword>'+settings.get('password')+'</bin:accountPassword>'+
                    '<bin:userID>'+settings.get('username')+'</bin:userID>'+
                    '<bin:tipoElenco>Note</bin:tipoElenco>'+
                    '<bin:ticketID>'+this.ticketId+'</bin:ticketID>'+
                    '<bin:pagina>'+String.valueOf(nPag)+'</bin:pagina>'+
                    '<!--Optional:-->'+
                    '<bin:campoOrdine></bin:campoOrdine>'+
                    '<!--Optional:-->'+
                    '<bin:versoOrdine></bin:versoOrdine>'+
                '</bin:getPagina>'+
            '</soapenv:Body>'+
            '</soapenv:Envelope>');

            req.setBodyDocument(doc);
            Http http = new Http();

            System.debug('@@@ DML2 ' + Limits.getDmlRows());
            System.debug('@@@ DML2 ' + Limits.getDmlStatements());
            System.debug('@@@ DML2 ' + Limits.getLimitDmlRows());
            System.debug('@@@ DML2 ' + Limits.getLimitDmlStatements());
            System.debug('@@@ DML2 ' + Limits.getQueueableJobs());
            System.debug('@@@ DML2 ' + Limits.getLimitQueueableJobs());

            HTTPResponse res = http.send(req);

            logArricchimento.InputPayload__c = doc.toXmlString();
            logArricchimento.OutputPayload__c = res.getBody().length() > 131072 ? res.getBody().substring(0,131072) : res.getBody();

            if(res.getStatusCode() == 200){
                Dom.Document responseDoc = res.getBodyDocument();
                Dom.XMLNode root = responseDoc.getRootElement();

                // PARSO L'XML

                String nameSpace='http://schemas.xmlsoap.org/soap/envelope/';
                String namespace2 = 'urn:ws.ribes.it/BInformationV4';

                Dom.XMLNode RISPOSTA = root.getChildElement('Body',namespace).getChildElement('getPaginaResponse',namespace2).getChildElement('return',namespace2).getChildElement('WSRBS',null).getChildElement('TRANSAZIONE',null).getChildElement('RISPOSTA',null);

                if(RISPOSTA != null){
                    Dom.XmlNode lista = RISPOSTA.getChildElement('Prodotto', null).getChildElement('Lista', null);
                    Dom.XmlNode listaNote = lista.getChildElement('ListaNote', null);
                    if(Integer.valueOf(listaNote.getAttribute('numeroPosizioniTotali', null)) > 0){
                        for(Dom.XMLNode Soggetto : listaNote.getChildElements()){
                            String provincia = Soggetto.getChildElement('InfoImpresa', null).getChildElement('KRea',null).getChildElement('Cciaa',null).getAttribute('sigla',null);
                            String rea = Soggetto.getChildElement('InfoImpresa', null).getChildElement('KRea', null).getChildElement('NRea', null).getText();
                            String cf = Soggetto.getChildElement('InfoImpresa', null).getChildElement('CodiceFiscale', null).getText();
                            // String notaId;
                            List<String> noteIds = new List<String>();
                            List<Dom.XmlNode> listaNoteSoggetti = Soggetto.getChildElement('ElencoNote', null).getChildElements();
                            if(listaNoteSoggetti.size() > 0){
                                for(Dom.XmlNode nota : listaNoteSoggetti){
                                    noteIds.add(nota.getChildElement('IDNota', null).getText());
                                }
                                // notaId = listaNoteSoggetti[0].getChildElement('IDNota', null).getText();
                            }


                            // if(rea != null && notaId != null){
                            //     note_REA.add(new Map<String,String>{'rea' => rea, 'notaId' => notaId, 'cf' => cf});
                            // }
                            if(rea != null && !noteIds.isEmpty()){
                                for(String notaId : noteIds){
                                    note_REA.add(new Map<String,String>{'rea' => rea, 'provincia' => provincia, 'notaId' => notaId, 'cf' => cf});
                                }
                            }
                        }

                        if(!note_REA.isEmpty()){
                            // System.abortJob(jobToAbort);
                            // TXT_Monitoraggi t = new TXT_Monitoraggi(note_REA, nPag, this.ticketId);
                            // System.enqueueJob(t);
                            // String hour = Datetime.now().hour() > 24 ? 0 : ;
                            // String min = String.valueOf(Datetime.now().minute());
                            // String ss = String.valueOf(Datetime.now().second());
                            // String day = String.valueOf(Datetime.now().day());
                            // String month = String.valueOf(Datetime.now().month());
                            // String year = String.valueOf(Datetime.now().year());

                            //parse to cron expression
                            // String schedulazione = ss + ' ' + min + ' ' + hour + ' ' + day + ' ' + month + ' ? ' + year;
                            Datetime dt = Datetime.now().addSeconds(30);
                            String schedulazione = String.valueOf(dt.second()) + ' ' + String.valueOf(dt.minute()) + ' ' + String.valueOf(dt.hour()) + ' ' + String.valueOf(dt.day()) + ' ' + String.valueOf(dt.month()) + ' ? ' + String.valueOf(dt.year());
                            // '0 12 11 11 NOV ? 2021'
                            System.debug('@@@ s ' + schedulazione);
                    
                            System.schedule('Innolva Monitoraggi - GetProdottoDaNota ' + nPag + dt, schedulazione, new TXT_Monitoraggi_Sched(note_REA, nPag, ticketId));
                        }
                    }
                }
            } else {
                System.debug('@@@ error chiamata ' + res.getBody());
                logArricchimento.ErrorMessage__c = String.valueOf(res.getStatusCode());
                logArricchimento.Success__c = false;
            }
        } catch (Exception e){
            System.debug('@@@ eccezione ' + e.getStackTraceString() + ' --- ' + e.getMessage());
            Map<String,String> tmp = new Map<String,String>();
            tmp.put('error', e.getStackTraceString() + ' --- ' + e.getMessage());
            // this.note_REA_Errors.add(tmp);

            logArricchimento.ErrorMessage__c = e.getStackTraceString() + ' --- ' + e.getMessage();
            logArricchimento.Success__c = false;
            // Log__c l = new Log__c(
            //     InputPayload__c = JSON.serializePretty(this.note_REA_Errors)
            // );
    
            // insert l;
        }

        insert logArricchimento;
    }

    public void finish(Database.BatchableContext info) {
        //saleforce case n. 43681804 -- AMS-001144
        f.TXT_Abilita_monitoraggio__c = true;
        update f;
    }
}