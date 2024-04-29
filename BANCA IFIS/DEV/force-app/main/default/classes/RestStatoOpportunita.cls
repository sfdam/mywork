@RestResource(urlMapping = '/StatoOpportunita')
global with sharing class RestStatoOpportunita {
  private RestStatoOpportunita() {}

    private static final String VALUTAZ_PRATICA = '1';
    private static final String FIRMA_CONTRATTI = '11';
    private static final String AVANZAMENTO_VAL_PRATICA = '6';
    @TestVisible 
    private static final String NON_DELIBERATA_PERSA = '5';
    @TestVisible
    private static final String PEF_DELIBERATA = '4';
    private static final String CEDACRI_DELIBERATA = '10';
    private static final String CEDACRI_NON_DELIBERATA = '7';
    
    private static final String PREDISP_CONTRATTO = 'Predisposizione Contratto';
    private static final String PERSA = 'Persa';
    private static final String PERF_CONTRATTI = 'Perfezionamento Contratto';
    private static final String PEF_DECLINATA = 'Pratica declinata';

  @HttpPost
  global static RestCommon.ResponseObject updateCartella(
    RestCommon.TechInfo techInfo,
    // MB - TEN: modificati parametri in input per gestire nodo "payload"
    UpdateCartellaInputPayload payload
  ) {
    String message;
    String codice;

	if (payload.cartella != null && payload.linee != null) {
      if (payload.cartella != null && String.isNotBlank(payload.cartella.idCartella)) {
	  // RICERCA CON ID CARTELLA NV
        String idCartella = payload.cartella.idCartella;

        Opportunity[] opps = [SELECT Id, AccountId, RecordType.DeveloperName,
                              (SELECT Id, IdProdotto__c FROM Linee__r)
                              FROM Opportunity
                              WHERE IdCartella__c = :idCartella];

        if (opps.isEmpty()) {
          codice = RestCommon.ID_CARTELLA_ASSENTE;
        } else if (opps.size() > 1) {
          message = 'Trovate troppe cartelle';
          codice = RestCommon.ID_CARTELLA_ASSENTE; //oppure altro errore???
        } else {
          Opportunity opp = opps[0];
          opp.StatoPEF__c = payload.cartella.esito;

          // MB - TEN: aggiunta gestione avanzamento automatico stato opportunità in base a esito cartella
          // SM - TEN: CR 401 eliminazione stato Predisposizione Contratto
          if (payload.cartella.esito == PEF_DELIBERATA)
		  {
			opp.StageName = PERF_CONTRATTI;
			//A.M. SDHDFNZ-120376 AGGIORNAMENTO STATO Linee per Opportunità deliberata 
			//(Data_Delibera e flag Deliberata vengono inseriti dal componente che, recuperando i dati dalla PEF, può gestire la delibera parziale)
			Linea__c[] tmp = new Linea__c[] {};
            for (Linea__c newL : opp.Linee__r) {
				newL.Stato__c = '11';
				//newL.WGC_Data_Delibera__c = Date.today();
				//newL.WGC_Deliberata__c = true;
				tmp.add(newL);
			}
			System.debug('@@@A.M. PEF_DELIBERATA: ' + tmp);
			update tmp;
		 }

          if (payload.cartella.esito == NON_DELIBERATA_PERSA)
		  {
            opp.StageName = PERSA;
			//SDCHG-5737 Inserita CategoriaChiusuraTrattativa in caso di chiusura utomatica
			opp.WGC_Fase__c = PERSA;
			opp.CategoriaChiusuraTrattativa__c = PEF_DECLINATA;
			//A.M. SDHDFNZ-120376 AGGIORNAMENTO STATO Linee per Opportunità persa
			Linea__c[] tmp = new Linea__c[] {};
            for (Linea__c newL : opp.Linee__r) {
				newL.Stato__c = '5';
				newL.WGC_Data_Declinazione__c = Date.today();
				newL.WGC_Non_Deliberata__c = true;
				tmp.add(newL);
			}
			update tmp;
		 }
          // MB - TEN: CR 273
          // MB - TEN: rimosso aggiornamento pratica con stato 11; l'aggiornamento in 'Perfezionamento Contratto' avviene solo quando tutte le linee hanno ricevuto codice 11
          // if (payload.cartella.esito == FIRMA_CONTRATTI)
          //   opp.StageName = PERF_CONTRATTI;
          // MB - TEN: aggiunta gestione avanzamento automatico stato opportunità in base a esito cartella

          // MB - TEN: aggiunta gestione nuovo campo "codPratica" al servizio
          if (payload.codPratica != null)
            opp.WGC_Codice_Pratica__c = payload.codPratica;
          // MB - TEN: aggiunta gestione nuovo campo "codPratica" al servizio

          try {
            asyncUpdateLinee(opp.AccountId, opp.Id);
            Linea__c[] toUpdate = aggiornaLineeOpportunita(opp.Linee__r, payload.linee);

            // update opp;
            update toUpdate;
            // MB - TEN: CR 273
            // MB - TEN: se tutte le linee della pratica hanno stato 11 o sono NON DELIBERATE, aggiorno stato pratica
            if (checkAllLinesCompleted(opp.Id))
              opp.StageName = PERF_CONTRATTI;
            update opp;
            codice = RestCommon.NESSUN_ERRORE;
			/* 2019-02-12 adione: commentata chiamata perchè stato 11 non gestito
            if (opp.StatoPEF__c == FIRMA_CONTRATTI) {
              //se documenti pronti -> ricerca DOC04 + recupero documeni tramite talend
              WsRestDocumentaleUtils.recuperaDocumentiAsync(opp.Id);
            }
			*/
          } catch (Ex.RestStatoOpportunitaException e) {
            codice = e.getMessage();
          } catch (Exception e) {
            message = e.getMessage();
            codice = RestCommon.ERRORE_GENERICO;
          }
        }
      } else if(payload.cartella != null && payload.codPratica != null) {
		// RICERCA CON CODICE PEF
	    // A.M. SDHDFNZ-115210 - Le opportunità di revisione non hanno idCartella ma non vengono aggiornate perchè non sono di tipo 'IFISOpportunitaFastFinance'
        //Opportunity[] oppsFF = [SELECT Id, StageName, StatoPEF__c FROM Opportunity WHERE WGC_Codice_Pratica__c =: payload.codPratica AND RecordType.DeveloperName = 'IFISOpportunitaFastFinance'];
		Opportunity[] oppsFF = [SELECT Id, StageName, StatoPEF__c FROM Opportunity WHERE WGC_Codice_Pratica__c =: payload.codPratica];
        
		System.debug('@@@A.M. Opp FF: ' + oppsFF);

        if (oppsFF.isEmpty()) {
          codice = RestCommon.ID_CARTELLA_ASSENTE;
        } else if (oppsFF.size() > 1) {
          message = 'Trovate troppe PEF';
          codice = RestCommon.ID_CARTELLA_ASSENTE; //oppure altro errore???
        } else {

          try{
            Opportunity opp = oppsFF[0];
            opp.StatoPEF__c = payload.cartella.esito;
            opp.StageName = PERF_CONTRATTI;
            update opp;
            codice = RestCommon.NESSUN_ERRORE;
          } catch (Ex.RestStatoOpportunitaException e) {
            codice = e.getMessage();
          } catch (Exception e) {
            message = e.getMessage();
            codice = RestCommon.ERRORE_GENERICO;
          }
        }
      }//SM - TEN: Aggiunta gestione Avanzamento pratica Fast Finance
    }
    RestCommon.ResponseObject response = new RestCommon.ResponseObject(codice, message);
    //A.M. -> Start Tracciatura codice pratica
    //RestCommon.logInboundMessage('StatoOpportunita Inbound', new Object[] {payload.cartella, payload.linee}, response);
    RestCommon.logInboundMessage('StatoOpportunita Inbound', new Object[] {payload.cartella, payload.linee, payload.codPratica}, response);

    return response;
  }

  @Future(callout=true)
  public static void asyncUpdateLinee(Id accountId, Id opportunityId){
      WizardOpportunityController.WrapperResponseWs response = WizardOpportunityController.asyncLoadDatiPEF(accountId, opportunityId);

      if(response.data == null && !test.isRunningTest()){
        return;
      }
      if(test.isRunningTest())
      {
          response.data = (WGC_WSUtils_Cart.DatiPEFResponse) JSON.deserialize(TestMockUtils.PAYLOAD_DATI_PEF, WGC_WSUtils_Cart.DatiPEFResponse.class);
      }

      WGC_WsUtils_Cart.DatiPEFResponse datiPef = (WGC_WsUtils_Cart.DatiPEFResponse)response.data;

      List<WGC_WsUtils_Cart.LineaCredito> listaLinee = datiPef.payload.outputRichiesta.elencoLineeCredito;
	  
	 
	  //SDCHG-6051 -> 	 
	  Opportunity oppo = [SELECT Id, BI_Stato_Pratica_PEF__c, BI_Tipo_Pratica_PEF__c, 
                        WGC_Organo_Deliberante__c, WGC_Data_Delibera_PEF__c,
                        WGC_Tipologia_Nota__c, WGC_Descrizione_Nota__c,
                        WGC_Data_Ultimo_inserimento__c
                        FROM Opportunity 
                        WHERE Id = :opportunityId];

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
              string desNota = EncodingUtil.base64Decode(nota.desTestoNota).toString();
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

	  if (oppo.BI_Stato_Pratica_PEF__c != null  ||  oppo.BI_Tipo_Pratica_PEF__c != null || oppo.WGC_Organo_Deliberante__c != null ||  oppo.WGC_Tipologia_Nota__c != null|| oppo.WGC_Descrizione_Nota__c != null|| oppo.WGC_Data_Ultimo_inserimento__c!= null)
      {
          update oppo;
      }

      Map<WGC_WsUtils_Cart.OutputRichiestaWrapper, List<WGC_WsUtils_Cart.LineaCredito>> mappaCredito = new Map<WGC_WsUtils_Cart.OutputRichiestaWrapper, List<WGC_WsUtils_Cart.LineaCredito>>();
      mappaCredito.put(datiPef.payload.outputRichiesta, listaLinee);


      List<Linea__c> lineeCarrello = [SELECT Id, Name, Opportunity__r.Originator__c, Opportunity__r.Originator_di_dettaglio__c, Prodotto__r.Codice__c, Stato__c FROM Linea__c WHERE Opportunity__c =: opportunityId];

      List<WGC_WsUtils_Cart.PEF40Input> lineeToPEF40 = new List<WGC_WsUtils_Cart.PEF40Input>();

      List<WGC_WsUtils_Cart.OutputRichiestaWrapper> keyMappaCredito = new List<WGC_WsUtils_Cart.OutputRichiestaWrapper>(mappaCredito.keySet());
	  
	  for(WGC_WsUtils_Cart.LineaCredito linea : mappaCredito.values().get(0)){
        for(Linea__c lineaCRM : lineeCarrello){
          if((linea.codGestione == 'N' || linea.codGestione == 'R') && linea.codLineaSistema == lineaCRM.Prodotto__r.Codice__c){
            WGC_WsUtils_Cart.PEF40Input inputPef40 = new WGC_WsUtils_Cart.PEF40Input(keyMappaCredito.get(0), linea, lineaCRM);
            lineeToPEF40.add(inputPef40);

			//SDHDFNZ-124486 - Aggiornamento stato linee -> viene fatto qui per "riciclare" la chiamata al ws datiPef
            lineaCRM.Stato__c = linea.codStatoLinea == '003' ? FIRMA_CONTRATTI : (linea.codStatoLinea == '004' ? NON_DELIBERATA_PERSA : VALUTAZ_PRATICA);
			System.debug('@@@A.M. Aggiornamento lineaCRM: ' + lineaCRM);
			update lineaCRM;
          }
        }
      }

      if(!lineeToPEF40.isEmpty()){
        Id jobId = System.enqueueJob(new WGC_QbleInvioCanaleVendita(lineeToPEF40));
      }
      else{
        return;
      }
  }

  private static Linea__c[] aggiornaLineeOpportunita(Linea__c[] linee, Linea[] newLinee) {
    Map<String, SObject> oppLinee = U.keyBy(linee, 'IdProdotto__c');
    Linea__c[] tmp = new Linea__c[] {};
    for (Linea newLinea : newLinee) {
      Linea__c l = (Linea__c)oppLinee.get(newLinea.id.leftPad(6).replace(' ', '0'));
      if (l != null) {
	    l.Stato__c = newLinea.stato;
        l.IdIstruttoria__c = newLinea.idIstruttoria;
        l.IdIstruttoriaFiglio__c = newLinea.idIstruttoriaFiglio;
        l.Dettaglio__c = newLinea.dettaglio;
        l.DataIstruttoria__c = UDate.parseDateYYYYMMDD(newLinea.dataIstruttoria);
        l.DataIstruttoriaFiglio__c = UDate.parseDateYYYYMMDD(newLinea.dataIstruttoriaFiglio);
        // MB - TEN: CR 273
        // MB - TEN: se linea con stato 11 (DELIBERATA), scrivo data delibera = today
        if (newLinea.stato == '11')
          l.WGC_Data_Contratti_Pronti__c = Date.today();

        tmp.add(l);
      }
    }
    return tmp;
  }

  public static Boolean checkAllLinesCompleted(String oppId) {
    Boolean completed = false;
    Boolean atLeastOne = false;
    List<Linea__c> lines = new List<Linea__c>();
    lines = [SELECT Id, Stato__c, WGC_Non_Deliberata__c FROM Linea__c WHERE Opportunity__c = :oppId];

    completed = (lines.size() > 0);
    for (Linea__c l : lines) {
      atLeastOne = atLeastOne || l.Stato__c == FIRMA_CONTRATTI;
      completed = completed && (l.Stato__c == FIRMA_CONTRATTI || l.WGC_Non_Deliberata__c);
    }

    return completed && atLeastOne;
  }

  //A.M. SDHDFNZ-125248 -> Aggiornamento stato opportunità se tutte le linee declinate (per le revisioni non arriva la chiamata inbound di PEF DECLINATA)
  public static Boolean checkAllLinesDeclined(String oppId) {
    Boolean declined = false;
    List<Linea__c> lines = new List<Linea__c>();
    lines = [SELECT Id, Stato__c, WGC_Non_Deliberata__c FROM Linea__c WHERE Opportunity__c = :oppId];

    declined = (lines.size() > 0);
    for (Linea__c l : lines) {
      declined = declined && (l.Stato__c == NON_DELIBERATA_PERSA || l.WGC_Non_Deliberata__c);
    }
    return declined;
  }
  
  global class UpdateCartellaInputPayload {
      String codiceIstituto3N;
      String idApplicazioneChiamante;
      @TestVisible
      Cartella cartella;
      @TestVisible
      Linea[] linee;
      @TestVisible
      Integer codPratica;
  }

  global class Cartella {
      @TestVisible
    String idCartella;
      @TestVisible
    String esito;
  }

  global class Linea {
    @TestVisible
    String id;
    String stato;
    String idIstruttoria;
    String dataIstruttoria;
    String idIstruttoriaFiglio;
    String dataIstruttoriaFiglio;
    String dettaglio;
  }
}