/**
* Controller of multipleAssignement LWC
*
* @author  Dam Kebe @Lutech
* @version 1.0
* @since   2020-07-08
*/
public without sharing class MultipleAssignmentController {
    
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

    /**
    * Updates Accounts by assigning new microwallet  
    *
    * @param params  JSON string containg following parameters
    *                   @ndgids: list of account Ids to update
    /                   @mwId: microWallet id
    * @return   void
    */
    @AuraEnabled
    public static void executeAssignment(String params) {
        
        AssignmentWrapper aw = (AssignmentWrapper) JSON.deserialize(params, AssignmentWrapper.Class);
        List<Account> accList = new List<Account>();
        for (String ndgId : aw.ndgIds) {
            Account acc = new Account(Id=ndgId, PTF_Portafoglio__c=aw.mwId);
            accList.add(acc);
        }
        update accList;
    }

    @AuraEnabled
    public static Map<String,Object> init(String recordId){

        Map<String,Object> mdsConfigurazioniMap = SV_Utilities.keyBy([SELECT Id, MasterLabel, PTF_MDS_End__c, PTF_MDS_Start__c,
                                                PTF_Abi__c, Finestra_Temporale__c, Iter_Approvativo__c,
                                                PTF_Filiale_End__c, PTF_Filiale_Start__c, PTF_JSON_Approvatori__c, PTF_StessoReferente__c,
                                                PTF_CheckNaturaGiuridica__c, PTF_CheckCedSpecifico__c, PTF_CheckTipologiaFilialeDestinazione__c, PTF_CheckTipologiaFilialePartenza__c, Tipo_di_Spostamento__c
                                                ,PTF_SuperUsers__c, Check_SegComp__c
                                                FROM ConfigurazioneSpostamenti__mdt
                                                WHERE Tipo_di_Spostamento__c = 'MDS' AND
                                                PTF_MDS_Start__c = 'Assente' AND
                                                PTF_IsActive__c = true], '{PTF_MDS_Start__c}_{PTF_MDS_End__c}_{PTF_Abi__c}', true);
        List<Contact> currentContactList = [SELECT Id, PTF_User__c, AccountId, Account.PTF_IdCEDPadre__c, Account.PTF_Division__c, Account.PTF_MacroDivision__c FROM Contact WHERE PTF_User__c =: UserInfo.getUserId() AND AccountId != '' ORDER BY CreatedDate DESC LIMIT 1];
        List<Wallet__c> currentPFList = [SELECT Id, Name, PTF_ModelloDiServizio__c,PTF_Pool__c, PTF_Filiale__r.PTF_UffPrivate__c, PTF_Filiale__r.PTF_IDCEDUffPrivate__c, PTF_Filiale__r.PTF_UffPrivate__r.PTF_IdCedPadre__c,
        PTF_Filiale__c, PTF_Filiale__r.PTF_BranchTypeDesc__c, PTF_Filiale__r.PTF_BranchTypologyMap__c, PTF_Filiale__r.Name, PTF_FIliale__r.PTF_IdCed__c, PTF_Capofila__c, PTF_Capofila__r.PTF_IdCed__c,
        PTF_Banca__c, PTF_Banca__r.FinServ__BankNumber__c, PTF_Banca__r.PTF_DowngradeReqStartDate__c, PTF_Banca__r.PTF_DowngradeReqEndDate__c, PTF_Banca__r.PTF_IdCed__c,
        PTF_DirezioneRegionale__r.PTF_IdCed__c, PTF_Area__r.PTF_IdCed__c, PTF_DirezioneRegionale__c, PTF_Area__c, Owner.Name, PTF_Fatturato__c, PTF_Patrimonio__c, PTF_Utilizzato__c, PTF_Accordato__c,
        PTF_DirezioneRegionale__r.PTF_DowngradeReqStartDate__c, PTF_DirezioneRegionale__r.PTF_DowngradeReqEndDate__c, PTF_Filiale__r.PTF_DowngradeReqStartDate__c, PTF_Filiale__r.PTF_DowngradeReqEndDate__c,
        PTF_StatoAssegnazione__c,
        (SELECT id, PTF_Gestore__c, PTF_Gestore__r.PTF_OFS__c, PTF_Gestore__r.Name FROM Backup_Assignments__r WHERE RecordType.DeveloperName = 'Primario' AND PTF_EndDate__c = null)
        FROM Wallet__c WHERE Id =: recordId];
        Contact currentContact;
        if(!currentContactList.isEmpty()){

            currentContact = currentContactList[0];
        }
        return new Map<String,Object>{

            'mdsConfigurazioniMap' => mdsConfigurazioniMap,
            'currentUser' => currentUser,
            'currentContact' => currentContact,
            'currentPF' => currentPFList[0]
        };
    }

    @AuraEnabled
    public static Map<String,Object> loadNdgList(String recordId, Integer offset, Integer pagesize, string name, string ndg, string tag){
        
        System.debug('DK loadNdgList.recordId: ' + recordId);
        System.debug('DK loadNdgList.name: ' + name);
        System.debug('DK loadNdgList.ndg: ' + ndg);
        System.debug('PZ loadNdgList.tag: ' + tag);
        String searchedName = '%' + name + '%'; 
        String searchedNDG = '%' + ndg + '%';
        String searchedTAG = '%' + tag + '%';
        String countQuery = '';
        String query = '';
        //check if ndg filter is activated
        //filter on Name is always set because Name field is required for Accounts

        countQuery = 'SELECT count() ' + 
                'FROM Account ' + 
                'WHERE PTF_Portafoglio__c = :recordId ';

        query = 'SELECT Id, Name, CRM_NDG__c, CRM_VAT__c,PTF_RiportafogliazioneTAG__c, Phone, PTF_GruppoComportamentale__c, PTF_NaturaGiuridica__c, PTF_Filiale__c, PTF_Filiale__r.Name, ModelloDiServizio__c, PTF_OFS__c,PTF_Patrimonio__c,AnnualRevenue,PTF_Concordato__c, PTF_Accordato__c,PTF_Utilizzato__c, PTF_Portafoglio__r.Name, PTF_Portafoglio__c, PTF_SegmentoComportamentale__c ' +
                'FROM Account ' +
                'WHERE PTF_Portafoglio__c = :recordId ';

        if(!String.isBlank(name)){

            countQuery += ' AND Name =: name ';
            query += ' AND Name =: name ';
        }

        if(!String.isBlank(ndg)){

            countQuery += ' AND CRM_NDG__c =: ndg ';
            query += ' AND CRM_NDG__c =: ndg ';
        }
        if(!String.isBlank(tag)){

            countQuery += ' AND PTF_RiportafogliazioneTAG__c =: tag ';
            query += ' AND PTF_RiportafogliazioneTAG__c =: tag ';
        }

        //query += ' LIMIT: pagesize OFFSET: offset';

        return new Map<String, Object>{
            'ndgListCount' => Database.countQuery(countQuery),
            'ndgList' => Database.query(query)
        };
    }

    //valerio.salvati
    @AuraEnabled
    public static Map<String,Object> loadMws(List<String> filiale, List<String> modello, Integer offset, Integer pagesize, Boolean exactMatch, String idPortafoglio){
        if(exactMatch) return loadPortafoglioPrimario(idPortafoglio);
        else return loadMwList(filiale,modello,offset,pagesize);
    }


    //valerio.salvati
    @AuraEnabled
    public static Map<String,Object> loadPortafoglioPrimario(String idPortafoglio){
        String countQuery = '';
        String query = '';

        countQuery = 'SELECT count() ' + 
                     'FROM Wallet__c ' +
                     'WHERE  RecordType.DeveloperName = \'MicroWallet\' ' +
                     'AND Id =: idPortafoglio ';

        query = 'SELECT Id, Name, PTF_ModelloDiServizio__c, PTF_Filiale__c, PTF_Filiale__r.Name, Owner.Name, PTF_ReferentiList__c,PTF_StatoAssegnazione__c,CRM_ReferenteFormula__c,  PTF_Filiale__r.PTF_UffPrivate__c, PTF_Filiale__r.PTF_IDCEDUffPrivate__c, PTF_Filiale__r.PTF_UffPrivate__r.PTF_IdCedPadre__c, ' +
                '(SELECT id, PTF_Gestore__c, PTF_Gestore__r.PTF_OFS__c, PTF_Gestore__r.Name FROM Backup_Assignments__r WHERE PTF_Gestore__r.PTF_OFS__c = true AND RecordType.DeveloperName = \'Primario\' AND PTF_EndDate__c = null) ' +
                'FROM Wallet__c ' +
                'WHERE RecordType.DeveloperName = \'MicroWallet\' ' +
                'AND Id =: idPortafoglio ';

        return new Map<String, Object>{
            'mwListCount' => Database.countQuery(countQuery),
            'mwList' => Database.query(query)
        };
        
    }


    @AuraEnabled
    public static Map<String,Object> loadMwList(List<String> filiale, List<String> modello, Integer offset, Integer pagesize){
        system.debug('filiale: '+filiale);
        system.debug('modello: '+modello);
        
        String countQuery = '';
        String query = '';

        // MS - Aggiunto filtro Name != '999'
        countQuery = 'SELECT count() ' + 
                     'FROM Wallet__c ' +
                     'WHERE  RecordType.DeveloperName = \'MicroWallet\' ' +
                     'AND PTF_Filiale__c IN: filiale ';
        
        //NEW UFF PRIVATE
        // MS - Aggiunto filtro Name != '999'
        query = 'SELECT Id, Name, PTF_ModelloDiServizio__c, PTF_Filiale__c, PTF_Filiale__r.Name, Owner.Name, PTF_ReferentiList__c,CRM_ReferenteFormula__c,PTF_StatoAssegnazione__c,  PTF_Filiale__r.PTF_UffPrivate__c, PTF_Filiale__r.PTF_IDCEDUffPrivate__c, PTF_Filiale__r.PTF_UffPrivate__r.PTF_IdCedPadre__c, ' +
        '(SELECT id, PTF_Gestore__c, PTF_Gestore__r.PTF_OFS__c, PTF_Gestore__r.Name FROM Backup_Assignments__r WHERE PTF_Gestore__r.PTF_OFS__c = true AND RecordType.DeveloperName = \'Primario\' AND PTF_EndDate__c = null) ' +
        'FROM Wallet__c ' +
        'WHERE RecordType.DeveloperName = \'MicroWallet\' ' +
        'AND PTF_Filiale__c IN: filiale ';
       
        if(currentUser.Profilo__c != 'NEC_D.0'){
            
            countQuery += ' AND PTF_ModelloDiServizio__c IN: modello AND PTF_DeletionDate__c = NULL ';
            countQuery += ' AND (NOT Name LIKE \'%999\') ';
            query += ' AND PTF_ModelloDiServizio__c IN: modello AND PTF_DeletionDate__c = NULL ';
            query += ' AND (NOT Name LIKE \'%999\') ';
        }

        query += ' ORDER BY CreatedDate DESC '; /*+
        ' LIMIT: pagesize ' +
        ' OFFSET: offset';*/

        return new Map<String, Object>{
            'mwListCount' => Database.countQuery(countQuery),
            'mwList' => Database.query(query)
        };
    }

    @AuraEnabled
    public static Map<String,Object> loadAssenteNdgList(String recordId, Integer pagesize){
        System.debug('DK loadAssenteNdgList.recordId: ' + recordId);
        System.debug('DK loadAssenteNdgList.pagesize: ' + pagesize);
        
        String countQuery = '';
        String query = '';
        //check if ndg filter is activated
        //filter on Name is always set because Name field is required for Accounts

        // countQuery = 'SELECT count() ' + 
        //         'FROM Account ' + 
        //         'WHERE PTF_Portafoglio__c = :recordId AND Id NOT IN (SELECT AccountId__c FROM WorkORderLineItem WHERE Status = \'Pending\') ' ;

        // MS 09-02-2024 aggiunto campo CRM_Specchio_BPER__c nel select
        query = ' SELECT Id, Name, RecordType.DeveloperName, CRM_NDG__c, PTF_Filiale__c, ModelloDiServizio__c, PTF_Portafoglio__c, PTF_CapoGruppo__c, PTF_Gruppo__c, AnnualRevenue, PTF_Accordato__c, PTF_Patrimonio__c, PTF_Utilizzato__c, ' +
                ' PTF_NaturaGiuridica__c, PTF_Portafoglio__r.PTF_ModelloDiServizio__c, PTF_Portafoglio__r.PTF_Filiale__c, PTF_Portafoglio__r.PTF_Filiale__r.PTF_BranchTypeDesc__c, PTF_Filiale__r.PTF_BranchTypeDesc__c, ' +
                ' PTF_Portafoglio__r.PTF_DirezioneRegionale__r.PTF_DowngradeReqStartDate__c, PTF_Portafoglio__r.PTF_DirezioneRegionale__r.PTF_DowngradeReqEndDate__c, ' +
                ' PTF_Portafoglio__r.PTF_Banca__r.PTF_DowngradeReqStartDate__c, PTF_Portafoglio__r.PTF_Banca__r.PTF_DowngradeReqEndDate__c, ' +
                ' PTF_Filiale__r.PTF_DowngradeReqStartDate__c, PTF_Filiale__r.PTF_DowngradeReqEndDate__c,' +
                ' PTF_Portafoglio__r.PTF_Banca__c, PTF_Portafoglio__r.PTF_Capofila__c,  ' +
                ' PTF_Portafoglio__r.PTF_DirezioneRegionale__c, PTF_Portafoglio__r.PTF_Area__c, PTF_Portafoglio__r.Name, PTF_SegmentoComportamentale__c, ' +
                ' PTF_OFS__c, ' +
                ' CRM_Specchio_BPER__c ' +
                'FROM Account ' +
                'WHERE PTF_Portafoglio__c = :recordId ' +
                'AND Id NOT IN (SELECT AccountId__c FROM WorkORderLineItem WHERE Status = \'Pending\') ' ;
        
        query += ' LIMIT: pagesize';

        List<Account> accountList = Database.query(query);
        List<Account> accountListToReturn = new List<Account>();

        List<account> cointestazioni = new List<account>();
        for(Account account : accountList){

            if(account.RecordType.DeveloperName == 'Cointestazione' && account.PTF_NaturaGiuridica__c == 'CO'){
                cointestazioni.add(account);
            }else{
                accountListToReturn.add(account);
            }
        }

        if(!cointestazioni.isEmpty()){

            Map<String, SObject> cointestazioniMap = SV_Utilities.keyBy(cointestazioni, 'Id');
            Map<String, SObject> giunzioniMap = SV_Utilities.keyBy([SELECT id, CRM_JointOwnership__c, CRM_Account__r.PTF_Portafoglio__c FROM CRM_AccountAccountJointOwnershipRelation__c WHERE CRM_Account__r.PTF_Portafoglio__c != '' AND
            CRM_JointOwnership__c IN: cointestazioniMap.keySet() AND
            CRM_Active__c = true AND
            CRM_PrimaryNDG__c = true AND CRM_Account__c IN (SELECT AccountId__c FROM WorkORderLineItem WHERE Status = 'Pending')], 'CRM_JointOwnership__c');
            for(Account cointestazione : cointestazioni){
                if(!giunzioniMap.containsKey(cointestazione.Id)){
                    accountListToReturn.add(cointestazione);
                }else{
                    if(((CRM_AccountAccountJointOwnershipRelation__c)giunzioniMap.get(cointestazione.Id)).CRM_Account__r.PTF_Portafoglio__c != recordId){
                        accountListToReturn.add(cointestazione);
                    }
                }
            }
        }

        return new Map<String, Object>{
            'ndgListCount' => accountListToReturn.size(),
            'ndgList' => accountListToReturn
        };
    }

    @AuraEnabled
    public static Map<String,Object> loadAssenteMwList(String serializedNdg, List<String> mdsEligible, Boolean isLoadAll, Integer offset, Integer pagesize, String ruoloVar, Boolean allInSameVar, String filialePrimarioVar, Wallet__c currentPF){
        
        System.debug('DK loadAssenteMwList.serializedNdg: ' + serializedNdg);
        System.debug('DK loadAssenteMwList.mdsEligible: ' + mdsEligible);
        System.debug('DK loadAssenteMwList.isLoadAll: ' + isLoadAll);
        System.debug('DK loadAssenteMwList.offset: ' + offset);
        System.debug('DK loadAssenteMwList.pagesize: ' + pagesize);
        System.debug('DK loadAssenteMwList.ruoloVar: ' + ruoloVar);
        System.debug('DK loadAssenteMwList.allInSameVar: ' + allInSameVar);
        System.debug('DK loadAssenteMwList.filialePrimarioVar: ' + filialePrimarioVar);
        System.debug('DK loadAssenteMwList.currentPF: ' + currentPF);


        SpostaNdgIterDataLoader.ruolo = ruoloVar;
        SpostaNdgIterDataLoader.allInSame = allInSameVar;
        SpostaNdgIterDataLoader.filialePrimario = filialePrimarioVar;
        SpostaNdgIterDataLoader.currentMDS = currentPF.PTF_ModelloDiServizio__c;
        SpostaNdgIterDataLoader.currentBranchTypeDesc = currentPF.PTF_Filiale__r.PTF_BranchTypeDesc__c;
        Boolean secondarySuperUser = currentUser.Profilo__c == 'NEC_D.2' && currentUser.idced__c == '6929' && currentPF.PTF_ModelloDiServizio__c == 'Assente';
        String countQuery = '';
        String query = '';
        Boolean isCointestazione = false;
        CRM_AccountAccountJointOwnershipRelation__c primario;
        Account ndg = (Account)JSON.deserialize(serializedNdg, Account.class);
        System.debug('ndg: ' + JSON.serializePretty(ndg));
        
        // countQuery = 'SELECT count() ' + 
        // 'FROM Wallet__c ' +
        // 'WHERE PTF_ModelloDiServizio__c IN: mdsEligible AND RecordType.DeveloperName = \'MicroWallet\' AND PTF_ModelloDiServizio__c != \'Residuale\' AND PTF_ModelloDiServizio__c != \'Assente\' AND PTF_DeletionDate__c = NULL ';
        
        // MS - Aggiunto filtro Name != '999'
        query = ' SELECT Id, Name, PTF_ModelloDiServizio__c, PTF_Pool__c, PTF_Filiale__r.PTF_UffPrivate__c, PTF_Filiale__r.PTF_IDCEDUffPrivate__c, PTF_Filiale__r.PTF_UffPrivate__r.PTF_IdCedPadre__c,' +
        ' PTF_Filiale__c, PTF_Filiale__r.PTF_BranchTypeDesc__c, PTF_Filiale__r.PTF_BranchTypologyMap__c, PTF_Filiale__r.Name, PTF_FIliale__r.PTF_IdCed__c, PTF_Capofila__c, PTF_Capofila__r.PTF_IdCed__c,' +
        ' PTF_Banca__c, PTF_Banca__r.FinServ__BankNumber__c, PTF_Banca__r.PTF_DowngradeReqStartDate__c, PTF_Banca__r.PTF_DowngradeReqEndDate__c, PTF_Banca__r.PTF_IdCed__c,' +
        ' PTF_DirezioneRegionale__r.PTF_IdCed__c, PTF_Area__r.PTF_IdCed__c, PTF_DirezioneRegionale__c, PTF_Area__c, Owner.Name, PTF_Fatturato__c, PTF_Patrimonio__c, PTF_Utilizzato__c, PTF_Accordato__c,' +
        ' PTF_DirezioneRegionale__r.PTF_DowngradeReqStartDate__c, PTF_DirezioneRegionale__r.PTF_DowngradeReqEndDate__c,' +
        ' PTF_Filiale__r.PTF_DowngradeReqStartDate__c, PTF_Filiale__r.PTF_DowngradeReqEndDate__c,PTF_StatoAssegnazione__c,' +
        ' (SELECT id, PTF_Gestore__c, PTF_Gestore__r.PTF_OFS__c, PTF_Gestore__r.Name FROM Backup_Assignments__r WHERE RecordType.DeveloperName = \'Primario\' AND PTF_EndDate__c = null) ' +
        'FROM Wallet__c ' +
        'WHERE RecordType.DeveloperName = \'MicroWallet\' AND PTF_DeletionDate__c = NULL ';
        
        if(currentUser.Profilo__c != 'NEC_D.0'){
            
            query += ' AND (NOT Name LIKE \'%999\') ';
        }
        
        String mwId= '';
        String mwMDS= '';
        String filiale = '';
        filiale = ndg.PTF_Filiale__c;
        // countQuery += 'AND PTF_Filiale__c =: filiale ';
        query += 'AND PTF_Filiale__c =: filiale ';

        query += ' ORDER BY PTF_ModelloDiServizio__c DESC ';


        // FARE QUERY
        System.debug('DK query: ' + query);

        List<Wallet__c> allPTF = Database.query(query);
        List<Wallet__c> ptfEligible = new List<Wallet__c>();
        if(currentUser.Profilo__c == 'NEC_D.0' || secondarySuperUser){
            
            for(Wallet__c portafoglio : allPTF){

                if(SpostaNdgIterDataLoader.checkEligibleSuperUser(portafoglio, ndg)){

                    ptfEligible.add(portafoglio);
                }
            }
        }else{
            
            for(Wallet__c portafoglio : allPTF){

                if(SpostaNdgIterDataLoader.checkEligible(portafoglio, ndg, currentPF)){

                    ptfEligible.add(portafoglio);
                }
            }
        }   

        System.debug('countQuery: ' + countQuery);
        return new Map<String, Object>{
            'mwListCount' => ptfEligible.size(),
            'mwList' => ptfEligible
        };
    }

    @AuraEnabled
    public static Map<String, Object> checkCointestazione(Account currentNDG, String microWalletId, String recordTypeDevName, Wallet__c currentPF){
        
        System.debug('DK checkCointestazione.currentNDG: ' + currentNDG);
        System.debug('DK checkCointestazione.microWalletId: ' + microWalletId);
        System.debug('DK checkCointestazione.recordTypeDevName: ' + recordTypeDevName);
        System.debug('DK checkCointestazione.currentPF: ' + currentPF);
        Map<String, Object> response = new Map<String, Object>();
        List<CRM_AccountAccountJointOwnershipRelation__c> primarioList;
        String assignedMW = '';
        String mdsPrimario = '';
        String filialePrimario;
        String ruolo = '';
        String errorMessage = '';
        Boolean isPrimario = false;
        Boolean hasDifferent = false;
        Boolean isAlone = true;
        List<Wallet__c> portafogliInEvidenza;
        List<Wallet__c> altriPortafogli;
        Set<String> microPortafoglioCointestazioniIdSet = new Set<String>();
        List<Account> cointestazioni = new List<Account>();
        List<Account> cointestazioniInSame = new List<Account>();
        Set<String> microportafogliCointestazioniFiliali = new Set<String>();

        if(recordTypeDevName == 'Cointestazione' && currentNDG.PTF_NaturaGiuridica__c == 'CO'){
    
            List<CRM_AccountAccountJointOwnershipRelation__c> primario = [SELECT id, CRM_Account__c, CRM_Account__r.CRM_NDG__c, CRM_Active__c, CRM_PrimaryNDG__c, CRM_JointOwnership__c,
            CRM_Account__r.PTF_Portafoglio__c, CRM_Account__r.PTF_Portafoglio__r.PTF_ModelloDiServizio__c, CRM_Account__r.PTF_Filiale__c, CRM_Account__r.ModelloDiServizio__c, CRM_Account__r.PTF_BloccoSpostamenti__c
            FROM CRM_AccountAccountJointOwnershipRelation__c 
            WHERE CRM_JointOwnership__c =: currentNDG.Id AND
            CRM_JointOwnership__r.PTF_Portafoglio__c != '' AND
            CRM_Active__c = true AND
            CRM_PrimaryNDG__c = true AND 
            CRM_Account__r.PTF_Portafoglio__r.RecordType.developerName != 'Residuale'
            ORDER BY CreatedDate DESC
            LIMIT 1];

            /*if(primario[0].CRM_Account__r.PTF_BloccoSpostamenti__c){
                return new Map<String, Object>{
                    'errorMessage' => 'Lo spostamento di NDG primario (' + primario[0].CRM_Account__r.CRM_NDG__c + ') è momentaneamente bloccato.'
                };
            }*/
            
            // Account currentNDG = [SELECT id, PTF_Filiale__c, ModelloDiServizio__c FROM Account WHERE id =: ndgId];
            SpostaNdgIterDataLoader.currentMDS = currentPF.PTF_ModelloDiServizio__c;
            SpostaNdgIterDataLoader.currentBranchTypeDesc = currentPF.PTF_Filiale__r.PTF_BranchTypeDesc__c;
            if(!primario.isEmpty()){
                
                ruolo = 'cointestazione';
                if(primario[0].CRM_Account__r.PTF_Portafoglio__c != microWalletId){
                    
                    portafogliInEvidenza = [SELECT Id, Name, PTF_ModelloDiServizio__c, PTF_Pool__c, PTF_Filiale__r.PTF_UffPrivate__c, PTF_Filiale__r.PTF_IDCEDUffPrivate__c, PTF_Filiale__r.PTF_UffPrivate__r.PTF_IdCedPadre__c,
                    PTF_Filiale__c, PTF_Filiale__r.PTF_BranchTypeDesc__c, PTF_Filiale__r.Name,PTF_StatoAssegnazione__c,
                    PTF_Banca__c, PTF_Banca__r.FinServ__BankNumber__c, PTF_Banca__r.PTF_DowngradeReqStartDate__c, PTF_Banca__r.PTF_DowngradeReqEndDate__c,
                    PTF_Filiale__r.PTF_DowngradeReqStartDate__c, PTF_Filiale__r.PTF_DowngradeReqEndDate__c, PTF_DirezioneRegionale__r.PTF_DowngradeReqStartDate__c, PTF_DirezioneRegionale__r.PTF_DowngradeReqEndDate__c,
                    PTF_Capofila__c, PTF_DirezioneRegionale__c, PTF_Area__c, Owner.Name, PTF_Fatturato__c, PTF_Patrimonio__c, PTF_Utilizzato__c, PTF_Accordato__c,
                    (SELECT id, PTF_Gestore__c, PTF_Gestore__r.PTF_OFS__c, PTF_Gestore__r.Name FROM Backup_Assignments__r WHERE RecordType.DeveloperName = 'Primario' AND PTF_EndDate__c = null)
                    FROM Wallet__c WHERE Id =: primario[0].CRM_Account__r.PTF_Portafoglio__c AND RecordType.developerName != 'TechnicalWallet' AND RecordType.developerName != 'Assente' AND RecordType.developerName != 'Residuale' LIMIT 1];

                    if(!portafogliInEvidenza.isEmpty()){

                        if(primario[0].CRM_Account__r.PTF_Filiale__c != currentNDG.PTF_Filiale__c &&
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
                        SpostaNdgIterDataLoader.isPTFInEvidenza = false;
                    }
                }else{

                    portafogliInEvidenza = null; 
                }
            }
        }else{
            
            Set<String> cointestazioniIdSet = new Set<String>();
            Set<String> cointestazioniPrimarioIdSet = new Set<String>();
            Map<String, SObject> giunzioni = SV_Utilities.keyBy([SELECT id, CRM_Account__c, CRM_Active__c, CRM_PrimaryNDG__c, CRM_JointOwnership__c,
                                            CRM_JointOwnership__r.PTF_Portafoglio__c
                                            FROM CRM_AccountAccountJointOwnershipRelation__c 
                                            WHERE CRM_Account__c =: currentNDG.Id AND 
                                            CRM_JointOwnership__r.PTF_Portafoglio__c != null AND 
                                            CRM_Active__c = true AND
                                            CRM_JointOwnership__r.PTF_Portafoglio__r.RecordType.developerName != 'Residuale'
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
                Map<String, Account> varCointestazioniMap = (Map<String, Account>) JSON.deserialize(JSON.serialize(SV_Utilities.keyBy([SELECT Id, PTF_BloccoSpostamenti__c, Name, CRM_NDG__c, PTF_Filiale__c, ModelloDiServizio__c, PTF_Portafoglio__c,
                                            PTF_CapoGruppo__c, PTF_Gruppo__c, AnnualRevenue, PTF_Accordato__c, PTF_Patrimonio__c, PTF_Utilizzato__c, PTF_NaturaGiuridica__c, PTF_Portafoglio__r.Name, PTF_SegmentoComportamentale__c
                                            FROM Account
                                            WHERE id IN: cointestazioniIdSet], 'Id')), Map<String, Account>.class);
                if(ruolo == 'primario'){
                    
                    // List<String> coBloccate = new List<String>();
                    if(!varCointestazioniMap.isEmpty()){

                        for(String cointestazioneId : varCointestazioniMap.keySet()){

                            if(cointestazioniPrimarioIdSet.contains(cointestazioneId)){

                                cointestazioni.add(varCointestazioniMap.get(cointestazioneId));
                                /*if(varCointestazioniMap.get(cointestazioneId).PTF_BloccoSpostamenti__c){
                                    coBloccate.add(varCointestazioniMap.get(cointestazioneId).CRM_NDG__c);
                                }*/
                                }
                            }
                        }

                    /*if(!coBloccate.isEmpty()){
                        return new Map<String,Object> {
                            'errorMessage' => 'Lo spostamento delle cointestazioni (' + String.join(coBloccate, ', ') + ') del primario è momentaneamente bloccato.'
                        };
                    }*/
                    // cointestazioni = !varCointestazioniMap.isEmpty() ? varCointestazioniMap.values() : null;
                    Set<String> microportafogliCointestazioni = new Set<String>();
                    for(Account cointestazione : cointestazioni){
                        
                        if(currentNDG.PTF_Portafoglio__c != cointestazione.PTF_Portafoglio__c){

                            microportafogliCointestazioni.add(cointestazione.PTF_Portafoglio__c);
                            if(currentPF.PTF_Filiale__c != cointestazione.PTF_Filiale__c){

                                microportafogliCointestazioniFiliali.add(cointestazione.PTF_Filiale__c);
                            }
                        }else{

                            cointestazioniInSame.add(cointestazione);
                        }
                    }
                    if(microportafogliCointestazioni.size() > 1){
                        
                        hasDifferent = true;
                    }
                    if(!microportafogliCointestazioni.isEmpty()){
    
                        portafogliInEvidenza = [SELECT Id, Name, PTF_ModelloDiServizio__c, PTF_Pool__c, PTF_Filiale__r.PTF_UffPrivate__c, PTF_Filiale__r.PTF_IDCEDUffPrivate__c, PTF_Filiale__r.PTF_UffPrivate__r.PTF_IdCedPadre__c,
                        PTF_Filiale__c, PTF_Filiale__r.PTF_BranchTypeDesc__c, PTF_Filiale__r.PTF_BranchTypologyMap__c, PTF_Filiale__r.Name, PTF_FIliale__r.PTF_IdCed__c, PTF_Capofila__c, PTF_Capofila__r.PTF_IdCed__c,
                        PTF_Banca__c, PTF_Banca__r.FinServ__BankNumber__c, PTF_Banca__r.PTF_DowngradeReqStartDate__c, PTF_Banca__r.PTF_DowngradeReqEndDate__c, PTF_Banca__r.PTF_IdCed__c,PTF_StatoAssegnazione__c,
                        PTF_DirezioneRegionale__r.PTF_IdCed__c, PTF_Area__r.PTF_IdCed__c, PTF_DirezioneRegionale__c, PTF_Area__c, Owner.Name, PTF_Fatturato__c, PTF_Patrimonio__c, PTF_Utilizzato__c, PTF_Accordato__c,
                        PTF_DirezioneRegionale__r.PTF_DowngradeReqStartDate__c, PTF_DirezioneRegionale__r.PTF_DowngradeReqEndDate__c, PTF_Filiale__r.PTF_DowngradeReqStartDate__c, PTF_Filiale__r.PTF_DowngradeReqEndDate__c,
                        (SELECT id, PTF_Gestore__c, PTF_Gestore__r.PTF_OFS__c, PTF_Gestore__r.Name FROM Backup_Assignments__r WHERE RecordType.DeveloperName = 'Primario' AND PTF_EndDate__c = null)
                        FROM Wallet__c WHERE Id IN: microportafogliCointestazioni AND RecordType.developerName != 'TechnicalWallet' AND RecordType.developerName != 'Assente' AND RecordType.developerName != 'Residuale' ];

                        if(!portafogliInEvidenza.isEmpty()){

                            SpostaNdgIterDataLoader.ruolo = ruolo;
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
                                portafogliInEvidenza = portafogliInEvidenzaFinal;
                            }else{
                                
                                for(Wallet__c portafoglio : portafogliInEvidenza){

                                    if(SpostaNdgIterDataLoader.checkEligible(portafoglio, currentNDG, currentPF)){

                                        portafogliInEvidenzaFinal.add(portafoglio);
                                    }
                                }
                                portafogliInEvidenza = portafogliInEvidenzaFinal;
                            }
                            portafogliInEvidenza = portafogliInEvidenzaFinal;
                            SpostaNdgIterDataLoader.isPTFInEvidenza = false;
                        }
                    }else{
        
                        portafogliInEvidenza = null;
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
        return new Map<String, Object>{
            'assignedMW' => assignedMW,
            'isInList' => assignedMW == microWalletId,
            'portafogliInEvidenza' => portafogliInEvidenza,
            'altriPortafogli' => altriPortafogli,
            'mdsPrimario' => mdsPrimario,
            'filialePrimario' => filialePrimario,
            'microportafogliCointestazioniFiliali' => microportafogliCointestazioniFiliali,
            'ruolo' => ruolo,
            'hasDifferent' => hasDifferent,
            'isAlone' => isAlone
        };
    }

    /**
    * Updates Accounts by assigning new microwallet  
    *
    * @param params  JSON string containg following parameters
    *                   @ndgids: list of account Ids to update
    /                   @mwId: microWallet id
    * @return   void
    */
    @AuraEnabled
    public static void executeAssignmentAssente(String params) {

        System.debug('DK checkCointestazione.params: ' + params);
        
        Map<String, Object> paramsMap = (Map<String,Object>) JSON.deserializeUntyped(params);
        Set<String> ndgIds = new Set<String>();
        ndgIds.add((String)paramsMap.get('ndg'));
        String mwOrigine = (String) paramsMap.get('mwOrigine');
        String ptfId = (String)paramsMap.get('mwId');
        Wallet__c ptf = [SELECT id, PTF_Filiale__c,PTF_StatoAssegnazione__c FROM Wallet__c WHERE Id =: ptfId];
        if((String)paramsMap.get('ruolo') == 'primario' && (Boolean)paramsMap.get('moveAll')){

            List<CRM_AccountAccountJointOwnershipRelation__c> giunzioni = [SELECT id, CRM_JointOwnership__c, CRM_JointOwnership__r.PTF_Portafoglio__r.PTF_Filiale__c
                                                    FROM CRM_AccountAccountJointOwnershipRelation__c 
                                                    WHERE CRM_JointOwnership__r.PTF_Portafoglio__c != '' AND
                                                    CRM_Account__c =: (String)paramsMap.get('ndg') AND
                                                    CRM_PrimaryNDG__c = true AND
                                                    CRM_Active__c = true
                                                    ORDER BY CreatedDate DESC];
            for(CRM_AccountAccountJointOwnershipRelation__c giunzione : giunzioni){
                
                if(mwOrigine == giunzione.CRM_JointOwnership__r.PTF_Portafoglio__c){
                    
                    ndgIds.add(giunzione.CRM_JointOwnership__c);
                }
            }
        }
        List<Account> accList = new List<Account>();
        for (String ndgId : ndgIds) {
            
            Account acc = new Account(Id=ndgId, PTF_Portafoglio__c=ptfId);
            accList.add(acc);
        }
        update accList;
    }

    /**
    * Wrapper Class for executeAssignment method JSON
    */
    public class AssignmentWrapper {
        
        public List<String> ndgIds;
        public String mwId;
    }

    //valerio.salvati
    @AuraEnabled
    public static Map<String,Object> loadRelatedRecords(List<String> personeFisiche, List<String> cointestazioni){
        
        Map<String,Object> result = new Map<String,Object>();
        List<CRM_AccountAccountJointOwnershipRelation__c> pfCorrelate = new List<CRM_AccountAccountJointOwnershipRelation__c>();
        List<CRM_AccountAccountJointOwnershipRelation__c> cointestazioniCorrelate = new List<CRM_AccountAccountJointOwnershipRelation__c>();
        List<CRM_AccountAccountJointOwnershipRelation__c> altreCointestazioni = new List<CRM_AccountAccountJointOwnershipRelation__c>();

        if(personeFisiche.size()>0){
            cointestazioniCorrelate = [SELECT Id, CRM_JointOwnership__c,CRM_Active__c, CRM_JointOwnership__r.PTF_BloccoSpostamenti__c, CRM_JointOwnership__r.PTF_Portafoglio__c, CRM_JointOwnership__r.PTF_Portafoglio__r.Name,CRM_Account__c, CRM_Account__r.PTF_Portafoglio__c,  CRM_Account__r.PTF_Portafoglio__r.Name, CRM_Account__r.PTF_Filiale__c, CRM_Account__r.ModelloDiServizio__c, CRM_PrimaryNDG__c, PTF_ABI__c, PTF_CheckPortafoglio__c, PTF_IntestazioneCointestazione__c, PTF_IntestazionePrimario__c, Tipo_collegamento__c, CRM_JointOwnership__r.PTF_Filiale__c, CRM_JointOwnership__r.ModelloDiServizio__c
             FROM CRM_AccountAccountJointOwnershipRelation__c 
             WHERE CRM_Account__c IN: personeFisiche AND CRM_PrimaryNDG__c = true AND  CRM_EndDate__c = null AND CRM_Active__c = true  and CRM_JointOwnership__r.PTF_Portafoglio__c !=null
             ];
        }

        if(cointestazioni.size()>0){
             pfCorrelate = [SELECT Id, CRM_JointOwnership__c,CRM_Active__c, CRM_JointOwnership__r.PTF_Portafoglio__c, CRM_JointOwnership__r.PTF_Portafoglio__r.Name,CRM_Account__c, CRM_Account__r.PTF_BloccoSpostamenti__c, CRM_Account__r.CRM_NDG__c, CRM_Account__r.PTF_Portafoglio__c, CRM_Account__r.PTF_Portafoglio__r.Name, CRM_Account__r.PTF_Filiale__c, CRM_Account__r.ModelloDiServizio__c, CRM_PrimaryNDG__c, PTF_ABI__c, PTF_CheckPortafoglio__c, PTF_IntestazioneCointestazione__c, PTF_IntestazionePrimario__c, Tipo_collegamento__c, CRM_JointOwnership__r.PTF_Filiale__c, CRM_JointOwnership__r.ModelloDiServizio__c
             FROM CRM_AccountAccountJointOwnershipRelation__c  
             WHERE CRM_JointOwnership__c IN: cointestazioni AND CRM_PrimaryNDG__c = true AND  CRM_EndDate__c = null AND CRM_Active__c = true and CRM_JointOwnership__r.PTF_Portafoglio__c !=null];

             if(pfCorrelate.size()>0){
                List<String> pfList = new List<String>();
                for(CRM_AccountAccountJointOwnershipRelation__c currentPf: pfCorrelate){
                    pfList.add(currentPf.CRM_Account__c);
                }
                altreCointestazioni =    [SELECT Id, CRM_JointOwnership__c,CRM_Active__c, CRM_JointOwnership__r.PTF_BloccoSpostamenti__c, CRM_JointOwnership__r.PTF_Portafoglio__c, CRM_JointOwnership__r.CRM_NDG__c, CRM_JointOwnership__r.PTF_Portafoglio__r.Name,CRM_Account__c, CRM_Account__r.PTF_Portafoglio__c,  CRM_Account__r.PTF_Portafoglio__r.Name, CRM_Account__r.PTF_Filiale__c, CRM_Account__r.ModelloDiServizio__c, CRM_PrimaryNDG__c, PTF_ABI__c, PTF_CheckPortafoglio__c, PTF_IntestazioneCointestazione__c, PTF_IntestazionePrimario__c, Tipo_collegamento__c, CRM_JointOwnership__r.PTF_Filiale__c, CRM_JointOwnership__r.ModelloDiServizio__c
                FROM CRM_AccountAccountJointOwnershipRelation__c 
                WHERE CRM_Account__c IN: pfList AND CRM_PrimaryNDG__c = true AND  CRM_EndDate__c = null AND CRM_Active__c = true  and CRM_JointOwnership__r.PTF_Portafoglio__c !=null];
             }

        }

        result.put('pfCorrelate',pfCorrelate);
        result.put('pfCorrelateMap',SV_Utilities.groupBy(pfCorrelate, 'CRM_JointOwnership__c'));
        result.put('cointestazioniCorrelate',cointestazioniCorrelate);
        result.put('cointestazioniCorrelateMap',SV_Utilities.groupBy(cointestazioniCorrelate, 'CRM_Account__c'));
        result.put('altreCointestazioni',altreCointestazioni);
        result.put('altreCointestazioniMap',SV_Utilities.groupBy(altreCointestazioni, 'CRM_Account__c'));

        return result;


    }


}