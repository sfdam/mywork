public class ManageGestoriCtrl {

    @AuraEnabled
    public static User getGestorePrincipale(String recordId) {
        Id ownId = [SELECT Id, OwnerId FROM Wallet__c WHERE Id = :recordId][0].OwnerId;
        return [
            SELECT Id, FirstName, LastName, Email, PTF_RegistrationNumber__c, Filiale__c, PTF_Ruolo__c, Profile.Name
            FROM User
            WHERE Id = :ownId
        ][0];
    }

    @AuraEnabled
    public static List<User> searchGestori(String params) {
        GestoriWrapper gw = (GestoriWrapper) JSON.deserialize(params, GestoriWrapper.Class);
        List<Id> acceptableGestori = getAcceptableGestori(gw.recordId);
        //String query = SearchUtils.getUsersSearchQueryFiltered(gw.nome, gw.cognome, gw.matricola, acceptableGestori);
        String query = '';
        List<User> users = (List<User>) Database.query(query);
        return users;
    }

    private static List<Id> getAcceptableGestori(String recordId) {
        Wallet__c wallet = [
            SELECT Id, PTF_ModelloDiServizio__c
            FROM Wallet__c
            WHERE Id = :recordId
        ][0];

        SearchUtils.SearchWrapper sw = new SearchUtils.SearchWrapper();
        //sw.filiale = wallet.PTF_Filiale__c;
        sw.modello = wallet.PTF_ModelloDiServizio__c;
        List<User> usersToReturn = MicroWalletConfigRetrieval.getGestoriPrincipali(sw);
        List<Id> userIds = new List<Id>();
        for (User u : usersToReturn) userIds.add(u.Id);
        return userIds;
    }

    @AuraEnabled
    public static void changeGestore(String params) {
        NewGestoreWrapper ngw = (NewGestoreWrapper) JSON.deserialize(params, NewGestoreWrapper.Class);
        Id newGestoreId;
        if (ngw.toUnassigned) {
            newGestoreId = [SELECT Id FROM User WHERE Profile.Name = 'TechnicalProfilePortafogliazione'][0].Id;
        } else {
            newGestoreId = ngw.gestoreId;
        }
        Wallet__c wallet = new Wallet__c(Id=ngw.recordId,OwnerId=newGestoreId);
        update wallet;
    }

    @AuraEnabled
    public static List<Contact> getGestoriBackup(String recordId) {
        //return SearchUtils.getGestoriBackupByWalletId(recordId);
        return null;
    }

    @AuraEnabled
    public static void deleteSelectedGestori(String params) {
        GestoriChangesWrapper gcw = (GestoriChangesWrapper) JSON.deserialize(params, GestoriChangesWrapper.Class);
        if (gcw.idsToDelete.size() > 0) {
            List<Assignment__c> bas = [
                SELECT Id
                FROM Assignment__c
                WHERE PTF_Gestore__c IN :gcw.idsToDelete
                AND PTF_MicroWallet__c = :gcw.recordId
            ];
            delete bas;
        }
    }
    
    @AuraEnabled
    public static void addNewGestoriBackup(String params) {
        GestoriChangesWrapper gcw = (GestoriChangesWrapper) JSON.deserialize(params, GestoriChangesWrapper.Class);

        if (gcw.idsToAdd.size() > 0) {
            List<Assignment__c> bas = new List<Assignment__c>();
            for (String idToAdd : gcw.idsToAdd) {
                bas.add(new Assignment__c(PTF_Gestore__c=idToAdd, PTF_MicroWallet__c=gcw.recordId));
            }
            insert bas;
        }
    }

    @AuraEnabled
    public static void saveChangesBackup(String params) {
        deleteSelectedGestori(params);
        addNewGestoriBackup(params);
    }

    @AuraEnabled
    public static List<Contact> searchGestoriBackup(String params) {
        //getContactsSearchQuery
        GestoriWrapper gw = (GestoriWrapper) JSON.deserialize(params, GestoriWrapper.Class);
        //String query = SearchUtils.getContactsSearchQuery(gw.nome, gw.cognome, gw.matricola);
        String query = '';
        List<Contact> contacts = (List<Contact>) Database.query(query);
        return contacts;
    }

    public class GestoriChangesWrapper {
        public String recordId;
        public List<String> idsToDelete;
        public List<String> idsToAdd;
    }

    public class NewGestoreWrapper {
        public String recordId;
        public Boolean toUnassigned;
        public String gestoreId;
    }

    public class GestoriWrapper {
        public String recordId;
        public String nome;
        public String cognome;
        public String matricola;
    }
}