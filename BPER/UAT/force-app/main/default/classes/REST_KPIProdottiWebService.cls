@RestResource(urlMapping='/v1/getkpiprodottiweb/*')
global class REST_KPIProdottiWebService {
        
    public class SearchNDGException extends Exception{}

    @HttpPost
    global static GetKpiProdottiWebResponse getKpiProdottiWebRequest(KpiProdottiWebInputDto caricaKPIProdotti){
        System.debug('@@@@@@ REQUEST: '+JSON.serialize(caricaKPIProdotti));
        GetKpiProdottiWebResponse getKpiProdottiWebResponse = new GetKpiProdottiWebResponse();

        RestResponse res;
        RestRequest req;

        
        try{
            
            req = RestContext.request;
            res = RestContext.response;

            //Set Response Headers
            setHeaders(req, res);
            
            getKpiProdottiWebResponse=process(caricaKPIProdotti, getKpiProdottiWebResponse);

            // return getKpiProdottiWebResponse;
            //Ricerca NDG START
        }
        catch(SearchNDGException ex){
            System.debug(ex);
            throw new SearchNDGException(ex.getMessage() + 'at: ' +ex.getStackTraceString());
        }
        catch(Exception ex){
            System.debug(ex);
            throw new SearchNDGException(ex.getMessage() + 'at: ' +ex.getStackTraceString());
        }finally{
            WsRestUtils.writeLog('getKpiProdottiWeb', req.httpMethod, JSON.serializePretty(caricaKPIProdotti), '200', 'status', JSON.serializePretty(getKpiProdottiWebResponse),  req.headers,  res.headers, '', '');
        }

        return getKpiProdottiWebResponse;
    }

    global class KpiProdottiWebInputDto{
        global KPIProdottiWsServiceRequest KPIProdottiWsServiceRequest;
    }

    global class KPIProdottiWsServiceRequest{
        global String banca;
        global String ndg;
        global String uo;
        global String scudati;
        global String flagEstrazione;
        global String dataInizioVerifica;
    }

    global class GetKpiProdottiWebResponse{
        global KpiProdottiWebOutputDto caricaKPIProdottiResponse;
        public GetKpiProdottiWebResponse(){
            this.caricaKPIProdottiResponse= new KpiProdottiWebOutputDto();
        }
    }

    global class KpiProdottiWebOutputDto{
        global KPIProdottiServiceResponse KPIProdottiServiceResponse;
        public KpiProdottiWebOutputDto(){
            this.KPIProdottiServiceResponse= new KPIProdottiServiceResponse();
        }
    }

    global class KPIProdottiServiceResponse{
        global Integer ratingAndamentale;       
        global Integer ratingUfficiale;
        global Integer azioniCrm;
        global Integer crossSelling;
        global Integer crossSellingTot;
        global String flagErrore;
        global String statoClienteCRM;
        global String rilevanzaClientela;
        global String crossSellingPond;
        global String codiceReferente;
        global String descrizioneReferente;   
        global List<BestProduct> nextBestProduct;
        global List<ProdottoRifiutato> prodottiRifiutati;
        global List<ProdottoSuggerito> prodottiSuggeriti;
        global List<ProdottoCointestato> prodottiCointestati;
        global List<ProdottoPosseduto> prodottiPosseduti;
    }

    global class BestProduct{
        global String categoriaAbi;
        global String flagPosseduto;  
        global String propensione;  
        global String prodottoSuggerito;  
    }
    global class ProdottoRifiutato{
        global String codAzione;
        global String descAzione;
        global String codBisogno;
        global String descBisogno;
        global String codCategoria;
        global String descCategoria;
        global String codMacrogruppo;
        global String descMacrogruppo;
        global String codGruppo;
        global String descGruppo;
        global String codSottogruppo;
        global String descSottogruppo;
        global String codProdotto;
        global String descProdotto;
        global String esito;
        global String tipologiaEsito;
        global String note;
        global String codCliente;
        global String categoriaEsito;
    }
    global class ProdottoSuggerito{
        global String codAzione;
        global String descAzione;
        global String codBisogno;
        global String descBisogno;
        global String codCategoria;
        global String descCategoria;
        global String codMacrogruppo;
        global String descMacrogruppo;
        global String codGruppo;
        global String descGruppo;
        global String codSottogruppo;
        global String descSottogruppo;
        global String codProdotto;
        global String descProdotto;
        global String esito;
        global String tipologiaEsito;
        global String note;
        global String codCliente;
        global String categoriaEsito;
    }
    global class ProdottoCointestato{
        global String codBisogno;
        global String descBisogno;
        global String codCategoria;
        global String descCategoria;
        global String codMacrogruppo;
        global String descMacrogruppo;
        global String codGruppo;
        global String descGruppo;
        global String codSottogruppo;
        global String descSottogruppo;
        global String codProdotto;
        global String descProdotto;
    }
    global class ProdottoPosseduto{
        global String codBisogno;
        global String descBisogno;
        global String codCategoria;
        global String descCategoria;
        global String codMacrogruppo;
        global String descMacrogruppo;
        global String codGruppo;
        global String descGruppo;
        global String codSottogruppo;
        global String descSottogruppo;
        global String codProdotto;
        global String descProdotto;
    }


    private static void setHeaders(RestRequest req, RestResponse res){
        if(req.headers.containsKey('testata_operationId')){
            res.addHeader('testata_operationId', req.headers.get('testata_operationId'));
        }
    }

    private static getKpiProdottiWebResponse process(KpiProdottiWebInputDto getKpiProdottiWeb, GetKpiProdottiWebResponse x){
        System.debug(X);
        List<ProdottoPosseduto> listNextProdottiPosseduti = new List<ProdottoPosseduto>();
        List<ProdottoCointestato> listNextprodottiCointestati = new List<ProdottoCointestato>();

        List<Account> account = [SELECT Id, CRM_PerformanceRating__c, CRM_CreditRating__c/*, CRM_CrossSellingABI__c*/ FROM Account WHERE CRM_NDG__c =: getKpiProdottiWeb.KPIProdottiWsServiceRequest.ndg];
        if(!account.isEmpty()){

            for(FinServ__FinancialAccount__c finAccount : [SELECT id, FinServ__Status__c, FinServ__JointOwner__c, FinServ__ProductName__r.CRM_NeedCode__c, FinServ__ProductName__r.CRM_Need__c, FinServ__ProductName__r.CRM_ProductCategoryCode__c, 
                                                            FinServ__ProductName__r.CRM_ProductCategory__c, FinServ__ProductName__r.CRM_MacroGroupCode__c, FinServ__ProductName__r.CRM_MacroGroup__c, FinServ__ProductName__r.CRM_GroupCode__c,
                                                            FinServ__ProductName__r.CRM_Group__c, FinServ__ProductName__r.CRM_SubGroupCode__c, FinServ__ProductName__r.CRM_SubGroup__c, FinServ__ProductName__r.ProductCode, FinServ__ProductName__r.Name
                                                            FROM FinServ__FinancialAccount__c 
                                                            WHERE FinServ__PrimaryOwner__c =: account[0].Id AND
                                                            FinServ__JointOwner__c = null AND
                                                            FinServ__Status__c = 'ATTIVO']){
    
                ProdottoPosseduto prodottoPosseduto = new ProdottoPosseduto();
                prodottoPosseduto.codBisogno = finAccount.FinServ__ProductName__r.CRM_NeedCode__c;
                prodottoPosseduto.descBisogno = finAccount.FinServ__ProductName__r.CRM_Need__c;
                prodottoPosseduto.codCategoria = finAccount.FinServ__ProductName__r.CRM_ProductCategoryCode__c;
                prodottoPosseduto.descCategoria = finAccount.FinServ__ProductName__r.CRM_ProductCategory__c;
                prodottoPosseduto.codMacrogruppo = finAccount.FinServ__ProductName__r.CRM_MacroGroupCode__c;
                prodottoPosseduto.descMacrogruppo = finAccount.FinServ__ProductName__r.CRM_MacroGroup__c;
                prodottoPosseduto.codGruppo = finAccount.FinServ__ProductName__r.CRM_GroupCode__c;
                prodottoPosseduto.descGruppo = finAccount.FinServ__ProductName__r.CRM_Group__c;
                prodottoPosseduto.codSottogruppo = finAccount.FinServ__ProductName__r.CRM_SubGroupCode__c;
                prodottoPosseduto.descSottogruppo = finAccount.FinServ__ProductName__r.CRM_SubGroup__c;
                prodottoPosseduto.codProdotto = finAccount.FinServ__ProductName__r.ProductCode;
                prodottoPosseduto.descProdotto = finAccount.FinServ__ProductName__r.Name;
                listNextProdottiPosseduti.add(prodottoPosseduto);
            }
    
            for(FinServ__FinancialAccountRole__c finAccount : [SELECT id, FinServ__FinancialAccount__r.FinServ__Status__c, FinServ__FinancialAccount__r.FinServ__ProductName__r.CRM_NeedCode__c, FinServ__FinancialAccount__r.FinServ__ProductName__r.CRM_Need__c, FinServ__FinancialAccount__r.FinServ__ProductName__r.CRM_ProductCategoryCode__c, 
                                                                FinServ__FinancialAccount__r.FinServ__ProductName__r.CRM_ProductCategory__c, FinServ__FinancialAccount__r.FinServ__ProductName__r.CRM_MacroGroupCode__c, FinServ__FinancialAccount__r.FinServ__ProductName__r.CRM_MacroGroup__c, FinServ__FinancialAccount__r.FinServ__ProductName__r.CRM_GroupCode__c,
                                                                FinServ__FinancialAccount__r.FinServ__ProductName__r.CRM_Group__c, FinServ__FinancialAccount__r.FinServ__ProductName__r.CRM_SubGroupCode__c, FinServ__FinancialAccount__r.FinServ__ProductName__r.CRM_SubGroup__c, FinServ__FinancialAccount__r.FinServ__ProductName__r.ProductCode, FinServ__FinancialAccount__r.FinServ__ProductName__r.Name
                                                                FROM FinServ__FinancialAccountRole__c 
                                                                WHERE FinServ__Role__c IN ('Primary Owner', 'Cointestatario') AND
                                                                CRM_NDG__c =: getKpiProdottiWeb.KPIProdottiWsServiceRequest.ndg AND
                                                                FinServ__FinancialAccount__r.FinServ__Status__c = 'ATTIVO']){
    
                ProdottoCointestato prodottiCointestato = new ProdottoCointestato();
                prodottiCointestato.codBisogno = finAccount.FinServ__FinancialAccount__r.FinServ__ProductName__r.CRM_NeedCode__c;
                prodottiCointestato.descBisogno = finAccount.FinServ__FinancialAccount__r.FinServ__ProductName__r.CRM_Need__c;
                prodottiCointestato.codCategoria = finAccount.FinServ__FinancialAccount__r.FinServ__ProductName__r.CRM_ProductCategoryCode__c;
                prodottiCointestato.descCategoria = finAccount.FinServ__FinancialAccount__r.FinServ__ProductName__r.CRM_ProductCategory__c;
                prodottiCointestato.codMacrogruppo = finAccount.FinServ__FinancialAccount__r.FinServ__ProductName__r.CRM_MacroGroupCode__c;
                prodottiCointestato.descMacrogruppo = finAccount.FinServ__FinancialAccount__r.FinServ__ProductName__r.CRM_MacroGroup__c;
                prodottiCointestato.codGruppo = finAccount.FinServ__FinancialAccount__r.FinServ__ProductName__r.CRM_GroupCode__c;
                prodottiCointestato.descGruppo = finAccount.FinServ__FinancialAccount__r.FinServ__ProductName__r.CRM_Group__c;
                prodottiCointestato.codSottogruppo = finAccount.FinServ__FinancialAccount__r.FinServ__ProductName__r.CRM_SubGroupCode__c;
                prodottiCointestato.descSottogruppo = finAccount.FinServ__FinancialAccount__r.FinServ__ProductName__r.CRM_SubGroup__c;
                prodottiCointestato.codProdotto = finAccount.FinServ__FinancialAccount__r.FinServ__ProductName__r.ProductCode;
                prodottiCointestato.descProdotto = finAccount.FinServ__FinancialAccount__r.FinServ__ProductName__r.Name;
                listNextProdottiCointestati.add(prodottiCointestato);
            }
    
            x.caricaKPIProdottiResponse.KPIProdottiServiceResponse.ratingAndamentale = account[0].CRM_PerformanceRating__c != null ? Integer.valueOf(account[0].CRM_PerformanceRating__c) : 0;
            x.caricaKPIProdottiResponse.KPIProdottiServiceResponse.ratingUfficiale = account[0].CRM_CreditRating__c != null ? Integer.valueOf(account[0].CRM_CreditRating__c) : 0;
            x.caricaKPIProdottiResponse.KPIProdottiServiceResponse.azioniCrm = [SELECT COUNT() FROm CampaignMember WHERE Contact.AccountId =: account[0].Id AND Status != 'Responded'] + [SELECT COUNT() FROM Opportunity WHERE AccountId =: account[0].Id AND isClosed = false];
            // x.caricaKPIProdottiResponse.KPIProdottiServiceResponse.crossSelling = account[0].CRM_CrossSellingABI__c;
            /*x.caricaKPIProdottiResponse.KPIProdottiServiceResponse.crossSellingTot = 0;
            x.caricaKPIProdottiResponse.KPIProdottiServiceResponse.flagErrore = '0';
            x.caricaKPIProdottiResponse.KPIProdottiServiceResponse.statoClienteCRM = 'NATT';
            x.caricaKPIProdottiResponse.KPIProdottiServiceResponse.rilevanzaClientela = '';
            x.caricaKPIProdottiResponse.KPIProdottiServiceResponse.crossSellingPond = '';
            x.caricaKPIProdottiResponse.KPIProdottiServiceResponse.codiceReferente ='';
            x.caricaKPIProdottiResponse.KPIProdottiServiceResponse.descrizioneReferente = '';*/       
            x.caricaKPIProdottiResponse.KPIProdottiServiceResponse.prodottiPosseduti = listNextProdottiPosseduti;        
            x.caricaKPIProdottiResponse.KPIProdottiServiceResponse.prodottiCointestati = listNextProdottiCointestati;        
        }


        return x;
    }

}