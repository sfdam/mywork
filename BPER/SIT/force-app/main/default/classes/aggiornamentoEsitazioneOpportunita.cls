/**
 * @description       : 
 * @author            : simone.viglianti@tengroup.it
 * @group             : 
 * @last modified on  : 12-09-2021
 * @last modified by  : simone.viglianti@tengroup.it
**/
public class aggiornamentoEsitazioneOpportunita {

    public static String userId{get;set;}

    public static User currentUser {
        get{

            if(currentUser != null){
                return currentUser;
            }

            currentUser = [SELECT FederationIdentifier, FirstName, LastName, abi__c,applicazione__c, ndgsettoriale__c,
                        banca__c, terminale__c, idced__c, ip__c, cab__c, branchcode__c, userid__c,
                        sessionId__c, operationId__c, sysCaller__c, fnCaller__c, serviceName__c, fnName__c,
                        Token__c, idApplicazione__c, esb_idCed__c, esb_operatore__c, esb_IP__c,
                        serviceImplClass__c, serviceClient__c, TermId__c, customerId__c, ServiceVersion__c, Matricola6CifreFormula__c, Name, Profile.Name
                        FROM User WHERE id =: userId];
            return currentUser;
        }set;
    }
    
    public class FlowInputs {
        @InvocableVariable public String stato;
        @InvocableVariable public String note;
        @InvocableVariable public String recordId;
        @InvocableVariable public String certificationName;
        @InvocableVariable public Boolean disableLog;
        @InvocableVariable public String apiRequestName;
    }

    /**
    * @description 
    * @author simone.viglianti@tengroup.it | 12-06-2021 
    * @param inputs 
    * @return FlowOuputs[] 
    **/
    @InvocableMethod
    public static FlowOutputs[] makeRequest(List<FlowInputs> inputs){
        System.debug(LoggingLevel.DEBUG,'*** START -- makeRequest Method ***');
        System.debug(LoggingLevel.DEBUG,'### Fase: '+inputs[0].stato);
        System.debug(LoggingLevel.DEBUG,'### recordId: '+inputs[0].recordId);
        System.debug(LoggingLevel.DEBUG,'### certficationName: '+inputs[0].certificationName);
        System.debug(LoggingLevel.DEBUG,'### disableLog: '+inputs[0].disableLog);
        System.debug(LoggingLevel.DEBUG,'### apiRequestName: '+inputs[0].apiRequestName);

        Boolean esito = false;

        List<FlowOutputs> outputs = new List<FlowOutputs>();

        try {
            List<Opportunity> oppList = [SELECT Id, Name, Description, CodiceAzione__c, CodiceAzioneUtente__c, PTF_ABICED__c, CRM_FormulaAccountNDG__c,
                                                CloseDate, CRM_Motivo__c, CRM_Titolo__c, CRM_Esito__c, MatricolaAutore__c, MatricolaReferente__c, 
                                                Autore__c, Referente__c, Mds__c, DescrizioneMds__c, Microportafoglio__c, UnitaOrganizzativa__c, StageName,
                                                CRM_Oggetto__c, CRM_Bisogno__c, CRM_CategoriaProdotto__c, CRM_Canale__c, CRM_FaseFormula__c,
                                                Account.PTF_Portafoglio__r.CRM_ReferentePortafoglio__r.LastName,Account.PTF_Portafoglio__r.CRM_ReferentePortafoglio__r.FirstName,
                                                Account.PTF_Portafoglio__r.CRM_ReferentePortafoglio__r.PTF_RegistrationNumber__c,
                                                CRM_NoteEsitazioneOpps__c, CRM_EsitoContatto__c, CRM_Assegnatario__c, CRM_Assegnatario__r.LastName,  CRM_Assegnatario__r.FirstName,
                                                CRM_ProductCategory__c
                                         FROM Opportunity 
                                         WHERE Id =:inputs[0].recordId];

            System.debug(LoggingLevel.DEBUG,'### oppList: '+oppList);
            esito = invokeWS(inputs[0].apiRequestName,oppList,inputs[0].stato,inputs[0].note,inputs[0].certificationName,inputs[0].disableLog,null);
            FlowOutputs out = new FlowOutputs();
            out.response = esito;
            outputs.add(out);
        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR,'### Exception aggiornamentoEsitazioneOpportunità: '+e.getMessage()+' at line: '+e.getLineNumber());
        }
        System.debug(LoggingLevel.DEBUG,'### result: '+outputs);
        System.debug(LoggingLevel.DEBUG,'*** END -- makeRequest Method ***');
        return outputs;
    }

    /**
    * @description 
    * @author simone.viglianti@tengroup.it | 12-06-2021 
    * @param certificationName 
    * @param oppList 
    * @param stato 
    * @param note 
    * @param disableLog 
    * @param runAsUserId 
    * @return Boolean 
    **/
    private static Boolean invokeWS(String apiRequestName, List<Opportunity> oppList, String stato, String note, String certificationName, Boolean disableLog, String runAsUserId){
        System.debug(LoggingLevel.DEBUG,'*** START -- makeRequest Method ***');
        System.debug(LoggingLevel.DEBUG,'### apiRequestName: '+apiRequestName);
        System.debug(LoggingLevel.DEBUG,'### stato: '+stato);
        System.debug(LoggingLevel.DEBUG,'### note: '+note);
        System.debug(LoggingLevel.DEBUG,'### certificationName: '+certificationName);
        System.debug(LoggingLevel.DEBUG,'### disableLog: '+disableLog);
        System.debug(LoggingLevel.DEBUG,'### oppList: '+oppList);
        System.debug(LoggingLevel.DEBUG,'### runAsUserId: '+runAsUserId);

        Boolean esito = false;
        Map<String,String> headersReq = new Map<String,String>();

        userId = !String.isBlank(runAsUserId) ? runAsUserId : UserInfo.getUserId();

        WsRestInput restInput = new WsRestInput(currentUser, null);
        Map<String,String> testataMap = (Map<String,String>)JSON.deserialize(JSON.serialize(restInput.headers.testata), Map<String,String>.class);

        //Recuperare dati da custom setting Endpoint List
        Endpoint__c apiRequest = Endpoint__c.getInstance(apiRequestName);
        String endpoint = apiRequest.Endpoint__c;
        String method = apiRequest.Method__c;
        Decimal timeout = apiRequest.Timeout__c;

        HttpRequest req = new HttpRequest();

        for(String key: testataMap.keySet()){

            if(testataMap.get(key) != null){
                req.setHeader(!WsRestUtils.outOfObjectParams.contains(key) ? 'testata' + '_' + key : key, testataMap.get(key));
                headersReq.put(!WsRestUtils.outOfObjectParams.contains(key) ? 'testata' + '_' + key : key, testataMap.get(key));
            }else{
               /*
                req.setHeader(!WsRestUtils.outOfObjectParams.contains(key) ? 'testata' + '_' + key : key, '');
                headersReq.put(!WsRestUtils.outOfObjectParams.contains(key) ? 'testata' + '_' + key : key, '');*/
            }
        }
		
        
        req.setHeader('Content-Type', 'application/json');
        headersReq.put('Content-Type', 'application/json');
        req.setEndpoint(endpoint);
        req.setMethod(method);
        req.setTimeout(timeout.intValue());
        if(certificationName != null) req.setClientCertificateName(certificationName);
        String body = requestBody(stato,note,oppList);
        req.setBody(body);

        Http http = new Http();               
        HTTPResponse res = http.send(req);
        String response = res.toString(); 

        System.debug(LoggingLevel.DEBUG,'### response: '+res.toString());
        System.debug(LoggingLevel.DEBUG,'### response: '+res.getBody());
        System.debug(LoggingLevel.DEBUG,'### responseStatusCode: '+res.getStatusCode());

        if(res.getStatusCode() == 204){
            esito = true;
        }

        string[] headerkeysRes = res.getHeaderKeys();

        //create an object to store your header key-value pairs
        Map<string, string> headersRes = new map<string, string>();

        //iterate through they keys, and populate your map
        for(string s : headerkeysRes){
            headersRes.put(s,res.getHeader(s));
        }

        if(disableLog == null){
            
            disableLog = false;
        }

        if(!disableLog){
            WsRestUtils.writeLog(
                apiRequest.Name,
                method,
                body,
                res.getStatusCode(),
                res.getBody(),
                JSON.serialize(response).length() >= 131071 ? JSON.serialize(response).substring(0, 131071) : JSON.serialize(response),
                headersReq,
                headersRes,
                endpoint,
                res.getBody()
                // responseObj.isCorrect() ? null : responseObj.getErrors()
            );
        }
        System.debug(LoggingLevel.DEBUG,'*** END -- makeRequest Method ***');
        return esito;
    }

    /**
    * @description 
    * @author simone.viglianti@tengroup.it | 12-06-2021 
    * @param stato 
    * @param note 
    * @param oppList 
    * @return String 
    **/
    private static String requestBody(String stato, String note, List<Opportunity> oppList){
        List<TargetNec> targetNecList = new List<TargetNec>();
 		Map<String,String> mapMMDSCode = New Map<String,String>{'PRIVATE'=>'1',	'FAMILY'=>'2',	'CORPORATE'=>'3',	'LARGE CORPORATE'=>'4',	'PERSONAL'=>'5',	'SMALL BUSINESS'=>'6',	'BUSINESS ALTRI'=>'7',	'CONTROPARTI ISTITUZIONALI'=>'8',	'ASSENTE'=>'9',	'RESIDUALE'=>'10',	'LARGE CORPORATE'=>'11',	/*'CORPORATE'=>'12',*/	'POE'=>'13',	'CONSULENTI FINANZIARI'=>'14',	'KEY CLIENT PRIVATI'=>'15',	'ENTI E TESORERIE'=>'50',	'NON PORTAFOGLIATI'=>'99'};
        List<String> listMMDSPOOL = New List<String>{'Family', 'POE', 'Assente', 'Residuale','Non Portafogliati'};
      
        for(Opportunity opp: oppList){
            TargetNec trg = new TargetNec();
            
            trg.microportafoglio = opp.Microportafoglio__c;
            trg.motivoEliminazione =  '';
            trg.ndg = opp.CRM_FormulaAccountNDG__c;
            trg.codiceAzioneUtente = opp.Name;
            trg.nota = note;
            trg.codiceAzione = opp.Name;
            trg.statoAzione = opp.CRM_FaseFormula__c;
            trg.banca =opp.PTF_ABICED__c;
            trg.esito = /*opp.CRM_EsitoContatto__c;*/stato;
            
            trg.matricolaAutore = ((currentUser.FederationIdentifier!=null) ? 'U'+currentUser.FederationIdentifier : 'U0000'); //opp.MatricolaAutore__c;
            trg.autore = ((currentUser!=null) ? currentUser.LastName +' '+currentUser.FirstName : '');

            if(listMMDSPOOL.contains(opp.DescrizioneMds__c)){
                trg.matricolaReferente =(opp.CRM_Assegnatario__c!=null ? 'U'+opp.CRM_Assegnatario__r.FederationIdentifier : '');
            	trg.referente = (opp.CRM_Assegnatario__c!=null ? opp.CRM_Assegnatario__r.LastName+' '+opp.CRM_Assegnatario__r.FirstName : '');
            }else{
                trg.matricolaReferente =(opp.Account.PTF_Portafoglio__r.CRM_ReferentePortafoglio__r.PTF_RegistrationNumber__c!=null ? 'U'+opp.Account.PTF_Portafoglio__r.CRM_ReferentePortafoglio__r.PTF_RegistrationNumber__c : '');
            	trg.referente = (opp.Account.PTF_Portafoglio__r.CRM_ReferentePortafoglio__c!=null ? opp.Account.PTF_Portafoglio__r.CRM_ReferentePortafoglio__r.LastName+' '+opp.Account.PTF_Portafoglio__r.CRM_ReferentePortafoglio__r.FirstName : '');
            }
            if(opp.DescrizioneMds__c!=null){
                trg.mds = (mapMMDSCode.containsKey(String.ValueOf(opp.DescrizioneMds__c).ToUpperCase()) ? mapMMDSCode.get(String.ValueOf(opp.DescrizioneMds__c).ToUpperCase()) : '');// opp.Mds__c; 
                trg.descrizioneMds = String.valueOf(opp.DescrizioneMds__c).toUpperCase();          
            }
            
            if(opp.CRM_Canale__c=='Contact Center'){
            	trg.motivo = 'Opportunità Contact Center';
                trg.origineAzione = 'Contact Center';
            }else if(opp.CRM_Canale__c=='Self'){
                trg.motivo = 'Opportunità Self';
                trg.origineAzione = 'Self';
            }else if(opp.CRM_Canale__c=='Check-up'){
                trg.motivo = 'Opportunità Checkup'; 
                trg.origineAzione = 'Checkup';            
            }
            
            if(trg.motivo.containsIgnoreCase('Self') || trg.motivo.containsIgnoreCase('Checkup')){
                trg.nomeAzione = (opp.CRM_Oggetto__c!=null ? opp.CRM_Oggetto__c : '')+' - '+(opp.CRM_Bisogno__c!=null ? opp.CRM_Bisogno__c : '');
            }else if(trg.motivo.containsIgnoreCase('Contact Center')){
                trg.nomeAzione = (opp.CRM_ProductCategory__c!=null ? opp.CRM_ProductCategory__c : '')+(opp.CRM_Bisogno__c!= null ? ' - '+opp.CRM_Bisogno__c : '');
            }

            if(currentUser.Profile.Name.contains('NEC_'))
            	trg.unitaOrganizzativa = 'Rete';
            else
            	trg.unitaOrganizzativa ='Contact Center';
            
            //Date
            DateTime dt1 = DateTime.now();
            DateTime dtGMT = DateTime.newInstanceGmt(dt1.date(), dt1.time());
            String dateEsitazione = String.valueOf(dt1);
            dateEsitazione = dateEsitazione.replace(' ','T');
            trg.dataEsitazione = dateEsitazione;

            String dataFine = String.valueOf(opp.CloseDate);
            dataFine = dataFine.replace(' ','T');
            trg.dataFineAzione = dataFine+'T00:00:00';
           
            targetNecList.add(trg);
        }

        ListaTarget listaTarget = new ListaTarget();
        listaTarget.targetNec = targetNecList;
        Request req = new Request();
        req.tipoEsitazione = 'OPPORTUNITA';
        req.listaTarget = listaTarget;

        String serializeResult = JSON.serialize(req);
        System.debug(LoggingLevel.DEBUG,'### serializeRwsult: '+serializeResult);
        return serializeResult;
    }

    public class FlowOutputs{
        @InvocableVariable public Boolean response;
    }

    public class Request {
        String tipoEsitazione;
        ListaTarget listaTarget;
    }

    public class ListaTarget {
        List<TargetNec> targetNec;
    }

    public class TargetNec {
        String statoAzione;
        String nota;
        String banca;
        String ndg;
        String codiceAzione;
        String codiceAzioneUtente;
        String dataFineAzione;
        String motivo;
        String nomeAzione;
        String esito;
        String dataEsitazione;
        String matricolaAutore;
        String autore;
        String motivoEliminazione;
        String unitaOrganizzativa;
        String mds;
        String descrizioneMds;
        String matricolaReferente;
        String referente;
        String microportafoglio;
        String origineAzione;
    }
}