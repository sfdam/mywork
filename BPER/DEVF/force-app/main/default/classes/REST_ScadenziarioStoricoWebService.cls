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
        global String utente; //non mappare al momento
        global String dataUltimaModifica; // CRM_Data_Esitazione__c (DateTime) valorizzare con orario fisso
        global String autore; // CRM_Autore__c (Text) 
        global String banca;
        global String filiale; //non mappare al momento
        global String idProposta; // CRM_IdProposta__c (Text)
        global String ndgClientePrimario; // AccountId se non è popolato ndgCointestazione
        global String ndgClienteCointestatari; // non mappare al momento
        global String ndgCointestazione; // AccountId se popolato
        global String codProdotto; // campo di lookup
        global String dataScadenza; // CloseDate (Date)
        global String codStatoProposta; // non mappare al momento
        global String descStatoProposta; // StageName da mappare combinazione stato proposta - stato contratto a seconda di chi è popolato + CRM_EsitoContatto__c tramite tabella riconduzione
        global String descStatoContratto; // StageName da mappare combinazione stato proposta - stato contratto a seconda di chi è popolato + CRM_EsitoContatto__c tramite tabella riconduzione
        global String dataInserimento; // CreatedDate (DateTime)
        global String tipologiaRecord; // non mappare al momento
        global String nota; // CRM_NoteEsitazioneOpps__c (Long Text Area)
        // CRM_Canale__c = BSTORE e RecordtypeId = Opportunit_Bstore e CRM_Oggetto__c = Product2.CRM_MacroGroup__c  e CRM_Bisogno__c = Product2.CRM_Bisogno__c
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
        String checkClienteCointestatari = '';
        String rep = '';
        List<String> listaClienteCointestatari = new List<String>();
        if(getScadenziarioStoricoWebService.ScadenziarioStoricoCrmWsServiceRequest.proposta.ndgClienteCointestatari != null) {
            checkClienteCointestatari=getScadenziarioStoricoWebService.ScadenziarioStoricoCrmWsServiceRequest.proposta.ndgClienteCointestatari;
            rep = checkClienteCointestatari.replace('|',',');
            listaClienteCointestatari = rep.split(',');
        }

        System.debug('AD checkClienteCointestatari : ' + checkClienteCointestatari);
        System.debug('AD ndgClientePrimario : ' + getScadenziarioStoricoWebService.ScadenziarioStoricoCrmWsServiceRequest.proposta.ndgClientePrimario);
        System.debug('AD ndgCointestazione: ' + getScadenziarioStoricoWebService.ScadenziarioStoricoCrmWsServiceRequest.proposta.ndgCointestazione);
        System.debug('AD idProposta : ' + getScadenziarioStoricoWebService.ScadenziarioStoricoCrmWsServiceRequest.proposta.idProposta);
        System.debug('AD listaClienteCointestatari : ' + listaClienteCointestatari);
        System.debug('AD banca : ' + getScadenziarioStoricoWebService.ScadenziarioStoricoCrmWsServiceRequest.proposta.banca);
        
        Id bstoreRTId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Opportunit_Bstore').getRecordTypeId();
        String ndgForOpps = '';
        
        if(getScadenziarioStoricoWebService.ScadenziarioStoricoCrmWsServiceRequest.proposta.ndgCointestazione != null) {
            ndgForOpps = getScadenziarioStoricoWebService.ScadenziarioStoricoCrmWsServiceRequest.proposta.ndgCointestazione;
        } else {
            ndgForOpps = getScadenziarioStoricoWebService.ScadenziarioStoricoCrmWsServiceRequest.proposta.ndgClientePrimario;
        }
        
        System.debug('AD ndgForOpps : ' + ndgForOpps );

        
        List<Opportunity> proposteCOntrattiList = [SELECT Id FROM Opportunity 
                                                    WHERE Account.CRM_NDG__c = :ndgForOpps 
                                                    AND CRM_Canale__c ='BSTORE'
                                                    AND RecordTypeId = : bstoreRTId
                                                    AND CRM_IdProposta__c = :getScadenziarioStoricoWebService.ScadenziarioStoricoCrmWsServiceRequest.proposta.idProposta];        
        
        System.debug('AD proposteCOntrattiList : ' + proposteCOntrattiList);

        List<Account> ndgList = [ SELECT Id 
                                    FROM Account 
                                    WHERE CRM_NDG__c =:ndgForOpps 
                                    AND  FinServ__BankNumber__c =: getScadenziarioStoricoWebService.ScadenziarioStoricoCrmWsServiceRequest.proposta.banca];
        System.debug('AD ndgList : ' + ndgList);
        
        String checkProdotti = '';
        String prodottiReplace = '';
        List<String> listaProdotti = new List<String>();
        if(getScadenziarioStoricoWebService.ScadenziarioStoricoCrmWsServiceRequest.proposta.codProdotto != null) {
            checkProdotti = getScadenziarioStoricoWebService.ScadenziarioStoricoCrmWsServiceRequest.proposta.codProdotto;
            prodottiReplace = checkProdotti.replace('|',',');
            listaProdotti = prodottiReplace.split(',');
        }
        
        List<Product2> products = [SELECT Id, ProductCode, CRM_MacroGroup__c , CRM_Bisogno__c FROM Product2
                                                    WHERE ProductCode IN :listaProdotti ];  
                                                    
        Map<String, Id> productMap = new Map<String, Id>();

        for (Product2 product : products) {
            productMap.put(product.ProductCode, product.Id);
        }
                                                    
        String stageNameOpp = '';
        String esitoOpp = '';
        if(getScadenziarioStoricoWebService.ScadenziarioStoricoCrmWsServiceRequest.proposta.descStatoContratto != null) {
            BstoreSuOpps__mdt metadataForOpps = [SELECT StageNameOpp__c, EsitoOpp__c FROM BstoreSuOpps__mdt WHERE StatoBstoreKey__c = :getScadenziarioStoricoWebService.ScadenziarioStoricoCrmWsServiceRequest.proposta.descStatoContratto][0];
            stageNameOpp = metadataForOpps.StageNameOpp__c;
            esitoOpp = metadataForOpps.EsitoOpp__c;
        } else if (getScadenziarioStoricoWebService.ScadenziarioStoricoCrmWsServiceRequest.proposta.descStatoProposta != null) {
            BstoreSuOpps__mdt metadataForOpps = [SELECT StageNameOpp__c, EsitoOpp__c FROM BstoreSuOpps__mdt WHERE StatoBstoreKey__c = :getScadenziarioStoricoWebService.ScadenziarioStoricoCrmWsServiceRequest.proposta.descStatoProposta][0];
            stageNameOpp = metadataForOpps.StageNameOpp__c;
            esitoOpp = metadataForOpps.EsitoOpp__c;
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
            Datetime dataOraUltimaModifica = Datetime.newInstanceGmt(
                Integer.valueOf(dataUltimaModifica.substring(0, 4)),
                Integer.valueOf(dataUltimaModifica.substring(5, 7)),
                Integer.valueOf(dataUltimaModifica.substring(8, 9)),
                2, // Ore fisse a 02:00
                0, // Minuti
                0  // Secondi
            );
            String dataScadenza = getScadenziarioStoricoWebService.ScadenziarioStoricoCrmWsServiceRequest.proposta.dataScadenza;
            String dataInserimento = getScadenziarioStoricoWebService.ScadenziarioStoricoCrmWsServiceRequest.proposta.dataInserimento;
            //Start Alessandro Di Nardo @ten 15/06/2023
            String utente = getScadenziarioStoricoWebService.ScadenziarioStoricoCrmWsServiceRequest.proposta.utente;
            String repUtente = utente.replace('U','');
            System.debug('AD repUtente : ' + repUtente);
            List<Opportunity> listOpp = new List<Opportunity>();
            List<User> idUser = [SELECT Id FROM User WHERE FederationIdentifier =:repUtente];
            System.debug('AD idUser : ' + idUser);

            if(!productMap.isEmpty()) {
                for (String productCode : productMap.keySet()) {
                    listOpp.add(new Opportunity(
                        Name = (String)('OPP-' + getScadenziarioStoricoWebService.ScadenziarioStoricoCrmWsServiceRequest.proposta.idProposta),
                        CRM_Data_Esitazione__c = dataOraUltimaModifica != null ? dataOraUltimaModifica : null,
                        CRM_Autore__c = getScadenziarioStoricoWebService.ScadenziarioStoricoCrmWsServiceRequest.proposta.autore,
                        CRM_IdProposta__c =  getScadenziarioStoricoWebService.ScadenziarioStoricoCrmWsServiceRequest.proposta.idProposta,
                        AccountId = ndgList.size() > 0 ? ndgList[0].Id : null,
                        CloseDate = getScadenziarioStoricoWebService.ScadenziarioStoricoCrmWsServiceRequest.proposta.dataScadenza != null ? Date.valueOf(dataScadenza) : null, 
                        StageName = stageNameOpp,
                        CRM_EsitoContatto__c = esitoOpp,
                        CreatedDate = getScadenziarioStoricoWebService.ScadenziarioStoricoCrmWsServiceRequest.proposta.dataInserimento != null ? Date.valueOf(dataInserimento) : null, 
                        CRM_Prodotto__c = productMap.get(productCode) != null ? productMap.get(productCode) : null,
                        CRM_NoteEsitazioneOpps__c = getScadenziarioStoricoWebService.ScadenziarioStoricoCrmWsServiceRequest.proposta.nota,
                        CRM_Canale__c = 'BSTORE',
                        RecordTypeId = bstoreRTId,
                        OwnerId =idUser[0].Id
                        //CRM_Oggetto__c = pdt.CRM_MacroGroup__c,
                        //CRM_Bisogno__c = pdt.CRM_Bisogno__c
                        )
                    );   
                }       
            }
            
            System.debug('AD listOpp : ' + listOpp);
            insert listOpp;
            //End Alessandro Di Nardo @ten 15/06/2023

        }else{

            System.debug('ESITO: UPDATE');
            String dataUltimaModifica = getScadenziarioStoricoWebService.ScadenziarioStoricoCrmWsServiceRequest.proposta.dataUltimaModifica;
            Datetime dataOraUltimaModifica = Datetime.newInstanceGmt(
                Integer.valueOf(dataUltimaModifica.substring(0, 4)),
                Integer.valueOf(dataUltimaModifica.substring(5, 7)),
                Integer.valueOf(dataUltimaModifica.substring(8, 9)),
                2, // Ore fisse a 02:00
                0, // Minuti
                0  // Secondi
            );
            String dataScadenza = getScadenziarioStoricoWebService.ScadenziarioStoricoCrmWsServiceRequest.proposta.dataScadenza;
            //Start Alessandro Di Nardo @ten 15/06/2023
            List<Opportunity> updateProposteCOntrattiList = new List<Opportunity>();
            for(Opportunity prContratto : proposteCOntrattiList){
                
                prContratto.CRM_Data_Esitazione__c = dataOraUltimaModifica != null ? dataOraUltimaModifica : null; 
                prContratto.CloseDate = getScadenziarioStoricoWebService.ScadenziarioStoricoCrmWsServiceRequest.proposta.dataScadenza != null ? Date.valueOf(dataScadenza) : null; 
                prContratto.StageName = stageNameOpp; 
                prContratto.CRM_EsitoContatto__c = esitoOpp; 
                prContratto.CRM_NoteEsitazioneOpps__c  = getScadenziarioStoricoWebService.ScadenziarioStoricoCrmWsServiceRequest.proposta.nota; 

                updateProposteCOntrattiList.add(prContratto);
            }
            
            update updateProposteCOntrattiList;
          
        }


        x.scriviPropostaCrmResponse.ScadenziarioStoricoCrmServiceResponse.esitoList = 'OK';
      
        return x;
    }


}