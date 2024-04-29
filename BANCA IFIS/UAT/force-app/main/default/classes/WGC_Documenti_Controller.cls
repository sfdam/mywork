public class WGC_Documenti_Controller {

    @AuraEnabled
    public static WrapperResponse getDocumentData(String accountId){
        WrapperResponse wr = new WrapperResponse();

        try{
            Result r = new Result();
            //Recupero tutti i documenti di prima visita, se esistono setto il colore blu nei box, se non esiste o non è più valido setto il colore del box rosso
            //Privacy Persona Giurida && Modulo Tecniche di Comunicazione devo recuperare i dati direttamente da account
            Account a = new Account();
            a = [SELECT Id, Name, ConsensoAllaProfilazione__c, ConsensoAttivitaPromRicercheMercato__c, ConsensoAttivitaPromozionaleTerzi__c,
                ConsensoProdottiBancaRicercheMercato__c, ConsensoProdottiSocietaTerze__c, ConsensoSoloModalitaTradizionali__c, 
                Email__c, EmailPEC__c, Phone, Fax, CreatedDate, BillingAddress, ShippingAddress, DataInserimentoConsensi__c FROM Account WHERE Id =: accountId];
            //Controllo compilazione privacy
            if(a.DataInserimentoConsensi__c != null){
                r.accountList.add(a);
            }

            if((a.get('Email__c') != null || a.get('EmailPEC__c') != null || a.get('Phone') != null || a.get('Fax') != null) ||
                (a.get('BillingAddress') != null) || (a.get('ShippingAddress') != null)){
                r.accountListMTC.add(a);
            }
            //Questionario
            // List<QuestionarioQualitativo__c> qq = new List<QuestionarioQualitativo__c>();
            // qq = [SELECT Id, Name, DataCompilazione__c, CreatedDate FROM QuestionarioQualitativo__c WHERE Account__c =: accountId AND Stato__c = 'Confermato' ORDER BY DataCompilazione__c DESC LIMIT 1];
            // if(!qq.isEmpty() && qq.get(0).DataCompilazione__c != null){
            //     r.qqList.add(qq.get(0));
            // }
            //Modulo adeguata verifica
            List<AdeguataVerifica__c> mav = new List<AdeguataVerifica__c>();
            mav = [SELECT Id, Name, CreatedDate, WGC_Data_Compilazione__c,WGC_TipologiaMav__c FROM AdeguataVerifica__c WHERE Account__c =: accountId AND WGC_Data_Compilazione__c != null ORDER BY WGC_Data_Compilazione__c DESC LIMIT 1];
            if(!mav.isEmpty() && mav.get(0).WGC_Data_Compilazione__c != null){
                r.mavList.add(mav.get(0));
            }
            //Relazione Prima Visita
            List<RelazionePrimaVisita__c> rpv = new List<RelazionePrimaVisita__c>();
            rpv = [SELECT Id, Name, CreatedDate FROM RelazionePrimaVisita__c WHERE Account__c =: accountId ORDER BY CreatedDate LIMIT 1];
            if(!rpv.isEmpty()){
                r.rpvList.add(rpv.get(0));
            }
            //Aggiungo le liste di tutti i documenti
            wr.data.add(r);

            wr.success = true;
            return wr;
        }
        catch(AuraException e){
            wr.success = false;
            wr.message = e.getMessage();
            return wr;
        }

    }

    public class WrapperResponse{
        @AuraEnabled
        public Boolean success;
        @AuraEnabled
        public String message;
        @AuraEnabled
        public List<Object> data; 

        public WrapperResponse(){
            this.success = true;
            this.message = '';
            this.data = new List<Object>();
        }
    }

    public class Result {
        @AuraEnabled public List<Account> accountList;
        @AuraEnabled public List<Account> accountListMTC;
        @AuraEnabled public List<QuestionarioQualitativo__c> qqList;
        @AuraEnabled public List<AdeguataVerifica__c> mavList;
        @AuraEnabled public List<RelazionePrimaVisita__c> rpvList;

        public Result(){
            this.accountList = new List<Account>();
            this.accountListMTC = new List<Account>();
            this.qqList = new List<QuestionarioQualitativo__c>();
            this.mavList = new List<AdeguataVerifica__c>();
            this.rpvList = new List<RelazionePrimaVisita__c>();
        }
    }

    //Metodo utilizzato per generare una sezione documenti opportunità factoring, per ogni opportunità factoring associata all'anagrafica
    @AuraEnabled
    public static WrapperResponse getOptyFactoring(String accountId){
        
        List<Opportunity> optyFact = new List<Opportunity>();
        WrapperResponse wrap = new WrapperResponse();

        // try{
        optyFact = [SELECT Id, Name, StageName FROM Opportunity WHERE AccountId =: accountId AND RecordType.DeveloperName = 'IFISOpportunitaFactoring'];

        wrap.data = optyFact;

        return wrap;
        // }
        // catch(Exception e){
        //     wrap.success = false;
        //     wrap.message = e.getMessage();

        //     return wrap;
        // }
    }

    //Chiamata al servizio CheckList DOC10
    @AuraEnabled
    public static WrapperResponse docCheckList(String objId){
        
        WrapperResponse wrap = new WrapperResponse();

        try{
            Id objectId = (Id)objId;
            String objectName = objectId.getSObjectType().getDescribe().getName();
            
            Sobject obj;
            if(objectName == 'Account'){
                obj = (Sobject) Database.query(
                    QueryBuilder.newInstance(objectName, new String[] {
                        'Id',
                        'Name',
                        'NDGGruppo__c',
                        'codiceIstituto3N__c',
                        'NaturaGiuridica__c',
                        'WGC_Alert_KPI_Centrale_Rischi__c'
                        })
                        .beginFilter()
                        .add('Id', QBOp.QEQUAL, objectId)
                        .endFilter()
                        .getQuery()
                    );
            }
            else{
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

            if(obj.get('CodiceIstituto3N__c') != '881'){
                wrap.message = 'Anagrafica non 881';
                wrap.success = false;

                return wrap;
            }

            InputDoc10 inputDoc10 = new InputDoc10(obj, objectName);

            WsRestInput input = new WsRestInput(inputDoc10);
            
            OutputDoc10 outputDoc = new OutputDoc10();
        
            outputDoc = (OutputDoc10) WGC_WsRest.doc10(inputDoc10);
            
            Set<String> chiaviDocXId = new Set<String>();
            for(ResultDoc10 item : outputDoc.payload.results){
                String chiave = String.valueOf(obj.get('Id')) + '_' + item.index_value;
                chiaviDocXId.add(chiave);
            }

            List<WGC_Nota_Documento__c> notesAcc = [SELECT Id, Name, Id_Univoco__c, Note__c FROM WGC_Nota_Documento__c WHERE Id_Univoco__c IN: chiaviDocXId];


            wrap.data.add(outputDoc);
            wrap.data.add(notesAcc);
            //return JSON.serialize(outputDoc);
            return wrap;
        }
        catch(Exception e){
            wrap.message = e.getMessage();
            wrap.success = false;
            
            return wrap;
        }
        
    }

    //Chiamata al servizio doc10 quando sono all'interno del carrello per recuperarmi tutti i documenti relativi alla pratica, esecutore e ai garanti e ai debitori
    @AuraEnabled
    public static WrapperResponse docCheckListCarrello(String opportunityId){
        WrapperResponse response = new WrapperResponse();

        try{
            Opportunity opp = [SELECT Id, StageName, WGC_Codice_Pratica__c, IdCartella__c, AccountId, Account.NDGGruppo__c, 
                                Account.CodiceIstituto3N__c, Account.WGC_Alert_KPI_Centrale_Rischi__c, IsOppNSA__c, TiAnticipo__c, RecordType.DeveloperName, WGC_Assuntore__c FROM Opportunity WHERE Id =: opportunityId];
                
            //Recupero le info per capire i tag da inserire nei parametri della chiamata
            //SE eventi negativi tutti 'G' allora inserisco il tag di alert, se sono tutti 'V' allora non inserisco tag alert
            Account acc = [SELECT Id, Name, CodiceIstituto3N__c, NDGGruppo__c, NaturaGiuridica__c, WGC_Semaforo_Gianos__c, WGC_Semaforo_CLC__c, 
                                    WGC_Gruppo_frm__c, EventiNegativiProtesti__c, EventiNegativiProcedureConcorsuali__c,
                                    EventiNegativiPregiudizievoli__c, EventiNegativiCIGS__c,
                                    EventiNegativiAllarmiQuote__c, EventiNegativiGlobale__c, WGC_Alert_KPI_Centrale_Rischi__c
                            FROM Account WHERE Id =: opp.AccountId];

            if(acc.CodiceIstituto3N__c != '881'){
                WrapperResponse resp = new WrapperResponse();
                resp.message = 'Anagrafica non 881';
                resp.success = false;

                return resp;
            }
            
            //Query per recuperare le info riguardo i tipi di prodotti
            //CR - Seconda Parte - 22/07/2019
            //Aggiunta condizione WGC_Numero_Linea_Credito__c = null per non richiedere documenti di prodotti vecchi
            //Aggiunta condizione per cui recuperare anche i prodotti di tipo Factoring Cedente ed aggiungere il tag FACTORING_CEDENTE se presenti prodotto di questo tipo
            List<Linea__c> prodotti = [SELECT Id, Name, Opportunity__r.Name, Prodotto__r.CodiceProdotto__c, 
                                                Prodotto__r.WGC_Area__c, Prodotto__r.WGC_Famiglia__c, Prodotto__r.CodiceUnivoco__c, WGC_Polizza_CPI__c, RecordType.DeveloperName
                                        FROM Linea__c 
                                        WHERE Opportunity__c =: opportunityId AND WGC_Numero_Linea_Credito__c = null];

            // AND (Prodotto__r.CodiceProdotto__c = 'PCMCC' OR 
            //                             Prodotto__r.WGC_Area__c = 'Finanziamenti' OR 
            //                             Prodotto__r.CodiceUnivoco__c LIKE '%IfisImpresa%' OR 
            //                             Prodotto__r.WGC_Area__c = 'Factoring - Cedente')                                    

            System.debug('@@@ linee ' + JSON.serialize(prodotti));

            //Dati per chiamata al doc 10 con i dati dei vari attori
            //Recupero garanti debitori ed esecutore pratica
            List<NDGLinea__c> attori = new List<NDGLinea__c>();
            List<NDGLinea__c> debitori = [SELECT Id, Name, Tipo__c, WGC_TipologiaPersona__c, Opportunita__c, Appalto_d_opera__c, Commessa__c, 
                                            Contact__c, Contact__r.CodiceIstituto3N__c, Contact__r.NDGGruppo__c, Contact__r.Name, Contact__r.Account.WGC_Alert_KPI_Centrale_Rischi__c,
                                            Account__c, Account__r.CodiceIstituto3N__c, Account__r.NDGGruppo__c, Account__r.Name, Account__r.WGC_Alert_KPI_Centrale_Rischi__c
                                            FROM NDGLinea__c 
                                            WHERE Opportunita__c =: opportunityId AND Tipo__c = 'Debitore' AND Account__c !=: WGC_PC_CartController.idAdE  AND Id IN (SELECT Debitore__c FROM JoinLineaDebitore__c WHERE Linea__r.Opportunity__c =: opportunityId AND WGC_Codice_Random_Coppia__c = null) ];
            List<NDGLinea__c> garanti = [SELECT Id, Name, Tipo__c, WGC_TipologiaPersona__c, Opportunita__c, Appalto_d_opera__c, Commessa__c, 
                                            Contact__c, Contact__r.CodiceIstituto3N__c, Contact__r.NDGGruppo__c, Contact__r.Name, Contact__r.Account.WGC_Alert_KPI_Centrale_Rischi__c,
                                            Account__c, Account__r.CodiceIstituto3N__c, Account__r.NDGGruppo__c, Account__r.Name, Account__r.WGC_Alert_KPI_Centrale_Rischi__c
                                            FROM NDGLinea__c 
                                            WHERE Opportunita__c =: opportunityId AND Tipo__c = 'Garante' AND Id IN (SELECT Garante__c FROM JoinGaranteGaranzia__c WHERE Garanzia__r.Opportunita__c =: opportunityId AND Garante__r.Account__c !=: UtenzeDefault__c.getOrgDefaults().IdGaranteDefaultMutuo__c) ];

            attori.addAll(debitori);
            attori.addAll(garanti);

            List<AccountContactRelation> esecutore = [SELECT Id, ContactId, Contact.Name, Contact.NDGGruppo__c, Contact.CodiceIstituto3N__c, WGC_Esecutore_MAV__c, 
                                                            Contact.Account.WGC_Alert_KPI_Centrale_Rischi__c, Contact.DataInserimentoConsensi__c
                                                    FROM AccountContactRelation WHERE AccountId =: opp.AccountId AND WGC_Esecutore_MAV__c = true LIMIT 1];

            // CR - Seconda Parte - 22/07/2019
            List<AccountContactRelation> titolareEff = [SELECT Id, ContactId, Contact.Name, Contact.NDGGruppo__c, Contact.CodiceIstituto3N__c, WGC_Effettivo_MAV__c, 
                                                            Contact.Account.WGC_Alert_KPI_Centrale_Rischi__c, Contact.DataInserimentoConsensi__c, Contact.Ultima_professione_svolta__c
                                                    FROM AccountContactRelation WHERE AccountId =: opp.AccountId AND WGC_Effettivo_MAV__c = true AND WGC_Esecutore_MAV__c = false];

            //Genero il Payload
            InputDoc10 payload = new InputDoc10(acc, opp, prodotti, attori);

            System.debug('@@@ payload ' + payload);

            OutputDoc10 output = new OutputDoc10();
            List<WGC_Nota_Documento__c> notesOpty = new List<WGC_Nota_Documento__c>();

            if(payload.tags.size() > 0){
                output = (OutputDoc10) WGC_WsRest.doc10(payload);

                Map<String,ResultDoc10> mappaDoc = new Map<String,ResultDoc10>();

                for(ResultDoc10 doc : output.payload.results){
                    System.debug('@@@ doc ' + JSON.serialize(doc));
                    //ADDED FOR CBOX RESPONSE
                    for(DOCS d : doc.docs){
                        System.debug('@@@ d ' + JSON.serialize(d));
                        System.debug('@@@ cond ' + d.id != null ? d.id : d.uuid);
                        d.id = d.id != null ? d.id : d.uuid;
                    }
                    mappaDoc.put(doc.index_value, doc);
                }

                System.debug('@@@ mappaDoc ' + JSON.serialize(mappaDoc));

                for(ResultDoc10 doc : output.payload.results){
                    if(mappaDoc.containsKey(doc.index_value) && mappaDoc.get(doc.index_value).required == false && doc.required){
                        // doc.id = doc.id != null ? doc.id : doc.docref;
                        mappaDoc.put(doc.index_value, doc);
                    }
                }

                System.debug('@@@ mappaDoc after ' + JSON.serialize(mappaDoc));

                output.payload.results = mappaDoc.values();

                Set<String> optyDocXNDG = new Set<String>();

                for(ResultDoc10 item : output.payload.results){
                    String chiave = opp.Id + '_' + item.index_value;
                    optyDocXNDG.add(chiave);
                }

                notesOpty = [SELECT Id, Name, Note__c, Id_univoco__c FROM WGC_Nota_Documento__c WHERE Id_univoco__c IN: optyDocXNDG];

                System.debug('@@@ notesOpty ' + notesOpty);
            }

            List<InputDoc10> payloadAttori = new List<InputDoc10>();
            List<OutputDoc10> outputAttori = new List<OutputDoc10>();

            List<AttoriXDoc> out = new List<AttoriXDoc>();
            Set<String> chiaviDocXNDG = new Set<String>();

            if(attori.size() > 0){
                for(NDGLinea__c attore : attori){
                    InputDoc10 payloadAttore = new InputDoc10(attore, opp);
                    System.debug('@@@ payload attore ' + JSON.serialize(payloadAttore));
                    System.debug('@@@ attore ndg ' + attore);
                    OutputDoc10 outputAttore = (OutputDoc10) WGC_WsRest.doc10(payloadAttore);

                    outputAttori.add(outputAttore);
                    
                    for(ResultDoc10 item : outputAttore.payload.results){
                        String chiave = attore.Id+'_'+item.index_value;
                        chiaviDocXNDG.add(chiave);
                    }
                    
                    AttoriXDoc wrap = new AttoriXDoc(attore, outputAttore);
                    out.add(wrap);
                }
            }

            
            List<WGC_Nota_Documento__c> notesAttori = [SELECT Id, Name, Note__c, Id_univoco__c FROM WGC_Nota_Documento__c WHERE Id_univoco__c IN: chiaviDocXNDG];

            for(AttoriXDoc item : out){
                for(WGC_Nota_Documento__c nota : notesAttori){
                    SObject a = (SObject) item.attore;
                    String idA = String.valueOf(a.get('Id'));
                    if(nota.Id_Univoco__c.contains(idA)){
                        item.note.add(nota);
                    }
                }
            }
			
            if(esecutore.size() > 0){
                InputDoc10 payloadEsecutore = new InputDoc10(esecutore.get(0));
                System.debug('@@@ payaload Esecutore ' + payloadEsecutore);
                OutputDoc10 outputEsecutore = (OutputDoc10) WGC_WsRest.doc10(payloadEsecutore);
    
                Set<String> chiaviDocXEsec = new Set<String>();
                for(ResultDoc10 item : outputEsecutore.payload.results){
                    String chiave = esecutore.get(0).Id + '_' + item.index_value;
                    chiaviDocXEsec.add(chiave);
                }
    
                List<WGC_Nota_Documento__c> notesEsecutore = [SELECT Id, Name, Note__c, Id_univoco__c FROM WGC_Nota_Documento__c WHERE Id_univoco__c IN: chiaviDocXEsec];
    
                AttoriXDoc wrapEsec = new AttoriXDoc(esecutore.get(0), outputEsecutore, notesEsecutore);
                out.add(wrapEsec);
            }

            // CR - Seconda Parte - 22/07/2019
            if(titolareEff.size() > 0){
                for(AccountContactRelation titEff : titolareEff){
                    InputDoc10 payloadTitEff = new InputDoc10(titEff,true);
                    System.debug('@@@ payaload titEff ' + payloadTitEff);
                    OutputDoc10 outputTitEff = (OutputDoc10) WGC_WsRest.doc10(payloadTitEff);
        
                    Set<String> chiaviDocXTitEff = new Set<String>();
                    for(ResultDoc10 item : outputTitEff.payload.results){
                        String chiave = titEff.Id + '_' + item.index_value;
                        chiaviDocXTitEff.add(chiave);
                    }
        
                    List<WGC_Nota_Documento__c> notesTitEff = [SELECT Id, Name, Note__c, Id_univoco__c FROM WGC_Nota_Documento__c WHERE Id_univoco__c IN: chiaviDocXTitEff];
        
                    AttoriXDoc wrapEsec = new AttoriXDoc(titEff, outputTitEff, notesTitEff);
                    out.add(wrapEsec);
                }
            }

            //if(payload.tags.size() > 0){
                //Doc opty
                response.data.add(output);
                //Note opty
                response.data.add(notesOpty);
            //}
            //Wrap attori x doc x note
            response.data.add(out);
            return response;
        }
        catch(Exception e){
            response.message = e.getMessage() + ' - ' + e.getLineNumber();
            response.success = false;

            return response;
        }
    }

    @AuraEnabled
    public static WrapperResponse getDocsAssuntore(String opportunityId){
        WrapperResponse response = new WrapperResponse();

        try{
            Opportunity opp = [SELECT Id, WGC_Azienda_Cedente__c, WGC_Azienda_Cedente__r.NDGGruppo__c, WGC_Azienda_Cedente__r.CodiceIstituto3N__c, RecordType.DeveloperName, WGC_Assuntore__c FROM Opportunity WHERE Id =: opportunityId];
            //SM - TEN: TEN- chiedo i documenti dell'assuntore solo se il flag è a true
            if(opp.WGC_Assuntore__c){
                // Account assuntore = [SELECT Id, Name, NDGGruppo__c, CodiceIstituto3N__c FROM Account WHERE Id =: opp.WGC_Azienda_Cedente__c];

                InputDoc10 payloadAssuntore = new InputDoc10(opp, opp.WGC_Assuntore__c);
                System.debug('@@@ payloadAssuntore ' + payloadAssuntore);
                OutputDoc10 outputAssuntore = (OutputDoc10) WGC_WsRest.doc10(payloadAssuntore);

                
                for(ResultDoc10 item : outputAssuntore.payload.results){
                    System.debug('@@@ item ' + item);
                    if(!item.docs.isEmpty()){
                        for(Docs doc : item.docs){
                            System.debug('@@@ doc ' + JSON.serialize(doc));
                            doc.id = doc.id != null ? doc.id : doc.uuid;
                        }
                    }
                }
                

                Set<String> chiaviDocXAssuntore = new Set<String>();
                for(ResultDoc10 item : outputAssuntore.payload.results){
                    String chiave = opp.WGC_Azienda_Cedente__c + '_' + item.index_value;
                    chiaviDocXAssuntore.add(chiave);
                }

                List<WGC_Nota_Documento__c> notesAssuntore = [SELECT Id, Name, Note__c, Id_univoco__c FROM WGC_Nota_Documento__c WHERE Id_univoco__c IN: chiaviDocXAssuntore];

                // AttoriXDoc wrapEsec = new AttoriXDoc(titEff, outputTitEff, notesTitEff);
                System.debug('@@@ outputAssuntore ' + JSON.serialize(outputAssuntore));
                response.data.add(outputAssuntore);
                response.data.add(notesAssuntore);
            } else
                response.message = 'No Assuntore';
        } catch (Exception e){
            response.message = e.getMessage() + ' - ' + e.getLineNumber();
            response.success = false;
        }

        return response;
    }

    public class AttoriXDoc{
        @AuraEnabled
        public Object attore;
        @AuraEnabled
        public OutputDoc10 docs;
        @AuraEnabled
        public List<WGC_Nota_Documento__c> note;

        public AttoriXDoc(){
            this.attore = new NDGLinea__c();
            this.docs = new OutputDoc10();
            this.note = new List<WGC_Nota_Documento__c>();
        }

        public AttoriXDoc(NDGLinea__c attore, OutputDoc10 docs){
            this.attore = attore;
            this.docs = docs;
            this.note = new List<WGC_Nota_Documento__c>();
        }

        public AttoriXDoc(AccountContactRelation esec, OutputDoc10 docs, List<WGC_Nota_Documento__c> notes){
            this.attore = esec;
            this.docs = docs;
            this.note = notes.size() > 0 ? notes : new List<WGC_Nota_Documento__c>();
        }
    }

    //Chiamata al servizio CheckList DOC10
    @AuraEnabled
    public static WrapperResponse docCheckListOpportunity(String opportunityId){
        
        WrapperResponse wrap = new WrapperResponse();

        try{
            Opportunity opp = [SELECT Id, StageName, WGC_Codice_Pratica__c, IdCartella__c, AccountId, Account.NDGGruppo__c, 
                                Account.CodiceIstituto3N__c, IsOppNSA__c, TiAnticipo__c, RecordType.DeveloperName, WGC_Assuntore__c FROM Opportunity WHERE Id =: opportunityId];
                

            //Recupero le info per capire i tag da inserire nei parametri della chiamata
            //SE eventi negativi tutti 'G' allora inserisco il tag di alert, se sono tutti 'V' allora non inserisco tag alert
            Account acc = [SELECT Id, Name, CodiceIstituto3N__c, NDGGruppo__c, NaturaGiuridica__c, WGC_Semaforo_Gianos__c, WGC_Semaforo_CLC__c, 
                                    WGC_Gruppo_frm__c, EventiNegativiProtesti__c, EventiNegativiProcedureConcorsuali__c,
                                    EventiNegativiPregiudizievoli__c, EventiNegativiCIGS__c,
                                    EventiNegativiAllarmiQuote__c, EventiNegativiGlobale__c, WGC_Alert_KPI_Centrale_Rischi__c
                            FROM Account WHERE Id =: opp.AccountId];

            //Aggiunto per gestire il tag ALWAYS sulle chiamate alle opportunity e al carrello in casi particolari
            List<Linea__c> prodotti = [SELECT Id, Name, Opportunity__r.Name, Prodotto__r.CodiceProdotto__c, 
                                Prodotto__r.WGC_Area__c, Prodotto__r.WGC_Famiglia__c, Prodotto__r.CodiceUnivoco__c, WGC_Polizza_CPI__c, RecordType.DeveloperName
                        FROM Linea__c 
                        WHERE Opportunity__c =: opportunityId AND WGC_Numero_Linea_Credito__c = null];

            // AND (Prodotto__r.CodiceProdotto__c = 'PCMCC' OR 
            //             Prodotto__r.WGC_Area__c = 'Finanziamenti' OR 
            //             Prodotto__r.CodiceUnivoco__c LIKE '%IfisImpresa%' OR 
            //             Prodotto__r.WGC_Area__c = 'Factoring - Cedente')       
            
            List<JoinLineaDebitore__c> joins = new List<JoinLineaDebitore__c>([SELECT Id FROM JoinLineaDebitore__c WHERE Opportunita__c =: opportunityId AND WGC_Cod_Tipo_Car__c != null]);

                            
            if(acc.CodiceIstituto3N__c != '881'){
                WrapperResponse resp = new WrapperResponse();
                resp.message = 'Anagrafica non 881';
                resp.success = false;

                return resp;
            }


            InputDoc10 inputDoc10 = new InputDoc10(acc, opp, prodotti, joins);
            
            OutputDoc10 outputDoc = new OutputDoc10();
        
            outputDoc = (OutputDoc10) WGC_WsRest.doc10(inputDoc10);

            Set<String> chiaviDocXId = new Set<String>();
            for(ResultDoc10 item : outputDoc.payload.results){
                String chiave = opportunityId + '_' + item.index_value;
                chiaviDocXId.add(chiave);
            }

            List<WGC_Nota_Documento__c> notesOpp = [SELECT Id, Name, Id_Univoco__c, Note__c FROM WGC_Nota_Documento__c WHERE Id_Univoco__c IN: chiaviDocXId];

            wrap.data.add(outputDoc);
            wrap.data.add(notesOpp);
            return wrap;
        }
        catch(Exception e){
            wrap.message = e.getMessage();
            wrap.success = false;
            
            return wrap;
        }
        
    }

    //Funzione che recupera la mappatura dei metadati per assegnare il nome corretto ai docs restituiti dal servizio doc10
    @AuraEnabled
    public static WrapperResponse getDocumentMapping(){
        
        WrapperResponse response = new WrapperResponse();

        List<WGC_Metadati_Documentale__mdt> mappaturaDoc = [SELECT Id, MasterLabel, DeveloperName, Classe__c, Documento__c, Istituto__c, Sottoclasse__c FROM WGC_Metadati_Documentale__mdt];
        response.data.add(mappaturaDoc);
        return response;
    }

    //Funzione utilizzata per recuperare tutti gli attori collegati ad una pratica
    //utilizzati per creare una sezione doc apposita per gli attori nella carrello
    @AuraEnabled
    public static WrapperResponse getAttoriPratica(String oppId){
        WrapperResponse response = new WrapperResponse();

        try{

            List<NDGLinea__c> debitori = [SELECT Id, Name, Tipo__c FROM NDGLinea__c WHERE Opportunita__c =: oppId AND Tipo__c = 'Debitore'];

            List<NDGLinea__c> garanti = [SELECT Id, Name,  Tipo__c FROM NDGLinea__c WHERE Opportunita__c =: oppId AND Tipo__c = 'Garante'];

            List<NDGLinea__c> esecutore = [SELECT Id, Name, Tipo__c FROM NDGLinea__c WHERE Opportunita__c =: oppId AND Tipo__c = 'Esecutore adeguata verifica'];

            Attore attoriWrap = new Attore();
            attoriWrap.debitori = debitori;
            attoriWrap.garanti = garanti;
            attoriWrap.esecutore = esecutore;

            for(NDGLinea__c item : debitori){
                OutputDoc10 output = (OutputDoc10) WGC_WsRest.doc10(item.Id);
            }

            response.data.add(attoriWrap);
            return response;
        }
        catch(Exception e){
            response.message = e.getMessage();
            response.success = false;

            return response;
        }
    }

    //Wrapper utilizzata per separare debitori e garanti
    public class Attore{
        @AuraEnabled
        public List<NDGLinea__c> debitori;
        @AuraEnabled
        public List<NDGLinea__c> garanti;
        @AuraEnabled
        public List<NDGLinea__c> esecutore;

        public Attore(){
            this.debitori = new List<NDGLinea__c>();
            this.garanti = new List<NDGLinea__c>();
            this.esecutore = new List<NDGLinea__c>();
        }
    }

    @AuraEnabled
    public static List<String> generateTagsPratica(Account account, Opportunity opp, List<Linea__c> linee, List<NDGLinea__c> attori, List<JoinLineaDebitore__c> joins){
        List<String> tags = new List<String>();
        if(opp.IsOppNSA__c){
            tags.add('NSA');
        }
        else if(opp.TiAnticipo__c){
            tags.add('TiAnticipo');
        }
        else if((linee != null && linee.size() > 0) || (joins != null && !joins.isEmpty())){
            tags.add('ALWAYS');
            
            //Modifiche per assuntore FF
            if(opp.RecordType.DeveloperName == 'IFISOpportunitaFastFinance' && !opp.WGC_Assuntore__c)
                tags.add('ASSUNTORE_NO');
        }

        if(!tags.contains('NSA') && !tags.contains('TiAnticipo') && opp.RecordType.DeveloperName != 'IFISOpportunitaFastFinance'){

            Boolean checkFinanziamento = false;
            Boolean checkMutuo = false;
            Boolean checkCC = false;
            //CR - Seconda Parte - 22/07/2019 - Boolean aggiunto per generare un nuovo tag FACTORING_CEDENTE
            Boolean checkFactCed = false;
            //CR - Lotto 3.3 - Gestione documenti CPI
            Boolean checkCPI = false;
            //CR - Mutui Controgarantiti
            Boolean checkControgarantiti = false;
            //FF - Prodotto ATD IVA
            Boolean checkIVABonis = false;
            //SM - TEN: Banca Corporate
            Boolean checkCorporate = false;
            //SM - TEN: Banca Corporate Estero
            Boolean checkCorporateEstero = false;
            Boolean checkCorporateEsteroBP = false;
            //A.M. Mutuo SACE
            Boolean checkSace = false;
            //A.M. Bonus Edilizi
            Boolean checkBonusEdil = false;
            
            System.debug('@@@ linee ' + JSON.serialize(linee));
            //Presenza di prodotto di area finanziamento 
            if(linee != null && linee.size() > 0){

                //A.M. Aggiungo prodotto PCMDL e PC13E
                //Aggiunti anche i prodotti di factoring MCC e ACF MCC
                //Gestione Mutuo Veneto Sviluppo (garanzia MCC solo per quota Ifis)
				// non si può generalizzare come fatto in checkFamigliaProd
                for(Linea__c linea : linee){
                    if(linea.Prodotto__r.CodiceProdotto__c == 'PCMCC' || 
                       linea.Prodotto__r.CodiceProdotto__c == 'PCMDL' ||
                       linea.Prodotto__r.CodiceProdotto__c == 'PC13E' ||
                       linea.Prodotto__r.CodiceProdotto__c == 'PCFGF' ||
                       linea.Prodotto__r.CodiceProdotto__c == 'PCAMC' ||
					   linea.Prodotto__r.CodiceProdotto__c == 'PCANM' ||
					   linea.Prodotto__r.CodiceProdotto__c == 'PCBEM' ||
                       linea.Prodotto__r.CodiceProdotto__c == 'PCVSI' ||
					   linea.Prodotto__r.CodiceProdotto__c == 'PCCDP'){
                        //è presente un mutuo MCC aggiungo il tag
                        checkMutuo = true;
                        break;
                    }
                }

                //A.M. Aggiungo controllo per Mutuo SACE
                for(Linea__c linea : linee){
                    if(linea.Prodotto__r.CodiceProdotto__c == 'PCSAC'){
                        //è presente un mutuo SACE aggiungo il tag
                        checkSace = true;
                        break;
                    }
                }

                for(Linea__c linea : linee){
                    if(linea.Prodotto__r.WGC_Area__c == 'Finanziamenti' ){
                        //è presente un mutuo MCC aggiungo il tag
                        checkFinanziamento = true;
                        break;
                    }
                }

                for(Linea__c linea : linee){
                    if(linea.Prodotto__r.CodiceUnivoco__c.startsWith('IfisImpresa') == true){
                        checkCC = true;
                        break;
                    }
                }

                //CR - Seconda Parte - 22/07/2019 - Loop per controllare la presenza di prodotti Factoring - Cedente
                for(Linea__c linea : linee){
                    if(linea.Prodotto__r.WGC_Area__c == 'Factoring - Cedente'){
                        checkFactCed = true;
                        break;
                    }
                }

                //CR - Lotto 3.3 - Gestione Documento CPI
                for(Linea__c linea : linee){
                    if(linea.WGC_Polizza_CPI__c){
                        checkCPI = true;
                        break;
                    }
                }

                //CR - Mutuo Controgarantito
                for(Linea__c l : linee){
                    if(l.Prodotto__r.CodiceUnivoco__c == 'MutuoControgarantitoMCC'){
                        checkControgarantiti = true;
                        break;
                    }
                }

                //FF - Prodotti ATD
                for(Linea__c l : linee){
                    if(l.Prodotto__r.WGC_Famiglia__c == 'ATD - IVA' || l.Prodotto__r.WGC_Famiglia__c == 'DFO - IVA'){
                        checkIVABonis = true;
                        break;
                    }
                }

                //SM - TEN: Banca Corporate
                for(Linea__c l : linee){
                    if(l.RecordType.DeveloperName == 'Corporate'){
                        checkCorporate = true;
                        break;
                    }
                }

                //SM - TEN: Banca Corporate Estero
                for(Linea__c l : linee){
                    if(l.RecordType.DeveloperName == 'WGC_Corporate_Estero'){
                        checkCorporateEstero = true;
                        if(l.Prodotto__r.CodiceUnivoco__c == 'AnticipoExport' || l.Prodotto__r.CodiceUnivoco__c == 'FinanziamentoExport' || l.Prodotto__r.CodiceUnivoco__c == 'FinanziamentoImport')
                            checkCorporateEsteroBP = true;
                    }
                }
                
                //A.M. - Bonus Edilizi
                for(Linea__c linea : linee){
                    if(linea.Prodotto__r.WGC_Area__c == 'Bonus Edilizi'){
                        checkBonusEdil = true;
                        break;
                    }
                }

                if(checkFinanziamento)
                    tags.add('FINANZIAMENTO');

                if(checkMutuo)
                    tags.add('MCC');

                if(checkCC)
                    tags.add('CC');

                //CR - Seconda Parte - 22/07/2019 - Aggiunta del tag se presente un prodotto di Factoring - Cedente
                if(checkFactCed)
                    tags.add('FACTORING_CEDENTE');
                
                //CR - Lotto 3.3 - Gestione Documento CPI
                if(checkCPI) tags.add('CPI');

                //CR - MutuoContragarantito
                if(checkControgarantiti) tags.add('CONTROGARANTITO');

                //FF
                if(checkIVABonis) tags.add('IVABONIS');

                //SM - TEN: Banca Corporate
                if(checkCorporate) tags.add('CORPORATE');

                //SM - TEN: Banca Corporate Estero
                if(checkCorporateEstero) tags.add('ESTERO');

                //SM - TEN: Banca Corporate Estero
                if(checkCorporateEsteroBP) tags.add('ESTEROBP');

                //A.M. Nuovo Mutuo garantito SACE
                if(checkSace) tags.add('SACE');
            
                //A.M. Bonus Edilizi
                if(checkBonusEdil) tags.add('EDIL');
            }

            //Se il mese della data odierna è compreso tra settembre e aprile 
            //Allora devo aggiungere un ulteriore tag alla chiamata
            Date oggi = System.Today();
            Integer mese = oggi.Month();

            if(mese >= 9 || mese <= 4){
                //FLAG
                tags.add('SETT_APR');
            }

            //FLAG alert CLC
            if(account.WGC_Semaforo_CLC__c == 'ROSSO' || account.WGC_Semaforo_CLC__c == 'GIALLO'){
                tags.add('CLC');
            }

            //FLAG Alert Gianos
            if(account.WGC_Semaforo_Gianos__c == 'ROSSO' || account.WGC_Semaforo_Gianos__c == 'GIALLO'){
                tags.add('GIANOS');
            }

            //FLAG Alert Eventi Negativi
            if(account.EventiNegativiProtesti__c == 'R' || account.EventiNegativiProcedureConcorsuali__c == 'R' ||
                account.EventiNegativiPregiudizievoli__c == 'R' || account.EventiNegativiCIGS__c == 'R' ||
                account.EventiNegativiAllarmiQuote__c == 'R' || account.EventiNegativiGlobale__c == 'R'){

                tags.add('EVENTI');
            }

            //FLAG Gruppo
            if(account.WGC_Gruppo_frm__c){
                tags.add('GRUPPO');
            }

            if(account.WGC_Alert_KPI_Centrale_Rischi__c){
                tags.add('CR');
            }

        }

        //Aggiuntivi
        if(linee != null && linee.size() > 0 && !tags.contains('NSA') && !tags.contains('TiAnticipo')){
            tags.add('AGGIUNTIVI');
        }

        return tags;
    }

    @AuraEnabled
    public static List<String> generateTagsDebitore(NDGLinea__c attore){
        List<String> tags = new List<String>();
        //tags.add('ALWAYS');

        //FLAG COMMESSA
        if(attore.Commessa__c){
            tags.add('COMMESSA');
        }

        //FLAG APPALTO
        if(attore.Appalto_d_opera__c){
            tags.add('APPALTO_SI');
        }
        else{
            tags.add('APPALTO_NO');
        }

        //FLAG CR
        if(attore.Account__r.WGC_Alert_KPI_Centrale_Rischi__c){
            tags.add('CR');
        }

		//adione CR 293 mostra doc caricati col bottone +
		tags.add('AGGIUNTIVI');

        return tags;
    }

    @AuraEnabled
    public static List<ParamsDoc10> generateParamsPratica(String tipoDocumentale, Opportunity opp){
        List<ParamsDoc10> listaParametri = new List<ParamsDoc10>();

        //Se ho la IDOPPORTUNITA o IdCartella__c
        //Popola la lista parametri

        ParamsDoc10 idOpp = new ParamsDoc10();
        idOpp.nome = tipoDocumentale;
        idOpp.operatore = '=';
        idOpp.valore = opp.Id;
        listaParametri.add(idOpp);

        return listaParametri;
    }

    @AuraEnabled
    public static List<ParamsDoc10> generateParamsDebitore(NDGLinea__c attore, Opportunity opp){
        List<ParamsDoc10> listaParametri = new List<ParamsDoc10>();

        ParamsDoc10 idOpp = new ParamsDoc10();
        idOpp.nome = 'IDCFLOW';
        idOpp.operatore = '=';
        idOpp.valore = opp.Id;
        listaParametri.add(idOpp);

        ParamsDoc10 NDG = new ParamsDoc10();
        NDG.nome = 'NDGDEBITORE';
        NDG.operatore = '=';
        //NDG.valore = opp.Account.NDGGruppo__c;
        NDG.valore = attore.Account__r.NDGGruppo__c != null ? attore.Account__r.NDGGruppo__c : attore.Contact__r.NDGGruppo__c;
        listaParametri.add(NDG);

        return listaParametri;
    }

    public class InputDoc10{
        @AuraEnabled
        public String institute;
        @AuraEnabled
        public String ndg;
        @AuraEnabled
        public String config;
        @AuraEnabled
        public String dossier_date;
        @AuraEnabled
        public String legal_nature;
        @AuraEnabled
        public String rating;
        @AuraEnabled
        public List<String> tags;
        // @AuraEnabled
        // public List<ParamsDoc10> params;
        @AuraEnabled
        public List<ParamsDoc10> paramsFilenet;
        @AuraEnabled
        public List<ParamsDoc10> paramsCbox;
        @AuraEnabled
        public Integer maxRows;
        @AuraEnabled
        public String orderBy;

        public InputDoc10(){
            this.institute = '881';
            this.ndg = '';
            this.config = 'Anagrafica_CRM';
            this.dossier_date = String.valueOf(System.Today());
            this.legal_nature = '';
            this.rating = '';
            this.tags = new List<String>{'default', 'always'};
            this.maxRows = 10;
            this.orderBy = 'DATECREATED DESC';
            // this.params = new List<ParamsDoc10>();
            this.paramsFilenet = new List<ParamsDoc10>();
            this.paramsCbox = new List<ParamsDoc10>();
        }

        public InputDoc10(Sobject obj, String objectName){
            this.institute = (String) obj.get('codiceIstituto3N__c') ;
            this.ndg = (String) obj.get('NDGGruppo__c');
            this.config = objectName == 'Account' ? 'CRM_Azienda' : 'CRM_Referenti';
            this.dossier_date = String.valueOf(System.Today());
            this.legal_nature = objectName == 'Account' ? 'PG' : 'PF';
            this.rating = '***'; //FISSO
            this.tags = new List<String>{'ALWAYS'};
            this.maxRows = 10;
            this.orderBy = 'DATECREATED DESC';
            // this.params = new List<ParamsDoc10>();
            this.paramsFilenet = new List<ParamsDoc10>();
            this.paramsCbox = new List<ParamsDoc10>();
        }

        //Costruttore per chiamata opty nella pagina account
        public InputDoc10(Account account, Opportunity opp){
            this.institute = account.CodiceIstituto3N__c;
            this.ndg = account.NDGGruppo__c;
            this.config = opp.RecordType.DeveloperName == 'IFISOpportunitaFastFinance' ? 'CRM_Istruttoria_PROC' : 'CRM_Istruttoria_Fact';
            this.dossier_date = String.valueOf(System.Today());
            this.legal_nature = 'PG';
            this.rating = '***'; //FISSO
            this.tags = generateTagsPratica(account, opp, null, null, null); 
            this.maxRows = 10;
            this.orderBy = 'DATECREATED DESC';
            // this.params = generateParamsPratica(opp);
            this.paramsFilenet = generateParamsPratica('IDCFLOW', opp);
            //TODO Scommenta
            // this.paramsCbox = generateParamsPratica('ID_CRM', opp);
            this.paramsCbox = opp.RecordType.DeveloperName == 'IFISOpportunitaFastFinance' ? generateParamsPratica('ID_CRM', opp) : new List<ParamsDoc10>();
        }

        //Costruttore per chiamata opty nella pagina account && Carrello 
        public InputDoc10(Account account, Opportunity opp, List<Linea__c> linee, List<JoinLineaDebitore__c> joins){
            this.institute = account.CodiceIstituto3N__c;
            this.ndg = account.NDGGruppo__c;
            this.config = opp.RecordType.DeveloperName == 'IFISOpportunitaFastFinance' ? 'CRM_Istruttoria_PROC' : 'CRM_Istruttoria_Fact';
            this.dossier_date = String.valueOf(System.Today());
            this.legal_nature = 'PG';
            this.rating = '***'; //FISSO
            this.tags = generateTagsPratica(account, opp, linee, null, joins); 
            this.maxRows = 10;
            this.orderBy = 'DATECREATED DESC';
            // this.params = generateParamsPratica(opp);
            this.paramsFilenet = generateParamsPratica('IDCFLOW', opp);
            // this.paramsCbox = generateParamsPratica('ID_CRM', opp);
            // this.paramsCbox = generateParamsPratica('RIFERIMENTO', opp);
            // this.paramsCbox = new List<ParamsDoc10>();
            this.paramsCbox = opp.RecordType.DeveloperName == 'IFISOpportunitaFastFinance' ? generateParamsPratica('ID_CRM', opp) : new List<ParamsDoc10>();
        }

        //Costruttore per chiamata carrello
        public InputDoc10( Account account, Opportunity opp, List<Linea__c> linee, List<NDGLinea__c> attori ){
            this.institute = opp.Account.CodiceIstituto3N__c;
            this.ndg = opp.Account.NDGGruppo__c;
            this.config = opp.RecordType.DeveloperName == 'IFISOpportunitaFastFinance' ? 'CRM_Istruttoria_PROC' : 'CRM_Istruttoria_Fact';
            this.dossier_date = String.valueOf(System.Today());
            this.legal_nature = 'PG';
            this.rating = '***';
            this.tags = generateTagsPratica(account, opp, linee, attori, null);
            this.maxRows = 10;
            this.orderBy = 'DATECREATED DESC';
            // this.params = generateParamsPratica(opp);
            this.paramsFilenet = generateParamsPratica('IDCFLOW', opp);
            this.paramsCbox = opp.RecordType.DeveloperName == 'IFISOpportunitaFastFinance' ? generateParamsPratica('ID_CRM', opp) : new List<ParamsDoc10>();
        }

        //Costruttore Garanti Debitori Esecutore
        public InputDoc10( NDGLinea__c attore, Opportunity opp ){

            if(attore.Tipo__c == 'Debitore'){
                this.institute = opp.Account.CodiceIstituto3N__c;
                this.ndg = opp.Account.NDGGruppo__c;
                this.config = opp.RecordType.DeveloperName == 'IFISOpportunitaFastFinance' ? 'CRM_Istruttoria_PROC' : 'CRM_Istruttoria_Fact';
                this.dossier_date = String.valueOf(System.Today());
                this.legal_nature = 'PG';
                this.rating = '***';
                this.tags = generateTagsDebitore(attore);
                this.maxRows = 10;
                this.orderBy = 'DATECREATED DESC';
                // this.params = generateParamsDebitore(attore, opp);
                this.paramsFilenet = generateParamsDebitore(attore, opp);
                this.paramsCbox = generateParamsDebitore(attore, opp);
            }
            else if(attore.Tipo__c == 'Garante'){
                if(attore.WGC_TipologiaPersona__c == 'PG'){
                    this.institute = opp.Account.CodiceIstituto3N__c;
                    this.ndg = opp.Account.NDGGruppo__c;
                    this.config = 'CRM_Garante';
                    this.dossier_date = String.valueOf(System.Today());
                    this.legal_nature = attore.WGC_TipologiaPersona__c;
                    this.rating = '***';
                    this.tags = new List<String>{'GARANTE_PG'};
                    this.maxRows = 10;
                    this.orderBy = 'DATECREATED DESC';
                    // this.params = generateParamsDebitore(attore, opp);
                    this.paramsFilenet = generateParamsDebitore(attore, opp);
                    this.paramsCbox = generateParamsDebitore(attore, opp);

                    if(opp.account.WGC_Alert_KPI_Centrale_Rischi__c){
                        tags.add('CR');
                    }
                }
                else{
                    this.institute = opp.Account.CodiceIstituto3N__c;
                    this.ndg = opp.Account.NDGGruppo__c;
                    this.config = 'CRM_Garante';
                    this.dossier_date = String.valueOf(System.Today());
                    this.legal_nature = attore.WGC_TipologiaPersona__c;
                    this.rating = '***';
                    this.tags =  new List<String>{'GARANTE_PF'};
                    this.maxRows = 10;
                    this.orderBy = 'DATECREATED DESC';
                    // this.params = generateParamsDebitore(attore, opp);
                    this.paramsFilenet = generateParamsDebitore(attore, opp);
                    this.paramsCbox = generateParamsDebitore(attore, opp);

                    if(opp.account.WGC_Alert_KPI_Centrale_Rischi__c){
                        tags.add('CR');
                    }
                }
            }

        }

        public InputDoc10(AccountContactRelation esecutore){
            if(esecutore != null){
                this.institute = esecutore.Contact.CodiceIstituto3N__c;
                this.ndg = esecutore.Contact.NDGGruppo__c;
                this.config = 'CRM_Esecutore';
                this.dossier_date = String.valueOf(System.Today());
                this.legal_nature = 'PF';
                this.rating = '***';
                this.maxRows = 10;
                this.orderBy = 'DATECREATED DESC';
                this.tags = new List<String>{'ALWAYS'};
                // this.params = new List<ParamsDoc10>();
                this.paramsFilenet = new List<ParamsDoc10>();
                this.paramsCbox = new List<ParamsDoc10>();
                //this.tags = new List<String>{'ALWAYS'};
    
                if(esecutore.Contact.Account.WGC_Alert_KPI_Centrale_Rischi__c){
                    tags.add('CR');
                }
            }
        }

        // Configurazione chiamata titolare effettivo - CR - Seconda Parte - 22/07/2019
        public InputDoc10(AccountContactRelation titolareEff, Boolean isTitEff){
            this.institute = titolareEff.Contact.CodiceIstituto3N__c;
            this.ndg = titolareEff.Contact.NDGGruppo__c;
            this.config = 'CRM_Titolare_Effettivo';
            this.dossier_date = String.valueOf(System.Today());
            this.legal_nature = 'PF';
            this.rating = '***';
            this.maxRows = 10;
            this.orderBy = 'DATECREATED DESC';
            this.tags = new List<String>{'ALWAYS'};
            // this.params = new List<ParamsDoc10>();
            this.paramsFilenet = new List<ParamsDoc10>();
            this.paramsCbox = new List<ParamsDoc10>();
            //this.tags = new List<String>{''};

            if(titolareEff.Contact.Account.WGC_Alert_KPI_Centrale_Rischi__c){
                tags.add('CR');
            }
        }

        public InputDoc10(Opportunity opp, Boolean assuntoreSi){
            this.institute = opp.WGC_Azienda_Cedente__r.CodiceIstituto3N__c;
            this.ndg = opp.WGC_Azienda_Cedente__r.NDGGruppo__c;
            this.config = 'CRM_Istruttoria_PROC';
            this.dossier_date = String.valueOf(System.Today());
            this.legal_nature = 'PG';
            this.rating = '***';
            // this.tags = new List<String>();//generateTagsPratica(account, opp);
            this.tags = new List<String>{'ASSUNTORE_SI', 'AGGIUNTIVI'};
            this.maxRows = 10;
            this.orderBy = 'DATECREATED DESC';
            // this.params = generateParamsPratica(opp);
            this.paramsFilenet = generateParamsPratica('IDCFLOW', opp);
            this.paramsCbox = generateParamsPratica('ID_CRM', opp);
        }
    }

    public class ParamsDoc10{
        @AuraEnabled
        public String nome;
        @AuraEnabled
        public String operatore;
        @AuraEnabled
        public String valore;

        public ParamsDoc10(){
            this.nome = '';
            this.operatore = '';
            this.valore = '';
        }

        public ParamsDoc10(String nome, String operatore, String valore){
            this.nome = nome;
            this.operatore = operatore;
            this.valore = valore;
        }
    }

    public class OutputDoc10 extends WsRestInput.CommonResponse{
        @AuraEnabled
        public ListResultDoc10 payload;

        public OutputDoc10(){
            this.payload = new ListResultDoc10();
        }

        public override Boolean isCorrect(){
            return payload != null;
        }
    }

    public class ListResultDoc10{
        @AuraEnabled
        public List<ResultDoc10> results;

        public ListResultDoc10(){
            this.results = new List<ResultDoc10>();
        }
    }

    public class ResultDoc10{
        @AuraEnabled
        public String institute;
        @AuraEnabled
        public String valid_from; //UnixTimeStamp
        @AuraEnabled
        public String valid_to; //UnixTimeStamp
        @AuraEnabled
        public String config;
        @AuraEnabled
        public String legal_nature;
        @AuraEnabled
        public String rating;
        @AuraEnabled
        public String distressed;
        @AuraEnabled
        public String protested;
        @AuraEnabled
        public String documentary;
        @AuraEnabled
        public String document_class;
        @AuraEnabled
        public String index_name;
        @AuraEnabled
        public String index_value;
        @AuraEnabled
        public Boolean required;
        @AuraEnabled
        public Boolean missing;
        @AuraEnabled
        public List<Docs> docs;

        public ResultDoc10(){
            this.institute = institute;
            this.valid_from = valid_from;
            this.valid_to = valid_to;
            this.config = config;
            this.legal_nature = legal_nature;
            this.rating = rating;
            this.distressed = distressed;
            this.protested = protested;
            this.documentary = documentary;
            this.document_class = document_class;
            this.index_name = index_name;
            this.index_value = index_value;
            this.required = required;
            this.missing = missing;
            this.docs = new List<Docs>();
        }
    }

    public class Docs{
        @AuraEnabled
        public String id;
        @AuraEnabled
        public String uuid;
        @AuraEnabled
        public String objectStore;
        @AuraEnabled
        public String classe;
        @AuraEnabled
        public String tipoBase;
        @AuraEnabled
        public String file_name;
        @AuraEnabled
        public String content_type;
        @AuraEnabled
        public String version_date;
        @AuraEnabled
        public List<IndiceDoc10> indice;

        public Docs(){
            this.id = id != null ? id : uuid;
            this.uuid = uuid;
            this.objectStore = objectStore;
            this.classe = classe;
            this.tipoBase = tipoBase;
            this.indice = new List<IndiceDoc10>();
        }
    }

    public class IndiceDoc10{
        @AuraEnabled
        public String nome;
        @AuraEnabled
        public String valore;

        public IndiceDoc10(){
            this.nome = nome;
            this.valore = valore;
        }
    }

    public class WrapperDettaglioDocInput extends WsRestInput.CommonInput{
        @AuraEnabled
        public String matricola;
        @AuraEnabled
        public String ruolo;
        @AuraEnabled
        public Integer filiale;
        @AuraEnabled
        public WrapperDatiDoc datiDocumento;
        @AuraEnabled
        public String campiAggiuntivi;
        @AuraEnabled
        public String idOperazione;
		@AuraEnabled
        public String utenzaCanale;

        public WrapperDettaglioDocInput(){
            //TODO capire valore campi
            this.matricola = 'YH01175';
            this.ruolo = 'I340'; //'I420';
            this.filiale = 0;
            this.idOperazione = '1';
            this.utenzaCanale = '1';
            this.datiDocumento = datiDocumento;
            this.campiAggiuntivi = '';
        }
    }

    public class WrapperDatiDoc{
        @AuraEnabled
        public String classeOggetto;
        @AuraEnabled
        public List<WrapperIndice> indice;
        @AuraEnabled
        public String versione;
        @AuraEnabled
        public String disabilitaStampaPdf;
        @AuraEnabled
	    public String converti;
        @AuraEnabled
		public String idlettore;

        public WrapperDatiDoc(){
            this.classeOggetto = classeOggetto;
            this.indice = new List<WrapperIndice>();
            this.versione = '1';
            this.disabilitaStampaPdf = 'false';
            this.converti = 'false';
        }

        public WrapperDatiDoc(String numeroServizio){
            if(numeroServizio == '06'){
                this.classeOggetto = classeOggetto;
                this.indice = indice;
                this.versione = versione;
            }
            else if(numeroServizio == '08'){

                this.classeOggetto = classeOggetto;
                this.indice = new List<WrapperIndice>();
                this.disabilitaStampaPdf = 'false';
                this.converti = 'false';
                this.idLettore = '';
            }
        }
    }

    public class WrapperIndice{
        @AuraEnabled
        public String nome;
        @AuraEnabled
        public String operatore;
        @AuraEnabled
        public String valore;

        public WrapperIndice(){
            this.nome = nome;
            this.operatore = operatore;
            this.valore = valore;
        }

        public WrapperIndice(String nomeI, String operatoreI, String valoreI){
            this.nome = nomeI;
            this.operatore = operatoreI;
            this.valore = valoreI;
        }
    }

    public class DocDownload{
        @AuraEnabled
        public String id;
        @AuraEnabled
        public String title;
        //Parametro utilizzato per utilizzare il doc11 e fare la document composition
        //Utilizzato se è uno dei doc fissi
        @AuraEnabled
        public String codId;

        public DocDownload(){
            this.id = id;
            this.title = title;
            this.codId = codId;
        }
    }


    @AuraEnabled
    public static WrapperResponse doc08(String accountId, String document){
        System.debug('@@@ ~> accountId: ' + accountId);
        System.debug('@@@ ~> document: ' + document);

        DocDownload doc = new DocDownload();
        doc = (DocDownload) JSON.deserialize(document, DocDownload.Class);

        //System.debug('@@@ doc ' + JSON.serialize(doc));

        WrapperResponse wrap = new WrapperResponse();
        //Genero il payload di input
        WrapperDettaglioDocInput payload = new WrapperDettaglioDocInput();
        WrapperDatiDoc datiDoc = new WrapperDatiDoc('08');
        WrapperIndice indice = new WrapperIndice('Id', '=', doc.id);
        
        if(doc.id == null || String.isBlank(doc.id)){
            wrap.message = 'Nessun documento trovato';
            wrap.success = false;

            return wrap;
        }            

        datiDoc.indice.add(indice);
        datiDoc.classeOggetto = 'DOCUMENTI_CLIENTE';
        payload.datiDocumento = datiDoc;

        WsRestInput input = new WsRestInput(payload);

        //Nullify because of apex heap
        indice = null;

        try{
            //Metodo di utility
            String blobEnc = EncodingUtil.base64Encode(WGC_WsRest.downloadPDF(input.toJSONString()));

            wrap.data.add(blobEnc);
            wrap.success = true;

            return wrap;
        }
        catch(Exception e){
            wrap.success = false;
            wrap.message = e.getMessage();
            
            return wrap;
        }
    }

    /*
    * DOC61 -- Classi input DOC61 download
    *
    */

    public class InputPayload61 {
        @AuraEnabled public String codiceIstituto3N;
        @AuraEnabled public DatiDocumentoInput61 datiDocumento;

        public InputPayload61(String tipoDocumentale, String idDocumento){
            this.codiceIstituto3N = '881';
            this.datiDocumento = new DatiDocumentoInput61(tipoDocumentale, idDocumento);
        }

    }

    public class DatiDocumentoInput61{
        @AuraEnabled public String documentary; //filenet || cbox
        @AuraEnabled public String idDocumento; //Id del documento da scaricare
        @AuraEnabled public String classeOggetto; //Se non valorizzato avrà valore DOCUMENTI_CLIENTE che corrisponde a classeOggetto di filenet
        
        public DatiDocumentoInput61(String tipoDocumentale, String id){
            this.documentary = tipoDocumentale;
            this.idDocumento = id;
            this.classeOggetto = tipoDocumentale == 'cbox' ? 'ff_generico' : 'DOCUMENTI_CLIENTE';
        }
    }

    @AuraEnabled
    public static WrapperResponse doc61(String idDocumento, String codDocumento) {
        WrapperResponse response = new WrapperResponse();

        if (idDocumento ==null || idDocumento ==''){
            response.success = false;
            response.message = 'Nessun documento da scaricare';
            System.debug('Id documento non definito');
        }else {
            //get documentary parameter
            List<WGC_Metadati_Documentale__mdt> metaDoc = [SELECT Tipo_Documentale__c,Documento__c
                                                           FROM WGC_Metadati_Documentale__mdt
                                                           WHERE Documento__c =:codDocumento
                                                           /*AND isUpload__c = false*/];
            if (!metaDoc.isEmpty()){
                String tipoDocumentale = metaDoc.get(0).Tipo_Documentale__c;
                try{
                    InputPayload61 payload = new InputPayload61(tipoDocumentale, idDocumento);
                    WsRestInput input = new WsRestInput(payload);
                    String blobEnc = EncodingUtil.base64Encode(WGC_WsRest.downloadDoc61(input.toJSONString()));
                    // System.debug('@@@ blobEnc ' + blobEnc);
                    response.data.add(blobEnc);
                } catch(exception e){
                    response.message = e.getMessage();
                    response.success = false;
                    System.debug('@@@ eccezione ' + e.getStackTraceString() + ' -- ' + e.getMessage() + ' -- ' + e.getLineNumber());
                }
            }else {
                response.success = false;
                response.message = 'Errore interno';
                System.debug('Nessun metadata trovato!');
            }
        }

        return response;
    }

    /*
    * END -- DOC61
    *
    */

    @AuraEnabled
    public static WrapperResponse getContactPrivacy(String contactId){
        WrapperResponse wrap = new WrapperResponse();
        
        try{

            Contact c = new Contact();
            c = [SELECT Id, FirstName, LastName, ConsensoAllaProfilazione__c, ConsensoAttivitaPromRicercheMercato__c, 
                ConsensoAttivitaPromozionaleTerzi__c, ConsensoProdottiBancaRicercheMercato__c, ConsensoProdottiSocietaTerze__c, 
                ConsensoSoloModalitaTradizionali__c, CreatedDate, DataInserimentoConsensi__c
                FROM Contact WHERE Id =: contactId];

            if(c.DataInserimentoConsensi__c != null){
                wrap.data.add(c);
            }

            return wrap;
        }
        catch(Exception e){

            wrap.message = e.getMessage();
            wrap.success = false;
            
            return wrap;
        }
    }

    @AuraEnabled
    public static WrapperResponse doc11(String recordId, String codiceModulo, String nomeFile, String lingua){
        WrapperResponse wrap = new WrapperResponse();

        try{
            System.debug('@@@ codiceModulo ' + codiceModulo);
            //HttpRequest req = new HttpRequest();

            Id objectId = (Id)recordId;
            String objectName = objectId.getSObjectType().getDescribe().getName();

            System.debug('@@@ recordId ' + objectName);
            
            WrapperDatiDoc11 payload = new WrapperDatiDoc11();
			//adione CR DigiBox - start
			if (codiceModulo == 'AdeguataVerifica') payload.idModello = '3000'; //MAV
			if (codiceModulo == 'TecnicheComunicazione') payload.idModello = '3001'; //MTC
			if (codiceModulo == 'ServiziFinanziari') payload.idModello = '3002'; //RSF
			if (codiceModulo == 'PrivacyPG') payload.idModello = '3003'; //PRIVACY PG
			if (codiceModulo == 'PrivacyPF') payload.idModello = '3004'; //PRIVACY PF
			String objNdg;
			if (objectName == 'Account') {
				objNdg = [SELECT Id, Name, NDGGruppo__c FROM Account WHERE Id =: recordId LIMIT 1].NDGGruppo__c;

			} else if (objectName == 'Contact') {
                objNdg = [SELECT Id, Name, NDGGruppo__c FROM Contact WHERE Id =: recordId LIMIT 1].NDGGruppo__c;
                
            } else if (objectName == 'Opportunity') {
                objNdg = [SELECT Id, WGC_NDG_Cedente__c FROM Opportunity WHERE Id =: objectId LIMIT 1].WGC_NDG_Cedente__c;

			} else {
                wrap.message = 'Non posso trovare NDG per oggetto '+objectName;
                wrap.success = false;
                return wrap;
			}
			payload.ndg = objNdg;
            System.debug('-----> WGC_Documenti_Controller.doc11 - payload: ' + JSON.serialize(payload));
            //adione CR DigiBox - end
            
            codiceModulo = (codiceModulo == 'PrivacyPF') ? 'PrivacyEsecutore' : (codiceModulo == 'PrivacyPG') ? 'Privacy' : codiceModulo;

            String chiaveComposizione;

            if(lingua != null){
                chiaveComposizione = codiceModulo + '_' + lingua;
            }
            else{
                chiaveComposizione = codiceModulo + '_' + 'IT';
            }

            System.debug('@@@ chiaveComposizione ' + chiaveComposizione);

            List<WGC_Composizione_Documento__mdt> comp = new List<WGC_Composizione_Documento__mdt>();
            comp = [SELECT Id, MasterLabel, DeveloperName, Lingua__c, Nome_Template__c FROM WGC_Composizione_Documento__mdt WHERE DeveloperName =: chiaveComposizione];

            System.debug('@@@ comp ' + JSON.serialize(comp));

            reportDefinitions def = new reportDefinitions(comp[0].Nome_Template__c);
            
            String accountName;
            Sobject obj;
            Sobject parentObj;
            Origine origine;
            Object datasource;

            if(objectName == 'Account' && codiceModulo == 'Privacy'){

                Account account = [SELECT Id, Name, NDGGruppo__c, codiceIstituto3N__c, NaturaGiuridica__c, ConsensoAllaProfilazione__c,
                                    ConsensoProdottiBancaRicercheMercato__c, ConsensoProdottiSocietaTerze__c, ConsensoAttivitaPromozionaleTerzi__c,
                                    ConsensoAttivitaPromRicercheMercato__c, ConsensoSoloModalitaTradizionali__c, BillingCity, 
                                    CF__c, PIVA__c, PIVACF__c, SAE__c, RAE__c, WGC_Esecutore_Firmatario_Privacy__c, TelefonoPrefisso__c
                                    FROM Account WHERE Id =: recordId];

                // List<AccountContactRelation> acrList = new List<AccountContactRelation>();
                AccountContactRelation acr = new AccountContactRelation();
                /*
                try{
                    acrList = [SELECT Id, ContactId, Contact.Name, AccountId, WGC_Titolare_Esecutore__c FROM AccountContactRelation WHERE AccountId =: account.Id AND WGC_Titolare_Esecutore__c = true];
                    System.debug('@@@ acr esecutore ' + JSON.serialize(acrList));
                }
                catch(Exception e){
                    wrap.message = 'Compilare esecutore, prima di scaricare il modulo privacy';
                    wrap.success = false;

                    return wrap;
                }
                */
                
                // acrList = [SELECT Id, ContactId, Contact.Name, AccountId, WGC_Titolare_Esecutore__c FROM AccountContactRelation WHERE AccountId =: account.Id AND WGC_Titolare_Esecutore__c = true AND WGC_Selezionato__c = true];
                // System.debug('@@@ esecutore ' + JSON.serialize(acrList));

                if(account.WGC_Esecutore_Firmatario_Privacy__c == null){
                    wrap.message = 'Compilare esecutore, prima di scaricare il modulo privacy';
                    wrap.success = false;

                    return wrap;
                }
                // else{
                //     acr = acrList[0];
                // }


                datasource = new Origine().generateOrigine(account, acr);

            }

            if(objectName == 'Contact' && codiceModulo == 'PrivacyEsecutore' ){

                Contact contact = [SELECT Id, Name, NDGGruppo__c, codiceIstituto3N__c, NaturaGiuridica__c, ConsensoAllaProfilazione__c,
                                    ConsensoProdottiBancaRicercheMercato__c, ConsensoProdottiSocietaTerze__c, ConsensoAttivitaPromozionaleTerzi__c,
                                    ConsensoAttivitaPromRicercheMercato__c, ConsensoSoloModalitaTradizionali__c, MailingCity, 
                                    CF__c, SAE__c, Account.Name
                                    FROM Contact WHERE Id =: recordId];
            
                datasource = new Origine().generateOrigine(contact);
            }

            if(codiceModulo == 'AdeguataVerifica'){
                Account acc = [SELECT Id, Name, PIVA__c, CF__c, ProvinciaCCIAA__c, REA__c, BillingStreet, BillingCity, BillingPostalCode,
                                BillingState, BillingCountry, ShippingStreet, ShippingCity, ShippingPostalCode, ShippingState, ShippingCountry, 
                                Phone, Fax, DataIscrizioneCCIAA__c, SAE__c, Ateco__c, PaeseCasaMadre__c, PaeseSvolgimentoAttivitaPrevalente__c,
                                ProvinciaSvolgimentoAttivitaPrevalente__c, PaeseRelazioni1__c, PaeseRelazioni2__c, PaeseRelazioni3__c,
                                PartecipazioneSocietaFiduciarie2__c, ShippingStreetType__c, ShippingStreetName__c, ShippingStreetNumber__c, WGC_Emissioni_di_Azioni_al_Portatore_PNF__c,
                                BillingStreetType__c, BillingStreetName__c, BillingStreetNumber__c, TelefonoPrefisso__c, WGC_Partecipazione_societa_fiduciarie__c, WGC_Partecipazione_Trust__c
                                FROM Account WHERE Id =: recordId];

                List<AccountContactRelation> listaTE = [SELECT Id, Contact.FirstName, Contact.LastName, Contact.Birthdate, Contact.PEPTipoCarica__c,
                                Contact.LuogoNascita__c, Contact.ProvinciaNascita__c, Contact.PaeseNascita__c, Contact.Cittadinanza__c,
                                Contact.Sesso__c, Contact.MailingStreet, Contact.MailingCity, Contact.MailingPostalCode, Contact.MailingState,
                                Contact.MailingCountry, Contact.CF__c, toLabel(Contact.TipoDocumentoId__c), Contact.NumeroDoc__c, Contact.LuogoEmissioneDoc__c,
                                Contact.DataEmissioneDoc__c, Contact.DataScadenzaDoc__c, Contact.PEP__c, Contact.Altre_Cariche_Pubbliche__c, Contact.TAECode__c, Contact.Ruolo__c,
                                Contact.OtherStreet, Contact.OtherCity, Contact.OtherPostalCode, Contact.OtherState,
                                Contact.OtherCountry, toLabel(Contact.Professione__c), ContactId, AccountId, WGC_Ruolo__c, WGC_Ruolo_Pratica__c, toLabel(Contact.Ultima_professione_svolta__c),
                                toLabel(WGC_Tipologia_Titolare_Effettivo__c),toLabel(WGC_Relazioni_Tra_Cliente_ed_Esecutore__c), WGC_Titolare_Esecutore__c, WGC_Titolare_Effettivo__c, WGC_Selezionato__c, WGC_Tipologia_Esecutore__c
                                FROM AccountContactRelation WHERE AccountId =: recordId];
				
                List<AdeguataVerifica__c> mavList = new List<AdeguataVerifica__c>();
                AdeguataVerifica__c mav = new AdeguataVerifica__c();
                
                mavList = [SELECT Id, Name, Natura_Factoring__c, Natura_Finanziamenti__c, Natura_Servizi_Bancari__c, Scopo_Factoring__c, Scopo_Finanziamenti__c, Scopo_Servizi_Bancari__c,
								Natura_Crediti_Erariali__c, Altro_Crediti_Erariali__c, NaturaRapportoContinuativoFD__c, ScopoFD11__c, ScopoFD12__c, 
                                ScopoFD13__c, ScopoFD14__c, ScopoFD15__c, ScopoFD16__c, ScopoFD17__c, ScopoFD18__c, ScopoFD19__c, 
                                OrigineFondi1__c, OrigineFondi2__c, OrigineFondi3__c, OrigineFondi4__c, OrigineFondiAltro__c,WGC_TipologiaMav__c
                                FROM AdeguataVerifica__c WHERE Account__c =: recordId AND
                                (CorrispondenzaCountry__c = null OR CorrispondenzaState__c = null OR CorrispondenzaCity__c = null OR 
                                CorrispondenzaStreetType__c = null OR CorrispondenzaStreetName__c = null OR 
                                CorrispondenzaStreetNumber__c = null OR CorrispondenzaCAP__c = null) ORDER BY LastModifiedDate DESC LIMIT 1];
                
                if(!mavList.isEmpty()){
                    mav = mavList.get(0);
                }
				
				System.debug('@@@ mav ' + JSON.serialize(mav));
                if(mav.Id == null){
                    wrap.message = 'Compilare il modulo adeguata verifica, prima di scaricarlo';
                    wrap.success = false;

                    return wrap;
                }

                Boolean esecutorePresente = false;

                for(AccountContactRelation acr : listaTE){
                    if(acr.WGC_Ruolo_Pratica__c != null && acr.WGC_Tipologia_Esecutore__c != null){
                        if((acr.WGC_Ruolo_Pratica__c.contains(acr.WGC_Tipologia_Esecutore__c))){
                            esecutorePresente = true;
                            break;
                        }
                    }
                }
                
                if(!esecutorePresente){
                    wrap.message = 'Aggiungere un esecutore prima di generare il Modulo Adeguata Verifica';
                    wrap.success = false;

                    return wrap;
                }

                datasource = new Origine().generateOrigine(acc, listaTE, mav);

            }
            else if(codiceModulo == 'ServiziFinanziari'){
                Opportunity opp = [SELECT Id, Name, StageName, AccountId, HasFactoringDiretto__c, HasConfirming__c FROM Opportunity WHERE Id =: recordId];

                Account acc = [SELECT Id, Name, PIVA__c, CF__c, ProvinciaCCIAA__c, REA__c, BillingStreet, BillingCity, BillingPostalCode,
                                BillingState, BillingCountry, ShippingStreet, ShippingCity, ShippingPostalCode, ShippingState, ShippingCountry, 
                                Phone, Fax, DataIscrizioneCCIAA__c, SAE__c, Ateco__c, PaeseCasaMadre__c, PaeseSvolgimentoAttivitaPrevalente__c,
                                ProvinciaSvolgimentoAttivitaPrevalente__c, PaeseRelazioni1__c, PaeseRelazioni2__c, PaeseRelazioni3__c,
                                PartecipazioneSocietaFiduciarie2__c, Fatturato__c, Email__c, SIA__c, WGC_Numero_dipendenti__c,
                                ShippingStreetType__c, ShippingStreetName__c, ShippingStreetNumber__c, BillingStreetType__c, 
                                BillingStreetName__c, BillingStreetNumber__c, TelefonoPrefisso__c
                                FROM Account WHERE Id =: opp.AccountId];

                List<Linea__c> linee = [SELECT Name, Durata__c, DurataDilazione__c, DurataMaxCredito__c, FinalitaMutuo__c, GiorniFree__c,
                                Importo__c, Opzioni__c, Prodotto__c, QuotaProSoluto__c, Prodotto__r.Name, Prodotto__r.CodiceUnivoco__c, 
                                Prodotto__r.CodiceProdotto__c, Prodotto__r.WGC_Area__c, RecordType.DeveloperName, LineaATDSingola__c, WGC_Polizza_CPI__c, Prodotto__r.Applicazione__c
                                FROM Linea__c WHERE Opportunity__c = :recordId];

                // List<NDGLinea__c>  ndglinee = [SELECT Id, Name, Plafond__c, DurataNominale__c, Fatturato__c, Opportunita__c, 
                //                 Account__r.Name, Account__r.BillingStreet, Account__r.BillingCity, Account__r.BillingState, 
                //                 Account__r.CF__c, Account__r.PIVA__c, RecordType.DeveloperName
                //                 FROM NDGLinea__c WHERE Opportunita__c =: recordId];
                List<JoinLineaDebitore__c> ndgLinee = [SELECT Id, Debitore__r.Plafond__c, Debitore__r.DurataNominale__c, Debitore__r.Fatturato__c, Opportunita__c,
                                                        Debitore__r.Account__r.Name, Debitore__r.Account__r.BillingStreet, Debitore__r.Account__r.BillingCity, Debitore__r.Account__r.BillingState,
                                                        Debitore__r.Account__r.CF__c, Debitore__r.Account__r.PIVA__c, Debitore__r.RecordType.DeveloperName
                                                        FROM JoinLineaDebitore__c WHERE Opportunita__c =: recordId];

                            //TODO TEST
                Map<String, SObject> lMap = U.keyBy(linee, 'Prodotto__r.CodiceUnivoco__c');

                System.debug('@@@ account rsf ' + JSON.serialize(acc));

                if(acc.Fatturato__c == null){
                    wrap.message = 'Per generare RSF, è necessario compilare il fatturato sul profilo dell\'anagrafica'; //'Fatturato mancante, non è possibile generare il documento';
                    wrap.success = false;

                    return wrap;
                }

                datasource = new Origine().generateOrigine(opp, acc, linee, ndgLinee);

            }
            else if(codiceModulo == 'TecnicheComunicazione'){
                Account acc = [SELECT Id, Name, Email__c, EmailPEC__c, EmailPECFatturaElettronica__c, CodiceDestinatario__c, PIVA__c, CF__c, ProvinciaCCIAA__c, REA__c, 
                                    IndirizzoPerInvioCorrispondenza__c, BillingState, BillingCountry, BillingStreet, BillingCity, BillingPostalCode, BillingStreetType__c, BillingStreetName__c, BillingStreetNumber__c, 
                                    ShippingState, ShippingCountry, ShippingStreet, ShippingCity, ShippingPostalCode, ShippingStreetType__c, ShippingStreetName__c, ShippingStreetNumber__c, 
                                    Phone, Fax, DataIscrizioneCCIAA__c, SIA__c, SAE__c, Ateco__c, PaeseCasaMadre__c, PaeseSvolgimentoAttivitaPrevalente__c,
                                    ProvinciaSvolgimentoAttivitaPrevalente__c, PaeseRelazioni1__c, PaeseRelazioni2__c, PaeseRelazioni3__c,
                                    PartecipazioneSocietaFiduciarie2__c, TelefonoPrefisso__c
                                FROM Account WHERE Id =: recordId];

                if(acc.IndirizzoPerInvioCorrispondenza__c == null){
                    wrap.message = 'Compilare correttamente il modulo tecniche comunicazione, non è stato selezionato l\'indirizzo per l\'invio della corrispondenza';
                    wrap.success = false;

                    return wrap;
                }                                
                                
                List<AdeguataVerifica__c> mavList = new List<AdeguataVerifica__c>();
                AdeguataVerifica__c mav = new AdeguataVerifica__c();
                
                mavList = [SELECT Id, Name, CorrispondenzaStreetType__c, CorrispondenzaStreetName__c, CorrispondenzaStreetNumber__c,
                                            CorrispondenzaCity__c, CorrispondenzaCAP__c, CorrispondenzaState__c
                                            FROM AdeguataVerifica__c WHERE Account__c =: recordId ORDER BY CreatedDate DESC LIMIT 1];
				
                if(!mavList.isEmpty()){
					mav = mavList.get(0);                    
                }
                
                datasource = new Origine().generateOrigine(acc, mav);

            }

            Origine o = new Origine();

            System.debug('@@@ datasource ' + datasource);
            System.debug('@@@ datasource json ' + JSON.serialize(datasource));

            o.origine = datasource;

            System.debug('@@@ origine ' + JSON.serialize(o));
            def.datasource.data = JSON.serialize(o);


            payload.reportDefinitions.add(def);

            nomeFile = nomeFile == null ? codiceModulo : nomeFile;

            // nomeFile = nomeFile == 'ServiziFinanziari' ? 'RSF' : nomeFile;
            // nomeFile = nomeFile == 'PrivacyPersonaFisica' ? 'PrivacyEsecutore' : nomeFile;

            DatiDocumento datiDoc = new DatiDocumento(nomeFile);

            payload.datiDocumento = datiDoc;

            System.debug('@@@ payload ' + JSON.serialize(payload));

            WsRestInput input = new WsRestInput(payload);

            String inputStr = JSON.serialize(input);
            System.debug('@@@ limite heap ' + Limits.getHeapSize());
            Blob file = WGC_WsRest.doc11(inputStr);
            System.debug('@@@ limite heap ' + Limits.getHeapSize());
            System.debug('@@@ file ' + file);

            if(file == null || file.size() < 500){
                wrap.success = false;
                wrap.message = 'Nessun documento trovato';

                return wrap;
            }

            String fileStr = EncodingUtil.base64Encode(file);
            
            wrap.data.add(fileStr);
            wrap.message = 'OK';
            return wrap;
        }
        catch(Exception e){
            wrap.message = e.getMessage() + ' - ' + e.getCause() + ' - ' + e.getLineNumber() + ' - ' + e.getStackTraceString();
            wrap.success = false;

            return wrap;
        }
    }

    public class WrapperDatiDoc11{
        @AuraEnabled
        public DatiDocumento datiDocumento;
        @AuraEnabled
        public List<reportDefinitions> reportDefinitions;
		//adione CR DigiBox - start
		@AuraEnabled
        public String ndg;
		@AuraEnabled
        public String idModello;
        //adione CR DigiBox - end
        
        public WrapperDatiDoc11(){
            this.datiDocumento = new DatiDocumento();
            this.reportDefinitions = new List<reportDefinitions>();
			this.ndg = '';
			this.idModello = '';
        }
    }

    public class DatiDocumento{
        @AuraEnabled
        public String classeOggetto;
        @AuraEnabled
        public String nomeFile;

        public DatiDocumento(){
            this.classeOggetto = 'DOCUMENTI_CLIENTE';
            this.nomeFile = 'test_dett_interessi.pdf';
        }

        public DatiDocumento(String nomeFile){
            this.classeOggetto = 'DOCUMENTI_CLIENTE';
            this.nomeFile = nomeFile != null ? nomeFile : '';
        }
    }

    public class reportDefinitions{
        @AuraEnabled
        public String templateName;
        @AuraEnabled
        public DataSource datasource;

        public reportDefinitions(){
            this.templateName = 'jasper/CRM/Privacy/Privacy.jrxml';
            this.datasource = new DataSource();
        }

        public reportDefinitions(String nomeTemplate){
            this.templateName = nomeTemplate;
            this.datasource = new DataSource();
        }
    }

    public class DataSource{
        @AuraEnabled
        public String archtype;
        @AuraEnabled
        public String data;

        public DataSource(){
            this.archtype = 'ArchReportJsonDatasource';
            this.data = '';
        }
    }

    public class Origine{
        @AuraEnabled
        public Object origine;

        //Costruttore per privacy ragione sociale
        
        public Object generateOrigine( Account account, AccountContactRelation acr ){
            return origine = new DatiPrivacy(account, acr);
        }

        //Costruttore per privacy referente
        public Object generateOrigine( Contact contact ){
            return origine = new DatiPrivacy(contact);
        }
        

        //Costruttore per MAV
        public Object generateOrigine( Account account, List<AccountContactRelation> listaTitolariEsecutori, AdeguataVerifica__c mav){
            return origine = new DatiAdeguataVerifica(account, listaTitolariEsecutori, mav);

        }

        //Costruttore per RSF
        public Object generateOrigine( Opportunity opp, Account account, List<Linea__c> attori, List<JoinLineaDebitore__c> listaClienti ){
            return origine = new DatiRichiestaServiziFinanziari(opp, account, attori, listaClienti);
        }

        //Costruttore per MTC
        public Object generateOrigine( Account account, AdeguataVerifica__c mav ){
            return origine = new DatiTecnicheComunicazione(account, mav);
        }

        public Origine(){
            this.origine = origine;
        }
    }

    public virtual class DatiCliente{
        @AuraEnabled
        public String denominazione;
        @AuraEnabled
        public String pIva;
        @AuraEnabled
        public String cf;
        @AuraEnabled
        public String cciaa;
        @AuraEnabled
        public String rea;
        @AuraEnabled
        public String indirizzoLegale;
        @AuraEnabled
        public String cittaLegale;
        @AuraEnabled
        public String capLegale;
        @AuraEnabled
        public String provinciaLegale;
        @AuraEnabled
        public String indirizzoAmm;
        @AuraEnabled
        public String cittaAmm;
        @AuraEnabled
        public String capAmm;
        @AuraEnabled
        public String provinciaAmm;
        @AuraEnabled
        public String telefono;
        @AuraEnabled
        public String fax;

        public DatiCliente(){
            this.denominazione = denominazione;
            this.pIva = pIva;
            this.cf = cf;
            this.cciaa = cciaa;
            this.rea = rea;
            this.indirizzoLegale = indirizzoLegale;
            this.cittaLegale = cittaLegale;
            this.capLegale = capLegale;
            this.provinciaLegale = provinciaLegale;
            this.indirizzoAmm = indirizzoAmm;
            this.cittaAmm = cittaAmm;
            this.capAmm = capAmm;
            this.provinciaAmm = provinciaAmm;
            this.telefono = telefono;
            this.fax = fax;
        }

        public DatiCliente(Account account){
            this.denominazione = account.Name;
            this.pIva = account.PIVA__c;
            this.cf = account.CF__c;
            this.cciaa = account.ProvinciaCCIAA__c;
            this.rea = account.REA__c;
            this.indirizzoLegale = account.BillingStreet;
            this.cittaLegale = account.BillingCity;
            this.capLegale = account.BillingPostalCode;
            this.provinciaLegale = account.BillingState;
            this.indirizzoAmm = account.ShippingStreet;
            this.cittaAmm = account.ShippingCity;
            this.capAmm = account.ShippingPostalCode;
            this.provinciaAmm = account.ShippingState;
            this.telefono = account.TelefonoPrefisso__c	+ '' + account.Phone;
            this.fax = account.Fax;
        }
    }

    public class DatiPrivacy{
        @AuraEnabled
        public String autorizzazione1;
        @AuraEnabled
        public String autorizzazione2;
        @AuraEnabled
        public String autorizzazione3;
        @AuraEnabled
        public String autorizzazione4;
        @AuraEnabled
        public String autorizzazione5;
        @AuraEnabled
        public String modalita;
        @AuraEnabled
        public String nomeCognome;
        @AuraEnabled
        public String azienda;
        @AuraEnabled
        public String luogo;
        @AuraEnabled
        public String data;

        public DatiPrivacy(){
            this.autorizzazione1 = 'AUTORIZZO';
            this.autorizzazione2 = 'AUTORIZZO';
            this.autorizzazione3 = 'NON AUTORIZZO';
            this.autorizzazione4 = 'AUTORIZZO';
            this.autorizzazione5 = 'AUTORIZZO';
            this.modalita = 'AUTORIZZO';
            this.nomeCognome = 'Mario Rossi';
            this.azienda = 'Rossi s.r.l.';
            this.luogo = 'Padova';
            this.data = '12/03/2019';
        }

        public DatiPrivacy(Contact contact){
            this.autorizzazione1 = contact.ConsensoAllaProfilazione__c == true ? 'AUTORIZZO' : 'NON AUTORIZZO';
            this.autorizzazione2 = contact.ConsensoProdottiBancaRicercheMercato__c == true ? 'AUTORIZZO' : 'NON AUTORIZZO';
            this.autorizzazione3 = contact.ConsensoProdottiSocietaTerze__c == true ? 'AUTORIZZO' : 'NON AUTORIZZO';
            this.autorizzazione4 = contact.ConsensoAttivitaPromRicercheMercato__c == true ? 'AUTORIZZO' : 'NON AUTORIZZO';
            this.autorizzazione5 = contact.ConsensoAttivitaPromozionaleTerzi__c == true ? 'AUTORIZZO' : 'NON AUTORIZZO';
            this.modalita = contact.ConsensoSoloModalitaTradizionali__c == true ? 'AUTORIZZO' : 'NON AUTORIZZO';
            this.nomeCognome = contact.Name;
            this.azienda = contact.Account.Name;
            this.luogo = contact.MailingCity != null ? contact.MailingCity : '';
            this.data = System.Today().format();
        }

        public DatiPrivacy(Account account, AccountContactRelation acr){
            this.autorizzazione1 = account.ConsensoAllaProfilazione__c == true ? 'AUTORIZZO' : 'NON AUTORIZZO';
            this.autorizzazione2 = account.ConsensoProdottiBancaRicercheMercato__c == true ? 'AUTORIZZO' : 'NON AUTORIZZO';
            this.autorizzazione3 = account.ConsensoProdottiSocietaTerze__c == true ? 'AUTORIZZO' : 'NON AUTORIZZO';
            this.autorizzazione4 = account.ConsensoAttivitaPromRicercheMercato__c == true ? 'AUTORIZZO' : 'NON AUTORIZZO';
            this.autorizzazione5 = account.ConsensoAttivitaPromozionaleTerzi__c == true ? 'AUTORIZZO' : 'NON AUTORIZZO';
            this.modalita = account.ConsensoSoloModalitaTradizionali__c == true ? 'AUTORIZZO' : 'NON AUTORIZZO';
            //this.nomeCognome = acr != null ? acr.Contact.Name : '';
            this.nomeCognome = String.isBlank(account.WGC_Esecutore_Firmatario_Privacy__c) ? '' : account.WGC_Esecutore_Firmatario_Privacy__c;
            this.azienda = account.Name;
            this.luogo = account.BillingCity != null ? account.BillingCity : '';
            this.data = System.Today().format();
        }
    }

    //Dati per doc11 MODULO ADEGUATA VERIFICA
    public class DatiAdeguataVerifica{
        @AuraEnabled
        public DatiClienteMAV datiCliente;
        @AuraEnabled
        public ProfiloClienteMAV profiloCliente;
        @AuraEnabled
        public String titolariEffettivo;
        @AuraEnabled
        public String numTitolari;
        @AuraEnabled
        public String societa;
        @AuraEnabled
        public String societaFiduciarie;
        @AuraEnabled
        public String societaFiduciariePaese;
        @AuraEnabled
        public String trust;
        @AuraEnabled
        public String trustPaese;
        @AuraEnabled
        public String societaAnonime;
        @AuraEnabled
        public String societaAnonimePaese;
        @AuraEnabled
        public String fondazioni;
        @AuraEnabled
        public String fondazioniPaese;
        @AuraEnabled
        public List<TitolariMAV> titolari;
        @AuraEnabled
        public EsecutoreMAV esecutore;
        @AuraEnabled
        public RapportoMAV rapporto;
        @AuraEnabled
        public String luogoData;
		@AuraEnabled
        public String profilo;        

        public DatiAdeguataVerifica(){
            this.datiCliente = new DatiClienteMAV();
            this.profiloCliente = new ProfiloClienteMAV();
            this.titolariEffettivo = titolariEffettivo;
            this.numTitolari = numTitolari;
            this.societa = societa;
            this.fondazioni = fondazioni;
            this.fondazioniPaese = fondazioniPaese;
            this.societaFiduciarie = societaFiduciarie;
            this.societaFiduciariePaese = societaFiduciariePaese;
            this.trust = trust;
            this.trustPaese = trustPaese;
            this.societaAnonime = societaAnonime;
            this.societaAnonimePaese = societaAnonimePaese;
            this.titolari = new List<TitolariMAV>();
            this.esecutore = new EsecutoreMAV();
            this.rapporto = new RapportoMAV();
            this.luogoData = '';
			this.profilo = '';
        }

        //Costruttore corretto
        public DatiAdeguataVerifica(Account account, List<AccountContactRelation> listaTitolariEsecutori, AdeguataVerifica__c mav){
            Integer countTitEff = 0;
            for(AccountContactRelation acr : listaTitolariEsecutori){
                System.debug('@@@ acr.WGC_Ruolo_Pratica__c ' + acr.WGC_Ruolo_Pratica__c);
                if(acr.WGC_Ruolo_Pratica__c != null){
                    if((acr.WGC_Ruolo_Pratica__c.contains('J') || acr.WGC_Ruolo_Pratica__c.contains('J1')) && acr.WGC_Selezionato__c){
                        countTitEff ++;
                    }
                }
            }

            System.debug('@@@ countTitEff ' + countTitEff);
            System.debug('@@@ str countTitEff ' + String.valueOf(countTitEff));

            this.datiCliente = new DatiClienteMAV(account);
            this.profiloCliente = new ProfiloClienteMAV(account);
            this.titolariEffettivo = !listaTitolariEsecutori.isEmpty() == true ? 'VERO' : 'FALSO';
            this.numTitolari = String.valueOf(countTitEff);
            this.societa = account.PartecipazioneSocietaFiduciarie2__c == true ? 'VERO' : 'FALSO';
            this.societaFiduciarie = account.WGC_Partecipazione_societa_fiduciarie__c == '01' ? 'VERO':'FALSO';
            this.societaFiduciariePaese = account.WGC_Partecipazione_societa_fiduciarie__c == '01' ? account.WGC_Partecipazione_Trust__c : '';
            this.trust = account.WGC_Partecipazione_societa_fiduciarie__c == '02' ? 'VERO':'FALSO';
            this.trustPaese = account.WGC_Partecipazione_societa_fiduciarie__c == '02' ? account.WGC_Partecipazione_Trust__c : '';
            this.societaAnonime = account.WGC_Partecipazione_societa_fiduciarie__c == '03' ? 'VERO':'FALSO';
            this.societaAnonimePaese = account.WGC_Partecipazione_societa_fiduciarie__c == '03' ? account.WGC_Partecipazione_Trust__c : '';
            this.fondazioni = account.WGC_Partecipazione_societa_fiduciarie__c == '04' ? 'VERO':'FALSO';
            this.fondazioniPaese = account.WGC_Partecipazione_societa_fiduciarie__c == '04' ? account.WGC_Partecipazione_Trust__c : '';
            this.titolari = new TitolariMAV().generaTitolari(listaTitolariEsecutori);
            this.esecutore = new EsecutoreMAV().generateEsecutore(listaTitolariEsecutori);
            this.rapporto = new RapportoMAV(mav);
            this.luogoData = '';
			Profile p = [Select Name from Profile where Id =: UserInfo.getProfileid()];
            //PALUMBO 27/03/2020
			//this.profilo = p.Name;
            this.profilo = mav.WGC_TipologiaMav__c != null && mav.WGC_TipologiaMav__c == 'CE' ? 'PROCEDURA' : '';
            System.debug('@@@ this.titolari ' + JSON.serialize(this.titolari));
        }
    }

    public class DatiClienteMAV extends DatiCliente{
        @AuraEnabled
        public String dataIscrizione;
        @AuraEnabled
        public String paeseLegale;
        @AuraEnabled
        public String paeseAmm;

        public DatiClienteMAV(){
            this.dataIscrizione = dataIscrizione;
            this.paeseLegale = paeseLegale;
            this.paeseAmm = paeseAmm;
        }

        public DatiClienteMAV(Account account){

            account.ShippingStreet = UtilAnagrafiche.getIndirizzoCompleto(
                account.ShippingStreetType__c,
                account.ShippingStreetName__c,
                account.ShippingStreetNumber__c
            );

            account.BillingStreet = UtilAnagrafiche.getIndirizzoCompleto(
                account.BillingStreetType__c,
                account.BillingStreetName__c,
                account.BillingStreetNumber__c
            );

            if(account.ShippingStreet == account.BillingStreet && 
                account.BillingCity == account.ShippingCity && 
                account.BillingPostalCode == account.ShippingPostalCode && 
                account.BillingState == account.ShippingState){

                account.ShippingStreet = '';
                account.ShippingCity = '';
                account.ShippingPostalCode = '';
                account.ShippingState = '';
            }
            
            this.denominazione = account.Name;
            this.pIva = account.PIVA__c != null ? account.PIVA__c : '';
            this.cf = account.CF__c != null ? account.CF__c : '';
            this.cciaa = account.ProvinciaCCIAA__c != null ? account.ProvinciaCCIAA__c : '';
            this.rea = account.REA__c != null ? account.REA__c : '';
            this.indirizzoLegale = account.BillingStreet != null ? account.BillingStreet : '';
            this.cittaLegale = account.BillingCity != null ? account.BillingCity : '';
            this.capLegale = account.BillingPostalCode != null ? account.BillingPostalCode : '';
            this.provinciaLegale = account.BillingState != null ? account.BillingState : '';
            this.indirizzoAmm = account.ShippingStreet != null ? account.ShippingStreet : '';
            this.cittaAmm = account.ShippingCity != null ? account.ShippingCity : '';
            this.capAmm = account.ShippingPostalCode != null ? account.ShippingPostalCode : '';
            this.provinciaAmm = account.ShippingState != null ? account.ShippingState : '';
            this.telefono = account.TelefonoPrefisso__c	!= null && account.Phone != null ? account.TelefonoPrefisso__c + '' + account.Phone : '';
            this.fax = account.Fax != null ? account.Fax : '';
            this.dataIscrizione = account.DataIscrizioneCCIAA__c != null ? account.DataIscrizioneCCIAA__c.format() : '';
            this.paeseLegale = account.BillingCountry != null ? account.BillingCountry : '';
            this.paeseAmm = account.ShippingCountry != null ? account.ShippingCountry : '';
        }

    }

    public class ProfiloClienteMAV{
        @AuraEnabled
        public String sae;
        @AuraEnabled
        public String ateco;
        @AuraEnabled
        public String paeseMadre;
        @AuraEnabled
        public String paeseAttivita;
        @AuraEnabled
        public String provinciaAttivita;
        @AuraEnabled
        public String paese1;
        @AuraEnabled
        public String paese2;
        @AuraEnabled
        public String paese3;
        @AuraEnabled
        public String azioniPortatore;

        public ProfiloClienteMAV(){
            this.sae = sae;
            this.ateco = ateco;
            this.paeseMadre = paeseMadre;
            this.paeseAttivita = paeseAttivita;
            this.provinciaAttivita = provinciaAttivita;
            this.paese1 = paese1;
            this.paese2 = paese2;
            this.paese3 = paese3;
            this.azioniPortatore = azioniPortatore;
        }


        public ProfiloClienteMAV(Account account){
            this.sae = account.SAE__c != null ? account.SAE__c : '';
            this.ateco = account.ATECO__c != null ? account.ATECO__c : '';
            this.paeseMadre = account.PaeseCasaMadre__c != null ? account.PaeseCasaMadre__c : '';
            this.paeseAttivita = account.PaeseSvolgimentoAttivitaPrevalente__c != null ? account.PaeseSvolgimentoAttivitaPrevalente__c : '';
            this.provinciaAttivita = account.ProvinciaSvolgimentoAttivitaPrevalente__c != null ? account.ProvinciaSvolgimentoAttivitaPrevalente__c : '';
            this.paese1 = account.PaeseRelazioni1__c != null ? account.PaeseRelazioni1__c : '';
            this.paese2 = account.PaeseRelazioni2__c != null ? account.PaeseRelazioni2__c : '';
            this.paese3 = account.PaeseRelazioni3__c != null ? account.PaeseRelazioni3__c : '';
            this.azioniPortatore = account.WGC_Emissioni_di_Azioni_al_Portatore_PNF__c ? 'S' : 'N';
        }
    }

    public class TitolariMAV{
        @AuraEnabled
        public String cognome;
        @AuraEnabled
        public String nome;
        @AuraEnabled
        public String dataNascita;
        @AuraEnabled
        public String luogoNascita;
        @AuraEnabled
        public String provinciaNascita;
        @AuraEnabled
        public String paeseNascita;
        @AuraEnabled
        public String cittadinanza;
        @AuraEnabled
        public String sesso;
        @AuraEnabled
        public String indirizzoResidenza;
        @AuraEnabled
        public String cittaResidenza;
        @AuraEnabled
        public String capResidenza;
        @AuraEnabled
        public String provinciaResidenza;
        @AuraEnabled
        public String paeseResidenza;
        @AuraEnabled
        public String cf;
        @AuraEnabled
        public String tipoDocumento;
        @AuraEnabled
        public String numDocumento;
        @AuraEnabled
        public String luogo;
        @AuraEnabled
        public String dataEmissione;
        @AuraEnabled
        public String dataScadenza;
        @AuraEnabled
        public String testoPep;
        @AuraEnabled
        public String pep;
        @AuraEnabled
        public String pepSi;
        @AuraEnabled
        public String tipologiaDiretta;
        @AuraEnabled
        public String tipologiaIndiretta;
        @AuraEnabled
        public String tipologiaControllo;
        @AuraEnabled
        public String tipologiaPotere;
        @AuraEnabled
        public String tipologiaFondatore;
        @AuraEnabled
        public String tipologiaTrust;
        @AuraEnabled
        public String relazioneClienteEsecutore;
        @AuraEnabled
        public String tae;
        @AuraEnabled
        public String professione;
		@AuraEnabled
		public String altreCarichePubbliche;
        @AuraEnabled
		public String ultimaProfessione;
        @AuraEnabled
		public String pil;
        @AuraEnabled
		public String pilSi;

        public TitolariMAV(){
            this.cognome = cognome;
            this.nome = nome;
            this.dataNascita = dataNascita;
            this.luogoNascita = luogoNascita;
            this.provinciaNascita = provinciaNascita;
            this.paeseNascita = paeseNascita;
            this.cittadinanza = cittadinanza;
            this.sesso = sesso;
            this.indirizzoResidenza = indirizzoResidenza;
            this.cittaResidenza = cittaResidenza;
            this.capResidenza = capResidenza;
            this.provinciaResidenza = provinciaResidenza;
            this.paeseResidenza = paeseResidenza;
            this.cf = cf;
            this.tipoDocumento = tipoDocumento;
            this.numDocumento = numDocumento;
            this.luogo = luogo;
            this.dataEmissione = dataEmissione;
            this.dataScadenza = dataScadenza;
            this.pep = pep;
            this.pepSi = pepSi;
            this.tipologiaDiretta = tipologiaDiretta;
            this.tipologiaIndiretta = tipologiaIndiretta;
            this.tipologiaControllo = tipologiaControllo;
            this.tipologiaPotere = tipologiaPotere;
            this.tipologiaFondatore = tipologiaFondatore;
            this.tipologiaTrust = tipologiaTrust;
            this.relazioneClienteEsecutore = relazioneClienteEsecutore;
            this.tae = tae;
            this.professione = professione;
			this.altreCarichePubbliche = altreCarichePubbliche;
            this.ultimaProfessione = ultimaProfessione;
            this.pil = pil;
            this.pilSi = pilSi;
        }

        public List<TitolariMAV> generaTitolari(List<AccountContactRelation> listaTitolari){
            List<TitolariMAV> lista = new List<TitolariMAV>();
            for(AccountContactRelation acr : listaTitolari){
                if(acr.WGC_Selezionato__c && (acr.WGC_Ruolo_Pratica__c.contains('J') || acr.WGC_Ruolo_Pratica__c.contains('J1'))){
                    TitolariMAV titolare = new TitolariMAV();
                    titolare.cognome = acr.Contact.LastName != null ? acr.Contact.LastName : '';
                    titolare.nome = acr.Contact.FirstName != null ? acr.Contact.FirstName : '';
                    titolare.dataNascita = acr.Contact.Birthdate != null ? acr.Contact.Birthdate.format() : '';
                    titolare.luogoNascita = acr.Contact.LuogoNascita__c != null ? acr.Contact.LuogoNascita__c : '';
                    titolare.provinciaNascita = acr.Contact.ProvinciaNascita__c != null ? acr.Contact.ProvinciaNascita__c : '';
                    titolare.paeseNascita = acr.Contact.PaeseNascita__c != null ? acr.Contact.PaeseNascita__c : '';
                    titolare.cittadinanza = acr.Contact.Cittadinanza__c != null ? acr.Contact.Cittadinanza__c : '';
                    titolare.sesso = acr.Contact.Sesso__c != null ? acr.Contact.Sesso__c : '';
                    titolare.indirizzoResidenza = acr.Contact.MailingStreet != null ? acr.Contact.MailingStreet : '';
                    titolare.cittaResidenza = acr.Contact.MailingCity != null ? acr.Contact.MailingCity : '';
                    titolare.capResidenza = acr.Contact.MailingPostalCode != null ? acr.Contact.MailingPostalCode : '';
                    titolare.provinciaResidenza = acr.Contact.MailingState != null ? acr.Contact.MailingState : '';
                    titolare.paeseResidenza = acr.Contact.MailingCountry != null ? acr.Contact.MailingCountry : '';
                    titolare.cf = acr.Contact.CF__c != null ? acr.Contact.CF__c : '';
                    titolare.tipoDocumento = acr.Contact.TipoDocumentoId__c != null ? acr.Contact.TipoDocumentoId__c : '';
                    titolare.numDocumento = acr.Contact.NumeroDoc__c != null ? acr.Contact.NumeroDoc__c : '';
                    titolare.luogo = acr.Contact.LuogoEmissioneDoc__c != null ? acr.Contact.LuogoEmissioneDoc__c : '';
                    titolare.dataEmissione = acr.Contact.DataEmissioneDoc__c != null ? acr.Contact.DataEmissioneDoc__c.format() : '';
                    titolare.dataScadenza = acr.Contact.DataScadenzaDoc__c != null ? acr.Contact.DataScadenzaDoc__c.format() : '';
                    titolare.testoPep = acr.Contact.PEPTipoCarica__c != null ? acr.Contact.PEPTipoCarica__c : '';
                    // titolare.pep = acr.Contact.PEPTipoCarica__c != null ? acr.Contact.PEPTipoCarica__c : '';
                    // titolare.pepSi = acr.Contact.PEP__c  ? 'S' : 'N';
                    titolare.pep = acr.Contact.PEP__c ? 'S' : 'N';
                    titolare.pepSi = acr.Contact.PEP__c  ? acr.Contact.PEPTipoCarica__c : '';
					titolare.altreCarichePubbliche = acr.Contact.Altre_Cariche_Pubbliche__c ? 'S' : 'N';
                    titolare.pil = (titolare.altreCarichePubbliche == 'S')? 'S' : 'N';
                    titolare.pilSi = (titolare.altreCarichePubbliche == 'S')? acr.Contact.PEPTipoCarica__c : '';
                    titolare.tipologiaDiretta = acr.WGC_Tipologia_Titolare_Effettivo__c.contains('Proprietà diretta') ? 'S' : 'N';
                    titolare.tipologiaIndiretta = (acr.WGC_Tipologia_Titolare_Effettivo__c.contains('Proprietà indiretta') && titolare.tipologiaDiretta == 'S') ? 'N' : (acr.WGC_Tipologia_Titolare_Effettivo__c.contains('Proprietà indiretta') && titolare.tipologiaDiretta == 'N') ? 'S' : 'N';
                    titolare.tipologiaControllo = acr.WGC_Tipologia_Titolare_Effettivo__c.contains('Controllo') ? 'S' : 'N';
                    titolare.tipologiaPotere = acr.WGC_Tipologia_Titolare_Effettivo__c.contains('Potere di amministrazione e direzione') ? 'S' : 'N';
                    titolare.tipologiaFondatore = acr.WGC_Tipologia_Titolare_Effettivo__c.contains('Fondatore e/o beneficiario di Ass./Fond./Org. No profit/PG privata') ? 'S' : 'N';
                    titolare.tipologiaTrust = acr.WGC_Tipologia_Titolare_Effettivo__c.contains('Componente di Trust') ? 'S' : 'N';
                    titolare.relazioneClienteEsecutore = acr.WGC_Relazioni_Tra_Cliente_ed_Esecutore__c != null ? acr.WGC_Relazioni_Tra_Cliente_ed_Esecutore__c:'';
                    titolare.tae = acr.Contact.TAECode__c != null ? acr.Contact.TAECode__c : '';
                    titolare.professione = acr.Contact.Professione__c != null ? acr.Contact.Professione__c : '';
                    titolare.ultimaProfessione = acr.Contact.Ultima_professione_svolta__c != null ? acr.Contact.Ultima_professione_svolta__c : '';

                    lista.add(titolare);
                }
            }

            if(lista.isEmpty()){
                TitolariMAV titolare = new TitolariMAV();
                titolare.cognome = '';
                titolare.nome = '';
                titolare.dataNascita = '';
                titolare.luogoNascita = '';
                titolare.provinciaNascita = '';
                titolare.paeseNascita = '';
                titolare.cittadinanza = '';
                titolare.sesso ='';
                titolare.indirizzoResidenza = '';
                titolare.cittaResidenza = '';
                titolare.capResidenza = '';
                titolare.provinciaResidenza = '';
                titolare.paeseResidenza = '';
                titolare.cf = '';
                titolare.tipoDocumento = '';
                titolare.numDocumento = '';
                titolare.luogo = '';
                titolare.dataEmissione = '';
                titolare.dataScadenza = '';
                titolare.testoPep = '';
                // titolare.pep = acr.Contact.PEPTipoCarica__c != null ? acr.Contact.PEPTipoCarica__c : '';
                // titolare.pepSi = acr.Contact.PEP__c  ? 'S' : 'N';
                titolare.pep = '';
                titolare.pepSi = '';
                titolare.tipologiaDiretta = '';
                titolare.tipologiaIndiretta = '';
                titolare.tipologiaControllo ='';
                titolare.tipologiaPotere = '';
                titolare.tae ='';
                titolare.professione = '';

                lista.add(titolare);
            }
            
            return lista;
        }
    }

    public class EsecutoreMAV{
        @AuraEnabled
        public String esecutoreLegale;
        @AuraEnabled
        public String esecutoreProcuratore;
        @AuraEnabled
        public String esecutoreAltro;
        @AuraEnabled
        public String esecutoreTesto;
        @AuraEnabled
        public String cognome;
        @AuraEnabled
        public String nome;
        @AuraEnabled
        public String dataNascita;
        @AuraEnabled
        public String luogoNascita;
        @AuraEnabled
        public String provinciaNascita;
        @AuraEnabled
        public String paeseNascita;
        @AuraEnabled
        public String cittadinanza;
        @AuraEnabled
        public String sesso;
        @AuraEnabled
        public String indirizzoResidenza;
        @AuraEnabled
        public String cittaResidenza;
        @AuraEnabled
        public String capResidenza;
        @AuraEnabled
        public String provinciaResidenza;
        @AuraEnabled
        public String paeseResidenza;
        @AuraEnabled
        public String indirizzoDomicilio;
        @AuraEnabled
        public String cittaDomicilio;
        @AuraEnabled
        public String capDomicilio;
        @AuraEnabled
        public String provinciaDomicilio;
        @AuraEnabled
        public String paeseDomicilio;
        @AuraEnabled
        public String cf;
        @AuraEnabled
        public String tipoDocumento;
        @AuraEnabled
        public String numDocumento;
        @AuraEnabled
        public String luogo;
        @AuraEnabled
        public String dataEmissione;
        @AuraEnabled
        public String dataScadenza;
        @AuraEnabled
        public String pep;
        @AuraEnabled
        public String testoPep;
        // @AuraEnabled 
        // public String pepSi;
        @AuraEnabled
        public String tae;
        @AuraEnabled
        public String professione;
		@AuraEnabled
        public String altreCarichePubbliche;
        @AuraEnabled
        public String testoPil;
        @AuraEnabled
        public String pil;
        @AuraEnabled
        public String relazioneClienteEsecutore;
                   

        public EsecutoreMAV(){
            this.esecutoreLegale = esecutoreLegale;
            this.esecutoreProcuratore = esecutoreProcuratore;
            this.esecutoreAltro = esecutoreAltro;
            this.esecutoreTesto = esecutoreTesto;
            this.cognome = cognome;
            this.nome = nome;
            this.dataNascita = dataNascita;
            this.luogoNascita = luogoNascita;
            this.provinciaNascita = provinciaNascita;
            this.paeseNascita = paeseNascita;
            this.cittadinanza = cittadinanza;
            this.sesso = sesso;
            this.indirizzoResidenza = indirizzoResidenza;
            this.cittaResidenza = cittaResidenza;
            this.capResidenza = capResidenza;
            this.provinciaResidenza = provinciaResidenza;
            this.paeseResidenza = paeseResidenza;
            this.indirizzoDomicilio = indirizzoDomicilio;
            this.cittaDomicilio = cittaDomicilio;
            this.capDomicilio = capDomicilio;
            this.provinciaDomicilio = provinciaDomicilio;
            this.paeseDomicilio = paeseDomicilio;
            this.cf = cf;
            this.tipoDocumento = tipoDocumento;
            this.numDocumento = numDocumento;
            this.luogo = luogo;
            this.dataEmissione = dataEmissione;
            this.dataScadenza = dataScadenza;
            this.pep = pep;
            this.tae = tae;
            this.professione = professione;
			this.altreCarichePubbliche = altreCarichePubbliche;
            this.testoPil = testoPil;
            this.pil = pil;
            this.relazioneClienteEsecutore = relazioneClienteEsecutore;

        }

        public EsecutoreMAV generateEsecutore(List<AccountContactRelation> listaReferenti){
            EsecutoreMAV esecutore = new EsecutoreMAV();
            for(AccountContactRelation acr : listaReferenti){
                System.debug('@@@ acr ' + acr);
                if(acr.WGC_Ruolo_Pratica__c != null && acr.WGC_Tipologia_Esecutore__c != null){
                    if(acr.WGC_Selezionato__c && acr.WGC_Ruolo_Pratica__c.contains(acr.WGC_Tipologia_Esecutore__c)){
                        List<String> pickListValuesList= new List<String>();
                        Schema.DescribeFieldResult fieldResult = AccountContactRelation.WGC_Ruolo__c.getDescribe();
                        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
                        String esecAltro = '';
                        for( Schema.PicklistEntry pickListVal : ple){
                            if(!acr.WGC_Ruolo_Pratica__c.contains('Z1') && !acr.WGC_Ruolo_Pratica__c.contains('Z3') && 
                            acr.WGC_Ruolo_Pratica__c.contains(acr.WGC_Tipologia_Esecutore__c) && acr.WGC_Tipologia_Esecutore__c == pickListVal.getValue()){
                                System.debug('@@@ pickListVal.getLabel(); ' + pickListVal.getLabel());
                                esecAltro = pickListVal.getLabel();
                            }
                        }
                        System.debug('@@@ esecAltro  ' + esecAltro);
                        esecutore.esecutoreLegale = acr.WGC_Ruolo_Pratica__c.contains('Z1') ? 'S' : 'N';
                        esecutore.esecutoreProcuratore = acr.WGC_Ruolo_Pratica__c.contains('Z3') ? 'S' : 'N';
                        esecutore.esecutoreAltro = (!acr.WGC_Ruolo_Pratica__c.contains('Z1') && !acr.WGC_Ruolo_Pratica__c.contains('Z3')) ? 'S' : 'N';
                        esecutore.esecutoreTesto = (!acr.WGC_Ruolo_Pratica__c.contains('Z1') && !acr.WGC_Ruolo_Pratica__c.contains('Z3')) ? esecAltro : '';
                        esecutore.cognome = acr.Contact.LastName != null ? acr.Contact.LastName : '';
                        esecutore.nome = acr.Contact.FirstName != null ? acr.Contact.FirstName : '';
                        esecutore.dataNascita = acr.Contact.Birthdate != null ? acr.Contact.Birthdate.format() : '';
                        esecutore.luogoNascita = acr.Contact.LuogoNascita__c != null ? acr.Contact.LuogoNascita__c : '';
                        esecutore.provinciaNascita = acr.Contact.ProvinciaNascita__c != null ? acr.Contact.ProvinciaNascita__c : '';
                        esecutore.paeseNascita = acr.Contact.PaeseNascita__c != null ? acr.Contact.PaeseNascita__c : '';
                        esecutore.cittadinanza = acr.Contact.Cittadinanza__c != null ? acr.Contact.Cittadinanza__c : '';
                        esecutore.sesso = acr.Contact.Sesso__c != null ? acr.Contact.Sesso__c : '';
                        esecutore.indirizzoResidenza = acr.Contact.MailingStreet != null ? acr.Contact.MailingStreet : '';
                        esecutore.cittaResidenza = acr.Contact.MailingCity != null ? acr.Contact.MailingCity : '';
                        esecutore.capResidenza = acr.Contact.MailingPostalCode != null ? acr.Contact.MailingPostalCode : '';
                        esecutore.provinciaResidenza = acr.Contact.MailingState != null ? acr.Contact.MailingState : '';
                        esecutore.paeseResidenza = acr.Contact.MailingCountry != null ? acr.Contact.MailingCountry : '';
                        esecutore.indirizzoDomicilio = acr.Contact.OtherStreet != null ? acr.Contact.OtherStreet : '';
                        esecutore.cittaDomicilio = acr.Contact.OtherCity != null ? acr.Contact.OtherCity : '';
                        esecutore.capDomicilio = acr.Contact.OtherPostalCode != null ? acr.Contact.OtherPostalCode : '';
                        esecutore.provinciaDomicilio = acr.Contact.OtherState != null ? acr.Contact.OtherState : '';
                        esecutore.paeseDomicilio = acr.Contact.OtherCountry != null ? acr.Contact.OtherCountry : '';
                        esecutore.cf = acr.Contact.CF__c != null ? acr.Contact.CF__c : '';
                        esecutore.tipoDocumento = acr.Contact.TipoDocumentoId__c != null ? acr.Contact.TipoDocumentoId__c : '';
                        esecutore.numDocumento = acr.Contact.NumeroDoc__c != null ? acr.Contact.NumeroDoc__c : '';
                        esecutore.luogo = acr.Contact.LuogoEmissioneDoc__c != null ? acr.Contact.LuogoEmissioneDoc__c : '';
                        esecutore.dataEmissione = acr.Contact.DataEmissioneDoc__c != null ? acr.Contact.DataEmissioneDoc__c.format() : '';
                        esecutore.dataScadenza = acr.Contact.DataScadenzaDoc__c != null ? acr.Contact.DataScadenzaDoc__c.format() : '';
                        //esecutore.pep = acr.Contact.PEPTipoCarica__c != null ? acr.Contact.PEPTipoCarica__c : ''; 
                        esecutore.pep = acr.Contact.PEP__c ? 'S' : 'N';
                        esecutore.testoPep = acr.Contact.PEP__c ? acr.Contact.PEPTipoCarica__c : '';
						//esecutore.altreCarichePubbliche = acr.Contact.Altre_Cariche_Pubbliche__c ? 'S' : 'N';
                        //esecutore.pepSi = acr.Contact.PEPTipoCarica__c != null ? acr.Contact.PEPTipoCarica__c : '';
                        esecutore.tae = acr.Contact.TAECode__c != null ? acr.Contact.TAECode__c : '';
                        esecutore.professione = acr.Contact.Professione__c != null ? acr.Contact.Professione__c : '';
                        esecutore.testoPil = acr.Contact.PEPTipoCarica__c != null ? acr.Contact.PEPTipoCarica__c : '';
                        esecutore.pil = acr.Contact.Altre_Cariche_Pubbliche__c ? 'S' : 'N';
						esecutore.relazioneClienteEsecutore = acr.WGC_Relazioni_Tra_Cliente_ed_Esecutore__c != null ? acr.WGC_Relazioni_Tra_Cliente_ed_Esecutore__c:'';

                    }
                }
            }

            System.debug('@@@ esecutore ' + JSON.serialize(esecutore));

            if(esecutore.cognome == null || esecutore.cf == null){

                // esecutore.esecutoreLegale = '';
                // esecutore.esecutoreProcuratore = '';
                // esecutore.esecutoreAltro = '';
                // esecutore.esecutoreTesto = '';
                // esecutore.cognome = '';
                // esecutore.nome = '';
                // esecutore.dataNascita = '';
                // esecutore.luogoNascita = '';
                // esecutore.provinciaNascita = '';
                // esecutore.paeseNascita = '';
                // esecutore.cittadinanza = '';
                // esecutore.sesso = '';
                // esecutore.indirizzoResidenza = '';
                // esecutore.cittaResidenza = '';
                // esecutore.capResidenza = '';
                // esecutore.provinciaResidenza = '';
                // esecutore.paeseResidenza = '';
                // esecutore.indirizzoDomicilio = '';
                // esecutore.cittaDomicilio = '';
                // esecutore.capDomicilio = '';
                // esecutore.provinciaDomicilio = '';
                // esecutore.paeseDomicilio = '';
                // esecutore.cf = '';
                // esecutore.tipoDocumento = '';
                // esecutore.numDocumento = '';
                // esecutore.luogo = '';
                // esecutore.dataEmissione = '';
                // esecutore.dataScadenza = '';
                // esecutore.pep = '';
                // esecutore.tae = '';
                // esecutore.professione = '';
            }
            return esecutore;
        }

    }

    public class RapportoMAV{
        @AuraEnabled
        public String natura;
        //@AuraEnabled
        //public String gestTesorerieAziendali;
        @AuraEnabled
        public String affidamentiConcessi;
        //@AuraEnabled
        //public String attivitaInvestimento;
        @AuraEnabled
        public String gestBasiAttive;
        @AuraEnabled
        public String smobCreditiCommItalia;
        @AuraEnabled
        public String gestStipendiDipendenti;
        @AuraEnabled
        public String gestFornitori;
        @AuraEnabled
        public String smobCreditiCommEstero;
        @AuraEnabled
        public String regolamTransEstero;
        @AuraEnabled
        public String origineImpresa;
        @AuraEnabled
        public String origineStraordinari;
        @AuraEnabled
        public String origineCessioni;
        @AuraEnabled
        public String origineAltro;
        @AuraEnabled
        public String origineTesto;
		@AuraEnabled
        public String naturaFactoring;
		@AuraEnabled
        public String naturaFinanziamenti;
		@AuraEnabled
        public String naturaServiziBancari;
		@AuraEnabled
        public String naturaCreditiErariali;
		@AuraEnabled
        public String cesCreditiFiscali;
		@AuraEnabled
        public String cesCreditiCommerciali;
		@AuraEnabled
        public String altroCreditiErariali;
		@AuraEnabled
        public String testoAltroCreditiErariali;

        public RapportoMAV(){
            this.natura = natura;
            //this.gestTesorerieAziendali = gestTesorerieAziendali;
            this.affidamentiConcessi = affidamentiConcessi;
            //this.attivitaInvestimento = attivitaInvestimento;
            this.gestBasiAttive = gestBasiAttive;
            this.smobCreditiCommItalia = smobCreditiCommItalia;
            this.gestStipendiDipendenti = gestStipendiDipendenti;
            this.gestFornitori = gestFornitori;
            this.smobCreditiCommEstero = smobCreditiCommEstero;
            this.regolamTransEstero = regolamTransEstero;
            this.origineImpresa = origineImpresa;
            this.origineStraordinari = origineStraordinari;
            this.origineCessioni = origineCessioni;
            this.origineAltro = origineAltro;
            this.origineTesto = origineTesto;
			this.naturaFinanziamenti = naturaFactoring;
			this.naturaFinanziamenti = naturaFinanziamenti;
			this.naturaServiziBancari = naturaServiziBancari;
			this.cesCreditiFiscali = cesCreditiFiscali;
			this.cesCreditiCommerciali = cesCreditiCommerciali;
			this.altroCreditiErariali = altroCreditiErariali;
			this.testoAltroCreditiErariali = testoAltroCreditiErariali;
        }

        //Costruttore corretto
        public RapportoMAV(AdeguataVerifica__c mav){
            //this.natura = mav.NaturaRapportoContinuativoFD__c != null ? mav.NaturaRapportoContinuativoFD__c : '';
            //this.gestTesorerieAziendali = mav.ScopoFD11__c == true ? 'S' : 'N';
            //this.affidamentiConcessi = mav.ScopoFD12__c == true ? 'S' : 'N';
            //this.attivitaInvestimento = mav.ScopoFD13__c == true ? 'S' : 'N';
            //this.gestBasiAttive = mav.ScopoFD14__c == true ? 'S' : 'N';
            //this.smobCreditiCommItalia = mav.ScopoFD15__c == true ? 'S' : 'N';
            //this.gestStipendiDipendenti = mav.ScopoFD16__c == true ? 'S' : 'N';
            //this.gestFornitori = mav.ScopoFD17__c == true ? 'S' : 'N';
            //this.smobCreditiCommEstero = mav.ScopoFD18__c == true ? 'S' : 'N';
            //this.regolamTransEstero = mav.ScopoFD19__c == true ? 'S' : 'N';
            this.origineImpresa = mav.OrigineFondi1__c == true ? 'S' : 'N';
            this.origineStraordinari = mav.OrigineFondi2__c == true ? 'S' : 'N';
            this.origineCessioni = mav.OrigineFondi3__c == true ? 'S' : 'N';
            this.origineAltro = mav.OrigineFondi4__c == true ? 'S' : 'N';
            this.origineTesto = mav.OrigineFondiAltro__c != null ? mav.OrigineFondiAltro__c : '';
			//nuovo MAV @Nonni
			this.naturaFactoring = mav.Natura_Factoring__c == true ? 'S' : 'N';
			this.naturaFinanziamenti = mav.Natura_Finanziamenti__c == true ? 'S' : 'N';
			this.naturaServiziBancari = mav.Natura_Servizi_Bancari__c == true ? 'S' : 'N';
			this.affidamentiConcessi = mav.Scopo_Factoring__c == '14'?  'S' : 'N';
			this.smobCreditiCommItalia =  mav.Scopo_Factoring__c == '18'?  'S' : 'N';
			this.smobCreditiCommEstero =  mav.Scopo_Factoring__c == '21'?  'S' : 'N';
			if (this.affidamentiConcessi == 'N')
				this.affidamentiConcessi = mav.Scopo_Finanziamenti__c == '14'?  'S' : 'N';
			if (this.affidamentiConcessi == 'N')
				this.affidamentiConcessi = mav.Scopo_Servizi_Bancari__c == '14'?  'S' : 'N';
			this.gestBasiAttive =  mav.Scopo_Servizi_Bancari__c == '16'?  'S' : 'N';
			this.gestStipendiDipendenti =  mav.Scopo_Servizi_Bancari__c == '19'?  'S' : 'N';
			this.gestFornitori =  mav.Scopo_Servizi_Bancari__c == '20'?  'S' : 'N';
			this.regolamTransEstero =  mav.Scopo_Servizi_Bancari__c == '22'?  'S' : 'N';
			this.cesCreditiFiscali = mav.Natura_Crediti_Erariali__c == 'Cessione di crediti fiscali'?  'S' : 'N';
			this.cesCreditiCommerciali = mav.Natura_Crediti_Erariali__c == 'Cessione di crediti commerciali'?  'S' : 'N';
			this.altroCreditiErariali = mav.Natura_Crediti_Erariali__c == 'Altro'?  'S' : 'N';
			this.testoAltroCreditiErariali = mav.Altro_Crediti_Erariali__c != null ? mav.Altro_Crediti_Erariali__c : '';
        }
    }

    public class DatiRichiestaServiziFinanziari{
        @AuraEnabled
        public DatiClienteRSF datiCliente;
        @AuraEnabled
        public String sae;
        @AuraEnabled
        public String numAddetti;
        @AuraEnabled
        public Decimal fatturato;
        @AuraEnabled
        public String factoring;
        @AuraEnabled
        public List<Cliente> clienti;
        @AuraEnabled
        public String mutuo;
        @AuraEnabled
        public Decimal importoMutuo;
        @AuraEnabled
        public String importoMutuoLettere;
        @AuraEnabled
        public String aperturaConto;
        @AuraEnabled
        public Decimal importoConto;
        @AuraEnabled
        public String importoContoLettere;
        @AuraEnabled
        public String dilazionePagamento;
        @AuraEnabled
        public String giorni;
        @AuraEnabled
        public String durata;
        @AuraEnabled
        public String cc;
        @AuraEnabled
        public String confirming;
        @AuraEnabled
        public String altro;
        @AuraEnabled
        public String testoAltro;
        @AuraEnabled
        public String luogoData;
        @AuraEnabled
        public String contrattoAssicurazione;
        //SM - Crediti Erariali - Aggiunto flag per le linee di Crediti Erariali
        @AuraEnabled
        public String cessioneCreditiIva;
        //SM - TEN: Corporate - Aggiungo flag per le linee di Corporate
        @AuraEnabled
        public String servizioIncassi;
        @AuraEnabled
        public String anticipoPortafoglioCommerciale;
        @AuraEnabled
        public String anticipoFatture;
        @AuraEnabled
        public String timeDeposit;
        //SM - TEN: Corporate Estero - Aggiungo flag per le linee di Corporate Estero
        @AuraEnabled
        public String anticipoExport;
        @AuraEnabled
        public String finanziamentoImport;
        @AuraEnabled
        public String finanziamentoExport;
        @AuraEnabled
        public String creditoDocumentarioImport;
        @AuraEnabled
        public String creditoDocumentarioExport;
        @AuraEnabled
        public String standByLetter;
        @AuraEnabled
        public String garanziaInternazionale;
        @AuraEnabled
        public String documentataIncasso;
        //A.M. Bonus Edilizi
        @AuraEnabled
        public String acquistoProSolutoCreditiImposta;


        public DatiRichiestaServiziFinanziari(){
            this.datiCliente = new DatiClienteRSF();
            this.sae = sae;
            this.numAddetti = numAddetti;
            this.fatturato = fatturato;
            this.factoring = factoring;
            this.clienti = new List<Cliente>();
            this.mutuo = mutuo;
            this.importoMutuo = importoMutuo;
            this.importoMutuoLettere = importoMutuoLettere;
            this.aperturaConto = aperturaConto;
            this.importoConto = importoConto;
            this.importoContoLettere = importoContoLettere;
            this.dilazionePagamento = dilazionePagamento;
            this.giorni = giorni;
            this.durata = durata;
            this.cc = cc;
            this.confirming = confirming;
            this.altro = altro;
            this.testoAltro = testoAltro;
            this.luogoData = '';
            this.contrattoAssicurazione = contrattoAssicurazione;
            //A.M. Bonus Edilizi
            this.acquistoProSolutoCreditiImposta = acquistoProSolutoCreditiImposta;
        }

        public DatiRichiestaServiziFinanziari(Opportunity opp, Account account, List<Linea__c> linee, List<JoinLineaDebitore__c> listaAttori ){

            DatiMutuo m = checkFamigliaProd(linee);
            DatiContoCorrente cc = checkMutuo(linee);
            DatiPlafond dp = checkPlafond(linee);

            System.debug('@@@ listaAttori ' + JSON.serialize(listaAttori));
            this.datiCliente = new DatiClienteRSF(account);
            this.sae = account.SAE__c != null ? account.SAE__c : '';
            this.numAddetti = account.WGC_Numero_dipendenti__c != null ? String.valueOf(account.WGC_Numero_dipendenti__c) : '';
            System.debug('@@@ account.Fatturato__c ' + account.Fatturato__c);
            this.fatturato = account.Fatturato__c != null ? account.Fatturato__c * 1000 : null;
            // this.factoring = opp.HasFactoringDiretto__c == true ? 'S' : 'N';
            this.clienti = new Cliente().generaClienti(listaAttori); //opp.HasFactoringDiretto__c == true ? new Cliente().generaClienti(listaAttori) : new List<Cliente>();
            this.mutuo = m.mutuo;
            this.importoMutuo = m.importoMutuo;
            this.importoMutuoLettere = m.importoMutuoLettere;
            this.aperturaConto = cc.aperturaConto;
            this.importoConto = cc.importoConto;
            this.importoContoLettere = cc.importoContoLettere;
            this.dilazionePagamento = dp.dilazionePagamento;
            this.giorni = dp.giorni;
            this.durata = dp.durata;
            this.cc = cc.cc;
            this.confirming = opp.HasConfirming__c == true ? 'S' : 'N';
            this.altro = 'N';
            this.testoAltro = '';
            this.luogoData = '';
            // this.cessioneCreditiIva = '';
            //SM - TEN: Corporate - metto di default i flag a N
            this.servizioIncassi = 'N';
            this.anticipoPortafoglioCommerciale = 'N';
            this.anticipoFatture = 'N';
            this.timeDeposit = 'N';
            this.anticipoExport = 'N';
            this.finanziamentoImport = 'N';
            this.finanziamentoExport = 'N';
            this.creditoDocumentarioImport = 'N';
            this.creditoDocumentarioExport = 'N';
            this.standByLetter = 'N';
            this.garanziaInternazionale = 'N';
            this.documentataIncasso = 'N';
            //A.M. Bonus Edilizi
            this.acquistoProSolutoCreditiImposta = 'N';

            String checkFactCed = 'N';
            for(Linea__c linea : linee){
                if(linea.Prodotto__r.WGC_Area__c == 'Factoring - Cedente'){
                    checkFactCed = 'S';
                    break;
                }
            }
            this.factoring = checkFactCed;

            //A.M. Bonus Edilizi
            String checkBonusEdil = 'N';
            for(Linea__c linea : linee){
                if(linea.Prodotto__r.WGC_Area__c == 'Bonus Edilizi'){
                    checkBonusEdil = 'S';
                    break;
                }
            }
            this.acquistoProSolutoCreditiImposta = checkBonusEdil;
            
            
            Boolean checkMutuoCPI = false;
            for(Linea__c linea : linee){
                if(linea.WGC_Polizza_CPI__c){
                    checkMutuoCPI = true;
                    break;
                }
            }
            this.contrattoAssicurazione = checkMutuoCPI == true ? 'S' : 'N';
            
            Boolean cessioneCrediti = false;
            for(Linea__c linea : linee){
                if(linea.Prodotto__r.WGC_Area__c == 'Factoring - Fiscale'){
                    cessioneCrediti = true;
                    break;
                }
            }
            this.cessioneCreditiIva = cessioneCrediti ? 'S' : 'N';

            //Condizione
            if(linee.size() == 1 && linee[0].Prodotto__r.CodiceProdotto__c == 'PCACC'){
                this.factoring = 'S';
                this.confirming = 'N';
            }

            //SM - TEN: Corporate - popolo i flag in base ai prodotti di Corporate
            for(Linea__c linea : linee){
                if(linea.Prodotto__r.CodiceUnivoco__c == 'SBF' || linea.Prodotto__r.CodiceUnivoco__c == 'GestionePTF')
                    this.servizioIncassi = 'S';
                
                if(linea.Prodotto__r.CodiceUnivoco__c == 'SBF')
                    this.anticipoPortafoglioCommerciale = 'S';
                
                if(linea.Prodotto__r.CodiceUnivoco__c == 'AnticipoFatture')
                    this.anticipoFatture = 'S';

                if(linea.Prodotto__r.CodiceUnivoco__c == 'AnticipoExport')
                    this.anticipoExport = 'S';
                
                if(linea.Prodotto__r.CodiceUnivoco__c == 'FinanziamentoImport')
                    this.finanziamentoImport = 'S';

                if(linea.Prodotto__r.CodiceUnivoco__c == 'FinanziamentoExport')
                    this.finanziamentoExport = 'S';

                if(linea.Prodotto__r.CodiceUnivoco__c == 'CreditoDocumentarioImport')
                    this.creditoDocumentarioImport = 'S';

                if(linea.Prodotto__r.CodiceUnivoco__c == 'CreditoDocumentarioExport')
                    this.creditoDocumentarioExport = 'S';

                if(linea.Prodotto__r.CodiceUnivoco__c == 'StandByLetter')
                    this.standByLetter = 'S';

                if(linea.Prodotto__r.CodiceUnivoco__c == 'GaranziaInternazionaleLT' || linea.Prodotto__r.CodiceUnivoco__c == 'GaranziaInternazionaleBT')
                    this.garanziaInternazionale = 'S';

                if(linea.Prodotto__r.CodiceUnivoco__c == 'DocumentateIncasso')
                    this.documentataIncasso = 'S';
            }
        }
    }

    @AuraEnabled
    public static DatiContoCorrente checkMutuo(List<Linea__c> linee){
        DatiContoCorrente cc = new DatiContoCorrente();
        Linea__c lineaToCheck;
        Decimal importoContoTot = 0;

        for(Linea__c item : linee){
            if(item.Prodotto__r.Name == 'Fido' && item.Importo__c != null && item.Importo__c != 0/*&& !String.isBlank(item.LineaATDSingola__c)*/){
                importoContoTot += item.Importo__c;
                continue;
            }
            
            if(item.Prodotto__r.CodiceUnivoco__c.startsWith('IfisImpresa')){
                lineaToCheck = item;
                importoContoTot += item.Importo__c != null ? item.Importo__c : 0;
            }
        }

        if(lineaToCheck != null){
            cc.cc = 'S';
            cc.aperturaConto = importoContoTot > 0 ? 'S' : 'N';
            cc.importoConto = importoContoTot > 0 ? importoContoTot : null; //lineaToCheck.Importo__c != null ? lineaToCheck.Importo__c : null ;
            cc.importoContoLettere = importoContoTot > 0 ? UtilNumeri.convertiInLettere(Double.valueOf(importoContoTot)) : '';
            // cc.dilazionePagamento = lineaToCheck.DurataDilazione__c != null ? String.valueOf(lineaToCheck.DurataDilazione__c) : '';
            // cc.giorni = lineaToCheck.Durata__c != null ? String.valueOf(lineaToCheck.Durata__c * 30) : '';
            // cc.durata = lineaToCheck.Durata__c != null ? String.valueOf(lineaToCheck.Durata__c) : '';
        }
        else{
            cc.cc = 'N';
            cc.aperturaConto = 'N';
            cc.importoConto = null;
            cc.importoContoLettere = '';
            // cc.dilazionePagamento = 'N';
            // cc.giorni = '';
            // cc.durata = '';
        }

        return cc;
    }

    @AuraEnabled
    public static DatiMutuo checkFamigliaProd(List<Linea__c> linee){
        DatiMutuo m = new DatiMutuo();
        Linea__c lineaToCheck;
        //A.M. Gestione Mutuo Veneto Sviluppo (dichiarazione variabili di appoggio per somma importi due linee di muto)
        Boolean VenetoSviluppo = false;
        Decimal impVsTotale = 0;
        Decimal impVsParziale = 0;

        //A.M. Aggiungo prodotto PCMDL e PC13E
        //A.M. 21/09/2020 - Generalizzata presenza Mutuo per gestione RSF
        for(Linea__c item : linee){
            //if(item.Prodotto__r.CodiceProdotto__c == 'PCMCC' || 
            //    item.Prodotto__r.CodiceProdotto__c == 'PCASS' ||
            //    item.Prodotto__r.CodiceProdotto__c == 'PCMPR' ||
            //    item.Prodotto__r.CodiceProdotto__c == 'PCNSA' ||
            //   item.Prodotto__r.CodiceProdotto__c == 'PCMDL' ||
            //    item.Prodotto__r.CodiceProdotto__c == 'PC13E' 
            if(item.Prodotto__r.Applicazione__c == '21C'){
                lineaToCheck = item;
            }
            //A.M. Gestione Mutuo Veneto Sviluppo
            else if (item.Prodotto__r.Applicazione__c == '06C'){
                lineaToCheck = item;
                VenetoSviluppo = true;
                Decimal impVsLinea = lineaToCheck.Importo__c != null ? lineaToCheck.Importo__c : 0;
                impVsTotale = impVsLinea + impVsParziale;
                impVsParziale = impVsTotale;
            }
        }

        if(lineaToCheck != null){
            m.mutuo = 'S';
            if (VenetoSviluppo){
                m.importoMutuo = impVsTotale;         
                m.importoMutuoLettere = impVsTotale != null ? UtilNumeri.convertiInLettere(Double.valueOf(impVsTotale)) : ''; 
            } else {
                m.importoMutuo = lineaToCheck.Importo__c != null ? lineaToCheck.Importo__c : null;
                m.importoMutuoLettere = lineaToCheck.Importo__c != null ? UtilNumeri.convertiInLettere(Double.valueOf(lineaToCheck.Importo__c)) : '';  
            }
        }
        else{
            m.mutuo = 'N';
            m.importoMutuo = null;
            m.importoMutuoLettere = '';
        }

        return m;
    }

    public class DatiPlafond{
        @AuraEnabled
        public String dilazionePagamento;
        @AuraEnabled
        public String giorni;
        @AuraEnabled
        public String durata;

        // cc.dilazionePagamento = lineaToCheck.DurataDilazione__c != null ? String.valueOf(lineaToCheck.DurataDilazione__c) : '';
            // cc.giorni = lineaToCheck.Durata__c != null ? String.valueOf(lineaToCheck.Durata__c * 30) : '';
            // cc.durata = lineaToCheck.Durata__c != null ? String.valueOf(lineaToCheck.Durata__c) : '';

        public DatiPlafond(){
            this.dilazionePagamento = 'N';
            this.giorni = '';
            this.durata = '';
        }
    }

    @AuraEnabled
    public static DatiPlafond checkPlafond(List<Linea__c> linee){
        DatiPlafond dati = new DatiPlafond();
        Linea__c lineaToCheck;

        if(linee.size() > 0){
            for(Linea__c linea : linee){
                if(linea.Prodotto__r.CodiceUnivoco__c == 'ConProroga'){
                    lineaToCheck = linea;
                }
            }

            if(lineaToCheck != null){
                dati.dilazionePagamento = 'S'; //String.valueOf(lineaToCheck.DurataDilazione__c);
                dati.giorni = lineaToCheck.DurataDilazione__c != null ? String.valueOf(lineaToCheck.DurataDilazione__c) : '';
                dati.durata = lineaToCheck.DurataMaxCredito__c != null ? String.valueOf(lineaToCheck.DurataMaxCredito__c) : '';
            }
        }

        System.debug('@@@ dati ' + dati);
        return dati;
    }

    public class DatiContoCorrente{
        @AuraEnabled
        public String aperturaConto;
        @AuraEnabled
        public Decimal importoConto;
        @AuraEnabled
        public String importoContoLettere;
        @AuraEnabled
        public String dilazionePagamento;
        @AuraEnabled
        public String giorni;
        @AuraEnabled
        public String durata;
        @AuraEnabled
        public String cc;

        public DatiContoCorrente(){
            this.aperturaConto = aperturaConto;
            this.importoConto = importoConto;
            this.importoContoLettere = importoContoLettere;
            this.dilazionePagamento = dilazionePagamento;
            this.giorni = giorni;
            this.durata = durata;
            this.cc = cc;
        }
    }

    public class DatiMutuo{
        @AuraEnabled
        public String mutuo;
        @AuraEnabled
        public Decimal importoMutuo;
        @AuraEnabled
        public String importoMutuoLettere;

        public DatiMutuo(){
            this.mutuo = mutuo;
            this.importoMutuo = importoMutuo;
            this.importoMutuoLettere = importoMutuoLettere;
        }
    }

    public class DatiClienteRSF extends DatiCliente{
        @AuraEnabled
        public String email;
        @AuraEnabled
        public String paeseLegale;
        @AuraEnabled
        public String paeseAmm;

        public DatiClienteRSF(){
            this.email = email;
        }

        public DatiClienteRSF(Account account){
            //Compilazione corretta indirizzi
            account.ShippingStreet = UtilAnagrafiche.getIndirizzoCompleto(
                account.ShippingStreetType__c,
                account.ShippingStreetName__c,
                account.ShippingStreetNumber__c
            );

            account.BillingStreet = UtilAnagrafiche.getIndirizzoCompleto(
                account.BillingStreetType__c,
                account.BillingStreetName__c,
                account.BillingStreetNumber__c
            );

            if(account.ShippingStreet == account.BillingStreet && 
                account.BillingCity == account.ShippingCity && 
                account.BillingPostalCode == account.ShippingPostalCode && 
                account.BillingState == account.ShippingState){

                account.ShippingStreet = '';
                account.ShippingCity = '';
                account.ShippingPostalCode = '';
                account.ShippingState = '';
            }

            System.debug('@@@ account in daticliente ' + JSON.serialize(account));
            this.denominazione = account.Name != null ? account.Name : '';
            this.pIva = account.PIVA__c != null ? account.PIVA__c  : '';
            this.cf = account.CF__c != null ? account.CF__c : '';
            this.cciaa = account.ProvinciaCCIAA__c != null ? account.ProvinciaCCIAA__c : '';
            this.rea = account.REA__c != null ? account.REA__c : '';
            this.indirizzoLegale = account.BillingStreet != null ? account.BillingStreet : '';
            this.cittaLegale = account.BillingCity != null ? account.BillingCity : '';
            this.capLegale = account.BillingPostalCode != null ? account.BillingPostalCode : '';
            this.provinciaLegale = account.BillingState != null ? account.BillingState : '';
            this.indirizzoAmm = account.ShippingStreet != null ? account.ShippingStreet : '';
            this.cittaAmm = account.ShippingCity != null ? account.ShippingCity : '';
            this.capAmm = account.ShippingPostalCode != null ? account.ShippingPostalCode : '';
            this.provinciaAmm = account.ShippingState != null ? account.ShippingState : '';
            this.telefono = account.TelefonoPrefisso__c	!= null && account.Phone != null ? account.TelefonoPrefisso__c + '' + account.Phone : '';
            this.fax = account.Fax != null ? account.Fax : '';
            this.email = account.Email__c != null ? account.Email__c : '';
            this.paeseLegale = account.BillingCountry != null ? account.BillingCountry : '';
            this.paeseAmm = account.ShippingCountry != null ? account.ShippingCountry : '';

        }
    }

    public class Cliente{
        @AuraEnabled
        public String denominazione;
        @AuraEnabled
        public String cf;
        @AuraEnabled
        public String sede;
        @AuraEnabled
        public Decimal fatturato;
        @AuraEnabled
        public String durata;
        @AuraEnabled
        public Decimal plafond;

        public Cliente(){
            this.denominazione = '';
            this.cf = '';
            this.sede = '';
            this.fatturato = 0;
            this.durata = '';
            this.plafond = 0;
        }

        public Cliente(JoinLineaDebitore__c attore){
            this.denominazione = attore.Debitore__r.Account__r.Name != null ? attore.Debitore__r.Account__r.Name : '';
            this.cf = attore.Debitore__r.Account__r.CF__c != null ? attore.Debitore__r.Account__r.CF__c : '';
            this.sede = String.valueOf(attore.Debitore__r.Account__r.BillingStreet) + ' ' + String.valueOf(attore.Debitore__r.Account__r.BillingCity) + ' ' + String.valueOf(attore.Debitore__r.Account__r.BillingState);
            this.fatturato = attore.Debitore__r.Fatturato__c != null ? attore.Debitore__r.Fatturato__c : null;
            this.durata = attore.Debitore__r.DurataNominale__c != null ? String.valueOf(attore.Debitore__r.DurataNominale__c) : '';
            this.plafond = attore.Debitore__r.Plafond__c != null ? attore.Debitore__r.Plafond__c : null;
        }

        public List<Cliente> generaClienti(List<JoinLineaDebitore__c> attori){
            List<Cliente> clienti = new List<Cliente>();
            for(JoinLineaDebitore__c item : attori){
                //SM - Crediti Erariali - Aggiunta Condizione per non aggiungere Agenzia delle entrate come debitore
                if(item.Debitore__r.Account__c != null && item.Debitore__r.RecordType.DeveloperName == 'Debitore' && item.Debitore__r.Account__c != WGC_PC_CartController.idAde){
                    Cliente c = new Cliente(item);
                    System.debug('@@@ Debitore ' + JSON.serialize(c));
                    clienti.add(c);
                }
            }

            // if(clienti.size() == 0){
            //     Cliente c = new Cliente();
            //     clienti.add(c);
            // }

            return clienti;
        }
    }

    public class DatiTecnicheComunicazione{
        @AuraEnabled
        public DatiClienteMTC datiCliente;
        @AuraEnabled
        public String pec;
        @AuraEnabled
        public String sedeLegale;
        @AuraEnabled
        public String sedeAmm;
        @AuraEnabled
        public String altro;
        @AuraEnabled
        public String testoAltro;
        @AuraEnabled
        public String indirizzo;
        @AuraEnabled
        public String citta;
        @AuraEnabled
        public String cap;
        @AuraEnabled
        public String provincia;
        @AuraEnabled
        public String telefono;
        @AuraEnabled
        public String fax;
        @AuraEnabled
        public String email;
        @AuraEnabled
        public String pecFattura;
        @AuraEnabled
        public String codiceDestinatario;        
        @AuraEnabled
        public String luogoData;
        @AuraEnabled
        public String paese;

        public DatiTecnicheComunicazione(){
            this.datiCliente = new DatiClienteMTC();
            this.pec = pec;
            this.sedeLegale = sedeLegale;
            this.sedeAmm = sedeAmm;
            this.altro = altro;
            this.testoAltro = testoAltro;
            this.indirizzo = indirizzo;
            this.citta = citta;
            this.cap = cap;
            this.provincia = provincia;
            this.telefono = telefono;
            this.fax = fax;
            this.email = email;
            this.pecFattura = pecFattura;
            this.codiceDestinatario = codiceDestinatario;
            this.paese = paese;
            this.luogoData = '';
        }

        public DatiTecnicheComunicazione(Account account, AdeguataVerifica__c mav){
            System.debug('@@@ account ' + JSON.serialize(account));
            String city = account.ShippingCity;
            String postalCode = account.ShippingPostalCode;
            String state = account.ShippingState;

            this.datiCliente = new DatiClienteMTC(account);
            this.pec = account.EmailPEC__c != null ? account.EmailPEC__c : '';
            this.sedeLegale = account.IndirizzoPerInvioCorrispondenza__c == 'Sede legale' ? 'S' : 'N';
            this.sedeAmm = account.IndirizzoPerInvioCorrispondenza__c.contains('amministrativa') ? 'S' : 'N';
            this.altro = account.IndirizzoPerInvioCorrispondenza__c == 'Altro' ? 'S' : 'N';
            this.testoAltro = '';
            this.indirizzo = account.IndirizzoPerInvioCorrispondenza__c == 'Sede legale' ? account.BillingStreetType__c + ' ' + account.BillingStreetName__c + ' ' + account.BillingStreetNumber__c : account.IndirizzoPerInvioCorrispondenza__c.contains('amministrativa') ? account.ShippingStreetType__c + ' ' + account.ShippingStreetName__c + ' ' + account.ShippingStreetNumber__c : (mav.CorrispondenzaStreetType__c != null && mav.CorrispondenzaStreetName__c != null && mav.CorrispondenzaStreetNumber__c != null)  ? mav.CorrispondenzaStreetType__c + ' ' + mav.CorrispondenzaStreetName__c + ' ' + mav.CorrispondenzaStreetNumber__c : ' ' ;
            this.citta = account.IndirizzoPerInvioCorrispondenza__c == 'Sede legale' ? account.BillingCity : account.IndirizzoPerInvioCorrispondenza__c.contains('amministrativa') ? city : mav.CorrispondenzaCity__c != null ? mav.CorrispondenzaCity__c : '' ;
            this.cap = account.IndirizzoPerInvioCorrispondenza__c == 'Sede legale' ? account.BillingPostalCode : account.IndirizzoPerInvioCorrispondenza__c.contains('amministrativa') ? postalCode : mav.CorrispondenzaCAP__c != null ? mav.CorrispondenzaCAP__c : '' ;
            this.provincia = account.IndirizzoPerInvioCorrispondenza__c == 'Sede legale' ? account.BillingState : account.IndirizzoPerInvioCorrispondenza__c.contains('amministrativa') ? state : mav.CorrispondenzaState__c != null ? mav.CorrispondenzaState__c : ''  ;
            this.telefono = account.Phone != null && account.TelefonoPrefisso__c != null ? account.TelefonoPrefisso__c + '' + account.Phone : '';
            this.fax = account.Fax != null ? account.Fax : '';
            this.email = account.Email__c != null ? account.Email__c : '';
            this.pecFattura = account.EmailPECFatturaElettronica__c != null ? account.EmailPECFatturaElettronica__c : '';
            this.codiceDestinatario = account.CodiceDestinatario__c != null ? account.CodiceDestinatario__c : '';
            this.paese = '';
            this.luogoData = '';

            System.debug('@@@ this.citta ' + this.citta);


        }
    }

    public class DatiClienteMTC extends DatiCliente{
        @AuraEnabled
        public String email;
        @AuraEnabled
        public String sia;
        @AuraEnabled
        public String paeseLegale;
        @AuraEnabled
        public String paeseAmm;

        public DatiClienteMTC(){
            this.email = email;
            this.sia = sia;
        }

        /*
        public DatiClienteMTC(Sobject obj, Sobject parent, String objectName){
            this.email = email;
            this.sia = sia;
        }
        */

        public DatiClienteMTC(Account account){
            account.ShippingStreet = UtilAnagrafiche.getIndirizzoCompleto(
                account.ShippingStreetType__c,
                account.ShippingStreetName__c,
                account.ShippingStreetNumber__c
            );

            account.BillingStreet = UtilAnagrafiche.getIndirizzoCompleto(
                account.BillingStreetType__c,
                account.BillingStreetName__c,
                account.BillingStreetNumber__c
            );

            if(account.ShippingStreet == account.BillingStreet && 
                account.BillingCity == account.ShippingCity && 
                account.BillingPostalCode == account.ShippingPostalCode && 
                account.BillingState == account.ShippingState){

                account.ShippingStreet = '';
                account.ShippingCity = '';
                account.ShippingPostalCode = '';
                account.ShippingState = '';
            }
            
            this.denominazione = account.Name != null ? account.Name : '';
            this.pIva = account.PIVA__c != null ? account.PIVA__c : '';
            this.cf = account.CF__c != null ? account.CF__c : '';
            this.cciaa = account.ProvinciaCCIAA__c != null ? account.ProvinciaCCIAA__c : '';
            this.rea = account.REA__c != null ? account.REA__c : '';
            this.indirizzoLegale = account.BillingStreet != null ? account.BillingStreet : '';
            this.cittaLegale = account.BillingCity != null ? account.BillingCity : '';
            this.capLegale = account.BillingPostalCode != null ? account.BillingPostalCode : '';
            this.provinciaLegale = account.BillingState != null ? account.BillingState : '';
            this.indirizzoAmm = account.ShippingStreet != null ? account.ShippingStreet : '';
            this.cittaAmm = account.ShippingCity != null ? account.ShippingCity : '';
            this.capAmm = account.ShippingPostalCode != null ? account.ShippingPostalCode : '';
            this.provinciaAmm = account.ShippingState != null ? account.ShippingState : '';
            this.telefono = account.TelefonoPrefisso__c != null && account.Phone != null ? account.TelefonoPrefisso__c + '' + account.Phone : '';
            this.fax = account.Fax != null ? account.Fax : '';
            this.email = account.Email__c != null ? account.Email__c : '';
            this.sia = account.SIA__c != null ? account.SIA__c : '';
            this.paeseLegale = account.BillingCountry != null ? account.BillingCountry : '';
            this.paeseAmm = account.ShippingCountry != null ?  account.ShippingCountry : '';
        }
    }

    public class outputDoc11 extends WsRestInput.CommonResponse{
        @AuraEnabled
        public String payload;

        public outputDoc11(){
            this.payload = payload;
        }

        public override Boolean isCorrect(){
            return payload != null;
        }
    }

    public class OutputPayload{
        @AuraEnabled
        public String idDocumento;
        @AuraEnabled
        public String linkDocumento;

        public OutputPayload(){
            this.idDocumento = idDocumento;
            this.linkDocumento = linkDocumento;
        }
    }

    @AuraEnabled
    public static String WGC_VerifyStatusDoc(String recordId){

        WrapperResponse responseDoc10 = new WrapperResponse();
        Boolean checkPresenti = true;

        try{
            //RecordId deve essere opportunity
            responseDoc10 = docCheckList(recordId);
            if(responseDoc10.data.isEmpty()){
                return 'NO RESPONSE FROM DOC 10';
            }
            else{
                OutputDoc10 output = (OutputDoc10) responseDoc10.data[0];

                Set<String> idNotes = new Set<String>();

                if(output.payload != null ){
                    for(ResultDoc10 singleDoc : output.payload.results){
                        String idU = recordId + '_' + singleDoc.index_value;
                        idNotes.add(idU);
                    }

                    System.debug('@@@ idNotes ' + JSON.serialize(idNotes));

                    List<WGC_Nota_Documento__c> note = new List<WGC_Nota_Documento__c>();

                    note = [SELECT Id, Id_Univoco__c FROM WGC_Nota_Documento__c WHERE Id_Univoco__c IN : idNotes];

                    System.debug('@@@ notes ' + JSON.serialize(note));

                    if(note.size() > 0){
                        for(ResultDoc10 doc : output.payload.results){
                            for(WGC_Nota_Documento__c nota : note){
                                String unique = recordId + '_' + doc.index_value;
                                if(doc.required && doc.missing){
                                    if(nota.Id_univoco__c != unique){
                                        checkPresenti = false;
                                        break;
                                    }
                                }

                                if(!checkPresenti){
                                    break;
                                }
                            }
                        }
                    }
                    else{
                        for(ResultDoc10 doc : output.payload.results){
                            if(doc.required && doc.missing){
                                checkPresenti = false;
                                break;
                            }
                        }
                    }

                    return checkPresenti == false ? 'KO' : 'OK';
                }
                else{
                    return 'KO';
                }
            }
        }
        catch(Exception e){
            return 'Eccezione ' + e.getMessage() + ' - ' + e.getLineNumber() + ' - ' + e.getStackTraceString();
        }
    }

    public class WrapperRicercaMAV{
        @AuraEnabled
        public String base64File;
        @AuraEnabled
        public String nomeFile;
        @AuraEnabled
        public String mime;
        @AuraEnabled
        public String ndgAcc;
        @AuraEnabled
        public String oppId;
        @AuraEnabled
        public String nominativo;
        @AuraEnabled
        public String datarif;
        @AuraEnabled
        public String datastato;

        public WrapperRicercaMAV(){
            this.base64File = base64File;
            this.nomeFile = nomeFile;
            this.mime = mime;
            this.ndgAcc = ndgAcc;
            this.oppId = oppId;
            this.nominativo = nominativo;
            this.datarif = datarif;
            this.datastato = datastato;
        }
    }

    @AuraEnabled
    @Future(callout=true)
    public static void ricercaMAV(String ndg, String optyId){
        WrapperResponse response = new WrapperResponse();
        String datastato;
        String dataprod;
        String datarif;
        String nominativo;

        try{

            //Recupero Metadati
            List<WGC_Metadati_Documentale__mdt> listaMetadati = new List<WGC_Metadati_Documentale__mdt>();
            listaMetadati = [SELECT Id, MasterLabel, DeveloperName, Istituto__c, Documento__c, Sottoclasse__c FROM WGC_Metadati_Documentale__mdt WHERE DeveloperName = 'Modulo_adeguata_verifica' ]; 
            System.debug('@@@ listaMetadati ' + JSON.serialize(listaMetadati));

            PayloadRicercaMultipla payload = new PayloadRicercaMultipla();

            IndiceRicerca indiceNDGMAV = new IndiceRicerca('NDG', '=', ndg);
            IndiceRicerca indiceCodDoc = new IndiceRicerca('CODICEDOC', '=', listaMetadati.get(0).Documento__c);
            String codDoc = listaMetadati.get(0).Documento__c;

            DatiRicercaMultipla datiR = new DatiRicercaMultipla();
            datiR.datiDocumento.indice.add(indiceNDGMAV);
            datiR.datiDocumento.indice.add(indiceCodDoc);

            payload.datiRicerca.add(datiR);
            System.debug('@@@ payload.datiRicerca ' + JSON.serializePretty(payload));

            WsRestInput input = new WsRestInput(payload);

            DatiRicercaMultiplaEsito resp = (DatiRicercaMultiplaEsito) WGC_WsRest.ricercaMultiplaDocumenti(payload);
            System.debug('@@@ test resp ');
            System.debug('@@@ resp ' + JSON.serialize(resp));

            WrapperMetaDoc docMAV = new WrapperMetaDoc();

            if(resp.payload != null){
                if(resp.payload.datiRicercaEsito != null){
                    ElementiRicerca mav = resp.payload.datiRicercaEsito[0].elemento[0];
                    System.debug('@@@ mav ' + JSON.serialize(mav));
                    docMAV.Id = mav.id;
                    for(OutputIndice indice : mav.indice){
                        if(indice.nome == 'Name'){
                            docMAV.nomeFile = indice.valore;
                        }
                        if(indice.nome == 'MimeType'){
                            docMAV.mime = indice.valore;
                        }
                        if(indice.nome == 'DATASTATO'){
                            datastato = indice.valore;
                        }
                        if(indice.nome == 'DATARIF'){
                            datarif = indice.valore;
                        }
                        if(indice.nome == 'DATAPROD'){
                            dataprod = indice.valore;
                        }
                        if(indice.nome == 'NOMINATIVO'){
                            nominativo = indice.valore;
                        }
                    }
                }
            }

            DocDownload dd = new DocDownload();
            dd.id = docMAV.id;
            dd.title = docMav.nomeFile;
            dd.codId = '';

            String docStr = JSON.serialize(dd);
            WrapperResponse responseDownload = doc08('', docStr);

            System.debug('@@@ responseDownload mav ' + JSON.serialize(responseDownload));

            System.debug('@@@ bs64 ' + String.valueOf(responseDownload.data[0]));

            String mavToUpload;
            if(responseDownload.success){
                mavToUpload = String.valueOf(responseDownload.data[0]);
                //mavToUpload = String.valueOf(responseDownload.data[0]);
                //mavToUpload = Blob.valueOf(responseDownload.data[0]);
            }
            else{
                response.message = 'Errore durante il download del mav';
                response.success = false;
                
                System.debug('@@@ response.message ' + response.message);
                return;
            }

            System.debug('@@@ download ' + mavToUpload);
            System.debug('@@@ docMAV ' + JSON.serialize(docMAV));

            WrapperRicercaMAV wrapperUpload = new WrapperRicercaMAV();
            wrapperUpload.base64File = mavToUpload; //EncodingUtil.base64Encode(mavToUpload);
            wrapperUpload.nomeFile = docMav.nomeFile;
            wrapperUpload.mime = docMav.mime;
            wrapperUpload.ndgAcc = ndg;
            wrapperUpload.oppId = optyId;
            wrapperUpload.nominativo = nominativo;
            wrapperUpload.datarif = datarif;
            wrapperUpload.datastato = datastato;

            System.debug('@@@ wrapperRicerca ' + JSON.serialize(wrapperUpload));

            //WGC_FileUploaderController.WrapperResponse rispostaUploadMAV = WGC_FileUploaderController.uploadDocMultipart_Direct(mavToUpload, docMav.nomeFile, docMAV.mime, ndg, optyId, nominativo, datarif, datastato);
            WGC_FileUploaderController.WrapperResponse rispostaUploadMAV = WGC_FileUploaderController.uploadDocMultipart_Direct(wrapperUpload);

            System.debug('@@@ rispostaUploadMAV ' + JSON.serialize(rispostaUploadMAV));


            response.data.add(wrapperUpload);
            response.message = 'OK';
            
        }
        catch(Exception e){
            System.debug('@@@ exception ' + e.getMessage() + ' - ' + e.getLineNumber());
            response.message = e.getMessage();
            response.success = false;

            //System.debug('@@@ exception')
        }

        return;
    }

    @AuraEnabled
    public static WrapperResponse ricercaMultiplaDoc(String opportunityId){
        WrapperResponse response = new WrapperResponse();

        try{
            PayloadRicercaMultipla payload = new PayloadRicercaMultipla();

            Opportunity opp = [SELECT Id, Name, StageName, Account.NDGGruppo__c FROM Opportunity WHERE Id =: opportunityId];

            IndiceRicerca indiceIDCFLOW = new IndiceRicerca('IDCFLOW', '=', opp.Id);

            // payload.datiRicerca = new List<DatiRicercaMultipla>(); 
            // payload.datiRicerca[0].datiDocumento.indice.add(indiceIDCFLOW);

            DatiRicercaMultipla datiR = new DatiRicercaMultipla();
            datiR.datiDocumento.indice.add(indiceIDCFLOW);

            payload.datiRicerca.add(datiR);

            WsRestInput input = new WsRestInput(payload);

            System.debug('@@@ input json ' + input.toJSONString());

			// HttpRequest reqMP = new HttpRequest();
			// reqMP.setHeader('X-LAGKey', EndpointServizi__c.getInstance('settings').LAGKey__c);
			// reqMP.setHeader('Content-Type', 'application/json'); 
			// reqMP.setEndpoint('https://uatservices.bancaifis.it/arch/lag/proxy/documentmanager/ricercadocumenti/multisearchdocument');
			// reqMP.setMethod('POST');
            // //{"headers": {"headers": {"user_header": {"id": "user_header","archUser": {"userRoles": [],"userId": "ext.crm","userGroups": [],"surname": "TEN","name": "Admin","actualUserId": "ext.crm"}},"tech_header": {"timeStamp": 1554106391223,"id": "tech_header","correlationId": "f1c3a4f3-e1dd-7328-7413-e4a44db81320","channel": "B2B","applicationCode": "CRM"}}},  "payload": {    "codiceIstituto3N": 881,    "idApplicazioneChiamante": "CRM",    "idSessioneChiamante": "",    "lingua": "",    "idOperazione": "",    "datiRicerca": [      {        "etichetta": "RICERCA-1",        "matricola": "YH02741",        "ruolo": "I340",        "datiDocumento": { "classeOggetto": "DOCUMENTI_CLIENTE", "indice": [   {     "nome": "CARTELLANV",     "operatore": "=",     "valore": "TEST"   } ], "cartella": "", "sottoCartella": "", "pagina": {   "indice": "1",   "dimensione": "999" }, "ordine": "DATECREATED DESC", "righeMassime": "999"        }      }    ]  }}
            // reqMP.setBody(input.toJSONString());
			// reqMP.setTimeout(120000);
            // HttpResponse resMP = new Http().send(reqMP);

            // DatiRicercaMultiplaEsito resp = (DatiRicercaMultiplaEsito)JSON.deserialize(resMP.getBody(), DatiRicercaMultiplaEsito.Class);

            DatiRicercaMultiplaEsito resp = (DatiRicercaMultiplaEsito) WGC_WsRest.ricercaMultiplaDocumenti(payload);

            System.debug('@@@ resp ' + JSON.serialize(resp));

            Set<String> idDocumentiNV = new Set<String>();

            List<WrapperMetaDoc> listaDocNV = new List<WrapperMetaDoc>();

            for(EsitoRicerca esito : resp.payload.datiRicercaEsito){
                System.debug('@@@ esito ' + JSON.serialize(esito));
                for(ElementiRicerca documento : esito.elemento){
                    WrapperMetaDoc docNV = new WrapperMetaDoc();
                    System.debug('@@@ documento ' + JSON.serialize(documento));
                    idDocumentiNV.add(documento.Id);

                    docNV.id = documento.Id;

                    for(OutputIndice indiciDoc : documento.indice){
                        if(indiciDoc.nome == 'Name'){
                            docNV.nomeFile = indiciDoc.valore;
                        }
                        if(indiciDoc.nome == 'MimeType'){
                            docNV.mime = indiciDoc.valore;
                        }
                    }

                    listaDocNV.add(docNV);
                }
            }

            System.debug('@@@ listaDocNV ' + JSON.serialize(listaDocNV));

            System.debug('@@@ idDocumentiNV ' + JSON.serialize(idDocumentiNV));

            response.data.add(listaDocNV);
            response.message = 'OK';

        }
        catch(Exception e){
            response.message = e.getMessage();
            response.success = false;
        }

        return response;
    }

    public class PayloadRicercaMultipla{
        @AuraEnabled
        public Integer codiceIstituto3N; //881,
        @AuraEnabled
        public String idApplicazioneChiamante; //1,
        @AuraEnabled
        public String idSessioneChiamante; //1,
        @AuraEnabled
        public String lingua; //IT
        @AuraEnabled
        public String idOperazione; //1
        // @AuraEnabled
        // public String utenzaCanale; //1
        @AuraEnabled
        public List<DatiRicercaMultipla> datiRicerca;

        public PayloadRicercaMultipla(){
            this.codiceIstituto3N = 881;
            this.idApplicazioneChiamante = 'CRM';
            this.idSessioneChiamante = 'CRM';
            this.lingua = 'IT';
            this.idOperazione = '1';
            // this.utenzaCanale = '1';
            this.datiRicerca = new List<DatiRicercaMultipla>();
        }
    }

    public class DatiRicercaMultipla{
        @AuraEnabled
        public String etichetta;
        @AuraEnabled
        public String matricola;
        @AuraEnabled
        public String ruolo;
        // @AuraEnabled
        // public Integer filiale;
        @AuraEnabled
        public DatiDocumentoRicerca datiDocumento;
        @AuraEnabled
        public String campiAggiuntivi;

        public DatiRicercaMultipla(){
            this.etichetta = 'RICERCA-1';
            this.matricola = 'YH01175';
            this.ruolo = 'I340';
            //this.filiale = 0;
            this.datiDocumento = new DatiDocumentoRicerca();
            this.campiAggiuntivi = '';
        }
    }

    public class DatiDocumentoRicerca{
        @AuraEnabled
        public String classeOggetto;
        @AuraEnabled
        public List<IndiceRicerca> indice;
        @AuraEnabled
        public String cartella;
        @AuraEnabled
        public String sottoCartella;
        @AuraEnabled
        public PaginaRicerca pagina;
        @AuraEnabled
        public String ordine;
        @AuraEnabled
        public String righeMassime;

        public DatiDocumentoRicerca(){
            this.classeOggetto = 'DOCUMENTI_CLIENTE';
            this.indice = new List<IndiceRicerca>();
            this.cartella = '';
            this.sottoCartella = '';
            this.pagina = new PaginaRicerca();
            this.ordine = 'DATECREATED DESC';
            this.righeMassime = '100';
        }
    }


    public class IndiceRicerca{
        @AuraEnabled
        public String nome;
        @AuraEnabled
        public String operatore;
        @AuraEnabled
        public String valore;

        public IndiceRicerca(){
            this.nome = '';
            this.operatore = '';
            this.valore = '';
        }

        public IndiceRicerca(String nomeI, String operatoreI, String valoreI){
            this.nome = nomeI;
            this.operatore = operatoreI;
            this.valore = valoreI;
        }
    }

    public class PaginaRicerca{
        @AuraEnabled
        public String indice;
        @AuraEnabled
        public String dimensione;

        public PaginaRicerca(){
            this.indice = '1';
            this.dimensione = '100';
        }
    }

    public class DatiRicercaMultiplaEsito extends WsRestInput.CommonResponse{
        @AuraEnabled
        public DatiRicercaEsito payload;

        public DatiRicercaMultiplaEsito(){
            this.payload = new DatiRicercaEsito();
        }

        public override Boolean isCorrect(){
            return this.payload.datiRicercaEsito.size() > 0;
        }
    }

    public class DatiRicercaEsito{
        @AuraEnabled
        public List<EsitoRicerca> datiRicercaEsito;

        public DatiRicercaEsito(){
            this.datiRicercaEsito = new List<EsitoRicerca>();
        }
    }

    public class EsitoRicerca{
        @AuraEnabled
        public String etichetta;
        @AuraEnabled
        public String returnCode;
        @AuraEnabled
        public Integer numeroElementi;
        @AuraEnabled
        public List<ElementiRicerca> elemento;

        public EsitoRicerca(){
            this.etichetta = etichetta;
            this.returnCode = returnCode;
            this.numeroElementi = numeroElementi;
            this.elemento = elemento;
        }
    }

    public class ElementiRicerca{
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

        public ElementiRicerca(){
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

    public class WrapperMetaDoc{
        @AuraEnabled
        public String id;
        @AuraEnabled
        public String nomeFile;
        @AuraEnabled
        public String mime;

        public WrapperMetaDoc(){
            this.id = id;
            this.nomeFile = nomeFile;
            this.mime = mime;
        }

        public WrapperMetaDoc(String docId, String nome, String type){
            this.id = docId;
            this.nomeFile = nome;
            this.mime = type;
        }
    }


    @AuraEnabled
    @future(callout=true)
    public static void InvioDocNuovaVendita(String opportunityId){
        WrapperResponse response = new WrapperResponse();

        //try{
            Opportunity opp = [SELECT Id, Name, StageName, AccountId, Account.NDGGruppo__c, IdCartella__c FROM Opportunity WHERE Id =: opportunityId];
            System.debug('@@@ opp ' + opp.IdCartella__c);

            WrapperResponse responseRicerca = ricercaMultiplaDoc(opportunityId);
            System.debug('@@@ responseRicerca ' + JSON.serialize(responseRicerca));

            if(opp.IdCartella__c == null){
                response.message = 'Nessuna cartella nuova vendita rilevata';
                response.success = false;
                
                return;
            }

            if(responseRicerca.data.isEmpty()){
                response.message = 'La ricerca non ha restituito alcun documento';
                response.success = false;

                return;
            }

            // WrapperResponse responseRicercaMAV = ricercaMAV(opp.Account.NDGGruppo__c, opp.Id);
            // System.debug('@@@ responseRicercaMAV ' + JSON.serialize(responseRicercaMAV));

            System.debug('@@@ idDocs ' + JSON.serialize(responseRicerca.data[0]));

            List<WrapperMetaDoc> docsToNuovaVendita = new List<WrapperMetaDoc>();
            docsToNuovaVendita = (List<WrapperMetaDoc>)responseRicerca.data[0];

            System.debug('@@@ docsToNuovaVendita ' + JSON.serialize(docsToNuovaVendita));

            // //Aggiungo il mav
            // if(!responseRicercaMAV.data.isEmpty() && responseRicercaMAV.success){
            //     docsToNuovaVendita.add((WrapperMetaDoc)responseRicercaMAV.data[0]);
            // }
            // else{
            //     return;
            // }

            System.debug('@@@ docsToNuovaVendita con mav ' + JSON.serialize(docsToNuovaVendita));


            List<AggiornamentoData> qblePayload = new List<AggiornamentoData>();

            //List<IndiceInput> listaIndiciDocs = new List<IndiceInput>();

            AggiornamentoData prova = new AggiornamentoData();
            System.debug('@@@ prova ' + JSON.serialize(prova));

            for(WrapperMetaDoc idDoc : docsToNuovaVendita){
                AggiornamentoData payload = new AggiornamentoData();
                IndiceInput indice = new IndiceInput('Id', idDoc.id);
                IndiceInput indiceAggiornaIdCartella = new IndiceInput('CARTELLANV', opp.IdCartella__c);
                indiceAggiornaIdCartella.ricerca = 'FALSE';
                indiceAggiornaIdCartella.append = 'TRUE';
                payload.data.datiDocumento = new AggiornamentoDatiDocumento();
                payload.data.datiDocumento.indice.add(indice);
                payload.data.datiDocumento.indice.add(indiceAggiornaIdCartella);

                payload.data.datiDocumento.contenutoDocumento = new List<ContenutoDocumento>();

                ContenutoDocumento cntDoc = new ContenutoDocumento();
                cntDoc.nomeFIle = idDoc.nomeFile;
                cntDoc.tipoMime = idDoc.mime;
                cntDoc.base64 = null;

                System.debug('@@@ cntDoc ' + JSON.serialize(cntDoc));

                payload.data.datiDocumento.contenutoDocumento.add(cntDoc);
                // payload.data.datiDocumento.contenutoDocumento[0].nomeFIle = idDoc.nomeFile;
                // payload.data.datiDocumento.contenutoDocumento[0].tipoMime = idDoc.mime;

                System.debug('@@@ payload ' + JSON.serialize(payload));
                qblePayload.add(payload);
            }

            System.debug('@@@ btcPayload ' + JSON.serialize(qblePayload));

            Id jobId = System.enqueueJob(new WGC_QbleInvioDocumentiNuovaVendita(qblePayload));
            System.debug('@@@ jobId  ' + jobId );

        //}
        // catch(Exception e){
        //     response.message = e.getMessage();
        //     response.success = false;
        // }

        // return response;
    }

    // public class AggiornamentoDataPayload extends WsRestInput.CommonInput{
    //     @AuraEnabled
    //     public AggiornamentoData payload;

    //     public AggiornamentoDataPayload(){
    //         this.payload = new AggiornamentoData();
    //     }
    // }


    public class AggiornamentoData{
        @AuraEnabled
        public WrapperData data;

        public AggiornamentoData(){
            this.data = new WrapperData();
        }
    }

    public class WrapperData{
        @AuraEnabled
        public String codiceIstituto3N; //881,
        @AuraEnabled
        public String idApplicazioneChiamante; //1,
        @AuraEnabled
        public String idSessioneChiamante; //1,
        @AuraEnabled
        public String lingua; //IT
        @AuraEnabled
        public String idOperazione; //1
        @AuraEnabled
        public String matricola; //1
        @AuraEnabled
        public String ruolo; //1
        @AuraEnabled
        public AggiornamentoDatiDocumento datiDocumento;

        public WrapperData(){
            this.codiceIstituto3N = '881';
            this.idApplicazioneChiamante = 'CRM';
            this.idSessioneChiamante = 'CRM';
            this.lingua = 'IT';
            this.idOperazione = '1';
            this.matricola = 'YH01175';
            this.ruolo = 'I340';
            this.datiDocumento = new AggiornamentoDatiDocumento();
        }
    }

    public class AggiornamentoDatiDocumento{
        @AuraEnabled
        public String classeOggetto;
        @AuraEnabled
        public List<IndiceInput> indice;
        @AuraEnabled
        public String azioneDiRicerca;
        @AuraEnabled
        public List<ContenutoDocumento> contenutoDocumento;

        public AggiornamentoDatiDocumento(){
            this.classeOggetto = 'DOCUMENTI_CLIENTE';
            this.indice = new List<IndiceInput>();
            this.azioneDiRicerca = 'UPDATE_CURRENT_VERSION';
            this.contenutoDocumento = new List<ContenutoDocumento>();
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

        public ContenutoDocumento(String nomeF, String estensione){
            this.nomeFIle = nomeF;
            this.tipoMime = estensione;
            this.base64 = null;
        }
    }

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

        public IndiceInput(String nomeI, String valoreI){
            this.nome = nomeI;
            this.ricerca = 'TRUE';
            this.append = 'FALSE';
            this.valore = valoreI;
        }
    }

    public class OptionsLingue{
        @AuraEnabled
        public String value;
        @AuraEnabled
        public String label;
    }

    @AuraEnabled
    public static WrapperResponse getLanguage(Boolean isRSF){
        WrapperResponse response = new WrapperResponse();

        try{
            List<WGC_Composizione_Documento__mdt> metaLingue = new List<WGC_Composizione_Documento__mdt>();
            if(isRSF){
                metaLingue = [SELECT Id, DeveloperName, MasterLabel, toLabel(Lingua__c), Nome_Template__c FROM WGC_Composizione_Documento__mdt];
            }
            else{
                metaLingue = [SELECT Id, DeveloperName, MasterLabel, toLabel(Lingua__c), Nome_Template__c FROM WGC_Composizione_Documento__mdt WHERE toLabel(Lingua__c) != 'Italiano'];
            }
            
            System.debug('@@@ meta ' + JSON.serialize(metaLingue));
            Map<String,String> lingue = new Map<String,String>();

            for(WGC_Composizione_Documento__mdt meta : metaLingue){
                // OptionsLingue lingua = new OptionsLingue();
                // lingua.value = meta.Lingua__c;
                // lingua.label = meta.Lingua__c;
                
                // System.debug('@@@ contiene ' + !lingue.contains(lingua));
                // System.debug('@@@ lingua ' + JSON.serialize(lingua));
                // System.debug('@@@ lingue ' + JSON.serialize(lingue));
                // if(!lingue.contains(lingua))
                //     lingue.add(lingua);
                String apiLingua = meta.DeveloperName.split('_')[1];

                System.debug('@@@ lingua ' + meta.Lingua__c);
                lingue.put(meta.Lingua__c, apiLingua);
            }

            // SYstem.debug('@@@ aaa ' , lingue[0]);
            // SYstem.debug('@@@ bbb ' , lingue[1]);
            // System.debug('@@@ prova ' , lingue[0] == lingue[1]);

            response.data.add(lingue);

        }
        catch(Exception e){
            response.message = e.getMessage() + ' - ' + e.getLineNumber();
            response.success = false;
        }

        return response;
    }

    @AuraEnabled
    public static Boolean privacyEsecutoreFirmata(String accountId){
        AccountContactRelation esec = new AccountContactRelation();

        esec = [SELECT Id, ContactId, Contact.Name, Contact.DataInserimentoConsensi__c
                FROM AccountContactRelation WHERE AccountId =: accountId AND WGC_Esecutore_MAV__c = true LIMIT 1];

        return esec.Contact.DataInserimentoConsensi__c != null ? true : false;
    }
    
    @AuraEnabled
	public static String getProfilo() {
		Profile p = [Select Name from Profile where Id =: userinfo.getProfileid()];
		String profile = p.Name;
        return profile;
	}

	//adione CR 293
	public class SoggettoOpp {
		@AuraEnabled
		public Id id = null;
		@AuraEnabled
		public String name = '';
		@AuraEnabled
		public String tipo = '';

		public SoggettoOpp() {
		}
	}
	//adione CR 293
	@AuraEnabled
	public static WrapperResponse getSoggettiOpp(Id oppId) {
		WrapperResponse res = new WrapperResponse();
		try {
			List<SoggettoOpp> lst = new List<SoggettoOpp>();

			if (String.isBlank(oppId)) {
				res.data = lst;
				return res;
			}

			List<NDGLinea__c> debitori = [
				SELECT Id, Nome__c, Account__r.Id
				FROM NDGLinea__c
				WHERE Tipo__c = 'Debitore'
				  AND Opportunita__c = :oppId
			];

			Opportunity opp = [
				SELECT Id, Account.Id, Account.Name
				FROM Opportunity
				WHERE Id = :oppId
				LIMIT 1
			];

			SoggettoOpp o;
			//cedente
			o = new SoggettoOpp();
			o.id = opp.Account.Id;
			o.name = opp.Account.Name;
			o.tipo = 'CEDENTE';
			lst.add(o);
			//debitori
			for (NDGLinea__c deb : debitori) {
				o = new SoggettoOpp();
				//o.id = deb.Account__r.Id;
				o.id = deb.Id; // per debitori usiamo NDGLinea__c così viene gestito tag per FileNet
				o.name = deb.Nome__c;
				o.tipo = 'DEBITORE';
				lst.add(o);
			}

			res.data = lst;
			return res;

		} catch (Exception ex) {
            res.success = false;
            res.message = ex.getMessage();
            return res;
		}
	}


    //PALUMBO 05/02/2020
    @AuraEnabled
    public static Boolean getProfileInfo(){
        String profileFF = 'IFIS - B/O Valutazione Fast Finance';
        String profileCE = 'IFIS - Crediti Erariali';

        try{
            Profile profile = [SELECT Id, Name FROM Profile WHERE Id =: UserInfo.getProfileId()];
            return profile.Name.equals(profileFF) || profile.Name.equals(profileCE);
        }catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static String getOppRecordTypeInfo(Id opportunityId){
        System.debug('getOppRecordTypeInfo: '+opportunityId);
        String rtDevName = 'IFISOpportunitaFastFinance';

        try{
            Opportunity opp = [SELECT Id, RecordType.DeveloperName FROM Opportunity WHERE Id =: opportunityId];
            return opp.RecordType.DeveloperName.equals(rtDevName) ? 'CE' : 'CC';
        }catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static String setAllDocNonReperibili(Id opportunityId, Boolean value, List<WGC_Nota_Documento__c> notes){
        try{
            //Se ho flaggato tutti non reperibili inserisco note
            //Altrimenti le cancello
            if(value)
                insert notes;
            else
                delete notes;

            //Infine aggiorno il campo su opportunità per mantenere lo stato
            return WizardOpportunityController.updateField('WGC_Documenti_Non_Reperibili__c', (Object)value, opportunityId);
        } catch(Exception e){
            return e.getMessage();
        }
    }
}