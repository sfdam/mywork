/**
 * @description       : aggiunte le proposte "Bstore" su Opportunity (documento specifica :"BPER_Proposte Bstore su Opps")
 * @author            : alessandro di nardo
 * @group             : ten
 * @last modified on  : 20-06-2023 
 * @last modified by  : 
**/
@RestResource(urlMapping='/v1/scadenziariostoricowebservice/*')
global class REST_ScadenziarioStoricoWebService {
    
    public class SearchNDGException extends Exception{}

    @HttpPost
    global static GetScadenziarioStoricoWebServiceResponse getScadenziarioStoricoWebServiceRequest(ScadenziarioStoricoWebServiceInputDto scriviPropostaCrm){
        System.debug('AD getScadenziarioStoricoWebServiceRequest ');
        System.debug('AD oggetto inviato  : ' + scriviPropostaCrm);

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
        System.debug('AD sono in process');
        System.debug('AD GetScadenziarioStoricoWebServiceResponse : ' + x);
        System.debug('AD getScadenziarioStoricoWebService : ' + getScadenziarioStoricoWebService);
        //Start Alessandro Di Nardo @ten 15/06/2023
        String checkClienteCointestatari=getScadenziarioStoricoWebService.ScadenziarioStoricoCrmWsServiceRequest.proposta.ndgClienteCointestatari;
        String rep = checkClienteCointestatari.replace('|',',');
        List<String> listaClienteCointestatari = rep.split(',');

        System.debug('AD checkClienteCointestatari : ' + checkClienteCointestatari);
        System.debug('AD ndgClientePrimario : ' + getScadenziarioStoricoWebService.ScadenziarioStoricoCrmWsServiceRequest.proposta.ndgClientePrimario);
        System.debug('AD idProposta : ' + getScadenziarioStoricoWebService.ScadenziarioStoricoCrmWsServiceRequest.proposta.idProposta);
        System.debug('AD listaClienteCointestatari : ' + listaClienteCointestatari);
        System.debug('AD banca : ' + getScadenziarioStoricoWebService.ScadenziarioStoricoCrmWsServiceRequest.proposta.banca);

        
        List<Opportunity> proposteCOntrattiList = [SELECT Id FROM Opportunity 
                                                    WHERE (Account.CRM_NDG__c =:getScadenziarioStoricoWebService.ScadenziarioStoricoCrmWsServiceRequest.proposta.ndgClientePrimario 
                                                    OR Account.CRM_NDG__c IN :listaClienteCointestatari) AND CRM_Canale__c ='BSTORE' AND CRM_IdProposta__c = :getScadenziarioStoricoWebService.ScadenziarioStoricoCrmWsServiceRequest.proposta.idProposta];        
        System.debug(getScadenziarioStoricoWebService.ScadenziarioStoricoCrmWsServiceRequest.proposta.ndgClientePrimario);
        System.debug('AD proposteCOntrattiList : ' + proposteCOntrattiList);

        List<Account> ndgList = [ SELECT Id 
                                    FROM Account 
                                    WHERE (CRM_NDG__c =:getScadenziarioStoricoWebService.ScadenziarioStoricoCrmWsServiceRequest.proposta.ndgClientePrimario OR CRM_NDG__c IN :listaClienteCointestatari) AND  FinServ__BankNumber__c =: getScadenziarioStoricoWebService.ScadenziarioStoricoCrmWsServiceRequest.proposta.banca];
        System.debug('AD ndgList : ' + ndgList);

                                    /*Alessandro Di Nardo @ten 15/06/2023
        List<Account> cointestazioneList = new List<Account>();
        if(getScadenziarioStoricoWebService.ScadenziarioStoricoCrmWsServiceRequest.proposta.ndgCointestazione != null) {
            cointestazioneList = [ SELECT Id 
                         FROM Account 
                         WHERE CRM_NDG__c =: getScadenziarioStoricoWebService.ScadenziarioStoricoCrmWsServiceRequest.proposta.ndgCointestazione AND 
                            FinServ__BankNumber__c =: getScadenziarioStoricoWebService.ScadenziarioStoricoCrmWsServiceRequest.proposta.banca];
        }*/
        //End Alessandro Di Nardo @ten 15/06/2023
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
            //Start Alessandro Di Nardo @ten 15/06/2023
            String utente = getScadenziarioStoricoWebService.ScadenziarioStoricoCrmWsServiceRequest.proposta.utente;
            String repUtente = utente.replace('U','');
            System.debug('AD repUtente : ' + repUtente);
            List<Opportunity> listOpp = new List<Opportunity>();
            List<User> idUser = [SELECT Id FROM User WHERE FederationIdentifier =:repUtente];
            System.debug('AD idUser : ' + idUser);

            for(Account acc : ndgList){
                listOpp.add(new Opportunity(
                    Name = (String)('OPP-' + getScadenziarioStoricoWebService.ScadenziarioStoricoCrmWsServiceRequest.proposta.idProposta),
                    CloseDate = getScadenziarioStoricoWebService.ScadenziarioStoricoCrmWsServiceRequest.proposta.dataScadenza != null ? Date.valueOf(dataScadenza.substring(0,4) + '-' + dataScadenza.substring(4,6) + '-' + dataScadenza.substring(6,8)) : null,
                    CRM_DataUltimaModifica__c = getScadenziarioStoricoWebService.ScadenziarioStoricoCrmWsServiceRequest.proposta.dataUltimaModifica != null ? Date.valueOf(dataUltimaModifica.substring(0,4) + '-' + dataUltimaModifica.substring(4,6) + '-' + dataUltimaModifica.substring(6,8)) : null,
                    CRM_Banca__c = getScadenziarioStoricoWebService.ScadenziarioStoricoCrmWsServiceRequest.proposta.banca,
                    CRM_Filiale__c = getScadenziarioStoricoWebService.ScadenziarioStoricoCrmWsServiceRequest.proposta.filiale,
                    CRM_IdProposta__c =  getScadenziarioStoricoWebService.ScadenziarioStoricoCrmWsServiceRequest.proposta.idProposta,
                    AccountId =acc.Id,
                    CRM_DataScadenzaIniziale__c = getScadenziarioStoricoWebService.ScadenziarioStoricoCrmWsServiceRequest.proposta.dataScadenza != null ? Date.valueOf(dataScadenza.substring(0,4) + '-' + dataScadenza.substring(4,6) + '-' + dataScadenza.substring(6,8)) : null,
                    StageName = getScadenziarioStoricoWebService.ScadenziarioStoricoCrmWsServiceRequest.proposta.descStatoProposta,
                    CRM_StatoContratto__c = getScadenziarioStoricoWebService.ScadenziarioStoricoCrmWsServiceRequest.proposta.descStatoContratto,
                    CRM_Codiceprodotto__c = getScadenziarioStoricoWebService.ScadenziarioStoricoCrmWsServiceRequest.proposta.codProdotto,
                    CRM_NoteEsitazioneOpps__c = getScadenziarioStoricoWebService.ScadenziarioStoricoCrmWsServiceRequest.proposta.nota,
                    CRM_Canale__c = 'Bstore',
                    OwnerId =idUser[0].Id
                    )
                );
            }
            System.debug('AD listOpp : ' + listOpp);
            insert listOpp;
            //End Alessandro Di Nardo @ten 15/06/2023

        }else{

            System.debug('ESITO: UPDATE');
            String dataUltimaModifica = getScadenziarioStoricoWebService.ScadenziarioStoricoCrmWsServiceRequest.proposta.dataUltimaModifica;
            String dataScadenza = getScadenziarioStoricoWebService.ScadenziarioStoricoCrmWsServiceRequest.proposta.dataScadenza;
            //Start Alessandro Di Nardo @ten 15/06/2023
            List<Opportunity> updateProposteCOntrattiList = new List<Opportunity>();
            for(Opportunity prContratto : proposteCOntrattiList){
                
                prContratto.CRM_DataUltimaModifica__c = getScadenziarioStoricoWebService.ScadenziarioStoricoCrmWsServiceRequest.proposta.dataUltimaModifica != null ? Date.valueOf(dataUltimaModifica.substring(0,4) + '-' + dataUltimaModifica.substring(4,6) + '-' + dataUltimaModifica.substring(6,8)) : null; 
                prContratto.CRM_Banca__c = getScadenziarioStoricoWebService.ScadenziarioStoricoCrmWsServiceRequest.proposta.banca; 
                prContratto.CRM_Filiale__c = getScadenziarioStoricoWebService.ScadenziarioStoricoCrmWsServiceRequest.proposta.filiale; 
                prContratto.CRM_DataScadenzaIniziale__c  = getScadenziarioStoricoWebService.ScadenziarioStoricoCrmWsServiceRequest.proposta.dataScadenza != null ? Date.valueOf(dataScadenza.substring(0,4) + '-' + dataScadenza.substring(4,6) + '-' + dataScadenza.substring(6,8)) : null; 
                prContratto.StageName = getScadenziarioStoricoWebService.ScadenziarioStoricoCrmWsServiceRequest.proposta.descStatoProposta; 
                prContratto.CRM_StatoContratto__c = getScadenziarioStoricoWebService.ScadenziarioStoricoCrmWsServiceRequest.proposta.descStatoContratto;
                prContratto.CRM_Codiceprodotto__c = getScadenziarioStoricoWebService.ScadenziarioStoricoCrmWsServiceRequest.proposta.codProdotto; 
                prContratto.CRM_NoteEsitazioneOpps__c  = getScadenziarioStoricoWebService.ScadenziarioStoricoCrmWsServiceRequest.proposta.nota; 
                /* proposteCOntrattiList[0].CRM_Codiceprodotto__c = getScadenziarioStoricoWebService.ScadenziarioStoricoCrmWsServiceRequest.proposta.codProdotto; 
                proposteCOntrattiList[0].CRM_NoteEsitazioneOpps__c  = getScadenziarioStoricoWebService.ScadenziarioStoricoCrmWsServiceRequest.proposta.nota;  */
                updateProposteCOntrattiList.add(prContratto);
            }
            update updateProposteCOntrattiList;
            //proposteCOntrattiList[x].CRM_DataUltimaModifica__c = getScadenziarioStoricoWebService.ScadenziarioStoricoCrmWsServiceRequest.proposta.dataUltimaModifica != null ? Date.valueOf(dataUltimaModifica.substring(0,4) + '-' + dataUltimaModifica.substring(4,6) + '-' + dataUltimaModifica.substring(6,8)) : null; proposteCOntrattiList[x].CRM_Banca__c = getScadenziarioStoricoWebService.ScadenziarioStoricoCrmWsServiceRequest.proposta.banca; proposteCOntrattiList[x].CRM_Filiale__c = getScadenziarioStoricoWebService.ScadenziarioStoricoCrmWsServiceRequest.proposta.filiale; proposteCOntrattiList[x].CRM_DataScadenzaIniziale__c  = getScadenziarioStoricoWebService.ScadenziarioStoricoCrmWsServiceRequest.proposta.dataScadenza != null ? Date.valueOf(dataScadenza.substring(0,4) + '-' + dataScadenza.substring(4,6) + '-' + dataScadenza.substring(6,8)) : null; proposteCOntrattiList[x].StageName = getScadenziarioStoricoWebService.ScadenziarioStoricoCrmWsServiceRequest.proposta.descStatoProposta; proposteCOntrattiList[x].CRM_StatoContratto__c = getScadenziarioStoricoWebService.ScadenziarioStoricoCrmWsServiceRequest.proposta.descStatoContratto; proposteCOntrattiList[0].CRM_Codiceprodotto__c = getScadenziarioStoricoWebService.ScadenziarioStoricoCrmWsServiceRequest.proposta.codProdotto; proposteCOntrattiList[0].CRM_NoteEsitazioneOpps__c  = getScadenziarioStoricoWebService.ScadenziarioStoricoCrmWsServiceRequest.proposta.nota; 
            //End Alessandro Di Nardo @ten 15/06/2023
            //update proposteCOntrattiList;            
        }


        x.scriviPropostaCrmResponse.ScadenziarioStoricoCrmServiceResponse.esitoList = 'OK';
      
        return x;
    }


}