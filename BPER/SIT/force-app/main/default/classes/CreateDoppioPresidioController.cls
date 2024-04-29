/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 09-09-2020
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
 * Modifications Log 
 * Ver   Date         Author                               Modification
 * 1.0   09-07-2020   ChangeMeIn@UserSettingsUnder.SFDoc   Initial Version
**/
public class CreateDoppioPresidioController {
    public class CustomException extends Exception {}

    @AuraEnabled
    public static Boolean getContactRole(){
        List<Contact> userContact=[SELECT Id FROM Contact WHERE PTF_User__c=:UserInfo.getUserId() AND PTF_Ruolo__c = '100' AND Account.RecordType.DeveloperName = 'FilialeDiRelazione' ];
        if(userContact.size()>0){
            return true;
        }
        else{
            return false;
        }
    }

    @AuraEnabled
    public static Boolean getContactRoleFinanziario(String recordId){
        List<Account> acc =[SELECT PTF_Filiale__c FROM Account WHERE Id=:recordId];
        List<Contact> userContact=[SELECT Id FROM Contact WHERE PTF_User__c=:UserInfo.getUserId() AND PTF_TipologiaRuolo__r.Name='Titolare' AND AccountId =:acc[0].PTF_Filiale__c];
        if(userContact.size()>0){
            return true;
        }
        else{
            return false;
        }
    }

    @AuraEnabled
    public static NDGManagementMember__c creaDoppioPresidioFinanziario(Id recId, Id contId) {
        System.debug('Account id: ' + recId);
        System.debug('Contact id: ' + contId);
        NDGManagementMember__c doppioPresidio = null;
        try {
            Id recTypeId = SV_Utilities.getRecordTypeByDeveloperName('NDGManagementMember__c', 'DoppioPresidio');
            // List<NDGManagementMember__c> presidioToDelete= [SELECT PTF_Gestore__c, PTF_Gestore__r.Name, PTF_Gestore__r.Email, PTF_Gestore__r.PTF_RegistrationNumber__c, PTF_Gestore__r.PTF_TipologiaRuolo__r.Name, PTF_Gestore__r.PTF_UnitaOrganizzativa__c
            //                                         FROM NDGManagementMember__c WHERE RecordTypeId=:recTypeId AND PTF_NDG__c=:recId AND PTF_EndDate__c=NULL];
            // for(NDGManagementMember__c dp:presidioToDelete){
            //     dp.PTF_EndDate__c= Date.today();
            // }
            // if(presidioToDelete.size()>0){
            //     update presidioToDelete;
            // }                                        
            
            doppioPresidio = new NDGManagementMember__c();
            doppioPresidio.PTF_Gestore__c = contId;
            doppioPresidio.PTF_NDG__c = recId;
            doppioPresidio.RecordTypeId = recTypeId;
            doppioPresidio.PTF_StartDate__c = Date.today();
            doppioPresidio.PTF_StartDate_DT__c = Datetime.now();
            System.debug('Doppio Presidio: '+ doppioPresidio);
            insert doppioPresidio;
        }
        catch(Exception exc) {
            throw new AuraHandledException(exc.getMessage());
        }
        return doppioPresidio;
    }

    @AuraEnabled
    public static NDGManagementMember__c createDoppioPresidio(Id recId) {
        NDGManagementMember__c doppioPresidio = null;
        try {
            Id recTypeId = SV_Utilities.getRecordTypeByDeveloperName('NDGManagementMember__c', 'DoppioPresidio');
            Account rec = [
                SELECT  Id,
                        ModelloDiServizio__c,
                        PTF_Filiale__c
                FROM Account
                WHERE Id =:recId
            ];
            List<Contact> contacts = [
                SELECT  Id,
                        PTF_User__c,
                        PTF_TipologiaRuolo__c,
                        PTF_TipologiaRuolo__r.Name
                FROM Contact
                WHERE  PTF_User__c =: UserInfo.getUserId()
            ];
            if (contacts.size()>0 && contacts.get(0).PTF_TipologiaRuolo__r.Name!='Titolare') {
                throw new CustomException('Non risulti TITOLARE'); 
            }

            if ('Private'.equals(rec.ModelloDiServizio__c)) {
                throw new CustomException('Modello di Servizio non ammesso'); 
            }

            
                if (contacts!=null && contacts.size()>0) {
                    List<NDGManagementMember__c> presidio = [
                        SELECT  Id,
                                PTF_EndDate__c
                        FROM NDGManagementMember__c
                        WHERE PTF_Gestore__c =: contacts.get(0).Id
                        AND PTF_NDG__c =: recId
                        AND PTF_EndDate__c=NULL
                        AND RecordType.DeveloperName = 'DoppioPresidio'
                    ];
                    if (presidio!=null && presidio.size()>0) {
                        throw new CustomException('Esiste già un doppio presidio');
                    }
                    else {
                        doppioPresidio = new NDGManagementMember__c();
                        doppioPresidio.PTF_Gestore__c = contacts.get(0).Id;
                        doppioPresidio.PTF_NDG__c = recId;
                        doppioPresidio.RecordTypeId = recTypeId;
                        doppioPresidio.PTF_StartDate__c = Date.today();
                        doppioPresidio.PTF_StartDate_DT__c = Datetime.now();
                        insert doppioPresidio;
                    }
                }
                else {
                    throw new CustomException('Nessun contatto associato'); 
                }
            

            
        }
        catch(Exception exc) {
            throw new AuraHandledException(exc.getMessage());
        }
        return doppioPresidio;
    }

    @AuraEnabled
    public static DoppioPresidioFinanzirioWrapper getNDG(Id recId,  String nominativo, String matricola, String tipologia, List<String> modelli) {
        System.debug('Record id: ' + recId);
        System.debug('SearchedNominativo: ' + nominativo);
        System.debug('SearchedMatricola: ' + matricola);
        System.debug('SearchedTipologia: ' + tipologia);
        DoppioPresidioFinanzirioWrapper wrapper = new DoppioPresidioFinanzirioWrapper();
        try {
            User currentUser = [SELECT ID, Profile.Name FROM User WHERE Id =: UserInfo.getUserId()];

            wrapper.ndg = [
                SELECT  Id,
                        ModelloDiServizio__c,
                        PTF_Filiale__c,
                        PTF_Filiale__r.PTF_IDCEDUffPrivate__c,
                        PTF_ModelloDiServizio__c,
                        FinServ__BankNumber__c
                FROM Account
                WHERE Id=:recId                 
            ];
            String idCedUffPrivate = wrapper.ndg.PTF_Filiale__r.PTF_IDCEDUffPrivate__c;
            List<String> officeList = idCedUffPrivate.split('\\|');
            System.debug('***getNdg OfficeList: '+officeList);

            List<Account> accExecutive = new List<Account>();
            if(!officeList.isEmpty()){
                accExecutive= [SELECT PTF_IdCEDPadre__c
                FROM Account
                WHERE FinServ__BankNumber__c in ('01015','05387')
                AND RecordType.DeveloperName ='AltraUnitaOrganizzativa'
                AND PTF_IdCED__c in: officeList AND PTF_DataChiusura__c = null];
    
            }
            List<String> IdExOfficeList = new LIst<String>();
            for(Account cAcc: accExecutive){
                if(!String.isBlank(cAcc.PTF_IdCEDPadre__c)) IdExOfficeList.add(cAcc.PTF_IdCEDPadre__c);
            }

            String bankCode = wrapper.ndg.FinServ__BankNumber__c;
            Set<String> PTFCodes = new Set<String>();
            PTFCodes.add('065');
            PTFCodes.add('069');
            PTFCodes.add('990');
            PTFCodes.add('991');
            PTFCodes.add('F_914');
            PTFCodes.add('F_912');
            PTFCodes.add('F_905');
            PTFCodes.add('144');
            PTFCodes.add('F_140');
            //Set<String> modelloDiServizio = new Set<String>{'POE','SMALL BUSINESS','CORPORATE','Corporate'};
            if (wrapper.ndg!=null && modelli.contains(wrapper.ndg.ModelloDiServizio__c)) {
                /*List<NDGManagementMember__c> ndgMMs = [
                    SELECT  Id,
                            PTF_NDG__c,
                            RecordType.DeveloperName,
                            PTF_Gestore__c,
                            PTF_Gestore__r.PTF_User__c,
                            PTF_Gestore__r.PTF_TipologiaRuolo__c,
                            PTF_Gestore__r.PTF_TipologiaRuolo__r.PTF_Code__c,
                            PTF_Gestore__r.PTF_ProfiloLDAP__c,
                            PTF_EndDate__c
                    FROM NDGManagementMember__c
                    WHERE PTF_NDG__c =: recId
                    //AND PTF_Gestore__r.PTF_TipologiaRuolo__r.PTF_Code__c IN : PTFCodes//('990','991')
                    AND ( PTF_Gestore__r.PTF_TipologiaRuolo__r.PTF_Code__c IN : PTFCodes
                    OR (PTF_Gestore__r.PTF_TipologiaRuolo__r.PTF_Code__c = '100' 
                        AND PTF_Gestore__r.PTF_ProfiloLDAP__c IN ('NEC_D.10','NEC_T.7')
                        AND PTF_Gestore__r.PTF_IdcedPadre__c = '3008' )) //valerio.salvati
                    AND  RecordType.DeveloperName = 'DoppioPresidio'
                    AND PTF_EndDate__c=NULL
                ];*/

                // if (ndgMMs.size()>0) {
                //     throw new CustomException('Esiste già un consulente finanziario associarto');
                // }
                List<String> conditionList= new List<String>();
                String searchedNominativo = '%' + nominativo + '%'; 
                String searchedMatricola = '%' + matricola + '%';
                String searchedTipologia = '%' + tipologia + '%';

                /*String countQuery='SELECT Count() FROM Contact'+
                                    ' WHERE (PTF_TipologiaRuolo__r.PTF_Code__c IN :PTFCodes OR (PTF_TipologiaRuolo__r.PTF_Code__c = \'100\' AND PTF_ProfiloLDAP__c IN (\'NEC_D.10\',\'NEC_T.7\') '+
                                    'AND PTF_IdcedPadre__c = \'3008\' ) )  and PTF_RegistrationNumber__c!=null and PTF_Closed_Date_Referente__c =null';
                String Query= 'SELECT Id,Name,AccountId,PTF_TipologiaRuolo__c,PTF_TipologiaRuolo__r.PTF_Code__c,PTF_TipologiaRuolo__r.Name,PTF_ModelloDiServizio__c,PTF_UnitaOrganizzativa__c,PTF_RegistrationNumber__c FROM Contact'+
                                ' WHERE (PTF_TipologiaRuolo__r.PTF_Code__c IN :PTFCodes OR (PTF_TipologiaRuolo__r.PTF_Code__c = \'100\' AND PTF_ProfiloLDAP__c IN (\'NEC_D.10\',\'NEC_T.7\') '+
                                'AND PTF_IdcedPadre__c = \'3008\' ) )  and PTF_RegistrationNumber__c!=null and PTF_Closed_Date_Referente__c =null';
                */
                String Query= 'SELECT Id,Name,AccountId,PTF_TipologiaRuolo__c,PTF_TipologiaRuolo__r.PTF_Code__c,PTF_TipologiaRuolo__r.Name,PTF_ModelloDiServizio__c,PTF_UnitaOrganizzativa__c,PTF_RegistrationNumber__c FROM Contact '+
                                'WHERE (PTF_TipologiaRuolo__r.PTF_Code__c IN :PTFCodes '+
                                'OR (PTF_TipologiaRuolo__r.PTF_Code__c = \'F_144\' AND PTF_ProfiloLDAP__c IN (\'NEC_D.10\',\'NEC_T.7\') AND PTF_IdcedPadre__c = \'3008\' ) )'+  
                                'AND PTF_RegistrationNumber__c!=null AND PTF_Closed_Date_Referente__c = null ';

                List<String> superUserList = new List<String>{'System Administrator','NEC_D.0'};
                if(!superUserList.contains(currentUser.Profile.Name) ){           
                    
                    System.debug('VP officeList: ' + officeList);
                    
                    Query+= 'AND ( (PTF_MDSConcatList__c =\'Private\' AND PTF_IdCED__c IN: officeList AND Account.FinServ__BankNumber__c =: bankCode ) '+
                                'OR (PTF_MDSConcatList__c =\'Key Client Privati\' AND Account.FinServ__BankNumber__c =: bankCode) '+
                                'xxxxx ';
        
                            if(!IdExOfficeList.isEmpty()){ query = query.replace('xxxxx','OR (PTF_ProfiloLDAP__c in (\'NEC_D.10\',\'NEC_T.7\') AND PTF_IdCed__c IN: IdExOfficeList AND Account.FinServ__BankNumber__c =: bankCode)');}
                            else{ query = query.replace('xxxxx','');}


                            if(bankCode != '01015') query += 'OR (PTF_MDSConcatList__c =\'Consulenti Finanziari\')';

                            query+= ')';
                
                }

                if(!String.isBlank(nominativo)){
                    System.debug('Nominativo not Blank');
                    //conditionList.add(' Name LIKE: searchedNominativo ');
                    conditionList.add(' CRM_nominativoNoEnc__c LIKE: searchedNominativo ');
                }
                if(!String.isBlank(matricola)){
                    System.debug('Matricola not Blank');
                    //conditionList.add(' PTF_ConcatRegistrationNumber__c LIKE: searchedMatricola ');
                    conditionList.add(' PTF_RegistrationNumber__c =: matricola ');
                    //conditionList.add(' CRM_matricolaNoEnc__c LIKE: searchedMatricola ');
                }
                if(!String.isBlank(tipologia)){
                    conditionList.add(' PTF_TipologiaRuolo__r.Name LIKE: searchedTipologia');
                    //conditionList.add(' PTF_ModelloDiServizio__c LIKE: searchedtipologia');
                }

                
                if(!conditionList.isEmpty()){

                    //countQuery += ' AND ' + String.join(conditionList, ' AND ');
                    query += ' AND ' + String.join(conditionList, ' AND ');
                }
                //query+= 'LIMIT:pagesize OFFSET:offset';               
                /*List<Contact> consulentiFinanziari = [
                    SELECT  Id,
                            Name,
                            AccountId,
                            PTF_TipologiaRuolo__c,
                            PTF_TipologiaRuolo__r.PTF_Code__c,
                            PTF_TipologiaRuolo__r.Name,
                            PTF_ModelloDiServizio__c,
                            PTF_UnitaOrganizzativa__c,
                            PTF_RegistrationNumber__c
                    FROM Contact
                    WHERE PTF_TipologiaRuolo__r.PTF_Code__c IN ('990','991')
                    AND PTF_ModelloDiServizio__c =: 'Consulenti Finanziari'
                    LIMIT:pagesize OFFSET:offset
                ];*/
                
                System.debug('Query: ' + query);
                List<Contact> consulentiFinanziari = Database.query(query);    

                System.debug('Consulenti finanziari: ' + consulentiFinanziari);
                //Integer listCount=Database.countQuery(countQuery);
                Integer listCount=consulentiFinanziari.size();
                wrapper.listCount=ListCount;
                if (consulentiFinanziari!=null && consulentiFinanziari.size()>0) {
                    wrapper.consulentiFinanziari = consulentiFinanziari;
                }                    

            }
            else {
                throw new CustomException('Operazione non ammessa per il modello di servizio');
            }
        }
        catch(Exception exc) {
            throw new AuraHandledException(exc.getMessage());
        }
        return wrapper;
    }

    @AuraEnabled
    public static NDGManagementMember__c creazioneDoppioPresidioEstero(Id recId, Id contId) {
        NDGManagementMember__c doppioPresidioEstero = null;
        try {
            Id recTypeId = SV_Utilities.getRecordTypeByDeveloperName('NDGManagementMember__c', 'DoppioPresidioEstero');
                                                  
            doppioPresidioEstero = new NDGManagementMember__c();
            doppioPresidioEstero.PTF_Gestore__c = contId;
            doppioPresidioEstero.PTF_NDG__c = recId;
            doppioPresidioEstero.RecordTypeId = recTypeId;
            doppioPresidioEstero.PTF_StartDate__c = Date.today();
            doppioPresidioEstero.PTF_StartDate_DT__c = Datetime.now();
            insert doppioPresidioEstero;
        }
        catch(Exception exc) {
            throw new AuraHandledException(exc.getMessage());
        }
        return doppioPresidioEstero;
    }

    @AuraEnabled
    public static DoppioPresidioEsteroWrapper getNDGEstero(Id recId,  String nominativo, String matricola, List<String> modelli) {
        DoppioPresidioEsteroWrapper wrapper = new DoppioPresidioEsteroWrapper();
        try {
            wrapper.ndgEstero = [
                SELECT  Id,
                        ModelloDiServizio__c,
                        PTF_Filiale__c
                FROM Account
                WHERE Id=:recId                 
            ];
            if (wrapper.ndgEstero!=null && modelli.contains(wrapper.ndgEstero.ModelloDiServizio__c)) {
                
                List<String> conditionList= new List<String>();
                String searchedNominativo = '%' + nominativo + '%'; 
                String searchedMatricola = '%' + matricola + '%';
                String countQuery='SELECT Count() FROM Contact'+
                                    ' WHERE PTF_TipologiaRuolo__r.PTF_Code__c IN (\'300\',\'301\', \'F_915\') AND PTF_IdCED__c = \'21068\' ' ;
                String Query= 'SELECT Id,Name,AccountId,PTF_TipologiaRuolo__c,PTF_TipologiaRuolo__r.PTF_Code__c,PTF_TipologiaRuolo__r.Name,PTF_ModelloDiServizio__c,PTF_UnitaOrganizzativa__c,PTF_RegistrationNumber__c FROM Contact'+
                                ' WHERE PTF_TipologiaRuolo__r.PTF_Code__c IN (\'300\',\'301\', \'F_915\') AND PTF_IdCED__c = \'21068\'  ';
                System.debug('QUUERY '+Query);
                if(!String.isBlank(nominativo)){

                    conditionList.add(' Name LIKE: searchedNominativo ');
                }
                if(!String.isBlank(matricola)){

                    conditionList.add(' PTF_RegistrationNumber__c LIKE: searchedMatricola ');
                }
                if(!conditionList.isEmpty()){

                    countQuery += ' AND ' + String.join(conditionList, ' AND ');
                    query += ' AND ' + String.join(conditionList, ' AND ');
                }
                
                List<Contact> consulentiEstero = Database.query(query);                   
                Integer listCount=Database.countQuery(countQuery);
                wrapper.listCount=ListCount;
                if (consulentiEstero!=null && consulentiEstero.size()>0) {
                    wrapper.consulentiEstero = consulentiEstero;
                }                    

            }
            else {
                throw new CustomException('Operazione non ammessa per il modello di servizio');
            }
        }
        catch(Exception exc) {
            throw new AuraHandledException(exc.getMessage());
        }
        return wrapper;
    }


    public class DoppioPresidioFinanzirioWrapper {
        @AuraEnabled public Account ndg    {get; set;}
        @AuraEnabled public Set<Id> contattiFinanziari {get;set;}
        @AuraEnabled public List<Contact> consulentiFinanziari {get; set;}
        @AuraEnabled public Integer listCount;
        public DoppioPresidioFinanzirioWrapper() {
            this.ndg = null;
            this.contattiFinanziari = new Set<Id>();
            this.consulentiFinanziari = new List<Contact>();
        }
    }

    public class DoppioPresidioEsteroWrapper {
        @AuraEnabled public Account ndgEstero    {get; set;}
        @AuraEnabled public Set<Id> contattiEstero {get;set;}
        @AuraEnabled public List<Contact> consulentiEstero {get; set;}
        @AuraEnabled public Integer listCount;
        public DoppioPresidioEsteroWrapper() {
            this.ndgEstero = null;
            this.contattiEstero = new Set<Id>();
            this.consulentiEstero = new List<Contact>();
        }
    }

    @AuraEnabled
    public static List<NDGManagementMember__c> getDoppioPresidio(String recordId){
        System.debug('SV recordId: ' + recordId);
        Id recTypeId = SV_Utilities.getRecordTypeByDeveloperName('NDGManagementMember__c', 'DoppioPresidio');
        Set<String> PTFCodes = new Set<String>();
        PTFCodes.add('065');
        PTFCodes.add('069');
        PTFCodes.add('990');
        PTFCodes.add('991');
        PTFCodes.add('F_914');
        PTFCodes.add('F_912');
        PTFCodes.add('F_905');
        PTFCodes.add('144');
        PTFCodes.add('F_140');

        User currentUser = [SELECT ID, Profile.Name FROM User WHERE Id =: UserInfo.getUserId()];
        Account acc = [
            SELECT  Id,
                    ModelloDiServizio__c,
                    PTF_Filiale__c,
                    PTF_ModelloDiServizio__c,
                    PTF_Filiale__r.PTF_IDCEDUffPrivate__c,
                    FinServ__BankNumber__c
            FROM Account
            WHERE Id=:recordId];
        List<String> officeList = acc.PTF_Filiale__r.PTF_IDCEDUffPrivate__c.split('\\|');
        System.debug('***getDoppioPresidio OfficeList: '+officeList);

        List<Account> accExecutive  = new List<Account>();
        if(!officeList.isEmpty()){
            accExecutive= [SELECT PTF_IdCEDPadre__c
            FROM Account
            WHERE FinServ__BankNumber__c in ('01015','05387')
            AND RecordType.DeveloperName ='AltraUnitaOrganizzativa'
            AND PTF_IdCED__c in: officeList AND PTF_DataChiusura__c = null];

        }

        List<String> IdOfficeList = new LIst<String>();
        for(Account cAcc: accExecutive){
            if(!String.isBlank(cAcc.PTF_IdCEDPadre__c)) IdOfficeList.add(cAcc.PTF_IdCEDPadre__c);
        }

        List<NDGManagementMember__c> result;
        String query;
        List<String> superUserList = new List<String>{'System Administrator','NEC_D.0'};
            query = 'SELECT PTF_Gestore__c, PTF_Gestore__r.Name, PTF_Gestore__r.Email, PTF_Gestore__r.PTF_RegistrationNumber__c, PTF_Gestore__r.PTF_TipologiaRuolo__r.Name, PTF_Gestore__r.PTF_UnitaOrganizzativa__c '+
                    'FROM NDGManagementMember__c WHERE RecordTypeId=:recTypeId AND PTF_NDG__c=:recordId AND PTF_EndDate__c=NULL AND (PTF_Gestore__r.PTF_TipologiaRuolo__r.PTF_Code__c IN : PTFCodes '+
                    'OR (PTF_Gestore__r.PTF_TipologiaRuolo__r.PTF_Code__c = \'100\' AND PTF_Gestore__r.PTF_ProfiloLDAP__c IN (\'NEC_D.10\',\'NEC_T.7\') AND PTF_Gestore__r.PTF_IdcedPadre__c = \'3008\' )) '; 
        if(!superUserList.contains(currentUser.Profile.Name) ){
            query+=     'AND ((PTF_Gestore__r.PTF_MDSConcatList__c =\'Private\' AND PTF_Gestore__r.PTF_IdCed__c IN: officeList AND PTF_Gestore__r.Account.FinServ__BankNumber__c =: acc.FinServ__BankNumber__c ) '+
                        'OR (PTF_Gestore__r.PTF_MDSConcatList__c =\'Key Client Privati\' AND PTF_Gestore__r.Account.FinServ__BankNumber__c =: acc.FinServ__BankNumber__c) '+
                        'xxxxx ' ;
                        

                    if(!IdOfficeList.isEmpty()){  query = query.replace('xxxxx','OR (PTF_Gestore__r.PTF_ProfiloLDAP__c in (\'NEC_D.10\',\'NEC_T.7\') AND PTF_Gestore__r.PTF_IdCed__c IN: IdOfficeList AND PTF_Gestore__r.Account.FinServ__BankNumber__c =: acc.FinServ__BankNumber__c)');
                    }else{ query = query.replace('xxxxx',''); }

                    if(acc.FinServ__BankNumber__c != '01015') query += 'OR (PTF_Gestore__r.PTF_MDSConcatList__c =\'Consulenti Finanziari\')';

                    query+= ')';

        }
        result =Database.query(query);
        return result;

    }
    //gestione del doppio presidio estero - start
    @AuraEnabled
    public static List<NDGManagementMember__c> getDoppioPresidioEstero(String recordId){
        System.debug('GB recordId: ' + recordId);
        Id recTypeId = SV_Utilities.getRecordTypeByDeveloperName('NDGManagementMember__c', 'DoppioPresidioEstero');
        List<NDGManagementMember__c> result= [SELECT PTF_Gestore__c, PTF_Gestore__r.Name, PTF_Gestore__r.Email, PTF_Gestore__r.PTF_RegistrationNumber__c, 
                                              PTF_Gestore__r.PTF_TipologiaRuolo__r.Name, PTF_Gestore__r.PTF_UnitaOrganizzativa__c
        FROM NDGManagementMember__c WHERE RecordTypeId=:recTypeId AND PTF_NDG__c=:recordId AND PTF_EndDate__c=NULL AND PTF_Gestore__r.PTF_TipologiaRuolo__r.PTF_Code__c IN ('300','301','F_915')];
        return result;

    }
    //gestione del doppio presidio estero - end

    @AuraEnabled
    public static List<NDGManagementMember__c> deleteDoppioPresidio(String recordId, List<String> idDPList){
        System.debug('SV idDPList: ' + idDPList);
        System.debug('SV recordId: ' + recordId);

        List<NDGManagementMember__c> result = [SELECT Id, PTF_EndDate__c, PTF_EndDate_DT__c
        FROM NDGManagementMember__c WHERE id IN : idDPList ];

        for(NDGManagementMember__c member : result){
            member.PTF_EndDate__c = Date.today();
            member.PTF_EndDate_DT__c = Datetime.now();
        }
        if(result.size()>0){
            update result;
        }
        

        Id recTypeId = SV_Utilities.getRecordTypeByDeveloperName('NDGManagementMember__c', 'DoppioPresidio');
        List<NDGManagementMember__c> newResult= [SELECT PTF_Gestore__c, PTF_Gestore__r.Name, PTF_Gestore__r.Email, PTF_Gestore__r.PTF_RegistrationNumber__c, 
                                                 PTF_Gestore__r.PTF_TipologiaRuolo__r.Name, PTF_Gestore__r.PTF_UnitaOrganizzativa__c
        FROM NDGManagementMember__c WHERE RecordTypeId=:recTypeId AND PTF_NDG__c=:recordId AND PTF_EndDate__c=NULL AND PTF_Gestore__r.PTF_TipologiaRuolo__r.PTF_Code__c IN ('990','991')];

        return newResult;

    }

    @AuraEnabled
    public static List<NDGManagementMember__c> deleteDoppioPresidioEstero(String recordId, List<String> idDPList){
        System.debug('GB idDPList: ' + idDPList);
        System.debug('GB recordId: ' + recordId);

        List<NDGManagementMember__c> result = [SELECT Id, PTF_EndDate__c, PTF_EndDate_DT__c
        FROM NDGManagementMember__c WHERE id IN : idDPList ];

        for(NDGManagementMember__c member : result){
            member.PTF_EndDate__c = Date.today();
            member.PTF_EndDate_DT__c = Datetime.now();
        }
        if(result.size()>0){
            update result;
        }
        

        Id recTypeId = SV_Utilities.getRecordTypeByDeveloperName('NDGManagementMember__c', 'DoppioPresidioEstero');
        List<NDGManagementMember__c> newResult= [SELECT PTF_Gestore__c, PTF_Gestore__r.Name, PTF_Gestore__r.Email, PTF_Gestore__r.PTF_RegistrationNumber__c, 
                                                 PTF_Gestore__r.PTF_TipologiaRuolo__r.Name, PTF_Gestore__r.PTF_UnitaOrganizzativa__c
        FROM NDGManagementMember__c WHERE RecordTypeId=:recTypeId AND PTF_NDG__c=:recordId AND PTF_EndDate__c=NULL AND PTF_Gestore__r.PTF_TipologiaRuolo__r.PTF_Code__c IN ('990','991')];

        return newResult;

    }
}