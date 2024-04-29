@RestResource(urlMapping='/v1/popup/*')
global class REST_OpenPopUp {

    public class OpenPopUpException extends Exception{}

    global class AzioniCommerciali {
        /*global String idAzione;
        global String tipologiaCodice;
        global String tipologiaDescrizione;
        global String denominazioneReferente;
        global String statoContatto;
        global String categoria;*/
        global Boolean attiva;
        /*global DateTime dataTermine;
        global String descrizione;*/
    }

    global class AzioniCommercialiInput {
        global String abi;
        global String filiale;
        global String ndg;
    }

    global class AzioniCommercialiOutputDto {
        
        global AzioniCommercialiClienteResponse AzioniCommercialiClienteResponse;
        /*public AzioniCommercialiOutputDto(){
            this.AzioniCommercialiClienteResponse= new AzioniCommercialiClienteResponse();
        }*/
        global List<AzioniCommerciali> azioniCommerciali;
    }

    global class AzioniCommercialiClienteResponse {
       
        global List<AzioniCommerciali> azioniCommerciali;
    }

    global class EstraiAzioniCommercialiClienteResponse {
        /*global AzioniCommercialiOutputDto AzioniCommercialiOutputDto;
        public EstraiAzioniCommercialiClienteResponse(){
            this.AzioniCommercialiOutputDto = new AzioniCommercialiOutputDto();
        }*/
        //global List<AzioniCommerciali> azioniCommerciali;  
        global Boolean attiva;  
       }
    
    @HttpGet
    global static EstraiAzioniCommercialiClienteResponse openPopUpRequest() {
        EstraiAzioniCommercialiClienteResponse estraiAzioniCommercialiClienteResponse = new EstraiAzioniCommercialiClienteResponse();
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;

        setHeaders(req, res);

        try {
            String abi = req.params.get('abi');
            String filiale = req.params.get('filiale');
            String ndg = req.params.get('ndg');

            AzioniCommercialiInput azioniCommercialiInput = new AzioniCommercialiInput();
            azioniCommercialiInput.abi = abi;
            azioniCommercialiInput.filiale = filiale;
            azioniCommercialiInput.ndg = ndg;
            
            estraiAzioniCommercialiClienteResponse = process(azioniCommercialiInput,estraiAzioniCommercialiClienteResponse );

            WsRestUtils.writeLog('openPopUp', req.httpMethod, JSON.serializePretty(req.params), '200', 'status', JSON.serializePretty(estraiAzioniCommercialiClienteResponse), req.headers, res.headers, '', '');

            return estraiAzioniCommercialiClienteResponse;

        } catch(OpenPopUpException ex) {
            System.debug(ex);
        } catch(Exception ex) {
            System.debug(ex);
        }

        return null;
    }
    
    
    @HttpPost
    global static EstraiAzioniCommercialiClienteResponse openPopUpRequest(AzioniCommercialiInput azioniCommercialiInput) {
        EstraiAzioniCommercialiClienteResponse estraiAzioniCommercialiClienteResponse = new EstraiAzioniCommercialiClienteResponse();
        AzioniCommerciali x = new AzioniCommerciali();
        AzioniCommercialiInput y = new AzioniCommercialiInput();

        

        RestResponse res;
        RestRequest req;

        try {
            req = RestContext.request;
            res = RestContext.response;

            setHeaders(req, res);

            estraiAzioniCommercialiClienteResponse = process(azioniCommercialiInput,estraiAzioniCommercialiClienteResponse);

            WsRestUtils.writeLog('openPopUp', req.httpMethod, JSON.serializePretty(req.params), '200', 'status', JSON.serializePretty(estraiAzioniCommercialiClienteResponse), req.headers, res.headers, '', '');

            return estraiAzioniCommercialiClienteResponse;

        } catch(OpenPopUpException ex) {
            System.debug(ex);
        } catch(Exception ex) {
            System.debug(ex);
        }

        return null;
    }


    private static void setHeaders(RestRequest req, RestResponse res) {
        if(req.headers.containsKey('testata_operationId')) {
            res.addHeader('testata_operationId', req.headers.get('testata_operationId'));
        }
    }


    private static EstraiAzioniCommercialiClienteResponse process(AzioniCommercialiInput azioniCommercialiInput, EstraiAzioniCommercialiClienteResponse estraiAzioniCommercialiClienteResponse){
        AzioniCommerciali x = new AzioniCommerciali();
        List<AzioniCommerciali> azioniCommercialiList = new List<AzioniCommerciali>();

        EstraiAzioniCommercialiClienteResponse y = new EstraiAzioniCommercialiClienteResponse();
       
        try { String abi_ndg = azioniCommercialiInput.abi + '_' + azioniCommercialiInput.ndg;
        List<Account> listAcc = [SELECT id, ModelloDiServizio__c, FinServ__BankNumber__c, CRM_NDG__c, CRM_Filiale__r.name, FinServ__BranchCode__c  FROM Account WHERE NDW_ExternalId__c=:abi_ndg ];
        
        System.debug('@@@listAcc '+listAcc);
        if (listAcc.size() > 0) {
            

            List<CampaignMember> listCampaignMem = [SELECT Id, CRM_AssegnatarioFormula__c, CampaignId, Campaign.Tipologia_Azione__c, Campaign.Type, Campaign.Name, Campaign.StartDate, Campaign.EndDate, CRM_Esito__c,Status, Campaign.CRM_SottotipologiaCampagna__c, Campaign.CRM_Categoria__c, Campaign.Data_FineFormula__c FROM CampaignMember WHERE Contact.AccountID =:listAcc[0].Id AND CRM_EsitoDefinitivo__c = false AND Campaign.CRM_CampagnaInCorso__c = true];

            System.debug('@@@listCampaignMem '+listCampaignMem);

            List<CRM_Memo__c> listMemo = [SELECT Id, Name,CRM_Titolo__c, CRM_Note__c, CRM_FineValidita__c, Autore__c  FROM CRM_Memo__c WHERE Cliente__c =:listAcc[0].Id AND CRM_StatoMemo__c != 'Scaduto' AND CRM_PopupCassa__c = true AND CRM_FineValidita__c >= TODAY];
            System.debug('@@@listMemo '+listMemo);

            if (listAcc[0].ModelloDiServizio__c == 'Private') {
                //x.attiva = !listMemo.isEmpty()? true : false;
                estraiAzioniCommercialiClienteResponse.attiva = !listMemo.isEmpty()? true : false;

            } else if (listAcc[0].ModelloDiServizio__c != 'Private' &&  listAcc[0].FinServ__BranchCode__c != azioniCommercialiInput.filiale) {

                //x.attiva = !listMemo.isEmpty()? true : false;
                estraiAzioniCommercialiClienteResponse.attiva = !listMemo.isEmpty()? true : false;

            } else if (listAcc[0].ModelloDiServizio__c != 'Private' &&  listAcc[0].FinServ__BranchCode__c == azioniCommercialiInput.filiale) {

                //x.attiva = (!listCampaignMem.isEmpty() || !listMemo.isEmpty()) ? true : false;
                estraiAzioniCommercialiClienteResponse.attiva = (!listCampaignMem.isEmpty() || !listMemo.isEmpty()) ? true : false;
            }

            //azioniCommercialiList.add(x);

            //estraiAzioniCommercialiClienteResponse.azioniCommerciali = azioniCommercialiList;

        }
                        
        } catch (Exception ex) {
            throw new OpenPopUpException('Error: ' + ex.getMessage() + '; at: ' + ex.getStackTraceString());
        }
        
        
        return estraiAzioniCommercialiClienteResponse;
    }






}