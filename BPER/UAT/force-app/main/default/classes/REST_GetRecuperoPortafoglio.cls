@RestResource(urlMapping='/v1/getrecuperoportafoglio/*')
global class REST_GetRecuperoPortafoglio {
    
    public class SearchNDGException extends Exception{}

    global class RecuperoPortafoglioInputDto{
        global String pAbi;
        global String pCodPortafoglio;
        global String pNomEmailAddr;
        global Boolean pFlgBackup;
    }

    global class GetRecuperoPortafoglioResponse{
        global RecuperoPortafoglioOutputDto recuperoPortafoglioOutput;
        public GetRecuperoPortafoglioResponse(){
            this.recuperoPortafoglioOutput= new RecuperoPortafoglioOutputDto();
        }
    }

    global class RecuperoPortafoglioOutputDto{
        global String code;
        global ListaCfPortafoglio listCfPortafoglio;
        global String message;
    }

    global class ListaCfPortafoglio{
        global Integer numeroElementiTotali;
        global List<CfPortafoglio> cfPortafogli;
        public ListaCfPortafoglio(){
            this.cfPortafogli=new List<CfPortafoglio>();
        }
    }

    global class CfPortafoglio{
        global String abi;
        global String codFiscale;
        global String codMds;
        global String codPortafoglio;
        global String denominazione;
        global String naturaGiuridica;
        global String ndg;
        global String nomCognome;
        global String nomMds;
        global String nomNome;
        global String nomPortafoglio;
        global String partitaIva;
        global String segmento;
        global Boolean pFlgBackup;

    }

    @HttpPost
    global static GetRecuperoPortafoglioResponse getRecuperoPortafoglio(RecuperoPortafoglioInputDto recuperoPortafoglioInput){
        System.debug('@@@@@@ REQUEST: '+JSON.serialize(recuperoPortafoglioInput));
        GetRecuperoPortafoglioResponse getRecuperoPortafoglioResponse = new GetRecuperoPortafoglioResponse();
        RestResponse res;
        RestRequest req;

        try{
            req = RestContext.request;
            res = RestContext.response;
            
            //Set Response Headers
            setHeaders(req, res);

            //Controllo Parametri Mandatori
            checkRequiredParameter(recuperoPortafoglioInput);
            
            //Ricerca Consulente 
            List<Contact> consulenti = ricercaConsulente(recuperoPortafoglioInput);

            getRecuperoPortafoglioResponse=process(recuperoPortafoglioInput, getRecuperoPortafoglioResponse, consulenti);
            
            WsRestUtils.writeLog('GetRecuperoPortafoglio', req.httpMethod, JSON.serializePretty(recuperoPortafoglioInput), getRecuperoPortafoglioResponse.recuperoPortafoglioOutput.code, getRecuperoPortafoglioResponse.recuperoPortafoglioOutput.message, '', req.headers, res.headers, '','');

            return getRecuperoPortafoglioResponse;
            //Ricerca NDG START
            

            

        }
        catch(REST_CreatePortafogliaDipartimentale.CheckParamsException ex){
            getRecuperoPortafoglioResponse.recuperoPortafoglioOutput.code='003';
            getRecuperoPortafoglioResponse.recuperoPortafoglioOutput.message=ex.getMessage();
            WsRestUtils.writeLog('GetRecuperoPortafoglio', req.httpMethod, JSON.serializePretty(recuperoPortafoglioInput), getRecuperoPortafoglioResponse.recuperoPortafoglioOutput.code, getRecuperoPortafoglioResponse.recuperoPortafoglioOutput.message, '', req.headers, res.headers, '','');
            return getRecuperoPortafoglioResponse;
        }
        catch(REST_CreatePortafogliaDipartimentale.CheckConsulenteException ex){
            getRecuperoPortafoglioResponse.recuperoPortafoglioOutput.code='001';
            getRecuperoPortafoglioResponse.recuperoPortafoglioOutput.message=ex.getMessage();
            WsRestUtils.writeLog('GetRecuperoPortafoglio', req.httpMethod, JSON.serializePretty(recuperoPortafoglioInput), getRecuperoPortafoglioResponse.recuperoPortafoglioOutput.code, getRecuperoPortafoglioResponse.recuperoPortafoglioOutput.message, '', req.headers, res.headers, '','');
            return getRecuperoPortafoglioResponse;
        }
        catch(SearchNDGException ex){
            getRecuperoPortafoglioResponse.recuperoPortafoglioOutput.code='002';
            getRecuperoPortafoglioResponse.recuperoPortafoglioOutput.message=ex.getMessage();
            WsRestUtils.writeLog('GetRecuperoPortafoglio', req.httpMethod, JSON.serializePretty(recuperoPortafoglioInput), getRecuperoPortafoglioResponse.recuperoPortafoglioOutput.code, getRecuperoPortafoglioResponse.recuperoPortafoglioOutput.message,'', req.headers, res.headers, '','');
            return getRecuperoPortafoglioResponse;
        }
        catch(Exception ex){
            getRecuperoPortafoglioResponse.recuperoPortafoglioOutput.code='099';
            getRecuperoPortafoglioResponse.recuperoPortafoglioOutput.message=ex.getMessage()+' '+ex.getStackTraceString();
            WsRestUtils.writeLog('GetRecuperoPortafoglio', req.httpMethod, JSON.serializePretty(recuperoPortafoglioInput), getRecuperoPortafoglioResponse.recuperoPortafoglioOutput.code, ex.getMessage(), '', req.headers, res.headers, '','');
            return getRecuperoPortafoglioResponse;
        }
    }

    private static void setHeaders(RestRequest req, RestResponse res){
        if(req.headers.containsKey('testata_operationId')){
            res.addHeader('testata_operationId', req.headers.get('testata_operationId'));
        }
    }

    private static void checkRequiredParameter(recuperoPortafoglioInputDto input){
        
        List<String> missingParams= new List<String>();

        if(String.isBlank(input.pAbi)){
            missingParams.add('pAbi');
        }
        
        if(String.isBlank(input.pNomEmailAddr)){
            missingParams.add('pNomEmailAddr');
        }
        
        if(missingParams.size()>0){
            throw new REST_CreatePortafogliaDipartimentale.CheckParamsException('Mancano i seguenti parametri mandatori: '+String.join(missingParams, ', '));
        }
    }

    private static List<Contact> ricercaConsulente(RecuperoPortafoglioInputDto recuperoPortafoglioInput){
        
        /*String bancaRecordTypeId= SV_Utilities.getRecordTypeByDeveloperName('Account', 'Banca');
        String filialeRecordTypeId= SV_Utilities.getRecordTypeByDeveloperName('Account', 'FilialeDiRelazione');
        List<Account> bancaList= [SELECT Id FROM Account WHERE FinServ__BankNumber__c=:recuperoPortafoglioInput.pAbi AND RecordTypeId=:bancaRecordTypeId];
        if(bancaList.size()==0){
            throw new REST_CreatePortafogliaDipartimentale.CheckConsulenteException('Referente non trovato in anagrafica di portafogliazione');
        }

        Map<String,SObject> filialiMap= SV_Utilities.keyBy([SELECT 
                                                        Id, PTF_Banca__r.FinServ__BankNumber__c,  PTF_BranchTypology__c 
                                                        FROM Account 
                                                        WHERE  PTF_Banca__r.FinServ__BankNumber__c=:recuperoPortafoglioInput.pAbi AND RecordTypeId=:filialeRecordTypeId], 'Id', false) ;
        if(filialiMap.keySet().size()==0){
            throw new REST_CreatePortafogliaDipartimentale.CheckConsulenteException('Referente non trovato in anagrafica di portafogliazione');
        }*/
        List<Contact> consulenti = [SELECT Id FROM Contact WHERE PTF_RegistrationNumber__c=:((recuperoPortafoglioInput.pNomEmailAddr.replace('U', '')).replace(' ', ''))];
        if(consulenti.size()==0){
            throw new REST_CreatePortafogliaDipartimentale.CheckConsulenteException('Referente non trovato in anagrafica di portafogliazione');
        }
        return consulenti;
    }

    private static GetRecuperoPortafoglioResponse process(RecuperoPortafoglioInputDto recuperoPortafoglioInput, GetRecuperoPortafoglioResponse getRecuperoPortafoglioResponse, List<Contact> consulenti){

        String primarioRecordTypeId= SV_Utilities.getRecordTypeByDeveloperName('Assignment__c', 'Primario');
        String backupRecordTypeId= SV_Utilities.getRecordTypeByDeveloperName('Assignment__c', 'Backup');
        List<Assignment__c> assList = new List<Assignment__c>();
        if(String.isBlank(recuperoPortafoglioInput.pCodPortafoglio)){
            if(recuperoPortafoglioInput.pFlgBackup==true){
                assList=[SELECT Id, PTF_Gestore__r.AccountId, PTF_MicroWallet__r.PTF_Codice_Portafoglio__c, PTF_MicroWallet__r.Name, PTF_MicroWallet__r.PTF_ModelloDiServizio__c, PTF_MicroWallet__c FROM Assignment__c  WHERE RecordTypeId=:backupRecordTypeId AND PTF_Gestore__c IN:consulenti AND PTF_EndDate__c=null];
            }
            else{
                assList=[SELECT Id, PTF_Gestore__r.AccountId, PTF_MicroWallet__r.PTF_Codice_Portafoglio__c, PTF_MicroWallet__r.Name, PTF_MicroWallet__r.PTF_ModelloDiServizio__c, PTF_MicroWallet__c FROM Assignment__c  WHERE RecordTypeId=:primarioRecordTypeId AND PTF_Gestore__c IN:consulenti AND PTF_EndDate__c=null];
            }
        }
        else if( recuperoPortafoglioInput.pFlgBackup==true){
            assList=[SELECT Id, PTF_Gestore__r.AccountId, PTF_MicroWallet__r.PTF_Codice_Portafoglio__c, PTF_MicroWallet__r.Name, PTF_MicroWallet__r.PTF_ModelloDiServizio__c, PTF_MicroWallet__c FROM Assignment__c  WHERE RecordTypeId=:backupRecordTypeId AND PTF_Gestore__c IN:consulenti AND PTF_MicroWallet__r.PTF_Codice_Portafoglio__c=:recuperoPortafoglioInput.pCodPortafoglio AND PTF_EndDate__c=null];
        }
        else{
            assList=[SELECT Id, PTF_Gestore__r.AccountId, PTF_MicroWallet__r.PTF_Codice_Portafoglio__c, PTF_MicroWallet__r.Name, PTF_MicroWallet__r.PTF_ModelloDiServizio__c, PTF_MicroWallet__c FROM Assignment__c  WHERE RecordTypeId=:primarioRecordTypeId AND PTF_Gestore__c IN:consulenti AND PTF_MicroWallet__r.PTF_Codice_Portafoglio__c=:recuperoPortafoglioInput.pCodPortafoglio AND PTF_EndDate__c=null];
        }
        if(assList.size()==0){
            throw new SearchNDGException('Nessun risultato trovato');
        }
        Set<String> walletIds= new Set<String>();
        for(Assignment__c ass:assList ){
            walletIds.add(ass.PTF_MicroWallet__c);
        }
        Map<String,SObject> modelliMap= SV_Utilities.keyBy([SELECT 
                                                        Id, Name, PTF_Code__c 
                                                        FROM ServiceModel__c  
                                                        ], 'Name', false) ;
        for(String modello:modelliMap.keySet()){
            modelliMap.put(modello.toUpperCase(), modelliMap.remove(modello));   
        }
        List<Account> ndgList = [SELECT Id, CRM_TaxId__c, PTF_Portafoglio__r.PTF_Codice_Portafoglio__c, PTF_Portafoglio__r.Name, RecordType.DeveloperName, Name, FirstName, LastName, CRM_NDG__c, CRM_VAT__c, CRM_ManagementSegmentCode__c, ModelloDiServizio__c, PTF_NaturaGiuridica__c, PTF_Portafoglio__r.PTF_ModelloDiServizio__c FROM Account WHERE PTF_Portafoglio__c IN:walletIds];
        if(ndgList.size()==0){
            throw new SearchNDGException('Nessun risultato trovato');
        }
        getRecuperoPortafoglioResponse.recuperoPortafoglioOutput.listCfPortafoglio= new ListaCfPortafoglio();
        for(Account ndg:ndgList){
            getRecuperoPortafoglioResponse.recuperoPortafoglioOutput.listCfPortafoglio.numeroElementiTotali=ndgList.size();
            CfPortafoglio cf= new CfPortafoglio();
            if(ndg.RecordType.DeveloperName=='PersonAccount'){
                cf.nomNome=ndg.FirstName;
                cf.nomCognome=ndg.LastName;
            }
            else{
                cf.denominazione=ndg.Name;
            }
            cf.codPortafoglio=ndg.PTF_Portafoglio__r.PTF_Codice_Portafoglio__c;
            cf.nomMds=ndg.PTF_Portafoglio__r.PTF_ModelloDiServizio__c;
            cf.codMds= (String)modelliMap.get(cf.nomMds.toUpperCase()).get('PTF_Code__c') ;
            cf.pFlgBackup=recuperoPortafoglioInput.pFlgBackup==null ? false : recuperoPortafoglioInput.pFlgBackup ;
            cf.naturaGiuridica=ndg.PTF_NaturaGiuridica__c;
            cf.ndg=ndg.CRM_NDG__c;
            cf.segmento= ndg.CRM_ManagementSegmentCode__c;
            cf.nomPortafoglio=ndg.PTF_Portafoglio__r.Name;
            cf.abi=recuperoPortafoglioInput.pAbi;
            cf.partitaIva=ndg.CRM_VAT__c;
            cf.codFiscale=ndg.CRM_TaxId__c;
            getRecuperoPortafoglioResponse.recuperoPortafoglioOutput.listCfPortafoglio.cfPortafogli.add(cf);
        }
        getRecuperoPortafoglioResponse.recuperoPortafoglioOutput.code='000';
        getRecuperoPortafoglioResponse.recuperoPortafoglioOutput.message='OK';
        
        return getRecuperoPortafoglioResponse;
    }
}