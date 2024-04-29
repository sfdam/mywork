//IMPORTANTE: lasciare without sharing
public without sharing class TaCtrlRegistrazioneUtenti {
    private static Integer MAX_LENGTH = 131072;
    
    /**
    * Recupera informazioni riguardo ai contatti associati all'account dell'utente Community loggato
    * Per le regole di sicurezza, vede solo i contatti creati da utente community e non tutto quelli esistenti
    * @return   lista dei contatti
    */
    public static Contact[] fetchContacts() {
        //profili certificati vedono tutti i referenti dell'azienda, gli altri sono quelli che hanno creato
        //nascondo il contatto dell'utente community
        //nascondo il centralino (sigh)
        Contact[] contacts = [SELECT Id,
                              CreatedById,
                              AccountId,
                              Name,
                              FirstName,
                              LastName,
                              CF__c,
                              Ruolo__c,
                              Birthdate,
                              LuogoNascita__c,
                              CodCatastaleLocNascita__c,
                              MobilePhone,
                              Email,
                              Sesso__c,
                              ProvinciaNascita__c,
                              SAE__c,
                              TAECode__c,
                              MailingCountry,
                              MailingState,
                              MailingStreetType__c,
                              MailingStreetName__c,
                              MailingStreetNumber__c,
                              MailingCity,
                              MailingPostalCode,
                              TipoDocumentoId__c,
                              NumeroDoc__c,
                              LuogoEmissioneDoc__c,
                              DataEmissioneDoc__c,
                              DataScadenzaDoc__c,
                              EnteEmitettenteDocumento__c,
                              TitolareDefault__c,
                              EsecutoreDefault__c,
                              TipologiaTitolareEffettivo__c,
                              TipoDocumentoIdentita__c,
                              TelefonoPrefisso__c,
                              TelefonoNumero__c,
                              PEP__c,
                              PEPTipoCarica__c,
                              Cittadinanza__c,
                              PaeseNascita__c,
                              Professione__c,
                              PresaVisionePrivacy__c,
                              (SELECT Id, Name, LatestContentVersionId__c FROM Allegati__r)
                              FROM Contact
                              WHERE AccountId = :TiAnticipoUtils.getUserAccountId()
                              AND Id != :TiAnticipoUtils.getUserContactId()
                              AND FirstName != 'Centralino'];
        
        if (!TiAnticipoUtils.isUtenteTitolare()) {
            contacts = U.filter(contacts, 'CreatedById', UserInfo.getUserId());
        }
        
        return contacts;
    }
    
    /**
    * addContactAllegato crea nuovo contatto in CRM/Cedacri e salva documento 
    * viene scatenato da funzionalità portale -> rubrica rappresentanti -> aggiungi rappresentante
    * @param  contatto     JSON dell'oggetto contatto
    * @param  idAttachment idAttachment del documento del contatto
    * @return              esito operazione
    */
    public static Boolean addContactAllegato(String contatto, String idAttachment) {   
        Contact con = (Contact)JSON.deserialize(contatto, Contact.class);
        con.AccountId = TiAnticipoUtils.getUserAccountId();
        System.debug('----- CONTATTO JSON: '+contatto);
        //adione CRM20
        con.NaturaGiuridica__c = 'PF';
        con.MailingPostalCode__c = con.MailingPostalCode;
        con.MailingState__c = con.MailingState;
        con.MailingCity__c = con.MailingCity;
        con.MailingCountry__c = con.MailingCountry;
        con.HomePhone = con.TelefonoPrefisso__c + con.TelefonoNumero__c;
        con.Phone = con.HomePhone;
        //correzione codifica documento in caso di input da portale
		//TipoDocumentoId__c è il campo che usa il CRM e integra con Cedacri: deve usare il codice doc.
        if (con.TipoDocumentoIdentita__c == 'CartaIdentita') con.TipoDocumentoId__c = 'I';
        else if (con.TipoDocumentoIdentita__c == 'Patente') con.TipoDocumentoId__c = 'U';
        else if (con.TipoDocumentoIdentita__c == 'Passaporto') con.TipoDocumentoId__c = 'S';
        else if (con.TipoDocumentoIdentita__c == 'PortoArmi') con.TipoDocumentoId__c = 'A';
        else if (con.TipoDocumentoIdentita__c == 'TesseraPostale') con.TipoDocumentoId__c = 'T';
        else if (con.TipoDocumentoIdentita__c == 'Altro10') con.TipoDocumentoId__c = '2';

		//TipoDocumentoIdentita__c è il campo usato da TiAnticpo e deve rimanere stringa descrittiva
		//altrimenti si rompe il FE di VUE

        //qui potrebbe andare in chiave doppia se esiste già una PF in CRM con lo stesso CF
        //fare un ricerca prima per eventualmente andare in update non serve perché utente community
        //non ha visibilità su contatti del CRM (vede solo quelli di cui è titolare)
        try {
        	upsert con;
            System.debug('----- CONTATTO UPSERT OK');
        } catch (Exception e) {
            //se va in chiave doppia logghiamo errore per recupero manuale...
			//è il caso in cui la PF esiste già in CRM
            if (e.getMessage().indexOf('DUPLICATE_VALUE') != -1) {
                
                System.debug('----- CONTATTO ESISTENTE SU CRM: '+Ex.getReadableMessage(e));
                Log__c l  = new Log__c(
                    Source__c = 'TiAnticipo',
                    CodiceFunzione__c = 'TaCtrlRegistrazioneUtenti.addContactAllegato',
                    ErorrMessage__c = 'CONTATTO ESISTENTE SU CRM' + '\n' + Ex.getReadableMessage(e) + '\n' + e.getStackTraceString(),
                    InputPayload__c = contatto.abbreviate(MAX_LENGTH)
                );
                Logger.log(l); 
				//purtroppo non c'è modo di gestire programmaticamente questa casistica
				//serve creare una PF censita full a titolarità utente community
				//e creare una PF Lead dove eventualmente spostare le attività CRM già presenti

            //altrimenti propaghiamo l'eccezione a FE
            } 
			//blocchiamo utente
			throw e;
        }
        
        //completa operazioni
		completeAddContactAllegato(JSON.serialize(con), idAttachment);

        Log__c l  = new Log__c(
            Source__c = 'TiAnticipo',
            CodiceFunzione__c = 'TaCtrlRegistrazioneUtenti.addContactAllegato',
            InputPayload__c = contatto,
			Contact__c = con.Id,
			NDG__c = con.NDGGruppo__c
        );
        Logger.log(l); 

        return true;          
    }
    
    /**
     * metodo di completamento di "addContactAllegato" 
     * vengono spostate qui attività di callout in modo Future 
     * viene scatenato da "addContactAllegato" 
     */
    @Future(callout=true)
    private static void completeAddContactAllegato(String conSerialized, String idAttachment) {
        try {
            Contact con = (Contact) JSON.deserialize(conSerialized, Contact.class);
            System.debug('----- CONTATTO DA DESER: '+con);
            //cerchiamo PF su Cedacri per verificare se ha già NDG
            List<Contact> res = WsAnagrafeUtils.searchPF(con.CF__c, null, null);        
            if (res.isEmpty()) {
                System.debug('----- CONTATTO NON ESISTENTE SU CEDACRI, PROCEDO A CENSIMENTO');
                //devo censire su Cedacri per ottenere NDG e poter caricare i doc su FileNet
                Account acc = [SELECT Id, NDGGruppo__c FROM Account WHERE Id = :con.AccountId LIMIT 1];
                if (String.isBlank(con.CI3N_CF__c)) con.CI3N_CF__c = '881-'+con.CF__c.trim();
                con.Id = CtrlWizardAccount.WGC_upsertContact(con, acc, new AccountContactRelation[]{}, 'TiAnticipo', 'full');
                System.debug('----- CONTATTO DOPO CENSIMENTO Cedacri: '+con);
            } else if (res.size() != 1) {
                    System.debug('----- PF su Cedacri MAGGIORE di 1!');
                    //non dovremo avere più PF con lo stesso CF su Cedacri!
                    Log__c l  = new Log__c(
                        Source__c = 'TiAnticipo',
                        CodiceFunzione__c = 'TaCtrlRegistrazioneUtenti.addContactAllegato',
                        ErorrMessage__c = 'Più risultati PF trovati su Cedacri per CF '+con.CF__c,
                        InputPayload__c = conSerialized.abbreviate(MAX_LENGTH)
                    );
                    Logger.log(l);
            } else {
                System.debug('----- TROVATA PF CENSITA IN Cedacri, copio NDG');
                //mi prendo NDG del contatto
                con.NDGGruppo__c = res.get(0).NDGGruppo__c;
            }
            
            System.debug('----- CONTATTO PER File Upload: '+JSON.serialize(con));
            //carica doc - il contact passato deve avere NDG
            if (String.isNotBlank(con.NDGGruppo__c)) {
                //update con; //se al metodo chiamante ero andato in chiave doppia, qua non posso chiamare update....
                if (String.isNotBlank(idAttachment)) {
                    //il caricam. doc. è un Future per cui essendo già in un future 
                    //dobbiamo "staccare" un queueable...
                    QueableAllegato q1 = new QueableAllegato(con, idAttachment);
					ID jobID = System.enqueueJob(q1);
                }
            }
            
        } catch (Exception e) {
            Log__c l  = new Log__c(
                Source__c = 'TiAnticipo',
                CodiceFunzione__c = 'TaCtrlRegistrazioneUtenti.completeAddContactAllegato',
                ErorrMessage__c = Ex.getReadableMessage(e) + '\n' + e.getStackTraceString(),
                InputPayload__c = conSerialized.abbreviate(MAX_LENGTH)
            );
            Logger.log(l);            
        }
                
    }
    
    /**
     * classe di utilità per TiAnticipo reg. utenti, delega caricamento doc identificativo PF
     * viene scatenato da "completeAddContactAllegato" 
     **/
    public class QueableAllegato implements Queueable, Database.AllowsCallouts { 
        Contact c;
        String idAttach;
        
        public QueableAllegato(Contact con, String idAttachment) {
            this.c = con;
            this.idAttach = idAttachment;
        }
        
        public void execute(QueueableContext context) {
			TaCtrlRegistrazioneUtenti.salvaDocumentoIdentita(c, idAttach);
        }
    }
    
    /**
    * Modifica un contatto del portale TA
    * @param  	contatto JSON dell'oggetto contatto da modificare
    * @param 	idAttachment eventuale id del documento da allegare
    * @param 	idCessione eventuale Cessione della quale il contatto fa parte
    * @return Booleano per successo dell'operazione
	*/
    @RemoteAction
    public static Boolean modifyContactAllegato(String contatto, String idAttachment, String idCessione) {
        Contact con = (Contact)JSON.deserialize(contatto, Contact.class);
        con.AccountId = TiAnticipoUtils.getUserAccountId();
        //adione-crm20
        con.MailingPostalCode__c = con.MailingPostalCode;
        con.MailingState__c = con.MailingState;
        con.MailingCity__c = con.MailingCity;
        con.MailingCountry__c = con.MailingCountry;
        con.HomePhone = con.TelefonoPrefisso__c + con.TelefonoNumero__c;
        con.Phone = con.HomePhone;
        //correzione codifica documento in caso di input da portale
		//TipoDocumentoId__c è il campo che usa il CRM e integra con Cedacri: deve usare il codice doc.
        if (con.TipoDocumentoIdentita__c == 'CartaIdentita') con.TipoDocumentoId__c = 'I';
        else if (con.TipoDocumentoIdentita__c == 'Patente') con.TipoDocumentoId__c = 'U';
        else if (con.TipoDocumentoIdentita__c == 'Passaporto') con.TipoDocumentoId__c = 'S';
        else if (con.TipoDocumentoIdentita__c == 'PortoArmi') con.TipoDocumentoId__c = 'A';
        else if (con.TipoDocumentoIdentita__c == 'TesseraPostale') con.TipoDocumentoId__c = 'T';
        else if (con.TipoDocumentoIdentita__c == 'Altro10') con.TipoDocumentoId__c = '2';
		//TipoDocumentoIdentita__c è il campo usato da TiAnticpo e deve rimanere stringa descrittiva
		//altrimenti si rompe il FE di VUE
        update con;
        
        if (String.isNotBlank(idCessione)) {
            NDGLinea__c[] titEffL = [SELECT Id
                                     FROM NDGLinea__c
                                     WHERE Contact__c = :con.Id
                                     AND Opportunita__r.Cessione__c = :idCessione
                                     AND Tipo__c = 'Titolare effettivo adeguata verifica'
                                    ];
            if (!titEffL.isEmpty()) {
                update U.massSet(titEffL, 'TipologiaTitolareEffettivo__c', con.TipologiaTitolareEffettivo__c);
            }
        }
        
        if (String.isNotBlank(idAttachment)) salvaDocumentoIdentita(con, idAttachment);

        Log__c l  = new Log__c(
            Source__c = 'TiAnticipo',
            CodiceFunzione__c = 'TaCtrlRegistrazioneUtenti.modifyContactAllegato',
            InputPayload__c = contatto,
			Contact__c = con.Id,
			NDG__c = con.NDGGruppo__c
        );
        Logger.log(l); 
        return true;
    }
    
    /**
     * crea allegato e manda doc. identificativo in FileNet
     **/
    private static void salvaDocumentoIdentita(Contact con, String idAttachment) {
        ContentVersion v = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :idAttachment];
        Allegato__c allegato = new Allegato__c(
            Contact__c = con.Id,
            Tipo__c = con.TipoDocumentoIdentita__c,
            FamigliaDocumento__c = 'Documenti identità'
        );
        allegato.LatestContentVersionId__c = v.Id;
        upsert allegato;
        
        ContentDocumentLink cl = new ContentDocumentLink(
            ContentDocumentId = v.ContentDocumentId,
            LinkedEntityId = allegato.Id,
            ShareType = 'I',
            Visibility = 'AllUsers'
        );
        insert cl;
        //mandiamo il doc in filenet (solo se abbiamo NDG - per gestire eventuali vecchie PF non censite)
        if (String.isNotBlank(con.NDGGruppo__c)) 
        	salvaAllegatoFileNet(con.Id, v.ContentDocumentId);
        
        //adione correzione codifica documento
        //FIX-ME mancano le specificità, p.e. Passporto può esser questura/prefettura/ambasciata/etc etc
        //correzione codifica documento in caso di input da portale
		//TipoDocumentoId__c è il campo che usa il CRM e integra con Cedacri: deve usare il codice doc.
        if (con.TipoDocumentoIdentita__c == 'CartaIdentita') con.TipoDocumentoId__c = 'I';
        else if (con.TipoDocumentoIdentita__c == 'Patente') con.TipoDocumentoId__c = 'U';
        else if (con.TipoDocumentoIdentita__c == 'Passaporto') con.TipoDocumentoId__c = 'S';
        else if (con.TipoDocumentoIdentita__c == 'PortoArmi') con.TipoDocumentoId__c = 'A';
        else if (con.TipoDocumentoIdentita__c == 'TesseraPostale') con.TipoDocumentoId__c = 'T';
        else if (con.TipoDocumentoIdentita__c == 'Altro10') con.TipoDocumentoId__c = '2';
        update con;
		//TipoDocumentoIdentita__c è il campo usato da TiAnticpo e deve rimanere stringa descrittiva
		//altrimenti si rompe il FE di VUE
        
        TaCtrlDocumentazione.chiudiAnomaliaAttore(con.Id);
    }
    
    /**
     * Salve documento su FileNet; assicurarsi che il contact sia censito con NDG attribuito (altrimenti va in errore)
     **/
    @Future(callout=true)
    private static void salvaAllegatoFileNet(String contactId, String fileid) {
        //DOC ESECUTORE / TITEF
        String inizioVal = Date.today().format(); //inizio validità doc
        String fineVal = Date.today().addYears(10).format(); //scadenza doc
        String famiglia = 'Documenti persona fisica'; //'SY0000064';
        String tipoDoc = 'SY0000002';
        String docToInsert = '{"dataProduzione":"'+inizioVal+'","dataScadenza":"'+fineVal+'","famiglia":"'+famiglia+'","tipoDoc":"'+tipoDoc+'","docId":"'+fileid+'"}';
        WGC_FileUploaderController.WrapperResponse wr = WGC_FileUploaderController.uploadDocMultipart(contactId, docToInsert, null, false, 'TiAnticipo');
        if (!wr.success) {
            Logger.createLog(new Log__c(Contact__c=contactId, ErorrMessage__c='errore salvataggio documento in FileNet', InputPayload__c=docToInsert));
        }  
    }
    
    public static Boolean aggiungiAttore(Id idCessione, Id idReferente, String tipo) {
        Cessione__c cessione = [SELECT Id, Account__c FROM Cessione__c WHERE Id = :idCessione];
        Opportunity opty = [SELECT Id, Cessione__c FROM Opportunity WHERE Cessione__c = :idCessione];
        Contact referente = [SELECT Id, TipologiaTitolareEffettivo__c FROM Contact WHERE Id = :idReferente];
        Id rt = U.getRecordTypes('NDGLinea__c').get('Referente').Id;
        
        NDGLinea__c attore = new NDGLinea__c(
            Cessione__c = idCessione,
            Contact__c = idReferente,
            Opportunita__c = opty.Id,
            Tipo__c = tipo, //Titolare effettivo adeguata verifica || Esecutore adeguata verifica
            RecordTypeId = rt
        );
        if (tipo == 'Titolare effettivo adeguata verifica') {
            attore.TipologiaTitolareEffettivo__c = referente.TipologiaTitolareEffettivo__c;
        }
        insert attore;
        
        //create relation with Account and specify role
        AccountContactRelation rel = [
            SELECT Id, WGC_Ruolo__c, WGC_Tipologia_Titolare_Effettivo__c, WGC_Ruolo_Pratica__c
            FROM AccountContactRelation 
            WHERE AccountId = :cessione.Account__c and ContactId = :idReferente
            LIMIT 1];
        
        rel.WGC_Ruolo__c = tipo.containsIgnoreCase('Esecutore') ? 'Z1' : 'J';
        rel.WGC_Ruolo_Pratica__c = rel.WGC_Ruolo__c;
        if (tipo == 'Titolare effettivo adeguata verifica') {
            rel.WGC_Tipologia_Titolare_Effettivo__c = referente.TipologiaTitolareEffettivo__c;
        }
        rel.WGC_Selezionato__c = true; //adione-CRM20 seleziona i referenti per il MAV
        rel.WGC_IsSelected__c = true;
        List<String> selectedRoles = new List<String>(); 
        selectedRoles.add(rel.WGC_Ruolo__c);
        //crea rete in Cedacri
        bifis_crm_c_CommonUtils.runUpdateRole(cessione.Account__c, idReferente, selectedRoles);
        
        return true;
    }
    
    public static Boolean rimuoviAttore(Id idCessione, Id idReferente, String tipo) {
        delete [SELECT Id FROM NDGLinea__c
                WHERE Cessione__c = :idCessione
                AND Contact__c = :idReferente
                AND Tipo__c = :tipo];
        return true;
    }
    
    public static List<NDGLinea__c> fetchAttoriCessione(Id idCessione) {
        List<NDGLinea__c> attori = [SELECT
                                    Tipo__c,
                                    Contact__r.TipologiaTitolareEffettivo__c,
                                    Contact__r.Id,
                                    Contact__r.Name,
                                    Contact__r.FirstName,
                                    Contact__r.LastName,
                                    Contact__r.CF__c,
                                    Contact__r.Ruolo__c,
                                    Contact__r.Birthdate,
                                    Contact__r.LuogoNascita__c,
                                    Contact__r.CodCatastaleLocNascita__c,
                                    Contact__r.MobilePhone,
                                    Contact__r.Email,
                                    Contact__r.Sesso__c,
                                    Contact__r.ProvinciaNascita__c,
                                    Contact__r.SAE__c,
                                    Contact__r.TAECode__c,
                                    Contact__r.MailingCountry,
                                    Contact__r.MailingState,
                                    Contact__r.MailingStreetType__c,
                                    Contact__r.MailingStreetName__c,
                                    Contact__r.MailingStreetNumber__c,
                                    Contact__r.MailingCity,
                                    Contact__r.MailingPostalCode,
                                    Contact__r.TipoDocumentoId__c,
                                    Contact__r.NumeroDoc__c,
                                    Contact__r.LuogoEmissioneDoc__c,
                                    Contact__r.DataEmissioneDoc__c,
                                    Contact__r.DataScadenzaDoc__c,
                                    Contact__r.EnteEmitettenteDocumento__c,
                                    Contact__r.TitolareDefault__c,
                                    Contact__r.EsecutoreDefault__c,
                                    Contact__r.Professione__c,
                                    Contact__r.PaeseNascita__c,
                                    Contact__r.Cittadinanza__c,
                                    Contact__r.TelefonoPrefisso__c,
                                    Contact__r.TelefonoNumero__c,
                                    Contact__r.PEP__c,
                                    Contact__r.PEPTipoCarica__c,
                                    Contact__r.TipoDocumentoIdentita__c,
                                    Contact__r.PresaVisionePrivacy__c,
                                    Contact__r.ConsensoAllaProfilazione__c,
                                    Contact__r.ConsensoAttivitaPromRicercheMercato__c,
                                    Contact__r.ConsensoAttivitaPromozionaleTerzi__c,
                                    Contact__r.ConsensoProdottiBancaRicercheMercato__c,
                                    Contact__r.ConsensoProdottiSocietaTerze__c,
                                    Contact__r.ConsensoSoloModalitaTradizionali__c,
                                    Contact__r.ConsensiPrivacyModificati__c
                                    FROM NDGLinea__c
                                    WHERE Cessione__c = : idCessione];
        return attori;
    }
    
    public static Boolean removeContact(Id idContact) {
        delete new Contact(Id = idContact);
        return true;
    }
}