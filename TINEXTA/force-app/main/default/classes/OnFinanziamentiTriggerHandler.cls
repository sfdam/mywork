public class OnFinanziamentiTriggerHandler {
    
    public static void InsertdaListino (Map <Id,Finanziamenti__c> input) {
        
        Set<Id> idproduct = new Set<Id>();
        Set<Id> idbundle = new Set<Id>();
        Set<Id> idoption = new Set<Id>();
        Set<Id> idcon = new Set <Id> ();
        Set<Id> Pag = new Set<Id>();
        boolean bun=false;
        
        // se non sto usando il pulsante di rinnovo carico i prodotti
        for (Id  fin : input.keyset()) {
            If(input.get(fin).Escludi_da_template__c == false && input.get(fin).Formula_Semaforo_Trigger__c == true){  
                idproduct.add(input.get(fin).Formula_Id_Prodotto__c);
                idoption.add(input.get(fin).Formula_Id_Bundle__c);
            }
        }
        
        
        //Mappa su Bu warrant e su prodotto
        Map<Id, Business_Area_Warrant__c> BUCondizioni = new map <Id,Business_Area_Warrant__c> ([SELECT Id,Fisso_WarrantCPQ__c,Percentuale_WarrantCPQ__c, Importo_WarrantCPQ__c,SingoloProdotto_WarrantCPQ__c, ProdottoBundle_WarrantCPQ__c,RecordTypeId, RecordType.Name FROM Business_Area_Warrant__c WHERE SingoloProdotto_WarrantCPQ__c in : idproduct]);
        Map<Id, SBQQ__ProductOption__c> Bundle = new map <Id, SBQQ__ProductOption__c> ([SELECT Id,SBQQ__ConfiguredSKU__c,SBQQ__OptionalSKU__c FROM SBQQ__ProductOption__c WHERE Id IN: idoption]);
        
        //mappe vuote per AsyncCopy
        Map<Id,Business_Area_Warrant__c> toSaveCondizioni = new Map<Id,Business_Area_Warrant__c>();
        Map<Id,SBQQ__QuoteLine__c> idquote = new Map<Id,SBQQ__QuoteLine__c>();
        Map<Id, Finanziamenti__c> idfin = new Map <Id,Finanziamenti__c>();             
        
        // se l'oggetto è tipo bundle lo segnalo con un flag
        If(Bundle.size()>0){
            bun=true;
        }
        
        //stampe di controllo
        System.debug('BuCondizioni' + BUCondizioni);
        System.debug('Bundle' + Bundle + bun);
        
        
        //Salvo i dati sulle condizioni da creare
        
        for (Id f : input.keyset()) {
            //Caso prodotto secco
            If(bun == false){
                for (Id c : BUCondizioni.keyset()) {
                    If(BuCondizioni.get(c).RecordType.Name == 'Condizioni'){
                        toSaveCondizioni.put(c,BUCondizioni.get(c));
                        idfin.put(f,input.get(f));
                    } 
                } 
            } else If(bun == true){
                //caso bundle
                for (Id bk : BuCondizioni.keyset()) {
                    for(Id p:Bundle.keyset()){
                        If(BuCondizioni.get(bk).ProdottoBundle_WarrantCPQ__c == Bundle.get(p).SBQQ__ConfiguredSKU__c && BuCondizioni.get(bk).SingoloProdotto_WarrantCPQ__c == Bundle.get(p).SBQQ__OptionalSKU__c){
                            //Caso per prodotto bundle: confronto il master
                            If(BuCondizioni.get(bk).RecordType.Name == 'Condizioni'){
                                toSaveCondizioni.put(bk,BUCondizioni.get(bk));
                                idfin.put(f,input.get(f));
                            }   
                        }
                    }
                }
            }
        }
        
        System.debug('Business Area Map Condizioni : ' + toSaveCondizioni);
        
        if(!toSaveCondizioni.isEmpty()){
            SBQQ.TriggerControl.disable();
            String s='cond';
            try {
                AsyncBUCopy executeQueueable = new AsyncBUCopy(toSaveCondizioni.keyset(),idquote.keyset(),s,idfin.keyset(),idcon,pag);  //PASSO IL SET AD ASYNCEXE
                ID jobID = System.enqueueJob(executeQueueable);
                System.debug('Condizioni jobID : ' + jobID);
            }finally{
                SBQQ.TriggerControl.enable();
            }
        }   
        
    }
    
    
    public static void AllineaRollupInsert (List <Finanziamenti__c> input) {
        Set<Id> idquote = new Set <Id> ();
        Decimal Importo = 0;
        Decimal Stima = 0;
        
        Decimal totale = 0 ;
        
        //salvo la Quote
        
        for(Finanziamenti__c fi :input){
            //Escludo i rinnovi in insert, basta il calcolo in update
            If(fi.Escludi_da_template__c == false && fi.Formula_Semaforo_Trigger__c == false && fi.WRT_Update_da_Rinnovo__c == false){
                idquote.add(fi.Quote_Line__c);
                
            }
        }
        system.debug('id quoteline' + idquote);
        //Mappo la Quote
        
        
        Map <Id,SBQQ__QuoteLine__c> MapQuote = new Map <Id,SBQQ__QuoteLine__c> ([SELECT Id,Non_allineare_valore_OPT_con_Pricing__c,WRT_Totale_beneficio_cliente__c,Valore_del_pagamento_in_euro_Prodotto__c,Numero_Finanziamenti__c,Finanziamento_Stimato_Prodotto__c FROM SBQQ__QuoteLine__c WHERE Id IN:idquote]);
        Map <Id, Finanziamenti__c> MapFin = new Map <Id, Finanziamenti__c> ([SELECT Id,Name, Importo_WarrantCPQ__c,Quote_Line__c FROM Finanziamenti__c WHERE Quote_Line__c IN:idquote]);    
        
        system.debug('Map quoteline' + MapQuote.values());
        //system.debug('Map Fin' + MapFin.values());
        
        Decimal Numero = 0;
        
        for (Id f : MapFin.keyset()) {
            if (MapFin.get(f).Importo_WarrantCPQ__c != null){
                totale += MapFin.get(f).Importo_WarrantCPQ__c;
            }
            Numero += 1; 
        }
        
        
        for(Id q:MapQuote.keyset()){
            
            If(MapQuote.get(q).Non_allineare_valore_OPT_con_Pricing__c  == false){ 
                MapQuote.get(q).WRT_Totale_beneficio_cliente__c = totale;
            }
            MapQuote.get(q).Numero_Finanziamenti__c = Numero;
            
        }  
        
        system.debug('Insert' + MapQuote.values());
        
        IF(MapQuote.size() >0){
            SBQQ.TriggerControl.disable();
            update MapQuote.values();
            SBQQ.TriggerControl.enable();
        }
    }
    
    public static void AllineaRollupUpdate ( Map<Id,Finanziamenti__c> oldinput, Map <Id,Finanziamenti__c> newinput) {
        
        Set<Id> idquoteline = new Set <Id> ();
        Decimal Importo = 0;
        Decimal Stima = 0;
        Decimal totale = 0 ;
        
        //salvo la Quoteline
        
        for(Id f: newinput.keySet()){
            Finanziamenti__c oldfin= oldinput.get(newinput.get(f).Id);
            if(((newinput.get(f).Importo_WarrantCPQ__c != oldfin.Importo_WarrantCPQ__c)||(newinput.get(f).Stima_WarrantCPQ__c != oldfin.Stima_WarrantCPQ__c)) && oldfin.WRT_Update_da_Rinnovo__c == false ){
                idquoteline.add(newinput.get(f).Quote_Line__c);
            }
        }
        
        system.debug('id quoteline' + idquoteline);
        //Mappo la Quoteline
        Map <Id,SBQQ__QuoteLine__c> MapQuoteline = new Map <Id,SBQQ__QuoteLine__c> ([SELECT Id,Non_allineare_valore_OPT_con_Pricing__c,WRT_Totale_beneficio_cliente__c,Valore_del_pagamento_in_euro_Prodotto__c,Numero_Finanziamenti__c,Finanziamento_Stimato_Prodotto__c FROM SBQQ__QuoteLine__c WHERE Id IN:idquoteline ]);
        Map <Id, Finanziamenti__c> MapFin = new Map <Id, Finanziamenti__c>([SELECT Id, Importo_WarrantCPQ__c FROM Finanziamenti__c WHERE Quote_Line__c IN: idquoteline]);
        system.debug('Map quoteline' + MapQuoteline);
        system.debug('MapFin' + MapFin);
        
        for(Id fin:MapFin.keyset()){
            If(MapFin.get(fin).Importo_WarrantCPQ__c != null){
                totale+=MapFin.get(fin).Importo_WarrantCPQ__c;
            }
        }
        boolean check=false;
        
        for(Id q:MapQuoteline.keyset()){
            If(MapQuoteline.get(q).Non_allineare_valore_OPT_con_Pricing__c ==false){
                MapQuoteline.get(q).WRT_Totale_beneficio_cliente__c = totale; 
                check=true;
            }
        }
        
        system.debug('Update' + MapQuoteline.values());
        
        If(MapQuoteline.size()>0 && check==true){
            SBQQ.TriggerControl.disable();
            update MapQuoteline.values();
            SBQQ.TriggerControl.enable();
        }
    }
    
    public static void AllineaRollupDelete (List <Finanziamenti__c> input) {
        Set<Id> idquote = new Set <Id> ();
        Decimal Importo = 0;
        Decimal Stima = 0;
        Decimal totale = 0;
        Decimal Numero = 0;
        
        
        for(Finanziamenti__c f:input){
            If(f.Importo_WarrantCPQ__c != null){
                idquote.add(f.Quote_Line__c);
            }
        }
        system.debug('id quoteline' + idquote);
        //Mappo la Quote
        Map <Id,SBQQ__QuoteLine__c> MapQuote = new Map <Id,SBQQ__QuoteLine__c> ([SELECT Id,Non_allineare_valore_OPT_con_Pricing__c,Valore_del_pagamento_in_euro_Prodotto__c,Numero_Finanziamenti__c,Finanziamento_Stimato_Prodotto__c,WRT_Totale_beneficio_cliente__c FROM SBQQ__QuoteLine__c WHERE Id IN:idquote]);
        Map <Id, Finanziamenti__c> MapFin = new Map <Id, Finanziamenti__c>([SELECT Id, Importo_WarrantCPQ__c, Quote_Line__c FROM Finanziamenti__c WHERE Quote_Line__c IN: idquote]);
        //Aggiorno prima del delete
        
        for (Id f : MapFin.keyset()) {
            if (MapFin.get(f).Importo_WarrantCPQ__c != null){
                totale += MapFin.get(f).Importo_WarrantCPQ__c ;          
            }
            Numero=Numero + 1;
        }
        system.debug('Map quoteline' + MapQuote);
        
        for(Id q:MapQuote.keyset()){
            for(Id fin:MapFin.keyset()){
                If(MapQuote.get(q).Id == MapFin.get(fin).Quote_Line__c){
                    //non sono convintissima di questa parte del Numero Finanziamento (funziona con pricing ma non saprei con IS o Dataloader)
                    MapQuote.get(q).Numero_Finanziamenti__c = Numero -1;
                    if(MapQuote.get(q).Non_allineare_valore_OPT_con_Pricing__c  == false && MapFin.get(fin).Importo_WarrantCPQ__c!= null ){
                        MapQuote.get(q).WRT_Totale_beneficio_cliente__c = totale - MapFin.get(fin).Importo_WarrantCPQ__c;
                    }
                }
            }
        }
        
        system.debug('Numero' + Numero);
        system.debug('Update' + MapQuote.values());
        
        If(MapQuote.size()>0){
            SBQQ.TriggerControl.disable();
            update MapQuote.values();
            SBQQ.TriggerControl.enable();
        }
        
    }
    
    //TODO: Delete
    // @future(callout=true)
    // public static void eliminaFinanziamentiInfostore(Set<String> finanziamentiIds){
    //   if(UserInfo.getProfileId() == [SELECT Id FROM Profile WHERE Name = 'Warrant - Integration Profile'].Id)
    //   return;
    
    //   Boolean Success = true;
    //   String msg = '';
    //   String jsonString = '';
    //   String jsonResponse = '';
    //   try{
    
    //     List<String> records = new List<String>();
    //     records.addAll(finanziamentiIds);
    //     HttpRequest request = new HttpRequest();
    //     // request.setEndpoint('https://salesforce-test.warranthub.it/v1/Wh/Delete');
    //     // request.setEndpoint(EndpointServizi__c.getOrgDefaults().WRT_Elimina_Finanziamenti_CPQ_Infostore__c + records[0]);
    //     request.setMethod('DELETE');
    //     Map<String,Object> payload = new Map<String,Object>{ 'records' => finanziamentiIds, 'object' => 'Finanziamenti'};
    //     // System.debug('@@@ payload ' + JSON.serialize(payload));
    //     jsonString = JSON.serialize(payload);
    //     request.setBody(jsonString);
    //     // request.setBody(JSON.serialize(payload));
    
    //     date myDate  = date.today();
    //     String month = String.valueOf(myDate.month());
    //     String year  = String.valueOf(myDate.year());
    //     String day   = String.valueOf(myDate.day());
    
    //     String keyIntegrazioneInfoStore = EndpointServizi__c.getInstance().WRN_Key_IntegrazioneInfoStore__c;
    //     String output = encodingUtil.base64Encode(Blob.valueof(keyIntegrazioneInfoStore + year + (month.length() <= 1 ? ('0' + month) : month) + (day.length() <= 1 ? ('0' + day) : day)));
    //     JWT jwt = new JWT('HS256'); 
    //     jwt.userEmail = UserInfo.getUserEmail();
    
    //     jwt.privateKey = output; 
    //     // jwt.iss = 'your issuer'; 
    //     // jwt.sub = 'some subject'; 
    //     // jwt.aud = 'some audience'; 
    //     String token = jwt.issue();        
    //     system.debug ('token: '+ token);
    //     request.setHeader('Content-type', 'application/json');
    //     request.setHeader('Authorization', 'Bearer ' + token);
    //     request.setTimeout(90000);
    //     HttpResponse response = new Http().send(request);
    //     // System.debug('@@@ response ' + response.getBody());
    
    //     jsonResponse = response.getBody();
    //     System.debug('@@@ response ' + jsonResponse);
    
    //   } catch (Exception e){
    //       System.debug('@@@ error ' + e.getMessage() + ' -- ' + e.getStackTraceString());
    //       Success = false;
    //       msg = e.getMessage() + ' -- ' + e.getStackTraceString();
    //   }
    
    //   insert new Log__c(
    //     Success__c = success,
    //     Societa__c = 'WarrantHub',
    //     Source__c = 'IntegrazioneInfoStore_DeleteFinanziamenti',
    //     ErrorMessage__c = msg,
    //     InputPayload__c = jsonString,
    //     OutputPayload__c = jsonResponse
    //   );
    // }
    
    public static Boolean eliminaFinanziamentiRelated(Id finanziamentoId){
        if(UserInfo.getProfileId() == [SELECT Id FROM Profile WHERE Name = 'Warrant - Integration Profile'].Id)
            return false;
        
        Boolean Success = true;
        String msg = 'ok';
        String jsonString = '';
        String jsonResponse = '';
        
        try{
            
            //Recupero tutte le righe sotto questa condizione
            Map<Id,Finanziamenti__c> finanziamento = new Map<Id,Finanziamenti__c>([SELECT Id FROM Finanziamenti__c WHERE Id =: finanziamentoId]);
            Map<Id,Condizioni__c> condizioni = new Map<Id,Condizioni__c>([SELECT Id FROM Condizioni__c WHERE Finanziamento__c =: finanziamentoId]);
            Map<Id,Condizione_Opzionale__c> opzionali = new Map<Id,Condizione_Opzionale__c>([SELECT Id FROM Condizione_Opzionale__c WHERE CondizionePadre_WarrantCPQ__c IN: condizioni.keySet()]);
            Map<Id,Pagamenti__c> pagamenti = new Map<Id,Pagamenti__c>([SELECT Id FROM Pagamenti__c WHERE Condizione_WarrantCPQ__c IN: condizioni.keySet()]);
            Map<String,List<String>> payload = new Map<String,List<String>>();
            payload.put('Finanziamenti', Utilities.toList(Utilities.keyBy(finanziamento.values(), 'Id').keySet()));
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
            Source__c = 'IntegrazioneInfoStore_DeleteFinanziamenti',
            ErrorMessage__c = msg,
            InputPayload__c = jsonString,
            OutputPayload__c = jsonResponse
        );
        
        return Success;
    }
    
    // @future(callout=true)
    // public static void aggiornaFinanziamentiInfostore(Set<Id> finanziamentiIds){
    //   if(UserInfo.getProfileId() == [SELECT Id FROM Profile WHERE Name = 'Warrant - Integration Profile'].Id)
    //   return;
    
    //   Boolean Success = true;
    //   String msg = '';
    //   String jsonString = '';
    //   String jsonResponse = '';
    
    //   try{
    
    //     Map<Id, Finanziamenti__c> finanziamentiMap = new Map<Id, Finanziamenti__c>([SELECT Id, Chiave_Esterna__c, CreatedById, CreatedDate, Fattura_WarrantCPQ__c,
    //     Importo_WarrantCPQ__c, IsDeleted, LastModifiedById, LastModifiedDate, Name, Quote__c, Quote_Line__c, RecordTypeId, Stima_WarrantCPQ__c, Tipologia_Finanziamento_WarrantCPQ__c 
    //     FROM Finanziamenti__c WHERE Id IN: finanziamentiIds]);
    
    //     // Map<String,List<SObject>> records = new Map<String,List<SObject>>{ 'records' =>}
    //     HttpRequest request = new HttpRequest();
    //     // request.setEndpoint('https://salesforce-test.warranthub.it/v1/Wh/Update');
    //     request.setEndpoint(EndpointServizi__c.getOrgDefaults().WRT_Aggiornamento_CPQ_Infostore__c);
    //     request.setMethod('PUT');
    //     Map<String,Object> payload = new Map<String,Object>{ 'records' => finanziamentiMap.values(), 'object' => 'Finanziamenti'};
    //     // request.setBody(JSON.serialize(payload));
    //     jsonString = JSON.serialize(payload);
    //     request.setBody(jsonString);
    
    //     date myDate  = date.today();
    //     String month = String.valueOf(myDate.month());
    //     String year  = String.valueOf(myDate.year());
    //     String day   = String.valueOf(myDate.day());
    
    //     String keyIntegrazioneInfoStore = EndpointServizi__c.getInstance().WRN_Key_IntegrazioneInfoStore__c;
    //     String output = encodingUtil.base64Encode(Blob.valueof(keyIntegrazioneInfoStore + year + (month.length() <= 1 ? ('0' + month) : month) + (day.length() <= 1 ? ('0' + day) : day)));
    //     JWT jwt = new JWT('HS256'); 
    //     jwt.userEmail = UserInfo.getUserEmail();
    
    //     jwt.privateKey = output; 
    //     // jwt.iss = 'your issuer'; 
    //     // jwt.sub = 'some subject'; 
    //     // jwt.aud = 'some audience'; 
    //     String token = jwt.issue();        
    //     system.debug ('token: '+ token);
    //     request.setHeader('Authorization', 'Bearer ' + token);
    
    //     HttpResponse response = new Http().send(request);
    //     // System.debug('@@@ response ' + response.getBody());
    //     jsonResponse = response.getBody();
    //     System.debug('@@@ response ' + jsonResponse);
    
    //   } catch (Exception e){
    //       System.debug('@@@ error ' + e.getMessage() + ' -- ' + e.getStackTraceString());
    //       Success = false;
    //       msg = e.getMessage() + ' -- ' + e.getStackTraceString();
    //   }
    
    //   insert new Log__c(
    //     Success__c = success,
    //     Societa__c = 'WarrantHub',
    //     Source__c = 'IntegrazioneInfoStore_UpdateFinanziamenti',
    //     ErrorMessage__c = msg,
    //     InputPayload__c = jsonString,
    //     OutputPayload__c = jsonResponse
    //   );
    // }
    
    // @future(callout=true)
    // public static void createFinanziamentiInfostore(Set<Id> finanziamentiIds){
    //   if(UserInfo.getProfileId() == [SELECT Id FROM Profile WHERE Name = 'Warrant - Integration Profile'].Id)
    //   return;
    
    //   Boolean Success = true;
    //   String msg = '';
    //   String jsonString = '';
    //   String jsonResponse = '';
    
    //   try{
    
    //     Map<Id, Finanziamenti__c> finanziamentiMap = new Map<Id, Finanziamenti__c>([SELECT Id, Chiave_Esterna__c, CreatedById, CreatedDate, Fattura_WarrantCPQ__c,
    //     Importo_WarrantCPQ__c, IsDeleted, LastModifiedById, LastModifiedDate, Name, Quote__c, Quote_Line__c, RecordTypeId, Stima_WarrantCPQ__c, Tipologia_Finanziamento_WarrantCPQ__c 
    //     FROM Finanziamenti__c WHERE Id IN: finanziamentiIds]);
    
    //     // Map<String,List<SObject>> records = new Map<String,List<SObject>>{ 'records' =>}
    //     HttpRequest request = new HttpRequest();
    //     // request.setEndpoint('https://salesforce-test.warranthub.it/v1/Wh/Update');
    //     request.setEndpoint(EndpointServizi__c.getOrgDefaults().WRT_Create_CPQ_Infostore__c);
    //     request.setMethod('POST');
    //     Map<String,Object> payload = new Map<String,Object>{ 'records' => finanziamentiMap.values(), 'object' => 'Finanziamenti'};
    //     // request.setBody(JSON.serialize(payload));
    //     jsonString = JSON.serialize(payload);
    //     request.setBody(jsonString);
    
    //     date myDate  = date.today();
    //     String month = String.valueOf(myDate.month());
    //     String year  = String.valueOf(myDate.year());
    //     String day   = String.valueOf(myDate.day());
    
    //     String keyIntegrazioneInfoStore = EndpointServizi__c.getInstance().WRN_Key_IntegrazioneInfoStore__c;
    //     String output = encodingUtil.base64Encode(Blob.valueof(keyIntegrazioneInfoStore + year + (month.length() <= 1 ? ('0' + month) : month) + (day.length() <= 1 ? ('0' + day) : day)));
    //     JWT jwt = new JWT('HS256'); 
    //     jwt.userEmail = UserInfo.getUserEmail();
    
    //     jwt.privateKey = output; 
    //     // jwt.iss = 'your issuer'; 
    //     // jwt.sub = 'some subject'; 
    //     // jwt.aud = 'some audience'; 
    //     String token = jwt.issue();        
    //     system.debug ('token: '+ token);
    //     request.setHeader('Authorization', 'Bearer ' + token);
    
    //     HttpResponse response = new Http().send(request);
    //     // System.debug('@@@ response ' + response.getBody());
    
    //     jsonResponse = response.getBody();
    //     System.debug('@@@ response ' + jsonResponse);
    
    //   } catch (Exception e){
    //       System.debug('@@@ error ' + e.getMessage() + ' -- ' + e.getStackTraceString());
    //       Success = false;
    //       msg = e.getMessage() + ' -- ' + e.getStackTraceString();
    //   }
    
    //   insert new Log__c(
    //     Success__c = success,
    //     Societa__c = 'WarrantHub',
    //     Source__c = 'IntegrazioneInfoStore_CreateFinanziamenti',
    //     ErrorMessage__c = msg,
    //     InputPayload__c = jsonString,
    //     OutputPayload__c = jsonResponse
    //   );      
    // }
    
    
    public static void aggiornaCampoFinanziamentoApprovazioneQuote_Insert(Map<Id, Finanziamenti__c> newinput){
        
        //Recupero l'utente:
        User currUser = [SELECT Id, Utente_Integrazione__c FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];
        
        //Recupero Finanziamento:
        Map<Id,Finanziamenti__c> finMap = new Map<Id,Finanziamenti__c>([SELECT Quote_Line__r.SBQQ__Quote__c FROM Finanziamenti__c WHERE Id IN :newinput.keySet()]);
        
        //Lista approvazioni e finanziamenti da inserire a DB:
        List<Approvazioni__c> appToUpsert = new List<Approvazioni__c>();
        
        for(Id i:newinput.keySet()){
            System.debug('Metodo Insert Approvazione');
            if(newinput.get(i).Controllo_Approvazioni_in_attesa__c==false && currUser.Utente_Integrazione__c==false && newinput.get(i).WRT_Update_da_Rinnovo__c==false &&newinput.get(i).Formula_Semaforo_Trigger__c==false){
                system.debug('Dentro if approvazione');            
                Approvazioni__c app = new Approvazioni__c(
                    Quote__c=finMap.get(i).Quote_Line__r.SBQQ__Quote__c,
                    Approval_Step__c='In attesa di approvazione',
                    Finanziamento__c=newinput.get(i).Id,
                    Name='Approvazione Commerciale',
                    Quote_Line__c=newinput.get(i).Quote_Line__c,
                    Soglia_AM_KAM_Superata__c=true,
                    Soglia_Commerciale_Superata__c=true,
                    Soglia_Dir_Comm_Superata__c=true,
                    Soglia_DM_Superata__c=true,
                    Approvazione_per_creazione__c=true,
                    RecordTypeId='0125I000000l0baQAA');
                appToUpsert.add(app);               
                
            } 
        }
        
        If(appToUpsert.size()>0){
            insert appToUpsert;
        }
        
    }
    
    //non ci sono campi di finanziamento che necessitano di tracciare la modifica    
    /* public static void aggiornaCampoFinanziamentoApprovazioneQuote_Update(Map<Id, Finanziamenti__c> newinput, Map<Id, Finanziamenti__c> oldinput){

System.debug('dentro metodo finanziamenti');
//update solo alla variazione di questi campi: esempio copiato da condizioni

Boolean check = false;
for(Id c:newinput.keyset()){
Condizioni__c old = oldinput.get(newinput.get(c).Id);
If(old.Fisso_WarrantCPQ__c != newinput.get(c).Fisso_WarrantCPQ__c || old.Percentuale_WarrantCPQ__c != newinput.get(c).Percentuale_WarrantCPQ__c){
check=true;
system.debug('Check true');
}
}

if(check==true){

//Recupero l'utente:
User currUser = [SELECT Id, Utente_Integrazione__c FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];

//Recupero quote:
Map<Id,Finanziamenti__c> finMap = new Map<Id,Finanziamenti__c>([SELECT Quote_Line__r.SBQQ__Quote__c FROM Finanziamenti__c WHERE Id IN :newinput.keySet()]);

//Recupero se ci sono approvazioni in attesa:
Map<Id, Approvazioni__c> appr = new Map<Id, Approvazioni__c>([SELECT Finanziamento__r.Id, Approval_Step__c FROM Approvazioni__c WHERE Finanziamento__c IN :newinput.keySet()]);

//Lista approvazioni da inserire a DB:
List<Approvazioni__c> appToUpsert = new List<Approvazioni__c>();

for(Id i:newinput.keySet()){
//il metodo in update è spezzato da quello in insert solo per questo If --> ottimizzabile ma in una fase 3
if(appr.size()== 0 && newinput.get(i).Controllo_Approvazioni_in_attesa__c==false && newinput.get(i).Formula_Semaforo_Trigger__c==false && newinput.get(i).Controllo_Approvazioni_in_attesa__c==oldinput.get(i).Controllo_Approvazioni_in_attesa__c && currUser.Utente_Integrazione__c==false && newinput.get(i).WRT_Update_da_Rinnovo__c==false && newinput.get(i).WRT_Update_da_Rinnovo__c==oldinput.get(i).WRT_Update_da_Rinnovo__c){
System.debug('dentro if');
Approvazioni__c app = new Approvazioni__c(
Quote__c=finMap.get(i).Quote_Line__r.SBQQ__Quote__c,
Approval_Step__c='In attesa di approvazione',
Finanziamento__c=newinput.get(i).Id,
Name='Approvazione Commerciale',
Quote_Line__c=newinput.get(i).Quote_Line__c,
Soglia_AM_KAM_Superata__c=true,
Soglia_Commerciale_Superata__c=true,
Soglia_Dir_Comm_Superata__c=true,
Soglia_DM_Superata__c=true,
RecordTypeId='0125I000000l0baQAA');
appToUpsert.add(app);

}
}


if(appToUpsert.size()>0){
insert appToUpsert;     
}       
}
}*/
}