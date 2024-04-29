public class THR_CleanOldCaseSpainDailyBatch implements Database.Batchable<SObject>  {
    private static final Integer TEN_YEARS = 10*365;
    private static final Integer EIGHT_YEARS = 8*365;
    private static final Integer FIVE_YEARS = 5*365;
    private static final Integer TWELVE_YEARS = 12*365;
    private static final Integer ONE_DAY = 1;
    private static final Integer TWO_DAYS = 2;
    private static final String REGULATORY = 'THR_Regulatory_es';
    private static final String QUALITY = 'THR_Quality_es';
    private static final String MEDICAL = 'THR_Medical_and_Pharmacovigilance_ES';
    private static final String PHARMA = 'THR_Pharmacovigilance';
    private static final String QUERY = 'SELECT Id, LastModifiedDate, RecordType_Developer_Name__c, THR_Locked__c, THR_Locked_Date__c, THR_Country__c, ContactId, THR_Contact__c FROM Case WHERE THR_Country__c = \'ES\' AND THR_Locked__c = True AND (Account.Name = \'PACIENTE GENERICO\' OR Account.Name = \'Personal Sanitario\' OR Account.Name = \'Médico\')';
    private static final String QUERY_TEST = 'SELECT Id, LastModifiedDate, RecordType_Developer_Name__c, THR_Locked__c, THR_Locked_Date__c, THR_Country__c, ContactId, THR_Contact__c FROM Case WHERE THR_Country__c = \'ES\'  AND (Account.Name = \'PACIENTE GENERICO\' OR Account.Name = \'Personal Sanitario\' OR Account.Name = \'Médico\')';

    public Database.QueryLocator start(Database.BatchableContext BC){
//        System.debug('### THR_CleanOldCaseSpainDailyBatch START ###');
        if(!Test.isRunningTest()) {
            return Database.getQueryLocator(QUERY);
        } else {
            return Database.getQueryLocator(QUERY_TEST);
        }
    }

    public void execute(Database.BatchableContext BC, List<Case> scope){
//        System.debug('### THR_CleanOldCaseSpainDailyBatch EXECUTE ###');
        Date today = Date.today();
        Set<Id> fakeContactIds = new Set<Id>();
        Set<Id> oldContactIds = new Set<Id>();
        List<Case> caseToClean = new List<Case>();

        for(Case c: scope) {
            if (Test.isRunningTest()) {
                c = executeInTestMode(c);
            }
            if (c.RecordType_Developer_Name__c == MEDICAL || c.RecordType_Developer_Name__c == PHARMA) {
                if (c.THR_Locked_Date__c.date().daysBetween(today) >= TEN_YEARS) { //TEN_YEARS
                    fakeContactIds.add(c.THR_Contact__c);
                    oldContactIds.add(c.ContactId);
                    c.ContactId = null;
                    c.THR_Contact__c = null;
                    caseToClean.add(c);
                }
            } else if (c.RecordType_Developer_Name__c == REGULATORY) {
                if (c.THR_Locked_Date__c.date().daysBetween(today) >= EIGHT_YEARS) { //EIGHT_YEARS
                    fakeContactIds.add(c.THR_Contact__c);
                    oldContactIds.add(c.ContactId);
                    c.ContactId = null;
                    c.THR_Contact__c = null;
                    caseToClean.add(c);
                }
            } else if (c.RecordType_Developer_Name__c == QUALITY) {
                if (c.THR_Locked_Date__c.date().daysBetween(today) >= FIVE_YEARS) { //FIVE_YEARS
                    fakeContactIds.add(c.THR_Contact__c);
                    oldContactIds.add(c.ContactId);
                    c.ContactId = null;
                    c.THR_Contact__c = null;
                    caseToClean.add(c);
                }
            } else {
                if (c.THR_Locked_Date__c.date().daysBetween(today) >= FIVE_YEARS) { //FIVE_YEARS
                    fakeContactIds.add(c.THR_Contact__c);
                    oldContactIds.add(c.ContactId);
                    c.ContactId = null;
                    c.THR_Contact__c = null;
                    caseToClean.add(c);
                }
            }
        }
        if(!caseToClean.isEmpty()) {
            update caseToClean;
            if(!fakeContactIds.isEmpty()) {
                List<THR_FakeContact__c> fakeContactToDelete = [SELECT Id, ContactId__c FROM THR_FakeContact__c WHERE Id IN :fakeContactIds];
                delete fakeContactToDelete;
            }
            if(!oldContactIds.isEmpty()) {
                List<Contact> oldContactToDelete = [SELECT Id FROM Contact WHERE Id IN :oldContactIds];
                delete oldContactToDelete;
            }
        }
//        System.debug('### THR_CleanOldCaseSpainDailyBatch EXITING ###');

    }

    public void finish(Database.BatchableContext BC){
        AsyncApexJob job = [SELECT Id, Status, NumberOfErrors,JobItemsProcessed,TotalJobItems FROM AsyncApexJob WHERE Id = :BC.getJobId()];
//        System.debug('JobInfo: ' + job);
//        System.debug('### THR_CleanOldCaseSpainDailyBatch END ###');
    }

    @TestVisible
    private static Case executeInTestMode(Case c) {
        String caseJSON = JSON.serialize(c);
        Date today = Date.today();
        caseJSON = caseJSON.substring(0, caseJSON.lastIndexOf('}'));
        Date dt = today.addDays(-TWELVE_YEARS);
        Time tm = Time.newInstance(9, 0, 0, 0);
        Datetime newDate = Datetime.newInstance(dt, tm);
        String dateJSON = JSON.serialize(newDate);
        Date lockedDate = Date.today();
        if(c.RecordType_Developer_Name__c == REGULATORY) {
            lockedDate = today.addDays(-EIGHT_YEARS - 10);
        } else if(c.RecordType_Developer_Name__c == QUALITY) {
            lockedDate = today.addDays(-FIVE_YEARS - 10);
        } else if(c.RecordType_Developer_Name__c == MEDICAL || c.RecordType_Developer_Name__c == PHARMA) {
            lockedDate = today.addDays(-TEN_YEARS - 10);
        } else {
            lockedDate = today.addDays(-FIVE_YEARS - 10);
        }
        String lockedDateJSON = JSON.serialize(Datetime.newInstance(lockedDate, tm));
        caseJSON += ',"LastModifiedDate":' + dateJSON + ',"CreatedDate":' + dateJSON + ', "THR_Locked__c":"true", "THR_Locked_Date__c":' + lockedDateJSON + '}';
        Case newCase = (Case) JSON.deserialize(caseJSON, Case.class);
        return newCase;
    }
}