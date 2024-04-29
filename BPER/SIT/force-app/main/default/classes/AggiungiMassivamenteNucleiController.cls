public without sharing class AggiungiMassivamenteNucleiController {
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

        Wallet__c currentPF = [SELECT Id, Name, PTF_ModelloDiServizio__c,
        PTF_Filiale__c, PTF_Filiale__r.PTF_BranchTypeDesc__c, PTF_Filiale__r.PTF_BranchTypologyMap__c, PTF_Filiale__r.Name, PTF_FIliale__r.PTF_IdCed__c, PTF_Capofila__c, PTF_Capofila__r.PTF_IdCed__c,
        PTF_Banca__c, PTF_Banca__r.FinServ__BankNumber__c, PTF_Banca__r.PTF_DowngradeReqStartDate__c, PTF_Banca__r.PTF_DowngradeReqEndDate__c, PTF_Banca__r.PTF_IdCed__c,
        PTF_DirezioneRegionale__r.PTF_IdCed__c, PTF_Area__r.PTF_IdCed__c, PTF_DirezioneRegionale__c, PTF_Area__c, Owner.Name, PTF_Fatturato__c, PTF_Patrimonio__c, PTF_Utilizzato__c, PTF_Accordato__c,
        PTF_DirezioneRegionale__r.PTF_DowngradeReqStartDate__c, PTF_DirezioneRegionale__r.PTF_DowngradeReqEndDate__c, PTF_Pool__c, PTF_Filiale__r.PTF_DowngradeReqStartDate__c, PTF_Filiale__r.PTF_DowngradeReqEndDate__c,
        PTF_Filiale__r.PTF_BloccaSpostamentiFiliale__c, PTF_Filiale__r.PTF_BloccaSpostamentiInFiliale__c,
        (SELECT id, PTF_Gestore__c, PTF_Gestore__r.PTF_OFS__c, PTF_Gestore__r.Name FROM Backup_Assignments__r WHERE RecordType.DeveloperName = 'Primario' AND PTF_EndDate__c = null)
        FROM Wallet__c WHERE Id =: recordId AND RecordType.developerName != 'TechnicalWallet' AND (NOT Name LIKE '%999')];
        currentMDS = currentPF.PTF_ModelloDiServizio__c;
        currentBranchType = currentPF.PTF_Filiale__r.PTF_BranchTypeDesc__c;
        abi = currentPF.PTF_Banca__r.FinServ__BankNumber__c;

        // User currentUser = [SELECT Id, Profile.Name FROM User WHERE id =: UserInfo.getUserId()];

        // Contact currentContact = [SELECT id, Name, PTF_TipologiaRuolo__r.Name FROM Contact WHERE PTF_User__c =: UserInfo.getUserId() LIMIT 1];
        if(currentPF.PTF_Filiale__r.PTF_BloccaSpostamentiFiliale__c ||
            currentPF.PTF_Filiale__r.PTF_BloccaSpostamentiInFiliale__c){
            String errorMessage = 'Lo spostamento di questo NDG è momentaneamente bloccato dalla Filiale.';
            return new Map<String,Object> {
    
                'errorMessage' => errorMessage
            };
        }else{

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
    public static Map<String,Object> loadNdgList(Wallet__c portafoglio, string nome,  String ndg, Integer offset, Integer pagesize, Wallet__c portafoglioDiDestinazione){
        
        String searchedName =  nome ; 
        String searchedNdg =  ndg ;
        String countQuery = '';
        String queryPort = '';
        String mwId = portafoglio.Id;
        String userId = UserInfo.getUserId();
        List<String> condiionList = new List<String>();



        //check if cognome filter is activated
        //filter on Name is always set because nome field is required for Accounts
        countQuery = 'SELECT count() ' + 
                'FROM Account WHERE PTF_Portafoglio__c =: mwId AND PTF_BloccoSpostamenti__c = false';

        queryPort = 'SELECT Id, PTF_Patrimonio__c, PTF_Utilizzato__c, PTF_Nucleo__c, Filiale__c, PTF_Caponucleo__c, CRM_NDG__c, Name, PTF_Filiale__c, PTF_Filiale__r.Name, ModelloDiServizio__c, PTF_Portafoglio__c, PTF_Portafoglio__r.Name, PTF_NaturaGiuridica__c, PTF_GruppoGestionale__c, PTF_OFS__c ' +
                'FROM Account WHERE PTF_Portafoglio__c =: mwId AND PTF_BloccoSpostamenti__c = false';
        /*
        if(!String.isBlank(nome)){

            condiionList.add(' Name =: searchedName ');
        }
        
        if(!String.isBlank(ndg)){

            condiionList.add(' CRM_NDG__c =: searchedNDG ');
        }
        if(!condiionList.isEmpty()){

            countQuery += ' AND ' + String.join(condiionList, ' AND ');
            queryPort += ' AND ' + String.join(condiionList, ' AND ');
        }*/
        queryPort += ' ORDER BY PTF_Caponucleo__c';



        List<Account> portList= Database.query(queryPort);

        List<Account> parentList= new List<Account>();
        List<String> parentId= new List<String>();
        List<Account> orfanList= new List<Account>();
        List<Account> ndgList= new List<Account>();
        List<String> nucleiId = new List<String>();
        Set<String> nucleiOFS = new Set<String>();
        for(Account a:portList){
            If(a.PTF_Caponucleo__c ){
                nucleiId.add(a.PTF_Nucleo__c);
                if(a.PTF_OFS__c) nucleiOFS.add(a.PTF_Nucleo__c);
                parentList.add(a);
            }
        }

        for(Account a:portList){
                If(!a.PTF_Caponucleo__c ){
                    orfanList.add(a);
                }
            
            
        }

            List<Account> childList=[SELECT Id, PTF_Patrimonio__c, PTF_Utilizzato__c, PTF_Nucleo__c, Filiale__c, PTF_Caponucleo__c, CRM_NDG__c, Name, PTF_Filiale__c, PTF_Filiale__r.Name, ModelloDiServizio__c, PTF_Portafoglio__c, PTF_Portafoglio__r.Name, PTF_NaturaGiuridica__c, PTF_GruppoGestionale__c, PTF_OFS__c
                                FROM Account WHERE PTF_Nucleo__c IN:nucleiId AND PTF_Caponucleo__c=false AND PTF_Portafoglio__c =: mwId  AND PTF_DeletionDate__c = NULL AND PTF_BloccoSpostamenti__c = false];
        
         
         List<String> parentListId= new List<String>();
         if(parentList.size()>0) {
             for(Account a:parentList){
                ndgList.add(a);
                parentListId.add(a.Id);
                for(Account acc:childList){
                    if(acc.PTF_Nucleo__c==a.PTF_Nucleo__c){
                        ndgList.add(acc);
                    }
                }

             }
            
         }  
         
         List<String> childListId= new List<String>();
         if(childList.size()>0) {
             for(Account a:childList){
                childListId.add(a.Id);
                if(a.PTF_OFS__c) nucleiOFS.add(a.PTF_Nucleo__c);
             }
            
         }
         
         
         
         if(orfanList.size()>0) {
            ndgList.addAll(orfanList);
         }

         for(Integer i=0; i<ndgList.size(); i++){
            if(currentUser.Profilo__c == 'NEC_D.0'){

                if(!SpostaNdgIterDataLoader.checkEligibleSuperUser(portafoglioDiDestinazione, ndgList[i])){

                    ndgList.remove(i);
                }
            }else{

                if(!checkEligible(portafoglioDiDestinazione, ndgList[i], portafoglio)){
    
                    ndgList.remove(i);
                }
            }
         }




         Set<Account> ndgSet= new Set<Account>(ndgList);
         List<Account> ndgListnoDup = new List<Account>(ndgSet);

        
        
        

        return new Map<String, Object>{
            'ndgListCount' => ndgListnoDup.size(),
            'ndgList' => ndgListnoDup,
            'nuclei'=>nucleiId,
            'nucleiOFS'=>nucleiOFS,
            'parentList'=> parentListId,
            'childList'=>childListId
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
    public static Map<String,Object> loadMwList(String filiale, String modelloDiServizio, String nome, String portafoglio, Integer offset, Integer pagesize, List<String> recordType){
        
        String searchedName = '%' + nome + '%';
        String countQuery = '';
        String query = '';
        String userId = UserInfo.getUserId();
        List<String> condiionList = new List<String>();
        //check if cognome filter is activated
        //filter on Name is always set because nome field is required for Accounts
        List<Id> recordTypes= new List<Id>();
        for(String rt:recordType){
            Id recordTypeId = Schema.SObjectType.Wallet__c.getRecordTypeInfosByDeveloperName().get(rt).getRecordTypeId();
            recordTypes.add(recordTypeId);
        }
        

        countQuery = 'SELECT count() ' + 
                'FROM Wallet__c WHERE Id !=: portafoglio AND PTF_Filiale__c =: filiale AND PTF_ModelloDiServizio__c =: modelloDiServizio AND RecordTypeId NOT IN: recordTypes AND PTF_DeletionDate__c=null AND (NOT Name LIKE \'%999\')';

        query = 'SELECT Id, Name, PTF_ModelloDiServizio__c,' + 
        'PTF_Filiale__c, PTF_Filiale__r.PTF_BranchTypeDesc__c, PTF_Filiale__r.PTF_BranchTypologyMap__c, PTF_Filiale__r.Name, PTF_FIliale__r.PTF_IdCed__c, PTF_Capofila__c, PTF_Capofila__r.PTF_IdCed__c,' + 
        'PTF_Banca__c, PTF_Banca__r.FinServ__BankNumber__c, PTF_Banca__r.PTF_DowngradeReqStartDate__c, PTF_Banca__r.PTF_DowngradeReqEndDate__c, PTF_Banca__r.PTF_IdCed__c,' + 
        'PTF_DirezioneRegionale__r.PTF_IdCed__c, PTF_Area__r.PTF_IdCed__c, PTF_DirezioneRegionale__c, PTF_Area__c, Owner.Name, PTF_Fatturato__c, PTF_Patrimonio__c, PTF_Utilizzato__c, PTF_Accordato__c,' + 
        'PTF_DirezioneRegionale__r.PTF_DowngradeReqStartDate__c, PTF_DirezioneRegionale__r.PTF_DowngradeReqEndDate__c, PTF_Pool__c, PTF_Filiale__r.PTF_DowngradeReqStartDate__c, PTF_Filiale__r.PTF_DowngradeReqEndDate__c,' + 
        '(SELECT id, PTF_Gestore__c, PTF_Gestore__r.PTF_OFS__c, PTF_Gestore__r.Name FROM Backup_Assignments__r WHERE RecordType.DeveloperName = \'Primario\' AND PTF_EndDate__c = null)' + 
        'FROM Wallet__c WHERE Id !=: portafoglio AND PTF_Filiale__c =: filiale AND PTF_ModelloDiServizio__c =: modelloDiServizio AND RecordTypeId NOT IN: recordTypes AND PTF_DeletionDate__c=null AND (NOT Name LIKE \'%999\')';

        if(!String.isBlank(nome)){

            condiionList.add(' Name LIKE: searchedName ');
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
    public static void moveNdgsToWallet(String portafoglio, List<String> ndgIdList, String portafogliopartenza){
        
        Id primario= Schema.SObjectType.Assignment__c.getRecordTypeInfosByDeveloperName().get('Primario').getRecordTypeId();

        List<Wallet__c> wal =[SELECT Id, PTF_Filiale__c FROM Wallet__c WHERE Id=:portafoglio AND (NOT Name LIKE '%999')];
        Map<String, SObject> referentiMap =SV_Utilities.keyBy([SELECT PTF_Gestore__c, PTF_MicroWallet__c FROM Assignment__c WHERE (PTF_MicroWallet__c=:portafoglio OR PTF_MicroWallet__c=:portafogliopartenza) AND RecordTypeId=:primario AND PTF_EndDate__c=null ]
                                                                , '{PTF_Gestore__c}_{PTF_MicroWallet__c}', true);
        List<String> referentiMapKeyList = new List<String>(referentiMap.keySet());
        
        //Se Cambia il Referente
        if(referentiMapKeyList.size()<2 || (referentiMapKeyList[0].split('_')[0] != referentiMapKeyList[1].split('_')[0] )){

            handleChangeReferente(portafoglio, ndgIdList, portafogliopartenza);

        }

        Set<Account> accountSetToupdate = new Set<Account>();
        for(String ndgId : ndgIdList){

            accountSetToupdate.add(new Account(id = ndgId, PTF_Portafoglio__c = portafoglio, PTF_Filiale__c=wal[0].PTF_Filiale__c));
        }
        List<Account> accountListToupdate = new List<Account>(accountSetToupdate);

        System.debug('DK accountListToupdate: ' + JSON.serialize(accountListToupdate));
        if(!accountListToupdate.isEmpty()){

            update accountListToupdate;
        }
        
    }

    private static void handleChangeReferente(String portafoglio, List<String> ndgIdList, String portafogliopartenza){

        Set<String> ndgIdSet = new Set<String> (ndgIdList);
        List<Account> ndgList =[SELECT Id, PTF_Nucleo__c, PTF_Caponucleo__c FROM Account Where Id IN:ndgIdSet];//Lista di tutti gli NDG da spostare
        Map<String,List<Account>> mapNucleoListNDG = new Map<String,List<Account>>(); // Mappa Nucleo e Account da spostare appartenenti a quel Nucleo 
        for(Account a:ndgList){

            if(String.isNotBlank(a.PTF_Nucleo__c)){
                
                if(mapNucleoListNDG.containsKey(a.PTF_Nucleo__c)){
                    List<Account> listAcc=mapNucleoListNDG.get(a.PTF_Nucleo__c);
                    listAcc.add(a);
                    mapNucleoListNDG.put(a.PTF_Nucleo__c,listAcc);
                }
                else{
                    List<Account> listAcc = new List<Account>();
                    listAcc.add(a);
                    mapNucleoListNDG.put(a.PTF_Nucleo__c,listAcc);
                }

            }

        }
        List<Account> ndgTotList =[SELECT Id, PTF_Nucleo__c, PTF_Caponucleo__c FROM Account Where PTF_Nucleo__c IN:mapNucleoListNDG.keySet()]; //Lista di tutti gli account appartenenti ai Nuclei degli NDG da spostare
        Map<String,List<Account>> mapNucleoTotListNDG = new Map<String,List<Account>>(); // Mappa Nucleo e Account appartenenti a quel Nucleo 

        for(Account a:ndgTotList){
            if(String.isNotBlank(a.PTF_Nucleo__c)){

                if(mapNucleoTotListNDG.containsKey(a.PTF_Nucleo__c)){

                    List<Account> listAcc=mapNucleoTotListNDG.get(a.PTF_Nucleo__c);
                    listAcc.add(a);
                    mapNucleoTotListNDG.put(a.PTF_Nucleo__c,listAcc);

                }
                else{
                    List<Account> listAcc = new List<Account>();
                    listAcc.add(a);
                    mapNucleoTotListNDG.put(a.PTF_Nucleo__c,listAcc);
                }

            }
        }


        //Confronto le due Mappe
        Integer nucleiDaCreare= 0;
        List<Account> nucleiMinimi = new List<Account> ();
        List<List<Account>> nucleiComposti= new List<List<Account>>();
        List<String> nucleiToDeleteId= new List<String>();
        for(String nucleo: mapNucleoListNDG.keySet()){
            List<Account> listAcc = mapNucleoListNDG.get(nucleo);
            List<Account> totListAcc = mapNucleoTotListNDG.get(nucleo);
            
            //Se non sposto tutto il Nucleo
           if(listAcc.size()<totListAcc.size()){
                Boolean CPN= false; //Booleano che indica se tra gli account di questo Nucleo c'è il caponucleo
                for(Account a:listAcc){
                    if(a.PTF_Caponucleo__c) {
                        CPN = true;
                        break;
                    }
                }
                if(CPN && listAcc.size()==1){
                    nucleiToDeleteId.add(nucleo);
                    nucleiDaCreare=nucleiDaCreare+totListAcc.size();
                    nucleiMinimi.addAll(totListAcc);
                    //Devo creare n Nuclei Minimi dove n è listAcc.size()

                }
                if(CPN && listAcc.size()>1){
                    nucleiToDeleteId.add(nucleo);
                    nucleiComposti.add(listAcc);
                    nucleiDaCreare=nucleiDaCreare+1;
                    for(Account acc:totListAcc){
                        if(!listAcc.contains(acc)){
                            nucleiDaCreare=nucleiDaCreare+1;
                            nucleiMinimi.add(acc);
                        }
                    }
                    //Devo creare un Nucleo composto e ed n nuclei minimi dove n è la differenza tra listAccTot.size() e listAcc.size()

                }
                if(!CPN){
                    nucleiDaCreare=nucleiDaCreare+listAcc.size();
                    nucleiMinimi.addAll(listAcc);
                    //Devo creare n Nuclei Minimi dove n è listAcc.size() 
                }

            }
        }
        handleSave(nucleiDaCreare, nucleiMinimi, nucleiComposti, nucleiToDeleteId);

            


    }

    private static void handleSave(Integer nucleiDaCreare, List<Account> nucleiMinimi, List<List<Account>> nucleiComposti,  List<String> nucleiToDeleteId){

        List<Nucleo__c> listNucleiDaCreare= new List<Nucleo__c>();
        List<Account> listAccountToUpdate = new List<Account>();
        
        
            for(Integer i=0; i<nucleiDaCreare; i++){
                Nucleo__c nuc = new Nucleo__c();
                listNucleiDaCreare.add(nuc);
            }
    
            insert listNucleiDaCreare;
    
            for(Integer i=0; i<nucleiMinimi.size(); i++){
                nucleiMinimi[i].PTF_Nucleo__c=listNucleiDaCreare[i].Id;
                nucleiMinimi[i].PTF_Caponucleo__c=true;
                listAccountToUpdate.add(nucleiMinimi[i]);
            }
    
            for(Integer i=0; i<nucleiComposti.size(); i++){
                List<Account> accountNucleoComposto =nucleiComposti[i];
                for(Account a:accountNucleoComposto){
                    a.PTF_Nucleo__c=listNucleiDaCreare[i+nucleiMinimi.size()].Id;
                    listAccountToUpdate.add(a);
                }
            }
    
            update listAccountToUpdate;
            
            List<Nucleo__c> nucleiToDelete= new List<Nucleo__c>();
            for(String nucleoId:nucleiToDeleteId){
                nucleiToDelete.add(new Nucleo__c(Id=nucleoId));
            }
    
            delete nucleiToDelete;
        
        
        

    }

    public class ProfiliAutorizzati{

        Boolean spostamento_autorizzato_tutti{get;set;}
        Map<String, ProfiloObject> profili_autorizzati{get;set;}
    }

    public class ProfiloObject{

        List<Map<String,String>> users{get;set;}
    }
}