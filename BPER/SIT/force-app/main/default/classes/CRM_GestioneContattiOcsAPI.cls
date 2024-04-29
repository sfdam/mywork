/***  
* Auhtor        :   Alessandro Lumaca
* Label         :   CR Ingaggio agenti reti esterne
* Modify Date   :   2022-10-14
* Modify        :   Ingaggio agenti reti esterne
***/ 

public with sharing class CRM_GestioneContattiOcsAPI {

    public virtual class BaseException extends Exception {}
    
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
                        serviceImplClass__c, serviceClient__c, TermId__c, customerId__c, ServiceVersion__c, Matricola6CifreFormula__c, Name
                        FROM User WHERE id =: userId];
            return currentUser;
        }set;
    }
    public static Map<String, String> cfMap = new Map<String,String>{'L'=>'0','M'=>'1','N'=>'2','P'=>'3','Q'=>'4','R'=>'5','S'=>'6','T'=>'7','U'=>'8','V'=>'9'};
    
    //public static Set<String> abiCedSet = new Set<String>{'03084_100','03084_105','05387_3600','05387_3601','05387_3602','05387_3603','05387_3604','05387_3605','05387_3606','05387_3607','05387_3608','05387_3609','05387_3610','05387_3611','05387_3612','05387_3613','05387_3614','05387_3615','05387_3616','05387_3617','05387_3618','05387_3619','05387_3620','05387_3621','05387_3622','05387_3623','05387_3624','05387_3625','05387_3626','05387_3627','05387_3628','05387_3629','05387_3630','05387_3631','05387_3632','05387_3633','05387_3634','05387_3635','05387_3636','05387_3637','05387_3638','05387_3639','05387_3640','05387_3641','05387_3642','05387_3643','05387_3644','05387_3645','05387_3646','05387_3647','05387_3648','05387_3649','05387_3650','05387_3651','05387_3652','05387_3653','05387_3654','05387_3655','05387_3656','05387_3657','05387_3658','05387_3659','05387_3660','05387_3661','05387_3662','05387_3663','05387_3664','05387_3665','05387_3666','05387_3667','05387_3668','05387_3669','05387_3670','05387_3671','05387_3672','05387_3673','05387_3674','05387_3675','05387_3676','05387_3677','05387_3678','05387_3679','05387_3680','05387_3681','05387_3682','05387_3683','05387_3684','05387_3685','05387_3686','05387_3687','05387_3688','05387_3689','05387_3690','05387_3691','05387_3692','05387_3693','05387_3694','05387_3695','05387_3696','05387_3697','05387_3698','05387_3699','05387_3700','05387_3701','05387_3702','05387_3703','05387_3704','05387_3705','05387_3706','05387_3707','05387_3708','05387_3709','05387_3710','05387_3711','05387_3712','05387_3713','05387_3714','05387_3715','05387_3716','05387_3717','05387_3718','05387_3719','05387_3720','05387_3721','05387_3722','05387_3723','05387_3724','05387_3725','05387_3726','05387_3727','05387_3728','05387_3729','05387_3730','05387_3731','05387_3732','05387_3733','05387_3734','05387_3735','05387_3736','05387_3737','05387_3738','05387_3739','05387_3740','05387_3741','05387_3742','05387_3743','05387_3744','05387_3745','05387_3746','05387_3747','05387_3748','05387_3749','05387_3750','05387_3751','05387_3752','05387_3753','05387_3754','05387_3755','05387_3756','05387_3757','05387_3758','05387_3759','05387_3760','05387_3761','05387_3762','05387_3763','05387_3764','05387_3765','05387_3766','05387_3767','05387_3768','05387_3769','05387_3770','05387_3771','05387_3772','05387_3773','05387_3774','05387_3775','05387_3776','05387_3777','05387_3778','05387_3779','05387_3780','05387_3781','05387_3782','05387_3783','05387_3784','05387_3785','05387_3786','05387_3787','05387_3788','05387_3789','05387_3790','05387_3791','05387_3792','05387_3793','05387_3794','05387_3795','05387_3796','05387_3797','05387_3798','05387_3799','05387_3800','05387_3801','05387_3802','05387_3803','05387_3804','05387_3805','05387_3806','05387_3807','05387_3808','05387_3809','05387_3810','05387_3811','05387_3812','05387_3813','05387_3814','05387_3815','05387_3816','05387_3817','05387_3818','05387_3819','05387_3820','05387_3821','05387_3822','05387_3823','05387_3824','05387_3825','05387_3826','05387_3827','05387_3828','05387_3829','05387_3830','05387_3831','05387_3832','05387_3833','05387_3834','05387_3835','05387_3836','05387_3837','05387_3838','05387_3839','05387_3840','05387_3841','05387_3842','05387_3843','05387_3844','05387_3845','05387_3846','05387_3847','05387_3848','05387_3849','05387_3850','05387_3851','05387_3852','05387_3853','05387_3854','05387_3855','05387_3856','05387_3857','05387_3858','05387_3859','05387_3860','05387_3861','05387_3862','05387_3863','05387_3864','05387_3865','05387_3866','05387_3900','05387_3901','05387_3902','05387_3903','05387_3904','05387_3905','05387_3906','05387_3907','05387_3908','05387_3909','05387_3910'};    

    public class FlowInputs {
        /*@InvocableVariable public String recordId;
        @InvocableVariable public Integer numeroPagina;
        @InvocableVariable public Integer numeroMaxElementiPerPagina;
        @InvocableVariable public String tipologia;
        @InvocableVariable public String codiceAgenzia;
        @InvocableVariable public String agenziaAttiva;
        @InvocableVariable public String certificationName;
        @InvocableVariable public Boolean disableLog;
        @InvocableVariable public String apiRequestName;*/

        // CR Ingaggio agenti reti esterne
        @InvocableVariable public String accountId;
        @InvocableVariable public String codiceSegnalatore;
        @InvocableVariable public String campingID; 
        @InvocableVariable public String note; 
        // CR Ingaggio agenti reti esterne -- Fine 
    }

    public class FlowOutputs{
        // CR Ingaggio agenti reti esterne
        @InvocableVariable public String codice;
        @InvocableVariable public String  messaggio; 
        @InvocableVariable public String  idContatto; 
        // CR Ingaggio agenti reti esterne -- Fine
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
        /*System.debug(LoggingLevel.DEBUG,'### recordId: '+inputs[0].recordId);
        System.debug(LoggingLevel.DEBUG,'### certficationName: '+inputs[0].certificationName);
        System.debug(LoggingLevel.DEBUG,'### disableLog: '+inputs[0].disableLog);
        System.debug(LoggingLevel.DEBUG,'### apiRequestName: '+inputs[0].apiRequestName);*/

        Map<String, Object> response = new Map<String, Object>();
        List<FlowOutputs> outputs = new List<FlowOutputs>();
        try {
            // List<SObject> records = [SELECT Id FROM SObject WHERE Id =: inputs[0].recordId];
            response = invokeWS(new List<SObject>(), (Map<String,Object>)JSON.deserializeUntyped(JSON.serialize(inputs[0])), '');
            System.debug('DK makeRequest.response: ' + JSON.serialize(response));
            FlowOutputs output = new FlowOutputs();
            output.codice = (String)response.get('codice');
            output.messaggio = (String)response.get('messaggio');
            output.idContatto = (String)response.get('idContatto');
            outputs.add(output);
        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR,'### Exception aggiornamentoEsitazioneOpportunità: '+e.getMessage()+' at line: '+e.getLineNumber());
        }
        System.debug(LoggingLevel.DEBUG,'### result: '+response);
        System.debug(LoggingLevel.DEBUG,'*** END -- makeRequest Method ***');
        return outputs;
    }

    /**
    * @description 
    * @author simone.viglianti@tengroup.it | 12-06-2021 
    * @param certificationName 
    * @param SObjectList 
    * @param disableLog 
    * @param runAsUserId 
    * @return Boolean 
    **/
    public static Map<String, Object> invokeWS(List<SObject> SObjectList, Map<String, Object> inputs, String runAsUserId){

        String apiRequestName = 'GestioneContattiOCSApi';
        String certificationName = 'salesforcetestclient2024';
        System.debug(LoggingLevel.DEBUG,'*** START -- makeRequest Method ***');
        System.debug(LoggingLevel.DEBUG,'### apiRequestName: ' + apiRequestName);
        System.debug(LoggingLevel.DEBUG,'### certificationName: ' + certificationName);
        System.debug(LoggingLevel.DEBUG,'### SObjectList: ' + SObjectList);
        System.debug(LoggingLevel.DEBUG,'### runAsUserId: ' + runAsUserId);
        Map<String, Object> responseMap = new Map<String, Object>();

        // CR Ingaggio agenti reti esterne
        Account acc = [
            SELECT Id, FinServ__BankNumber__c, PTF_IdCedFilialeOnNDG__c, CRM_TaxId__c, FirstName, LastName, CRM_NDG__c, CRM_Filiale__r.PTF_IdCedFiliale__c,
                   PersonBirthdate, PersonEmail, CRM_ResidentialAddress__pc, Phone, PersonMobilePhone, CRM_FormulaBirthDate__c, CRM_Phone1__c, CRM_Phone2__c, CRM_SmartWebMobilePhone__c, FinServ__BranchCode__c 
            FROM   Account
            WHERE  Id = :( (Id) inputs.get('accountId') )
            LIMIT  1
        ];
        //  CR Ingaggio agenti reti esterne -- Fine 
        System.debug('DK abiIDCED: ' + acc.FinServ__BankNumber__c + '_' + acc.CRM_Filiale__r.PTF_IdCedFiliale__c);

        /*if(abiCedSet.contains(acc.FinServ__BankNumber__c + '_' + acc.CRM_Filiale__r.PTF_IdCedFiliale__c)){
            System.debug('DK EXECPTION');
            responseMap.put('codice', '800');
            responseMap.put('messaggio', 'Non è possibile proseguire con la richiesta.');
            return responseMap;
        }*/

        Boolean esito = false;
        //Map<String, Object> responseMap = new Map<String, Object>();
        Map<String,String> headersReq = new Map<String,String>();

        userId = !String.isBlank(runAsUserId) ? runAsUserId : UserInfo.getUserId();

        WsRestInput restInput = new WsRestInput(currentUser, null);
        Map<String,String> testataMap = (Map<String,String>)JSON.deserialize(JSON.serialize(restInput.headers.testata), Map<String,String>.class);

        //Recuperare dati da custom setting Endpoint List
        Endpoint__c apiRequest = Endpoint__c.getInstance(apiRequestName);
        String endpoint = apiRequest.Endpoint__c;
        Map<String,String> endpointParams = !String.isBlank(apiRequest.EndpointParams__c) ? (Map<String,String>)JSON.deserialize(apiRequest.EndpointParams__c, Map<String,String>.class) : null;
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

        /*StaticResource staticResource = [select id,body from StaticResource Where Name = 'jsonWrapper'];
        String jsonWrapper = staticResource.body.toString();
        Map<String,Object> parsedJsonWrapper = (Map<String,Object>)JSON.deserializeUntyped(jsonWrapper);
        if(parsedJsonWrapper.containsKey(apiRequestName)){

            Map<String,Object> parsedJsonElement = (Map<String,Object>)JSON.deserializeUntyped(JSON.serialize(parsedJsonWrapper.get(apiRequestName)));
            Map<String, Object> parsedJsonElementFields = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(parsedJsonElement.get('fields')));
            Map<String, Map<String, Object>> fieldsMap = new Map<String, Map<String, Object>>();
            for(String fieldName : parsedJsonElementFields.keySet()){
    
                fieldsMap.put(fieldName, (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(parsedJsonElementFields.get(fieldName))));
            }
            System.debug('DK fieldsMap: ' + JSON.serialize(fieldsMap));
            Map<String,String> urlParams = new Map<String,String>();
            String regex = '\\{.*?\\}';
            Pattern pattr = Pattern.compile(regex); 
            Matcher mat = pattr.matcher(apiRequest.Endpoint__c);
            do{
                try{
                    System.debug('DK: mat.group() ' + mat.group());
                    Map<String,Object> field = fieldsMap.get(mat.group().replace('{', '').replace('}', ''));
                    if(!String.isBlank((String)field.get('SObject')) &&
                        (String)field.get('SObject') == 'User'){
    
                        urlParams.put(mat.group(), (String)currentUser.get((String)field.get('devName')));
                    }/*else{
    
                        if(String.isBlank((String)field.get('fieldReferenceDevName'))){
        
                            if((String)field.get('type') != 'Date'){
        
                                urlParams.put(mat.group(), (String)record.get((String)field.get('devName')));
                            }else{
        
                                DateTime dateValue = (DateTime)JSON.deserialize(JSON.serialize(record.get((String)field.get('devName'))), DateTime.class);
                                urlParams.put(mat.group(), '' + dateValue.year() + dateValue.month() + dateValue.day());
                            }
                        }else{
        
                            Map<String,Object> recordMap = record.getPopulatedFieldsAsMap();
                            SObject parentRecord = (SObject)recordMap.get((String)field.get('fieldReferenceDevName'));
                            if((String)field.get('type') != 'Date'){
        
                                System.debug('DK urlParams value: ' + (String)parentRecord.get((String)field.get('devName')));
                                urlParams.put(mat.group(), (String)parentRecord.get((String)field.get('devName')));
                            }else{
                                
                                DateTime dateValue = (DateTime)JSON.deserialize(JSON.serialize(parentRecord.get((String)field.get('devName'))), DateTime.class);
                                urlParams.put(mat.group(), '' + dateValue.year() + dateValue.month() + dateValue.day());
                            }
                        }
                    }
                }catch(Exception ex){
                    System.debug('DK error_paramsMap: ' + ex.getMessage() + '; at: ' + ex.getStackTraceString());
                }
            }while(mat.find());
    
            System.debug('DK urlParams: ' + JSON.serialize(urlParams));
    
            for(String key : urlParams.keySet()){
                System.debug(key);
                endpoint = endpoint.replace(key, urlParams.get(key));
            }
        }*/

        List<String> params = new List<String>();
        if(endpointParams != null){
            for(String key : endpointParams.keySet()){
                if(inputs.containsKey(key)){
                    params.add(key + '=' + inputs.get(key));
                }
            }
            if(!params.isEmpty()){
                endpoint += '?';
                endpoint += String.join(params, '&');
            }
        }
        
        // CR Ingaggio agenti reti esterne
        /*Account acc = [
            SELECT Id, FinServ__BankNumber__c, PTF_IdCedFilialeOnNDG__c, CRM_TaxId__c, FirstName, LastName, CRM_NDG__c
                   , PersonBirthdate, PersonEmail, CRM_ResidentialAddress__pc, Phone, PersonMobilePhone, CRM_FormulaBirthDate__c, CRM_Phone1__c, CRM_Phone2__c, CRM_SmartWebMobilePhone__c, FinServ__BranchCode__c 
            FROM   Account
            WHERE  Id = :( (Id) inputs.get('accountId') )
            LIMIT  1
        ];*/
        //  CR Ingaggio agenti reti esterne -- Fine 

        req.setHeader('Content-Type', 'application/json');
        headersReq.put('Content-Type', 'application/json');
        req.setEndpoint(endpoint);
        req.setMethod(method);
        req.setTimeout(timeout.intValue());
        if(certificationName != null && !Test.isRunningTest()){

            req.setClientCertificateName(certificationName);
        }
        String body = '';
        if(method == 'POST'){
            // CR Ingaggio agenti reti esterne
            // if(apiRequestName == 'inserisciContatto'){

                // body = '{"abiContatto":"05387","abiOperatore":"05387","cabContatto":"40130","cabOperatore":"40130","agenteRiferimento":0,"agenteSegnalatore":0,"azione":null,"campagna":"1-J7Y2W1","campagnaPratica":null,"cartellaDocExt":null,"cedContatto":"3168","cedFilialeOperatore":"3168","codiceAgenzia":"0","codiceContatto":"1450","codiceOperatore":"1450","codiceSegnalatore":"1450","dataNuovoContatto":null,"datiAmministrazione":null,"datiAnagrafici":{"email":"crescenzocoppola@hotmail.com","telefonoCellulare":"3473847687","telefono":null,"codiceCatastaleResidenza":"F839","indirizzo":"VIA DELLA MAIELLA","codiceCatastaleNascita":"F839","dataNascita":"1986-06-23","sesso":"M","codiceFiscale":"CPPCSC86H23F839I","cognome":"COPPOLA","nome":"CRESCENZO","ndg":"21159252"},"esitoAzione":null,"flagStampaPrivacy":true,"motivoEsito":null,"nota":null,"origineContatto":null,"tmpKey":"'+ tmpKey + '"}';
                // InserisciContatto inserisciContatto = new InserisciContatto(); 
                Integer sessoCF = acc.CRM_TaxId__c != null ? Integer.valueOf(acc.CRM_TaxId__c.Substring(9,11)) : null ; 
                String codiceCatastaleNascita = acc.CRM_TaxId__c != null ? acc.CRM_TaxId__c.substring(12, acc.CRM_TaxId__c.length() - 1) : null;
                String phone1 = acc.CRM_Phone1__c != null ? String.valueOf(acc.CRM_Phone1__c) : null;
                String comuneResidenza = acc.CRM_ResidentialAddress__pc != null ? acc.CRM_ResidentialAddress__pc.substringBeforeLast(' , ') : null;
                String residenza = comuneResidenza!= null ? comuneResidenza.substringAfterLast(' , ') : null;
                String codiceCatastaleResidenza = '';
                System.debug('residenza : '+residenza );
                List<CRM_CodiciCatastali__c> codiciComuni = [SELECT Id, CRM_Codice__c, Name FROM CRM_CodiciCatastali__c WHERE Name = :residenza];
                System.debug('codiciComuni: '+codiciComuni );
                if(!codiciComuni.isEmpty()) {
                    codiceCatastaleResidenza = codiciComuni[0].CRM_Codice__c;
                }
                
                for(String key : cfMap.keySet()){
                    codiceCatastaleNascita = codiceCatastaleNascita.contains(key) ? codiceCatastaleNascita.replace(key, cfMap.get(key)) : codiceCatastaleNascita;
                }
                codiceCatastaleNascita = acc.CRM_TaxId__c != null ? acc.CRM_TaxId__c.substring(11, 12) + codiceCatastaleNascita : null;
                System.debug('@@@inputs: '+inputs);
                System.debug('@@@nota: '+inputs.get('note'));
                InserisciContatto inserisciContatto = new InserisciContatto();
                // CR Ingaggio agenti reti esterne
                // if(inserisciContatto != null ) {                
                    inserisciContatto.abiContatto  = acc.FinServ__BankNumber__c;
                    inserisciContatto.abiOperatore = acc.FinServ__BankNumber__c;
                    inserisciContatto.campagna     = (String) inputs.get('campingID'); 
                    inserisciContatto.cedContatto  = acc.FinServ__BranchCode__c;
                    inserisciContatto.cedFilialeOperatore = acc.FinServ__BranchCode__c;
                    inserisciContatto.codiceContatto      = currentUser.FederationIdentifier;
                    inserisciContatto.codiceOperatore     = currentUser.FederationIdentifier;
                    inserisciContatto.codiceSegnalatore   = (String) inputs.get('codiceSegnalatore');
                    inserisciContatto.datiAnagrafici.codiceFiscale = acc.CRM_TaxId__c;
                    inserisciContatto.datiAnagrafici.cognome       = acc.LastName;
                    inserisciContatto.datiAnagrafici.nome          = acc.FirstName;
                    inserisciContatto.datiAnagrafici.ndg           = acc.CRM_NDG__c;
                    inserisciContatto.datiAnagrafici.email         = acc.PersonEmail; 
                    if(acc.CRM_ResidentialAddress__pc.replaceAll(' , ',',').length()>60){
                        inserisciContatto.datiAnagrafici.indirizzo = acc.CRM_ResidentialAddress__pc.replaceAll(' , ',',').substring(0, 60);
                    } else {
                        inserisciContatto.datiAnagrafici.indirizzo     = acc.CRM_ResidentialAddress__pc.replaceAll(' , ',',');
                    }
                    IF(phone1 != null) {
                        inserisciContatto.datiAnagrafici.telefono      = phone1.startsWith('0') ? phone1 : null;
                    }
                    inserisciContatto.datiAnagrafici.telefonoCellulare = acc.CRM_SmartWebMobilePhone__c != null ? acc.CRM_SmartWebMobilePhone__c : acc.CRM_Phone2__c ;
                    inserisciContatto.datiAnagrafici.codiceCatastaleResidenza = codiceCatastaleResidenza;
                    inserisciContatto.datiAnagrafici.codiceCatastaleNascita = codiceCatastaleNascita;
                    inserisciContatto.datiAnagrafici.sesso = sessoCF > 40 ? 'F' : 'M';
                    inserisciContatto.datiAnagrafici.dataNascita= String.valueOf(acc.PersonBirthdate);
                    inserisciContatto.nota                = (String) inputs.get('note');
                // }
                // CR Ingaggio agenti reti esterne -- Fne 
                body = JSON.serialize(inserisciContatto, true);
    
                req.setBody(body);
            // }
        }

        Http http = new Http();               
        HTTPResponse res = http.send(req);
        String response = res.getBody(); 

        System.debug(LoggingLevel.DEBUG,'### response: '+res.toString());
        System.debug(LoggingLevel.DEBUG,'### response: '+res.getBody());
        System.debug(LoggingLevel.DEBUG,'### responseStatusCode: '+res.getStatusCode());

        // CR Ingaggio agenti reti esterne -- Fine 

        string[] headerkeysRes = res.getHeaderKeys();

        //create an object to store your header key-value pairs
        Map<string, string> headersRes = new map<string, string>();

        //iterate through they keys, and populate your map
        for(string s : headerkeysRes){
            headersRes.put(s,res.getHeader(s));
        }

        WsRestUtils.writeLog(
            apiRequest.Name,
            method,
            body,
            res.getStatusCode(),
            res.getStatus(),
            JSON.serialize(response).length() >= 131071 ? JSON.serialize(response).substring(0, 131071) : JSON.serialize(response),
            headersReq,
            headersRes,
            endpoint,
            ''
            // responseObj.isCorrect() ? null : responseObj.getErrors()
        );
        System.debug(LoggingLevel.DEBUG,'*** END -- makeRequest Method ***');

        if(res.getStatusCode() == 200){
            responseMap.put('esito', true);
            
            // CR Ingaggio agenti reti esterne 
            responseMap.put('codice', '204');
            responseMap.put('messaggio', 'Successo');
            Map<String, Object> mapResp = (Map<String, Object>) JSON.deserializeUntyped(response);
            responseMap.put('idContatto', String.valueOf(mapResp.get('contatto')));
            // CR Ingaggio agenti reti esterne
            insert new CRM_IngaggioRetiEsterne__c (CRM_Cliente__c = (Id) inputs.get('accountId')
                                   , CRM_Autore__c = 'U' + currentUser.FederationIdentifier + '-' + currentUser.Name
                                   , CRM_Motivo__c = 'Proposta Cessione del Quinto'
                                   , CRM_Esito__c = 'Ingaggio agente'
                                   , CRM_CodiceSegnalatore__c = (String) inputs.get('codiceSegnalatore')
                                   , CRM_Notes__c = (String) inputs.get('note')
            );
            // CR Ingaggio agenti reti esterne -- Fine
        }
        // CR Ingaggio agenti reti esterne 
        else {
            if(!String.isBlank(response)){

                Map<String, Object> mapResp = (Map<String, Object>) JSON.deserializeUntyped(response);
                responseMap.put('codice', (String) mapResp.get('codice') );
                responseMap.put('messaggio', (String) mapResp.get('messaggio') );
            }else{
                responseMap.put('codice', res.getStatusCode());
                responseMap.put('messaggio', 'Response is blank'); 
            }
        }
        


        return responseMap;
    }

    public class InserisciContatto {

        public string abiContatto {get;set;}
        public string abiOperatore {get;set;}
        public Integer agenteRiferimento {get;set;}
        public Integer agenteSegnalatore {get;set;}
        // public string azione {get;set;}
        public string campagna {get;set;}
        // public string campagnaPratica {get;set;}
        // public string cartellaDocExt {get;set;}
        public string cedContatto {get;set;}
        public string cedFilialeOperatore {get;set;}
        public string codiceAgenzia {get;set;}
        public string codiceContatto {get;set;}
        public string codiceOperatore {get;set;}
        public string codiceSegnalatore {get;set;}
        // public string dataNuovoContatto {get;set;}
        public DatiAnagrafici datiAnagrafici {get;set;}
        // public string esitoAzione {get;set;}
        public Boolean flagStampaPrivacy {get;set;}
        // public string motivoEsito {get;set;}
        public string nota {get;set;}
        // public string origineContatto {get;set;}
        public string tmpKey {get;set;}

        public InserisciContatto(){

            Long timestamp = datetime.now().getTime();
            this.tmpKey = 'TMP' + datetime.now().year() + datetime.now().month() + datetime.now().day() + timestamp;
            this.DatiAnagrafici = new DatiAnagrafici();
        }
    }

    public class DatiAnagrafici{
        public Integer cliente {get;set;}
        public string codiceCatastaleNascita {get;set;}
        public string codiceCatastaleResidenza {get;set;}
        public string codiceFiscale {get;set;}
        public string cognome {get;set;}
        public string dataNascita {get;set;}
        public DatiPrivacy datiPrivacy {get;set;}
        public string properties {get;set;}
        public string email {get;set;}
        public string indirizzo {get;set;}
        public string ndg {get;set;}
        public string nome {get;set;}
        public string sesso {get;set;}
        public string telefono {get;set;}
        public string telefonoCellulare {get;set;}
        public DatiAnagrafici(){
            this.datiPrivacy = new DatiPrivacy();
        }
    }

    public class DatiPrivacy{
        public String consensoConsegnaInformativaSIC {get;set;}
        public String consensoDatiPrivacyOfferteCommercialiEsterne {get;set;}
        public String consensoDatiPrivacyOfferteCommercialiEsterneAutomatizzate {get;set;}
        public String consensoDatiPrivacyOfferteCommercialiInterne {get;set;}
        public String consensoDatiPrivacyOfferteCommercialiInterneAutomatizzate {get;set;}
        public String consensoDatiPrivacyOfferteServiziAltri {get;set;}
        public String consensoDatiPrivacyPratiche {get;set;}
        public String consensoDatiPrivacyQualita {get;set;}
        public String consensoUlterioriDatiSensibili {get;set;}
        public String dataConsensoDatiPrivacyOfferteCommerciali {get;set;}
        public String dataConsensoDatiPrivacyPratiche {get;set;}
        public String dataConsensoInformativaSIC {get;set;}
        public String dataConsensoUlterioriDatiSensibili {get;set;}

        public DatiPrivacy(){}
    }
}