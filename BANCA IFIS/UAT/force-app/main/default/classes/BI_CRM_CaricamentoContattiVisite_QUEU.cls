@TestVisible
public class BI_CRM_CaricamentoContattiVisite_QUEU implements Queueable {

	List<CaricamentoContattiVisite__c> records;

	public BI_CRM_CaricamentoContattiVisite_QUEU(List<CaricamentoContattiVisite__c> record) {
		this.records = record;
	}

	public void execute(QueueableContext context) {
		if (records.size() > 0) {
			CaricamentoContattiVisite__c rec = records.remove(0);
			// rileggo il dato altrimenti quello passato dal trigger è read only
			CaricamentoContattiVisite__c record = [select Id, Assegnatario__c, Campagna__c, Cellulare__c, Commenti__c, Data_Attivita__c, Email__c, Esito_Livello_1__c, Esito_Livello_2__c, ID_Attivita__c, Name, Originator__c, Originator_Dettaglio__c, Referente_Cognome__c, Referente_Nome__c, Telefono_numero__c, Telefono_prefisso__c, Tipologia_Inserimento__c FROM CaricamentoContattiVisite__c WHERE Id = :rec.Id];
			try {
				List<Account> anagrafica = [select Id, NDGGruppo__c, Name, WGC_Specialista_Factoring__c FROM Account WHERE NDGGruppo__c = :record.Name AND CodiceIstituto3N__c = '881' LIMIT 1];
				if (anagrafica.size() > 0) {
					System.debug('ANAG ' + anagrafica.get(0).NDGGruppo__c + ' - ' + anagrafica.get(0).Name);

					if (record.Tipologia_Inserimento__c.equalsIgnoreCase('CONTATTO')) {
						if (record.ID_Attivita__c == null) {
							Task task = new Task();
							task.Subject = 'Ricontatto telefonico';
							task.Status = 'Aperto';
							task.Priority = 'Alta';
							task.RecordTypeId = '01258000000FItFAAW'; //Sviluppo Diretto
							task.WhatId = anagrafica.get(0).Id;
							if (record.Originator__c != null && record.Originator__c != '') {
								task.Originator__c = record.Originator__c;
							} else {
								record.Stato_Elaborazione__c = 'ERRORE: Originator mancante';
								update record;
								if (records.size() > 0) {
									System.enqueueJob(new BI_CRM_CaricamentoContattiVisite_QUEU(records));
									return;
								} else {
									return;
								}
							}
							if (record.Originator_Dettaglio__c != null && record.Originator_Dettaglio__c != '') {
								task.Originator_di_dettaglio__c = record.Originator_Dettaglio__c;
							} else {
								record.Stato_Elaborazione__c = 'ERRORE: Originator Dettaglio mancante';
								update record;
								if (records.size() > 0) {
									System.enqueueJob(new BI_CRM_CaricamentoContattiVisite_QUEU(records));
									return;
								} else {
									return;
								}
							}
							if (record.Assegnatario__c != null && record.Assegnatario__c != '') {
								try {
									List<User> user = [select Id, Name FROM User WHERE Name = :record.Assegnatario__c LIMIT 1];
									if (user.size() > 0)
									task.OwnerId = user.get(0).Id;
								} catch(Exception ex) {
									record.Stato_Elaborazione__c = 'ERRORE NEL RECUPERO DELL\'ASSEGNATARIO: ' + ex.getStackTraceString();
									update record;
									if (records.size() > 0) {
										System.enqueueJob(new BI_CRM_CaricamentoContattiVisite_QUEU(records));
										return;
									} else {
										return;
									}
								}
							}
							if (record.Referente_Cognome__c != null && record.Referente_Nome__c != '' && record.Referente_Cognome__c != '' && record.Referente_Nome__c != null) {
								try {
									List<Contact> c = [select Id, Name, NDGGruppo__c FROM Contact WHERE AccountId = :anagrafica.get(0).Id AND FirstName = :record.Referente_Nome__c AND LastName = :record.Referente_Cognome__c ORDER BY NDGGruppo__c DESC NULLS LAST limit 1];
									if (c.size() > 0)
									task.Referente_dell_azienda__c = c.get(0).Id;
								} catch(Exception ex) {
									record.Stato_Elaborazione__c = 'ERRORE NEL RECUPERO DEL REFERENTE: ' + ex.getStackTraceString();
									update record;
									if (records.size() > 0) {
										System.enqueueJob(new BI_CRM_CaricamentoContattiVisite_QUEU(records));
										return;
									} else {
										return;
									}
								}
							} else {
								List<Contact> c = [select Id, Name, NDGGruppo__c FROM Contact WHERE AccountId = :anagrafica.get(0).Id AND Name like 'Centralino%'];
								if (c.size() > 0)
								task.WhoId = c.get(0).Id;
							}
							task.activityDate = record.Data_Attivita__c;
							task.Data_Inizio__c = record.Data_Attivita__c;
							task.Data_Fine__c = task.Data_Inizio__c.addHours(1);
							if (record.Campagna__c != null && record.Campagna__c != '') {
								List<Campaign> campagna = [select id, Name FROM Campaign WHERE Name = :record.Campagna__c];
								if (campagna.size() > 0)
								task.Campagna__c = campagna.get(0).Id;
							}
							task.TipoAttivita__c = 'Sviluppo Diretto';
							if (record.Esito_Livello_1__c != null)
							task.EsitoLivello1__c = record.Esito_Livello_1__c;
							if (record.Esito_Livello_2__c != null)
							task.EsitoLivello2__c = record.Esito_Livello_2__c;
							if (record.Commenti__c != null)
							task.CommentiEsito__c = record.Commenti__c;

							insert task;
							System.debug('CONTATTO inserito. ' + task);

						} else {
							Task task = new Task();
							task.activityDate = record.Data_Attivita__c;
							if (record.Esito_Livello_1__c != null)
							task.EsitoLivello1__c = record.Esito_Livello_1__c;
							if (record.Esito_Livello_2__c != null)
							task.EsitoLivello2__c = record.Esito_Livello_2__c;
							if (record.Commenti__c != null)
							task.CommentiEsito__c = record.Commenti__c;
							task.Id = record.ID_Attivita__c;
							if (record.Assegnatario__c != null && record.Assegnatario__c != '') {
								List<User> user = [select Id, Name FROM User WHERE Name = :record.Assegnatario__c LIMIT 1];
								if (user.size() > 0)
								task.OwnerId = user.get(0).Id;
							}
							try {
								update task;
							} catch(Exception ex) {
								record.Stato_Elaborazione__c = 'ERRORE AGGIORNAMENTO CONTATTO: ' + ex.getStackTraceString();
								update record;
								if (records.size() > 0) {
									System.enqueueJob(new BI_CRM_CaricamentoContattiVisite_QUEU(records));
									return;
								} else {
									return;
								}
							}
							System.debug('CONTATTO aggiornato. ' + task);
						}

					} else if (record.Tipologia_Inserimento__c.startsWithIgnoreCase('VISITA')) {
						System.debug('TIPO VISITA: ' + record.Tipologia_Inserimento__c);
						if (record.ID_Attivita__c == null) {
							Event event = new Event();
							if (record.Tipologia_Inserimento__c.equalsIgnoreCase('VISITA RELAZIONALE')){
								event.Subject = 'Visita Relazionale - ' + anagrafica.get(0).Name;
								event.TipoAttivita__c = 'Relazionale';
							} else {
								event.Subject = 'Visita Commerciale - ' + anagrafica.get(0).Name;
								event.TipoAttivita__c = 'Sviluppo Diretto';
							}
							event.RecordTypeId = '01258000000FIlFAAW'; //Visita Commerciale o Relazionale
							event.WhatId = anagrafica.get(0).Id;
							if (record.Originator__c != null && record.Originator__c != '') {
								event.Originator__c = record.Originator__c;
							} else {
								record.Stato_Elaborazione__c = 'ERRORE: Originator mancante';
								update record;
								if (records.size() > 0) {
									System.enqueueJob(new BI_CRM_CaricamentoContattiVisite_QUEU(records));
									return;
								} else {
									return;
								}
							}
							if (record.Originator_Dettaglio__c != null && record.Originator_Dettaglio__c != '') {
								event.Originator__c = record.Originator_Dettaglio__c;
							} else {
								record.Stato_Elaborazione__c = 'ERRORE: Originator Dettaglio mancante';
								update record;
								if (records.size() > 0) {
									System.enqueueJob(new BI_CRM_CaricamentoContattiVisite_QUEU(records));
									return;
								} else {
									return;
								}
							}
							System.debug('OWNER- Assegnatario: ' + record.Assegnatario__c + ' -Specialista: ' + anagrafica.get(0).WGC_Specialista_Factoring__c);
							if (record.Assegnatario__c != null && record.Assegnatario__c != '') {
								try {
									List<User> user = [select Id, Name FROM User WHERE Name = :record.Assegnatario__c LIMIT 1];
									if (user.size() > 0)
									event.OwnerId = user.get(0).Id;
								} catch(Exception ex) {
									record.Stato_Elaborazione__c = 'ERRORE NEL RECUPERO DELL\'ASSEGNATARIO: ' + ex.getStackTraceString();
									update record;
									if (records.size() > 0) {
										System.enqueueJob(new BI_CRM_CaricamentoContattiVisite_QUEU(records));
										return;
									} else {
										return;
									}
								}
							} else {
								try {
									event.OwnerId = anagrafica.get(0).WGC_Specialista_Factoring__c;
								} catch(Exception ex) {
									record.Stato_Elaborazione__c = 'ERRORE NEL RECUPERO DEL REERENTE FACTORING: ' + ex.getStackTraceString();
									update record;
									if (records.size() > 0) {
										System.enqueueJob(new BI_CRM_CaricamentoContattiVisite_QUEU(records));
										return;
									} else {
										return;
									}
								}		
							}
							if (record.Campagna__c != null && record.Campagna__c != '') {
								List<Campaign> campagna = [select id, Name FROM Campaign WHERE Name = :record.Campagna__c];
								if (campagna.size() > 0)
								event.Campagna__c = campagna.get(0).Id;
							}
							event.DurationInMinutes = 60;
							event.ActivityDateTime = DateTime.newInstance(record.Data_Attivita__c, Time.newInstance(10, 00, 0, 0));
							if (record.Esito_Livello_1__c != null)
							event.EsitoLivello1__c = record.Esito_Livello_1__c;
							if (record.Esito_Livello_2__c != null)
							event.EsitoLivello2__c = record.Esito_Livello_2__c;
							if (record.Commenti__c != null)
							event.CommentiEsito__c = record.Commenti__c;

							insert event;
							System.debug('VISITA inserita. ' + event);

						} else {
							Event event = new Event();
							event.ActivityDateTime = DateTime.newInstance(record.Data_Attivita__c, Time.newInstance(10, 00, 0, 0));
							if (record.Esito_Livello_1__c != null)
							event.EsitoLivello1__c = record.Esito_Livello_1__c;
							if (record.Esito_Livello_2__c != null)
							event.EsitoLivello2__c = record.Esito_Livello_2__c;
							if (record.Commenti__c != null)
							event.CommentiEsito__c = record.Commenti__c;
							event.Id = record.ID_Attivita__c;
							if (record.Assegnatario__c != null && record.Assegnatario__c != '') {
								List<User> user = [select Id, Name FROM User WHERE Name = :record.Assegnatario__c LIMIT 1];
								if (user.size() > 0)
								event.OwnerId = user.get(0).Id; 
							}

							try {
								update event;
							} catch(Exception ex) {
								record.Stato_Elaborazione__c = 'ERRORE AGGIORNAMENTO VISITA: ' + ex.getStackTraceString();
								update record;
								if (records.size() > 0) {
									System.enqueueJob(new BI_CRM_CaricamentoContattiVisite_QUEU(records));
									return;
								} else {
									return;
								}
							}
							System.debug('VISITA aggiornata. ' + event);
						}

					} else if (record.Tipologia_Inserimento__c.equalsIgnoreCase('REFERENTE')) {
						try {
							boolean contattoModificato = false;
							if (record.Referente_Cognome__c != null && record.Referente_Nome__c != '' && record.Referente_Cognome__c != '' && record.Referente_Nome__c != null) {
								List<Contact> c = [select Id, Name, NDGGruppo__c, Email, TelefonoPrefisso__c, TelefonoNumero__c, MobilePhone FROM Contact WHERE AccountId = :anagrafica.get(0).Id AND FirstName = :record.Referente_Nome__c AND LastName = :record.Referente_Cognome__c ORDER BY NDGGruppo__c DESC NULLS LAST limit 1];
								if (c.size() > 0) {
									if (String.isNotEmpty(record.Email__c)) {
										c.get(0).Email = record.Email__c;
										contattoModificato = true;
									}
									if (String.isNotEmpty(record.Telefono_prefisso__c)) {
										c.get(0).TelefonoPrefisso__c = record.Telefono_prefisso__c;
										contattoModificato = true;
									}
									if (String.isNotEmpty(record.Telefono_numero__c)) {
										c.get(0).TelefonoNumero__c = record.Telefono_numero__c;
										contattoModificato = true;
									}
									if (String.isNotEmpty(record.Cellulare__c)) {
										c.get(0).MobilePhone = record.Cellulare__c;
										contattoModificato = true;
									}
									if (contattoModificato == true) {
										update c;
										System.debug('REFERENTE aggiornato. ' + c);
									}
								} else {
									Contact referente = new Contact();
									referente.AccountId = anagrafica.get(0).Id;
									referente.CodiceIstituto3N__c = '881';
									referente.NaturaGiuridica__c = 'PF';
									referente.TAECode__c = '984';
									referente.Email = record.Email__c;
									referente.TelefonoPrefisso__c = record.Telefono_prefisso__c;
									referente.TelefonoNumero__c = record.Telefono_numero__c;
									referente.MobilePhone = record.Cellulare__c;
									referente.FirstName = record.Referente_Nome__c;
									referente.LastName = record.Referente_Cognome__c;

									insert referente;
									System.debug('REFERENTE inserito. ' + c);
								}
							} else {
								record.Stato_Elaborazione__c = 'ERRORE: Nome o Cognome del referente mancanti';
								update record;
								if (records.size() > 0) {
									System.enqueueJob(new BI_CRM_CaricamentoContattiVisite_QUEU(records));
									return;
								} else {
									return;
								}
							}

						} catch(Exception ex) {
							record.Stato_Elaborazione__c = 'ERRORE NEL RECUPERO DEL REFERENTE: ' + ex.getStackTraceString();
							update record;
							if (records.size() > 0) {
								System.enqueueJob(new BI_CRM_CaricamentoContattiVisite_QUEU(records));
								return;
							} else {
								return;
							}
						}
					} else {
						record.Stato_Elaborazione__c = 'ERRORE: Tipologia sconosciuta';
						update record;
						if (records.size() > 0) {
							System.enqueueJob(new BI_CRM_CaricamentoContattiVisite_QUEU(records));
							return;
						} else {
							return;
						}
					}
				} else {
					System.debug('ANAG non trovata');
					record.Stato_Elaborazione__c = 'ERRORE: NDG mancante';
					update record;
					if (records.size() > 0) {
						System.enqueueJob(new BI_CRM_CaricamentoContattiVisite_QUEU(records));
						return;
					} else {
						return;
					}
				}
			} catch(Exception ex) {
				record.Stato_Elaborazione__c = 'ERRORE: ' + ex.getStackTraceString();
				System.debug('ERRORE: ' + ex.getStackTraceString());
				update record;
				if (records.size() > 0) {
					System.enqueueJob(new BI_CRM_CaricamentoContattiVisite_QUEU(records));
					return;
				} else {
					return;
				}
			}
			System.debug('DEBUG: ' + record);
			record.Stato_Elaborazione__c = 'Elaborato';
			update record;

			if (records.size() > 0)
			System.enqueueJob(new BI_CRM_CaricamentoContattiVisite_QUEU(records));
		}
	}
}