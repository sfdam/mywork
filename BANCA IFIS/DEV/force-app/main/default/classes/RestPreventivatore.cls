@RestResource(urlMapping = '/preventivatore')
global class RestPreventivatore {

	global class PreventivatoreResponse {
		Decimal costoMin, costoMax;
		Decimal incassoMin, incassoMax;
		String dataCessioneIpotetica;
		@testVisible Boolean success;
		@testVisible String message;

		public PreventivatoreResponse(Date d, Decimal costoMin, Decimal costoMax, Decimal incassoMin, Decimal incassoMax, String message) {
			if (d != null) {
				this.dataCessioneIpotetica = d.day() + '/' + d.month() + '/' + d.year();
			}

			this.costoMin = costoMin;
			this.costoMax = costoMax;
			this.incassoMin = incassoMin;
			this.incassoMax = incassoMax;
			this.message = message;
			this.success = String.isBlank(message);
		}
	}

	@HttpPost
	global static PreventivatoreResponse calcoloPreventivo(String codiceFiscale, Decimal importoFattura, String dataFattura) {
		Decimal costoMin, costoMax, incassoMin, incassoMax;
		Date dataCessioneIpotetica;

		String[] errori = validazioneInput(codiceFiscale, importoFattura, dataFattura);
		if (errori.isEmpty()) {

			try {
				Date dataFatt = Date.parse(dataFattura);
				dataCessioneIpotetica = Date.today() + 10;
				Integer deltaGiorni = dataCessioneIpotetica.daysBetween(dataFatt);

				Account[] tmp = [SELECT Id,
				                 SegmentoRischio__c
				                 FROM Account WHERE CF__c = :codiceFiscale
				                 AND SegmentoRischio__c != null];
				Account debitore = tmp[0];

				Decimal costo = TiAnticipoUtils.calcoloCostoPreventivoPubblico(
				                                                               debitore.SegmentoRischio__c,
				                                                               importoFattura,
				                                                               deltaGiorni);

				if (costo != null) {
					costoMin = costo * 0.9;
					costoMax = costo * 1.1;
					incassoMin = importoFattura - costoMax;
					incassoMax = importoFattura - costoMin;
				} else {
					errori.add('errore nel calcolo del preventivo');
				}

			} catch(Exception e) {
				errori.add(e.getMessage());
			}
		}

		return new PreventivatoreResponse(dataCessioneIpotetica, costoMin, costoMax, incassoMin, incassoMax, String.join(errori, ','));
	}

	private static String[] validazioneInput(String codiceFiscale, Decimal importoFattura, String dataFattura) {
		String[] errori = new String[] { };

		try {
			ParametriTiAnticipo__c parametriTA = ParametriTiAnticipo__c.getInstance();
			Date dataFatt = Date.parse(dataFattura);

			//adione-modifica soglie 
			if (importoFattura<parametriTA.ImportoMinimoCessione__c)
			errori.add('importo fattura inferiore alla soglia minima');

			Integer deltaGiorniScadenza = Date.today().daysBetween(dataFatt);
			if (deltaGiorniScadenza<parametriTA.Soglia_giorni_scadenza_fattura__c)
			errori.add('data scadenza fattura inferiore alla soglia minima');

			Date dataCessioneIpotetica = Date.today() + 10;
			Integer deltaGiorni = dataCessioneIpotetica.daysBetween(dataFatt);
			if (deltaGiorni< 10)
			errori.add('dataFattura non valida');

			Account[] tmp = [SELECT Id,
			                 SegmentoRischio__c
			                 FROM Account WHERE CF__c = :codiceFiscale
			                 AND SegmentoRischio__c != null];

			if (tmp.isEmpty())
			errori.add('debitore non trovato');

		} catch(Exception e) {
			errori.add(e.getMessage());
		}

		return errori;
	}
}