/**
 * @description       : 
 * @author            : simone.viglianti@tengroup.it
 * @group             : 
 * @last modified on  : 07-07-2022
 * @last modified by  : simone.viglianti@tengroup.it
**/
@RestResource(urlMapping='/v1/esitazioneazionistorico/*')
global class REST_EsitazioneAzioniStorico {

    public class SearchNDGException extends Exception{}

    @HttpPost
    global static GetEsitazioneAzioniStoricoResponse getEsitazioneAzioniStoricoRequest(EsitazioneAzioniStoricoInputDto esitazioneAzioni){
        System.debug('@@@@@@ REQUEST: '+JSON.serialize(esitazioneAzioni));
        GetEsitazioneAzioniStoricoResponse getEsitazioneAzioniStoricoResponse = new GetEsitazioneAzioniStoricoResponse();

        RestResponse res;
        RestRequest req;

        
        try{
            req = RestContext.request;
            res = RestContext.response;

            //Set Response Headers
            setHeaders(req, res);
            
            getEsitazioneAzioniStoricoResponse=process(esitazioneAzioni, getEsitazioneAzioniStoricoResponse);

            WsRestUtils.writeLog('getEsitazioneAzioniStorico', req.httpMethod, JSON.serializePretty(esitazioneAzioni), '200', 'status', JSON.serializePretty(getEsitazioneAzioniStoricoResponse),  req.headers,  res.headers, '', '');


            return getEsitazioneAzioniStoricoResponse;
            //Ricerca NDG START
            

            

        }
        catch(SearchNDGException ex){
            System.debug(ex);
        }
        catch(Exception ex){
            System.debug(ex);
        }

        return null;
    }

    global class EsitazioneAzioniStoricoInputDto{
        global EsitazioneAzioniStoricoWsServiceRequest EsitazioneAzioniStoricoWsServiceRequest;
    }

    global class EsitazioneAzioniStoricoWsServiceRequest{
        global List<EsitazioneAzioniInput> esitazioneAzioniInput;
    }

    global class EsitazioneAzioniInput{
        global String banca;
        global String ndg;
        global String prodotto;
        global String tipoRichiesta;
        global String matricola;
        global String appChiamante;
        global String nomeMatricola;
    }

    global class GetEsitazioneAzioniStoricoResponse{
        global EsitazioneAzioniStoricoOutputDto esitazioneAzioniResponse;
        public GetEsitazioneAzioniStoricoResponse(){
            this.esitazioneAzioniResponse = new EsitazioneAzioniStoricoOutputDto();
        }
    }

    global class EsitazioneAzioniStoricoOutputDto{
        global EsitazioneAzioniStoricoServiceResponse EsitazioneAzioniStoricoServiceResponse;
        public EsitazioneAzioniStoricoOutputDto(){
            this.EsitazioneAzioniStoricoServiceResponse= new EsitazioneAzioniStoricoServiceResponse();
        }
    }

    global class EsitazioneAzioniStoricoServiceResponse{
        global List<EsitazioneAzioniOutput> esitazioneAzioniOutput;
    }

    global class EsitazioneAzioniOutput{
        global String chiaveAbi;
        global String chiaveNdg;
        global String chiaveCodProdotto;
        global List<AzioniInEssereEsitate> azioniInEssereEsitate;
        global Integer esito;  
    }

    global class AzioniInEssereEsitate{
        global String noteAzione;
        global String referenteAzione;
        global String esitoAzione;
        global String descrizioneAzione;
        global String tipoAzione;
        global String nomeAzione;
        global String codiceAzione;
        global String tipoRichiesta;
    }


    private static void setHeaders(RestRequest req, RestResponse res){
        if(req.headers.containsKey('testata_operationId')){
            res.addHeader('testata_operationId', req.headers.get('testata_operationId'));
        }
    }

    private static getEsitazioneAzioniStoricoResponse process(EsitazioneAzioniStoricoInputDto getEsitazioneAzioniStorico, GetEsitazioneAzioniStoricoResponse getEsitazioneAzioniStoricoResponse){
        List<EsitazioneAzioniOutput> listaEsitazioneAzioniOutput = new List<EsitazioneAzioniOutput>();
        Set<String> setAbi = new Set<String>();
        Set<String> setNDG = new Set<String>();
        Set<String> setProdotto = new Set<String>();
        //CR Esitazione Azione SV - START
        Set<String> setAbi_Ndg = new Set<String>();
        //CR Esitazione Azione SV - END
        for(EsitazioneAzioniInput esitazioneAzioniInput : getEsitazioneAzioniStorico.EsitazioneAzioniStoricoWsServiceRequest.esitazioneAzioniInput){
            setAbi.add(esitazioneAzioniInput.banca);
            setNDG.add(esitazioneAzioniInput.ndg);
            setProdotto.add(esitazioneAzioniInput.prodotto);
            setAbi_Ndg.add(esitazioneAzioniInput.banca+'_'+esitazioneAzioniInput.ndg);
        }
        try {
            //CR Esitazione Azione SV - START
            List<CRM_AccountAccountJointOwnershipRelation__c> accJoinOwnershipList = [SELECT CRM_Account__r.FinServ__BankNumber__c, CRM_Account__r.CRM_NDG__c FROM CRM_AccountAccountJointOwnershipRelation__c WHERE CRM_JointOwnership__r.NDW_ExternalId__c IN :setAbi_Ndg AND CRM_Active__c = true];

            if(!accJoinOwnershipList.isEmpty()){
                for(CRM_AccountAccountJointOwnershipRelation__c accJoin : accJoinOwnershipList){
                    setAbi.add(accJoin.CRM_Account__r.FinServ__BankNumber__c);
                    setNDG.add(accJoin.CRM_Account__r.CRM_NDG__c);
                }
            }
            //CR Esitazione Azione SV - END
            List<CampaignMember> members = [SELECT Id, Chiave_Banca_NDG__c,Status, CRM_AccPTF__c, CRM_AccNDG__c, Motivo_Affinamento__c, CRM_AccMDS__c, Contact.Account.CRM_NDG__c, Contact.Account.PTF_ABICED__c, Contact.Account.FinServ__BankNumber__c, NDW_ExternalId__c, CRM_EsitoDefinitivo__c, CRM_TipoEsitazione__c,  
            CampaignId, Campaign.CRM_StatoFormula__c, Campaign.RecordTypeId, Campaign.Name, Campaign.CRM_TipologiaCampagnaStep__c, Campaign.CRM_OwnerSystem__c, Campaign.CRM_Progressivo__c, Campaign.Codice_Campagna__c, Campaign.Codice_Azione_Utente__c,
            Campaign.CRM_SottotipologiaCampagna__c, Campaign.CRM_TipologiaCampagna__c, CRM_Assegnatario__c, CRM_Assegnatario__r.FederationIdentifier, CRM_Assegnatario__r.LastName, CRM_Assegnatario__r.FirstName, Campaign.Data_FineFormula__c,
            Contact.Account.PTF_Portafoglio__r.CRM_ReferentePortafoglio__r.PTF_RegistrationNumber__c, Contact.Account.PTF_Portafoglio__r.CRM_ReferentePortafoglio__c, Contact.Account.PTF_Portafoglio__r.CRM_ReferentePortafoglio__r.LastName, Contact.Account.PTF_Portafoglio__r.CRM_ReferentePortafoglio__r.FirstName
            FROM CampaignMember WHERE Contact.Account.CRM_NDG__c IN: setNDG AND Contact.Account.FinServ__BankNumber__c IN: setAbi AND isActive__c = true AND CRM_EsitoDefinitivo__c = false /*CR Esitazione Azione SV - START*/ AND (Campaign.CRM_CampagnaInCorso__c = true OR Campaign.CRM_FormulaValidita__c > TODAY)/*CR Esitazione Azione SV - END*/];
            Set<String> campaignSet = SV_Utilities.keyBy(members, 'CampaignId').keySet();
            Map<String,Object> memberMap = SV_Utilities.groupBy(members, '{Chiave_Banca_NDG__c}', true);
            System.debug('SV: '+memberMap);
            //CR Esitazione Azione SV - START
            List<Product2> productList = [SELECT CRM_SubGroupCode__c, CRM_ProductCategoryCode__c, CRM_NeedCode__c, CRM_MacroGroupCode__c, CRM_GroupCode__c FROM Product2 WHERE ProductCode IN : setProdotto];
            if(!productList.isEmpty()){
                for(Product2 prod : productList){
                    setProdotto.add(prod.CRM_SubGroupCode__c);
                    setProdotto.add(prod.CRM_ProductCategoryCode__c);
                    setProdotto.add(prod.CRM_NeedCode__c);
                    setProdotto.add(prod.CRM_MacroGroupCode__c);
                    setProdotto.add(prod.CRM_GroupCode__c);
                }
            }
            //CR Esitazione Azione SV - END
            List<CRM_AssociazioneProdottiCampagna__c> assocCampagnaList = [SELECT id, CRM_Prodotto__r.ProductCode, CRM_Campagna__c FROM CRM_AssociazioneProdottiCampagna__c WHERE CRM_Campagna__c IN: campaignSet AND CRM_Prodotto__r.ProductCode IN: setProdotto];
            Map<String,Object> associazioneCampagna = SV_Utilities.keyBy(assocCampagnaList, 'CRM_Prodotto__r.ProductCode');
            Map<String,Object> campagnaMap = SV_Utilities.keyBy(assocCampagnaList, 'CRM_Campagna__c');
            List<CampaignMember> membersToUpdate = new List<CampaignMember>();
            for(EsitazioneAzioniInput esitazioneAzioniInput : getEsitazioneAzioniStorico.EsitazioneAzioniStoricoWsServiceRequest.esitazioneAzioniInput){
                EsitazioneAzioniOutput x = new EsitazioneAzioniOutput();
                Boolean onlyInEssere = esitazioneAzioniInput.tipoRichiesta == 'ESITAZIONE' ? false : true;
                List<AzioniInEssereEsitate> listX_figlio = new List<AzioniInEssereEsitate>();
                // if(memberMap.containsKey(esitazioneAzioniInput.banca + '_' + esitazioneAzioniInput.ndg)){
                system.debug('esitazioneAzioniInput.banca: '+esitazioneAzioniInput.banca);
                system.debug('esitazioneAzioniInput.ndg: '+esitazioneAzioniInput.ndg);
                system.debug('check: '+memberMap.containsKey(esitazioneAzioniInput.banca + '_' + esitazioneAzioniInput.ndg));
                if(!memberMap.isEmpty()) {
                    for(CampaignMember member : (List<CampaignMember>)memberMap.get(esitazioneAzioniInput.banca + '-' + esitazioneAzioniInput.ndg)){
        
                        if(onlyInEssere && member.CRM_EsitoDefinitivo__c){
                            continue;
                        }
                        if(associazioneCampagna.containsKey(esitazioneAzioniInput.prodotto)){
        
                            AzioniInEssereEsitate y = new AzioniInEssereEsitate();
                            y.noteAzione = 'noteAzione';
                            y.referenteAzione = 'referenteAzione';
                            y.esitoAzione = 'Da proporre';
                            y.descrizioneAzione = 'Proponi SmartWeb';
                            y.tipoAzione = 'Altra proposta commerciale';
                            y.nomeAzione = 'Proponi SmartWeb';
                            y.codiceAzione = '1-F2VAEU';
                            y.tipoRichiesta = 'In essere';
                            listX_figlio.add(y);
                        }
                        if(campagnaMap.containsKey(member.CampaignId)){
                            member.Status = 'Prodotto venduto';
                            //Boolean esito = AggiornamentoEsitazioneInvocaWS.makeResponse('salvaEsitazioneAzioniNec',new List<CampaignMember>{member}, 'Prodotto venduto', '', 'salesforceprodclient2024', false, null, false, false);
                            //if(esito)
                            membersToUpdate.add(member);
                        }
                    }
                // }
                }
                if(!listX_figlio.isEmpty()){
                    
                    x.azioniInEssereEsitate = listX_figlio;
                    x.chiaveAbi = esitazioneAzioniInput.banca;
                    x.chiaveNdg = esitazioneAzioniInput.ndg;
                    x.chiaveCodProdotto = esitazioneAzioniInput.prodotto;
                    x.esito = 2;  
        
                    listaEsitazioneAzioniOutput.add(x);
                }
                
            }
    
            getEsitazioneAzioniStoricoResponse.esitazioneAzioniResponse.EsitazioneAzioniStoricoServiceResponse.esitazioneAzioniOutput = listaEsitazioneAzioniOutput;
            if(!membersToUpdate.isEmpty()){
                update membersToUpdate;
            }
        } catch (Exception ex) {
            throw new SearchNDGException('Error: ' + ex.getMessage() + '; at: ' + ex.getStackTraceString());
        }
        
        
        return getEsitazioneAzioniStoricoResponse;
    }


}