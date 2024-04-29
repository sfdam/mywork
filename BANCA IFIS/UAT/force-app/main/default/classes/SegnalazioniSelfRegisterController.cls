public without sharing class SegnalazioniSelfRegisterController {

	class AuraWrapper{
		Id account;
		String codiceAccordo;
		Boolean isBanca;
		String esito;
		String message;
    }

    @AuraEnabled
    public static String checkAccordo (String numeroAccordo) {
        AuraWrapper aw = new AuraWrapper();        
        String nA = numeroAccordo.trim();
        try {
            List<Account> accountList = [SELECT Id,BI_CodiceAccordo__c,NaturaGiuridica__c from Account WHERE BI_CodiceAccordo__c = :nA];
            if (accountList.size() == 1) {
                for (Account tmp : accountList) {
                    if (tmp.BI_CodiceAccordo__c == nA) {
                        aw.esito = 'OK';
                        aw.codiceAccordo = nA;
                        aw.account = tmp.Id;
                        if (tmp.NaturaGiuridica__c == 'IC') {
                            aw.isBanca = true;
                        } else {
                            aw.isBanca = false;
                        }
                        aw.message = '';
                    } else {
                        aw.esito = 'KO';
                        aw.message = Label.CheckAccordoError;
                    }
                }
            } else {
                aw.esito = 'KO';
                aw.message = Label.CheckAccordoError;
            }
        } catch(Exception e){
            aw.esito= 'KO';
            aw.message= e.getCause() + ' - ' + e.getMessage() + ' - ' + e.getLineNumber();
        }
        
        return JSON.serialize(aw);
    }
    
    @AuraEnabled
    public static String registraUtente (String numeroAccordo, String nome, String cognome, String email, String cellulare, String accountId, String abi, String cab, String nomeProfilo, Boolean isBanca) {
        AuraWrapper aw = new AuraWrapper();
        
        Savepoint sp = null;
        try {
            sp = Database.setSavepoint();
            
            if (nome == '' || cognome == '' || email == '' || cellulare == '' || (isBanca && (abi == '' || cab == ''))) {
                aw.esito = 'KO';
                aw.message = Label.CheckRequiredFields;
            } else {
                // Creo il contatto
                Contact c = new Contact();
                c.AccountId = accountId;
                c.FirstName = nome;
                c.LastName = cognome;
                c.Email = email;
                c.TelefonoNumero__c = cellulare;
                c.BI_ABI_Accordo__c = abi;
                c.BI_CAB_Accordo__c = cab;
                
                Database.Saveresult src = Database.insert(c);
                if (src.isSuccess()) {
                    Id contactId = src.getId();
                    System.debug('contactId creato: ' + contactId);
                    
                    // Trovo il profilo
                    Id profilo = [SELECT Id FROM Profile WHERE Name = :nomeProfilo].Id;
                    System.debug('Id profilo: ' + profilo);

					// Genero Alias
					String alias = string.valueof(nome.substring(0,1) + cognome.substring(0,1) + Math.random());
                    
                    // Creo l'utente
                    User u = new User();
                    u.FirstName = nome;
                    u.LastName = cognome;
                    u.ContactId = contactId;
                    u.ProfileId = profilo;
                    u.Email = email;
					u.Phone = cellulare;
					//creo username univoco introducendo un riferimento al portale
					List<String> parts = email.split('@');
                    u.Username = parts[0] + '.b1p3@' + parts[1];
                    u.Alias = alias.substring(0,7);
                    u.EmailEncodingKey = 'UTF-8';
                    u.TimeZoneSidKey = 'Europe/Rome';
                    u.LocaleSidKey = 'it_IT';
                    u.LanguageLocaleKey = 'it';
                    
                    String nickname = ((nome != null && nome.length() > 0) ? nome.substring(0,1) : '' ) + cognome.substring(0,1);
                    nickname += String.valueOf(Crypto.getRandomInteger()).substring(1,7);
                    u.put('CommunityNickname', nickname);
                    
                    Database.Saveresult sru = Database.insert(u);
                    if (sru.isSuccess()) {
                        aw.esito = 'OK';
                        aw.message = Label.UserCreationSuccess;
                    } else {
                        aw.esito = 'KO';
                        aw.message = Label.UserCreationError;
                        for(Database.Error err : src.getErrors()) {
                            System.debug('The following error has occurred.');                    
                            System.debug(err.getStatusCode() + ': ' + err.getMessage());
                            System.debug('Account fields that affected this error: ' + err.getFields());                        
                        }
                    }
                    
                } else {
                    aw.esito = 'KO';
                    aw.message = Label.ContactCreationError;
                    for(Database.Error err : src.getErrors()) {
            			System.debug('The following error has occurred.');                    
            			System.debug(err.getStatusCode() + ': ' + err.getMessage());
            			System.debug('Account fields that affected this error: ' + err.getFields());                        
                    }
                }
            }      
            
        } catch (Exception ex) {
            Database.rollback(sp);
            aw.esito = 'KO';
			aw.message = ex.getMessage();            
        }
                
        return JSON.serialize(aw);
    }
}