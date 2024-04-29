public class OnPagamentiTriggerHandler {
    
    public static void AllineaRollupDelete (List <Pagamenti__c> input) {
        Set<Id> idquote = new Set <Id> ();
        Decimal Importo = 0;
        Decimal Stima = 0;
        
        //salvo la Quote
        for(Pagamenti__c p:input){
            idquote.add(p.Quote_Line__c);
            Importo=p.Formula_Importo_WarrantCPQ__c;
            Stima=p.Formula_Stima_WarrantCPQ__c;
        }
        system.debug('id quoteline' + idquote);
        //Mappo la Quote
        Map <Id,SBQQ__QuoteLine__c> MapQuote = new Map <Id,SBQQ__QuoteLine__c> ([SELECT Id,Non_allineare_valore_OPT_con_Pricing__c,AllineaConImporto__c,Numero_Pagamenti__c,Finanziamento_Stimato_Prodotto__c,Valore_del_pagamento_in_euro_Prodotto__c FROM SBQQ__QuoteLine__c WHERE Id IN:idquote]);
        Map<Id,Pagamenti__c> MapPag = new Map <Id,Pagamenti__c>([SELECT Id,Quote_Line__c FROM Pagamenti__c WHERE Quote_Line__c IN:idquote]);
        system.debug('Map quoteline' + MapQuote);
        
        Decimal Numero = 0;
        
        for (Id n : MapPag.keyset()) {
            Numero+= 1;
        }
        
        for(Id q:MapQuote.keyset()){
            for(Id p:MapPag.keyset()){
                If(MapQuote.get(q).Id == MapPag.get(p).Quote_Line__c){
                    //Come per Fin e Cond, non so se così va bene
                    MapQuote.get(q).Numero_Pagamenti__c = Numero-1;
                    Importo=MapQuote.get(q).Valore_del_pagamento_in_euro_Prodotto__c - Importo;
                    Stima=MapQuote.get(q).Finanziamento_Stimato_Prodotto__c - Stima;
                }
            }
            If(MapQuote.get(q).Non_allineare_valore_OPT_con_Pricing__c == false){
                MapQuote.get(q).Valore_del_pagamento_in_euro_Prodotto__c = Importo;                
            }
            MapQuote.get(q).Finanziamento_Stimato_Prodotto__c = Stima;
            If(MapQuote.get(q).AllineaConImporto__c == true && MapQuote.get(q).Non_allineare_valore_OPT_con_Pricing__c == false){
                MapQuote.get(q).SBQQ__ListPrice__c = Importo;
            } else if(MapQuote.get(q).AllineaConImporto__c == false && MapQuote.get(q).Non_allineare_valore_OPT_con_Pricing__c == false){
                MapQuote.get(q).SBQQ__ListPrice__c = Stima;
            }
        }
        
        system.debug('Numero Delete' + Numero);
        system.debug('Update Delete' + MapQuote.values());
        
        If(MapQuote.size()>0){
            SBQQ.TriggerControl.disable();
            update MapQuote.values();
            SBQQ.TriggerControl.enable();
        }
    }
    
     public static void AllineaRollupUpdate (Map <Id,Pagamenti__c> input, Map<Id, Pagamenti__c> OldPag) {
        Set<Id> idquote = new Set <Id> ();
                
        for(Id i:input.keyset()){
            if(OldPag.get(i).WRT_Update_da_Rinnovo__c == false && input.get(i).SwitchTrigger__c == OldPag.get(i).SwitchTrigger__c){
                idquote.add(input.get(i).Quote_Line__c);
            }
        }
        system.debug('id quoteline' + idquote);
        
        //Mappo la Quote Line
        Map <Id,SBQQ__QuoteLine__c> MapQuote = new Map <Id,SBQQ__QuoteLine__c> ([SELECT Id, Non_allineare_valore_OPT_con_Pricing__c,AllineaConImporto__c,Valore_del_pagamento_in_euro_Prodotto__c,Numero_Finanziamenti__c,Finanziamento_Stimato_Prodotto__c 
                                                                                    FROM SBQQ__QuoteLine__c 
                                                                                    WHERE Id IN:idquote]); 
        
        //Pagamenti correlati alla QuoteLine
        
        Map<Id,Decimal> MapImporto = new Map <Id,Decimal>();
        Map<Id,Decimal> MapStima = new Map <Id,Decimal>();
        Map<Id,Integer> MapNumero = new Map <Id,Integer>();
        
        Map<Id,Pagamenti__c> MapPag = new Map <Id,Pagamenti__c>([SELECT Id, Quote_Line__c,SwitchTrigger__c, Formula_Importo_WarrantCPQ__c,Blocco_riga_pagamento__c, Formula_Stima_WarrantCPQ__c 
                                                                FROM Pagamenti__c
                                                                WHERE Quote_Line__c IN:idquote ]);
        
        
        system.debug('Map quoteline' + MapQuote);
        system.debug('Map Pag' + MapPag);
        
        
        
        for(Id pag:MapPag.keyset()){
            If(MapPag.get(pag).Formula_Importo_WarrantCPQ__c != null && MapPag.get(pag).Blocco_riga_pagamento__c == false){
                If(MapImporto.containskey(MapPag.get(pag).Quote_Line__c)){
                    Decimal Importo = MapImporto.get(MapPag.get(pag).Quote_Line__c);
                    //commentare
                    MapImporto.put(MapPag.get(pag).Quote_Line__c,Importo+MapPag.get(pag).Formula_Importo_WarrantCPQ__c);
                }else{
                    MapImporto.put(MapPag.get(pag).Quote_Line__c, MapPag.get(pag).Formula_Importo_WarrantCPQ__c);
                }
                
            }
            If(MapPag.get(pag).Formula_Stima_WarrantCPQ__c != null && MapPag.get(pag).Blocco_riga_pagamento__c == false){
                If(MapStima.containskey(MapPag.get(pag).Quote_Line__c)){
                    Decimal Stima = MapStima.get(MapPag.get(pag).Quote_Line__c);
                    //commentare
                    MapStima.put(MapPag.get(pag).Quote_Line__c,Stima+MapPag.get(pag).Formula_Stima_WarrantCPQ__c);
                }else{
                    MapStima.put(MapPag.get(pag).Quote_Line__c, MapPag.get(pag).Formula_Stima_WarrantCPQ__c);
                }
            }
            If(MapNumero.containskey(MapPag.get(pag).Quote_Line__c)){
                Integer Numero = MapNumero.get(MapPag.get(pag).Quote_Line__c);
                //commentare
                MapNumero.put(MapPag.get(pag).Quote_Line__c,Numero+1);
            }else{
                MapNumero.put(MapPag.get(pag).Quote_Line__c, 1);
            }
        }
        
        boolean change=false;
        
        for(Id q:MapQuote.keyset()){
            
            If(MapQuote.get(q).Valore_del_pagamento_in_euro_Prodotto__c != MapImporto.get(q) && MapQuote.get(q).Non_allineare_valore_OPT_con_Pricing__c == false){
                MapQuote.get(q).Valore_del_pagamento_in_euro_Prodotto__c = MapImporto.get(q);
                system.debug('Dentro importo');
                change=true;
            }
            If(MapQuote.get(q).Non_allineare_valore_OPT_con_Pricing__c == false && MapQuote.get(q).Finanziamento_Stimato_Prodotto__c != MapStima.get(q)){
                MapQuote.get(q).Finanziamento_Stimato_Prodotto__c = MapStima.get(q);
                change=true;
                system.debug('Dentro stima');
            }
            
            if(MapPag.size()>0){
                MapQuote.get(q).Numero_Pagamenti__c = MapNumero.get(q);
                change=true;
                system.debug('Dentro numero');
            }
        }
        
        system.debug('Update' + MapQuote.values());

         
        If(MapQuote.size()>0 && MapPag.size()>0 && change==true){
            SBQQ.TriggerControl.disable();
            update MapQuote.values();
            SBQQ.TriggerControl.enable();
        }
    }
    
    public static void StimainLettere (List <Pagamenti__c> input) {
        
        List<Decimal> Stima = new List<Decimal>();
        List<Decimal> Importo = new List<Decimal>();
        String minus = '-';
        
        for(Pagamenti__c p: input){
            Stima.add(p.Formula_Stima_WarrantCPQ__c);
            Importo.add(p.Formula_Importo_WarrantCPQ__c);
        }
        
        
        for(Pagamenti__c p:input){
            for(Decimal s:Stima){
                if(p.Formula_Stima_WarrantCPQ__c == s){
                    double st = (double)s;
                    st= math.abs(st);
                    String wordText = NumberToWordversion2.convert(st);
                    system.debug(wordText);
                    If(s >0){
                        p.StimaInLettere__c=wordText;
                    }else{
                        p.StimaInLettere__c= Minus + wordText;
                    }
                }
            }
        }
        
        for(Pagamenti__c p:input){
            for(Decimal i:Importo){
                if(p.Formula_Importo_WarrantCPQ__c == i){
                    double imp = (double)i;
                    imp = math.abs(imp);
                    String ImpLettere=NumberToWordversion2.convert(imp);
                    system.debug(ImpLettere);
                    If(i>0){
                        p.Importo_in_lettere__c=ImpLettere;
                    }else{
                        p.Importo_in_lettere__c= Minus + ImpLettere; 
                    }
                }
            }
        }
    }
    
    
    
    //@future(callout=true)
    public static Boolean eliminaPagamentiInfostore(Set<String> pagamentiIds){
        if(UserInfo.getProfileId() == [SELECT Id FROM Profile WHERE Name = 'Warrant - Integration Profile'].Id)
            return false;
        
        Boolean Success = true;
        String msg = 'ok';
        String jsonString = '';
        String jsonResponse = '';
        
        try{
            List<String> records = new List<String>();
            records.addAll(pagamentiIds);
            HttpRequest request = new HttpRequest();
            //   request.setEndpoint('https://salesforce-test.warranthub.it/v1/Wh/Delete');
            request.setEndpoint(EndpointServizi__c.getOrgDefaults().WRT_Elimina_Pagamenti_CPQ_Infostore__c + records[0]);
            request.setMethod('DELETE');
            Map<String,Object> payload = new Map<String,Object>{ 'records' => pagamentiIds, 'object' => 'Pagamenti'};
                System.debug('@@@ payload ' + JSON.serialize(payload));
            //   request.setBody(JSON.serialize(payload));
            jsonString = JSON.serialize(payload);
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
            //   System.debug('@@@ response ' + response.getBody());
            
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
            Source__c = 'IntegrazioneInfoStore_DeletePagamenti',
            ErrorMessage__c = msg,
            InputPayload__c = jsonString,
            OutputPayload__c = jsonResponse
        );
        
        return Success;
    }
    
    // @future(callout=true)
    // public static void aggiornaPagamentiInfostore(Set<Id> pagamentiIds){
    //   if(UserInfo.getProfileId() == [SELECT Id FROM Profile WHERE Name = 'Warrant - Integration Profile'].Id)
    //   return;
    
    //   Boolean Success = true;
    //   String msg = '';
    //   String jsonString = '';
    //   String jsonResponse = '';
    
    //   try{
    
    //     Map<Id, Pagamenti__c> pagamentiMap = new Map<Id, Pagamenti__c>([SELECT Id, Blocco_riga_pagamento__c, Chiave_Esterna__c, Codice_Ordine_Cliente_WarrantCPQ__c,
    //     Condizione_WarrantCPQ__c, CreatedById, CreatedDate, Data_Fattura__c, Data_Ordine_Cliente__c, Descrizione_fattura_WarrantCPQ__c, FatturaCheck_WarrantCPQ__c,
    //     Formula_Id_Prodotto__c, Formula_Importo_WarrantCPQ__c, Formula_Numero_e_data_fattura__c, Formula_Numero_Pagamento__c, Formula_Stima_WarrantCPQ__c,
    //     IsDeleted, LastModifiedById, LastModifiedDate, Name, Numero_Fattura__c, Opzione_WarrantCPQ__c, Parte_WarrantCPQ__c, Percentuale_WarrantCPQ__c,
    //     Probabilita_WarrantCPQ__c, Procedimento_pagamento__c, Quote_Line__c, RecordTypeId, Scadenza_WarrantCPQ__c, Tipo_pagamento_WarrantCPQ__c, WRT_cig__c,
    //     WRT_cup__c, WRT_Stato_fatturazione__c, WRT_Stato_pagamento__c FROM Pagamenti__c WHERE Id IN: pagamentiIds]);
    
    //     // List<SObject> records = (List<SObject>) Database.query('SELECT ' + queryStringPag + ' FROM Pagamenti__c WHERE Id IN: pagamentiIds');
    
    //     // Map<String,List<SObject>> records = new Map<String,List<SObject>>{ 'records' =>}
    //     HttpRequest request = new HttpRequest();
    //     // request.setEndpoint('https://salesforce-test.warranthub.it/v1/Wh/Update');
    //     request.setEndpoint(EndpointServizi__c.getOrgDefaults().WRT_Aggiornamento_CPQ_Infostore__c);
    //     request.setMethod('PUT');
    //     Map<String,Object> payload = new Map<String,Object>{ 'records' => pagamentiMap.values(), 'object' => 'Pagamenti'};
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
    //     Source__c = 'IntegrazioneInfoStore_UpdatePagamenti',
    //     ErrorMessage__c = msg,
    //     InputPayload__c = jsonString,
    //     OutputPayload__c = jsonResponse
    //   );      
    // }
    
    // @future(callout=true)
    // public static void createPagamentiInfostore(Set<Id> pagamentiIds){
    //   if(UserInfo.getProfileId() == [SELECT Id FROM Profile WHERE Name = 'Warrant - Integration Profile'].Id)
    //   return;
    
    //   Boolean Success = true;
    //   String msg = '';
    //   String jsonString = '';
    //   String jsonResponse = '';
    
    //   try{
    
    //     Map<Id, Pagamenti__c> pagamentiMap = new Map<Id, Pagamenti__c>([SELECT Id, Blocco_riga_pagamento__c, Chiave_Esterna__c, Codice_Ordine_Cliente_WarrantCPQ__c,
    //     Condizione_WarrantCPQ__c, CreatedById, CreatedDate, Data_Fattura__c, Data_Ordine_Cliente__c, Descrizione_fattura_WarrantCPQ__c, FatturaCheck_WarrantCPQ__c,
    //     Formula_Id_Prodotto__c, Formula_Importo_WarrantCPQ__c, Formula_Numero_e_data_fattura__c, Formula_Numero_Pagamento__c, Formula_Stima_WarrantCPQ__c,
    //     IsDeleted, LastModifiedById, LastModifiedDate, Name, Numero_Fattura__c, Opzione_WarrantCPQ__c, Parte_WarrantCPQ__c, Percentuale_WarrantCPQ__c,
    //     Probabilita_WarrantCPQ__c, Procedimento_pagamento__c, Quote_Line__c, RecordTypeId, Scadenza_WarrantCPQ__c, Tipo_pagamento_WarrantCPQ__c, WRT_cig__c,
    //     WRT_cup__c, WRT_Stato_fatturazione__c, WRT_Stato_pagamento__c FROM Pagamenti__c WHERE Id IN: pagamentiIds]);
    
    //     // Map<String,List<SObject>> records = new Map<String,List<SObject>>{ 'records' =>}
    //     HttpRequest request = new HttpRequest();
    //     // request.setEndpoint('https://salesforce-test.warranthub.it/v1/Wh/Update');
    //     request.setEndpoint(EndpointServizi__c.getOrgDefaults().WRT_Create_CPQ_Infostore__c);
    //     request.setMethod('POST');
    //     Map<String,Object> payload = new Map<String,Object>{ 'records' => pagamentiMap.values(), 'object' => 'Pagamenti'};
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
    //     Source__c = 'IntegrazioneInfoStore_CreatePagamenti',
    //     ErrorMessage__c = msg,
    //     InputPayload__c = jsonString,
    //     OutputPayload__c = jsonResponse
    //   );      
    // }
    
    
    public static void setOnCondizioni(Map<Id,Pagamenti__c> input){
        //Creo mappa con solo pagamenti che rispettano le condizioni
        Map<Id,Pagamenti__c> pagamentiToUpdate = new Map<Id,Pagamenti__c>();
        for(Id i:input.keySet()){           
            if(input.get(i).Formula_Semaforo_Trigger__c==false && input.get(i).Escludi_da_template_Pag__c == false){
                switch on input.get(i).Opzione_WarrantCPQ__c {
                    when '1475143626','1475143698','1475143725','Altro' {
                        pagamentiToUpdate.put(input.get(i).Condizione_WarrantCPQ__c, input.get(i));
                    }                  
                }                                    
            }
        }    
        //Recupero le condizioni associate che dovrò aggiornare
        Map<Id,Condizioni__c> condizioniToUpdate = new Map<Id,Condizioni__c>([SELECT Condizione_con_Opzione_in_Pagamento__c FROM Condizioni__c WHERE Id IN :pagamentiToUpdate.keySet()]);
        
        //Aggiorno il campo richiesto e inserisco nel database
        for(Id i:condizioniToUpdate.keySet()){
            condizioniToUpdate.get(i).Condizione_con_Opzione_in_Pagamento__c=true;
        }
        update condizioniToUpdate.values();
    }    
    
    
    public static void setOnCondizioniup(Map<Id,Pagamenti__c> oldinput, Map<Id,Pagamenti__c> newinput){
        //Creo mappa con solo pagamenti che rispettano le condizioni
        Map<Id,Pagamenti__c> pagamentiToUpdate = new Map<Id,Pagamenti__c>();
        Map<Id,Pagamenti__c> pagamentiToUpdate2 = new Map<Id,Pagamenti__c>();
        for(Id i:newinput.keySet()){           
            if(newinput.get(i).Formula_Semaforo_Trigger__c==false && oldinput.get(i).WRT_Update_da_Rinnovo__c == false && oldinput.get(i).Opzione_WarrantCPQ__c != null && newinput.get(i).Opzione_WarrantCPQ__c==null){
                pagamentiToUpdate.put(newinput.get(i).Condizione_WarrantCPQ__c, newinput.get(i));
            }
            if(newinput.get(i).Formula_Semaforo_Trigger__c==false && oldinput.get(i).WRT_Update_da_Rinnovo__c == false){
                switch on newinput.get(i).Opzione_WarrantCPQ__c {
                    when '1475143626','1475143698','1475143725','Altro' {
                        pagamentiToUpdate2.put(newinput.get(i).Condizione_WarrantCPQ__c, newinput.get(i));
                    }                  
                }                                    
            }
        }
        //Recupero le condizioni associate che dovrò aggiornare
        Map<Id,Condizioni__c> condizioniToUpdate = new Map<Id,Condizioni__c>([SELECT Condizione_con_Opzione_in_Pagamento__c FROM Condizioni__c WHERE Id IN :pagamentiToUpdate.keySet()]);
        Map<Id,Condizioni__c> condizioniToUpdate2 = new Map<Id,Condizioni__c>([SELECT Condizione_con_Opzione_in_Pagamento__c FROM Condizioni__c WHERE Id IN :pagamentiToUpdate2.keySet()]);
        
        //Aggiorno i campi richiesti e inserisco nel database
        for(Id i:condizioniToUpdate.keySet()){
            condizioniToUpdate.get(i).Condizione_con_Opzione_in_Pagamento__c=false;            
        }
        update condizioniToUpdate.values();
        
        for(Id i:condizioniToUpdate2.keySet()){
            condizioniToUpdate2.get(i).Condizione_con_Opzione_in_Pagamento__c=true;            
        }
        update condizioniToUpdate2.values();        
    }	
    
    
    public static void updateStatoPagamento(Map<Id,Pagamenti__c> newinput, Map<Id,Pagamenti__c> oldinput){
        //Creo mappa con solo i pagamenti da processare
        Map<Id,Pagamenti__c> pagamentiToProcess = new Map<Id,Pagamenti__c>();
        for(Id i:newinput.keySet()){
            if(newinput.get(i).WRT_Stato_pagamento__c=='Pagato' && oldinput.get(i).WRT_Stato_pagamento__c!='Pagato' && oldinput.get(i).WRT_Update_da_rinnovo__c == false){
                pagamentiToProcess.put(newinput.get(i).Condizione_WarrantCPQ__c, newinput.get(i));
            }
        }
        //Recupero condizioni associate ai pagamenti da processare
        Map<Id,Condizioni__c> condizioniToProcess = new Map<Id,Condizioni__c>([SELECT Importo_Appoggio__c FROM Condizioni__c WHERE Id IN :pagamentiToProcess.keySet()]);
        
        //A questo punto gli id delle due mappe dovrebbero essere uguali e posso procedere con l'operazione
        for(Id i:pagamentiToProcess.keySet()){
            pagamentiToProcess.get(i).Importo_al_pagamento__c=(condizioniToProcess.get(i).Importo_Appoggio__c * pagamentiToProcess.get(i).Percentuale_WarrantCPQ__c)/100;
        }        
    }
    
    public static void aggiornaCampoPagamentiApprovazioneQuote_Insert(Map<Id, Pagamenti__c> newinput){
        
        //Recupero l'utente
        User currUser = [SELECT Id, Utente_Integrazione__c FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];
        
        //Recupero quote:
        Map<Id,Pagamenti__c> pagMap = new Map<Id,Pagamenti__c>([SELECT Quote_Line__r.SBQQ__Quote__c FROM Pagamenti__c WHERE Id IN :newinput.keySet()]);
        
        List<Approvazioni__c> appToUpsert = new List<Approvazioni__c>();
        
        for(Id i:newinput.keySet()){
            if(newinput.get(i).Formula_Semaforo_Trigger__c==false && newinput.get(i).WRT_Update_da_Rinnovo__c== false && newinput.get(i).Controllo_Approvazioni_in_attesa__c==false && currUser.Utente_Integrazione__c==false ){                
                Approvazioni__c app = new Approvazioni__c(
                    Quote__c=pagMap.get(i).Quote_Line__r.SBQQ__Quote__c,
                    Approval_Step__c='In attesa di approvazione',
                    Pagamento__c=newinput.get(i).Id,
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
    
    public static void aggiornaCampoPagamentiApprovazioneQuote_Update(Map<Id, Pagamenti__c> newinput, Map<Id, Pagamenti__c> oldinput){
        
        //update solo alla variazione di questi campi: id 98 Procedimenti/Pagamenti ma con valori specifici
        
        Boolean check = false;
        Boolean appproc= false;
        Boolean stato=false;
        Boolean updates=false;        
        
         for(Id c:newinput.keyset()){
            Pagamenti__c old = oldinput.get(newinput.get(c).Id);
                If(old.Approvazione_per_Proc_Pagamenti__c ==true && old.Procedimento_pagamento__c != newinput.get(c).Procedimento_pagamento__c){
                    check=true;
                system.debug('Check true');
                //metto il check qui perchè ho solo questa condizione
                appproc=true;                    
                system.debug('Change procedimento/pagamento');
            }
}

        
        if(check==true){
            //Recupero l'utente
            User currUser = [SELECT Id, Utente_Integrazione__c FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];
            
            //Recupero quote:
            Map<Id,Pagamenti__c> pagMap = new Map<Id,Pagamenti__c>([SELECT Quote_Line__r.SBQQ__Quote__c FROM Pagamenti__c WHERE Id IN :newinput.keySet()]);
            
            Map<Id, Approvazioni__c> appMap = new Map<Id, Approvazioni__c>([SELECT Id, Pagamento__c, Approvazione_per_Proc_Pagamenti__c, Approval_Step__c FROM Approvazioni__c WHERE Pagamento__c IN: newinput.keyset()]);
            
   
            List<Approvazioni__c> listApp = new List<Approvazioni__c>();
        //Se ci sono presenti approvazioni controllo lo stato
        for(id a: appMap.keyset()){
            if(appMap.get(a).Approval_Step__c == 'In attesa di approvazione'){
                stato = true;
            }
        }

        //recupero i valori delle label e api della picklsit dei pagamenti
        Schema.DescribeFieldResult stagesFR = Schema.getGlobalDescribe().get('Pagamenti__c').getDescribe().fields.getMap().get('Tipo_pagamento_WarrantCPQ__c').getDescribe();
        List<Schema.PicklistEntry> stagesPle = stagesFR.getPicklistValues();

        Map<String,String> valuesList = new Map<String,String>();

        for( Schema.PicklistEntry s : stagesPle)
        {
            valuesList.put(s.getValue(), s.getLabel());
        }             


            for(Id i:newinput.keySet()){
                system.debug('Metodo Update Pagamenti');
                //unica differenza da metodo in insert questo if --> ottimizzabile
                if((appMap.size() == 0 || stato == false ) || newinput.get(i).WRT_Update_da_Rinnovo__c==oldinput.get(i).WRT_Update_da_Rinnovo__c && newinput.get(i).WRT_Update_da_Rinnovo__c== false && newinput.get(i).Controllo_Approvazioni_in_attesa__c==false && newinput.get(i).Controllo_Approvazioni_in_attesa__c==oldinput.get(i).Controllo_Approvazioni_in_attesa__c && currUser.Utente_Integrazione__c==false){                
                    Approvazioni__c app = new Approvazioni__c(
                        Quote__c=pagMap.get(i).Quote_Line__r.SBQQ__Quote__c,
                        Approval_Step__c='In attesa di approvazione',
                        Pagamento__c=newinput.get(i).Id,
                        Name='Approvazione Commerciale',
                        Quote_Line__c=newinput.get(i).Quote_Line__c,
                        Soglia_Diretto_Superiore__c = true,
                        Approvazione_per_Proc_Pagamenti__c=appproc,
                        RecordTypeId='0125I000000l0baQAA');
                    system.debug('creazione approvazione');   
                    if(oldinput.get(i).Tipo_pagamento_WarrantCPQ__c != newinput.get(i).Tipo_pagamento_WarrantCPQ__c) app.Tipo_Pagamento_attuale__c = valuesList.get(newinput.get(i).Tipo_pagamento_WarrantCPQ__c);
                    if(oldinput.get(i).Tipo_pagamento_WarrantCPQ__c != newinput.get(i).Tipo_pagamento_WarrantCPQ__c) app.Tipo_Pagamento_precedente__c = valuesList.get(oldinput.get(i).Tipo_pagamento_WarrantCPQ__c);
                    if(oldinput.get(i).Nome_Procedimento_Pagamento__c != newinput.get(i).Nome_Procedimento_Pagamento__c) app.Procedimento_Pagamento_precedente__c = oldinput.get(i).Nome_Procedimento_Pagamento__c;
                    listApp.add(app);

                }
                else if(AppMap.size() != 0 && stato == true){
                    System.debug('Approvazione già presente');

                    //AGGIUNGERE MAPPATURA CAMPI VALORI PRECEDENTE LOG MODIFICHE

                    for(Id a:appMap.keySet()){
                        if(newinput.get(i).Id == appMap.get(a).Pagamento__c){
                            //Aggiorno solo se è cambiato qualcosa
                            if(appMap.get(a).Approvazione_per_Proc_Pagamenti__c!=appproc && appproc == true){
                                appMap.get(a).Soglia_Diretto_Superiore__c = true;
                                appMap.get(a).Approvazione_per_Proc_Pagamenti__c=appproc;
                                updates = true;
                                if(oldinput.get(i).Tipo_pagamento_WarrantCPQ__c != newinput.get(i).Tipo_pagamento_WarrantCPQ__c) appMap.get(a).Tipo_Pagamento_attuale__c = valuesList.get(newinput.get(i).Tipo_pagamento_WarrantCPQ__c);
                                if(oldinput.get(i).Tipo_pagamento_WarrantCPQ__c != newinput.get(i).Tipo_pagamento_WarrantCPQ__c) appMap.get(a).Tipo_Pagamento_precedente__c = valuesList.get(oldinput.get(i).Tipo_pagamento_WarrantCPQ__c);
                                if(oldinput.get(i).Nome_Procedimento_Pagamento__c != newinput.get(i).Nome_Procedimento_Pagamento__c) appMap.get(a).Procedimento_Pagamento_precedente__c = oldinput.get(i).Nome_Procedimento_Pagamento__c;
                                        System.debug('Aggiorno appproc');
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