/**
  * Progetto:         FrontEndUtils
  * Sviluppatore      Marco Bonin <marco.bonin@bancaifis.it>
  * Descrizione:      Controller di supporto per le funzionalità esposte dal componente BI_COM_FrontEndUtils_LCOM
*/

 

public class BI_COM_FrontEndUtils_CTRL  {

 

    @AuraEnabled
    public static String checkFreezedUsers () {

 

        return JSON.serialize(getUserLoginStatus());

 

    }

 

    @AuraEnabled
    public static Integer freezeUsers () {

 

        List<User> searchUser = [SELECT id, Name FROM User where IsActive = true and FederationIdentifier <> '' and (Profile.Name <> 'Amministratore del sistema' and Profile.Name <> 'System Administrator')];

 

        List<UserLogin> searchUnfreezedUserLogin = new List<UserLogin>();

 

        if(searchUser.size() > 0){

 

            searchUnfreezedUserLogin = [SELECT id, IsFrozen FROM UserLogin where IsFrozen = false and UserId IN :searchUser];

 

            for (UserLogin actualUser : searchUnfreezedUserLogin) {
            
                actualUser.IsFrozen = true;
            
            }

 

            if(!Test.isRunningTest())
                update searchUnfreezedUserLogin;

 

        }

 

        return searchUnfreezedUserLogin.size();

 

    }

 

    @AuraEnabled
    public static Integer unfreezeUsers () {

 

        List<User> searchUser = [SELECT id, Name FROM User where IsActive = true and FederationIdentifier <> '' and (Profile.Name <> 'Amministratore del sistema' and Profile.Name <> 'System Administrator')];

 

        List<UserLogin> searchFreezedUserLogin = new List<UserLogin>();

 

        if(searchUser.size() > 0){

 

            searchFreezedUserLogin = [SELECT id, IsFrozen FROM UserLogin where IsFrozen = true and UserId IN :searchUser];

 

            for (UserLogin actualUser : searchFreezedUserLogin) {
            
                actualUser.IsFrozen = false;
            
            }

 

            if(!Test.isRunningTest())
                update searchFreezedUserLogin;

 

        }

 

        return searchFreezedUserLogin.size();

 

    }

 


    private static resultWrapper getUserLoginStatus(){
    
        resultWrapper rw = new resultWrapper();

 

        List<User> searchUser = [SELECT id, Name FROM User where IsActive = true and FederationIdentifier <> '' and (Profile.Name <> 'Amministratore del sistema' and Profile.Name <> 'System Administrator')];

        if(searchUser.size() > 0){

            List<UserLogin> searchFreezedUserLogin = [SELECT id FROM UserLogin where IsFrozen = true and UserId IN :searchUser];

 

            rw.UTENTI_FREEZATI = searchFreezedUserLogin.size();

 

            List<UserLogin> searchUnfreezedUserLogin = [SELECT id FROM UserLogin where IsFrozen = false and UserId IN :searchUser];

 

            rw.UTENTI_NON_FREEZATI = searchUnfreezedUserLogin.size();

 

        }

 

        return rw;

 

    }

 

    public class resultWrapper {

 

        public Integer UTENTI_FREEZATI = 0;
        
        public Integer UTENTI_NON_FREEZATI = 0;

 

    }

	@AuraEnabled
	public static void riassegnaTerritoriFD() {
		//mantenere allineata la logica della classe con la BI_COM_SuddivisioneTerritoriale_SCHD
		Date data = Date.today();
		Integer meseCorrente = data.month();
		String htmlBody='';

		//Disabilito trigger sull'oggetto Assegnazione Anagrafica poichè non esegue attività per FD ma causerebbe l'errore "Too many SOQL queries"
		List<Funzionalita__c> funzionalita = [select Id, DisabilitaTriggerAssegnazioneAnagrafica__c FROM Funzionalita__c where Name = 'a0958000005bb3T'];
		if(funzionalita.size() > 0){
			funzionalita.get(0).DisabilitaTriggerAssegnazioneAnagrafica__c = true;
			update funzionalita;
			System.debug('Disabilito trigger Assegnazione Anagrafica');
		}

		System.debug('Avvio aggiornamento automatico suddivisione territoriale FD');
		List<Suddivisione_Territoriale_FD__c> suddivisioneTerritoriale = [select Id, Operatore_FD__c, Filiale__c from Suddivisione_Territoriale_FD__c where Mese__c = :meseCorrente];

		if (suddivisioneTerritoriale.size() > 0) {
			for (Suddivisione_Territoriale_FD__c zona : suddivisioneTerritoriale) {
				List<AssegnazioneAnagrafica__c> assegnazioneAnagrafica = [select Id, Utente__c FROM AssegnazioneAnagrafica__c WHERE FiloDiretto__c = true AND Filiale__c = :zona.Filiale__c];
				if (assegnazioneAnagrafica.size() > 0) {
					for (AssegnazioneAnagrafica__c assegnazione : assegnazioneAnagrafica) {
						assegnazione.Utente__c = zona.Operatore_FD__c;
					}
					try {
						if(!Test.isRunningTest())
							update assegnazioneAnagrafica;
					} catch(Exception ex) {
						htmlBody += 'Errore nella riassegnazione territoriale della Filiale ' + zona.Filiale__c + '<br>';
						System.debug('Errore nella riassegnazione territoriale FD: ' + ex);
					}
					System.debug('Aggiornata Filiale ' + zona.Filiale__c);
					htmlBody += 'Aggiornata Filiale ' + zona.Filiale__c + '<br>';
				}
			}
		}

		//Riabilito trigger
		if(funzionalita.size() > 0){
			funzionalita.get(0).DisabilitaTriggerAssegnazioneAnagrafica__c = false;
			update funzionalita;
			System.debug('Abilito trigger Assegnazione Anagrafica');
		}

		Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();

		String[] toAddresses = new String[] { 'ict.am.crmmulticanalita@bancaifis.it' };
		mail.setToAddresses(toAddresses);
		mail.setSubject('Aggiornamento Suddivisione Territoriale FD');
		mail.setBccSender(false);
		mail.setUseSignature(false);
		OrgWideEmailAddress owea = [SELECT Id FROM OrgWideEmailAddress WHERE Address = 'ict.am.crmmulticanalita@bancaifis.it' LIMIT 1];
		mail.setOrgWideEmailAddressId(owea.Id);
		mail.setHtmlBody(htmlBody);
		Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
		}
}