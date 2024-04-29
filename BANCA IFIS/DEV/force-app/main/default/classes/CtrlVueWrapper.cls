public with sharing class CtrlVueWrapper {
	private static Integer MAX_LENGTH = 131072;


	@AuraEnabled
	public static Task[] fetchMyTasks() { return CtrlListeHp.fetchMyTasks(); }

	@AuraEnabled
	public static Event[] fetchMyEvents() { return CtrlListeHp.fetchMyEvents(); }

	@AuraEnabled
	public static SObject[] fetchActivities(String accountId) { return CtrlRecentActivities.fetchActivities(accountId); }

	// POSIZIONE ACCOUNT

	@AuraEnabled
	public static Rapporto__c[] fetchRapporti(String accountId) { return CtrlPosizioneAccount.fetchRapporti(accountId); }

	@AuraEnabled
	public static Rapporto__c fetchAssetDebitore(String accountId) { return CtrlPosizioneAccount.fetchAssetDebitore(accountId); }

	@AuraEnabled
	public static Relazione__c[] fetchRelazioneClienti(String accountId) { return CtrlPosizioneAccount.fetchRelazioneClienti(accountId); }

	@AuraEnabled
	public static String tipoAccount(String accountId) { return CtrlPosizioneAccount.tipoAccount(accountId); }

	@AuraEnabled
	public static List<Map<String, Object>> getRiepilogoOpportunita(String opportunityId) { return CtrlWizardOpportunity.getRiepilogoOpportunita(opportunityId); }

	@AuraEnabled
	public static List<Map<String, Object>> getRiepilogoInfoCr(String opportunityId) { return CtrlWizardOpportunity.getRiepilogoInfoCr(opportunityId); }

	@AuraEnabled
	public static CtrlCointestazione.ResponseObject recuperaCointestazioni(String processId, Boolean riepilogoCointestazioni, Id sObjectId) {
		return CtrlCointestazione.recuperaCointestazioni(processId, riepilogoCointestazioni, sObjectId);
	}

	@AuraEnabled
	public static List<Map<String, Object>> getRiepilogoAccountTeam(String accountId) { return CtrlWizardAccount.getRiepilogoAccountTeam(accountId); }

	@AuraEnabled
	public static Map<String, Map<String, Object>> getFieldSets(String fieldSetList, String sObjectId, String sObjectName) { return CtrlWizardAccount.getFieldSets(fieldSetList, sObjectId, sObjectName); }

	@AuraEnabled
	public static Id upsertObject(String obj, String objName) {
		try {
			return CtrlWizardAccount.upsertObject(obj, objName);
		} catch(Exception e) {
			throw new AuraHandledException(Ex.getReadableMessage(e));
		}
	}

	@AuraEnabled
	public static Boolean renderModifica(String profileList) { return CtrlWizardAccount.renderModifica(profileList); }

	@AuraEnabled
	public static WSRestRibesUtils.EventiNegativiPlain getInformazioniPopupDebitore(String accountId) {
		try {
			return CtrlWizardOpportunity.getInformazioniPopupDebitore(accountId);
		} catch(Exception e) {
			throw new AuraHandledException(e.getMessage());
		}
	}

	@AuraEnabled
	public static Id getInformazioniPopupDebitorePDF(String accountId) {
		try {
			return CtrlWizardOpportunity.getInformazioniPopupDebitorePDF(accountId);
		} catch(Exception e) {
			throw new AuraHandledException(e.getMessage());
		}
	}

	@AuraEnabled
	public static void aggiornaNSA(Id oppId) {
		ExtViewCheckList.aggiornaNSA(oppId);
	}

	@AuraEnabled
	public static ExtViewCheckList.StatoCheckList getStatoChecklist(String oppId) { return ExtViewChecklist.getStatoChecklist(oppId); }

	@AuraEnabled
	public static Boolean refreshStatoCartella(String oppId) { return ExtViewChecklist.refreshStatoCartella(oppId); }

	@AuraEnabled
	public static Opportunity getInformazioniOppChecklist(Id oppId) { return ExtViewCheckList.getInformazioniOppChecklist(oppId); }

	@AuraEnabled
	public static Boolean getUpdatedFatturatoAndDipendenti(Id objectId) {
		return ExtViewCheckList.getUpdatedFatturatoAndDipendenti(objectId);
	}

	@AuraEnabled
	public static SObject inverseLookup(String fieldLabel, String fieldValue, String[] otherFields, String targetObj, String value) { return ExtSfdcLookup.inverseLookup(fieldLabel, fieldValue, otherFields, targetObj, value); }

	@AuraEnabled
	public static SObject[] searchRecent(String fieldLabel, String fieldValue, String[] otherFields, String targetObj, String[] valuesToExclude) { return ExtSfdcLookup.searchRecent(fieldLabel, fieldValue, otherFields, targetObj, valuesToExclude); }

	//------------------------------ COMMUNITY TI ANTICIPO -------------------------------------
	@AuraEnabled
	public static String login(String input) {
		try {
			return TaCtrlLogin.login(input);
		} catch(Exception e) {
            /* adione: ripristinare log evento solo per analisi problemi puntuali
             * tenere spento per troppi log da tentativi automatici di malintenzionati
			//errore tecnico ...o anche sbagliata la psw, con le nuove API non c'è distinguo
			//remove password when logging
			Integer idxStart = input.lastIndexOf('password":"');
			Integer idxEnd = input.indexOf('","', idxStart);
			String newInput = input.substring(0, idxStart) + 'password":"*****' + input.substring(idxEnd, input.length());
			AsyncLog__e l = new AsyncLog__e(
			                                Source__c = 'TiAnticipo',
			                                CodiceFunzione__c = 'TaCtrlLogin.login',
			                                ErrorMessage__c = Ex.getReadableMessage(e) + '\n' + e.getStackTraceString(),
			                                InputPayload__c = newInput.abbreviate(MAX_LENGTH)
			);

			EventBus.publish(l);
            */
			//dati login sbagliati
			throw new AuraHandledException(Ex.getReadableMessage(e));
		}
	}

	@AuraEnabled
	public static String selfRegister(String input) {
		try {
			return TaCtrlLogin.selfRegister(input);

		} catch(Ex.GenericException e) {
			//remove password when logging
			Integer idxStart = input.lastIndexOf('password":"');
			Integer idxEnd = input.indexOf('","', idxStart);
			String newInput = input.substring(0, idxStart) + 'password":"*****' + input.substring(idxEnd, input.length());
			AsyncLog__e l = new AsyncLog__e(
			                                Source__c = 'TiAnticipo',
			                                CodiceFunzione__c = 'TaCtrlLogin.selfRegister',
			                                ErrorMessage__c = Ex.getReadableMessage(e) + '\n' + e.getStackTraceString(),
			                                InputPayload__c = newInput.abbreviate(MAX_LENGTH)
			);

			EventBus.publish(l);
			//questo tipo di eccezione è applicativa, mostriamo msg al cliente
			throw new AuraHandledException(Ex.getReadableMessage(e));

		} catch(Exception e) {
			//remove password when logging
			Integer idxStart = input.lastIndexOf('password":"');
			Integer idxEnd = input.indexOf('","', idxStart);
			String newInput = input.substring(0, idxStart) + 'password":"*****' + input.substring(idxEnd, input.length());
			AsyncLog__e l = new AsyncLog__e(
			                                Source__c = 'TiAnticipo',
			                                CodiceFunzione__c = 'TaCtrlLogin.selfRegister',
			                                ErrorMessage__c = Ex.getReadableMessage(e) + '\n' + e.getStackTraceString(),
			                                InputPayload__c = newInput.abbreviate(MAX_LENGTH)
			);
			EventBus.publish(l);
			//questo tipo di eccezione è tecnica, diamo msg generale al cliente
			throw new AuraHandledException('Errore: riprovare o contattare servizio clienti.');
		}
	}

	@AuraEnabled
	public static Boolean resetPassword(String input) {
		try {
			return TaCtrlLogin.resetPassword(input);

		} catch(Exception e) {
			//remove password when logging
			Integer idxStart = input.lastIndexOf('password":"');
			Integer idxEnd = input.indexOf('","', idxStart);
			String newInput = input.substring(0, idxStart) + 'password":"*****' + input.substring(idxEnd, input.length());
			AsyncLog__e l = new AsyncLog__e(
			                                Source__c = 'TiAnticipo',
			                                CodiceFunzione__c = 'TaCtrlLogin.resetPassword',
			                                ErrorMessage__c = Ex.getReadableMessage(e) + '\n' + e.getStackTraceString(),
			                                InputPayload__c = newInput.abbreviate(MAX_LENGTH)+' --- User: '+UserInfo.getName()+', User Id: '+UserInfo.getUserId()
			);
			EventBus.publish(l);
			//throw new AuraHandledException(Ex.getReadableMessage(e));
			throw new AuraHandledException('Non è stato possibile resettare la password per l\'email indicata');
		}
	}

	@AuraEnabled
	public static Boolean setAccessoEffettuato(Boolean value) {
		try {
			return TaCtrlLogin.setAccessoEffettuato(value);

		} catch(Exception e) {
			AsyncLog__e l = new AsyncLog__e(
			                                Source__c = 'TiAnticipo',
			                                CodiceFunzione__c = 'TaCtrlLogin.setAccessoEffettuato',
			                                ErrorMessage__c = Ex.getReadableMessage(e) + '\n' + e.getStackTraceString(),
			                                InputPayload__c = value + ''
			);
			EventBus.publish(l);
			//throw new AuraHandledException(Ex.getReadableMessage(e));
			throw new AuraHandledException('Errore: riprovare o contattare servizio clienti.');
		}
	}

	@AuraEnabled
	public static SObject[] search(String fieldLabel, String fieldValue, String[] otherFields, String targetObj, String value, String[] valuesToExclude) {
		try {
			return ExtSfdcLookup.search(fieldLabel, fieldValue, otherFields, targetObj, value, valuesToExclude);
		} catch(Exception e) {
			AsyncLog__e l = new AsyncLog__e(
			                                Source__c = 'TiAnticipo',
			                                CodiceFunzione__c = 'ExtSfdcLookup.search',
			                                ErrorMessage__c = Ex.getReadableMessage(e) + '\n' + e.getStackTraceString(),
			                                InputPayload__c = 'fieldLabel: ' + fieldLabel + ', fieldValue: ' + fieldValue + ', otherFields: ' + otherFields + ', targetObj: ' + targetObj + ', value: ' + value + ', valuesToExclude: ' + valuesToExclude
			);
			EventBus.publish(l);
			//throw new AuraHandledException(Ex.getReadableMessage(e));
			throw new AuraHandledException('Errore: riprovare o contattare servizio clienti.');
		}
	}

	@AuraEnabled
	public static SObject[] searchComuni(String fieldLabel, String fieldValue, String[] otherFields, String targetObj, String value, String[] valuesToExclude) {
		try {
			return ExtSfdcLookup.searchComuni(fieldLabel, fieldValue, otherFields, targetObj, value, valuesToExclude);
		} catch(Exception e) {
			AsyncLog__e l = new AsyncLog__e(
			                                Source__c = 'TiAnticipo',
			                                CodiceFunzione__c = 'ExtSfdcLookup.searchComuni',
			                                ErrorMessage__c = Ex.getReadableMessage(e) + '\n' + e.getStackTraceString(),
			                                InputPayload__c = 'fieldLabel: ' + fieldLabel + ', fieldValue: ' + fieldValue + ', otherFields: ' + otherFields + ', targetObj: ' + targetObj + ', value: ' + value + ', valuesToExclude: ' + valuesToExclude
			);
			EventBus.publish(l);
			//throw new AuraHandledException(Ex.getReadableMessage(e));
			throw new AuraHandledException('Errore: riprovare o contattare servizio clienti.');
		}
	}

	@AuraEnabled
	public static SObject[] searchFactoringUsers(String fieldLabel, String fieldValue, String[] otherFields, String targetObj, String value, String[] valuesToExclude) {
		try {
			return ExtSfdcLookup.searchFactoringUsers(fieldLabel, fieldValue, otherFields, targetObj, value, valuesToExclude);
		} catch(Exception e) {
			AsyncLog__e l = new AsyncLog__e(
			                                Source__c = 'TiAnticipo',
			                                CodiceFunzione__c = 'ExtSfdcLookup.searchFactoringUsers',
			                                ErrorMessage__c = Ex.getReadableMessage(e) + '\n' + e.getStackTraceString(),
			                                InputPayload__c = 'fieldLabel: ' + fieldLabel + ', fieldValue: ' + fieldValue + ', otherFields: ' + otherFields + ', targetObj: ' + targetObj + ', value: ' + value + ', valuesToExclude: ' + valuesToExclude
			);
			EventBus.publish(l);
			//throw new AuraHandledException(Ex.getReadableMessage(e));
			throw new AuraHandledException('Errore: riprovare o contattare servizio clienti.');
		}
	}

	@AuraEnabled
	public static Map<String, String> getPicklistMap(String fieldName, String objectName) {
		try {
			return ExtSfdcLookup.getPicklistMap(fieldName, objectName);
		} catch(Exception e) {
			AsyncLog__e l = new AsyncLog__e(
			                                Source__c = 'TiAnticipo',
			                                CodiceFunzione__c = 'ExtSfdcLookup.getPicklistMap',
			                                ErrorMessage__c = Ex.getReadableMessage(e) + '\n' + e.getStackTraceString(),
			                                InputPayload__c = 'fieldName: ' + fieldName + ', objectName: ' + objectName
			);
			EventBus.publish(l);
			//throw new AuraHandledException(Ex.getReadableMessage(e));
			throw new AuraHandledException('Errore: riprovare o contattare servizio clienti.');
		}
	}

	@AuraEnabled
	public static Boolean addContactAllegato(String contact, String file) {
		try {
			return TaCtrlRegistrazioneUtenti.addContactAllegato(contact, file);
		} catch(Exception e) {
			//qui potremo arrivarci per errori tecnici, p.e. errore rete
			//ma anche per errore leciti, p.e. contatto duplicato o CF non valido
			AsyncLog__e l = new AsyncLog__e(
			                                Source__c = 'TiAnticipo',
			                                CodiceFunzione__c = 'TaCtrlRegistrazioneUtenti.addContactAllegato',
			                                ErrorMessage__c = Ex.getReadableMessage(e) + '\n' + e.getStackTraceString(),
			                                InputPayload__c = 'CONTACT: '+contact+' --- User: '+UserInfo.getName()+', User Id: '+UserInfo.getUserId()
			);
			EventBus.publish(l);
			throw new AuraHandledException(Ex.getReadableMessage(e));
		}
	}

	@AuraEnabled
	public static Boolean aggiungiAttore(String idCessione, String idReferente, String tipo) {
		try {
			return TaCtrlRegistrazioneUtenti.aggiungiAttore(idCessione, idReferente, tipo);
		} catch(Exception e) {
			AsyncLog__e l = new AsyncLog__e(
			                                Source__c = 'TiAnticipo',
			                                CodiceFunzione__c = 'TaCtrlRegistrazioneUtenti.aggiungiAttore',
			                                ErrorMessage__c = Ex.getReadableMessage(e) + '\n' + e.getStackTraceString(),
			                                InputPayload__c = 'Cessione: ' + idCessione + ', Referente: ' + idReferente + ', Tipo: ' + tipo+' --- User: '+UserInfo.getName()+', User Id: '+UserInfo.getUserId()
			);
			EventBus.publish(l);
			throw new AuraHandledException('Errore: riprovare o contattare servizio clienti.');
		}
	}

	@AuraEnabled
	public static Boolean removeContact(String idContact) {
		try {
			return TaCtrlRegistrazioneUtenti.removeContact(idContact);
		} catch(Exception e) {
			AsyncLog__e l = new AsyncLog__e(
			                                Source__c = 'TiAnticipo',
			                                CodiceFunzione__c = 'TaCtrlRegistrazioneUtenti.removeContact',
			                                ErrorMessage__c = Ex.getReadableMessage(e) + '\n' + e.getStackTraceString(),
			                                InputPayload__c = 'Contact: ' + idContact+' --- User: '+UserInfo.getName()+', User Id: '+UserInfo.getUserId()
			);
			EventBus.publish(l);
			//throw new AuraHandledException(Ex.getReadableMessage(e));
			throw new AuraHandledException('Errore: riprovare o contattare servizio clienti.');
		}
	}

	@AuraEnabled
	public static Boolean rimuoviAttore(String idCessione, String idReferente, String tipo) {
		try {
			return TaCtrlRegistrazioneUtenti.rimuoviAttore(idCessione, idReferente, tipo);
		} catch(Exception e) {
			AsyncLog__e l = new AsyncLog__e(
			                                Source__c = 'TiAnticipo',
			                                CodiceFunzione__c = 'TaCtrlRegistrazioneUtenti.rimuoviAttore',
			                                ErrorMessage__c = Ex.getReadableMessage(e) + '\n' + e.getStackTraceString(),
			                                InputPayload__c = 'Cessione: ' + idCessione + ', Referente: ' + idReferente + ', Tipo: ' + tipo+' --- User: '+UserInfo.getName()+', User Id: '+UserInfo.getUserId()
			);
			EventBus.publish(l);
			//throw new AuraHandledException(Ex.getReadableMessage(e));
			throw new AuraHandledException('Errore: riprovare o contattare servizio clienti.');
		}
	}

	@AuraEnabled
	public static NDGLinea__c[] fetchAttoriCessione(String idCessione) {
		try {
			return TaCtrlRegistrazioneUtenti.fetchAttoriCessione(idCessione);
		} catch(Exception e) {
			AsyncLog__e l = new AsyncLog__e(
			                                Source__c = 'TiAnticipo',
			                                CodiceFunzione__c = 'TaCtrlRegistrazioneUtenti.fetchAttoriCessione',
			                                ErrorMessage__c = Ex.getReadableMessage(e) + '\n' + e.getStackTraceString(),
			                                InputPayload__c = 'idCessione: ' + idCessione
			);
			EventBus.publish(l);
			//throw new AuraHandledException(Ex.getReadableMessage(e));
			throw new AuraHandledException('Errore: riprovare o contattare servizio clienti.');
		}
	}

	@AuraEnabled
	public static Boolean modifyContactAllegato(String contact, String file, String idCessione) {
		try {
			return TaCtrlRegistrazioneUtenti.modifyContactAllegato(contact, file, idCessione);
		} catch(Exception e) {
			AsyncLog__e l = new AsyncLog__e(
			                                Source__c = 'TiAnticipo',
			                                CodiceFunzione__c = 'TaCtrlRegistrazioneUtenti.modifyContactAllegato',
			                                ErrorMessage__c = Ex.getReadableMessage(e) + '\n' + e.getStackTraceString(),
			                                InputPayload__c = 'Cessione: ' + idCessione + ', Contact: ' + contact+' --- User: '+UserInfo.getName()+', User Id: '+UserInfo.getUserId()
			);
			EventBus.publish(l);
			//throw new AuraHandledException(Ex.getReadableMessage(e));
			throw new AuraHandledException('Errore: riprovare o contattare servizio clienti.');
		}
	}

	@AuraEnabled
	public static Cessione__c[] fetchCessioni() {
		try {
			return TaCtrlDettaglio.fetchCessioni();
		} catch(Exception e) {
			AsyncLog__e l = new AsyncLog__e(
			                                Source__c = 'TiAnticipo',
			                                CodiceFunzione__c = 'TaCtrlDettaglio.fetchCessioni',
			                                ErrorMessage__c = Ex.getReadableMessage(e) + '\n' + e.getStackTraceString()
			);
			EventBus.publish(l);
			//throw new AuraHandledException(Ex.getReadableMessage(e));
			throw new AuraHandledException('Errore: riprovare o contattare servizio clienti.');
		}
	}

	@AuraEnabled
	public static Anomalia__c[] fetchAnomalie() {
		try {
			return TaCtrlDettaglio.fetchAnomalie();
		} catch(Exception e) {
			AsyncLog__e l = new AsyncLog__e(
			                                Source__c = 'TiAnticipo',
			                                CodiceFunzione__c = 'TaCtrlDettaglio.fetchAnomalie',
			                                ErrorMessage__c = Ex.getReadableMessage(e) + '\n' + e.getStackTraceString()+' --- User: '+UserInfo.getName()+', User Id: '+UserInfo.getUserId()
			);
			EventBus.publish(l);
			//throw new AuraHandledException(Ex.getReadableMessage(e));
			throw new AuraHandledException('Errore: riprovare o contattare servizio clienti.');
		}
	}

	@AuraEnabled
	public static Boolean setReadedMessage(String idAnomalia) {
		try {
			return TaCtrlDettaglio.setReadedMessage(idAnomalia);
		} catch(Exception e) {
			AsyncLog__e l = new AsyncLog__e(
			                                Source__c = 'TiAnticipo',
			                                CodiceFunzione__c = 'TaCtrlDettaglio.setReadMessage',
			                                ErrorMessage__c = Ex.getReadableMessage(e) + '\n' + e.getStackTraceString(),
			                                InputPayload__c = 'idAnomalia: ' + idAnomalia
			);
			EventBus.publish(l);
			//throw new AuraHandledException(Ex.getReadableMessage(e));
			throw new AuraHandledException('Errore: riprovare o contattare servizio clienti.');
		}
	}

	@AuraEnabled
	public static TaCtrlDettaglio.DettaglioCessione fetchCessione(Id idCessione) {
		try {
			return TaCtrlDettaglio.fetchCessione(idCessione);
		} catch(Exception e) {
			AsyncLog__e l = new AsyncLog__e(
			                                Source__c = 'TiAnticipo',
			                                CodiceFunzione__c = 'TaCtrlDettaglio.fetchCessione',
			                                ErrorMessage__c = Ex.getReadableMessage(e) + '\n' + e.getStackTraceString(),
			                                InputPayload__c = 'idCessione: ' + idCessione
			);
			EventBus.publish(l);
			//throw new AuraHandledException(Ex.getReadableMessage(e));
			throw new AuraHandledException('Errore: riprovare o contattare servizio clienti.');
		}
	}

	@AuraEnabled
	public static void popolaUltimoAccesso(Id idCessione) {
		try {
			TaCtrlDettaglio.popolaUltimoAccesso(idCessione);
		} catch(Exception e) {
			AsyncLog__e l = new AsyncLog__e(
			                                Source__c = 'TiAnticipo',
			                                CodiceFunzione__c = 'TaCtrlDettaglio.popolaUltimoAccesso',
			                                ErrorMessage__c = Ex.getReadableMessage(e) + '\n' + e.getStackTraceString(),
			                                InputPayload__c = 'idCessione: ' + idCessione
			);
			EventBus.publish(l);
			//throw new AuraHandledException(Ex.getReadableMessage(e));
			throw new AuraHandledException('Errore: riprovare o contattare servizio clienti.');
		}
	}

	@AuraEnabled
	public static Contact[] fetchContacts() {
		try {
			return TaCtrlRegistrazioneUtenti.fetchContacts();
		} catch(Exception e) {
			AsyncLog__e l = new AsyncLog__e(
			                                Source__c = 'TiAnticipo',
			                                CodiceFunzione__c = 'TaCtrlRegistrazioneUtenti.fetchContacts',
			                                ErrorMessage__c = Ex.getReadableMessage(e) + '\n' + e.getStackTraceString()
			);
			EventBus.publish(l);
			//throw new AuraHandledException(Ex.getReadableMessage(e));
			throw new AuraHandledException('Errore: riprovare o contattare servizio clienti.');
		}
	}

	@AuraEnabled
	public static TaCtrlLogin.ProfileInfo fetchProfile() {
		try {
			return TaCtrlLogin.fetchProfile();
		} catch(Exception e) {
			AsyncLog__e l = new AsyncLog__e(
			                                Source__c = 'TiAnticipo',
			                                CodiceFunzione__c = 'TaCtrlLogin.fetchProfile',
			                                ErrorMessage__c = Ex.getReadableMessage(e) + '\n' + e.getStackTraceString()
			);
			EventBus.publish(l);
			//throw new AuraHandledException(Ex.getReadableMessage(e));
			throw new AuraHandledException('Errore: riprovare o contattare servizio clienti.');
		}
	}

	@AuraEnabled
	public static Boolean updateProfile(String input) {
		try {
			return TaCtrlLogin.updateProfile(input);
		} catch(Exception e) {
			AsyncLog__e l = new AsyncLog__e(
			                                Source__c = 'TiAnticipo',
			                                CodiceFunzione__c = 'TaCtrlLogin.updateProfile',
			                                ErrorMessage__c = Ex.getReadableMessage(e) + '\n' + e.getStackTraceString(),
			                                InputPayload__c = (input+' --- User: '+UserInfo.getName()+', User Id: '+UserInfo.getUserId()).abbreviate(MAX_LENGTH)
			);
			EventBus.publish(l);
			//throw new AuraHandledException(Ex.getReadableMessage(e));
			throw new AuraHandledException('Errore: riprovare o contattare servizio clienti.');
		}
	}

	@AuraEnabled
	public static TaCtrlDettaglio.DettaglioCessione upsertCessione(String cessione) {
		try {
			return TaCtrlDettaglio.upsertCessione(cessione);
		} catch(Exception e) {
			AsyncLog__e l = new AsyncLog__e(
			                                Source__c = 'TiAnticipo',
			                                CodiceFunzione__c = 'TaCtrlDettaglio.upsertCessione',
			                                ErrorMessage__c = Ex.getReadableMessage(e) + '\n' + e.getStackTraceString(),
			                                InputPayload__c = cessione.abbreviate(MAX_LENGTH)
			);
			EventBus.publish(l);
			//throw new AuraHandledException(Ex.getReadableMessage(e));
			throw new AuraHandledException('Errore: riprovare o contattare servizio clienti.');
		}
	}

	@AuraEnabled
	public static void documentiPrivacyCaricati(Id idCessione) {
		try {
			TaCtrlDocumentazione.documentiPrivacyCaricati(idCessione);
		} catch(Exception e) {
			AsyncLog__e l = new AsyncLog__e(
			                                Source__c = 'TiAnticipo',
			                                CodiceFunzione__c = 'TaCtrlDocumentazione.documentiPrivacyCaricati',
			                                ErrorMessage__c = Ex.getReadableMessage(e) + '\n' + e.getStackTraceString(),
			                                InputPayload__c = 'idCessione: ' + idCessione+' --- User: '+UserInfo.getName()+', User Id: '+UserInfo.getUserId()
			);
			EventBus.publish(l);
			//throw new AuraHandledException(Ex.getReadableMessage(e));
			throw new AuraHandledException('Errore: riprovare o contattare servizio clienti.');
		}
	}

	@AuraEnabled
	public static TaCtrlDocumentazione.InfoDocUpload getDocumentiUpload(Id idCessione) {
		try {
			return TaCtrlDocumentazione.getDocumentiUpload(idCessione);
		} catch(Exception e) {
			AsyncLog__e l = new AsyncLog__e(
			                                Source__c = 'TiAnticipo',
			                                CodiceFunzione__c = 'TaCtrlDocumentazione.getDocumentiUpload',
			                                ErrorMessage__c = Ex.getReadableMessage(e) + '\n' + e.getStackTraceString(),
			                                InputPayload__c = 'idCessione: ' + idCessione
			);
			EventBus.publish(l);
			//throw new AuraHandledException(Ex.getReadableMessage(e));
			throw new AuraHandledException('Errore: riprovare o contattare servizio clienti.');
		}
	}

	@AuraEnabled
	public static TaCtrlDocumentazione.InfoDoc[] getDocumentiAnomali(Id idCessione) {
		try {
			return TaCtrlDocumentazione.getDocumentiAnomali(idCessione);
		} catch(Exception e) {
			AsyncLog__e l = new AsyncLog__e(
			                                Source__c = 'TiAnticipo',
			                                CodiceFunzione__c = 'TaCtrlDocumentazione.getDocumentiAnomali',
			                                ErrorMessage__c = Ex.getReadableMessage(e) + '\n' + e.getStackTraceString(),
			                                InputPayload__c = 'idCessione: ' + idCessione
			);
			EventBus.publish(l);
			//throw new AuraHandledException(Ex.getReadableMessage(e));
			throw new AuraHandledException('Errore: riprovare o contattare servizio clienti.');
		}
	}

	@AuraEnabled
	public static Boolean chiudiAnomalia(Id idAnomalia) {
		try {
			return TaCtrlDocumentazione.chiudiAnomalia(idAnomalia);
		} catch(Exception e) {
			AsyncLog__e l = new AsyncLog__e(
			                                Source__c = 'TiAnticipo',
			                                CodiceFunzione__c = 'TaCtrlDocumentazione.chiudiAnomalia',
			                                ErrorMessage__c = Ex.getReadableMessage(e) + '\n' + e.getStackTraceString(),
			                                InputPayload__c = 'idAnomalia: ' + idAnomalia
			);
			EventBus.publish(l);
			//throw new AuraHandledException(Ex.getReadableMessage(e));
			throw new AuraHandledException('Errore: riprovare o contattare servizio clienti.');
		}
	}

	@AuraEnabled
	public static Boolean deleteDocument(Id contentVersionId) {
		try {
			return TaCtrlDocumentazione.deleteDocument(contentVersionId);
		} catch(Exception e) {
			AsyncLog__e l = new AsyncLog__e(
			                                Source__c = 'TiAnticipo',
			                                CodiceFunzione__c = 'TaCtrlDocumentazione.deleteDocument',
			                                ErrorMessage__c = Ex.getReadableMessage(e) + '\n' + e.getStackTraceString(),
			                                InputPayload__c = 'contentVersionId: ' + contentVersionId
			);
			EventBus.publish(l);
			//throw new AuraHandledException(Ex.getReadableMessage(e));
			throw new AuraHandledException('Errore: riprovare o contattare servizio clienti.');
		}
	}

    
	@AuraEnabled
	public static String getFoglioInformativoDownload() {
		try {
			return TaCtrlDocumentazione.getFoglioInformativoDownload();
		} catch(Exception e) {
			AsyncLog__e l = new AsyncLog__e(
			                                Source__c = 'TiAnticipo',
			                                CodiceFunzione__c = 'TaCtrlDocumentazione.getFoglioInformativoDownload',
			                                ErrorMessage__c = Ex.getReadableMessage(e) + '\n' + e.getStackTraceString()
			);
			EventBus.publish(l);
			//throw new AuraHandledException(Ex.getReadableMessage(e));
			throw new AuraHandledException('Errore: riprovare o contattare servizio clienti.');
		}
	}
    
	@AuraEnabled
	public static TaCtrlDocumentazione.InfoDoc[] getDocumentiDownload(Id cessioneId) {
		try {
			return TaCtrlDocumentazione.getDocumentiDownload(cessioneId);
		} catch(Exception e) {
			AsyncLog__e l = new AsyncLog__e(
			                                Source__c = 'TiAnticipo',
			                                CodiceFunzione__c = 'TaCtrlDocumentazione.getDocumentiDownload',
			                                ErrorMessage__c = Ex.getReadableMessage(e) + '\n' + e.getStackTraceString(),
			                                InputPayload__c = 'cessioneId: ' + cessioneId+' --- User: '+UserInfo.getName()+', User Id: '+UserInfo.getUserId()
			);
			EventBus.publish(l);
			//throw new AuraHandledException(Ex.getReadableMessage(e));
			throw new AuraHandledException('Errore: riprovare o contattare servizio clienti.');
		}
	}

	@AuraEnabled
	public static TaCtrlDocumentazione.InfoDoc[] getDocumentiDinamiciDownload(String[] codici) {
		try {
			return TaCtrlDocumentazione.getDocumentiDinamiciDownload(codici);
		} catch(Exception e) {
			AsyncLog__e l = new AsyncLog__e(
			                                Source__c = 'TiAnticipo',
			                                CodiceFunzione__c = 'TaCtrlDocumentazione.getDocumentiDinamiciDownload',
			                                ErrorMessage__c = Ex.getReadableMessage(e) + '\n' + e.getStackTraceString(),
			                                InputPayload__c = 'codici: ' + codici+' --- User: '+UserInfo.getName()+', User Id: '+UserInfo.getUserId()
			);
			EventBus.publish(l);
			//throw new AuraHandledException(Ex.getReadableMessage(e));
			throw new AuraHandledException('Errore: riprovare o contattare servizio clienti.');
		}
	}

	@AuraEnabled
	public static String[] fetchStatiEsteri() {
		try {
			return ExtSfdcLookup.fetchStatiEsteri();
		} catch(Exception e) {
			AsyncLog__e l = new AsyncLog__e(
			                                Source__c = 'TiAnticipo',
			                                CodiceFunzione__c = 'ExtSfdcLookup.fetchStatiEsteri',
			                                ErrorMessage__c = Ex.getReadableMessage(e) + '\n' + e.getStackTraceString()
			);
			EventBus.publish(l);
			//throw new AuraHandledException(Ex.getReadableMessage(e));
			throw new AuraHandledException('Errore: riprovare o contattare servizio clienti.');
		}
	}

	@AuraEnabled
	public static Comune__c[] fetchStatiEsteriFull() {
		try {
			return ExtSfdcLookup.fetchStatiEsteriFull();
		} catch(Exception e) {
			AsyncLog__e l = new AsyncLog__e(
			                                Source__c = 'TiAnticipo',
			                                CodiceFunzione__c = 'ExtSfdcLookup.fetchStatiEsteriFull',
			                                ErrorMessage__c = Ex.getReadableMessage(e) + '\n' + e.getStackTraceString()
			);
			EventBus.publish(l);
			//throw new AuraHandledException(Ex.getReadableMessage(e));
			throw new AuraHandledException('Errore: riprovare o contattare servizio clienti.');
		}
	}

	@AuraEnabled
	public static String searchCodiceCatastaleComune(String city, String state) {
		try {
			return ExtSfdcLookup.searchCodiceCatastaleComune(city, state);
		} catch(Exception e) {
			AsyncLog__e l = new AsyncLog__e(
			                                Source__c = 'TiAnticipo',
			                                CodiceFunzione__c = 'ExtSfdcLookup.searchCodiceCatastaleComune',
			                                ErrorMessage__c = Ex.getReadableMessage(e) + '\n' + e.getStackTraceString(),
			                                InputPayload__c = 'city: ' + city + ', state: ' + state
			);
			EventBus.publish(l);
			//throw new AuraHandledException(Ex.getReadableMessage(e));
			throw new AuraHandledException('Errore: riprovare o contattare servizio clienti.');
		}
	}

	@AuraEnabled
	public static Account[] taSearchAnagrafica(String piva, String platform) {
		try {
			CtrlWizardAccount.InputObj inputObj = new CtrlWizardAccount.InputObj(piva, null, null, 'piva', false);
			return CtrlWizardAccount.searchAnagrafica(inputObj, platform);
		} catch(Exception e) {
			AsyncLog__e l = new AsyncLog__e(
			                                Source__c = 'TiAnticipo',
			                                CodiceFunzione__c = 'CtrlWizardAccount.searchAnagrafica',
			                                ErrorMessage__c = Ex.getReadableMessage(e) + '\n' + e.getStackTraceString(),
			                                InputPayload__c = 'P.IVA: ' + piva + ', platform: ' + platform
			);
			EventBus.publish(l);
			//throw new AuraHandledException(Ex.getReadableMessage(e));
			throw new AuraHandledException('Errore: riprovare o contattare servizio clienti.');
		}
	}

	@AuraEnabled
	public static Boolean salvaAllegatoCessione(String codiceDocumento, String famigliaDocumento, String idAttachment, String idCessione, String tipo) {
		try {
			return TaCtrlDocumentazione.salvaAllegatoCessione(codiceDocumento, famigliaDocumento, idAttachment, idCessione, tipo);
		} catch(Exception e) {
			AsyncLog__e l = new AsyncLog__e(
			                                Source__c = 'TiAnticipo',
			                                CodiceFunzione__c = 'TaCtrlDocumentazione.salvaAllegatoCessione',
			                                ErrorMessage__c = Ex.getReadableMessage(e) + '\n' + e.getStackTraceString(),
			                                InputPayload__c = 'cod doc: ' + codiceDocumento + ', famiglia: ' + famigliaDocumento + ', tipo: ' + tipo + ', idAttachment :' + idAttachment + ', cessione: ' + idCessione+' --- User: '+UserInfo.getName()+', User Id: '+UserInfo.getUserId()
			);
			EventBus.publish(l);
			//throw new AuraHandledException(Ex.getReadableMessage(e));
			throw new AuraHandledException('Errore: riprovare o contattare servizio clienti.');
		}
	}

	@AuraEnabled
	public static Boolean salvaCertificazione(String idAttachment, String idCessione) {
		try {
			return TaCtrlDocumentazione.salvaCertificazione(idAttachment, idCessione);
		} catch(Exception e) {
			AsyncLog__e l = new AsyncLog__e(
			                                Source__c = 'TiAnticipo',
			                                CodiceFunzione__c = 'TaCtrlDocumentazione.salvaCertificazione',
			                                ErrorMessage__c = Ex.getReadableMessage(e) + '\n' + e.getStackTraceString(),
			                                InputPayload__c = 'idAttachment :' + idAttachment + ', cessione: ' + idCessione+' --- User: '+UserInfo.getName()+', User Id: '+UserInfo.getUserId()
			);
			EventBus.publish(l);
			//quasi sempre l'errore non è tecnico relativo al file caricato dal cliente
			//per cui mostriamo il messaggio d'errore previsto
			throw new AuraHandledException(Ex.getReadableMessage(e));
		}
	}

	@AuraEnabled
	public static TaCtrlDettaglio.UploadCertificazioneInfo associaDebitoriCertificazioni(Certificazione__c[] certificazioni) {
		try {
			return TaCtrlDettaglio.associaDebitoriCertificazioni(certificazioni);
		} catch(Exception e) {
			AsyncLog__e l = new AsyncLog__e(
			                                Source__c = 'TiAnticipo',
			                                CodiceFunzione__c = 'TaCtrlDettaglio.associaDebitoriCertificazioni',
			                                ErrorMessage__c = Ex.getReadableMessage(e) + '\n' + e.getStackTraceString(),
			                                InputPayload__c = 'certificazioni: ' + certificazioni+' --- User: '+UserInfo.getName()+', User Id: '+UserInfo.getUserId()
			);
			EventBus.publish(l);
			//errore su dati fatture o certificazione: mostriamo messaggio all'utente
			throw new AuraHandledException(Ex.getReadableMessage(e));
		}
	}

	@AuraEnabled
	public static Fattura__c[] fetchFatture(String idCessione) {
		try {
			return TaCtrlDettaglio.fetchFatture(idCessione);
		} catch(Exception e) {
			AsyncLog__e l = new AsyncLog__e(
			                                Source__c = 'TiAnticipo',
			                                CodiceFunzione__c = 'TaCtrlDettaglio.fetchFatture',
			                                ErrorMessage__c = Ex.getReadableMessage(e) + '\n' + e.getStackTraceString(),
			                                InputPayload__c = 'idCessione: ' + idCessione
			);
			EventBus.publish(l);
			//throw new AuraHandledException(Ex.getReadableMessage(e));
			throw new AuraHandledException('Errore: riprovare o contattare servizio clienti.');
		}
	}

	@AuraEnabled
	public static Cessione__c fetchPreventivoCorretto(String idCessione, Boolean retryCalcoloSeNecessario) {
		try {
			return TaCtrlDettaglio.fetchPreventivoCorretto(idCessione, retryCalcoloSeNecessario);
		} catch(Exception e) {
			AsyncLog__e l = new AsyncLog__e(
			                                Source__c = 'TiAnticipo',
			                                CodiceFunzione__c = 'TaCtrlDettaglio.fetchPreventivoCorretto',
			                                ErrorMessage__c = Ex.getReadableMessage(e) + '\n' + e.getStackTraceString(),
			                                InputPayload__c = 'idCessione: ' + idCessione + ', retryCalcoloSeNecessario: ' + retryCalcoloSeNecessario
			);
			EventBus.publish(l);
			//throw new AuraHandledException(Ex.getReadableMessage(e));
			throw new AuraHandledException('Errore: riprovare o contattare servizio clienti.');
		}
	}

	@AuraEnabled
	public static Boolean updateFatture(String input) {
		try {
			return TaCtrlDettaglio.updateFatture(input);
		} catch(Exception e) {
			AsyncLog__e l = new AsyncLog__e(
			                                Source__c = 'TiAnticipo',
			                                CodiceFunzione__c = 'TaCtrlDettaglio.updateFatture',
			                                ErrorMessage__c = Ex.getReadableMessage(e) + '\n' + e.getStackTraceString(),
			                                InputPayload__c = input.abbreviate(MAX_LENGTH)
			);
			EventBus.publish(l);
			//throw new AuraHandledException(Ex.getReadableMessage(e));
			throw new AuraHandledException('Errore: riprovare o contattare servizio clienti.');
		}
	}

	@AuraEnabled
	public static Boolean deleteCertificazione(String idCertificazione) {
		try {
			return TaCtrlDettaglio.deleteCertificazione(idCertificazione);
		} catch(Exception e) {
			AsyncLog__e l = new AsyncLog__e(
			                                Source__c = 'TiAnticipo',
			                                CodiceFunzione__c = 'TaCtrlDettaglio.deleteCertificazione',
			                                ErrorMessage__c = Ex.getReadableMessage(e) + '\n' + e.getStackTraceString(),
			                                InputPayload__c = 'idCertificazione: ' + idCertificazione
			);
			EventBus.publish(l);
			//throw new AuraHandledException(Ex.getReadableMessage(e));
			throw new AuraHandledException('Errore: riprovare o contattare servizio clienti.');
		}
	}

	@AuraEnabled
	public static Certificazione__c[] fetchCertificazioniFatture(String idCessione) {
		try {
			return TaCtrlDettaglio.fetchCertificazioniFatture(idCessione);
		} catch(Exception e) {
			AsyncLog__e l = new AsyncLog__e(
			                                Source__c = 'TiAnticipo',
			                                CodiceFunzione__c = 'TaCtrlDettaglio.fetchCertificazioniFatture',
			                                ErrorMessage__c = Ex.getReadableMessage(e) + '\n' + e.getStackTraceString(),
			                                InputPayload__c = 'idCessione: ' + idCessione
			);
			EventBus.publish(l);
			//throw new AuraHandledException(Ex.getReadableMessage(e));
			throw new AuraHandledException('Errore: riprovare o contattare servizio clienti.');
		}
	}

	@AuraEnabled
	public static TaCtrlDettaglio.UploadCertificazioneInfo fetchUploadCertificazioneInfo(String idCessione) {
		try {
			return TaCtrlDettaglio.fetchUploadCertificazioneInfo(idCessione);
		} catch(Exception e) {
			AsyncLog__e l = new AsyncLog__e(
			                                Source__c = 'TiAnticipo',
			                                CodiceFunzione__c = 'TaCtrlDettaglio.fetchUploadCertificazioneInfo',
			                                ErrorMessage__c = Ex.getReadableMessage(e) + '\n' + e.getStackTraceString(),
			                                InputPayload__c = 'idCessione: ' + idCessione
			);
			EventBus.publish(l);
			//throw new AuraHandledException(Ex.getReadableMessage(e));
			throw new AuraHandledException('Errore: riprovare o contattare servizio clienti.');
		}
	}

	@AuraEnabled
	public static String generaDocumentazioneTa(Id idOpportunity, String tipo) {
		try {
			return TaCtrlDocumentazione.generaDocumentazione(idOpportunity, tipo);
		} catch(Exception e) {
			AsyncLog__e l = new AsyncLog__e(
			                                Source__c = 'TiAnticipo',
			                                CodiceFunzione__c = 'TaCtrlDocumentazione.generaDocumentazione',
			                                ErrorMessage__c = Ex.getReadableMessage(e) + '\n' + e.getStackTraceString(),
			                                InputPayload__c = 'idOpportunity: ' + idOpportunity + ', tipo' + tipo+' --- User: '+UserInfo.getName()+', User Id: '+UserInfo.getUserId()
			);
			EventBus.publish(l);
			//throw new AuraHandledException(Ex.getReadableMessage(e));
			throw new AuraHandledException('Errore: riprovare o contattare servizio clienti.');
		}
	}

	@AuraEnabled
	public static String[] generaDocumentazioneStaticaTa() {
		try {
			return TaCtrlDocumentazione.generaDocumentazioneStatica();
		} catch(Exception e) {
			AsyncLog__e l = new AsyncLog__e(
			                                Source__c = 'TiAnticipo',
			                                CodiceFunzione__c = 'TaCtrlDocumentazione.generaDocumentazioneStaticaTa',
			                                ErrorMessage__c = Ex.getReadableMessage(e) + '\n' + e.getStackTraceString()+' --- User: '+UserInfo.getName()+', User Id: '+UserInfo.getUserId()
			);
			EventBus.publish(l);
			//throw new AuraHandledException(Ex.getReadableMessage(e));
			throw new AuraHandledException('Errore: riprovare o contattare servizio clienti.');
		}
	}

	@AuraEnabled
	public static TestiTa__c[] fetchFAQ() {
		try {
			return TaCtrlTesti.fetchFAQ();
		} catch(Exception e) {
			AsyncLog__e l = new AsyncLog__e(
			                                Source__c = 'TiAnticipo',
			                                CodiceFunzione__c = 'TaCtrlTesti.fetchFAQ',
			                                ErrorMessage__c = Ex.getReadableMessage(e) + '\n' + e.getStackTraceString()
			);
			EventBus.publish(l);
			//throw new AuraHandledException(Ex.getReadableMessage(e));
			throw new AuraHandledException('Errore: riprovare o contattare servizio clienti.');
		}
	}

	@AuraEnabled
	public static TaCtrlLogin.UserInfoObj getUserInfo() {
		try {
			return TaCtrlLogin.getUserInfo();
		} catch(Exception e) {
			AsyncLog__e l = new AsyncLog__e(
			                                Source__c = 'TiAnticipo',
			                                CodiceFunzione__c = 'TaCtrlLogin.getUserInfo',
			                                ErrorMessage__c = Ex.getReadableMessage(e) + '\n' + e.getStackTraceString(),
			                                InputPayload__c = 'Name: ' + UserInfo.getName() + ', userId: ' + UserInfo.getUserId()
			);
			EventBus.publish(l);
			//throw new AuraHandledException(Ex.getReadableMessage(e));
			throw new AuraHandledException('Errore: riprovare o contattare servizio clienti.');
		}
	}

	@AuraEnabled
	public static Ateco__c[] fetchAteco() {
		try {
			return CtrlWizardAccount.fetchAteco();
		} catch(Exception e) {
			AsyncLog__e l = new AsyncLog__e(
			                                Source__c = 'TiAnticipo',
			                                CodiceFunzione__c = 'CtrlWizardAccount.fetchAteco',
			                                ErrorMessage__c = Ex.getReadableMessage(e) + '\n' + e.getStackTraceString()
			);
			EventBus.publish(l);
			//throw new AuraHandledException(Ex.getReadableMessage(e));
			throw new AuraHandledException('Errore: riprovare o contattare servizio clienti.');
		}
	}

	@AuraEnabled
	public static NaturaGiuridicaSAE__mdt[] fetchRelazioneNgSae() {
		try {
			return CtrlWizardAccount.fetchRelazioneNgSae();
		} catch(Exception e) {
			AsyncLog__e l = new AsyncLog__e(
			                                Source__c = 'TiAnticipo',
			                                CodiceFunzione__c = 'CtrlWizardAccount.fetchRelazioneNgSae',
			                                ErrorMessage__c = Ex.getReadableMessage(e) + '\n' + e.getStackTraceString()
			);
			EventBus.publish(l);
			//throw new AuraHandledException(Ex.getReadableMessage(e));
			throw new AuraHandledException('Errore: riprovare o contattare servizio clienti.');
		}
	}

	@AuraEnabled
	public static Boolean updatePrivacy(SObject obj, String oppCess) {
		try {
			return CtrlWizardOpportunity.updatePrivacy(obj, oppCess);
		} catch(Exception e) {
			AsyncLog__e l = new AsyncLog__e(
			                                Source__c = 'TiAnticipo',
			                                CodiceFunzione__c = 'CtrlWizardOpportunity.updatePrivacy',
			                                ErrorMessage__c = Ex.getReadableMessage(e) + '\n' + e.getStackTraceString(),
			                                InputPayload__c = ('oppCess: ' + oppCess + ', obj input: ' + obj+' --- User: '+UserInfo.getName()+', User Id: '+UserInfo.getUserId()).abbreviate(MAX_LENGTH)
			);
			EventBus.publish(l);
			//throw new AuraHandledException(Ex.getReadableMessage(e));
			throw new AuraHandledException('Errore: riprovare o contattare servizio clienti.');
		}
	}

	@AuraEnabled
	public static Opportunity fetchPrivacyCompilata(String idCessione) {
		try {
			return CtrlWizardOpportunity.fetchPrivacyCompilata(idCessione);
		} catch(Exception e) {
			AsyncLog__e l = new AsyncLog__e(
			                                Source__c = 'TiAnticipo',
			                                CodiceFunzione__c = 'CtrlWizardOpportunity.fetchPrivacyCompilata',
			                                ErrorMessage__c = Ex.getReadableMessage(e) + '\n' + e.getStackTraceString(),
			                                InputPayload__c = 'idCessione: ' + idCessione+' --- User: '+UserInfo.getName()+', User Id: '+UserInfo.getUserId()
			);
			EventBus.publish(l);
			//throw new AuraHandledException(Ex.getReadableMessage(e));
			throw new AuraHandledException('Errore: riprovare o contattare servizio clienti.');
		}
	}

	@AuraEnabled
	public static Map<String, SObject> fetchInfograficheTiAnticipo() {
		try {
			return CtrlWizardOpportunity.fetchInfograficheTiAnticipo();
		} catch(Exception e) {
			AsyncLog__e l = new AsyncLog__e(
			                                Source__c = 'TiAnticipo',
			                                CodiceFunzione__c = 'CtrlWizardOpportunity.fetchInfograficheTiAnticipo',
			                                ErrorMessage__c = Ex.getReadableMessage(e) + '\n' + e.getStackTraceString()
			);
			EventBus.publish(l);
			//throw new AuraHandledException(Ex.getReadableMessage(e));
			throw new AuraHandledException('Errore: riprovare o contattare servizio clienti.');
		}
	}

	@AuraEnabled
	public static Id fetchAttorePrivacy(String objType, Id oppId) {
		try {
			return CtrlWizardOpportunity.fetchAttorePrivacy(objType, oppId);
		} catch(Exception e) {
			AsyncLog__e l = new AsyncLog__e(
			                                Source__c = 'TiAnticipo',
			                                CodiceFunzione__c = 'CtrlWizardOpportunity.fetchAttorePrivacy',
			                                ErrorMessage__c = Ex.getReadableMessage(e) + '\n' + e.getStackTraceString(),
			                                InputPayload__c = 'oppId: ' + oppId + ', objType: ' + objType+' --- User: '+UserInfo.getName()+', User Id: '+UserInfo.getUserId()
			);
			EventBus.publish(l);
			//throw new AuraHandledException(Ex.getReadableMessage(e));
			throw new AuraHandledException('Errore: riprovare o contattare servizio clienti.');
		}
	}

	@AuraEnabled
	public static Boolean editNomeCessione(Id idCessione, String nomeCessione) {
		try {
			return TaCtrlDettaglio.editNomeCessione(idCessione, nomeCessione);
		} catch(Exception e) {
			AsyncLog__e l = new AsyncLog__e(
			                                Source__c = 'TiAnticipo',
			                                CodiceFunzione__c = 'TaCtrlDettaglio.editNomeCessione',
			                                ErrorMessage__c = Ex.getReadableMessage(e) + '\n' + e.getStackTraceString(),
			                                InputPayload__c = 'idCessione: ' + idCessione + ', nomeCessione:' + nomeCessione
			);
			EventBus.publish(l);
			//throw new AuraHandledException(Ex.getReadableMessage(e));
			throw new AuraHandledException('Errore: riprovare o contattare servizio clienti.');
		}
	}

	@AuraEnabled
	public static String generaDocumentazione(Id oppId, String tipo) {
		try {
			return ExtViewChecklist.generaDocumentazione(oppId, tipo);
		} catch(Exception e) {
			AsyncLog__e l = new AsyncLog__e(
			                                Source__c = 'TiAnticipo',
			                                CodiceFunzione__c = 'ExtViewChecklist.generaDocumentazione',
			                                ErrorMessage__c = Ex.getReadableMessage(e) + '\n' + e.getStackTraceString(),
			                                InputPayload__c = 'idOpportunità: ' + oppId + ', tipo doc:' + tipo+' --- User: '+UserInfo.getName()+', User Id: '+UserInfo.getUserId()
			);
			EventBus.publish(l);
			//throw new AuraHandledException(Ex.getReadableMessage(e));
			throw new AuraHandledException('Errore: riprovare o contattare servizio clienti.');
		}
	}

	@AuraEnabled
	public static List<String> generaDocumentazioneStatica() {
		try {
			return TaCtrlDocumentazione.generaDocumentazioneStatica();
		} catch(Exception e) {
			AsyncLog__e l = new AsyncLog__e(
			                                Source__c = 'TiAnticipo',
			                                CodiceFunzione__c = 'TaCtrlDocumentazione.generaDocumentazioneStatica',
			                                ErrorMessage__c = Ex.getReadableMessage(e) + '\n' + e.getStackTraceString()+' --- User: '+UserInfo.getName()+', User Id: '+UserInfo.getUserId()
			);
			EventBus.publish(l);
			//throw new AuraHandledException(Ex.getReadableMessage(e));
			throw new AuraHandledException('Errore: riprovare o contattare servizio clienti.');
		}
	}
	//---------------------------------- END COMMUNITY TI ANTICIPO ---------------------------------- 


	@AuraEnabled
	public static String[] getSessionIdServerUrl() {
		String[] result = new String[] { };
		result.add((String) JSON.deserialize(Page.SessionId.getContent().toString(), String.class));
		String userType = UserInfo.getUserType();
		String serverUrl = (userType == 'Guest' || userType == 'CspLitePortal') ? URL.getSalesforceBaseUrl().toExternalForm() : 'https://' + [SELECT InstanceName FROM Organization LIMIT 1].InstanceName.toLowerCase() + '.salesforce.com';
		result.add(serverUrl);
		return result;
	}

	@RemoteAction
	@AuraEnabled
	public static Map<String, String> getLabels(String objName) {
		Map<String, String> ret = new Map<String, String> ();
		Map<String, Schema.SObjectField> fields = Schema.getGlobalDescribe().get(objName).getDescribe().fields.getMap();
		Schema.DescribeFieldResult tmp;
		for (String key : fields.keySet()) {
			tmp = fields.get(key).getDescribe();
			ret.put(tmp.getName(), tmp.getLabel());
		}
		return ret;
	}

	@AuraEnabled
	public static void updateBilancioSintetico(Id accountId) {
		WsRestRibesUtils.updateBilancioSintetico(accountId);
	}

	@AuraEnabled
	public static Account getInformazioniCambiaOwnerAccount(String accountId) { return TrgAccount.getInformazioniCambiaOwnerAccount(accountId); }

	@AuraEnabled
	public static TrgAccount.CambiaOwnerAccountResult cambiaOwnerAccount(String accountId, Boolean inviaMessaggioNotifica, String nuovoTitolareId, Boolean trasferisciOpportunitaAperte) {
		return TrgAccount.cambiaOwnerAccount(accountId, inviaMessaggioNotifica, nuovoTitolareId, trasferisciOpportunitaAperte);
	}

	@AuraEnabled
	public static Id getContentDocumentId(Id oppId, String tipo) {
		return CtrlGestioneAllegati.getContentDocumentId(oppId, tipo);
	}

	@AuraEnabled
	public static Boolean isPolandSearch() {
		return CtrlWizardAccount.isPolandSearch();
	}

}