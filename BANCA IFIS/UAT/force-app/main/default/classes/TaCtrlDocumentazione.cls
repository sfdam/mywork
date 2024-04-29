/**
* Progetto:         Banca IFIS - Ti Anticipo
* Sviluppata il:    04/10/2016
* Developer:        Stefano Brivio
*/

public without sharing class TaCtrlDocumentazione {
    
    private static String DOC_CODICE_CERTIFICAZIONEPDF = 'certificazionePdf';
    private static String DOC_CODICE_FATTURA = 'FATT';
    private static String DOC_TIPO_FATTURA = 'Fattura';
    private static String DOC_CONTRATTO_APPALTO = 'contrapp';
    private static String DOC_REGOLAMENTO_ATI = 'RegolamentoATI';
    private static String DOC_POTERI_DI_FIRMA = 'APP';
    private static String DOC_PRIVACY_PF = 'PrivacyPf';
    private static String DOC_PRIVACY_PG = 'Privacy';
    
    public class InfoDocUpload {
        @AuraEnabled public InfoDoc[] documenti;
        @AuraEnabled public Boolean documentiCaricati;
        
        public InfoDocUpload(InfoDoc[] documenti, Boolean documentiCaricati) {
            this.documenti = documenti;
            this.documentiCaricati = documentiCaricati;
        }
    }
    
    public class InfoDoc {
        @AuraEnabled public String codiceDocumento;
        @AuraEnabled public String name;
        @AuraEnabled public String fileName;
        @AuraEnabled public String descrizione;
        @AuraEnabled public String help;
        @AuraEnabled public Datetime data;
        @AuraEnabled public String tipo;
        @AuraEnabled public String famigliaDocumento;
        @AuraEnabled public String contentVersionId;
        @AuraEnabled public String documentId;
        @AuraEnabled public Boolean required;
        @AuraEnabled public InfoDoc[] docMultipli;
        @AuraEnabled public String descrizioneAnomalia;
        @AuraEnabled public String sottotipoAnomalia;
        @AuraEnabled public Id idAnomalia;
        @AuraEnabled public String nomeAttore;
        
        public InfoDoc(String name, String tipo, String documentId, String help) {
            this.name = name;
            this.tipo = tipo;
            this.documentId = documentId;
            this.help = help;
        }
        
        public InfoDoc(
            String codiceDocumento,
            String name,
            String fileName,
            String descrizione,
            String help,
            Datetime data,
            String tipo,
            String famigliaDocumento,
            String contentVersionId,
            Boolean required
        ) {
            this.codiceDocumento = codiceDocumento;
            this.name = name;
            this.fileName = fileName;
            this.descrizione = descrizione;
            this.help = help;
            this.data = data;
            this.tipo = tipo;
            this.famigliaDocumento = famigliaDocumento;
            this.contentVersionId = contentVersionId;
            this.required = required;
        }
        
        //per doc invalidi
        public InfoDoc(
            String idAnomalia,
            String codiceDocumento,
            String name,
            String fileName,
            String descrizione,
            String help,
            String tipo,
            String famigliaDocumento,
            String contentVersionId,
            String descrizioneAnomalia,
            String sottotipoAnomalia,
            String nomeAttore
        ) {
            this.idAnomalia = idAnomalia;
            this.codiceDocumento = codiceDocumento;
            this.name = name;
            this.fileName = fileName;
            this.descrizione = descrizione;
            this.help = help;
            this.tipo = tipo;
            this.famigliaDocumento = famigliaDocumento;
            this.contentVersionId = contentVersionId;
            this.descrizioneAnomalia = descrizioneAnomalia;
            this.sottotipoAnomalia = sottotipoAnomalia;
            this.nomeAttore = nomeAttore;
        }
    }
    
    //mi paicerebbe fare le cose bene, ma non ho tempo
    public static String getFoglioInformativoDownload() {
        // Il timestamp è aggiunto per evitare problemi di caching del file
        return EndpointServizi__c.getInstance('settings').UrlDocumentiTaStatici__c + '/app/uploads/2022/01/2022.01.01_Rilevazione-tassi-interesse-effettivi.pdf';
    }
    
    public static InfoDoc[] getDocumentiDownload() {
        return getDocumentiDownload(null);
    }
    
    //lista documenti nella pagina "scarica e firma i documenti"
    //l'icona di download è disattivata perchè si usa bottone "scarica tutti e procedi"
    public static InfoDoc[] getDocumentiDownload(Id cessioneId) {
        Cessione__c cess = [SELECT ConsensiPrivacyDaMostrareEsecutore__c,
                            ConsensiPrivacyDaMostrareAzienda__c
                            FROM Cessione__c
                            WHERE Id = :cessioneId];
        
        String[] documentiDaEscludere = new String[] { };
            
            // Se è specificata una cessione controllo se è necessario scaricare i moduli privacy legati all'azienda e all'esecutore
            if (cessioneId != null) {
                NDGLinea__c[] esecutori = [SELECT
                                           Contact__r.ConsensiPrivacyDaCaricare__c,
                                           Cessione__r.Account__r.ConsensiPrivacyDaCaricare__c
                                           FROM NDGLinea__c
                                           WHERE Cessione__c = :cessioneId
                                           AND Tipo__c = 'Esecutore adeguata verifica'];
                if (esecutori.size() == 1) {
                    if (!esecutori[0].Contact__r.ConsensiPrivacyDaCaricare__c && !cess.ConsensiPrivacyDaMostrareEsecutore__c) documentiDaEscludere.add(DOC_PRIVACY_PF);
                    if (!esecutori[0].Cessione__r.Account__r.ConsensiPrivacyDaCaricare__c && !cess.ConsensiPrivacyDaMostrareAzienda__c) documentiDaEscludere.add(DOC_PRIVACY_PG);
                }
            }
        //documenti precompilati con dati del cliente
        InfoDoc[] result = getDocumentiDinamiciDownload(null, documentiDaEscludere);
        //documenti statici informativi della banca (aggiornati periodicamente)
        ParametriTiAnticipo__c params = ParametriTiAnticipo__c.getOrgDefaults();
        result.add(new InfoDoc('Scarica e prendi visione della Guida all\'Arbitro Finanziario', null, params.IDArbitroBancarioFinanziario__c, null));
        result.add(new InfoDoc('Scarica e prendi visione del Foglio Informativo', null, params.IDFoglioInformativo__c, null));
        result.add(new InfoDoc('Scarica e prendi visione del documento di Rilevazione dei tassi di interesse globali medi', null, params.IDTassi__c, null));
        
        return result;
    }
    
    public static InfoDoc[] getDocumentiDinamiciDownload(String[] codiceDocumento) {
        return getDocumentiDinamiciDownload(codiceDocumento, null);
    }
    
    /**
* Recupera i documenti generati e precompilati da Salesforce da scaricare.
* Corrispondono ai documenti presenti nella matrice TiAnticipoDocumenti (visibili e download) e quelli elencati
* nel parametro codiceDocumento
* @param  codiceDocumento
* @return
*/
    public static InfoDoc[] getDocumentiDinamiciDownload(String[] codiceDocumento, String[] codiceDocumentoDaEscludere) {
        InfoDoc[] result = new InfoDoc[] { };
            
            QueryBuilder.FilterBuilder qb = QueryBuilder.newInstance(
                'TiAnticipoDocumenti__mdt',
                new String[] {
                    'Label',
                        'DescrizioneDownload__c',
                        'DeveloperName',
                        'Help__c',
                        'Ordine__c'
                        })
            .beginFilter()
            .add('Visibile__c', QBOp.QEQUAL, true)
            .add('Download__c', QBOp.QEQUAL, true);
        
        if (codiceDocumentoDaEscludere != null && !codiceDocumentoDaEscludere.isEmpty()) qb.add('DeveloperName', QBOp.QNOT_IN, codiceDocumentoDaEscludere);
        if (codiceDocumento != null && !codiceDocumento.isEmpty()) qb.add('DeveloperName', QBOp.QIN, codiceDocumento);
        
        String query = qb.endFilter()
            .orderBy(new String[] { 'Ordine__c' })
            .getQuery();
        
        List<TiAnticipoDocumenti__mdt> docs = Database.query(query);
        for (TiAnticipoDocumenti__mdt d : docs) {
            result.add(new InfoDoc(d.DescrizioneDownload__c, d.DeveloperName, null, d.Help__c));
        }
        
        return result;
    }
    
    public static Boolean deleteDocument(Id contentVersionId) {
        ContentVersion doc = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id = :contentVersionId];
        delete new ContentDocument(Id = doc.ContentDocumentId);
        return true;
    }
    
    /**
* Recupera la lista dei documenti da caricare sul portale.
* Corrisponde ai documenti presenti nella matrice TiAnticipoDocumenti (visibili e upload).
* Nel caso in cui una certificazione sia flaggata ATI sono recuperati anche i Contratti d'appalto e il Regolamento ATI.
* I documenti di Privacy Azienda ed Esecutore sono da caricare sul portale in base al flag "ConsensiPrivacyDaCaricare" presente su Account/Contact.
* @param  idCessione
* @return
*/
    public static InfoDocUpload getDocumentiUpload(Id idCessione) {
        Cessione__c cess = [SELECT ConsensiPrivacyDaMostrareEsecutore__c,
                            ConsensiPrivacyDaMostrareAzienda__c
                            FROM Cessione__c
                            WHERE Id = :idCessione];
        
        InfoDoc[] result = new InfoDoc[] { };
            Boolean documentiCaricati = true;
        
        TiAnticipoDocumenti__mdt[] metaDoc = [SELECT Label,
                                              DeveloperName,
                                              DescrizioneUpload__c,
                                              Help__c,
                                              FamigliaDocumento__c,
                                              Ordine__c,
                                              Tipo__c,
                                              Visibile__c,
                                              Required__c,
                                              UploadMultiplo__c
                                              FROM TiAnticipoDocumenti__mdt
                                              WHERE(
                                                  Visibile__c = true
                                                  AND Upload__c = true)
                                              ORDER BY Ordine__c];
        
        metaDoc.addAll([SELECT Label,
                        DeveloperName,
                        DescrizioneUpload__c,
                        Help__c,
                        FamigliaDocumento__c,
                        Ordine__c,
                        Tipo__c,
                        Visibile__c,
                        Required__c,
                        UploadMultiplo__c
                        FROM TiAnticipoDocumenti__mdt
                        WHERE DeveloperName = :DOC_CONTRATTO_APPALTO]);
        
        metaDoc.addAll([SELECT Label,
                        DeveloperName,
                        DescrizioneUpload__c,
                        Help__c,
                        FamigliaDocumento__c,
                        Ordine__c,
                        Tipo__c,
                        Visibile__c,
                        Required__c,
                        UploadMultiplo__c
                        FROM TiAnticipoDocumenti__mdt
                        WHERE DeveloperName = :DOC_REGOLAMENTO_ATI]);
        
        Integer numCertificazioniAti = [SELECT count()
                                        FROM Certificazione__c
                                        WHERE ATI__c = true
                                        AND Cessione__c = :idCessione];
        
        Map<String, Allegato__c[]> allDoc = U.groupBy(
            [SELECT Id,
             CodiceDocumentoTiAnticipo__c,
             LastModifiedDate,
             LatestContentVersionId__c,
             NomeFile__c
             FROM Allegato__c
             WHERE Cessione__c = : idCessione],
            'CodiceDocumentoTiAnticipo__c'
        );
        
        // Controllo se è necessario scaricare e caricare i moduli privacy legati all'azienda e all'esecutore
        Set<String> documentiDaEscludere = new Set<String> ();
        NDGLinea__c[] esecutori = [SELECT
                                   Contact__r.ConsensiPrivacyDaCaricare__c,
                                   Cessione__r.Account__r.ConsensiPrivacyDaCaricare__c
                                   FROM NDGLinea__c
                                   WHERE Cessione__c = :idCessione
                                   AND Tipo__c = 'Esecutore adeguata verifica'];
        
        Map<String, Allegato__c[]> docPrivacyPresenti = U.groupBy([SELECT Id,
                                                                   Tipo__c
                                                                   FROM Allegato__c
                                                                   WHERE(Cessione__c = :idCessione
                                                                         OR Opportunita__r.Cessione__c = :idCessione)
                                                                   AND Tipo__c IN('PrivacyFirm', 'PrivacyPfFirm')], 'Tipo__c');
        System.debug('docPrivacyPresenti: ' + JSON.serialize(docPrivacyPresenti));
        if (esecutori.size() == 1) {
            if (!esecutori[0].Contact__r.ConsensiPrivacyDaCaricare__c && !cess.ConsensiPrivacyDaMostrareEsecutore__c) documentiDaEscludere.add(DOC_PRIVACY_PF);
            if (!esecutori[0].Cessione__r.Account__r.ConsensiPrivacyDaCaricare__c && !cess.ConsensiPrivacyDaMostrareAzienda__c) documentiDaEscludere.add(DOC_PRIVACY_PG);
            Allegato__c[] allToDelete = new Allegato__c[] { };
                if (esecutori[0].Contact__r.ConsensiPrivacyDaCaricare__c && docPrivacyPresenti.containsKey('PrivacyPfFirm')) allToDelete.addAll(docPrivacyPresenti.get('PrivacyPfFirm'));
            if (esecutori[0].Cessione__r.Account__r.ConsensiPrivacyDaCaricare__c && docPrivacyPresenti.containsKey('PrivacyFirm')) allToDelete.addAll(docPrivacyPresenti.get('PrivacyFirm'));
            System.debug('allToDelete: ' + JSON.serialize(allToDelete));
            if (!allToDelete.isEmpty()) delete allToDelete;
        }
        
        // Creo ora la lista di documenti da caricare
        for (TiAnticipoDocumenti__mdt md : metaDoc) {
            if ((md.DeveloperName == DOC_CONTRATTO_APPALTO || md.DeveloperName == DOC_REGOLAMENTO_ATI) && numCertificazioniAti == 0) continue;
            if (documentiDaEscludere.contains(md.DeveloperName)) continue;
            Allegato__c a = (allDoc.containsKey(md.DeveloperName)) ? allDoc.get(md.DeveloperName) [0] : null;
            
            InfoDoc d = new InfoDoc(
                md.DeveloperName, // codiceDocumento
                md.Label, // name
                a != null ? a.NomeFile__c : null, // fileName
                md.DescrizioneUpload__c, // descrizione
                md.Help__c, // help
                a != null ? a.LastModifiedDate : null, // data
                md.Tipo__c, // tipo
                md.FamigliaDocumento__c, // famigliaDocumento
                a != null ? a.LatestContentVersionId__c : null, // contentVersionId
                md.Required__c // required
            );
            
            // per alcuni documenti restituiamo n record
            if (md.UploadMultiplo__c && allDoc.containsKey(md.DeveloperName)) {
                InfoDoc[] tmp = new InfoDoc[] { };
                    for (Allegato__c f : allDoc.get(md.DeveloperName)) {
                        tmp.add(new InfoDoc(f.NomeFile__c, md.Tipo__c, f.LatestContentVersionId__c, null));
                    }
                d.docMultipli = tmp;
            }
            
            result.add(d);
            
            if (md.Required__c == true) documentiCaricati = documentiCaricati && a != null;
        }
        return new InfoDocUpload(result, documentiCaricati);
    }
    
    public static void documentiPrivacyCaricati(Id idCessione) {
        NDGLinea__c[] esecutori = [SELECT
                                   Contact__c,
                                   Cessione__r.Account__c
                                   FROM NDGLinea__c
                                   WHERE Cessione__c = :idCessione
                                   AND Tipo__c = 'Esecutore adeguata verifica'];
        system.debug('-----> esecutori size: '+esecutori.size());
        if (esecutori.size() == 1) {
            update new Contact(Id = esecutori[0].Contact__c, ConsensiPrivacyModificati__c = false);
            update new Account(Id = esecutori[0].Cessione__r.Account__c, ConsensiPrivacyModificati__c = false);
        }
    }
    
    @RemoteAction
    public static Boolean salvaAllegatoCessione(
        String codiceDocumento,
        String famigliaDocumento,
        String idAttachment,
        String idCessione,
        String tipo
    ) {
        return salvaAllegato(
            codiceDocumento,
            famigliaDocumento,
            idAttachment,
            idCessione,
            tipo
        );
    }
    
    @RemoteAction
    public static Boolean salvaCertificazione(String idAttachment, String idCessione) {
        Id idCertificazione = inserisciCertificazione(idAttachment, idCessione);
        
        salvaAllegatoCertificazione(
            idCessione,
            idCertificazione,
            idAttachment,
            'Documentazione cliente',
            'Certificazione'
        );
        
        return true;
    }
    
    @TestVisible
    private static Boolean salvaAllegatoCertificazione(
        Id idCessione,
        Id idCertificazione,
        String idAttachment,
        String famigliaDocumento,
        String tipo
    ) {
        Opportunity opp = [SELECT Id
                           FROM Opportunity
                           WHERE Cessione__c = :idCessione];
        
        ContentVersion v = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :idAttachment];
        
        Allegato__c allegato = new Allegato__c(
            Cessione__c = idCessione,
            Certificazione__c = idCertificazione,
            Opportunita__c = opp.Id,
            CodiceDocumentoTiAnticipo__c = DOC_CODICE_CERTIFICAZIONEPDF,
            FamigliaDocumento__c = famigliaDocumento,
            Tipo__c = tipo
        );
        insert allegato;
        
        ContentDocumentLink cl = new ContentDocumentLink(
            ContentDocumentId = v.ContentDocumentId,
            LinkedEntityId = allegato.Id,
            ShareType = 'I'
        );
        if (tipo == 'PrivacyFirm' || tipo == 'PrivacyPfFirm' || famigliaDocumento == 'Documenti identità') cl.Visibility = 'AllUsers';
        insert cl;
        
        return true;
    }
    
    private static Boolean salvaAllegato(
        String codiceDocumento,
        String famigliaDocumento,
        String idAttachment,
        String idCessione,
        String tipo
    ) {
        //recupero l'opportunità legata a questa cessione
        Opportunity opp = [SELECT Id,
                           AccountId,
                           Account.ConsensiPrivacyModificati__c
                           FROM Opportunity
                           WHERE Cessione__c = :idCessione];
        
        //recupero il cv del documento da salvare
        ContentVersion v = [SELECT ContentDocumentId, VersionData, Title, PathOnClient FROM ContentVersion WHERE Id = :idAttachment];
        //recupero tutti gli allegati legati a questa cessione per quel tipo di documento da caricare
        Allegato__c[] allegati = [SELECT Id
                                  FROM Allegato__c
                                  WHERE Cessione__c = :idCessione
                                  AND CodiceDocumentoTiAnticipo__c = :codiceDocumento];
        
        Allegato__c allegato;
        //controllo la configurazione dei documenti che possono esser più file
        Set<String> documentiMultipli = U.getSet([SELECT DeveloperName
                                                  FROM TiAnticipoDocumenti__mdt
                                                  WHERE UploadMultiplo__c = true], 'DeveloperName');
        //il documento che carichiamo non è multiplo e ci son già versioni caricate
        if (!documentiMultipli.contains(codiceDocumento) && allegati.size() > 0) {
            allegato = allegati[0];
            
            Set<Id> linkIdSet = U.getIdSet(
                [SELECT Id, ContentDocumentId
                 FROM ContentDocumentLink
                 WHERE LinkedEntityId = : allegato.Id],
                'ContentDocumentId');
            //rimuoviamo versione precedente
            TrgContentDocument.skipCancellaAllegati = true;
            delete[SELECT Id
                   FROM ContentDocument
                   WHERE Id IN : linkIdSet];
        } else { //nuovo documento da caricare oppure documento multiplo
            allegato = new Allegato__c(
                Cessione__c = idCessione,
                Opportunita__c = opp.Id,
                Tipo__c = tipo,
                FamigliaDocumento__c = famigliaDocumento,
                CodiceDocumentoTiAnticipo__c = codiceDocumento
            );
        }
        //aggiorniamo documento caricato
        allegato.NomeFile__c = v.Title;
        allegato.LatestContentVersionId__c = v.Id;
        upsert allegato;
        
        ContentDocumentLink cl = new ContentDocumentLink(
            ContentDocumentId = v.ContentDocumentId,
            LinkedEntityId = allegato.Id,
            ShareType = 'I'
        );
        if (tipo == 'PrivacyFirm' || tipo == 'PrivacyPfFirm' || famigliaDocumento == 'Documenti identità') cl.Visibility = 'Allusers';
        insert cl;
        
        // Se il documento caricato è la privacy firmata, aggiorno l'Allegato associato all'account / esecutore
        // e segnalo che i consensi privacy sull'account / esecutore non sono più modificati
        Allegato__c allPrincipale;
        if (tipo == 'PrivacyFirm') {
            if (opp.Account.ConsensiPrivacyModificati__c) update new Account(Id = opp.AccountId, ConsensiPrivacyModificati__c = false);
            
            Allegato__c[] allList = [SELECT Id
                                     FROM Allegato__c
                                     WHERE Account__c = :opp.AccountId
                                     AND Opportunita__c = null
                                     AND Cessione__c = null
                                     AND Tipo__c = :tipo
                                    ];
            if (allList.size() == 1) {
                allPrincipale = allList[0];
            } else {
                allPrincipale = new Allegato__c(
                    Account__c = opp.AccountId,
                    Tipo__c = tipo,
                    FamigliaDocumento__c = famigliaDocumento
                );
                insert allPrincipale;
            }
        }
        
        if (tipo == 'PrivacyPfFirm') {
            NDGLinea__c esecutore = [SELECT Id,
                                     Contact__c,
                                     Contact__r.ConsensiPrivacyModificati__c
                                     FROM NDGLinea__c
                                     WHERE Opportunita__c = :opp.Id
                                     AND Tipo__c = 'Esecutore Adeguata Verifica'];
            if (esecutore.Contact__r.ConsensiPrivacyModificati__c) update new Contact(Id = esecutore.Contact__c, ConsensiPrivacyModificati__c = false);
            
            Allegato__c[] allList = [SELECT Id
                                     FROM Allegato__c
                                     WHERE Contact__c = :esecutore.Contact__c
                                     AND Opportunita__c = null
                                     AND Cessione__c = null
                                     AND Tipo__c = :tipo
                                    ];
            
            if (allList.size() == 1) {
                allPrincipale = allList[0];
            } else {
                allPrincipale = new Allegato__c(
                    Contact__c = esecutore.Contact__c,
                    Tipo__c = tipo,
                    FamigliaDocumento__c = famigliaDocumento
                );
                insert allPrincipale;
            }
        }
        
        if (tipo == 'PrivacyFirm' || tipo == 'PrivacyPfFirm') {
            ContentDocumentLink[] cdls = [SELECT ContentDocumentId,
                                          LinkedEntityId,
                                          ShareType
                                          FROM ContentDocumentLink
                                          WHERE LinkedEntityId = :allPrincipale.Id];
            
            ContentVersion cv = new ContentVersion(VersionData = v.VersionData, Title = v.Title, PathOnClient = v.PathOnClient);
            
            if (cdls.size() == 1) {
                cv.ContentDocumentId = cdls[0].ContentDocumentId;
            }
            
            insert cv;
            
            if (cdls.isEmpty()) {
                cv = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id];
                insert new ContentDocumentLink(
                    LinkedEntityId = allPrincipale.Id,
                    ContentDocumentId = cv.ContentDocumentId,
                    ShareType = 'I',
                    Visibility = 'AllUsers'
                );
            }
        }
        
        //andiamo a caricare il documento su FileNet
        salvaAllegatoFileNet(codiceDocumento, famigliaDocumento, opp.Id, opp.AccountId, v.ContentDocumentId);
        
        return true;
    }
    
    @Future(callout = true)
    private static void salvaAllegatoFileNet(String codiceDocumento, String famigliaDocumento, String oppId, String accId, String fileid) {
        System.debug('-----> salvaAllegatoFileNet - codDoc: ' + codiceDocumento + ', famDoc: ' + famigliaDocumento + ', oppId: ' + oppId + ', accId: ' + accId);
        String inizioVal = Date.today().format(); //inizio validità doc
        String fineVal = Date.today().addDays(30).format(); //scadenza doc
        String famiglia, tipoDoc;
        Boolean delDoc = false; //non rimuovere doc da SFD, così é sempre recuperabile in caso di problemi filenet
        
        if (codiceDocumento == 'RSF') { //RSF
            famiglia = 'Documenti finanziari'; //'EX0010028';
            tipoDoc = 'NV0000002';
            fineVal = Date.today().addMonths(3).format();
            String docToInsert = '{"dataProduzione":"' + inizioVal + '","dataScadenza":"' + fineVal + '","famiglia":"' + famiglia + '","tipoDoc":"' + tipoDoc + '","docId":"' + fileid + '"}';
            WGC_FileUploaderController.WrapperResponse wr = WGC_FileUploaderController.uploadDocMultipart(accId, docToInsert, oppId, delDoc, 'TiAnticipo');
            if (!wr.success) {
                Logger.createLog(new Log__c(Source__c = 'TiAnticipo', CodiceFunzione__c = 'TaCtrlDocumentazione.salvaAllegatoFileNet', Account__c = accId, Opportunity__c = oppId, ErorrMessage__c = 'errore salvataggio documento in FileNet', InputPayload__c = docToInsert));
            }
        }
        
        if (codiceDocumento == 'MAV') { //MAV
            famiglia = 'Identificazione clientela'; //'NV0000001';
            tipoDoc = 'EX0000173';
            fineVal = Date.today().addYears(1).format(); //scadenza 1 anno
            String docToInsert = '{"dataProduzione":"' + inizioVal + '","dataScadenza":"' + fineVal + '","famiglia":"' + famiglia + '","tipoDoc":"' + tipoDoc + '","docId":"' + fileid + '"}';
            WGC_FileUploaderController.WrapperResponse wr = WGC_FileUploaderController.uploadDocMultipart(accId, docToInsert, oppId, delDoc, 'TiAnticipo');
            if (!wr.success) {
                Logger.createLog(new Log__c(Source__c = 'TiAnticipo', CodiceFunzione__c = 'TaCtrlDocumentazione.salvaAllegatoFileNet', Account__c = accId, Opportunity__c = oppId, ErorrMessage__c = 'errore salvataggio documento in FileNet', InputPayload__c = docToInsert));
            }
        }
        
        if (codiceDocumento == 'ModuloTecnicheDiComunicazione') { //MTC
            famiglia = 'Identificazione clientela'; //'NV0000001';
            tipoDoc = 'EX0000179';
            fineVal = Date.today().addYears(10).format(); //scadenza 10 anni
            String docToInsert = '{"dataProduzione":"' + inizioVal + '","dataScadenza":"' + fineVal + '","famiglia":"' + famiglia + '","tipoDoc":"' + tipoDoc + '","docId":"' + fileid + '"}';
            WGC_FileUploaderController.WrapperResponse wr = WGC_FileUploaderController.uploadDocMultipart(accId, docToInsert, oppId, delDoc, 'TiAnticipo');
            if (!wr.success) {
                Logger.createLog(new Log__c(Source__c = 'TiAnticipo', CodiceFunzione__c = 'TaCtrlDocumentazione.salvaAllegatoFileNet', Account__c = accId, Opportunity__c = oppId, ErorrMessage__c = 'errore salvataggio documento in FileNet', InputPayload__c = docToInsert));
            }
        }
        
        if (codiceDocumento == 'APP') { //ATTO COSTITUTIVO-POTERI DI FIRMA
            famiglia = 'Documentazione societaria'; //'EX0010023';
            tipoDoc = 'EX0000185';
            fineVal = Date.today().addYears(10).format();
            String docToInsert = '{"dataProduzione":"' + inizioVal + '","dataScadenza":"' + fineVal + '","famiglia":"' + famiglia + '","tipoDoc":"' + tipoDoc + '","docId":"' + fileid + '"}';
            WGC_FileUploaderController.WrapperResponse wr = WGC_FileUploaderController.uploadDocMultipart(accId, docToInsert, oppId, delDoc, 'TiAnticipo');
            if (!wr.success) {
                Logger.createLog(new Log__c(Source__c = 'TiAnticipo', CodiceFunzione__c = 'TaCtrlDocumentazione.salvaAllegatoFileNet', Account__c = accId, Opportunity__c = oppId, ErorrMessage__c = 'errore salvataggio documento in FileNet', InputPayload__c = docToInsert));
            }
        }
        
        if (codiceDocumento == 'durc') { //DURC
            //famiglia = 'Regolarità contributiva'; //per qualche motivo usare la stringa non viene riconosciuto
            famiglia = [SELECT tolabel(Sottoclasse__c)
                        FROM WGC_Metadati_Documentale__mdt
                        WHERE toLabel(Documento__c) = 'EX0000143'
                        LIMIT 1].Sottoclasse__c;
            tipoDoc = 'EX0000143';
            fineVal = Date.today().addMonths(4).format();
            String docToInsert = '{"dataProduzione":"' + inizioVal + '","dataScadenza":"' + fineVal + '","famiglia":"' + famiglia + '","tipoDoc":"' + tipoDoc + '","docId":"' + fileid + '"}';
            WGC_FileUploaderController.WrapperResponse wr = WGC_FileUploaderController.uploadDocMultipart(accId, docToInsert, oppId, delDoc, 'TiAnticipo');
            if (!wr.success) {
                Logger.createLog(new Log__c(Source__c = 'TiAnticipo', CodiceFunzione__c = 'TaCtrlDocumentazione.salvaAllegatoFileNet', Account__c = accId, Opportunity__c = oppId, ErorrMessage__c = 'errore salvataggio documento in FileNet', InputPayload__c = docToInsert));
            }
        }
        
        if (codiceDocumento == 'FATT') { //FATTURE
            famiglia = 'Documenti credito';
            tipoDoc = 'EX0000187';
            fineVal = Date.today().addYears(1).format();
            String docToInsert = '{"dataProduzione":"' + inizioVal + '","dataScadenza":"' + fineVal + '","famiglia":"' + famiglia + '","tipoDoc":"' + tipoDoc + '","docId":"' + fileid + '"}';
            WGC_FileUploaderController.WrapperResponse wr = WGC_FileUploaderController.uploadDocMultipart(accId, docToInsert, oppId, delDoc, 'TiAnticipo');
            if (!wr.success) {
                Logger.createLog(new Log__c(Source__c = 'TiAnticipo', CodiceFunzione__c = 'TaCtrlDocumentazione.salvaAllegatoFileNet', Account__c = accId, Opportunity__c = oppId, ErorrMessage__c = 'errore salvataggio documento in FileNet', InputPayload__c = docToInsert));
            }
        }
        
        if (codiceDocumento == 'Privacy') { //Privacy PG
            famiglia = 'Identificazione clientela';
            tipoDoc = 'EX0000200';
            fineVal = Date.today().addYears(10).format();
            String docToInsert = '{"dataProduzione":"' + inizioVal + '","dataScadenza":"' + fineVal + '","famiglia":"' + famiglia + '","tipoDoc":"' + tipoDoc + '","docId":"' + fileid + '"}';
            WGC_FileUploaderController.WrapperResponse wr = WGC_FileUploaderController.uploadDocMultipart(accId, docToInsert, oppId, delDoc, 'TiAnticipo');
            if (!wr.success) {
                Logger.createLog(new Log__c(Source__c = 'TiAnticipo', CodiceFunzione__c = 'TaCtrlDocumentazione.salvaAllegatoFileNet', Account__c = accId, Opportunity__c = oppId, ErorrMessage__c = 'errore salvataggio documento in FileNet', InputPayload__c = docToInsert));
            }
        }
        
        if (codiceDocumento == 'PrivacyPf') { //Privacy PF
            //idealmente è uno ma non possiamo fidarci di quanto inserito da utente di portale, in caso logghiamo
            Id conId = null;
            List<Contact> titolariEsecutori = TaCtrlRegistrazioneUtenti.fetchContacts();
            if (titolariEsecutori.isEmpty()) {
                Logger.createLog(new Log__c(Source__c = 'TiAnticipo', CodiceFunzione__c = 'TaCtrlDocumentazione.salvaAllegatoFileNet', Account__c = accId, Opportunity__c = oppId, ErorrMessage__c = 'Non trovati esecutori'));
                return;
                
            } else if (titolariEsecutori.size() > 1) {
                Logger.createLog(new Log__c(Source__c = 'TiAnticipo', CodiceFunzione__c = 'TaCtrlDocumentazione.salvaAllegatoFileNet', Account__c = accId, Opportunity__c = oppId, ErorrMessage__c = 'Trovato più di un esecutore'));
                return;
                
            } else {
                conId = titolariEsecutori.get(0).Id;
            }
            
            famiglia = 'Documenti persona fisica';
            tipoDoc = 'SY0000074';
            fineVal = Date.today().addYears(10).format();
            String docToInsert = '{"dataProduzione":"' + inizioVal + '","dataScadenza":"' + fineVal + '","famiglia":"' + famiglia + '","tipoDoc":"' + tipoDoc + '","docId":"' + fileid + '"}';
            //FIXME dobbiamo passare id esecutore e non dell'account
            WGC_FileUploaderController.WrapperResponse wr = WGC_FileUploaderController.uploadDocMultipart(conId, docToInsert, oppId, delDoc, 'TiAnticipo');
            if (!wr.success) {
                Logger.createLog(new Log__c(Source__c = 'TiAnticipo', CodiceFunzione__c = 'TaCtrlDocumentazione.salvaAllegatoFileNet', Account__c = accId, Opportunity__c = oppId, ErorrMessage__c = 'errore salvataggio documento in FileNet', InputPayload__c = docToInsert));
            }
        }
    }
    
    private static Id inserisciCertificazione(Id idAttachment, String idCessione) {
        ContentVersion cv = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :idAttachment];
        WsRestPdfParser.ParseCertificazioneResponse response = WsRestPdfParser.parseCertificazione(cv.ContentDocumentId);
        
        if (!response.isCorrect())
            throw new Ex.GenericException('Non è stato possibile analizzare il pdf.');
        
        eliminaCertificazionePrecedente(idCessione, response.payload.numeroCertificazione);
        
        return inserisciCertificazioneConFatture(idCessione, idAttachment, response.payload);
    }
    
    private static void eliminaCertificazionePrecedente(Id idCessione, String numeroCertificazione) {
        Certificazione__c[] existing = [SELECT Id
                                        FROM Certificazione__c
                                        WHERE CodiceCertificazione__c = :numeroCertificazione
                                        AND Cessione__c = :idCessione];
        if (existing.size() > 0) delete existing;
    }
    
    private static Id inserisciCertificazioneConFatture(Id idCessione, Id idAttachment, WsRestPdfParser.DatiCrediti datiCertificazione) {
        System.debug('SV inserisciCertificazioneConFatture');
        Account acc = [SELECT Id, CF__c FROM Account WHERE Id = :TiAnticipoUtils.getUserAccountId()];
        
        //l'utente di portale deve essere titolare TA dell'Account oppure non c'è nessun titolare e lo assegniamo all'utente corrente
        if (!TiAnticipoUtils.isUtenteTitolare() && !TiAnticipoUtils.setUtenteTitolare()) {
            throw new Ex.GenericException('Gentile cliente, ci risulta che la tua azienda abbia già un utenza abilitata al portale. Contatta la banca per maggiori informazioni.');
        }
        
        //verifichiamo che il doc caricato corrisponda all'Account TA
        if (datiCertificazione.pivaOrCf != acc.CF__c) {
            throw new Ex.GenericException('La certificazione caricata non è relativa alla propria società');
        }
        
        ContentVersion fileCert = [SELECT Title FROM ContentVersion WHERE Id = :idAttachment];
        
        Certificazione__c certificazione = new Certificazione__c(
            Name = fileCert.Title,
            Cessione__c = idCessione,
            IdFileCertificazione__c = IdAttachment,
            AmmontareComplessivoCredito__c = datiCertificazione.getAmmontareComplessivoCredito(),
            CodiceCertificazione__c = datiCertificazione.numeroCertificazione,
            DataPagamento__c = datiCertificazione.getDataPagamento(),
            ImportoCertificato__c = datiCertificazione.getImportoCertificato(),
            RagioneSocialeDebitore__c = datiCertificazione.debitore
        );
        insert certificazione;
        
        Fattura__c[] fatture = new Fattura__c[] { };
            for (WsRestPdfParser.Fattura f : datiCertificazione.fatture) {
                if (f.getImportoRiconosciuto() > 0) {
                    fatture.add(
                        new Fattura__c(
                            CertificazioneParent__c = certificazione.Id,
                            DataFattura__c = f.getData(),
                            ImportoFattura__c = f.getImporto(),
                            ImportoFatturaCertificato__c = f.getImportoRiconosciuto(),
                            NumeroFattura__c = f.numeroFattura
                        )
                    );
                }
            }
        insert fatture;
        
        return certificazione.Id;
    }
    
    public static Id generaDocumentazione(String idOpportunity, String tipo) {
        if (tipo=='MAV') {
            return '06926000000oza5AAA';
        } else {
            Id idContentDoc = ExtViewChecklist.generaDocumentazione(idOpportunity, tipo);
            ContentDocument cd = [SELECT Id, LatestPublishedVersionId FROM ContentDocument WHERE Id = :idContentDoc];
            return cd.LatestPublishedVersionId;
        }
    }
    
    /**
* Crea gli URL del sito pubblico TiAnticipo da cui scaricare i documenti statici
* questo metodo è chiamato al click del bottone "scarica tutti e procedi"
* @return   url dei documenti statici da scaricare
*/
    public static String[] generaDocumentazioneStatica() {
        String[] result = new String[] { };
            String endpoint = EndpointServizi__c.getInstance('settings').UrlDocumentiTaStatici__c;
        // Il timestamp è aggiunto per evitare problemi di caching del file
        Long currentTime = Datetime.now().getTime();
        /* originale ADIONE
result.add(endpoint + '/FoglioInformativo.pdf?T=' + currentTime);
result.add(endpoint + '/RilevazioneTassiInteresseEffettivi.pdf?T=' + currentTime);
result.add(endpoint + '/ArbitroBancarioFinanziario.pdf?T=' + currentTime);
*/ //non ritorno nulla e sposto gli statici nei dinamici
        
        return result;
    }
    
    /**
* Recupera la lista dei documenti da ri-caricare sul portale, a seguito di anomalie.
* @param  idCessione
* @return
*/
    public static InfoDoc[] getDocumentiAnomali(Id idCessione) {
        //mostriamo esclusivamente i box per il caricamento, non mostriamo il file caricato perché tanto lo caricano one shot e poi sparisce l'anomalia
        InfoDoc[] result = new InfoDoc[] { };
            
            Anomalia__c[] anomalie = [SELECT Id,
                                      Attore__c,
                                      Attore__r.Name,
                                      DescrizioneAnomalia__c,
                                      SottotipoAnomalia__c,
                                      TipoAnomalia__c,
                                      toLabel(TipoAnomalia__c) TipoAnomaliaLabel
                                      FROM Anomalia__c
                                      WHERE Cessione__c = :idCessione
                                      AND Risolta__c = false];
        
        
        Map<String, SObject> docTypes = U.keyBy([SELECT Label,
                                                 DeveloperName,
                                                 DescrizioneUpload__c,
                                                 FamigliaDocumento__c,
                                                 Help__c,
                                                 Tipo__c,
                                                 UploadMultiplo__c
                                                 FROM TiAnticipoDocumenti__mdt],
                                                'DeveloperName');
        
        Map<String, Allegato__c[]> allDoc = U.groupBy(
            [SELECT Id,
             CodiceDocumentoTiAnticipo__c,
             LastModifiedDate,
             LatestContentVersionId__c,
             NomeFile__c
             FROM Allegato__c
             WHERE Cessione__c = : idCessione],
            'CodiceDocumentoTiAnticipo__c'
        );
        
        for (Anomalia__c anomalia : anomalie) {
            TiAnticipoDocumenti__mdt md = (TiAnticipoDocumenti__mdt) docTypes.get(anomalia.TipoAnomalia__c);
            if (md != null) {
                Allegato__c a = (allDoc.containsKey(md.DeveloperName)) ? allDoc.get(md.DeveloperName) [0] : null;
                InfoDoc d = new InfoDoc(
                    anomalia.Id, // idAnomalia
                    anomalia.TipoAnomalia__c, // codiceDocumento
                    (String) anomalia.get('TipoAnomaliaLabel'), // name
                    a != null ? a.NomeFile__c : null, // fileName
                    String.isNotBlank(md.DescrizioneUpload__c) ? md.DescrizioneUpload__c : 'Carica nuovamente il documento', // descrizione
                    md.Help__c, // help
                    md.Tipo__c, // tipo
                    md.FamigliaDocumento__c, // famigliaDocumento
                    a != null ? a.LatestContentVersionId__c : null, // contentVersionId
                    anomalia.DescrizioneAnomalia__c, // descrizioneAnomalia
                    anomalia.SottotipoAnomalia__c, // sottotipoAnomalia
                    anomalia.Attore__r.Name // nomeAttore
                );
                
                // per alcuni documenti restituiamo n record
                if (md.UploadMultiplo__c && allDoc.containsKey(md.DeveloperName)) {
                    InfoDoc[] tmp = new InfoDoc[] { };
                        for (Allegato__c f : allDoc.get(md.DeveloperName)) {
                            tmp.add(new InfoDoc(f.NomeFile__c, md.Tipo__c, f.LatestContentVersionId__c, null));
                        }
                    d.docMultipli = tmp;
                }
                
                result.add(d);
            }
        }
        return result;
    }
    
    public static Boolean chiudiAnomalia(Id idAnomalia) {
        update new Anomalia__c(Id = idAnomalia, Risolta__c = true);
        return true;
    }
    
    public static Boolean chiudiAnomaliaAttore(Id idContact) {
        Anomalia__c[] anomalie = [SELECT Id
                                  FROM Anomalia__c
                                  WHERE Attore__c = :idContact
                                  AND Risolta__c = false];
        
        U.massSet(anomalie, 'Risolta__c', true);
        update anomalie;
        return true;
    }
}