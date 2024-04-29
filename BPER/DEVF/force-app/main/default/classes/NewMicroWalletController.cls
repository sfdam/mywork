/**
 * @description       :
 * @author            : simone.viglianti@tengroup.it
 * @group             :
 * @last modified on  : 05-16-2022
 * @last modified by  : simone.viglianti@tengroup.it
**/

/** 
* Auhtor		:	Alessandro Lumaca
* Label         :   CR 60703
* Modify Date	:	2022-10-22
* Modify		:	Gestione profili
***/

/**
 * @TestClass   :   NewMicroWalletControllerTest
 */

// LV CR NEC #70081

public without sharing class NewMicroWalletController {

    @AuraEnabled
    public static User currentUser{
        get{
            if(currentUser != null)return currentUser;

            currentUser = [SELECT Id, Profilo__c, abi__c, banca__c FROM User WHERE id =: UserInfo.getUserId()];
            return currentUser;
        }set;
    }

    // CR 60703 -- Gestione profili
    public static Map<String, String> viewAllMMDSMap{
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
    

    public virtual class BaseException extends Exception {}
    public class OtherException extends BaseException {}

    // START DK 02/02 - VISIBILITA PORTAFOGLI KCI
    public static Map<String, String> filialeVirtualeGroupMap {
        get{
            if(filialeVirtualeGroupMap != null){
                return filialeVirtualeGroupMap;
            }

            filialeVirtualeGroupMap = new Map<String, String>();
            Map<String, String> idcedFittiziaMap = new Map<String, String>();
            for(Struttura_Banca__c sb : [SELECT Id, IdCed__c, IDCed_Fittizia__c FROm STRUTTURA_BANCA__c WHERE IDCed_Fittizia__c  != '' AND Codice_Filiale__c IN ('937', '1200','1201')]){
                // filialeVirtualeGroupMap.put(sb.IdCed__c, sb.IDCed_Fittizia__c);
                idcedFittiziaMap.put('RIDCED'+sb.IDCed_Fittizia__c, sb.IdCed__c);
            }

            for(Group gr : [SELECT ID, DeveloperName FROM Group WHERE DeveloperName IN: idcedFittiziaMap.keySet()]){
                
                filialeVirtualeGroupMap.put(idcedFittiziaMap.get(gr.DeveloperName), gr.Id);
            }
            return filialeVirtualeGroupMap;
        }set;
    }
    // END DK 02/02 - VISIBILITA PORTAFOGLI KCI

    @AuraEnabled
    public static WrapperObj getAllData(){
        System.debug('SV getAllData');

        Map<String, SObject> bancheMap = new Map<String, SObject>();
        Map<String, SObject> dirRegionaleMap = new Map<String, SObject>();
        Map<String, SObject> areaMap = new Map<String, SObject>();
        Map<String, SObject> filialeMap = new Map<String, SObject>();
        Map<String, SObject> altraUOMap = new Map<String, SObject>();

        WrapperObj response = new WrapperObj();
        String bancaUtente = !String.isBlank(currentUser.abi__c) ? currentUser.abi__c  : currentUser.banca__c ;
        String condizioneAggiuntiva = currentUser.Profilo__c != 'NEC_D.0' ?
        ' AND FinServ__BankNumber__c = \'' + currentUser.abi__c + '\'': ''; 
        try { 
            bancheMap = SV_Utilities.keyBy([ SELECT Id, Name, FinServ__BankNumber__c, PTF_BranchTypeDesc__c, ParentId, PTF_BranchTypology__c, PTF_Capofila__c, PTF_Area__c, PTF_DirezioneRegionale__c, PTF_Banca__c
                                                    FROM Account 
                                                    WHERE RecordType.DeveloperName =: 'Banca' AND PTF_DataChiusura__c = NULL AND IsPTF__c = TRUE ], 'Id', false);
            System.debug('SV bancheMap: ' + bancheMap);

            response.bancheMap = bancheMap;

            dirRegionaleMap = SV_Utilities.keyBy([ SELECT Id, Name, FinServ__BankNumber__c, PTF_BranchTypeDesc__c, ParentId, PTF_BranchTypology__c, PTF_Capofila__c, PTF_Area__c, PTF_DirezioneRegionale__c, PTF_Banca__c
                                                    FROM Account 
                                                    WHERE RecordType.DeveloperName =: 'DirezioneRegionale' AND PTF_DataChiusura__c = NULL AND IsPTF__c = TRUE ], 'Id', false);
            System.debug('SV dirRegionaleMap: ' + dirRegionaleMap);

            response.dirRegionaleMap = dirRegionaleMap;

            areaMap = SV_Utilities.keyBy([ SELECT Id, Name, FinServ__BankNumber__c, PTF_BranchTypeDesc__c, ParentId, PTF_BranchTypology__c, PTF_Capofila__c, PTF_Area__c, PTF_DirezioneRegionale__c, PTF_Banca__c
                                                    FROM Account 
                                                    WHERE RecordType.DeveloperName =: 'Area' AND PTF_DataChiusura__c = NULL AND IsPTF__c = TRUE ], 'Id', false);
            System.debug('SV areaMap: ' + areaMap);

            response.areaMap = areaMap;

            altraUOMap = SV_Utilities.keyBy([ SELECT Id, Name, FinServ__BankNumber__c, ParentId, PTF_BranchTypology__c, PTF_BranchTypeDesc__c, PTF_Capofila__c, PTF_Area__c, PTF_DirezioneRegionale__c, PTF_Banca__c
                                                    FROM Account 
                                                    WHERE RecordType.DeveloperName =: 'AltraUnitaOrganizzativa' AND PTF_DataChiusura__c = NULL AND IsPTF__c = TRUE ], 'Id', false);
            System.debug('SV altraUOMap: ' + altraUOMap);

            response.altraUOMap = altraUOMap;

            filialeMap = SV_Utilities.keyBy([ SELECT Id, Name, FinServ__BankNumber__c, ParentId, PTF_BranchTypology__c, PTF_Capofila__c, PTF_Area__c, PTF_DirezioneRegionale__c, PTF_Banca__c, 
                                                    PTF_MDSAbilitati__c, PTF_UffPrivate__c, PTF_BranchTypeDesc__c, PTF_IdCed__c
                                                    FROM Account 
                                                    WHERE RecordType.DeveloperName =: 'FilialeDiRelazione' AND PTF_DataChiusura__c = NULL AND IsPTF__c = TRUE ], 'Id', false);
            System.debug('SV filialeMap: ' + filialeMap);

            response.filialeMap = filialeMap;
            response.currentUser = currentUser; 

        } catch (BaseException e) {  
            // This catches the OtherException
            System.debug('SV BaseException ' + e);

        } 

        return response;

    }

    @AuraEnabled
    public static List<String> getAllModelli() {
        List<String> modelli = new List<String>();
        SObjectField picklistUsingGlobal = Wallet__c.Wallet__c.fields.PTF_ModelloDiServizio__c;
        List<PicklistEntry> entries = picklistUsingGlobal.getDescribe().getPicklistValues();
        List<String> modelliNames = new List<String>();
        System.debug('SV entries: ' + entries);
        for (PicklistEntry pe : entries){
        	if(pe.getValue() != 'Non portafogliati') modelliNames.add(pe.getValue());
        }
        return modelliNames;
    }

    @AuraEnabled
    public static Map<String, SObject> getGestoriPrincipali(String filialeId, String modelloServizio, Boolean isChecked999,
    Boolean isCheckedPTF) { // LV CR NEC #70081 

        Map<String, SObject> gestoriPrincipaliMap = new Map<String, SObject>();
        try { 
            Account filiale= [SELECT Id, PTF_BranchTypology__c, PTF_Area__r.PTF_Idced__c,
            PTF_DirezioneRegionale__r.PTF_Idced__c, PTF_Banca__r.PTF_Idced__c, FinServ__BankNumber__c, PTF_UffPrivate__c
            FROM Account WHERE Id=:filialeId];
            Set<String> idCedGerarchiaSet = new Set<String>{filiale.PTF_Area__r.PTF_Idced__c, filiale.PTF_DirezioneRegionale__r.PTF_Idced__c, filiale.PTF_Banca__r.PTF_Idced__c};
            List<String> eligibleRoles = new List<String>();
            //List<String> eligibleRolesGerarchia = new List<String>();

            String idCedBanca = filiale.PTF_Banca__r.PTF_Idced__c;
            String idCedDR = filiale.PTF_DirezioneRegionale__r.PTF_Idced__c;
            String idCedArea = filiale.PTF_Area__r.PTF_Idced__c;
            String bankNumber = filiale.FinServ__BankNumber__c;
            
            system.debug('filiale: '+filiale);
            for(RoleMDS__c roleMDS : [SELECT Id, PTF_RoleTypology__c, PTF_ServiceModel__r.Name
                            FROM RoleMDS__c 
                            WHERE PTF_BranchTypology__c =: filiale.PTF_BranchTypology__c AND
                            PTF_StartDate__c <=: Date.today()
                            AND (PTF_EndDate__c >=: Date.today() OR PTF_EndDate__c=null)]){

                if(roleMDS.PTF_ServiceModel__r.Name.toUpperCase() == modelloServizio.toUpperCase() && roleMDS.PTF_RoleTypology__c!=null){
                    eligibleRoles.add(roleMDS.PTF_RoleTypology__c+'_'+roleMDS.PTF_ServiceModel__r.Name.toUpperCase());
                }
            }
            /*for(RoleMDS__c roleMDS : [SELECT Id, PTF_RoleTypology__c, PTF_ServiceModel__r.Name, PTF_IdcedFunzionale__c
                            FROM RoleMDS__c 
                            WHERE PTF_IdcedFunzionale__c IN: idCedGerarchiaSet AND
                            PTF_IdcedFunzionale__c != '' AND
                            PTF_StartDate__c <=: Date.today()
                            AND (PTF_EndDate__c >=: Date.today() OR PTF_EndDate__c=null)]){

                if(roleMDS.PTF_ServiceModel__r.Name.toUpperCase() == modelloServizio.toUpperCase() && roleMDS.PTF_RoleTypology__c!=null){
                    
                    eligibleRolesGerarchia.add(roleMDS.PTF_RoleTypology__c+'_'+roleMDS.PTF_ServiceModel__r.Name.toUpperCase()+'_'+roleMDS.PTF_IdcedFunzionale__c);
                }
            }*/
            //Set<String> modelliBanca = new Set<String>{'Key Client Privati', 'Consulenti Finanziari', 'Enti e Tesorerie', 'LARGE CORPORATE'};
            //Set<String> modelliDirezione = new Set<String>{'Private','SMALL BUSINESS','Corporate','Personal'};
            Set<String> idCedUffPrivate= SV_Utilities.getSet([SELECT PTF_IdCEDUffPrivate__c FROM ConfigUffPrivateDR__c WHERE PTF_IdCEDDR__c=:idCedDR], 'PTF_IdCEDUffPrivate__c');
            Set<String> idCedUffPrivate_CP= SV_Utilities.getSet([SELECT PTF_IdCEDUffPrivate__c, PTF_IdCP__c FROM ConfigUffPrivateDR__c WHERE PTF_IdCEDDR__c=:idCedDR], '{PTF_IdCEDUffPrivate__c}_{PTF_IdCP__c}', true, false);
            Map<String, Set<String>> contactToExcludeMap = new Map<String, Set<String>>();
            contactToExcludeMap.put('progressivo', new Set<String>());
            contactToExcludeMap.put('ptf999', new Set<String>());
            contactToExcludeMap.put('ptfsviluppo', new Set<String>());
            for(Assignment__c assignment : [SELECT PTF_Gestore__c, PTF_MicroWallet__r.Name FROM Assignment__c WHERE RecordType.DeveloperName = 'Primario' AND PTF_EndDate__c = null AND PTF_MicroWallet__r.PTF_ModelloDiServizio__c =: modelloServizio AND PTF_MicroWallet__r.PTF_Filiale__c =: filialeId]){
                if(assignment.PTF_MicroWallet__r.Name.right(3) == '999'){
                    contactToExcludeMap.get('ptf999').add(assignment.PTF_Gestore__c);
                }else if(assignment.PTF_MicroWallet__r.Name.contains('-666')){
                    contactToExcludeMap.get('ptfsviluppo').add(assignment.PTF_Gestore__c);
                }else{
                    contactToExcludeMap.get('progressivo').add(assignment.PTF_Gestore__c);
                }
            }
            Set<String> contactToExclude = isChecked999 ? contactToExcludeMap.get('ptf999') : isCheckedPTF ? contactToExcludeMap.get('ptfsviluppo') : contactToExcludeMap.get('progressivo');
            // Set<String> contactToExclude= SV_Utilities.getSet([SELECT PTF_Gestore__c FROM Assignment__c WHERE RecordType.DeveloperName = 'Primario' AND PTF_EndDate__c = null AND PTF_MicroWallet__r.PTF_ModelloDiServizio__c =: modelloServizio AND PTF_MicroWallet__r.PTF_Filiale__c =: filialeId AND (NOT PTF_MicroWallet__r.Name LIKE '%999') AND (NOT PTF_MicroWallet__r.Name LIKE '%-666%')], 'PTF_Gestore__c'); // LV CR NEC #70081
            Set<String> role41_42= SV_Utilities.getSet([SELECT Id FROM RoleTypology__c WHERE PTF_Code__c IN ('041','042')], 'Id');
            
            List<Contact> contactFiliale = new List<Contact>();
            List<Contact> contactBanca = new List<Contact>();
            List<Contact> contactDR = new List<Contact>();
            List<Contact> contactArea = new List<Contact>();
            if(String.isNotBlank(filialeId)){
                contactFiliale= [SELECT Id, PTF_CentroPrivate__c, Name, Email, PTF_RegistrationNumber__c, Account.Name, PTF_TipologiaRuolo__c , Account.PTF_IdCEDPadre__c, Account.PTF_IdCED__c, PTF_Ruolo__c FROM Contact WHERE PTF_ReferenteElegibile__c=true AND AccountId=:filialeId];
                System.debug('LP contactFiliale '+JSON.serialize(contactFiliale));
            }

            if(String.isNotBlank(idCedBanca)){
                contactBanca= [SELECT Id, PTF_CentroPrivate__c, Name, Email, PTF_RegistrationNumber__c, Account.Name, PTF_TipologiaRuolo__c , PTF_TipologiaRuolo__r.PTF_Code__c, Account.PTF_IdCEDPadre__c, Account.PTF_IdCED__c, PTF_Ruolo__c, PTF_ProfiloLDAP__c FROM Contact WHERE PTF_ReferenteElegibile__c=true AND Account.PTF_IdCEDPadre__c =:idCedBanca];
                System.debug('LP contactBanca '+JSON.serialize(contactBanca));
            }

            if(String.isNotBlank(idCedDR)){
                contactDR= contactDR= [SELECT Id, PTF_CentroPrivate__c, Name, Email, PTF_RegistrationNumber__c, Account.Name, PTF_TipologiaRuolo__c , Account.PTF_IdCEDPadre__c, Account.PTF_IdCED__c, PTF_Ruolo__c FROM Contact WHERE PTF_ReferenteElegibile__c=true AND Account.PTF_IdCEDPadre__c =:idCedDR];
                System.debug('LP contactDR '+JSON.serialize(contactDR));
            }

            if(String.isNotBlank(idCedArea)){
                contactArea= [SELECT Id, Name, PTF_CentroPrivate__c,Email, PTF_RegistrationNumber__c, Account.Name, PTF_TipologiaRuolo__c , Account.PTF_IdCEDPadre__c, Account.PTF_IdCED__c, PTF_Ruolo__c FROM Contact WHERE PTF_ReferenteElegibile__c=true AND Account.PTF_IdCED__c =:idCedArea];
                System.debug('LP contactArea '+JSON.serialize(contactArea));
            }
            Set<String> refs= new Set<String>();
            //Ref Filiale
            for(Contact con:contactFiliale){
                if(eligibleRoles.contains(con.PTF_TipologiaRuolo__c+'_'+modelloServizio.toUpperCase()) && !contactToExclude.contains(con.Id) ){
                    refs.add(con.Id);
                }
            }
            //Ref Filiale

            //Ref Area
            for(Contact con:contactArea){
                if(eligibleRoles.contains(con.PTF_TipologiaRuolo__c+'_'+modelloServizio.toUpperCase()) && !contactToExclude.contains(con.Id)){
                    refs.add(con.Id);
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
                    if(eligibleRoles.contains(key+'_'+modelloServizio.toUpperCase()) && !contactToExclude.contains(con.Id) ){
                        refs.add(con.Id);
                    }
                }
            }
            else if(eligibleRoles.contains(con.PTF_TipologiaRuolo__c+'_'+modelloServizio.toUpperCase()) && !contactToExclude.contains(con.Id) ){
                refs.add(con.Id);
            }
        }
        //Ref DR

        //Ref Banca
        for(Contact con:contactBanca){
            
            
            if(modelloServizio=='Private'){
                //Uffici Private BPER
                if(idCedUffPrivate.contains(con.Account.PTF_IdCED__c)){
                    if(con.PTF_Ruolo__c=='100' || con.PTF_TipologiaRuolo__r.PTF_Code__c=='300'/* || isChecked999 == true*/) {
                        if(eligibleRoles.contains(con.PTF_TipologiaRuolo__c+'_'+modelloServizio.toUpperCase())){
                            refs.add(con.Id);
                        }
                    }
                    else{
                        // START DK 02/09 - REEFERENTE COORDINATORE ASSISTENTE
                        if(idCedUffPrivate_CP.contains(con.Account.PTF_IdCed__c+'_'+con.PTF_CentroPrivate__c) && eligibleRoles.contains(con.PTF_TipologiaRuolo__c+'_'+modelloServizio.toUpperCase()) && !contactToExclude.contains(con.Id) && (con.PTF_ProfiloLDAP__c != 'NEC_T.8' || con.PTF_TipologiaRuolo__r.PTF_Code__c != '038')){
                        if(idCedUffPrivate_CP.contains(con.Account.PTF_IdCed__c+'_'+con.PTF_CentroPrivate__c) && eligibleRoles.contains(con.PTF_TipologiaRuolo__c+'_'+modelloServizio.toUpperCase()) && !contactToExclude.contains(con.Id)){
                            refs.add(con.Id);
                            refs.add(con.Id);
                        }
                        }
                        // END DK 02/09 - REEFERENTE COORDINATORE ASSISTENTE
                    }     
                }
                //Uffici Private BPER
                //Ufficio Private BDS
                /* if(con.Account.PTF_IdCED__c=='5690'){
                    if(eligibleRoles.contains(con.PTF_TipologiaRuolo__c+'_'+modelloServizio.toUpperCase()) && !contactToExclude.contains(con.Id)){
                        refs.add(con.Id);
                    }
                } */
                //Ufficio Private BDS
            }/*else if(isChecked999 == true){ 
                if(eligibleRoles.contains(con.PTF_TipologiaRuolo__c+'_'+modelloServizio.toUpperCase())) refs.add(con.Id);
            }  */
            else if(eligibleRoles.contains(con.PTF_TipologiaRuolo__c+'_'+modelloServizio.toUpperCase()) && !contactToExclude.contains(con.Id)){
                refs.add(con.Id);
            }
        }
        //Ref Banca

        //Ref Consulenti Finanziari
        if(modelloServizio=='Consulenti Finanziari'){
            List<Contact> consFin=[SELECT Id, Name, Email, PTF_RegistrationNumber__c, Account.Name, PTF_TipologiaRuolo__c, Account.PTF_IdCEDPadre__c, Account.PTF_IdCED__c, PTF_Ruolo__c  FROM Contact WHERE Account.PTF_IdCed__c='7113' AND PTF_Ruolo__c IN ('990','991')];
            for(Contact con:consFin){
                if(!contactToExclude.contains(con.Id)){
                    refs.add(con.Id);
                }
            }
        }
        //Ref Consulenti Finanziari

        //REF PRIVATE 05387
        if(modelloServizio=='Private' && bankNumber == '05387'){
            System.debug('SV DENTRO');
            List<Contact> consFin=[SELECT Id, Name, Email, PTF_RegistrationNumber__c, Account.Name, PTF_TipologiaRuolo__c, Account.PTF_IdCEDPadre__c, Account.PTF_IdCED__c, PTF_Ruolo__c  FROM Contact WHERE PTF_ReferenteElegibile__c=true AND AccountId IN (SELECT PTF_UffPrivate__c FROM Account WHERE PTF_UffPrivate__c != '')];
            for(Contact con:consFin){
                if(eligibleRoles.contains(con.PTF_TipologiaRuolo__c+'_'+modelloServizio.toUpperCase()) && !contactToExclude.contains(con.Id)){
                    refs.add(con.Id);
                }
            }
        }
        //REF PRIVATE 05387

        gestoriPrincipaliMap = SV_Utilities.keyBy([
                    SELECT Id, FirstName, LastName, PTF_RegistrationNumber__c, PTF_User__c, Account.Name
                    FROM Contact
                    WHERE Id IN:refs], 'Id', false);
        System.debug('SV gestoriPrincipaliMap: ' + gestoriPrincipaliMap);
            /*if (modelliBanca.contains(modelloServizio)) {
                gestoriPrincipaliMap = SV_Utilities.keyBy([ 
                    SELECT Id, FirstName, LastName, PTF_RegistrationNumber__c, PTF_User__c
                    FROM Contact
                    WHERE 
                    (
                        (AccountId =: filialeId 
                         AND PTF_TipologiaRuolo__c IN: RoleTipologyIdSet
                         AND PTF_ManagePortafoglioEnable__c=true
                        )
                        OR 
                        (Account.PTF_Banca__r.PTF_IdCED__c IN: idCedGerarchiaSet
                         AND PTF_TipologiaRuolo__c IN: RoleTipologyGerarchiaIdSet
                         AND PTF_ManagePortafoglioEnable__c=true
                        )
                    )
                    AND Id NOT IN (SELECT PTF_Gestore__c FROM Assignment__c WHERE RecordType.DeveloperName = 'Primario' AND PTF_EndDate__c = null AND PTF_MicroWallet__r.PTF_ModelloDiServizio__c =: modelloServizio AND PTF_MicroWallet__r.PTF_Filiale__c=:filialeId)], 'Id', false); 
            }
            else if (modelliDirezione.contains(modelloServizio)) {
				gestoriPrincipaliMap = SV_Utilities.keyBy([ 
                    SELECT Id, FirstName, LastName, PTF_RegistrationNumber__c, PTF_User__c
                    FROM Contact
                    WHERE 
                    (
                        (AccountId =: filialeId 
                         AND PTF_TipologiaRuolo__c IN: RoleTipologyIdSet
                         AND PTF_ManagePortafoglioEnable__c=true
                        )
                        OR 
                        (Account.PTF_DirezioneRegionale__r.PTF_IdCED__c IN: idCedGerarchiaSet
                         AND PTF_TipologiaRuolo__c IN: RoleTipologyGerarchiaIdSet
                         AND PTF_ManagePortafoglioEnable__c=true
                        )
                    )
                    AND Id NOT IN (SELECT PTF_Gestore__c FROM Assignment__c WHERE RecordType.DeveloperName = 'Primario' AND PTF_EndDate__c = null AND PTF_MicroWallet__r.PTF_ModelloDiServizio__c =: modelloServizio AND PTF_MicroWallet__r.PTF_Filiale__c=:filialeId)], 'Id', false);                 
            }
            else {
            	gestoriPrincipaliMap = SV_Utilities.keyBy([
                    SELECT Id, FirstName, LastName, PTF_RegistrationNumber__c, PTF_User__c
                    FROM Contact
                    WHERE (AccountId =: filialeId 
                           AND PTF_TipologiaRuolo__c IN: RoleTipologyIdSet
                           AND PTF_ManagePortafoglioEnable__c=true
                          )
                    AND Id NOT IN (SELECT PTF_Gestore__c FROM Assignment__c WHERE RecordType.DeveloperName = 'Primario' AND PTF_EndDate__c = null AND PTF_MicroWallet__r.PTF_ModelloDiServizio__c =: modelloServizio AND PTF_MicroWallet__r.PTF_Filiale__c=:filialeId)], 'Id', false);
            }
            System.debug('SV gestoriPrincipaliMap: ' + gestoriPrincipaliMap);*/

            // Set<Id> userIds = new Set<Id>();
            // for (Id key : gestoriPrincipaliMap.keySet()) {
            //     userIds.add((Id)key);
            // }

            // Map<String, SObject> mws = SV_Utilities.keyBy([ SELECT Id, PTF_Gestore__c, PTF_ModelloDiServizio__c  
            //                                                 FROM Assignment__c 
            //                                                 WHERE RecordType.Name = 'Primario' AND 
            //                                                     PTF_Gestore__c IN : userIds AND 
            //                                                     PTF_EndDate__c = null], '{Id}_{PTF_Gestore__c}', true);
            // System.debug('SV mws: ' + mws);
            // for (String key : mws.keySet()) {
            //     List<String> keysplit = key.split('_');
            //     if(gestoriPrincipaliMap.containsKey(keysplit[1])){
            //         /*if((String)mws.get(key).get('PTF_Filiale__c') == filialeId){
            //             gestoriPrincipaliMap.remove(keysplit[1]);
            //         }*/
            //     }
            // }



        } catch (BaseException e) {  
            // This catches the OtherException
            System.debug('SV BaseException ' + e);

        } 
        return gestoriPrincipaliMap;
    }

    @AuraEnabled
    public static Map<String, SObject> getGestoriBackup(String filialeId, String modelloServizio, Boolean isChecked999,
    Boolean isCheckedPTF) { // LV CR NEC #70081

        Map<String, SObject> gestoriBackupMap = new Map<String, SObject>();

        try { 

            Account filiale= [SELECT Id, PTF_BranchTypology__c, PTF_Area__r.PTF_Idced__c,
            PTF_DirezioneRegionale__r.PTF_Idced__c, PTF_Banca__r.PTF_Idced__c, FinServ__BankNumber__c, PTF_UffPrivate__c
            FROM Account WHERE Id=:filialeId];
            Set<String> idCedGerarchiaSet = new Set<String>{filiale.PTF_Area__r.PTF_Idced__c, filiale.PTF_DirezioneRegionale__r.PTF_Idced__c, filiale.PTF_Banca__r.PTF_Idced__c};
            List<String> eligibleRoles = new List<String>();
            //List<String> eligibleRolesGerarchia = new List<String>();

            String idCedBanca = filiale.PTF_Banca__r.PTF_Idced__c;
            String idCedDR = filiale.PTF_DirezioneRegionale__r.PTF_Idced__c;
            String idCedArea = filiale.PTF_Area__r.PTF_Idced__c;
            String bankNumber = filiale.FinServ__BankNumber__c;

            system.debug('filiale: '+filiale);
            for(RoleMDS__c roleMDS : [SELECT Id, PTF_RoleTypology__c, PTF_ServiceModel__r.Name
                            FROM RoleMDS__c 
                            WHERE PTF_BranchTypology__c =: filiale.PTF_BranchTypology__c AND
                            PTF_StartDate__c <=: Date.today()
                            AND (PTF_EndDate__c >=: Date.today() OR PTF_EndDate__c=null)]){

                if(roleMDS.PTF_ServiceModel__r.Name.toUpperCase() == modelloServizio.toUpperCase() && roleMDS.PTF_RoleTypology__c!=null){
                    eligibleRoles.add(roleMDS.PTF_RoleTypology__c+'_'+roleMDS.PTF_ServiceModel__r.Name.toUpperCase());
                }
            }
            /*for(RoleMDS__c roleMDS : [SELECT Id, PTF_RoleTypology__c, PTF_ServiceModel__r.Name, PTF_IdcedFunzionale__c
                            FROM RoleMDS__c 
                            WHERE PTF_IdcedFunzionale__c IN: idCedGerarchiaSet AND
                            PTF_IdcedFunzionale__c != '' AND
                            PTF_StartDate__c <=: Date.today()
                            AND (PTF_EndDate__c >=: Date.today() OR PTF_EndDate__c=null)]){

                if(roleMDS.PTF_ServiceModel__r.Name.toUpperCase() == modelloServizio.toUpperCase() && roleMDS.PTF_RoleTypology__c!=null){
                    
                    eligibleRolesGerarchia.add(roleMDS.PTF_RoleTypology__c+'_'+roleMDS.PTF_ServiceModel__r.Name.toUpperCase()+'_'+roleMDS.PTF_IdcedFunzionale__c);
                }
            }*/
            //Set<String> modelliBanca = new Set<String>{'Key Client Privati', 'Consulenti Finanziari', 'Enti e Tesorerie', 'LARGE CORPORATE'};
            //Set<String> modelliDirezione = new Set<String>{'Private','SMALL BUSINESS','Corporate','Personal'};
            Set<String> idCedUffPrivate= SV_Utilities.getSet([SELECT PTF_IdCEDUffPrivate__c FROM ConfigUffPrivateDR__c WHERE PTF_IdCEDDR__c=:idCedDR], 'PTF_IdCEDUffPrivate__c');
            Set<String> idCedUffPrivate_CP= SV_Utilities.getSet([SELECT PTF_IdCEDUffPrivate__c, PTF_IdCP__c FROM ConfigUffPrivateDR__c WHERE PTF_IdCEDDR__c=:idCedDR], '{PTF_IdCEDUffPrivate__c}_{PTF_IdCP__c}', true, false);

            Set<String> role41_42= SV_Utilities.getSet([SELECT Id FROM RoleTypology__c WHERE PTF_Code__c IN ('041','042')], 'Id');

            List<Contact> contactFiliale = new List<Contact>();
            List<Contact> contactBanca = new List<Contact>();
            List<Contact> contactDR = new List<Contact>();
            List<Contact> contactArea = new List<Contact>();
            if(String.isNotBlank(filialeId)){
                contactFiliale= [SELECT Id, PTF_CentroPrivate__c, Name, Email, PTF_RegistrationNumber__c, Account.Name, PTF_TipologiaRuolo__c , Account.PTF_IdCEDPadre__c, Account.PTF_IdCED__c, PTF_Ruolo__c FROM Contact WHERE PTF_ReferenteElegibile__c=true AND AccountId=:filialeId];
                System.debug('LP contactFiliale '+JSON.serialize(contactFiliale));
            }

            if(String.isNotBlank(idCedBanca)){
                contactBanca= [SELECT Id, PTF_CentroPrivate__c, Name, Email, PTF_RegistrationNumber__c, Account.Name, PTF_TipologiaRuolo__c , PTF_TipologiaRuolo__r.PTF_Code__c, Account.PTF_IdCEDPadre__c, Account.PTF_IdCED__c, PTF_Ruolo__c, PTF_ProfiloLDAP__c FROM Contact WHERE PTF_ReferenteElegibile__c=true AND Account.PTF_IdCEDPadre__c =:idCedBanca];
                System.debug('LP contactBanca '+JSON.serialize(contactBanca));
            }

            if(String.isNotBlank(idCedDR)){
                contactDR= contactDR= [SELECT Id, Name, PTF_CentroPrivate__c, Email, PTF_RegistrationNumber__c, Account.Name, PTF_TipologiaRuolo__c , Account.PTF_IdCEDPadre__c, Account.PTF_IdCED__c, PTF_Ruolo__c FROM Contact WHERE PTF_ReferenteElegibile__c=true AND Account.PTF_IdCEDPadre__c =:idCedDR];
                System.debug('LP contactDR '+JSON.serialize(contactDR));
            }

            if(String.isNotBlank(idCedArea)){
                contactArea= [SELECT Id, Name, PTF_CentroPrivate__c, Email, PTF_RegistrationNumber__c, Account.Name, PTF_TipologiaRuolo__c , Account.PTF_IdCEDPadre__c, Account.PTF_IdCED__c, PTF_Ruolo__c FROM Contact WHERE PTF_ReferenteElegibile__c=true AND Account.PTF_IdCED__c =:idCedArea];
                System.debug('LP contactArea '+JSON.serialize(contactArea));
            }
            Set<String> refs= new Set<String>();
            //Ref Filiale
            for(Contact con:contactFiliale){
                if(eligibleRoles.contains(con.PTF_TipologiaRuolo__c+'_'+modelloServizio.toUpperCase()) ){
                    refs.add(con.Id);
                }
            }
            //Ref Filiale

            //Ref Area
            for(Contact con:contactArea){
                if(eligibleRoles.contains(con.PTF_TipologiaRuolo__c+'_'+modelloServizio.toUpperCase()) ){
                    refs.add(con.Id);
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
                        if(eligibleRoles.contains(key+'_'+modelloServizio.toUpperCase())){
                            refs.add(con.Id);
                        }
                    }
                }
                else if(eligibleRoles.contains(con.PTF_TipologiaRuolo__c+'_'+modelloServizio.toUpperCase()) ){
                    refs.add(con.Id);
                }
            }
            //Ref DR

            //Ref Banca
            for(Contact con:contactBanca){
                if(modelloServizio=='Private'){
                    //Uffici Private BPER
                    if(idCedUffPrivate.contains(con.Account.PTF_IdCED__c)){
                        if((con.PTF_Ruolo__c=='100' || con.PTF_TipologiaRuolo__r.PTF_Code__c=='300')
                        || (isCheckedPTF == true)){ // LV CR NEC #70081
                            if(eligibleRoles.contains(con.PTF_TipologiaRuolo__c+'_'+modelloServizio.toUpperCase())){
                                refs.add(con.Id);
                            }
                        }
                        else{
                            // START DK 02/09 - REEFERENTE COORDINATORE ASSISTENTE
                            if(con.PTF_ProfiloLDAP__c == 'NEC_T.8' && con.PTF_TipologiaRuolo__r.PTF_Code__c == '038') {
                                
                                if(eligibleRoles.contains(con.PTF_TipologiaRuolo__c+'_'+modelloServizio.toUpperCase())){
                                    refs.add(con.Id);
                                }
                            }
                            // END DK 02/09 - REEFERENTE COORDINATORE ASSISTENTE
                            else if(idCedUffPrivate_CP.contains(con.Account.PTF_IdCed__c+'_'+con.PTF_CentroPrivate__c) && eligibleRoles.contains(con.PTF_TipologiaRuolo__c+'_'+modelloServizio.toUpperCase()) ){
                                refs.add(con.Id); 
                            }
                        }
                    }
                    //Uffici Private BPER
                    //Ufficio Private BDS
                    /* if(con.Account.PTF_IdCED__c=='5690'){
                        if(eligibleRoles.contains(con.PTF_TipologiaRuolo__c+'_'+modelloServizio.toUpperCase()) ){
                            refs.add(con.Id);
                        }
                    } */
                    //Ufficio Private BDS
                }else if(isChecked999 == true) { 
                    if(eligibleRoles.contains(con.PTF_TipologiaRuolo__c+'_'+modelloServizio.toUpperCase())) refs.add(con.Id);
                   
                } 
                 else if(eligibleRoles.contains(con.PTF_TipologiaRuolo__c+'_'+modelloServizio.toUpperCase()) ){
                     refs.add(con.Id);
                 }  
            }
            //Ref Banca

            //REF PRIVATE 05387
            if(modelloServizio=='Private' && bankNumber == '05387'){
                List<Contact> consFin=[SELECT Id, Name, Email, PTF_RegistrationNumber__c, Account.Name, PTF_TipologiaRuolo__c, Account.PTF_IdCEDPadre__c, Account.PTF_IdCED__c, PTF_Ruolo__c  FROM Contact WHERE PTF_ReferenteElegibile__c=true AND AccountId =: filiale.PTF_UffPrivate__c];
                for(Contact con:consFin){
                    if(eligibleRoles.contains(con.PTF_TipologiaRuolo__c+'_'+modelloServizio.toUpperCase()) ){
                        refs.add(con.Id);
                    }
                }
            }
            //REF PRIVATE 05387

            gestoriBackupMap = SV_Utilities.keyBy([ SELECT Id, FirstName, LastName,PTF_RegistrationNumber__c,PTF_User__c
                                                    FROM Contact
                                                    WHERE Id IN:refs
                                                    ], 'Id', false);
            System.debug('SV gestoriBackupMap: ' + gestoriBackupMap);
            //Set<String> contactToExclude= SV_Utilities.getSet([SELECT PTF_Gestore__c FROM Assignment__c WHERE RecordType.DeveloperName = 'Primario' AND PTF_EndDate__c = null AND PTF_MicroWallet__r.PTF_ModelloDiServizio__c =: modelloServizio AND PTF_MicroWallet__r.PTF_Filiale__c =: filialeId], 'PTF_Gestore__c');
            
            /*if (modelliBanca.contains(modelloServizio)) {
                gestoriBackupMap = SV_Utilities.keyBy([
                    SELECT Id, FirstName, LastName,PTF_RegistrationNumber__c,PTF_User__c
                    FROM Contact
                    WHERE 
                    (
                        (AccountId =: filialeId 
                         AND PTF_TipologiaRuolo__c IN: RoleTipologyIdSet
                         AND PTF_ManagePortafoglioEnable__c=true
                        )
                        OR 
                        (Account.PTF_Banca__r.PTF_IdCED__c IN: idCedGerarchiaSet
                         AND PTF_TipologiaRuolo__c IN: RoleTipologyGerarchiaIdSet
                         AND PTF_ManagePortafoglioEnable__c=true
                        )
                    )], 'Id', false);
            }
            else if (modelliDirezione.contains(modelloServizio)) {
                gestoriBackupMap = SV_Utilities.keyBy([
                    SELECT Id, FirstName, LastName,PTF_RegistrationNumber__c,PTF_User__c
                    FROM Contact
                    WHERE 
                    (
                        (AccountId =: filialeId 
                         AND PTF_TipologiaRuolo__c IN: RoleTipologyIdSet
                         AND PTF_ManagePortafoglioEnable__c=true
                        )
                        OR 
                        (Account.PTF_DirezioneRegionale__r.PTF_IdCED__c IN: idCedGerarchiaSet
                         AND PTF_TipologiaRuolo__c IN: RoleTipologyGerarchiaIdSet
                         AND PTF_ManagePortafoglioEnable__c=true
                        )
                    )], 'Id', false);
            }
            else {
            	gestoriBackupMap = SV_Utilities.keyBy([ SELECT Id, FirstName, LastName,PTF_RegistrationNumber__c,PTF_User__c
                                                    FROM Contact
                                                    WHERE (AccountId =: filialeId 
                                                           AND PTF_TipologiaRuolo__c IN: RoleTipologyIdSet
                                                           AND PTF_ManagePortafoglioEnable__c=true
                                                          )
                                                    ], 'Id', false);
            }
            System.debug('SV gestoriBackupMap: ' + gestoriBackupMap);*/

        } catch (BaseException e) {  
            // This catches the OtherException
            System.debug('SV BaseException ' + e);

        } 

        return gestoriBackupMap;
    }

    //START DK 30/07 - VISIBILITA PORTAFOGLI
    public static Map<String, ServiceModel__c> MDSMap {
        get{
            if(MDSMap != null) return MDSMap;
            MDSMap = new Map<String, ServiceModel__c>();
            for(ServiceModel__c serviceModel : [SELECT id, Name, PTF_NameAbbreviation__c 
                                                , PTF_Division__c // CR 60703 
                                                FROM ServiceModel__c]){
                
                MDSMap.put(serviceModel.Name.toUpperCase(), serviceModel);
            }
            return MDSMap;
        }
        set;
    }
    public static Map<String,Group> findRoleGroupFilialeMDS(Set<String> filialiRIDCEDSet){
        Map<String,Group> roleGroupFiliale= new Map<String,Group>();
        Set<String> groupNameSet = new Set<String>();
        for(String groupName : filialiRIDCEDSet){
            for(String mds : MDSMap.keySet()){
                groupNameSet.add(groupName + '_' + MDSMap.get(mds).PTF_NameAbbreviation__c);
            }
        }
        
        List<Group> filialiGroup = [SELECT Id, DeveloperName FROM Group WHERE DeveloperName IN:groupNameSet];
        for(Group g:filialiGroup){
            roleGroupFiliale.put(g.DeveloperName, g);
        }
        return roleGroupFiliale;
    }
    //END DK 30/07 - VISIBILITA PORTAFOGLI

    @AuraEnabled
    public static Boolean saveMicroWallet(String filiale, String banca, String dirRegionale, String area, String capofila, String modelloServizio, Integer numMP, List<String> gestorePrincipale, List<String> gestoreBackup, String ufficioPrivate , Boolean isPTF999 ,
                                            Boolean isPTFSvil, String centroPrivate) { // LV CR NEC #70081 //SV agiunto centro private in input
        System.debug('SV saveMicroWallet filiale: ' + filiale);
        System.debug('SV saveMicroWallet modelloServizio: ' + modelloServizio);
        System.debug('SV saveMicroWallet numMP: ' + numMP);
        System.debug('SV saveMicroWallet banca: ' + banca);
        System.debug('SV saveMicroWallet dirRegionale: ' + dirRegionale);
        System.debug('SV saveMicroWallet area: ' + area);
        System.debug('SV saveMicroWallet gestorePrincipale: ' + gestorePrincipale);
        System.debug('SV saveMicroWallet gestoreBackup: ' + gestoreBackup);
        //CR52359 SV start
        System.debug(LoggingLevel.DEBUG,'### ufficoPrivate: '+ufficioPrivate);
        Account idUfficioPrivate = new Account();
        if(String.isNotBlank(ufficioPrivate)){
            idUfficioPrivate = [SELECT Id FROM Account WHERE PTF_IdCED__c = :ufficioPrivate];
        }
        //CR52359 SV end
        //SV Centro Private start
        System.debug(LoggingLevel.DEBUG,'### centroPrivate: '+centroPrivate);
        Account idCentroPrivate = new Account();
        if(String.isNotBlank(centroPrivate)){
            idCentroPrivate = [SELECT Id FROM Account WHERE PTF_IdCED__c = :centroPrivate];
        }
        //SV Centro Private end
        List<Assignment__c> assignmentsToInsert = new List<Assignment__c>();
        List<Wallet__c> walletsToInsert = new List<Wallet__c>();
        Map<Id,Schema.RecordTypeInfo> rtMap = Wallet__c.sobjectType.getDescribe().getRecordTypeInfosById();

        Map<String, SObject> mtdWalletlMap  = SV_Utilities.keyBy([SELECT Id, MasterLabel, PTF_IsPool__c
                                                            FROM PTF_ModelloDiServizio__mdt ], 'MasterLabel', false);

        System.debug('SV mtdWalletlMap: '  + mtdWalletlMap);
        try { 
            Id microWalletRTId = SV_Utilities.getRecordTypeByDeveloperName('Wallet__c', 'MicroWallet');
            //User unassigned = [SELECT Id FROM User WHERE Profile.Name = 'TechnicalProfilePortafogliazione'][0];

            if(numMP == 1){

                System.debug('SV result: ' + (Boolean)mtdWalletlMap.get(modelloServizio).get('PTF_IsPool__c'));
                Contact firstGestore = gestorePrincipale.size() > 0 ? [SELECT Id, PTF_User__c FROM Contact WHERE Id =: gestorePrincipale[0]] : null;

                Wallet__c mw = new Wallet__c();
                mw.PTF_Filiale__c = filiale; System.debug('modelloServizio ' + modelloServizio);
                mw.PTF_ModelloDiServizio__c = modelloServizio;
                mw.PTF_Area__c = String.isNotBlank(area) ? area : null;
                //CR52359 SV start
                mw.PTF_UffPrivate__c = modelloServizio.equals('Private') ? idUfficioPrivate.Id : null;
                //CR52359 SV start
                //SV Centro PRivate start
                mw.PTF_CentrPrivate__c = modelloServizio.equals('Private') ? idCentroPrivate.Id : null;
                //SV Centro PRivate start
                mw.PTF_Banca__c = banca;
                mw.PTF_DirezioneRegionale__c = String.isNotBlank(dirRegionale) ? dirRegionale : null;
                mw.PTF_Capofila__c = capofila;
                mw.RecordTypeId = microWalletRTId;
                mw.PTF_Pool__c = (Boolean)mtdWalletlMap.get(modelloServizio).get('PTF_IsPool__c');
                //mw.OwnerId = gestorePrincipale.size() > 0 ? firstGestore.PTF_User__c : unassigned.Id;
                buildName(mw,isPTF999,isPTFSvil); // LV CR NEC #70081
                insert mw;
                Set<String> wIds= new Set<String>{mw.Id};
                
                system.debug('@@@@sonoqui');
                createShare(wIds);

                for(String idContact : gestorePrincipale){
                    assignmentsToInsert.add(new Assignment__c(
                        PTF_MicroWallet__c = mw.Id,
                        PTF_StartDate__c=Date.today(),
                        PTF_StartDate_DT__c = Datetime.now(),
                        PTF_Gestore__c = idContact,
                        RecordTypeId = Schema.SObjectType.Assignment__c.getRecordTypeInfosByDeveloperName().get('Primario').getRecordTypeId()
                    ));
                }

                for(String idContact : gestoreBackup){
                    assignmentsToInsert.add(new Assignment__c(
                        PTF_MicroWallet__c = mw.Id,
                        PTF_StartDate__c=Date.today(),
                        PTF_StartDate_DT__c = Datetime.now(),
                        PTF_Gestore__c = idContact,
                        RecordTypeId = Schema.SObjectType.Assignment__c.getRecordTypeInfosByDeveloperName().get('Backup').getRecordTypeId()
                    ));
                }

                insert assignmentsToInsert;
            } else {

                for(Integer i=0; i < numMP; i++){
                    Wallet__c mw = new Wallet__c();
                    mw.PTF_Filiale__c = filiale;
                    mw.PTF_ModelloDiServizio__c = modelloServizio;
                    //CR52359 SV start
                    mw.PTF_UffPrivate__c = modelloServizio.equals('Private') ? idUfficioPrivate.Id : null;
                    //CR52359 SV start
                    mw.PTF_Area__c = String.isNotBlank(area) ? area : null;
                    mw.PTF_Banca__c = banca;
                    mw.PTF_DirezioneRegionale__c = String.isNotBlank(dirRegionale) ? dirRegionale : null;
                    mw.PTF_Capofila__c = capofila;
                    mw.RecordTypeId = microWalletRTId;
                    mw.PTF_Pool__c = (Boolean)mtdWalletlMap.get(modelloServizio).get('PTF_IsPool__c');

                    //mw.OwnerId = unassigned.Id;
                    walletsToInsert.add(mw);
                }
                system.debug('@@@@sonoqui');
                buildName(walletsToInsert,isPTF999, isPTFSvil); // LV CR NEC #70081
                insert walletsToInsert;
                Set<String> wIds= new Set<String>();
                for(Wallet__c w: walletsToInsert){
                    wIds.add(w.Id);
                    system.debug('@@@@sonoqui');
                }
                system.debug('@@@@sonoqui');
                createShare(wIds);

            }           

        } catch (BaseException e) {  
            // This catches the OtherException
            System.debug('SV BaseException ' + e);

        } 

        return true;
    }

    /*..........................................*/
    /* Wrapper class to display Position       */
    /*.........................................*/
    
    public class WrapperObj {

        @AuraEnabled public Map<String, SObject> bancheMap;
        @AuraEnabled public Map<String, SObject> dirRegionaleMap;
        @AuraEnabled public Map<String, SObject> areaMap;
        @AuraEnabled public Map<String, SObject> filialeMap;
        @AuraEnabled public Map<String, SObject> altraUOMap;
        @AuraEnabled public Map<String, SObject> modelloServizioMap;
        @AuraEnabled public User currentUser;

    }

    

    public static void createShare(Set<String> walletsId){

        system.debug('@@@@sonoqui');
        List<Wallet__c> scope = [SELECT Id, PTF_Filiale__r.PTF_IdCED__c, PTF_Filiale__r.PTF_IdCEDFiliale__c, PTF_Filiale__r.PTF_IDCEDUffPrivate__c, PTF_Filiale__c, PTF_Area__r.PTF_IdCED__c,PTF_Area__c, PTF_DirezioneRegionale__r.PTF_IdCED__c, PTF_DirezioneRegionale__c, PTF_Banca__r.PTF_IdCED__c, PTF_Banca__c, PTF_Banca__r.FinServ__BankNumber__c, PTF_ModelloDiServizio__c /*CR 52359 SV start*/, PTF_UffPrivate__c, PTF_UffPrivate__r.PTF_IdCED__c /* CR 52359 SV end*/  FROM Wallet__c WHERE Id IN: walletsId];
        Set<String> filialiRIDCEDSet = new Set<String>();
        Set<String> ufficiPadreIDCEDSet = new Set<String>();
        Set<String> DRIDCEDSet = new Set<String>();

        /*Map<String,List<Account>> dirToCentri= new Map<String,List<Account>>();
        Map<String,Group> mRoleGroupCentroImpresa= new Map<String,Group>();
        Map<String,Group> mRoleGroupFiliale= new Map<String,Group>();*/
        Map<String,Group> mRoleGroupFilialeMDS= new Map<String,Group>();
        //NEW UFF PRIVATE
        Set<String> uffPrivateRIDCEDSet = new Set<String>();
        Map<String,Group> mRoleGroupUffPrivate= new Map<String,Group>();
        //NEW UFF PRIVATE
        Map<String,List<GroupWrapper>> mGroupWrapper= new Map<String,List<GroupWrapper>>();

        List<Wallet__Share> wsToInsert = new List<Wallet__Share>();
        Map<String,SObject> serviceModelMap = SV_Utilities.keyBy([SELECT PTF_Division__c, PTF_MacroDivision__c, Name FROM ServiceModel__c ], '{PTF_Division__c}_{PTF_MacroDivision__c}_{Name}', true);
        for(String modello:serviceModelMap.keySet()){
            String keyUpper=modello.split('_')[0]+'_'+modello.split('_')[1]+'_'+modello.split('_')[2].toUpperCase();
            serviceModelMap.put(keyUpper, serviceModelMap.remove(modello));   
        }
        for(Wallet__c por: scope){
            system.debug('@@@@port:'+por);
            if(String.isNotBlank(por.PTF_Filiale__r.PTF_IdCED__c)) filialiRIDCEDSet.add('RIDCED'+por.PTF_Filiale__r.PTF_IdCED__c);
            // togliere commento
            //if(por.PTF_Filiale__r.PTF_BranchTypeDesc__c == 'Spoke Light' && !String.isBlank(por.PTF_Filiale__r.PTF_Capofila__c)) filialiRIDCEDSet.add('RIDCED'+por.PTF_Filiale__r.PTF_Capofila__r.PTF_IdCED__c);
            // togliere commento
            //NEW UFF PRIVATE //CR 53259 SV Start
            if(String.isNotBlank(por.PTF_UffPrivate__r.PTF_IdCED__c)) uffPrivateRIDCEDSet.add('RIDCED'+por.PTF_UffPrivate__r.PTF_IdCED__c);
            //NEW UFF PRIVATE //CR 53259 SV Start
            if(String.isNotBlank(por.PTF_Area__r.PTF_IdCED__c)) ufficiPadreIDCEDSet.add(por.PTF_Area__r.PTF_IdCED__c);
            if(String.isNotBlank(por.PTF_DirezioneRegionale__r.PTF_IdCED__c)) {
                ufficiPadreIDCEDSet.add(por.PTF_DirezioneRegionale__r.PTF_IdCED__c);
                DRIDCEDSet.add(por.PTF_DirezioneRegionale__c);
            }
            if(String.isNotBlank(por.PTF_Banca__r.PTF_IdCED__c)) ufficiPadreIDCEDSet.add(por.PTF_Banca__r.PTF_IdCED__c);
        }

        //Eccezioni
        List<Group> eccList= [SELECT Id, DeveloperName FROM Group WHERE DeveloperName IN('Filiale937_1200','Filiale2499')];
        Map<String,Group> eccMap= new Map<String,Group>();
        for(Group g:eccList){
            eccMap.put(g.DeveloperName,g);
        }
        //Eccezioni

        //Uffici Private
        /*List<ConfigUffPrivateDR__c> confList= [SELECT Name,PTF_IdCEDUffPrivate__c, PTF_IdCP__c, PTF_IdCEDDR__c FROM ConfigUffPrivateDR__c];
        Set<String> IdCedToSkip= new Set<String>();
        Set<String> gruppiUffPrivateDevName= new Set<String>();
        Map<String,List<String>> drIdCedToGruppiPrivateDevName = new Map<String,List<String>>();
        //NEW UFF PRIVATE
        IdCedToSkip.addAll(uffPrivateRIDCEDSet);
        //NEW UFF PRIVATE
        for(ConfigUffPrivateDR__c conf:confList){
            IdCedToSkip.add('RIDCED'+conf.PTF_IdCEDUffPrivate__c);
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
        }*/
        //Uffici Private

        //mRoleGroupFiliale=findRoleGroupFiliale(filialiRIDCEDSet);
        mRoleGroupFilialeMDS=Batch_CreaVisibilita.findRoleGroupFilialeMDS(filialiRIDCEDSet);
        //NEW UFF PRIVATE
        mRoleGroupUffPrivate=Batch_CreaVisibilita.findRoleGroupUffPrivate(uffPrivateRIDCEDSet);
        //NEW UFF PRIVATE
        
        //dirToCentri=populateDirToCentri(DRIDCEDSet);
        //mRoleGroupCentroImpresa=findRoleGroupCentroImpresa(DRIDCEDSet);
        System.debug('ufficiIdCed: '+ufficiPadreIDCEDSet);
        mGroupWrapper=findRoleGroupUfficio(ufficiPadreIDCEDSet);

        for(Wallet__c por:scope){
            if(por.PTF_ModelloDiServizio__c=='Private'){
                /*if(por.PTF_Banca__r.FinServ__BankNumber__c == '01015'){
                    if(drIdCedToGruppiPrivateDevName.containsKey(por.PTF_DirezioneRegionale__r.PTF_IdCED__c)){
                        system.debug('@@@@@sonoqui');
                        for(String key:drIdCedToGruppiPrivateDevName.get(por.PTF_DirezioneRegionale__r.PTF_IdCED__c)){
                            system.debug('@@@@@sonoqui');
                            if(devNameToGroupUffPriv.containsKey(key)){
                                system.debug('@@@@@sonoqui');
                                Wallet__Share ws = new Wallet__Share();
                                ws.ParentId=por.Id;
                                ws.UserOrGroupId=devNameToGroupUffPriv.get(key).Id;
                                ws.AccessLevel='Edit';
                                system.debug('@@@@@wsToInsert: '+key);
                                wsToInsert.add(ws);
                            }
                        }
                    }
                }
                //NEW UFF PRIVATE //CR 53259 SV Start
                else{*/
                    if(mRoleGroupUffPrivate.containsKey('RIDCED'+por.PTF_UffPrivate__r.PTF_IdCED__c)){
                        Wallet__Share ws = new Wallet__Share();
                        ws.ParentId=por.Id;
                        ws.UserOrGroupId=mRoleGroupUffPrivate.get('RIDCED'+por.PTF_UffPrivate__r.PTF_IdCED__c).Id;
                        ws.AccessLevel='Edit';
                        wsToInsert.add(ws);
                    }
                // }
                //NEW UFF PRIVATE //CR 53259 SV Start
            }
            
            //Eccezioni
            /*if(por.PTF_Filiale__r.PTF_IdCEDFiliale__c=='937' || por.PTF_Filiale__r.PTF_IdCEDFiliale__c=='1200'){
                //sharo al gruppo Filiale937_1200
                if(eccMap.containsKey('Filiale937_1200')){
                    Wallet__Share ws = new Wallet__Share();
                    ws.ParentId=por.Id;
                    ws.UserOrGroupId=eccMap.get('Filiale937_1200').Id;
                    ws.AccessLevel='Edit';
                    wsToInsert.add(ws);
                }
                
            }*/
            if(por.PTF_Filiale__r.PTF_IdCEDFiliale__c=='2499'){
                //sharo al gruppo Filiale2499
                if(eccMap.containsKey('Filiale2499')){
                    Wallet__Share ws = new Wallet__Share();
                    ws.ParentId=por.Id;
                    ws.UserOrGroupId=eccMap.get('Filiale2499').Id;
                    ws.AccessLevel='Edit';
                    wsToInsert.add(ws);
                }
            }
            //Eccezioni
            
            /*if(dirToCentri.containsKey(por.PTF_DirezioneRegionale__r.PTF_IdCED__c)){
                system.debug('@@@@centrisonoqui');
                for(Account centro:dirToCentri.get(por.PTF_DirezioneRegionale__r.PTF_IdCED__c)){
                    system.debug('@@@@centrisonoqui');
                    if(por.PTF_ModelloDiServizio__c=='CORPORATE' || por.PTF_ModelloDiServizio__c=='Corporate' ){
                        system.debug('@@@@centrisonoqui');
                        String key= centro.PTF_IdCED__c;
                        if(mRoleGroupCentroImpresa.containsKey('RIDCED'+key)){
                            system.debug('@@@@centrisonoqui');
                            Wallet__Share ws = new Wallet__Share();
                            ws.ParentId=por.Id;
                            ws.UserOrGroupId=mRoleGroupCentroImpresa.get('RIDCED'+key).Id;
                            ws.AccessLevel='Edit';
                            wsToInsert.add(ws);
                            system.debug('@@@@@wsToInsert: '+key);
                        }
                    }
                    
                }
            }*/
            
            //COMMENTED BY DK 30/07
            /*if(mRoleGroupFiliale.containsKey('RIDCED'+por.PTF_Filiale__r.PTF_IdCED__c)){
                system.debug('@@@@:'+por.Id);
                Wallet__Share ws = new Wallet__Share();
                ws.ParentId=por.Id;
                ws.UserOrGroupId=mRoleGroupFiliale.get('RIDCED'+por.PTF_Filiale__r.PTF_IdCED__c).Id;
                ws.AccessLevel='Edit';
                wsToInsert.add(ws);
                system.debug('@@@@@wsToInsert: '+ws.UserOrGroupId);
            }*/
            //COMMENTED BY DK 30/07

            // START DK 30/07 - VISIBILITA PORTAFOGLI
            Set<String> idcedSet = new Set<String>{por.PTF_Filiale__r.PTF_IdCED__c};
            // togliere commento
            /*if(por.PTF_Filiale__r.PTF_BranchTypeDesc__c == 'Spoke Light' && !String.isBlank(por.PTF_Filiale__r.PTF_Capofila__c)){
                idcedSet.add(por.PTF_Filiale__r.PTF_Capofila__r.PTF_IdCED__c);
            }*/
            // togliere commento
            for(String idCed : idcedSet){
                
                if(mRoleGroupFilialeMDS.containsKey('RIDCED'+idCed + '_' + Batch_CreaVisibilita.MDSMap.get(por.PTF_ModelloDiServizio__c.toUpperCase()).PTF_NameAbbreviation__c)){
                    Wallet__Share ws = new Wallet__Share();
                    ws.ParentId=por.Id;
                    ws.UserOrGroupId=mRoleGroupFilialeMDS.get('RIDCED'+idCed + '_' + Batch_CreaVisibilita.MDSMap.get(por.PTF_ModelloDiServizio__c.toUpperCase()).PTF_NameAbbreviation__c).Id;
                    ws.AccessLevel='Edit';
                    wsToInsert.add(ws);
                    // START DK 02/02 - VISIBILITA PORTAFOGLI KCI
                    if(idCed == por.PTF_Filiale__r.PTF_IdCed__c && (por.PTF_Filiale__r.PTF_IdCEDFiliale__c == '937' || por.PTF_Filiale__r.PTF_IdCEDFiliale__c == '1200' || por.PTF_Filiale__r.PTF_IdCEDFiliale__c == '1201')){
                            
                        Wallet__Share ws1 = new Wallet__Share();
                        ws1.ParentId=por.Id;
                        ws1.UserOrGroupId=filialeVirtualeGroupMap.get(idCed);
                        ws1.AccessLevel='Edit';
                        wsToInsert.add(ws1);
                    }
                    // START DK 02/02 - VISIBILITA PORTAFOGLI KCI
                    
                }
                // END DK 30/07 - VISIBILITA PORTAFOGLI
            }
            // END DK 30/07 - VISIBILITA PORTAFOGLI

            if(mGroupWrapper.containsKey(por.PTF_Area__r.PTF_IdCED__c)){
                system.debug('@@@@@sonoqui');
                for(GroupWrapper wrap:mGroupWrapper.get(por.PTF_Area__r.PTF_IdCED__c)){
                    if(checkShare(por.PTF_ModelloDiServizio__c.toUpperCase() , wrap.filiera, wrap.macroFiliera, serviceModelMap)){
                        Wallet__Share ws = new Wallet__Share();
                        ws.ParentId=por.Id;
                        ws.UserOrGroupId=wrap.gruppo.Id;
                        ws.AccessLevel='Edit';
                        wsToInsert.add(ws);
                        system.debug('@@@@@wsToInsert: '+ws.UserOrGroupId);
                    }
                }
            }
            if(mGroupWrapper.containsKey(por.PTF_DirezioneRegionale__r.PTF_IdCED__c)){
                system.debug('@@@@@sonoqui');
                for(GroupWrapper wrap:mGroupWrapper.get(por.PTF_DirezioneRegionale__r.PTF_IdCED__c)){
                    if(checkShare(por.PTF_ModelloDiServizio__c.toUpperCase() , wrap.filiera, wrap.macroFiliera, serviceModelMap)){
                        Wallet__Share ws = new Wallet__Share();
                        ws.ParentId=por.Id;
                        ws.UserOrGroupId=wrap.gruppo.Id;
                        ws.AccessLevel='Edit';
                        wsToInsert.add(ws);
                        system.debug('@@@@@wsToInsert: '+ws.UserOrGroupId);
                    }
                }
            }
            if(mGroupWrapper.containsKey(por.PTF_Banca__r.PTF_IdCED__c)){
                system.debug('@@@@@sonoqui');
                for(GroupWrapper wrap:mGroupWrapper.get(por.PTF_Banca__r.PTF_IdCED__c)){
                    if(!idCedUffPrivateSet.contains(wrap.gruppo.DeveloperName)){
                        if(checkShare(por.PTF_ModelloDiServizio__c.toUpperCase() , wrap.filiera, wrap.macroFiliera, serviceModelMap)){
                            if(por.PTF_ModelloDiServizio__c!='LARGE CORPORATE'){
                                Wallet__Share ws = new Wallet__Share();
                                ws.ParentId=por.Id;
                                ws.UserOrGroupId=wrap.gruppo.Id;
                                ws.AccessLevel='Edit';
                                wsToInsert.add(ws);
                                system.debug('@@@@@wsToInsert: '+ws.UserOrGroupId);
                            }
                        }
                    }
                    
                }
            }
            // CR 60703 -- Gestione profili
            if(viewAllMMDSMap.containsKey( 'ViewAll_' + MDSMap.get(por.PTF_ModelloDiServizio__c.toUpperCase() ).PTF_Division__c) ) {
                Wallet__Share ws = new Wallet__Share();
                ws.ParentId = por.Id;
                ws.UserOrGroupId = viewAllMMDSMap.get('ViewAll_' + MDSMap.get( por.PTF_ModelloDiServizio__c.toUpperCase() ).PTF_Division__c );
                ws.AccessLevel = 'Edit';
                wsToInsert.add(ws); 
            }
            // CR 60703 -- Fine
        }
        if(wsToInsert.size()>0){
            insert wsToInsert;
        }
    }

    public static Set<String> idCedUffPrivateSet {
        get{
            if(idCedUffPrivateSet != null) return idCedUffPrivateSet;

            idCedUffPrivateSet = new Set<String>();
            for(Account filiale : [SELECT id, PTF_IDCEDUffPrivate__c from Account WHERE RecordTypeName__c = 'Filiale di relazione' AND PTF_IDCEDUffPrivate__c  != null]){
                idCedUffPrivateSet.addAll(filiale.PTF_IDCEDUffPrivate__c.replace('|', ';').split(';'));
         }
            return idCedUffPrivateSet;
        }set;
    }

    /*private static Map<String,List<Account>> populateDirToCentri(Set<String> DRIDCEDSet){

        Map<String,List<Account>> returnMap= new Map<String,List<Account>>();

        List<Account> centriImpresa= [SELECT Id, PTF_IdCED__c,PTF_DirezioneRegionale__r.PTF_IdCED__c, PTF_Division__c, PTF_MacroDivision__c FROM Account WHERE PTF_BranchTypology__c='F' AND PTF_DirezioneRegionale__c IN:DRIDCEDSet];
        
        for(Account c: centriImpresa){
           if(!returnMap.containsKey(c.PTF_DirezioneRegionale__r.PTF_IdCED__c)){
               returnMap.put(c.PTF_DirezioneRegionale__r.PTF_IdCED__c,new List<Account>());
           }
           returnMap.get(c.PTF_DirezioneRegionale__r.PTF_IdCED__c).add(c);
        }
        return returnMap;
    }

    private static Map<String,Group> findRoleGroupCentroImpresa(Set<String> DRIDCEDSet){

        Map<String,Group> RoleGroupCentroImpresa= new Map<String,Group>();

        List<Account> centriImpresa= [SELECT Id, PTF_IdCED__c FROM Account WHERE PTF_BranchTypology__c='F' AND  PTF_DirezioneRegionale__c IN:DRIDCEDSet];
        
        Set<String> centriImpresaRIDCEDSet=new Set<String>();
        
        for(Account c: centriImpresa){
            centriImpresaRIDCEDSet.add('RIDCED'+c.PTF_IdCED__c);
        }

        List<Group> centriGroup = [SELECT Id, DeveloperName FROM Group WHERE DeveloperName IN:centriImpresaRIDCEDSet AND Type='Role'];

        for(Group g:centriGroup){
            RoleGroupCentroImpresa.put(g.DeveloperName, g);
        }

        return RoleGroupCentroImpresa;
    }*/

    /*private static Map<String,Group> findRoleGroupFiliale(Set<String> filialiRIDCEDSet){

        Map<String,Group> roleGroupFiliale= new Map<String,Group>();
        
        List<Group> filialiGroup = [SELECT Id, DeveloperName FROM Group WHERE DeveloperName IN:filialiRIDCEDSet AND Type='Role'];

        for(Group g:filialiGroup){
            roleGroupFiliale.put(g.DeveloperName, g);
        }

        return roleGroupFiliale;
    }*/

    private static Map<String,List<GroupWrapper>> findRoleGroupUfficio(Set<String> ufficiPadreIDCEDSet){

        Map<String,List<GroupWrapper>> returnMap= new Map<String,List<GroupWrapper>>();

        List<Account> uffici = [SELECT Id, PTF_Division__c, PTF_MacroDivision__c, PTF_IdCED__c, PTF_IdCEDPadre__c  FROM Account WHERE PTF_IdCEDPadre__c IN:ufficiPadreIDCEDSet AND RecordType.DeveloperName='AltraUnitaOrganizzativa'];
        System.debug('uffici: '+uffici.size());

        Map<String,List<Account>> padreIdCedToUffici = new Map<String,List<Account>>();
        Set<String> RIDCedUffici= new Set<String>();

        for(Account acc: uffici){
            
            if(!padreIdCedToUffici.containsKey(acc.PTF_IdCEDPadre__c)){
                padreIdCedToUffici.put(acc.PTF_IdCEDPadre__c,new List<Account>());
            }
            padreIdCedToUffici.get(acc.PTF_IdCEDPadre__c).add(acc);
            RIDCedUffici.add('RIDCED'+acc.PTF_IdCED__c);
        }
        System.debug('RIDCedUffici '+RIDCedUffici);
        List<Group> gruppi= [SELECT Id, DeveloperName FROM Group WHERE DeveloperName IN:RIDCedUffici AND Type='Role'];

        System.debug('gruppi'+gruppi);
        Map<String, Group> RIDCedToGroup= new Map<String, Group>();

        for(Group g : gruppi){
            
            RIDCedToGroup.put(g.DeveloperName, g);
        }

        for(String key: padreIdCedToUffici.keySet()){

            for(Account uff: padreIdCedToUffici.get(key)){

                if(RIDCedToGroup.containsKey('RIDCED'+uff.PTF_IdCED__c)){

                    if(!returnMap.containsKey(key)){
                        returnMap.put(key, new List<GroupWrapper>());
                    }

                    GroupWrapper wrap= new GroupWrapper();
                    wrap.gruppo= RIDCedToGroup.get('RIDCED'+uff.PTF_IdCED__c);
                    wrap.filiera=uff.PTF_Division__c;
                    wrap.macroFiliera=uff.PTF_MacroDivision__c;

                    returnMap.get(key).add(wrap);

                }
            }
        }

        return returnMap;
    }

    private static Boolean checkShare(String mds, String filiera, String macrofiliera, Map<String,SObject> serviceModelMap){
        Boolean share=false;
        if(String.isBlank(filiera) && String.isBlank(macrofiliera)){
            share=true;
        }
        else if(String.isBlank(filiera) && String.isNotBlank(macrofiliera)){
            for(String s: serviceModelMap.keySet()){
                if(s.contains(macrofiliera+'_'+mds)) share=true;
            }
        }
        else if(String.isBlank(macrofiliera) && String.isNotBlank(filiera)){
            for(String s: serviceModelMap.keySet()){
                if(s.contains('_'+mds)) {
                    if(s.contains(filiera+'_')) share=true;
                }
            }
        }
        else if(serviceModelMap.containsKey(filiera+'_'+macrofiliera+'_'+mds)){
            share=true;
        }
        return share;

    }

    private class GroupWrapper{
        Group gruppo;
        String filiera;
        String macroFiliera;
    }

    public static void buildName(Wallet__c mw, Boolean isPTF999, Boolean isPTFSvil) { // LV CR NEC #70081

        List<ServiceModel__c > sm=[SELECT PTF_TresholdPTF__c  FROM ServiceModel__c  WHERE Name=:mw.PTF_ModelloDiServizio__c];

        
        Integer start= Integer.valueOf(sm[0].PTF_TresholdPTF__c) ;
        start++;
        
        System.debug('mw.PTF_Filiale__c -> ' + mw.PTF_Filiale__c);
        List<Account> accList= [SELECT Id, PTF_IdCEDFiliale__c, FinServ__BankNumber__c FROM Account WHERE Id=:mw.PTF_Filiale__c]; 
        String abi=accList[0].FinServ__BankNumber__c;
        String ced=accList[0].PTF_IdCEDFiliale__c;

        if(ced.length()<4){
            do{
                ced='0'+ced;
            }
            while(ced.length()<4);
        }

        List<PTF_ModelloDiServizio__mdt> mdt=[SELECT Id, MasterLabel, PTF_Abbreviazione__c
                                                FROM PTF_ModelloDiServizio__mdt 
                                                WHERE MasterLabel =: mw.PTF_ModelloDiServizio__c];

        String ptfName='PTF-'+mdt[0].PTF_Abbreviazione__c+'-'+abi+'-'+ced+'-';
        Integer max=0;
        String seq = '';
        if(isPTF999){
            seq = '999';
        } else if (isPTFSvil){
            System.debug('@@@@max '+max);
            List<Wallet__c> oldList=[SELECT Name FROM Wallet__c WHERE RecordTypeId=:mw.RecordTypeId AND PTF_Filiale__c=:mw.PTF_Filiale__c AND PTF_ModelloDiServizio__c=:mw.PTF_ModelloDiServizio__c AND (NOT Name LIKE '%999')
            AND (Name LIKE '%-666%')]; // LV CR NEC #70081
            if(oldList.size()>0){
                for(Wallet__c w:oldList){
                    Integer num= Integer.valueOf(w.Name.split('-')[4]);
                    if(num>max){
                        max=num;
                        System.debug('@@@@max '+max);
                    }
                }
            }
            System.debug('@@@@max '+max);
            if(max>=start){
                max++;
                start=max;
                System.debug('@@@@start '+start);
            }   
            seq = String.valueOf(start);
        }else{
            // Integer max=0;
            List<Wallet__c> oldList=[SELECT Name FROM Wallet__c WHERE RecordTypeId=:mw.RecordTypeId AND PTF_Filiale__c=:mw.PTF_Filiale__c AND PTF_ModelloDiServizio__c=:mw.PTF_ModelloDiServizio__c AND (NOT Name LIKE '%999')
            AND (NOT Name LIKE '%-666%')]; // LV CR NEC #70081
            if(oldList.size()>0){
                for(Wallet__c w:oldList){
                    Integer num= Integer.valueOf(w.Name.split('-')[4]);
                    if((mw.PTF_ModelloDiServizio__c=='Private' && num>max && num!=75) || num>max){
                        max=num;
                    }
                }
            }
            if(max>=start){
                start=max+1;
                System.debug('@@@@start '+start);
            }
            seq = String.valueOf(start);
        }

        if(isPTFSvil) {
            if(seq.length()<6){
                do{
                    seq ='0'+seq;
                }
                while(seq.length()<6);
            }
            // String firstDigit = seq.substring(0, 1);
            // if (firstDigit == '0') {
            	// MS 02-02-2024 modificato codice 555 con 666
                seq = '666' + seq.substring(3);
            // }
            ptfName= ptfName+seq;
        }
        else{ 
            // LV CR NEC #70081 end
            if(seq.length()<6){
                do{
                    seq='0'+seq;
                }
                while(seq.length()<6);
            }
            ptfName= ptfName+seq;
        }
        mw.Name=ptfName;
    }

    public static void buildName(List<Wallet__c> mwList, Boolean isPTF999, Boolean isPTFSvil){ // LV CR NEC #70081

        List<ServiceModel__c > sm=[SELECT PTF_TresholdPTF__c  FROM ServiceModel__c  WHERE Name=:mwList[0].PTF_ModelloDiServizio__c];

        System.debug('valore soglia '+sm[0].PTF_TresholdPTF__c);
        Integer start= Integer.valueOf(sm[0].PTF_TresholdPTF__c) ;
        start++; 

        System.debug('@@@@start '+start);

        List<Account> accList= [SELECT Id, PTF_IdCEDFiliale__c, FinServ__BankNumber__c FROM Account WHERE  Id=:mwList[0].PTF_Filiale__c];
        String abi=accList[0].FinServ__BankNumber__c;
        String ced=accList[0].PTF_IdCEDFiliale__c;

        if(ced.length()<4){
            do{
                ced='0'+ced;
            }
            while(ced.length()<4);
        }

        List<PTF_ModelloDiServizio__mdt> mdt=[SELECT Id, MasterLabel, PTF_Abbreviazione__c
                                                FROM PTF_ModelloDiServizio__mdt 
                                                WHERE MasterLabel =: mwList[0].PTF_ModelloDiServizio__c];

        String ptfName='PTF-'+mdt[0].PTF_Abbreviazione__c+'-'+abi+'-'+ced+'-';
        System.debug('ptfName: GR 2 '+ ptfName);

        if(isPTFSvil){
            //DK is ptf di sviluppo
            Integer max=0;
            System.debug('@@@@max '+max);
            List<Wallet__c> oldList=[SELECT Name FROM Wallet__c WHERE RecordTypeId=:mwList[0].RecordTypeId AND PTF_Filiale__c=:mwList[0].PTF_Filiale__c AND PTF_ModelloDiServizio__c=:mwList[0].PTF_ModelloDiServizio__c AND (NOT Name LIKE '%999') AND (Name LIKE '%-666%')]; // LV CR NEC #70081
            if(oldList.size()>0){
                for(Wallet__c w:oldList){
                    Integer num= Integer.valueOf(w.Name.split('-')[4]);
                    if(num>max){
                        max=num;
                        System.debug('@@@@max '+max);
                    }
                }
            }
            System.debug('@@@@max '+max);
            if(max>=start){
                max++;
                start=max;
                System.debug('@@@@start '+start);
            }   
        }else{
            //DK is ptf common
            Integer max=0;
            System.debug('@@@@max '+max);
            List<Wallet__c> oldList=[SELECT Name FROM Wallet__c WHERE RecordTypeId=:mwList[0].RecordTypeId AND PTF_Filiale__c=:mwList[0].PTF_Filiale__c AND PTF_ModelloDiServizio__c=:mwList[0].PTF_ModelloDiServizio__c AND (NOT Name LIKE '%999') AND (NOT Name LIKE '%-666%')]; // LV CR NEC #70081
            if(oldList.size()>0){
                for(Wallet__c w:oldList){
                    Integer num= Integer.valueOf(w.Name.split('-')[4]);
                    if((mwList[0].PTF_ModelloDiServizio__c=='Private' && num>max && num!=75) || (num>max)){
                        max=num;
                        System.debug('@@@@max '+max);
                    }
                }
            }
            System.debug('@@@@max '+max);
            if(max>=start){
                max++;
                if(mwList[0].PTF_ModelloDiServizio__c=='Private' &&  max==75){
                    max++;
                }
                start=max;
            }
        }

        if(isPTFSvil){
            //DK is ptf di sviluppo
            for(Wallet__c mw:mwList){
                String seq= String.valueOf(start);
                if(seq.length()<6){
                    do{
                        seq ='0'+seq;
                    }
                    while(seq.length()<6);
                }
                // String firstDigit = seq.substring(0, 1);
                // if (firstDigit == '0') {
                	// MS 02-02-2024 modificato codice 555 con 666
                    seq = '666' + seq.substring(3);
                // }
                mw.Name=ptfName+seq;

                start++;
            }
        }else{
            //DK is ptf common
            for(Wallet__c mw:mwList){
                if(mwList[0].PTF_ModelloDiServizio__c=='Private' && start==75){
                    start++;
                }
                String seq= String.valueOf(start);
                if(seq.length()<6){
                    do{
                        seq='0'+seq;
                    }
                    while(seq.length()<6);
                }
                mw.Name=ptfName+seq;
                start++;
            }
        }
    }

    //CR52359 SV start
    @AuraEnabled
    public static Wrapper getUffPrivate(String idFiliale){
        List<Map<String,String>> options = new List<Map<String,String>>();
        List<Map<String,String>> optionsCentri = new List<Map<String,String>>();//SV Centri Private
        Map<String,List<Account>> mappaCentri = new Map<String,List<Account>>();//SV Centri Private
        List<String> idCedStrutturaBancaList = new List<String>();//SV Centri Private
        Map<String,String> mappaUffici = new Map<String,String>();//SV Centri Private
        Wrapper wrap = new Wrapper();//SV Centri Private
        List<String> idCedList = new List<String>();

        // for(Account account : [SELECT Id, PTF_IdCedUffPrivate__c FROM Account WHERE Id = :idFiliale]){
        //     idCedList.addAll(!String.isBlank(account.PTF_IdCedUffPrivate__c) ? account.PTF_IdCedUffPrivate__c.replace('|', ';').split(';') : new List<String>());
        // }

        // Modifica - Salvatore Barbieri - 07/02/2024
        // ASSOCIAZIONE UFFICI PRIVATE ALLA FILIALE PRIVATE 1800 CON IDCED 27926
        System.debug('Test idFiliale --> ' + idFiliale);
        Account accountTmp = [SELECT Id, PTF_IdCedUffPrivate__c, PTF_IdCED__c FROM Account WHERE Id = :idFiliale];
        System.debug('Test accountTmp --> ' + accountTmp);
        if(accountTmp != null){
            if(accountTmp.PTF_IdCED__c == '27926'){
                //SV Centri Private start
                /*for(Struttura_Banca__c struttBanca : [SELECT Id, Name, IDCed__c, Livello__c, Filiera__c, Nome_Livello__c FROM Struttura_Banca__c WHERE ABI__c = '03084' AND (Livello__c = '200' OR Livello__c = '180') and Stato__c = 'A']){
                        Map<String,String> values = new Map<String,String> {
                            'label' => struttBanca.Name,
                            'value' => struttBanca.IDCed__c
                        };
                        options.add(values);
                }*/
                for(Struttura_Banca__c struttBanca : [SELECT IDCed__c FROM Struttura_Banca__c WHERE ABI__c = '03084' AND (Livello__c = '200' OR Livello__c = '180') and Stato__c = 'A']){
                    idCedStrutturaBancaList.add(struttBanca.IDCed__c);
                }
                for(Account acc : [SELECT Id, Name, PTF_IdCed__c, PTF_Livello__c, ParentId, Parent.PTF_IdCed__c FROM Account WHERE PTF_Livello__c IN ('200', '180') AND FinServ__BankNumber__c='03084' AND PTF_IdCed__c IN :idCedStrutturaBancaList]){
                    if(acc.PTF_Livello__c.equals('180')){
                        Map<String,String> values = new Map<String,String> {
                            'label' => acc.Name,
                            'value' => acc.PTF_IdCed__c
                        };
                        options.add(values);
                    }
                    if(acc.PTF_Livello__c.equals('200')){
                        Map<String,String> values = new Map<String,String> {
                            'label' => acc.Name,
                            'value' => acc.PTF_IdCed__c
                        };
                        //popolo la mappa centri dove la chiave è l'id ced dell'uffiico e i valori solo i record dei centri collegati
                        optionsCentri.add(values);
                        if(!mappaCentri.containsKey(acc.Parent.PTF_IdCed__c)){
                            mappaCentri.put(acc.Parent.PTF_IdCed__c,new List<Account>());
                        }
                        mappaCentri.get(acc.Parent.PTF_IdCed__c).add(acc);
                        //popolo la mappa uffici dove la chiave è l'id ced del centro e il valore l'id ced dell'uffico
                        mappaUffici.put(acc.PTF_IdCed__c,acc.Parent.PTF_IdCed__c);
                    }
                }
                System.debug(LoggingLevel.DEBUG,'### mappa uffici: '+mappaUffici);
                System.debug(LoggingLevel.DEBUG,'### mappa centri: '+mappaCentri);
                wrap.optionUffici = options;
                wrap.optionCentri = optionsCentri;
                wrap.filiale1800 = true;
                wrap.mappaUffici = mappaUffici;
                wrap.mappaCentri = mappaCentri;
            }else{
                idCedList.addAll(!String.isBlank(accountTmp.PTF_IdCedUffPrivate__c) ? accountTmp.PTF_IdCedUffPrivate__c.replace('|', ';').split(';') : new List<String>());
                for(Account uffPrivate : [SELECT Id, PTF_IdCed__c, Name FROM Account WHERE PTF_IdCed__c IN: idCedList]){
                    Map<String,String> values = new Map<String,String> {
                        'label' => uffPrivate.Name,
                        'value' => uffPrivate.PTF_IdCed__c
                    };
                    options.add(values);
                }
                wrap.optionUffici = options;//SV Centri Private
            }
        }
        System.debug('Test options --> ' + options);
        //return options;//SV Centri Private
        return wrap;//SV Centri Private
    } 
    
    //SV creazione wrapper per ritorno uffici private e centri private start
    public class Wrapper {
        @AuraEnabled
        public List<Map<String,String>> optionUffici;
        @AuraEnabled
        public List<Map<String,String>> optionCentri;
        @AuraEnabled
        public Boolean filiale1800 = false;
        @AuraEnabled
        public Map<String,String> mappaUffici;
        @AuraEnabled
        public Map<String,List<Account>> mappaCentri;
    }
    //SV creazione wrapper per ritorno uffici private e centri private end
    @AuraEnabled
    public static Map<String, SObject> getGestoriPrincipaliPrivate(String idFiliale, String modelloServizio, String ufficioPrivate, String abi, Boolean isCheckedPTF, Boolean isPTFSvil, String centroPrivate){
        //SV agiunto centro private in input
        Map<String, SObject> gestoriPrincipaliMapPrivate = new Map<String, SObject>();
        try{
            //SV Centro Private - aggiunta filtro per centro private in query, cambiato il risultato in lista start
            //Account ufficiPrivate = [SELECT Id, PTF_IdCEDPadre__c, PTF_IdCED__c FROM Account WHERE PTF_IdCED__c = :ufficioPrivate];
            List<Account> ufficiPrivate = new List<Account>();
            if(centroPrivate != null){
                ufficiPrivate = [SELECT Id, PTF_IdCEDPadre__c, PTF_IdCED__c, Parent.PTF_IdCED__c FROM Account WHERE PTF_IdCED__c = :ufficioPrivate OR PTF_IdCED__c = :centroPrivate];
            }else{
                ufficiPrivate = [SELECT Id, PTF_IdCEDPadre__c, PTF_IdCED__c, Parent.PTF_IdCED__c FROM Account WHERE PTF_IdCED__c = :ufficioPrivate];
            }
            //SV Centri Private end
            System.debug(LoggingLevel.DEBUG,'### ufficiPrivate: '+ufficioPrivate);
            //SV Centri Private start
            List<String> idCEDPadreList = new List<String>();
            List<String> ufficiPrivateList = new List<String>();
            List<String> ufficiPrivateListOnly = new List<String>();
            for(Account uffPrivate: ufficiPrivate){
                ufficiPrivateList.add(uffPrivate.PTF_IdCED__c);
                idCEDPadreList.add(uffPrivate.Parent.PTF_IdCED__c);
                ufficiPrivateListOnly.add(uffPrivate.PTF_IdCED__c);
            }
            //SV Centro Private - aggiunta filtro per centro private in query, cambiato il risultato in lista
            //Account ufficiPrivateExecutive = [SELECT Id, Name, PTF_IdCED__c FROM Account WHERE PTF_IdCED__c = : ufficiPrivate.PTF_IdCEDPadre__c];
            List<Account> ufficiPrivateExecutive = [SELECT Id, Name, PTF_IdCED__c FROM Account WHERE PTF_IdCED__c IN :idCEDPadreList];
            System.debug(LoggingLevel.DEBUG,'### ufficiPrivateExecutive: '+ufficiPrivateExecutive);
            //SV Centri Private start
            List<String> ufficiPrivateExecutiveList = new List<String>();
            for(Account uffPrivateExective : ufficiPrivateExecutive){
                ufficiPrivateList.add(uffPrivateExective.PTF_IdCED__c);
                ufficiPrivateExecutiveList.add(uffPrivateExective.PTF_IdCED__c);
            }  
            //SV Centri Private start
            System.debug(LoggingLevel.DEBUG, '### ufficiPrivateList: '+ufficiPrivateList);
            Map<String, Set<String>> contactToExcludeMap = new Map<String, Set<String>>();
            contactToExcludeMap.put('progressivo', new Set<String>());
            contactToExcludeMap.put('ptf999', new Set<String>());
            contactToExcludeMap.put('ptfsviluppo', new Set<String>());
            for(Assignment__c assignment : [SELECT PTF_Gestore__c, PTF_MicroWallet__r.Name FROM Assignment__c WHERE RecordType.DeveloperName = 'Primario' AND PTF_EndDate__c = null AND PTF_MicroWallet__r.PTF_ModelloDiServizio__c =: modelloServizio AND PTF_MicroWallet__r.PTF_Filiale__c =: idFiliale]){
                if(assignment.PTF_MicroWallet__r.Name.right(3) == '999'){
                    contactToExcludeMap.get('ptf999').add(assignment.PTF_Gestore__c);
                }else if(assignment.PTF_MicroWallet__r.Name.contains('-666')){
                    contactToExcludeMap.get('ptfsviluppo').add(assignment.PTF_Gestore__c);
                }else{
                    contactToExcludeMap.get('progressivo').add(assignment.PTF_Gestore__c);
                }
            }
            Set<String> contactToExclude = isCheckedPTF ? contactToExcludeMap.get('ptf999') : isPTFSvil ? contactToExcludeMap.get('ptfsviluppo') : contactToExcludeMap.get('progressivo');
            // Set<String> contactToExclude= SV_Utilities.getSet([SELECT PTF_Gestore__c FROM Assignment__c WHERE RecordType.DeveloperName = 'Primario' AND PTF_EndDate__c = null AND PTF_MicroWallet__r.PTF_ModelloDiServizio__c =: modelloServizio AND PTF_MicroWallet__r.PTF_Filiale__c =: idFiliale], 'PTF_Gestore__c'); // LV CR NEC #70081
            ////SV Centri Private start
            //List<Contact> contactList = [SELECT Id, Name, PTF_IdCED__c, PTF_TipologiaRuolo__r.PTF_Code__c, PTF_ProfiloLDAP__c   FROM Contact WHERE PTF_IdCED__c IN (:ufficiPrivate.PTF_IdCED__c,:ufficiPrivateExecutive.PTF_IdCED__c)];
            List<Contact> contactList = [SELECT Id, Name, PTF_IdCED__c, PTF_TipologiaRuolo__r.PTF_Code__c, PTF_ProfiloLDAP__c   FROM Contact WHERE PTF_IdCED__c IN :ufficiPrivateList];
            //SV Centri Private end
            System.debug(LoggingLevel.DEBUG,'### contactList: '+contactList);
            Set<String> refs= new Set<String>();
            for(Contact con : contactList){
                //SV Centri Private - cambio condizione if per ufficiPrivate
                //if(String.isNotBlank(con.PTF_TipologiaRuolo__r.PTF_Code__c) && String.isNotBlank(con.PTF_ProfiloLDAP__c) && con.PTF_TipologiaRuolo__r.PTF_Code__c.equals('069') && (con.PTF_ProfiloLDAP__c.equals('NEC_T.8') || (con.PTF_ProfiloLDAP__c.equals('NEC_D.5') && abi == '01015')) && !contactToExclude.contains(con.Id) && con.PTF_IdCED__c.equals(ufficiPrivate.PTF_IdCED__c)){
                if(String.isNotBlank(con.PTF_TipologiaRuolo__r.PTF_Code__c) && String.isNotBlank(con.PTF_ProfiloLDAP__c) && con.PTF_TipologiaRuolo__r.PTF_Code__c.equals('069') && (con.PTF_ProfiloLDAP__c.equals('NEC_T.8') || (con.PTF_ProfiloLDAP__c.equals('NEC_D.5') && abi == '01015')) && !contactToExclude.contains(con.Id) && ufficiPrivateListOnly.contains(con.PTF_IdCED__c)){
                    refs.add(con.Id);
                }
                //SV Centri Private - cambio condizione if per ufficiPrivate
                //if(String.isNotBlank(con.PTF_TipologiaRuolo__r.PTF_Code__c) && String.isNotBlank(con.PTF_ProfiloLDAP__c) && con.PTF_TipologiaRuolo__r.PTF_Code__c.equals('F_140') && con.PTF_ProfiloLDAP__c.equals('NEC_T.7') && con.PTF_IdCED__c.equals(ufficiPrivate.PTF_IdCED__c)) {
                if(String.isNotBlank(con.PTF_TipologiaRuolo__r.PTF_Code__c) && String.isNotBlank(con.PTF_ProfiloLDAP__c) && con.PTF_TipologiaRuolo__r.PTF_Code__c.equals('F_140') && con.PTF_ProfiloLDAP__c.equals('NEC_T.7') && ufficiPrivateListOnly.contains(con.PTF_IdCED__c)) {
                    refs.add(con.Id);
                }
                //SV Centri Private - cambio condizione if per ufficiPrivate
                //if(String.isNotBlank(con.PTF_TipologiaRuolo__r.PTF_Code__c) && String.isNotBlank(con.PTF_ProfiloLDAP__c) && con.PTF_TipologiaRuolo__r.PTF_Code__c.equals('100') && (con.PTF_ProfiloLDAP__c.equals('NEC_D.10') || con.PTF_ProfiloLDAP__c.equals('NEC_T.7')) && (con.PTF_IdCED__c.equals(ufficiPrivate.PTF_IdCED__c) || con.PTF_IdCED__c.equals(ufficiPrivateExecutive.PTF_IdCED__c))){
                if(String.isNotBlank(con.PTF_TipologiaRuolo__r.PTF_Code__c) && String.isNotBlank(con.PTF_ProfiloLDAP__c) && con.PTF_TipologiaRuolo__r.PTF_Code__c.equals('100') && (con.PTF_ProfiloLDAP__c.equals('NEC_D.10') || con.PTF_ProfiloLDAP__c.equals('NEC_T.7')) && (ufficiPrivateListOnly.contains(con.PTF_IdCED__c) || con.PTF_IdCED__c.contains(con.PTF_IdCED__c))){
                    refs.add(con.Id);
                }
            }
            gestoriPrincipaliMapPrivate = SV_Utilities.keyBy([
                SELECT Id, FirstName, LastName, PTF_RegistrationNumber__c, PTF_User__c, Account.Name
                FROM Contact
                WHERE Id IN:refs], 'Id', false);    
        }catch(Exception e){
            System.debug(LoggingLevel.ERROR,'### getGestoriPrincipaliPrivate Exception at line: '+e.getLineNumber()+' - '+e.getMessage());
        }
        return gestoriPrincipaliMapPrivate;
    }
    @AuraEnabled
    public static Map<String, SObject> gestoriBackupPrivate( String idFiliale, String modelloServizio, String ufficioPrivate, String abi, String centroPrivate){ //SV agiunto centro private in input
        Map<String, SObject> gestoriBackupMapPrivate = new Map<String, SObject>();
        try{
            //SV Centri Private start
            //Account ufficiPrivate = [SELECT Id, PTF_IdCEDPadre__c, PTF_IdCED__c FROM Account WHERE PTF_IdCED__c = :ufficioPrivate];
            List<Account> ufficiPrivate = new List<Account>();
            if(centroPrivate != null){
                ufficiPrivate = [SELECT Id, PTF_IdCEDPadre__c, PTF_IdCED__c, Parent.PTF_IdCED__c FROM Account WHERE PTF_IdCED__c = :ufficioPrivate OR PTF_IdCED__c = :centroPrivate];
            }else{
                ufficiPrivate = [SELECT Id, PTF_IdCEDPadre__c, PTF_IdCED__c, Parent.PTF_IdCED__c FROM Account WHERE PTF_IdCED__c = :ufficioPrivate];
            } 
            //SV Centri Private end
            System.debug(LoggingLevel.DEBUG,'### ufficiPrivate: '+ufficioPrivate);
            //SV Centri Private start
            List<String> idCEDPadreList = new List<String>();
            List<String> ufficiPrivateList = new List<String>();
            List<String> ufficiPrivateListOnly = new List<String>();
            for(Account uffPrivate: ufficiPrivate){
                ufficiPrivateList.add(uffPrivate.PTF_IdCED__c);
                idCEDPadreList.add(uffPrivate.Parent.PTF_IdCED__c);
                ufficiPrivateListOnly.add(uffPrivate.PTF_IdCED__c);
            }
            //SV Centri Private end
            //SV Centri Private start
            //Account ufficiPrivateExecutive = [SELECT Id, Name, PTF_IdCED__c FROM Account WHERE PTF_IdCED__c = :ufficiPrivate.PTF_IdCEDPadre__c];
            List<Account> ufficiPrivateExecutive = [SELECT Id, Name, PTF_IdCED__c FROM Account WHERE PTF_IdCED__c IN :idCEDPadreList];
            List<String> ufficiPrivateExecutiveList = new List<String>();
            for(Account uffPrivateExective : ufficiPrivateExecutive){
                ufficiPrivateList.add(uffPrivateExective.PTF_IdCED__c);
                ufficiPrivateExecutiveList.add(uffPrivateExective.PTF_IdCED__c);
            } 
            //SV Centri Private end
            System.debug(LoggingLevel.DEBUG,'### ufficiPrivateExecutive: '+ufficiPrivateExecutive);
            //SV Centri Private start
            //List<Contact> contactList = [SELECT Id, Name, PTF_IdCED__c, PTF_TipologiaRuolo__r.PTF_Code__c, PTF_ProfiloLDAP__c   FROM Contact WHERE PTF_IdCED__c IN (:ufficiPrivate.PTF_IdCED__c,:ufficiPrivateExecutive.PTF_IdCED__c)];
            List<Contact> contactList = [SELECT Id, Name, PTF_IdCED__c, PTF_TipologiaRuolo__r.PTF_Code__c, PTF_ProfiloLDAP__c   FROM Contact WHERE PTF_IdCED__c IN :ufficiPrivateList];
            //SV Centri Private end
            System.debug(LoggingLevel.DEBUG,'### contactList: '+contactList);
            Set<String> refs= new Set<String>();
            for(Contact con : contactList){
                //SV Centri Private - cambio condizione if per ufficiPrivate
                //if(String.isNotBlank(con.PTF_TipologiaRuolo__r.PTF_Code__c) && String.isNotBlank(con.PTF_ProfiloLDAP__c) && con.PTF_TipologiaRuolo__r.PTF_Code__c.equals('069') && (con.PTF_ProfiloLDAP__c.equals('NEC_T.8') || (con.PTF_ProfiloLDAP__c.equals('NEC_D.5') && abi == '01015')) && con.PTF_IdCED__c.equals(ufficiPrivate.PTF_IdCED__c)){
                if(String.isNotBlank(con.PTF_TipologiaRuolo__r.PTF_Code__c) && String.isNotBlank(con.PTF_ProfiloLDAP__c) && con.PTF_TipologiaRuolo__r.PTF_Code__c.equals('069') && (con.PTF_ProfiloLDAP__c.equals('NEC_T.8') || (con.PTF_ProfiloLDAP__c.equals('NEC_D.5') && abi == '01015')) && ufficiPrivateListOnly.contains(con.PTF_IdCED__c)){
                    refs.add(con.Id);
                }
                //SV Centri Private - cambio condizione if per ufficiPrivate
                //if(String.isNotBlank(con.PTF_TipologiaRuolo__r.PTF_Code__c) && String.isNotBlank(con.PTF_ProfiloLDAP__c) && con.PTF_TipologiaRuolo__r.PTF_Code__c.equals('F_140') && con.PTF_ProfiloLDAP__c.equals('NEC_T.7') && con.PTF_IdCED__c.equals(ufficiPrivate.PTF_IdCED__c)) {
                if(String.isNotBlank(con.PTF_TipologiaRuolo__r.PTF_Code__c) && String.isNotBlank(con.PTF_ProfiloLDAP__c) && con.PTF_TipologiaRuolo__r.PTF_Code__c.equals('F_140') && con.PTF_ProfiloLDAP__c.equals('NEC_T.7') && ufficiPrivateListOnly.contains(con.PTF_IdCED__c)) {
                    refs.add(con.Id);
                }
                //SV Centri Private - cambio condizione if per ufficiPrivate
                //if(String.isNotBlank(con.PTF_TipologiaRuolo__r.PTF_Code__c) && String.isNotBlank(con.PTF_ProfiloLDAP__c) && con.PTF_TipologiaRuolo__r.PTF_Code__c.equals('100') && (con.PTF_ProfiloLDAP__c.equals('NEC_D.10') || con.PTF_ProfiloLDAP__c.equals('NEC_T.7')) && (con.PTF_IdCED__c.equals(ufficiPrivate.PTF_IdCED__c) || con.PTF_IdCED__c.equals(ufficiPrivateExecutive.PTF_IdCED__c))){
                    if(String.isNotBlank(con.PTF_TipologiaRuolo__r.PTF_Code__c) && String.isNotBlank(con.PTF_ProfiloLDAP__c) && con.PTF_TipologiaRuolo__r.PTF_Code__c.equals('100') && (con.PTF_ProfiloLDAP__c.equals('NEC_D.10') || con.PTF_ProfiloLDAP__c.equals('NEC_T.7')) && (ufficiPrivateListOnly.contains(con.PTF_IdCED__c) || ufficiPrivateExecutiveList.contains(con.PTF_IdCED__c))){
                    refs.add(con.Id);
                }
            }
            gestoriBackupMapPrivate = SV_Utilities.keyBy([
                SELECT Id, FirstName, LastName, PTF_RegistrationNumber__c, PTF_User__c, Account.Name
                FROM Contact
                WHERE Id IN:refs], 'Id', false);
        }catch(Exception e){
            System.debug(LoggingLevel.ERROR,'### getGestoriBackupPrivate Exception at line: '+e.getLineNumber()+' - '+e.getMessage());
        }
        return gestoriBackupMapPrivate;
    }
    //CR52359 SV end
    @AuraEnabled
    public static Boolean checkPortafoglioExists(String filiale, String modelloServizio){
        List<Wallet__c> portafogli = [SELECT PTF_Filiale__c FROM Wallet__c WHERE PTF_Filiale__c =: filiale AND PTF_ModelloDiServizio__c =: modelloServizio AND Name LIKE '%999' ];
        return !portafogli.isEmpty();
    }
}