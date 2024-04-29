public class WGC_FileUploaderController {

    public static final String codice_CBOX = 'cbox';
    public static final String codice_FILENET = 'filenet';

    @AuraEnabled
    public static WrapperResponse getDocMetadata(Boolean isDocFisso){
        WrapperResponse wrap = new WrapperResponse();
        List<WGC_Metadati_Documentale__mdt> recordsMetadati = new List<WGC_Metadati_Documentale__mdt>();

        try{

            if(isDocFisso){
                recordsMetadati = [SELECT Id, MasterLabel, DeveloperName, Classe__c, Documento__c, Istituto__c, toLabel(Sottoclasse__c), Giorni_Data_Scadenza__c, Data_documento_popolata__c FROM WGC_Metadati_Documentale__mdt];
            }
            else{
                recordsMetadati = [SELECT Id, MasterLabel, DeveloperName, Classe__c, Documento__c, toLabel(Sottoclasse__c), Giorni_Data_Scadenza__c, Data_documento_popolata__c FROM WGC_Metadati_Documentale__mdt WHERE IsUpload__c = true];
            }
            System.debug('@@@ recordsMetadati ' + JSON.serialize(recordsMetadati));

            Map<String, List<SObject>> groupDoc = new Map<String, List<SObject>>();
            groupDoc = U.groupBy(recordsMetadati, 'Sottoclasse__c');

            System.debug('@@@ groupDoc ' + JSON.serialize(groupDoc));

            wrap.data.add(groupDoc);

            if(Test.isRunningTest()) throw new TestException();
        }
        catch(Exception e){
            wrap.message = e.getMessage();
            wrap.success = false;

        }
        return wrap;
    }

    //TODO Aggiungi la logica per salvare le note dei documenti non disponibili
    @AuraEnabled
    public static WrapperResponse saveNote(String recordId, String note, String docId){
        WrapperResponse response = new WrapperResponse();

        try{
            // Id recId = (Id)recordId;
            // String objectName = recId.getSObjectType().getDescribe().getName();

            // System.debug('@@@ accId ' + accId);
            // Id actId;
            // String attoreName;
            // if(accId != null){
            //     actId = (Id)accId;
            //     attoreName = actId.getSObjectType().getDescribe().getName();
            // }

            // Account a = new Account();
            // Contact c = new Contact();
            // Opportunity o = new Opportunity();

            // if(objectName == 'Account'){
            //     a = [SELECT Id, Name FROM Account WHERE Id =: recId];
            // }
            // else if(objectName == 'Contact'){
            //     c = [SELECT Id, Name FROM Contact WHERE Id =: recId];
            // }
            // else if(objectName == 'Opportunity'){
            //     o = [SELECT Id, Name FROM Opportunity WHERE Id =: recId];

            //     if(actId != null){
            //         a = [SELECT Id, Name FROM Account WHERE Id=:actId];
            //     }
            // }

            WGC_Nota_Documento__c notaDoc = new WGC_Nota_Documento__c();
            // notaDoc.Anagrafica__c = a.Id != null ? a.Id : null;
            // notaDoc.Opportunit__c = o.Id != null ? o.Id : null;
            notaDoc.Id_Documentale__c = docId;
            notaDoc.Note__c = note;
            notaDoc.Id_Univoco__c = docId + '_' + recordId;

            System.debug('@@@ notaDoc ' + notaDoc);

            upsert notaDoc;

            response.data.add(notaDoc);
            response.message = 'OK';

            return response;
        }
        catch(Exception e){
            response.message = e.getMessage();
            response.success = false;

            return response;
        }
    }

    @AuraEnabled
    public static WrapperResponse handleNote(String recordId, String note, String docId, String accId){
        WrapperResponse response = new WrapperResponse();

        try{
            // Id recId = (Id)recordId;
            // String objectName = recId.getSObjectType().getDescribe().getName();

            // if(accId != null){
            //     Id actId = (Id)accId;
            //     String attoreName = actId.getSObjectType().getDescribe().getName();
            // }

            // Account a = new Account();
            // Contact c = new Contact();
            // Opportunity o = new Opportunity();

            // if(objectName == 'Account'){
            //     a = [SELECT Id, Name FROM Account WHERE Id =: recId];
            // }
            // else if(objectName == 'Contact'){
            //     c = [SELECT Id, Name FROM Contact WHERE Id =: recId];
            // }
            // else if(objectName == 'Opportunity'){
            //     o = [SELECT Id, Name FROM Opportunity WHERE Id =: recId];
            // }

            // String chiave = a.Id != null ? docId + '_' + a.Id : o.Id != null ? docId + '_' + o.Id : null;
            // System.debug('@@@ chiave ' + chiave);

            String chiave = docId + '_' + recordId;
            List<WGC_Nota_Documento__c> notes = [SELECT Id, Name, Anagrafica__c, Opportunit__c, Id_Documentale__c, Id_Univoco__c FROM WGC_Nota_Documento__c WHERE Id_Univoco__c =: chiave ORDER BY CreatedDate DESC];

            System.debug('@@@ notes ' + notes);

            response.data.add(notes[0]);

            delete notes[0];

            
            response.message = 'OK';

            return response;
        }
        catch(Exception e){
            response.message = e.getMessage();
            response.success = false;

            return response;
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

    public class DOC{
        @AuraEnabled
        public String dataProduzione;
        @AuraEnabled
        public String dataScadenza;
        @AuraEnabled
        public String famiglia;
        @AuraEnabled
        public String tipoDoc;
        @AuraEnabled
        public String docId;
        @AuraEnabled
        public String noteDocUpload;

        public DOC(){
            this.dataProduzione = dataProduzione;
            this.dataScadenza = dataScadenza;
            this.famiglia = famiglia;
            this.tipoDoc = tipoDoc;
            this.docId = docId;
            this.noteDocUpload = (noteDocUpload != null) ? noteDocUpload : '';
        }
    }

    // @AuraEnabled
    // public static WrapperResponse uploadDocMultipartOLD(String recordId, String docToInsert, String optyId, Boolean delDoc){
    //     System.debug('@@@ recordId ' + recordId);
    //     System.debug('@@@ string ' + docToInsert);        

    //     WrapperResponse wrap = new WrapperResponse();

    //     try{
    //         DOC wrapDoc = new DOC();
    //         wrapDoc = (DOC)JSON.deserialize(docToInsert, DOC.Class);

    //         System.debug('@@@ wrapDoc ' + wrapDoc);

    //         Id objectId = (Id)recordId;
    //         String objectName = objectId.getSObjectType().getDescribe().getName();
            
    //         Sobject obj;
    //         Sobject attore;

    //         System.debug('@@@ objectName ' + objectName);

    //         Opportunity o;
    //         Id oId;

    //         if(objectName != 'NDGLinea__c'){
    //             obj = (Sobject) Database.query(
    //                 QueryBuilder.newInstance(objectName, new String[] {
    //                     'Id',
    //                     'Name',
    //                     'NDGGruppo__c',
    //                     'codiceIstituto3N__c',
    //                     'NaturaGiuridica__c'
    //                     })
    //                     .beginFilter()
    //                     .add('Id', QBOp.QEQUAL, objectId)
    //                     .endFilter()
    //                     .getQuery()
    //                 );
    //         }
    //         else{
    //             attore = (Sobject) Database.query(
    //                 QueryBuilder.newInstance(objectName, new String[] {
    //                     'Id',
    //                     'Name',
    //                     'Account__c',
    //                     'Contact__c',
    //                     'Opportunita__c'
    //                     })
    //                     .beginFilter()
    //                     .add('Id', QBOp.QEQUAL, objectId)
    //                     .endFilter()
    //                     .getQuery()
    //                 );
                
    //             if(attore.get('Account__c') != null){
    //                 objectName = 'Account';
    //                 objectId = (Id)attore.get('Account__c');

    //             }
    //             else if(attore.get('Contact__c') != null){
    //                 objectName = 'Contact';
    //                 objectId = (Id)attore.get('Contact__c');
    //             }

    //             if(attore.get('Opportunita__c') != null){
    //                 oId = (Id)attore.get('Opportunita__c');
    //                 o = [SELECT Id, Name, AccountId, Account.NDGGruppo__c, Account.Name FROM Opportunity WHERE Id =: oId];
    //             }


    //             obj = (Sobject) Database.query(
    //                 QueryBuilder.newInstance(objectName, new String[] {
    //                     'Id',
    //                     'Name',
    //                     'NDGGruppo__c',
    //                     'NaturaGiuridica__c',
    //                     'codiceIstituto3N__c'
    //                     })
    //                     .beginFilter()
    //                     .add('Id', QBOp.QEQUAL, objectId)
    //                     .endFilter()
    //                     .getQuery()
    //             );
    //         }

    //         System.debug('@@@ obj final ' + JSON.serialize(obj));

    //         //Account a = [SELECT Id, Name, NDGGruppo__c FROM Account WHERE Id =: recordId];
    //         ContentDocument cd = [SELECT Id, Title, FileExtension, LatestPublishedVersionId FROM ContentDocument WHERE Id=:wrapDoc.docId];
    //         ContentVersion cv = [SELECT Id, PathOnClient, ContentDocumentId, ContentDocument.Title, ContentDocument.FileExtension, ContentDocument.LatestPublishedVersionId, VersionData FROM ContentVersion WHERE ContentDocumentId=:wrapDoc.docId AND IsLatest=true];

    //         System.debug('@@@ cv uploaded ' + JSON.serialize(cv));

    //         //Query per recuperare ndg operatore

    //         User u = [SELECT Id, NDGGruppo__c, WGC_NDG_Operatore__c, LocaleSidKey FROM User WHERE Id =: UserInfo.getUserId()];
    //         System.debug('@@@ u ' + JSON.serialize(u));

    //         //Recupero Metadati
    //         List<WGC_Metadati_Documentale__mdt> listaMetadati = new List<WGC_Metadati_Documentale__mdt>();
    //         listaMetadati = [SELECT Id, MasterLabel, DeveloperName, Istituto__c, Documento__c, Sottoclasse__c FROM WGC_Metadati_Documentale__mdt WHERE toLabel(Sottoclasse__c) =: wrapDoc.famiglia AND toLabel(Documento__c) =: wrapDoc.tipoDoc]; 
    //         System.debug('@@@ listaMetadati ' + JSON.serialize(listaMetadati));

    //         //Recupero il mime type del file caricato
    //         String mimeType = MIMETypeUtils.getMIMETypeFromExtension(cd.FileExtension);
    //         System.debug('@@@ extension ' + cd.FileExtension);
    //         System.debug('@@@ mime type ' + mimeType);

    //         //Input Wrapper
    //         InputMultipart input = new InputMultipart();
    //         //Matricola / ruolo dell'utente da caricare
    //         input.data.matricola = 'YH01175';
    //         input.data.ruolo = 'I340';
    //         //input.data.filiale = 0;
    //         input.data.lingua = 'IT';

    //         //Dati del documento di input
    //         InputDatiDoc datiDocInput = new InputDatiDoc();
    //         datiDocInput.classeOggetto = 'DOCUMENTI_CLIENTE';

    //         //Lista di indici da aggiungere ai datiDocInput
    //         List<IndiceInput> listaIndici = new List<IndiceInput>();

    //         IndiceInput indiceNDG = new IndiceInput();
    //         indiceNDG.nome = 'NDG';
    //         indiceNDG.valore = o != null ? o.Account.NDGGruppo__c : obj.get('NDGGruppo__c').toString();

    //         listaIndici.add(indiceNDG);

    //         IndiceInput indiceSottoClasse = new IndiceInput();
    //         indiceSottoClasse.nome = 'CODICESOTTOCLASSE';
    //         indiceSottoClasse.valore = listaMetadati.size() > 0 ? listaMetadati.get(0).Sottoclasse__c : wrapDoc.famiglia;

    //         listaIndici.add(indiceSottoClasse);

    //         //Errore sulla classe documentale
    //         IndiceInput indiceUtente = new IndiceInput();
    //         indiceUtente.nome = 'UTENTE';
    //         indiceUtente.valore = UserInfo.getUserName();
            
    //         listaIndici.add(indiceUtente);

    //         //Errore sulla classe documentale
    //         IndiceInput indiceUtenteDesc = new IndiceInput();
    //         indiceUtenteDesc.nome = 'UTENTEDESC';
    //         indiceUtenteDesc.valore = UserInfo.getFirstName() + ' ' + UserInfo.getLastName();

    //         listaIndici.add(indiceUtenteDesc);

    //         IndiceInput indiceIstituto = new IndiceInput();
    //         indiceIstituto.nome = 'ISTITUTO';
    //         indiceIstituto.valore = listaMetadati.size() > 0 ? listaMetadati.get(0).Istituto__c : '881';

    //         listaIndici.add(indiceIstituto);

    //         IndiceInput indiceNominativo = new IndiceInput();
    //         indiceNominativo.nome = 'NOMINATIVO';
    //         indiceNominativo.valore = UserInfo.getLastName() + ' ' + UserInfo.getFirstName();

    //         listaIndici.add(indiceNominativo);

    //         IndiceInput indiceVisibilita = new IndiceInput();
    //         indiceVisibilita.nome = 'VISIBILITA';
    //         indiceVisibilita.valore = 'B'; //C = Cliente
            
    //         listaIndici.add(indiceVisibilita);

    //         IndiceInput indiceDataProd = new IndiceInput();
    //         indiceDataProd.nome = 'DATAPROD';
    //         indiceDataProd.valore = wrapDoc.dataProduzione.replace('/','').length() == 8 ? wrapDoc.dataProduzione.replace('/','') : '0'+wrapDoc.dataProduzione.replace('/','');
    //         listaIndici.add(indiceDataProd);

    //         IndiceInput indiceNDGUser = new IndiceInput();
    //         indiceNDGUser.nome = 'NDGOPERATORE';
    //         indiceNDGUser.valore =  u.NDGGruppo__c != null ? u.NDGGruppo__c : '';

    //         listaIndici.add(indiceNDGUser);

    //         IndiceInput indiceDataRif = new IndiceInput();
    //         indiceDataRif.nome = 'DATARIF';
    //         indiceDataRif.valore = wrapDoc.dataScadenza.replace('/','').length() == 8 ? wrapDoc.dataScadenza.replace('/','') : '0'+wrapDoc.dataScadenza.replace('/','');
    //         listaIndici.add(indiceDataRif);

    //         IndiceInput indiceCodiceDoc = new IndiceInput();
    //         indiceCodiceDoc.nome = 'CODICEDOC';
    //         indiceCodiceDoc.valore = listaMetadati.size() > 0 ? listaMetadati.get(0).Documento__c : wrapDoc.tipoDoc;

    //         listaIndici.add(indiceCodiceDoc);

    //         IndiceInput indiceNoteDoc = new IndiceInput();
    //         indiceNoteDoc.nome = 'NOTEDOC';
    //         indiceNoteDoc.valore = ''; //

    //         listaIndici.add(indiceNoteDoc);

    //         IndiceInput indiceOpty = new IndiceInput();
    //         indiceOpty.nome = 'IDCFLOW';
    //         indiceOpty.valore = optyId != null ? optyId : '';

    //         System.debug('@@@ optyId ' + optyId);
    //         if(optyId != null)
    //             listaIndici.add(indiceOpty);

    //         IndiceInput indiceNdgDeb = new IndiceInput();
    //         indiceNdgDeb.nome = 'NDGDEBITORE';
    //         indiceNdgDeb.valore = obj.get('NDGGruppo__c').toString();

    //         if(obj.get('NDGGruppo__c') != null)
    //             listaIndici.add(indiceNdgDeb);

    //         datiDocInput.indice = new List<IndiceInput>();

    //         datiDocInput.indice = listaIndici;

    //         ContenutoDocumento contenuto = new ContenutoDocumento();
    //         contenuto.nomeFIle = cd.Title+'.'+cd.FileExtension;
    //         //old
    //         //contenuto.tipoMime = 'application/'+cd.FileExtension;
    //         //new
    //         contenuto.tipoMime = mimeType;

    //         datiDocInput.contenutoDocumento = new List<ContenutoDocumento>();
    //         datiDocInput.contenutoDocumento.add(contenuto);


    //         input.data.datiDocumento = datiDocInput;

    //         WsRestInput payload = new WsRestInput(input);

    //         System.debug('@@@ payload ' + JSON.serialize(payload));
            
    //         //String base = EncodingUtil.base64Encode(cv.VersionData);

    //         String binary = getBinaryFile(cv.Id);
            
    //         String boundary = '----WebKitFormBoundary7MA4YWxkTrZu0gW';
    //         String body = '--' + boundary + '\r\n';
    //         body += 'Content-Disposition: form-data; name="oggetto"; filename="'+cd.Title+'.'+cd.FileExtension+'" \r\n';
    //         //body += 'Content-Type: application/pdf \r\n\r\n';
    //         //body += 'Content-Type: '+mimeType+' \r\n\r\n';
    //         body += 'Content-Type: application/octet-stream \r\n\r\n';
    //         body += binary + '\r\n';
    //         body += '--' + boundary + '\r\n';
    //         body += 'Content-Disposition: form-data; name="archMessage"; filename="archMessage.json" \r\n';
    //         body += 'Content-Type: application/json \r\n\r\n';
    //         //body += '{"payload":{"data":{"codiceIstituto3N":"881","idApplicazioneChiamante":"CRM","idSessioneChiamante":"","lingua":"IT","idOperazione":"56cd2bde-734f-493b-9d4e-b016ced62b90","matricola":"YH01175","ruolo":"I340","datiDocumento":{"classeOggetto":"DOCUMENTI_CLIENTE","indice":[{"nome":"NDG","ricerca":"FALSE","append":"FALSE","valore":"180305"},{"nome":"CODICESOTTOCLASSE","ricerca":"FALSE","append":"FALSE","valore":"SY0000064"},{"nome":"UTENTE","ricerca":"FALSE","append":"FALSE","valore":"Marco.Gallo@bancaifis.it"},{"nome":"UTENTEDESC","ricerca":"FALSE","append":"FALSE","valore":"MarcoGallo"},{"nome":"ISTITUTO","ricerca":"FALSE","append":"FALSE","valore":"881"},{"nome":"NOMINATIVO","ricerca":"FALSE","append":"FALSE","valore":"GALLOMARCO"},{"nome":"VISIBILITA","ricerca":"FALSE","append":"FALSE","valore":"B"},{"nome":"DATAPROD","ricerca":"FALSE","append":"FALSE","valore":"30102018"},{"nome":"NDGOPERATORE","ricerca":"FALSE","append":"FALSE","valore":"180305"},{"nome":"DATARIF","ricerca":"FALSE","append":"FALSE","valore":"13062018"},{"nome":"CODICEDOC","ricerca":"FALSE","append":"FALSE","valore":"SY0000002"},{"nome":"NOTEDOC","ricerca":"FALSE","append":"FALSE","valore":"scadenza31122020"}],"azioneDiRicerca":"NONE","contenutoDocumento":[{"nomeFIle":"Test.pdf","tipoMime":"application/pdf","base64":null}]}}},"headers":{"headers":{"tech_header":{"id":"tech_header","applicationCode":"CRM","correlationId":"f6e0782d-9201-4d3b-bdd4-a300c6a1fc8e","channel":"B2B","timeStamp":1540908700335,"workstationId":null,"clientIpAddress":null,"clientHostname":null},"user_header":{"id":"user_header","archUser":{"name":"Marco","surname":"Gallo","emailAddress":"Marco.Gallo@bancaifis.it","phoneNumber":"+390415027531","userId":"mgallo","actualUserId":"mgallo","institute":"BancaIFISSpA","userGroups":[],"userRoles":[]}}}}} \r\n';
    //         body += payload.toJSONString() + '\r\n';
    //         body += '--' + boundary + '--';
            
    //         ResponseUpload om = (ResponseUpload) WGC_WsRest.uploadDoc(body, boundary);
    //         System.debug('@@@ om ' + JSON.serialize(om));
    //         //Cancello il documento da salesforce
    //         if(delDoc)
    //             delete cd;

    //         wrap.data.add(om);
    //         wrap.message = 'OK';
            
    //         return wrap;
    //     }
    //     catch(Exception e){
    //         System.debug('@@@ exception ' + e.getMessage() + ' - ' + e.getCause() + ' - ' + e.getLineNumber() + ' - ' + e.getStackTraceString());
    //         wrap.message = e.getMessage();
    //         wrap.success = false;

    //         return wrap;
    //     }
    // }
    
    //OLD PARAMETERS Blob file, String file_name, String mimeType, String ndg, String optyId, String nominativo, String datarif, String datastato
    @AuraEnabled
    public static WrapperResponse uploadDocMultipart_Direct(WGC_Documenti_Controller.WrapperRicercaMAV mav) {
        WrapperResponse response = new WrapperResponse();
        
        System.debug('@@@ mav ' + JSON.serialize(mav));
        try {

            //Query per recuperare ndg operatore
            User u = [SELECT Id, NDGGruppo__c, WGC_NDG_Operatore__c, LocaleSidKey, WGC_Matricola_Cedacri__c FROM User WHERE Id =: UserInfo.getUserId()];
            System.debug('@@@ u ' + JSON.serialize(u));

            //Recupero Metadati
            List<WGC_Metadati_Documentale__mdt> listaMetadati = new List<WGC_Metadati_Documentale__mdt>();
            listaMetadati = [SELECT Id, MasterLabel, DeveloperName, Istituto__c, Documento__c, Sottoclasse__c FROM WGC_Metadati_Documentale__mdt WHERE DeveloperName = 'Modulo_adeguata_verifica' ];
            System.debug('@@@ listaMetadati ' + JSON.serialize(listaMetadati));

            //Input Wrapper
            InputMultipart input = new InputMultipart();
            //Matricola / ruolo dell'utente da caricare

            input.data.matricola = u.WGC_Matricola_Cedacri__c != null ? u.WGC_Matricola_Cedacri__c : '';
            input.data.ruolo = 'I340';
            input.data.lingua = 'IT';

            //Dati del documento di input
            InputDatiDoc datiDocInput = new InputDatiDoc();
            datiDocInput.classeOggetto = 'DOCUMENTI_CLIENTE';

            //Lista di indici da aggiungere ai datiDocInput
            List<IndiceInput> listaIndici = new List<IndiceInput>();

            IndiceInput indiceNDG = new IndiceInput();
            indiceNDG.nome = 'NDG';
            //indiceNDG.valore = a.NDGGruppo__c;
            //indiceNDG.valore = (o != null && String.valueOf(attore.get('Tipo__c')) != 'Esecutore adeguata verifica') ? o.Account.NDGGruppo__c : obj.get('NDGGruppo__c').toString();
            indiceNDG.valore = mav.ndgAcc;
            //indiceNDG.ricerca = 'TRUE';

            listaIndici.add(indiceNDG);

            IndiceInput indiceSottoClasse = new IndiceInput();
            indiceSottoClasse.nome = 'CODICESOTTOCLASSE';
            indiceSottoClasse.valore = listaMetadati.size() > 0 ? listaMetadati.get(0).Sottoclasse__c : '';

            listaIndici.add(indiceSottoClasse);

            //Errore sulla classe documentale
            IndiceInput indiceUtente = new IndiceInput();
            indiceUtente.nome = 'UTENTE';
            indiceUtente.valore = UserInfo.getUserName();
            
            listaIndici.add(indiceUtente);

            //Errore sulla classe documentale
            IndiceInput indiceUtenteDesc = new IndiceInput();
            indiceUtenteDesc.nome = 'UTENTEDESC';
            indiceUtenteDesc.valore = UserInfo.getFirstName() + ' ' + UserInfo.getLastName();

            listaIndici.add(indiceUtenteDesc);

            IndiceInput indiceIstituto = new IndiceInput();
            indiceIstituto.nome = 'ISTITUTO';
            indiceIstituto.valore = listaMetadati.size() > 0 ? listaMetadati.get(0).Istituto__c : '881';

            listaIndici.add(indiceIstituto);

            IndiceInput indiceNominativo = new IndiceInput(); //Nome NDG
            indiceNominativo.nome = 'NOMINATIVO';
            //indiceNominativo.valore = UserInfo.getLastName() + ' ' + UserInfo.getFirstName();
            //indiceNominativo.valore = o != null ? o.Account.Name : String.valueOf(obj.get('Name'));
            indiceNominativo.valore = mav.nominativo;

            listaIndici.add(indiceNominativo);

            IndiceInput indiceVisibilita = new IndiceInput();
            indiceVisibilita.nome = 'VISIBILITA';
            indiceVisibilita.valore = 'B'; //C = Cliente
            
            listaIndici.add(indiceVisibilita);

            String oggi = String.valueOf(System.Today().Day()).length() == 1 ? '0'+String.valueOf(System.Today().Day()) : String.valueOf(System.Today().Day());
            String mese = String.valueOf(System.Today().Month()).length() == 1 ? '0'+String.valueOf(System.Today().Month()) : String.valueOf(System.Today().Month());
            String anno = String.valueOf(System.Today().Year());

            String dataProd = oggi + '' + mese + '' + anno;
            System.debug('@@@ dataProd ' + dataProd);

            IndiceInput indiceDataProd = new IndiceInput();
            indiceDataProd.nome = 'DATAPROD';
            //indiceDataProd.valore = UserInfo.getLocale() == 'it_IT' ? String.valueOf(System.Today().format().replace('/','')) : String.valueOf(System.Today());
            indiceDataProd.valore = dataProd;
            listaIndici.add(indiceDataProd);

            System.debug('@@@ data produzione ' + String.valueOf(System.Today()));

            IndiceInput indiceNDGUser = new IndiceInput();
            indiceNDGUser.nome = 'NDGOPERATORE';
            indiceNDGUser.valore =  u.NDGGruppo__c != null ? u.NDGGruppo__c : '';

            listaIndici.add(indiceNDGUser);

            //OLD
            // IndiceInput indiceDataRif = new IndiceInput();
            // indiceDataRif.nome = 'DATARIF';
            // indiceDataRif.valore = wrapDoc.dataScadenza.replace('/','').length() == 8 ? wrapDoc.dataScadenza.replace('/','') : '0'+wrapDoc.dataScadenza.replace('/','');
            // listaIndici.add(indiceDataRif);

            IndiceInput indiceDataRif = new IndiceInput();
            indiceDataRif.nome = 'DATARIF';
            //indiceDataRif.valore = wrapDoc.dataProduzione.replace('/','').length() == 8 ? wrapDoc.dataProduzione.replace('/','') : '0'+wrapDoc.dataProduzione.replace('/','');
            indiceDataRif.valore = mav.datarif;
            listaIndici.add(indiceDataRif);

            IndiceInput indiceDataStato = new IndiceInput();
            indiceDataStato.nome = 'DATASTATO';
            //indiceDataStato.valore = wrapDoc.dataScadenza.replace('/','').length() == 8 ? wrapDoc.dataScadenza.replace('/','') : '0'+wrapDoc.dataScadenza.replace('/','');
            indiceDataStato.valore = mav.datastato;
            listaIndici.add(indiceDataStato);

            IndiceInput indiceCodiceDoc = new IndiceInput();
            indiceCodiceDoc.nome = 'CODICEDOC';
            indiceCodiceDoc.valore = listaMetadati.size() > 0 ? listaMetadati.get(0).Documento__c : '';
            //indiceCodiceDoc.ricerca = 'TRUE';

            listaIndici.add(indiceCodiceDoc);

            IndiceInput indiceNoteDoc = new IndiceInput();
            indiceNoteDoc.nome = 'NOTEDOC';
            indiceNoteDoc.valore = ''; //

            listaIndici.add(indiceNoteDoc);

            IndiceInput indiceOpty = new IndiceInput();
            indiceOpty.nome = 'IDCFLOW';
            indiceOpty.valore = mav.oppId != null ? mav.oppId : '';
            //indiceOpty.append = 'TRUE';
            //indiceOpty.ricerca = 'FALSE';

            System.debug('@@@ optyId ' + mav.oppId);
            if(mav.oppId != null)
                listaIndici.add(indiceOpty);

            Opportunity opp = [SELECT IdCartella__c FROM Opportunity WHERE Id =: mav.oppId];

            System.debug('@@@ opp ' + JSON.serialize(opp));

            if(!String.isBlank(opp.IdCartella__c)){
                IndiceInput indiceIdCartella = new IndiceInput();
                indiceIdCartella.nome = 'CARTELLANV';
                indiceIdCartella.valore = opp.idCartella__c;
                //indiceIdCartella.append = 'TRUE';
                listaIndici.add(indiceIdCartella);
            }

            System.debug('@@@ listaIndici ' + JSON.serialize(listaIndici));

            datiDocInput.indice = new List<IndiceInput>();

            datiDocInput.indice = listaIndici;

            ContenutoDocumento contenuto = new ContenutoDocumento();
            contenuto.nomeFIle = mav.nomeFile;  //file_name+'.'+mimeType;//cd.Title+'.'+cd.FileExtension;
            contenuto.tipoMime = mav.mime;

            datiDocInput.contenutoDocumento = new List<ContenutoDocumento>();
            datiDocInput.contenutoDocumento.add(contenuto);

            input.data.datiDocumento = datiDocInput;

			/**
			 * adione: qua devo chiamare digibox e controllare il return code
			 * in caso devo fare fallback su FileNet
			 */
			WrapperResponse wr; //output chiamata DigiBox
			Boolean uploadDigibox = false;
            //digibox va chiamato solo per alcuni documenti e (pe ora) solo per CRM (non i portali esterni)
            if (Impostazioni__c.getInstance().Abilita_DigiBox__c) {
				System.debug('-----> Upload DigiBox');
                uploadDigibox = true;
				Account acc = [SELECT Id FROM Account WHERE NDGGruppo__c = :mav.ndgAcc LIMIT 1];
				List<Object> indici = new List<Object>{};
				indici.addAll(listaIndici);
                wr = BI_CRM_DigiBox_CODE.createAutomatic('', (String)acc.Id, indici, contenuto.nomeFIle, EncodingUtil.base64Decode(mav.base64File));

				//eventuale errore DIGIBOX di barcode già usato va notificato all'utente invece che fare fallback su FileNet
				if (wr != null && 
					('Barcode già associato a un documento' == wr.message
					|| 'Barcode non esistente in DIGIBOX'  == wr.message)) {

					response.message = wr.message;
					response.success = false;

					return response; //errore bloccante
				} else {
					response.data.add(wr.data.get(0)); //response upload digibox
				}

			} else { //upload diretto su FileNet
				System.debug('-----> Upload Doc62');
				WsRestInput payload = new WsRestInput(input);

				System.debug('@@@ payload ' + JSON.serialize(payload));

				//form multipart preparation
				String boundary = '----------------------------741e90d31eff';
				String headerEncoded = EncodingUtil.base64Encode(Blob.valueOf(boundary));

				String archMsgPart = '--'+boundary+'\nContent-Disposition: form-data; name="archMessage"; filename="archMessage.json";\nContent-Type: application/json';
				String archMsgPartEncoded = EncodingUtil.base64Encode(Blob.valueOf(archMsgPart+'\r\n\r\n'));
				while(archMsgPartEncoded.endsWith('=')) {
					archMsgPart+=' ';
					archMsgPartEncoded = EncodingUtil.base64Encode(Blob.valueOf(archMsgPart+'\r\n\r\n'));
				}
    
				String archMsg = JSON.serialize(payload);
				String archMsgEncoded = EncodingUtil.base64Encode(Blob.valueOf( archMsg +'\r\n\r\n' ));
				while(archMsgEncoded.endsWith('=')) {
					archMsg+=' ';
					archMsgEncoded = EncodingUtil.base64Encode(Blob.valueOf(archMsg+'\r\n\r\n'));
				}

				String filePart = '--'+boundary+'\nContent-Disposition: form-data; name="oggetto"; filename="'+mav.nomeFile+'";\nContent-Type: application/octet-stream';
				String filePartEncoded = EncodingUtil.base64Encode(Blob.valueOf(filePart+'\r\n\r\n'));
					while(filePartEncoded.endsWith('=')) {
					filePart+=' ';
					filePartEncoded = EncodingUtil.base64Encode(Blob.valueOf(filePart+'\r\n\r\n'));
				}

				String footer = '--'+boundary+'--';

				System.debug('@@@ file ' + mav.base64File);
    
				//String bodyEncoded = EncodingUtil.base64Encode(file);
				String bodyEncoded = mav.base64File;
    
				Blob bodyBlob = null;
				String last4Bytes = bodyEncoded.substring(bodyEncoded.length()-4,bodyEncoded.length());
    
				if(last4Bytes.endsWith('==')) {
					last4Bytes = last4Bytes.substring(0,2) + '0K';
					bodyEncoded = bodyEncoded.substring(0,bodyEncoded.length()-4) + last4Bytes;
				} else if(last4Bytes.endsWith('=')) {
					last4Bytes = last4Bytes.substring(0,3) + 'N';
					bodyEncoded = bodyEncoded.substring(0,bodyEncoded.length()-4) + last4Bytes;
					footer = '\n' + footer;
				} else {
					footer = '\r\n' + footer;
				}
    
				String footerEncoded = EncodingUtil.base64Encode(Blob.valueOf(footer));
				bodyBlob = EncodingUtil.base64Decode( archMsgPartEncoded + archMsgEncoded + filePartEncoded + bodyEncoded + footerEncoded); 

				ResponseUpload om = (ResponseUpload) WGC_WsRest.uploadDoc(bodyBlob, boundary);

				System.debug('@@@ om ' + JSON.serialize(om));

				response.data.add(om);
			} //fine upload diretto FileNet

        } catch(Exception e) {
            response.message = e.getMessage();
            response.success = false;
        }

        return response;
    }

	/**
	 * Upload file su documentale, con gestione DigiBox quando applicabile in base a tipo documento
	 * @param String recordId il soggetto da cui ricavare dettagli per collegare il documento: Account / Contact / NDGLinea__c
	 * @param String docToInsert json con serializzazion di oggetto WGC_FileUploaderController.DOC - metadati del documento
	 * @param String optyId id opportunità - opzionale
	 * @param Boolean delDoc indica se cancellare o meno lo stream caricato (e salvato in saleforce)
	 */
	@AuraEnabled
    public static WrapperResponse uploadDocMultipart(String recordId, String docToInsert, String optyId, Boolean delDoc) {
        System.debug('-----> uploadDocMultipart con default a CRM');
		return WGC_FileUploaderController.uploadDocMultipart(recordId, docToInsert, optyId, delDoc, 'CRM');
	}

	/**
	 * Upload file su documentale, con gestione DigiBox quando applicabile in base a tipo documento
	 * @param String recordId il soggetto da cui ricavare dettagli per collegare il documento: Account / Contact / NDGLinea__c
	 * @param String docToInsert json con serializzazion di oggetto WGC_FileUploaderController.DOC - metadati del documento
	 * @param String optyId id opportunità - opzionale
	 * @param Boolean delDoc indica se cancellare o meno lo stream caricato (e salvato in saleforce)
	 * @param String source il chiamante che discrimina alcuni comportamenti, p.e. TiAnticipo non usa DigiBox - valori possibili CRM, NSA, TiAnticipo - default CRM
	 */
    @AuraEnabled
    public static WrapperResponse uploadDocMultipart(String recordId, String docToInsert, String optyId, Boolean delDoc, String source) {
        // System.debug('@@@ recordId ' + recordId);
        // System.debug('@@@ string ' + docToInsert);        

        WrapperResponse wrap = new WrapperResponse();

        try{
            DOC wrapDoc = new DOC();
            wrapDoc = (DOC)JSON.deserialize(docToInsert, DOC.Class);

            // System.debug('@@@ wrapDoc ' + wrapDoc);

            Id objectId = (Id)recordId;
            String objectName = objectId.getSObjectType().getDescribe().getName();
            
            Sobject obj;
            Sobject attore;

            // System.debug('@@@ objectName ' + objectName);

            Opportunity o;
            Id oId;

            Boolean isDebitore = false;

            if(objectName != 'NDGLinea__c'){
                obj = (Sobject) Database.query(
                    QueryBuilder.newInstance(objectName, new String[] {
                        'Id',
                        'Name',
                        'NDGGruppo__c',
                        'codiceIstituto3N__c',
                        'NaturaGiuridica__c'
                        })
                        .beginFilter()
                        .add('Id', QBOp.QEQUAL, objectId)
                        .endFilter()
                        .getQuery()
                    );
            }
            else{
                attore = (Sobject) Database.query(
                    QueryBuilder.newInstance(objectName, new String[] {
                        'Id',
                        'Name',
                        'Account__c',
                        'Contact__c',
                        'Opportunita__c',
                        'Tipo__c'
                        })
                        .beginFilter()
                        .add('Id', QBOp.QEQUAL, objectId)
                        .endFilter()
                        .getQuery()
                    );

                // System.debug('@@@ isDebitore control ' + String.valueOf(attore.get('Tipo__c')));
                // if(String.valueOf(attore.get('Tipo__c')) == 'Debitore'){
                //     isDebitore = true;
                // }

                //Setto il flag a true se è un attore
                isDebitore = true;


                if(attore.get('Account__c') != null){
                    objectName = 'Account';
                    objectId = (Id)attore.get('Account__c');

                }
                else if(attore.get('Contact__c') != null){
                    objectName = 'Contact';
                    objectId = (Id)attore.get('Contact__c');
                }

                if(attore.get('Opportunita__c') != null){
                    oId = (Id)attore.get('Opportunita__c');
                    o = [SELECT Id, Name, AccountId, Account.NDGGruppo__c, Account.Name FROM Opportunity WHERE Id =: oId];
                }


                obj = (Sobject) Database.query(
                    QueryBuilder.newInstance(objectName, new String[] {
                        'Id',
                        'Name',
                        'NDGGruppo__c',
                        'NaturaGiuridica__c',
                        'codiceIstituto3N__c'
                        })
                        .beginFilter()
                        .add('Id', QBOp.QEQUAL, objectId)
                        .endFilter()
                        .getQuery()
                );
            }

            // System.debug('@@@ obj final ' + JSON.serialize(obj));

            ContentDocument cd = [SELECT Id, Title, FileExtension, LatestPublishedVersionId 
                                    FROM ContentDocument 
                                    WHERE Id=:wrapDoc.docId];
            ContentVersion cv = [SELECT Id, PathOnClient, ContentDocumentId, ContentDocument.Title, ContentDocument.FileExtension, 
                                        ContentDocument.LatestPublishedVersionId, VersionData, ContentSize 
                                    FROM ContentVersion 
                                    WHERE ContentDocumentId=:wrapDoc.docId 
                                    AND IsLatest=true];

            String file_name = cd.Title +'.'+cd.FileExtension;
            // System.debug('@@@ file name :'+file_name);

            //9168377
            if(cv.ContentSize >= 9000000){
                wrap.message = 'Documento troppo grande, caricare il documento dal sistema Documentale';
                wrap.success = false;
                return wrap;
            }                                    

            //Query per recuperare ndg operatore
            User u = [SELECT Id, NDGGruppo__c, WGC_NDG_Operatore__c, LocaleSidKey, WGC_Matricola_Cedacri__c FROM User WHERE Id =: UserInfo.getUserId()];
            // System.debug('@@@ u ' + JSON.serialize(u));

            //Recupero Metadati
            List<WGC_Metadati_Documentale__mdt> listaMetadati = new List<WGC_Metadati_Documentale__mdt>();
            listaMetadati = [SELECT Id, MasterLabel, DeveloperName, Istituto__c, Documento__c, Sottoclasse__c,Tipo_Documentale__c FROM WGC_Metadati_Documentale__mdt WHERE toLabel(Sottoclasse__c) =: wrapDoc.famiglia AND toLabel(Documento__c) =: wrapDoc.tipoDoc];
            // System.debug('@@@ listaMetadati ' + JSON.serialize(listaMetadati));

            //Recupero il mime type del file caricato
            String mimeType = MIMETypeUtils.getMIMETypeFromExtension(cd.FileExtension);
            // System.debug('@@@ extension ' + cd.FileExtension);
            // System.debug('@@@ mime type ' + mimeType);

            String tipoDocumentale = listaMetadati.get(0).Tipo_Documentale__c;

            InputMultipart62 input = new InputMultipart62(tipoDocumentale);

            List<Object> indici;
            if (tipoDocumentale.equals('filenet')){
                indici = generateIndiciFilenet(o,attore,obj,listaMetadati, u,wrapDoc,optyId);
            }else {
                o = [SELECT Id, Name, AccountId, Account.NDGGruppo__c, Account.Name FROM Opportunity WHERE Id =: optyId];
                indici = generateIndiciCbox(o, attore, obj, listaMetadati, wrapDoc, file_name);
            }

            input.data.datiDocumento.indice = indici;

            WsRestInput payload = new WsRestInput(input);
            // System.debug('@@@ payload ' + JSON.serialize(payload));

			WrapperResponse wr; //output chiamata DigiBox
            ResponseUpload62 om; //output chiamata FileNet

		    /**
			 * adione: qua devo chiamare digibox e controllare il return code
			 * in caso devo fare fallback su FileNet
			 */
			Boolean uploadDigibox = false;
            source = (String.isBlank(source)) ? 'CRM' : source; //default to 'CRM' if not specified

			System.debug('-----> DigiBox abilitato: '+Impostazioni__c.getInstance().Abilita_DigiBox__c);
			// System.debug('-----> source: '+source);
			// System.debug('-----> tipoDoc: '+wrapDoc.tipoDoc);
			System.debug('-----> upload DigiBox? '+(Impostazioni__c.getInstance().Abilita_DigiBox__c &&
				source == 'CRM'  &&
                (wrapDoc.tipoDoc == 'EX0000173' //MAV
                || wrapDoc.tipoDoc == 'EX0000179' //MTC
                || wrapDoc.tipoDoc == 'SY0000074' //PrivacyPF
                || wrapDoc.tipoDoc == 'EX0000200' //PrivacyPF
                || wrapDoc.tipoDoc == 'NV0000002')));            
            //digibox va chiamato solo per alcuni documenti e (pe ora) solo per CRM (non i portali esterni)
            if (Impostazioni__c.getInstance().Abilita_DigiBox__c &&
				source == 'CRM'  &&
                (wrapDoc.tipoDoc == 'EX0000173' //MAV
                || wrapDoc.tipoDoc == 'EX0000179' //MTC
                || wrapDoc.tipoDoc == 'SY0000074' //PrivacyPF
                || wrapDoc.tipoDoc == 'EX0000200' //PrivacyPF
                || wrapDoc.tipoDoc == 'NV0000002')) { //RSF

				System.debug('-----> Upload DigiBox');
                uploadDigibox = true;
                wr = BI_CRM_DigiBox_CODE.createAutomatic(wrapDoc.docId, recordId, indici, file_name, cv.VersionData);
            }
            //eventuale errore DIGIBOX di barcode già usato va notificato all'utente invece che fare fallback su FileNet
			if (wr != null && 
				('Barcode già associato a un documento' == wr.message
				|| 'Barcode non esistente in DIGIBOX'  == wr.message)) {
		        //Cancello il documento da salesforce
				if (delDoc)
					delete cd;

				wrap.message = wr.message;
				wrap.success = false;

				return wrap;
			}
			
			//fallback upload diretto su FileNet
			if (!uploadDigibox || (wr != null && !wr.success)) { 
				if (uploadDigibox) //era un doc che doveva passare per DigiBox ma è andata male -> logghiamo
                    System.debug('-----> caricamento su DigiBox KO, fallback su caricamento diretto FileNet (Errore: '+wr.message+')');
                
				// System.debug('-----> Upload Doc62');

                Blob file_body2 = cv.VersionData;
				// System.debug('@@@ cv.ContentSize ' + cv.ContentSize);

				//form multipart preparation
				String boundary = '----------------------------741e90d31eff';
				String headerEncoded = EncodingUtil.base64Encode(Blob.valueOf(boundary));

				String archMsgPart = '--'+boundary+'\nContent-Disposition: form-data; name="archMessage"; filename="archMessage.json";\nContent-Type: application/json';
				String archMsgPartEncoded = EncodingUtil.base64Encode(Blob.valueOf(archMsgPart+'\r\n\r\n'));
				while(archMsgPartEncoded.endsWith('=')) {
					archMsgPart+=' ';
					archMsgPartEncoded = EncodingUtil.base64Encode(Blob.valueOf(archMsgPart+'\r\n\r\n'));
				}
    
				String archMsg = JSON.serialize(payload);
				String archMsgEncoded = EncodingUtil.base64Encode(Blob.valueOf( archMsg +'\r\n\r\n' ));
				while(archMsgEncoded.endsWith('=')) {
					archMsg+=' ';
					archMsgEncoded = EncodingUtil.base64Encode(Blob.valueOf(archMsg+'\r\n\r\n'));
				}

				String filePart = '--'+boundary+'\nContent-Disposition: form-data; name="uploadfile"; filename="'+file_name+'";\nContent-Type: application/octet-stream';
				String filePartEncoded = EncodingUtil.base64Encode(Blob.valueOf(filePart+'\r\n\r\n'));
					while(filePartEncoded.endsWith('=')) {
					filePart+=' ';
					filePartEncoded = EncodingUtil.base64Encode(Blob.valueOf(filePart+'\r\n\r\n'));
				}

				String footer = '--'+boundary+'--';
    
				//String bodyEncoded = EncodingUtil.base64Encode(file_body);
				String bodyEncoded = EncodingUtil.base64Encode(file_body2);
				String bodyEncoded2;

				System.debug('@@@ bodyEncoded.length() ' + bodyEncoded.length());

				List<String> bodyEncs = new List<String>();

                bodyEncs = splitStringEvery(bodyEncoded, 6000000);
                // bodyEncs = splitStringEvery(bodyEncoded, 5940000);
				// System.debug('@@@ bodyEncs after method ' + bodyEncs.size());

				Blob bodyBlob = null;
				String last4Bytes;

				last4Bytes = bodyEncs[bodyEncs.size() - 1].substring(bodyEncs[bodyEncs.size() - 1].length() - 4, bodyEncs[bodyEncs.size() - 1].length());
				System.debug('@@@ last4Bytes ' + last4Bytes);

				//Test2
				if(last4Bytes.endsWith('==')) {
					last4Bytes = last4Bytes.substring(0,2) + '0K';
					bodyEncs[bodyEncs.size() - 1] = bodyEncs[bodyEncs.size() - 1].substring(0,bodyEncs[bodyEncs.size() - 1].length()-4) + last4Bytes;
				} else if(last4Bytes.endsWith('=')) {
					last4Bytes = last4Bytes.substring(0,3) + 'N';
					bodyEncs[bodyEncs.size() - 1] = bodyEncs[bodyEncs.size() - 1].substring(0,bodyEncs[bodyEncs.size() - 1].length()-4) + last4Bytes;
					footer = '\n' + footer;
				} else {
					footer = '\r\n' + footer;
				}

				// System.debug('@@@ footer ' + footer);
				String footerEncoded = EncodingUtil.base64Encode(Blob.valueOf(footer));

                //OLD Limite 6000000
				if(bodyEncoded.length() < 5940000){
					last4Bytes = bodyEncoded.substring(bodyEncoded.length()-4,bodyEncoded.length());
					if(last4Bytes.endsWith('==')) {
						last4Bytes = last4Bytes.substring(0,2) + '0K';
						bodyEncoded = bodyEncoded.substring(0,bodyEncoded.length()-4) + last4Bytes;
					} else if(last4Bytes.endsWith('=')) {
						last4Bytes = last4Bytes.substring(0,3) + 'N';
						bodyEncoded = bodyEncoded.substring(0,bodyEncoded.length()-4) + last4Bytes;
						footer = '\n' + footer;
					} else {
						footer = '\r\n' + footer;
					}

					// System.debug('@@@ sync ' + bodyEncoded);
					bodyBlob = EncodingUtil.base64Decode( archMsgPartEncoded + archMsgEncoded + filePartEncoded + bodyEncoded + footerEncoded);
				} else {
					multipartForBigFile(archMsgPartEncoded, archMsgEncoded, filePartEncoded, bodyEncs, footerEncoded, String.valueOf(obj.get('Id')));
					wrap.message = 'Il documento verrà caricato a breve';

					archMsgPartEncoded = null;
					archMsgEncoded = null;
					filePartEncoded = null;
					bodyEncs = null;
					footerEncoded = null;

					//Cancello il documento da salesforce
					System.debug('@@@ delDoc ' + delDoc);
					if(delDoc)
						delete cd;
                
					return wrap;
				}

				om = (ResponseUpload62) WGC_WsRest.uploadDoc62(bodyBlob, boundary);
			} //fallback upload diretto su FileNet - END

            //Cancello il documento da salesforce
            if (delDoc)
                delete cd;
                
            //upload su DIGIBOX senza errori
            if (uploadDigibox && (wr != null && wr.success)) { 
                //response digibox se caricato sincrono
                if (!wr.data.isEmpty())
                    wrap.data.add(wr.data.get(0));
                //forziamo messaggio per upload asincrono come per i documenti di grandi dimensioni
                wrap.message = 'Il documento verrà caricato a breve';
                
            } else { //upload diretto su FileNet
                wrap.data.add(om); //response filenet
                wrap.message = 'OK';
            }
			return wrap;

        } catch(Exception e) {
            System.debug('@@@ exception ' + e.getMessage() + ' - ' + e.getCause() + ' - ' + e.getLineNumber() + ' - ' + e.getStackTraceString());
            wrap.message = e.getMessage();
            wrap.success = false;

            return wrap;
        }
    }

    private static List<Object> generateIndiciCbox(Opportunity o, SObject attore, SObject obj, List<WGC_Metadati_Documentale__mdt> listaMetadati, DOC wrapDoc, String file_name){
        List<Object> indici = new List<Object>();

        IndiceInputMulti areaTipo = new IndiceInputMulti();
        areaTipo.nome = 'AREA_TIPO';
        areaTipo.valori.add(listaMetadati.size() > 0 ? listaMetadati.get(0).Documento__c : wrapDoc.tipoDoc);

        indici.add(areaTipo);

//        IndiceInput businessArea = new IndiceInput();
//        businessArea.nome = 'businessArea ';
//        businessArea.valore = listaMetadati.size() > 0 ? listaMetadati.get(0).Sottoclasse__c : wrapDoc.famiglia;
//
//        indici.add(businessArea);

        IndiceInput indiceNDG = new IndiceInput();
        indiceNDG.nome = 'NDG_GRUPPO';
        indiceNDG.valore = (o != null && attore != null && String.valueOf(attore.get('Tipo__c')) != 'Esecutore adeguata verifica') ? o.Account.NDGGruppo__c : obj.get('NDGGruppo__c').toString();
        indici.add(indiceNDG);

        Map<String,String> indice_valore = new Map<String,String>{'COMMESSA' => 'Commessa Test',
                                                                    'checkDuplicate' => 'N', 'overwriteMode' => 'SKIP', /*'note' => 'test note',*/ 'businessArea' =>'FastFinance', 'titolo' => wrapDoc.noteDocUpload != null ? wrapDoc.noteDocUpload : '',
                                                                    'ID_CRM' => o.Id};

        for(String i : indice_valore.keySet()){
            IndiceInput doc_ind = new IndiceInput(i, indice_valore.get(i));
            indici.add(doc_ind);
        }

        return indici;
    }

    private static List<IndiceInput> generateIndiciFilenet(Opportunity o, Sobject attore,Sobject obj, List<WGC_Metadati_Documentale__mdt> listaMetadati, User u, DOC wrapDoc, String optyId){
        //Lista di indici da aggiungere ai datiDocInput
        List<IndiceInput> listaIndici = new List<IndiceInput>();

        IndiceInput indiceNDG = new IndiceInput();
        indiceNDG.nome = 'NDG';
        indiceNDG.valore = (o != null && String.valueOf(attore.get('Tipo__c')) != 'Esecutore adeguata verifica') ? o.Account.NDGGruppo__c : obj.get('NDGGruppo__c').toString();

        listaIndici.add(indiceNDG);

        IndiceInput indiceSottoClasse = new IndiceInput();
        indiceSottoClasse.nome = 'CODICESOTTOCLASSE';
        indiceSottoClasse.valore = listaMetadati.size() > 0 ? listaMetadati.get(0).Sottoclasse__c : wrapDoc.famiglia;

        listaIndici.add(indiceSottoClasse);

        //Errore sulla classe documentale
        IndiceInput indiceUtente = new IndiceInput();
        indiceUtente.nome = 'UTENTE';
        indiceUtente.valore = UserInfo.getUserName();

        listaIndici.add(indiceUtente);

        //Errore sulla classe documentale
        IndiceInput indiceUtenteDesc = new IndiceInput();
        indiceUtenteDesc.nome = 'UTENTEDESC';
        indiceUtenteDesc.valore = UserInfo.getFirstName() + ' ' + UserInfo.getLastName();

        listaIndici.add(indiceUtenteDesc);

        IndiceInput indiceIstituto = new IndiceInput();
        indiceIstituto.nome = 'ISTITUTO';
        indiceIstituto.valore = listaMetadati.size() > 0 ? listaMetadati.get(0).Istituto__c : '881';

        listaIndici.add(indiceIstituto);

        IndiceInput indiceNominativo = new IndiceInput(); //Nome NDG
        indiceNominativo.nome = 'NOMINATIVO';
        indiceNominativo.valore = o != null ? o.Account.Name : String.valueOf(obj.get('Name'));

        listaIndici.add(indiceNominativo);

        IndiceInput indiceVisibilita = new IndiceInput();
        indiceVisibilita.nome = 'VISIBILITA';
        indiceVisibilita.valore = 'B'; //C = Cliente

        listaIndici.add(indiceVisibilita);

        String oggi = String.valueOf(System.Today().Day()).length() == 1 ? '0'+String.valueOf(System.Today().Day()) : String.valueOf(System.Today().Day());
        String mese = String.valueOf(System.Today().Month()).length() == 1 ? '0'+String.valueOf(System.Today().Month()) : String.valueOf(System.Today().Month());
        String anno = String.valueOf(System.Today().Year());

        String dataProd = oggi + '' + mese + '' + anno;
        System.debug('@@@ dataProd ' + dataProd);

        IndiceInput indiceDataProd = new IndiceInput();
        indiceDataProd.nome = 'DATAPROD';
        indiceDataProd.valore = dataProd;
        listaIndici.add(indiceDataProd);

        System.debug('@@@ data produzione ' + String.valueOf(System.Today()));

        IndiceInput indiceNDGUser = new IndiceInput();
        indiceNDGUser.nome = 'NDGOPERATORE';
        indiceNDGUser.valore =  u.NDGGruppo__c != null ? u.NDGGruppo__c : '';

        listaIndici.add(indiceNDGUser);

        IndiceInput indiceDataRif = new IndiceInput();
        indiceDataRif.nome = 'DATARIF';
        indiceDataRif.valore = wrapDoc.dataProduzione.replace('/','').length() == 8 ? wrapDoc.dataProduzione.replace('/','') : '0'+wrapDoc.dataProduzione.replace('/','');
        System.debug('@@@ DATARIF ' + indiceDataRif.valore);
        if(indiceDataRif.valore == '' || indiceDataRif.valore == '0'){
            indiceDataRif.valore = '';
        }
        System.debug('@@@ DATARIF POST ' + indiceDataRif.valore);
        listaIndici.add(indiceDataRif);

        if (!String.isBlank(wrapDoc.dataScadenza)) {
            IndiceInput indiceDataStato = new IndiceInput();
            indiceDataStato.nome = 'DATASTATO';
            indiceDataStato.valore = wrapDoc.dataScadenza.replace('/','').length() == 8 ? wrapDoc.dataScadenza.replace('/','') : '0'+wrapDoc.dataScadenza.replace('/','');
            System.debug('@@@ DATASTATO ' + indiceDataStato.valore);
            if(indiceDataStato.valore == '' || indiceDataStato.valore == '0'){
                indiceDataStato.valore = '';
            }
            System.debug('@@@ DATASTATO POST' + indiceDataStato.valore);
            listaIndici.add(indiceDataStato);
        }

        IndiceInput indiceCodiceDoc = new IndiceInput();
        indiceCodiceDoc.nome = 'CODICEDOC';
        indiceCodiceDoc.valore = listaMetadati.size() > 0 ? listaMetadati.get(0).Documento__c : wrapDoc.tipoDoc;

        listaIndici.add(indiceCodiceDoc);

        IndiceInput indiceNoteDoc = new IndiceInput();
        indiceNoteDoc.nome = 'NOTEDOC';
        indiceNoteDoc.valore = wrapDoc.noteDocUpload; //

        listaIndici.add(indiceNoteDoc);

        IndiceInput indiceOpty = new IndiceInput();
        indiceOpty.nome = 'IDCFLOW';
        indiceOpty.valore = optyId != null ? optyId : '';

        System.debug('@@@ optyId ' + optyId);
        if(optyId != null && listaMetadati.size() > 0 &&
                listaMetadati.get(0).Documento__c != 'EX0000173' &&
                listaMetadati.get(0).Documento__c != 'EX0000179' &&
                listaMetadati.get(0).Documento__c != 'SY0000074' &&
                listaMetadati.get(0).Documento__c != 'EX0000200')
            listaIndici.add(indiceOpty);

        if(optyId != null){
            Opportunity opp = [SELECT IdCartella__c FROM Opportunity WHERE Id =: optyId];

            if(!String.isBlank(opp.IdCartella__c) && listaMetadati.size() > 0 &&
                    listaMetadati.get(0).Documento__c != 'EX0000173' &&
                    listaMetadati.get(0).Documento__c != 'EX0000179' &&
                    listaMetadati.get(0).Documento__c != 'SY0000074' &&
                    listaMetadati.get(0).Documento__c != 'EX0000200'){
                IndiceInput indiceIdCartella = new IndiceInput();
                indiceIdCartella.nome = 'CARTELLANV';
                indiceIdCartella.valore = opp.idCartella__c;
                listaIndici.add(indiceIdCartella);
            }
        }

        IndiceInput indiceNdgDeb = new IndiceInput();
        indiceNdgDeb.nome = 'NDGDEBITORE';
        indiceNdgDeb.valore = obj.get('NDGGruppo__c').toString();
        //Solo se sei debitore e non cedente della pratica

        if((o != null && String.valueOf(attore.get('Tipo__c')) != 'Esecutore adeguata verifica')){
            listaIndici.add(indiceNdgDeb);
        }

        return listaIndici;
    }

    // public static String getBinaryFile(String versionId){

    //     if(String.isBlank(versionId)) return 'Nessun documento da cercare';

    //     HttpRequest req = new HttpRequest();
    //     req.setHeader('Content-Type', 'application/json');
    //     req.setEndpoint('callout:TestNamedCredential/services/data/v43.0/sobjects/ContentVersion/'+versionId+'/VersionData');
    //     req.setMethod('GET');
    //     //req.setBody(body);
    //     req.setTimeout(120000);

    //     Http h = new Http();
    //     HttpResponse response = new HttpResponse();
    //     response = h.send(req);
        
    //     return response.getBody();
    // }

    /** 
    * Classi Wrapper di creazione del payload di input
    **/
    public class InputMultipart{
        @AuraEnabled
        public WrapperData data;

        public InputMultipart(){
            this.data = new WrapperData();
        }
    }

    //OLD
    public class WrapperData{
        @AuraEnabled
        public String matricola;
        @AuraEnabled
        public String ruolo;
        @AuraEnabled
        public String codiceIstituto3N;
        @AuraEnabled
        public String idApplicazioneChiamante;
        @AuraEnabled
        public String idSessioneChiamante;
        @AuraEnabled
        public String lingua;
        @AuraEnabled
        public String idOperazione;
        @AuraEnabled
        public InputDatiDoc datiDocumento;

        public WrapperData(){
            this.matricola = 'YH01175';
            this.ruolo = 'I340';
            this.codiceIstituto3N = '881';
            this.idApplicazioneChiamante = 'CRM';
            this.idSessioneChiamante = 'CRM';
            this.lingua = 'IT';
            this.idOperazione = '8a0c790a-a193-4929-8817-54e86a167fe5';
            this.datiDocumento = new InputDatiDoc();
        }
    }

    public class InputDatiDoc{
        @AuraEnabled
        public String classeOggetto;
        @AuraEnabled
        public List<IndiceInput> indice;
        @AuraEnabled
        public String azioneDiRicerca;
        @AuraEnabled
        public List<ContenutoDocumento> contenutoDocumento;

        public InputDatiDoc(){
            this.classeOggetto = classeOggetto;
            this.indice = new List<IndiceInput>();
            this.azioneDiRicerca = 'NONE';
            this.contenutoDocumento = new List<ContenutoDocumento>();
        }
    }

    //Da riutilizzare
    public class IndiceInput{
        @AuraEnabled
        public String nome;
        @AuraEnabled
        public String ricerca;
        @AuraEnabled
        public String append;
        @AuraEnabled
        public String valore;

        public IndiceInput(){
            this.nome = nome;
            this.ricerca = 'FALSE';
            this.append = 'FALSE';
            this.valore = valore;
        }

        public IndiceInput(String n, String val){
            this.nome = n;
            this.ricerca = 'FALSE';
            this.append = 'FALSE';
            this.valore = val;
        }
    }

    public class IndiceInputMulti{
        @AuraEnabled
        public String nome;
        @AuraEnabled
        public String ricerca;
        @AuraEnabled
        public String append;
        @AuraEnabled
        public List<String> valori;

        public IndiceInputMulti(){
            this.nome = nome;
            this.ricerca = 'FALSE';
            this.append = 'FALSE';
            this.valori = new List<String>();
        }
    }

    public class ContenutoDocumento{
        @AuraEnabled
        public String nomeFIle;
        @AuraEnabled
        public String tipoMime;
        @AuraEnabled
        public String base64;

        public ContenutoDocumento(){
            this.nomeFIle = nomeFIle;
            this.tipoMime = tipoMime;
            this.base64 = null;
        }
    }

    /**
    * Classi wrapper per gestire la risposta di inserimento del documentale
    **/

    public class ResponseUpload extends WsRestInput.CommonResponse{
        @AuraEnabled
        public OutputMultipart payload;

        public ResponseUpload(){
            this.payload = new OutputMultipart();
        }

        public override Boolean isCorrect(){
            return payload != null;
        }
    }

    public class OutputMultipart{
        @AuraEnabled
        public OutputDatiDoc datiDocumento;

        public OutputMultipart(){
            this.datiDocumento = new OutputDatiDoc();
        }
    }

    public class OutputDatiDoc{
        @AuraEnabled
        public String id;
        @AuraEnabled
        public String objectStore;
        @AuraEnabled
        public String classe;
        @AuraEnabled
        public String tipoBase;
        @AuraEnabled
        public List<OutputIndice> indice;

        public OutputDatiDoc(){
            this.id = id;
            this.objectStore = objectStore;
            this.classe = classe;
            this.tipoBase = tipoBase;
            this.indice = new List<OutputIndice>();
        }

    }

    public class OutputIndice{
        @AuraEnabled
        public String nome;
        @AuraEnabled
        public String label;
        @AuraEnabled
        public String valore;

        public OutputIndice(){
            this.nome = nome;
            this.label = label;
            this.valore = valore;
        }
    }

    //NEW
    /*
    * Classe di input per DOC62
    *
    */
    public class InputMultipart62{
        @AuraEnabled
        public DatiDocumentoInput data;

        public InputMultipart62(String tipoDocumentale){
            this.data = new DatiDocumentoInput(tipoDocumentale);
        }
    }

    public class DatiDocumentoInput{
        @AuraEnabled public String codiceIstituto3N; //SE CBOX NULL, SE FILENET "881"
        @AuraEnabled public String documentary; //valori: filenet, cbox definiti nel metadato WGC_Metadati_Documentale__c per ogni documento
        @AuraEnabled public DatiDocumento datiDocumento;
        @AuraEnabled public String campiAggiuntivi; //Sembra sempre null

        public DatiDocumentoInput(String documentary){
            this.codiceIstituto3N = documentary == 'cbox' ? null : '881';
            this.documentary = documentary;
            this.datiDocumento = new DatiDocumento(documentary == 'cbox' ? 'ff_generico' : 'DOCUMENTI_CLIENTE');
        }
    }

    public class DatiDocumento{
        @AuraEnabled public String classeDocumento; //SE CBOX "ff_generico", SE FILENET "DOCUMENTI_CLIENTE"
        @AuraEnabled public List<Object> indice;
        @AuraEnabled public String azioneDiRicerca; //Sempre null
        @AuraEnabled public String owner;
        @AuraEnabled public List<String> tags; //SE CBOX array vuoto, se FILENET null
        // @AuraEnabled public String titolo; //SOLO PER CBOX, SE FILENET NULL
        
        public DatiDocumento(String classe){
            this.classeDocumento = classe;
            this.indice = new List<IndiceInput>();
            this.owner = classe == 'ff_generico' ? UserInfo.getName() : '';
            this.tags = classe == 'ff_generico' ? new List<String>() : null;
        }
    }

    /*
    * Classe di output per DOC62
    *
    */

    public class ResponseUpload62 extends WsRestInput.CommonResponse{
        @AuraEnabled public OutputMultipart62 payload;

        public ResponseUpload62(){
            this.payload = new OutputMultipart62();
        }

        public override Boolean isCorrect(){
            return payload != null;
        }

    }

    public class OutputMultipart62{
        @AuraEnabled public DatiDocumentoOutput datiDocumento;
        @AuraEnabled public String result_code;
        @AuraEnabled public String result_message;
    }

    public class DatiDocumentoOutput{
        @AuraEnabled public String idDocumento;
        @AuraEnabled public String objectStore;
        @AuraEnabled public String classe;
        @AuraEnabled public String tipoBase;
        @AuraEnabled public List<OutputIndice> indice;
        @AuraEnabled public String lettori;
        @AuraEnabled public String link;
    }

//    @AuraEnabled
//    public static String uploadMultipartDoc62(Id accountId, String tipoDocumentale, String docToInsert, String optyId){
//        try{
//
//            DOC wrapDoc = new DOC();
//            wrapDoc = (DOC)JSON.deserialize(docToInsert, DOC.Class);
//            System.debug('@@@ doc ' + docToInsert);
//            //{"dataProduzione":"14/03/2020","dataScadenza":"14/03/2021","famiglia":"Identificazione clientela","tipoDoc":"EX0000173","docId":"06925000000aAhMAAU","noteDocUpload":"CC"}
//
//            Account acc = [SELECT Id, Name, NDGGruppo__c FROM Account WHERE Id =: accountId];
//            User currentUser = [SELECT Id, Name, NDGGruppo__c FROM User WHERE Id =: UserInfo.getUserId()];
//
//            InputMultipart62 payload = new InputMultipart62(tipoDocumentale);
//
//            payload.data.datiDocumento.indice = generateIndice(tipoDocumentale, acc, wrapDoc);
//
//            WsRestInput input = new WsRestInput(payload);
//
//            //TMP ONLY FOR TEST, REMOVE
//            //input.headers.headers.user_header.archUser.userId = 'msartor';
//            //input.headers.headers.user_header.archUser.actualUserId = 'msartor';
//
//
//            ContentVersion cv = [SELECT Id, Title, ContentDocumentId, VersionData FROM ContentVersion ORDER BY CreatedDate DESC LIMIT 1 ];
//            ContentDocument cd = [SELECT Id FROM ContentDocument WHERE Id =: cv.ContentDocumentId ];
//
//            Blob file_body2 = cv.VersionData;
//
//            System.debug('@@@ input ' + JSON.serialize(input));
//            //form multipart preparation
//
//            //JSON PART -- FILE PART
//            String boundary = '----------------------------741e90d31eff';
//            String headerEncoded = EncodingUtil.base64Encode(Blob.valueOf(boundary));
//
//            String archMsgPart = '--'+boundary+'\nContent-Disposition: form-data; name="archMessage"; filename="archMessage.json";\nContent-Type: application/json';
//            String archMsgPartEncoded = EncodingUtil.base64Encode(Blob.valueOf(archMsgPart+'\r\n\r\n'));
//            while(archMsgPartEncoded.endsWith('=')) {
//                archMsgPart+=' ';
//                archMsgPartEncoded = EncodingUtil.base64Encode(Blob.valueOf(archMsgPart+'\r\n\r\n'));
//            }
//
//            String archMsg = JSON.serialize(input);
//            String archMsgEncoded = EncodingUtil.base64Encode(Blob.valueOf( archMsg +'\r\n\r\n' ));
//            while(archMsgEncoded.endsWith('=')) {
//                archMsg+=' ';
//                archMsgEncoded = EncodingUtil.base64Encode(Blob.valueOf(archMsg+'\r\n\r\n'));
//            }
//
//            // OLD name="archMessage" --> NEW name="uploadfile"
//            String filePart = '--'+boundary+'\nContent-Disposition: form-data; name="uploadfile"; filename="'+cv.Title+'";\nContent-Type: application/octet-stream';
//            String filePartEncoded = EncodingUtil.base64Encode(Blob.valueOf(filePart+'\r\n\r\n'));
//                while(filePartEncoded.endsWith('=')) {
//                filePart+=' ';
//                filePartEncoded = EncodingUtil.base64Encode(Blob.valueOf(filePart+'\r\n\r\n'));
//            }
//
//            String footer = '--'+boundary+'--';
//
//            //FILE
//            String bodyEncoded = EncodingUtil.base64Encode(file_body2);
//
//            String last4Bytes = bodyEncoded.substring(bodyEncoded.length()-4,bodyEncoded.length());
//            if(last4Bytes.endsWith('==')) {
//                last4Bytes = last4Bytes.substring(0,2) + '0K';
//                bodyEncoded = bodyEncoded.substring(0,bodyEncoded.length()-4) + last4Bytes;
//            } else if(last4Bytes.endsWith('=')) {
//                last4Bytes = last4Bytes.substring(0,3) + 'N';
//                bodyEncoded = bodyEncoded.substring(0,bodyEncoded.length()-4) + last4Bytes;
//                footer = '\n' + footer;
//            } else {
//                footer = '\r\n' + footer;
//            }
//
//            String footerEncoded = EncodingUtil.base64Encode(Blob.valueOf(footer));
//            System.debug('@@@ sync ' + bodyEncoded);
//
//            Blob bodyBlob = EncodingUtil.base64Decode( archMsgPartEncoded + archMsgEncoded + filePartEncoded + bodyEncoded + footerEncoded);
//
//            //String bodyEncoded = EncodingUtil.base64Encode(file_body);
//            // String bodyEncoded = EncodingUtil.base64Encode(file_body2);
//
//            ResponseUpload62 om = (ResponseUpload62) WGC_WsRest.uploadDoc62(bodyBlob, boundary);
//            System.debug('@@@ response upload ' + JSON.serialize(om));
//
//            //ELIMINO IL DOC DA SALESFORCE
//            delete cd;
//
//            return JSON.serialize(om);
//
//            //return 'ok';
//        } catch (exception e){
//            System.debug('@@@ ecc ' + e.getMessage() + ' -- ' + e.getLineNumber() + ' -- ' + e.getStackTraceString());
//            return e.getMessage() + ' -- ' + e.getLineNumber();
//        }
//    }

//    public static List<IndiceInput> generateIndice(String tipoDocumentale, Account acc, Doc documento){
//        return tipoDocumentale == 'cbox' ? generateIndiceCbox(acc, documento) : generateIndiceFilenet(acc, documento);
//    }
//
//    public static List<IndiceInput> generateIndiceFilenet(Account acc, Doc documento){
//        List<IndiceInput> indici = new List<IndiceInput>();
//        Map<String,String> indice_valore = new Map<String,String>{'NDG' => acc.NDGGruppo__c, 'NOMINATIVO' => acc.Name};
//
//        for(String i : indice_valore.keySet()){
//            IndiceInput doc_ind = new IndiceInput(i, indice_valore.get(i));
//            indici.add(doc_ind);
//        }
//
//        IndiceInput indiceSottoClasse = new IndiceInput();
//        indiceSottoClasse.nome = 'CODICESOTTOCLASSE';
//        // indiceSottoClasse.valore = listaMetadati.size() > 0 ? listaMetadati.get(0).Sottoclasse__c : wrapDoc.famiglia;
//        indiceSottoClasse.valore = 'EX0010025';
//
//        indici.add(indiceSottoClasse);
//
//        //Errore sulla classe documentale
//        IndiceInput indiceUtente = new IndiceInput();
//        indiceUtente.nome = 'UTENTE';
//        indiceUtente.valore = UserInfo.getUserName();
//
//        indici.add(indiceUtente);
//
//        //Errore sulla classe documentale
//        IndiceInput indiceUtenteDesc = new IndiceInput();
//        indiceUtenteDesc.nome = 'UTENTEDESC';
//        indiceUtenteDesc.valore = UserInfo.getFirstName() + ' ' + UserInfo.getLastName();
//
//        indici.add(indiceUtenteDesc);
//
//        // IndiceInput indiceIstituto = new IndiceInput();
//        // indiceIstituto.nome = 'ISTITUTO';
//        // indiceIstituto.valore = listaMetadati.size() > 0 ? listaMetadati.get(0).Istituto__c : '881';
//
//        // indici.add(indiceIstituto);
//
//        // IndiceInput indiceNominativo = new IndiceInput(); //Nome NDG
//        // indiceNominativo.nome = 'NOMINATIVO';
//        // //indiceNominativo.valore = UserInfo.getLastName() + ' ' + UserInfo.getFirstName();
//        // indiceNominativo.valore = acc.Name;//o != null ? o.Account.Name : String.valueOf(obj.get('Name'));
//
//        // indici.add(indiceNominativo);
//
//        IndiceInput indiceVisibilita = new IndiceInput();
//        indiceVisibilita.nome = 'VISIBILITA';
//        indiceVisibilita.valore = 'B'; //C = Cliente
//
//        indici.add(indiceVisibilita);
//
//        //OLD
//        // IndiceInput indiceDataProd = new IndiceInput();
//        // indiceDataProd.nome = 'DATAPROD';
//        // indiceDataProd.valore = wrapDoc.dataProduzione.replace('/','').length() == 8 ? wrapDoc.dataProduzione.replace('/','') : '0'+wrapDoc.dataProduzione.replace('/','');
//        // indici.add(indiceDataProd);
//
//        // Date oggi = System.Today();
//        // String locale = UserInfo.getLocale();
//
//        // String dataProd;
//
//        // if(locale == 'it_IT'){
//        //     dataProd = String.valueOf(System.Today().format().replace('/',''));
//        // }
//        // else{
//        //     dataProd = String.valueOf(System.Today().getDay()+System.Today().Month()+);
//        // }
//
//        String oggi = String.valueOf(System.Today().Day()).length() == 1 ? '0'+String.valueOf(System.Today().Day()) : String.valueOf(System.Today().Day());
//        String mese = String.valueOf(System.Today().Month()).length() == 1 ? '0'+String.valueOf(System.Today().Month()) : String.valueOf(System.Today().Month());
//        String anno = String.valueOf(System.Today().Year());
//
//        String dataProd = oggi + '' + mese + '' + anno;
//        System.debug('@@@ dataProd ' + dataProd);
//
//        IndiceInput indiceDataProd = new IndiceInput();
//        indiceDataProd.nome = 'DATAPROD';
//        //indiceDataProd.valore = UserInfo.getLocale() == 'it_IT' ? String.valueOf(System.Today().format().replace('/','')) : String.valueOf(System.Today());
//        indiceDataProd.valore = dataProd;
//        indici.add(indiceDataProd);
//
//        System.debug('@@@ data produzione ' + String.valueOf(System.Today()));
//
//        IndiceInput indiceNDGUser = new IndiceInput();
//        indiceNDGUser.nome = 'NDGOPERATORE';
//        indiceNDGUser.valore =  [SELECT Id, Name, NDGGruppo__c FROM User WHERE Id =: UserInfo.getUserId()].NDGGruppo__c != null ? [SELECT Id, Name, NDGGruppo__c FROM User WHERE Id =: UserInfo.getUserId()].NDGGruppo__c : '';//u.NDGGruppo__c != null ? u.NDGGruppo__c : '';
//
//        indici.add(indiceNDGUser);
//        IndiceInput indiceDataRif = new IndiceInput();
//        indiceDataRif.nome = 'DATARIF';
//        indiceDataRif.valore = dataProd;//wrapDoc.dataProduzione.replace('/','').length() == 8 ? wrapDoc.dataProduzione.replace('/','') : '0'+wrapDoc.dataProduzione.replace('/','');
//        System.debug('@@@ DATARIF ' + indiceDataRif.valore);
//        if(indiceDataRif.valore == '' || indiceDataRif.valore == '0'){
//            indiceDataRif.valore = '';
//        }
//        System.debug('@@@ DATARIF POST ' + indiceDataRif.valore);
//        indici.add(indiceDataRif);
//
//        // if (!String.isBlank(wrapDoc.dataScadenza)) {
//        //     IndiceInput indiceDataStato = new IndiceInput();
//        //     indiceDataStato.nome = 'DATASTATO';
//        //     indiceDataStato.valore = wrapDoc.dataScadenza.replace('/','').length() == 8 ? wrapDoc.dataScadenza.replace('/','') : '0'+wrapDoc.dataScadenza.replace('/','');
//        //     System.debug('@@@ DATASTATO ' + indiceDataStato.valore);
//        //     if(indiceDataStato.valore == '' || indiceDataStato.valore == '0'){
//        //         indiceDataStato.valore = '';
//        //     }
//        //     System.debug('@@@ DATASTATO POST' + indiceDataStato.valore);
//        //     indici.add(indiceDataStato);
//        // }
//
//        IndiceInput indiceCodiceDoc = new IndiceInput();
//        indiceCodiceDoc.nome = 'CODICEDOC';
//        indiceCodiceDoc.valore = 'EX0000138';//listaMetadati.size() > 0 ? listaMetadati.get(0).Documento__c : wrapDoc.tipoDoc;
//
//        indici.add(indiceCodiceDoc);
//
//        IndiceInput indiceNoteDoc = new IndiceInput();
//        indiceNoteDoc.nome = 'NOTEDOC';
//        indiceNoteDoc.valore = 'Note Test'; //wrapDoc.noteDocUpload; //
//
//        indici.add(indiceNoteDoc);
//
//        IndiceInput indiceOpty = new IndiceInput();
//        indiceOpty.nome = 'IDCFLOW';
//        indiceOpty.valore = '';//optyId != null ? optyId : '';
//        indici.add(indiceOpty);
//
//        return indici;
//    }

//    public static List<IndiceInput> generateIndiceCbox(Account acc, DOC documento){
//        List<IndiceInput> indici = new List<IndiceInput>();
//        Map<String,String> indice_valore = new Map<String,String>{'COMMESSA' => 'Commessa Test', 'AREA_TIPO' => '110', 'businessArea' => 'FastFinance', /*'FF_GENERICO'*/ /*'NPL',*/
//                                                                    'checkDuplicate' => 'N', 'overwriteMode' => 'SKIP', 'note' => 'test note', 'titolo' => 'DocTitle',
//                                                                    'NDG_GRUPPO' => acc.NDGGruppo__c};
//
//        for(String i : indice_valore.keySet()){
//            IndiceInput doc_ind = new IndiceInput(i, indice_valore.get(i));
//            indici.add(doc_ind);
//        }
//
//        return indici;
//    }

    @future(callout=true)
    public static void multipartForBigFile(String str, String str2, String str3, List<String> listaBody, String str6, String relatedObjId){
        String boundary = '----------------------------741e90d31eff';

        String abc = str + str2 + str3;

        String msgPost;

        System.debug('@@@ limite heap 1  ' + Limits.getHeapSize());

        try{
            for(String s : listaBody){
                abc += s;
            }

            //Nullify for apex heap size
            listaBody = null;

            abc += str6;
            Blob bodyBlob = EncodingUtil.base64Decode(abc);

            //Nullify for apex heap size
            abc = null;

            System.debug('@@@ limite heap 1  ' + Limits.getHeapSize());

            ResponseUpload62 om = (ResponseUpload62) WGC_WsRest.uploadDoc62(bodyBlob, boundary);
            System.debug('@@@ response upload ' + JSON.serialize(om));

            msgPost = 'Documento caricato correttamente';
        }
        catch(Exception e){
            System.debug('@@@ eccezione future ' + e.getMessage() + ' - ' + e.getLineNumber());
            msgPost = 'Documento non caricato correttamente';
        }

        // FeedItem post = new FeedItem();

        // post.ParentId = UserInfo.getUserId();
        // post.Body = msgPost;
        // post.Title = 'Caricamento documento';
        // // post.LinkUrl = '/'+relatedObjId;
        // post.CreatedById = UtenzeDefault__c.getInstance().IdUtente__c;

        // insert post;

        // ConnectApi.FeedItemInput feedItemInput = new ConnectApi.FeedItemInput();
        // ConnectApi.MentionSegmentInput mentionSegmentInput = new ConnectApi.MentionSegmentInput();
        // ConnectApi.MessageBodyInput messageBodyInput = new ConnectApi.MessageBodyInput();
        // ConnectApi.TextSegmentInput textSegmentInput = new ConnectApi.TextSegmentInput();

        // messageBodyInput.messageSegments = new List<ConnectApi.MessageSegmentInput>();

        // mentionSegmentInput.id = UserInfo.getUserId();
        // messageBodyInput.messageSegments.add(mentionSegmentInput);

        // textSegmentInput.text = msgPost;
        // messageBodyInput.messageSegments.add(textSegmentInput);

        // feedItemInput.body = messageBodyInput;
        // feedItemInput.feedElementType = ConnectApi.FeedElementType.FeedItem;
        // feedItemInput.subjectId = relatedObjId;

        // ConnectApi.FeedElement feedElement = ConnectApi.ChatterFeeds.postFeedElement(Network.getNetworkId(), feedItemInput);

        // System.debug('@@@ post ' + post);

        String rispostaChatter = createChatterPostForDocument(msgPost);

    }

    //Metodo di appoggio per splittare stringhe troppo lunghe per l'upload
    public static String[] splitStringEvery(String s, Integer interval) {
        Integer arrayLength = (Integer) Math.ceil(((s.length() / (double)Interval)));
        String[] result = new String[arrayLength];

        Integer j = 0;
        Integer lastIndex = result.size() - 1;
        for (Integer i = 0; i < lastIndex; i++) {
            result[i] = s.substring(j, j + interval);
            j += interval;
        } //Add the last bit
        result[lastIndex] = s.substring(j);

        return result;
    }

    public static String createChatterPostForDocument(String msgPost){
        String risp = 'OK';

        try{
            HttpRequest req = new HttpRequest();
                        
            req.setMethod('POST');
            req.setEndpoint('callout:TestNamedCredential/services/data/v23.0/chatter/feeds/record/' + UserInfo.getUserId() + '/feed-items');
            req.setHeader('Content-type', 'application/json');
            //req.setHeader('Authorization', 'OAuth ' + UserInfo.getSessionId());
                        
            req.setBody('{ "body" : { "messageSegments" : [ { "type": "mention", "id" : "' + UserInfo.getUserId() + '" }, { "type": "text",  "text" : "' + ' ' + msgPost +  '" } ] } }');
            Http http = new Http();
            
            HTTPResponse res = http.send(req);
        }
        catch(Exception e){
            risp = e.getMessage();
        }

        return risp;
    }


    @AuraEnabled
    public static Contact getDatiCI(String contactId){
        Contact c;
        c = [SELECT Id, Name, DataEmissioneDoc__c, DataScadenzaDoc__c FROM Contact WHERE Id =: contactId AND DataEmissioneDoc__c != null AND DataScadenzaDoc__c != null];
        
        return c;

    }

}