public  class OnCondizioniTriggerHandler {
    
    public static void OnCondizioniOpzionali(Map <Id,Condizioni__c> input) {
        
        //Assegnazione variabili
        Set<Id> idproduct = new Set<Id>();
        Set<Id> idbundle = new Set<Id>();
        Set<Id> idoption = new Set<Id>();
        boolean bun=false;
        
        // se non sto usando il pulsante di rinnovo carico i prodotti
        for (Id c : input.keyset()) {
            IF(input.get(c).Escludi_da_template__c == false && input.get(c).Formula_Semaforo_Trigger__c==true){    
                idproduct.add (input.get(c).ID_Prodotto_Formula__c);
                idoption.add(input.get(c).Id_Bundle_formula__c);
            }
        }
        
        System.debug('Idprodotto e bundle'+ idproduct + idoption);
        
        //Query su BAW per recuperare i dati di maschera
        Map<Id, Business_Area_Warrant__c> BUCondizioniPag = new map <Id,Business_Area_Warrant__c> ([SELECT Id, Fisso_WarrantCPQ__c, Percentuale_WarrantCPQ__c, SingoloProdotto_WarrantCPQ__c, ProdottoBundle_WarrantCPQ__c,RecordTypeId, RecordType.Name FROM Business_Area_Warrant__c WHERE SingoloProdotto_WarrantCPQ__c in : idproduct]);
        Map<Id, SBQQ__ProductOption__c> Bundle = new map <Id,	SBQQ__ProductOption__c> ([SELECT Id,SBQQ__ConfiguredSKU__c,SBQQ__OptionalSKU__c FROM SBQQ__ProductOption__c WHERE Id IN: idoption]);
        
        //mappe vuote per AsyncCopy
        Map<Id,Business_Area_Warrant__c> toSaveCondizioniOp = new Map<Id,Business_Area_Warrant__c>();
        Map<Id,Business_Area_Warrant__c> toSavePagamenti = new Map<Id,Business_Area_Warrant__c>(); 
        Map<Id,SBQQ__QuoteLine__c> idquote = new Map<Id,SBQQ__QuoteLine__c>();
        Map<Id, Finanziamenti__c> idfin = new Map <Id,Finanziamenti__c>();
        Map<Id,Condizioni__c>idcon=new Map<Id, Condizioni__c>();             
        
        // se l'oggetto è tipo bundle lo segnalo con un flag
        If(Bundle.size()>0){
            bun=true;
        }
        
        //stampe check
        System.debug('BuCondizioniOpzionali' + BUCondizioniPag);
        System.debug('Bundle' + Bundle + bun);
        
        //Salvo le condizioni opzionali e i pagamenti da creare
        for (Id con : input.keyset()) {
            If(bun == false){
                for (Id op : BUCondizioniPag.keyset()) {
                    If(BUCondizioniPag.get(op).RecordType.Name == 'Condizione Opzionale'){
                        toSaveCondizioniOp.put(op,BUCondizioniPag.get(op));
                        idcon.put(con, input.get(con));
                    }
                    If(BUCondizioniPag.get(op).RecordType.Name == 'Pagamenti'){
                        toSavePagamenti.put(op,BUCondizioniPag.get(op));
                        idcon.put(con, input.get(con));  
                    } 
                }  
            } else If(bun == true){
                //qui va condizione per bundle
                for (Id pk : BUCondizioniPag.keyset()) {
                    for(Id p:Bundle.keyset()){
                        If(BUCondizioniPag.get(pk).ProdottoBundle_WarrantCPQ__c == Bundle.get(p).SBQQ__ConfiguredSKU__c && BUCondizioniPag.get(pk).SingoloProdotto_WarrantCPQ__c == Bundle.get(p).SBQQ__OptionalSKU__c){
                            //Caso per prodotto bundle: confronto il master
                            If(BUCondizioniPag.get(pk).RecordType.Name == 'Pagamenti'){
                                toSavePagamenti.put(pk,BUCondizioniPag.get(pk));
                                idcon.put(con, input.get(con));
                            } 
                            if(BUCondizioniPag.get(pk).RecordType.Name == 'Condizione Opzionale'){
                                toSaveCondizioniOp.put(pk,BUCondizioniPag.get(pk));
                                idcon.put(con, input.get(con));
                            }
                            
                        }
                    }
                }
            }
        }
        
        System.debug('Business Area Map Condizioni Opzionali : ' + toSaveCondizioniOp);
        System.debug('Business Area Map Pagamenti : ' + toSavePagamenti);
        
        if(!toSaveCondizioniOp.isEmpty() || !toSavePagamenti.isEmpty()){
            SBQQ.TriggerControl.disable();
            String s='op';
            try {
                AsyncBUCopy executeQueueable = new AsyncBUCopy(toSaveCondizioniOp.keyset(),idquote.keyset(),s,idfin.keyset(),idcon.keyset(),toSavePagamenti.keyset());  //PASSO IL SET AD ASYNCEXE
                ID jobID = System.enqueueJob(executeQueueable);
                System.debug('Condizioni jobID : ' + jobID);
            }finally{
                SBQQ.TriggerControl.enable();
            }
        }
    }
    
    public static void AllineaRollupInsert (List <Condizioni__c> input) {
        Set<Id> idquote = new Set <Id> ();
        
        //salvo la Quote
        for(Condizioni__c c:input){
            If(c.Escludi_da_template__c == false && c.Formula_Semaforo_Trigger__c == false){
                idquote.add(c.Quote_Line__c);
            }
        }
        system.debug('id quoteline' + idquote);
        //Mappo la Quote
        Map <Id,SBQQ__QuoteLine__c> MapQuote = new Map <Id,SBQQ__QuoteLine__c> ([SELECT Id,Numero_Condizioni__c FROM SBQQ__QuoteLine__c WHERE Id IN:idquote]);
        system.debug('Map quoteline' + MapQuote);
        Map<Id,Condizioni__c> MapCond = new Map<Id,Condizioni__c>([SELECT Id FROM Condizioni__c WHERE Quote_Line__c IN:idquote]);
        
        Decimal Numero = 0;
        
        for(Id c:MapCond.keyset()){
            Numero+= 1;
        }
        
        for(Id q:MapQuote.keyset()){
            MapQuote.get(q).Numero_Condizioni__c = Numero;
        }
        
        system.debug('Numero' + Numero);
        system.debug('Update' + MapQuote.values());
        
        If(MapQuote.size()>0){
            SBQQ.TriggerControl.disable();
            update MapQuote.values();
            SBQQ.TriggerControl.enable();
        }
    }
    
    
    
    
    public static void AllineaRollupDelete (List <Condizioni__c> input) {
        Set<Id> idquote = new Set <Id> ();
        //salvo la Quote
        for(Condizioni__c c:input){
            idquote.add(c.Quote_Line__c);
        }
        system.debug('id quoteline' + idquote);
        //Mappo la Quote
        Map <Id,SBQQ__QuoteLine__c> MapQuoteLine = new Map <Id,SBQQ__QuoteLine__c> ([SELECT Id,Numero_Condizioni__c FROM SBQQ__QuoteLine__c WHERE Id IN:idquote]);
        system.debug('Map quoteline' + MapQuoteLine);
        Map<Id,Condizioni__c> MapCond = new Map<Id,Condizioni__c>([SELECT Id,Quote_Line__c FROM Condizioni__c WHERE Quote_Line__c IN:idquote]);
        
        Decimal Numero = 0;
        
        for (Id f : MapCond.keyset()) {
            Numero+= 1;
        }
        system.debug('Numero Cond Before Delete' + Numero);
        
        for(Id q:MapQuoteLine.keyset()){
            for(Id con:MapCond.keyset()){
                If(MapQuoteLine.get(q).Id == MapCond.get(con).Quote_Line__c){
                    //Come per i fin non sono convinta qui
                    MapQuoteLine.get(q).Numero_Condizioni__c = Numero - 1;
                }
            }
        }
        
        system.debug('Numero' + Numero);
        system.debug('Update' + MapQuoteLine.values());
        
        If(MapQuoteLine.size()>0){
            SBQQ.TriggerControl.disable();
            update MapQuoteLine.values();
            SBQQ.TriggerControl.enable();
        }
    }
    
    // @future(callout=true)
    // public static void updateCondizioniInfostore(Set<Id> condizioniIds){
    //   if(UserInfo.getProfileId() == [SELECT Id FROM Profile WHERE Name = 'Warrant - Integration Profile'].Id)
    //     return;
    
    //   Boolean success = true;
    //   String msg = '';
    //   String jsonString = '';
    //   String jsonResponse = '';
    //   try{
    
    //     Map<Id,Condizioni__c> condizioniMap = new Map<Id, Condizioni__c>([SELECT Id, AccountId__c, Chiave_Esterna__c, CreatedById, CreatedDate,
    //     FF_WarrantCPQ__c, Finanziamento__c, Fisso_WarrantCPQ__c, Formula_Importo_WarrantCPQ__c, Formula_Stima_WarrantCPQ__c, ID_Prodotto_Formula__c, IsDeleted, 
    //     LastModifiedById, LastModifiedDate, Limite_WarrantCPQ__c, Massimo_WarrantCPQ__c, Min_garantito_WarrantCPQ__c, Minimo_WarrantCPQ__c, Name, Percentuale_WarrantCPQ__c,
    //     Quote_Line__c, RecordTypeId, Stima_Appoggio__c, Tipo_WarrantCPQ__c, Valore_max_WarrantCPQ__c, WRT_Tipologia_Finanziamento_FORM__c FROM Condizioni__c WHERE Id IN: condizioniIds]);
    
    //     Map<Id, Condizione_Opzionale__c> condizioniOpzMap = new Map<Id, Condizione_Opzionale__c>([SELECT Id, Chiave_Esterna__c, CondizionePadre_WarrantCPQ__c, CreatedById,
    //     CreatedDate, FF_WarrantCPQ__c, Fisso_WarrantCPQ__c, Formula_Condizioni_Opzionali_Name__c, Formula_Id_Prodotto__c, Formula_Importo_WarrantCPQ__c, Formula_Quote_Line__c,
    //     IsDeleted, LastModifiedById, LastModifiedDate, Limite_WarrantCPQ__c, Massimo_WarrantCPQ__c, Min_garantito_WarrantCPQ__c, Minimo_WarrantCPQ__c, Name, 
    //     Percentuale_WarrantCPQ__c, Quote_Line__c, RecordTypeId, Tipo_WarrantCPQ__c, WRT_Tipologia_Finanziamento_FORM__c, Valore_max_WarrantCPQ__c
    //     FROM Condizione_Opzionale__c WHERE CondizionePadre_WarrantCPQ__c IN: condizioniMap.keySet() ]);
    
    //     // Map<Id, Condizione_Opzionale__c> condizioniOpzMap = new Map<Id, Condizione_Opzionale__c>([SELECT Id, CondizionePadre_WarrantCPQ__c FROM Condizione_Opzionale__c WHERE CondizionePadre_WarrantCPQ__c IN: condizioniMap.keySet()]);
    //     Map<String, List<Condizione_Opzionale__c>> padreXChildren = (Map<String,List<Condizione_Opzionale__c>>) Utilities.groupBy(condizioniOpzMap.values(), 'CondizionePadre_WarrantCPQ__c');
    
    //     for(Id cId : condizioniMap.keySet()){
    //       List<SObject> records = new List<SObject>();
    
    //       records.add(condizioniMap.get(cId));
    //       records.addAll(padreXChildren.get(cId));
    
    //       HttpRequest request = new HttpRequest();
    //       // request.setEndpoint('https://salesforce.warranthub.it/v1/Wh/Update');
    //       request.setEndpoint(EndpointServizi__c.getOrgDefaults().WRT_Aggiornamento_CPQ_Infostore__c);
    //       request.setMethod('PUT');
    //       Map<String,Object> payload = new Map<String,Object>{ 'records' => records, 'object' => 'Condizioni'};
    //       jsonString = JSON.serialize(payload);
    //       request.setBody(jsonString);
    
    //       HttpResponse response = new Http().send(request);
    //       jsonResponse = response.getBody();
    //       System.debug('@@@ response ' + jsonResponse);
    //     }
    //   } catch(Exception e){
    //     System.debug('@@@ e ' + e.getMessage() + ' -- ' + e.getStackTraceString());
    //     msg = e.getMessage() + ' -- ' + e.getStackTraceString();
    //     success = false;
    //   }
    
    //   insert new Log__c(
    //     Success__c = success,
    //     Societa__c = 'WarrantHub',
    //     Source__c = 'IntegrazioneInfoStore_UpdateCondizioni',
    //     ErrorMessage__c = msg,
    //     InputPayload__c = jsonString,
    //     OutputPayload__c = jsonResponse
    //   );
    // }
    
    // @future(callout=true)
    // public static void createCondizioniOpzionaliInfostore(Set<Id> condizioniIds){
    //     if(UserInfo.getProfileId() == [SELECT Id FROM Profile WHERE Name = 'Warrant - Integration Profile'].Id)
    //     return;
    
    //     Boolean Success = true;
    //     String msg = '';
    //     String jsonString = '';
    //     String jsonResponse = '';
    
    //     try{
    
    //         Map<Id, Condizioni__c> condizioniMap = new Map<Id, Condizioni__c>([SELECT Id, AccountId__c, Chiave_Esterna__c, CreatedById, CreatedDate,
    //         FF_WarrantCPQ__c, Finanziamento__c, Fisso_WarrantCPQ__c, Formula_Importo_WarrantCPQ__c, Formula_Stima_WarrantCPQ__c, ID_Prodotto_Formula__c, IsDeleted, 
    //         LastModifiedById, LastModifiedDate, Limite_WarrantCPQ__c, Massimo_WarrantCPQ__c, Min_garantito_WarrantCPQ__c, Minimo_WarrantCPQ__c, Name, Percentuale_WarrantCPQ__c,
    //         Quote_Line__c, RecordTypeId, Stima_Appoggio__c, Tipo_WarrantCPQ__c, Valore_max_WarrantCPQ__c, WRT_Tipologia_Finanziamento_FORM__c FROM Condizioni__c WHERE Id IN: condizioniIds]);
    
    //         HttpRequest request = new HttpRequest();
    //         // request.setEndpoint('https://salesforce-test.warranthub.it/v1/Wh/Delete');
    //         request.setEndpoint(EndpointServizi__c.getOrgDefaults().WRT_Create_CPQ_Infostore__c);
    //         request.setMethod('POST');
    //         Map<String,Object> payload = new Map<String,Object>{ 'records' => condizioniMap.values(), 'object' => 'Condizioni'};
    //         System.debug('@@@ payload ' + JSON.serialize(payload));
    //         // request.setBody(JSON.serialize(payload));
    //         jsonString = JSON.serialize(payload);
    //         request.setBody(jsonString);
    
    //         date myDate  = date.today();
    //         String month = String.valueOf(myDate.month());
    //         String year  = String.valueOf(myDate.year());
    //         String day   = String.valueOf(myDate.day());
    
    //         String keyIntegrazioneInfoStore = EndpointServizi__c.getInstance().WRN_Key_IntegrazioneInfoStore__c;
    //         String output = encodingUtil.base64Encode(Blob.valueof(keyIntegrazioneInfoStore + year + (month.length() <= 1 ? ('0' + month) : month) + (day.length() <= 1 ? ('0' + day) : day)));
    //         JWT jwt = new JWT('HS256'); 
    //         jwt.userEmail = UserInfo.getUserEmail();
    
    //         jwt.privateKey = output; 
    //         // jwt.iss = 'your issuer'; 
    //         // jwt.sub = 'some subject'; 
    //         // jwt.aud = 'some audience'; 
    //         String token = jwt.issue();        
    //         system.debug ('token: '+ token);
    //         request.setHeader('Authorization', 'Bearer ' + token);
    
    //         HttpResponse response = new Http().send(request);
    //         // System.debug('@@@ response ' + response.getBody());
    
    
    //         jsonResponse = response.getBody();
    //         System.debug('@@@ response ' + jsonResponse);
    
    //     } catch (Exception e){
    //         System.debug('@@@ error ' + e.getMessage() + ' -- ' + e.getStackTraceString());
    //         Success = false;
    //         msg = e.getMessage() + ' -- ' + e.getStackTraceString();
    //     }
    
    //     insert new Log__c(
    //       Success__c = success,
    //       Societa__c = 'WarrantHub',
    //       Source__c = 'IntegrazioneInfoStore_CreateCondizioni',
    //       ErrorMessage__c = msg,
    //       InputPayload__c = jsonString,
    //       OutputPayload__c = jsonResponse
    //     );
    // }
    
    //OLD!
    //@future(callout=true)
    // public static String eliminaCondizioniInfostore(Set<String> condizioniIds){
    //     if(UserInfo.getProfileId() == [SELECT Id FROM Profile WHERE Name = 'Warrant - Integration Profile'].Id)
    //     return 'error';
    
    //     Boolean Success = true;
    //     String msg = 'ok';
    //     String jsonString = '';
    //     String jsonResponse = '';
    
    //     try{
    
    //         List<String> records = new List<String>();
    //         // records.addAll(Utilities.getSet(condizioniPadreFinal, 'Id'));
    //         records.addAll(condizioniIds);
    
    //         HttpRequest request = new HttpRequest();
    //         // request.setEndpoint('https://salesforce-test.warranthub.it/v1/Wh/Delete');
    //         request.setEndpoint(EndpointServizi__c.getOrgDefaults().WRT_Elimina_Condizioni_CPQ_Infostore__c + records[0]);
    //         request.setMethod('DELETE');
    //         Map<String,Object> payload = new Map<String,Object>{ 'records' => records, 'object' => 'Condizioni'};
    //         // System.debug('@@@ payload ' + JSON.serialize(payload));
    //         // request.setBody(JSON.serialize(payload));
    //         jsonString = JSON.serialize(payload);
    //         System.debug('@@@ payload ' + jsonString);
    //         request.setBody(jsonString);
    
    //         date myDate  = date.today();
    //         String month = String.valueOf(myDate.month());
    //         String year  = String.valueOf(myDate.year());
    //         String day   = String.valueOf(myDate.day());
    
    //         String keyIntegrazioneInfoStore = EndpointServizi__c.getInstance().WRN_Key_IntegrazioneInfoStore__c;
    //         String output = encodingUtil.base64Encode(Blob.valueof(keyIntegrazioneInfoStore + year + (month.length() <= 1 ? ('0' + month) : month) + (day.length() <= 1 ? ('0' + day) : day)));
    //         JWT jwt = new JWT('HS256'); 
    //         jwt.userEmail = UserInfo.getUserEmail();
    
    //         jwt.privateKey = output; 
    //         // jwt.iss = 'your issuer'; 
    //         // jwt.sub = 'some subject'; 
    //         // jwt.aud = 'some audience'; 
    //         String token = jwt.issue();        
    //         system.debug ('token: '+ token);
    //         request.setHeader('Content-type', 'application/json');
    //         request.setHeader('Authorization', 'Bearer ' + token);
    //         request.setTimeout(90000);
    //         HttpResponse response = new Http().send(request);
    //         // System.debug('@@@ response ' + response.getBody());
    
    
    //         jsonResponse = response.getBody();
    //         System.debug('@@@ response ' + jsonResponse);
    
    //     } catch (Exception e){
    //         System.debug('@@@ error ' + e.getMessage() + ' -- ' + e.getStackTraceString());
    //         Success = false;
    //         msg = e.getMessage() + ' -- ' + e.getStackTraceString();
    //     }
    
    //     insert new Log__c(
    //       Success__c = success,
    //       Societa__c = 'WarrantHub',
    //       Source__c = 'IntegrazioneInfoStore_DeleteCondizioni',
    //       ErrorMessage__c = msg,
    //       InputPayload__c = jsonString,
    //       OutputPayload__c = jsonResponse
    //     );
    
    //     return msg;
    // }
    
    public static Boolean eliminaCondizioniRelated(String condizioneId){
        if(UserInfo.getProfileId() == [SELECT Id FROM Profile WHERE Name = 'Warrant - Integration Profile'].Id)
            return false;
        
        Boolean Success = true;
        String msg = 'ok';
        String jsonString = '';
        String jsonResponse = '';
        
        try{
            
            //Recupero tutte le righe sotto questa condizione
            Map<Id,Condizioni__c> condizioni = new Map<Id,Condizioni__c>([SELECT Id FROM Condizioni__c WHERE Id =: condizioneId]);
            Map<Id,Condizione_Opzionale__c> opzionali = new Map<Id,Condizione_Opzionale__c>([SELECT Id FROM Condizione_Opzionale__c WHERE CondizionePadre_WarrantCPQ__c =: condizioneId]);
            Map<Id,Pagamenti__c> pagamenti = new Map<Id,Pagamenti__c>([SELECT Id FROM Pagamenti__c WHERE Condizione_WarrantCPQ__c =: condizioneId]);
            Map<String,List<String>> payload = new Map<String,List<String>>();
            payload.put('Condizioni', Utilities.toList(Utilities.keyBy(condizioni.values(), 'Id').keySet()));
            payload.get('Condizioni').addAll(Utilities.toList(Utilities.keyBy(opzionali.values(), 'Id').keySet()));
            payload.put('Pagamenti', Utilities.toList(Utilities.keyBy(pagamenti.values(), 'Id').keySet()));
            
            HttpRequest request = new HttpRequest();
            // request.setEndpoint('https://salesforce-test.warranthub.it/v1/Wh/Delete');
            request.setEndpoint(EndpointServizi__c.getOrgDefaults().WRT_Elimina_Bulk_Pricing__c);
            request.setMethod('POST');
            // Map<String,Object> payload = new Map<String,Object>{ 'records' => records, 'object' => 'Condizioni'};
            // System.debug('@@@ payload ' + JSON.serialize(payload));
            // request.setBody(JSON.serialize(payload));
            jsonString = JSON.serialize(payload);
            System.debug('@@@ payload ' + jsonString);
            request.setBody(jsonString);
            
            date myDate  = date.today();
            String month = String.valueOf(myDate.month());
            String year  = String.valueOf(myDate.year());
            String day   = String.valueOf(myDate.day());
            
            String keyIntegrazioneInfoStore = EndpointServizi__c.getInstance().WRN_Key_IntegrazioneInfoStore__c;
            String output = encodingUtil.base64Encode(Blob.valueof(keyIntegrazioneInfoStore + year + (month.length() <= 1 ? ('0' + month) : month) + (day.length() <= 1 ? ('0' + day) : day)));
            JWT jwt = new JWT('HS256'); 
            jwt.userEmail = UserInfo.getUserEmail();
            
            jwt.privateKey = output; 
            // jwt.iss = 'your issuer'; 
            // jwt.sub = 'some subject'; 
            // jwt.aud = 'some audience'; 
            String token = jwt.issue();
            system.debug ('token: '+ token);            
            request.setHeader('Content-type', 'application/json');
            request.setHeader('Authorization', 'Bearer ' + token);
            request.setTimeout(90000);
            HttpResponse response = new Http().send(request);
            // System.debug('@@@ response ' + response.getBody());
            
            
            jsonResponse = response.getBody();
            System.debug('@@@ response ' + jsonResponse);
            
            Map<String,Object> responseMap = (Map<String,Object>) JSON.deserializeUntyped(jsonResponse);
            msg = String.valueOf(responseMap.get('message'));
            Success = (Boolean) responseMap.get('success');
            
        } catch (Exception e){
            System.debug('@@@ error ' + e.getMessage() + ' -- ' + e.getStackTraceString());
            Success = false;
            msg = e.getMessage() + ' -- ' + e.getStackTraceString();
        }
        
        insert new Log__c(
            Success__c = success,
            Societa__c = 'WarrantHub',
            Source__c = 'IntegrazioneInfoStore_DeleteCondizioni',
            ErrorMessage__c = msg,
            InputPayload__c = jsonString,
            OutputPayload__c = jsonResponse
        );
        
        return Success;
    }
    
    
    public static void setMinimum(List<Condizioni__c> input){
        for(Condizioni__c c:input){
            if(c.Massimo_WarrantCPQ__c>0 && c.Minimo_WarrantCPQ__c==null){
                c.Minimo_WarrantCPQ__c=0;
            }
        }        
    }
    
    public static void setMinimumOnUpdate(Map<Id,Condizioni__c> newinput, Map<Id,Condizioni__c> oldinput){
        for(Id i:newinput.keySet()){
            if(newinput.get(i).Massimo_WarrantCPQ__c>0 && newinput.get(i).Minimo_WarrantCPQ__c==null && oldinput.get(i).WRT_Update_da_Rinnovo__c==false){
                newinput.get(i).Minimo_WarrantCPQ__c=0;
                //Da errore????
            }
        }        
    }
    
    public static void aggiornaCampoCondizioniApprovazioneQuote_Insert(Map<Id, Condizioni__c> newinput){
        
User currUser = [SELECT Id, Utente_Integrazione__c FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];
        
        Map<Id,Condizioni__c> condMap = new Map<Id,Condizioni__c>([SELECT Quote_Line__r.SBQQ__Quote__c FROM Condizioni__c WHERE Id IN :newinput.keySet()]);
        
        List<Approvazioni__c> listApp = new List<Approvazioni__c>();
        
        //Prima controllo quali flag devo mettere all'approvazione poi vado a creare l'approvazione
        //Senza fare creazione e update successivo
        
        Boolean SogliaCommerciale=false;
        Boolean SogliaAMKAM=false;
        Boolean SottosogliaDM = false;
        Boolean SottosogliaDC=false;
        Boolean appvaloremax=false;
        Boolean appnegativo = false;
        Boolean SogliaSup = false;
        
        for(Id c:newinput.keyset()){
            if(newinput.get(c).Valore_max_WarrantCPQ__c != null){
                appvaloremax=true;
            }
            if(newinput.get(c).Importo_Appoggio__c<0 && newinput.get(c).Approvazione_importo_negativo__c == true){
                appnegativo=true;
            }
        }
        
        for(Id i:newinput.keySet()){
            
            //Controllo Soglia Diretto Superiore
            if(appnegativo==true){
                SogliaSup=true;
            }
            //Controllo Sotto Soglia Commerciale
            if((newinput.get(i).Fisso_WarrantCPQ__c > 0 && newinput.get(i).Fisso_WarrantCPQ__c < newinput.get(i).Soglia_Commerciale_Fisso__c)
               || appvaloremax==true||
               (newinput.get(i).Percentuale_WarrantCPQ__c>0 && newinput.get(i).Percentuale_WarrantCPQ__c<newinput.get(i).Soglia_Commerciale_Percentuale__c)){	
                   SogliaCommerciale=true;
                   System.debug('Soglia Commerciale');	
               }
            
            //Controllo Sotto Soglia DM
            if((newinput.get(i).Fisso_WarrantCPQ__c>0 && newinput.get(i).Fisso_WarrantCPQ__c<newinput.get(i).Soglia_DM_Fisso__c)
               ||appvaloremax==true ||(appvaloremax==true && newinput.get(i).Valore_max_WarrantCPQ__c<newinput.get(i).Soglia_Valore_Max_AM__c)
               ||(newinput.get(i).Percentuale_WarrantCPQ__c>0 && newinput.get(i).Percentuale_WarrantCPQ__c<newinput.get(i).Soglia_DM_Percentuale__c)){		
                   SottosogliaDM=true;
                   System.debug('Sotto Soglia DM');		
               } 
            
            //Controllo Sotto Soglia AM/KAM
            if((newinput.get(i).Fisso_WarrantCPQ__c>0 && newinput.get(i).Fisso_WarrantCPQ__c<newinput.get(i).Soglia_AM_KAM_Fisso__c) 
               ||(appvaloremax==true && newinput.get(i).Valore_max_WarrantCPQ__c<newinput.get(i).Soglia_Valore_Max_DC__c) 
               ||(newinput.get(i).Percentuale_WarrantCPQ__c>0 && newinput.get(i).Percentuale_WarrantCPQ__c<newinput.get(i).Soglia_AM_KAM_Percentuale__c)){		
                   SogliaAMKAM=true;	
                   System.debug('Soglia AM - KAM');	
               }
            
            
            
            //Controllo Sotto Soglia Direttore Commerciale    
            if((newinput.get(i).Fisso_WarrantCPQ__c>0 && newinput.get(i).Fisso_WarrantCPQ__c<newinput.get(i).Soglia_Dir_Comm_Fisso__c) 
               ||(newinput.get(i).Percentuale_WarrantCPQ__c>0 && newinput.get(i).Percentuale_WarrantCPQ__c<newinput.get(i).Soglia_Dir_Comm_Percentuale__c)){        
                   SottosogliaDC=true;
                   System.debug('Sotto soglia DC');
               }    
            
        }
        
        
        
        for(Id q:newinput.keySet()){
            if(newinput.get(q).WRT_Update_da_Rinnovo__c==false && newinput.get(q).Formula_Semaforo_Trigger__c==false){
                System.debug('Creazione Manuale');
                if(currUser.Utente_Integrazione__c==false && newinput.get(q).Controllo_Approvazioni_in_attesa__c==false){
                    System.debug('Creazione');
                    Approvazioni__c app = new Approvazioni__c(
                        Quote__c=condMap.get(q).Quote_Line__r.SBQQ__Quote__c,
                        Approval_Step__c='In attesa di approvazione',
                        Condizione__c=newinput.get(q).Id,
                        Name='Approvazione Commerciale',
                        Quote_Line__c=newinput.get(q).Quote_Line__c,
                        Soglia_Commerciale_Superata__c=SogliaCommerciale,
                        Soglia_AM_KAM_Superata__c=SogliaAMKAM,
                        Soglia_DM_Superata__c = SottosogliaDM,
                        Soglia_Dir_Comm_Superata__c = SottosogliaDC,
                        Soglia_Diretto_Superiore__c = SogliaSup,
                        Approvazione_per_valore_max__c=appvaloremax,
                        Approvazione_per_creazione__c=true,
                        Approvazione_per_importo_negativo__c=appnegativo,
                        RecordTypeId='0125I000000l0baQAA');
                    listApp.add(app);	
                }
            }
        }
        try{
            if(listApp.size()>0){
                insert listApp;
            }
        } catch (Exception e){
            System.debug('Si è verificato un problema: '+e.getMessage());	
        }
    }
    
    public static void aggiornaCampoCondizioniApprovazioneQuote_Update(Map<Id, Condizioni__c> newinput, Map<Id, Condizioni__c> oldinput){
        
        System.debug('dentro metodo condizioni');
        
        
        //update solo alla variazione di questi campo
        
        Boolean check = false;
        Boolean garantito = false;
        Boolean appfissoper = false;
        Boolean appvaloremax=false;
        Boolean appnegativo = false;
        
        for(Id c:newinput.keyset()){
            Condizioni__c old = oldinput.get(newinput.get(c).Id);
            If((newinput.get(c).Approvazione_importo_negativo__c == true  && old.Importo_Appoggio__c != newinput.get(c).Importo_Appoggio__c && newinput.get(c).Importo_Appoggio__c<0)
               ||(old.Min_garantito_WarrantCPQ__c != null && newinput.get(c).Min_garantito_WarrantCPQ__c == null) 
               || (old.Valore_max_WarrantCPQ__c != newinput.get(c).Valore_max_WarrantCPQ__c) 
               || old.Fisso_WarrantCPQ__c != newinput.get(c).Fisso_WarrantCPQ__c 
               || old.Percentuale_WarrantCPQ__c != newinput.get(c).Percentuale_WarrantCPQ__c){
                   check=true;
                   system.debug('Check true');
               }
            If(old.Min_garantito_WarrantCPQ__c != null && newinput.get(c).Min_garantito_WarrantCPQ__c == null && newinput.get(c).Name_Prodotto__c.contains('DRIVER')){
                garantito = true;
                system.debug('garantito true');
            }
            If(old.Fisso_WarrantCPQ__c != newinput.get(c).Fisso_WarrantCPQ__c || old.Percentuale_WarrantCPQ__c != newinput.get(c).Percentuale_WarrantCPQ__c){
                appfissoper=true;
                system.debug('fisso/percentuale true');
            }
            If((old.Valore_max_WarrantCPQ__c != newinput.get(c).Valore_max_WarrantCPQ__c)){
                appvaloremax=true;
                system.debug('valore max true');
            }
            if(newinput.get(c).Approvazione_importo_negativo__c == true && old.Importo_Appoggio__c != newinput.get(c).Importo_Appoggio__c && newinput.get(c).Importo_Appoggio__c<0){
                appnegativo=true;
                system.debug('importo negativo');
            }
        }
        
        if(check==true){
            system.debug('Modifica richiesta');
            
            User currUser = [SELECT Id, Utente_Integrazione__c FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];
            
            Map<Id,Condizioni__c> condMap = new Map<Id,Condizioni__c>([SELECT Quote_Line__r.SBQQ__Quote__c FROM Condizioni__c WHERE Id IN :newinput.keySet()]);
            
            Map<Id, Approvazioni__c> appMap = new Map<Id, Approvazioni__c>([SELECT Approvazione_per_importo_negativo__c,Condizione__r.Id, Approval_Step__c,Soglia_Commerciale_Superata__c,Soglia_Diretto_Superiore__c,Soglia_DM_Superata__c,Soglia_AM_KAM_Superata__c,Soglia_Dir_Comm_Superata__c,Approvazione_per_Fisso_o_Percentuale__c,Approvazione_per_minimo_garantito__c,Approvazione_per_valore_max__c FROM Approvazioni__c WHERE Condizione__c IN :newinput.keySet()]);
            
            Boolean stato=false;
            //Se ci sono presenti approvazioni controllo lo stato, questo punto è da confermare:
            for(id a: appMap.keyset()){
                if(appMap.get(a).Approval_Step__c == 'In attesa di approvazione'){
                    stato = true;
                }
            }
            
            List<Approvazioni__c> listApp = new List<Approvazioni__c>();
            //Prima controllo quali flag devo mettere all'approvazione poi vado a creare l'approvazione
            //Senza fare creazione e update successivo
            
            Boolean SogliaCommerciale=false;
            Boolean SogliaAMKAM=false;
            Boolean SottosogliaDM = false;
            Boolean SottosogliaDC=false;
            Boolean SogliaSup = false;
            Boolean updates = false;
            
            for(Id i:newinput.keySet()){               
                
                //Controllo Soglia Diretto Superiore
                if(garantito==true || appnegativo == true){
                    SogliaSup=true;
                }                
                //Controllo Sotto Soglia Commerciale
                if((newinput.get(i).Fisso_WarrantCPQ__c > 0 && newinput.get(i).Fisso_WarrantCPQ__c < newinput.get(i).Soglia_Commerciale_Fisso__c)
                   || (newinput.get(i).Percentuale_WarrantCPQ__c>0 && newinput.get(i).Percentuale_WarrantCPQ__c<newinput.get(i).Soglia_Commerciale_Percentuale__c)
                   ||appvaloremax == true){	
                       SogliaCommerciale=true;
                       System.debug('Soglia Commerciale');	
                   }
                //Controllo Sotto Soglia DM
                if((newinput.get(i).Fisso_WarrantCPQ__c>0 && newinput.get(i).Fisso_WarrantCPQ__c<newinput.get(i).Soglia_DM_Fisso__c)
                   || (newinput.get(i).Percentuale_WarrantCPQ__c>0 && newinput.get(i).Percentuale_WarrantCPQ__c<newinput.get(i).Soglia_DM_Percentuale__c)
                   || (appvaloremax == true && newinput.get(i).Valore_max_WarrantCPQ__c<newinput.get(i).Soglia_Valore_Max_AM__c)){		
                       SottosogliaDM=true;
                       System.debug('Soglia DM');		
                   }    
                
                
                //Controllo Sotto Soglia AM/KAM
                if((newinput.get(i).Fisso_WarrantCPQ__c>0 && newinput.get(i).Fisso_WarrantCPQ__c<newinput.get(i).Soglia_AM_KAM_Fisso__c) 
                   || (newinput.get(i).Percentuale_WarrantCPQ__c>0 && newinput.get(i).Percentuale_WarrantCPQ__c<newinput.get(i).Soglia_AM_KAM_Percentuale__c)
                   || (appvaloremax == true && newinput.get(i).Valore_max_WarrantCPQ__c<newinput.get(i).Soglia_Valore_Max_DC__c)){		
                       SogliaAMKAM=true;	
                       System.debug('Soglia AM - KAM');	
                   }
                
                
                //Controllo Sotto Soglia Direttore Commerciale    
                if((newinput.get(i).Fisso_WarrantCPQ__c>0 && newinput.get(i).Fisso_WarrantCPQ__c<newinput.get(i).Soglia_Dir_Comm_Fisso__c) 
                   || (newinput.get(i).Percentuale_WarrantCPQ__c>0 && newinput.get(i).Percentuale_WarrantCPQ__c<newinput.get(i).Soglia_Dir_Comm_Percentuale__c)){        
                       SottosogliaDC=true;
                       System.debug('Soglia DC');
                   }    
                
            }
            
            for(Id q:newinput.keySet()){
                if(newinput.get(q).WRT_Update_da_Rinnovo__c==oldinput.get(q).WRT_Update_da_Rinnovo__c && newinput.get(q).WRT_Update_da_Rinnovo__c==false){
                    system.debug('Aggiornamento Condizione Manuale');
                    if(currUser.Utente_Integrazione__c==false && (appMap.size() == 0 || stato == false ) && newinput.get(q).Controllo_Approvazioni_in_attesa__c==oldinput.get(q).Controllo_Approvazioni_in_attesa__c && newinput.get(q).Controllo_Approvazioni_in_attesa__c==false){
                        System.debug('Creo una nuova Approvazione');
                        Approvazioni__c app = new Approvazioni__c(
                            Quote__c=condMap.get(q).Quote_Line__r.SBQQ__Quote__c,
                            Approval_Step__c='In attesa di approvazione',
                            Condizione__c=newinput.get(q).Id,
                            Name='Approvazione Commerciale',
                            Soglia_Commerciale_Superata__c=SogliaCommerciale,
                            Soglia_AM_KAM_Superata__c=SogliaAMKAM,
                            Soglia_DM_Superata__c = SottosogliaDM,
                            Soglia_Dir_Comm_Superata__c = SottosogliaDC,
                            Soglia_Diretto_Superiore__c = SogliaSup,
                            Approvazione_per_Fisso_o_Percentuale__c = appfissoper,
                            Approvazione_per_minimo_garantito__c=garantito,
                            Quote_Line__c=newinput.get(q).Quote_Line__c,
                            Approvazione_per_valore_max__c=appvaloremax,
                            Approvazione_per_importo_negativo__c=appnegativo,
                            RecordTypeId='0125I000000l0baQAA');
                            if(oldinput.get(q).Fisso_WarrantCPQ__c != newinput.get(q).Fisso_WarrantCPQ__c) app.Fisso_Precedente__c = oldinput.get(q).Fisso_WarrantCPQ__c;
                            if(oldinput.get(q).Percentuale_WarrantCPQ__c != newinput.get(q).Percentuale_WarrantCPQ__c) app.Percentuale_Precedente__c = oldinput.get(q).Percentuale_WarrantCPQ__c;
                            if(oldinput.get(q).Min_garantito_WarrantCPQ__c != newinput.get(q).Min_garantito_WarrantCPQ__c) app.Min_garantito_precedente__c = (oldinput.get(q).Min_garantito_WarrantCPQ__c == null)? 0 : oldinput.get(q).Min_garantito_WarrantCPQ__c;
                            if(oldinput.get(q).Valore_max_WarrantCPQ__c != newinput.get(q).Valore_max_WarrantCPQ__c) app.Valore_max_precedente__c = (oldinput.get(q).Valore_max_WarrantCPQ__c == null)? 0 : oldinput.get(q).Valore_max_WarrantCPQ__c;
                        listApp.add(app);
                    }
                    else if(AppMap.size() != 0 && stato == true){
                        System.debug('Approvazione già presente');

                        //AGGIUNGERE MAPPATURA CAMPI VALORI PRECEDENTE LOG MODIFICHE

                        for(Id a:appMap.keySet()){
                            if(newinput.get(q).Id == appMap.get(a).Condizione__r.Id){
                                //Aggiorno le soglie solo se è cambiato qualcosa
                                if(appMap.get(a).Soglia_Commerciale_Superata__c!=SogliaCommerciale){
                                    appMap.get(a).Soglia_Commerciale_Superata__c=SogliaCommerciale;
                                    updates = true;
                                    System.debug('Aggiorno soglia commerciale');
                                }
                                If(appMap.get(a).Soglia_AM_KAM_Superata__c!=SogliaAMKAM){
                                    appMap.get(a).Soglia_AM_KAM_Superata__c=SogliaAMKAM;
                                    updates=true;
                                    system.debug('Aggiorno soglia AM');
                                }
                                if(appMap.get(a).Soglia_DM_Superata__c != SottosogliaDM){
                                    appMap.get(a).Soglia_DM_Superata__c = SottosogliaDM;
                                    updates=true;
                                    system.debug('Aggiorno soglia DM');
                                }
                                if(appMap.get(a).Soglia_Dir_Comm_Superata__c != SottosogliaDC){
                                    appMap.get(a).Soglia_Dir_Comm_Superata__c = SottosogliaDC;
                                    updates=true;
                                    system.debug('Aggiorno soglia direttore');
                                }
                                if(appfissoper == true && appMap.get(a).Approvazione_per_Fisso_o_Percentuale__c ==false){
                                    appMap.get(a).Approvazione_per_Fisso_o_Percentuale__c = appfissoper;
                                    system.debug('Aggiorno approvazione fisso o percentuale');
                                }
                                if(garantito == true && appMap.get(a).Approvazione_per_minimo_garantito__c ==false){
                                    appMap.get(a).Approvazione_per_minimo_garantito__c = garantito;
                                    system.debug('Aggiorno approvazione minimo garantito');
                                }
                                if(appvaloremax == true && appMap.get(a).Approvazione_per_valore_max__c ==false){
                                    appMap.get(a).Approvazione_per_valore_max__c = appvaloremax;
                                    system.debug('Aggiorno approvazione valore max');
                                }
                                if(appnegativo == true && appMap.get(a).Approvazione_per_importo_negativo__c ==false){
                                    appMap.get(a).Approvazione_per_importo_negativo__c = appnegativo;
                                    system.debug('Aggiorno approvazione valore max');
                                }
                                if(appMap.get(a).Soglia_Diretto_Superiore__c != SogliaSup){
                                    appMap.get(a).Soglia_Diretto_Superiore__c = SogliaSup;
                                    updates=true;
                                }
                                if(oldinput.get(q).Fisso_WarrantCPQ__c != newinput.get(q).Fisso_WarrantCPQ__c) appMap.get(a).Fisso_Precedente__c = oldinput.get(q).Fisso_WarrantCPQ__c;
                                if(oldinput.get(q).Percentuale_WarrantCPQ__c != newinput.get(q).Percentuale_WarrantCPQ__c) appMap.get(a).Percentuale_Precedente__c = oldinput.get(q).Percentuale_WarrantCPQ__c;
                                if(oldinput.get(q).Min_garantito_WarrantCPQ__c != newinput.get(q).Min_garantito_WarrantCPQ__c) appMap.get(a).Min_garantito_precedente__c = (oldinput.get(q).Min_garantito_WarrantCPQ__c == null)? 0 : oldinput.get(q).Min_garantito_WarrantCPQ__c;
                                if(oldinput.get(q).Valore_max_WarrantCPQ__c != newinput.get(q).Valore_max_WarrantCPQ__c) appMap.get(a).Valore_max_precedente__c = (oldinput.get(q).Valore_max_WarrantCPQ__c == null)? 0 : oldinput.get(q).Valore_max_WarrantCPQ__c;
                            }
                        }
                    }
                }
            }
            
            System.debug('STATO'+stato);
            System.debug('UP'+updates);
            
            If(stato==false && updates == false){
                system.debug('Creazione Approvazione');
                insert listApp;  
            } 
            If(stato==true && updates == true){
                system.debug('Aggiornamento approvazione');
                update appMap.values();
            }         
            
        }
    }
    
}