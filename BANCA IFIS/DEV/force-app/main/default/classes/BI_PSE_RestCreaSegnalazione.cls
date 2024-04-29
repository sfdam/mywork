/**
* Project:              Banca Ifis - CRM: Flusso di popolamento Portale Segnalatori
* Developer:            Annalisa Trabacchin 
* Description:          Creazione di una pratica inviata via file in formato JSON 
*                       in Portale Segnalatori 
*
*/

/*
ESEMPIO DI PAYLOAD IN INGRESSO

	{
	"techInfo": {
	"applicationCode": "CRM",
	"channel": "B2B",
	"correlationId": "9c9af967-8d1b-42c2-a121-0b6ab9de9a01",
	"timeStamp": 1563544009402,
	"userId": "ext.crm",
	"username": "CRM",
	"clientIpAddress": "127.0.0.1",
	"emailAddress": "a@a.it"
	},
	"payload": {
	"enteSegnalante": "GNL-121728G1",
	"idPraticaEnteSegnalante": "534643643",
	"statoPratica": "",
	"codiceFiscaleAzienda": "11111111112",
	"ragioneSocialeAzienda" : "Unit Test Srl",
	"naturaGiuridicaAzienda": "SPA",
	"indirizzoSedeLegale": "Via Gatta",
	"civico": "41",
	"paeseSedeLegale": "Italia",
	"regione": "Veneto",
	"comune": "Venezia",
	"provincia": "VE",
	"cap": "30174",
	"ateco": "49.41",
	"codiceSae": "430",
	"nIscrizioneCCIAA": "1628325",
	"provinciaCCIAA": "MI",
	"nomeReferente": "Banca Generali",
	"cognomeReferente": "Banca Generali",
	"ruoloReferente": "Segnalazione",
	"contattoTelefonicoReferente": "1111111111",
	"indirizzoMailReferente": "",
	"codiceConsulente": "GN2222",
	"nomeECognomeConsulente": "Annalisa Bianchi",
	"cellulareConsulente": "325265262",
    "tipologiaSegnalazione": "MISTO",
	"stimaFabbisognoFinanziario": "1000000",
	"nazionalitaClienti": "ITALIANI",
	"naturaClienti": "PRIVATI",
	"importoMutuo": "400000",
	"mesiAmmortamento": "4",
	"mesiPreAmmortamento": "12",
	"finalitaMutuo": "INVESTIMENTO",
	"importoLeasing": "",
	"businessLeasing": "",
	"importoRental": "",
	"businessRental": "",
	"note": "Test"
	}
	}
*/

@RestResource(urlMapping = '/PortaleSegnalatori')
global with sharing class BI_PSE_RestCreaSegnalazione { 
    
     // Support class for the input file with the data to be inserted in the Portale Segnalatori
     global with sharing class WorkflowSegnalatoriInputPayload {

        /** Ente segnalante e.g.  */ 
        global String enteSegnalante { get; set; }
        /** id pratica ente segnalante */
        global String idPraticaEnteSegnalante { get; set; }       
        global String statoPratica  { get; set; }
        /** Dati azienda */
        /** partita IVA azienda */
        global String codiceFiscaleAzienda  { get; set; }
        global String ragioneSocialeAzienda { get; set; }
        global String naturaGiuridicaAzienda { get; set; }
        global String indirizzoSedeLegale  { get; set; }
        global String civico  { get; set; }
        //paese sede legale - campo mancante
        global String paeseSedeLegale  { get; set; }
        //paese regione - campo mancante
        global String regione { get; set; }
        global String comune { get; set; }
        global String provincia { get; set; }
        global String cap { get; set; }
        global String ateco { get; set; }
        global String codiceSae { get; set; }
        global String nIscrizioneCCIAA { get; set; }
        global String provinciaCCIAA { get; set; }
        /** Dati Referente Azienda */
        global String nomeReferente { get; set; }
        global String cognomeReferente { get; set; }
        global String ruoloReferente { get; set; }
        global String contattoTelefonicoReferente { get; set; }
        global String indirizzoMailReferente { get; set; }
        /** Dati consulente */
        global String codiceConsulente { get; set; }
        global String nomeECognomeConsulente { get; set; }
        global String cellulareConsulente { get; set; }        
        /** Dettaglio richiesta */
        /** Tipo servizio richiesto: FACTORING / MUTUO / LEASING / RENTAL */
        global String tipologiaSegnalazione { get; set; }
        /** FACTORING o MUTUO + FACTORING */ 
        global String stimaFabbisognoFinanziario { get; set; }
        global String naturaClienti { get; set; }
        global String nazionalitaClienti { get; set; }
        /** MUTUO */
        global String importoMutuo { get; set; }
        global String mesiAmmortamento { get; set; }
        global String mesiPreAmmortamento { get; set; }
        global String finalitaMutuo { get; set; }
        /** LEASING */
        global String importoLeasing { get; set; }
        global String businessLeasing { get; set; }
        /** RENTAL */
        global String importoRental { get; set; }
        global String businessRental { get; set; }
        global String note { get; set; }

    }

@HttpPost
  global static RestCommon.ResponseObject creaSegnalazione(RestCommon.TechInfo techInfo, WorkflowSegnalatoriInputPayload payload) {
    //RestCommon.ResponseObject response = new RestCommon.ResponseObject('0', 'Nothing done');;
    String partitaIva = '';
    String isPIVAValid = '';
    String nomeReferenteBGL = 'Banca generali';
    //String enteSegnalanteBGLCode = 'GNL-121728G1';
     
        // first checks on valid inputs
        partitaIva = payload.codiceFiscaleAzienda;
        
        if( String.isBlank(partitaIva)){
        RestCommon.ResponseObject response = new RestCommon.ResponseObject('-1', 'Campi obbligatori non valorizzati correttamente');
        return response;  
        }
    
    List<Object> searchResult = bifis_crm_c_CommonUtils.checkPartitaIva(partitaIva);
      
      WorkflowSegnalatori__c newWorkflow;
      Account currentAccount;
      
      if (searchResult.isEmpty()) {
       RestCommon.ResponseObject response = new RestCommon.ResponseObject('-2', 'Anomalia nella ricerca anagrafica. Nessun risultato trovato.');
       return response; 
      }
      else {
        isPIVAValid = (String) searchResult[0];     
        currentAccount = (Account) searchResult[2];
        

      }
      
      System.debug('inizio a far qualcosa');
      if (isPIVAValid.equals('OK') ) {
          //crea oggetto in portale segnalatori e invia pratica
         System.debug('Inizio creazione pratica portale segnalatori');
         newWorkflow = new WorkflowSegnalatori__c();
         newWorkflow.PartitaIVA__c = partitaIva;   
         newWorkFlow.Ente_segnalante__c = payload.enteSegnalante;
         newWorkFlow.Tipo_Segnalatore__c = 'Esterno'; 
         //add new field to store IdPraticaEnteSegnalante;
         newWorkFlow.Ragione_Sociale__c = payload.ragioneSocialeAzienda;	
         newWorkFlow.Natura_Giuridica__c = payload.naturaGiuridicaAzienda;
         newWorkFlow.Stato__c = 'BOZZA_DATI';
         newWorkFlow.IndirizzoLegale__c =	payload.indirizzoSedeLegale;
         newWorkFlow.CivicoLegale__c    = payload.civico;
		 newWorkFlow.CittaLegale__c    = payload.comune;
		 newWorkFlow.ProvinciaLegale__c    = payload.provincia;
		 newWorkFlow.CapLegale__c    = payload.cap;
		 newWorkFlow.ATECO__c    = payload.ateco;
		 newWorkFlow.SAE__c    = payload.codiceSae;
		 newWorkFlow.REA__c    = payload.nIscrizioneCCIAA;
		 newWorkFlow.ProvinciaCCIAA__c = payload.provinciaCCIAA;

         newWorkFlow.CognomeReferente__c = payload.nomeECognomeConsulente;
         //newWorkFlow.CodiceReferente__c = payload.codiceConsulente; 
         newWorkFlow.TelefonoReferente__c =  payload.cellulareConsulente;
		//	newWorkFlow.    = payload.
		//	newWorkFlow.    = payload.  
         
		//Referenti JSON
        String referentiJson = '{"nome":"' + payload.nomeReferente + '","cognome":' + payload.cognomeReferente + ',"ruolo":"' + ',"telefono":"' + ',"mail":"'+ ',"codiceFiscale":"' +'"}';
		System.debug('Partita IVA ' + newWorkflow.PartitaIVA__c);
         if (currentAccount == null) {
           
          // compila campi
         }
    
		/*
		 try {

           insert newWorkflow;

    	}

    	catch (Exception ex){
    
      		RestCommon.ResponseObject response = new RestCommon.ResponseObject('-2', 'Errore generico nella procedura di inserimento');

     	 return response;

         }*/
      }
     
       RestCommon.ResponseObject response = new RestCommon.ResponseObject('0', 'Procedura di inserimento pratica completata con successo.');
       return response;

    }
    

    
    


}