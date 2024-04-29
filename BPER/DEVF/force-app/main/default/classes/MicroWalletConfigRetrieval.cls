global class MicroWalletConfigRetrieval {
    @AuraEnabled
    public static MicroWrapper getMicroConfigs() {
        return new MicroWrapper(getAllFiliali(), getAllModelli());
    }
    
    @AuraEnabled
    public static List<String> getAllFiliali() {
        List<String> filiali = new List<String>();
        /*SObjectField picklistUsingGlobal = Wallet__c.Wallet__c.fields.PTF_Filiale__c;
        List<PicklistEntry> entries = picklistUsingGlobal.getDescribe().getPicklistValues();
        List<String> filialiNames = new List<String>();
        for (PicklistEntry pe : entries) filialiNames.add(pe.getValue());
        return filialiNames;*/
        return null;
    }

    @AuraEnabled
    public static List<String> getListBanche() {
        List<String> names = new List<String>();
        List<Account> accs = [SELECT Id, Name FROM Account WHERE RecordType.Name = 'Banca'];
        for (Account  acc : accs) names.add(acc.Name);
        return names;
    }

    @AuraEnabled
    public static List<String> getListDR(String nomeBanca) {
        List<String> names = new List<String>();
        List<Account> accs = [SELECT Id, Name FROM Account WHERE RecordType.Name = 'Direzione Regionale' AND Parent.Name = :nomeBanca];
        for (Account acc : accs) names.add(acc.Name);
        return names;
    }

    @AuraEnabled
    public static List<String> getListAree(String nomeDR) {
        List<String> names = new List<String>();
        List<Account> accs = [SELECT Id, Name FROM Account WHERE RecordType.Name = 'Area' AND Parent.Name = :nomeDR];
        for (Account acc : accs) names.add(acc.Name);
        return names;
    }

    @AuraEnabled
    public static List<String> getListFiliali(String nomeArea) {
        List<String> names = new List<String>();
        List<Account> accs = [SELECT Id, Name FROM Account WHERE RecordType.Name = 'Filiale di relazione' AND Parent.Name = :nomeArea];
        for (Account acc : accs) names.add(acc.Name);
        return names;
    }
    

    @AuraEnabled
    public static List<String> getAllModelli() {
        List<String> modelli = new List<String>();
        SObjectField picklistUsingGlobal = Wallet__c.Wallet__c.fields.PTF_ModelloDiServizio__c;
        List<PicklistEntry> entries = picklistUsingGlobal.getDescribe().getPicklistValues();
        List<String> modelliNames = new List<String>();
        for (PicklistEntry pe : entries) modelliNames.add(pe.getValue());
        return modelliNames;
    }

    @AuraEnabled
    public static List<GestoreWrapper> getGestoriByFilters(String params) {
        SearchUtils.SearchWrapper pw = (SearchUtils.SearchWrapper) JSON.deserialize(params, SearchUtils.SearchWrapper.Class);
        List<GestoreWrapper> gw = new List<GestoreWrapper>();
        List<User> users = [
            SELECT Id, FirstName, LastName, Filiale__c, ModelloDiServizio__c
            FROM User
            WHERE Filiale__c = :pw.filiale
            AND ModelloDiServizio__c  = :pw.modello
        ];
        for (User u : users) {
            gw.add(new GestoreWrapper(u.Id, u.FirstName, u.LastName));
        }
        return gw;
    }

    @AuraEnabled
    public static List<User> getGestoriPrincipali(SearchUtils.SearchWrapper pw) {
        List<GestoreWrapper> gw = new List<GestoreWrapper>();
        List<Id> usersToRemoveIds = new List<Id>();
        List<User> usersToReturn = new List<User>();
        List<Id> userIds = new List<Id>();
        List<User> users = [
            SELECT Id, FirstName, LastName, Filiale__c, ModelloDiServizio__c, PTF_RegistrationNumber__c
            FROM User
            WHERE Filiale__c = :pw.filiale
            AND ModelloDiServizio__c  = :pw.modello
        ];
        System.debug('users found = '+users);
        for (User u : users) userIds.add(u.Id);
        List<Wallet__c> mws = [SELECT Id, PTF_ModelloDiServizio__c, OwnerId FROM Wallet__c WHERE RecordType.Name = 'Micro-Portafoglio'];
        System.debug('mws found = '+mws);
        for (User u : users) {
            for (Wallet__c w : mws) {
                /*if (u.Id == w.OwnerId && u.Filiale__c == w.PTF_Filiale__c && u.ModelloDiServizio__c == w.PTF_ModelloDiServizio__c) {
                    usersToRemoveIds.add(u.Id);
                }*/
            }
        }
        System.debug('users to remove ids = '+usersToRemoveIds);
        for (User u : users) {
            if (!usersToRemoveIds.contains(u.Id)) {
                usersToReturn.add(u);
            }
        }
        return usersToReturn;
    }

    @AuraEnabled
    public static Gestori getGestori(String params) {
        SearchUtils.SearchWrapper pw = (SearchUtils.SearchWrapper) JSON.deserialize(params, SearchUtils.SearchWrapper.Class);
        System.debug('pw = '+pw);
        List<User> gestPrinc = getGestoriPrincipali(pw);
        List<Id> gpIds = new List<Id>();
        for (User u : gestPrinc) gpIds.add(u.Id);
        //List<Contact> gestoriBackup = SearchUtils.getGestoriBackup(pw);
        List<Contact> gestoriBackup = new List<Contact>();
        return new Gestori(gestPrinc, gestoriBackup);
    } 

    @AuraEnabled
    public static void createMicroWallet(String params) {
        List<Wallet__c> wallets = new List<Wallet__c>();
        MicroToCreateWrapper mtcw = (MicroToCreateWrapper) JSON.deserialize(params, MicroToCreateWrapper.Class);
        User unassigned = [SELECT Id FROM User WHERE Profile.Name = 'Amministratore di sistema'][0];
        Id microWalletRTId = [SELECT Id FROM RecordType WHERE Name = 'Micro-Portafoglio'][0].Id;
        Wallet__c mw = new Wallet__c();
        //mw.PTF_Filiale__c = mtcw.filiale;
        mw.PTF_ModelloDiServizio__c = mtcw.modello;
        mw.RecordTypeId = microWalletRTId;
        Integer numOfWallets = mtcw.numOfMWs;
        if (numOfWallets == 1) {
            if (mtcw.gestoreId == null) {
                // retrieve "Unassigned" user by profile name
                mw.OwnerId = unassigned.Id;
            } else mw.OwnerId = mtcw.gestoreId;
            wallets.add(mw);
        } else {
            Wallet__c tempWallet;
            for (Integer i = 0; i < numOfWallets; i++) {
                tempWallet = mw.clone(false, false, false, false);
                tempWallet.OwnerId = unassigned.Id;
                wallets.add(tempWallet);
            }
        }
        insert wallets;
        if (wallets.size() == 1) createBackupAssignments(wallets, mtcw.gbWrapper);
    }

    private static void createBackupAssignments(List<Wallet__c> wallets, List<String> contactIds) {
        List<Assignment__c> bas = new List<Assignment__c>();
        for (String contactId : contactIds) {
            for (Wallet__c wallet : wallets) {
                bas.add(new Assignment__c(PTF_Gestore__c=contactId,PTF_MicroWallet__c=wallet.Id));
            }
        }
        insert bas;
    }

    public class Gestori {
        @AuraEnabled
        public List<User> gestoriPrincipali;
        @AuraEnabled
        public List<Contact> gestoriBackup;
        public Gestori (List<User> gestoriPrincipali, List<Contact> gestoriBackup) {
            this.gestoriPrincipali = gestoriPrincipali;
            this.gestoriBackup = gestoriBackup;
        }
    }

    public class GestoreWrapper {
        @AuraEnabled
        public String id;
        @AuraEnabled
        public String firstName;
        @AuraEnabled
        public String lastName;
        public GestoreWrapper(String id, String firstName, String lastName) {
            this.id = id;
            this.firstName = firstName;
            this.lastName = lastName;
        }
    }

    public class MicroWrapper {
        @AuraEnabled
        public List<String> filiali;
        @AuraEnabled
        public List<String> modelli;
        public MicroWrapper(List<String> filiali, List<String> modelli) {
            this.filiali = filiali;
            this.modelli = modelli;
        }
    }

    public class MicroToCreateWrapper {
        public String filiale;
        public String modello;
        public String gestoreId;
        public Integer numOfMWs;
        public List<String> gbWrapper;
    }

    public class GBWrapper {
        public String gestoreId;
    }

    public class GestoriPrincipali {
        @InvocableVariable
        public List<User> gestoriPrincipali;
        public GestoriPrincipali(List<User> users) {
            this.gestoriPrincipali = users;
        }
    }

}