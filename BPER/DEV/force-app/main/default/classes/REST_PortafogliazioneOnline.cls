@RestResource(urlMapping='/v1/portafogliazioneOnline/*')
global with sharing class REST_PortafogliazioneOnline {
    public REST_PortafogliazioneOnline() {

    }

    public class CheckParamsException extends Exception {}
    public class CheckConsulenteException extends Exception {}
    public class AlreadyAssignedException extends Exception {}
    public class CheckMdsCodeException extends Exception {}

    global class PortafogliazioneOnlineInput{
        global String abi;
        global String codFiliale;
        global String Matricola;
        global String CodiceMDS;
        global List<NDG_Input> ndgList;
    }

    global class NDG_Input{
        global String denominazione;
        global String naturaGiuridica;
        global String ndg;
        global String cognome;
        global String nome;
        global Boolean fuoriSede;
    }

    global class NDG_Output{
        global String esitoNDG =' ';
        global String errorCodeNDG =' ';
        global String messaggioNDG =' ';
        global String abi =' ';
        global String filiale =' ';
        global String ndg =' ';
        global String nominativo =' ';
        global String tipoNDG =' ';
        global String gruco =' ';
        global String mds =' ';
        global String caponucleo =' ';
        global String nomePRTF =' ';
        global String matricola =' ';
        global String nominativoReferente =' ';
        global String codGruco =' ';
        global String codMDS =' ';
        global String segmentoComportamentale =' ';
    }

    global class PortafogliazioneOnlineResponse{
        global PortafogliazioneOnlineOutput portafogliazioneOnlineOutput;
        global PortafogliazioneOnlineResponse(){
            this.portafogliazioneOnlineOutput  = new PortafogliazioneOnlineOutput();
        }
    }

    global class PortafogliazioneOnlineOutput{
        global String esito;
        global String errorCode;
        global String messaggio;
        global List<NDG_Output> ndgList;
        
    }

    /*global class ListaPortafoglio{
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
    }*/
    
    @HttpPost
    global static PortafogliazioneOnlineResponse processRiportafogliazioneOnline(PortafogliazioneOnlineInput portafogliazioneOnlineInput){
        System.debug('@@@@@@ REQUEST: '+JSON.serialize(portafogliazioneOnlineInput));
        PortafogliazioneOnlineResponse portafogliazioneOnlineResponse = new PortafogliazioneOnlineResponse();
        RestResponse res;
        RestRequest req;
        String mDSDescription='';
        Savepoint sp= Database.setSavepoint();
        try{
            
            req = RestContext.request;
            res = RestContext.response;

            Map<String,SObject> modelliMap= SV_Utilities.keyBy([SELECT 
                                                            Id, Name, PTF_Code__c 
                                                            FROM ServiceModel__c WHERE PTF_Code__c =:portafogliazioneOnlineInput.CodiceMDS
                                                            ], 'Name', false) ;
            if(modelliMap.isEmpty() || (portafogliazioneOnlineInput.CodiceMDS!='1' && portafogliazioneOnlineInput.CodiceMDS!='15')){
            	throw new CheckMdsCodeException('Il modello di servizio indicato non è corretto oppure non è abilitato alla funzionalità: '+portafogliazioneOnlineInput.CodiceMDS);
        	}
            for(String modello:modelliMap.keySet()){
                modelliMap.put(modello.toUpperCase(), modelliMap.remove(modello));
                mDSDescription=modello;
            }                                                
            //Set Response Headers
            setHeaders(req, res);
            //Controllo parametri mandatori
            checkRequiredParameter(portafogliazioneOnlineInput);
            //Ricerca Consulente  
            String consulenteId = ricercaConsulente(portafogliazioneOnlineInput);
            
            //Ricerca Portafoglio 
            //Assignment__c assignment= ricercaPortafoglio(portafogliazioneOnlineInput, consulenteId, portafogliazioneOnlineResponse, modelliMap);
            
            portafogliazioneOnlineResponse = process(portafogliazioneOnlineInput, portafogliazioneOnlineResponse, mDSDescription, consulenteId);

            WsRestUtils.writeLog('processRiportafogliazioneOnline', req.httpMethod, JSON.serializePretty(portafogliazioneOnlineInput), portafogliazioneOnlineResponse.portafogliazioneOnlineOutput.errorCode, portafogliazioneOnlineResponse.portafogliazioneOnlineOutput.messaggio, JSON.serializePretty(portafogliazioneOnlineResponse), req.headers, res.headers, '','');

            return portafogliazioneOnlineResponse;
            
        }
        catch(CheckMdsCodeException ex){
            portafogliazioneOnlineResponse.portafogliazioneOnlineOutput.errorCode='007';
            portafogliazioneOnlineResponse.portafogliazioneOnlineOutput.messaggio=ex.getMessage();
            Database.rollback(sp);
            WsRestUtils.writeLog('processRiportafogliazioneOnline', req.httpMethod, JSON.serializePretty(portafogliazioneOnlineInput), portafogliazioneOnlineResponse.portafogliazioneOnlineOutput.errorCode, portafogliazioneOnlineResponse.portafogliazioneOnlineOutput.messaggio, JSON.serializePretty(portafogliazioneOnlineResponse), req.headers, res.headers,'', '');
            return portafogliazioneOnlineResponse;
        }
        catch(CheckParamsException ex){
            portafogliazioneOnlineResponse.portafogliazioneOnlineOutput.errorCode='007';
            portafogliazioneOnlineResponse.portafogliazioneOnlineOutput.messaggio=ex.getMessage();
            Database.rollback(sp);
            WsRestUtils.writeLog('processRiportafogliazioneOnline', req.httpMethod, JSON.serializePretty(portafogliazioneOnlineInput), portafogliazioneOnlineResponse.portafogliazioneOnlineOutput.errorCode, portafogliazioneOnlineResponse.portafogliazioneOnlineOutput.messaggio, JSON.serializePretty(portafogliazioneOnlineResponse), req.headers, res.headers,'', '');
            return portafogliazioneOnlineResponse;
        }
        catch(CheckConsulenteException ex){
            portafogliazioneOnlineResponse.portafogliazioneOnlineOutput.errorCode='001';
            portafogliazioneOnlineResponse.portafogliazioneOnlineOutput.messaggio=ex.getMessage();
            Database.rollback(sp);
            WsRestUtils.writeLog('processRiportafogliazioneOnline', req.httpMethod, JSON.serializePretty(portafogliazioneOnlineInput), portafogliazioneOnlineResponse.portafogliazioneOnlineOutput.errorCode, portafogliazioneOnlineResponse.portafogliazioneOnlineOutput.messaggio, JSON.serializePretty(portafogliazioneOnlineResponse), req.headers, res.headers, '','');
            return portafogliazioneOnlineResponse;
        }
        catch(AlreadyAssignedException ex){
            portafogliazioneOnlineResponse.portafogliazioneOnlineOutput.errorCode='006';
            portafogliazioneOnlineResponse.portafogliazioneOnlineOutput.messaggio=ex.getMessage();
            Database.rollback(sp);
            WsRestUtils.writeLog('processRiportafogliazioneOnline', req.httpMethod, JSON.serializePretty(portafogliazioneOnlineInput), portafogliazioneOnlineResponse.portafogliazioneOnlineOutput.errorCode, portafogliazioneOnlineResponse.portafogliazioneOnlineOutput.messaggio, JSON.serializePretty(portafogliazioneOnlineResponse), req.headers, res.headers, '','');
            return portafogliazioneOnlineResponse;
        }
        catch(Exception ex){
            portafogliazioneOnlineResponse.portafogliazioneOnlineOutput.errorCode='099';
            portafogliazioneOnlineResponse.portafogliazioneOnlineOutput.messaggio=ex.getMessage()+' '+ex.getStackTraceString();
            Database.rollback(sp);
            WsRestUtils.writeLog('processRiportafogliazioneOnline', req.httpMethod, JSON.serializePretty(portafogliazioneOnlineInput), portafogliazioneOnlineResponse.portafogliazioneOnlineOutput.errorCode, ex.getMessage().left(255), JSON.serializePretty(portafogliazioneOnlineResponse), req.headers, res.headers, '','');
            return portafogliazioneOnlineResponse;
        }
    }

    private static void checkRequiredParameter(PortafogliazioneOnlineInput input){
        
        List<String> missingParams= new List<String>();

        if(String.isBlank(input.abi)){
            missingParams.add('abi');
        }
        if(String.isBlank(input.codFiliale)){
            missingParams.add('codFiliale');
        }
        if(String.isBlank(input.Matricola)){
            missingParams.add('Matricola');
        }
        if(String.isBlank(input.CodiceMDS)){
            missingParams.add('CodiceMDS');
        }
        if(input.ndgList==null || input.ndgList.size()==0){
            missingParams.add('ndgList');
        }
        if(input.ndgList!=null && input.ndgList.size()>0){
            for(NDG_Input ndg:input.ndgList){
                if(String.isBlank(ndg.ndg)){
                    missingParams.add('ndg');
                }
                if(String.isBlank(ndg.nome) && ndg.naturaGiuridica=='PF'){
                    missingParams.add('Nome');
                }
                if(String.isBlank(ndg.cognome) && ndg.naturaGiuridica=='PF'){
                    missingParams.add('cognome');
                }
                if(String.isBlank(ndg.denominazione) && ndg.naturaGiuridica=='CO'){
                    missingParams.add('denominazione');
                }
                if(String.isBlank(ndg.naturaGiuridica)){
                    missingParams.add('naturaGiuridica');
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

    private static String ricercaConsulente(PortafogliazioneOnlineInput portafogliazioneOnlineInput){

        List<Contact> consulenti = [SELECT Id FROM Contact WHERE PTF_RegistrationNumber__c=:portafogliazioneOnlineInput.matricola];
        if(consulenti.size()==0){
            throw new CheckConsulenteException('Referente non trovato in anagrafica di portafogliazione');
        }
        return consulenti[0].Id;
    }

    private static PortafogliazioneOnlineResponse process(PortafogliazioneOnlineInput portafogliazioneOnlineInput, PortafogliazioneOnlineResponse portafogliazioneOnlineResponse, String mdsDescription, String consulenteId){


        //Nuova Logica Start
        Assignment__c assignment= new Assignment__c();
        String primarioRecordTypeId= SV_Utilities.getRecordTypeByDeveloperName('Assignment__c', 'Primario');
        String filialeRecordTypeId= SV_Utilities.getRecordTypeByDeveloperName('Account', 'FilialeDiRelazione');
        
        String cedFiliale;
        if(portafogliazioneOnlineInput.codFiliale=='0000' || portafogliazioneOnlineInput.codFiliale=='0'){
            cedFiliale='0';
        }
        else{
            cedFiliale=portafogliazioneOnlineInput.codFiliale.replaceFirst( '^0+', '');
        }
        List<Account> filiali= [SELECT 
                    Id, PTF_Banca__r.FinServ__BankNumber__c, FinServ__BankNumber__c , PTF_BranchTypology__c, PTF_Banca__c, PTF_Capofila__c, PTF_Area__c, PTF_DirezioneRegionale__c 
                    FROM Account 
                    WHERE PTF_IdCEDFiliale__c=:cedFiliale AND PTF_Banca__r.FinServ__BankNumber__c=:portafogliazioneOnlineInput.abi  AND RecordTypeId=:filialeRecordTypeId] ;
        
        
        String filialeId=filiali[0].Id;
        List<Assignment__c> assignmentList = [SELECT Id, PTF_Gestore__r.AccountId, PTF_MicroWallet__r.PTF_Codice_Portafoglio__c, PTF_MicroWallet__r.Name, PTF_MicroWallet__r.PTF_ModelloDiServizio__c, PTF_MicroWallet__c FROM Assignment__c WHERE PTF_MicroWallet__r.PTF_ModelloDiServizio__c=:mdsDescription AND PTF_MicroWallet__r.PTF_Filiale__c=:filialeId AND PTF_Gestore__c=:consulenteId AND RecordTypeId=:primarioRecordTypeId AND PTF_EndDate__c=null];
        if(assignmentList.size()>0){
            assignment=assignmentList[0];
        }
        else{
            List<Contact> cList =[SELECT Id, PTF_User__c FROM Contact WHERE Id=:consulenteId];
            Wallet__c wal = new Wallet__c();
            wal.PTF_ModelloDiServizio__c=/*'Consulenti Finanziari'; */mdsDescription;
            wal.PTF_Filiale__c=filialeId;
            //wal.OwnerId=cList[0].PTF_User__c;
            wal.RecordTypeId = SV_Utilities.getRecordTypeByDeveloperName('Wallet__c', 'MicroWallet');
            NewMicroWalletController.buildName(wal,false,false);
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
        for(NDG_Input ndg: portafogliazioneOnlineInput.ndgList){
            ndgS.add(portafogliazioneOnlineInput.abi+'_'+ndg.ndg);
        }
        Map<String,SObject> ndgMap= SV_Utilities.keyBy([SELECT 
                                                        Id, CRM_NDG__c, PTF_Portafoglio__r.Name, ModelloDiServizio__c, PTF_Portafoglio__c, PTF_Portafoglio__r.PTF_Codice_Portafoglio__c, PTF_Portafoglio__r.RecordTypeId , RecordType.DeveloperName, PTF_DeletionDate__c, PTF_Portafoglio__r.PTF_ModelloDiServizio__c
                                                        FROM Account  
                                                        WHERE NDW_ExternalId__c IN:ndgS
                                                        ], 'CRM_NDG__c', false) ;
        for(String key: ndgMap.keySet()){
            Account acc = (Account)ndgMap.get(key);
            
            if(String.isNotBlank(acc.PTF_Portafoglio__c) && acc.PTF_Portafoglio__c!=assignment.PTF_MicroWallet__c  && acc.PTF_DeletionDate__c==null && acc.ModelloDiServizio__c!='Residuale'){
                /*portafogliazioneOnlineResponse.portafogliazioneOnlineOutput.listKo= new ListaKoReturn();
                portafogliazioneOnlineResponse.portafogliazioneOnlineOutput.listKo.numeroElementiTotali=1;
                KoReturn ko = new KoReturn();
                ko.codPortafoglio=acc.PTF_Portafoglio__r.PTF_Codice_Portafoglio__c;
                ko.nomePortafoglio=acc.PTF_Portafoglio__r.Name;
                ko.nomeMds=acc.PTF_Portafoglio__r.PTF_ModelloDiServizio__c;
                ko.codMds= (String)modelliMap.get(ko.nomeMds.toUpperCase()).get('PTF_Code__c') ;
                portafogliazioneOnlineResponse.portafogliazioneOnlineOutput.listKo.koReturn.add(ko);*/
                /*if(String.isBlank(portafogliazioneOnlineInput.codPortafoglio)){
                    throw new AlreadyAssignedWithoutCodIdException('NDG già assegnato ad un portafoglio');
                }*/
                //else{
                    throw new AlreadyAssignedException('NDG già assegnato ad un portafoglio');
                //}
            }   
        }
        List<Account> accToUpdate = new List<Account>();
        List<Account> accToInsert = new List<Account>();
        for(NDG_Input ndg: portafogliazioneOnlineInput.ndgList){
            if(ndgMap.containsKey(ndg.ndg)){
                Account acc = (Account)ndgMap.get(ndg.ndg);
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
                    acc.PTF_NaturaGiuridica__c = ndg.naturaGiuridica;
                    acc.CRM_ManagementSegmentCode__c = '';
                    if(ndg.naturaGiuridica=='PF'){
                        acc.FirstName=ndg.nome;
                        acc.LastName=ndg.cognome;
                    }
                    else if(ndg.naturaGiuridica=='CO'){
                        acc.Name=ndg.denominazione;
                    }
                    acc.ModelloDiServizio__c= assignment.PTF_MicroWallet__r.PTF_ModelloDiServizio__c;
                    accToUpdate.add(acc);
                    }
            }
            else{
                Account acc = new Account();
                acc.PTF_NaturaGiuridica__c = ndg.naturaGiuridica;
                if(ndg.naturaGiuridica=='PF'){
                    acc.RecordTypeId=personRecordTypeId;
                    acc.FirstName=ndg.nome;
                    acc.LastName=ndg.cognome;
                }
                else if(ndg.naturaGiuridica=='CO'){
                    acc.RecordTypeId=cointestazioneRecordTypeId;
                    acc.Name=ndg.denominazione;
                }
                acc.PTF_Capofila__c= String.isNotBlank(filiali[0].PTF_Capofila__c) ? filiali[0].PTF_Capofila__c : filialeId;
                acc.PTF_DirezioneRegionale__c=filiali[0].PTF_DirezioneRegionale__c;
                acc.PTF_Area__c=filiali[0].PTF_Area__c;
                acc.PTF_Banca__c=filiali[0].PTF_Banca__c;
                acc.FinServ__BankNumber__c=filiali[0].FinServ__BankNumber__c;
                acc.PTF_StatoCRM__c='ATT';
                acc.PTF_Portafoglio__c= assignment.PTF_MicroWallet__c;
                acc.PTF_Filiale__c= filialeId;
                acc.CRM_ManagementSegmentCode__c = '';
                acc.ModelloDiServizio__c= assignment.PTF_MicroWallet__r.PTF_ModelloDiServizio__c;
                acc.NDW_ExternalId__c=portafogliazioneOnlineInput.abi+'_'+ndg.ndg;
                acc.CRM_NDG__c=ndg.ndg;
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


        List<Account> accToReturn= [SELECT CRM_NDG__c, PTF_Portafoglio__r.Name, Id, FinServ__BankNumber__c, CRM_Filiale__r.PTF_IdCEDFiliale__c,PTF_Filiale__r.PTF_IdCEDFiliale__c, name, PTF_IndiceGruco__c, PTF_NaturaGiuridica__c, ModelloDiServizio__c, PTF_Portafoglio__r.CRM_ReferentePortafoglio__r.Name, PTF_Portafoglio__r.CRM_ReferentePortafoglio__r.PTF_RegistrationNumber__c, PTF_IndiceNuovoMDS__c, PTF_SegmentoComportamentale__c, PTF_GruppoComportamentale__c,PTF_SegmentoComportamentaleCode__c  FROM Account WHERE NDW_ExternalId__c IN:ndgS];
        /*portafogliazioneOnlineResponse.portafogliazioneOnlineOutput.listCodPortafoglio= new ListaPortafoglio();
        portafogliazioneOnlineResponse.portafogliazioneOnlineOutput.listCodPortafoglio.numeroElementiTotali=accToReturn.size();
        for(Account acc:accToReturn){
            Portafoglio por = new Portafoglio();
            por.codPortafoglio=acc.PTF_Portafoglio__r.PTF_Codice_Portafoglio__c;
            por.ndg=acc.CRM_NDG__c;
            por.nomePortafoglio=acc.PTF_Portafoglio__r.Name;
            portafogliazioneOnlineResponse.portafogliazioneOnlineOutput.listCodPortafoglio.portafogli.add(por);
        }*/
        
        portafogliazioneOnlineResponse.portafogliazioneOnlineOutput.ndgList= new List<NDG_Output>();
        
        Map<String,String> defaultValueMap = New Map<String,String>{'Number'=>'0','String'=>' '};
        
        for(Account acc:accToReturn){
            NDG_Output nNdgOut = new NDG_Output();
            nNdgOut.esitoNDG='OK';
            nNdgOut.errorCodeNDG='000';
            nNdgOut.abi =(acc.FinServ__BankNumber__c!= null ? acc.FinServ__BankNumber__c : defaultValueMap.get('Number'));
            nNdgOut.filiale = (acc.PTF_Filiale__r.PTF_IdCEDFiliale__c!= null ? acc.PTF_Filiale__r.PTF_IdCEDFiliale__c : defaultValueMap.get('Number'));
            nNdgOut.ndg = (acc.CRM_NDG__c!= null ? acc.CRM_NDG__c : defaultValueMap.get('Number'));
            nNdgOut.nominativo = (acc.Name!= null ? acc.Name : defaultValueMap.get('Number'));
            nNdgOut.tipoNDG = (acc.PTF_NaturaGiuridica__c!= null ? acc.PTF_NaturaGiuridica__c : defaultValueMap.get('Number'));
            nNdgOut.gruco = (acc.PTF_GruppoComportamentale__c!= null ? acc.PTF_GruppoComportamentale__c : defaultValueMap.get('Number'));
            nNdgOut.mds = (acc.ModelloDiServizio__c!= null ? acc.ModelloDiServizio__c : defaultValueMap.get('Number'));
            nNdgOut.nomePRTF = (acc.PTF_Portafoglio__r.Name!= null ? acc.PTF_Portafoglio__r.Name : defaultValueMap.get('Number'));
            nNdgOut.matricola = (acc.PTF_Portafoglio__r.CRM_ReferentePortafoglio__r.PTF_RegistrationNumber__c!= null ? acc.PTF_Portafoglio__r.CRM_ReferentePortafoglio__r.PTF_RegistrationNumber__c : defaultValueMap.get('Number'));
            nNdgOut.nominativoReferente = (acc.PTF_Portafoglio__r.CRM_ReferentePortafoglio__r.Name!= null ? acc.PTF_Portafoglio__r.CRM_ReferentePortafoglio__r.Name : defaultValueMap.get('Number'));
            nNdgOut.codGruco = (acc.PTF_IndiceGruco__c!= null ? String.ValueOf(acc.PTF_IndiceGruco__c) : defaultValueMap.get('Number'));
            nNdgOut.codMDS = (portafogliazioneOnlineInput.CodiceMDS!= null ? portafogliazioneOnlineInput.CodiceMDS : defaultValueMap.get('Number'));
            nNdgOut.segmentoComportamentale = (acc.PTF_SegmentoComportamentaleCode__c!= null ? acc.PTF_SegmentoComportamentaleCode__c : defaultValueMap.get('Number'));
            
            
                
            portafogliazioneOnlineResponse.portafogliazioneOnlineOutput.ndgList.add(nNdgOut);
        }
        
        portafogliazioneOnlineResponse.portafogliazioneOnlineOutput.errorCode='000';
        portafogliazioneOnlineResponse.portafogliazioneOnlineOutput.messaggio='OK';
        portafogliazioneOnlineResponse.portafogliazioneOnlineOutput.esito='OK';
        

        
        return portafogliazioneOnlineResponse;
    }
}