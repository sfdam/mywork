global class bifis_crm_b_MccNsaGenerateOpportunity implements Database.Batchable<SObject>, Database.AllowsCallouts, Database.Stateful {
	
	RecordType oppRecType = [SELECT Id FROM RecordType WHERE DeveloperName = 'IFISOpportunitaFactoring' LIMIT 1];
	RecordType lineaRecType = [SELECT Id FROM RecordType WHERE DeveloperName = 'Fido' LIMIT 1];
	Prodotto__c prodMutuo = [SELECT Id, WGC_Famiglia__c FROM Prodotto__c WHERE CodiceUnivoco__c= 'MutuoPCNSA' LIMIT 1];
	Prodotto__c prodMutuoSA = [SELECT Id, WGC_Famiglia__c FROM Prodotto__c WHERE CodiceUnivoco__c= 'MutuoPCNSASA' LIMIT 1];
	Id rtMutuoMCNSA = U.getRecordTypes('Linea__c').get('Fido').Id;
	Set<WorkflowMutui__c> toBeConverted;
	Integer recordElaborati = 0;
	Account a;
	List<Object> referenti; 
	Contact esecutore;
	WorkflowMutui__c w; 
	Opportunity o;
	Map<Integer, Domanda[]> domandeMap;
	String advPayload = '';
	OrgWideEmailAddress owa = [SELECT id, Address, DisplayName from OrgWideEmailAddress where DisplayName = 'Portale Pratiche MCC NSA' limit 1];
	Parametri_MccNsa__c mccNsaParameters = Parametri_MccNsa__c.getInstance();
	//adione-CRM20
	String cmDevName = 'Partner_Broker_NSA';
	WGC_Originator__mdt originatorMD = [
		SELECT Originator__c, Originator_dettaglio__c
		FROM WGC_Originator__mdt
		WHERE DeveloperName = :cmDevName
	];

	/**
	 * empty constructor: will process all NSA objects with status 'INVIATA'
	 */
	global bifis_crm_b_MccNsaGenerateOpportunity() {
	}

	/**
	 * default constructor: loads and processes the objects passed in input
	 */
	global bifis_crm_b_MccNsaGenerateOpportunity(Set<WorkflowMutui__c> toBeConverted) {	
		this.toBeConverted = toBeConverted;
	}

	/**
	 * @description gets invoked when the batch job starts
	 * @param context contains the job ID
	 * @returns the record set as a QueryLocator object that will be batched for execution
	 */ 
	global Database.QueryLocator start(Database.BatchableContext context) {
		Set<Id> ids = new Set<Id>();
		if (toBeConverted != null) {
			for (WorkflowMutui__c w : toBeConverted) {
				ids.add(w.Id);
			}
		} 

		return Database.getQueryLocator(QueryBuilder.newInstance('WorkflowMutui__c', new String[]{
			'Id',
			'AltreNoteNSA__c', 
			'CapAltro__c', 
			'CapLegale__c', 
			'CapSpedizione__c', 
			'CittaAltro__c', 
			'CittaLegale__c', 
			'CittaSpedizione__c', 
			'TipoViaLegale__c',
			'TipoViaSpedizione__c',
			'CivicoLegale__c',
			'CivicoSpedizione__c',
			'IndirizzoLegale__c',
			'IndirizzoSpedizione__c',
			'IndirizzoAltro__c', 
			'ProvinciaLegale__c',
			'ProvinciaSpedizione__c',
			'ProvinciaAltro__c', 
			'CostoMediazione__c', 
			'DurataPreAmmortamento__c', 
			'DurataTotale__c', 
			'EmailPEC__c', 
			'Email__c', 
			'Fatturato__c', 
			'Fax__c', 
			'Finalita__c', 
			'Floor__c', 
			'GaranziaImporto__c', 
			'Importo__c', 
			'MAV_Affidamenti__c', 
			'MAV_Altro_Descrizione__c', 
			'MAV_Altro__c', 
			'MAV_Cessione__c', 
			'MAV_Fornitori__c', 
			'MAV_Incassi_Pagamenti__c', 
			'MAV_Investimento__c', 
			'MAV_Natura_Rapporto__c', 
			'MAV_Proventi__c', 
			'MAV_Smobilizzo_Estero__c', 
			'MAV_Smobilizzo_Italia__c', 
			'MAV_Stipendi__c', 
			'MAV_Straordinari__c', 
			'MAV_Tesorerie__c', 
			'MAV_Transazioni_Estero__c', 
			'MTC_Indirizzo__c', 
			'NumeroAddetti__c', 
			'PartitaIVA__c', 
			'Privacy_Azienda_1__c', 
			'Privacy_Azienda_2__c', 
			'Privacy_Azienda_3__c', 
			'Privacy_Azienda_4__c', 
			'Privacy_Azienda_5__c', 
			'Privacy_Azienda_Tradizionali__c', 
			'Privacy_Esecutore_1__c', 
			'Privacy_Esecutore_2__c', 
			'Privacy_Esecutore_3__c', 
			'Privacy_Esecutore_4__c', 
			'Privacy_Esecutore_5__c', 
			'Privacy_Esecutore_Tradizionali__c', 
			'ProvinciaCCIAA__c', 
			'QQCO10__c', 
			'QQCO11__c', 
			'QQCO12__c', 
			'QQCO13__c', 
			'QQCO14__c', 
			'QQCO15__c', 
			'QQCO16__c', 
			'QQCO17__c', 
			'QQCO18__c', 
			'QQCO19__c', 
			'QQCO1__c', 
			'QQCO20__c', 
			'QQCO21__c', 
			'QQCO2__c', 
			'QQCO3__c', 
			'QQCO4__c', 
			'QQCO5__c', 
			'QQCO6__c', 
			'QQCO7__c', 
			'QQCO8__c', 
			'QQCO9__c', 
			'QQSB10__c', 
			'QQSB11__c', 
			'QQSB12__c', 
			'QQSB13__c', 
			'QQSB14__c', 
			'QQSB15__c', 
			'QQSB16__c', 
			'QQSB17__c', 
			'QQSB18__c', 
			'QQSB1__c', 
			'QQSB2__c', 
			'QQSB3__c', 
			'QQSB4__c', 
			'QQSB5__c', 
			'QQSB6__c', 
			'QQSB7__c', 
			'QQSB8__c', 
			'QQSB9__c', 
			'Ragione_Sociale__c', 
			'SpeseCommissione__c', 
			'SpeseIstruttoria__c', 
			'SpreadPositivo__c', 
			'Stato__c', 
			'StatoElaborazione__c',
			'Telefono__c', 
			'TipologiaQuestionario__c', 
			'Tipologia_Mutuo__c', 
			'ImportoSA__c', 
			'DurataPreAmmortamentoSA__c', 
			'DurataTotaleSA__c', 
			'FinalitaSA__c', 
			'SpreadPositivoSA__c', 
			'FloorSA__c', 
			'SpeseIstruttoriaSA__c', 
			'SpeseCommissioneSA__c', 
			'CostoMediazioneSA__c', 
			'GaranziaImportoSA__c', 
			'DOCUMENTO_A4_JSON__c',
			'DOCUMENTO_BE3_JSON__c',
			'DOCUMENTO_BESC_JSON__c',
			'DOCUMENTO_BPR_JSON__c',
			'DOCUMENTO_BVA_JSON__c',
			'DOCUMENTO_DAB_JSON__c',
			'DOCUMENTO_DCVC_JSON__c',
			'DOCUMENTO_DIA4_JSON__c',
			'DOCUMENTO_DIC_JSON__c',
			'DOCUMENTO_DIE_JSON__c',
			'DOCUMENTO_DIT_JSON__c',
			'DOCUMENTO_DITS_JSON__c',
			'DOCUMENTO_DM10_JSON__c',
			'DOCUMENTO_DM10I_JSON__c',
			'DOCUMENTO_ECF_JSON__c',
			'DOCUMENTO_GCE_JSON__c',
			'DOCUMENTO_MAV_JSON__c',
			'DOCUMENTO_MPA_JSON__c',
			'DOCUMENTO_MPE_JSON__c',
			'DOCUMENTO_MTC_JSON__c',
			'DOCUMENTO_MU2_JSON__c',
			'DOCUMENTO_MUS_JSON__c',
			'DOCUMENTO_PCD_JSON__c',
			'DOCUMENTO_PRO_JSON__c',
			'DOCUMENTO_RI_JSON__c',
			'DOCUMENTO_RSF_JSON__c',
			'DOCUMENTO_SDG_JSON__c',
			'DOCUMENTO_SVR_JSON__c',
			'DOCUMENTO_UAC_JSON__c',
			'DOCUMENTO_VCL_JSON__c',
			'REFERENTI_JSON__c',
			'Numero_Pratica_Crm__c',
			'Opportunity__c',
			'SAE__c',
			'RAE__c',
			'ATECO__c',
			'Natura_Giuridica__c'
		})
		  .beginFilter()
              .beginAnd()
                .add('StatoElaborazione__c', QBOp.QEQUAL, 'DA ELABORARE')
                .add('Stato__c', QBOp.QEQUAL, 'INVIATA')
                .add('Id', QBOp.QIN, ids)
              .end()
            .endFilter()
			.setLimit(1)
		  .getQuery()
		);


	}

	/**
	 * @description gets invoked when the batch job executes and operates on one batch of records. Contains or calls the main execution logic for the batch job.
	 * @param context contains the job ID
	 * @param scope contains the batch of records to process.
	 */ 
   	global void execute(Database.BatchableContext context, List<WorkflowMutui__c> scope) {
		//prepare for rollback in case of errors
		System.SavePoint sp;

		//something to process?
		if (scope.size() > 0) {
			try {
				//evita di creare automaticamente contatto telefonico nella onInsert dell'Account
				TrgAccount.disabilitaCreazioneCTDopoInsertAccount = true;

				recordElaborati = scope.size();
				//process 1 object at a time to avoid hitting gov. limits
				w = scope[0];

				if (String.isBlank(w.PartitaIVA__c)) {
					throw new bifis_crm_c_MccNsaException('Manca la Partita IVA - ' + w);
				}

				//can we find company in CRM or Ribes?
				a = bifis_crm_c_CommonUtils.searchByPIVA(w.PartitaIVA__c);
				if(a == null) {
					a = bifis_crm_c_CommonUtils.createFromNSAObj(w);
				}
	
				//segna elaborazione partita
				w.StatoElaborazione__c = 'PARZIALE';
				//cancella eventuali messaggi d'errore di elaborazioni precedenti
				w.ErrorMessage__c = '';
		        a.CanaleSviluppo__c = '1'; //BROKER
				a.Sottocanale__c = '998'; //NSA
				/*
				 * create/update Account
				 */
				//Se è nuovo prospect assegno a utenza default
				if(a.Id == null)
					a.OwnerId = UtenzeDefault__c.getInstance().IdUtente__c;
				if(String.isNotBlank(w.Telefono__c))
					a.Phone = w.Telefono__c;
				if(String.isNotBlank(w.Fax__c))
					a.Fax = w.Fax__c;
				if(String.isNotBlank(w.Email__c))
					a.Email__c = w.Email__c;
				if(String.isNotBlank(w.EmailPEC__c))
					a.EmailPEC__c = w.EmailPEC__c;

				if(String.isNotBlank(w.CittaLegale__c)) {
					a.BillingCity = w.CittaLegale__c.toUpperCase();
					a.BillingCity__c = w.CittaLegale__c.toUpperCase();
				}
				if(String.isNotBlank(w.CapLegale__c)) {
					a.BillingPostalCode = w.CapLegale__c;
					a.BillingPostalCode__c = w.CapLegale__c;
				}
				if(String.isNotBlank(w.ProvinciaLegale__c)) {
					a.BillingState = w.ProvinciaLegale__c.toUpperCase();
					a.BillingState__c = w.ProvinciaLegale__c.toUpperCase();
				}
				if(String.isNotBlank(w.IndirizzoLegale__c))
					a.BillingStreetName__c = w.IndirizzoLegale__c.toUpperCase();
				if(String.isNotBlank(w.CivicoLegale__c))
					a.BillingStreetNumber__c = w.CivicoLegale__c.toUpperCase();
				if(String.isNotBlank(w.TipoViaLegale__c))
					a.BillingStreetType__c = w.TipoViaLegale__c.toUpperCase();
					
				if(String.isNotBlank(w.CittaSpedizione__c)) {
					a.ShippingCity = w.CittaSpedizione__c.toUpperCase();
					a.ShippingCity__c = w.CittaSpedizione__c.toUpperCase();
				}
				if(String.isNotBlank(w.CapSpedizione__c)) {
					a.ShippingPostalCode = w.CapSpedizione__c;
					a.ShippingPostalCode__c = w.CapSpedizione__c;
				}
				if(String.isNotBlank(w.ProvinciaSpedizione__c)) {
					a.ShippingState = w.ProvinciaSpedizione__c.toUpperCase();
					a.ShippingState__c = w.ProvinciaSpedizione__c.toUpperCase();
				}
				if(String.isNotBlank(w.IndirizzoSpedizione__c))
					a.ShippingStreetName__c = w.IndirizzoSpedizione__c.toUpperCase();
				if(String.isNotBlank(w.CivicoSpedizione__c))
					a.ShippingStreetNumber__c = w.CivicoSpedizione__c.toUpperCase();
				if(String.isNotBlank(w.TipoViaSpedizione__c))
					a.ShippingStreetType__c = w.TipoViaSpedizione__c.toUpperCase();
				//adione-CRM20
				a.WGC_Originator__c = originatorMD.Originator__c;
				a.WGC_Originator_dettaglio__c = originatorMD.Originator_dettaglio__c;
				a.WGC_Specialista_Factoring__c = a.ownerId; //usato per ricavare filiale per invio a NV
				if(w.NumeroAddetti__c != null) {
					a.NumberOfEmployees = Integer.valueOf(w.NumeroAddetti__c);
					a.WGC_Numero_dipendenti__c = w.NumeroAddetti__c;
				}
				if(w.Fatturato__c != null)
					a.Fatturato__c = (w.Fatturato__c / 1000).round(System.RoundingMode.HALF_DOWN); //adione-CRM20 fatturato mostrato in migliaia
				if(String.isNotBlank(w.ProvinciaCCIAA__c))
					a.ProvinciaCCIAA__c = w.ProvinciaCCIAA__c;
				if(String.isNotBlank(w.REA__c)) {
					a.REA__c = w.REA__c;
					a.CCIAA__c = w.REA__c;
				}
				if(String.isNotBlank(w.Natura_Giuridica__c)) {
					a.NaturaGiuridica__c = w.Natura_Giuridica__c;
				}
				//store new Account
				Account[] accs = TrgAccount.gestisciOwner(new Account[]{a});
				//fix ownership based on NSA rules
				TrgAccount.assegnazioneAnagraficaOperatoriNSA(accs);
				//gestisci sae/rae/ateco: tieniamo quelli recuperati se Account esistente
				//oppure recuperati da infoprovider, altrimenti usiamo quelli inseriti da Community
				if (a.SAE__c == null) a.SAE__c = w.SAE__c;
				if (a.RAE__c == null) a.RAE__c = w.RAE__c;
				if (a.Ateco__c == null) a.Ateco__c = w.Ateco__c;


				upsert accs;//qui ottengo anche l'eventuale account Id in caso sia un nuovo PG non presente in CRM
				//can we find contacts in CRM? Otherwise insert them
				referenti = bifis_crm_c_CommonUtils.parseReferentiJSON(w.REFERENTI_JSON__c);
				//crea, inserisce e correla all'account i referenti
				bifis_crm_c_CommonUtils.createFromNSAObj(referenti, a.Id);

				String cfEsecutore; 
				for(Object current : referenti) {	
					Map<String, Object> m = (Map<String, Object>) current;
					String valoreRuolo = (String) m.get('ruolo');
					if(valoreRuolo.containsIgnoreCase('Esecutore')) {
						cfEsecutore = (String) m.get('codiceFiscale');
						break;
					}
				}
				esecutore = bifis_crm_c_CommonUtils.searchByCodFisc(cfEsecutore);

				//crea Opportunità
				o = createOpportunity(a);
				insert o; //qui ottengo opportunity Id che mi serve per le config linee
				//associa prodotto e suoi parametri all'opportunità appena creata
				updateLinea(w, o.Id);
				//compila privacy
				o = compilaPrivacy(a, esecutore, o, w); //azienda + esecutore
				//compila QQ
				compilaQQ(a, o, w);
				//compila MAV e MTC
				compilaADV(a, referenti, o, w); //tutti i referenti
				
				/*
				 * update WorkflowMutui__c
				 */
				w.Numero_Pratica_Crm__c = o.Id;
				w.Opportunity__c =  o.Id;
				update w;
				update o;

			} catch(bifis_crm_c_MccNsaException e) {
				//rollback
				if(sp != null)
					Database.rollback(sp);

				//log error
				bifis_crm_c_CommonUtils.logError(a, esecutore, w, e);
				this.sendErrorMail(w, e);

				//update w status
				w.StatoElaborazione__c = 'ERRORE';
				w.ErrorMessage__c = (e.getMessage() + '\n\n' + e.getStackTraceString()).abbreviate(131072);
				update w;

			} catch(CalloutException e) {
				if(sp != null)
					Database.rollback(sp);

				//log error
				bifis_crm_c_CommonUtils.logError(a, esecutore, w, e);
				this.sendErrorMail(w, e);

				//update w status
				w.StatoElaborazione__c = 'ERRORE';
				w.ErrorMessage__c = (e.getMessage() + '\n\n' + e.getStackTraceString()).abbreviate(131072);
				update w;

			} catch(Exception e) {
				if(sp != null)
					Database.rollback(sp);

				//log error
				bifis_crm_c_CommonUtils.logError(a, esecutore, w, e);
				this.sendErrorMail(w, e);

				//update w status
				w.StatoElaborazione__c = 'ERRORE';
				w.ErrorMessage__c = (e.getMessage() + '\n\n' + e.getStackTraceString()).abbreviate(131072);
				update w;
			}
		}
	}
	
	/**
	 * @description gets invoked when the batch job finishes. Place any clean up code in this method.
	 * @param context contains the job ID
	 */ 
	global void finish(Database.BatchableContext context) {
		if (recordElaborati > 0) {

			//call out jobs
			System.enqueueJob(new AsyncJobsNSA_Q(
				a, 
				referenti,
                o,
				w, 
				domandeMap,
				advPayload,
				'PG'
			));
			//set flag
			CtrlWizardOpportunity.setWizardCompletato(o.Id, true);
		}
	}

	/**
	 * crea opportunità e preimposta alcuni campi, si basa su custom setting per gestire operatività
	 * prodotto mutui mcc nsa ovvero pre-imposta alcune configurazioni opportunità-linea
	 */
	private Opportunity createOpportunity(Account a) {
		Opportunity o = new Opportunity();
		o.CloseDate = Date.today().addMonths(1);
		o.RecordTypeId = oppRecType.Id;
		o.AccountId = a.Id;
		//adione-CRM20 adeguamenti valori standard
		o.StageName = 'In Istruttoria';
		o.Tipologia_Opportunit__c = 'CONC'; //Nuova Concessione
		o.WGC_Prodotti_Selezionati__c = prodMutuo.WGC_Famiglia__c;
		o.Originator__c = originatorMD.Originator__c;
		o.Originator_di_dettaglio__c = originatorMD.Originator_dettaglio__c;
		//testo standard fisso
		o.DescrizioneOperazioneProposta__c = 'Si propone operazione di Mutuo PMI a MLT garantito dal Fondo di Garanzia l. 662/96 originata nell’ambito dell’accordo di collaborazione sottoscritto con NSA SpA.\nLa documentazione pre contrattuale e istruttoria a supporto della proposta è disponibile nel documentale.';
		//eventuale altro commento inserito nella pratica
		o.NoteStoricheAziendaeAttivitaSvolte__c = w.AltreNoteNSA__c;
		o.AnalisiDiBilancio__c = '.';
		o.Approfondimenti__c = '.';
		o.ComposizioneDelCapitaleSociale__c = '.';
		o.Garanzie__c = '.';
		o.NoteSuEsponentiManagementESoci__c = '.';
		o.ProgrammiEProspettiveFuture__c = '.';
		o.RapportiBancariECR__c = '.';	
		o.ModalitaDiAperturaPEF__c = 'Pre-consolidata'; //serve per la spunta verde a FE
		//CR 142 - Centrale Rischi non bloccante NSA
		o.WGC_Presa_Visione_CR__c = true;
		o.WGC_NoteCR__c = 'Forzata per operatore NSA';
		//prevalorizzato per NSA - introdotto con rilascio TEN 8.1
		o.WGC_Configurazione_Prodotti_Completa__c = true;

		return o;
	}

	/**
	 * aggiorna Linea (prodotto) dell'opportunità creata, si basa su custom setting per gestire operatività
	 * prodotto mutui mcc nsa ovvero pre-imposta alcune configurazioni linea-parametri
	 * qui facciamo eventuali override delle configurazioni in base all'input utente
	 */
	private void updateLinea(WorkflowMutui__c w, Id oid) {
		List<PConfigurato__c> pconfs = new List<PConfigurato__c>();
		//cancella eventuale linea autocreata nel trigger
		List<Linea__c> autoL = [SELECT Id FROM Linea__c WHERE Opportunity__c = :oid];
        delete autoL;

		String spreadPositivo;
		if (w.Tipologia_Mutuo__c == bifis_crm_c_CommonUtils.STANDARD
			|| w.Tipologia_Mutuo__c == bifis_crm_c_CommonUtils.MISTO) {
			Linea__c l = new Linea__c(
				Opportunity__c = oid, 
				Prodotto__c = prodMutuo.id, 
				RecordTypeId = rtMutuoMCNSA
			);
			//override dettagli 
			l.Importo__c = w.Importo__c;
			Decimal durataEffettiva = w.DurataTotale__c - w.DurataPreAmmortamento__c;
			l.Durata__c = durataEffettiva;
			l.FinalitaMutuo__c = w.Finalita__c;
			insert l;
			//nuova valorizzazione dei parametri
			List<CtrlWizardOpportunity.WoConfigurazioneParametro> parametri = CtrlWizardOpportunity.getParametriProdottiLinea(oid);
				for (CtrlWizardOpportunity.WoConfigurazioneParametro parametro : parametri){
					if (parametro.codice == '355'){
						PConfigurato__c def = new PConfigurato__c();
						def.linea__c = l.Id;
						def.Codice__c = parametro.codice;
						def.Default__c = parametro.defaultval;
						def.Tipo__c = parametro.tipo;
						def.Valore__c = parametro.defaultval;
						pconfs.add(def);
					} else if (parametro.codice == 'M2106_8501') {
						//spreadPositivo--default non presente, valori ammessi compresi tra 0% e 9%, estremi inclusi
						PConfigurato__c spos = new PConfigurato__c();
						spos.linea__c = l.Id;
						spos.Codice__c = parametro.codice;
						spos.Default__c = parametro.defaultval;
						spos.Tipo__c = parametro.tipo;
						spos.Valore__c = (w.SpreadPositivo__c != null) ? w.SpreadPositivo__c + '' : spos.Default__c;
						pconfs.add(spos);
						spreadPositivo = spos.Valore__c;
					} else if (parametro.codice == 'M2106_8503') {
						//spreadPositivo--default non presente, valori ammessi compresi tra 0% e 9%, estremi inclusi
						PConfigurato__c tr = new PConfigurato__c();
						tr.linea__c = l.Id;
						tr.Codice__c = parametro.codice;
						tr.Default__c = parametro.defaultval;
						tr.Tipo__c = parametro.tipo;
						tr.Valore__c = tr.Default__c;
						pconfs.add(tr);
					} else if (parametro.codice == 'M2106_8504') {
						//periodicità rate--default “Mensile”, non editabile
						PConfigurato__c pr = new PConfigurato__c();
						pr.linea__c = l.Id;
						pr.Codice__c = parametro.codice;
						pr.Default__c = parametro.defaultval;
						pr.Tipo__c = parametro.tipo;
						pr.Valore__c = pr.Default__c;
						pconfs.add(pr);
					} else if (parametro.codice == 'M2106_8505') {
						//importoRichiesto--editabile
						PConfigurato__c ir = new PConfigurato__c();
						ir.linea__c = l.Id;
						ir.Codice__c = parametro.codice;
						ir.Default__c = parametro.defaultval;
						ir.Tipo__c = parametro.tipo;
						ir.Valore__c = (w.Importo__c != null) ? w.Importo__c + '' : ir.Default__c;
						pconfs.add(ir);
					} else if (parametro.codice == 'M2106_8509') {
						//durataMesi--Durata ammortamento (mesi), impostare la valorizzazione automatica di questo campo per differenza tra la durata totale e la durata del pre-ammortamento
						PConfigurato__c dm = new PConfigurato__c();
						dm.linea__c = l.Id;
						dm.Codice__c = parametro.codice;
						dm.Default__c = parametro.defaultval;
						dm.Tipo__c = parametro.tipo;
						dm.Valore__c = (durataEffettiva != null) ? durataEffettiva + '' : dm.Default__c;
						pconfs.add(dm);
					} else if (parametro.codice == 'M2106_8511') {
						//speseIstruttoria--compilazione automatica sulla base dell’importo, non editabile
						PConfigurato__c si = new PConfigurato__c();
						si.linea__c = l.Id;
						si.Codice__c = parametro.codice;
						si.Default__c = parametro.defaultval;
						si.Tipo__c = parametro.tipo;
						si.Valore__c = (w.SpeseIstruttoria__c != null) ? w.SpeseIstruttoria__c + '' : si.Default__c;
						pconfs.add(si);
					} else if (parametro.codice == 'M2106_8513') {
						//speseIncassoRata--default “1,80€”, non editabile
						PConfigurato__c sir = new PConfigurato__c();
						sir.linea__c = l.Id;
						sir.Codice__c = parametro.codice;
						sir.Default__c = parametro.defaultval;
						sir.Tipo__c = parametro.tipo;
						sir.Valore__c = sir.Default__c;
						pconfs.add(sir);
					} else if (parametro.codice == 'M2106_8514') {
						//codice commissione--fisso a 003
						PConfigurato__c cc = new PConfigurato__c();
						cc.linea__c = l.Id;
						cc.Codice__c = parametro.codice;
						cc.Default__c = parametro.defaultval;
						cc.Tipo__c = parametro.tipo;
						cc.Valore__c = cc.Default__c;
						pconfs.add(cc);
					} else if (parametro.codice == 'M2106_8515') {
						//importo commissione--editabile
						PConfigurato__c ic = new PConfigurato__c();
						ic.linea__c = l.Id;
						ic.Codice__c = parametro.codice;
						ic.Default__c = parametro.defaultval;
						ic.Tipo__c = parametro.tipo;
						ic.Valore__c = (w.SpeseCommissione__c != null) ? w.SpeseCommissione__c + '' : ic.Default__c;
						pconfs.add(ic);
					} else if (parametro.codice == 'M2106_8535') {
						//tassoMinVariazTasso (floor)--replicare valore inserito nello Spread Positivo, non editabile
						PConfigurato__c tm = new PConfigurato__c();
						tm.linea__c = l.Id;
						tm.Codice__c = parametro.codice;
						tm.Default__c = parametro.defaultval;
						tm.Tipo__c = parametro.tipo;
						//non ha senso assegnare il valore qua poichè il valore di 'spreadPositivo' non è ancora stato assegnato
						//tm.Valore__c = spreadPositivo; //replica valore dello spread positivo
						pconfs.add(tm);
					}
				}
			}

		for (PConfigurato__c pconf : pconfs) {
			if (pconf.Codice__c == 'M2106_8535'){
				pconf.Valore__c = spreadPositivo; //replica valore dello spread positivo
			}
		}

		if (w.Tipologia_Mutuo__c == bifis_crm_c_CommonUtils.ASSICURATIVO
			|| w.Tipologia_Mutuo__c == bifis_crm_c_CommonUtils.MISTO) {
			Linea__c l = new Linea__c(
				Opportunity__c = oid, 
				Prodotto__c = prodMutuoSA.id, 
				RecordTypeId = rtMutuoMCNSA
			);
			//override dettagli 
			l.Importo__c = w.ImportoSA__c;
			Decimal durataEffettiva = w.DurataTotaleSA__c; //non c'e' pre-amm per assicurativo
			l.Durata__c = durataEffettiva;
			l.FinalitaMutuo__c = w.FinalitaSA__c;
			insert l;

			//nuova valorizzazione dei parametri
			List<CtrlWizardOpportunity.WoConfigurazioneParametro> parametri = CtrlWizardOpportunity.getParametriProdottiLinea(oid);
				for (CtrlWizardOpportunity.WoConfigurazioneParametro parametro : parametri){
					if (parametro.codice == '355'){
						PConfigurato__c def = new PConfigurato__c();
						def.linea__c = l.Id;
						def.Codice__c = parametro.codice;
						def.Default__c = parametro.defaultval;
						def.Tipo__c = parametro.tipo;
						def.Valore__c = parametro.defaultval;
						pconfs.add(def);
					} else if (parametro.codice == 'M2107_8501') {
						//spreadPositivo--default 0 (zero), non editabile
						PConfigurato__c spos = new PConfigurato__c();
						spos.linea__c = l.Id;
						spos.Codice__c = parametro.codice;
						spos.Default__c = parametro.defaultval;
						spos.Tipo__c = parametro.tipo;
						spos.Valore__c = spos.Default__c;
						pconfs.add(spos);
					} else if (parametro.codice == 'M2107_8503') {
						//tasso riferimento--default 0 (zero), non editabile
						PConfigurato__c tr = new PConfigurato__c();
						tr.linea__c = l.Id;
						tr.Codice__c = parametro.codice;
						tr.Default__c = parametro.defaultval;
						tr.Tipo__c = parametro.tipo;
						tr.Valore__c = tr.Default__c;
						pconfs.add(tr);
					} else if (parametro.codice == 'M2107_8504') {
						//periodicità rate--default “Mensile”, non editabile
						PConfigurato__c pr = new PConfigurato__c();
						pr.linea__c = l.Id;
						pr.Codice__c = parametro.codice;
						pr.Default__c = parametro.defaultval;
						pr.Tipo__c = parametro.tipo;
						pr.Valore__c = pr.Default__c;
						pconfs.add(pr);
					} else if (parametro.codice == 'M2107_8505') {
						//importoRichiesto--editabile
						PConfigurato__c ir = new PConfigurato__c();
						ir.linea__c = l.Id;
						ir.Codice__c = parametro.codice;
						ir.Default__c = parametro.defaultval;
						ir.Tipo__c = parametro.tipo;
						ir.Valore__c = (w.ImportoSA__c != null) ? w.ImportoSA__c + '' : ir.Default__c;
						pconfs.add(ir);
					} else if (parametro.codice == 'M2107_8509') {
						//durataMesi--Durata ammortamento (mesi), impostare la valorizzazione automatica di questo campo per differenza tra la durata totale e la durata del pre-ammortamento
						PConfigurato__c dm = new PConfigurato__c();
						dm.linea__c = l.Id;
						dm.Codice__c = parametro.codice;
						dm.Default__c = parametro.defaultval;
						dm.Tipo__c = parametro.tipo;
						dm.Valore__c = (durataEffettiva != null) ? durataEffettiva + '' : dm.Default__c;
						pconfs.add(dm);
					} else if (parametro.codice == 'M2107_8511') {
						//speseIstruttoria--default 0 (zero), non editabile
						PConfigurato__c si = new PConfigurato__c();
						si.linea__c = l.Id;
						si.Codice__c = parametro.codice;
						si.Default__c = parametro.defaultval;
						si.Tipo__c = parametro.tipo;
						si.Valore__c = si.Default__c;
						pconfs.add(si);
					}  else if (parametro.codice == 'M2107_8513') {
						//speseIncassoRata--default 0 (zero), non editabile
						PConfigurato__c sir = new PConfigurato__c();
						sir.linea__c = l.Id;
						sir.Codice__c = parametro.codice;
						sir.Default__c = parametro.defaultval;
						sir.Tipo__c = parametro.tipo;
						sir.Valore__c = sir.Default__c;
						pconfs.add(sir);
					}  else if (parametro.codice == 'M2107_8514') {
						//codice commissione-- fisso a 003
						PConfigurato__c cc = new PConfigurato__c();
						cc.linea__c = l.Id;
						cc.Codice__c = parametro.codice;
						cc.Default__c = parametro.defaultval;
						cc.Tipo__c = parametro.tipo;
						cc.Valore__c = cc.Default__c;
						pconfs.add(cc);
					}  else if (parametro.codice == 'M2107_8515') {
						//importo commissione--editabile
						PConfigurato__c ic = new PConfigurato__c();
						ic.linea__c = l.Id;
						ic.Codice__c = parametro.codice;
						ic.Default__c = parametro.defaultval;
						ic.Tipo__c = parametro.tipo;
						ic.Valore__c = (w.SpeseCommissioneSA__c != null) ? w.SpeseCommissioneSA__c + '' : ic.Default__c;
						pconfs.add(ic);
					}  else if (parametro.codice == 'M2107_8535') {
						//tassoMinVariazTasso (floor)--default 0 (zero), non editabile
						PConfigurato__c tm = new PConfigurato__c();
						tm.linea__c = l.Id;
						tm.Codice__c = parametro.codice;
						tm.Default__c = parametro.defaultval;
						tm.Tipo__c = parametro.tipo;
						tm.Valore__c = tm.Default__c;
						pconfs.add(tm);		
					}
				}
			}
					
		insert pconfs;
	}

	/**
	 * compila i valori privacy come da modulo caricato
	 */
	private Opportunity compilaPrivacy(Account acc, Contact con, Opportunity opp, WorkflowMutui__c w) {
		//privacy azienda
		if (acc != null) {
			a.ConsensoAllaProfilazione__c = w.Privacy_Azienda_1__c == 'OK' ? true : false;
			a.ConsensoAttivitaPromRicercheMercato__c = w.Privacy_Azienda_2__c == 'OK' ? true : false;
			a.ConsensoAttivitaPromozionaleTerzi__c = w.Privacy_Azienda_3__c == 'OK' ? true : false;
			a.ConsensoProdottiBancaRicercheMercato__c = w.Privacy_Azienda_4__c == 'OK' ? true : false;
			a.ConsensoProdottiSocietaTerze__c = w.Privacy_Azienda_5__c == 'OK' ? true : false;
			a.ConsensoSoloModalitaTradizionali__c = w.Privacy_Azienda_Tradizionali__c == 'SI' ? true : false;
			a.DataInserimentoConsensi__c = Datetime.now();
			a.PresaVisionePrivacy__c = true;
			//a.ConsensiPrivacyModificati__c = true; TODO: questo inibisce poi invio a FEU?

			update a;
			//opp.ConsensiPrivacyCompilatiAzienda__c = true; //adione-tmp-finchè non si riesce a censire full la PF
			opp.ConsensiPrivacyCompilatiAzienda__c = false; 
		}

		//privacy esecutore ADV
		if (con != null) {
			Contact c = [
				SELECT Id, 
				ConsensoAllaProfilazione__c,
				ConsensoAttivitaPromRicercheMercato__c,
				ConsensoAttivitaPromozionaleTerzi__c,
				ConsensoProdottiBancaRicercheMercato__c,
				ConsensoProdottiSocietaTerze__c,
				ConsensoSoloModalitaTradizionali__c,
				DataInserimentoConsensi__c,
				PresaVisionePrivacy__c,
				ConsensiPrivacyModificati__c
				FROM Contact
				WHERE id = :con.id
				LIMIT 1
			];
			c.ConsensoAllaProfilazione__c = w.Privacy_Esecutore_1__c == 'OK' ? true : false;
			c.ConsensoAttivitaPromRicercheMercato__c = w.Privacy_Esecutore_2__c == 'OK' ? true : false;
			c.ConsensoAttivitaPromozionaleTerzi__c = w.Privacy_Esecutore_3__c == 'OK' ? true : false;
			c.ConsensoProdottiBancaRicercheMercato__c = w.Privacy_Esecutore_4__c == 'OK' ? true : false;
			c.ConsensoProdottiSocietaTerze__c = w.Privacy_Esecutore_5__c == 'OK' ? true : false;
			c.ConsensoSoloModalitaTradizionali__c = w.Privacy_Esecutore_Tradizionali__c == 'SI' ? true : false;
			c.DataInserimentoConsensi__c = Datetime.now();
			c.PresaVisionePrivacy__c = true;
			//c.ConsensiPrivacyModificati__c = true;  TODO: questo inibisce poi invio a FEU?

			update c;
		  	//opp.ConsensiPrivacyCompilatiEsecutore__c = true; //adione-tmp-finchè non si riesce a censire full la PF
			opp.ConsensiPrivacyCompilatiEsecutore__c = false; 
		}

		return opp;
	}

	/**
	 * compila il QQ coi dati inseriti
 	 */
	private void compilaQQ(Account acc, Opportunity opp, WorkflowMutui__c w) {
		QuestionarioQualitativo__c qq = new QuestionarioQualitativo__c(Opportunita__c = opp.Id, Account__c = acc.Id);
		if (String.isBlank(w.TipologiaQuestionario__c)) {
			w.TipologiaQuestionario__c = CtrlCompilazioneQQ.getNomeModello(acc.Fatturato__c);
		}
		qq.NomeModello__c = w.TipologiaQuestionario__c;
		qq.Stato__c = 'Confermato';
		qq.Account__c = acc.Id;
		if (w.TipologiaQuestionario__c =='Small Business') {
			qq.Risposta1__c = w.QQSB1__c;
			qq.Risposta2__c = w.QQSB2__c;
			qq.Risposta3__c = w.QQSB3__c;
			qq.Risposta4__c = w.QQSB4__c;
			qq.Risposta5__c = w.QQSB5__c;
			qq.Risposta6__c = w.QQSB6__c;
			qq.Risposta7__c = w.QQSB7__c;
			qq.Risposta8__c = w.QQSB8__c;
			qq.Risposta9__c = w.QQSB9__c;
			qq.Risposta10__c = w.QQSB10__c;
			qq.Risposta11__c = w.QQSB11__c;
			qq.Risposta12__c = w.QQSB12__c;
			qq.Risposta13__c = w.QQSB13__c;
			qq.Risposta14__c = w.QQSB14__c;
			qq.Risposta15__c = w.QQSB15__c;
			qq.Risposta16__c = w.QQSB16__c;
			qq.Risposta17__c = w.QQSB17__c;
			qq.Risposta18__c = w.QQSB18__c;
		} else {
			qq.Risposta1__c = w.QQCO1__c;
			qq.Risposta2__c = w.QQCO2__c;
			qq.Risposta3__c = w.QQCO3__c;
			qq.Risposta4__c = w.QQCO4__c;
			qq.Risposta5__c = w.QQCO5__c;
			qq.Risposta6__c = w.QQCO6__c;
			qq.Risposta7__c = w.QQCO7__c;
			qq.Risposta8__c = w.QQCO8__c;
			qq.Risposta9__c = w.QQCO9__c;
			qq.Risposta10__c = w.QQCO10__c;
			qq.Risposta11__c = w.QQCO11__c;
			qq.Risposta12__c = w.QQCO12__c;
			qq.Risposta13__c = w.QQCO13__c;
			qq.Risposta14__c = w.QQCO14__c;
			qq.Risposta15__c = w.QQCO15__c;
			qq.Risposta16__c = w.QQCO16__c;
			qq.Risposta17__c = w.QQCO17__c;
			qq.Risposta18__c = w.QQCO18__c;
			qq.Risposta19__c = w.QQCO19__c;
			qq.Risposta20__c = w.QQCO20__c;
			qq.Risposta21__c = w.QQCO21__c;
		}

		// inizio recuperaQQ
	    Integer[] listaSezioni = CtrlCompilazioneQQ.getListaSezioni(w.TipologiaQuestionario__c);
		Domanda[] domande = 
			(Domanda[]) JSON.deserialize(bifis_crm_c_CommonUtils.getDomandeQQ(w.TipologiaQuestionario__c), Domanda[].class);
		//fine recuperaQQ

		domandeMap = new Map<Integer, Domanda[]>();
		for (Domanda d : domande) {
			List<Domanda> l = domandeMap.get(d.codiceModulo);
			if (l != null) {
				l.add(d);
			} else {
				List<Domanda> newL = new List<Domanda>();
				newL.add(d);
				domandeMap.put(d.codiceModulo, newL);
			}
		}
		//inizio salvaQQ		
		Account a = [SELECT Id, NDGGruppo__c, Fatturato__c FROM Account WHERE Id = :qq.Account__c];

		System.Savepoint sp = Database.setSavePoint();
		try {
		  QuestionarioQualitativo__c[] qqL = [SELECT
			Id,
			Account__c,
			Account__r.Fatturato__c,
			Account__r.NDGGruppo__c,
			NomeModello__c,
			Opportunita__c
			FROM QuestionarioQualitativo__c 
			WHERE Account__c = :qq.Account__c AND Stato__c = 'Bozza' LIMIT 1
		  ];

		  String tipoAttuale = w.TipologiaQuestionario__c;
		  if(!qqL.isEmpty() && qqL[0].NomeModello__c != tipoAttuale) {
			delete qqL;
		  }

		  if(qq.Stato__c == 'Confermato') {
			// instanzio una mappa di nome-stato in modo che faccia le varie operazioni sui qq nei servizi mule
			Map<String,String> nomistati = new Map<String,String>();

			List<QuestionarioQualitativo__c> daArchiviare = [
			  SELECT Id, Name, IdSiebel__c, Stato__c
			  FROM QuestionarioQualitativo__c
			  WHERE Account__c = :qq.Account__c
			  AND Stato__c IN ('Scaduto','Confermato')
			];

			for(QuestionarioQualitativo__c qda : daArchiviare) {
			  if(String.isNotBlank(qda.IdSiebel__c)) nomistati.put(qda.IdSiebel__c, 'archiviamigrato');
			  else nomistati.put(qda.Name, 'archivia');
			  qda.Stato__c = 'Archiviato';
			}

			// aggiorno quelli da archiviare
			update daArchiviare;

			// solo se il qq è in stato confermato metto la data di compilazione
			qq.DataCompilazione__c = Date.today();
		  }

		  Map<Integer, String> mappaDm = CtrlCompilazioneQQ.getMappaParametriDataModel(tipoAttuale);

		  for(Domanda[] lista : domandeMap.values()) {
			for(Domanda d : lista) {
			  qq.put(mappaDm.get(d.codiceDatoDomanda), d.value);
			}
		  }

		  Domanda[] payload = new List<Domanda>();
		  for(Domanda[] sez : domandeMap.values()) {
			payload.addAll(sez);
		  }
		  qq.Payload__c = JSON.serialize(payload);

		  upsert qq;

		} catch(DmlException err) {
		  Database.rollback(sp);
		  System.debug(err);
		  throw new Ex.WSException('Errore aggiornamento questionario qualitativo: ' + err.getDmlMessage(0), err);
		}
		//fine salvaQQ
	}

	/**
	 * compila MAV e MTC coi dati inseriti
	 */
	private void compilaADV(Account acc, List<Object> referenti, Opportunity opp, WorkflowMutui__c w) {
		//riusiamo il metodo già presente nel Wizard, si basa sul JSON inviato da FE-VUE
		CtrlWizardOpportunity.WoAdeguataVerifica av = new CtrlWizardOpportunity.WoAdeguataVerifica();
		av.opportunityId = opp.Id;
		av.referenti = new Id[]{};
		av.ruoloReferenti = new String[]{};
		av.tipologiaTitEffReferenti = new String[]{};
		av.advL = new List<CtrlWizardOpportunity.WoAv>(); //scelte dell'ADV
		av.indirizzo = new CtrlWizardOpportunity.WoIndirizzo(); //MTC
		av.account = acc;

		for(Object current : referenti) {	
			Map<String, Object> m = (Map<String, Object>) current;
			String valoreRuolo = (String) m.get('ruolo');
			String valoreTipo = (String) m.get('tipologiaTE');
			String valoreCF = (String) m.get('codiceFiscale');
			Contact c = bifis_crm_c_CommonUtils.searchByCodFisc(valoreCF);
			av.referenti.add(c.Id);
			av.ruoloReferenti.add(valoreRuolo);
			av.tipologiaTitEffReferenti.add(valoreTipo);
		}

		//WoAv
		CtrlWizardOpportunity.WoAv elem = new CtrlWizardOpportunity.WoAv();
		elem.categoria = 'FactDir';
		elem.naturaScopoContinuativo = w.MAV_Natura_Rapporto__c;
		elem.origineFondiObbligatoria = false; //??
		elem.origineFondiAltro = String.isNotBlank(w.MAV_Altro_Descrizione__c) ? w.MAV_Altro_Descrizione__c : null;
		elem.adv = new String[]{}; //SCOPO DEL RAPPORTO CONTINUATIVO  
		if (w.MAV_Tesorerie__c) elem.adv.add('11');
		if (w.MAV_Affidamenti__c) elem.adv.add('12');
		if (w.MAV_Investimento__c) elem.adv.add('13');
		if (w.MAV_Incassi_Pagamenti__c) elem.adv.add('14');
		if (w.MAV_Smobilizzo_Italia__c) elem.adv.add('15');
		if (w.MAV_Stipendi__c) elem.adv.add('16');
		if (w.MAV_Fornitori__c) elem.adv.add('17');
		if (w.MAV_Smobilizzo_Estero__c) elem.adv.add('18');
		if (w.MAV_Transazioni_Estero__c) elem.adv.add('19');
		elem.origineFondi = new String[]{}; //ADEGUATA VERIFICA: ORIGINE DEI FONDI
		if (w.MAV_Proventi__c) elem.origineFondi.add('1');
		if (w.MAV_Straordinari__c) elem.origineFondi.add('2');
		if (w.MAV_Cessione__c) elem.origineFondi.add('3');
		if (w.MAV_Altro__c) elem.origineFondi.add('4');
		av.advL.add(elem); //aggiunto WoAv

		/*adione--crm20  gestito diversamente tramite MTC
		av.indirizzo.tipo = w.MTC_Indirizzo__c;
		switch on w.MTC_Indirizzo__c {
			when 'billing' {
				acc.put('IndirizzoPerInvioCorrispondenza__c', 'Sede legale');
				av.indirizzo.streetType = w.TipoViaLegale__c;
				av.indirizzo.streetNumber = w.CivicoLegale__c;
				av.indirizzo.streetName = w.IndirizzoLegale__c;
				av.indirizzo.city = w.CittaLegale__c.toUpperCase();
				av.indirizzo.cap = w.CapLegale__c;
				av.indirizzo.state = w.ProvinciaLegale__c.toUpperCase();
				av.indirizzo.country = 'ITALIA'; //FIXME
				}
			when 'shipping' {
				acc.put('IndirizzoPerInvioCorrispondenza__c', 'Sede amministrativa');
				av.indirizzo.streetType = w.TipoViaSpedizione__c;
				av.indirizzo.streetNumber = w.CivicoSpedizione__c;
				av.indirizzo.streetName = w.IndirizzoSpedizione__c;
				av.indirizzo.city = w.CittaSpedizione__c.toUpperCase();
				av.indirizzo.cap = w.CapSpedizione__c;
				av.indirizzo.state = w.ProvinciaSpedizione__c.toUpperCase();
				av.indirizzo.country = 'ITALIA'; //FIXME
				}
			when 'other' {
				acc.put('IndirizzoPerInvioCorrispondenza__c', 'Altro');
				av.indirizzo.streetType = w.TipoViaAltro__c;
				av.indirizzo.streetNumber = w.CivicoAltro__c;
				av.indirizzo.streetName = w.IndirizzoAltro__c;
				av.indirizzo.city = w.CittaAltro__c.toUpperCase();
				av.indirizzo.cap = w.CapAltro__c;
				av.indirizzo.state = w.ProvinciaAltro__c.toUpperCase();
				av.indirizzo.country = 'ITALIA'; //FIXME
				}
			}
			*/

			advPayload = JSON.serialize(av);
			update acc; //salva flag per indirizzo MTC
	}

	/**
	 * Allega i documenti caricati nella pratica all'opportunità creata
	 */
	public static void allegaDocs(Opportunity o, WorkflowMutui__c w, List<String> docNames) {
		System.debug('opportunity: '+o);
		System.debug('workflowmutui: '+w);
		System.debug('docNames: '+docNames);
		Contact esecutore = null;
		if (docNames != null && !docNames.isEmpty()) {
			try {
				String docName = docNames.remove(0); //get next doc name to process
				String inizioVal = Date.today().format(); //inizio validità doc
				String fineVal = Date.today().addDays(30).format(); //scadenza doc
				String famiglia, tipoDoc;
				String cfEsecutore; 
				List<Object> referenti = bifis_crm_c_CommonUtils.parseReferentiJSON(w.REFERENTI_JSON__c);
				for(Object current : referenti) {	
					Map<String, Object> m = (Map<String, Object>) current;
					String valoreRuolo = (String) m.get('ruolo');
					if(valoreRuolo.containsIgnoreCase('Esecutore')) {
						cfEsecutore = (String) m.get('codiceFiscale');
						break;
					}
				}
				//arrivato qua il referente esecutore è già inserito in CRM
				esecutore = bifis_crm_c_CommonUtils.searchByCodFisc(cfEsecutore);	

				String jsonInput = (String) w.get(docName);
				List<Object> result;
				//RSF
				if (docName == 'DOCUMENTO_RSF_JSON__c') {
					result = bifis_crm_c_CommonUtils.parseDocumentJSON(jsonInput);
					if (result != null) {
						for (Object current : result) {
							   Map<String, Object> entry = (Map<String, Object>) current;
							   String fileid = (String) entry.get('id');
							   //bifis_crm_c_CommonUtils.pairFileToOpportunity(o.Id, fileid, 'Identificazione cliente', 'RSFFirm');
							   famiglia = 'Documenti finanziari'; //'EX0010028';
							   tipoDoc = 'NV0000002';
							   fineVal = Date.today().addMonths(3).format();
							   System.debug('---> upload su cedacri documento: '+docName);
							   String docToInsert = '{"dataProduzione":"'+inizioVal+'","famiglia":"'+famiglia+'","tipoDoc":"'+tipoDoc+'","docId":"'+fileid+'"}';
							   bifis_crm_c_CommonUtils.uploadDoc(o.AccountId, docToInsert, o.Id, docName);
						}
						o.RSFFirmata__c = true;
					}
				}

				//MAV
				if (docName == 'DOCUMENTO_MAV_JSON__c') {
					result = bifis_crm_c_CommonUtils.parseDocumentJSON(jsonInput);
					if (result != null) {
						for (Object current : result) {
							   Map<String, Object> entry = (Map<String, Object>) current;
							   String fileid = (String) entry.get('id');
							   //bifis_crm_c_CommonUtils.pairFileToOpportunity(o.Id, fileid, 'Identificazione cliente', 'MAVFirm');
							   famiglia = 'Identificazione clientela'; //'NV0000001';
							   tipoDoc = 'EX0000173';
							   fineVal = Date.today().addYears(1).format(); //scadenza 1 anno
							   System.debug('---> upload su cedacri documento: '+docName);
							   String docToInsert = '{"dataProduzione":"'+inizioVal+'","dataScadenza":"'+fineVal+'","famiglia":"'+famiglia+'","tipoDoc":"'+tipoDoc+'","docId":"'+fileid+'"}';
							   bifis_crm_c_CommonUtils.uploadDoc(o.AccountId, docToInsert, o.Id, docName);
						}
						o.MAVFirmato__c = true;	
					}
				}
		
				//MTC
				if (docName == 'DOCUMENTO_MTC_JSON__c') {
					result = bifis_crm_c_CommonUtils.parseDocumentJSON(jsonInput);
					if (result != null) {
						for (Object current : result) {
							   Map<String, Object> entry = (Map<String, Object>) current;
							   String fileid = (String) entry.get('id');
							   //bifis_crm_c_CommonUtils.pairFileToOpportunity(o.Id, fileid, 'Identificazione cliente', 'ModuloTecnicheDiComunicazioneFirm');
							   famiglia = 'Identificazione clientela'; //'NV0000001';
							   tipoDoc = 'EX0000179';
								fineVal = Date.today().addYears(10).format(); //scadenza 10 anni
							   System.debug('---> upload su cedacri documento: '+docName);
							   String docToInsert = '{"dataProduzione":"'+inizioVal+'","dataScadenza":"'+fineVal+'","famiglia":"'+famiglia+'","tipoDoc":"'+tipoDoc+'","docId":"'+fileid+'"}';
							   bifis_crm_c_CommonUtils.uploadDoc(o.AccountId, docToInsert, o.Id, docName);
						}
						o.TDCFirmato__c = true;	
					}
				}
		
				//privacy azienda
				if (docName == 'DOCUMENTO_MPA_JSON__c') {
					result = bifis_crm_c_CommonUtils.parseDocumentJSON(jsonInput);
					if (result != null) {
						for (Object current : result) {
							   Map<String, Object> entry = (Map<String, Object>) current;
							   String fileid = (String) entry.get('id');
							   //bifis_crm_c_CommonUtils.pairFileToOpportunity(o.Id, fileid, 'Documenti identità', 'PrivacyFirm');
							   famiglia = 'Identificazione clientela'; //'NV0000001';
							   tipoDoc = 'EX0000200';
							   fineVal = Date.today().addYears(10).format(); //scadenza 10 anni
							   System.debug('---> upload su cedacri documento: '+docName);
							   String docToInsert = '{"dataProduzione":"'+inizioVal+'","dataScadenza":"'+fineVal+'","famiglia":"'+famiglia+'","tipoDoc":"'+tipoDoc+'","docId":"'+fileid+'"}';
							   bifis_crm_c_CommonUtils.uploadDoc(o.AccountId, docToInsert, o.Id, docName);
						}
						o.PrivacyFirmato__c = true;	
					}
				}
		
				//privacy esecutore
				if (docName == 'DOCUMENTO_MPE_JSON__c') {
					result = bifis_crm_c_CommonUtils.parseDocumentJSON(jsonInput);
					if (result != null) {
						for (Object current : result) {
							   Map<String, Object> entry = (Map<String, Object>) current;
							   String fileid = (String) entry.get('id');
							   //bifis_crm_c_CommonUtils.pairFileToOpportunity(o.Id, fileid, 'Documenti identità', 'PrivacyPfFirm');
							   famiglia = 'Documenti persona fisica'; //'SY0000064';
							   tipoDoc = 'SY0000074';
							   fineVal = Date.today().addYears(10).format(); //scadenza 10 anni
							   System.debug('---> upload su cedacri documento: '+docName);
							   String docToInsert = '{"dataProduzione":"'+inizioVal+'","famiglia":"'+famiglia+'","tipoDoc":"'+tipoDoc+'","docId":"'+fileid+'"}';
							   bifis_crm_c_CommonUtils.uploadDoc(esecutore.Id, docToInsert, o.Id, docName);
						}
					}
				}
				/* ALTRI DOC NON OBBLIGATORI PER CONVALIDA MA NECESSARI ALLA PRATICA */
				//Allegato 4
				if (docName == 'DOCUMENTO_A4_JSON__c') {
					result = bifis_crm_c_CommonUtils.parseDocumentJSON(jsonInput);
					if (result != null) {
						for (Object current : result) {
							   Map<String, Object> entry = (Map<String, Object>) current;
							   String fileid = (String) entry.get('id');
							   //bifis_crm_c_CommonUtils.pairFileToOpportunity(o.Id, fileid, 'Garanzie', 'altro9');
							   famiglia = 'Mutui'; //'EX0000193';
							   tipoDoc = 'EX0000195';
							   fineVal = Date.today().addMonths(3).format(); //scadenza 3 mesi
							   System.debug('---> upload su cedacri documento: '+docName);
							   String docToInsert = '{"dataProduzione":"'+inizioVal+'","famiglia":"'+famiglia+'","tipoDoc":"'+tipoDoc+'","docId":"'+fileid+'"}';
							   bifis_crm_c_CommonUtils.uploadDoc(o.AccountId, docToInsert, o.Id, docName);
						}
					}
				}

				//Bilancio d’esercizio degli ultimi 3 anni
				if (docName == 'DOCUMENTO_BE3_JSON__c') {
					result = bifis_crm_c_CommonUtils.parseDocumentJSON(jsonInput);
					if (result != null) {
						for (Object current : result) {
							   Map<String, Object> entry = (Map<String, Object>) current;
							   String fileid = (String) entry.get('id');
							   //bifis_crm_c_CommonUtils.pairFileToOpportunity(o.Id, fileid, 'Bilanci', 'Civilistico');
							   famiglia = 'Bilanci'; //'SY0000067';
							   tipoDoc = 'EX0000111';
							   fineVal = Date.today().addMonths(18).format();
							   System.debug('---> upload su cedacri documento: '+docName);
							   String docToInsert = '{"dataProduzione":"'+inizioVal+'","famiglia":"'+famiglia+'","tipoDoc":"'+tipoDoc+'","docId":"'+fileid+'"}';
							   bifis_crm_c_CommonUtils.uploadDoc(o.AccountId, docToInsert, o.Id, docName);
						}
					}
				}

				//Bilancio d'esericizio dell'ultimo anno delle società controllate e controllanti
				if (docName == 'DOCUMENTO_BESC_JSON__c') {
					result = bifis_crm_c_CommonUtils.parseDocumentJSON(jsonInput);
					if (result != null) {
						for (Object current : result) {
							   Map<String, Object> entry = (Map<String, Object>) current;
							   String fileid = (String) entry.get('id');
							   //bifis_crm_c_CommonUtils.pairFileToOpportunity(o.Id, fileid, 'Bilanci', 'Consolidato');
							   famiglia = 'Bilanci'; //'SY0000067';
							   tipoDoc = 'SY0000040';
							   fineVal = Date.today().addMonths(18).format();
							   System.debug('---> upload su cedacri documento: '+docName);
							   String docToInsert = '{"dataProduzione":"'+inizioVal+'","famiglia":"'+famiglia+'","tipoDoc":"'+tipoDoc+'","docId":"'+fileid+'"}';
							   bifis_crm_c_CommonUtils.uploadDoc(o.AccountId, docToInsert, o.Id, docName);
						}
					}
				}

				//Bilancio di verifica o dettaglio Debiti e Crediti
				if (docName == 'DOCUMENTO_BVA_JSON__c') {
					result = bifis_crm_c_CommonUtils.parseDocumentJSON(jsonInput);
					if (result != null) {
						for (Object current : result) {
							   Map<String, Object> entry = (Map<String, Object>) current;
							   String fileid = (String) entry.get('id');
							   //bifis_crm_c_CommonUtils.pairFileToOpportunity(o.Id, fileid, 'Bilanci', 'Consolidato');
							   famiglia = 'Bilanci'; //'SY0000067';
							   tipoDoc = 'SY0000042';
							   fineVal = Date.today().addMonths(12).format();
							   System.debug('---> upload su cedacri documento: '+docName);
							   String docToInsert = '{"dataProduzione":"'+inizioVal+'","famiglia":"'+famiglia+'","tipoDoc":"'+tipoDoc+'","docId":"'+fileid+'"}';
							   bifis_crm_c_CommonUtils.uploadDoc(o.AccountId, docToInsert, o.Id, docName);
						}
					}
				}

				//Bilancio provvisorio 
				if (docName == 'DOCUMENTO_BPR_JSON__c') {
					result = bifis_crm_c_CommonUtils.parseDocumentJSON(jsonInput);
					if (result != null) {
						for (Object current : result) {
							   Map<String, Object> entry = (Map<String, Object>) current;
							   String fileid = (String) entry.get('id');
							   //bifis_crm_c_CommonUtils.pairFileToOpportunity(o.Id, fileid, 'Bilanci', 'Consolidato');
							   famiglia = 'Bilanci'; //'SY0000067';
							   tipoDoc = 'SY0000039';
							   fineVal = Date.today().addMonths(6).format();
							   System.debug('---> upload su cedacri documento: '+docName);
							   String docToInsert = '{"dataProduzione":"'+inizioVal+'","famiglia":"'+famiglia+'","tipoDoc":"'+tipoDoc+'","docId":"'+fileid+'"}';
							   bifis_crm_c_CommonUtils.uploadDoc(o.AccountId, docToInsert, o.Id, docName);
						}
					}
				}

				//Copia del documento d'identità del legale rappresentante sottoscrittore dell'Allegato 4 
				if (docName == 'DOCUMENTO_DIA4_JSON__c') {
					result = bifis_crm_c_CommonUtils.parseDocumentJSON(jsonInput);
					if (result != null) {
						for (Object current : result) {
							   Map<String, Object> entry = (Map<String, Object>) current;
							   String fileid = (String) entry.get('id');
							   //bifis_crm_c_CommonUtils.pairFileToOpportunity(o.Id, fileid, 'Documenti identità', 'CartaIdentita');
							   famiglia = 'Documenti persona fisica'; //'SY0000064';
							   tipoDoc = 'SY0000002';
							   fineVal = Date.today().addYears(10).format();
							   System.debug('---> upload su cedacri documento: '+docName);
							   String docToInsert = '{"dataProduzione":"'+inizioVal+'","famiglia":"'+famiglia+'","tipoDoc":"'+tipoDoc+'","docId":"'+fileid+'"}';
							   bifis_crm_c_CommonUtils.uploadDoc(esecutore.Id, docToInsert, o.Id, docName);
						}
					}
				}

				//Copia del documento d'identità dell'esecutore
				if (docName == 'DOCUMENTO_DIE_JSON__c') {
					result = bifis_crm_c_CommonUtils.parseDocumentJSON(jsonInput);
					if (result != null) {
						for (Object current : result) {
							   Map<String, Object> entry = (Map<String, Object>) current;
							   String fileid = (String) entry.get('id');
							   //bifis_crm_c_CommonUtils.pairFileToOpportunity(o.Id, fileid, 'Documenti identità', 'CartaIdentita');
							   famiglia = 'Documenti persona fisica'; //'SY0000064';
							   tipoDoc = 'SY0000002';
							   fineVal = Date.today().addYears(10).format();
							   String docToInsert = '{"dataProduzione":"'+inizioVal+'","famiglia":"'+famiglia+'","tipoDoc":"'+tipoDoc+'","docId":"'+fileid+'"}';
							   bifis_crm_c_CommonUtils.uploadDoc(esecutore.Id, docToInsert, o.Id, docName);
						}
					}
				}	

				//Copia del/i documento/i d'identità del/i soci
				if (docName == 'DOCUMENTO_DITS_JSON__c') {
					result = bifis_crm_c_CommonUtils.parseDocumentJSON(jsonInput);
					if (result != null) {
						for (Object current : result) {
								Map<String, Object> entry = (Map<String, Object>) current;
								String fileid = (String) entry.get('id');
								//bifis_crm_c_CommonUtils.pairFileToOpportunity(o.Id, fileid, 'Documenti identità', 'CartaIdentita');
							   famiglia = 'Documenti persona fisica'; //'SY0000064';
							   tipoDoc = 'SY0000002';
							   fineVal = Date.today().addYears(10).format();
							   System.debug('---> upload su cedacri documento: '+docName);
							   String docToInsert = '{"dataProduzione":"'+inizioVal+'","famiglia":"'+famiglia+'","tipoDoc":"'+tipoDoc+'","docId":"'+fileid+'"}';
							   bifis_crm_c_CommonUtils.uploadDoc(esecutore.Id, docToInsert, o.Id, docName);
							   //FIXME va usato contact id dei vari soci, non legato tutto all'esecutore
						}
					}
				}

				//Copia del/i documento/i d'identità del/i titolare/i effettivo/i
				if (docName == 'DOCUMENTO_DIT_JSON__c') {
					result = bifis_crm_c_CommonUtils.parseDocumentJSON(jsonInput);
					if (result != null) {
						for (Object current : result) {
							   Map<String, Object> entry = (Map<String, Object>) current;
							   String fileid = (String) entry.get('id');
							   //bifis_crm_c_CommonUtils.pairFileToOpportunity(o.Id, fileid, 'Documenti identità', 'CartaIdentita');
							   famiglia = 'Documenti persona fisica'; //'SY0000064';
							   tipoDoc = 'SY0000002';
							   fineVal = Date.today().addYears(10).format();
							   System.debug('---> upload su cedacri documento: '+docName);
							   String docToInsert = '{"dataProduzione":"'+inizioVal+'","famiglia":"'+famiglia+'","tipoDoc":"'+tipoDoc+'","docId":"'+fileid+'"}';
							   bifis_crm_c_CommonUtils.uploadDoc(esecutore.Id, docToInsert, o.Id, docName);
							   //FIXME va usato contact id dei vari TITEF, non legato tutto all'esecutore
						}
					}
				}

				//Copia ufficiale di Atto Costitutivo, Statuto, relativo ultimo aggiornamento e verbale/i comprovante/i i poteri di firma del soggetto sottoscrittore
				if (docName == 'DOCUMENTO_UAC_JSON__c') {
					result = bifis_crm_c_CommonUtils.parseDocumentJSON(jsonInput);
					if (result != null) {
						for (Object current : result) {
							   Map<String, Object> entry = (Map<String, Object>) current;
							   String fileid = (String) entry.get('id');
							   //bifis_crm_c_CommonUtils.pairFileToOpportunity(o.Id, fileid, 'Documentazione societaria', 'AttoCostitutivo');
							   famiglia = 'Documentazione societaria'; //'EX0010023';
							   tipoDoc = 'EX0000185';
							   fineVal = Date.today().addYears(10).format();
							   System.debug('---> upload su cedacri documento: '+docName);
							   String docToInsert = '{"dataProduzione":"'+inizioVal+'","famiglia":"'+famiglia+'","tipoDoc":"'+tipoDoc+'","docId":"'+fileid+'"}';
							   bifis_crm_c_CommonUtils.uploadDoc(o.AccountId, docToInsert, o.Id, docName);
						}
					}
				}

				//Dichiarazione costi di mediazione
				if (docName == 'DOCUMENTO_DIC_JSON__c') {
					result = bifis_crm_c_CommonUtils.parseDocumentJSON(jsonInput);
					if (result != null) {
						for (Object current : result) {
							   Map<String, Object> entry = (Map<String, Object>) current;
							   String fileid = (String) entry.get('id');
							   //bifis_crm_c_CommonUtils.pairFileToOpportunity(o.Id, fileid, 'Documentazione cliente', 'Altro');
							   famiglia = 'Documentazione cliente'; //'EX0010030';
							   tipoDoc = 'EX0000168';
							   fineVal = Date.today().addYears(10).format();
							   System.debug('---> upload su cedacri documento: '+docName);
							   String docToInsert = '{"dataProduzione":"'+inizioVal+'","famiglia":"'+famiglia+'","tipoDoc":"'+tipoDoc+'","docId":"'+fileid+'"}';
							   bifis_crm_c_CommonUtils.uploadDoc(o.AccountId, docToInsert, o.Id, docName);
						}
					}
				}

				//DM10
				if (docName == 'DOCUMENTO_DM10_JSON__c') {
					result = bifis_crm_c_CommonUtils.parseDocumentJSON(jsonInput);
					if (result != null) {
						for (Object current : result) {
							Map<String, Object> entry = (Map<String, Object>) current;
							String fileid = (String) entry.get('id');
							//bifis_crm_c_CommonUtils.pairFileToOpportunity(o.Id, fileid, 'Regolarità contributiva', 'DM10');
							famiglia = 'Regolarità contributiva'; //'EX0010026';
							tipoDoc = 'EX0000144';
							fineVal = Date.today().addMonths(3).format();
							System.debug('---> upload su cedacri documento: '+docName);
							String docToInsert = '{"dataProduzione":"'+inizioVal+'","famiglia":"'+famiglia+'","tipoDoc":"'+tipoDoc+'","docId":"'+fileid+'"}';
							bifis_crm_c_CommonUtils.uploadDoc(o.AccountId, docToInsert, o.Id, docName);
						}
					}
				}

				//DM10 imprese associate/collegate
				if (docName == 'DOCUMENTO_DM10I_JSON__c') {
					result = bifis_crm_c_CommonUtils.parseDocumentJSON(jsonInput);
					if (result != null) {
						for (Object current : result) {
								Map<String, Object> entry = (Map<String, Object>) current;
								String fileid = (String) entry.get('id');
								//bifis_crm_c_CommonUtils.pairFileToOpportunity(o.Id, fileid, 'Regolarità contributiva', 'DM10');
								famiglia = 'Regolarità contributiva'; //'EX0010026';
								tipoDoc = 'EX0000144';
								fineVal = Date.today().addMonths(3).format();
								System.debug('---> upload su cedacri documento: '+docName);
								String docToInsert = '{"dataProduzione":"'+inizioVal+'","famiglia":"'+famiglia+'","tipoDoc":"'+tipoDoc+'","docId":"'+fileid+'"}';
								bifis_crm_c_CommonUtils.uploadDoc(o.AccountId, docToInsert, o.Id, docName);
						}
					}
				}

				//ELENCO affidamenti bancari
				if (docName == 'DOCUMENTO_DAB_JSON__c') {
					result = bifis_crm_c_CommonUtils.parseDocumentJSON(jsonInput);
					if (result != null) {
						for (Object current : result) {
								Map<String, Object> entry = (Map<String, Object>) current;
								String fileid = (String) entry.get('id');
								//bifis_crm_c_CommonUtils.pairFileToOpportunity(o.Id, fileid, 'Documenti finanziari', 'AffidamentiBancari');
								famiglia = 'Documenti finanziari'; //'EX0010028';
								tipoDoc = 'EX0000155';
								fineVal = Date.today().addMonths(12).format();
								System.debug('---> upload su cedacri documento: '+docName);
								String docToInsert = '{"dataProduzione":"'+inizioVal+'","famiglia":"'+famiglia+'","tipoDoc":"'+tipoDoc+'","docId":"'+fileid+'"}';
								bifis_crm_c_CommonUtils.uploadDoc(o.AccountId, docToInsert, o.Id, docName);
						}
					}
				}

				//Elenco dei principali clienti e fornitori
				if (docName == 'DOCUMENTO_ECF_JSON__c') {
					result = bifis_crm_c_CommonUtils.parseDocumentJSON(jsonInput);
					if (result != null) {
						for (Object current : result) {
							   Map<String, Object> entry = (Map<String, Object>) current;
							   String fileid = (String) entry.get('id');
							   //bifis_crm_c_CommonUtils.pairFileToOpportunity(o.Id, fileid, 'Documenti finanziari', 'Altro7');
								famiglia = 'Bilanci'; //'SY0000067';
								tipoDoc = 'SY0000043';
								fineVal = Date.today().addMonths(12).format();
								System.debug('---> upload su cedacri documento: '+docName);
								String docToInsert = '{"dataProduzione":"'+inizioVal+'","famiglia":"'+famiglia+'","tipoDoc":"'+tipoDoc+'","docId":"'+fileid+'"}';
								bifis_crm_c_CommonUtils.uploadDoc(o.AccountId, docToInsert, o.Id, docName);
						}
					}
				}

				//Giusitificativi Cerved e/o Centrale Rischi
				if (docName == 'DOCUMENTO_GCE_JSON__c') {
					result = bifis_crm_c_CommonUtils.parseDocumentJSON(jsonInput);
					if (result != null) {
						for (Object current : result) {
							   Map<String, Object> entry = (Map<String, Object>) current;
							   String fileid = (String) entry.get('id');
							   //bifis_crm_c_CommonUtils.pairFileToOpportunity(o.Id, fileid, 'Documenti finanziari', 'DocumentazioneCR');
								famiglia = 'Documenti finanziari'; //'EX0010028';
								tipoDoc = 'EX0000157';
								fineVal = Date.today().addMonths(3).format();
								System.debug('---> upload su cedacri documento: '+docName);
								String docToInsert = '{"dataProduzione":"'+inizioVal+'","famiglia":"'+famiglia+'","tipoDoc":"'+tipoDoc+'","docId":"'+fileid+'"}';
								bifis_crm_c_CommonUtils.uploadDoc(o.AccountId, docToInsert, o.Id, docName);
						}
					}
				}

				//Modello Unico degli ultimi 2 anni della società
				if (docName == 'DOCUMENTO_MU2_JSON__c') {
					result = bifis_crm_c_CommonUtils.parseDocumentJSON(jsonInput);
					if (result != null) {
						for (Object current : result) {
							   Map<String, Object> entry = (Map<String, Object>) current;
							   String fileid = (String) entry.get('id');
							   //bifis_crm_c_CommonUtils.pairFileToOpportunity(o.Id, fileid, 'Regolarità contributiva', 'ModelloUnico');
								famiglia = 'Regolarità contributiva'; //'EX0010026';
								tipoDoc = 'EX0000147';
								fineVal = Date.today().addMonths(18).format();
								System.debug('---> upload su cedacri documento: '+docName);
								String docToInsert = '{"dataProduzione":"'+inizioVal+'","famiglia":"'+famiglia+'","tipoDoc":"'+tipoDoc+'","docId":"'+fileid+'"}';
								bifis_crm_c_CommonUtils.uploadDoc(o.AccountId, docToInsert, o.Id, docName);
						}
					}
				}

				//Modello Unico dell'ultimo del/i socio/i
				if (docName == 'DOCUMENTO_MUS_JSON__c') {
					result = bifis_crm_c_CommonUtils.parseDocumentJSON(jsonInput);
					if (result != null) {
						for (Object current : result) {
							   Map<String, Object> entry = (Map<String, Object>) current;
							   String fileid = (String) entry.get('id');
							   //bifis_crm_c_CommonUtils.pairFileToOpportunity(o.Id, fileid, 'Documenti persona fisica', 'ModelloUnico2');
								famiglia = 'Documenti persona fisica'; //'SY0000064';
								tipoDoc = 'EX0000004';
								fineVal = Date.today().addMonths(18).format();
								System.debug('---> upload su cedacri documento: '+docName);
								String docToInsert = '{"dataProduzione":"'+inizioVal+'","famiglia":"'+famiglia+'","tipoDoc":"'+tipoDoc+'","docId":"'+fileid+'"}';
								bifis_crm_c_CommonUtils.uploadDoc(esecutore.Id, docToInsert, o.Id, docName);
								//FIXME va usato contact id dei vari soci, non legato tutto all'esecutore
						}
					}
				}

				//Prospetto di calcolo dimensionale
				if (docName == 'DOCUMENTO_PCD_JSON__c') {
					result = bifis_crm_c_CommonUtils.parseDocumentJSON(jsonInput);
					if (result != null) {
						for (Object current : result) {
							   Map<String, Object> entry = (Map<String, Object>) current;
							   String fileid = (String) entry.get('id');
							   //bifis_crm_c_CommonUtils.pairFileToOpportunity(o.Id, fileid, 'Garanzie', 'Altro9');
								famiglia = 'Mutui'; //'EX0000193';
								tipoDoc = 'EX0000198';
								fineVal = Date.today().addMonths(3).format();
								System.debug('---> upload su cedacri documento: '+docName);
								String docToInsert = '{"dataProduzione":"'+inizioVal+'","famiglia":"'+famiglia+'","tipoDoc":"'+tipoDoc+'","docId":"'+fileid+'"}';
								bifis_crm_c_CommonUtils.uploadDoc(o.AccountId, docToInsert, o.Id, docName);
						}
					}
				}

				//Provvedimenti di concessione delle eventuali agevolazioni in regime di de minimis
				if (docName == 'DOCUMENTO_PRO_JSON__c') {
					result = bifis_crm_c_CommonUtils.parseDocumentJSON(jsonInput);
					if (result != null) {
						for (Object current : result) {
							   Map<String, Object> entry = (Map<String, Object>) current;
							   String fileid = (String) entry.get('id');
							   //bifis_crm_c_CommonUtils.pairFileToOpportunity(o.Id, fileid, 'Documentazione societaria', 'Altro2');
								famiglia = 'Mutui'; //'EX0000193';
								tipoDoc = 'EX0000199';
								fineVal = Date.today().addMonths(3).format();
								System.debug('---> upload su cedacri documento: '+docName);
								String docToInsert = '{"dataProduzione":"'+inizioVal+'","famiglia":"'+famiglia+'","tipoDoc":"'+tipoDoc+'","docId":"'+fileid+'"}';
								bifis_crm_c_CommonUtils.uploadDoc(o.AccountId, docToInsert, o.Id, docName);
						}
					}
				}

				//Report Impresa
				if (docName == 'DOCUMENTO_RI_JSON__c') {
					result = bifis_crm_c_CommonUtils.parseDocumentJSON(jsonInput);
					if (result != null) {
						for (Object current : result) {
							   Map<String, Object> entry = (Map<String, Object>) current;
							   String fileid = (String) entry.get('id');
							   //bifis_crm_c_CommonUtils.pairFileToOpportunity(o.Id, fileid, 'Documentazione cliente', 'ProfiloAziendale');
								famiglia = 'Documentazione societaria'; //'EX0010023';
								tipoDoc = 'EX0000120';
								fineVal = Date.today().addMonths(3).format();
								System.debug('---> upload su cedacri documento: '+docName);
								String docToInsert = '{"dataProduzione":"'+inizioVal+'","famiglia":"'+famiglia+'","tipoDoc":"'+tipoDoc+'","docId":"'+fileid+'"}';
								bifis_crm_c_CommonUtils.uploadDoc(o.AccountId, docToInsert, o.Id, docName);
						}
					}
				}

				//Scheda valutazione del rischio
				if (docName == 'DOCUMENTO_SVR_JSON__c') {
					result = bifis_crm_c_CommonUtils.parseDocumentJSON(jsonInput);
					if (result != null) {
						for (Object current : result) {
							   Map<String, Object> entry = (Map<String, Object>) current;
							   String fileid = (String) entry.get('id');
							   //bifis_crm_c_CommonUtils.pairFileToOpportunity(o.Id, fileid, 'Documentazione cliente', 'Altro');
								famiglia = 'Mutui'; //'EX0000193';
								tipoDoc = 'EX0000196';
								fineVal = Date.today().addMonths(3).format();
								System.debug('---> upload su cedacri documento: '+docName);
								String docToInsert = '{"dataProduzione":"'+inizioVal+'","famiglia":"'+famiglia+'","tipoDoc":"'+tipoDoc+'","docId":"'+fileid+'"}';
								bifis_crm_c_CommonUtils.uploadDoc(o.AccountId, docToInsert, o.Id, docName);
						}
					}
				}

				//Schema Gruppo
				if (docName == 'DOCUMENTO_SDG_JSON__c') {
					result = bifis_crm_c_CommonUtils.parseDocumentJSON(jsonInput);
					if (result != null) {
						for (Object current : result) {
							   Map<String, Object> entry = (Map<String, Object>) current;
							   String fileid = (String) entry.get('id');
							   //bifis_crm_c_CommonUtils.pairFileToOpportunity(o.Id, fileid, 'Documentazione societaria', 'VisuraCamerale');
								famiglia = 'Documentazione cliente'; //'EX0010030';
								tipoDoc = 'EX0000167';
								fineVal = Date.today().addMonths(3).format();
								System.debug('---> upload su cedacri documento: '+docName);
								String docToInsert = '{"dataProduzione":"'+inizioVal+'","famiglia":"'+famiglia+'","tipoDoc":"'+tipoDoc+'","docId":"'+fileid+'"}';
								bifis_crm_c_CommonUtils.uploadDoc(o.AccountId, docToInsert, o.Id, docName);
						}
					}
				}

				//Visura camerale o Libro soci
				if (docName == 'DOCUMENTO_DCVC_JSON__c') {
					result = bifis_crm_c_CommonUtils.parseDocumentJSON(jsonInput);
					if (result != null) {
						for (Object current : result) {
							   Map<String, Object> entry = (Map<String, Object>) current;
							   String fileid = (String) entry.get('id');
							   //bifis_crm_c_CommonUtils.pairFileToOpportunity(o.Id, fileid, 'Documentazione societaria', 'VisuraCamerale');
								famiglia = 'Documentazione societaria'; //'EX0010023';
								tipoDoc = 'EX0000186';
								fineVal = Date.today().addMonths(3).format();
								System.debug('---> upload su cedacri documento: '+docName);
								String docToInsert = '{"dataProduzione":"'+inizioVal+'","famiglia":"'+famiglia+'","tipoDoc":"'+tipoDoc+'","docId":"'+fileid+'"}';
								bifis_crm_c_CommonUtils.uploadDoc(o.AccountId, docToInsert, o.Id, docName);
						}
					}
				}

				//Visura camerale o Libro soci -- clienti/debitori
				if (docName == 'DOCUMENTO_VCL_JSON__c') {
					result = bifis_crm_c_CommonUtils.parseDocumentJSON(jsonInput);
					if (result != null) {
						for (Object current : result) {
							   Map<String, Object> entry = (Map<String, Object>) current;
							   String fileid = (String) entry.get('id');
							   //bifis_crm_c_CommonUtils.pairFileToOpportunity(o.Id, fileid, 'Documentazione societaria', 'VisuraCamerale');
								famiglia = 'Documentazione societaria'; //'EX0010023';
								tipoDoc = 'EX0000186';
								fineVal = Date.today().addMonths(3).format();
								System.debug('---> upload su cedacri documento: '+docName);
								String docToInsert = '{"dataProduzione":"'+inizioVal+'","famiglia":"'+famiglia+'","tipoDoc":"'+tipoDoc+'","docId":"'+fileid+'"}';
								bifis_crm_c_CommonUtils.uploadDoc(o.AccountId, docToInsert, o.Id, docName);
						}
					}
				}

				//processa il prossimo documento della lista
				bifis_crm_b_MccNsaGenerateOpportunity.allegaDocs(o, w, docNames);

			} catch(Exception e) {
				//log error
				bifis_crm_c_CommonUtils.logError(null, esecutore, w, e);

				//update w status
				w.StatoElaborazione__c = 'PARZIALE';
				w.ErrorMessage__c = (e.getMessage() + '\n\n' + e.getStackTraceString()).abbreviate(131072);
				update w;
			}
		} //END-IF
	}

	@TestVisible
	private void sendErrorMail(WorkflowMutui__c w, Exception e) {
		Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
		mail.setOrgWideEmailAddressId(owa.id);
		mail.setToAddresses(new String[] {mccNsaParameters.Mail_Segnalazione_Errori__c});
		mail.setReplyTo('noreply@bancaifis.it');
		//mail.setSenderDisplayName('Batch Processing NSA');
		mail.setSubject('Batch Process NSA Error');
		String body = 'An NSA batch process failed! \n';
		body += 'SFDC Instance: ' + System.URL.getSalesforceBaseUrl().toExternalForm() + '\n'; 
		body = body + '------------------------------------------------------------------------------------------------\n\n';
		body = body + w;
		body = body + '------------------------------------------------------------------------------------------------\n\n';
		body = body + e.getMessage();
		body = body + '------------------------------------------------------------------------------------------------\n\n';
		body = body + e.getStackTraceString();
		body = body + '------------------------------------------------------------------------------------------------\n\n';
		mail.setPlainTextBody(body);

		Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
	}

	/********************************************************************************************
	 * classi locali 
	 *******************************************************************************************/
	//Questionario Qualitativo
	@TestVisible
	public Class Domanda {
		public Integer codiceDatoDomanda;
		public String value;
		public String domanda;
		public Integer codiceModulo;
		public DominioRisposta[] dominio;
	}

	//Questionario Qualitativo
	@TestVisible
	public Class DominioRisposta {
		public String value;
		public String label;
	}

	@TestVisible
	public class AsyncJobsNSA_Q implements Queueable, Database.AllowsCallouts {

		Account a;
		List<Object> referenti;
		String tipoModulo;
		Map<Integer, Domanda[]> mappaCodiciValori;
		String advPayload;
		WorkflowMutui__c w;
        Opportunity o;
		String mode;

		public AsyncJobsNSA_Q(Account a, List<Object> referenti, Opportunity o, WorkflowMutui__c w, Map<Integer, Domanda[]> mappaCodiciValori, String advPayload, String mode) {
			this.a=a;
			this.referenti=referenti;
			this.tipoModulo=w.TipologiaQuestionario__c;
			this.mappaCodiciValori=mappaCodiciValori;
			this.advPayload = advPayload;
			this.w = w;
            this.o = o;
			this.mode = mode;
		}

		public void execute(QueueableContext context) {
			Boolean ndgOttenuto = true;
			try {
				//CENSIMENTO ACCOUNT
				if (mode == 'PG') {
					if (String.isBlank(a.NDG__c) || String.isBlank(a.NDGGruppo__c)) {
						//il prospect è presente in CRM ma non ha NDG: o nuovo censimento o manca aggancio Cedacri
						Account accFull = [
							SELECT Id,
								OwnerId, 
								RecordType.DeveloperName, 
								NDGGruppo__c, 
								NDG__c, 
								StatoCensimento__c, 
								Name, 
								NaturaGiuridica__c,
								SAE__c,
								RAE__c,
								Ateco__c,
								TAECode__c,
								DataIscrizioneCCIAA__c,
								REA__c,
								BillingStreetName__c,
								BillingStreetType__c,
								BillingStreetNumber__c,
								BillingPostalCode,
								BillingCountry,
								BillingState,
								BillingCity, 
								ShippingCity,
								ShippingStreetName__c,
								ShippingStreetType__c,
								ShippingStreetNumber__c,
								ShippingPostalCode,
								ShippingCountry,
								ShippingState,
								CF__c,
								PIVA__c,
								Email__c,
								EmailPEC__c, 
								telefonoprefisso__c,
								telefononumero__c,
								fax,
								consensoallaprofilazione__c,
								consensoattivitapromozionaleterzi__c,
								consensoattivitapromricerchemercato__c,
								consensoprodottibancaricerchemercato__c,
								consensoprodottisocietaterze__c,
								consensosolomodalitatradizionali__c,
								datainserimentoconsensi__c,
								PartecipazioneSocietaFiduciarie2__c,
								NumberOfEmployees,
								WGC_Numero_dipendenti__c,
								Fatturato__c,
								DataFatturato__c,
								PaeseCasaMadre__c,
								Website
							FROM Account
							WHERE Id = :a.Id
							LIMIT 1
						];
						if (accFull.NaturaGiuridica__c == 'DI')  {//FIXME
							bifis_crm_c_CommonUtils.logError(accFull, null, w, new bifis_crm_c_MccNsaException('Azienda DI: serve censimento full manuale della PF titolare'));
							w.ErrorMessage__c = 'Azienda DI: serve censimento full manuale della PF titolare';
							update w;
							return;
						}
						//prima cerco su Cedacri, se c'è allora variazione
						List<Account> accCedacri = WsAnagrafeUtils.searchPG(null, null, accFull.PIVA__c, null);
						//non lo trovo -> censisco nuovo
						if (accCedacri.size() == 0) {
							String ndg = WsAnagrafeUtils.censimentoLight(accFull);
							a=accFull;
							a.NDG__c = ndg;
							a.NDGGruppo__c = ndg;
							if (ndg == null){
								w.ErrorMessage__c = 'Censimento Light fallito';
								update w;
							}
							update a;						
						//trovato corrispondenza su Cedacri, aggancio NDG
						} else if (accCedacri.size() == 1) {
							a.NDG__c = !String.isBlank(accCedacri[0].NDG__c) ? accCedacri[0].NDG__c : accCedacri[0].NDGGruppo__c;
							a.NDGGruppo__c = accCedacri[0].NDGGruppo__c;
							update a;
						} else {
							//più risultati per la stessa P.IVA
						}
				
						if (String.isBlank(a.NDGGruppo__c)) {
							bifis_crm_c_CommonUtils.logError(accFull, null, w, new bifis_crm_c_MccNsaException('NDG per PG non ottenuto!'));
							w.ErrorMessage__c = 'NDG per PG non ottenuto!';
							update w;
							return;						
						}
					}

					//correla Accout su Opportunità
					o.AccountId = a.Id;
					update o;

					//avendo già fatto le callout per l'Account, 
					//devo staccare una nuova transazione per gov. limits
					System.enqueueJob(new AsyncJobsNSA_Q(
						a, 
						referenti,
						o,
						w, 
						mappaCodiciValori,
						advPayload,
						'PF'
					));
				} //END CENSIMENTO ACCOUNT

				//CENSIMENTO PERSONE FISICHE
				if (mode == 'PF') {
					if (referenti == null || referenti.isEmpty()) {
						//ho censito tutti i referenti, continuiamo col resto
						System.enqueueJob(new AsyncJobsNSA_Q(
							a, 
							referenti,
							o,
							w, 
							mappaCodiciValori,
							advPayload,
							'OT'
						));
					} else {
						//processiamo 1 referente e i prossimi vanno in async
						Object pf = referenti.remove(0);

						Map<String, Object> m = (Map<String, Object>) pf;
						String cf = ((String) m.get('codiceFiscale')).toUpperCase();
						String nome = ((String) m.get('nome')).toUpperCase();
						String cognome = ((String) m.get('cognome')).toUpperCase();

						Contact contactCRM = bifis_crm_c_CommonUtils.searchByCodFisc(cf);
						if (contactCRM == null) {
							bifis_crm_c_MccNsaException e = 
								new bifis_crm_c_MccNsaException('Impossibile trovare PF con codice fiscale ' + cf);
							//log error
							bifis_crm_c_CommonUtils.logError(a, contactCRM, w, e);

							//update w status
							w.StatoElaborazione__c = 'ERRORE';
							w.ErrorMessage__c = (e.getMessage() + '\n\n' + e.getStackTraceString()).abbreviate(131072);
							update w;
							throw e;
						}
						List<AccountContactRelation> rels = [
							SELECT WGC_Ruolo__c, AccountId, ContactId
							FROM AccountContactRelation 
							WHERE AccountId = :a.Id and ContactId = :contactCRM.Id
						];
						List<String> selectedRoles = new List<String>(); 
						for (AccountContactRelation r : rels) {
							selectedRoles.add(r.WGC_Ruolo__c);
						}
						//PF presente in CRM senza NDG, cerchiamo su Cedacri oppure censimento light
						if (String.isBlank(contactCRM.NDGGruppo__c)) {
							//String accId = [SELECT Id FROM Account WHERE NDGGruppo__c = :a.NDGGruppo__c].Id;
							String tipoCensimento = 'light';
							String whoAreYou ='batchnsa'; 
							Opportunity opportunitySelected = null;

							List<Contact> contactsCedacri = WsAnagrafeUtils.searchPF(contactCRM.CF__c, null, null);
						
							if (contactsCedacri.isEmpty()) {
								//censimento light
								WGC_CreateContact.saveContact(
									contactCRM,
									a.Id,
									selectedRoles,
									tipoCensimento,
									whoAreYou,
									opportunitySelected);
						
							} else if (contactsCedacri.size() == 1) {
								//trovato su cedacri: upsert su CRM
								Contact merged = contactsCedacri.get(0); //FIXME mergiare i dati tra quello CRM e quello Cedacri
								merged.SAE__c = contactCRM.SAE__c;
								merged.TAECode__c = String.isBlank(contactCRM.TAECode__c) ? '984' : contactCRM.TAECode__c;
								merged.Birthdate = contactCRM.Birthdate;
								merged.FirstName = contactCRM.FirstName;
								merged.LastName = contactCRM.LastName;
								merged.LuogoNascita__c = contactCRM.LuogoNascita__c;
								merged.ProvinciaNascita__c = contactCRM.ProvinciaNascita__c;
								merged.Id = contactCRM.Id;
								update merged;

							} else if (contactsCedacri.size() > 1) {
								//più risultati, non posso procedere
								bifis_crm_c_MccNsaException e = 
									new bifis_crm_c_MccNsaException('Anomalia ricerca su Cedacri per codice fiscale ' + contactCRM.CF__c
										+ '. Troppi risultati ' + contactsCedacri.size() + ', me ne aspetto solo uno.');
								//log error
								bifis_crm_c_CommonUtils.logError(a, contactCRM, w, e);

								//update w status
								w.StatoElaborazione__c = 'ERRORE';
								w.ErrorMessage__c = (e.getMessage() + '\n\n' + e.getStackTraceString()).abbreviate(131072);
								update w;
								throw e;						
							}						
						} //END-IF String.isBlank(contactCRM.NDGGruppo__c)

						/*
						--FIXME non pre-associamo per poter laciare fare l'operazione a FE
						//questo finchè non avremo i dati da NSA per fare censimento FULL
						//allora potremo creare le reti da batch
						//bifis_crm_c_CommonUtils.runUpdateRole(a.Id, contactCRM.Id, selectedRoles);
						*/

						//ho censito il referente, continuiamo col prossimo
						System.enqueueJob(new AsyncJobsNSA_Q(
							a, 
							referenti,
							o,
							w, 
							mappaCodiciValori,
							advPayload,
							'PF'
						));	
					}
				} //END CENSIMENTO PERSONE FISICHE

				//RESTO DELLE ELABORAZIONI
				if (mode == 'OT') {
					//ADEGUATA VERIFICA
					if (String.isNotBlank(advPayload))
						CtrlWizardOpportunity.updateAdeguataVerifica(advPayload);

					if (String.isBlank(a.NDGGruppo__c))
						return;

					//QUESTIONARIO QUALITATIVO
					WsAnagrafe.ModificaDatiAggiuntiviQQInput input = new WsAnagrafe.ModificaDatiAggiuntiviQQInput();
					input.ndg = Long.valueOf(a.NDGGruppo__c);

					WsAnagrafe.RequestDato[] rdlist = new List<WsAnagrafe.RequestDato>();
					for (Integer codMod : mappaCodiciValori.keySet()) {
					  // primo parametro è il codice modulo
					  rdlist.clear();
					  WsAnagrafe.RequestDato rdCodiceModulo = new WsAnagrafe.RequestDato();
					  rdCodiceModulo.codice = codMod;
					  rdlist.add(rdCodiceModulo);

					  for (Domanda d: mappaCodiciValori.get(codMod)) {
						WsAnagrafe.RequestDato rd = new WsAnagrafe.RequestDato();
						rd.codice = d.codiceDatoDomanda;
						rd.valore = d.value;
						rdlist.add(rd);
					  }

					  WsAnagrafe.RequestDati requestDati = new WsAnagrafe.RequestDati();
					  requestDati.requestDato = rdlist;

					  input.requestDati = requestDati;
					  //call out jobs
					  String payload = JSON.serialize(input);
					  bifis_crm_c_CommonUtils.runQQ(payload);
					}

					//avendo già fatto le callout per QQ etc, 
					//devo staccare una nuova transazione per gov. limits
					System.enqueueJob(new AsyncJobsNSA_Q(
						a, 
						referenti,
						o,
						w, 
						mappaCodiciValori,
						advPayload,
						'AT'
					));

				}

				//RESTO DELLE ELABORAZIONI
				if (mode == 'AT') {
					List<String> docNames = new List<String> {
						'DOCUMENTO_RSF_JSON__c',
						'DOCUMENTO_MAV_JSON__c',
						'DOCUMENTO_MTC_JSON__c',
						'DOCUMENTO_MPA_JSON__c',
						'DOCUMENTO_MPE_JSON__c',
						'DOCUMENTO_A4_JSON__c',
						'DOCUMENTO_BE3_JSON__c',
						'DOCUMENTO_BESC_JSON__c',
						'DOCUMENTO_BVA_JSON__c',
						'DOCUMENTO_BPR_JSON__c',
						'DOCUMENTO_DIA4_JSON__c',
						'DOCUMENTO_DIE_JSON__c',
						'DOCUMENTO_DITS_JSON__c',
						'DOCUMENTO_DIT_JSON__c',
						'DOCUMENTO_UAC_JSON__c',
						'DOCUMENTO_DIC_JSON__c',
						'DOCUMENTO_DM10_JSON__c',
						'DOCUMENTO_DM10I_JSON__c',
						'DOCUMENTO_DAB_JSON__c',
						'DOCUMENTO_ECF_JSON__c',
						'DOCUMENTO_GCE_JSON__c',
						'DOCUMENTO_MU2_JSON__c',
						'DOCUMENTO_MUS_JSON__c',
						'DOCUMENTO_PCD_JSON__c',
						'DOCUMENTO_PRO_JSON__c',
						'DOCUMENTO_RI_JSON__c',
						'DOCUMENTO_SVR_JSON__c',
						'DOCUMENTO_SDG_JSON__c',
						'DOCUMENTO_DCVC_JSON__c',
						'DOCUMENTO_VCL_JSON__c'
					};
					//collega gli allegati all'opportunità
					bifis_crm_b_MccNsaGenerateOpportunity.allegaDocs(o, w, docNames);
            
					//Aggiorna stato elaborazione pratica
					w.StatoElaborazione__c = 'COMPLETA';
					update w;
				}

			} catch(Exception e) {
				//log error
				bifis_crm_c_CommonUtils.logError(a, null, w, e);

				//update w status
				w.StatoElaborazione__c = 'PARZIALE';
				w.ErrorMessage__c = (e.getMessage() + '\n\n' + e.getStackTraceString()).abbreviate(131072);
				update w;
			}
		}
	}

	
}