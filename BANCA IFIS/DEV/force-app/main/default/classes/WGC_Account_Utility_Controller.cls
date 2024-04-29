/**
 * @description       : 
 * @author            : simone.viglianti@tengroup.it
 * @group             : 
 * @last modified on  : 10-10-2022
 * @last modified by  : simone.viglianti@tengroup.it
**/
public class WGC_Account_Utility_Controller {

    //EVENTI NEGATIVI
    //Metodo per recuperare i dati di eventi negativi da ribes
    @AuraEnabled
    public static WrapperResponse callServiceEventiNegativi(String accountId){
        System.debug('@@@ accountId ' + accountId);
        
        Account acc = [ SELECT Id, REA__c, ProvinciaCCIAA__c, EventiNegativiIdTicket__c, EventiNegativiGlobale__c,
                              EventiNegativiProtesti__c, EventiNegativiPregiudizievoli__c, EventiNegativiProcedureConcorsuali__c,
                              EventiNegativiCIGS__c, EventiNegativiAllarmiQuote__c, WGC_UltimaRichiestaEventiNegativi__c,
                              NDGGruppo__c, codiceIstituto3N__c
                        FROM Account 
                        WHERE Id=:accountId ];
        
        if(acc.codiceIstituto3N__c != '881'){
            WrapperResponse resp = new WrapperResponse();
            resp.success = false;
            resp.msg = 'Anagrafica con codice istituto diverso da 881';

            return resp;
        }
        //WSRestRibesUtils.EventiNegativiPlain risposta = new WSRestRibesUtils.EventiNegativiPlain();
        WsRestRibes.GetEventiNegativiResponse risposta = new WsRestRibes.GetEventiNegativiResponse();
        WsRestRibes.GetEventiNegativiResponse rispostaPDF = new WsRestRibes.GetEventiNegativiResponse();
        WrapperResponse responseFinal = new WrapperResponse();
        Id documentPDF;

        System.debug('@@@ acc.WGC_UltimaRichiestaEventiNegativi__c ' + acc.WGC_UltimaRichiestaEventiNegativi__c );
        System.debug('@@@ Today - 1 months ' + Date.today().addMonths(-1) );
        if (acc.WGC_UltimaRichiestaEventiNegativi__c == null || (acc.WGC_UltimaRichiestaEventiNegativi__c != null && acc.WGC_UltimaRichiestaEventiNegativi__c < Date.today().addMonths(-6) )) {

            try{
                risposta =  WsRestRibes.getEventiNegativi(acc.REA__c, acc.ProvinciaCCIAA__c, 'S', 'XML', null, String.valueOf(acc.NDGGruppo__c));
                System.debug('@@@ responseEvent ' + JSON.serialize(risposta));
                //System.debug('@@@ documentPDF Id ' + documentPDF);

                if (risposta.isCorrect()) {
                    acc.EventiNegativiIdTicket__c = risposta.getTicketId();
                    acc.WGC_UltimaRichiestaEventiNegativi__c = Date.today();

                    WsRestRibes.Sintesi sintesi = risposta.getSintesi();
                    if (sintesi != null) {
                        if (sintesi.globale != null) {
                        acc.EventiNegativiGlobale__c = sintesi.globale.semaforo;
                        }
                        if (sintesi.protesti != null) {
                        acc.EventiNegativiProtesti__c = sintesi.protesti.semaforo;
                        }
                        if (sintesi.pregiudizievoli != null) {
                        acc.EventiNegativiPregiudizievoli__c = sintesi.pregiudizievoli.semaforo;
                        }
                        if (sintesi.procedureConcorsuali != null) {
                        acc.EventiNegativiProcedureConcorsuali__c = sintesi.procedureConcorsuali.semaforo;
                        }
                        if (sintesi.cigs != null) {
                        acc.EventiNegativiCIGS__c = sintesi.cigs.semaforo;
                        }
                        if (sintesi.allarmiQuote != null) {
                        acc.EventiNegativiAllarmiQuote__c = sintesi.allarmiQuote.semaforo;
                        }
                    }
                    //Chiamata per generare il pdf
                    // rispostaPDF = WsRestRibes.getEventiNegativi(acc.REA__c, acc.ProvinciaCCIAA__c, 'A', 'PDF', acc.EventiNegativiIdTicket__c.longValue(), acc.NDGGruppo__c);
                    // System.debug('@@@ rispostaPDF ' + JSON.serialize(rispostaPDF));
					//A.M. Modifica Inforpovider RIBES -> CERVED (non è necessaria la seconda chiamata per il recupero del PDF
                    //getPDF_EventiNegativi(acc.Id);
                    upsert acc;

                    responseFinal.data.add(acc);
                    System.debug('@@@ response final ' + JSON.serialize(responseFinal.data));

                }
                
            }
            catch (Exception e){
                System.debug('@@@ exception message ' + e.getMessage());
                responseFinal.success = false;
                responseFinal.msg = e.getMessage();
                //throw new AuraHandledException(e.getMessage());
                System.debug('@@@ responseFinal ' + responseFinal);
            }
        } else {
            responseFinal.success = true;
            responseFinal.msg = 'Chiamata odierna già effettuata';
            responseFinal.data.add(acc); 
        }

        return responseFinal;
    }

    @Future(callout=true)
    @AuraEnabled
    public static void getPDF_EventiNegativi(String accId){
	
		Account actualAccount;

		try{

			actualAccount = [ SELECT Id, REA__c, ProvinciaCCIAA__c, EventiNegativiIdTicket__c, EventiNegativiGlobale__c,
					EventiNegativiProtesti__c, EventiNegativiPregiudizievoli__c, EventiNegativiProcedureConcorsuali__c,
					EventiNegativiCIGS__c, EventiNegativiAllarmiQuote__c, WGC_UltimaRichiestaEventiNegativi__c,
					NDGGruppo__c, codiceIstituto3N__c
			FROM Account 
			WHERE Id=:accId ];

			String eventiNegativiTicketId = null;

			// CONTROLLO DI SICUREZZA NEL CASO IL TICKET ID NON SIA VALORIZZATO (IN CASO DI CHIAMATA PRECEDENTE ANDATA KO)
			// COSA GIA' VERIFICATA IN PRD E QUINDI BONIFICATA CON IL CONTROLLO SOTTO.

			if(actualAccount.EventiNegativiIdTicket__c != null){
			
				eventiNegativiTicketId = actualAccount.EventiNegativiIdTicket__c;
			
			}

			WsRestRibes.GetEventiNegativiResponse rispostaPDF = new WsRestRibes.GetEventiNegativiResponse();
			rispostaPDF = WsRestRibes.getEventiNegativi(actualAccount.REA__c, actualAccount.ProvinciaCCIAA__c, 'A', 'PDF', eventiNegativiTicketId, actualAccount.NDGGruppo__c);

		}
		catch(Exception ex){

			BI_COM_AppLogFacade_CODE.insertAppLog(BI_COM_AppLogFacade_CODE.Threshold.ERROR,WGC_Account_Utility_Controller.class.getName(),accId,ex.getTypeName() + ' - ' + ex.getStackTraceString(),String.valueOf(actualAccount));
		
		}

    }

    //ABILITAZIONE BOTTONI (TOP DX)
    //Metodo per recuperare Task ed Event collegati all'Account ed esitati
    @AuraEnabled
    public static WrapperResponse accountHasHesitatedTaskOrEvent(String accountId) {
        WrapperResponse responseFinal = new WrapperResponse();

        try {
            List<Task> tasksOpen = [ SELECT Id 
                                     FROM Task 
                                     WHERE AccountId = :accountId 
                                        AND RecordType.DeveloperName != 'Promemoria'
                                        AND (NOT RecordType.DeveloperName LIKE '%Diario%')
                                        AND EsitoLivello1__c = null];
            List<Event> eventsOpen = [SELECT Id FROM Event WHERE AccountId = :accountId AND EsitoLivello1__c = null];
            List<Task> tasks = [SELECT Id FROM Task WHERE AccountId = :accountId AND StatoEsitazione__c = 'Esitato'];
            List<Event> events = [SELECT Id FROM Event WHERE AccountId = :accountId AND StatoEsitazione__c = 'Esitato'];
            responseFinal.success = true;
            responseFinal.msg = '';
            Map<String, Object> m = (Map<String, Object>) JSON.deserializeUntyped('{"data":{"task":'+(tasks.size() > 0)+',"event":'+(events.size() > 0)+', "taskOpen" : '+(tasksOpen.size() > 0)+', "eventOpen" : '+(eventsOpen.size() > 0)+'}}');
            responseFinal.data = new List<Object>();
            responseFinal.data.add(m.get('data'));
            System.debug('@@@ responseFinal task event' + JSON.serialize(responseFinal));
            if(Test.isRunningTest()) throw new TestException();

        } catch (Exception e) {
            responseFinal.success = false;
            responseFinal.msg = e.getMessage();
            responseFinal.data = null;
        }

        return responseFinal;
    }

    //Metodo per recuperare i dati referenti all'header dell'account come le iniziative e i prodotti attivi e la marginalità e le campagne attive
    @AuraEnabled
    public static WrapperResponse getAccountHeaderData(String accountId){
        System.debug('@@@ accountId ' + accountId);
        //Istanzio il wrapper che ritornerà i valori al componente
        WrapperResponse wr = new WrapperResponse();
        Response r = new Response();
        //Recupero le campagne collegate all'account
        List<CampaignMember> countCampagne = [SELECT Id, Name, CompanyOrAccount, AccountId__c, ContactId, Contact.Account.Name FROM CampaignMember WHERE Contact.AccountId =: accountId AND Campaign.Status != 'Completata' ];
        System.debug('@@@ lista di campaign member ' + countCampagne);
        System.debug('@@@ size lista di campaign member ' + countCampagne.size());
        r.countCampagne = countCampagne;
        //wr.data.add(countCampagne.size());
        //Recupero i dati del bilancio
        //TODO : da modificare con il campo in cui è contenuto il dato, probabilmente campo su account
        //List<WGC_Bilancio__c> lstBilancio = [SELECT Id, Name FROM WGC_Bilancio__c WHERE Account__c =: accountId];
        //System.debug('@@@ lista bilancio ' + lstBilancio);
        
        //wr.data.add(lstBilancio);
        //Recupero i dati del prodotto in base al record type
        List<Account> myAccount = new List<Account>();
        myAccount = [SELECT Id, NDGGruppo__c, codiceIstituto3N__c FROM Account WHERE Id =: accountId];
        System.debug('myAccount = ' + myAccount);
        List<Account> listLE = new List<Account>();
        listLE = WGC_LegalEntity_Utility.getLinkLegalEntity(myAccount.get(0).NDGGruppo__c, myAccount.get(0).codiceIstituto3N__c);
        
        List<WGC_Linea_Prodotto__c> lstProdottiFactoringCed = new List<WGC_Linea_Prodotto__c>();
        List<WGC_Linea_Prodotto__c> lstProdottiFactoringDeb = new List<WGC_Linea_Prodotto__c>();
        List<WGC_Linea_Prodotto__c> lstProdottiLeasing = new List<WGC_Linea_Prodotto__c>();
        List<WGC_Linea_Prodotto__c> lstProdottiFinanziamento = new List<WGC_Linea_Prodotto__c>();
        List<WGC_Linea_Prodotto__c> lstProdottiAltro = new List<WGC_Linea_Prodotto__c>();

        //Se ho altra legal entity conteggio anche i prodotti delle altre Legal Entity
        if(listLE != null && !listLE.isEmpty()){
            lstProdottiFactoringCed = [SELECT Id, Name FROM WGC_Linea_Prodotto__c WHERE Anagrafica__c IN : listLE AND (RecordType.DeveloperName = 'FACTORINGCEDENTE' OR RecordType.DeveloperName = 'FACTORINGFISCALE') AND (Stato__c = 'Attivo' OR Stato__c = 'ACTIVE')];
            lstProdottiFactoringDeb = [SELECT Id, Name FROM WGC_Linea_Prodotto__c WHERE Anagrafica__c IN : listLE AND RecordType.DeveloperName = 'FACTORINGDEBITORE' AND (Stato__c = 'Attivo' OR Stato__c = 'ACTIVE')];
            lstProdottiLeasing = [SELECT Id, Name FROM WGC_Linea_Prodotto__c WHERE Anagrafica__c IN : listLE AND RecordType.DeveloperName = 'LEASING' AND (Stato__c = 'Attivo' OR Stato__c = 'ACTIVE')];
            lstProdottiFinanziamento = [SELECT Id, Name FROM WGC_Linea_Prodotto__c WHERE Anagrafica__c IN : listLE AND RecordType.DeveloperName = 'FINANZIAMENTI' AND (Stato__c = 'Attivo' OR Stato__c = 'ACTIVE')];
            lstProdottiAltro = [SELECT Id, Name FROM WGC_Linea_Prodotto__c WHERE Anagrafica__c IN : listLE AND (Stato__c = 'Attivo' OR Stato__c = 'ACTIVE') AND (RecordType.DeveloperName = 'GARANZIE' OR  RecordType.DeveloperName = 'CREDITIPROBLEMATICI' OR  RecordType.DeveloperName = 'SERVIZIBANCARI' OR  RecordType.DeveloperName = 'CREDITIDIFIRMA' OR RecordType.DeveloperName = 'NPL' OR RecordType.DeveloperName = 'CREDITIERARIALI' OR RecordType.DeveloperName = 'Anticipo_Fatture' OR RecordType.DeveloperName = 'Portafoglio_Commerciale')];
        }
        else{
            lstProdottiFactoringCed = [SELECT Id, Name FROM WGC_Linea_Prodotto__c WHERE Anagrafica__c =: accountId AND (RecordType.DeveloperName = 'FACTORINGCEDENTE' OR RecordType.DeveloperName = 'FACTORINGFISCALE') AND (Stato__c = 'Attivo' OR Stato__c = 'ACTIVE')];
            lstProdottiFactoringDeb = [SELECT Id, Name FROM WGC_Linea_Prodotto__c WHERE Anagrafica__c =: accountId AND RecordType.DeveloperName = 'FACTORINGDEBITORE' AND (Stato__c = 'Attivo' OR Stato__c = 'ACTIVE')];
            lstProdottiLeasing = [SELECT Id, Name FROM WGC_Linea_Prodotto__c WHERE Anagrafica__c =: accountId AND RecordType.DeveloperName = 'LEASING' AND (Stato__c = 'Attivo' OR Stato__c = 'ACTIVE')];
            lstProdottiFinanziamento = [SELECT Id, Name FROM WGC_Linea_Prodotto__c WHERE Anagrafica__c =: accountId AND RecordType.DeveloperName = 'FINANZIAMENTI' AND (Stato__c = 'Attivo' OR Stato__c = 'ACTIVE')];
            lstProdottiAltro = [SELECT Id, Name FROM WGC_Linea_Prodotto__c WHERE Anagrafica__c =: accountId AND (Stato__c = 'Attivo' OR Stato__c = 'ACTIVE') AND (RecordType.DeveloperName = 'GARANZIE' OR  RecordType.DeveloperName = 'CREDITIPROBLEMATICI' OR  RecordType.DeveloperName = 'SERVIZIBANCARI' OR  RecordType.DeveloperName = 'CREDITIDIFIRMA' OR RecordType.DeveloperName = 'NPL' OR RecordType.DeveloperName = 'CREDITIERARIALI' OR RecordType.DeveloperName = 'Anticipo_Fatture' OR RecordType.DeveloperName = 'Portafoglio_Commerciale')];
        }

        System.debug('@@@ lstProdottiFactoringCed ' + lstProdottiFactoringCed);
        System.debug('@@@ lstProdottiFactoringDeb ' + lstProdottiFactoringDeb);
        System.debug('@@@ lstProdottiFinanziamento ' + lstProdottiFinanziamento);
        System.debug('@@@ lstProdottiAltro ' + lstProdottiAltro);

        r.lstProdottiFactoringCed = lstProdottiFactoringCed;
        r.lstProdottiFactoringDeb = lstProdottiFactoringDeb;
        r.lstProdottiLeasing = lstProdottiLeasing;
        r.lstProdottiFinanziamento = lstProdottiFinanziamento;
        r.lstProdottiAltro = lstProdottiAltro;
        /*
        wr.data.add(lstProdottiFactoringCed);
        wr.data.add(lstProdottiFactoringDeb);
        wr.data.add(lstProdottiFinanziamento);
        wr.data.add(lstProdottiAltro);
        */

        //Recupero i task ed eventi da inserire nella sezione iniziative
        List<Task> lstT = [SELECT AccountId, Account.Name, Subject, ActivityDate, OwnerId, WhoId, RecordType.DeveloperName, DataOraEsitazione__c, Data_Inizio__c, Data_Fine__c
                            FROM Task 
                            WHERE DataOraEsitazione__c >= LAST_N_DAYS:365 AND
                                AccountId =: accountId AND
                                StatoEsitazione__c = 'Esitato' AND
                                RecordType.DeveloperName != 'WGC_Diario_Inserimento_Campagna'
                            ORDER BY DataOraEsitazione__c DESC];
        List<Event> lstE = [SELECT AccountId, Account.Name, Subject, ActivityDateTime, OwnerId, WhoId, StartDateTime, EndDateTime, Data_Inizio__c, Data_Fine__c, StatoEsitazione__c 
                            FROM Event 
                            WHERE ActivityDateTime >= LAST_N_DAYS:365 AND
                                AccountId =: accountId AND
                                StatoEsitazione__c = 'Esitato'
                            ORDER BY StartDateTime DESC];

            r.lstT = lstT;
            r.lstE = lstE;

        Account a = new Account();
        a = [SELECT Id, Name, WGC_MDI_PY__c, WGC_MDI_CY__c, Ateco__c, NaturaGiuridica__c FROM Account WHERE Id =: accountId];

        if(a.get('Id') != null){
            //wr.data.add(a);
            r.bilancio = a;
        }

		//SDCHG-5172 - Aggiunta ricerca descrizione Ateco e Natura Giuridica inseriti nell'header
		if(!(a.Ateco__c == '' || a.Ateco__c == null)){
          List<Ateco__c> ateco = new List<Ateco__c>();
          //MS factory start Aggiunto campo Status__c e cambiati parametri
          ateco = [ SELECT Id, Name, Cedacri__c, Descrizione__c, Status__c FROM Ateco__c WHERE Cedacri__c =: a.Ateco__c LIMIT 1];
          if (ateco.size() > 0){
			r.descrizioneAteco = ateco[0].Descrizione__c;
            wr.atecoStatus = ateco[0].Status__c;
            //MS factory end
          } else {
			r.descrizioneAteco = '';
          }
        }

		for (Schema.PicklistEntry f : Account.NaturaGiuridica__c.getDescribe().getPicklistValues()) {
		  if (f.getValue().equals(a.NaturaGiuridica__c))	{	
			r.naturaGiuridicaDescrizione = f.getLabel();
		  }
		}
        
        wr.data.add(r);
        System.debug('@@@ response final ' + JSON.serialize(wr));
        return wr;
    }

    @AuraEnabled
    public static WrapperResponse getLegalEntities(String ndg, String codiceIstituto){
        WrapperResponse resp = new WrapperResponse();

        try {
            resp.data = (List<Object>) WGC_LegalEntity_Utility.getLinkLegalEntity(ndg, codiceIstituto);
            if(Test.isRunningTest()) throw new TestException();
        } catch (Exception e) {
            resp.msg = e.getMessage();
            resp.success = false;
        }

        return resp;
    }

    /*..........................................*/
    /* Wrapper class to display Response       */
    /*.........................................*/
    
    public class WrapperResponse {
        
        @AuraEnabled public Boolean success;
        @AuraEnabled public String msg;
        @AuraEnabled public List<Object> data;
        @AuraEnabled public String atecoStatus;
        
        public WrapperResponse(){
            success = true;
            msg = '';
            data = new List<Object>();
        }
    }

    public class Response{
        @AuraEnabled public Account bilancio;
        @AuraEnabled public List<CampaignMember> countCampagne;
        @AuraEnabled public List<WGC_Linea_Prodotto__c> lstProdottiFactoringCed;
        @AuraEnabled public List<WGC_Linea_Prodotto__c> lstProdottiFactoringDeb;
        @AuraEnabled public List<WGC_Linea_Prodotto__c> lstProdottiLeasing;
        @AuraEnabled public List<WGC_Linea_Prodotto__c> lstProdottiFinanziamento;
        @AuraEnabled public List<WGC_Linea_Prodotto__c> lstProdottiAltro;
        @AuraEnabled public List<Task> lstT;
        @AuraEnabled public List<Event> lstE;
		//SDCHG-5172 - Aggiunto campo per descrizione Ateco inserito nell'header
		@AuraEnabled public String descrizioneAteco;
		@AuraEnabled public String naturaGiuridicaDescrizione;

        // public Response(){
        //     this.bilancio = bilancio;
        //     this.countCampagne = countCampagne;
        //     this.lstProdottiFactoringCed = lstProdottiFactoringCed;
        //     this.lstProdottiFactoringDeb = lstProdottiFactoringDeb;
        //     this.lstProdottiLeasing = lstProdottiLeasing;
        //     this.lstProdottiFinanziamento = lstProdottiFinanziamento;
        //     this.lstProdottiAltro = lstProdottiAltro;
        //     this.lstT = lstT;
        //     this.lstE = lstE;

        // }
    }


    // CHIAMATA AL BILANCIO CON NUOVO SERVIZIO RIBES 11
    //IMPORTANTE
    @AuraEnabled
    public static ResponseBilancio getBilancioRibes(String accountId, String tipoBilancio){
        System.debug('@@@ accountId ' + accountId);

        Account a = new Account();
        a = [SELECT Id, Name, NDG__c, NDGGruppo__c, NDGGruppoGiuridico__c, WGC_NDG_controllante__c, 
                    CF__c, PIVA__c, codiceIstituto3N__c, Fatturato__c, WGC_Numero_dipendenti__c, NaturaGiuridica__c, ProvinciaCCIAA__c
                     FROM Account WHERE Id =: accountId];

        List<WGC_Bilancio__c> bilancio_CRMList = new List<WGC_Bilancio__c>();
                bilancio_CRMList = [ SELECT Id, PatrimonioNetto__c, DataFatturato__c
                                FROM WGC_Bilancio__c 
                                WHERE Account__c =: accountId 
                                    AND (NOT(DataFatturato__c = THIS_YEAR
                                        AND PatrimonioNetto__c = 0))
                                ORDER BY DataFatturato__c DESC LIMIT 2 ];

        List<WGC_Bilancio__c> ultimoBilancio = new List<WGC_Bilancio__c>();
        ultimoBilancio = [SELECT Id, LastModifiedDate, PatrimonioNetto__c  FROM WGC_Bilancio__c WHERE Account__c =: accountId ORDER BY DataFatturato__c DESC LIMIT 2];

        if(ultimoBilancio.size() > 0 && ultimoBilancio[0].LastModifiedDate.Date() == System.Today()){
            System.debug('@@@ data ultima modifica ' + ultimoBilancio[0].LastModifiedDate.Date());
            System.debug('@@@ Today ' + System.Today());
            ResponseBilancio resp = new ResponseBilancio();
            resp.success = true;
            resp.message = 'Chiamata odierna al bilancio già effettuata';

			//A.M. Valorizzazione Patrimonio Netto in caso di bilancio già chiamato (per valorizzare KPI commerciali)
			resp.bilancio = new WGC_Bilancio__c(PatrimonioNetto__c = ultimoBilancio[0].PatrimonioNetto__c);
			if(ultimoBilancio.size()>1)
				resp.bilancioPrecedente = new WGC_Bilancio__c(PatrimonioNetto__c = ultimoBilancio[1].PatrimonioNetto__c);

            return resp;
        }

        if(a.codiceIstituto3N__c != '881' || a.ProvinciaCCIAA__c == 'EE'){
            ResponseBilancio resp = new ResponseBilancio();
            resp.success = false;
            resp.message = 'Anagrafica con codice istituto diverso da 881';

            return resp;
        }
            
        //Lista dei bilanci da aggiornare
        List<WGC_Bilancio__c> lstBilancio = new List<WGC_Bilancio__c>();

        //Date utilizzate per recuperare gli ultimi 3 anni di bilancio
        Integer annoCorrente = System.today().Year();
        Integer annoPrecedente = System.today().addYears(-1).Year();
        Integer annoPrecedente2 = System.today().addYears(-2).Year();
        
        //Payload input
        BilancioInputGen BilancioInput = new BilancioInputGen();
        //Sostituire con Custom Settings
        BilancioInput.codiceIstituto3N = 881;
        BilancioInput.idSessioneChiamante = 'CRM';
        BilancioInput.idApplicazioneChiamante = 'CRM';
        BilancioInput.lingua = 'I';
        BilancioInput.idOperazione = '1';
        BilancioInput.utenzaCanale = '1';

        switch on tipoBilancio{
            when 'Civilistico' {
                if(a.NDGGruppo__c != null){
                    BilancioInput.ndg = Long.valueOf(a.NDGGruppo__c);
                }
            }
            when 'Consolidato' {
                if(a.NDGGruppoGiuridico__c != null){
                    BilancioInput.ndg = Long.valueOf(a.NDGGruppoGiuridico__c);
                }
            }
            when 'Controllante' {
                if(a.WGC_NDG_controllante__c != null){
                    BilancioInput.ndg = Long.valueOf(a.WGC_NDG_controllante__c);
                }
            }
        }

        if(String.isBlank(a.CF__c) && String.isBlank(a.PIVA__c)){
            ResponseBilancio response = new ResponseBilancio();
            response.message = 'L\'anagrafica non ha Codice Fiscale o Partita Iva per poter effettuare la chiamata al bilancio';
            response.success = false;
            return response;
            //return 'L\'anagrafica non ha Codice Fiscale o Partita Iva per poter effettuare la chiamata al bilancio';
        }
        
        BilancioInput.codiceFiscale = (a.NaturaGiuridica__c == 'DI' && a.NaturaGiuridica__c != null) ? a.PIVA__c : a.CF__c; 
        BilancioInput.numeroBilanci = 3;

        System.debug('@@@ BilancioInput ' + JSON.serialize(BilancioInput));

        //Wrapper Finale
        //WsRestInput input = new WsRestInput(BilancioInput);
        //System.debug('@@@ input final ' + JSON.serialize(input));
        OutputMain om = new OutputMain();
        try{
            om = WGC_WsRest.callServiceBilancio(BilancioInput);
        }
        catch(Exception e){
            ResponseBilancio resp = new ResponseBilancio();
            resp.message = 'ERRORE NELLA CHIAMATA';
            resp.success = false;

            return resp;
        }
        System.debug('@@@ prima prova ' + om);
		
        try{
        if((om != null && om.payload.listaBilanci.size() > 0) ||
            (ultimoBilancio.size() > 0 && ultimoBilancio[0].LastModifiedDate.Date() == System.Today())){
            /*
            OutputMain om = (OutputMain) JSON.deserialize(res.getBody(), OutputMain.Class);
            System.debug('@@@ output Main ' + om);
            */

            BilancioOutput bo = (BilancioOutput) JSON.deserialize(JSON.serialize(om.payload), BilancioOutput.Class);
            System.debug('@@@ Bilancio Output ' + JSON.serialize(bo));

            //Query sui record type in base al valore di tipoBilancio
            RecordType RTByType = [SELECT Id, DeveloperName FROM RecordType WHERE DeveloperName =: tipoBilancio LIMIT 1];

            //Metadati mappatura
            Map<String, SObject> cMap = U.keyBy([
                SELECT Id,
                Codice__c,
                Nome_Campo__c
                FROM WGC_Mappatura_Bilancio__mdt
                ], 'Codice__c');
            
            System.debug('@@@ cMap ' + cMap);

            for(Integer i = 0; i < bo.listaBilanci.size(); i++){

                WGC_Bilancio__c bilancio = new WGC_Bilancio__c();

                Long dataChiusuraLong;
                DateTime annoBilancio;

                Date anno;

                if(bo.listaBilanci[i].testataBilancio.dataChiusura != null){
                    dataChiusuraLong = Long.valueOf(bo.listaBilanci[i].testataBilancio.dataChiusura);
                    annoBilancio = DateTime.newInstance(dataChiusuraLong);
                    bilancio.Chiave__c = annoBilancio.Date().format() + '_' + a.NDGGruppo__c;
                }

                if(annoBilancio != null){
                    bilancio.Name = 'Bilancio ' + annoBilancio.Year();
                    bilancio.DataFatturato__c = annoBilancio.Date();
                }
                else{
                    bilancio.Name = 'Bilancio ' + System.Today().addYears(-i).Year();
                    bilancio.DataFatturato__c = System.Today().addYears(-i);
                }


                //Query per recuperare gli ultimi 3 anni di bilancio
                List<WGC_Bilancio__c> lstBilancioAnnoCorrente = new List<WGC_Bilancio__c>();
                lstBilancioAnnoCorrente = [SELECT Id, Name, DataFatturato__c, Durata_Operativa__c FROM WGC_Bilancio__c WHERE Account__c =: accountId AND RecordType.DeveloperName =: tipoBilancio AND Chiave__c =: bilancio.Chiave__c ORDER BY DataFatturato__c DESC LIMIT 1];
                System.debug('@@@ lstBilancioAnnoCorrente ' + lstBilancioAnnoCorrente);

                if(!lstBilancioAnnoCorrente.isEmpty() && lstBilancioAnnoCorrente.get(0) != null){
                    bilancio = lstBilancioAnnoCorrente.get(0);
                    System.debug('@@@ bilancio anno Corrente ' + lstBilancioAnnoCorrente.get(0));
                }
                else{
                    bilancio.Account__c = accountId;
                    if(RTByType.get('Id') != null){
                        bilancio.RecordTypeId = RTByType.Id;
                    }
                }

                System.debug('@@@ initial bilancio ' + bilancio);

                bilancio.Durata_Operativa__c = bo.listaBilanci[i].testataBilancio.durata != null ? Decimal.valueOf(bo.listaBilanci[i].testataBilancio.durata) : 12;

                bilancio.Tipo_Bilancio__c = bo.listaBilanci[i].testataBilancio.tipo.descrizione != null ? bo.listaBilanci[i].testataBilancio.tipo.descrizione : '';

                System.debug('@@@ before populate bilancio ' + bilancio);
                
                if(bo.listaBilanci[i].sezioni.statoPatrimonialeAttivo != null)
                    bilancio = populateField(bilancio, bo.listaBilanci[i].sezioni.statoPatrimonialeAttivo.listaVoci, cMap);
                
                if(bo.listaBilanci[i].sezioni.statoPatrimonialeAttivoPercentuale != null)
                    bilancio = populateField(bilancio, bo.listaBilanci[i].sezioni.statoPatrimonialeAttivoPercentuale.listaVoci, cMap);

                if(bo.listaBilanci[i].sezioni.statoPatrimonialeAttivoPercentuale != null)
                    bilancio = populateField(bilancio, bo.listaBilanci[i].sezioni.statoPatrimonialePassivo.listaVoci, cMap);

                if(bo.listaBilanci[i].sezioni.statoPatrimonialePassivoPercentuale != null)
                    bilancio = populateField(bilancio, bo.listaBilanci[i].sezioni.statoPatrimonialePassivoPercentuale.listaVoci, cMap);

                if(bo.listaBilanci[i].sezioni.contoEconomico != null)
                    bilancio = populateField(bilancio, bo.listaBilanci[i].sezioni.contoEconomico.listaVoci, cMap);
                
                if(bo.listaBilanci[i].sezioni.contoEconomicoPercentuale != null)
                    bilancio = populateField(bilancio, bo.listaBilanci[i].sezioni.contoEconomicoPercentuale.listaVoci, cMap);

                if(bo.listaBilanci[i].sezioni.indicatori != null)
                    bilancio = populateField(bilancio, bo.listaBilanci[i].sezioni.indicatori.listaVoci, cMap);


                System.debug('@@@ bilancio rec ' + JSON.serialize(bilancio));

                lstBilancio.add(bilancio);

            }

            System.debug('@@@ lstBilancio ' + JSON.serialize(lstBilancio));

            if(!lstBilancio.isEmpty()){
                upsert lstBilancio;

                System.debug('@@@ lstBilancio[0] ' + JSON.serialize(lstBilancio[lstBilancio.size()-1]));
                System.debug('@@@ fatturato ' + lstBilancio[lstBilancio.size()-1].Fatturato__c);
                System.debug('@@@ fatturato ' + String.valueOf(lstBilancio[lstBilancio.size()-1].Fatturato__c));
                System.debug('@@@ fatturato split ' + String.valueOf(lstBilancio[lstBilancio.size()-1].Fatturato__c).split(','));
                System.debug('@@@ fatturato split ' + String.valueOf(lstBilancio[lstBilancio.size()-1].Fatturato__c).split('\\.'));
                String dc = String.valueOf(lstBilancio[lstBilancio.size()-1].Fatturato__c).split('\\.')[1].length() > 2 ? String.valueOf(lstBilancio[lstBilancio.size()-1].Fatturato__c).split('\\.')[1].substring(0,2) : '0';
                System.debug('@@@ dc ' + dc);
                String ft = String.valueOf(lstBilancio[lstBilancio.size()-1].Fatturato__c).split('\\.')[0] + '.' + dc;
                System.debug('@@@ ft ' + ft);

                Decimal ftDec = Decimal.valueOf(ft);

                System.debug('@@@ ftDEC ' + ftDec);
                System.debug('@@@ ftDec ' + ftDec.stripTrailingZeros());
                //Aggiorno i dati del bilancio sull'anagrafica
                a.WGC_Numero_dipendenti__c = lstBilancio[lstBilancio.size()-1].NumberOfEmployees__c;
                //a.Fatturato__c = lstBilancio[lstBilancio.size()-1].Fatturato__c;
                a.Fatturato__c = ftDec;

                update a;

                ResponseBilancio response = new ResponseBilancio();

                bilancio_CRMList = [ SELECT Id, PatrimonioNetto__c, DataFatturato__c
                                FROM WGC_Bilancio__c 
                                WHERE Account__c =: accountId 
                                    AND (NOT(DataFatturato__c = THIS_YEAR
                                        AND PatrimonioNetto__c = 0))
                                ORDER BY DataFatturato__c DESC LIMIT 2 ];

                response.bilancio = bilancio_CRMList[0];
                response.bilancioPrecedente = bilancio_CRMList[1];
                response.message = 'ok';
                response.success = true;
                return response;
            }
            else{
                ResponseBilancio resp = new ResponseBilancio();
                if(bilancio_CRMList.size() != 0){
                    if(bilancio_CRMList[0].DataFatturato__c != null){
                            resp.bilancio = bilancio_CRMList[0];

                            if(bilancio_CRMList.size() > 1){
                                resp.bilancioPrecedente = bilancio_CRMList[1];
                            } else {
                                resp.bilancioPrecedente = new WGC_Bilancio__c(PatrimonioNetto__c = 0);
                            }
                    
                    } else {
                        resp.bilancio = new WGC_Bilancio__c(PatrimonioNetto__c = 0);
                        resp.bilancioPrecedente = bilancio_CRMList[0];
                    }
                }

                // resp.bilancio = bilancio_CRMList.size() == 0 ? new WGC_Bilancio__c() : bilancio_CRMList[0];
                // resp.bilancioPrecedente = bilancio_CRMList.size() > 1 ? bilancio_CRMList[1] : new WGC_Bilancio__c();
                resp.message = 'Nessun bilancio da aggiornare';
                resp.success = true;
                return resp;
                //return null;
            }

        }
        else{
                ResponseBilancio resp = new ResponseBilancio();
                if(bilancio_CRMList.size() > 0){
                    if(bilancio_CRMList[0].DataFatturato__c != null){
                            resp.bilancio = bilancio_CRMList[0];

                            if(bilancio_CRMList.size() > 1){
                                resp.bilancioPrecedente = bilancio_CRMList[1];
                            } else {
                                resp.bilancioPrecedente = new WGC_Bilancio__c(PatrimonioNetto__c = 0);
                            }
                    
                    } else {
                        resp.bilancio = new WGC_Bilancio__c(PatrimonioNetto__c = 0);
                        resp.bilancioPrecedente = bilancio_CRMList[0];
                    }
                } else {
                    resp.bilancio = new WGC_Bilancio__c();
                    resp.bilancioPrecedente = new WGC_Bilancio__c();
                }
            // response.bilancio = bilancio_CRMList.size() == 0 ? new WGC_Bilancio__c() : bilancio_CRMList[0];
            // response.bilancioPrecedente = bilancio_CRMList.size() > 1 ? bilancio_CRMList[1] : new WGC_Bilancio__c();
            resp.message = 'Servizio Bilancio non disponibile';
            resp.success = false;
            return resp;
        }
        }catch(Exception e){
            ResponseBilancio resp = new ResponseBilancio();
            if(bilancio_CRMList.size() != 0){
                if(bilancio_CRMList[0].DataFatturato__c != null){
                        resp.bilancio = bilancio_CRMList[0];

                        if(bilancio_CRMList.size() > 1){
                            resp.bilancioPrecedente = bilancio_CRMList[1];
                        } else {
                            resp.bilancioPrecedente = new WGC_Bilancio__c(PatrimonioNetto__c = 0);
                        }
                
                } else {
                    resp.bilancio = new WGC_Bilancio__c(PatrimonioNetto__c = 0);
                    resp.bilancioPrecedente = bilancio_CRMList[0];
                }
            }
            resp.message = e.getMessage();
            resp.success = false;
            return resp;
        }
    }
    
    @TestVisible
    private static WGC_Bilancio__c populateField(WGC_Bilancio__c bilancio, List<ListaVoci> listaVoci, Map<String, SObject> mappatura) {
		ListaVoci voceMancante;

		for (ListaVoci voce : listaVoci) {
			try {
				if (voce.valore != null) {
					voceMancante = voce;
					//bilancio.put((String)mappatura.get(voce.codice).get('Nome_Campo__c'), Decimal.valueOf(voce.valore.replace('.','').replace(',','.')));
					bilancio.put((String) mappatura.get(voce.codice).get('Nome_Campo__c'), Decimal.valueOf(voce.valore));
				}
			} catch(Exception e) {
				System.debug('@@@ voce non presente: ' + voceMancante);
			}
		}
		return bilancio;
	}

    @AuraEnabled
    public static Boolean checkRinnovoAvailable(Id accountId){
        User u = [SELECT Id, Qualifica_Utente__c FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];
        //AND Qualifica_Prodotto__c = 'Cliente attivo'
        List<WGC_Linea_Prodotto__c> linee = [SELECT Id, Qualifica_Prodotto__c, Data_Scadenza__c, Anagrafica__r.WGC_Somma_RollUp_Rinnovo__c FROM WGC_Linea_Prodotto__c WHERE Anagrafica__c = :accountId AND Recordtype.DeveloperName = 'FACTORINGCEDENTE' AND Codice_Stato__c = '003'];
        System.debug('@@@ linee ' + JSON.serialize(linee));
        Boolean isAvailable = false;

        if (u.Qualifica_Utente__c == 'Sviluppo_Commerciale_Filiali' || u.Qualifica_Utente__c == 'Gestore Debitore' || u.Qualifica_Utente__c == 'IFIS_International')
            for (WGC_Linea_Prodotto__c l : linee)
                if (l.Data_Scadenza__c != null) { 
                    // System.debug('@@@ Date.today().daysBetween(l.Data_Scadenza__c) ' + Date.today().daysBetween(l.Data_Scadenza__c));
                    // System.debug('@@@ Date.today().daysBetween(l.Data_Scadenza__c) <= 30 && Date.today().daysBetween(l.Data_Scadenza__c) >= 0 ' + Date.today().daysBetween(l.Data_Scadenza__c) <= 30 && Date.today().daysBetween(l.Data_Scadenza__c) >= 0);
                    // System.debug('@@@ Date.today().daysBetween(l.Data_Scadenza__c) <= 30 && Date.today().daysBetween(l.Data_Scadenza__c) >= 0 ' + Date.today().daysBetween(l.Data_Scadenza__c) <= 30 );
                    // System.debug('@@@ Date.today().daysBetween(l.Data_Scadenza__c) >= 0 ' + Date.today().daysBetween(l.Data_Scadenza__c) >= 0);
                    if (Date.today().daysBetween(l.Data_Scadenza__c) <= 30 /* && Date.today().daysBetween(l.Data_Scadenza__c) >= 0 */ && l.Anagrafica__r.WGC_Somma_RollUp_Rinnovo__c > 0) {
                        isAvailable = true;
                        break;
                    }}

        return isAvailable;
    }
    
    @AuraEnabled
    public static String getUserProfile(){
        return [SELECT Id, Profile.Name FROM User WHERE Id =: UserInfo.getUserId()].Profile.Name;
    }

    //wrapper per gestire la risposta della chiamata al bilancio
    public class ResponseBilancio{
        @AuraEnabled
        public String message;
        @AuraEnabled
        public Boolean success;
        @AuraEnabled
        public WGC_Bilancio__c bilancio;
        @AuraEnabled
        public WGC_Bilancio__c bilancioPrecedente;

        public ResponseBilancio(){
            this.bilancio = bilancio;
            this.bilancioPrecedente = bilancioPrecedente;
            this.message = message;
            this.success = true;
        }
    }

    //Classe di Input per la chiamata al servizio bilancio (Ribes 11)

    public class BilancioInputGen{
        public Integer codiceIstituto3N;
        public String idApplicazioneChiamante;
        public String idSessioneChiamante;
        public String lingua;
        public String idOperazione;
        public String utenzaCanale;
        public Long ndg;
        public String codiceFiscale;
        public Integer numeroBilanci;

        public BilancioInputGen(){
            this.codiceIstituto3N = codiceIstituto3N;
            this.idApplicazioneChiamante = idApplicazioneChiamante;
            this.idSessioneChiamante = idSessioneChiamante;
            this.lingua = lingua;
            this.idOperazione = idOperazione;
            this.utenzaCanale = utenzaCanale;
            this.ndg = ndg;
            this.codiceFiscale = codiceFiscale;
            this.numeroBilanci = numeroBilanci;
        }

    }

    //Classe di Output per ricevere la risposta al servizio bilancio (Ribes 11)
    //Le classi sottostanti sono la composizione della classe BilancioOutput

    public class OutputMain extends WsRestInput.CommonResponse{
        public BilancioOutput payload;

        public OutputMain(){
            this.payload = payload;
        }

        public override Boolean isCorrect() {
            return payload != null;
        }
    }

    public class BilancioOutput{
        public String esitoRicerca;
        public InfoImpresa infoImpresa;
        public List<SingleBilancio> listaBilanci;

        // public BilancioOutput(){
        //     this.esitoRicerca = esitoRicerca;
        //     this.infoImpresa = infoImpresa;
        //     this.listaBilanci = listaBilanci;
        // }
    }

    public class InfoImpresa{
        public String denominazione;
        public String naturaGiuridica;
        public String codiceFiscale;
        public KRea kRea;
        public String indirizzo;
        public String provincia;
        public String cap;

        // public InfoImpresa(){
        //     this.denominazione = denominazione;
        //     this.naturaGiuridica = naturaGiuridica;
        //     this.codiceFiscale = codiceFiscale;
        //     this.kRea = kRea;
        //     this.indirizzo = indirizzo;
        //     this.provincia = provincia;
        //     this.cap = cap;
        // }
    }

    public class KRea{
        public String cciaaSiglaProvincia;
        public String nRea;

        // public KRea(){
        //     this.cciaaSiglaProvincia = cciaaSiglaProvincia;
        //     this.nRea = nRea;
        // }
    }

    public class SingleBilancio{
        public TestataBilancio testataBilancio;
        public Sezioni sezioni;

        // public SingleBilancio(){
        //     this.testataBilancio = testataBilancio;
        //     this.sezioni = sezioni;
        // }
    }

    public class Sezioni{
        public Voci statoPatrimonialeAttivo;
        public Voci statoPatrimonialePassivo;
        public Voci contoEconomico;
        public Voci quozienteFlussi;
        public Voci statoPatrimonialeAttivoPercentuale;
        public Voci statoPatrimonialePassivoPercentuale;
        public Voci contoEconomicoPercentuale;
        public Voci indicatori;

        // public Sezioni(){
        //     this.statoPatrimonialeAttivo = statoPatrimonialeAttivo;
        //     this.statoPatrimonialePassivo = statoPatrimonialePassivo;
        //     this.contoEconomico = contoEconomico;
        //     this.quozienteFlussi = quozienteFlussi;
        //     this.statoPatrimonialeAttivoPercentuale = statoPatrimonialeAttivoPercentuale;
        //     this.statoPatrimonialePassivoPercentuale = statoPatrimonialePassivoPercentuale;
        //     this.contoEconomicoPercentuale = contoEconomicoPercentuale;
        //     this.indicatori = indicatori;
        // }
    }

    public class TestataBilancio{
        public String idBilancio;
        public TipoBilancio tipo;
        public String durata;
        public SchemaTestataBilancio schema;
        public String dataChiusura;

        // public TestataBilancio(){
        //     this.idBilancio = idBilancio;
        //     this.tipo = tipo;
        //     this.durata = durata;
        //     this.schema = schema;
        //     this.dataChiusura = dataChiusura;
        // }
    }

    public class TipoBilancio{
        public String codice;
        public String descrizione;

        // public TipoBilancio(){
        //     this.codice = codice;
        //     this.descrizione = descrizione;
        // }
    }

    public class SchemaTestataBilancio{
        public String codice;
        public String descrizione;

        // public SchemaTestataBilancio(){
        //     this.codice = codice;
        //     this.descrizione = descrizione;
        // }
    }

    public class Ateco{
        public String codice;
        public String descrizione;

        // public Ateco(){
        //     this.codice = codice;
        //     this.descrizione = descrizione;
        // }
    }

    public class Voci{
        @AuraEnabled
        public List<ListaVoci> listaVoci;

        // public Voci(){
        //     this.listaVoci = new List<ListaVoci>();
        // }
    }


    public class ListaVoci{
        public String codice;
        public String descrizione;
        public Feu feu;
        public String valore;

        // public ListaVoci(){
        //     this.codice = codice;
        //     this.descrizione = descrizione;
        //     this.feu = feu;
        //     this.valore = valore;
        // }
    }

    public class Feu{
        public String sezione;
        public String codiceRiga;
        public String sigla;
        public String descrizione;

        // public Feu(){
        //     this.sezione = sezione;
        //     this.codiceRiga = codiceRiga;
        //     this.sigla = sigla;
        //     this.descrizione = descrizione;
        // }
    }
}