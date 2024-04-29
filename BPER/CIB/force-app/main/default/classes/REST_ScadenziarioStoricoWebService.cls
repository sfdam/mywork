@RestResource(urlMapping='/v1/scadenziariostoricowebservice/*')
global class REST_ScadenziarioStoricoWebService {
    
    public class SearchNDGException extends Exception{}

    @HttpPost
    global static GetScadenziarioStoricoWebServiceResponse getScadenziarioStoricoWebServiceRequest(ScadenziarioStoricoWebServiceInputDto scriviPropostaCrm){
        System.debug('@@@@@@ REQUEST: '+JSON.serialize(scriviPropostaCrm));
        GetScadenziarioStoricoWebServiceResponse getScadenziarioStoricoWebServiceResponse = new GetScadenziarioStoricoWebServiceResponse();

        RestResponse res;
        RestRequest req;

        
        try{
            req = RestContext.request;
            res = RestContext.response;

            //Set Response Headers
            setHeaders(req, res);
            
            getScadenziarioStoricoWebServiceResponse=process(scriviPropostaCrm, getScadenziarioStoricoWebServiceResponse);


            // return getScadenziarioStoricoWebServiceResponse;
            //Ricerca NDG START
            

            

        }
        catch(SearchNDGException ex){

            System.debug('SearchNDGException ' + ex.getMessage());
            throw new SearchNDGException(ex.getMessage());

        }
        catch(Exception ex){
            System.debug('Exception ' + ex.getMessage());
            throw new SearchNDGException(ex.getMessage());

        }finally {
            // This gets executed after the exception is handled
            WsRestUtils.writeLog('getScadenziarioStoricoWebService', req.httpMethod, JSON.serializePretty(scriviPropostaCrm), 200, 'status', JSON.serializePretty(getScadenziarioStoricoWebServiceResponse),  req.headers,  res.headers, '', '');
            
        }

        return getScadenziarioStoricoWebServiceResponse;
    }

    global class ScadenziarioStoricoWebServiceInputDto{
        global ScadenziarioStoricoCrmWsServiceRequest ScadenziarioStoricoCrmWsServiceRequest;
    }

    global class ScadenziarioStoricoCrmWsServiceRequest{
        global Proposta proposta;
    }

    global class Proposta{
        global String utente;
        global String dataUltimaModifica;
        global String autore;
        global String banca;
        global String filiale;
        global String idProposta;
        global String ndgClientePrimario;
        global String ndgClienteCointestatari;
        global String ndgCointestazione;
        global String codProdotto;
        global String dataScadenza;
        global String codStatoProposta;
        global String descStatoProposta;
        global String descStatoContratto;
        global String dataInserimento;
        global String tipologiaRecord;
        global String nota;
    }

    private static void setHeaders(RestRequest req, RestResponse res){
        if(req.headers.containsKey('testata_operationId')){
            res.addHeader('testata_operationId', req.headers.get('testata_operationId'));
        }
    }

    global class GetScadenziarioStoricoWebServiceResponse{
        global ScadenziarioStoricoWebServiceOutputDto scriviPropostaCrmResponse;

        public GetScadenziarioStoricoWebServiceResponse(){
            this.scriviPropostaCrmResponse = new ScadenziarioStoricoWebServiceOutputDto();
        }
    }

    global class ScadenziarioStoricoWebServiceOutputDto{
        global ScadenziarioStoricoCrmServiceResponse ScadenziarioStoricoCrmServiceResponse;
        public ScadenziarioStoricoWebServiceOutputDto(){
            this.ScadenziarioStoricoCrmServiceResponse = new ScadenziarioStoricoCrmServiceResponse();
        }
    }

    global class ScadenziarioStoricoCrmServiceResponse{
        global String esitoList;
    }

    private static getScadenziarioStoricoWebServiceResponse process(ScadenziarioStoricoWebServiceInputDto getScadenziarioStoricoWebService, GetScadenziarioStoricoWebServiceResponse x){
        System.debug(X);
        List<CRM_ProposteContrattiPreventivi__c> proposteCOntrattiList = [SELECT Id, CRM_NDGCointestazione__c, CRM_DataUltimaModifica__c, CRM_Autore__c, CRM_Banca__c, CRM_Filiale__c, CRM_Id__c, CRM_NDGPrimario__c, CRM_NDGPrimario__r.CRM_NDG__c, CRM_DataScadenza__c, CRM_StatoProposta__c, CRM_StatoContratto__c, CRM_DataInserimento__c, CRM_TipologiaRecord__c, CRM_Note__c FROM CRM_ProposteContrattiPreventivi__c WHERE CRM_NDGPrimario__r.CRM_NDG__c =: getScadenziarioStoricoWebService.ScadenziarioStoricoCrmWsServiceRequest.proposta.ndgClientePrimario AND CRM_Id__c =: getScadenziarioStoricoWebService.ScadenziarioStoricoCrmWsServiceRequest.proposta.idProposta];
        System.debug(getScadenziarioStoricoWebService.ScadenziarioStoricoCrmWsServiceRequest.proposta.ndgClientePrimario);
        List<Account> ndgList = [ SELECT Id 
                     FROM Account 
                     WHERE CRM_NDG__c =: getScadenziarioStoricoWebService.ScadenziarioStoricoCrmWsServiceRequest.proposta.ndgClientePrimario AND 
                        FinServ__BankNumber__c =: getScadenziarioStoricoWebService.ScadenziarioStoricoCrmWsServiceRequest.proposta.banca];
        
        List<Account> cointestazioneList = new List<Account>();
        if(getScadenziarioStoricoWebService.ScadenziarioStoricoCrmWsServiceRequest.proposta.ndgCointestazione != null) {
            cointestazioneList = [ SELECT Id 
                         FROM Account 
                         WHERE CRM_NDG__c =: getScadenziarioStoricoWebService.ScadenziarioStoricoCrmWsServiceRequest.proposta.ndgCointestazione AND 
                            FinServ__BankNumber__c =: getScadenziarioStoricoWebService.ScadenziarioStoricoCrmWsServiceRequest.proposta.banca];
        }
        
        if(ndgList.size() <= 0){

            //throw new SearchNDGException('NDG ' + getScadenziarioStoricoWebService.ScadenziarioStoricoCrmWsServiceRequest.proposta.ndgClientePrimario + ' ABI ' +
                                        //getScadenziarioStoricoWebService.ScadenziarioStoricoCrmWsServiceRequest.proposta.banca + ' NON TROVATO');
            x.scriviPropostaCrmResponse.ScadenziarioStoricoCrmServiceResponse.esitoList = 'OK';
            return x;
        }
        
        if(proposteCOntrattiList.isEmpty()){

            System.debug('ESITO: INSERT');
            String dataUltimaModifica = getScadenziarioStoricoWebService.ScadenziarioStoricoCrmWsServiceRequest.proposta.dataUltimaModifica;
            String dataScadenza = getScadenziarioStoricoWebService.ScadenziarioStoricoCrmWsServiceRequest.proposta.dataScadenza;
            insert new CRM_ProposteContrattiPreventivi__c(
                CRM_NDGCointestazione__c = cointestazioneList.size() > 0 ? cointestazioneList[0].Id : null,
                CRM_DataUltimaModifica__c = getScadenziarioStoricoWebService.ScadenziarioStoricoCrmWsServiceRequest.proposta.dataUltimaModifica != null ? Date.valueOf(dataUltimaModifica.substring(0,4) + '-' + dataUltimaModifica.substring(4,6) + '-' + dataUltimaModifica.substring(6,8)) : null,
                CRM_Autore__c = getScadenziarioStoricoWebService.ScadenziarioStoricoCrmWsServiceRequest.proposta.autore,
                CRM_Banca__c = getScadenziarioStoricoWebService.ScadenziarioStoricoCrmWsServiceRequest.proposta.banca,
                CRM_Filiale__c = getScadenziarioStoricoWebService.ScadenziarioStoricoCrmWsServiceRequest.proposta.filiale,
                CRM_Id__c = getScadenziarioStoricoWebService.ScadenziarioStoricoCrmWsServiceRequest.proposta.idProposta,
                CRM_NDGPrimario__c = ndgList[0].Id,
                CRM_DataScadenza__c = getScadenziarioStoricoWebService.ScadenziarioStoricoCrmWsServiceRequest.proposta.dataScadenza != null ? Date.valueOf(dataScadenza.substring(0,4) + '-' + dataScadenza.substring(4,6) + '-' + dataScadenza.substring(6,8)) : null,
                CRM_StatoProposta__c = getScadenziarioStoricoWebService.ScadenziarioStoricoCrmWsServiceRequest.proposta.descStatoProposta,
                CRM_StatoContratto__c = getScadenziarioStoricoWebService.ScadenziarioStoricoCrmWsServiceRequest.proposta.descStatoContratto,
                CRM_DataInserimento__c = getScadenziarioStoricoWebService.ScadenziarioStoricoCrmWsServiceRequest.proposta.dataInserimento != null ? Date.valueOf(getScadenziarioStoricoWebService.ScadenziarioStoricoCrmWsServiceRequest.proposta.dataInserimento) : null,
                CRM_TipologiaRecord__c = getScadenziarioStoricoWebService.ScadenziarioStoricoCrmWsServiceRequest.proposta.tipologiaRecord,
                CRM_Referente__c = getScadenziarioStoricoWebService.ScadenziarioStoricoCrmWsServiceRequest.proposta.utente,
                CRM_Codiceprodotto__c = getScadenziarioStoricoWebService.ScadenziarioStoricoCrmWsServiceRequest.proposta.codProdotto,
                CRM_NDGClienticointestatari__c = getScadenziarioStoricoWebService.ScadenziarioStoricoCrmWsServiceRequest.proposta.ndgClienteCointestatari,
                CRM_Note__c = getScadenziarioStoricoWebService.ScadenziarioStoricoCrmWsServiceRequest.proposta.nota,
                CRM_Motivo__c = 'Bstore - Proposta/Contratto'
            );
        }else{

            System.debug('ESITO: UPDATE');
            String dataUltimaModifica = getScadenziarioStoricoWebService.ScadenziarioStoricoCrmWsServiceRequest.proposta.dataUltimaModifica;
            String dataScadenza = getScadenziarioStoricoWebService.ScadenziarioStoricoCrmWsServiceRequest.proposta.dataScadenza;
            proposteCOntrattiList[0].CRM_NDGCointestazione__c = cointestazioneList.size() > 0 ? cointestazioneList[0].Id : null;
            proposteCOntrattiList[0].CRM_DataUltimaModifica__c = getScadenziarioStoricoWebService.ScadenziarioStoricoCrmWsServiceRequest.proposta.dataUltimaModifica != null ? Date.valueOf(dataUltimaModifica.substring(0,4) + '-' + dataUltimaModifica.substring(4,6) + '-' + dataUltimaModifica.substring(6,8)) : null;
            proposteCOntrattiList[0].CRM_Autore__c = getScadenziarioStoricoWebService.ScadenziarioStoricoCrmWsServiceRequest.proposta.autore;
            proposteCOntrattiList[0].CRM_Banca__c = getScadenziarioStoricoWebService.ScadenziarioStoricoCrmWsServiceRequest.proposta.banca;
            proposteCOntrattiList[0].CRM_Filiale__c = getScadenziarioStoricoWebService.ScadenziarioStoricoCrmWsServiceRequest.proposta.filiale;
            proposteCOntrattiList[0].CRM_Id__c = getScadenziarioStoricoWebService.ScadenziarioStoricoCrmWsServiceRequest.proposta.idProposta;
            proposteCOntrattiList[0].CRM_NDGPrimario__c = ndgList[0].Id;
            proposteCOntrattiList[0].CRM_DataScadenza__c = getScadenziarioStoricoWebService.ScadenziarioStoricoCrmWsServiceRequest.proposta.dataScadenza != null ? Date.valueOf(dataScadenza.substring(0,4) + '-' + dataScadenza.substring(4,6) + '-' + dataScadenza.substring(6,8)) : null;
            proposteCOntrattiList[0].CRM_StatoProposta__c = getScadenziarioStoricoWebService.ScadenziarioStoricoCrmWsServiceRequest.proposta.descStatoProposta;
            proposteCOntrattiList[0].CRM_StatoContratto__c = getScadenziarioStoricoWebService.ScadenziarioStoricoCrmWsServiceRequest.proposta.descStatoContratto;
            proposteCOntrattiList[0].CRM_DataInserimento__c = getScadenziarioStoricoWebService.ScadenziarioStoricoCrmWsServiceRequest.proposta.dataInserimento != null ? Date.valueOf(getScadenziarioStoricoWebService.ScadenziarioStoricoCrmWsServiceRequest.proposta.dataInserimento) : null;
            proposteCOntrattiList[0].CRM_TipologiaRecord__c = getScadenziarioStoricoWebService.ScadenziarioStoricoCrmWsServiceRequest.proposta.tipologiaRecord;
            proposteCOntrattiList[0].CRM_Referente__c = getScadenziarioStoricoWebService.ScadenziarioStoricoCrmWsServiceRequest.proposta.utente;
            proposteCOntrattiList[0].CRM_Codiceprodotto__c = getScadenziarioStoricoWebService.ScadenziarioStoricoCrmWsServiceRequest.proposta.codProdotto;
            proposteCOntrattiList[0].CRM_NDGClienticointestatari__c = getScadenziarioStoricoWebService.ScadenziarioStoricoCrmWsServiceRequest.proposta.ndgClienteCointestatari;
            proposteCOntrattiList[0].CRM_Note__c = getScadenziarioStoricoWebService.ScadenziarioStoricoCrmWsServiceRequest.proposta.nota;
            if(getScadenziarioStoricoWebService.ScadenziarioStoricoCrmWsServiceRequest.proposta.descStatoContratto == 'Contratto Concluso'){
                proposteCOntrattiList[0].CRM_Esito__c = 'Prodotto venduto';
            }
            update proposteCOntrattiList;
        }


        x.scriviPropostaCrmResponse.ScadenziarioStoricoCrmServiceResponse.esitoList = 'OK';
      
        return x;
    }


}