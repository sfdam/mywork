/**
 * Progetto:         Banca IFIS
 * Descrizione:      Classe handler del trigger Campagna.trigger
 * Sviluppata il:    21/10/2016
 * Developer:        Zerbinati Francesco, Michele Triaca
*/

public without sharing class TrgCampagna {
	private TrgCampagna() { }

	public static Boolean disableTrigger = false;

	/**
	 * Metodo che crea un task sul contatto dell'account in membri campagna
	 **/
	public static void creaTaskContatto(T tu) {
		Campaign[] camps = tu.filter('IsActive', true).getChanged('IsActive');
		if (camps.isEmpty()) return;

		creaTaskDaCampaignMember([SELECT
		                         Id,
		                         AccountOwner__c,
		                         AccountId__c,
		                         AccountOpFiloDiretto__c,
		                         Cap__c,
		                         Comune__c,
		                         Provincia__c,
		                         CampaignId,
		                         NomeCampagna__c,
		                         DataContattoCampagna__c,
		                         DataUltimaImportazioneDaWeb__c,
		                         ContactId,
		                         TipologiaCliente__c,
		                         BI_Target_Form_MCC__c,
		                         MessaggioFormWeb__c,
		                         IFISForm__c,
		                         IFISIdUnicoForm__c,
		                         BI_IFISFormPriority__c,
		                         CanaleCampagna__c,
								 BI_TargetForm__c
		                         FROM CampaignMember
		                         WHERE CampaignID IN :camps
		                         ]);
	}

	/**
	 * Metodo di appoggio usato da creaTaskContatto e anche dal trigger dei campaign member
	 **/
	public static void creaTaskDaCampaignMember(CampaignMember[] cmL) {

		if (cmL.isEmpty()) return;

		Set<Id> setUtenti = U.getIdSet(cmL, 'AccountOwner__c'); // SV - TEN Modificato campo formula [ Contact.Account.WGC_Specialista_Factoring__c ]
		setUtenti.addAll(U.getIdSet(cmL, 'AccountOpFiloDiretto__c')); // SV - TEN Modificato campo formula [ Contact.Account.WGC_Specialista_Filo_Diretto__c ]
		Map<Id, User> utenti = new Map<Id, User> ([SELECT Id, IsActive FROM User WHERE Id IN :setUtenti]);
		System.debug('SV utenti: ' + utenti);
		CU.addToCache(utenti.keySet());

		// SV - TEN GESTIONE ORIGINATOR E ORIGINATOR DETTAGLIO
		Set<Id> setAccountId = U.getIdSet(cmL, 'AccountId__c'); // recupero account id da cmL
		//Map<String, SObject> leadAccs = U.keyBy([
		                                        //SELECT Id, IFISIdUnicoForm__c, IFISForm__c, WGC_Originator__c, WGC_Originator_Dettaglio__c, AccountCollegato__c
		                                        //FROM Lead
		                                        //WHERE AccountCollegato__c IN :setAccountId], 'Id');
		//System.debug('SV leadAccs: ' + leadAccs);

		List<Lead> leadAccs2 = [SELECT Id, IFISIdUnicoForm__c, IFISForm__c, WGC_Originator__c, WGC_Originator_Dettaglio__c, AccountCollegato__c
		                                        FROM Lead
		                                        WHERE AccountCollegato__c IN :setAccountId ORDER BY CreatedDate DESC LIMIT 1];
		System.debug('SV leadAccs: ' + leadAccs2);

		Map<String, SObject> canaleDiSviluppoMap = U.keyBy([
		                                                   SELECT Id, DeveloperName, MasterLabel, NamespacePrefix, Label,
		                                                   QualifiedApiName, Originator__c, Originator_dettaglio__c,
		                                                   Forzatura__c, Canale_di_sviluppo__c, Qualifica_Utente__c, IFISForm__c
		                                                   FROM WGC_Originator__mdt
		                                                   WHERE IFISForm__c != null], 'IFISForm__c');
		System.debug('SV canaleDiSviluppoMap: ' + canaleDiSviluppoMap);

		CampaignMember[] cmLStandard = U.filter(cmL, 'CanaleCampagna__c', 'Sviluppo Diretto');
		CampaignMember[] cmLFD = U.filter(cmL, 'CanaleCampagna__c', 'Filo Diretto');

		Map<String, Map<String, Id>> tipoCampagna2ownerCapMap = new Map<String, Map<String, Id>> {
			'fd' => UtilAnagrafiche.getOwners(U.getSet(cmLFD, 'Cap__c'), U.getSet(cmLFD, 'Comune__c'), U.getSet(cmLFD, 'Provincia__c'), true),
			'altri' => UtilAnagrafiche.getOwners(U.getSet(cmLStandard, 'Cap__c'), U.getSet(cmLStandard, 'Comune__c'), U.getSet(cmLStandard, 'Provincia__c'), false)
		};

		System.debug('SV tipoCampagna2ownerCapMap: ' + tipoCampagna2ownerCapMap);

		Map<Id, Account> accsToUpdate = new Map<Id, Account> ();
		Map<Id, Account> accsToReassign = new Map<Id, Account> ();
		Map<Id, Account> accs = new Map<Id, Account> ([SELECT Id, CanaleSviluppo__c, Sottocanale__c, OwnerId, WGC_Originator__c, WGC_Originator_dettaglio__c, WGC_Specialista_Factoring__c, WGC_Specialista_Filo_Diretto__c FROM Account WHERE Id IN :U.getIdSet(cmL, 'AccountId__c')]);

		for (CampaignMember cm : cmL) {
			String canale = cm.CanaleCampagna__c == 'Filo Diretto' ? 'fd' : 'altri';
			Map<String, Id> ownerCap = tipoCampagna2ownerCapMap.get(canale);
			Id ownerId = ownerCap.get('0000');
			if (String.isNotBlank(cm.Cap__c) && ownerCap.containsKey(cm.Cap__c)) ownerId = ownerCap.get(cm.Cap__c);
			else if (String.isNotBlank(cm.Comune__c) && ownerCap.containsKey(cm.Comune__c)) ownerId = ownerCap.get(cm.Comune__c);
			else if (String.isNotBlank(cm.Provincia__c) && ownerCap.containsKey(cm.Provincia__c)) ownerId = ownerCap.get(cm.Provincia__c);

			Account a = accs.get(cm.AccountId__c);

			if (a.CanaleSviluppo__c != '5' && a.CanaleSviluppo__c != '4') {
				a.CanaleSviluppo__c = '2';
				if (String.isBlank(a.Sottocanale__c)) a.Sottocanale__c = cm.NomeCampagna__c;
				accsToUpdate.put(a.Id, a);
			}

			if (!(cm.AccountOwner__c != null && utenti.get(cm.AccountOwner__c).IsActive) || UtenzeDefault__c.getInstance(cm.AccountOwner__c).AssegnatarioDiDefault__c) {
				// a.OwnerId = ownerId; 08.07
				accsToUpdate.put(cm.AccountId__c, a);
				accsToReassign.put(cm.AccountId__c, a);
			}
		}

		update accsToUpdate.values();

		Task[] res = new Task[] { };
		//elabora solo gli item eleggibili per contratti Ifis (p.e. i clienti sono PG e non PF)
		//usiamo un Set per evitare di aggiungere 2 volte lo stesso record quando controlliamo quelli facebook più sotto
		Set<CampaignMember> items = new Set<CampaignMember>();
        //M.N. SDCHG-5359 Classificazione In Target/Fuori Target 
		//items.addAll((CampaignMember[])U.filter(cmL, 'TipologiaCliente__c', '3', false));
		items.addAll((CampaignMember[])U.filter(cmL, 'BI_TargetForm__c', '0', false));
		//caso particolare: lead arrivati tramite form Facebook devono avere sempre il CT anche se non eleggibili per contratti Ifis 
		for (CampaignMember cm : cmL) {
			if (cm.IFISForm__c == '22')
				items.add(cm);
		}

		for (CampaignMember cm : items) {
			// NESSUN TASK ANCHE SE FUORI TARGET. CONCETTO INTRODOTTO IN SEGUITO, IF NON ELEGANTE MA CAMPO FILTER NEL FOR NON PREVEDE PIU' CAMPI DI VALUTAZIONE
			//Modifiche per DSP (M. Bonin)
			//if (cm.BI_Target_Form_MCC__c != '1') {
            if (cm.BI_Target_Form_MCC__c != '2' && cm.BI_Target_Form_MCC__c != '3' && cm.BI_Target_Form_MCC__c != '4') {
				String canale = cm.CanaleCampagna__c == 'Filo Diretto' ? 'fd' : 'altri';
				Map<String, Id> ownerCap = tipoCampagna2ownerCapMap.get(canale);

				Id ownerId = ownerCap.get('0000');
				if (CU.isFiloDiretto(cm.AccountOpFiloDiretto__c) && utenti.get(cm.AccountOpFiloDiretto__c).IsActive && cm.CampaignId == BI_COM_ConversioneLead_BTCH.ID_CAMPAGNA_WEB) ownerId = cm.AccountOpFiloDiretto__c;
				else if (CU.isFiloDiretto(cm.AccountOpFiloDiretto__c) && utenti.get(cm.AccountOpFiloDiretto__c).IsActive && cm.CanaleCampagna__c == 'Filo Diretto') ownerId = cm.AccountOpFiloDiretto__c;
				else if (CU.isCommerciale(cm.AccountOwner__c) && utenti.get(cm.AccountOwner__c).IsActive && cm.CanaleCampagna__c != 'Filo Diretto') ownerId = cm.AccountOwner__c;
				else if (String.isNotBlank(cm.Cap__c) && ownerCap.containsKey(cm.Cap__c)) ownerId = ownerCap.get(cm.Cap__c);
				else if (String.isNotBlank(cm.Comune__c) && ownerCap.containsKey(cm.Comune__c)) ownerId = ownerCap.get(cm.Comune__c);
				else if (String.isNotBlank(cm.Provincia__c) && ownerCap.containsKey(cm.Provincia__c)) ownerId = ownerCap.get(cm.Provincia__c);

				Date activityDate = Date.today();
				if (cm.DataUltimaImportazioneDaWeb__c != null && cm.DataUltimaImportazioneDaWeb__c > Date.today()) activityDate = cm.DataUltimaImportazioneDaWeb__c.date();
				else if (cm.DataContattoCampagna__c != null && cm.DataContattoCampagna__c > Date.today()) activityDate = cm.DataContattoCampagna__c;

				// SV - TEN CHIEDERE SE LA LOGICA checkTaskAperti VA BENE.
				//Account a = accs.get(cm.AccountId__c);
				String forzatura = (leadAccs2.size() > 0 && leadAccs2.get(0).IFISForm__c != null) ? String.valueOf(canaleDiSviluppoMap.get(leadAccs2.get(0).IFISForm__c).get('Forzatura__c')) : 'false';

				Task t = new Task(
				                  WhoId = cm.ContactId,
				                  WhatId = cm.AccountId__c,
				                  Canale__c = cm.CanaleCampagna__c == 'Filo Diretto' ? 'Campagna Filo Diretto' : null,
				                  OwnerId = cm.CanaleCampagna__c == 'Filo Diretto' ? ownerId : (accsToReassign.containsKey(cm.AccountId__c) ? accsToReassign.get(cm.AccountId__c).WGC_Specialista_Filo_Diretto__c : cm.AccountOwner__c),
				                  Status = 'Aperto',
				                  Subject = 'Contatto telefonico campagna',
				                  ActivityDate = activityDate,
				                  Campagna__c = cm.CampaignId,
				                  RecordTypeId = U.getRecordTypes('Task').get('ContattoTelefonicoDiretto').Id,
				                  Data_Inizio__c = System.now(),
				                  Data_Fine__c = System.now(),
				                  MembroCampagna__c = cm.Id,
								  WGC_Forzatura__c = forzatura.toUpperCase().equals('SI'),

				                  // ORIGINATORS CALCOLATI IN BASE CHE IL LEAD SIA CAMPAGNA O FORM

				                  //Originator__c = leadAccs.containsKey(a.Id) ? leadAccs.get(a.Id).get('IFISIdUnicoForm__c') != null ? (String) canaleDiSviluppoMap.get((String) leadAccs.get(a.Id).get('IFISForm__c')).get('Originator__c') : (String) leadAccs.get(a.Id).get('WGC_Originator__c') : null,
				                  //Originator_di_dettaglio__c = leadAccs.containsKey(a.Id) ? leadAccs.get(a.Id).get('IFISIdUnicoForm__c') != null ? (String) canaleDiSviluppoMap.get((String) leadAccs.get(a.Id).get('IFISForm__c')).get('Originator_dettaglio__c') : (String) leadAccs.get(a.Id).get('WGC_Originator_Dettaglio__c') : null,
								  //WGC_IsCreatedFromLead__c = leadAccs.containsKey(a.Id)
								  Originator__c = (leadAccs2.size() > 0 && leadAccs2.get(0).IFISForm__c != null) ? (leadAccs2.get(0).IFISIdUnicoForm__c != null) ? (String) canaleDiSviluppoMap.get(leadAccs2.get(0).IFISForm__c).get('Originator__c') : leadAccs2.get(0).WGC_Originator__c : null,
				                  Originator_di_dettaglio__c = (leadAccs2.size() > 0 && leadAccs2.get(0).IFISForm__c != null) ? leadAccs2.get(0).IFISIdUnicoForm__c != null ? (String) canaleDiSviluppoMap.get(leadAccs2.get(0).IFISForm__c).get('Originator_dettaglio__c') : leadAccs2.get(0).WGC_Originator_Dettaglio__c : null,

				                  WGC_IsCreatedFromLead__c = (leadAccs2.size() > 0 && leadAccs2.get(0).IFISForm__c != null) ? true : false

				);
				System.debug('WGC_IsCreatedFromLead__c:'+ String.valueOf((leadAccs2.size() > 0 && leadAccs2.get(0).IFISForm__c != null) ? true : false));
				// EVENTUALE "TRAVASO" DI DATI NEL TASK, DATI PROVENIENTI DAL LEAD ORIGINARIO

				if (String.isNotBlank(cm.MessaggioFormWeb__c)) t.Description = cm.MessaggioFormWeb__c;
				if (String.isNotBlank(cm.IFISForm__c)) t.IFISForm__c = cm.IFISForm__c;
				if (String.isNotBlank(cm.IFISIdUnicoForm__c)) t.IFISIdUnicoForm__c = cm.IFISIdUnicoForm__c;
				if (String.isNotBlank(cm.BI_IFISFormPriority__c)) t.BI_IFISFormPriority__c = cm.BI_IFISFormPriority__c;

				res.add(t);
			}
		}

		insert res;

	}

	/**
	 * Metodo di appoggio usato da eliminaTaskContatto e anche dal trigger dei campaign member
	 **/
	//public static void eliminaTaskDaCampaignMember(Map<Id,CampaignMember> cmL) {
	//  if(cmL.isEmpty()) return;

	//  Task[] res = [SELECT Id FROM Task WHERE MembroCampagna__c IN :cmL.keySet()];
	//  delete res;

	//}
}