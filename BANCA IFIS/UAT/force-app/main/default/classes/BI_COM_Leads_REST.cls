/**
  * Progetto:         CRM 2.0.
  * Sviluppatore      Marco Bonin <marco.bonin@bancaifis.it>
  * Descrizione:      Classe di accesso all'oggetto lead mediante servizio rest.
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
	"nome": "Marco",
	"cognome": "Bonin",
	"ragioneSociale": "BMT Snc",
	"partitaIva": "1122334455",
	"messaggio" : "Messaggio di prova",
	"ifisFormId": "1",
	"ifisFormIdUnivoco": "4bd57db2bacd0abfcb38e615c51add",
	"tipologiaClienti": "2",
	"tipologiaInseritore": "Azienda",
	"contattoTelefonico": "3339334571",
	"email": "marco.bonin@bancaifis.it",
	"tipologiaInserimento": "TRADIZIONALE"
	}
	}

*/

@RestResource(urlMapping = '/leads/*')
global with sharing class BI_COM_Leads_REST {

	global with sharing class AcquisisciLeadInputPayload {
		public String nome {get; set; }
		public String cognome {get; set; }
		public String ragioneSociale {get; set; }
		public String partitaIva {get; set; }
		public String messaggio {get; set; }
		public String ifisFormId {get; set; }
		public String ifisFormIdUnivoco {get; set; }
		public String tipologiaClienti {get; set; }
		public String tipologiaInseritore {get; set; }
		public String contattoTelefonico {get; set; }
		public String email {get; set; }
		public String tipologiaInserimento {get; set; }
		public String privacyMarketing {get; set; }
		public String fatturato {get; set; }
	}

	@HttpPost
	global static RestCommon.ResponseObject acquisisciLead(RestCommon.TechInfo techInfo, AcquisisciLeadInputPayload payload) {

		Lead actualLead = new Lead();

		// CAMPI OBBLIGATORI

		if(String.isBlank(payload.nome) || String.isBlank(payload.cognome) || String.isBlank(payload.ragioneSociale) || String.isBlank(payload.partitaIva) || String.isBlank(payload.ifisFormId) || String.isBlank(payload.ifisFormIdUnivoco) || String.isBlank(payload.tipologiaClienti)){
		
			RestCommon.ResponseObject response = new RestCommon.ResponseObject('-1', 'Campi obbligatori non valorizzati correttamente');

			return response;
			 
		}
		
		actualLead.FirstName = payload.nome;
		actualLead.LastName = payload.cognome;
		actualLead.Company = payload.ragioneSociale;
		actualLead.PIVA__c = payload.partitaIva;
		actualLead.IFISForm__c = payload.ifisFormId;
		actualLead.IFISIdUnicoForm__c = payload.ifisFormIdUnivoco;
		actualLead.TipoAccount__c = payload.tipologiaClienti;

		// CAMPI NON OBBLIGATORI

		actualLead.Messaggio__c = payload.messaggio;
		actualLead.TipoAnagrafica__c = payload.tipologiaInseritore;
		actualLead.Phone = payload.contattoTelefonico;
		actualLead.Email = payload.email;
		actualLead.BI_Tipologia_Inserimento__c = payload.tipologiaInserimento;
		actualLead.PrivacyMarketing__c = payload.privacyMarketing;
		actualLead.BI_Fatturato__c = payload.fatturato;

		try {

			insert actualLead;

		}

		catch (Exception ex){
		
			RestCommon.ResponseObject response = new RestCommon.ResponseObject('-2', 'Errore generico nella procedura di inserimento');

			return response;

		}
		
		RestCommon.ResponseObject response = new RestCommon.ResponseObject('0', 'Risposta OK');

		return response;
	}

}