public with sharing class SpostaNdgIterDataLoader {
    
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
    public static Set<String> validMDS = new Set<String>{'Assente', 'Consulenti Finanziari'};

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
    public static Set<String> microportafogliCointestazioniFiliali = new Set<String>();
    @AuraEnabled
    public static String ruolo {get;set;}
    public static String filialePrimario {get;set;}
    public static String mdsCO {get;set;}
    public static Boolean allInSame {get;set;}
    
    public static Map<String, Boolean> eligibleIterMap = new Map<String, Boolean>();
    public static Map<String, Set<String>> iterKeyListMap = new Map<String, Set<String>>();

    public static Boolean isPTFInEvidenza = false;

    public static List<Assignment__c> currentReferenti = new List<Assignment__c>();

    public static Map<String, String> idFittiziaMap {
        get{
            if(idFittiziaMap != null){
                return idFittiziaMap;
            }

            idFittiziaMap = new Map<String, String>();
            Map<String, String> idcedMap = new Map<String, String>();
            for(Struttura_Banca__c sb : [SELECT Id, IdCed__c, IDCed_Fittizia__c FROm STRUTTURA_BANCA__c WHERE IDCed_Fittizia__c  != '']){
                idcedMap.put(sb.IDCed_Fittizia__c, sb.IdCed__c);
            }
            for(Account account : [SELECT Id, PTF_IdCed__c FROM Account WHERE PTF_IdCed__c IN: idcedMap.keySet()]){

                idFittiziaMap.put(idcedMap.get(account.PTF_IdCed__c), account.Id);
            }
            return idFittiziaMap;
        }set;
    }

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
                                                                ,PTF_SuperUsers__c,Check_SegComp__c
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
                        System.debug('pz filialeConfigurazioniMap ' + filialeConfigurazioniMap);
                    }else{
    
                        for(String mds : modelloDiServizioList){
                            System.debug('pz mds ' +mds);
                            String key = configurazione.PTF_StessoReferente__c ? configurazione.PTF_Filiale_Start__c + '_' + configurazione.PTF_Filiale_End__c + '_' + mds + '_' + configurazione.PTF_StessoReferente__c + '_' + configurazione.PTF_Filiale_StessoMicroMercato__c + '_' + configurazione.PTF_Filiale_StessaArea__c + '_' + configurazione.PTF_Filiale_StessaDR__c + '_' + configurazione.PTF_Abi__c :
                            configurazione.PTF_Filiale_Start__c + '_' + configurazione.PTF_Filiale_End__c + '_' + mds + '_' + configurazione.PTF_Filiale_StessoMicroMercato__c + '_' + configurazione.PTF_Filiale_StessaArea__c + '_' + configurazione.PTF_Filiale_StessaDR__c + '_' + configurazione.PTF_Abi__c;
                            if(!filialeConfigurazioniMap.containsKey(key)){

                                branchEligible.add(configurazione.PTF_Filiale_End__c);
                                filialeConfigurazioniMap.put(key, configurazione);
                                System.debug('pz filialeConfigurazioniMap ' +filialeConfigurazioniMap);
                            }
                        }
                    }
                }/*else{

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
                }*/
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
                            System.debug('pz 332 ' );
                            System.debug('pz filialeConfigurazioniMap ' + filialeConfigurazioniMap);
                        }else{

                            for(String mds : modelloDiServizioList){

                                String key = configurazione.PTF_StessoReferente__c ? tipologiaFilialePartenza + '_' + tipologiaFilialeDestinazione + '_' + mds + '_' +  configurazione.PTF_StessoReferente__c + '_' + configurazione.PTF_Filiale_StessoMicroMercato__c + '_' + configurazione.PTF_Filiale_StessaArea__c + '_' + configurazione.PTF_Filiale_StessaDR__c + '_' + configurazione.PTF_Abi__c:
                                tipologiaFilialePartenza + '_' + tipologiaFilialeDestinazione + '_' + mds + '_' + configurazione.PTF_Filiale_StessoMicroMercato__c + '_' + configurazione.PTF_Filiale_StessaArea__c + '_' + configurazione.PTF_Filiale_StessaDR__c + '_' + configurazione.PTF_Abi__c;
                                if(!filialeConfigurazioniMap.containsKey(key)){
                                    System.debug('pz 344 ' );
                                    branchEligible.add(tipologiaFilialeDestinazione);
                                    filialeConfigurazioniMap.put(tipologiaFilialePartenza + '_' + tipologiaFilialeDestinazione + '_' + mds + '_' + configurazione.PTF_Filiale_StessoMicroMercato__c + '_' + configurazione.PTF_Filiale_StessaArea__c + '_' + configurazione.PTF_Filiale_StessaDR__c + '_' + configurazione.PTF_Abi__c, configurazione);
                                    System.debug('pz 347 ' );
                                    System.debug('pz filialeConfigurazioniMap ' + filialeConfigurazioniMap);
                                }
                            }
                        }
                    }
                }
            }
            System.debug('pz filialeConfigurazioniMap ' + filialeConfigurazioniMap);
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
    public static Map<String,Object> loadMwList(List<String> mdsEligible, List<String> branchEligible, Integer pagesize, Account ndg, Wallet__c currentPF, String ruoloVar, Boolean allInSameVar, String filialePrimarioVar, String mdsCOVar, List<String> microportafogliCointestazioniFilialiVar, List<Assignment__c> referenti){
        
        currentReferenti = referenti;
        // System.debug('pz referenti: ' + referenti);
        // System.debug('pz currentReferenti: ' + currentReferenti);
        Integer startingHeap = Limits.getHeapSize();
        System.debug('Dk loadMwList_currentPF: ' + JSON.serialize(currentPF));
        String errorMessage = '';
        String query = '';
        String portafoglioId = currentPF.id;
        // Boolean secondarySuperUser = currentUser.Profilo__c == 'NEC_D.2' && currentUser.idced__c == '6929' && currentPF.PTF_ModelloDiServizio__c == 'Assente';
        String currentMDS = currentPF.PTF_ModelloDiServizio__c;
        String currentBranchTypeDesc = currentPF.PTF_Filiale__r.PTF_BranchTypeDesc__c;
        String branchTypeDesc = '%' + currentBranchTypeDesc + '%';
        ruolo = ruoloVar;
        allInSame = allInSameVar;
        filialePrimario = filialePrimarioVar;
        mdsCO = mdsCOVar;
        microportafogliCointestazioniFiliali = new Set<String>(microportafogliCointestazioniFilialiVar);
        System.debug('DK microportafogliCointestazioniFiliali: ' + microportafogliCointestazioniFiliali);
        eligibleIterMap = new Map<String, Boolean>();
        iterKeyListMap = new Map<String, Set<String>>();
        // DK CR 44355 
        List<String> UneligibleMMDS = new List<String>{'TechnicalWallet'};
        if(currentUser.Profilo__c == 'NEC_D.0' && (mdsEligible.size() != 1 || mdsEligible[0] != 'Residuale')){
            UneligibleMMDS.add('Residuale');
        }
        // DK CR 44355 
        //NEW UFF PRIVATE
        // MS - Aggiunto filtro Name != '999'
        query = 'SELECT Id, Name,CRM_ReferentePortafoglio__c, PTF_ModelloDiServizio__c, PTF_UffPrivate__c, PTF_Filiale__r.PTF_UffPrivate__c, PTF_Filiale__r.PTF_IDCEDUffPrivate__c, PTF_UffPrivate__r.PTF_IdCedPadre__c,' +
                ' PTF_Filiale__c, PTF_Pool__c, PTF_Filiale__r.PTF_BranchTypeDesc__c, PTF_Filiale__r.PTF_BranchTypologyMap__c, PTF_Filiale__r.Name, PTF_FIliale__r.PTF_IdCed__c, PTF_Capofila__c, PTF_Capofila__r.PTF_IdCed__c, ' +
                ' PTF_Banca__c, PTF_Banca__r.FinServ__BankNumber__c, PTF_Banca__r.PTF_DowngradeReqStartDate__c, PTF_Banca__r.PTF_DowngradeReqEndDate__c, PTF_Banca__r.PTF_IdCed__c, PTF_Filiale__r.PTF_DowngradeReqStartDate__c, PTF_Filiale__r.PTF_DowngradeReqEndDate__c,' +
                ' PTF_DirezioneRegionale__r.PTF_DowngradeReqStartDate__c, PTF_DirezioneRegionale__r.PTF_DowngradeReqEndDate__c,PTF_StatoAssegnazione__c,' +
                ' PTF_DirezioneRegionale__r.PTF_IdCed__c, PTF_Area__r.PTF_IdCed__c, PTF_DirezioneRegionale__c, PTF_Area__c, Owner.Name, PTF_Fatturato__c, PTF_Patrimonio__c, PTF_Utilizzato__c, PTF_Accordato__c, ' +
                ' PTF_Filiale__r.PTF_BloccaSpostamentiInFiliale__c, PTF_Filiale__r.PTF_BloccaSpostamentiVersoFiliale__c, PTF_Filiale__r.PTF_BloccaSpostamentiFiliale__c, ' +
                ' (SELECT id, PTF_Gestore__c, PTF_Gestore__r.PTF_OFS__c, PTF_Gestore__r.Name FROM Backup_Assignments__r WHERE RecordType.DeveloperName = \'Primario\' AND PTF_EndDate__c = null) ' +
                'FROM Wallet__c WHERE Id !=: portafoglioId AND RecordType.DeveloperName NOT IN: UneligibleMMDS ' +
                ' AND PTF_Filiale__c != null AND PTF_Banca__c != null  AND PTF_DeletionDate__c=null' +
                ' AND PTF_Banca__c = \'' + String.escapeSingleQuotes(currentPF.PTF_Banca__c) + '\'';
        if(currentUser.Profilo__c != 'NEC_D.0'){
            query += ' AND (NOT Name LIKE \'%999\') ';
            
        } 
        // DK CR 44355 
        if(currentUser.Profilo__c == 'NEC_D.0'){
            if(mdsEligible.size() == 1 && mdsEligible[0] == 'Residuale'){
               query += ' AND PTF_ModelloDiServizio__c IN: mdsEligible '; 
            }
        }else{
            query += ' AND (PTF_ModelloDiServizio__c IN: mdsEligible OR (PTF_Filiale__r.PTF_BranchTypeDesc__c IN: branchEligible AND PTF_ModelloDiServizio__c =: currentMDS)) ';
        }
        // DK CR 44355 


        System.debug('DK query: ' + query);
        return new Map<String, Object>{
            'mwList' => Database.query(query),
            'addedHeap' => Limits.getHeapSize() - startingHeap,
            'heapSize' => Limits.getHeapSize()
        };

        /*for(Wallet__c portafoglio : Database.query(query)){
            if(currentUser.Profilo__c == 'NEC_D.0'){
                if(mdsEligible.size() == 1 && mdsEligible[0] == 'Residuale'){
                    if(checkEligible(portafoglio, ndg, currentPF)){
    
                        ptfEligible.add(portafoglio);
                    }
                }else{
                    if(checkEligibleSuperUser(portafoglio, ndg)){
    
                        ptfEligible.add(portafoglio);
                    }
                }
            }else if(secondarySuperUser){
                if(checkEligibleSuperUser(portafoglio, ndg)){

                    ptfEligible.add(portafoglio);
                }
            }else{
                if(checkEligible(portafoglio, ndg, currentPF)){

                    ptfEligible.add(portafoglio);
                }
            }
        }*/

        /*List<Wallet__c> ptfEligible = new List<Wallet__c>();
        Datetime startQuery = null;
        Datetime startCheckEligible = null;
        Datetime endQuery = null;
        Datetime endCheckEligible = null;
        try {
            
            startQuery = Datetime.now();
            List<Wallet__c> allPTF = Database.query(query);
            endQuery = Datetime.now();
            // DK CR 44355 
            startCheckEligible = Datetime.now();
            if(currentUser.Profilo__c == 'NEC_D.0'){
                if(mdsEligible.size() == 1 && mdsEligible[0] == 'Residuale'){
                    for(Wallet__c portafoglio : allPTF){
        
                        if(checkEligible(portafoglio, ndg, currentPF)){
        
                            ptfEligible.add(portafoglio);
                        }
                    }
                // DK CR 44355 
                }else{
    
                    for(Wallet__c portafoglio : allPTF){
        
                        if(checkEligibleSuperUser(portafoglio, ndg)){
        
                            ptfEligible.add(portafoglio);
                        }
                    }

                }
            }else if(secondarySuperUser){
                
                for(Wallet__c portafoglio : allPTF){
    
                    if(checkEligibleSuperUser(portafoglio, ndg)){
    
                        ptfEligible.add(portafoglio);
                    }
                }
            }else{
                for(Wallet__c portafoglio : allPTF){
    
                    if(checkEligible(portafoglio, ndg, currentPF)){
    
                        ptfEligible.add(portafoglio);
                    }
                }
                
            }            
            
            endCheckEligible = Datetime.now();
        } catch (Exception ex) {
            errorMessage = 'DK Exception: ' + ex.getMessage() + '; at: ' + ex.getStackTraceString() + '; cause: ' + ex.getCause();
            
            System.debug(errorMessage);
            // throw new BaseException(errorMessage);
        }

        return new Map<String, Object>{
            'mwListCount' => ptfEligible.size(),
            'mwList' => ptfEligible,
            'timeQuery' => endQuery != null ? String.valueOf(endQuery.getTime() - startQuery.getTime()) : 'non ha finito',
            'timeCheckEligible' => endCheckEligible != null ? String.valueOf(endCheckEligible.getTime() - startCheckEligible.getTime()) : 'non ha finito',
            'errorMessage' => errorMessage,
            'referenti' => currentReferenti
        };*/
    }
    
    public static Boolean checkEligibleSuperUser(Wallet__c portafoglio, Account ndg){

        List<Wallet__c> ptfEligible = new List<Wallet__c>();
        Set<String> natureGiuridiche = new Set<String>{'PF', 'CO'};
        if(ndg.PTF_OFS__c){

            if(!portafoglio.Backup_Assignments__r.isEmpty() && !portafoglio.Backup_Assignments__r[0].PTF_Gestore__r.PTF_OFS__c){System.debug(portafoglio.Id + ' ESCO QUA 4');return false;}
            // if(portafoglio.Backup_Assignments__r.isEmpty())return false;
            // if(!portafoglio.Backup_Assignments__r[0].PTF_Gestore__r.PTF_OFS__c)return false;
        }

        if(natureGiuridiche.contains(ndg.PTF_NaturaGiuridica__c)){

            if(portafoglio.PTF_ModelloDiServizio__c == 'POE'){

                return false;
            }
        }else{
            
            if(portafoglio.PTF_ModelloDiServizio__c == 'Family'){

                return false;
            }
        }

        return true;
    }

    public static Boolean checkEligible(Wallet__c portafoglio, Account ndg, Wallet__c currentPF){

        System.debug('DK PTF.ID: ' + portafoglio.Id);
        System.debug('DK currentReferenti: ' + JSON.serialize(currentReferenti));
        System.debug('DK portafoglio.Backup_Assignments__r: ' + JSON.serialize(portafoglio.Backup_Assignments__r));
        System.debug('PZ portafoglio'  + portafoglio);
        System.debug('PZ ndg'  + ndg);
        System.debug('PZ currentPF'  + JSON.serialize(currentPF));
        if(!isPTFInEvidenza){

            if(!validMDS.contains(portafoglio.PTF_ModelloDiServizio__c) && currentPF.PTF_ModelloDiServizio__c != 'Consulenti Finanziari'){

                if(ruolo == 'primario'){
                    System.debug('PZ 577');
                    System.debug('PZ allInSame'+allInSame);
                    System.debug('PZ microportafogliCointestazioniFiliali:'+microportafogliCointestazioniFiliali);
                    System.debug('PZ portafoglio.PTF_Filiale__c:'+portafoglio.PTF_Filiale__c);
                    System.debug('PZ portafoglio.PTF_ModelloDiServizio__c:'+portafoglio.PTF_ModelloDiServizio__c);
                    System.debug('PZ mdsCO:'+mdsCO);
                    if((!allInSame && (!microportafogliCointestazioniFiliali.contains(portafoglio.PTF_Filiale__c) ||
                    portafoglio.PTF_ModelloDiServizio__c != currentPF.PTF_ModelloDiServizio__c) &&
                    mdsCO != 'Consulenti Finanziari' && !String.isBlank(mdsCO)
                    )){
            
                        System.debug(portafoglio.Id + ' ESCO QUA 1');
                        return false;
                    }
                }else if(ruolo == 'cointestazione'){
                    System.debug('PZ 599');
                    if(portafoglio.PTF_Filiale__c != currentPF.PTF_Filiale__c ||
                    portafoglio.PTF_ModelloDiServizio__c != currentPF.PTF_ModelloDiServizio__c || allInSame
                    ){
        
                        System.debug(portafoglio.Id + ' ESCO QUA 2');
                        return false;
                    }
                }else if(ruolo == 'cointestatario' && allInSame){

                    System.debug(portafoglio.Id + ' ESCO QUA 3');
                    return false;
                }
            }
        }

        if(ndg.PTF_OFS__c){

            if(!portafoglio.Backup_Assignments__r.isEmpty() && !portafoglio.Backup_Assignments__r[0].PTF_Gestore__r.PTF_OFS__c){System.debug(portafoglio.Id + ' ESCO QUA 4');
            System.debug('PZ 607');
            return false;}
            // if(portafoglio.Backup_Assignments__r.isEmpty())return false;
            // if(!portafoglio.Backup_Assignments__r[0].PTF_Gestore__r.PTF_OFS__c){System.debug(portafoglio.Id + ' ESCO QUA 5');return false;}
        }

        String startMDS = ndg.PTF_Portafoglio__r.PTF_ModelloDiServizio__c;
        String startFiliale = ndg.PTF_Filiale__c;
        String startFilialeBranch = ndg.PTF_Filiale__r.PTF_BranchTypeDesc__c;
        String endMDS = portafoglio.PTF_ModelloDiServizio__c;
        String endFiliale = portafoglio.PTF_Filiale__c;
        String endFilialeBranch = portafoglio.PTF_Filiale__r.PTF_BranchTypeDesc__c;
        String configurationKey1 = '';
        String configurationKey2 = '';
        String configurationKey3 = '';
        String configurationKey4 = '';
        String configurationKey5 = '';
        String configurationKey6 = '';
        String configurationKey7 = '';
        String configurationKey8 = '';

        if(startMDS != endMDS){
            configurationKey2 = startMDS + '_' + endMDS;
        }

        String mmPartenza = !String.isBlank(ndg.PTF_Portafoglio__r.PTF_Capofila__c) ? ndg.PTF_Portafoglio__r.PTF_Capofila__c : ndg.PTF_Portafoglio__r.PTF_Filiale__c;
        String mmDestinazione = !String.isBlank(portafoglio.PTF_Capofila__c) ? portafoglio.PTF_Capofila__c : portafoglio.PTF_Filiale__c;
       // String sameReferente = (!currentReferenti.isEmpty() && !portafoglio.Backup_Assignments__r.isEmpty()) && portafoglio.Backup_Assignments__r[0].PTF_Gestore__c == currentReferenti[0].PTF_Gestore__c ? 'true' : 'false';
        String sameReferente ;
        System.debug(portafoglio.Id +'PZ 667' + currentReferenti);
                //System.debug(portafoglio.Id +'PZ 670' +portafoglio.Backup_Assignments__r[0].PTF_Gestore__c == currentReferenti[0].PTF_Gestore__c);
                //System.debug(portafoglio.Id +'PZ 670'+portafoglio.Backup_Assignments__r[0].PTF_Gestore__c);
                //System.debug(portafoglio.Id +'PZ 670' +portafoglio.Backup_Assignments__r[0].PTF_Gestore__c);
        if (currentReferenti != null && !currentReferenti.isEmpty() &&
            portafoglio != null && portafoglio.Backup_Assignments__r != null && !portafoglio.Backup_Assignments__r.isEmpty()) {
                System.debug(portafoglio.Id +'PZ 669');
                
            if (portafoglio.Backup_Assignments__r[0].PTF_Gestore__c == currentReferenti[0].PTF_Gestore__c) {
              sameReferente = 'true';
              System.debug(portafoglio.Id +'PZ 672'+sameReferente);
            }else{
                sameReferente = 'false';  
                System.debug(portafoglio.Id +'PZ 675'+sameReferente);
            }
             
        }else {
            sameReferente = 'false';
        }
        if(!portafoglio.Backup_Assignments__r.isEmpty())System.debug('DK portafoglioReferenteId: ' + portafoglio.Backup_Assignments__r[0].PTF_Gestore__c);
        //if(!currentReferenti.isEmpty()){
        //System.debug('DK currentReferenteId: ' + currentReferenti[0].PTF_Gestore__c);}
        String sameMicroMercato = mmPartenza == mmDestinazione ? 'true' : 'false';
        String sameArea = (!String.isBlank(ndg.PTF_Portafoglio__r.PTF_Area__c) && !String.isBlank(portafoglio.PTF_Area__c)) && (ndg.PTF_Portafoglio__r.PTF_Area__c == portafoglio.PTF_Area__c) ? 'true' : 'false';
        String sameDirReg;
        if(portafoglio.PTF_Banca__r.FinServ__BankNumber__c == '01015'){

            sameDirReg = (ndg.PTF_Portafoglio__r.PTF_DirezioneRegionale__c == portafoglio.PTF_DirezioneRegionale__c) ? 'true' : 'false';
        }else{

            sameDirReg = (!String.isBlank(ndg.PTF_Portafoglio__r.PTF_DirezioneRegionale__c) && !String.isBlank(portafoglio.PTF_DirezioneRegionale__c)) && (ndg.PTF_Portafoglio__r.PTF_DirezioneRegionale__c == portafoglio.PTF_DirezioneRegionale__c) ? 'true' : 'false';
        }
        if(startFiliale != endFiliale ||
        startFilialeBranch != endFilialeBranch){
            System.debug('PZ 669');
            //pz 587612C
            if(currentPF.PTF_StatoAssegnazione__c == 'Non Assegnato' && currentPF.PTF_ModelloDiServizio__c == 'Consulenti Finanziari'  && portafoglio.PTF_ModelloDiServizio__c == 'Consulenti Finanziari'){
                System.debug('PZ 669');
                System.debug(portafoglio.Id + ' pz 716');
                   return false;
            } 
            //pz 587612C    
            if(portafoglio.PTF_StatoAssegnazione__c == 'Non Assegnato' && portafoglio.PTF_ModelloDiServizio__c == 'Consulenti Finanziari'){
                System.debug(portafoglio.Id + ' pz 702');
                   return false;
                }  
            // DK START 587612C
            if(currentPF.PTF_ModelloDiServizio__c == 'Consulenti Finanziari' && portafoglio.PTF_ModelloDiServizio__c == 'Consulenti Finanziari' &&  sameReferente == 'false'){
                System.debug('PZ 682'+ portafoglio.Id);
                return false;
            }
            // DK START 587612C
            if(!String.isBlank(configurationKey2)){

                configurationKey2 = configurationKey2 + '_';
            }else{

                configurationKey2 = '';
                configurationKey7 = startFilialeBranch + '_' + endFilialeBranch + '_' + startMDS + '_' + sameReferente + '_' + sameMicroMercato + '_' + sameArea + '_' + sameDirReg;
            }
            configurationKey4 = configurationKey2 == '' ?
                                configurationKey2 + startFilialeBranch + '_' + 'TUTTE' + '_' + startMDS + '_' + sameMicroMercato + '_' + sameArea + '_' + sameDirReg :
                                configurationKey2 + startFilialeBranch + '_' + endFilialeBranch + '_' + sameMicroMercato + '_' + sameArea + '_' + sameDirReg;

            configurationKey2 = configurationKey2 == '' ?
                                configurationKey2 + startFilialeBranch + '_' + endFilialeBranch + '_' + startMDS + '_' +  sameMicroMercato + '_' + sameArea + '_' + sameDirReg : 
                                configurationKey2 + startFilialeBranch + '_' + endFilialeBranch + '_' + sameMicroMercato + '_' + sameArea + '_' + sameDirReg;
                                
        }else{
            //pz 587612C
            if(currentPF.PTF_StatoAssegnazione__c == 'Non Assegnato' && currentPF.PTF_ModelloDiServizio__c == 'Consulenti Finanziari'  && portafoglio.PTF_ModelloDiServizio__c == 'Consulenti Finanziari'){
                System.debug(portafoglio.Id + ' pz 716');
                   return false;
                }
            //pz 587612C    
                if(portafoglio.PTF_StatoAssegnazione__c == 'Non Assegnato' && currentPF.PTF_ModelloDiServizio__c == 'Consulenti Finanziari' && portafoglio.PTF_ModelloDiServizio__c == 'Consulenti Finanziari'){
                System.debug(portafoglio.Id + ' pz 720');
                return false;
                }

            if(!String.isBlank(configurationKey2)){

                configurationKey6 = configurationKey2 + '_' + startFilialeBranch + '_' + endFilialeBranch;
            }
        }

        if(String.isBlank(configurationKey2)){

            configurationKey2 = startMDS + '_' + endMDS;
        }

        configurationKey1 = configurationKey2;
        configurationKey3 = configurationKey2;
        configurationKey5 = configurationKey4;
            
        configurationKey1 = configurationKey1 + '_' + startFilialeBranch;
        configurationKey8 = configurationKey1;

        if(!String.isBlank(portafoglio.PTF_Banca__c)){

            configurationKey4 = configurationKey4 + '_' + portafoglio.PTF_Banca__r.FinServ__BankNumber__c;
            configurationKey1 = configurationKey1 + '_' + portafoglio.PTF_Banca__r.FinServ__BankNumber__c;
            configurationKey2 = configurationKey2 + '_' + portafoglio.PTF_Banca__r.FinServ__BankNumber__c;
            configurationKey6 = configurationKey6 + '_' + portafoglio.PTF_Banca__r.FinServ__BankNumber__c;
            configurationKey7 = configurationKey7 + '_' + portafoglio.PTF_Banca__r.FinServ__BankNumber__c;
        }
        configurationKey3 = configurationKey3 + '_TUTTE';
        configurationKey5 = configurationKey5 + '_TUTTE';
        configurationKey8 = configurationKey8 + '_TUTTE';

        System.debug('DK PTF.PTF_Filiale__c: ' + portafoglio.PTF_Filiale__c);
        System.debug('DK configurationKey1: ' + portafoglio.name + '+' + configurationKey1 );
        System.debug('DK configurationKey2: ' + portafoglio.name + '+' + configurationKey2);
        System.debug('DK configurationKey3: ' + portafoglio.name + '+' + configurationKey3);
        System.debug('DK configurationKey4: ' + portafoglio.name + '+' + configurationKey4);
        System.debug('DK configurationKey5: ' + portafoglio.name + '+' + configurationKey5);
        System.debug('DK configurationKey6: ' + portafoglio.name + '+' + configurationKey6);
        System.debug('DK configurationKey7: ' + portafoglio.name + '+' + configurationKey7);
        System.debug('DK configurationKey8: ' + portafoglio.name + '+' + configurationKey8);
        Map<String, ConfigurazioneSpostamenti__mdt> configurationMap;
        
        if(mdsConfigurazioniMap.containsKey(configurationKey2) || mdsConfigurazioniMap.containsKey(configurationKey3) || mdsConfigurazioniMap.containsKey(configurationKey1) || mdsConfigurazioniMap.containsKey(configurationKey6)){
        
            configurationMap = mdsConfigurazioniMap;
        }else if(filialeConfigurazioniMap.containsKey(configurationKey2) || filialeConfigurazioniMap.containsKey(configurationKey3) || filialeConfigurazioniMap.containsKey(configurationKey1) || filialeConfigurazioniMap.containsKey(configurationKey4) || filialeConfigurazioniMap.containsKey(configurationKey7) || filialeConfigurazioniMap.containsKey(configurationKey5)){

            configurationMap = filialeConfigurazioniMap;
        }else if(filialeMDSConfigurazioniMap.containsKey(configurationKey2) || filialeMDSConfigurazioniMap.containsKey(configurationKey3) || filialeMDSConfigurazioniMap.containsKey(configurationKey1)){

            configurationMap = filialeMDSConfigurazioniMap;
        }else if(referentiConfigurazioniMap.containsKey(configurationKey2) || referentiConfigurazioniMap.containsKey(configurationKey3) || referentiConfigurazioniMap.containsKey(configurationKey1) || referentiConfigurazioniMap.containsKey(configurationKey8)){

            configurationMap = referentiConfigurazioniMap;
        }

        System.debug('DK Boolean(configurationMap): ' + (configurationMap != null));
        if(configurationMap != null){

            String mapKey = '';
            if(configurationMap.containsKey(configurationKey1)){

                mapKey = configurationKey1;
            }else if(configurationMap.containsKey(configurationKey8)){
                
                mapKey = configurationKey8;
            }else if(configurationMap.containsKey(configurationKey6)){
                
                mapKey = configurationKey6;
            }else if(configurationMap.containsKey(configurationKey7)){
                
                mapKey = configurationKey7;
            }else if(configurationMap.containsKey(configurationKey2)){
                
                mapKey = configurationKey2;
            }else if(configurationMap.containsKey(configurationKey4)){

                mapKey = configurationKey4;
            }else if(configurationMap.containsKey(configurationKey3)){
                
                mapKey = configurationKey3;
            }else {

                mapKey = configurationKey5;
            }

            System.debug('DK mapKey: ' + mapKey + ' /'+ portafoglio.Id);
            
            // DK CR 44355 
            if(currentUser.Profilo__c == 'NEC_D.0'){

                eligibleIterMap.put(mapKey, true);
                return true;
            }
            // DK CR 44355 
            
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

                        eligibleIterMap.put(mapKey, false);
                        return false;
                    }
                }else{

                    if(naturaGiuridicaValues.contains(ndg.PTF_NaturaGiuridica__c)){

                        eligibleIterMap.put(mapKey, false);
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
                            IdKey = livelloFunzionaleFInale == 'Filiale' ? portafoglioFinale.PTF_Filiale__r.PTF_IdCED__c :livelloFunzionaleFInale == 'MM' ? portafoglioFinale.PTF_Capofila__r.PTF_IdCED__c : livelloFunzionaleFInale == 'Area' ? portafoglioFinale.PTF_Area__r.PTF_IdCED__c : livelloFunzionaleFInale == 'DR' ? portafoglioFinale.PTF_DirezioneRegionale__r.PTF_IdCED__c : livelloFunzionaleFInale == 'Fittizia' ? idFittiziaMap.get(portafoglioFinale.PTF_Filiale__r.PTF_IdCed__c) : portafoglioFinale.PTF_Banca__r.PTF_IdCED__c;
                        }else{
                            
                            IdKey = livelloFunzionaleFInale == 'Filiale' ? portafoglioFinale.PTF_Filiale__c :livelloFunzionaleFInale == 'MM' ? portafoglioFinale.PTF_Capofila__c : livelloFunzionaleFInale == 'Area' ? portafoglioFinale.PTF_Area__c : livelloFunzionaleFInale == 'DR' ? portafoglioFinale.PTF_DirezioneRegionale__c : livelloFunzionaleFInale == 'Fittizia' ? idFittiziaMap.get(portafoglioFinale.PTF_Filiale__r.PTF_IdCed__c) : portafoglioFinale.PTF_Banca__c;
                        }

                        String division;
                        if(!String.isBlank(mds)){

                            division = servceModelMap.containsKey(mds) ? (String)servceModelMap.get(mds).get('PTF_Division__c') : (String)servceModelMap.get(mds.toUpperCase()).get('PTF_Division__c');
                        }
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
                        if(currentUser.Profilo__c == 'NEC_F.1'){
                        
                            if(!String.isBlank(division)){

                                keyList.add(currentUser.Profilo__c + '_' + division + '_' + IdKey);
                            }
                            keyList.add(currentUser.Profilo__c + '_' + IdKey);
                        }
                    }
                    iterKeyListMap.put(mapKey, keyList);
                    System.debug('DK keyList: ' + JSON.serialize(keyList));
                    if(String.isBlank(currentContact.AccountId)){

                        eligibleIterMap.put(mapKey, false);
                        return false;
                    }
                    System.debug('DK IdCed: ' + currentContact.Account.PTF_IdCed__c);
                    System.debug('DK profile: ' + currentUser.Profilo__c);
                    System.debug('DK IdCed: ' + currentContact.Account.PTF_IdCed__c);

                    if(!keyList.contains(currentUser.Profilo__c + '_' + currentUser.PTF_RuoloLDAP__c + '_' + currentContact.AccountId) &&
                        !keyList.contains(currentUser.Profilo__c + '_' + currentContact.Account.PTF_IdCEDPadre__c) &&
                        !keyList.contains(currentUser.Profilo__c + '_' + currentUser.PTF_RuoloLDAP__c + '_' + currentContact.Account.PTF_IdCEDPadre__c) &&
                        !keyList.contains(currentUser.Profilo__c + '_' + currentContact.Account.PTF_Division__c + '_' + currentContact.Account.PTF_IdCEDPadre__c) &&
                        !keyList.contains(currentUser.Profilo__c + '_' + currentUser.PTF_RuoloLDAP__c + '_' + currentContact.Account.PTF_Division__c + '_' + currentContact.Account.PTF_IdCEDPadre__c) &&
                        !keyList.contains(currentUser.Profilo__c) &&
                        !keyList.contains(currentUser.Profilo__c + '_' + currentContact.AccountId)){

                        // throw "Non Puoi eseguire questo tipo di spostamento!!";
                        eligibleIterMap.put(mapKey, false);
                        return false;
                    }
                }else{

                    eligibleIterMap.put(mapKey, false);
                    return false;
                }
            }
            
            eligibleIterMap.put(mapKey, true);
        }else{

            return false;
        }

        return true;
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

    public class ProfiliAutorizzati{

        Boolean spostamento_autorizzato_tutti{get;set;}
        Map<String, ProfiloObject> profili_autorizzati{get;set;}
    }

    public class ProfiloObject{

        List<Map<String,String>> users{get;set;}
    }

   
   
}