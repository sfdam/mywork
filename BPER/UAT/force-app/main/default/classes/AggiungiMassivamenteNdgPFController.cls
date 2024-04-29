public without sharing class AggiungiMassivamenteNdgPFController {

    public static String currentMDS{get;set;}
    public static String currentBranchType{get;set;}
    public static String abi{get;set;}

    @AuraEnabled
    public static User currentUser{

        get{

            if(currentUser != null){

                return currentUser;
            }
            currentUser = [SELECT Id, Profile.Name, Profilo__c, PTF_RuoloLDAP__c, idced__c, PTF_IdCEDPadre__c, banca__c FROM User WHERE id =: UserInfo.getUserId()];
            return currentUser;
        }set;
    }

    @AuraEnabled
    public static Contact currentContact{

        get{

            if(currentContact != null){

                return currentContact;
            }
            List<Contact> currentContactList = [SELECT Id, PTF_User__c, AccountId, Account.PTF_IdCEDPadre__c, Account.PTF_Division__c, Account.PTF_MacroDivision__c, PTF_TipologiaRuolo__r.Name FROM Contact WHERE PTF_User__c =: UserInfo.getUserId() AND AccountId != '' ORDER BY CreatedDate DESC LIMIT 1];
            currentContact = new Contact();
            if(!currentContactList.isEmpty()){

                currentContact = currentContactList[0];
            }
            return currentContact;
        }set;
    }

    @AuraEnabled
    public static Map<String, SObject> servceModelMap{

        get{

            if(servceModelMap != null){

                return servceModelMap;
            }
            servceModelMap = SV_Utilities.keyBy([SELECT id, Name, PTF_Division__c, PTF_MacroDivision__c FROM ServiceModel__c], 'Name');
            return servceModelMap;
        }set;
    } 

    @AuraEnabled
    public static Map<String, ConfigurazioneSpostamenti__mdt> referentiConfigurazioniMap{

        get{

            if(referentiConfigurazioniMap != null){
    
                return referentiConfigurazioniMap;
            }
    
            referentiConfigurazioniMap = new Map<String, ConfigurazioneSpostamenti__mdt>();
            for(ConfigurazioneSpostamenti__mdt configurazione : [ SELECT Id, MasterLabel, PTF_MDS_End__c, PTF_MDS_Start__c,
                                PTF_Abi__c, Finestra_Temporale__c, Iter_Approvativo__c,
                                PTF_Filiale_End__c, PTF_Filiale_Start__c, PTF_Filiale_StessaArea__c, PTF_Filiale_StessaDR__c,
                                PTF_Filiale_StessoMicroMercato__c, PTF_JSON_Approvatori__c, PTF_StessoReferente__c,
                                PTF_CheckNaturaGiuridica__c, PTF_CheckTipologiaFilialeDestinazione__c, 
                                PTF_CheckCedSpecifico__c, PTF_CheckTipologiaFilialePartenza__c, Tipo_di_Spostamento__c
                                ,PTF_SuperUsers__c
                                FROM ConfigurazioneSpostamenti__mdt
                                WHERE Tipo_di_Spostamento__c = 'Referenti' AND
                                PTF_MDS_Start__c =: currentMDS AND PTF_IsActive__c = true]){
                
                if(String.isBlank(configurazione.PTF_CheckTipologiaFilialePartenza__c)){

                    referentiConfigurazioniMap.put(configurazione.PTF_MDS_Start__c + '_' + configurazione.PTF_MDS_End__c + '_' + configurazione.PTF_Abi__c, configurazione);
                }else{

                    for(String filialePartenza : configurazione.PTF_CheckTipologiaFilialePartenza__c.split(',')){

                        referentiConfigurazioniMap.put(configurazione.PTF_MDS_Start__c + '_' + configurazione.PTF_MDS_End__c + '_' + filialePartenza + '_' + configurazione.PTF_Abi__c, configurazione);
                    }
                }
            }
            return referentiConfigurazioniMap;
        }set;
    }

    @AuraEnabled
    public static Map<String,Object> init(String recordId){
        //NEW UFF PRIVATE
        Wallet__c currentPF = [SELECT Id, Name, PTF_ModelloDiServizio__c, PTF_UffPrivate__c, PTF_Filiale__r.PTF_UffPrivate__c, PTF_Filiale__r.PTF_IDCEDUffPrivate__c, PTF_Filiale__r.PTF_UffPrivate__r.PTF_IdCedPadre__c,
        PTF_Filiale__c, PTF_Filiale__r.PTF_BranchTypeDesc__c, PTF_Filiale__r.PTF_BranchTypologyMap__c, PTF_Filiale__r.Name, PTF_FIliale__r.PTF_IdCed__c, PTF_Capofila__c, PTF_Capofila__r.PTF_IdCed__c,
        PTF_Banca__c, PTF_Banca__r.FinServ__BankNumber__c, PTF_Banca__r.PTF_DowngradeReqStartDate__c, PTF_Banca__r.PTF_DowngradeReqEndDate__c, PTF_Banca__r.PTF_IdCed__c,
        PTF_DirezioneRegionale__r.PTF_IdCed__c, PTF_Area__r.PTF_IdCed__c, PTF_DirezioneRegionale__c, PTF_Area__c, Owner.Name, PTF_Fatturato__c, PTF_Patrimonio__c, PTF_Utilizzato__c, PTF_Accordato__c,
        PTF_DirezioneRegionale__r.PTF_DowngradeReqStartDate__c, PTF_DirezioneRegionale__r.PTF_DowngradeReqEndDate__c, PTF_Pool__c, PTF_Filiale__r.PTF_DowngradeReqStartDate__c, PTF_Filiale__r.PTF_DowngradeReqEndDate__c,
        PTF_Filiale__r.PTF_BloccaSpostamentiInFiliale__c, PTF_Filiale__r.PTF_BloccaSpostamentiFiliale__c,
        (SELECT id, PTF_Gestore__c, PTF_Gestore__r.PTF_OFS__c, PTF_Gestore__r.Name FROM Backup_Assignments__r WHERE RecordType.DeveloperName = 'Primario' AND PTF_EndDate__c = null)
        FROM Wallet__c WHERE Id =: recordId AND RecordType.developerName != 'TechnicalWallet' ];
        currentMDS = currentPF.PTF_ModelloDiServizio__c;
        currentBranchType = currentPF.PTF_Filiale__r.PTF_BranchTypeDesc__c;
        abi = currentPF.PTF_Banca__r.FinServ__BankNumber__c;
        if(currentUser.Profilo__c != 'NEC_D.0' && (currentPF.PTF_Filiale__r.PTF_BloccaSpostamentiFiliale__c ||
            currentPF.PTF_Filiale__r.PTF_BloccaSpostamentiInFiliale__c)){
            String errorMessage = 'Lo spostamento di questo NDG è momentaneamente bloccato dalla Filiale.';
            return new Map<String,Object> {
    
                'errorMessage' => errorMessage
            };
        }else{

            // User currentUser = [SELECT Id, Profile.Name, Profilo__c FROM User WHERE id =: UserInfo.getUserId()];
            // List<Contact> currentContact = [SELECT id, Name, PTF_TipologiaRuolo__r.Name, AccountId FROM Contact WHERE PTF_User__c =: UserInfo.getUserId() LIMIT 1];
            return new Map<String,Object> {
    
                'currentPF' => currentPF,
                'currentUser' => currentUser,
                'hasOFS' => currentPF.Backup_Assignments__r.size() > 0,
                'currentContact' => currentContact,
                'referentiConfigurazioniMap' => referentiConfigurazioniMap
            };
        }
    }

    @AuraEnabled
    public static Map<String, Object> loadNdgList(Wallet__c portafoglio, Boolean isOFS, string nome, String ndg, Integer offset, Integer pagesize, Wallet__c portafoglioDiDestinazione){
        
        WrapperObj response = new WrapperObj();

        Map<String, SObject> accMap = new Map<String, SObject>();
        Map<String, SObject> gruppiFMap = new Map<String, SObject>();
        Set<String> accGruppoId = new Set<String>();
        Set<String> capoGruppoIdSet = new Set<String>();
        Set<String> accId = new Set<String>();

        Set<Boolean> valueOFS = new Set<Boolean>();
        valueOFS.add(false);
        if(isOFS){
            valueOFS.add(true);
        } 


        accMap = SV_Utilities.keyBy([SELECT Id, Name, CRM_NDG__c, PTF_CapoGruppo__c, PTF_Gruppo__c, PTF_Filiale__c, PTF_Filiale__r.Name, ModelloDiServizio__c, PTF_Portafoglio__c, PTF_Portafoglio__r.Name, 
                                            PTF_Patrimonio__c, PTF_Utilizzato__c, PTF_NaturaGiuridica__c, PTF_OFS__c, RecordType.DeveloperName
                                    FROM Account
                                    WHERE PTF_Portafoglio__c =: portafoglio.Id AND 
                                        PTF_DeletionDate__c = NULL AND
                                        PTF_OFS__c IN : valueOFS /*AND
                                        PTF_BloccoSpostamenti__c = false*/], 'Id', false);

        response.accMap=accMap;
        List<CRM_LinkedNDG__c> accList = [SELECT Id, CRM_Account__c, CRM_LinkCode__c, CRM_RelatedAccount__c, CRM_Status__c FROM CRM_LinkedNDG__c WHERE CRM_RelatedAccount__c IN : accMap.keySet() AND CRM_LinkCode__c IN ('113', '165') ORDER BY CRM_LinkCode__c ASC ];
        Map<String,CRM_LinkedNDG__c> accToLinkObj= new Map<String,CRM_LinkedNDG__c>();
        
        Map<String, List<SObject>> gruppoMembriMap = SV_Utilities.groupBy(accList, 'CRM_Account__c');
        Map<String, Map<String, List<Account>>> relazioneDiAccountMap = new Map<String, Map<String, List<Account>>>();
        for(CRM_LinkedNDG__c acc: accList){
            accGruppoId.add(acc.CRM_Account__c);
            accId.add(acc.CRM_RelatedAccount__c);
            accToLinkObj.put(acc.CRM_RelatedAccount__c, acc);
            if(accMap.containsKey(acc.CRM_RelatedAccount__c) && acc.CRM_LinkCode__c == '113'){

                relazioneDiAccountMap.put(acc.CRM_Account__c, new Map<String, List<Account>>{acc.CRM_RelatedAccount__c => new List<Account>()});
            }
        }
        response.accToLinkObj=accToLinkObj;

        gruppiFMap = SV_Utilities.keyBy([ SELECT Id, Name, ParentId, PTF_Gruppo__c, PTF_NaturaGiuridica__c, PTF_Portafoglio__c, 
                    PTF_Portafoglio__r.PTF_ModelloDiServizio__c, PTF_Portafoglio__r.Name, RecordType.DeveloperName,
                    Filiale__c, PTF_Filiale__c, PTF_Filiale__r.Name, CRM_NDG__c, CRM_VAT__c, PTF_GruppoGestionale__c, PTF_OFS__c
                FROM Account
                WHERE Id IN : accGruppoId AND 
                    RecordType.DeveloperName = 'GruppoFinanziario' AND 
                    PTF_DeletionDate__c = NULL ], 'Id', false);

        System.debug('DK gruppiFMap: ' + JSON.serialize(gruppiFMap));           
        response.gruppiFMap = gruppiFMap;

        for(String gruppoId : relazioneDiAccountMap.keySet()){

            for(String capoGruppoId : relazioneDiAccountMap.get(gruppoId).keySet()){

                relazioneDiAccountMap.get(gruppoId).get(capoGruppoId).add((Account)gruppiFMap.get(gruppoId));
            }
        }

        System.debug('DK relazioneDiAccountMap: ' + JSON.serialize(relazioneDiAccountMap));

        for(String gruppoId : gruppoMembriMap.keySet()){

            if(relazioneDiAccountMap.containsKey(gruppoId)){

                for(String capoGruppoId : relazioneDiAccountMap.get(gruppoId).keySet()){
                    
                    for(CRM_LinkedNDG__c linkedNdg : (List<CRM_LinkedNDG__c>)gruppoMembriMap.get(gruppoId)){
        
                        if(linkedNdg.CRM_RelatedAccount__c != capoGruppoId && accMap.containsKey(linkedNdg.CRM_RelatedAccount__c)){
    
                            relazioneDiAccountMap.get(gruppoId).get(capoGruppoId).add((Account)accMap.get(linkedNdg.CRM_RelatedAccount__c));
                            accMap.remove(linkedNdg.CRM_RelatedAccount__c);
                        }
                    }
                }
            }
        }

        Map<String, List<Account>> relazioneDiAccountMapToReturn = new  Map<String, List<Account>>();
        for(Map<String, List<Account>> relazioneMap : relazioneDiAccountMap.values()){

            for(String capoGruppo : relazioneMap.keySet()){

                relazioneDiAccountMapToReturn.put(capoGruppo, new List<Account>(relazioneMap.get(capoGruppo)));
            }
        }

        for(String accountId: accMap.keySet()){

            if(currentUser.Profilo__c == 'NEC_D.0'){

                if(!SpostaNdgIterDataLoader.checkEligibleSuperUser(portafoglioDiDestinazione, (Account)accMap.get(accountId))){
    
                    accMap.remove(accountId);
                    // relazioneDiAccountMapToReturn.remove();
                }
            }else{

                if(!checkEligible(portafoglioDiDestinazione, (Account)accMap.get(accountId), portafoglio)){
    
                    accMap.remove(accountId);
                    // relazioneDiAccountMapToReturn.remove();
                }
            }
        }

        // return response;
        return new Map<String, Object>{

            'accMap' => accMap,
            'relazioneDiAccountMap' => relazioneDiAccountMapToReturn
        };
    }

    public static Boolean checkEligible(Wallet__c portafoglio, Account ndg, Wallet__c currentPF){

        System.debug('DK PTF.ID: ' + portafoglio.Id);
        if(ndg.PTF_OFS__c){

            if(!portafoglio.Backup_Assignments__r.isEmpty() && !portafoglio.Backup_Assignments__r[0].PTF_Gestore__r.PTF_OFS__c){System.debug('ESCO QUA 4');return false;}
            // if(portafoglio.Backup_Assignments__r.isEmpty())return false;
            // if(!portafoglio.Backup_Assignments__r[0].PTF_Gestore__r.PTF_OFS__c){System.debug('ESCO QUA 5');return false;}
        }
        Map<String, ConfigurazioneSpostamenti__mdt> configurationMap;
        currentMDS = currentPF.PTF_ModelloDiServizio__c;
        currentBranchType = currentPF.PTF_Filiale__r.PTF_BranchTypeDesc__c;
        abi = currentPF.PTF_Banca__r.FinServ__BankNumber__c;
        String configurationKey = currentMDS + '_' + currentMDS + '_' + abi;
        String configurationKey2 = currentMDS + '_' + currentMDS + '_TUTTE';
        String configurationKey3 = currentMDS + '_' + currentMDS + '_' + currentBranchType + '_' + abi;
        String configurationKey4 = currentMDS + '_' + currentMDS + '_' + currentBranchType + '_TUTTE';
        if(referentiConfigurazioniMap.containsKey(configurationKey) ||
        referentiConfigurazioniMap.containsKey(configurationKey2) || 
        referentiConfigurazioniMap.containsKey(configurationKey3) || 
        referentiConfigurazioniMap.containsKey(configurationKey4)){

            configurationMap = referentiConfigurazioniMap;
        }

        if(configurationMap != null){

            String mapKey = '';
            if(configurationMap.containsKey(configurationKey3)){

                mapKey = configurationKey3;
            }else if(configurationMap.containsKey(configurationKey)){
                
                mapKey = configurationKey;
            }else if(configurationMap.containsKey(configurationKey4)){
                
                mapKey = configurationKey4;
            }else if(configurationMap.containsKey(configurationKey2)){
                
                mapKey = configurationKey2;
            }
            System.debug('DK mapKey: ' + mapKey);
            if(!String.isBlank(configurationMap.get(mapKey).PTF_CheckNaturaGiuridica__c)){
            
                List<String> naturaGiuridicaValues = new List<String>();
                Boolean isEquals = true;
                if(configurationMap.get(mapKey).PTF_CheckNaturaGiuridica__c.contains('!')){

                    isEquals = false;
                    naturaGiuridicaValues = configurationMap.get(mapKey).PTF_CheckNaturaGiuridica__c.split('!')[1].split(',');
                }else{

                    naturaGiuridicaValues = configurationMap.get(mapKey).PTF_CheckNaturaGiuridica__c.split(',');
                }
                if(isEquals){

                    if(!naturaGiuridicaValues.contains(ndg.PTF_NaturaGiuridica__c)){

                        return false;
                    }
                }else{

                    if(naturaGiuridicaValues.contains(ndg.PTF_NaturaGiuridica__c)){

                        return false;
                    }
                }
            }
            ProfiliAutorizzati profiliAutorizzati = (ProfiliAutorizzati) JSON.deserialize(configurationMap.get(mapKey).PTF_JSON_Approvatori__c, ProfiliAutorizzati.class);
            if(!profiliAutorizzati.spostamento_autorizzato_tutti){

                if(profiliAutorizzati.profili_autorizzati.containsKey(currentUser.Profilo__c)){

                    System.debug('Utente ha profilo autorizzato');
                    Set<String> keyList = new Set<String>();
                        
                    for(Map<String,String> user : profiliAutorizzati.profili_autorizzati.get(currentUser.Profilo__c).users){

                        String livelloFunzionaleFInale = !String.isBlank(user.get('livelloFunzionale')) ? user.get('livelloFunzionale') : user.get('livelloFunzionalePadre');
                        Boolean isPadre = !String.isBlank(user.get('livelloFunzionale')) ? false : true;
                        Wallet__c portafoglioFinale = user.get('direzione') == 'partenza' ? currentPF : portafoglio;
                        String IdKey;
                        String mds;
                        List<String> ruoli = !String.isBlank(user.get('PTF_RuoloLDAP__c')) ? user.get('PTF_RuoloLDAP__c').split(',') : new List<String>();
                        
                        if(isPadre){
                        
                            mds = user.containsKey('mds') ? user.get('mds') : null;
                            IdKey = livelloFunzionaleFInale == 'Filiale' ? portafoglioFinale.PTF_Filiale__r.PTF_IdCED__c :livelloFunzionaleFInale == 'MM' ? portafoglioFinale.PTF_Capofila__r.PTF_IdCED__c : livelloFunzionaleFInale == 'Area' ? portafoglioFinale.PTF_Area__r.PTF_IdCED__c : livelloFunzionaleFInale == 'DR' ? portafoglioFinale.PTF_DirezioneRegionale__r.PTF_IdCED__c : portafoglioFinale.PTF_Banca__r.PTF_IdCED__c;
                        }else{
                            
                            IdKey = livelloFunzionaleFInale == 'Filiale' ? portafoglioFinale.PTF_Filiale__c :livelloFunzionaleFInale == 'MM' ? portafoglioFinale.PTF_Capofila__c : livelloFunzionaleFInale == 'Area' ? portafoglioFinale.PTF_Area__c : livelloFunzionaleFInale == 'DR' ? portafoglioFinale.PTF_DirezioneRegionale__c : portafoglioFinale.PTF_Banca__c;
                        }

                        String division;
                        if(!String.isBlank(mds)){

                            division = servceModelMap.containsKey(mds) ? (String)servceModelMap.get(mds).get('PTF_Division__c') : (String)servceModelMap.get(mds.toUpperCase()).get('PTF_Division__c');
                        }
                        
                        if(!isPadre){
                        
                            if(!ruoli.isEmpty()){

                                for(String ruolo : ruoli){
                                    
                                    String ruoloKey = '_' + ruolo;
                                    keyList.add(currentUser.Profilo__c + ruoloKey + '_' + IdKey);
                                }
                            }else{

                                keyList.add(currentUser.Profilo__c + '_' + IdKey);
                            }
                        }else{
                            if(!ruoli.isEmpty()){
                                
                                for(String ruolo : ruoli){
                                    
                                    String ruoloKey = '_' + ruolo;
                                    if(!String.isBlank(division)){

                                        keyList.add(currentUser.Profilo__c + ruoloKey + '_' + division + '_' + IdKey);
                                    }else{

                                        keyList.add(currentUser.Profilo__c + ruoloKey + '_' + IdKey);
                                    }
                                }
                            }else{

                                if(!String.isBlank(division)){

                                    keyList.add(currentUser.Profilo__c + '_' + division + '_' + IdKey);
                                }else{

                                    keyList.add(currentUser.Profilo__c + '_' + IdKey);
                                }
                            }
                        }
                        if(currentUser.Profilo__c == 'NEC_F.1'){
                        
                            if(!String.isBlank(division)){

                                keyList.add(currentUser.Profilo__c + '_' + division + '_' + IdKey);
                            }
                            keyList.add(currentUser.Profilo__c + '_' + IdKey);
                        }
                    }
                    System.debug('DK keyList: ' + JSON.serialize(keyList));
                    if(String.isBlank(currentContact.AccountId)){

                        System.debug('ESCO 1');
                        return false;
                    }
                    if(!keyList.contains(currentUser.Profilo__c + '_' + currentUser.PTF_RuoloLDAP__c + '_' + currentContact.AccountId) &&
                        !keyList.contains(currentUser.Profilo__c + '_' + currentContact.Account.PTF_IdCEDPadre__c) &&
                        !keyList.contains(currentUser.Profilo__c + '_' + currentUser.PTF_RuoloLDAP__c + '_' + currentContact.Account.PTF_IdCEDPadre__c) &&
                        !keyList.contains(currentUser.Profilo__c + '_' + currentContact.Account.PTF_Division__c + '_' + currentContact.Account.PTF_IdCEDPadre__c) &&
                        !keyList.contains(currentUser.Profilo__c + '_' + currentUser.PTF_RuoloLDAP__c + '_' + currentContact.Account.PTF_Division__c + '_' + currentContact.Account.PTF_IdCEDPadre__c) &&
                        !keyList.contains(currentUser.Profilo__c) &&
                        !keyList.contains(currentUser.Profilo__c + '_' + currentContact.AccountId)){

                        // throw "Non Puoi eseguire questo tipo di spostamento!!";
                        System.debug('ESCO 2');
                        return false;
                    }
                }else{

                    System.debug('ESCO 3');
                    return false;
                }
            }
        }

        System.debug('ESCO 4');
        return true;
    }

    @AuraEnabled
    public static Map<String,Object> loadMwList(String filiale, String modelloDiServizio, String nome, String portafoglio, Integer offset, Integer pagesize){
        
        String searchedName = '%' + nome + '%';
        String countQuery = '';
        String query = '';
        String userId = UserInfo.getUserId();
        List<String> condiionList = new List<String>();
        //check if cognome filter is activated
        //filter on Name is always set because nome field is required for Accounts

        System.debug('DK loadMwList portafoglio: ' + portafoglio);
        System.debug('DK loadMwList filiale: ' + filiale);
        System.debug('DK loadMwList modelloDiServizio: ' + modelloDiServizio);

        countQuery = 'SELECT count() ' + 
                'FROM Wallet__c WHERE Id !=: portafoglio AND PTF_Filiale__c =: filiale AND PTF_ModelloDiServizio__c =: modelloDiServizio AND RecordType.DeveloperName = \'MicroWallet\' AND PTF_DeletionDate__c=null';

        // query = 'SELECT Id, Name, PTF_ModelloDiServizio__c, PTF_Filiale__r.Name, Owner.Name ' +
                // 'FROM Wallet__c WHERE Id !=: portafoglio AND PTF_Filiale__c =: filiale AND PTF_ModelloDiServizio__c =: modelloDiServizio AND RecordType.DeveloperName = \'MicroWallet\' AND PTF_DeletionDate__c=null';
        query = 'SELECT Id, Name, PTF_ModelloDiServizio__c, PTF_UffPrivate__c, PTF_Filiale__r.PTF_UffPrivate__c, PTF_Filiale__r.PTF_IDCEDUffPrivate__c, PTF_Filiale__r.PTF_UffPrivate__r.PTF_IdCedPadre__c,' + 
                'PTF_Filiale__c, PTF_Filiale__r.PTF_BranchTypeDesc__c, PTF_Filiale__r.PTF_BranchTypologyMap__c, PTF_Filiale__r.Name, PTF_FIliale__r.PTF_IdCed__c, PTF_Capofila__c, PTF_Capofila__r.PTF_IdCed__c,' + 
                'PTF_Banca__c, PTF_Banca__r.FinServ__BankNumber__c, PTF_Banca__r.PTF_DowngradeReqStartDate__c, PTF_Banca__r.PTF_DowngradeReqEndDate__c, PTF_Banca__r.PTF_IdCed__c,' + 
                'PTF_DirezioneRegionale__r.PTF_IdCed__c, PTF_Area__r.PTF_IdCed__c, PTF_DirezioneRegionale__c, PTF_Area__c, Owner.Name, PTF_Fatturato__c, PTF_Patrimonio__c, PTF_Utilizzato__c, PTF_Accordato__c,' + 
                'PTF_DirezioneRegionale__r.PTF_DowngradeReqStartDate__c, PTF_DirezioneRegionale__r.PTF_DowngradeReqEndDate__c, PTF_Pool__c, PTF_Filiale__r.PTF_DowngradeReqStartDate__c, PTF_Filiale__r.PTF_DowngradeReqEndDate__c,' + 
                '(SELECT id, PTF_Gestore__c, PTF_Gestore__r.PTF_OFS__c, PTF_Gestore__r.Name FROM Backup_Assignments__r WHERE RecordType.DeveloperName = \'Primario\' AND PTF_EndDate__c = null)' + 
                'FROM Wallet__c WHERE Id !=: portafoglio AND PTF_Filiale__c =: filiale AND PTF_ModelloDiServizio__c =: modelloDiServizio AND RecordType.DeveloperName = \'MicroWallet\' AND PTF_DeletionDate__c=null';
        if(!String.isBlank(nome)){

            condiionList.add(' Name =: nome ');
        }
        if(!condiionList.isEmpty()){

            countQuery += ' AND ' + String.join(condiionList, ' AND ');
            query += ' AND ' + String.join(condiionList, ' AND ');
        }
        query += ' ORDER BY Name ASC LIMIT: pagesize OFFSET: offset';

        List<Wallet__c> mwListX = Database.query(query);
        Set<Id> mwIds = new Set<Id>();
        for(Wallet__c w : mwListX){
            mwIds.add(w.Id);
        }

        Map<String, SObject> referentiMap = SV_Utilities.keyBy([SELECT Id, Name, PTF_Gestore_Name__c, PTF_MicroWallet__c, RecordType.DeveloperName 
                                                                FROM Assignment__c 
                                                                WHERE RecordType.DeveloperName = 'Primario' AND 
                                                                      PTF_MicroWallet__c IN : mwIds AND
                                                                      PTF_EndDate__c = null], 'PTF_MicroWallet__c', false);



        return new Map<String, Object>{
            'mwListCount' => Database.countQuery(countQuery),
            'mwList' => mwListX,
            'referenti' => referentiMap
        };
    }

    @AuraEnabled
    public static void moveNdgsToWallet(String portafoglio, List<String> ndgIdList){

        List<Account> accountListToupdate = new List<Account>();
        
        for(String ndgId : ndgIdList){

            accountListToupdate.add(new Account(id = ndgId, PTF_Portafoglio__c = portafoglio));
        }

        System.debug('DK accountListToupdate: ' + JSON.serialize(accountListToupdate));
        if(!accountListToupdate.isEmpty()){

            update accountListToupdate;
        }
    }

    @AuraEnabled
    public static Map<String,Object> getLogicaApprovazione(String portafoglioDestizioneId, String portafoglioPartenzaId){
        System.debug('SV portafoglioDestizioneId ' + portafoglioDestizioneId);
        System.debug('SV portafoglioPartenzaId ' + portafoglioPartenzaId);

        Map<String, SObject> walletMap = SV_Utilities.keyBy([ SELECT Id, Name, PTF_ModelloDiServizio__c, PTF_Filiale__r.Name, Owner.Name
                    FROM Wallet__c
                    WHERE Id =: portafoglioDestizioneId OR Id =: portafoglioPartenzaId], 'Id', false);
            System.debug('DK walletMap: ' + walletMap);

            String MDS_Start = (String)walletMap.get(portafoglioPartenzaId).get('PTF_ModelloDiServizio__c');
            String MDS_End = (String)walletMap.get(portafoglioDestizioneId).get('PTF_ModelloDiServizio__c');
            

            Map<String, Object> mtdApprovazioneMap = SV_Utilities.keyBy([ SELECT Id, PTF_MDS_End__c, PTF_MDS_Start__c
                    FROM ConfigurazioneSpostamenti__mdt
                    WHERE PTF_MDS_Start__c =: MDS_Start AND
                     PTF_MDS_End__c =: MDS_End ], 'Id', false);

        return mtdApprovazioneMap;
        
    }


    /*..........................................*/
    /* Wrapper class to display Position       */
    /*.........................................*/
    
    public class WrapperObj {

        @AuraEnabled public Map<String, SObject> accMap;
        @AuraEnabled public Map<String, SObject> gruppiFMap;
        @AuraEnabled public Map<String, CRM_LinkedNDG__c> accToLinkObj;

    }

    public class ProfiliAutorizzati{

        Boolean spostamento_autorizzato_tutti{get;set;}
        Map<String, ProfiloObject> profili_autorizzati{get;set;}
    }

    public class ProfiloObject{

        List<Map<String,String>> users{get;set;}
    }
}