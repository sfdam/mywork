@RestResource(urlMapping='/v1/getalertforpicorequest/*')
global class REST_GetAlertForPicoRequest {
    
    public class SearchNDGException extends Exception{}

    @HttpPost
    global static GetAlertForPicoResponse getAlertForPicoRequest(AlertForPicoInputDto getAlertForPico){
        System.debug('@@@@@@ REQUEST: '+JSON.serialize(getAlertForPico));
        GetAlertForPicoResponse getAlertForPicoResponse = new GetAlertForPicoResponse();

        RestResponse res;
        RestRequest req;

        
        try{
            req = RestContext.request;
            res = RestContext.response;

            //Set Response Headers
            setHeaders(req, res);
            
            getAlertForPicoResponse=process(getAlertForPico, getAlertForPicoResponse);

            WsRestUtils.writeLog('getAlertForPico', req.httpMethod, JSON.serializePretty(getAlertForPico), '200', 'status', 'output',  req.headers,  res.headers, '', '');


            // return getAlertForPicoResponse;
            //Ricerca NDG START
            

            

        }
        catch(SearchNDGException ex){
            System.debug('XXX');
            throw new SearchNDGException(ex.getMessage());
        }
        catch(Exception ex){
            System.debug('XXX');
            throw new SearchNDGException(ex.getMessage());
        }finally {
            // This gets executed after the exception is handled
            WsRestUtils.writeLog('getalertforpicorequest', req.httpMethod, JSON.serializePretty(getAlertForPico), 200, 'status', JSON.serializePretty(getAlertForPicoResponse),  req.headers,  res.headers, '', '');
            
        }

        return getAlertForPicoResponse;
    }

    global class AlertForPicoInputDto{
        global List<AbiNDG> listaAbiNdg;
    }

    global class AbiNDG{
        global String abi;
        global String ndg;
    }

    global class GetAlertForPicoResponse{
        global AlertForPicoOutputDto getAlertForPicoResponse;
        public GetAlertForPicoResponse(){
            this.getAlertForPicoResponse= new AlertForPicoOutputDto();
        }
    }

    global class AlertForPicoOutputDto{
        global Integer numeroAlertRestituiti;       
        global List<Alert> listaAlert;
    }

    global class Alert{
        global Integer numeroAzioniAlert;       
        global String abi;
        global String ndg;
        global String flag;
    }


    private static void setHeaders(RestRequest req, RestResponse res){
        if(req.headers.containsKey('testata_operationId')){
            res.addHeader('testata_operationId', req.headers.get('testata_operationId'));
        }
    }

    private static getAlertForPicoResponse process(AlertForPicoInputDto getAlertForPico, GetAlertForPicoResponse getRecuperoPortafoglioResponse){

        List<Alert> listaAlertX = new List<Alert>();
        Set<String> setAbi = new Set<String>();
        Set<String> setNDG = new Set<String>();
        Map<String, String> memberMap = new Map<String, String>();
        for(AbiNDG abiNDG : getAlertForPico.listaAbiNdg){
            setAbi.add(abiNDG.abi);
            setNDG.add(abiNDG.ndg);
        }

        List<CampaignMember> membersList = [SELECT Id, Contact.Account.CRM_NDG__c, Contact.Account.FinServ__BankNumber__c, CRM_EsitoDefinitivo__c, Campaign.CRM_SottotipologiaCampagna__c FROM CampaignMember WHERE Contact.Account.CRM_NDG__c IN: setNDG AND Contact.Account.FinServ__BankNumber__c IN: setAbi];
        Map<String,List<Object>> memberSizeMap = SV_Utilities.groupBy(membersList, '{Contact.Account.FinServ__BankNumber__c}_{Contact.Account.CRM_NDG__c}', true);
        System.debug('memberSizeMap: ' + JSON.serialize(memberSizeMap));
        for(CampaignMember member : membersList){
            String key = member.Contact.Account.FinServ__BankNumber__c + '_' + member.Contact.Account.CRM_NDG__c;
            if(member.CRM_EsitoDefinitivo__c){
                memberMap.put(key, '2');
            }else{

                if(!memberMap.containsKey(key)){
                    if(member.Campaign.CRM_SottotipologiaCampagna__c == 'Altra proposta'){
                        memberMap.put(key, '1');
                    }
                }
            }
        }

        for(AbiNDG abiNDG : getAlertForPico.listaAbiNdg){
            
            Alert x = new Alert();
            x.abi = abiNDG.abi;
            x.ndg = abiNDG.ndg;
            x.flag = memberMap.containsKey(abiNDG.abi + '_' + abiNDG.ndg) ? memberMap.get(abiNDG.abi + '_' + abiNDG.ndg) : '0';
            x.numeroAzioniAlert = memberSizeMap.containsKey(abiNDG.abi + '_' + abiNDG.ndg) ? memberSizeMap.get(abiNDG.abi + '_' + abiNDG.ndg).size() : 0;
            listaAlertX.add(x);
        }
        
        getRecuperoPortafoglioResponse.getAlertForPicoResponse.numeroAlertRestituiti = listaAlertX.size();
        getRecuperoPortafoglioResponse.getAlertForPicoResponse.listaAlert = listaAlertX;
        
        return getRecuperoPortafoglioResponse;
    }
}