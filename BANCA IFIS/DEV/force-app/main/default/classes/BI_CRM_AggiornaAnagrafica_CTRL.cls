public class BI_CRM_AggiornaAnagrafica_CTRL {

	@AuraEnabled
	public static CreateAccount.WrapperResponse valorizzaAccount(String id) {
		CreateAccount.WrapperResponse response = new CreateAccount.WrapperResponse();
		response.data = [SELECT Id, NDGGruppo__c, Name, WGC_Censimento__c, NaturaGiuridica__c, ProvinciaCCIAA__c, REA__c, PIVA__c, VAT__c, CF__c, CodiceIstituto3N__c, DettaglioSettore__c, BillingCountry, BillingCountry__c, BillingStreet, BillingCity, BillingCity__c, BillingState, BillingState__c, BillingPostalCode, BillingPostalCode__c, BillingStreetName__c, BillingStreetNumber__c, BillingStreetType__c, StatoAnagrafica__c, DataIscrizioneCCIAA__c, RAE__c, SAE__c, Ateco__c, WGC_Data_inizio_attivita__c, WGC_Ammontare__c, WGC_Divisa__c FROM Account WHERE Id = :id LIMIT 1];
		System.debug('--- response.data:' + response.data.size());
		if (response.data.size() > 0) {
			if (response.data.get(0).WGC_Censimento__c == 'Completo') {
				response.success = false;
				response.msg = 'Il profilo risulta già completo';
				return response;
			}
			if (response.data.get(0).BillingState == 'EE') {
				response.success = false;
				response.msg = 'La chiamata ad InfoProvider può essere fatta solo per le anagrafiche italiane';
				return response;
			}
			CreateAccount.WrapperRecords wr1 = new CreateAccount.WrapperRecords();
			wr1.pivaOrCf = response.data.get(0).CF__c;
			wr1.estero = false;
			String strWR = JSON.serialize(wr1);
			Account[] AccountList = new Account[] { };
			String AccountListString = JSON.serialize(AccountList);
			System.debug('--- Get info Ribes');
			try {
				CreateAccount.WrapperResponse result;
				if (Test.isRunningTest()) {
					List<Account> listAcc = [SELECT Id, CF__c FROM Account LIMIT 1];
					String strListAcc = JSON.serialize(listAcc);
					CreateAccount.WrapperRecords wr1Bis = new CreateAccount.WrapperRecords();
					wr1Bis.pivaOrCf = listAcc[0].CF__c;
					wr1Bis.tipoDiRicerca = 'piva';
					wr1Bis.ragioneSociale = 'Test';

					wr1Bis.estero = false;
					String strWRBis = JSON.serialize(wr1Bis);
					Test.setMock(HttpCalloutMock.class, new WGC_HttpRequestController_MockImpl());
					result = CreateAccount.getInformationAccountFromRibes(strWRBis, strListAcc);

				} else {
					result = CreateAccount.getInformationAccountFromRibes(strWR, AccountListString);
				}
				if (result.data.size() > 0) {
					WsRestRibesUtils ribesUtils = new WsRestRibesUtils();
					System.debug('--- Get info Ribes PG');
					if (Test.isRunningTest()) {
						result.data.get(0).REA__c = '383414';
						result.data.get(0).ProvinciaCCIAA__c = 'PD';
					}
					Account res = ribesUtils.updateDatiAnagraficiRibesPg(result.data.get(0));
					String esito = valorizzaDatiMancanti(response.data.get(0), res);
					CtrlWizardAccount.truncateAccount(response.data.get(0));
					response.success = true;
					response.msg = esito;
					return response;
				} else {
					response.success = false;
					response.msg = (result.msg != '')? 'Errore durante la chiamata a InfoProvider: ' + result.msg : 'Anagrafica INATTIVA, non aggiornata';
				}
			} catch(exception e) {
				response.success = false;
				response.msg = e.getMessage();
			}
			return response;
		}
		response.success = false;
		response.msg = 'Anagrafica non trovata in CRM';
		return response;
	}

	public static String valorizzaDatiMancanti(Account accountEsistente, Account accountRibes) {
		String campoVar = '';
		System.debug('--- accountEsistente Prima: ' + accountEsistente);
		if (accountEsistente.Name == null) { if (accountRibes.Name != null) {accountEsistente.Name = accountRibes.Name; campoVar = campoVar + 'Ragione Sociale: ' + accountEsistente.Name + '\n'; }}
		if (accountEsistente.NaturaGiuridica__c == null) { if (accountRibes.NaturaGiuridica__c != null) {accountEsistente.NaturaGiuridica__c = accountRibes.NaturaGiuridica__c; campoVar = campoVar + 'NaturaGiuridica: ' + accountEsistente.NaturaGiuridica__c + '\n'; }}
		if (accountEsistente.ProvinciaCCIAA__c == null) { if (accountRibes.ProvinciaCCIAA__c != null) {accountEsistente.ProvinciaCCIAA__c = accountRibes.ProvinciaCCIAA__c; campoVar = campoVar + 'Provincia CCIAA: ' + accountEsistente.ProvinciaCCIAA__c + '\n'; }}
		if (accountEsistente.REA__c == null) {if (accountRibes.REA__c != null) { accountEsistente.REA__c = accountRibes.REA__c; campoVar = campoVar + 'Numero REA: ' + accountEsistente.REA__c + '\n'; }}
		if (accountEsistente.PIVA__c == null) { if (accountRibes.PIVA__c != null) { accountEsistente.PIVA__c = accountRibes.PIVA__c; campoVar = campoVar + 'Partita IVA: ' + accountEsistente.PIVA__c + '\n'; }}
		if (accountEsistente.VAT__c == null) { if (accountRibes.VAT__c != null) {accountEsistente.VAT__c = accountRibes.VAT__c; }}
		if (accountEsistente.CF__c == null) { if (accountRibes.CF__c != null) {accountEsistente.CF__c = accountRibes.CF__c; campoVar = campoVar + 'Codice Fiscale: ' + accountEsistente.CF__c + '\n'; }}
		if (accountEsistente.CodiceIstituto3N__c == null) { if (accountRibes.CodiceIstituto3N__c != null) {accountEsistente.CodiceIstituto3N__c = accountRibes.CodiceIstituto3N__c; }}
		if (accountEsistente.DettaglioSettore__c == null) { if (accountRibes.DettaglioSettore__c != null) {accountEsistente.DettaglioSettore__c = accountRibes.DettaglioSettore__c; }}
		if (accountEsistente.BillingStreet == null) { if (accountRibes.BillingStreet != null) {accountEsistente.BillingStreet = accountRibes.BillingStreet; }}
		if (accountEsistente.BillingCity == null) { if (accountRibes.BillingCity != null) {accountEsistente.BillingCity = accountRibes.BillingCity; }}
		if (accountEsistente.BillingCity__c == null) { if (accountRibes.BillingCity__c != null) {accountEsistente.BillingCity__c = accountRibes.BillingCity; campoVar = campoVar + 'Città Sede Legale: ' + accountEsistente.BillingCity + '\n'; }}
		if (accountEsistente.BillingState == null) { if (accountRibes.BillingState != null) {accountEsistente.BillingState = accountRibes.BillingState; }}
		if (accountEsistente.BillingState__c == null) { if (accountRibes.BillingState__c != null) {accountEsistente.BillingState__c = accountRibes.BillingState; campoVar = campoVar + 'Provincia Sede Legale: ' + accountEsistente.BillingState + '\n'; }}
		if (accountEsistente.BillingPostalCode == null) { if (accountRibes.BillingPostalCode != null) {accountEsistente.BillingPostalCode = accountRibes.BillingPostalCode; }}
		if (accountEsistente.BillingPostalCode__c == null) { if (accountRibes.BillingPostalCode__c != null) {accountEsistente.BillingPostalCode__c = accountRibes.BillingPostalCode; campoVar = campoVar + 'CAP Sede Legale: ' + accountEsistente.BillingPostalCode + '\n'; }}
		if (accountEsistente.BillingStreetName__c == null) { if (accountRibes.BillingStreetName__c != null) {accountEsistente.BillingStreetName__c = accountRibes.BillingStreetName__c; campoVar = campoVar + 'Nome Via Sede Legale: ' + accountEsistente.BillingStreetName__c + '\n'; }}
        if (accountEsistente.BillingStreetNumber__c == null) { if (accountRibes.BillingStreetNumber__c != null) {accountEsistente.BillingStreetNumber__c = accountRibes.BillingStreetNumber__c; campoVar = campoVar + 'Numero Civico Sede Legale: ' + accountEsistente.BillingStreetNumber__c + '\n'; }}
		if (accountEsistente.BillingStreetType__c == null) { if (accountRibes.BillingStreetType__c != null) {accountEsistente.BillingStreetType__c = accountRibes.BillingStreetType__c; campoVar = campoVar + 'Tipo Via Sede Legaleccii: ' + accountEsistente.BillingStreetType__c + '\n'; }}
		if (accountEsistente.StatoAnagrafica__c == null) { if (accountRibes.StatoAnagrafica__c != null) {accountEsistente.StatoAnagrafica__c = accountRibes.StatoAnagrafica__c; }}
		if (accountEsistente.DataIscrizioneCCIAA__c == null) { if (accountRibes.DataIscrizioneCCIAA__c != null) {accountEsistente.DataIscrizioneCCIAA__c = accountRibes.DataIscrizioneCCIAA__c; campoVar = campoVar + 'Data Iscrizione CCIAA: ' + accountEsistente.DataIscrizioneCCIAA__c.format() + '\n'; }}
		//if (accountEsistente.RAE__c == null) { accountEsistente.RAE__c = accountRibes.RAE__c; campoVar= campoVar + 'RAE \n';}
		if (accountEsistente.SAE__c == null) { if (accountRibes.SAE__c != null) {accountEsistente.SAE__c = accountRibes.SAE__c; campoVar = campoVar + 'SAE: ' + accountEsistente.SAE__c + '\n'; }}
		if (accountEsistente.Ateco__c == null) { if (accountRibes.Ateco__c != null) {accountEsistente.Ateco__c = accountRibes.Ateco__c; campoVar = campoVar + 'Ateco: ' + accountEsistente.Ateco__c + '\n'; }}
		if (accountEsistente.WGC_Data_inizio_attivita__c == null) { if (accountRibes.WGC_Data_inizio_attivita__c != null) {accountEsistente.WGC_Data_inizio_attivita__c = accountRibes.WGC_Data_inizio_attivita__c; }}
		if(accountEsistente.BillingCountry == null) { accountEsistente.BillingCountry = 'ITALIA';}
        if(accountEsistente.BillingCountry__c == null) { accountEsistente.BillingCountry__c = 'ITALIA'; campoVar = campoVar + 'Nazione Sede Legale: ' + accountEsistente.BillingCountry;}
		String estito = (!String.isBlank(campoVar)) ? 'Richiesta completata. Verranno inseriti i seguenti campi: \n\n' + campoVar : 'Richiesta completata. Non ci sono campi da aggiornare.';
		System.debug('Campi aggiornati: ' + campoVar);
		return estito;
	}


	@AuraEnabled
	public static CreateAccount.WrapperResponse aggiornaAccount(Account a) {
		CreateAccount.WrapperResponse response = new CreateAccount.WrapperResponse();
		System.debug('--- entra in variazione');
		try {
			a.NDGGruppo__c = WsAnagrafeUtils.WGC_variazione(a, null);
			System.debug('--- NDGGruppo__c variato ' + a.NDGGruppo__c);
			if (!String.isBlank(a.NDGGruppo__c)) {
				update a;
				System.debug('--- Aggiornato NDG: ' + a.NDGGruppo__c);
				response.success = true;
				response.msg = 'Aggiornamento completato';
				return response;
			}
		} catch(exception e) {
			response.success = false;
			response.msg = e.getMessage();
		}
		return response;
	}
}