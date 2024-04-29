/**
* Controller of multipleAssignement LWC
*
* @author  Dam Kebe @Lutech
* @version 1.0
* @since   2020-07-08
* @testedIn ManageGestoriControllerTest
*/

// LV CR NEC #70081
public without sharing class ManageGestoriController {

    //public static Set<String> modelliBanca = new Set<String>{'Key Client Privati', 'Consulenti Finanziari', 'Enti e Tesorerie', 'LARGE CORPORATE'};
    //public static Set<String> modelliUffPrivate = new Set<String>{'Private'};
    //public static Set<String> modelliDirezione = new Set<String>{'Private','SMALL BUSINESS','Corporate','Personal'};
    
    @AuraEnabled
    public static Map<String,Object> init(String recordId){
        
        Wallet__c currentPF = [SELECT id, Name, PTF_Area__r.PTF_Idced__c, PTF_DirezioneRegionale__r.PTF_Idced__c, PTF_Banca__r.PTF_Idced__c, PTF_DeletionDate__c , PTF_Filiale__c, PTF_Filiale__r.PTF_BranchTypology__c, PTF_ModelloDiServizio__c,PTF_Pool__c,/*CR 52359 SV start*/PTF_UffPrivate__r.PTF_IdCED__c, PTF_UffPrivate__r.PTF_IdCEDPadre__c,PTF_ABI__c, /*CR 52359 SV end*//*SV Centri Private start*/PTF_CentrPrivate__c,PTF_CentrPrivate__r.PTF_IdCED__c,PTF_CentrPrivate__r.PTF_IdCEDPadre__c,/*SV Centri Private end*/ (SELECT id FROM Accounts__r WHERE PTF_OFS__c = true) FROM Wallet__c WHERE id =: recordId LIMIT 1][0];
        List<String> eligibleRoles = new List<String>();
        //List<String> eligibleRolesGerarchia = new List<String>();
        Set<String> idCedGerarchiaSet = new Set<String>{currentPF.PTF_Area__r.PTF_Idced__c, currentPF.PTF_DirezioneRegionale__r.PTF_Idced__c, currentPF.PTF_Banca__r.PTF_Idced__c};
        Map<String, Set<String>> roleMDSMap = new Map<String, Set<String>>();
        for(RoleMDS__c roleMDS : [SELECT Id, PTF_RoleTypology__c, PTF_ServiceModel__r.Name
                        FROM RoleMDS__c 
                        WHERE PTF_BranchTypology__c =: currentPF.PTF_Filiale__r.PTF_BranchTypology__c AND
                        PTF_RoleTypology__c != '' AND
                        PTF_StartDate__c <=: Date.today()
                        AND (PTF_EndDate__c >=: Date.today() OR PTF_EndDate__c=null)]){

            if(!roleMDSMap.containsKey(roleMDS.PTF_RoleTypology__c)){

                roleMDSMap.put(roleMDS.PTF_RoleTypology__c, new Set<String>());
            }
            roleMDSMap.get(roleMDS.PTF_RoleTypology__c).add(roleMDS.PTF_ServiceModel__r.Name);
            if(roleMDS.PTF_ServiceModel__r.Name == currentPF.PTF_ModelloDiServizio__c){
                
                eligibleRoles.add(roleMDS.PTF_RoleTypology__c+'_'+roleMDS.PTF_ServiceModel__r.Name.toUpperCase());
            }
        }

        /*for(RoleMDS__c roleMDS : [SELECT Id, PTF_RoleTypology__c, PTF_ServiceModel__r.Name, PTF_IdcedFunzionale__c
                        FROM RoleMDS__c 
                        WHERE PTF_IdcedFunzionale__c IN: idCedGerarchiaSet AND
                        PTF_IdcedFunzionale__c != '' AND
                        PTF_RoleTypology__c != '' AND
                        PTF_StartDate__c <=: Date.today()
                        AND (PTF_EndDate__c >=: Date.today() OR PTF_EndDate__c=null)]){

            if(!roleMDSMap.containsKey(roleMDS.PTF_RoleTypology__c)){

                roleMDSMap.put(roleMDS.PTF_RoleTypology__c, new Set<String>());
            }
            roleMDSMap.get(roleMDS.PTF_RoleTypology__c).add(roleMDS.PTF_ServiceModel__r.Name);
            if(roleMDS.PTF_ServiceModel__r.Name.toUpperCase() == currentPF.PTF_ModelloDiServizio__c.toUpperCase()){
                
                eligibleRolesGerarchia.add(roleMDS.PTF_RoleTypology__c+'_'+roleMDS.PTF_ServiceModel__r.Name.toUpperCase()+'_'+roleMDS.PTF_IdcedFunzionale__c);
            }
        }*/

        return new Map<String,Object> {

            'currentPF' => currentPF,
            'idCedGerarchiaSet' => idCedGerarchiaSet,
            'eligibleRoles' => eligibleRoles,
            //'eligibleRolesGerarchia' => eligibleRolesGerarchia,
            'roleMDSMap' => roleMDSMap,
            'hasOFS' => !currentPF.Accounts__r.isEmpty(),
            'idCedBanca'=> currentPF.PTF_Banca__r.PTF_Idced__c,
            'idCedDR' => currentPF.PTF_DirezioneRegionale__r.PTF_Idced__c,
            'idCedArea' => currentPF.PTF_Area__r.PTF_Idced__c,
            'isChecked999' => currentPF.Name.right(3) == '999',
            'isPTFSvil' => currentPF.Name.right(6).startsWith('666') // LV CR NEC #70081
        }; 
    }
    
    @AuraEnabled
    public static List<Map<String, Object>> getGestoriList(String recordId, Map<String, List<String>> roleMDSMap, String recordTypeName){

        List<Map<String, Object>> assignmentList = new List<Map<String, Object>>();
        System.debug('DK roleMDSMap: ' + JSON.serialize(roleMDSMap));
        for(Assignment__c assignment : [SELECT id, PTF_Gestore__r.Name,PTF_Gestore__r.Email, PTF_Gestore__r.PTF_RegistrationNumber__c,
                                        PTF_Gestore__r.AccountId,PTF_Gestore__r.Account.Name, PTF_Gestore__r.PTF_TipologiaRuolo__c
                                        FROM Assignment__c 
                                        WHERE PTF_MicroWallet__c =: recordId
							            AND PTF_EndDate__c = null
            							AND RecordTypeId =: Schema.getGlobalDescribe().get('Assignment__c').getDescribe().getRecordTypeInfosByDeveloperName().get(recordtypeName).getRecordTypeId()]){
            
            Map<String, Object> assignmentObject = new Map<String, Object>();
            assignmentObject.put('Id', assignment.Id);
            assignmentObject.put('contactId', assignment.PTF_Gestore__c);
            assignmentObject.put('Name', assignment.PTF_Gestore__r.Name);
            assignmentObject.put('Email', assignment.PTF_Gestore__r.Email);
            assignmentObject.put('Filiale', assignment.PTF_Gestore__r.Account.Name);
            if(roleMDSMap.containsKey(assignment.PTF_Gestore__r.PTF_TipologiaRuolo__c)){

                assignmentObject.put('PTF_ModelloDiServizio__c', String.join(roleMDSMap.get(assignment.PTF_Gestore__r.PTF_TipologiaRuolo__c), ', '));
            }
            assignmentObject.put('PTF_RegistrationNumber__c', assignment.PTF_Gestore__r.PTF_RegistrationNumber__c);
            assignmentList.add(assignmentObject);
        }

        return assignmentList;
    }

    @AuraEnabled
    public static Map<String, Object> searchGestoriList(String params, String filiale, List<String> eligibleRoles, Integer offset, integer pagesize,String profileName, Boolean isChecked999,
    Boolean isCheckedPTF) { // LV CR NEC #70081
        
        System.debug('DK paramsMap: ' + params);
        Map<String, Object> paramsMap = (Map<String, Object>) JSON.deserializeUntyped(params);
        //List<String> eligibleRolesGerarchia = paramsMap.containsKey('eligibleRolesGerarchia') ? (List<String>)JSON.deserialize(JSON.serialize(paramsMap.get('eligibleRolesGerarchia')), List<String>.class) : new List<String>();
        Set<String> idCedGerarchiaSet = paramsMap.containsKey('idCedGerarchiaSet') ? (Set<String>)JSON.deserialize(JSON.serialize(paramsMap.get('idCedGerarchiaSet')), Set<String>.class) : new Set<String>();
        String idCedBanca = paramsMap.containsKey('idCedBanca') ? (String) paramsMap.get('idCedBanca'): null;
        String idCedDR = paramsMap.containsKey('idCedDR') ? (String)paramsMap.get('idCedDR'): null;
        String idCedArea = paramsMap.containsKey('idCedArea') ? (String)paramsMap.get('idCedArea'): null;
        System.debug('@@@@idcedarea: '+idCedArea);
        System.debug('@@@@idCedDR: '+idCedDR);
        System.debug('@@@@idCedBanca: '+idCedBanca);
        System.debug('@@@@filiale: '+filiale);
        System.debug('@@@@profileName: '+profileName);
        Boolean hasOFS = (Boolean)paramsMap.get('hasOFS');
        //List<String> contactIdList = (List<String>)JSON.deserialize(JSON.serialize(paramsMap.get('contactIdList')), List<String>.class);
        string recordId = (String)paramsMap.get('recordId');
        String mds = (String)paramsMap.get('mds');
        //Get Filiale Branch
        List<Account> acc= [SELECT Id, PTF_BranchTypology__c, PTF_UffPrivate__c, PTF_Banca__r.FinServ__BankNumber__c FROM Account WHERE Id=:filiale];

        //Get Filiale Branch
        String branchT=acc[0].PTF_BranchTypology__c;
         //Get Filiale Branch
        //Get UfficiPrivate DR
        Set<String> idCedUffPrivate= SV_Utilities.getSet([SELECT PTF_IdCEDUffPrivate__c FROM ConfigUffPrivateDR__c WHERE PTF_IdCEDDR__c=:idCedDR], 'PTF_IdCEDUffPrivate__c');
        Set<String> idCedUffPrivate_CP= SV_Utilities.getSet([SELECT PTF_IdCEDUffPrivate__c, PTF_IdCP__c FROM ConfigUffPrivateDR__c WHERE PTF_IdCEDDR__c=:idCedDR], '{PTF_IdCEDUffPrivate__c}_{PTF_IdCP__c}', true, false);
        //Get UfficiPrivate DR
        
        //Get Role Typology 41 e 42
        Set<String> role41_42= SV_Utilities.getSet([SELECT Id FROM RoleTypology__c WHERE PTF_Code__c IN ('041','042')], 'Id');
        //Get Role Typology 41 e 42
        //Contatti Da Escludere
        Map<String, Set<String>> contactToExcludeMap = new Map<String, Set<String>>();
        contactToExcludeMap.put('progressivo', new Set<String>());
        contactToExcludeMap.put('ptf999', new Set<String>());
        contactToExcludeMap.put('ptfsviluppo', new Set<String>());
        for(Assignment__c assignment : [SELECT PTF_Gestore__c, PTF_MicroWallet__r.Name FROM Assignment__c WHERE ((RecordType.DeveloperName = 'Primario' AND PTF_EndDate__c = null AND PTF_MicroWallet__r.PTF_ModelloDiServizio__c =: mds AND PTF_MicroWallet__r.PTF_Filiale__c =: filiale) OR (RecordType.DeveloperName = 'Backup' AND PTF_MicroWallet__c =: recordId AND PTF_EndDate__c = null))]){
            if(assignment.PTF_MicroWallet__r.Name.right(3) == '999'){
                contactToExcludeMap.get('ptf999').add(assignment.PTF_Gestore__c);
            }else if(assignment.PTF_MicroWallet__r.Name.right(6).startsWith('666')){
                contactToExcludeMap.get('ptfsviluppo').add(assignment.PTF_Gestore__c);
            }else{
                contactToExcludeMap.get('progressivo').add(assignment.PTF_Gestore__c);
            }
        }
        System.debug('DK searchGestoriList_isChecked999: ' + isChecked999);
        System.debug('DK searchGestoriList_isCheckedPTF: ' + isCheckedPTF);
        System.debug('DK searchGestoriList_contactToExcludeMap: ' + JSON.serialize(contactToExcludeMap));
        Set<String> contactToExclude = isChecked999 ? contactToExcludeMap.get('ptf999') :
        isCheckedPTF ? contactToExcludeMap.get('ptfsviluppo') :
        contactToExcludeMap.get('progressivo');
        // Set<String> contactToExclude= SV_Utilities.getSet([SELECT PTF_Gestore__c FROM Assignment__c WHERE ((RecordType.DeveloperName = 'Primario' AND PTF_EndDate__c = null AND PTF_MicroWallet__r.PTF_ModelloDiServizio__c =: mds AND PTF_MicroWallet__r.PTF_Filiale__c =: filiale) OR (RecordType.DeveloperName = 'Backup' AND PTF_MicroWallet__c =: recordId AND PTF_EndDate__c = null)) AND (NOT PTF_MicroWallet__r.Name LIKE '%999') AND (NOT PTF_MicroWallet__r.Name LIKE '%-555%') ], 'PTF_Gestore__c'); // LV CR NEC #70081
        Set<String> contactToExcludeBackup= SV_Utilities.getSet([SELECT PTF_Gestore__c FROM Assignment__c WHERE PTF_MicroWallet__c =: recordId AND PTF_EndDate__c = null], 'PTF_Gestore__c');
        //Contatti Da Escludere
        //Query Filiale
        String queryFiliale= 'SELECT Id, PTF_CentroPrivate__c, Name, Email, PTF_RegistrationNumber__c, Account.Name, PTF_TipologiaRuolo__c , Account.PTF_IdCEDPadre__c, Account.PTF_IdCED__c, PTF_Ruolo__c ' +
                            ' FROM Contact WHERE ' +
                            ' PTF_ReferenteElegibile__c=true AND AccountId =\'' +(filiale != null ? String.escapeSingleQuotes(filiale) : filiale)+ '\' ';
        if(hasOFS){

            queryFiliale += ' AND PTF_OFS__c =: hasOFS ';
        }
        if (!String.isBlank((String)paramsMap.get('matricola'))) {
            queryFiliale += ' AND PTF_RegistrationNumber__c =\''+ String.escapeSingleQuotes((String)paramsMap.get('matricola'))+'\'';
        }
        //Query Filiale
        //Query Banca
        String queryBanca= 'SELECT Id, Name, PTF_CentroPrivate__c, Email, PTF_RegistrationNumber__c, AccountId, Account.Name, PTF_TipologiaRuolo__c , Account.PTF_IdCEDPadre__c, Account.PTF_IdCED__c, PTF_Ruolo__c, Account.PTF_Banca__r.FinServ__BankNumber__c ' +
                            ' FROM Contact WHERE ' +
                            ' PTF_ReferenteElegibile__c=true AND Account.PTF_IdCEDPadre__c =\'' + (idCedBanca!= null ? String.escapeSingleQuotes(idCedBanca) : idCedBanca) + '\' ';
        if(hasOFS){

            queryBanca += ' AND PTF_OFS__c =: hasOFS ';
        }
        if (!String.isBlank((String)paramsMap.get('matricola'))) {
            queryBanca += ' AND PTF_RegistrationNumber__c =\''+ String.escapeSingleQuotes((String)paramsMap.get('matricola'))+'\'';
        }
        //Query Banca
        //Query DR
        String queryDR= 'SELECT Id, Name, PTF_CentroPrivate__c, Email, PTF_RegistrationNumber__c, Account.Name, PTF_TipologiaRuolo__c, Account.PTF_IdCEDPadre__c, Account.PTF_IdCED__c, PTF_Ruolo__c ' +
                            ' FROM Contact WHERE ' +
                            ' PTF_ReferenteElegibile__c=true AND Account.PTF_IdCEDPadre__c =\'' + (idCedDR != null ? String.escapeSingleQuotes(idCedDR) : idCedDR) + '\' ';
        if(hasOFS){

            queryDR += ' AND PTF_OFS__c =: hasOFS ';
        }
        if (!String.isBlank((String)paramsMap.get('matricola'))) {
            queryDR += ' AND PTF_RegistrationNumber__c =\''+ String.escapeSingleQuotes((String)paramsMap.get('matricola'))+'\'';
        }
        //Query DR
        //Query Area
        String queryArea= 'SELECT Id, Name, PTF_CentroPrivate__c, Email, PTF_RegistrationNumber__c, Account.Name, PTF_TipologiaRuolo__c, Account.PTF_IdCEDPadre__c, Account.PTF_IdCED__c, PTF_Ruolo__c ' +
                            ' FROM Contact WHERE ' +
                            ' PTF_ReferenteElegibile__c=true AND Account.PTF_IdCED__c =\'' + (idCedArea != null ? String.escapeSingleQuotes(idCedArea) : idCedArea) + '\' ';
        if(hasOFS){

            queryArea += ' AND PTF_OFS__c =: hasOFS ';
        }
        if (!String.isBlank((String)paramsMap.get('matricola'))) {
            queryArea += ' AND PTF_RegistrationNumber__c =\''+ String.escapeSingleQuotes((String)paramsMap.get('matricola'))+'\'';
        }

        //Query Area

        //NEW UFF PRIVATE
        //Query UffPrivateFiliale
        String listParam = '';
        String listParamfinal = '';
        List<String> allTitolariPR = new List<String>();
        for(Account uff: [SELECT PTF_UffPrivate__c FROM Account WHERE PTF_UffPrivate__c != NULL])
            allTitolariPR.add(uff.PTF_UffPrivate__c);
        for(Account exe: [SELECT id FROM Account WHERE PTF_IdCEDPadre__c ='3008'])
            allTitolariPR.add(exe.id);
        for(String elem: allTitolariPR){
            listParam = '\''+elem+'\',';
            listParamfinal=listParam+listParamfinal;
        }
        listParamfinal=listParamfinal.removeEnd(',');
        String queryUffPrivateFiliale = 'SELECT Id, Name, PTF_CentroPrivate__c, Email, PTF_RegistrationNumber__c, AccountId, Account.Name, PTF_TipologiaRuolo__c , Account.PTF_IdCEDPadre__c, Account.PTF_IdCED__c, PTF_Ruolo__c  ' +
            ' FROM Contact WHERE ' +
            ' PTF_ReferenteElegibile__c=true AND AccountId IN ('+(listParamfinal != null ? String.escapeSingleQuotes(listParamfinal) : listParamfinal)+')';
            
        if(hasOFS){

            queryUffPrivateFiliale += ' AND PTF_OFS__c =: hasOFS ';
        }
        if (!String.isBlank((String)paramsMap.get('matricola'))) {
            queryUffPrivateFiliale += ' AND PTF_RegistrationNumber__c =\''+ String.escapeSingleQuotes((String)paramsMap.get('matricola'))+'\'';
        }
        //Query UffPrivateFiliale
        List<Contact> contactFiliale = new List<Contact>();
        List<Contact> contactBanca = new List<Contact>();
        List<Contact> contactDR = new List<Contact>();
        List<Contact> contactArea = new List<Contact>();
        List<Contact> contactUffPrivateFiliale = new List<Contact>();
        if(String.isNotBlank(filiale)){
            contactFiliale= Database.query(queryFiliale);
            System.debug('LP contactFiliale '+JSON.serialize(contactFiliale));
        }

        if(String.isNotBlank(idCedBanca)){
            contactBanca= Database.query(queryBanca);
            System.debug('LP contactBanca '+JSON.serialize(contactBanca));
        }

        if(String.isNotBlank(idCedDR)){
            contactDR= Database.query(queryDR);
            System.debug('LP contactDR '+JSON.serialize(contactDR));
        }

        if(String.isNotBlank(idCedArea)){
            contactArea= Database.query(queryArea);
            System.debug('LP contactArea '+JSON.serialize(contactArea));
        }

        //NEW UFF PRIVATE
        if(mds=='Private' && acc[0].PTF_Banca__r.FinServ__BankNumber__c == '05387'){
            contactUffPrivateFiliale= Database.query(queryUffPrivateFiliale);
            System.debug('LP contactUffPrivateFiliale '+JSON.serialize(contactUffPrivateFiliale));
        }
        //NEW UFF PRIVATE

        List<Contact> refs= new List<Contact>();
        //Ref Filiale
        for(Contact con:contactFiliale){
            if(eligibleRoles.contains(con.PTF_TipologiaRuolo__c+'_'+mds.toUpperCase()) && (((String)paramsMap.get('recordTypeName') == 'Primario' && !contactToExclude.contains(con.Id))  || ((String)paramsMap.get('recordTypeName') == 'Backup' && !contactToExcludeBackup.contains(con.Id))  ) ){
                refs.add(con);
            }
        }
        //Ref Filiale
        //Ref Area
        for(Contact con:contactArea){
            if(eligibleRoles.contains(con.PTF_TipologiaRuolo__c+'_'+mds.toUpperCase()) && (((String)paramsMap.get('recordTypeName') == 'Primario' && !contactToExclude.contains(con.Id))  || ((String)paramsMap.get('recordTypeName') == 'Backup' && !contactToExcludeBackup.contains(con.Id))  ) ){
                refs.add(con);
            }
        }
        //Ref Area
        //Ref DR
        for(Contact con:contactDR){
            /*if(modelliDirezione.contains(mds)){
                if((mds.equals('SMALL BUSINESS') || mds.equals('Corporate')) && branchT.equals('A')){
                    if(eligibleRolesGerarchia.contains(con.PTF_TipologiaRuolo__c+'_'+mds.toUpperCase()+'_'+con.Account.PTF_IdCEDPadre__c) && (((String)paramsMap.get('recordTypeName') == 'Primario' && !contactToExclude.contains(con.Id))  || ((String)paramsMap.get('recordTypeName') == 'Backup' && !contactToExcludeBackup.contains(con.Id))  ) ){
                        refs.add(con);
                    }
                }
                else if(mds.equals('Personal') || mds.equals('Private') ){
                    if(eligibleRolesGerarchia.contains(con.PTF_TipologiaRuolo__c+'_'+mds.toUpperCase()+'_'+con.Account.PTF_IdCEDPadre__c) && (((String)paramsMap.get('recordTypeName') == 'Primario' && !contactToExclude.contains(con.Id))  || ((String)paramsMap.get('recordTypeName') == 'Backup' && !contactToExcludeBackup.contains(con.Id))  ) ){
                        refs.add(con);
                    }
                }
            }*/
            if(con.Account.Name.startsWithIgnoreCase('Uff. Sviluppo ') && con.PTF_Ruolo__c=='100'){
                for(String key:role41_42){
                    if(eligibleRoles.contains(key+'_'+mds.toUpperCase()) && (((String)paramsMap.get('recordTypeName') == 'Primario' && !contactToExclude.contains(con.Id))  || ((String)paramsMap.get('recordTypeName') == 'Backup' && !contactToExcludeBackup.contains(con.Id))  ) ){
                        refs.add(con);
                    }
                }
            }
            else if(eligibleRoles.contains(con.PTF_TipologiaRuolo__c+'_'+mds.toUpperCase()) && (((String)paramsMap.get('recordTypeName') == 'Primario' && !contactToExclude.contains(con.Id))  || ((String)paramsMap.get('recordTypeName') == 'Backup' && !contactToExcludeBackup.contains(con.Id))  ) ){
                refs.add(con);
            }
            
        }
        //Ref DR

        //Ref Banca
        for(Contact con:contactBanca){
            /*if(modelliBanca.contains(mds)){
                if(eligibleRolesGerarchia.contains(con.PTF_TipologiaRuolo__c+'_'+mds.toUpperCase()+'_'+con.Account.PTF_IdCEDPadre__c) && (((String)paramsMap.get('recordTypeName') == 'Primario' && !contactToExclude.contains(con.Id))  || ((String)paramsMap.get('recordTypeName') == 'Backup' && !contactToExcludeBackup.contains(con.Id))  ) ){
                    refs.add(con);
                }
            }*/
            
            if(mds=='Private'){
                //Uffici Private BPER
                if(con.Account.PTF_Banca__r.FinServ__BankNumber__c == '01015'){
                    if(idCedUffPrivate.contains(con.Account.PTF_IdCED__c)){
                        if((con.PTF_Ruolo__c=='100')/*
                        ||(isCheckedPTF == true)*/){ // LV CR NEC #70081
                            if(eligibleRoles.contains(con.PTF_TipologiaRuolo__c+'_'+mds.toUpperCase()) && !contactToExcludeBackup.contains(con.Id)){
                                refs.add(con);
                            }
                        }
                        else{
                            if(idCedUffPrivate_CP.contains(con.Account.PTF_IdCed__c+'_'+con.PTF_CentroPrivate__c) && eligibleRoles.contains(con.PTF_TipologiaRuolo__c+'_'+mds.toUpperCase()) && (((String)paramsMap.get('recordTypeName') == 'Primario' && !contactToExclude.contains(con.Id))  || ((String)paramsMap.get('recordTypeName') == 'Backup' && !contactToExcludeBackup.contains(con.Id))  ) ){
                                refs.add(con); 
                            }
                        }   
                    }
                }
                //Uffici Private BPER
                //Ufficio Private BDS
                /*if(con.Account.PTF_IdCED__c=='5690'){
                    if(eligibleRoles.contains(con.PTF_TipologiaRuolo__c+'_'+mds.toUpperCase()) && (((String)paramsMap.get('recordTypeName') == 'Primario' && !contactToExclude.contains(con.Id))  || ((String)paramsMap.get('recordTypeName') == 'Backup' && !contactToExcludeBackup.contains(con.Id))  ) ){
                        refs.add(con);
                    }
                }*/
                //Ufficio Private BDS
            }/*
            else if(isChecked999 == true) {
                if(eligibleRoles.contains(con.PTF_TipologiaRuolo__c+'_'+mds.toUpperCase())) refs.add(con);
            } */ 
             else if(eligibleRoles.contains(con.PTF_TipologiaRuolo__c+'_'+mds.toUpperCase()) && !contactToExclude.contains(con.Id)){
                 refs.add(con);
             }
            else if(eligibleRoles.contains(con.PTF_TipologiaRuolo__c+'_'+mds.toUpperCase()) && (((String)paramsMap.get('recordTypeName') == 'Primario' && !contactToExclude.contains(con.Id))  || ((String)paramsMap.get('recordTypeName') == 'Backup' && !contactToExcludeBackup.contains(con.Id))  ) ){
                refs.add(con);
            }  
        }
        //Ref Banca

        //REF PRIVATE BPER
        for(Contact con : contactUffPrivateFiliale){
            // if(con.AccountId == acc[0].PTF_UffPrivate__c){
                if(con.PTF_Ruolo__c=='F_144'){
                    if(eligibleRoles.contains(con.PTF_TipologiaRuolo__c+'_'+mds.toUpperCase()) && !contactToExcludeBackup.contains(con.Id)){
                        refs.add(con);
                    }
                    //Executive
                    if((profileName.equals('NEC_D.0')||profileName.equals('System Administrator')) && con.Account.PTF_IdCEDPadre__c=='3008')
                        refs.add(con);
                }
                else{
                    if(/*idCedUffPrivate_CP.contains(con.Account.PTF_IdCed__c+'_'+con.PTF_CentroPrivate__c) && */eligibleRoles.contains(con.PTF_TipologiaRuolo__c+'_'+mds.toUpperCase()) && (((String)paramsMap.get('recordTypeName') == 'Primario' && !contactToExclude.contains(con.Id))  || ((String)paramsMap.get('recordTypeName') == 'Backup' && !contactToExcludeBackup.contains(con.Id))  ) ){
                        refs.add(con); 
                    }
                }   
            // }
        }
        //REF PRIVATE BPER

        //Ref Consulenti Finanziari
        if(mds=='Consulenti Finanziari' && (String)paramsMap.get('recordTypeName') == 'Primario' ){
            List<Contact> consFin=[SELECT Id, Name, Email, PTF_RegistrationNumber__c, Account.Name, PTF_TipologiaRuolo__c, Account.PTF_IdCEDPadre__c, Account.PTF_IdCED__c, PTF_Ruolo__c  FROM Contact WHERE Account.PTF_IdCed__c='7113' AND PTF_Ruolo__c IN ('990','991')];
            for(Contact con:consFin){
                if(!contactToExclude.contains(con.Id)){
                    refs.add(con);
                }
            }
        }
        //Ref Consulenti Finanziari
        Set<Contact> refSet= new Set<Contact>(refs);
        return new Map<String, Object>{
            'referentiListCount' => refSet.size(),
            'referentiList' => refSet
        };
        /*String query = 'SELECT Id, Name, Email, PTF_RegistrationNumber__c, Account.Name, PTF_TipologiaRuolo__c ' +
                            ' FROM Contact WHERE ' +
                            ' Id NOT IN : contactIdList AND PTF_ManagePortafoglioEnable__c = TRUE ';
        if (modelliBanca.contains(mds)) {
            
            query += ' AND ((AccountId =\'' + filiale + '\' AND PTF_TipologiaRuolo__c IN: eligibleRoles) OR (Account.PTF_Banca__r.PTF_IdCED__c IN: idCedGerarchiaSet AND PTF_TipologiaRuolo__c IN: eligibleRolesGerarchia)) ';
        }else if(modelliDirezione.contains(mds)){

            query += ' AND ((AccountId =\'' + filiale + '\' AND PTF_TipologiaRuolo__c IN: eligibleRoles) OR (Account.PTF_DirezioneRegionale__r.PTF_IdCED__c IN: idCedGerarchiaSet AND PTF_TipologiaRuolo__c IN: eligibleRolesGerarchia)) ';
        }else{
            
            query += ' AND (AccountId =\'' + filiale + '\' AND PTF_TipologiaRuolo__c IN: eligibleRoles) ';
        }

        if(hasOFS){

            query += ' AND PTF_OFS__c =: hasOFS ';
        }

        if (!String.isBlank((String)paramsMap.get('matricola'))) {
            query += ' AND PTF_RegistrationNumber__c =\''+ String.escapeSingleQuotes((String)paramsMap.get('matricola'))+'\'';
        }

        if((String)paramsMap.get('recordTypeName') == 'Primario'){

            query += ' AND Id NOT IN (SELECT PTF_Gestore__c FROM Assignment__c WHERE RecordType.DeveloperName = \'Primario\' AND PTF_EndDate__c = null AND PTF_MicroWallet__r.PTF_ModelloDiServizio__c =: mds AND PTF_MicroWallet__r.PTF_Filiale__c =: filiale) ' + 
                     ' AND Id NOT IN (SELECT PTF_Gestore__c FROM Assignment__c WHERE RecordType.DeveloperName = \'Backup\' AND PTF_MicroWallet__c =: recordId AND PTF_EndDate__c = null)';
        }else if((String)paramsMap.get('recordTypeName') == 'Backup'){

            query += ' AND Id NOT IN (SELECT PTF_Gestore__c FROM Assignment__c WHERE RecordType.DeveloperName = \'Primario\' AND PTF_MicroWallet__c =: recordId AND PTF_EndDate__c = null) ';
        }
        
        System.debug('DK contactIdList: ' + contactIdList);
        System.debug('DK eligibleRoles: ' + eligibleRoles);
        System.debug('DK idCedGerarchiaSet: ' + idCedGerarchiaSet);
        System.debug('DK eligibleRolesGerarchia: ' + eligibleRolesGerarchia);
        System.debug('DK hasOFS: ' + hasOFS);
        System.debug('DK recordId: ' + recordId);
        System.debug('DK mds: ' + mds);
        System.debug('DK query: ' + query);
        List<Contact> queryResult = Database.query(query);
        return new Map<String, Object>{
            'referentiListCount' => queryResult.size(),
            'referentiList' => queryResult
        };*/
    }

    @AuraEnabled
    public static void deleteSelectedGestori(String recordId, List<String> gestoriToDelete, String recordTypeName) {
        
        String recordTypeId = Schema.getGlobalDescribe().get('Assignment__c').getDescribe().getRecordTypeInfosByDeveloperName().get(recordTypeName).getRecordTypeId();
        // EDB 2020-08-02 rimosso per nuova logica
        //delete [SELECT id FROM Assignment__c WHERE PTF_MicroWallet__c =: recordId AND RecordTypeId =: recordTypeId AND Id IN: gestoriToDelete];
        // EDB 2020-08-02 aggiunto popolamento campo data di fine -- inizio
        List<Assignment__c> assignments = [SELECT id, PTF_EndDate__c, PTF_EndDate_DT__c FROM Assignment__c WHERE PTF_MicroWallet__c =: recordId AND RecordTypeId =: recordTypeId AND Id IN: gestoriToDelete];
        for(Assignment__c assign : assignments) {
            assign.PTF_EndDate__c = Date.today();
            assign.PTF_EndDate_DT__c = Datetime.now();
        }
        update assignments;
        // EDB 2020-08-02 aggiunto popolamento campo data di fine -- fine
        /*if(recordTypeName == 'Primario'){
            String unassignedGestoreId = [SELECT Id FROM User WHERE Profile.Name = 'TechnicalProfilePortafogliazione' LIMIT 1][0].Id;
            update new Wallet__c(Id = recordId, OwnerId = unassignedGestoreId);
        }*/
    }
    
    @AuraEnabled
    public static void insertNewGestori(String recordId, List<String> gestoriToInsert, String recordTypeName) {

        String recordTypeId = Schema.getGlobalDescribe().get('Assignment__c').getDescribe().getRecordTypeInfosByDeveloperName().get(recordTypeName).getRecordTypeId();
        /*if (recordTypeName == 'Primario') {
            
            // EDB 2020-08-02 rimosso per nuova logica
            //delete [SELECT id FROM Assignment__c WHERE PTF_MicroWallet__c =: recordId AND RecordTypeId =: recordTypeId];
            List<Contact> cnts = [SELECT Id, PTF_User__c FROM Contact WHERE Id IN :gestoriToInsert];
            update new Wallet__c(Id=recordId, OwnerId=cnts[0].PTF_User__c);
        }*/
        
        // EDB 2020-08-02 rimosso per nuova logica -- inizio
        // aggiunto campo PTF_StartDate__c = Date.today();
        // EDB 2020-08-02 rimosso per nuova logica -- fine
        List<Assignment__c> assignmentsToInsert = new List<Assignment__c>();
        for(String contactId : gestoriToInsert){
            assignmentsToInsert.add(new Assignment__c(
                PTF_MicroWallet__c = recordId,
                PTF_Gestore__c = contactId,
                RecordTypeId = recordTypeId,
                PTF_StartDate__c = Date.today(),
                PTF_StartDate_DT__c = Datetime.now()
            ));
        }
        insert assignmentsToInsert;
    }

    @AuraEnabled
    public static PercentageWrapper getPercentage(Id recordId, Id selectedRef){
        Id rectypeId= Schema.SObjectType.Assignment__c.getRecordTypeInfosByDeveloperName().get('Primario').getRecordTypeId();
        PercentageWrapper wrap= new PercentageWrapper();
        Decimal totalCountBefore=0;
        Decimal totalCountAfter;
        Map<String, Decimal> beforeMap=new Map<String, Decimal> ();
        Map<String, Decimal> afterMap=new Map<String, Decimal> ();
        List<AggregateResult> arList = [SELECT PTF_MicroWallet__r.PTF_ModelloDiServizio__c, COUNT(Id) c
                                        FROM Assignment__c
                                        WHERE PTF_Gestore__c=:selectedRef AND PTF_EndDate__c=null AND RecordTypeId=:rectypeId
                                        GROUP BY PTF_MicroWallet__r.PTF_ModelloDiServizio__c
                                        ORDER BY COUNT(Id) DESC
                                        ];
        system.debug(JSON.serialize(arList));
        for(AggregateResult ar: arList){
            totalCountBefore= totalCountBefore +Integer.valueOf(ar.get('c'));
            }
        Wallet__c wal =[SELECT Id, PTF_ModelloDiServizio__c FROM Wallet__c WHERE Id=:recordId][0];
        
        for(AggregateResult ar: arList){
            system.debug('@@@@@ sonoqui: '+totalCountAfter);
            totalCountAfter=totalCountBefore+1;
            system.debug('@@@@@ sonoqui: '+totalCountAfter);
            Decimal perBefore= Integer.valueOf(ar.get('c'))/totalCountBefore;
            beforeMap.put(String.valueOf(ar.get('PTF_ModelloDiServizio__c')), perBefore.setScale(2,RoundingMode.HALF_UP) );
        }
        if(beforeMap.containsKey(wal.PTF_ModelloDiServizio__c)){
            for(AggregateResult ar: arList){
                if(ar.get('PTF_ModelloDiServizio__c')==wal.PTF_ModelloDiServizio__c){
                    Decimal perAfter= (Integer.valueOf(ar.get('c'))+1)/totalCountAfter;
                    afterMap.put(String.valueOf(ar.get('PTF_ModelloDiServizio__c')), perAfter.setScale(2,RoundingMode.HALF_UP) );
                }
                else{
                    Decimal perAfter= Integer.valueOf(ar.get('c'))/totalCountAfter;
                    afterMap.put(String.valueOf(ar.get('PTF_ModelloDiServizio__c')), perAfter.setScale(2,RoundingMode.HALF_UP) );
                }
            }
        }
        else{
            for(AggregateResult ar: arList){
                Decimal perAfter= Integer.valueOf(ar.get('c'))/totalCountAfter;
                afterMap.put(String.valueOf(ar.get('PTF_ModelloDiServizio__c')), perAfter.setScale(2,RoundingMode.HALF_UP) );
            }
            system.debug('@@@@@ sonoqui: '+totalCountAfter);
            if(totalCountBefore!=0){
                Decimal perAfter= 1/totalCountAfter;
                afterMap.put(wal.PTF_ModelloDiServizio__c,perAfter.setScale(2,RoundingMode.HALF_UP)) ;
            }
            else{
                
                afterMap.put(wal.PTF_ModelloDiServizio__c,1) ;
            }
            
        }
        wrap.beforeMap=beforeMap;
        wrap.afterMap=afterMap;

        return wrap;
    }

    public class PercentageWrapper{
        @AuraEnabled public Map<String, Decimal> beforeMap;
        @AuraEnabled public Map<String, Decimal> afterMap;
    }

    //CR 52359 SV start
    @AuraEnabled
    public static Map<String, Object> searchGestoriPrivateList(String params,String recordId,String modelloServizio, String filiale, Boolean isCheck999, Boolean isPTFSvil){
        System.debug(LoggingLevel.DEBUG,'### paramsMap: ' + params);
        Map<String, Object> paramsMap = (Map<String, Object>) JSON.deserializeUntyped(params);
        String idCed = paramsMap.containsKey('idCed') ? (String) paramsMap.get('idCed'): null;
        String idCedPadre = paramsMap.containsKey('idCedPadre') ? (String) paramsMap.get('idCedPadre'): null;
        String abi = paramsMap.containsKey('abi') ? (String) paramsMap.get('abi'): null;
        //SV Centri Private start
        String idCedCentroPrivate = paramsMap.containsKey('idCedCentroPrivate') ? (String) paramsMap.get('idCedCentroPrivate') : null;
        String idCedPadreCentroPrivate = paramsMap.containsKey('idCedPadreCentroPrivate') ? (String) paramsMap.get('idCedPadreCentroPrivate') : null; 
        List<String> idCedList = new List<String>{idCed};
        if(idCedCentroPrivate != null){
            idCedList.add(idCedCentroPrivate);
        }
        List<String> idCedPadreList = new List<String>{idCedPadre};
        if(idCedPadreCentroPrivate != null){
            idCedPadreList.add(idCedPadreCentroPrivate);
        }
        //SV Centri Private start
        //Set<String> contactToExcludeBackup= SV_Utilities.getSet([SELECT PTF_Gestore__c FROM Assignment__c WHERE PTF_MicroWallet__c =: recordId AND PTF_EndDate__c = null], 'PTF_Gestore__c');
        //List<String> contactIdList = (List<String>)JSON.deserialize(JSON.serialize(paramsMap.get('contactIdList')), List<String>.class);
        Map<String, Set<String>> contactToExcludeMap = new Map<String, Set<String>>();
        contactToExcludeMap.put('progressivo', new Set<String>());
        contactToExcludeMap.put('ptf999', new Set<String>());
        contactToExcludeMap.put('ptfsviluppo', new Set<String>());
        for(Assignment__c assignment : [SELECT PTF_Gestore__c, PTF_MicroWallet__r.Name FROM Assignment__c WHERE RecordType.DeveloperName = 'Primario' AND PTF_EndDate__c = null AND PTF_MicroWallet__r.PTF_ModelloDiServizio__c =: modelloServizio AND PTF_MicroWallet__r.PTF_Filiale__c =: filiale]){
            if(assignment.PTF_MicroWallet__r.Name.right(3) == '999'){
                contactToExcludeMap.get('ptf999').add(assignment.PTF_Gestore__c);
            }else if(assignment.PTF_MicroWallet__r.Name.right(6).startsWith('666')){
                contactToExcludeMap.get('ptfsviluppo').add(assignment.PTF_Gestore__c);
            }else{
                contactToExcludeMap.get('progressivo').add(assignment.PTF_Gestore__c);
            }
        }
        Set<String> contactToExclude = isCheck999 ? contactToExcludeMap.get('ptf999') : isPTFSvil ? contactToExcludeMap.get('ptfsviluppo') : contactToExcludeMap.get('progressivo');
        // Set<String> contactToExclude= SV_Utilities.getSet([SELECT PTF_Gestore__c FROM Assignment__c WHERE RecordType.DeveloperName = 'Primario' AND PTF_EndDate__c = null AND PTF_MicroWallet__r.PTF_ModelloDiServizio__c =: modelloServizio AND PTF_MicroWallet__r.PTF_Filiale__c =: filiale AND (NOT PTF_MicroWallet__r.Name LIKE '%999') AND (NOT PTF_MicroWallet__r.Name LIKE '%-555%')], 'PTF_Gestore__c'); // LV CR NEC #70081
        System.debug(LoggingLevel.DEBUG,'### contactToExclude: '+contactToExclude);
        //SV Centri Private start
        //List<Contact> contactList = [SELECT Id, PTF_CentroPrivate__c, Name, PTF_RegistrationNumber__c, Account.Name, PTF_TipologiaRuolo__c, PTF_IdCED__c, PTF_TipologiaRuolo__r.PTF_Code__c, PTF_ProfiloLDAP__c   FROM Contact WHERE PTF_IdCED__c IN (:idCed,:idCedPadre)];
        List<Contact> contactList = new List<Contact>();
        if(idCedCentroPrivate != null && idCedPadreCentroPrivate != null){
            contactList = [SELECT Id, PTF_CentroPrivate__c, Name, PTF_RegistrationNumber__c, Account.Name, PTF_TipologiaRuolo__c, PTF_IdCED__c, PTF_TipologiaRuolo__r.PTF_Code__c, PTF_ProfiloLDAP__c   FROM Contact WHERE PTF_IdCED__c IN (:idCed,:idCedPadre,:idCedCentroPrivate,:idCedPadreCentroPrivate)];
        }else{
            contactList = [SELECT Id, PTF_CentroPrivate__c, Name, PTF_RegistrationNumber__c, Account.Name, PTF_TipologiaRuolo__c, PTF_IdCED__c, PTF_TipologiaRuolo__r.PTF_Code__c, PTF_ProfiloLDAP__c   FROM Contact WHERE PTF_IdCED__c IN (:idCed,:idCedPadre)];
        }
        //SV Centri Private end
        System.debug(LoggingLevel.DEBUG,'### contactList: '+contactList);
        Set<Contact> refs= new Set<Contact>();
        //SV Centri Private - modifica delle condizione con aggiusta che il PTF_IdCED__c del contatto sia contentuto all'iterno della lista di idCed del l'ufficio e del centro start
        for(Contact con : contactList){
            //if(String.isNotBlank(con.PTF_TipologiaRuolo__r.PTF_Code__c) && String.isNotBlank(con.PTF_ProfiloLDAP__c) && con.PTF_TipologiaRuolo__r.PTF_Code__c.equals('069') && (con.PTF_ProfiloLDAP__c.equals('NEC_T.8') || (con.PTF_ProfiloLDAP__c.equals('NEC_D.5') && abi == '01015')) && !contactToExclude.contains(con.Id) && con.PTF_IdCED__c.equals(idCed)){
            if(String.isNotBlank(con.PTF_TipologiaRuolo__r.PTF_Code__c) && String.isNotBlank(con.PTF_ProfiloLDAP__c) && con.PTF_TipologiaRuolo__r.PTF_Code__c.equals('069') && (con.PTF_ProfiloLDAP__c.equals('NEC_T.8') || (con.PTF_ProfiloLDAP__c.equals('NEC_D.5') && abi == '01015')) && !contactToExclude.contains(con.Id) && idCedList.contains(con.PTF_IdCED__c)){ 
                refs.add(con);
            }
            //if(String.isNotBlank(con.PTF_TipologiaRuolo__r.PTF_Code__c) && String.isNotBlank(con.PTF_ProfiloLDAP__c) && con.PTF_TipologiaRuolo__r.PTF_Code__c.equals('F_140') && con.PTF_ProfiloLDAP__c.equals('NEC_T.7') && con.PTF_IdCED__c.equals(idCed)) {
            if(String.isNotBlank(con.PTF_TipologiaRuolo__r.PTF_Code__c) && String.isNotBlank(con.PTF_ProfiloLDAP__c) && con.PTF_TipologiaRuolo__r.PTF_Code__c.equals('F_140') && con.PTF_ProfiloLDAP__c.equals('NEC_T.7') && idCedList.contains(con.PTF_IdCED__c)) {    
                refs.add(con);
            }
            /*if(String.isNotBlank(con.PTF_TipologiaRuolo__r.PTF_Code__c) &&
                String.isNotBlank(con.PTF_ProfiloLDAP__c) && 
                con.PTF_TipologiaRuolo__r.PTF_Code__c.equals('F_144') && 
                (con.PTF_ProfiloLDAP__c.equals('NEC_D.10') || con.PTF_ProfiloLDAP__c.equals('NEC_T.7'))
                 && (con.PTF_IdCED__c != null && (con.PTF_IdCED__c.equals(idCed) || con.PTF_IdCED__c.equals(idCedPadre)))){*/
            if(String.isNotBlank(con.PTF_TipologiaRuolo__r.PTF_Code__c) && String.isNotBlank(con.PTF_ProfiloLDAP__c) && con.PTF_TipologiaRuolo__r.PTF_Code__c.equals('F_144') && 
               (con.PTF_ProfiloLDAP__c.equals('NEC_D.10') || con.PTF_ProfiloLDAP__c.equals('NEC_T.7')) && (con.PTF_IdCED__c != null && (idCedList.contains(con.PTF_IdCED__c) || idCedPadreList.contains(con.PTF_IdCED__c)))){
                refs.add(con);
            }
            //SV Centri Private - modifica delle condizione con aggiusta che il PTF_IdCED__c del contatto sia contentuto all'iterno della lista di idCed del l'ufficio e del centro end
        }

        Set<Contact> refSet= new Set<Contact>(refs);
        return new Map<String, Object>{
            'referentiListCount' => refSet.size(),
            'referentiList' => refSet
        };
    }

    @AuraEnabled
    public static Map<String,Object> searchGetBackupPrivateList(String params,String recordId,String modelloServizio, String filiale){
        System.debug(LoggingLevel.DEBUG,'### paramsMap: ' + params);
        Map<String, Object> paramsMap = (Map<String, Object>) JSON.deserializeUntyped(params);
        String idCed = paramsMap.containsKey('idCed') ? (String) paramsMap.get('idCed'): null;
        String idCedPadre = paramsMap.containsKey('idCedPadre') ? (String) paramsMap.get('idCedPadre'): null;
        String abi = paramsMap.containsKey('abi') ? (String) paramsMap.get('abi'): null;
        System.debug('idCed: '+idCed);
        System.debug('idCedPadre: '+idCedPadre);
        //SV Centri Private start
        String idCedCentroPrivate = paramsMap.containsKey('idCedCentroPrivate') ? (String) paramsMap.get('idCedCentroPrivate') : null;
        String idCedPadreCentroPrivate = paramsMap.containsKey('idCedPadreCentroPrivate') ? (String) paramsMap.get('idCedPadreCentroPrivate') : null;
        List<String> idCedList = new List<String>{idCed};
        if(idCedCentroPrivate != null){
            idCedList.add(idCedCentroPrivate);
        }
        List<String> idCedPadreList = new List<String>{idCedPadre};
        if(idCedPadreCentroPrivate != null){
            idCedPadreList.add(idCedPadreCentroPrivate);
        }
        //SV Centri Private end
        Set<String> contactToExcludeBackup= SV_Utilities.getSet([SELECT PTF_Gestore__c FROM Assignment__c WHERE PTF_MicroWallet__c =: recordId AND PTF_EndDate__c = null AND (NOT PTF_MicroWallet__r.Name LIKE '%-666%')], 'PTF_Gestore__c'); // LV CR NEC #70081
        //SV Centri Private start
        //List<Contact> contactList = [SELECT Id, PTF_CentroPrivate__c, Name, PTF_RegistrationNumber__c, Account.Name, PTF_TipologiaRuolo__c, PTF_IdCED__c, PTF_TipologiaRuolo__r.PTF_Code__c, PTF_ProfiloLDAP__c   FROM Contact WHERE PTF_IdCED__c IN (:idCed,:idCedPadre)];
        List<Contact> contactList = new List<Contact>();
        if(idCedCentroPrivate != null && idCedPadreCentroPrivate != null){
            contactList = [SELECT Id, PTF_CentroPrivate__c, Name, PTF_RegistrationNumber__c, Account.Name, PTF_TipologiaRuolo__c, PTF_IdCED__c, PTF_TipologiaRuolo__r.PTF_Code__c, PTF_ProfiloLDAP__c   FROM Contact WHERE PTF_IdCED__c IN (:idCed,:idCedPadre,:idCedCentroPrivate,:idCedPadreCentroPrivate)];
        }else{
            contactList = [SELECT Id, PTF_CentroPrivate__c, Name, PTF_RegistrationNumber__c, Account.Name, PTF_TipologiaRuolo__c, PTF_IdCED__c, PTF_TipologiaRuolo__r.PTF_Code__c, PTF_ProfiloLDAP__c   FROM Contact WHERE PTF_IdCED__c IN (:idCed,:idCedPadre)];
        }
        System.debug(LoggingLevel.DEBUG,'### contactList: '+contactList);
        Set<Contact> refs= new Set<Contact>();
        //SV Centri Private - modifica delle condizione con aggiusta che il PTF_IdCED__c del contatto sia contentuto all'iterno della lista di idCed del l'ufficio e del centro start
        for(Contact con : contactList){
            System.debug('TipologiaRuolo: '+con.PTF_TipologiaRuolo__r.PTF_Code__c+' - ProfiloLdap: '+con.PTF_ProfiloLDAP__c+' - idCed: '+con.PTF_IdCED__c);
            //if(String.isNotBlank(con.PTF_TipologiaRuolo__r.PTF_Code__c) && String.isNotBlank(con.PTF_ProfiloLDAP__c) && con.PTF_TipologiaRuolo__r.PTF_Code__c.equals('069') && (con.PTF_ProfiloLDAP__c.equals('NEC_T.8') || (con.PTF_ProfiloLDAP__c.equals('NEC_D.5') && abi == '01015')) && !contactToExcludeBackup.contains(con.Id) && con.PTF_IdCED__c.equals(idCed)){
            if(String.isNotBlank(con.PTF_TipologiaRuolo__r.PTF_Code__c) && String.isNotBlank(con.PTF_ProfiloLDAP__c) && con.PTF_TipologiaRuolo__r.PTF_Code__c.equals('069') && (con.PTF_ProfiloLDAP__c.equals('NEC_T.8') || (con.PTF_ProfiloLDAP__c.equals('NEC_D.5') && abi == '01015')) && !contactToExcludeBackup.contains(con.Id) && idCedList.contains(con.PTF_IdCED__c)){
                System.debug('private baker');
                refs.add(con);
            }
            //if(String.isNotBlank(con.PTF_TipologiaRuolo__r.PTF_Code__c) && String.isNotBlank(con.PTF_ProfiloLDAP__c) && con.PTF_TipologiaRuolo__r.PTF_Code__c.equals('F_140') && con.PTF_ProfiloLDAP__c.equals('NEC_T.7') && con.PTF_IdCED__c.equals(idCed) && !contactToExcludeBackup.contains(con.Id) && con.PTF_IdCED__c.equals(idCed)) {
            if(String.isNotBlank(con.PTF_TipologiaRuolo__r.PTF_Code__c) && String.isNotBlank(con.PTF_ProfiloLDAP__c) && con.PTF_TipologiaRuolo__r.PTF_Code__c.equals('F_140') && con.PTF_ProfiloLDAP__c.equals('NEC_T.7') && idCedList.contains(con.PTF_IdCED__c) && !contactToExcludeBackup.contains(con.Id) && idCedList.contains(con.PTF_IdCED__c)) {
                System.debug('Supervisor');
                refs.add(con);
            }
            /*if(String.isNotBlank(con.PTF_TipologiaRuolo__r.PTF_Code__c) && 
               String.isNotBlank(con.PTF_ProfiloLDAP__c) && 
               con.PTF_TipologiaRuolo__r.PTF_Code__c.equals('F_144') &&
               (con.PTF_ProfiloLDAP__c.equals('NEC_D.10') || con.PTF_ProfiloLDAP__c.equals('NEC_T.7')) &&
               (con.PTF_IdCED__c != null && (con.PTF_IdCED__c.equals(idCed) || con.PTF_IdCED__c.equals(idCedPadre))) && 
               !contactToExcludeBackup.contains(con.Id) && 
               con.PTF_IdCED__c.equals(idCed)){*/
            if(String.isNotBlank(con.PTF_TipologiaRuolo__r.PTF_Code__c) && String.isNotBlank(con.PTF_ProfiloLDAP__c) && con.PTF_TipologiaRuolo__r.PTF_Code__c.equals('F_144') &&
               (con.PTF_ProfiloLDAP__c.equals('NEC_D.10') || con.PTF_ProfiloLDAP__c.equals('NEC_T.7')) && (con.PTF_IdCED__c != null && (idCedList.contains(con.PTF_IdCED__c) || idCedPadreList.contains(con.PTF_IdCED__c))) && 
                !contactToExcludeBackup.contains(con.Id) && idCedList.contains(con.PTF_IdCED__c)){
                System.debug('Executive');
                refs.add(con);
            }
            //SV Centri Private - modifica delle condizione con aggiusta che il PTF_IdCED__c del contatto sia contentuto all'iterno della lista di idCed del l'ufficio e del centro end
        }

        Set<Contact> refSet= new Set<Contact>(refs);
        System.debug('ref: '+refSet);
        return new Map<String, Object>{
            'referentiListCount' => refSet.size(),
            'referentiList' => refSet
        };
    }
    //CR 52359 SV end
}