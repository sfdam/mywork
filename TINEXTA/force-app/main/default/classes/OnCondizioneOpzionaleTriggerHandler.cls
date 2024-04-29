public without sharing class OnCondizioneOpzionaleTriggerHandler {
    
    //@future(callout=true)
    public static Boolean eliminaCondizioniOpzionaliInfostore(Set<String> condizioniIds){
        if(UserInfo.getProfileId() == [SELECT Id FROM Profile WHERE Name = 'Warrant - Integration Profile'].Id)
            return false;
        
        Boolean Success = true;
        String msg = 'ok';
        String jsonString = '';
        String jsonResponse = '';
        
        try{
            
            List<String> records = new List<String>();
            // records.addAll(Utilities.getSet(condizioniPadreFinal, 'Id'));
            records.addAll(condizioniIds);
            
            
            // String payLoadAuth = 'grant_type=password' 
            //             + '&username=' + EncodingUtil.urlEncode('warranthubapi','UTF-8') 
            //             + '&password=' + EncodingUtil.urlEncode('warranthubapi', 'UTF-8');
            
            // String endPointAuth = EndpointServizi__c.getInstance().WRN_URL_SharePoint_Auth__c;
            
            // HttpRequest reqAuth = new HttpRequest();                            
            // reqAuth.setEndpoint(endPointAuth);
            // reqAuth.setMethod('POST');
            // reqAuth.setHeader('Content-Type','application/x-www-form-urlencoded');
            // reqAuth.setBody(payLoadAuth);
            
            // //Execute web service call here 
            // Http http = new Http();               
            // HTTPResponse resAuth = http.send(reqAuth);
            
            // //Helpful debug messages 
            // System.debug('--- SV AUTH ---'); 
            
            // System.debug(resAuth.toString()); 
            // System.debug('STATUS: ' + resAuth.getStatus()); 
            // System.debug('STATUS_CODE: ' + resAuth.getStatusCode()); 
            // System.debug ('HTTPResponse Body: ' + resAuth.getBody());
            
            // Map<String, Object> resAuthBody = (Map<String, Object>) JSON.deserializeUntyped(resAuth.getBody());
            // System.debug('access_token: ' + resAuthBody.get('access_token'));
            // System.debug('token_type: ' + resAuthBody.get('token_type'));
            
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
            
            HttpRequest request = new HttpRequest();
            // request.setEndpoint('https://salesforce-test.warranthub.it/v1/Wh/Delete');
            request.setEndpoint(EndpointServizi__c.getOrgDefaults().WRT_Elimina_Condizioni_CPQ_Infostore__c + records[0]);
            request.setMethod('DELETE');
            Map<String,Object> payload = new Map<String,Object>{ 'records' => records, 'object' => 'Condizioni'};
                // System.debug('@@@ payload ' + JSON.serialize(payload));
                // request.setBody(JSON.serialize(payload));
                jsonString = JSON.serialize(payload);
            System.debug('@@@ payload ' + jsonString);
            request.setBody(jsonString);
            
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
    
    // @future(callout=true)
    // public static void createCondizioniOpzionaliInfostore(Set<Id> condizioniIds){
    //     if(UserInfo.getProfileId() == [SELECT Id FROM Profile WHERE Name = 'Warrant - Integration Profile'].Id)
    //     return;
    
    //     Boolean Success = true;
    //     String msg = '';
    //     String jsonString = '';
    //     String jsonResponse = '';
    
    //     try{
    
    //         Map<Id, Condizione_Opzionale__c> condizioniOpzMap = new Map<Id, Condizione_Opzionale__c>([SELECT Id, Chiave_Esterna__c, CondizionePadre_WarrantCPQ__c, CreatedById,
    //         CreatedDate, FF_WarrantCPQ__c, Fisso_WarrantCPQ__c, Formula_Condizioni_Opzionali_Name__c, Formula_Id_Prodotto__c, Formula_Importo_WarrantCPQ__c, Formula_Quote_Line__c,
    //         IsDeleted, LastModifiedById, LastModifiedDate, Limite_WarrantCPQ__c, Massimo_WarrantCPQ__c, Min_garantito_WarrantCPQ__c, Minimo_WarrantCPQ__c, Name, 
    //         Percentuale_WarrantCPQ__c, Quote_Line__c, RecordTypeId, Tipo_WarrantCPQ__c, WRT_Tipologia_Finanziamento_FORM__c, Valore_max_WarrantCPQ__c
    //         FROM Condizione_Opzionale__c WHERE Id IN: condizioniIds ]);
    
    //         HttpRequest request = new HttpRequest();
    //         // request.setEndpoint('https://salesforce-test.warranthub.it/v1/Wh/Delete');
    //         request.setEndpoint(EndpointServizi__c.getOrgDefaults().WRT_Create_CPQ_Infostore__c);
    //         request.setMethod('POST');
    //         Map<String,Object> payload = new Map<String,Object>{ 'records' => condizioniOpzMap.values(), 'object' => 'Condizioni'};
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
    
    public static void aggiornaCampoCondizioniApprovazioneQuote_Insert(Map<Id, Condizione_Opzionale__c> newinput){
        
User currUser = [SELECT Id, Utente_Integrazione__c FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];
        
        Map<Id,Condizione_Opzionale__c> condMap = new Map<Id,Condizione_Opzionale__c>([SELECT Quote_Line__r.SBQQ__Quote__c,CondizionePadre_WarrantCPQ__r.WRT_Update_da_Rinnovo__c FROM Condizione_Opzionale__c WHERE Id IN :newinput.keySet()]);
        
        List<Approvazioni__c> listApp = new List<Approvazioni__c>();
        
        //Prima controllo quali flag devo mettere all'approvazione poi vado a creare l'approvazione
        //Senza fare creazione e update successivo
        
        Boolean SogliaCommerciale=false;
        Boolean SogliaAMKAM=false;
        Boolean SottosogliaDM = false;
        Boolean SottosogliaDC=false;       
        Boolean appvaloremax=false;
        Boolean SogliaSup = false;
        Boolean appnegativo = false;
        
        for(Id c:newinput.keyset()){
            if(newinput.get(c).Valore_max_WarrantCPQ__c != null){
                appvaloremax=true;
            }
            if(newinput.get(c).Formula_Importo_WarrantCPQ__c<0 && newinput.get(c).Approvazione_per_importo_negativo__c == true){
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
               || appvaloremax==true||(newinput.get(i).Percentuale_WarrantCPQ__c>0 && newinput.get(i).Percentuale_WarrantCPQ__c<newinput.get(i).Soglia_Commerciale_Percentuale__c)){	
                   SogliaCommerciale=true;
                   System.debug('Soglia Commerciale');	
               }
            
            
            
            //Controllo Sotto Soglia DM
            if((newinput.get(i).Fisso_WarrantCPQ__c>0 && newinput.get(i).Fisso_WarrantCPQ__c<newinput.get(i).Soglia_DM_Fisso__c)
               || (appvaloremax==true && newinput.get(i).Valore_max_WarrantCPQ__c<newinput.get(i).Soglia_Valore_Max_AM__c)||(newinput.get(i).Percentuale_WarrantCPQ__c>0 && newinput.get(i).Percentuale_WarrantCPQ__c<newinput.get(i).Soglia_DM_Percentuale__c)){		
                   SottosogliaDM=true;
                   System.debug('Sotto Soglia DM');		
               }    
            
            //Controllo Sotto Soglia AM/KAM
            if((newinput.get(i).Fisso_WarrantCPQ__c>0 && newinput.get(i).Fisso_WarrantCPQ__c<newinput.get(i).Soglia_AM_KAM_Fisso__c) 
               ||(newinput.get(i).Percentuale_WarrantCPQ__c>0 && newinput.get(i).Percentuale_WarrantCPQ__c<newinput.get(i).Soglia_AM_KAM_Percentuale__c)
               ||(appvaloremax==true && newinput.get(i).Valore_max_WarrantCPQ__c<newinput.get(i).Soglia_Valore_Max_DC__c)){		
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
            if(newinput.get(q).CondizionePadre_WarrantCPQ__r.WRT_Update_da_Rinnovo__c==false && newinput.get(q).Formula_Semaforo_Trigger__c==false){
                System.debug('Creazione Manuale');
                if(currUser.Utente_Integrazione__c==false && newinput.get(q).Controllo_Approvazioni_in_attesa__c==false){
                    System.debug('Creazione');
                    Approvazioni__c app = new Approvazioni__c(
                        Quote__c=condMap.get(q).Quote_Line__r.SBQQ__Quote__c,
                        Approval_Step__c='In attesa di approvazione',
                        Condizione_Opzionale__c=newinput.get(q).Id,
                        Name='Approvazione Commerciale',
                        Quote_Line__c=newinput.get(q).Quote_Line__c,
                        Soglia_Commerciale_Superata__c=SogliaCommerciale,
                        Soglia_AM_KAM_Superata__c=SogliaAMKAM,
                        Soglia_DM_Superata__c = SottosogliaDM,
                        Soglia_Dir_Comm_Superata__c = SottosogliaDC,
                        Approvazione_per_valore_max__c=appvaloremax,
                        Approvazione_per_creazione__c=true,
                        Approvazione_per_importo_negativo__c=appnegativo,
                        RecordTypeId='0125I000000l0baQAA');
                    listApp.add(app);	
                }
            }
        }
        //try{
        if(listApp.size()>0){
            insert listApp;
        }
        /*} catch (Exception e){
System.debug('Si è verificato un problema: '+e.getMessage());	
}*/
    }
    
    public static void aggiornaCampoCondizioniApprovazioneQuote_Update(Map<Id, Condizione_Opzionale__c> newinput, Map<Id, Condizione_Opzionale__c> oldinput){
        
        System.debug('dentro metodo condizioni opzionali');
        //update solo alla variazione di questi campi: id 98 Procedimenti/Pagamenti ma con valori specifici
        
        Boolean check = false;
        Boolean garantito = false;
        Boolean appfissoper = false;
        Boolean appminimo = false;
        Boolean appvaloremax=false;
        Boolean appnegativo = false;
        
        
        for(Id c:newinput.keyset()){
            Condizione_Opzionale__c old = oldinput.get(newinput.get(c).Id);
            If((old.Min_garantito_WarrantCPQ__c != null && newinput.get(c).Min_garantito_WarrantCPQ__c == null) 
               || old.Fisso_WarrantCPQ__c != newinput.get(c).Fisso_WarrantCPQ__c || 
               old.Percentuale_WarrantCPQ__c != newinput.get(c).Percentuale_WarrantCPQ__c ||
               (old.Valore_max_WarrantCPQ__c != newinput.get(c).Valore_max_WarrantCPQ__c)
              || (newinput.get(c).Approvazione_per_importo_negativo__c == true  && old.Formula_Importo_WarrantCPQ__c != newinput.get(c).Formula_Importo_WarrantCPQ__c && newinput.get(c).Formula_Importo_WarrantCPQ__c<0)){
                   check=true;
                   system.debug('Check true');
               }
            If(old.Min_garantito_WarrantCPQ__c != null && newinput.get(c).Min_garantito_WarrantCPQ__c == null){
                garantito = true;
                appminimo=true;
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
            if(newinput.get(c).Approvazione_per_importo_negativo__c == true && old.Formula_Importo_WarrantCPQ__c != newinput.get(c).Formula_Importo_WarrantCPQ__c && newinput.get(c).Formula_Importo_WarrantCPQ__c<0){
                appnegativo=true;
                system.debug('importo negativo');
            }
        }
        
        If(check==true){
            User currUser = [SELECT Id, Utente_Integrazione__c FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];
            
            Map<Id,Condizione_Opzionale__c> condMap = new Map<Id,Condizione_Opzionale__c>([SELECT Quote_Line__r.SBQQ__Quote__c,CondizionePadre_WarrantCPQ__r.WRT_Update_da_Rinnovo__c,CondizionePadre_WarrantCPQ__r.Quote_Line__r.SBQQ__Quote__c FROM Condizione_Opzionale__c WHERE Id IN :newinput.keySet()]);
            
            Map<Id, Approvazioni__c> appMap = new Map<Id, Approvazioni__c>([SELECT Condizione__r.Id, Approval_Step__c,Soglia_Commerciale_Superata__c,Soglia_DM_Superata__c,Soglia_AM_KAM_Superata__c,Soglia_Dir_Comm_Superata__c,Condizione_Opzionale__c,Approvazione_per_Fisso_o_Percentuale__c,Approvazione_per_minimo_garantito__c,Approvazione_per_valore_max__c FROM Approvazioni__c WHERE Condizione_Opzionale__c IN :newinput.keySet()]);
            
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
            Boolean updates = false;
            Boolean SogliaSup = false;
            
            for(Id i:newinput.keySet()){
                //Controllo Soglia Diretto Superiore
                if(garantito==true || appnegativo == true){
                    SogliaSup=true;
                }  
                
                //Controllo Sotto Soglia Commerciale
                if((newinput.get(i).Fisso_WarrantCPQ__c > 0 && newinput.get(i).Fisso_WarrantCPQ__c < newinput.get(i).Soglia_Commerciale_Fisso__c)
                   ||appvaloremax == true||(newinput.get(i).Percentuale_WarrantCPQ__c>0 && newinput.get(i).Percentuale_WarrantCPQ__c<newinput.get(i).Soglia_Commerciale_Percentuale__c)){	
                       SogliaCommerciale=true;
                       System.debug('Soglia Commerciale');	
                   }
                //Controllo Sotto Soglia DM
                if((newinput.get(i).Fisso_WarrantCPQ__c>0 && newinput.get(i).Fisso_WarrantCPQ__c<newinput.get(i).Soglia_DM_Fisso__c)
                   ||(appvaloremax == true && newinput.get(i).Valore_max_WarrantCPQ__c<newinput.get(i).Soglia_Valore_Max_AM__c) ||(newinput.get(i).Percentuale_WarrantCPQ__c>0 && newinput.get(i).Percentuale_WarrantCPQ__c<newinput.get(i).Soglia_DM_Percentuale__c)){		
                       SottosogliaDM=true;
                       System.debug('Soglia DM');		
                   }    
                
                
                //Controllo Sotto Soglia AM/KAM
                if((newinput.get(i).Fisso_WarrantCPQ__c>0 && newinput.get(i).Fisso_WarrantCPQ__c<newinput.get(i).Soglia_AM_KAM_Fisso__c) 
                   ||(appvaloremax == true && newinput.get(i).Valore_max_WarrantCPQ__c<newinput.get(i).Soglia_Valore_Max_DC__c) || (newinput.get(i).Percentuale_WarrantCPQ__c>0 && newinput.get(i).Percentuale_WarrantCPQ__c<newinput.get(i).Soglia_AM_KAM_Percentuale__c)){		
                       SogliaAMKAM=true;	
                       System.debug('Soglia AM - KAM');	
                   }
                
                
                //Controllo Sotto Soglia Direttore Commerciale    
                if((newinput.get(i).Fisso_WarrantCPQ__c>0 && newinput.get(i).Fisso_WarrantCPQ__c<newinput.get(i).Soglia_Dir_Comm_Fisso__c) 
                   ||(newinput.get(i).Percentuale_WarrantCPQ__c>0 && newinput.get(i).Percentuale_WarrantCPQ__c<newinput.get(i).Soglia_Dir_Comm_Percentuale__c)){        
                       SottosogliaDC=true;
                       System.debug('Soglia DC');
                   }    
                
            }
            
            for(Id q:newinput.keySet()){
                if(newinput.get(q).CondizionePadre_WarrantCPQ__r.WRT_Update_da_Rinnovo__c==oldinput.get(q).CondizionePadre_WarrantCPQ__r.WRT_Update_da_Rinnovo__c && newinput.get(q).CondizionePadre_WarrantCPQ__r.WRT_Update_da_Rinnovo__c==false){
                    system.debug('Aggiornamento Condizione Manuale');
                    if(currUser.Utente_Integrazione__c==false && (appMap.size() == 0 || stato == false ) && newinput.get(q).Controllo_Approvazioni_in_attesa__c==oldinput.get(q).Controllo_Approvazioni_in_attesa__c && newinput.get(q).Controllo_Approvazioni_in_attesa__c==false){
                        System.debug('Creo una nuova Approvazione');
                        Approvazioni__c app = new Approvazioni__c(
                            Quote__c=condMap.get(q).CondizionePadre_WarrantCPQ__r.Quote_Line__r.SBQQ__Quote__c,
                            Approval_Step__c='In attesa di approvazione',
                            Condizione_Opzionale__c=newinput.get(q).Id,
                            Name='Approvazione Commerciale',
                            Soglia_Commerciale_Superata__c=SogliaCommerciale,
                            Soglia_AM_KAM_Superata__c=SogliaAMKAM,
                            Soglia_DM_Superata__c = SottosogliaDM,
                            Soglia_Dir_Comm_Superata__c = SottosogliaDC,
                            Approvazione_per_Fisso_o_Percentuale__c = appfissoper,
                            Approvazione_per_minimo_garantito__c=appminimo,
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
                            if(newinput.get(q).Id == appMap.get(a).Condizione_Opzionale__c){
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
    public static void insertquoteline (List<Condizione_Opzionale__c>newinput){
        
        Set <Id> Cond = new Set<Id>();
        
        for(Condizione_Opzionale__c n: newinput){
            if(n.Quote_Line__c == null){
                system.debug('Opzionale senza QuoteLine');
                Cond.add(n.CondizionePadre_WarrantCPQ__c);
            }
        }
        
        Map<Id,Condizioni__c> MapCond = new Map<Id, Condizioni__c>([SELECT Id, Quote_Line__c
                                                                    FROM Condizioni__c
                                                                    WHERE Id IN:Cond]);
        
        
        for(Condizione_Opzionale__c i: newinput){
            for(Id x:MapCond.keyset()){
                if(i.CondizionePadre_WarrantCPQ__c == MapCond.get(x).Id){
                    system.debug('assegno la QuoteLine');
                    i.Quote_Line__c = MapCond.get(x).Quote_Line__c; 
                }
            }
        }
        
    }
    
    
    
}