/****
* Name			:	Batch_AssegnaRuoli
* Author		:	Luca Pollastro @TEN
* ----
* Auhtor		:	Ezio Dal Bo
* Modify Date	:	2020-12-09
* Modify		:	Aggiunta logica gestione campo vicario Vicario__c
* ---
* Auhtor		:	Ezio Dal Bo
* Modify Date	:	2021-02-09
* Modify		:	Refactoring classe
* --- 
* Auhtor		:	Dam Kebe
* Label         :   CR 52803
* Modify Date	:	2022-10-22
* Modify		:	Visibilità MMDS
* --- 
* Auhtor		:	Alessandro Lumaca
* Label         :   CR 60703
* Modify Date	:	2022-10-22
* Modify		:	Gestione profili
***/ 

/**
 * @TestClass   :   Batch_AssegnaRuoliTest
 */

global class Batch_AssegnaRuoli implements Database.Batchable<sObject>, Database.stateful, IRunner {
    private static final String COD_CLASSE = 'GR004';
    private static final String COD_SVILUPPATORI = 'DEVELOPER';
    private static final String NOME_CLASSE = 'Batch_AssegnaRuoli';
    
    global List<ScheduledJob__c> sj = new List<ScheduledJob__c>();
    global Debug__mdt debug = (Debug__mdt)MetadataUtility.getRecordByName('Debug__mdt', COD_CLASSE);
    global Map<String,Struttura_Banca__c> mStruttura = new Map<String,Struttura_Banca__c>();
    global Map<String,List<String>> drIdCedToGruppiPrivateDevName = new Map<String,List<String>>();
    global Set<String> IdCedPrivate= new Set<String>();
    global Set<String> gruppiUffPrivateDevName= new Set<String>();
    global Map<String,EscludiUtenzaTecnicaLDAP__c> mEscludiUtenzaTecnica = EscludiUtenzaTecnicaLDAP__c.getAll();
    // global List<User> newUsers = new List<User>();
    // START DK - REASSIGN USER TO QUEUE
    global List<User> userUpdateQueues = new List<User>();
    // END DK - REASSIGN USER TO QUEUE
    
    global List<String> removeUsersList = new List<String>();
    global Map<String,String> errorOnCreationUser = new Map<String,String>();
    global Integer recordElab = 0;
    global Integer utentiCreati = 0;
    global Integer utentiNonCreati = 0;
    global Integer utentiCambioRuolo = 0;
    global Integer utentiUpdatati=0;
    global String testoMail ='';
    global Boolean isSandbox = [SELECT IsSandbox FROM Organization LIMIT 1].IsSandbox;
    global Map<Id,User> mUserToUpdateNewRole = new Map<Id,User>();
    global List<User> userToUpdateNewRole = new List<User>();
    global Boolean errorOnCreate = false;
    global map<String,Id> mProfiliSalesforce = new Map<String,Id>();
    global map<String,Id> mRuoliSalesforce = new Map<String,Id>();
    global Map<String,SObject> mProfiliBPER = new Map<String,SObject>();
    private List<String> queryFields = new List<String> {
        'Id',
        'Matricola__c',
        'IDCed__c',
        'Attivo__c',
        'Cognome__c',
        'Nome__c',
        'Ruolo_LDAP__c',
        'Team__c',
        'OFS__c',
        'Ruolo_LDAP_Calcolato__c',
        'Profilo_LDAP__c',
        'Vicario__c',
        'Email__c',
        'Da_Elaborare__c',
        // NEW DK PERMISSIONSET
        'CRM_PermissionSet__c',
        // NEW DK PERMISSIONSET
        // CR 52803
        'IdCedFittizia__c'
        // CR 52803
	};
    global LDAP__c ldapTest = null;
    Set<String> kciSet = new Set<String>{'21707', '21709', '21708'};
    Set<String> profilesSet = new Set<String>{'NEC_F%', 'NEC_D%', 'NEC_A%', 'NEC_T%'};
    
    // CR 60703 -- Gestione profili
    global static Map<String, String> viewAllMMDSMap{
        get{
            if(viewAllMMDSMap != null) return viewAllMMDSMap;
            viewAllMMDSMap = new Map<String, String>();
            for(Group gr : [
                SELECT Id, DeveloperName 
                FROM   Group 
                WHERE  DeveloperName LIKE 'ViewAll%_%'
                    AND Type = 'Regular'
            ]) {
                viewAllMMDSMap.put(gr.DeveloperName, gr.Id);
            }
            return viewAllMMDSMap;
        }set;
    }
    // END CR 60703

    public static Map<String, Set<String>> macroDivisionMap{

        get{

            if(macroDivisionMap != null){

                return macroDivisionMap;
            }
            macroDivisionMap = new Map<String, Set<String>>();
            for(ServiceModel__c serviceModel : [SELECT id, Name, PTF_Division__c, PTF_MacroDivision__c FROM ServiceModel__c]){
                if(!macroDivisionMap.containsKey(serviceModel.PTF_MacroDivision__c)){
                    macroDivisionMap.put(serviceModel.PTF_MacroDivision__c, new Set<String>());
                }
                macroDivisionMap.get(serviceModel.PTF_MacroDivision__c).add(serviceModel.PTF_Division__c);
            }
            return macroDivisionMap;
        }set;
    } 

    /***
     * IRunner
	***/
    global void initRunner(List<ScheduledJob__c> schedules) {
        this.sj.addAll(schedules);
    }
    
    
    /**
     * Batch
	***/
    global Database.QueryLocator start(Database.BatchableContext BC) {
        mProfiliSalesforce = getProfiliSalesforce();
        mStruttura = getStrutturaBanca();
        mProfiliBPER = MetadataUtility.getAllByMetadataName('Profilo_BPER__mdt');
        mRuoliSalesforce = getRuoliSalesforce(mProfiliBPER);
        //Set<String> uffList= SV_Utilities.getSet([SELECT PTF_IdCEDUffPrivate__c FROM ConfigUffPrivateDR__c], 'PTF_IdCEDUffPrivate__c');
        //String query = 'SELECT '+String.join(queryFields, ',')+' FROM LDAP__c WHERE Profilo_LDAP__c!=NULL AND (Da_Elaborare__c=TRUE OR IDCed__c IN:uffList)';
        Set<String> matricolaSet = new Set<String>();
        for(User u : [SELECT Id, FederationIdentifier FROM User WHERE UserRoleId = NULL AND IsActive = true]){
            matricolaSet.add('U' + u.FederationIdentifier);
        }
        //NON VA AGGIUNTO FILTRO DAELABORARE__c A TRUE PERCHE' ALTRIMETI NON VENGO RIASSEGNATI I RUOLI IN CASO DI MODIFICA IN STRUTTURA BANCA
        String query = 'SELECT '+String.join(queryFields, ',')+' FROM LDAP__c WHERE  Profilo_LDAP__c != null AND (Da_Elaborare__c = TRUE OR (Matricola__c IN: matricolaSet AND Profilo_LDAP__c LIKE: profilesSet) ) ';
        if (Test.isRunningTest()) {
            query += ' LIMIT 200';
        }
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<LDAP__c> scope) {
        List<GroupMember> members = new List<GroupMember>();
        Set<String> matricolaSet= new Set<String>();
        Set<String> RIDCEDSet= new Set<String>();
        // CR 52803
        Set<String> RIDCEDSetMDS = new Set<String>();
        // CR 52803
        Map<String,User> matricolaToUser = new Map<String,User>();
        Set<Id> idUsers = new Set<Id>();
        Map<String,UserRole> IdCedToRole= new Map<String,UserRole>();
        Set<String> gMembers = new Set<String>();
        Map<String,Group> mRoleGroupFilialeMDS= new Map<String,Group>();
        List<User> userToCreate = new List<User>();
        List<User> userToUpdate= new List<User>();

        List<User> userWithDifferentPSList= new List<User>();
        Map<Id, User> userWithDifferentPSOldMap= new Map<Id, User>();
        
        try {
            recordElab += scope.size();
            for(LDAP__c ldap: scope){
                if(String.isNotBlank(ldap.IDCed__c) && !mEscludiUtenzaTecnica.containsKey(ldap.Matricola__c)){
                    matricolaSet.add(ldap.Matricola__c.replace('U', ''));
                    RIDCEDSet.add('RIDCED'+ldap.IDCed__c);
                    // CR 52803
                    if(!String.isBlank(ldap.IdCedFittizia__c) && ldap.IdCedFittizia__c != ldap.IdCed__c){
                        RIDCEDSetMDS.add('RIDCED'+ldap.IdCedFittizia__c);
                    }
                    // CR 52803
                }
            }
            // CR 52803
            RIDCEDSetMDS.addAll(RIDCEDSet);
            // CR 52803

            //Uffici Private
            /*List<ConfigUffPrivateDR__c> confList=[SELECT Name,PTF_IdCEDUffPrivate__c,PTF_IdCP__c, PTF_IdCEDDR__c FROM ConfigUffPrivateDR__c];
            for(ConfigUffPrivateDR__c conf:confList){
                IdCedPrivate.add(conf.PTF_IdCEDUffPrivate__c);
                if(!drIdCedToGruppiPrivateDevName.containsKey(conf.PTF_IdCEDDR__c)){
                    drIdCedToGruppiPrivateDevName.put(conf.PTF_IdCEDDR__c, new List<String>());
                }
                drIdCedToGruppiPrivateDevName.get(conf.PTF_IdCEDDR__c).add(conf.PTF_IdCP__c+'_'+conf.PTF_IdCEDUffPrivate__c);
                gruppiUffPrivateDevName.add(conf.PTF_IdCP__c+'_'+conf.PTF_IdCEDUffPrivate__c);
            }
            Map<String,Group> devNameToGroupUffPriv= new Map<String,Group>();
            List<Group> tempGroupList=[SELECT Id, DeveloperName FROM Group WHERE DeveloperName IN:gruppiUffPrivateDevName];
            for(Group g: tempGroupList){
                devNameToGroupUffPriv.put(g.DeveloperName,g);
            }
            System.debug('gruppiUffPrivateDevName '+gruppiUffPrivateDevName);
            System.debug('tempGroupList '+tempGroupList);
            System.debug('devNameToGroupUffPriv '+devNameToGroupUffPriv);*/
            //Uffici Private

            //Eccezioni
            List<Group> eccList= [SELECT Id, DeveloperName FROM Group WHERE DeveloperName IN('Filiale937_1200','Filiale2499')];
            Map<String,Group> eccMap= new Map<String,Group>();
            for(Group g:eccList){
                eccMap.put(g.DeveloperName,g);
            }
            //Eccezioni
            matricolaToUser=findUtenti(matricolaSet,false);
            for (String uKey : matricolaToUser.keySet()) {
                idUsers.add(matricolaToUser.get(uKey).Id);
            }

            /*// START DK 30/08 - VISIBILITA PORTAFOGLI
            Set<String> userToRemoveFRomGroups = new Set<String>();
            for(LDAP__c ldap: scope){
                if(matricolaToUser.containsKey(ldap.Matricola__c.replace('U', ''))){
                    if(ldap.Ruolo_LDAP__c != matricolaToUser.get(ldap.Matricola__c.replace('U', '')).PTF_RuoloLDAP__c ||
                    ldap.Profilo_LDAP__c != matricolaToUser.get(ldap.Matricola__c.replace('U', '')).Profilo__c ||
                    ldap.idced__c != matricolaToUser.get(ldap.Matricola__c.replace('U', '')).idced__c){
                        userToRemoveFRomGroups.add(matricolaToUser.get(ldap.Matricola__c.replace('U', '')).Id);
                    }
                }
            }
            if(!userToRemoveFRomGroups.isEmpty()){

                delete [SELECT Id FROM GroupMember WHERE UserOrGroupId IN: userToRemoveFRomGroups AND Group.DeveloperName LIKE 'RIDCED%_%' AND Group.Type='Regular'];
            }
            // END DK 30/08 - VISIBILITA PORTAFOGLI*/

            IdCedToRole=findRole(RIDCEDSet);
            gMembers = findGroupMembers(idUsers);
            mRoleGroupFilialeMDS=Batch_CreaVisibilita.findRoleGroupFilialeMDS(RIDCEDSetMDS);
            
            SingleSingOnProvisionigHandler sso = new SingleSingOnProvisionigHandler();
            List<Map<String,String>> multiSSO = new List<Map<String,String>>();
            if (Test.isRunningTest() && ldapTest!=null) {
                scope.add(ldapTest);
                ldapTest = null;
            }
            for (LDAP__c ldap: scope) {
                System.debug('DK String.isNotBlank(ldap.IDCed__c): ' + String.isNotBlank(ldap.IDCed__c));
                System.debug('DK !mEscludiUtenzaTecnica.containsKey(ldap.Matricola__c): ' + !mEscludiUtenzaTecnica.containsKey(ldap.Matricola__c));
                System.debug('DK !matricolaToUser.containsKey(ldap.Matricola__c.replace(\'U\', \'\')): ' + !matricolaToUser.containsKey(ldap.Matricola__c.replace('U', '')));
                System.debug('DK isValidEmail(ldap.Email__c): ' + isValidEmail(ldap.Email__c));
                if(String.isNotBlank(ldap.IDCed__c) && !mEscludiUtenzaTecnica.containsKey(ldap.Matricola__c)) {
                    if(ldap.Attivo__c && !matricolaToUser.containsKey(ldap.Matricola__c.replace('U', '')) && isValidEmail(ldap.Email__c)) {
                        try {
                            Map<String,String> attributes = generateSSOAttribute(mStruttura.get(ldap.IDCed__c),ldap,isSandbox);
                            multiSSO.add(attributes);
                        }
                        catch(Exception exc) {
                            System.debug('An Execption occurred : '+exc.getMessage());
                            testoMail = NOME_CLASSE+' - An exception occurred during create user : '+exc.getMessage()+'<br/>'+exc.getStackTraceString();
                            mandaMail('Errore',testoMail);
                        }
                    }
                }
            }
            if (multiSSO.size()>0) {
                userToCreate.addAll(sso.createUsers(multiSSO));
            }
            if (userToCreate.size()>0) {
                onUserTriggerHandler.impostaFlagUtente(userToCreate);
                onUserTriggerHandler.ribaltaCampi(userToCreate);
                onUserTriggerHandler.impostaCallCenter(userToCreate);
                FollowUp.invokeCollegaContatto = false;
                List<Database.SaveResult> saveResults = Database.insert(userToCreate,false);
                FollowUp.invokeCollegaContatto = true;
                for(Integer index = 0, size = saveResults.size(); index < size; index++) {
                    Database.SaveResult sr = saveResults[index];
                    if (sr.isSuccess()) {
                        utentiCreati +=1;
                        User u = userToCreate[index];
                        u.Id = sr.getId();
                        matricolaToUser.put(u.FederationIdentifier,u);
                        // newUsers.add(u);
                    }
                    else {
                        utentiNonCreati +=1;
                        List<Database.Error> errors = sr.getErrors();
                        Database.Error error = errors[0];
                        User u = userToCreate[index];
                        errorOnCreationUser.put(u.FederationIdentifier,String.valueOf(error.getStatusCode()) +'//'+error.getMessage());
                        //errorOnCreationUser.add(String.valueOf(error.getStatusCode()) +'//'+error.getMessage());
                    }
                }
            }
            
            for(LDAP__c ldap: scope){
                if(String.isNotBlank(ldap.IDCed__c) && !mEscludiUtenzaTecnica.containsKey(ldap.Matricola__c)){
                    if(matricolaToUser.containsKey(ldap.Matricola__c.replace('U', ''))){
                        User u= matricolaToUser.get(ldap.Matricola__c.replace('U', ''));
                        
                        //Uffici Private Start
                        /*if(IdCedPrivate.contains(ldap.IDCed__c)){
                            if(String.isBlank(ldap.Team__c) && ldap.Ruolo_LDAP__c=='100'){
                                System.debug('IF '+ldap.IDCed__c);
                                for(String key: devNameToGroupUffPriv.keySet()){
                                    System.debug('CEDIF '+ldap.IDCed__c);
                                    System.debug('CEDIF1 '+key.split('_')[1]);
                                    if(ldap.IDCed__c==key.split('_')[1]){
                                        GroupMember member= new GroupMember();
                                        member.GroupId= devNameToGroupUffPriv.get(key).Id;
                                        member.UserOrGroupId=u.Id;
                                        if (!gMembers.contains(member.GroupId+'_'+member.UserOrGroupId)) {
                                            members.add(member);
                                        }
                                    }
                                }
                            }
                            else if(String.isNotBlank(ldap.Team__c) && ldap.Ruolo_LDAP__c=='069'){
                                if(devNameToGroupUffPriv.containsKey(ldap.Team__c+'_'+ldap.IDCed__c)){
                                    GroupMember member= new GroupMember();
                                    member.GroupId= devNameToGroupUffPriv.get(ldap.Team__c+'_'+ldap.IDCed__c).Id;
                                    member.UserOrGroupId=u.Id;
                                    if (!gMembers.contains(member.GroupId+'_'+member.UserOrGroupId)) {
                                        members.add(member);
                                    }
                                }
                            }
                        }*/
                        //Uffici Private End

                        //Eccezioni
                        // DK - MODIFICA KCI 13/12 - 5806 => 21709
                        /*if(/*ldap.IDCed__c=='5806' (ldap.IDCed__c=='21709' || ldap.IDCed__c=='21708' || ldap.IDCed__c=='21707') && (ldap.Ruolo_LDAP__c=='300'||ldap.Ruolo_LDAP__c=='301'||ldap.Ruolo_LDAP__c=='100') && ldap.Profilo_LDAP__c=='NEC_D.7'){
                            //Filiale937_1200
                            GroupMember member= new GroupMember();
                            member.GroupId= eccMap.get('Filiale937_1200').Id;
                            member.UserOrGroupId=u.Id;
                            if (!gMembers.contains(member.GroupId+'_'+member.UserOrGroupId)) {
                                members.add(member);
                            }
                            
                        }*/
                        if(ldap.IDCed__c=='8717' && ldap.Ruolo_LDAP__c=='100' && ldap.Profilo_LDAP__c=='NEC_D.7'){
                            //Filiale2499
                            GroupMember member= new GroupMember();
                            member.GroupId= eccMap.get('Filiale2499').Id;
                            member.UserOrGroupId=u.Id;
                            if (!gMembers.contains(member.GroupId+'_'+member.UserOrGroupId)) {
                                members.add(member);
                            }
                        }
                        //Eccezioni
                        if(ldap.Attivo__c){
                            User uc = u.clone(true,true,false,false);
                            String profilo = ldap.Profilo_LDAP__c.replaceAll('\\.','_');
                            Profilo_BPER__mdt profiloBper = (Profilo_BPER__mdt)mProfiliBPER.get(profilo);
                            Boolean toUpdate = false;

                            // è variato il profilo
                            if (u.Profilo__c!=ldap.Profilo_LDAP__c && profiloBper!=null) {
                                toUpdate = true;
                                Id profileId = null;
                                Set<String> profili = new Set<String>();
                                if (!String.isEmpty(profiloBper.Profilo_Salesforce__c)) {
                                    profili.add(profiloBper.Profilo_Salesforce__c);
                                }
                                if (!String.isEmpty(profiloBper.Profilo_Salesforce_ENG__c)) {
                                    profili.add(profiloBper.Profilo_Salesforce_ENG__c);
                                }
                                for (String p : profili) {
                                    if (mProfiliSalesforce.containsKey(p)) {
                                        profileId = mProfiliSalesforce.get(p);
                                        break;
                                    }
                                }
                                if (profileId!=null) {
                                    u.profileId = profileId;
                                }
                            }

                            if(u.idced__c != ldap.IDCed__c ||
                                u.PTF_RuoloLDAP__c   != ldap.Ruolo_LDAP__c){
                                // SGANCIO REFERENTI
                                u.ReferenteDaSganciare__c = true;
                                // SGANCIO REFERENTI
                            }

                            // START DK - REASSIGN USER TO QUEUE

                            if(u.Profilo__c != ldap.Profilo_LDAP__c || u.idced__c != ldap.IDCed__c ){
                                if(u.Profilo__c == 'NEC_D.10' && ldap.Profilo_LDAP__c == 'NEC_T.7'){
                                    if(u.idced__c != ldap.IDCed__c){
                                      userUpdateQueues.add(u);
                                    }
                                }else{
                                    userUpdateQueues.add(u);
                                }
                                
                                if(u.PTF_RuoloLDAP__c   != ldap.Ruolo_LDAP__c ){
                                    removeUsersList.add(u.id);
                                }    
                            }
                            // END DK - REASSIGN USER TO QUEUE
                            if(u.Profilo__c != ldap.Profilo_LDAP__c){
                                toUpdate = true;
                                u.Profilo__c = ldap.Profilo_LDAP__c;
                            }
                            //START DK  PERMISSIONSET
                            if(u.CRM_PermissionSet__c != ldap.CRM_PermissionSet__c){
                                toUpdate = true;
                                User ucPS = new User(Id = u.Id, CRM_PermissionSet__c = u.CRM_PermissionSet__c);
                                u.CRM_PermissionSet__c = ldap.CRM_PermissionSet__c;
                                userWithDifferentPSOldMap.put(u.Id, ucPS);
                                userWithDifferentPSList.add(u);
                            }
                            //START DK  PERMISSIONSET
                            // riassegno il ruolo
                            if (profiloBper!=null) {
                                if (!String.isBlank(profiloBper.Ruolo_Saleforce__c)) {
                                    if(u.UserRoleId != (mRuoliSalesforce.containsKey(profiloBper.Ruolo_Saleforce__c) ? mRuoliSalesforce.get(profiloBper.Ruolo_Saleforce__c) : null)){
                                        toUpdate = true;
                                    }
                                    u.UserRoleId = (mRuoliSalesforce.containsKey(profiloBper.Ruolo_Saleforce__c) ? mRuoliSalesforce.get(profiloBper.Ruolo_Saleforce__c) : null);
                                    if (uc.ProfileId!=u.ProfileId) {
                                    	mUserToUpdateNewRole.put(uc.Id,uc);
                                    }
                                }
                                //COMMENTED BY DK 30/07
                                /*else if(IdCedToRole.containsKey('RIDCED'+ldap.IDCed__c)) {
                                    UserRole userRoleByIdCed = IdCedToRole.get('RIDCED'+ldap.IDCed__c);
                                    u.idced__c = ldap.IDCed__c;
                                    u.UserRoleId= userRoleByIdCed.Id;
                                    if (uc.idced__c!=u.idced__c) {
                                        mUserToUpdateNewRole.put(uc.Id,uc);
                                    }
                                }*/
                                //COMMENTED BY DK 30/07
                                //START DK 30/07 - VISIBILITA PORTAFOGLI
                                else {        
                                    if(IdCedToRole.containsKey('RIDCED'+ldap.IDCed__c)) {
                                        UserRole userRoleByIdCed = IdCedToRole.get('RIDCED'+ldap.IDCed__c);
                                        u.idced__c = ldap.IDCed__c;
                                        if (uc.idced__c!=u.idced__c || u.UserRoleId != userRoleByIdCed.Id) {
                                            toUpdate = true;
                                            u.UserRoleId= userRoleByIdCed.Id;
                                            mUserToUpdateNewRole.put(uc.Id,uc);
                                        }
                                    }

                                    System.debug('DK mRoleGroupFilialeMDS: ' + JSON.serialize(mRoleGroupFilialeMDS));

                                    // CR 60703 -- Gestione profili macroDivisionMap
                                    if(u.Profilo__c == 'NEC_D.2' && u.abi__c == '05387') {
                                        if(!String.isBlank(u.PTF_DivisionUO__c) && viewAllMMDSMap.containsKey('ViewAll_' + u.PTF_DivisionUO__c)){

                                            GroupMember member = new GroupMember();
                                            member.GroupId = viewAllMMDSMap.get('ViewAll_' + u.PTF_DivisionUO__c);
                                            member.UserOrGroupId = u.Id;
                                            if (!gMembers.contains(member.GroupId + '_' + member.UserOrGroupId)) {
                                                members.add(member);
                                            }
                                        }else if(!String.isBlank(u.PTF_MacroDivisionUO__c)){
                                            for(String division : macroDivisionMap.get(u.PTF_MacroDivisionUO__c)){
                                                if(viewAllMMDSMap.containsKey('ViewAll_' + division)){
                                                    GroupMember member = new GroupMember();
                                                    member.GroupId = viewAllMMDSMap.get('ViewAll_' + division);
                                                    member.UserOrGroupId = u.Id;
                                                    if (!gMembers.contains(member.GroupId + '_' + member.UserOrGroupId)) {
                                                        members.add(member);
                                                    }
                                                }
                                            }
                                        }else if(String.isBlank(u.PTF_DivisionUO__c)){
                                            for(String groupName : viewAllMMDSMap.keySet()){
                                                GroupMember member = new GroupMember();
                                                member.GroupId = viewAllMMDSMap.get(groupName);
                                                member.UserOrGroupId = u.Id;
                                                if (!gMembers.contains(member.GroupId + '_' + member.UserOrGroupId)) {
                                                    members.add(member);
                                                }
                                            }
                                        }
                                    }
                                    // CR 60703 -- Fine

                                    // CR 52803
                                    List<String> idCedList = new List<String>{ldap.IDCed__c};
                                    if(kciSet.contains(ldap.idced__c) && !String.isBlank(ldap.IdCedFittizia__c) && ldap.IdCedFittizia__c != ldap.IdCed__c){
                                        idCedList.add(ldap.IdCedFittizia__c);
                                    }
                                    // CR 52803
                                    System.debug('DK idCedList: ' + JSON.serialize(idCedList));

                                    if(!String.isBlank(ldap.Vicario__c)){
                                        // CR 52803
                                        for(String idced : idCedList){
                                            for(String mds : Batch_CreaVisibilita.MDSMap.keySet()){
                                                if(mRoleGroupFilialeMDS.containsKey('RIDCED'+idced+'_'+Batch_CreaVisibilita.MDSMap.get(mds).PTF_NameAbbreviation__c)) {
                                                    GroupMember member= new GroupMember();
                                                    member.GroupId= mRoleGroupFilialeMDS.get('RIDCED'+idced+'_'+Batch_CreaVisibilita.MDSMap.get(mds).PTF_NameAbbreviation__c).Id;
                                                    member.UserOrGroupId=u.Id;
                                                    if (!gMembers.contains(member.GroupId+'_'+member.UserOrGroupId)) {
                                                        members.add(member);
                                                    }
                                                }
                                            }
                                        }
                                    }else{
                                        String ldapCode = mappingRuoliMDS.containsKey(ldap.Ruolo_LDAP__c) ? ldap.Ruolo_LDAP__c : '0'+ldap.Ruolo_LDAP__c;
                                        if(mappingRuoliMDS.containsKey(ldapCode)){

                                            if(mappingRuoliMDS.get(ldapCode) == 'Tutti'){
                                                // CR 52803
                                                for(String idced : idCedList){
                                                    for(String mds : Batch_CreaVisibilita.MDSMap.keySet()){
                                                        if(mRoleGroupFilialeMDS.containsKey('RIDCED'+idced+'_'+Batch_CreaVisibilita.MDSMap.get(mds).PTF_NameAbbreviation__c)){
                                                            GroupMember member= new GroupMember();
                                                            member.GroupId= mRoleGroupFilialeMDS.get('RIDCED'+idced+'_'+Batch_CreaVisibilita.MDSMap.get(mds).PTF_NameAbbreviation__c).Id;
                                                            member.UserOrGroupId=u.Id;
                                                            if (!gMembers.contains(member.GroupId+'_'+member.UserOrGroupId)) {
                                                                members.add(member);
                                                            }
                                                        }                                          
                                                    }
                                                }
                                            }else{
                                                // CR 52803
                                                for(String idced : idCedList){
                                                    for(String mds : mappingRuoliMDS.get(ldapCode).split(',')){
                                                        if(mRoleGroupFilialeMDS.containsKey('RIDCED'+idced+'_'+Batch_CreaVisibilita.MDSMap.get(mds.toUpperCase()).PTF_NameAbbreviation__c)){
                                                            GroupMember member= new GroupMember();
                                                            member.GroupId= mRoleGroupFilialeMDS.get('RIDCED'+idced+'_'+Batch_CreaVisibilita.MDSMap.get(mds.toUpperCase()).PTF_NameAbbreviation__c).Id;
                                                            member.UserOrGroupId=u.Id;
                                                            if (!gMembers.contains(member.GroupId+'_'+member.UserOrGroupId)) {
                                                                members.add(member);
                                                            }
                                                        }                                          
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                                //END DK 30/07 - VISIBILITA PORTAFOGLI
                            }
                            
                            /*
                            // è variato il ruolo
                            if(IdCedToRole.containsKey('RIDCED'+ldap.IDCed__c)) {
                            	UserRole userRoleByIdCed = IdCedToRole.get('RIDCED'+ldap.IDCed__c);
                            	mUserToUpdateNewRole.put(uc.Id,uc);
                            	u.UserRoleId= userRoleByIdCed.Id;
                            }
                            */
                            if(toUpdate){

                                userToUpdate.add(u);
                            }
                        }
                    }
                    
                }
                
            }
            if(userToUpdate.size()>0){
                OnUserTriggerHandler.skipUpdateMember=true;
                //FollowUp.invokeFutureGruppi = false;
                Database.update(userToUpdate, false);
                for (User u : userToUpdate) {
                    if (mUserToUpdateNewRole.containsKey(u.Id)) {
                        utentiCambioRuolo += 1;
                        userToUpdateNewRole.add(u);
                    }
                }
                //FollowUp.invokeFutureGruppi = true;
            }
            if(!userWithDifferentPSList.isEmpty()){
                System.enqueueJob(new PermissionSetAsignmentQueuableJobs(userWithDifferentPSList, userWithDifferentPSOldMap, null));
            }
            utentiUpdatati+=userToUpdate.size();
            if(members.size()>0){
                Database.insert(members, false);
            }
        }
        catch(Exception exc) {
            // intercept the error
            // set a boolean variable to true so the process is "blocked"
            System.debug(NOME_CLASSE+' - An exception occurred during create records : '+exc.getMessage());
            testoMail = NOME_CLASSE+' - An exception occurred during create records : '+exc.getMessage()+'<br/>'+exc.getStackTraceString();
            mandaMail('Errore',testoMail);
            errorOnCreate = true;
        }
    }

    

    public static Map<String, String> mappingRuoliMDS {

        get{
            if(mappingRuoliMDS != null)return mappingRuoliMDS;
            mappingRuoliMDS = new Map<String, String>();
            for(MappingRuoliMDS__mdt mappiing : [SELECt id, CodiceRuolo__c, MDS__c FROM MappingRuoliMDS__mdt]){
                mappingRuoliMDS.put(mappiing.CodiceRuolo__c, mappiing.MDS__c);
            }
            return mappingRuoliMDS;
        }set;
    }
    
    global void finish(Database.BatchableContext BC) {
        AsyncApexJob a = [
            SELECT	Id,
            		Status,
            		NumberOfErrors,
            		JobItemsProcessed,
            		TotalJobItems,
            		CreatedBy.Email
            		FROM AsyncApexJob 
            		WHERE Id = :BC.getJobId()
        	];
        
        testoMail = '';

        try
        {
            if(!removeUsersList.isEmpty()){
                EliminaUserDoppioPresidio.eliminaUtenti(removeUsersList);
            }
            if (userToUpdateNewRole.size()>0) {
                FollowUp.invokeBatchUpdateUserDoppiPresidi = true;
                FollowUp.invokeFutureUpdateUserDoppiPresidi = false;
                onUserTriggerHandler.updateRuoloUtente(userToUpdateNewRole, mUserToUpdateNewRole);
            }
            // START DK - REASSIGN USER TO QUEUE
            if(!userUpdateQueues.isEmpty()){
                onUserTriggerHandler.updateQueues(userUpdateQueues);
            }
            // END DK - REASSIGN USER TO QUEUE
            /*if (newUsers.size()>0) {
                // onUserTriggerHandler.impostaPermissionSet(newUsers);
                System.enqueueJob(new PermissionSetAsignmentQueuableJobs(null, null, newUsers));
            }*/
        }
        catch(Exception exc){
            System.debug('An Execption occurred : '+exc.getMessage());
            testoMail = NOME_CLASSE+' - An exception occurred during updateRuoloUtente : '+exc.getMessage()+'<br/>'+exc.getStackTraceString();
            mandaMail('Errore',testoMail);
            testoMail = '';
        }
        
        if (errorOnCreate) {
            testoMail += '<span style="{color:red;}">Ci sono stati degli errori durante la fase di gestione dei record. sono state inviate le mail</span><br/><br/>';
        }
        testoMail = testoMail + NOME_CLASSE + ' Apex job ha processato '+a.TotalJobItems+' job con '+a.NumberOfErrors+' errori.<br/>';
        testoMail += 'Numero totale di Record elaborati : '+recordElab+'<br/>';
        testoMail += 'Numero totale di Utenti updatati : '+utentiUpdatati+'<br/>';
        testoMail += 'Numero totale di Utenti creati : '+utentiCreati+'<br/>';
        testoMail += 'Numero totale di Utenti non creati : '+utentiNonCreati+'<br/>';
        String errorTable = '';
        if (errorOnCreationUser.size()>0) {
            errorTable +='<table border="1">';
            errorTable +='<thead>';
            errorTable +='<tr>';
            errorTable +='<th>Matricola</th>';
            errorTable +='<th>Errore</th>';
            errorTable +='</tr>';
            errorTable +='</thead>';
            errorTable +='<tbody>';
            for (String key : errorOnCreationUser.keySet()) {
                errorTable +='<tr>';
                errorTable +=('<td>'+key+'</td>');
                errorTable +=('<td>'+errorOnCreationUser.get(key)+'</td>');
                errorTable +='</tr>';
            }
            errorTable +='</tbody>';
            errorTable +='</table>';
            testoMail += errorTable;
            testoMail += '<br/>';
        }
        
        if (debug.Verbose__c) {
        	mandaMail('Recap',testoMail);
        }
        
        if (sj!=null && sj.size()>0 && !errorOnCreate) {
            JobRunner.executeNext(sj);
        }
    }
    
    /***
     * custom methods
	 ***/
    private static Map<String,Id> getRuoliSalesforce(Map<String,sObject> profiliBPER) {
        Set<String> ruoli = new Set<String>();
        Map<String,Id> mRuoli = new Map<String,Id>();
        for (String key : profiliBPER.keySet()) {
            Profilo_BPER__mdt p = (Profilo_BPER__mdt)profiliBPER.get(key);
            if (!String.isBlank(p.Ruolo_Saleforce__c)) {
                ruoli.add(p.Ruolo_Saleforce__c);
            }
        }
        if (ruoli.size()>0) {
            List<UserRole> roles = [
                SELECT	Id,
                        DeveloperName
                FROM UserRole
                WHERE DeveloperName =:ruoli
            ];
            for (UserRole ur : roles) {
                mRuoli.put(ur.DeveloperName,ur.Id);
            }
        }
        
        return mRuoli;
    }
    
    private static Map<String,Id> getProfiliSalesforce() {
        Map<String,Id> profili = new Map<String,Id>();
        List<Profile> profs = [
            SELECT Id,Name
            FROM Profile
        ];
        if (profs!=null && profs.size()>0) {
            for (Profile p : profs) {
                profili.put(p.Name,p.Id);
            }
        }
        
        return profili;
    } 
    
    private static Map<String,String> generateSSOAttribute(Struttura_Banca__c sb,LDAP__c ldap, Boolean isSandbox) {
        Map<String,String> attributes = new Map<String,String>();
        String userName = ldap.Matricola__c.replace('U', '')+'@gruppobper.it';
        if (isSandbox) {
            String Suffix = URL.getOrgDomainUrl().toExternalForm().split('\\.')[0].split('--')[1];
            userName +='.'+suffix;
        }
        if (Test.isRunningTest()) {
            username +='.test';
        }
        attributes.put('User.Email',ldap.Email__c);
        attributes.put('User.FirstName',ldap.Nome__c);
        attributes.put('User.LastName',ldap.Cognome__c);
        attributes.put('User.IsActive','1');
        attributes.put('User.Profilo__c',ldap.Profilo_LDAP__c);
        // NEW DK PERMISSIONSET
        attributes.put('User.CRM_PermissionSet__c',ldap.CRM_PermissionSet__c);
        // NEW DK PERMISSIONSET
        attributes.put('User.idced__c',ldap.IDCed__c);
        attributes.put('User.abi__c',(sb!=null ? sb.ABI__c : null));
        attributes.put('User.Username',userName);
        attributes.put('User.FederationIdentifier',ldap.Matricola__c.replace('U', ''));
        return attributes;
    }
    
    private static Boolean isValidEmail(String email) {
        Boolean res = false;
        if (!String.isEmpty(email)) {
            String emailRegex = '^[a-zA-Z0-9._|\\\\%#~`=?&/$^*!}{+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,4}$';
            Pattern MyPattern = Pattern.compile(emailRegex);
            Matcher MyMatcher = MyPattern.matcher(email);
            
            res = (!MyMatcher.matches() ? false : true);
        }
        
        return res;
    }
    
    private static Set<String> findGroupMembers(Set<Id> idUsers) {
        Set<String> gMembers = new Set<String>();
        List<GroupMember> members = [SELECT Id,UserOrGroupId, GroupId FROM GroupMember WHERE UserOrGroupId IN:idUsers];
        for (GroupMember gm : members) {
            gMembers.add(gm.GroupId+'_'+gm.UserOrGroupId);
        }
        return gMembers;
    }
    
    private static Map<String,UserRole> findRole(Set<String> RIDCEDSet){
        Map<String,UserRole> returnMap = new Map<String,UserRole>();
        
        List<UserRole> roles= [SELECT Id, DeveloperName FROM UserRole WHERE DeveloperName IN:RIDCEDSet ];
        
        for(UserRole r: roles){
            returnMap.put(r.DeveloperName, r);
        }
        
        return returnMap;
    }
    
    private static Map<String,User> findUtenti(Set<String> matricolaSet,Boolean useIsActive){
        Map<String,User> returnMap = new Map<String,User>();
        List<User> users;
        if (useIsActive) {
            users = [SELECT Id, ProfileId,FederationIdentifier,IsActive,UserRoleId,Profilo__c,idced__c, abi__c, PTF_DivisionUO__c, PTF_MacroDivisionUO__c, PTF_RuoloLDAP__c, CRM_PermissionSet__c 
                     FROM User 
                     WHERE FederationIdentifier IN:matricolaSet AND isActive=true];
        }
        else {
            users = [SELECT Id, ProfileId,FederationIdentifier,IsActive,UserRoleId,Profilo__c,idced__c, abi__c, PTF_DivisionUO__c, PTF_MacroDivisionUO__c, PTF_RuoloLDAP__c, CRM_PermissionSet__c 
                     FROM User 
                     WHERE FederationIdentifier IN:matricolaSet];
        }
        for(User u: users){
            returnMap.put(u.FederationIdentifier, u);
        }
        
        return returnMap;
    }
    
    private static Map<String,Struttura_Banca__c> getStrutturaBanca() {
        Map<String,Struttura_Banca__c> mStruttura = new Map<String,Struttura_Banca__c>();
        List<Struttura_Banca__c> sbs =  [
            SELECT	Id,
            Descrizione__c,
            Livello__c,
            IDCed__c,
            Stato__c,
            ABI__c
            FROM Struttura_Banca__c
            WHERE Stato__c ='A'
        ];
        if (sbs!=null && sbs.size()>0) {
            for (Struttura_Banca__c sb : sbs) {
                mStruttura.put(sb.IDCed__c,sb);
            }
        }
        return mStruttura;
    }
    
    public void mandaMail(String tipoMail, String mailBody) {
        String subject = (tipoMail=='Errore' ? 'Errore ' : (tipoMail=='Warning' ? 'Warning ' :'Elaborazione '))+NOME_CLASSE;
        Utenti_Speciali__mdt utenteSviluppatore = (Utenti_Speciali__mdt)MetadataUtility.getRecordByName('Utenti_Speciali__mdt', COD_SVILUPPATORI);
        List<Utenti_Speciali__mdt> utentiSpeciali = (List<Utenti_Speciali__mdt>)MetadataUtility.getRecordByPrefix('Utenti_Speciali__mdt', COD_CLASSE);
        Set<Id> idUtentiSpeciali = new Set<Id>();
        Set<String> emails = new Set<String>();
        for (Utenti_Speciali__mdt us : utentiSpeciali) {
            if (!String.isEmpty(us.ID_Utente__c)) {
                idUtentiSpeciali.add(us.ID_Utente__c);
            }
            if (!String.isEmpty(us.Email__c) && debug.Email__c) {
                emails.add(us.Email__c);
            }
        }
        if (utenteSviluppatore!=null) {
            if (!String.isEmpty(utenteSviluppatore.ID_Utente__c)) {
                idUtentiSpeciali.add(utenteSviluppatore.ID_Utente__c);
            }
            if (!String.isEmpty(utenteSviluppatore.Email__c) && debug.Email__c) {
                emails.add(utenteSviluppatore.Email__c);
            }
        }
        if (idUtentiSpeciali.size()>0) {
            for (Id idUtente : idUtentiSpeciali) {
                generaMail(mailBody,subject,idUtente,emails, utenteSviluppatore);
            }
        }
        else if (emails.size()>0) {
            generaMail(mailBody,subject,null,emails, utenteSviluppatore);
        }
    }
    
    public void generaMail(String mailBody,String subject,Id idUtente,Set<String> addresses, Utenti_Speciali__mdt utenteSviluppatore) {
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        if (idUtente!=null) {
            mail.setTargetObjectId(idUtente);
        }
        mail.setSenderDisplayName('Salesforce');
        if (utenteSviluppatore!=null && !String.isEmpty(utenteSviluppatore.Email__c)) {
            mail.setReplyTo(utenteSviluppatore.Email__c);
        }
        mail.setSubject(subject);
        if (!Test.isRunningTest() && addresses.size()>0) {
            mail.setToAddresses(new List<String>(addresses));
        }
        mail.setBccSender(false);
        mail.setUseSignature(false);
        mail.setSaveAsActivity(false);
        mail.setHtmlBody(mailBody);
        if (!Test.isRunningTest()) {
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        }
    }
}