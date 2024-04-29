public class THR_LockCaseSpainDailyBatch implements Database.Batchable<SObject>, Database.Stateful {
    private static final String QUERY = '' +
            'SELECT Id, LastModifiedDate, THR_Locked__c, THR_Locked_Date__c, THR_Country__c, ContactId, ContactEmail, ContactPhone, ContactMobile ' +
            'FROM Case ' +
            'WHERE THR_Country__c = \'ES\' AND LastModifiedDate <= LAST_N_DAYS:366 AND THR_Locked__c = False AND (Account.Name = \'PACIENTE GENERICO\' OR Account.Name = \'Personal Sanitario\' OR Account.Name = \'Médico\')';
    private static final String QUERY_TEST = '' +
            'SELECT Id, LastModifiedDate, THR_Locked__c, THR_Locked_Date__c, THR_Country__c, ContactId, ContactEmail, ContactPhone, ContactMobile ' +
            'FROM Case ' +
            'WHERE THR_Country__c = \'ES\' AND THR_Locked__c = False AND (Account.Name = \'PACIENTE GENERICO\' OR Account.Name = \'Personal Sanitario\' OR Account.Name = \'Médico\')';

    public Database.QueryLocator start(Database.BatchableContext BC){
//        System.debug('### THR_LockCaseSpainDailyBatch START ###');
        if(!Test.isRunningTest()) {
            return Database.getQueryLocator(QUERY);
        } else {
            return Database.getQueryLocator(QUERY_TEST);
        }
    }

    public void execute(Database.BatchableContext BC, List<Case> scope){
//        System.debug('### THR_LockCaseSpainDailyBatch EXECUTE ###');
        List<String> lstFieldNames = new List<String>(Contact.SObjectType.getDescribe().fields.getMap().keySet());
        //Id deletedContactId = [SELECT Id FROM Contact WHERE LastName = 'Bloqueado' LIMIT 1].Id;
        Set<Id> contactIds = new Set<Id>();
        String contactQuery = 'SELECT ' + String.join(lstFieldNames, ',') + ' FROM Contact WHERE Id IN :contactIds';
        Map<Id, THR_FakeContact__c> oldConId_FakeCon = new Map<Id, THR_FakeContact__c>();

        for (Case c : scope) {
            contactIds.add(c.ContactId);
//            System.debug('### Case trovato: '+ c);
            if(Test.isRunningTest()) {
                c = executeInTestMode(c);
            }
        }
        List<Contact> contactList = Database.query(contactQuery);

        //crea un oggetto fakeContact e "sbianca" le informazioni del contatto
        for(Contact con : contactList) {
            oldConId_FakeCon.put(con.Id, THR_Spain_Utils.newFakeContact(con));
            con = THR_Spain_Utils.hideContactInfo(con);

        }
        insert oldConId_FakeCon.values(); //inserisce i nuovi contatti fake

        for(Case c : scope) {
            THR_FakeContact__c fakeContact = oldConId_FakeCon.get(c.ContactId);
            //aggiorna il Case con l'Id del fakeContact
            c.THR_Contact__c = fakeContact.Id;
            //assegna l'Id di "Contacto Bloqueado" al ContactId del Case
            //c.ContactId = deletedContactId;
            c.THR_Locked__c = true;
            c.THR_Locked_Date__c = Datetime.now();
        }
        update contactList;
        update scope;
//        System.debug('### THR_LockCaseSpainDailyBatch EXITING ###');
    }

    public void finish(Database.BatchableContext BC){
        AsyncApexJob job = [SELECT Id, Status, NumberOfErrors,JobItemsProcessed,TotalJobItems FROM AsyncApexJob WHERE Id = :BC.getJobId()];
//        System.debug('JobInfo: ' + job);
//        System.debug('### THR_LockCaseSpainDailyBatch END ###');
    }

    @TestVisible
    private static Case executeInTestMode(Case c) {
        String caseJSON = JSON.serialize(c);
        caseJSON = caseJSON.substring(0,caseJSON.lastIndexOf('}'));
        Date dt = Date.today().addDays(-370);
        Time tm = Time.newInstance(9,0,0,0);
        Datetime newDate = Datetime.newInstance(dt, tm);
        String dateJSON = JSON.serialize(newDate);
        caseJSON += ',"LastModifiedDate":' + dateJSON + ',"CreatedDate":' + dateJSON + '}';
        Case newCase = (Case) JSON.deserialize(caseJSON, Case.class);
        return newCase;
    }
}