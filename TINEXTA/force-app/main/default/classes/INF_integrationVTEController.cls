//SM - TEN - Integrazione Salesforce - VTE Creazione Ticket
public class INF_integrationVTEController {

    public static final String VTE_ELEMENTTYPE_HELPDESK = 'HelpDesk';
    // public static final List<String> famigliaProdottoINF = new List<String>{'LEGALMAIL', 'LEGALCERT', 'LEGALINVOICE', 'LEGALDOC', 'INFOCERTID', 'ALTRO'};

    /* @description alla creazione di un caso in Salesforce, viene eseguita una chiamata a VTE per aprire un ticket sul sistema
    *  @param cases - contiene la lista di case da aprire su VTE
    * 
    */
    // @future(callout=true)
    @AuraEnabled
    public static String createTicketVTE(Id caseId){

        Boolean success = true;
        String input = '';
        String output = '';

        try{

            Case c = [SELECT Id, VTE_email_cliente__c, /*Opportunity__r.Account.PEC__c,*/ Opportunity__r.Name, Opportunity__r.OpportunityNumber__c, Opportunity__r.Codice_Cliente__r.Name,/*Opportunity__r.Account.Codice_Cliente_X3__c,*/ Contact.Name, Owner.Name, VTE_email_commerciale__c, Opportunity__r.Account.Codice_Unico_Tinexta__c, Priority, Description, VTE_Commenti_Interni__c, VTE_fascicolo__c, Id_Ticket_VTE__c, VTE_famiglia__c, VTE_product__c, Opportunity__r.AccountId, Opportunity__r.Account.Name FROM Case WHERE Id =: caseId];

            User u = [SELECT Id, Societa__c FROM User WHERE Id =: UserInfo.getUserId()];
            String keyDT = u.Societa__c + '- ' + c.Opportunity__r.AccountId;
            List<Dati_Di_Contatto__c> dtL = new List<Dati_Di_Contatto__c>([SELECT Id, PEC__c, Account__c FROM Dati_Di_Contatto__c WHERE TXT_Societa_di_riferimento__c =: keyDT]);
            // System.debug('@@@ cases ' + cases);
            // if(case.isEmpty())
            //     return '';

            // List<Contact> cnt = new List<Contact>([SELECT Id, Name FROM Contact WHERE AccountId =: cases[0].Opportunity__r.AccountId AND RecordType.DeveloperName = 'Infocert_Sixtema' LIMIT 1]);

            // string contactname = '';
            // if(!cnt.isEmpty())
            //     contactname = cnt[0].Name;

            Blob headerValue = Blob.valueOf(EndpointServizi__c.getOrgDefaults().INF_Username_VTE__c + ':' + EndpointServizi__c.getOrgDefaults().INF_Access_Key_VTE__c);
            String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue);

            HttpRequest request = new HttpRequest();
            request.setHeader('Authorization', authorizationHeader);
            request.setHeader('Content-Type', 'application/json');
            request.setEndpoint(EndpointServizi__c.getOrgDefaults().INF_Url_VTE__c + 'create');
            request.setMethod('POST');
            request.setTimeout(90000);

            // for(Case c : cases){
                VTECreateWrapper payload = new VTECreateWrapper();
                payload.elementType = VTE_ELEMENTTYPE_HELPDESK;
                payload.element = JSON.serialize(doMappingCaseVTE(c, !dtL.isEmpty() ? dtL[0].PEC__c : '')); //Da serializzare in string
                System.debug('@@@ payload ' + JSON.serialize(payload));
                request.setBody(JSON.serialize(payload));

                HttpResponse httpresponse = new Http().send(request);
                System.debug('@@@ httpresponse ' + httpresponse.getBody());

                VTECreateResponse response = (VTECreateResponse)JSON.deserialize(httpresponse.getBody(), VTECreateResponse.Class);
                System.debug('@@@ response ' + JSON.serialize(response));
                c.Id_Ticket_VTE__c = response.data.id;

                //Allego il campo commenti interni
                // VTECreateWrapper payloadComments = new VTECreateWrapper();
                // payloadComments.elementType = 'ModComments';
                // payloadComments.element = JSON.serialize(doMappingCommentVTE(response.data.id, c));

                // System.debug('@@@ payloadComments ' + JSON.serialize(payloadComments));
                // request.setBody(JSON.serialize(payloadComments));
                String responseComment = '';
                if(c.VTE_Commenti_Interni__c != null){
                    request.setBody('');
                    request.setEndpoint(EndpointServizi__c.getOrgDefaults().INF_Url_VTE_Commenti__c+'username='+EndpointServizi__c.getOrgDefaults().INF_Username_VTE__c+'&password='+EndpointServizi__c.getOrgDefaults().INF_Access_Key_VTE__c+'&recordid='+response.data.id.substring(2)+'&comment='+c.VTE_Commenti_Interni__c.replaceAll(' ', '&'));

                    httpresponse = new Http().send(request);
                    System.debug('@@@ httpresponse ' + httpresponse.getBody());
                    responseComment = httpresponse.getBody();
                }

                if(response.status != 200 || (responseComment != 'SUCCESS' && c.VTE_Commenti_Interni__c != null))
                    success = false;

                //response = (VTECreateResponse)JSON.deserialize(httpresponse.getBody(), VTECreateResponse.Class);
                //System.debug('@@@ response ' + JSON.serialize(response));
            // }

            update c;

            input = JSON.serialize(payload);
            output = httpresponse.getBody();

        }catch(Exception e){
            System.debug('@@@ e ' + e.getMessage());
            success = false;
            output = e.getMessage();
            // return e.getMessage();
        }

        Log__c l = new Log__c(
            Source__c = 'TicketVTE',
            InputPayload__c = input,
            OutputPayload__c = output,
            Success__c = success
        );

        insert l;

        return success ? 'ok' : output;
    }

    public static Map<string,object> doMappingCaseVTE(Case c, String PEC){
        Map<String,Object> ticketMap = new Map<String,Object>();

        if(c != null){
            //Mapping tra Case e ticket VTE
            ticketMap.put('cli_for', 'Top Client'); //Fisso
            ticketMap.put('canale_contatto', 'Salesforce'); //Fisso
            ticketMap.put('riferimento_esterno', c.Id);
            ticketMap.put('contatto_nome', c.Contact?.Name);
            ticketMap.put('contatto_email', c.VTE_email_commerciale__c);
            // ticketMap.put('codice_cliente', c.Opportunity__r.Account.Codice_Cliente_X3__c);
            ticketMap.put('codice_cliente', c.Opportunity__r.Codice_Cliente__r.Name);
            ticketMap.put('external_code', c.Opportunity__r.Account.Codice_Unico_Tinexta__c);
            ticketMap.put('tt_accountname', c.Opportunity__r.Account.Name);
            ticketMap.put('email_richiesta', c.VTE_email_cliente__c);
            ticketMap.put('ticketstatus', 'LBL_ADVANCED_STATUS'); //Fisso
            ticketMap.put('ckdom01', c.VTE_famiglia__c);
            ticketMap.put('ckdom01_0', c.VTE_product__c);
            ticketMap.put('ticketpriorities', c.Priority == 'Media' ? null : c.Priority);
            ticketMap.put('description', c.Description);
            ticketMap.put('fascicolo', c.VTE_fascicolo__c);
            ticketMap.put('denominazione', c.Opportunity__r.Account.Name);
            // ticketMap.put('tt_email', c.Opportunity__r.Account.PEC__c);
            ticketMap.put('tt_email', PEC);
            ticketMap.put('numero_ordine', c.Opportunity__r.OpportunityNumber__c);
            ticketMap.put('nome_opportunita', c.Opportunity__r.Name);
            // ticketMap.put('prezzo_totale', c.Opportunity__r.Amount); //Da verificare campo

            //Obbligatori non indicati nel documento
            ticketMap.put('fonte', 'InBound');
            ticketMap.put('motivo_contatto', 'Assistenza');
        }

        System.debug('@@@ ticket mapper ' + ticketMap );
        return ticketMap;

    }

    // public static Map<String,Object> doMappingCommentVTE(String idTicketVTE, Case c){
    //     Map<String,Object> commentMap = new Map<String,Object>();

    //     if(c != null && idTicketVTE != null){
    //         //Mapping tra commento ticket e commento VTE
    //         commentMap.put('related_to', idTicketVTE);
    //         commentMap.put('commentcontent', c.VTE_Commenti_Interni__c);
    //         commentMap.put('related_to_perm', '0'); //Fisso
    //         commentMap.put('createdtime', '0000-00-00 00:00:00'); //Fisso - default per orario corrente
    //         commentMap.put('modifiedtime', '0000-00-00 00:00:00'); //Fisso - default per orario corrente
    //         commentMap.put('creator', '19x1'); //Fisso - prefisso Users
    //         commentMap.put('parent_comments', '34x'); //Fisso - prefisso ModComments
    //         commentMap.put('visibility_comm', 'All'); //Fisso
    //     }

    //     return commentMap;
    // }

    @future(callout=true)
    public static void createTicketFatturazione(Id opportunityId, String emailBody, Boolean fatturaDaPartner, String partnerFattura, Decimal prezzoTotale){
        
        Boolean success = true;
        String input = '';
        String output = '';

        try{
            Opportunity opp = [SELECT Id, Name, AccountId, Account.Name, Codice_Cliente__r.Name, /*Account.Codice_Cliente_X3__c,*/ CicloAttivoFascicolo__c, OpportunityNumber__c FROM Opportunity WHERE Id =: opportunityId];
            Blob headerValue = Blob.valueOf(EndpointServizi__c.getOrgDefaults().INF_Username_VTE__c + ':' + EndpointServizi__c.getOrgDefaults().INF_Access_Key_VTE__c);
            String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue);

            HttpRequest request = new HttpRequest();
            request.setHeader('Authorization', authorizationHeader);
            request.setHeader('Content-Type', 'application/json');
            request.setEndpoint(EndpointServizi__c.getOrgDefaults().INF_Url_VTE__c + 'create');
            request.setMethod('POST');
            request.setTimeout(90000);

            VTECreateWrapper payload = new VTECreateWrapper();
            payload.elementType = VTE_ELEMENTTYPE_HELPDESK;
            //payload.element = JSON.serialize(doMappingCaseVTE(c)); //Da serializzare in string
            payload.element = JSON.serialize(doMappingTicketFatturazione(opp, opp.Codice_Cliente__r.Name,/*opp.Account.Codice_Cliente_X3__c,*/ emailBody, fatturaDaPartner, partnerFattura, prezzoTotale));
            System.debug('@@@ payload ' + JSON.serialize(payload));
            request.setBody(JSON.serialize(payload));

            HttpResponse httpresponse = new Http().send(request);
            System.debug('@@@ httpresponse ' + httpresponse.getBody());

            VTECreateResponse response = (VTECreateResponse)JSON.deserialize(httpresponse.getBody(), VTECreateResponse.Class);
            System.debug('@@@ response ' + JSON.serialize(response));

            input = JSON.serialize(payload);
            output = httpresponse.getBody();

        } catch(Exception e){
            //return e.getMessage() + ' -- ' + e.getStackTraceString();
            System.debug('@@@ errore ' + e.getMessage());
            success = false;
        }

        Log__c l = new Log__c(
            Source__c = 'TicketVTE_Fatturazione',
            InputPayload__c = input,
            OutputPayload__c = output,
            Success__c = success
        );

        insert l;
        //return 'ok';
    }

    private static Map<String,Object> doMappingTicketFatturazione(Opportunity opp, String CodCliX3, String emailBody, Boolean fatturaDaPartner, String partnerFattura, Decimal prezzoTotale){
        Map<String,Object> response = new Map<String,Object>();

        response.put('cli_for', 'Contact Center');
        response.put('canale_contatto', 'Salesforce');
        response.put('contatto_email', UserInfo.getUserName());
        response.put('codice_cliente', CodCliX3);
        response.put('denominazione', opp.Account.Name);
        response.put('ckdom01', 'ALTRO');
        response.put('ckdom01_0', 'ALTRO');
        response.put('ckdom01_1', 'Fatturazione');
        // response.put('riferimento_esterno', opp.Id);
        response.put('riferimento_esterno', opp.OpportunityNumber__c);
        response.put('fascicolo', opp.CicloAttivoFascicolo__c);
        response.put('status', 'Open');
        response.put('team_on_creation', '21x463');
        response.put('team', '21x463');
        response.put('nome_opportunita', opp.Name);
        // response.put('numero_ordine', opp.OpportunityNumber__c);
        // response.put('description', emailBody);

        String st;
        if(fatturaDaPartner){
            st = 'Fattura da Partner: Si ';
            // st += '\n';
            if(String.isNotBlank(partnerFattura))
                st += partnerFattura;
        } else
            st = 'Fattura da Partner: No';

        response.put('azione', st);
        // response.put('description', emailBody);
        // response.put('description', emailBody.replaceAll('<[/a-zAZ0-9]*>',''));
        response.put('description', emailBody.replaceAll('<[^>]*>', ' '));
        response.put('prezzo_totale', prezzoTotale);

        //Obbligatori non indicati nel documento
        response.put('fonte', 'InBound');
        response.put('motivo_contatto', 'Assistenza');

        return response;
    }

    //Wrapper Classes

    public class VTECreateWrapper{
        public String elementType; //Ogni oggetto ha un valore distinto, attualmente utilizziamo solo helpdesk
        public String element; //Corrisponde al wrapper contenente i campi
    }

    public class VTECreateResponse{
        public Integer status;
        public String error; // Usato solo in caso di errore
        public String message; // Usato solo in caso di errore
        public VTEELementResponse data;
    }

    public class VTEElementResponse{
        public String id;
        //Inserire altri campi se necessario
    }
}