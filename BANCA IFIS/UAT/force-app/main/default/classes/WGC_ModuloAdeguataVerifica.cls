public class WGC_ModuloAdeguataVerifica {
	
    @AuraEnabled
    public static AdeguataVerifica__c getMAV(String accountId){
        List<AdeguataVerifica__c> mav = new List<AdeguataVerifica__c>();
        //FACTORY SV -- Aggiunta campo WGC_Rapporto_Profilo_economico__c  in query
        mav = [SELECT Id, Name, Natura_Factoring__c, Natura_Finanziamenti__c, Natura_Servizi_Bancari__c, Scopo_Factoring__c, Scopo_Finanziamenti__c, Scopo_Servizi_Bancari__c,
								Natura_Crediti_Erariali__c, Altro_Crediti_Erariali__c, ScopoFD11__c, ScopoFD12__c, ScopoFD13__c, ScopoFD14__c, ScopoFD15__c, ScopoFD16__c, ScopoFD17__c, ScopoFD18__c, ScopoFD19__c, 
                                OrigineFondi1__c, OrigineFondi2__c, OrigineFondi3__c, OrigineFondi4__c, OrigineFondiAltro__c,
                                Account__r.WGC_Visita_Locali_Azienda__c, WGC_Rapporto_Profilo_economico__c 
                                FROM AdeguataVerifica__c WHERE Account__c =: accountId AND Opportunita__c = null AND
                                CorrispondenzaCountry__c = null AND CorrispondenzaState__c = null AND CorrispondenzaCity__c = null AND 
                                CorrispondenzaStreetType__c = null AND CorrispondenzaStreetName__c = null AND 
                                CorrispondenzaStreetNumber__c = null AND CorrispondenzaCAP__c = null
                                ORDER BY LastModifiedDate DESC LIMIT 1];

        if(!mav.isEmpty()){
            return mav.get(0);
        }
        else{
            return null;
        }
        //return mav;
    }

    @AuraEnabled
    public static WrapperResponse SaveRecord(String recordId, String recordMAV, String recordAccountContact, Boolean flagConsensi, map<String,String> informazioniMav, String tipologiaMav, Boolean visitaLocaliAzienda){
        //System.debug('@@@ record ' + recordMAV);
        //System.debug('@@@ recordAccountContact ' + recordAccountContact);

        WrapperResponse wrap = new WrapperResponse();

        try{
            //Gestione titolari esecutori
            List<WGC_Modal_TitolareEsecutore_Controller.listWrapper> listaTitolari = (List<WGC_Modal_TitolareEsecutore_Controller.listWrapper>) JSON.deserialize(recordAccountContact, List<WGC_Modal_TitolareEsecutore_Controller.listWrapper>.Class);


            List<AccountContactRelation> relationToUpdate = new List<AccountContactRelation>();
            String idAccConsensi;

            for(WGC_Modal_TitolareEsecutore_Controller.listWrapper item : listaTitolari){
                if(item.isRelation){
                    System.debug('@@@ lista titolari ' + JSON.serialize(item));
                    //Lista che mi serve per paragonare titolare effettivo
                    // AccountContactRelation old = [SELECT Id, WGC_Ruolo__c FROM AccountContactRelation WHERE Id =:item.Id];

                    AccountContactRelation acr = new AccountContactRelation();
                    acr.Id = item.Id;
                    acr.WGC_Selezionato__c = true;

                    // List<String> ruoliOld = old.WGC_Ruolo__c.split(';');
                    // System.debug('ruoliOld: ' +ruoliOld);
                    // List<String> ruoliNew = item.WGC_Ruolo.value.split(';');
					// System.debug('ruoliNew: '+ruoliNew);
                    // if(ruoliOld.equals(ruoliNew)){
                    //     if(old.WGC_Ruolo__c == 'J;J1'){
                    //         acr.WGC_Ruolo_Pratica__c = 'J';
                    //     }
                    //     else{
                    //         acr.WGC_Ruolo_Pratica__c = item.WGC_Ruolo.value;
                    //     }
                    // }
                    // else if(ruoliOld.contains('J') && ruoliNew.contains('J1')){
                    //     ruoliNew.set(ruoliNew.indexOf('J1'), 'J');

                    //     String aa = '';
                    //     for(String s : ruoliNew){
                    //         aa += s + ';';
                    //     }

                    //     aa = aa.substring(0, aa.length()-1);
                    //     acr.WGC_Ruolo_Pratica__c = aa;
                    // }
                    // else if(ruoliOld.contains('J1') && ruoliNew.contains('J')){
                    //     ruoliNew.set(ruoliNew.indexOf('J'), 'J1');

                    //     String aa = '';
                    //     for(String s : ruoliNew){
                    //         aa += s + ';';
                    //     }

                    //     aa = aa.substring(0, aa.length()-1);
                    //     acr.WGC_Ruolo_Pratica__c = aa;
                    // }

                    //OLD
                    // if(item.WGC_Ruolo.value == 'J1;Z1' || item.WGC_Ruolo.value == 'J;Z1' 
                    //     || item.WGC_Ruolo.value == 'J' || item.WGC_Ruolo.value == 'J1' || item.WGC_Ruolo.value == 'J;J1'){
                    //     acr.WGC_Tipologia_Titolare_Effettivo__c = item.WGC_Tipologia_Titolare_Effettivo;
                    // }

                    if(item.titolareEffettivo != null){
                        if(item.Ruolo_Pratica.value.contains(item.titolareEffettivo)){
                            acr.WGC_Tipologia_Titolare_Effettivo__c = item.WGC_Tipologia_Titolare_Effettivo;
                        }
                    }

                    // if(item.WGC_Ruolo.value == 'Z1'){
                    //     acr.WGC_Ruolo_Pratica__c = 'Z1';
                    // }

                    // System.debug('@@@ item.Ruolo_Pratica.value ' + item.Ruolo_Pratica);
                    if(item.Ruolo_Pratica != null){
                        acr.WGC_Ruolo_Pratica__c = item.Ruolo_Pratica.value;
                    }

					if(item.comportamentoCliente != null){
                        acr.Comportamento_cliente__c = item.comportamentoCliente;
                    }
                    //FACTORY SV -- START
                    if(item.relazioneClienteEsecutore != null){
                        acr.WGC_Relazioni_Tra_Cliente_ed_Esecutore__c = item.relazioneClienteEsecutore;
                    }
                    //FACTORY SV -- END

                    //Popolo la stringa contentente accountId in cui effettuare un update sui flagConsensi
                    idAccConsensi = item.AccountId;

                    relationToUpdate.add(acr);

                    System.debug('@@@ acr ' + acr);
                }
                else{
                    AccountContactRelation acr = new AccountContactRelation();
                    acr.Id = item.Id;
                    acr.WGC_Selezionato__c = false;
                    //acr.WGC_Ruolo__c = null;
                    acr.WGC_Ruolo_Pratica__c = null;
                    acr.WGC_Tipologia_Titolare_Effettivo__c = null;

                    //Popolo la stringa contentente accountId in cui effettuare un update sui flagConsensi
                    idAccConsensi = item.AccountId;

                    relationToUpdate.add(acr);

                    System.debug('@@@ acr ' + acr);
                }
            }
 
            Account accVariazione = [SELECT Id, Name, NDGGruppo__c, NaturaGiuridica__c, CF__c, PIVA__c, PIVACF__c, SAE__c, RAE__c, REA__c,
                    BillingAddress, BillingCity, BillingPostalCode, BillingStreetName__c, BillingStreetType__c, BillingStreetNumber__c, BillingCountry, BillingState,
                    ShippingAddress, ShippingCity, ShippingStreetName__c, ShippingStreetType__c, ShippingStreetNumber__c, ShippingPostalCode, ShippingCountry, ShippingState,
                    TelefonoPrefisso__c, TelefonoNumero__c, NumberOfEmployees, Fax, Phone, EmailPEC__c, Email__c, Ateco__c, TAECode__c, DataIscrizioneCCIAA__c,
                    ConsensoAllaProfilazione__c, ConsensoAttivitaPromRicercheMercato__c,
                    ConsensoAttivitaPromozionaleTerzi__c, ConsensoProdottiBancaRicercheMercato__c,
                    ConsensoProdottiSocietaTerze__c, ConsensoSoloModalitaTradizionali__c, 
                    DataInserimentoConsensi__c, PartecipazioneSocietaFiduciarie2__c, Fatturato__c, DataFatturato__c,
                    WGC_Visita_Locali_Azienda__c
                    FROM Account
                    WHERE Id =: recordId];
            
            //

            //Loop per aggiornare il flag consensi sull'account, in teoria è solo un account
            accVariazione.PartecipazioneSocietaFiduciarie2__c = flagConsensi; //!= accVariazione.PartecipazioneSocietaFiduciarie2__c ? flagConsensi : accVariazione.PartecipazioneSocietaFiduciarie2__c;
			//dati Mav
			accVariazione.PaeseCasaMadre__c = informazioniMav.get('PaeseCasaMadre__c');
			accVariazione.PaeseSvolgimentoAttivitaPrevalente__c = informazioniMav.get('PaeseSvolgimentoAttivitaPrevalente__c');
			accVariazione.ProvinciaSvolgimentoAttivitaPrevalente__c = informazioniMav.get('ProvinciaSvolgimentoAttivitaPrevalente__c');
			accVariazione.PaeseRelazioni1__c = informazioniMav.get('PaeseRelazioni1__c');
			accVariazione.PaeseRelazioni2__c = informazioniMav.get('PaeseRelazioni2__c');
			accVariazione.PaeseRelazioni3__c = informazioniMav.get('PaeseRelazioni3__c');
            //FACTORY SV -- START
            accVariazione.WGC_Emissioni_di_Azioni_al_Portatore_PNF__c = Boolean.valueOf(informazioniMav.get('WGC_Emissioni_di_Azioni_al_Portatore_PNF__c'));
            accVariazione.WGC_Assetti_Attivita_Svolta__c = Boolean.valueOf(informazioniMav.get('WGC_Assetti_Attivita_Svolta__c'));
            accVariazione.WGC_Soggetti_Partecipanti__c = Boolean.valueOf(informazioniMav.get('WGC_Soggetti_Partecipanti__c'));
            accVariazione.WGC_Partecipazione_societa_fiduciarie__c = informazioniMav.get('WGC_Partecipazione_societa_fiduciarie__c');
            accVariazione.WGC_Partecipazione_Trust__c = informazioniMav.get('WGC_Partecipazione_Trust__c');
            accVariazione.WGC_Visita_Locali_Azienda__c = visitaLocaliAzienda;
            //FACTORY SV -- END
            String response = WsAnagrafeUtils.WGC_variazione(accVariazione, null);
            System.debug('@@@ response WGC_variazione ' + response);
            update accVariazione;

            System.debug('@@@ account updated ' + accVariazione);
            
            //update consensiToUpdate;

            AdeguataVerifica__c mav = (AdeguataVerifica__c) JSON.deserialize(recordMAV, AdeguataVerifica__c.Class);
            mav.Account__c = recordId;
            //
            mav.WGC_Data_Compilazione__c = System.Today();

            //PALUMBO 06/02/2020
            System.debug('Tipologia MAV: '+tipologiaMav);
            mav.WGC_TipologiaMav__c = tipologiaMav;

            //Salvo MAV
            // if(mav.Id != null){
            //     update mav;
            // }
            // else{
            //     insert mav;
            // }
			System.debug('ADEGUATA VERIFICA: '+JSON.serialize(mav));
            upsert mav;
            //Salvo AccountContactRelation
            update relationToUpdate;
            wrap.data.add(mav);
            wrap.message = 'OK';
            return wrap;
        }
        catch(Exception e){
            wrap.message = e.getMessage();
            wrap.success = false;

            return wrap;
        }        
    }

    public class WrapperResponse{
        @AuraEnabled
        public List<Object> data;
        @AuraEnabled
        public String message;
        @AuraEnabled
        public Boolean success;

        public WrapperResponse(){
            this.data = new List<Object>();
            this.message = '';
            this.success = true;
        }
    }

	 @AuraEnabled
    public static Map < String, String > getselectOptions_Nazione () {
        Map < String, String > allOpts = new Map < String, String > ();
        // Get the list of picklist values for this field.
        list < Comune__c > values = [SELECT Id, Name, GruppoSAE__c FROM Comune__c WHERE StatoEstero__c = TRUE AND FlagStorico__c = FALSE AND CodiceLingua__c = NULL ORDER BY Name];
        
        // Add these values to the selectoption list.
        for (Comune__c a: values) {
            allOpts.put(a.Name, a.Name);
        }
        return allOpts;
    }

	@AuraEnabled
    public static Map < String, String > getselectOptions_Province () {
        Map < String, String > allOpts = new Map < String, String > ();
        // Get the list of picklist values for this field.
        list < BI_Provincia__mdt > values = [SELECT Label, Sigla__c FROM BI_Provincia__mdt WHERE Flag_storico__c = FALSE ORDER BY Label];
        
        // Add these values to the selectoption list.
        for (BI_Provincia__mdt a: values) {
            allOpts.put(a.Sigla__c, a.Label);
        }
        return allOpts;
    }

	@AuraEnabled
    public static Account getDatiMavAccount(String accountId){
        List<Account> a = new List<Account>();
        //FACTORY SV -- aggiunto campo WGC_Partecipazione_Trust in query
        a = [SELECT Id, PaeseCasaMadre__c, PaeseSvolgimentoAttivitaPrevalente__c, ProvinciaSvolgimentoAttivitaPrevalente__c, PaeseRelazioni1__c, PaeseRelazioni2__c, PaeseRelazioni3__c, WGC_Gruppo_frm__c, WGC_Partecipazione_Trust__c, WGC_Partecipazione_societa_fiduciarie__c,
                    WGC_Emissioni_di_Azioni_al_Portatore_PNF__c, WGC_Assetti_Attivita_Svolta__c, WGC_Soggetti_Partecipanti__c
               FROM Account WHERE Id =: accountId LIMIT 1];
        if(!a.isEmpty()){
            return a.get(0);
        }
        else{
            return null;
        }
    }

    @AuraEnabled
    public static Map<String, String> getScopoFactoring(){
        Map<String, String> options = new Map<String, String>();
        Schema.DescribeFieldResult fieldResult = AdeguataVerifica__c.Scopo_Factoring__c.getDescribe();
        List<Schema.PicklistEntry> pList = fieldResult.getPicklistValues();
        for (Schema.PicklistEntry p: pList) {
             options.put(p.getValue(),p.getLabel());
        }
        return options;
    }

	@AuraEnabled
    public static Map<String, String> getScopoFinanziamenti(){
        Map<String, String> options = new Map<String, String>();
        Schema.DescribeFieldResult fieldResult = AdeguataVerifica__c.Scopo_Finanziamenti__c.getDescribe();
        List<Schema.PicklistEntry> pList = fieldResult.getPicklistValues();
        for (Schema.PicklistEntry p: pList) {
            options.put(p.getValue(),p.getLabel());
        }
        return options;
    }

	@AuraEnabled
    public static Map<String, String> getScopoServiziBancari(){
        Map<String, String> options = new Map<String, String>();
        Schema.DescribeFieldResult fieldResult = AdeguataVerifica__c.Scopo_Servizi_Bancari__c.getDescribe();
        List<Schema.PicklistEntry> pList = fieldResult.getPicklistValues();
        for (Schema.PicklistEntry p: pList) {
            options.put(p.getValue(),p.getLabel());
        }
        return options;
    }

	@AuraEnabled
    public static Map<String, String> getNaturaCreditiErariali(){
        Map<String, String> options = new Map<String, String>();
        Schema.DescribeFieldResult fieldResult = AdeguataVerifica__c.Natura_Crediti_Erariali__c.getDescribe();
        List<Schema.PicklistEntry> pList = fieldResult.getPicklistValues();
        for (Schema.PicklistEntry p: pList) {
            options.put(p.getValue(),p.getLabel());
        }
        return options;
    }

	@AuraEnabled
	public static String getProfilo() {
		Profile p = [Select Name from Profile where Id =: userinfo.getProfileid()];
		String profile = p.Name;
        return profile;
	}
}