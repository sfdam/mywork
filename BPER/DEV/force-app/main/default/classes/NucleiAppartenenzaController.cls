/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 09-03-2020
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
 * Modifications Log 
 * Ver   Date         Author                               Modification
 * 1.0   09-03-2020   ChangeMeIn@UserSettingsUnder.SFDoc   Initial Version
**/
public without sharing class NucleiAppartenenzaController {
    @AuraEnabled
    public static Map<String, Object> getNDG(Id recordId) {
        Account acc = null;
        Wallet__c portafoglio = null;
        Assignment__c primario = null;
        try {
            acc = [
                SELECT  Id,
                        Name,
                        PTF_Nucleo__c,
                        PTF_Caponucleo__c,
                        PTF_Portafoglio__c,
                        ModelloDiServizio__c
                FROM Account
                WHERE Id =:recordId
            ];
            if(!String.isBlank(acc.PTF_Portafoglio__c)){

                portafoglio = [SELECT id, (SELECT id, PTF_Gestore__c, PTF_Gestore__r.PTF_User__c  FROM Backup_Assignments__r WHERE RecordType.DeveloperName = 'Primario' AND PTF_EndDate__c = null) FROM Wallet__c WHERE id =: acc.PTF_Portafoglio__c];
                if(!portafoglio.Backup_Assignments__r.isEmpty()){

                    primario = portafoglio.Backup_Assignments__r[0];
                }
            }
        }
        catch(Exception exc) {
            throw new AuraHandledException(exc.getMessage());
        }
        return new Map<String, Object>{
            'account' => acc,
            'portafoglio' => portafoglio,
            'primario' => primario
        };
    }

    @AuraEnabled
    public static List<Account> getNDGAppartenenza(Id nucleoId,id currentAccountId) {
        List<Account> accs = null;
        list<Account> filteredAccs = new list<Account>();
        try {
            accs = [
                SELECT  Id,
                        Name,
                        PTF_Nucleo__c,
                        PTF_Caponucleo__c,
                        CRM_NDG__c,
                        PTF_NaturaGiuridica__c,
                        PTF_GruppoComportamentale__c,
                        PTF_OFS__c,
                        ModelloDiServizio__c,
                        PTF_Portafoglio__c

                FROM Account
                WHERE PTF_Nucleo__c =:nucleoId
                ORDER BY PTF_Caponucleo__c DESC
            ];

            for(Account a : accs){
                if(a.id != currentAccountId){
                    if(a.PTF_Portafoglio__c != null && a.ModelloDiServizio__c != 'Residuale'){
                        filteredAccs.add(a);
                    }
                }
                else{
                    filteredAccs.add(a);
                }
            }
        }
        catch(Exception exc) {
            throw new AuraHandledException(exc.getMessage());
        }
        return (filteredAccs!=null && filteredAccs.size()>0 ? filteredAccs : new List<Account>());
    }

    @AuraEnabled
    public static Map<String,Object> loadNdgList( String nucleoId, String primarioId, String accountMDS, String portafoglioId, Integer offset, Integer pagesize, string nome, string cognome,  string ndg){
        SYstem.debug('SV loadNdgList nucleoId: ' + nucleoId);
        SYstem.debug('SV loadNdgList primarioId: ' + primarioId);
        SYstem.debug('SV loadNdgList accountMDS: ' + accountMDS);
        SYstem.debug('SV loadNdgList portafoglioId: ' + portafoglioId);
        SYstem.debug('SV loadNdgList offset: ' + offset);
        SYstem.debug('SV loadNdgList nome cognome  ndg: ' + nome + ' ' + cognome + ' '  + ndg);

        String searchedName =  nome ; 
        String searchedCognome =  cognome ;
        String searchedNDG =  ndg ;
        String countQuery = '';
        String query = '';
        String userId = UserInfo.getUserId();
        List<String> condiionList = new List<String>();
        //check if cognome filter is activated
        //filter on Name is always set because nome field is required for Accounts

        countQuery = 'SELECT count() ' + 
                'FROM Account WHERE PTF_Nucleo__c !=: nucleoId AND ModelloDiServizio__c =: accountMDS AND PTF_Portafoglio__c IN (SELECT PTF_MicroWallet__c FROM Assignment__c WHERE PTF_Gestore__c =: primarioId AND RecordType.DeveloperName = \'Primario\' AND PTF_EndDate__c = null) AND (RecordType.DeveloperName = \'PersonAccount\' OR RecordType.DeveloperName = \'Cointestazione\')';

        query = 'SELECT Id, PTF_Nucleo__c, Filiale__c, PTF_Caponucleo__c, CRM_NDG__c, Name, PTF_Filiale__c, PTF_Filiale__r.Name, ModelloDiServizio__c, PTF_Portafoglio__c, PTF_Portafoglio__r.Name, PTF_NaturaGiuridica__c ' +
                'FROM Account WHERE PTF_Nucleo__c !=: nucleoId AND ModelloDiServizio__c =: accountMDS AND PTF_Portafoglio__c IN (SELECT PTF_MicroWallet__c FROM Assignment__c WHERE PTF_Gestore__c =: primarioId AND RecordType.DeveloperName = \'Primario\' AND PTF_EndDate__c = null) AND (RecordType.DeveloperName = \'PersonAccount\' OR RecordType.DeveloperName = \'Cointestazione\')';

        if(!String.isBlank(nome)){

            condiionList.add(' FirstName =: searchedName ');
        }
        if(!String.isBlank(cognome)){

            condiionList.add(' LastName =: searchedCognome ');
        }
        
        if(!String.isBlank(ndg)){

            condiionList.add(' CRM_NDG__c =: searchedNDG ');
        }

        if(!condiionList.isEmpty()){

            countQuery += ' AND ' + String.join(condiionList, ' AND ');
            query += ' AND ' + String.join(condiionList, ' AND ');
        }
        query += ' ORDER BY CRM_Nome__c ASC LIMIT: pagesize OFFSET: offset';

        return new Map<String, Object>{
            'ndgListCount' => Database.countQuery(countQuery),
            'ndgList' => Database.query(query)
        };
    }

    @AuraEnabled
    public static Map<String, Object> crm_GetNDG(Id recordId) {
        Account acc = null;
        Wallet__c portafoglio = null;
        Assignment__c primario = null;
        try {
            acc = [
                SELECT  Id,
                        Name,
                        PTF_Nucleo__c,
                        PTF_Caponucleo__c,
                        PTF_Portafoglio__c,
                        ModelloDiServizio__c,
                        CRM_CrossSelling__c, CRM_MargineIntermediazione__c, CRM_ProdottoBancarioLordo__c,
                        PTF_StatoCRMFull__c
                FROM Account
                WHERE Id =:recordId
            ];
            if(!String.isBlank(acc.PTF_Portafoglio__c)){

                portafoglio = [SELECT id, (SELECT id, PTF_Gestore__c, PTF_Gestore__r.PTF_User__c  FROM Backup_Assignments__r WHERE RecordType.DeveloperName = 'Primario' AND PTF_EndDate__c = null) FROM Wallet__c WHERE id =: acc.PTF_Portafoglio__c];
                if(!portafoglio.Backup_Assignments__r.isEmpty()){

                    primario = portafoglio.Backup_Assignments__r[0];
                }
            }
        }
        catch(Exception exc) {
            throw new AuraHandledException(exc.getMessage());
        }
        return new Map<String, Object>{
            'account' => acc,
            'portafoglio' => portafoglio,
            'primario' => primario
        };
    }

    @AuraEnabled
    public static List<Account> crm_GetNDGAppartenenza(Id nucleoId,id currentAccountId) {
        List<Account> accs = null;
        list<Account> filteredAccs = new list<Account>();
        try {
            //MARCELLO SPADACCINI - AGGIUNTO CHECK SU USER "Consulenti Finanziari" 
        	User currentUser = [SELECT Id, ProfileId, Profile.Name FROM User WHERE Id = :UserInfo.getUserId()];
            if (currentUser.Profile.Name == 'CRM - Consulenti Finanziari')
            {
            accs = [
                SELECT  Id,
                        Name,
                        PTF_Nucleo__c,
                        PTF_Caponucleo__c,
                        CRM_NDG__c,
                        PTF_NaturaGiuridica__c,
                        PTF_GruppoComportamentale__c,
                        PTF_OFS__c,
                        ModelloDiServizio__c,
                        PTF_Portafoglio__c,
                        CRM_CrossSelling__c, CRM_MargineIntermediazione__c, CRM_ProdottoBancarioLordo__c,
                        PTF_StatoCRMFull__c
                FROM Account
               WHERE PTF_Nucleo__c =:nucleoId AND User_Is_Referente_Portafoglio__c = TRUE
               ORDER BY PTF_Caponucleo__c DESC
            ];
            }
            else
            {
			accs = [
                SELECT  Id,
                        Name,
                        PTF_Nucleo__c,
                        PTF_Caponucleo__c,
                        CRM_NDG__c,
                        PTF_NaturaGiuridica__c,
                        PTF_GruppoComportamentale__c,
                        PTF_OFS__c,
                        ModelloDiServizio__c,
                        PTF_Portafoglio__c,
                        CRM_CrossSelling__c, CRM_MargineIntermediazione__c, CRM_ProdottoBancarioLordo__c,
                        PTF_StatoCRMFull__c
                FROM Account
                WHERE PTF_Nucleo__c =:nucleoId
                ORDER BY PTF_Caponucleo__c DESC
            ];
            }
            for(Account a : accs){
                if(a.id != currentAccountId){
                    if(a.PTF_Portafoglio__c != null && a.ModelloDiServizio__c != 'Residuale'){
                        filteredAccs.add(a);
                    }
                }
                else{
                    filteredAccs.add(a);
                }
            }
        }
        catch(Exception exc) {
            throw new AuraHandledException(exc.getMessage());
        }
        return (filteredAccs!=null && filteredAccs.size()>0 ? filteredAccs : new List<Account>());
    }

    @AuraEnabled
    public static Map<String,Object> crm_LoadNdgList( String nucleoId, String primarioId, String accountMDS, String portafoglioId, Integer offset, Integer pagesize, string nome, string cognome,  string ndg){
        SYstem.debug('SV loadNdgList nucleoId: ' + nucleoId);
        SYstem.debug('SV loadNdgList primarioId: ' + primarioId);
        SYstem.debug('SV loadNdgList accountMDS: ' + accountMDS);
        SYstem.debug('SV loadNdgList portafoglioId: ' + portafoglioId);
        SYstem.debug('SV loadNdgList offset: ' + offset);
        SYstem.debug('SV loadNdgList nome cognome  ndg: ' + nome + ' ' + cognome + ' '  + ndg);

        String searchedName =  nome ; 
        String searchedCognome =  cognome ;
        String searchedNDG =  ndg ;
        String countQuery = '';
        String query = '';
        String userId = UserInfo.getUserId();
        List<String> condiionList = new List<String>();
        //check if cognome filter is activated
        //filter on Name is always set because nome field is required for Accounts

        countQuery = 'SELECT count() ' + 
                'FROM Account WHERE PTF_Nucleo__c !=: nucleoId AND ModelloDiServizio__c =: accountMDS AND PTF_Portafoglio__c IN (SELECT PTF_MicroWallet__c FROM Assignment__c WHERE PTF_Gestore__c =: primarioId AND RecordType.DeveloperName = \'Primario\' AND PTF_EndDate__c = null) AND (RecordType.DeveloperName = \'PersonAccount\' OR RecordType.DeveloperName = \'Cointestazione\')';

        query = 'SELECT Id, CRM_CrossSelling__c, CRM_MargineIntermediazione__c, CRM_ProdottoBancarioLordo__c, PTF_StatoCRMFull__c, PTF_Nucleo__c, Filiale__c, PTF_Caponucleo__c, CRM_NDG__c, Name, PTF_Filiale__c, PTF_Filiale__r.Name, ModelloDiServizio__c, PTF_Portafoglio__c, PTF_Portafoglio__r.Name, PTF_NaturaGiuridica__c ' +
                'FROM Account WHERE PTF_Nucleo__c !=: nucleoId AND ModelloDiServizio__c =: accountMDS AND PTF_Portafoglio__c IN (SELECT PTF_MicroWallet__c FROM Assignment__c WHERE PTF_Gestore__c =: primarioId AND RecordType.DeveloperName = \'Primario\' AND PTF_EndDate__c = null) AND (RecordType.DeveloperName = \'PersonAccount\' OR RecordType.DeveloperName = \'Cointestazione\')';

        if(!String.isBlank(nome)){

            condiionList.add(' FirstName =: searchedName ');
        }
        if(!String.isBlank(cognome)){

            condiionList.add(' LastName =: searchedCognome ');
        }
        
        if(!String.isBlank(ndg)){

            condiionList.add(' CRM_NDG__c =: searchedNDG ');
        }

        if(!condiionList.isEmpty()){

            countQuery += ' AND ' + String.join(condiionList, ' AND ');
            query += ' AND ' + String.join(condiionList, ' AND ');
        }
        query += ' ORDER BY CRM_Nome__c ASC LIMIT: pagesize OFFSET: offset';

        return new Map<String, Object>{
            'ndgListCount' => Database.countQuery(countQuery),
            'ndgList' => Database.query(query)
        };
    }

    @AuraEnabled
    public static void assignToNucleo(String nucleoId, List<String> accountIdList){

        List<Account> accountToUpdateList = new List<Account>();
        for(String accountId: accountIdList){

            accountToUpdateList.add(new Account(Id= accountId, PTF_Nucleo__c = nucleoId, PTF_Caponucleo__c = false));
        }

        update accountToUpdateList;
    }
}