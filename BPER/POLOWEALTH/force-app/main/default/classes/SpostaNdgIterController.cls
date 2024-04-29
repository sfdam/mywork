public without sharing class SpostaNdgIterController {
    public virtual class BaseException extends Exception {}

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

    public static Account filialeCurrentUser{
        get{
            if(filialeCurrentUser != null) return filialeCurrentUser;

            List<Account> filialeCurrentUserList = [SELECT Id, PTF_BloccaSpostamentiInFiliale__c, PTF_BloccaSpostamentiVersoFiliale__c, PTF_BloccaSpostamentiFiliale__c FROM Account WHERE PTF_idCed__c =: currentUser.idCed__c AND RecordTypeName__c IN ('Filiale di relazione', 'Area', 'Altra Unità Organizzativa', 'Banca', 'Direzione Territoriale') LIMIT 1];
            if(!filialeCurrentUserList.isEmpty()){
                filialeCurrentUser = filialeCurrentUserList[0];
            }else if(currentUser.Profile.Name == label.System_Administrator){
                filialeCurrentUser = new Account(
                    PTF_BloccaSpostamentiInFiliale__c = false,
                    PTF_BloccaSpostamentiVersoFiliale__c = false,
                    PTF_BloccaSpostamentiFiliale__c = false
                );
            }
            return filialeCurrentUser;
        }set;
    }

    @AuraEnabled
    public static Contact currentContact{

        get{

            if(currentContact != null){

                return currentContact;
            }
            List<Contact> currentContactList = [SELECT Id, PTF_User__c, AccountId, Account.PTF_IdCed__c, Account.PTF_IdCEDPadre__c, Account.PTF_Division__c, Account.PTF_MacroDivision__c FROM Contact WHERE PTF_User__c =: UserInfo.getUserId() AND AccountId != '' ORDER BY CreatedDate DESC LIMIT 1];
            currentContact = new Contact();
            if(!currentContactList.isEmpty()){

                currentContact = currentContactList[0];
            }
            return currentContact;
        }set;
    }

    public static Set<String> mdsToAvoid = new Set<String>{'Residuale', 'Non Portafogliati'};

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

    public static String currentBranchTypeDesc{get;set;}
    public static String currentMDS{get;set;}
    public static Set<String> branchEligible = new Set<String>();
    @AuraEnabled
    public static String ruolo {get;set;}
    public static String mdsPrimario {get;set;}
    public static String mdsCo {get;set;}
    public static String filialePrimario {get;set;}
    public static Boolean hasDifferent {get;set;}
    
    public static Map<String, Boolean> eligibleIterMap = new Map<String, Boolean>();
    public static Map<String, Set<String>> iterKeyListMap = new Map<String, Set<String>>();

    public static List<String> modelloDiServizioList{
        get{

            if(modelloDiServizioList != null){

                return modelloDiServizioList;
            }
            
            modelloDiServizioList = new List<String>();
            Map<String, Schema.SObjectField> walletFieldMap = Wallet__c.getSObjectType().getDescribe().fields.getMap();
            List<Schema.PicklistEntry> picklistValues = walletFieldMap.get('PTF_ModelloDiServizio__c').getDescribe().getPickListValues();
            for (Schema.PicklistEntry a : picklistValues) { //for all values in the picklist list
                
                if(!mdsToAvoid.contains(a.getValue())){

                    modelloDiServizioList.add(a.getValue());//add the value  to our final list
                }
            }

            return modelloDiServizioList;
        }set;
    }

    @AuraEnabled
    public static Map<String, ConfigurazioneSpostamenti__mdt> mdsConfigurazioniMap{

        get{

            if(mdsConfigurazioniMap != null){

                return mdsConfigurazioniMap;
            }

            mdsConfigurazioniMap = new Map<String, ConfigurazioneSpostamenti__mdt>();
            for(ConfigurazioneSpostamenti__mdt configurazione : [ SELECT Id, MasterLabel, PTF_MDS_End__c, PTF_MDS_Start__c,
                                                                PTF_Abi__c, Finestra_Temporale__c, Iter_Approvativo__c,
                                                                PTF_Filiale_End__c, PTF_Filiale_Start__c, PTF_JSON_Approvatori__c, PTF_StessoReferente__c,
                                                                PTF_CheckNaturaGiuridica__c, PTF_CheckCedSpecifico__c, PTF_CheckTipologiaFilialeDestinazione__c, PTF_CheckTipologiaFilialePartenza__c, Tipo_di_Spostamento__c
                                                                ,PTF_SuperUsers__c, Check_SegComp__c
                                                                FROM ConfigurazioneSpostamenti__mdt
                                                                WHERE Tipo_di_Spostamento__c = 'MDS' AND
                                                                (PTF_MDS_Start__c =: currentMDS OR PTF_MDS_Start__c = '')AND
                                                                PTF_IsActive__c = true]){
                
                if(!String.isBlank(configurazione.PTF_MDS_Start__c) && !String.isBlank(configurazione.PTF_MDS_End__c)){
                    
                    if(String.isBlank(configurazione.PTF_CheckTipologiaFilialePartenza__c) && String.isBlank(configurazione.PTF_CheckTipologiaFilialeDestinazione__c)){

                        mdsConfigurazioniMap.put(configurazione.PTF_MDS_Start__c + '_' + configurazione.PTF_MDS_End__c + '_' + configurazione.PTF_Abi__c, configurazione);
                    }else{

                        for(String tipologiaFilialePartenza : configurazione.PTF_CheckTipologiaFilialePartenza__c.split(',')){
    
                            for(String tipologiaFilialeDestinazione : configurazione.PTF_CheckTipologiaFilialeDestinazione__c.split(',')){
    
                                if(!mdsConfigurazioniMap.containsKey(configurazione.PTF_MDS_Start__c + '_' + configurazione.PTF_MDS_End__c + '_' + tipologiaFilialePartenza + '_' + tipologiaFilialeDestinazione + '_' + configurazione.PTF_Abi__c) &&
                                !mdsConfigurazioniMap.containsKey(configurazione.PTF_MDS_Start__c + '_' + configurazione.PTF_MDS_End__c + '_' + tipologiaFilialePartenza + '_' + tipologiaFilialeDestinazione + '_TUTTE')){
    
                                    mdsConfigurazioniMap.put(configurazione.PTF_MDS_Start__c + '_' + configurazione.PTF_MDS_End__c + '_' + tipologiaFilialePartenza + '_' + tipologiaFilialeDestinazione + '_' + configurazione.PTF_Abi__c, configurazione);
                                }
                            }
                        }
                    }

                }else{

                    if(String.isBlank(configurazione.PTF_MDS_Start__c)){

                        // System.debug('DK MasterLabel: ' + configurazione.MasterLabel);
                        for(String mdsStart : modelloDiServizioList){
                            
                            if(mdsStart != 'Assente'){
                                
                                if(String.isBlank(configurazione.PTF_CheckTipologiaFilialePartenza__c) && String.isBlank(configurazione.PTF_CheckTipologiaFilialeDestinazione__c)){
                                    
                                    if(mdsStart != configurazione.PTF_MDS_End__c){
        
                                        if(!mdsConfigurazioniMap.containsKey(mdsStart + '_' + configurazione.PTF_MDS_End__c + '_' + configurazione.PTF_Abi__c) &&
                                        !mdsConfigurazioniMap.containsKey(mdsStart + '_' + configurazione.PTF_MDS_End__c + '_TUTTE')){
        
                                            mdsConfigurazioniMap.put(mdsStart + '_' + configurazione.PTF_MDS_End__c + '_' + configurazione.PTF_Abi__c, configurazione);
                                        }
                                    }
                                }else{
    
                                    for(String tipologiaFilialePartenza : configurazione.PTF_CheckTipologiaFilialePartenza__c.split(',')){
                                        
                                        for(String tipologiaFilialeDestinazione : configurazione.PTF_CheckTipologiaFilialeDestinazione__c.split(',')){
                                            
                                            // System.debug('DK mdsConfigurazioniMap_KEYMAP: ' + mdsStart + '_' + configurazione.PTF_MDS_End__c + '_' + tipologiaFilialePartenza + '_' + tipologiaFilialeDestinazione + '_' + configurazione.PTF_Abi__c);
                                            if(!mdsConfigurazioniMap.containsKey(mdsStart + '_' + configurazione.PTF_MDS_End__c + '_' + tipologiaFilialePartenza + '_' + tipologiaFilialeDestinazione + '_' + configurazione.PTF_Abi__c) &&
                                            !mdsConfigurazioniMap.containsKey(mdsStart + '_' + configurazione.PTF_MDS_End__c + '_' + tipologiaFilialePartenza + '_' + tipologiaFilialeDestinazione + '_TUTTE')){
                
                                                mdsConfigurazioniMap.put(mdsStart + '_' + configurazione.PTF_MDS_End__c + '_' + tipologiaFilialePartenza + '_' + tipologiaFilialeDestinazione + '_' + configurazione.PTF_Abi__c, configurazione);
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }else{

                        for(String mdsEnd : modelloDiServizioList){

                            if(mdsEnd != 'Assente'){

                                if(String.isBlank(configurazione.PTF_CheckTipologiaFilialePartenza__c) && String.isBlank(configurazione.PTF_CheckTipologiaFilialeDestinazione__c)){
    
                                    if(configurazione.PTF_MDS_Start__c != mdsEnd){
                                    
                                        if(!mdsConfigurazioniMap.containsKey(configurazione.PTF_MDS_Start__c + '_' + mdsEnd + '_' + configurazione.PTF_Abi__c) &&
                                        !mdsConfigurazioniMap.containsKey(configurazione.PTF_MDS_Start__c + '_' + mdsEnd + '_TUTTE')){
        
                                            mdsConfigurazioniMap.put(configurazione.PTF_MDS_Start__c + '_' + mdsEnd + '_' + configurazione.PTF_Abi__c, configurazione);
                                        }
                                    }
                                }else{
    
                                    for(String tipologiaFilialePartenza : configurazione.PTF_CheckTipologiaFilialePartenza__c.split(',')){
        
                                        for(String tipologiaFilialeDestinazione : configurazione.PTF_CheckTipologiaFilialeDestinazione__c.split(',')){
                
                                            if(!mdsConfigurazioniMap.containsKey(configurazione.PTF_MDS_Start__c + '_' + mdsEnd + '_' + tipologiaFilialePartenza + '_' + tipologiaFilialeDestinazione + '_' + configurazione.PTF_Abi__c )&&
                                            !mdsConfigurazioniMap.containsKey(configurazione.PTF_MDS_Start__c + '_' + mdsEnd + '_' + tipologiaFilialePartenza + '_' + tipologiaFilialeDestinazione + '_TUTTE')){
                
                                                mdsConfigurazioniMap.put(configurazione.PTF_MDS_Start__c + '_' + mdsEnd + '_' + tipologiaFilialePartenza + '_' + tipologiaFilialeDestinazione + '_' + configurazione.PTF_Abi__c, configurazione);
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
            return mdsConfigurazioniMap;
        }set;
    }

    @AuraEnabled
    public static Map<String, ConfigurazioneSpostamenti__mdt> filialeConfigurazioniMap{

        get{

            if(filialeConfigurazioniMap != null){
    
                return filialeConfigurazioniMap;
            }
    
            filialeConfigurazioniMap = new Map<String, ConfigurazioneSpostamenti__mdt>();

            String branchTypeDesc = '%' + currentBranchTypeDesc + '%';
            for(ConfigurazioneSpostamenti__mdt configurazione : [ SELECT Id, MasterLabel, PTF_MDS_End__c, PTF_MDS_Start__c,
                                                        PTF_Abi__c, Finestra_Temporale__c, Iter_Approvativo__c,
                                                        PTF_Filiale_End__c, PTF_Filiale_Start__c, PTF_Filiale_StessaArea__c, PTF_Filiale_StessaDR__c,
                                                        PTF_Filiale_StessoMicroMercato__c, PTF_JSON_Approvatori__c, PTF_StessoReferente__c,
                                                        PTF_CheckNaturaGiuridica__c, PTF_CheckCedSpecifico__c, PTF_CheckTipologiaFilialeDestinazione__c, PTF_CheckTipologiaFilialePartenza__c, Tipo_di_Spostamento__c
                                                        ,PTF_SuperUsers__c
                                                        FROM ConfigurazioneSpostamenti__mdt
                                                        WHERE Tipo_di_Spostamento__c = 'Filiale' AND
                                                        PTF_Filiale_Start__c =: currentBranchTypeDesc AND
                                                        PTF_IsActive__c = true]){

                if(!String.isBlank(configurazione.PTF_Filiale_Start__c) && !String.isBlank(configurazione.PTF_Filiale_End__c)){

                    if(!String.isBlank(configurazione.PTF_MDS_Start__c)){
                        
                        branchEligible.add(configurazione.PTF_Filiale_End__c);
                        String key = configurazione.PTF_StessoReferente__c ? configurazione.PTF_Filiale_Start__c + '_' + configurazione.PTF_Filiale_End__c + '_' + configurazione.PTF_MDS_Start__c + '_' + configurazione.PTF_StessoReferente__c + '_' + configurazione.PTF_Filiale_StessoMicroMercato__c + '_' + configurazione.PTF_Filiale_StessaArea__c + '_' + configurazione.PTF_Filiale_StessaDR__c + '_' + configurazione.PTF_Abi__c :
                        configurazione.PTF_Filiale_Start__c + '_' + configurazione.PTF_Filiale_End__c + '_' + configurazione.PTF_MDS_Start__c + '_' + configurazione.PTF_Filiale_StessoMicroMercato__c + '_' + configurazione.PTF_Filiale_StessaArea__c + '_' + configurazione.PTF_Filiale_StessaDR__c + '_' + configurazione.PTF_Abi__c;
                        filialeConfigurazioniMap.put(key, configurazione);
                    }else{
    
                        for(String mds : modelloDiServizioList){
                            
                            String key = configurazione.PTF_StessoReferente__c ? configurazione.PTF_Filiale_Start__c + '_' + configurazione.PTF_Filiale_End__c + '_' + mds + '_' + configurazione.PTF_StessoReferente__c + '_' + configurazione.PTF_Filiale_StessoMicroMercato__c + '_' + configurazione.PTF_Filiale_StessaArea__c + '_' + configurazione.PTF_Filiale_StessaDR__c + '_' + configurazione.PTF_Abi__c :
                            configurazione.PTF_Filiale_Start__c + '_' + configurazione.PTF_Filiale_End__c + '_' + mds + '_' + configurazione.PTF_Filiale_StessoMicroMercato__c + '_' + configurazione.PTF_Filiale_StessaArea__c + '_' + configurazione.PTF_Filiale_StessaDR__c + '_' + configurazione.PTF_Abi__c;
                            if(!filialeConfigurazioniMap.containsKey(key)){

                                branchEligible.add(configurazione.PTF_Filiale_End__c);
                                filialeConfigurazioniMap.put(key, configurazione);
                            }
                        }
                    }
                }else{

                    if(!String.isBlank(configurazione.PTF_CheckTipologiaFilialePartenza__c) && !String.isBlank(configurazione.PTF_CheckTipologiaFilialeDestinazione__c)){

                        for(String tipologiaFilialePartenza : configurazione.PTF_CheckTipologiaFilialePartenza__c.split(',')){
    
                            for(String tipologiaFilialeDestinazione : configurazione.PTF_CheckTipologiaFilialeDestinazione__c.split(',')){
                                
                                if(!String.isBlank(configurazione.PTF_MDS_Start__c)){
    
                                    branchEligible.add(tipologiaFilialeDestinazione);
                                    String key = configurazione.PTF_StessoReferente__c ? tipologiaFilialePartenza + '_' + tipologiaFilialeDestinazione + '_' + configurazione.PTF_MDS_Start__c + '_' + configurazione.PTF_StessoReferente__c + '_' + configurazione.PTF_Filiale_StessoMicroMercato__c + '_' + configurazione.PTF_Filiale_StessaArea__c + '_' + configurazione.PTF_Filiale_StessaDR__c + '_' + configurazione.PTF_Abi__c:
                                    tipologiaFilialePartenza + '_' + tipologiaFilialeDestinazione + '_' + configurazione.PTF_MDS_Start__c + '_' + configurazione.PTF_Filiale_StessoMicroMercato__c + '_' + configurazione.PTF_Filiale_StessaArea__c + '_' + configurazione.PTF_Filiale_StessaDR__c + '_' + configurazione.PTF_Abi__c;
                                    filialeConfigurazioniMap.put(key, configurazione);
                                }else{
    
                                    for(String mds : modelloDiServizioList){
    
                                        String key = configurazione.PTF_StessoReferente__c ? tipologiaFilialePartenza + '_' + tipologiaFilialeDestinazione + '_' + mds + '_' + configurazione.PTF_StessoReferente__c + '_' + configurazione.PTF_Filiale_StessoMicroMercato__c + '_' + configurazione.PTF_Filiale_StessaArea__c + '_' + configurazione.PTF_Filiale_StessaDR__c + '_' + configurazione.PTF_Abi__c:
                                        tipologiaFilialePartenza + '_' + tipologiaFilialeDestinazione + '_' + mds + '_' + configurazione.PTF_Filiale_StessoMicroMercato__c + '_' + configurazione.PTF_Filiale_StessaArea__c + '_' + configurazione.PTF_Filiale_StessaDR__c + '_' + configurazione.PTF_Abi__c;
                                        if(!filialeConfigurazioniMap.containsKey(key)){
        
                                            branchEligible.add(tipologiaFilialeDestinazione);
                                            filialeConfigurazioniMap.put(key, configurazione);
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }

            for(ConfigurazioneSpostamenti__mdt configurazione : [ SELECT Id, MasterLabel, PTF_MDS_End__c, PTF_MDS_Start__c,
                                                        PTF_Abi__c, Finestra_Temporale__c, Iter_Approvativo__c,
                                                        PTF_Filiale_End__c, PTF_Filiale_Start__c, PTF_Filiale_StessaArea__c, PTF_Filiale_StessaDR__c,
                                                        PTF_Filiale_StessoMicroMercato__c, PTF_JSON_Approvatori__c, PTF_StessoReferente__c,
                                                        PTF_CheckNaturaGiuridica__c, PTF_CheckCedSpecifico__c, PTF_CheckTipologiaFilialeDestinazione__c, PTF_CheckTipologiaFilialePartenza__c, Tipo_di_Spostamento__c
                                                        ,PTF_SuperUsers__c
                                                        FROM ConfigurazioneSpostamenti__mdt
                                                        WHERE Tipo_di_Spostamento__c = 'Filiale' AND
                                                        PTF_CheckTipologiaFilialePartenza__c LIKE: branchTypeDesc AND
                                                        PTF_IsActive__c = true]){
                
                for(String tipologiaFilialePartenza : configurazione.PTF_CheckTipologiaFilialePartenza__c.split(',')){

                    for(String tipologiaFilialeDestinazione : configurazione.PTF_CheckTipologiaFilialeDestinazione__c.split(',')){
                        
                        if(!String.isBlank(configurazione.PTF_MDS_Start__c)){

                            branchEligible.add(tipologiaFilialeDestinazione);
                            String key = configurazione.PTF_StessoReferente__c ? tipologiaFilialePartenza + '_' + tipologiaFilialeDestinazione + '_' + configurazione.PTF_MDS_Start__c + '_' +  configurazione.PTF_StessoReferente__c + '_' + configurazione.PTF_Filiale_StessoMicroMercato__c + '_' + configurazione.PTF_Filiale_StessaArea__c + '_' + configurazione.PTF_Filiale_StessaDR__c + '_' + configurazione.PTF_Abi__c:
                            tipologiaFilialePartenza + '_' + tipologiaFilialeDestinazione + '_' + configurazione.PTF_MDS_Start__c + '_' + configurazione.PTF_Filiale_StessoMicroMercato__c + '_' + configurazione.PTF_Filiale_StessaArea__c + '_' + configurazione.PTF_Filiale_StessaDR__c + '_' + configurazione.PTF_Abi__c;
                            filialeConfigurazioniMap.put(key, configurazione);
                        }else{

                            for(String mds : modelloDiServizioList){

                                String key = configurazione.PTF_StessoReferente__c ? tipologiaFilialePartenza + '_' + tipologiaFilialeDestinazione + '_' + mds + '_' +  configurazione.PTF_StessoReferente__c + '_' + configurazione.PTF_Filiale_StessoMicroMercato__c + '_' + configurazione.PTF_Filiale_StessaArea__c + '_' + configurazione.PTF_Filiale_StessaDR__c + '_' + configurazione.PTF_Abi__c:
                                tipologiaFilialePartenza + '_' + tipologiaFilialeDestinazione + '_' + mds + '_' + configurazione.PTF_Filiale_StessoMicroMercato__c + '_' + configurazione.PTF_Filiale_StessaArea__c + '_' + configurazione.PTF_Filiale_StessaDR__c + '_' + configurazione.PTF_Abi__c;
                                if(!filialeConfigurazioniMap.containsKey(key)){

                                    branchEligible.add(tipologiaFilialeDestinazione);
                                    filialeConfigurazioniMap.put(tipologiaFilialePartenza + '_' + tipologiaFilialeDestinazione + '_' + mds + '_' + configurazione.PTF_Filiale_StessoMicroMercato__c + '_' + configurazione.PTF_Filiale_StessaArea__c + '_' + configurazione.PTF_Filiale_StessaDR__c + '_' + configurazione.PTF_Abi__c, configurazione);
                                }
                            }
                        }
                    }
                }
            }

            return filialeConfigurazioniMap;
        }set;
    }

    @AuraEnabled
    public static Map<String, ConfigurazioneSpostamenti__mdt> filialeMDSConfigurazioniMap{

        get{

            if(filialeMDSConfigurazioniMap != null){
    
                return filialeMDSConfigurazioniMap;
            }
    
            filialeMDSConfigurazioniMap = new Map<String, ConfigurazioneSpostamenti__mdt>();
            String branchTypeDesc = '%' + currentBranchTypeDesc + '%';
            for(ConfigurazioneSpostamenti__mdt configurazione : [ SELECT Id, MasterLabel, PTF_MDS_End__c, PTF_MDS_Start__c,
                                                        PTF_Abi__c, Finestra_Temporale__c, Iter_Approvativo__c,
                                                        PTF_Filiale_End__c, PTF_Filiale_Start__c, PTF_Filiale_StessaArea__c, PTF_Filiale_StessaDR__c,
                                                        PTF_Filiale_StessoMicroMercato__c, PTF_JSON_Approvatori__c, PTF_StessoReferente__c,
                                                        PTF_CheckNaturaGiuridica__c, PTF_CheckCedSpecifico__c, PTF_CheckTipologiaFilialeDestinazione__c, PTF_CheckTipologiaFilialePartenza__c, Tipo_di_Spostamento__c
                                                        ,PTF_SuperUsers__c
                                                        FROM ConfigurazioneSpostamenti__mdt
                                                        WHERE Tipo_di_Spostamento__c = 'MDS / Filiale' AND
                                                        PTF_MDS_Start__c =: currentMDS AND
                                                        PTF_CheckTipologiaFilialePartenza__c LIKE: branchTypeDesc AND
                                                        PTF_IsActive__c = true]){
            
                for(String tipologiaFilialePartenza : configurazione.PTF_CheckTipologiaFilialePartenza__c.split(',')){

                    for(String tipologiaFilialeDestinazione : configurazione.PTF_CheckTipologiaFilialeDestinazione__c.split(',')){
                        
                        branchEligible.add(tipologiaFilialeDestinazione);
                        filialeMDSConfigurazioniMap.put(configurazione.PTF_MDS_Start__c + '_' + configurazione.PTF_MDS_End__c + '_' + tipologiaFilialePartenza + '_' + tipologiaFilialeDestinazione + '_' + configurazione.PTF_Filiale_StessoMicroMercato__c + '_' + configurazione.PTF_Filiale_StessaArea__c + '_' + configurazione.PTF_Filiale_StessaDR__c + '_' + configurazione.PTF_Abi__c, configurazione);
                    }
                }
            }
            return filialeMDSConfigurazioniMap;
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
                                ,PTF_SuperUsers__c, Check_SegComp__c
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

        System.debug(' GR record id: '+ recordId);
        Integer startingHeap = Limits.getHeapSize();
        String gruppoFinanziarioId = '';
        Boolean isPrimario = false;
        hasDifferent = false;
        String errorMessage;
        List<Account> cointestazioni = new List<Account>();
        Set<String> microportafogliCointestazioniFiliali = new Set<String>();
        List<Account> cointestazioniInSame = new List<Account>();
        // MS - Aggiunto campo Name
        Account currentRecord = [SELECT Id, Name, PTF_Portafoglio__r.Name, PTF_BloccoSpostamenti__c, (SELECT Id FROM Work_Order_Line_Items__r WHERE Status = 'Pending') FROM Account WHERE Id =: recordId];
        // List<WorkOrderLineItem> pendingRequestList = [SELECT id FROM WorkOrderLineItem WHERE AccountId__c =: recordId AND Status = 'Pending'];
        
        if(currentUser.Profilo__c != 'NEC_D.0'){

            // MS - Aggiunto messaggio di errore se Name = '999'
            if(currentRecord.PTF_Portafoglio__r.Name.endsWith('999')){
                errorMessage = 'Lo spostamento di questo NDG non è consentito in quanto appartenente ad un portafoglio 999.';
                return new Map<String,Object> {
            
                    'errorMessage' => errorMessage
                };
            }
        }

        if(currentRecord.PTF_BloccoSpostamenti__c){
            errorMessage = 'Lo spostamento di questo NDG è momentaneamente bloccato.';
            return new Map<String,Object> {
    
                'errorMessage' => errorMessage
            };
        }
        
        if(!currentRecord.Work_Order_Line_Items__r.isEmpty()){

            errorMessage = 'NDG già inserito in iter.';
            return new Map<String,Object> {
    
                'errorMessage' => errorMessage
            };
        }
        Account currentNDG = [SELECT Id, Name, PTF_BloccoSpostamenti__c, RecordType.DeveloperName, CRM_NDG__c, PTF_Filiale__c, ModelloDiServizio__c, PTF_Portafoglio__c, PTF_CapoGruppo__c, PTF_Gruppo__c, AnnualRevenue, PTF_Accordato__c, PTF_Patrimonio__c, PTF_Utilizzato__c,
                PTF_NaturaGiuridica__c, PTF_Portafoglio__r.PTF_ModelloDiServizio__c, PTF_Portafoglio__r.PTF_Filiale__c, PTF_Portafoglio__r.PTF_Filiale__r.PTF_BranchTypeDesc__c, PTF_Filiale__r.PTF_BranchTypeDesc__c,
                PTF_Portafoglio__r.PTF_DirezioneRegionale__r.PTF_DowngradeReqStartDate__c, PTF_Portafoglio__r.PTF_DirezioneRegionale__r.PTF_DowngradeReqEndDate__c,
                PTF_Portafoglio__r.PTF_Banca__r.PTF_DowngradeReqStartDate__c, PTF_Portafoglio__r.PTF_Banca__r.PTF_DowngradeReqEndDate__c, PTF_Filiale__r.PTF_DowngradeReqStartDate__c, PTF_Filiale__r.PTF_DowngradeReqEndDate__c,
                PTF_Portafoglio__r.PTF_Banca__c, PTF_Portafoglio__r.PTF_Capofila__c, 
                PTF_Portafoglio__r.PTF_DirezioneRegionale__c, PTF_Portafoglio__r.PTF_Area__c,
                PTF_Filiale__r.PTF_IdCed__c, PTF_Filiale__r.PTF_BloccaSpostamentiInFiliale__c, PTF_Filiale__r.PTF_BloccaSpostamentiVersoFiliale__c, PTF_Filiale__r.PTF_BloccaSpostamentiFiliale__c, PTF_SegmentoComportamentale__c,
                PTF_OFS__c FROM Account WHERE id =: recordId];
        
        
        List<Wallet__c> currentPFList = [SELECT Id, Name, PTF_ModelloDiServizio__c, PTF_UffPrivate__c, PTF_Filiale__r.PTF_IDCEDUffPrivate__c, PTF_UffPrivate__r.PTF_IdCedPadre__c,
        PTF_Filiale__c, PTF_Filiale__r.PTF_BranchTypeDesc__c, PTF_Filiale__r.PTF_BranchTypologyMap__c, PTF_Filiale__r.Name, PTF_FIliale__r.PTF_IdCed__c, PTF_Capofila__c, PTF_Capofila__r.PTF_IdCed__c,
        PTF_Banca__c, PTF_Banca__r.FinServ__BankNumber__c, PTF_Banca__r.PTF_DowngradeReqStartDate__c, PTF_Banca__r.PTF_DowngradeReqEndDate__c, PTF_Banca__r.PTF_IdCed__c,
        PTF_DirezioneRegionale__r.PTF_IdCed__c, PTF_Area__r.PTF_IdCed__c, PTF_DirezioneRegionale__c, PTF_Area__c, Owner.Name, PTF_Fatturato__c, PTF_Patrimonio__c, PTF_Utilizzato__c, PTF_Accordato__c,
        PTF_DirezioneRegionale__r.PTF_DowngradeReqStartDate__c, PTF_DirezioneRegionale__r.PTF_DowngradeReqEndDate__c, PTF_Pool__c, PTF_Filiale__r.PTF_DowngradeReqStartDate__c, PTF_Filiale__r.PTF_DowngradeReqEndDate__c,
        PTF_Filiale__r.PTF_BloccaSpostamentiInFiliale__c, PTF_Filiale__r.PTF_BloccaSpostamentiVersoFiliale__c, PTF_Filiale__r.PTF_BloccaSpostamentiFiliale__c,PTF_StatoAssegnazione__c , 
        (SELECT id, PTF_Gestore__c, PTF_Gestore__r.PTF_OFS__c, PTF_Gestore__r.Name FROM Backup_Assignments__r WHERE RecordType.DeveloperName = 'Primario' AND PTF_EndDate__c = null)
        FROM Wallet__c WHERE Id =: currentNDG.PTF_Portafoglio__c AND RecordType.developerName != 'TechnicalWallet'];
        List<Wallet__c> portafogliInEvidenza;
        Set<String> microportafogliCointestazioni = new Set<String>();
        List<Wallet__c> altriPortafogli;

        System.debug('GR currentPFList[0].Name: ' +currentPFList[0].Name);
        System.debug('GR currentPFList: ' +currentPFList);
        
        if(currentPFList.isEmpty()){
            
            errorMessage = 'NDG non ancora assegnato ad un portafoglio.';
            return new Map<String,Object> {
                
                'errorMessage' => errorMessage
            };
        }else{
            
            Wallet__c currentPF = currentPFList[0];
            
            if(currentUser.Profilo__c != 'NEC_D.0'){

                if(currentNDG.PTF_Filiale__r.PTF_BloccaSpostamentiFiliale__c ||
                (currentNDG.PTF_Filiale__r.PTF_BloccaSpostamentiInFiliale__c && currentUser.IdCed__c == currentNDG.PTF_Filiale__r.PTF_IdCed__c && currentPF.PTF_ModelloDiServizio__c != 'Assente')){

                    errorMessage = 'Lo spostamento di questo NDG è momentaneamente bloccato dalla filiale.';
                    return new Map<String,Object> {
            
                        'errorMessage' => errorMessage
                    };
                }else if(filialeCurrentUser.PTF_BloccaSpostamentiFiliale__c || 
                (filialeCurrentUser.PTF_BloccaSpostamentiVersoFiliale__c && currentUser.IdCed__c != currentNDG.PTF_Filiale__r.PTF_IdCed__c)){
                    errorMessage = 'Gli spostamenti verso la tua filiale sono momentaneamente bloccati.';
                    return new Map<String,Object> {
            
                        'errorMessage' => errorMessage
                    };
                }
            }

            // LV 26-03-2024 CR NEC#79450 start
            if (currentNDG.PTF_NaturaGiuridica__c == 'DI' && currentNDG.PTF_Portafoglio__r.PTF_ModelloDiServizio__c == 'POE') {
                errorMessage = 'Lo spostamento di questo NDG con Natura Giuridica DI non é consentito in quanto appartiene ad un portafoglio POE.';
                return new Map<String, Object> {

                    'errorMessage' => errorMessage
                };
            }
            // LV 26-03-2024 CR NEC#79450 end
            
            if(currentNDG.RecordType.DeveloperName == 'GruppoFinanziario'){

                ruolo = 'gruppoFinanziario';                
            }else{
                
                //Select ParentId
                List<CRM_LinkedNDG__c> linkedNDGList = [SELECT Id, CRM_Account__c, CRM_LinkCode__c, CRM_RelatedAccount__c, CRM_Status__c FROM CRM_LinkedNDG__c WHERE CRM_RelatedAccount__c =: currentNDG.Id AND CRM_LinkCode__c IN ('113', '165') AND CRM_Status__c='A' ];
                SpostaNdgIterDataLoader.currentMDS = currentPF.PTF_ModelloDiServizio__c;
                SpostaNdgIterDataLoader.currentBranchTypeDesc = currentPF.PTF_Filiale__r.PTF_BranchTypeDesc__c;
                if(!linkedNDGList.isEmpty()){

                    map<String, SObject> gruppoMap = SV_Utilities.keyBy(linkedNDGList, 'CRM_LinkCode__c');
                    if(gruppoMap.containsKey('113')){

                        ruolo = 'capoGruppo';
                        CRM_LinkedNDG__c linkedNDG = (CRM_LinkedNDG__c)gruppoMap.get('113');
                        gruppoFinanziarioId = linkedNDG.CRM_Account__c;
                    }else{

                        CRM_LinkedNDG__c linkedNDG = (CRM_LinkedNDG__c)gruppoMap.get('165');
                        List<CRM_LinkedNDG__c> capoGruppo = [SELECT Id, CRM_Account__c, CRM_LinkCode__c, CRM_RelatedAccount__r.PTF_Portafoglio__c, CRM_Status__c FROM CRM_LinkedNDG__c WHERE CRM_Account__c =: linkedNDG.CRM_Account__c AND CRM_LinkCode__c IN ('113') AND CRM_Status__c='A' ];
                        if(!capoGruppo.isEmpty()){
                            
                            ruolo = 'membroGruppo';
                            if(capoGruppo[0].CRM_RelatedAccount__r.PTF_Portafoglio__c != currentNDG.PTF_Portafoglio__c){
        
                                portafogliInEvidenza = [SELECT Id, Name, PTF_ModelloDiServizio__c,PTF_Pool__c, PTF_UffPrivate__c, PTF_Filiale__r.PTF_IDCEDUffPrivate__c, PTF_UffPrivate__r.PTF_IdCedPadre__c,
                                PTF_Filiale__c, PTF_Filiale__r.PTF_BranchTypeDesc__c, PTF_Filiale__r.PTF_BranchTypologyMap__c, PTF_Filiale__r.Name, PTF_FIliale__r.PTF_IdCed__c, PTF_Capofila__c, PTF_Capofila__r.PTF_IdCed__c,
                                PTF_Banca__c, PTF_Banca__r.FinServ__BankNumber__c, PTF_Banca__r.PTF_DowngradeReqStartDate__c, PTF_Banca__r.PTF_DowngradeReqEndDate__c, PTF_Banca__r.PTF_IdCed__c,
                                PTF_DirezioneRegionale__r.PTF_IdCed__c, PTF_Area__r.PTF_IdCed__c, PTF_DirezioneRegionale__c, PTF_Area__c, Owner.Name, PTF_Fatturato__c, PTF_Patrimonio__c, PTF_Utilizzato__c, PTF_Accordato__c,
                                PTF_DirezioneRegionale__r.PTF_DowngradeReqStartDate__c, PTF_DirezioneRegionale__r.PTF_DowngradeReqEndDate__c,PTF_StatoAssegnazione__c, PTF_Filiale__r.PTF_DowngradeReqStartDate__c, PTF_Filiale__r.PTF_DowngradeReqEndDate__c,
                                (SELECT id, PTF_Gestore__c, PTF_Gestore__r.PTF_OFS__c, PTF_Gestore__r.Name FROM Backup_Assignments__r WHERE RecordType.DeveloperName = 'Primario' AND PTF_EndDate__c = null)
                                FROM Wallet__c WHERE Id =: capoGruppo[0].CRM_RelatedAccount__r.PTF_Portafoglio__c AND RecordType.developerName != 'TechnicalWallet'  AND RecordType.developerName != 'Assente' AND RecordType.developerName != 'Residuale' LIMIT 1];
    
                                /*if(!portafogliInEvidenza.isEmpty()){
    
                                    SpostaNdgIterDataLoader.ruolo = ruolo;
                                    SpostaNdgIterDataLoader.isPTFInEvidenza = true;
                                    if(currentUser.Profilo__c == 'NEC_D.0'){
    
                                        portafogliInEvidenza = SpostaNdgIterDataLoader.checkEligibleSuperUser(portafogliInEvidenza[0], currentNDG) ? portafogliInEvidenza : new List<Wallet__c>();
                                    }else{
    
                                        portafogliInEvidenza = SpostaNdgIterDataLoader.checkEligible(portafogliInEvidenza[0], currentNDG, currentPF) ? portafogliInEvidenza : new List<Wallet__c>();
                                    }
                                    SpostaNdgIterDataLoader.isPTFInEvidenza = false;
                                }*/
                            }else{
            
                                portafogliInEvidenza = null;
                            }
                        }else{
            
                            portafogliInEvidenza = null;
                        }
                    }
                }else if(currentNDG.RecordType.DeveloperName == 'Cointestazione' && currentNDG.PTF_NaturaGiuridica__c == 'CO'){
        
                    List<CRM_AccountAccountJointOwnershipRelation__c> primario = [SELECT id, CRM_Account__c, CRM_Active__c, CRM_PrimaryNDG__c, CRM_JointOwnership__c,
                    CRM_Account__r.CRM_NDG__c, CRM_Account__r.PTF_Portafoglio__c, CRM_Account__r.PTF_Portafoglio__r.PTF_Filiale__c, CRM_Account__r.PTF_Portafoglio__r.PTF_Filiale__r.PTF_IDCED__c, CRM_Account__r.PTF_Portafoglio__r.PTF_ModelloDiServizio__c, CRM_Account__r.PTF_Filiale__c, CRM_Account__r.ModelloDiServizio__c,
                    CRM_Account__r.PTF_Portafoglio__r.RecordType.developerName
                    FROM CRM_AccountAccountJointOwnershipRelation__c 
                    WHERE CRM_JointOwnership__c =: currentNDG.Id AND
                    CRM_JointOwnership__r.PTF_Portafoglio__c != '' AND
                    CRM_Active__c = true AND
                    CRM_PrimaryNDG__c = true AND 
                    CRM_Account__r.PTF_Portafoglio__r.RecordType.developerName != 'Residuale'
                    ORDER BY CreatedDate DESC
                    LIMIT 1];
                    
                    if(!primario.isEmpty()){
                        
                        ruolo = 'cointestazione';
                        if(primario[0].CRM_Account__r.PTF_Portafoglio__c == currentPF.Id){

                            List<WorkOrderLineItem> pendingRequestList = [SELECT id FROM WorkOrderLineItem WHERE AccountId__c =: primario[0].CRM_Account__c AND Status = 'Pending'];
                            if(!pendingRequestList.isEmpty()){
    
                                errorMessage = 'NDG primario (' + primario[0].CRM_Account__r.CRM_NDG__c + ') già inserito in iter.';
                                return new Map<String,Object> {
                        
                                    'errorMessage' => errorMessage
                                };
                            }
                        }
        
                        if(primario[0].CRM_Account__r.PTF_Portafoglio__c != currentPF.Id){
                            
                            portafogliInEvidenza = [SELECT Id, Name, PTF_ModelloDiServizio__c, PTF_Pool__c, PTF_UffPrivate__c, PTF_Filiale__r.PTF_IDCEDUffPrivate__c, PTF_UffPrivate__r.PTF_IdCedPadre__c,
                            PTF_Filiale__c, PTF_Filiale__r.PTF_BranchTypeDesc__c, PTF_Filiale__r.PTF_BranchTypologyMap__c, PTF_Filiale__r.Name, PTF_FIliale__r.PTF_IdCed__c, PTF_Capofila__c, PTF_Capofila__r.PTF_IdCed__c,
                            PTF_Banca__c, PTF_Banca__r.FinServ__BankNumber__c, PTF_Banca__r.PTF_DowngradeReqStartDate__c, PTF_Banca__r.PTF_DowngradeReqEndDate__c, PTF_Banca__r.PTF_IdCed__c,PTF_StatoAssegnazione__c,
                            PTF_DirezioneRegionale__r.PTF_IdCed__c, PTF_Area__r.PTF_IdCed__c, PTF_DirezioneRegionale__c, PTF_Area__c, Owner.Name, PTF_Fatturato__c, PTF_Patrimonio__c, PTF_Utilizzato__c, PTF_Accordato__c,
                            PTF_DirezioneRegionale__r.PTF_DowngradeReqStartDate__c, PTF_DirezioneRegionale__r.PTF_DowngradeReqEndDate__c, PTF_Filiale__r.PTF_DowngradeReqStartDate__c, PTF_Filiale__r.PTF_DowngradeReqEndDate__c,
                            (SELECT id, PTF_Gestore__c, PTF_Gestore__r.PTF_OFS__c, PTF_Gestore__r.Name FROM Backup_Assignments__r WHERE RecordType.DeveloperName = 'Primario' AND PTF_EndDate__c = null)
                            FROM Wallet__c WHERE Id =: primario[0].CRM_Account__r.PTF_Portafoglio__c AND RecordType.developerName != 'TechnicalWallet' AND RecordType.developerName != 'Assente' AND RecordType.developerName != 'Residuale' LIMIT 1];

                            if(primario[0].CRM_Account__r.PTF_Portafoglio__r.PTF_Filiale__r.PTF_IDCED__c != '7113' &&
                                currentPF.PTF_Filiale__r.PTF_IDCED__c != '7113' &&
                                primario[0].CRM_Account__r.PTF_Portafoglio__r.PTF_Filiale__c != currentContact.AccountId &&
                                currentPF.PTF_Filiale__c != currentContact.AccountId &&
                                currentUser.Profilo__c != 'NEC_D.0'){

                                errorMessage = 'Spostamento non consentito. Contattare i responsabili della filiale di relazione dell\'NDG';
                                return new Map<String,Object> {
                                    
                                    'errorMessage' => errorMessage
                                };
                            }

                            if(!portafogliInEvidenza.isEmpty()){

                                /*if(primario[0].CRM_Account__r.PTF_Filiale__c != currentNDG.PTF_Filiale__c &&
                                primario[0].CRM_Account__r.ModelloDiServizio__c != currentNDG.ModelloDiServizio__c){

                                    mdsPrimario = portafogliInEvidenza[0].PTF_ModelloDiServizio__c;
                                    filialePrimario = portafogliInEvidenza[0].PTF_Filiale__c;
                                }
                                SpostaNdgIterDataLoader.ruolo = ruolo;
                                // SpostaNdgIterDataLoader.mdsPrimario = portafogliInEvidenza[0].PTF_ModelloDiServizio__c;
                                SpostaNdgIterDataLoader.filialePrimario = portafogliInEvidenza[0].PTF_Filiale__c;
                                SpostaNdgIterDataLoader.isPTFInEvidenza = true;
                                if(currentUser.Profilo__c == 'NEC_D.0'){
    
                                    portafogliInEvidenza = SpostaNdgIterDataLoader.checkEligibleSuperUser(portafogliInEvidenza[0], currentNDG) ? portafogliInEvidenza : new List<Wallet__c>();
                                }else{
    
                                    portafogliInEvidenza = SpostaNdgIterDataLoader.checkEligible(portafogliInEvidenza[0], currentNDG, currentPF) ? portafogliInEvidenza : new List<Wallet__c>();
                                }
                                SpostaNdgIterDataLoader.isPTFInEvidenza = false;*/
                            }
                        }else{
    
                            portafogliInEvidenza = null;
                        }
                    }
                }else{
                    
                    // Set<String> microPortafoglioCointestazioniIdSet = new Set<String>();
                    Set<String> cointestazioniIdSet = new Set<String>();
                    Set<String> cointestazioniPrimarioIdSet = new Set<String>();
                    Map<String, SObject> giunzioni = SV_Utilities.keyBy([SELECT id, CRM_Account__c, CRM_Active__c, CRM_PrimaryNDG__c, CRM_JointOwnership__c,
                                                    CRM_JointOwnership__r.PTF_Portafoglio__c,
                                                    CRM_JointOwnership__r.PTF_Portafoglio__r.RecordType.developerName
                                                    FROM CRM_AccountAccountJointOwnershipRelation__c 
                                                    WHERE CRM_Account__c =: currentNDG.Id AND
                                                    CRM_JointOwnership__r.PTF_Portafoglio__c != null AND
                                                    CRM_JointOwnership__r.PTF_Portafoglio__r.RecordType.developerName != 'Residuale' AND 
                                                    CRM_Active__c = true
                                                    ORDER BY CreatedDate DESC], '{CRM_PrimaryNDG__c}_{CRM_JointOwnership__r.PTF_Portafoglio__c}_{CRM_JointOwnership__c}', true);
                    
                    System.debug('DK giunzioni: ' + JSON.serialize(giunzioni));
                    if(!giunzioni.isEmpty()){
        
                        for(String giunzioneKey : giunzioni.keySet()){
            
                            cointestazioniIdSet.add((String)giunzioni.get(giunzioneKey).get('CRM_JointOwnership__c'));
                            if(Boolean.valueOf(giunzioneKey.split('_')[0])){
            
                                isPrimario = true;
                                cointestazioniPrimarioIdSet.add(giunzioneKey.split('_')[2]);
                                // microPortafoglioCointestazioniIdSet.add(giunzioneKey.split('_')[1]);
                            }
                        }
                        ruolo = isPrimario ? 'primario' : 'cointestatario';
                        Map<String, Account> varCointestazioniMap = (Map<String, Account>) JSON.deserialize(JSON.serialize(SV_Utilities.keyBy([SELECT Id, Name, CRM_NDG__c, PTF_Filiale__c, ModelloDiServizio__c, PTF_Portafoglio__c, PTF_Portafoglio__r.PTF_ModelloDiServizio__c,
                                                    PTF_CapoGruppo__c, PTF_Gruppo__c, AnnualRevenue, PTF_Accordato__c, PTF_Patrimonio__c, PTF_Utilizzato__c, PTF_NaturaGiuridica__c, PTF_SegmentoComportamentale__c
                                                    FROM Account
                                                    WHERE id IN: cointestazioniIdSet], 'Id')), Map<String, Account>.class);
                        if(ruolo == 'primario'){
                            
                            if(!varCointestazioniMap.isEmpty()){

                                for(String cointestazioneId : varCointestazioniMap.keySet()){

                                    if(cointestazioniPrimarioIdSet.contains(cointestazioneId)){

                                        cointestazioni.add(varCointestazioniMap.get(cointestazioneId));
                                    }
                                }
                            }
                            System.debug('Pz cointestazioni: ' + JSON.serialize(cointestazioni));
                            System.debug('DK varCointestazioniMap: ' + JSON.serialize(varCointestazioniMap));
                            // cointestazioni = !varCointestazioniMap.isEmpty() ? varCointestazioniMap.values() : null;
                            Set<String> mdsCoList = new Set<String>();
                            for(Account cointestazione : cointestazioni){
                                
                                if(currentNDG.PTF_Portafoglio__c != cointestazione.PTF_Portafoglio__c){
    
                                    microportafogliCointestazioni.add(cointestazione.PTF_Portafoglio__c);
                                    if(currentPF.PTF_Filiale__c != cointestazione.PTF_Filiale__c){

                                        microportafogliCointestazioniFiliali.add(cointestazione.PTF_Filiale__c);
                                    }
                                    mdsCoList.add(cointestazione.PTF_Portafoglio__r.PTF_ModelloDiServizio__c);
                                }else{

                                    cointestazioniInSame.add(cointestazione);
                                }
                            }
                            System.debug('DK microportafogliCointestazioni: ' + JSON.serialize(microportafogliCointestazioni));
                            System.debug('Pz microportafogliCointestazioni: ' + JSON.serialize(microportafogliCointestazioni));
                            System.debug('PZ cointestazioniInSame: ' + JSON.serialize(cointestazioniInSame));
                            System.debug('PZ mdsCoList: ' + mdsCoList);
                            if(microportafogliCointestazioni.size() > 1){
                                
                                hasDifferent = true;
                                System.debug('PZ hasDifferent ' + hasDifferent);
                            }
                            if(mdsCoList.size() == 1){

                                //mdsCo = mdsCoList[0];
                                mdsCo = mdsCoList.iterator().next();
                                System.debug('PZ mdsCo :'+mdsCo);
                            }
                            if(!microportafogliCointestazioni.isEmpty()){
            
                                portafogliInEvidenza = [SELECT Id, Name, PTF_ModelloDiServizio__c, PTF_Pool__c, PTF_UffPrivate__c, PTF_Filiale__r.PTF_IDCEDUffPrivate__c, PTF_UffPrivate__r.PTF_IdCedPadre__c,
                                PTF_Filiale__c, PTF_Filiale__r.PTF_BranchTypeDesc__c, PTF_Filiale__r.PTF_BranchTypologyMap__c, PTF_Filiale__r.Name, PTF_FIliale__r.PTF_IdCed__c, PTF_Capofila__c, PTF_Capofila__r.PTF_IdCed__c,
                                PTF_Banca__c, PTF_Banca__r.FinServ__BankNumber__c, PTF_Banca__r.PTF_DowngradeReqStartDate__c, PTF_Banca__r.PTF_DowngradeReqEndDate__c, PTF_Banca__r.PTF_IdCed__c,PTF_StatoAssegnazione__c,
                                PTF_DirezioneRegionale__r.PTF_IdCed__c, PTF_Area__r.PTF_IdCed__c, PTF_DirezioneRegionale__c, PTF_Area__c, Owner.Name, PTF_Fatturato__c, PTF_Patrimonio__c, PTF_Utilizzato__c, PTF_Accordato__c,
                                PTF_DirezioneRegionale__r.PTF_DowngradeReqStartDate__c, PTF_DirezioneRegionale__r.PTF_DowngradeReqEndDate__c, PTF_Filiale__r.PTF_DowngradeReqStartDate__c, PTF_Filiale__r.PTF_DowngradeReqEndDate__c,
                                (SELECT id, PTF_Gestore__c, PTF_Gestore__r.PTF_OFS__c, PTF_Gestore__r.Name FROM Backup_Assignments__r WHERE RecordType.DeveloperName = 'Primario' AND PTF_EndDate__c = null)
                                FROM Wallet__c WHERE Id IN: microportafogliCointestazioni AND RecordType.developerName != 'TechnicalWallet' AND RecordType.developerName != 'Assente' AND RecordType.developerName != 'Residuale'];

                                if(!portafogliInEvidenza.isEmpty()){

                                    /*SpostaNdgIterDataLoader.ruolo = ruolo;
                                    SpostaNdgIterDataLoader.allInSame = !hasDifferent;
                                    // SpostaNdgIterDataLoader.mdsPrimario = portafogliInEvidenza[0].PTF_ModelloDiServizio__c;
                                    SpostaNdgIterDataLoader.isPTFInEvidenza = true;
                                    List<Wallet__c> portafogliInEvidenzaFinal = new List<Wallet__c>();
                                    if(currentUser.Profilo__c == 'NEC_D.0'){
                                        for(Wallet__c portafoglio : portafogliInEvidenza){

                                            if(SpostaNdgIterDataLoader.checkEligibleSuperUser(portafoglio, currentNDG)){

                                                portafogliInEvidenzaFinal.add(portafoglio);
                                            }
                                        }
                                    }else{
                                        
                                        for(Wallet__c portafoglio : portafogliInEvidenza){

                                            if(SpostaNdgIterDataLoader.checkEligible(portafoglio, currentNDG, currentPF)){

                                                portafogliInEvidenzaFinal.add(portafoglio);
                                            }
                                        }
                                    }
                                    portafogliInEvidenza = portafogliInEvidenzaFinal;
                                    SpostaNdgIterDataLoader.isPTFInEvidenza = false;*/
                                }
                            }else{
                
                                portafogliInEvidenza = null;
                                System.debug('PZ portafogliInEvidenza :'+portafogliInEvidenza);
                            }
                        }else if(ruolo == 'cointestatario'){
        
                            Map<String, CRM_AccountAccountJointOwnershipRelation__c> primarioMap = (Map<String, CRM_AccountAccountJointOwnershipRelation__c>) JSON.deserialize(JSON.serialize(SV_Utilities.keyBy([SELECT id, CRM_Account__c, CRM_Active__c, CRM_PrimaryNDG__c, CRM_JointOwnership__c,
                            CRM_JointOwnership__r.PTF_Portafoglio__c, CRM_Account__r.PTF_Portafoglio__c, CRM_Account__r.PTF_Portafoglio__r.PTF_ModelloDiServizio__c
                            FROM CRM_AccountAccountJointOwnershipRelation__c 
                            WHERE CRM_JointOwnership__c IN: cointestazioniIdSet AND
                            CRM_Active__c = true AND
                            CRM_PrimaryNDG__c = true AND
                            CRM_JointOwnership__r.PTF_Portafoglio__c != ''
                            ORDER BY CreatedDate DESC], 'CRM_JointOwnership__c')), Map<String, CRM_AccountAccountJointOwnershipRelation__c>.class);
                            
                            System.debug('DK primarioMap: ' + JSON.serialize(primarioMap));
                            if(!primarioMap.isEmpty()){
        
                                for(String cointestazioneId : primarioMap.keySet()){
                                    
                                    if(varCointestazioniMap.containsKey(cointestazioneId)){
        
                                        if(varCointestazioniMap.get(cointestazioneId).PTF_Portafoglio__c == primarioMap.get(cointestazioneId).CRM_Account__r.PTF_Portafoglio__c ||
                                        varCointestazioniMap.get(cointestazioneId).PTF_Portafoglio__c != currentPF.Id){
                
                                            hasDifferent = true;
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
    
            String currentMDS = currentPF.PTF_ModelloDiServizio__c;
            String currentBranchTypeDesc = currentPF.PTF_Filiale__r.PTF_BranchTypeDesc__c;
            String branchTypeDesc = '%' + currentBranchTypeDesc + '%';

            Map<String, ConfigurazioneSpostamenti__mdt> mdsConfigurazioniMap = new Map<String, ConfigurazioneSpostamenti__mdt>();
            for(ConfigurazioneSpostamenti__mdt configurazione : [ SELECT Id, MasterLabel, PTF_MDS_End__c, PTF_MDS_Start__c,
                                                                PTF_Abi__c, Finestra_Temporale__c, Iter_Approvativo__c,
                                                                PTF_Filiale_End__c, PTF_Filiale_Start__c, PTF_JSON_Approvatori__c, PTF_StessoReferente__c,
                                                                PTF_CheckNaturaGiuridica__c, PTF_CheckCedSpecifico__c, PTF_CheckTipologiaFilialeDestinazione__c, PTF_CheckTipologiaFilialePartenza__c, Tipo_di_Spostamento__c
                                                                ,PTF_SuperUsers__c, Check_SegComp__c
                                                                FROM ConfigurazioneSpostamenti__mdt
                                                                WHERE Tipo_di_Spostamento__c = 'MDS' AND
                                                                (PTF_MDS_Start__c =: currentMDS OR PTF_MDS_Start__c = '')AND
                                                                PTF_IsActive__c = true]){
                
                if(!String.isBlank(configurazione.PTF_MDS_Start__c) && !String.isBlank(configurazione.PTF_MDS_End__c)){
                    
                    if(String.isBlank(configurazione.PTF_CheckTipologiaFilialePartenza__c) && String.isBlank(configurazione.PTF_CheckTipologiaFilialeDestinazione__c)){

                        mdsConfigurazioniMap.put(configurazione.PTF_MDS_Start__c + '_' + configurazione.PTF_MDS_End__c + '_' + configurazione.PTF_Abi__c, configurazione);
                    }else{

                        for(String tipologiaFilialePartenza : configurazione.PTF_CheckTipologiaFilialePartenza__c.split(',')){
    
                            for(String tipologiaFilialeDestinazione : configurazione.PTF_CheckTipologiaFilialeDestinazione__c.split(',')){
    
                                if(!mdsConfigurazioniMap.containsKey(configurazione.PTF_MDS_Start__c + '_' + configurazione.PTF_MDS_End__c + '_' + tipologiaFilialePartenza + '_' + tipologiaFilialeDestinazione + '_' + configurazione.PTF_Abi__c) &&
                                !mdsConfigurazioniMap.containsKey(configurazione.PTF_MDS_Start__c + '_' + configurazione.PTF_MDS_End__c + '_' + tipologiaFilialePartenza + '_' + tipologiaFilialeDestinazione + '_TUTTE')){
    
                                    mdsConfigurazioniMap.put(configurazione.PTF_MDS_Start__c + '_' + configurazione.PTF_MDS_End__c + '_' + tipologiaFilialePartenza + '_' + tipologiaFilialeDestinazione + '_' + configurazione.PTF_Abi__c, configurazione);
                                }
                            }
                        }
                    }

                }else{

                    if(String.isBlank(configurazione.PTF_MDS_Start__c)){

                        // System.debug('DK MasterLabel: ' + configurazione.MasterLabel);
                        for(String mdsStart : modelloDiServizioList){
                            
                            if(mdsStart != 'Assente'){
                                
                                if(String.isBlank(configurazione.PTF_CheckTipologiaFilialePartenza__c) && String.isBlank(configurazione.PTF_CheckTipologiaFilialeDestinazione__c)){
                                    
                                    if(mdsStart != configurazione.PTF_MDS_End__c){
        
                                        if(!mdsConfigurazioniMap.containsKey(mdsStart + '_' + configurazione.PTF_MDS_End__c + '_' + configurazione.PTF_Abi__c) &&
                                        !mdsConfigurazioniMap.containsKey(mdsStart + '_' + configurazione.PTF_MDS_End__c + '_TUTTE')){
        
                                            mdsConfigurazioniMap.put(mdsStart + '_' + configurazione.PTF_MDS_End__c + '_' + configurazione.PTF_Abi__c, configurazione);
                                        }
                                    }
                                }else{
    
                                    for(String tipologiaFilialePartenza : configurazione.PTF_CheckTipologiaFilialePartenza__c.split(',')){
                                        
                                        for(String tipologiaFilialeDestinazione : configurazione.PTF_CheckTipologiaFilialeDestinazione__c.split(',')){
                                            
                                            // System.debug('DK mdsConfigurazioniMap_KEYMAP: ' + mdsStart + '_' + configurazione.PTF_MDS_End__c + '_' + tipologiaFilialePartenza + '_' + tipologiaFilialeDestinazione + '_' + configurazione.PTF_Abi__c);
                                            if(!mdsConfigurazioniMap.containsKey(mdsStart + '_' + configurazione.PTF_MDS_End__c + '_' + tipologiaFilialePartenza + '_' + tipologiaFilialeDestinazione + '_' + configurazione.PTF_Abi__c) &&
                                            !mdsConfigurazioniMap.containsKey(mdsStart + '_' + configurazione.PTF_MDS_End__c + '_' + tipologiaFilialePartenza + '_' + tipologiaFilialeDestinazione + '_TUTTE')){
                
                                                mdsConfigurazioniMap.put(mdsStart + '_' + configurazione.PTF_MDS_End__c + '_' + tipologiaFilialePartenza + '_' + tipologiaFilialeDestinazione + '_' + configurazione.PTF_Abi__c, configurazione);
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }else{

                        for(String mdsEnd : modelloDiServizioList){

                            if(mdsEnd != 'Assente'){

                                if(String.isBlank(configurazione.PTF_CheckTipologiaFilialePartenza__c) && String.isBlank(configurazione.PTF_CheckTipologiaFilialeDestinazione__c)){
    
                                    if(configurazione.PTF_MDS_Start__c != mdsEnd){
                                    
                                        if(!mdsConfigurazioniMap.containsKey(configurazione.PTF_MDS_Start__c + '_' + mdsEnd + '_' + configurazione.PTF_Abi__c) &&
                                        !mdsConfigurazioniMap.containsKey(configurazione.PTF_MDS_Start__c + '_' + mdsEnd + '_TUTTE')){
        
                                            mdsConfigurazioniMap.put(configurazione.PTF_MDS_Start__c + '_' + mdsEnd + '_' + configurazione.PTF_Abi__c, configurazione);
                                        }
                                    }
                                }else{
    
                                    for(String tipologiaFilialePartenza : configurazione.PTF_CheckTipologiaFilialePartenza__c.split(',')){
        
                                        for(String tipologiaFilialeDestinazione : configurazione.PTF_CheckTipologiaFilialeDestinazione__c.split(',')){
                
                                            if(!mdsConfigurazioniMap.containsKey(configurazione.PTF_MDS_Start__c + '_' + mdsEnd + '_' + tipologiaFilialePartenza + '_' + tipologiaFilialeDestinazione + '_' + configurazione.PTF_Abi__c )&&
                                            !mdsConfigurazioniMap.containsKey(configurazione.PTF_MDS_Start__c + '_' + mdsEnd + '_' + tipologiaFilialePartenza + '_' + tipologiaFilialeDestinazione + '_TUTTE')){
                
                                                mdsConfigurazioniMap.put(configurazione.PTF_MDS_Start__c + '_' + mdsEnd + '_' + tipologiaFilialePartenza + '_' + tipologiaFilialeDestinazione + '_' + configurazione.PTF_Abi__c, configurazione);
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }

            Map<String, ConfigurazioneSpostamenti__mdt> filialeConfigurazioniMap = new Map<String, ConfigurazioneSpostamenti__mdt>();
            for(ConfigurazioneSpostamenti__mdt configurazione : [ SELECT Id, MasterLabel, PTF_MDS_End__c, PTF_MDS_Start__c,
                                                        PTF_Abi__c, Finestra_Temporale__c, Iter_Approvativo__c,
                                                        PTF_Filiale_End__c, PTF_Filiale_Start__c, PTF_Filiale_StessaArea__c, PTF_Filiale_StessaDR__c,
                                                        PTF_Filiale_StessoMicroMercato__c, PTF_JSON_Approvatori__c, PTF_StessoReferente__c,
                                                        PTF_CheckNaturaGiuridica__c, PTF_CheckCedSpecifico__c, PTF_CheckTipologiaFilialeDestinazione__c, PTF_CheckTipologiaFilialePartenza__c, Tipo_di_Spostamento__c
                                                        ,PTF_SuperUsers__c
                                                        FROM ConfigurazioneSpostamenti__mdt
                                                        WHERE Tipo_di_Spostamento__c = 'Filiale' AND
                                                        PTF_Filiale_Start__c =: currentBranchTypeDesc AND
                                                        PTF_IsActive__c = true]){

                if(!String.isBlank(configurazione.PTF_Filiale_Start__c) && !String.isBlank(configurazione.PTF_Filiale_End__c)){

                    if(!String.isBlank(configurazione.PTF_MDS_Start__c)){
                        
                        branchEligible.add(configurazione.PTF_Filiale_End__c);
                        String key = configurazione.PTF_StessoReferente__c ? configurazione.PTF_Filiale_Start__c + '_' + configurazione.PTF_Filiale_End__c + '_' + configurazione.PTF_MDS_Start__c + '_' + configurazione.PTF_StessoReferente__c + '_' + configurazione.PTF_Filiale_StessoMicroMercato__c + '_' + configurazione.PTF_Filiale_StessaArea__c + '_' + configurazione.PTF_Filiale_StessaDR__c + '_' + configurazione.PTF_Abi__c :
                        configurazione.PTF_Filiale_Start__c + '_' + configurazione.PTF_Filiale_End__c + '_' + configurazione.PTF_MDS_Start__c + '_' + configurazione.PTF_Filiale_StessoMicroMercato__c + '_' + configurazione.PTF_Filiale_StessaArea__c + '_' + configurazione.PTF_Filiale_StessaDR__c + '_' + configurazione.PTF_Abi__c;
                        filialeConfigurazioniMap.put(key, configurazione);
                    }else{
    
                        for(String mds : modelloDiServizioList){
                            
                            String key = configurazione.PTF_StessoReferente__c ? configurazione.PTF_Filiale_Start__c + '_' + configurazione.PTF_Filiale_End__c + '_' + mds + '_' + configurazione.PTF_StessoReferente__c + '_' + configurazione.PTF_Filiale_StessoMicroMercato__c + '_' + configurazione.PTF_Filiale_StessaArea__c + '_' + configurazione.PTF_Filiale_StessaDR__c + '_' + configurazione.PTF_Abi__c :
                            configurazione.PTF_Filiale_Start__c + '_' + configurazione.PTF_Filiale_End__c + '_' + mds + '_' + configurazione.PTF_Filiale_StessoMicroMercato__c + '_' + configurazione.PTF_Filiale_StessaArea__c + '_' + configurazione.PTF_Filiale_StessaDR__c + '_' + configurazione.PTF_Abi__c;
                            if(!filialeConfigurazioniMap.containsKey(key)){

                                branchEligible.add(configurazione.PTF_Filiale_End__c);
                                filialeConfigurazioniMap.put(key, configurazione);
                            }
                        }
                    }
                }else{

                    if(!String.isBlank(configurazione.PTF_CheckTipologiaFilialePartenza__c) && !String.isBlank(configurazione.PTF_CheckTipologiaFilialeDestinazione__c)){

                        for(String tipologiaFilialePartenza : configurazione.PTF_CheckTipologiaFilialePartenza__c.split(',')){
    
                            for(String tipologiaFilialeDestinazione : configurazione.PTF_CheckTipologiaFilialeDestinazione__c.split(',')){
                                
                                if(!String.isBlank(configurazione.PTF_MDS_Start__c)){
    
                                    branchEligible.add(tipologiaFilialeDestinazione);
                                    String key = configurazione.PTF_StessoReferente__c ? tipologiaFilialePartenza + '_' + tipologiaFilialeDestinazione + '_' + configurazione.PTF_MDS_Start__c + '_' + configurazione.PTF_StessoReferente__c + '_' + configurazione.PTF_Filiale_StessoMicroMercato__c + '_' + configurazione.PTF_Filiale_StessaArea__c + '_' + configurazione.PTF_Filiale_StessaDR__c + '_' + configurazione.PTF_Abi__c:
                                    tipologiaFilialePartenza + '_' + tipologiaFilialeDestinazione + '_' + configurazione.PTF_MDS_Start__c + '_' + configurazione.PTF_Filiale_StessoMicroMercato__c + '_' + configurazione.PTF_Filiale_StessaArea__c + '_' + configurazione.PTF_Filiale_StessaDR__c + '_' + configurazione.PTF_Abi__c;
                                    filialeConfigurazioniMap.put(key, configurazione);
                                }else{
    
                                    for(String mds : modelloDiServizioList){
    
                                        String key = configurazione.PTF_StessoReferente__c ? tipologiaFilialePartenza + '_' + tipologiaFilialeDestinazione + '_' + mds + '_' + configurazione.PTF_StessoReferente__c + '_' + configurazione.PTF_Filiale_StessoMicroMercato__c + '_' + configurazione.PTF_Filiale_StessaArea__c + '_' + configurazione.PTF_Filiale_StessaDR__c + '_' + configurazione.PTF_Abi__c:
                                        tipologiaFilialePartenza + '_' + tipologiaFilialeDestinazione + '_' + mds + '_' + configurazione.PTF_Filiale_StessoMicroMercato__c + '_' + configurazione.PTF_Filiale_StessaArea__c + '_' + configurazione.PTF_Filiale_StessaDR__c + '_' + configurazione.PTF_Abi__c;
                                        if(!filialeConfigurazioniMap.containsKey(key)){
        
                                            branchEligible.add(tipologiaFilialeDestinazione);
                                            filialeConfigurazioniMap.put(key, configurazione);
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
            for(ConfigurazioneSpostamenti__mdt configurazione : [ SELECT Id, MasterLabel, PTF_MDS_End__c, PTF_MDS_Start__c,
                                                        PTF_Abi__c, Finestra_Temporale__c, Iter_Approvativo__c,
                                                        PTF_Filiale_End__c, PTF_Filiale_Start__c, PTF_Filiale_StessaArea__c, PTF_Filiale_StessaDR__c,
                                                        PTF_Filiale_StessoMicroMercato__c, PTF_JSON_Approvatori__c, PTF_StessoReferente__c,
                                                        PTF_CheckNaturaGiuridica__c, PTF_CheckCedSpecifico__c, PTF_CheckTipologiaFilialeDestinazione__c, PTF_CheckTipologiaFilialePartenza__c, Tipo_di_Spostamento__c
                                                        ,PTF_SuperUsers__c
                                                        FROM ConfigurazioneSpostamenti__mdt
                                                        WHERE Tipo_di_Spostamento__c = 'Filiale' AND
                                                        PTF_CheckTipologiaFilialePartenza__c LIKE: branchTypeDesc AND
                                                        PTF_IsActive__c = true]){
                
                for(String tipologiaFilialePartenza : configurazione.PTF_CheckTipologiaFilialePartenza__c.split(',')){

                    for(String tipologiaFilialeDestinazione : configurazione.PTF_CheckTipologiaFilialeDestinazione__c.split(',')){
                        
                        if(!String.isBlank(configurazione.PTF_MDS_Start__c)){

                            branchEligible.add(tipologiaFilialeDestinazione);
                            String key = configurazione.PTF_StessoReferente__c ? tipologiaFilialePartenza + '_' + tipologiaFilialeDestinazione + '_' + configurazione.PTF_MDS_Start__c + '_' +  configurazione.PTF_StessoReferente__c + '_' + configurazione.PTF_Filiale_StessoMicroMercato__c + '_' + configurazione.PTF_Filiale_StessaArea__c + '_' + configurazione.PTF_Filiale_StessaDR__c + '_' + configurazione.PTF_Abi__c:
                            tipologiaFilialePartenza + '_' + tipologiaFilialeDestinazione + '_' + configurazione.PTF_MDS_Start__c + '_' + configurazione.PTF_Filiale_StessoMicroMercato__c + '_' + configurazione.PTF_Filiale_StessaArea__c + '_' + configurazione.PTF_Filiale_StessaDR__c + '_' + configurazione.PTF_Abi__c;
                            filialeConfigurazioniMap.put(key, configurazione);
                        }else{

                            for(String mds : modelloDiServizioList){

                                String key = configurazione.PTF_StessoReferente__c ? tipologiaFilialePartenza + '_' + tipologiaFilialeDestinazione + '_' + mds + '_' +  configurazione.PTF_StessoReferente__c + '_' + configurazione.PTF_Filiale_StessoMicroMercato__c + '_' + configurazione.PTF_Filiale_StessaArea__c + '_' + configurazione.PTF_Filiale_StessaDR__c + '_' + configurazione.PTF_Abi__c:
                                tipologiaFilialePartenza + '_' + tipologiaFilialeDestinazione + '_' + mds + '_' + configurazione.PTF_Filiale_StessoMicroMercato__c + '_' + configurazione.PTF_Filiale_StessaArea__c + '_' + configurazione.PTF_Filiale_StessaDR__c + '_' + configurazione.PTF_Abi__c;
                                if(!filialeConfigurazioniMap.containsKey(key)){

                                    branchEligible.add(tipologiaFilialeDestinazione);
                                    filialeConfigurazioniMap.put(tipologiaFilialePartenza + '_' + tipologiaFilialeDestinazione + '_' + mds + '_' + configurazione.PTF_Filiale_StessoMicroMercato__c + '_' + configurazione.PTF_Filiale_StessaArea__c + '_' + configurazione.PTF_Filiale_StessaDR__c + '_' + configurazione.PTF_Abi__c, configurazione);
                                }
                            }
                        }
                    }
                }
            }

            Map<String, ConfigurazioneSpostamenti__mdt> filialeMDSConfigurazioniMap = new Map<String, ConfigurazioneSpostamenti__mdt>();
            for(ConfigurazioneSpostamenti__mdt configurazione : [ SELECT Id, MasterLabel, PTF_MDS_End__c, PTF_MDS_Start__c,
                                                        PTF_Abi__c, Finestra_Temporale__c, Iter_Approvativo__c,
                                                        PTF_Filiale_End__c, PTF_Filiale_Start__c, PTF_Filiale_StessaArea__c, PTF_Filiale_StessaDR__c,
                                                        PTF_Filiale_StessoMicroMercato__c, PTF_JSON_Approvatori__c, PTF_StessoReferente__c,
                                                        PTF_CheckNaturaGiuridica__c, PTF_CheckCedSpecifico__c, PTF_CheckTipologiaFilialeDestinazione__c, PTF_CheckTipologiaFilialePartenza__c, Tipo_di_Spostamento__c
                                                        ,PTF_SuperUsers__c
                                                        FROM ConfigurazioneSpostamenti__mdt
                                                        WHERE Tipo_di_Spostamento__c = 'MDS / Filiale' AND
                                                        PTF_MDS_Start__c =: currentMDS AND
                                                        PTF_CheckTipologiaFilialePartenza__c LIKE: branchTypeDesc AND
                                                        PTF_IsActive__c = true]){
            
                for(String tipologiaFilialePartenza : configurazione.PTF_CheckTipologiaFilialePartenza__c.split(',')){

                    for(String tipologiaFilialeDestinazione : configurazione.PTF_CheckTipologiaFilialeDestinazione__c.split(',')){
                        
                        branchEligible.add(tipologiaFilialeDestinazione);
                        filialeMDSConfigurazioniMap.put(configurazione.PTF_MDS_Start__c + '_' + configurazione.PTF_MDS_End__c + '_' + tipologiaFilialePartenza + '_' + tipologiaFilialeDestinazione + '_' + configurazione.PTF_Filiale_StessoMicroMercato__c + '_' + configurazione.PTF_Filiale_StessaArea__c + '_' + configurazione.PTF_Filiale_StessaDR__c + '_' + configurazione.PTF_Abi__c, configurazione);
                    }
                }
            }

            Map<String, ConfigurazioneSpostamenti__mdt> referentiConfigurazioniMap = new Map<String, ConfigurazioneSpostamenti__mdt>();
            for(ConfigurazioneSpostamenti__mdt configurazione : [ SELECT Id, MasterLabel, PTF_MDS_End__c, PTF_MDS_Start__c,
                                PTF_Abi__c, Finestra_Temporale__c, Iter_Approvativo__c,
                                PTF_Filiale_End__c, PTF_Filiale_Start__c, PTF_Filiale_StessaArea__c, PTF_Filiale_StessaDR__c,
                                PTF_Filiale_StessoMicroMercato__c, PTF_JSON_Approvatori__c, PTF_StessoReferente__c,
                                PTF_CheckNaturaGiuridica__c, PTF_CheckTipologiaFilialeDestinazione__c, 
                                PTF_CheckCedSpecifico__c, PTF_CheckTipologiaFilialePartenza__c, Tipo_di_Spostamento__c
                                ,PTF_SuperUsers__c, Check_SegComp__c
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
            return new Map<String,Object> {
    
                'currentNDG' => currentNDG,
                'currentPF' => currentPF,
                'currentUser' => currentUser,
                'currentContact' => currentContact,
                'portafogliInEvidenza' => portafogliInEvidenza,
                'microportafogliCointestazioni' => microportafogliCointestazioni,
                'altriPortafogli' => altriPortafogli,
                'mdsPrimario' => mdsPrimario,
                'filialePrimario' => filialePrimario,
                'mdsCo' => mdsCo,
                'ruolo' => ruolo,
                'gruppoFinanziarioId' => gruppoFinanziarioId,
                'hasDifferent' => hasDifferent,
                'cointestazioni' => cointestazioniInSame,
                'microportafogliCointestazioniFiliali' => microportafogliCointestazioniFiliali,
                'mdsConfigurazioniMap' => mdsConfigurazioniMap,
                'filialeConfigurazioniMap' => filialeConfigurazioniMap,
                'filialeMDSConfigurazioniMap' => filialeMDSConfigurazioniMap,
                'referentiConfigurazioniMap' => referentiConfigurazioniMap,
                'branchEligible' => branchEligible,
                'servceModelMap' => servceModelMap,
                'modelloDiServizioList' => modelloDiServizioList,
                'addedHeap' => Limits.getHeapSize() - startingHeap,
                'heapSize' => Limits.getHeapSize()
            };
        }

    }

    @AuraEnabled
    public static String sendMovementRequest(String portafoglioDestinazione, List<Account> ndgList, Map<String, String> ndgIterTypeMap, Map<String, String> subjectMap, String note, Map<String, String> configurationKeyMap, List<String> primari, Map<String, String> accountKeyMap, Map<String, String> woStepMap, String ruolo, String gruppoFinanziarioId, String recordId, String referente, Boolean hasIter, String process, String motivazione, Boolean lineItemIter){
        
        Map<String, Object> requestBody = new Map<String, Object>{
            'portafoglioDestinazione' => portafoglioDestinazione,
            'referente' => referente,
            'ndgList' => ndgList,
            'ndgIterTypeMap' => ndgIterTypeMap,
            'subjectMap' => subjectMap,
            'note' => note,
            'ruolo' => ruolo,
            'gruppoFinanziarioId' => gruppoFinanziarioId,
            'currentNDGId' => recordId,
            'ownerId' => UserInfo.getUserId(),
            'configurationKeyMap' => configurationKeyMap,
            'primari' => primari,
            'accountKeyMap' => accountKeyMap,
            'woStepMap' => woStepMap,
            'hasIter' => hasIter,
            'process' => process,
            'motivazione' => motivazione,
            'lineItemIter' => lineItemIter
        };
        
        Http req = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint('callout:CallMeBack/services/apexrest/createQueues');
        request.setHeader('Content-Type', 'Application/JSON');
        request.setMethod('PATCH');
        request.setTimeout(120000);
        System.debug('DK requestBody: ' + JSON.serialize(requestBody));
        request.setBody(JSON.serialize(requestBody));

        HttpResponse resp = new HttpResponse();
        String responseBody = req.send(request).getBody();
        System.debug('Dk responseBody: ' + responseBody);
        Map<String, Object> response = (Map<String, Object>)JSON.deserializeUntyped((String)JSON.deserializeUntyped(responseBody));
        if(response.containsKey('errorMessage')){
    
            throw new AuraHandledException((String)response.get('errorMessage'));
        }
        return responseBody;
    }

    @AuraEnabled
    public static String createQueues(List<Account> accountList, Map<String, SObject> ndgIterMap, Wallet__c portafoglioDiPartenza, Wallet__c portafoglioDiDestinazione, Boolean hasIter, String process){

        // if(hasIter){
            
            Map<String, Object> requestBody = new Map<String, Object>{
                'accountList' => accountList,
                'ndgIterMap' => ndgIterMap,
                'portafoglioDiPartenza' => portafoglioDiPartenza,
                'portafoglioDiDestinazione' => portafoglioDiDestinazione,
                'hasIter' => hasIter,
                'process' => process
            };
            
            Http req = new Http();
            HttpRequest request = new HttpRequest();
            request.setEndpoint('callout:CallMeBack/services/apexrest/createQueues');
            request.setHeader('Content-Type', 'Application/JSON');
            request.setMethod('POST');
            request.setTimeout(120000);
            System.debug('DK requestBody: ' + JSON.serialize(requestBody));
            request.setBody(JSON.serialize(requestBody));
    
            HttpResponse resp = new HttpResponse();
            String responseBody = req.send(request).getBody();
            System.debug('DK responseBody: ' + responseBody);
            Map<String, Object> response = (Map<String, Object>)JSON.deserializeUntyped((String)JSON.deserializeUntyped(responseBody));
            if(response.containsKey('errorMessage')){
    
                throw new AuraHandledException(responseBody);
            }
            return responseBody;
        // }

        // return null;
    }
    
    @AuraEnabled
    public static void moveNdgsToWallet(String portafoglio, String filiale, List<String> primari, List<Account> ndgList){

        List<Account> ndgToUpdate = new List<Account>();
        Map<String,SObject> accountMap = SV_Utilities.keyBy(ndgList, 'Id');
        Map<String,String> primarioFilaileDestinazioneMap = new Map<String,String>();
        Set<String> primariSet = new Set<String>(primari);
        for(Account ndg : ndgList){

            if(ndg.RecordType.DeveloperName != 'GruppoFinanziario'){

                ndgToUpdate.add(new Account(id = ndg.Id, PTF_Portafoglio__c = portafoglio, PTF_Filiale__c = filiale));
            }

            if(primariSet.contains(ndg.id)){
                
                primarioFilaileDestinazioneMap.put(ndg.Id, ndg.PTF_Filiale__c);
            }
        }

        if(!primari.isEmpty()){

            for(CRM_AccountAccountJointOwnershipRelation__c giunzione : [SELECT id, CRM_Account__c, CRM_JointOwnership__r.PTF_Portafoglio__c, CRM_Active__c, CRM_PrimaryNDG__c, CRM_JointOwnership__c, CRM_JointOwnership__r.PTF_Portafoglio__r.PTF_Filiale__c
                                            FROM CRM_AccountAccountJointOwnershipRelation__c 
                                            WHERE CRM_Account__c IN: primari AND 
                                            CRM_JointOwnership__r.PTF_Portafoglio__c != '' AND
                                            CRM_Active__c = true AND
                                            CRM_PrimaryNDG__c = true
                                            ORDER BY CreatedDate DESC]){
                if((String)accountMap.get(giunzione.CRM_Account__c).get('PTF_Portafoglio__c') == giunzione.CRM_JointOwnership__r.PTF_Portafoglio__c){

                    ndgToUpdate.add(new Account(Id = giunzione.CRM_JointOwnership__c,
                    PTF_Portafoglio__c = portafoglio,
                    PTF_Filiale__c = filiale));
                }
            }
        }
        update ndgToUpdate;
    }

    @AuraEnabled
    public static Map<String,Object> loadNdgList(String gruppo, String recordId, Wallet__c portafoglio, Wallet__c currentPF, Integer pagesize, String naturaGiuridica){
        
        SpostaNdgIterDataLoader.currentMDS = currentPF.PTF_ModelloDiServizio__c;
        SpostaNdgIterDataLoader.currentBranchTypeDesc = currentPF.PTF_Filiale__r.PTF_BranchTypeDesc__c;
        Set<String> natureGiuridiche = new Set<String>{'PF', 'CO'};
        String query = '';
        Set<String> relatedAccountSet = SV_Utilities.keyBy([SELECT CRM_RelatedAccount__c FROM CRM_LinkedNDG__c WHERE CRM_Account__c =: gruppo AND CRM_LinkCode__c = '165'], 'CRM_RelatedAccount__c').keySet();

        eligibleIterMap = new Map<String, Boolean>();
        iterKeyListMap = new Map<String, Set<String>>();
        query = ' SELECT Id, Name, RecordType.DeveloperName, CRM_NDG__c, PTF_Filiale__c, ModelloDiServizio__c, PTF_Portafoglio__c, PTF_CapoGruppo__c, PTF_Gruppo__c, AnnualRevenue, PTF_Accordato__c, PTF_Patrimonio__c, PTF_Utilizzato__c,' + 
                ' PTF_NaturaGiuridica__c, PTF_Portafoglio__r.PTF_ModelloDiServizio__c, PTF_Portafoglio__r.PTF_Filiale__c, PTF_Portafoglio__r.PTF_Filiale__r.PTF_BranchTypeDesc__c, PTF_Filiale__r.PTF_BranchTypeDesc__c,' + 
                ' PTF_Portafoglio__r.PTF_DirezioneRegionale__r.PTF_DowngradeReqStartDate__c, PTF_Portafoglio__r.PTF_DirezioneRegionale__r.PTF_DowngradeReqEndDate__c,' + 
                ' PTF_Portafoglio__r.PTF_Banca__r.PTF_DowngradeReqStartDate__c, PTF_Portafoglio__r.PTF_Banca__r.PTF_DowngradeReqEndDate__c, PTF_Filiale__r.PTF_DowngradeReqStartDate__c, PTF_Filiale__r.PTF_DowngradeReqEndDate__c,' + 
                ' PTF_Portafoglio__r.PTF_Banca__c, PTF_Portafoglio__r.PTF_Capofila__c, ' + 
                ' PTF_Portafoglio__r.PTF_DirezioneRegionale__c, PTF_Portafoglio__r.PTF_Area__c, PTF_OFS__c, PTF_SegmentoComportamentale__c ' + 
                ' FROM Account WHERE id !=: recordId AND (Id =: gruppo OR Id IN: relatedAccountSet)';
        
        if(natureGiuridiche.contains(naturaGiuridica)){
            
            query += ' AND (PTF_NaturaGiuridica__c IN: natureGiuridiche OR RecordType.DeveloperName = \'GruppoFinanziario\') ';
        }else{

            query += ' AND (PTF_NaturaGiuridica__c NOT IN: natureGiuridiche OR RecordType.DeveloperName = \'GruppoFinanziario\') ';
        }
        List<Account> queryResult = Database.query(query);
        // List<Account> accountList = new List<Account>();
        Map<String, Sobject> portafoglioMap;
        if(!queryResult.isEmpty()){

            Set<String> portafogliIdSet = SV_Utilities.keyBy(queryResult, 'PTF_Portafoglio__c').KeySet();
            portafoglioMap = SV_Utilities.keyBy([SELECT Id, Name, PTF_ModelloDiServizio__c, PTF_UffPrivate__c, PTF_Filiale__r.PTF_UffPrivate__c, PTF_Filiale__r.PTF_IDCEDUffPrivate__c, PTF_UffPrivate__r.PTF_IdCedPadre__c,
            PTF_Filiale__c, PTF_Filiale__r.PTF_BranchTypeDesc__c, PTF_Filiale__r.PTF_BranchTypologyMap__c, PTF_Filiale__r.Name, PTF_FIliale__r.PTF_IdCed__c, PTF_Capofila__c, PTF_Capofila__r.PTF_IdCed__c,
            PTF_Banca__c, PTF_Banca__r.FinServ__BankNumber__c, PTF_Banca__r.PTF_DowngradeReqStartDate__c, PTF_Banca__r.PTF_DowngradeReqEndDate__c, PTF_Banca__r.PTF_IdCed__c,PTF_StatoAssegnazione__c,
            PTF_DirezioneRegionale__r.PTF_IdCed__c, PTF_Area__r.PTF_IdCed__c, PTF_DirezioneRegionale__c, PTF_Area__c, Owner.Name, PTF_Fatturato__c, PTF_Patrimonio__c, PTF_Utilizzato__c, PTF_Accordato__c,
            PTF_DirezioneRegionale__r.PTF_DowngradeReqStartDate__c, PTF_DirezioneRegionale__r.PTF_DowngradeReqEndDate__c, PTF_Filiale__r.PTF_DowngradeReqStartDate__c, PTF_Filiale__r.PTF_DowngradeReqEndDate__c,
            (SELECT id, PTF_Gestore__c, PTF_Gestore__r.PTF_OFS__c, PTF_Gestore__r.Name FROM Backup_Assignments__r WHERE RecordType.DeveloperName = 'Primario' AND PTF_EndDate__c = null)
            FROM Wallet__c WHERE Id IN: portafogliIdSet AND RecordType.developerName != 'TechnicalWallet'], 'Id');
            System.debug('DK portafoglioMap: ' + JSON.serialize(portafoglioMap));
            /*for(Account ndg : queryResult){
                
                if(ndg.Recordtype.DeveloperName != 'GruppoFinanziario'){

                    if(currentUser.Profilo__c == 'NEC_D.0'){
                        
                        if(SpostaNdgIterDataLoader.checkEligibleSuperUser(portafoglio, ndg)){
        
                            accountList.add(ndg);
                        }
                    }else{
                        System.debug('DK ndg.PTF_Portafoglio__c: ' + ndg.PTF_Portafoglio__c);
                        if(portafoglioMap.containsKey(ndg.PTF_Portafoglio__c)){

                            if(SpostaNdgIterDataLoader.checkEligible(portafoglio, ndg, (Wallet__c)portafoglioMap.get(ndg.PTF_Portafoglio__c))){
            
                                accountList.add(ndg);
                            }
                        }
                    }
                }else{

                    accountList.add(ndg);
                }
            }*/
        }
        
        return new Map<String, Object>{
            // 'ndgListCount' => accountList.size(),
            'ndgList' => queryResult,
            'portafoglioMap' => portafoglioMap
        };
    }

    @AuraEnabled
    public static void approveWorkOrders(List<String> workOrderIdSet){
        try {
            
            List<WorkOrder> woToUpdate = new List<WorkOrder>();
            for(String woId : workOrderIdSet){

                woToUpdate.add(new WorkOrder(Id = woId, Status = 'Approvato'));
            }

            update woToUpdate;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    public static void testRun() {
        Integer i = 0;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
    }
}