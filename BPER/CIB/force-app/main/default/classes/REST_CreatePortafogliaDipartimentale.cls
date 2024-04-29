@RestResource(urlMapping='/v1/createportafogliadipartimentale/*')
global class REST_CreatePortafogliaDipartimentale {
    
    

    public class CheckParamsException extends Exception {}
    public class CheckConsulenteException extends Exception {}
    //public class CheckPortafoglioException extends Exception {}
    //public class MorePortafogliException extends Exception {}
    //public class NoPortafogliException extends Exception {}
    //public class AlreadyAssignedWithoutCodIdException extends Exception {}
    public class AlreadyAssignedException extends Exception {}

    global class PortafogliaDipartimentaleInputDto{
        global String pAbi;
        global String pCodFiliale;
        global String pCodPortafoglio;
        global String pNomEmailAddr;
        global List<NDG> pNdgList;
        
        
    }

    global class NDG{
        global String pDenominazione;
        global String pNaturaGiuridica;
        global String pNDG;
        global String pNomCognome;
        global String pNomNome;
        global String pSegmentoGestionale;
    }

    global class CreatePortafogliaDipartimentaleResponse{
        global PortafogliaDipartimentaleOutputDto portafogliaDipartimentaleOutput;
        global CreatePortafogliaDipartimentaleResponse(){
            this.portafogliaDipartimentaleOutput  = new PortafogliaDipartimentaleOutputDto();
        }
    }

    global class PortafogliaDipartimentaleOutputDto{
        global String code;
        global ListaPortafoglio listCodPortafoglio;
        global ListaKoReturn listKo;
        global String message;
        
    }

    global class ListaPortafoglio{
        global Integer numeroElementiTotali;
        global List<Portafoglio> portafogli;
        global ListaPortafoglio(){
            this.portafogli= new List<Portafoglio>();
        }
    }

    global class Portafoglio{
        global String codPortafoglio;
        global String ndg;
        global String nomePortafoglio;
    }

    global class ListaKoReturn{
        global Integer numeroElementiTotali;
        global List<KoReturn> koReturn;
        global ListaKoReturn(){
            this.koReturn= new List<KoReturn>();
        }
    }

    global class KoReturn{
        global String codMds;
        global String codPortafoglio;
        global String nomeMds;
        global String nomePortafoglio;
    }
    
    @HttpPost
    global static CreatePortafogliaDipartimentaleResponse createPortafogliaDipartimentale(PortafogliaDipartimentaleInputDto portafogliaDipartimentaleInput){
        System.debug('@@@@@@ REQUEST: '+JSON.serialize(portafogliaDipartimentaleInput));
        CreatePortafogliaDipartimentaleResponse createPortafogliaDipartimentaleResponse = new CreatePortafogliaDipartimentaleResponse();
        RestResponse res;
        RestRequest req;
        Savepoint sp= Database.setSavepoint();
        try{
            
            req = RestContext.request;
            res = RestContext.response;

            Map<String,SObject> modelliMap= SV_Utilities.keyBy([SELECT 
                                                            Id, Name, PTF_Code__c 
                                                            FROM ServiceModel__c  
                                                            ], 'Name', false) ;
            for(String modello:modelliMap.keySet()){
                modelliMap.put(modello.toUpperCase(), modelliMap.remove(modello));   
            }                                                
            //Set Response Headers
            setHeaders(req, res);
            //Controllo parametri mandatori
            checkRequiredParameter(portafogliaDipartimentaleInput);
            //Ricerca Consulente  
            String consulenteId = ricercaConsulente(portafogliaDipartimentaleInput);
            
            //Ricerca Portafoglio 
            //Assignment__c assignment= ricercaPortafoglio(portafogliaDipartimentaleInput, consulenteId, createPortafogliaDipartimentaleResponse, modelliMap);
            
            createPortafogliaDipartimentaleResponse = process(portafogliaDipartimentaleInput, createPortafogliaDipartimentaleResponse, modelliMap, consulenteId);

            WsRestUtils.writeLog('CreatePortafogliaDipartimentale', req.httpMethod, JSON.serializePretty(portafogliaDipartimentaleInput), createPortafogliaDipartimentaleResponse.portafogliaDipartimentaleOutput.code, createPortafogliaDipartimentaleResponse.portafogliaDipartimentaleOutput.message, JSON.serializePretty(createPortafogliaDipartimentaleResponse), req.headers, res.headers, '','');

            return createPortafogliaDipartimentaleResponse;
            
        }
        catch(CheckParamsException ex){
            createPortafogliaDipartimentaleResponse.portafogliaDipartimentaleOutput.code='007';
            createPortafogliaDipartimentaleResponse.portafogliaDipartimentaleOutput.message=ex.getMessage();
            Database.rollback(sp);
            WsRestUtils.writeLog('CreatePortafogliaDipartimentale', req.httpMethod, JSON.serializePretty(portafogliaDipartimentaleInput), createPortafogliaDipartimentaleResponse.portafogliaDipartimentaleOutput.code, createPortafogliaDipartimentaleResponse.portafogliaDipartimentaleOutput.message, JSON.serializePretty(createPortafogliaDipartimentaleResponse), req.headers, res.headers,'', '');
            return createPortafogliaDipartimentaleResponse;
        }
        catch(CheckConsulenteException ex){
            createPortafogliaDipartimentaleResponse.portafogliaDipartimentaleOutput.code='001';
            createPortafogliaDipartimentaleResponse.portafogliaDipartimentaleOutput.message=ex.getMessage();
            Database.rollback(sp);
            WsRestUtils.writeLog('CreatePortafogliaDipartimentale', req.httpMethod, JSON.serializePretty(portafogliaDipartimentaleInput), createPortafogliaDipartimentaleResponse.portafogliaDipartimentaleOutput.code, createPortafogliaDipartimentaleResponse.portafogliaDipartimentaleOutput.message, JSON.serializePretty(createPortafogliaDipartimentaleResponse), req.headers, res.headers, '','');
            return createPortafogliaDipartimentaleResponse;
        }/*
        catch(CheckPortafoglioException ex){
            createPortafogliaDipartimentaleResponse.portafogliaDipartimentaleOutput.code='002';
            createPortafogliaDipartimentaleResponse.portafogliaDipartimentaleOutput.message=ex.getMessage();
            Database.rollback(sp);
            WsRestUtils.writeLog('CreatePortafogliaDipartimentale', req.httpMethod, JSON.serializePretty(portafogliaDipartimentaleInput), createPortafogliaDipartimentaleResponse.portafogliaDipartimentaleOutput.code, createPortafogliaDipartimentaleResponse.portafogliaDipartimentaleOutput.message, JSON.serializePretty(createPortafogliaDipartimentaleResponse), req.headers, res.headers, '','');
            return createPortafogliaDipartimentaleResponse;
        }
        catch(MorePortafogliException ex){
            createPortafogliaDipartimentaleResponse.portafogliaDipartimentaleOutput.code='003';
            createPortafogliaDipartimentaleResponse.portafogliaDipartimentaleOutput.message=ex.getMessage();
            Database.rollback(sp);
            WsRestUtils.writeLog('CreatePortafogliaDipartimentale', req.httpMethod, JSON.serializePretty(portafogliaDipartimentaleInput), createPortafogliaDipartimentaleResponse.portafogliaDipartimentaleOutput.code, createPortafogliaDipartimentaleResponse.portafogliaDipartimentaleOutput.message, JSON.serializePretty(createPortafogliaDipartimentaleResponse), req.headers, res.headers, '','');
            return createPortafogliaDipartimentaleResponse;
        }
        catch(NoPortafogliException ex){
            createPortafogliaDipartimentaleResponse.portafogliaDipartimentaleOutput.code='004';
            createPortafogliaDipartimentaleResponse.portafogliaDipartimentaleOutput.message=ex.getMessage();
            Database.rollback(sp);
            WsRestUtils.writeLog('CreatePortafogliaDipartimentale', req.httpMethod, JSON.serializePretty(portafogliaDipartimentaleInput), createPortafogliaDipartimentaleResponse.portafogliaDipartimentaleOutput.code, createPortafogliaDipartimentaleResponse.portafogliaDipartimentaleOutput.message, JSON.serializePretty(createPortafogliaDipartimentaleResponse), req.headers, res.headers, '','');
            return createPortafogliaDipartimentaleResponse;
        }
        catch(AlreadyAssignedWithoutCodIdException ex){
            createPortafogliaDipartimentaleResponse.portafogliaDipartimentaleOutput.code='005';
            createPortafogliaDipartimentaleResponse.portafogliaDipartimentaleOutput.message=ex.getMessage();
            Database.rollback(sp);
            WsRestUtils.writeLog('CreatePortafogliaDipartimentale', req.httpMethod, JSON.serializePretty(portafogliaDipartimentaleInput), createPortafogliaDipartimentaleResponse.portafogliaDipartimentaleOutput.code, createPortafogliaDipartimentaleResponse.portafogliaDipartimentaleOutput.message, JSON.serializePretty(createPortafogliaDipartimentaleResponse), req.headers, res.headers, '','');
            return createPortafogliaDipartimentaleResponse;
        }*/
        catch(AlreadyAssignedException ex){
            createPortafogliaDipartimentaleResponse.portafogliaDipartimentaleOutput.code='006';
            createPortafogliaDipartimentaleResponse.portafogliaDipartimentaleOutput.message=ex.getMessage();
            Database.rollback(sp);
            WsRestUtils.writeLog('CreatePortafogliaDipartimentale', req.httpMethod, JSON.serializePretty(portafogliaDipartimentaleInput), createPortafogliaDipartimentaleResponse.portafogliaDipartimentaleOutput.code, createPortafogliaDipartimentaleResponse.portafogliaDipartimentaleOutput.message, JSON.serializePretty(createPortafogliaDipartimentaleResponse), req.headers, res.headers, '','');
            return createPortafogliaDipartimentaleResponse;
        }
        catch(Exception ex){
            createPortafogliaDipartimentaleResponse.portafogliaDipartimentaleOutput.code='099';
            createPortafogliaDipartimentaleResponse.portafogliaDipartimentaleOutput.message=ex.getMessage()+' '+ex.getStackTraceString();
            Database.rollback(sp);
            WsRestUtils.writeLog('CreatePortafogliaDipartimentale', req.httpMethod, JSON.serializePretty(portafogliaDipartimentaleInput), createPortafogliaDipartimentaleResponse.portafogliaDipartimentaleOutput.code, ex.getMessage().left(255), JSON.serializePretty(createPortafogliaDipartimentaleResponse), req.headers, res.headers, '','');
            return createPortafogliaDipartimentaleResponse;
        }
    }

    private static void checkRequiredParameter(PortafogliaDipartimentaleInputDto input){
        
        List<String> missingParams= new List<String>();

        if(String.isBlank(input.pAbi)){
            missingParams.add('pAbi');
        }
        if(String.isBlank(input.pCodFiliale)){
            missingParams.add('pCodFiliale');
        }
        if(String.isBlank(input.pNomEmailAddr)){
            missingParams.add('pNomEmailAddr');
        }
        if(input.pNdgList==null || input.pNdgList.size()==0){
            missingParams.add('pNdgList');
        }
        if(input.pNdgList!=null && input.pNdgList.size()>0){
            for(NDG ndg:input.pNdgList){
                if(String.isBlank(ndg.pNDG)){
                    missingParams.add('pNDG');
                }
                if(String.isBlank(ndg.pNomNome) && ndg.pNaturaGiuridica=='PF'){
                    missingParams.add('pNpNomNome');
                }
                if(String.isBlank(ndg.pNomCognome) && ndg.pNaturaGiuridica=='PF'){
                    missingParams.add('pNomCognome');
                }
                if(String.isBlank(ndg.pDenominazione) && ndg.pNaturaGiuridica=='CO'){
                    missingParams.add('pDenominazione');
                }
                if(String.isBlank(ndg.pNaturaGiuridica)){
                    missingParams.add('pNaturaGiuridica');
                }
            }
        }

        

        if(missingParams.size()>0){
            throw new CheckParamsException('Mancano i seguenti parametri mandatori: '+String.join(missingParams, ', '));
        }
    }

    private static void setHeaders(RestRequest req, RestResponse res){
        if(req.headers.containsKey('testata_operationId')){
            res.addHeader('testata_operationId', req.headers.get('testata_operationId'));
        }
    }

    private static String ricercaConsulente(PortafogliaDipartimentaleInputDto portafogliaDipartimentaleInput){

        /*String bancaRecordTypeId= SV_Utilities.getRecordTypeByDeveloperName('Account', 'Banca');
        String filialeRecordTypeId= SV_Utilities.getRecordTypeByDeveloperName('Account', 'FilialeDiRelazione');
        List<Account> bancaList= [SELECT Id FROM Account WHERE FinServ__BankNumber__c=:portafogliaDipartimentaleInput.pAbi AND RecordTypeId=:bancaRecordTypeId];
        /*if(bancaList.size()==0){
            throw new CheckConsulenteException('Referente non trovato in anagrafica di portafogliazione');
        }
        List<Account> filiali= [SELECT 
                    Id, PTF_Banca__r.FinServ__BankNumber__c,  PTF_BranchTypology__c 
                    FROM Account 
                    WHERE PTF_IdCEDFiliale__c=:portafogliaDipartimentaleInput.pCodFiliale AND PTF_Banca__r.FinServ__BankNumber__c=:portafogliaDipartimentaleInput.pAbi  AND RecordTypeId=:filialeRecordTypeId] ;
        
        
        String filialeId=filiali[0].Id;
        */
        List<Contact> consulenti = [SELECT Id FROM Contact WHERE PTF_RegistrationNumber__c=:((portafogliaDipartimentaleInput.pNomEmailAddr.replace('U', '')).replace(' ',''))];
        if(consulenti.size()==0){
            throw new CheckConsulenteException('Referente non trovato in anagrafica di portafogliazione');
        }
        return consulenti[0].Id;
}

    /*private static Assignment__c ricercaPortafoglio(PortafogliaDipartimentaleInputDto portafogliaDipartimentaleInput, String consulenteId, CreatePortafogliaDipartimentaleResponse createPortafogliaDipartimentaleResponse, Map<String,SObject> modelliMap){
        
        String cod_Id;
        

        String primarioRecordTypeId= SV_Utilities.getRecordTypeByDeveloperName('Assignment__c', 'Primario');
        List<Assignment__c> assignmentList = [SELECT Id, PTF_Gestore__r.AccountId, PTF_MicroWallet__r.PTF_Codice_Portafoglio__c, PTF_MicroWallet__r.Name, PTF_MicroWallet__r.PTF_ModelloDiServizio__c, PTF_MicroWallet__c FROM Assignment__c WHERE PTF_Gestore__c=:consulenteId AND RecordTypeId=:primarioRecordTypeId AND PTF_EndDate__c=null];
        if(assignmentList.size()==0){
            throw new CheckPortafoglioException('Nessun portafoglio associato al referente');
        }
        if(String.isBlank(portafogliaDipartimentaleInput.pCodPortafoglio) && assignmentList.size()>1){
            createPortafogliaDipartimentaleResponse.portafogliaDipartimentaleOutput.listKo= new ListaKoReturn();
            createPortafogliaDipartimentaleResponse.portafogliaDipartimentaleOutput.listKo.numeroElementiTotali=assignmentList.size();
            for(Assignment__c ass:assignmentList){
                KoReturn ko = new KoReturn();
                ko.codPortafoglio=ass.PTF_MicroWallet__r.PTF_Codice_Portafoglio__c;
                ko.nomePortafoglio=ass.PTF_MicroWallet__r.Name;
                ko.nomeMds=ass.PTF_MicroWallet__r.PTF_ModelloDiServizio__c;
                String modelName= ass.PTF_MicroWallet__r.PTF_ModelloDiServizio__c;
                ko.codMds= (String)modelliMap.get(modelName).get('PTF_Code__c') ;
                createPortafogliaDipartimentaleResponse.portafogliaDipartimentaleOutput.listKo.koReturn.add(ko);
            }
            throw new MorePortafogliException('Il referente ha più di un portafoglio assegnato');
        }
        
        List<String> portCodes= new List<String>();
        for(Assignment__c ass:assignmentList){
            portCodes.add(ass.PTF_MicroWallet__r.PTF_Codice_Portafoglio__c);
        }
        if(String.isNotBlank(portafogliaDipartimentaleInput.pCodPortafoglio) && assignmentList.size()>0 && !portCodes.contains(portafogliaDipartimentaleInput.pCodPortafoglio)){
            createPortafogliaDipartimentaleResponse.portafogliaDipartimentaleOutput.listKo= new ListaKoReturn();
            createPortafogliaDipartimentaleResponse.portafogliaDipartimentaleOutput.listKo.numeroElementiTotali=assignmentList.size();
            for(Assignment__c ass:assignmentList){
                KoReturn ko = new KoReturn();
                ko.codPortafoglio=ass.PTF_MicroWallet__r.PTF_Codice_Portafoglio__c;
                ko.nomePortafoglio=ass.PTF_MicroWallet__r.Name;
                ko.nomeMds=ass.PTF_MicroWallet__r.PTF_ModelloDiServizio__c;
                String modelName= ass.PTF_MicroWallet__r.PTF_ModelloDiServizio__c;
                ko.codMds= (String)modelliMap.get(modelName).get('PTF_Code__c') ;
                createPortafogliaDipartimentaleResponse.portafogliaDipartimentaleOutput.listKo.koReturn.add(ko);
            }
            throw new NoPortafogliException('II portafoglio richiesto non appartiene al referente');
        }
        Assignment__c assignment= new Assignment__c();
        if(String.isBlank(portafogliaDipartimentaleInput.pCodPortafoglio)){
            cod_Id=assignmentList[0].PTF_MicroWallet__r.PTF_Codice_Portafoglio__c;
            assignment=assignmentList[0];
        }
        else{
            cod_Id=portafogliaDipartimentaleInput.pCodPortafoglio;
            for(Assignment__c ass: assignmentList){
                if(cod_Id==ass.PTF_MicroWallet__r.PTF_Codice_Portafoglio__c){
                    assignment=ass;
                    break;
                }
            }
        }
        return assignment;
    }*/
    private static createPortafogliaDipartimentaleResponse process(PortafogliaDipartimentaleInputDto portafogliaDipartimentaleInput, CreatePortafogliaDipartimentaleResponse createPortafogliaDipartimentaleResponse, Map<String,SObject> modelliMap, String consulenteId){


        //Nuova Logica Start
        Assignment__c assignment= new Assignment__c();
        String primarioRecordTypeId= SV_Utilities.getRecordTypeByDeveloperName('Assignment__c', 'Primario');
        String filialeRecordTypeId= SV_Utilities.getRecordTypeByDeveloperName('Account', 'FilialeDiRelazione');
        
        String cedFiliale;
        if(portafogliaDipartimentaleInput.pCodFiliale=='0000' || portafogliaDipartimentaleInput.pCodFiliale=='0'){
            cedFiliale='0';
        }
        else{
            cedFiliale=portafogliaDipartimentaleInput.pCodFiliale.replaceFirst( '^0+', '');
        }
        List<Account> filiali= [SELECT 
                    Id, PTF_Banca__r.FinServ__BankNumber__c, FinServ__BankNumber__c , PTF_BranchTypology__c, PTF_Banca__c, PTF_Capofila__c, PTF_Area__c, PTF_DirezioneRegionale__c 
                    FROM Account 
                    WHERE PTF_IdCEDFiliale__c=:cedFiliale AND PTF_Banca__r.FinServ__BankNumber__c=:portafogliaDipartimentaleInput.pAbi  AND RecordTypeId=:filialeRecordTypeId] ;
        
        
        String filialeId=filiali[0].Id;
        List<Assignment__c> assignmentList = [SELECT Id, PTF_Gestore__r.AccountId, PTF_MicroWallet__r.PTF_Codice_Portafoglio__c, PTF_MicroWallet__r.Name, PTF_MicroWallet__r.PTF_ModelloDiServizio__c, PTF_MicroWallet__c FROM Assignment__c WHERE PTF_MicroWallet__r.PTF_ModelloDiServizio__c='Consulenti Finanziari' AND PTF_MicroWallet__r.PTF_Filiale__c=:filialeId AND PTF_Gestore__c=:consulenteId AND RecordTypeId=:primarioRecordTypeId AND PTF_EndDate__c=null];
        if(assignmentList.size()>0){
            assignment=assignmentList[0];
        }
        else{
            List<Contact> cList =[SELECT Id, PTF_User__c FROM Contact WHERE Id=:consulenteId];
            Wallet__c wal = new Wallet__c();
            wal.PTF_ModelloDiServizio__c='Consulenti Finanziari';
            wal.PTF_Filiale__c=filialeId;
            //wal.OwnerId=cList[0].PTF_User__c;
            wal.RecordTypeId = SV_Utilities.getRecordTypeByDeveloperName('Wallet__c', 'MicroWallet');
            NewMicroWalletController.buildName(wal);
            insert wal;
            NewMicroWalletController.createShare(new Set<String>{wal.Id});
            assignment.PTF_Gestore__c= consulenteId;
            assignment.RecordTypeId= primarioRecordTypeId;
            assignment.PTF_StartDate__c= Date.today();
            assignment.PTF_StartDate_DT__c = Datetime.now();
            assignment.PTF_MicroWallet__c= wal.Id;
            insert assignment;
        }
        //Nuova Logica End

        //String assenteRecordTypeId = SV_Utilities.getRecordTypeByDeveloperName('Wallet__c', 'Assente');
        //String tecnicoRecordTypeId = SV_Utilities.getRecordTypeByDeveloperName('Wallet__c', 'TechnicalWallet');
        String microRecordTypeId = SV_Utilities.getRecordTypeByDeveloperName('Wallet__c', 'MicroWallet');
        String personRecordTypeId = SV_Utilities.getRecordTypeByDeveloperName('Account', 'PersonAccount');
        String cointestazioneRecordTypeId = SV_Utilities.getRecordTypeByDeveloperName('Account', 'Cointestazione'); 
        List<String> ndgS = new List<String>();
        for(NDG ndg: portafogliaDipartimentaleInput.pNdgList){
            ndgS.add(portafogliaDipartimentaleInput.pAbi+'_'+ndg.pNDG);
        }
        Map<String,SObject> ndgMap= SV_Utilities.keyBy([SELECT 
                                                        Id, CRM_NDG__c, PTF_Portafoglio__r.Name, ModelloDiServizio__c, PTF_Portafoglio__c, PTF_Portafoglio__r.PTF_Codice_Portafoglio__c, PTF_Portafoglio__r.RecordTypeId , RecordType.DeveloperName, PTF_DeletionDate__c, PTF_Portafoglio__r.PTF_ModelloDiServizio__c
                                                        FROM Account  
                                                        WHERE NDW_ExternalId__c IN:ndgS
                                                        ], 'CRM_NDG__c', false) ;
        for(String key: ndgMap.keySet()){
            Account acc = (Account)ndgMap.get(key);
            
            if(String.isNotBlank(acc.PTF_Portafoglio__c) && acc.PTF_Portafoglio__c!=assignment.PTF_MicroWallet__c  && acc.PTF_DeletionDate__c==null && acc.ModelloDiServizio__c!='Residuale'){
                createPortafogliaDipartimentaleResponse.portafogliaDipartimentaleOutput.listKo= new ListaKoReturn();
                createPortafogliaDipartimentaleResponse.portafogliaDipartimentaleOutput.listKo.numeroElementiTotali=1;
                KoReturn ko = new KoReturn();
                ko.codPortafoglio=acc.PTF_Portafoglio__r.PTF_Codice_Portafoglio__c;
                ko.nomePortafoglio=acc.PTF_Portafoglio__r.Name;
                ko.nomeMds=acc.PTF_Portafoglio__r.PTF_ModelloDiServizio__c;
                ko.codMds= (String)modelliMap.get(ko.nomeMds.toUpperCase()).get('PTF_Code__c') ;
                createPortafogliaDipartimentaleResponse.portafogliaDipartimentaleOutput.listKo.koReturn.add(ko);
                /*if(String.isBlank(portafogliaDipartimentaleInput.pCodPortafoglio)){
                    throw new AlreadyAssignedWithoutCodIdException('NDG già assegnato ad un portafoglio');
                }*/
                //else{
                    throw new AlreadyAssignedException('NDG già assegnato ad un portafoglio');
                //}
            }   
        }
        List<Account> accToUpdate = new List<Account>();
        List<Account> accToInsert = new List<Account>();
        for(NDG ndg: portafogliaDipartimentaleInput.pNdgList){
            if(ndgMap.containsKey(ndg.pNDG)){
                Account acc = (Account)ndgMap.get(ndg.pNDG);
                if(acc.PTF_DeletionDate__c!=null || acc.ModelloDiServizio__c=='Residuale' || String.isBlank(acc.PTF_Portafoglio__c)){
                    acc.PTF_DeletionDate__c=null;
                    acc.PTF_ActivationDate__c=Date.today();
                    acc.PTF_DeactivationDate__c=null;
                    acc.PTF_Capofila__c= String.isNotBlank(filiali[0].PTF_Capofila__c) ? filiali[0].PTF_Capofila__c : filialeId;
                    acc.PTF_DirezioneRegionale__c=filiali[0].PTF_DirezioneRegionale__c;
                    acc.PTF_Area__c=filiali[0].PTF_Area__c;
                    acc.PTF_Banca__c=filiali[0].PTF_Banca__c;
                    acc.FinServ__BankNumber__c=filiali[0].FinServ__BankNumber__c;
                    acc.PTF_StatoCRM__c='ATT';
                    acc.PTF_Filiale__c= filialeId;
                    acc.PTF_Portafoglio__c= assignment.PTF_MicroWallet__c;
                    acc.PTF_NaturaGiuridica__c = ndg.pNaturaGiuridica;
                    acc.CRM_ManagementSegmentCode__c = 'RENCL';
                    if(ndg.pNaturaGiuridica=='PF'){
                        acc.FirstName=ndg.pNomNome;
                        acc.LastName=ndg.pNomCognome;
                    }
                    else if(ndg.pNaturaGiuridica=='CO'){
                        acc.Name=ndg.pDenominazione;
                    }
                    acc.ModelloDiServizio__c= assignment.PTF_MicroWallet__r.PTF_ModelloDiServizio__c;
                    accToUpdate.add(acc);
                    }
            }
            else{
                Account acc = new Account();
                acc.PTF_NaturaGiuridica__c = ndg.pNaturaGiuridica;
                if(ndg.pNaturaGiuridica=='PF'){
                    acc.RecordTypeId=personRecordTypeId;
                    acc.FirstName=ndg.pNomNome;
                    acc.LastName=ndg.pNomCognome;
                }
                else if(ndg.pNaturaGiuridica=='CO'){
                    acc.RecordTypeId=cointestazioneRecordTypeId;
                    acc.Name=ndg.pDenominazione;
                }
                acc.PTF_Capofila__c= String.isNotBlank(filiali[0].PTF_Capofila__c) ? filiali[0].PTF_Capofila__c : filialeId;
                acc.PTF_DirezioneRegionale__c=filiali[0].PTF_DirezioneRegionale__c;
                acc.PTF_Area__c=filiali[0].PTF_Area__c;
                acc.PTF_Banca__c=filiali[0].PTF_Banca__c;
                acc.FinServ__BankNumber__c=filiali[0].FinServ__BankNumber__c;
                acc.PTF_StatoCRM__c='ATT';
                acc.PTF_Portafoglio__c= assignment.PTF_MicroWallet__c;
                acc.PTF_Filiale__c= filialeId;
                acc.CRM_ManagementSegmentCode__c = 'RENCL';
                acc.ModelloDiServizio__c= assignment.PTF_MicroWallet__r.PTF_ModelloDiServizio__c;
                acc.NDW_ExternalId__c=portafogliaDipartimentaleInput.pAbi+'_'+ndg.pNDG;
                acc.CRM_NDG__c=ndg.pNDG;
                acc.PTF_ActivationDate__c=Date.today();
                acc.PTF_DeactivationDate__c=null;
                acc.OperationStrategy__c='INS';
                accToInsert.add(acc);  
            }
        }
        if(accToInsert.size()>0){
            insert accToInsert;
        }
        if(accToUpdate.size()>0){
            update accToUpdate;
        }


        List<Account> accToReturn= [SELECT CRM_NDG__c, PTF_Portafoglio__r.Name, PTF_Portafoglio__r.PTF_Codice_Portafoglio__c FROM Account WHERE NDW_ExternalId__c IN:ndgS];
        createPortafogliaDipartimentaleResponse.portafogliaDipartimentaleOutput.listCodPortafoglio= new ListaPortafoglio();
        createPortafogliaDipartimentaleResponse.portafogliaDipartimentaleOutput.listCodPortafoglio.numeroElementiTotali=accToReturn.size();
        for(Account acc:accToReturn){
            Portafoglio por = new Portafoglio();
            por.codPortafoglio=acc.PTF_Portafoglio__r.PTF_Codice_Portafoglio__c;
            por.ndg=acc.CRM_NDG__c;
            por.nomePortafoglio=acc.PTF_Portafoglio__r.Name;
            createPortafogliaDipartimentaleResponse.portafogliaDipartimentaleOutput.listCodPortafoglio.portafogli.add(por);
        }
        
        createPortafogliaDipartimentaleResponse.portafogliaDipartimentaleOutput.code='000';
        createPortafogliaDipartimentaleResponse.portafogliaDipartimentaleOutput.message='OK';
        return createPortafogliaDipartimentaleResponse;
    }
}