/**
  * Progetto:         Digital Selling Platform.
  * Sviluppatore      Marco Bonin <marco.bonin@bancaifis.it>
  * Descrizione:      Metodo che dato un account (per NDG o PIVA) allega una notifica (chatter)
  *
*/

@RestResource(urlMapping = '/notificaAccount/*')
global with sharing class BI_COM_NotificaAccount_REST {

	global class AllegaNotificaInputPayload {
		public String chiaveDiRicerca {get; set; }
		public String testo {get; set; }
		public String tipologiaNotifica {get; set; }
	}

	@HttpPost
	global static RestCommon.ResponseObject allegaNotifica(RestCommon.TechInfo techInfo, AllegaNotificaInputPayload payload) {

		String chiaveDiRicerca = payload.chiaveDiRicerca;

		String actualQuery = 'SELECT id FROM Account WHERE NDGGruppo__c = : chiaveDiRicerca';

		List<Account> actualAccount = Database.query(actualQuery);

		if (actualAccount.size() != 1) {

			RestCommon.ResponseObject response = new RestCommon.ResponseObject('-1', 'NDG non trovato');

			return response;

		}

		// INSERIMENTO DEL TESTO VIA CHATTER ABBINATO ALL'ACCOUNT

		ConnectApi.FeedElement feedElement = ConnectApi.ChatterFeeds.postFeedElement(Network.getNetworkId(), actualAccount.get(0).Id, ConnectApi.FeedElementType.FeedItem, payload.testo);

		RestCommon.ResponseObject response = new RestCommon.ResponseObject('0', 'Notifica inserita');

		return response;
	}

}