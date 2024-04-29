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
        //Inizio Modifica - Salvatore Barbieri - ReviewWbService
        global Integer finanzQuotaParteIntestato;
        global Integer finanzQuotaParteCointestato;
        global Integer finanzTotale;
        global Integer patrQuotaParteIntestato;
        global Integer patrQuotaParteCointestato;
        global Integer patrTotale;
        global Integer redditivita;
        global Integer flagConoVisibilita;
        //Fine Modifica - Salvatore Barbieri - ReviewWbService
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
        global List<CampagnaCodiceSconto> campagneCodiceSconto;//Modifica - Salvatore Barbieri - ReviewWbService
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

    global class CampagnaCodiceSconto{//Modifica - Salvatore Barbieri - ReviewWbService
        global String nomeAzione;
        global String codSconto;

    }


    private static void setHeaders(RestRequest req, RestResponse res){
        if(req.headers.containsKey('testata_operationId')){
            res.addHeader('testata_operationId', req.headers.get('testata_operationId'));
        }
    }

    private static getKpiProdottiWebResponse process(KpiProdottiWebInputDto getKpiProdottiWeb, GetKpiProdottiWebResponse x){
        System.debug('REST_KPIProdottiWebService --> process');
        System.debug(X);
        List<ProdottoPosseduto> listNextProdottiPosseduti = new List<ProdottoPosseduto>();
        List<ProdottoCointestato> listNextprodottiCointestati = new List<ProdottoCointestato>();

        //INIZIO Modifica - Salvatore Barbieri - 04/04/2024 - ReviewWbService
        List<ProdottoSuggerito> listNextProdottiSuggeriti = new List<ProdottoSuggerito>();
        List<ProdottoRifiutato> listNextProdottiRifiutati = new List<ProdottoRifiutato>();
        List<CampagnaCodiceSconto> listNextCampagnaCodiceSconto = new List<CampagnaCodiceSconto>();

        List<Account> account = new List<Account>();//[SELECT Id, CRM_PerformanceRating__c, CRM_CreditRating__c/*, CRM_CrossSellingABI__c*/ FROM Account WHERE CRM_NDG__c =: getKpiProdottiWeb.KPIProdottiWsServiceRequest.ndg];
        Boolean visibilitaScudati = getKpiProdottiWeb.KPIProdottiWsServiceRequest.scudati == 'S' ? true : false;
        System.debug('visibilitaScudati --> ' + visibilitaScudati);
        List<String> uoList = getKpiProdottiWeb.KPIProdottiWsServiceRequest.uo.split(',');
        System.debug('uoList --> ' + uoList);
        Integer sizeUoList = uoList.size();
        System.debug('sizeUoList --> ' + sizeUoList);
        String idToQuery = uoList.get(1).split('=').get(1);
        System.debug('idToQuery --> ' + idToQuery);
        String query = 'SELECT Id, CRM_PerformanceRating__c, CRM_CreditRating__c, IsPersonAccount';
        query += ' FROM Account';
        query += ' WHERE NDW_ExternalId__c = \'' + getKpiProdottiWeb.KPIProdottiWsServiceRequest.banca + '_' + getKpiProdottiWeb.KPIProdottiWsServiceRequest.ndg + '\'';
        switch on sizeUoList {
            when 3 {
                //Profilo direzionale(CRM_DP1)
                //nessun filtro aggiuntivo per la visibilità
            }
            when 4 {
                //Profilo banca(CRM_DP4)
                query += 'AND PTF_Banca__r.FinServ__BankNumber__c = \'' + idToQuery + '\'';
            }
            when 5{
                //Profilo di direzione territoriale (CRM_DTP2)
                query += 'AND PTF_DirezioneRegionale__r.PTF_IdCED__c = \'' + idToQuery + '\''; 
            }
            when 6{
                //Profilo area (CRM_AP1)
                query += 'AND PTF_Area__r.PTF_IdCED__c = \'' + idToQuery + '\''; 
            }
            when 7{
                //Profilo filiale capofila (CRM_FCP2)
                query += 'AND PTF_Capofila__r.PTF_IdCED__c = \'' + idToQuery + '\'';
            }
            when 8{
                //Profilo filiale (CRM_FP.1)
                query += 'AND PTF_Filiale__r.PTF_IdCED__c = \'' + idToQuery + '\'';
            }
        }

        System.debug('query --> ' + query);
        account = Database.query(query);

        String tipologiaEstrazione = getKpiProdottiWeb.KPIProdottiWsServiceRequest.flagEstrazione; //serve per decidere, in base ai codici che contiene, cosa estrarre

        if(!account.isEmpty()){

            if(tipologiaEstrazione.containsIgnoreCase('PP')){ //PP -> Prodotti Posseduti & Prodotti Cointestati
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

                    //visibilità campi solo se visibilitaScudati è true
                    ProdottoCointestato prodottiCointestato = new ProdottoCointestato();
                    prodottiCointestato.codBisogno = visibilitaScudati ? finAccount.FinServ__FinancialAccount__r.FinServ__ProductName__r.CRM_NeedCode__c : null;
                    prodottiCointestato.descBisogno = visibilitaScudati ? finAccount.FinServ__FinancialAccount__r.FinServ__ProductName__r.CRM_Need__c : null;
                    prodottiCointestato.codCategoria = visibilitaScudati ? finAccount.FinServ__FinancialAccount__r.FinServ__ProductName__r.CRM_ProductCategoryCode__c : null;
                    prodottiCointestato.descCategoria = visibilitaScudati ? finAccount.FinServ__FinancialAccount__r.FinServ__ProductName__r.CRM_ProductCategory__c : null;
                    prodottiCointestato.codMacrogruppo = visibilitaScudati ? finAccount.FinServ__FinancialAccount__r.FinServ__ProductName__r.CRM_MacroGroupCode__c : null;
                    prodottiCointestato.descMacrogruppo = visibilitaScudati ? finAccount.FinServ__FinancialAccount__r.FinServ__ProductName__r.CRM_MacroGroup__c : null;
                    prodottiCointestato.codGruppo = visibilitaScudati ? finAccount.FinServ__FinancialAccount__r.FinServ__ProductName__r.CRM_GroupCode__c : null;
                    prodottiCointestato.descGruppo = visibilitaScudati ? finAccount.FinServ__FinancialAccount__r.FinServ__ProductName__r.CRM_Group__c : null;
                    prodottiCointestato.codSottogruppo = visibilitaScudati ? finAccount.FinServ__FinancialAccount__r.FinServ__ProductName__r.CRM_SubGroupCode__c : null;
                    prodottiCointestato.descSottogruppo = visibilitaScudati ? finAccount.FinServ__FinancialAccount__r.FinServ__ProductName__r.CRM_SubGroup__c : null;
                    prodottiCointestato.codProdotto = visibilitaScudati ? finAccount.FinServ__FinancialAccount__r.FinServ__ProductName__r.ProductCode : null;
                    prodottiCointestato.descProdotto = visibilitaScudati ? finAccount.FinServ__FinancialAccount__r.FinServ__ProductName__r.Name : null;
                    listNextProdottiCointestati.add(prodottiCointestato);
                }
            }
            if(tipologiaEstrazione.containsIgnoreCase('PS') || tipologiaEstrazione.containsIgnoreCase('PR')){ //PS -> Prodotti Suggeriti, PR -> Prodotti Rifiutati
                //query su CampaignMember per recuperare le campagne a cui è iscritto account[0], dividendole per Prodotto Suggerito e Prodotto Rifiutato
                Map<String, CampaignMember> campaignMemberProdSuggeritoMap = new Map<String, CampaignMember>();
                Map<String, CampaignMember> campaignMemberProdRifiutatoMap = new Map<String, CampaignMember>();
                for(CampaignMember cM : [SELECT Id, CampaignId, Campaign.CRM_Identificativo_Campagna__c, Campaign.Name, CRM_Esito__c, 
                                            CRM_EsitoCampagna__r.CRM_TipoEsitazione__c, CRM_Note__c, Prodotto_Suggerito_Rifiutato__c
                                            FROM CampaignMember 
                                                WHERE Prodotto_Suggerito_Rifiutato__c IN ('Suggerito', 'Rifiutato') AND Contact.AccountId =: account[0].Id]){
                    if(cM.Prodotto_Suggerito_Rifiutato__c == 'Suggerito'){
                        campaignMemberProdSuggeritoMap.put(cM.CampaignId, cM);
                    }else if(cM.Prodotto_Suggerito_Rifiutato__c == 'Rifiutato'){
                        campaignMemberProdRifiutatoMap.put(cM.CampaignId, cM);
                    }
                }
                System.debug('campaignMemberProdSuggeritoMap --> ' + campaignMemberProdSuggeritoMap);
                System.debug('campaignMemberProdRifiutatoMap --> ' + campaignMemberProdRifiutatoMap);

                if(tipologiaEstrazione.containsIgnoreCase('PS')){//PS -> Prodotti Suggeriti
                    if(!campaignMemberProdSuggeritoMap.isEmpty()){
                        for(CRM_AssociazioneProdottiCampagna__c assProdCamp : [SELECT id, CRM_Prodotto__r.CRM_NeedCode__c, CRM_Prodotto__r.CRM_Need__c, CRM_Campagna__c, 
                                                                                CRM_Prodotto__r.CRM_ProductCategoryCode__c, CRM_Prodotto__r.CRM_ProductCategory__c, 
                                                                                CRM_Prodotto__r.CRM_MacroGroupCode__c, CRM_Prodotto__r.CRM_MacroGroup__c,
                                                                                CRM_Prodotto__r.CRM_GroupCode__c, CRM_Prodotto__r.CRM_Group__c, CRM_Prodotto__r.CRM_SubGroupCode__c,
                                                                                CRM_Prodotto__r.CRM_SubGroup__c,CRM_Prodotto__r.ProductCode,CRM_Prodotto__r.Name  
                                                                                    FROM CRM_AssociazioneProdottiCampagna__c 
                                                                                        WHERE CRM_Campagna__c IN :campaignMemberProdSuggeritoMap.keySet()]){
                            String campaignKey = assProdCamp.CRM_Campagna__c;
        
                            ProdottoSuggerito prodottoSuggerito = new ProdottoSuggerito();
                            prodottoSuggerito.codAzione = campaignMemberProdSuggeritoMap.get(campaignKey).Campaign.CRM_Identificativo_Campagna__c;
                            prodottoSuggerito.descAzione = campaignMemberProdSuggeritoMap.get(campaignKey).Campaign.Name;
                            prodottoSuggerito.codBisogno = assProdCamp.CRM_Prodotto__r.CRM_NeedCode__c;
                            prodottoSuggerito.descBisogno = assProdCamp.CRM_Prodotto__r.CRM_Need__c;
                            prodottoSuggerito.codCategoria = assProdCamp.CRM_Prodotto__r.CRM_ProductCategoryCode__c;
                            prodottoSuggerito.descCategoria = assProdCamp.CRM_Prodotto__r.CRM_ProductCategory__c;
                            prodottoSuggerito.codMacrogruppo = assProdCamp.CRM_Prodotto__r.CRM_MacroGroupCode__c;
                            prodottoSuggerito.descMacrogruppo = assProdCamp.CRM_Prodotto__r.CRM_MacroGroup__c;
                            prodottoSuggerito.codGruppo = assProdCamp.CRM_Prodotto__r.CRM_GroupCode__c;
                            prodottoSuggerito.descGruppo = assProdCamp.CRM_Prodotto__r.CRM_Group__c;
                            prodottoSuggerito.codSottogruppo = assProdCamp.CRM_Prodotto__r.CRM_SubGroupCode__c;
                            prodottoSuggerito.descSottogruppo = assProdCamp.CRM_Prodotto__r.CRM_SubGroup__c;
                            prodottoSuggerito.codProdotto = assProdCamp.CRM_Prodotto__r.ProductCode;
                            prodottoSuggerito.descProdotto = assProdCamp.CRM_Prodotto__r.Name;
                            prodottoSuggerito.esito = campaignMemberProdSuggeritoMap.get(campaignKey).CRM_Esito__c;
                            prodottoSuggerito.tipologiaEsito = campaignMemberProdSuggeritoMap.get(campaignKey).CRM_EsitoCampagna__r.CRM_TipoEsitazione__c;
                            prodottoSuggerito.note = campaignMemberProdSuggeritoMap.get(campaignKey).CRM_Note__c;
                            prodottoSuggerito.codCliente = campaignMemberProdSuggeritoMap.get(campaignKey).Id;
                            prodottoSuggerito.categoriaEsito = campaignMemberProdSuggeritoMap.get(campaignKey).CRM_Esito__c;
                            listNextProdottiSuggeriti.add(prodottoSuggerito);
                        }
                    }
                }
                if(tipologiaEstrazione.containsIgnoreCase('PR')){//PS -> Prodotti Rifiutati
                    if(!campaignMemberProdRifiutatoMap.isEmpty()){
                        for(CRM_AssociazioneProdottiCampagna__c assProdCamp : [SELECT id, CRM_Prodotto__r.CRM_NeedCode__c, CRM_Prodotto__r.CRM_Need__c, CRM_Campagna__c, 
                                                                                CRM_Prodotto__r.CRM_ProductCategoryCode__c, CRM_Prodotto__r.CRM_ProductCategory__c, 
                                                                                CRM_Prodotto__r.CRM_MacroGroupCode__c, CRM_Prodotto__r.CRM_MacroGroup__c,
                                                                                CRM_Prodotto__r.CRM_GroupCode__c, CRM_Prodotto__r.CRM_Group__c, CRM_Prodotto__r.CRM_SubGroupCode__c,
                                                                                CRM_Prodotto__r.CRM_SubGroup__c,CRM_Prodotto__r.ProductCode,CRM_Prodotto__r.Name  
                                                                                    FROM CRM_AssociazioneProdottiCampagna__c 
                                                                                        WHERE CRM_Campagna__c IN :campaignMemberProdRifiutatoMap.keySet()]){
                            String campaignKey = assProdCamp.CRM_Campagna__c;
        
                            ProdottoRifiutato prodottoRifiutato = new ProdottoRifiutato();
                            prodottoRifiutato.codAzione = campaignMemberProdRifiutatoMap.get(campaignKey).Campaign.CRM_Identificativo_Campagna__c;
                            prodottoRifiutato.descAzione = campaignMemberProdRifiutatoMap.get(campaignKey).Campaign.Name;
                            prodottoRifiutato.codBisogno = assProdCamp.CRM_Prodotto__r.CRM_NeedCode__c;
                            prodottoRifiutato.descBisogno = assProdCamp.CRM_Prodotto__r.CRM_Need__c;
                            prodottoRifiutato.codCategoria = assProdCamp.CRM_Prodotto__r.CRM_ProductCategoryCode__c;
                            prodottoRifiutato.descCategoria = assProdCamp.CRM_Prodotto__r.CRM_ProductCategory__c;
                            prodottoRifiutato.codMacrogruppo = assProdCamp.CRM_Prodotto__r.CRM_MacroGroupCode__c;
                            prodottoRifiutato.descMacrogruppo = assProdCamp.CRM_Prodotto__r.CRM_MacroGroup__c;
                            prodottoRifiutato.codGruppo = assProdCamp.CRM_Prodotto__r.CRM_GroupCode__c;
                            prodottoRifiutato.descGruppo = assProdCamp.CRM_Prodotto__r.CRM_Group__c;
                            prodottoRifiutato.codSottogruppo = assProdCamp.CRM_Prodotto__r.CRM_SubGroupCode__c;
                            prodottoRifiutato.descSottogruppo = assProdCamp.CRM_Prodotto__r.CRM_SubGroup__c;
                            prodottoRifiutato.codProdotto = assProdCamp.CRM_Prodotto__r.ProductCode;
                            prodottoRifiutato.descProdotto = assProdCamp.CRM_Prodotto__r.Name;
                            prodottoRifiutato.note = campaignMemberProdRifiutatoMap.get(campaignKey).CRM_Note__c;
                            prodottoRifiutato.codCliente = campaignMemberProdRifiutatoMap.get(campaignKey).Id;
                            prodottoRifiutato.categoriaEsito = campaignMemberProdRifiutatoMap.get(campaignKey).CRM_Esito__c;
                            listNextProdottiRifiutati.add(prodottoRifiutato);
                        }
                    }
                }
            }
            if(tipologiaEstrazione.containsIgnoreCase('KPI')){
                List<CRM_IndicatoriCliente__c> indCliente = [SELECT Id, CRM_CrossSellingABI__c 
                                                                FROM CRM_IndicatoriCliente__c 
                                                                    WHERE RecordType.DeveloperName = 'Flat' AND CRM_Account__c =: account[0].Id];

                x.caricaKPIProdottiResponse.KPIProdottiServiceResponse.ratingAndamentale = account[0].CRM_PerformanceRating__c != null ? Integer.valueOf(account[0].CRM_PerformanceRating__c) : 0;
                x.caricaKPIProdottiResponse.KPIProdottiServiceResponse.ratingUfficiale = account[0].CRM_CreditRating__c != null ? Integer.valueOf(account[0].CRM_CreditRating__c) : 0;
                x.caricaKPIProdottiResponse.KPIProdottiServiceResponse.azioniCrm = [SELECT COUNT() FROm CampaignMember WHERE Contact.AccountId =: account[0].Id AND CRM_EsitoDefinitivo__c = false];// + [SELECT COUNT() FROM Opportunity WHERE AccountId =: account[0].Id AND isClosed = false];
                
                x.caricaKPIProdottiResponse.KPIProdottiServiceResponse.crossSelling = visibilitaScudati ? (indCliente.size() > 0 ? Integer.valueOf(indCliente[0].CRM_CrossSellingABI__c) : null) : null;//account[0].CRM_CrossSellingABI__c;
                x.caricaKPIProdottiResponse.KPIProdottiServiceResponse.crossSellingTot = visibilitaScudati ? (account[0].IsPersonAccount ? 16 : 13) : null;
                x.caricaKPIProdottiResponse.KPIProdottiServiceResponse.finanzQuotaParteIntestato = visibilitaScudati ? null : null;
                x.caricaKPIProdottiResponse.KPIProdottiServiceResponse.finanzQuotaParteCointestato = visibilitaScudati ? null : null;
                x.caricaKPIProdottiResponse.KPIProdottiServiceResponse.finanzTotale = visibilitaScudati ? null : null;
                x.caricaKPIProdottiResponse.KPIProdottiServiceResponse.patrQuotaParteIntestato = visibilitaScudati ? null : null;
                x.caricaKPIProdottiResponse.KPIProdottiServiceResponse.patrQuotaParteCointestato = visibilitaScudati ? null : null;
                x.caricaKPIProdottiResponse.KPIProdottiServiceResponse.patrTotale = visibilitaScudati ? null : null;
                x.caricaKPIProdottiResponse.KPIProdottiServiceResponse.redditivita = visibilitaScudati ? null : null;
                x.caricaKPIProdottiResponse.KPIProdottiServiceResponse.flagConoVisibilita = null;
                // x.caricaKPIProdottiResponse.KPIProdottiServiceResponse.flagErrore = '0';
                // x.caricaKPIProdottiResponse.KPIProdottiServiceResponse.statoClienteCRM = 'NATT';
                // x.caricaKPIProdottiResponse.KPIProdottiServiceResponse.rilevanzaClientela = '';
                // x.caricaKPIProdottiResponse.KPIProdottiServiceResponse.crossSellingPond = '';
                // x.caricaKPIProdottiResponse.KPIProdottiServiceResponse.codiceReferente ='';
                // x.caricaKPIProdottiResponse.KPIProdottiServiceResponse.descrizioneReferente = '';    
            }

            for(CampaignMember cM : [SELECT Id, Name, Campaign.Name, Campaign.CRM_Codice_Sconto__c  
                                        FROM CampaignMember 
                                            WHERE Contact.Account.NDW_ExternalID__c =: String.valueOf(getKpiProdottiWeb.KPIProdottiWsServiceRequest.banca + '_' + getKpiProdottiWeb.KPIProdottiWsServiceRequest.ndg) 
                                                AND Campaign.CRM_CampagnaInCorso__c = true AND isactive__c = true ]){
                
                CampagnaCodiceSconto campagnaCodiceSconto = new CampagnaCodiceSconto();
                campagnaCodiceSconto.nomeAzione = cM.Campaign.Name;
                campagnaCodiceSconto.codSconto = cM.Campaign.CRM_Codice_Sconto__c;
                listNextCampagnaCodiceSconto.add(campagnaCodiceSconto);

            }
            
            x.caricaKPIProdottiResponse.KPIProdottiServiceResponse.prodottiPosseduti = listNextProdottiPosseduti;        
            x.caricaKPIProdottiResponse.KPIProdottiServiceResponse.prodottiCointestati = listNextProdottiCointestati;
            x.caricaKPIProdottiResponse.KPIProdottiServiceResponse.prodottiSuggeriti = listNextProdottiSuggeriti;        
            x.caricaKPIProdottiResponse.KPIProdottiServiceResponse.prodottiRifiutati = listNextProdottiRifiutati;
            x.caricaKPIProdottiResponse.KPIProdottiServiceResponse.campagneCodiceSconto = listNextCampagnaCodiceSconto;
        }


        return x;
    }

}