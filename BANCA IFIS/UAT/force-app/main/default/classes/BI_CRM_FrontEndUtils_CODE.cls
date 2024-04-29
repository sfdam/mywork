public class BI_CRM_FrontEndUtils_CODE {

	/**
	 * recupera valori dei metadati NaturaGiuridicaSAE__mdt per aziende in base a provincia legale del recordId
	 */
	private static List<NaturaGiuridicaSAE__mdt> getMD(String naturaGiuridica, String sae, String recordId) {
		
		List<Account> accs = new List<Account>();
		if (!String.isBlank(recordId)) {
			String accQuery = 'SELECT BillingState__c FROM Account WHERE Id = \'' + recordId + '\'';
			accs = Database.query(accQuery);
		}

		String query = 'SELECT Id, Label, SAE__c, AtecoRichiesto__c, RaeRichiesto__c, SedeLegale__c FROM NaturaGiuridicaSAE__mdt WHERE SedeLegale__c = ';
		if (!accs.isEmpty())
			query += (accs[0].BillingState__c == 'EE') ? ' \'\' ' : ' \'IT\' '; //stringa vuota oppure IT
		else 
			//query += ' \'\' '; //stringa vuota
        	query += ' \'IT\' '; //default su IT - vedi ticket SDHDFNZ-77126

		if (String.isNotBlank(naturaGiuridica) && String.isNotBlank(sae)) {
			query+= ' AND Label = \''+naturaGiuridica + '\' AND SAE__c = \''+sae+'\'';
		}

		query += 'ORDER BY SAE__c';

        List<NaturaGiuridicaSAE__mdt> val_mdt = Database.query(query);
		return val_mdt;
	}

	//adione CRM ID 211
    @AuraEnabled
    public static Boolean getCCIAA_ATECO_Conf(String naturaGiuridica, String sae, String recordId, String objType) {
		//CCIAA, ATECO non ci sono per le PF
		if (objType == 'Contact')
			return false;

		//altrimenti per le PG
        List<NaturaGiuridicaSAE__mdt> val_mdt = getMD(naturaGiuridica, sae, recordId);

		if (String.isBlank(recordId)) { //nuovo account, mi baso su altri param
			return (!val_mdt.isEmpty()) ? val_mdt.get(0).AtecoRichiesto__c : false;
		} else {
			Boolean estero = true;
			String query = 'SELECT BillingState__c FROM Account WHERE Id = \'' + recordId + '\'';
			List<Account> accs = Database.query(query);
			if (!accs.isEmpty())
				estero = (accs[0].BillingState__c == 'EE') ? true : false;

			if (!val_mdt.isEmpty())
				return val_mdt.get(0).AtecoRichiesto__c && !estero;
			else
				//return false; //FIXME dovrebbe esser un errore? altrimenti manca record nei metadati
				return !estero;
		}
	}

	//adione CRM ID 211
	/**
	 * usato da flow "Crea opportunità" per determinare se anagrafica completa in fase di creazione oppoertunità
	 */
	@InvocableMethod(label='anagraficaCompleta' description='Determina se anagrafica censita completa')
	public static List<Boolean> anagraficaCompleta(List<String> inp) {
		List<Boolean> res = new List<Boolean>();
		if (inp == null || inp.size() == 0 || String.isBlank(inp[0])) {
			res.add(false);
			return res;
		}

		String recId = inp[0];
		Account a = [
			SELECT CodiceIstituto3N__c,
				Name,
				NDGGruppo__c,
				CF__c,
				PIVA__c,
				NaturaGiuridica__c,
				SAE__c,
				Ateco__c, 
				REA__c,
				ProvinciaCCIAA__c,
				BillingCity__c,
				BillingCountry__c,
				BillingPostalCode__c,
				BillingStreetNumber__c,
				BillingState__c,
				BillingStreetName__c,
				BillingStreetType__c
			FROM Account
			WHERE Id = :recId
			];

		Boolean obb = getCCIAA_ATECO_Conf(a.NaturaGiuridica__c, a.SAE__c, recId, 'Account');

		Boolean val = true;
		if (a.CodiceIstituto3N__c != '881')
			val = false;
		if (String.isBlank(a.Name))
			val = false;
		if (String.isBlank(a.NDGGruppo__c))
			val = false;
		if (String.isBlank(a.CF__c))
			val = false;
		if (String.isBlank(a.PIVA__c))
			val = false;
		if (String.isBlank(a.NaturaGiuridica__c))
			val = false;
		if (String.isBlank(a.SAE__c))
			val = false;
		if (String.isBlank(a.BillingCity__c))
			val = false;
		if (String.isBlank(a.BillingCountry__c))
			val = false;
		if (String.isBlank(a.BillingPostalCode__c))
			val = false;
		if (String.isBlank(a.BillingStreetNumber__c))
			val = false;
		if (String.isBlank(a.BillingState__c))
			val = false;
		if (String.isBlank(a.BillingStreetName__c))
			val = false;
		if (String.isBlank(a.BillingStreetType__c))
			val = false;
		if (obb) {
			if (String.isBlank(a.REA__c))
				val = false;
			if (String.isBlank(a.ProvinciaCCIAA__c))
				val = false;
			if (String.isBlank(a.Ateco__c))
				val = false;
		}

		res.add(val);
		return res;
	}

	//adione CRM ID 207 
    @AuraEnabled
    public static Map<String, String> getselectOptions_SAE(String tipoOggetto) {

        Map<String, String> allOpts = new Map <String, String>();
        List<NaturaGiuridicaSAE__mdt> val_mdt = getMD(null, null, null);

        // Mappa con tutti i tipi oggetto presenti nella ORG
        Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();       
        // recuperiamo il tipo oggetto passatto, dovrebbe essere Account oppure Contact
        Schema.SObjectType objType = gd.get(tipoOggetto);
        System.assert(objType != null,'Type provided: "' + tipoOggetto + '" doesnt map to an sobject token in this org.');
        // crea nuova istanza dell'oggetto
        Sobject objObject = objType.newSobject();
        // recupera info sull'oggetto istanziato
        Schema.DescribeSObjectResult objDescribe = objType.getDescribe();
        // recupera i campi definiti per l'oggetto
        Map<String, Schema.SObjectField> fieldMap = objDescribe.fields.getMap();
        
        // recupera la lista dei valori definiti per quel campo di quell'oggetto
        List<Schema.PicklistEntry> values = fieldMap.get('SAE__c').getDescribe().getPickListValues();
        system.debug('values --->' + values);
        
        // Add these values to the selectoption list.
        for (Schema.PicklistEntry a : values) {
            for(NaturaGiuridicaSAE__mdt x : val_mdt){
                if(x.SAE__c == a.getValue()){
                    allOpts.put(a.getLabel(), a.getValue());
                }
            }
        }
        system.debug('allOpts ---->' + allOpts);
       
        return allOpts;
	}
}