global class WGC_BatchUpdateOpportunity implements Database.Batchable<sObject>, Database.AllowsCallouts,  Database.Stateful
{
    private static final String VALUTAZ_PRATICA = '1';
    private static final String FIRMA_CONTRATTI = '11';
    private static final String AVANZAMENTO_VAL_PRATICA = '6';
    private static final String NON_DELIBERATA_PERSA = '5';
    private static final String PEF_DELIBERATA = '4';
    private static final String CEDACRI_DELIBERATA = '10';
    private static final String CEDACRI_NON_DELIBERATA = '7';
    
    private static final String PREDISP_CONTRATTO = 'Predisposizione Contratto';
    private static final String PERSA = 'Persa';
    private static final String PERF_CONTRATTI = 'Perfezionamento Contratto';
    private static final String PEF_DECLINATA = 'Pratica declinata';
    
    global map<id, Opportunity> gblOppMap; //= new Map<Id,Opportunity>();
    global map<id, Linea__c> gblLineeMap; //= new map<id, Linea__c>();
    //global List<WGC_WsUtils_Cart.PEF40Input> lineeToPEF40; //= new List<WGC_WsUtils_Cart.PEF40Input>();
    
    /*global WGC_BatchUpdateOpportunity()
    {
        gblOppMap = new Map<Id,Opportunity>();
        gblLineeMap = new map<id, Linea__c>();
        lineeToPEF40 = new List<WGC_WsUtils_Cart.PEF40Input>();
    }*/
    
    global Database.QueryLocator start(Database.BatchableContext BC)
    {
        /**
* @description: il metodo esegue una query includendo in automatico tutti i campi dell'oggetto
* @param objectApiName: nome API oggetto su cui eseguire la query
* @return: lista di risultati di tipo "sObject" generico. È possibile fare il cast del risulta in una lista dell'oggetto specifico
*/ 
        Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        Map<String, Schema.SObjectField> fieldMap = schemaMap.get('Opportunity').getDescribe().fields.getMap();
        list<string> list_field = new list<string>(fieldMap.keyset());
        
        string qrSelect = 'select '+string.join(list_field , ',')+ ',(SELECT Id, Name, Opportunity__r.Originator__c, '+
            ' Opportunity__r.Originator_di_dettaglio__c, '+
            ' Prodotto__r.Codice__c, Stato__c FROM Linee__r) ';//SELECT con tutti i campi dell'oggetto
        string qrFrom = ' from Opportunity';//FROM oggetto
        string qrWhere = ' where RecordType.Developername  =  \'IFISOpportunitaFactoring\' and '+
            'StageName not in (\'Attivazione\',\'Persa\', \'Vinta\', \'In Istruttoria\',\'Perfezionamento Contratto\') and '+
            'WGC_Codice_Pratica__c != null'; //WHERE filtri query
        string qrOrder = ' order by '; //ORDER BY ordinamento risultati query
        
        //creo una variabile di tipo "Tipo lista<Oggetto>"
        //System.Type listType = System.Type.forName('List<Opportunity>');
        //istanzio una lista vuota del tipo "listType", in modo da poter fare il cast di "result" nel tipo corretto al di fuori del metodo
        //List<SObject> result = (List<SObject>)listType.newInstance();
        
        //aggiungere where/order se correttamente valorizzati nelle variabili
        //---(la lista funziona anche con un solo record: se non trova nulla non va in errore ma restituisce una lista vuota)---
        //result = database.query(qrSelect + qrFrom /*+ qrWhere + qrOrder*/);
        
        return Database.getQueryLocator(qrSelect + qrFrom + qrWhere);
    }
    
    global void execute(Database.BatchableContext BC, List<Opportunity> scope)
    {
        system.debug('scoper '+ scope.size());
        set<id> oppId = new set<id>();
        Map<String,List<Linea__c>> lineeMap = new  Map<String,List<Linea__c>>();
        set<id> accId = new set<id>();
        for(Opportunity oppo : scope)
        {
            if(oppo.Linee__r.size() > 0) lineeMap.put(oppo.id, oppo.linee__r);
            accId.add(oppo.AccountId);
        }
        map<string, account> mapAcc = new map<string, account>([SELECT Id, CodiceIstituto3N__c, NDGGruppo__c FROM Account WHERE Id in :accId]);
        for(Opportunity oppo : scope)
        {
            //WizardOpportunityController.WrapperResponseWs response = WizardOpportunityController.asyncLoadDatiPEF(oppo.accountId, oppo.Id);
            
            WizardOpportunityController.WrapperResponseWS resp = new WizardOpportunityController.WrapperResponseWS();
            
            // DO SOMETHING
            try {
                /*if (oppo.WGC_Codice_Pratica__c == null) {
                resp.success = false;
                resp.msg = 'Codice pratica mancante.';
                SObjectException err = new SObjectException();
                err.setMessage('Codice pratica mancante.');
                //throw err;
                system.debug(err);
                break;
				}*/
                
                WGC_WSUtils_Cart.DatiPEFInput input = new WGC_WSUtils_Cart.DatiPEFInput();
                input.codNdg = Long.valueOf(mapAcc.get(oppo.AccountId).NDGGruppo__c);
                input.codiceIstituto3N = Integer.valueOf(mapAcc.get(oppo.AccountId).CodiceIstituto3N__c);
                input.codPratica = Integer.valueOf(oppo.WGC_Codice_Pratica__c);
                WGC_WSUtils_Cart.DatiPEFResponse response = (!test.isRunningTest())? WGC_WSUtils_Cart.loadDatiPEF(input) : new WGC_WSUtils_Cart.DatiPEFResponse();
                
                resp.data = response;
                
                if(resp.data == null && !test.isRunningTest()){
                    continue;
                }
                if(test.isRunningTest())
                {
                    resp.data = (WGC_WSUtils_Cart.DatiPEFResponse) JSON.deserialize(TestMockUtils.PAYLOAD_DATI_PEF, WGC_WSUtils_Cart.DatiPEFResponse.class);
                }
                
                WGC_WsUtils_Cart.DatiPEFResponse datiPef = (WGC_WsUtils_Cart.DatiPEFResponse)resp.data;
                system.debug('datiPef '+ datiPef);
                List<WGC_WsUtils_Cart.LineaCredito> listaLinee = datiPef.payload.outputRichiesta.elencoLineeCredito;
                
                if (datiPef.payload.outputRichiesta.desStatoPratica != null || datiPef.payload.outputRichiesta.desStatoPratica != ''){
                    oppo.BI_Stato_Pratica_PEF__c = datiPef.payload.outputRichiesta.desStatoPratica;
                    System.debug('@@@A.M. desStatoPratica: ' + oppo.BI_Stato_Pratica_PEF__c);
                }
                if (datiPef.payload.outputRichiesta.desTipoPratica != null || datiPef.payload.outputRichiesta.desTipoPratica != ''){
                    oppo.BI_Tipo_Pratica_PEF__c = datiPef.payload.outputRichiesta.desTipoPratica;
                    System.debug('@@@A.M. desTipoPratica: ' + oppo.BI_Tipo_Pratica_PEF__c);
                }
                
                if (datiPef.payload.outputRichiesta.codRuoloDeliberante != null && datiPef.payload.outputRichiesta.codRuoloDeliberante != '' && datiPef.payload.outputRichiesta.datDelibera != null ){
                    oppo.WGC_Organo_Deliberante__c = datiPef.payload.outputRichiesta.codRuoloDeliberante;
                    oppo.WGC_Data_Delibera_PEF__c = DateTime.newInstance(datiPef.payload.outputRichiesta.datDelibera).date();
                }
                
                for(WGC_WsUtils_Cart.Nota nota : datiPef.payload.outputRichiesta.elencoNote)
                {
                    if ((nota.codTipoNota != null || nota.codTipoNota != '') && nota.codTipoNota == 'VAL')
                    {
                        oppo.WGC_Tipologia_Nota__c = nota.codTipoNota;
                        System.debug('@@@A.M. codTipoNota: ' + oppo.WGC_Tipologia_Nota__c);
                        
                        if (nota.desTestoNota != null || nota.desTestoNota != '')
                        {
                            string desNota = nota.desTestoNota;
                            oppo.WGC_Descrizione_Nota__c = (desNota.length() > 131072)? desNota.substring(0,131072) : desNota;
                            System.debug('@@@A.M. desTestoNota: ' + oppo.WGC_Descrizione_Nota__c);
                        }
                        if (nota.datInserimNota != null)
                        {
                            oppo.WGC_Data_Ultimo_inserimento__c = DateTime.newInstance(nota.datInserimNota).date();
                            System.debug('@@@A.M. datInserimNota: ' + oppo.WGC_Data_Ultimo_inserimento__c);
                        }
                    }
                }
                
                //Nota Deliberante
                for(WGC_WsUtils_Cart.Nota nota : datiPef.payload.outputRichiesta.elencoNote)
                {
                    if ((nota.codTipoNota != null || nota.codTipoNota != '') && nota.codTipoNota == 'DEL')
                    {
                        oppo.Tipo_Nota_Deliberante__c = nota.codTipoNota;
                        System.debug('@@@A.M. codTipoNota: ' + oppo.Tipo_Nota_Deliberante__c);
                        
                        if (nota.desTestoNota != null || nota.desTestoNota != '')
                        {
                            string desNota = nota.desTestoNota;
                            oppo.Nota_Deliberante__c = (desNota.length() > 131072)? desNota.substring(0,131072) : desNota;
                            System.debug('@@@A.M. desTestoNota: ' + oppo.Nota_Deliberante__c);
                        }
                        if (nota.datInserimNota != null)
                        {
                            oppo.Data_ultima_inserimento_nota_deliberante__c = DateTime.newInstance(nota.datInserimNota).date();
                            System.debug('@@@A.M. datInserimNota: ' + oppo.Data_ultima_inserimento_nota_deliberante__c);
                        }
                    }
                }
                
                if (oppo.BI_Stato_Pratica_PEF__c != null  ||  oppo.BI_Tipo_Pratica_PEF__c != null || oppo.WGC_Organo_Deliberante__c != null ||  oppo.WGC_Tipologia_Nota__c != null|| oppo.WGC_Descrizione_Nota__c != null|| oppo.WGC_Data_Ultimo_inserimento__c!= null || oppo.Data_ultima_inserimento_nota_deliberante__c!=null ||
                          oppo.Tipo_Nota_Deliberante__c != null || oppo.Nota_Deliberante__c!= null)
                {
                    update oppo; 
                 
                    //gblOppMap.put(oppo.id, oppo);
                    //system.debug('derntroooo '+ gblOppMap.size());
                }
                
                Map<WGC_WsUtils_Cart.OutputRichiestaWrapper, List<WGC_WsUtils_Cart.LineaCredito>> mappaCredito = new Map<WGC_WsUtils_Cart.OutputRichiestaWrapper, List<WGC_WsUtils_Cart.LineaCredito>>();
                mappaCredito.put(datiPef.payload.outputRichiesta, listaLinee);
                
                
                List<WGC_WsUtils_Cart.PEF40Input> lineeToPEF40 = new List<WGC_WsUtils_Cart.PEF40Input>();
                
                List<WGC_WsUtils_Cart.OutputRichiestaWrapper> keyMappaCredito = new List<WGC_WsUtils_Cart.OutputRichiestaWrapper>(mappaCredito.keySet());
                
                for(WGC_WsUtils_Cart.LineaCredito linea : mappaCredito.values().get(0)){
                    for(Linea__c lineaCRM : lineeMap.get(oppo.Id)){
                        if((linea.codGestione == 'N' || linea.codGestione == 'R') && linea.codLineaSistema == lineaCRM.Prodotto__r.Codice__c){
                            WGC_WsUtils_Cart.PEF40Input inputPef40 = new WGC_WsUtils_Cart.PEF40Input(keyMappaCredito.get(0), linea, lineaCRM);
                            lineeToPEF40.add(inputPef40);
                            
                            //SDHDFNZ-124486 - Aggiornamento stato linee -> viene fatto qui per "riciclare" la chiamata al ws datiPef
                            lineaCRM.Stato__c = linea.codStatoLinea == '003' ? FIRMA_CONTRATTI : (linea.codStatoLinea == '004' ? NON_DELIBERATA_PERSA : VALUTAZ_PRATICA);
                                System.debug('@@@A.M. Aggiornamento lineaCRM: ' + lineaCRM);
                            update lineaCRM;
                            //gblLineeMap.put(lineaCRM.id, lineaCRM);
                        }
                    }
                }
                
                if(!lineeToPEF40.isEmpty()){
                    Id jobId = System.enqueueJob(new WGC_QbleInvioCanaleVendita(lineeToPEF40));
                }
                else{
                    continue;
                }
                
                
            } catch (Exception e) {
                resp.success = false;
                resp.msg = e + 'Info '+e.getMessage()+e.getStackTraceString()+e.getLineNumber();
                CalloutException  err = new CalloutException ();
                err.setMessage(e.getMessage()+e.getStackTraceString()+e.getLineNumber());
                system.debug(err);
                system.debug(resp);
                //throw err;
                throw e;
            }
        }
    }
    
    global void finish(Database.BatchableContext BC)
    {
        //system.debug(gblOppMap.size());
        //system.debug(gblLineeMap.size());
        
        //update gblOppMap.values();
        //update gblLineeMap.values();
        
        /*if(!lineeToPEF40.isEmpty()){
            Id jobId = System.enqueueJob(new WGC_QbleInvioCanaleVendita(lineeToPEF40));
        }*/
        
        AsyncApexJob aaj = [SELECT Id, NumberOfErrors, Status, JobType, JobItemsProcessed, CompletedDate FROM AsyncApexJob WHERE Id =: BC.getJobId()];
        System.debug('@@@ query sul job ' + aaj);
    }
}