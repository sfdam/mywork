/**
* Progetto:         Banca IFIS - Ti Anticipo
* Sviluppata il:    14/06/2016
* Developer:        Stefano Brivio
*/

public without sharing class TaCtrlLogin {
	private static Integer MAX_LENGTH = 131072;
    private static String CANALE_TA = '5';
    private static String SOTTOCANALE_TA = '5';
    //adione CRM20 gestione originator
    private static String taDevName = 'Portali_TiAnticipo_Area_Riservata';
    
    public TaCtrlLogin() {
    }
    
    public class InputObj {
        public String nome, cognome, email, password, ragioneSociale, piva, selectedAccountKey, forgottenEmail, telefono;
        public Account selectedAccount;
        public Boolean privacy;
    }
    
    public class ProfileInfo {
        @AuraEnabled public Account account;
        @AuraEnabled public Contact contact;
        @AuraEnabled public List<Contact> titolariEsecutori;
        @AuraEnabled public AdeguataVerifica__c adegVerifica;
        
        public ProfileInfo(Account account, Contact contact) {
            this.account = account;
            this.contact = contact;
            this.titolariEsecutori = new List<Contact>();
            this.adegVerifica = new AdeguataVerifica__c();
        }
        
        public ProfileInfo(Account account, Contact contact, List<Contact> titolariEsecutori) {
            this.account = account;
            this.contact = contact;
            this.titolariEsecutori = titolariEsecutori;
            this.adegVerifica = new AdeguataVerifica__c();
        }
        
        public ProfileInfo(Account account, Contact contact, List<Contact> titolariEsecutori, AdeguataVerifica__c adegVerifica) {
            this.account = account;
            this.contact = contact;
            this.titolariEsecutori = titolariEsecutori;
            this.adegVerifica = adegVerifica;
        }
    }
    
    public class UserInfoObj {
        @AuraEnabled public String firstName, lastName, fullName, username;
        @AuraEnabled public Boolean accessoEffettuato;
        
        public UserInfoObj(String firstName, String lastName, String fullName, String username, Boolean accessoEffettuato) {
            this.firstName = firstName;
            this.lastName = lastName;
            this.fullName = fullName;
            this.username = username;
            this.accessoEffettuato = accessoEffettuato;
        }
    }
    
    public static String login(String input) {
        String errorMessage;
        InputObj obj = (InputObj) JSON.deserialize(input, InputObj.class);
        ApexPages.PageReference pRef;
        
        String usernameTA = TiAnticipoUtils.getCommunityUsername(obj.email);
        // includere /s/ per gestire il redirect lato client
        pRef = Site.login(TiAnticipoUtils.getCommunityUsername(obj.email), obj.password, '/s/home');
        if (pRef == null) {
            errorMessage = 'Credenziali non valide';
            throw new Ex.GenericException(errorMessage);
        }
        
        return pRef.getUrl();
    }
    
    public static String selfRegister(String input) {
        Account acc;
        InputObj obj = (InputObj)JSON.deserialize(input, InputObj.class);
        System.debug('SV obj.selectedAccount: ' + obj.selectedAccount);
        validateRegistration(obj);
        
        acc = obj.selectedAccount;
        //se non c'è NDG assegnato è un nuovo censimento
        Boolean isNuovoAccountSenzaNDG = String.isBlank(acc.NDGGruppo__c);
        //se non c'è object Id, l'anagrafica non è presente in CRM (ma magari è presente in Cedacri con NDG assegnato)
        Boolean existInCRM = !String.isBlank(acc.Id);
        ParametriTiAnticipo__c parametriTA = ParametriTiAnticipo__c.getInstance();
        Map <String, Object> accountAdditionalFields = new Map<String,Object>();
        
        //se non c'è in CRM, pre-popoliamo i campi specifici per TiAnticipo
        if (!existInCRM) {
            System.debug('-----> Account non presente in CRM');
            //adione-CRM20
            WGC_Originator__mdt originatorMD = [
                SELECT Originator__c, Originator_dettaglio__c
                FROM WGC_Originator__mdt
                WHERE DeveloperName = :taDevName
            ];
            
            accountAdditionalFields.put('CanaleSviluppo__c', CANALE_TA);
            accountAdditionalFields.put('Sottocanale__c', SOTTOCANALE_TA);
            //adione CRM20 gestione originator
            accountAdditionalFields.put('WGC_Originator__c', originatorMD.Originator__c);
            accountAdditionalFields.put('WGC_Originator_dettaglio__c', originatorMD.Originator_dettaglio__c);
            //accountAdditionalFields.put('OwnerId', parametriTA.IDTitolareFactoring__c); //spostato nella wf-rule
            //accountAdditionalFields.put('OpFiloDiretto__c', parametriTA.IDOperatoreFiloDiretto__c); //spostato nella wf-rule
            accountAdditionalFields.put('GestoreCliente__c', parametriTA.NDGGestoreCliente__c);
            accountAdditionalFields.put('ClienteTiAnticipo__c', true);
            
        } else { 
            //altrimenti aggiorniamo solo alcuni campi
            System.debug('-----> Account già presente in CRM');
            
            Account accCrm = [SELECT OwnerId, OpFiloDiretto__c, GestoreCliente__c FROM Account WHERE NDGGruppo__c =: acc.NDGGruppo__c];
            accountAdditionalFields.put('ClienteTiAnticipoGiaPresente__c', true);
            /* //spostato nella wf-rule
            if (String.isBlank(accCrm.OwnerId))
                accountAdditionalFields.put('OwnerId', parametriTA.IDTitolareFactoring__c);
            if (String.isBlank(accCrm.OpFiloDiretto__c))
                accountAdditionalFields.put('OpFiloDiretto__c', parametriTA.IDOperatoreFiloDiretto__c);
			*/
            if (String.isBlank(accCrm.GestoreCliente__c))
                accountAdditionalFields.put('GestoreCliente__c', parametriTA.NDGGestoreCliente__c);
        }
        
        //adione completiamo anagrafica in vista del censimento/variazione
        acc = CtrlWizardAccount.setupAccount(acc);
        
        //adione-CRM20 adeguate classi 
        Contact con = null;
        if (acc.NaturaGiuridica__c == 'DI') {
            con = CreateAccount.getContactFromDI(acc);
        }
        
        //dopo censim/variaz in Cedacri, aggiorniamo campi addizionali CRM
        for (String field : U.toList(accountAdditionalFields.keySet())) {
            acc.put(field, accountAdditionalFields.get(field));
        }            
        
        String tipoCens = isNuovoAccountSenzaNDG ? 'light' : 'variazione';
        acc.Id = CtrlWizardAccount.WGC_insertAccount(acc, acc.Origine__c, true, tipoCens, con);
        
        System.debug('-----> Account finale: '+JSON.serialize(acc));
        //SDHDFNZ-84971
        obj.email = obj.email.trim();
        obj.nome = obj.nome.trim();
        obj.cognome = obj.cognome.trim();
        obj.password = obj.password.trim();        
        String username = TiAnticipoUtils.creaCommunityUsername(obj.email);
        Id userId = createUser(username, obj.email, obj.nome, obj.cognome, obj.password, acc.Id);
        
        User u = [SELECT Id, ContactId, Username FROM User WHERE Id = :userId];
        System.debug('SV USER: ' + u);
        
        //log operation
        String msg = 'Nuovo utente portale Ti Anticipo creato. \nNome: '+obj.nome+' '+obj.cognome+' \nUsername: '+u.username+' \nAccount: '+acc.Name+' \nP.IVA: '+acc.PIVA__c+' \nNDG: '+acc.NDGGruppo__c;
        Integer idxStart = input.lastIndexOf('password":"');
        Integer idxEnd = input.indexOf('","', idxStart);
        //remove password when logging
        String newInput = input.substring(0, idxStart) + 'password":"*****' + input.substring(idxEnd, input.length());            
        Log__c l = new Log__c();
        l.CodiceApplicazione__c = 'Portale Ti Anticipo';
        l.CodiceFunzione__c = 'TaCtrlLogin.selfRegister';
        l.Source__c = 'TiAnticipo';
        l.NDG__c = acc.NDGGruppo__c;
        l.OutputPayload__c = msg;
        l.InputPayload__c = newInput.abbreviate(MAX_LENGTH);
        
        insert l;
        TiAnticipoUtils.sendInfoMail(msg);
        
        return login(JSON.serialize(obj));
    }
    
    public static Boolean resetPassword(String input) {
        String errorMessage;
        InputObj obj = (InputObj)JSON.deserialize(input, InputObj.class);
        String username = TiAnticipoUtils.getCommunityUsername(obj.forgottenEmail);
        if (!Site.isValidUsername(username)) {
            errorMessage = 'Lo username inserito non è valido';
			return true;
        } else {
            return Site.forgotPassword(username);
        }
    }
    
    private static void validateRegistration(InputObj obj) {
        String passError;
        String errorMessage = '';
        String[] errors = new String[] {};
            
        if (!UtilAnagrafiche.isOK(obj.nome)) errors.add('Nome');
        if (!UtilAnagrafiche.isOK(obj.cognome)) errors.add('Cognome');
        if (!UtilAnagrafiche.isOK(obj.email)) errors.add('Email');
        if (!UtilAnagrafiche.isOK(obj.ragioneSociale)) errors.add('Ragione sociale');
        if (!UtilAnagrafiche.isOK(obj.piva)) errors.add('Partita IVA');
        if (String.isBlank(obj.password)) {
            passError = 'Password non valida';
        }
        
        if (!errors.isEmpty()) {
            errorMessage = 'I seguenti campi sono obbligatori: ' + String.join(errors, ', ') + ' ';
        }
        if (String.isNotBlank(passError)) {
            errorMessage += passError;
        }
        
        if (String.isNotBlank(errorMessage)) new Ex.GenericException(errorMessage);
    }
    
    @TestVisible
    private static Id createUser(String username, String email, String nome, String cognome, String password, Id accountId) {
        User u = new User();
        //adione-CRM20
        WGC_Originator__mdt originatorMD = [
            SELECT Qualifica_Utente__c, Canale_di_sviluppo__c
            FROM WGC_Originator__mdt
            WHERE DeveloperName = :taDevName
        ];
        
        u.Username = username;
        u.Email = email;
        u.FirstName = nome;
        u.LastName = cognome;
        u.TimeZoneSidKey = 'Europe/Rome';
        u.CommunityNickname = u.Username.left(40);
        //adione-CRM20
        u.Qualifica_Utente__c = originatorMD.Qualifica_Utente__c; //Ti Anticipo
        u.WGC_Canale_di_sviluppo__c = originatorMD.Canale_di_sviluppo__c; //Ti Anticipo
        
        Site.validatePassword(u, password, password);
        System.debug('-----> TaCtrlLogin.createUser - user: '+JSON.serialize(u));
        System.debug('-----> TaCtrlLogin.createUser - accountId: '+accountId);
        
        Id res = Site.createExternalUser(
            u,
            accountId,
            password,
            true
        );

        return res;
    }
    
    public static ProfileInfo fetchProfile() {
        if (UserInfo.getUserType() == 'Guest') return null;
        
        Id contactId = TiAnticipoUtils.getUserContactId();
        System.debug('-----> TaCtrlLogin.fetchProfile');
        System.debug('-----> contactId: '+contactId);
        Contact userContact = [SELECT Id,
                               AccountId,
                               Name,
                               FirstName,
                               LastName,
                               CF__c,
                               Ruolo__c,
                               Birthdate,
                               LuogoNascita__c,
                               Phone,
                               MobilePhone,
                               Email
                               FROM Contact
                               WHERE Id = :contactId];
        System.debug('-----> userContact: '+userContact);
        Account userAccount = [SELECT Id,
                               Name,
                               PIVA__c,
                               BillingCity,
                               BillingCountry,
                               BillingPostalCode,
                               BillingState,
                               BillingStreet,
                               BillingStreetType__c,
                               BillingStreetNumber__c,
                               BillingStreetName__c,
                               ShippingCity,
                               ShippingCountry,
                               ShippingPostalCode,
                               ShippingState,
                               ShippingStreet,
                               ShippingStreetType__c,
                               ShippingStreetNumber__c,
                               ShippingStreetName__c,
                               FirmaDigitale__c,
                               REA__c,
                               SAE__c,
                               RAE__c,
                               Ateco__c,
                               ProvinciaCCIAA__c,
                               EmailPEC__c,
                               Email__c,
                               TelefonoPrefisso__c,
                               TelefonoNumero__c,
                               Fax,
                               NaturaGiuridica__c,
                               NDGGruppo__c,
                               ProvinciaCerved__c,
                               IBAN__c,
                               PresaVisionePrivacy__c,
                               CCIAA__c,
                               SIA__c,
                               PaeseSvolgimentoAttivitaPrevalente__c,
                               ProvinciaAttivitaPrevalente__c,
                               QualificaCliente__c,
                               NumberOfEmployees,
                               Fatturato__c,
                               RicaviNetti__c
                               FROM Account
                               WHERE Id = :userContact.AccountId];
        System.debug('-----> userAccount: '+userAccount);
        AdeguataVerifica__c adv; //FIXME CRM20: controllare gestione ADV che si basa su MTC
        AdeguataVerifica__c[] advs = [SELECT Id,
                                      Account__c,
                                      CorrispondenzaStreetType__c,
                                      CorrispondenzaStreetName__c,
                                      CorrispondenzaStreetNumber__c,
                                      CorrispondenzaCity__c,
                                      CorrispondenzaCAP__c,
                                      CorrispondenzaState__c,
                                      CorrispondenzaCountry__c,
                                      TipoIndirizzo__c
                                      FROM AdeguataVerifica__c
                                      WHERE Account__c = :userAccount.Id];
        System.debug('-----> advs: '+advs);
        adv = (advs.size() != 0) ? advs[0] : new AdeguataVerifica__c(
            Account__c = userAccount.Id,
            TipoIndirizzo__c = 'billing',
            CorrispondenzaCity__c = userAccount.BillingCity,
            CorrispondenzaCountry__c = userAccount.BillingCountry,
            CorrispondenzaCAP__c = userAccount.BillingPostalCode,
            CorrispondenzaState__c = userAccount.BillingState,
            CorrispondenzaStreetType__c = userAccount.BillingStreetType__c,
            CorrispondenzaStreetNumber__c = userAccount.BillingStreetNumber__c,
            CorrispondenzaStreetName__c = userAccount.BillingStreetName__c
        );
        if (adv.Id == null) insert adv;
        System.debug('-----> adv: '+adv);
        List<Contact> titolariEsecutori = TaCtrlRegistrazioneUtenti.fetchContacts();
        System.debug('-----> titolariEsecutori: '+titolariEsecutori);
        return new ProfileInfo(userAccount, userContact, titolariEsecutori, adv);
    }
    
    public static Boolean updateProfile(String input) {

        System.debug('-----> TaCtrlLogin.updateProfile');
        System.debug('-----> input: '+input);
        
        ProfileInfo profile = (ProfileInfo)JSON.deserialize(input, ProfileInfo.class);        
        Account acc = profile.account;
        if (acc.Fatturato__c != null)
            acc.Fatturato__c = (acc.Fatturato__c / 1000).round(System.RoundingMode.HALF_DOWN); //adione-CRM20 fatturato mostrato in migliaia
        acc.REA__C = acc.CCIAA__c;
        acc.ProvinciaCCIAA__c = acc.ProvinciaCerved__c;
        acc.ProvinciaSvolgimentoAttivitaPrevalente__c = acc.ProvinciaAttivitaPrevalente__c;
        acc.PaeseCasaMadre__c = acc.PaeseSvolgimentoAttivitaPrevalente__c; //FIXME ragionevole ma non certo 100%
        acc.WGC_Numero_dipendenti__c = acc.NumberOfEmployees;
        update acc;
        
        Contact con = profile.contact;
        //adione-crm20
        con.MailingPostalCode__c = profile.contact.MailingPostalCode;
        con.MailingState__c = profile.contact.MailingState;
        con.MailingCity__c = profile.contact.MailingCity;
        con.MailingCountry__c = profile.contact.MailingCountry;
        //correzione codifica documento in caso di input da portale
        if (con.TipoDocumentoIdentita__c == 'CartaIdentita') con.TipoDocumentoId__c = 'I';
        else if (con.TipoDocumentoIdentita__c == 'Patente') con.TipoDocumentoId__c = 'U';
        else if (con.TipoDocumentoIdentita__c == 'Passaporto') con.TipoDocumentoId__c = 'S';
        else if (con.TipoDocumentoIdentita__c == 'PortoArmi') con.TipoDocumentoId__c = 'A';
        else if (con.TipoDocumentoIdentita__c == 'TesseraPostale') con.TipoDocumentoId__c = 'T';
        else if (con.TipoDocumentoIdentita__c == 'Altro10') con.TipoDocumentoId__c = '2';
        //usiamo codice al posto di stringa anche in portale, la traduzione mette label corretta
        con.TipoDocumentoIdentita__c = con.TipoDocumentoId__c;   
        update con;
        
        AdeguataVerifica__c adv = profile.adegVerifica;
        update adv;
        
        update profile.titolariEsecutori;

        return true;
    }
    
    public static UserInfoObj getUserInfo() {
        Contact userContact = [SELECT Id,
                               AccessoEffettuatoTiAnticipo__c
                               FROM Contact
                               WHERE Id = :TiAnticipoUtils.getUserContactId()];
        
        return new UserInfoObj(
            UserInfo.getFirstName(),
            UserInfo.getLastName(),
            UserInfo.getName(),
            UserInfo.getUserName(),
            userContact.AccessoEffettuatoTiAnticipo__c
        );
    }
    
    public static Boolean setAccessoEffettuato(Boolean value) {
        update new Contact(Id = TiAnticipoUtils.getUserContactId(), AccessoEffettuatoTiAnticipo__c = value);
        return true;
    }
}