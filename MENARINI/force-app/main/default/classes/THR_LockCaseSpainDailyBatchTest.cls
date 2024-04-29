@IsTest
public with sharing class THR_LockCaseSpainDailyBatchTest {

    private static final String REGULATORY = 'THR_Regulatory_es';
    private static final String QUALITY = 'THR_Quality_es';
    private static final String MEDICAL = 'THR_Medical_and_Pharmacovigilance_ES';
    private static final String PHARMA = 'THR_Pharmacovigilance';
    private static final String CLAIM = 'THR_ClaimEs';
    private static final String FINANCE = 'THR_Finance_es';
    private static final String TRADE = 'THR_Trade_es';
    private static final String LOGISTIC = 'THR_Logistic_ES';
    private static final Integer CONTACT_NUMBER = 5;

    @TestSetup
    public static void setup() {
        Map<String, SObject> accCont = THR_TestDataFactory.createGenericPatientAndContactSpain();
        Account genericPatient = (Account) accCont.get('Account');
        Account simpleAcc = THR_TestDataFactory.CreateSingleCompleteAccount('Spain', '111111C');

        for (Contact c : THR_TestDataFactory.createNContactSpain(genericPatient.Id, CONTACT_NUMBER)) {
            THR_TestDataFactory.createSpainCaseForBatch(LOGISTIC, genericPatient.Id, c.Id);
        }
        for (Contact c : THR_TestDataFactory.createNContactSpain(simpleAcc.Id, CONTACT_NUMBER)) {
            THR_TestDataFactory.createSpainCaseForBatch(PHARMA, simpleAcc.Id, c.Id);
        }
    }

    @IsTest
    static void casesOlderThanAYearTest() {

        Test.startTest();
        Database.executeBatch(new THR_LockCaseSpainDailyBatch());
        Test.stopTest();

        List<Case> caseList = [SELECT Id, AccountId, LastModifiedDate, THR_Locked__c, THR_Contact__c, THR_Locked_Date__c, THR_Country__c, ContactId, ContactEmail, ContactPhone, ContactMobile FROM Case WHERE THR_Country__c = 'ES'];
        List<Contact> hiddenContactList = [SELECT Id, Name, LastName, FirstName, MailingStreet, Phone, MobilePhone, THR_Country__c, Email, AccountId FROM Contact WHERE THR_Country__c = 'ES' AND LastName = 'Bloqueado'];
        List<THR_FakeContact__c> newFakeContact = [SELECT Id FROM THR_FakeContact__c];
        Id genericPatientID = [SELECT Id FROM Account WHERE Name = 'PACIENTE GENERICO'].Id;

        for (Case c : caseList) {
            if(c.AccountId == genericPatientID) {
                System.assert(c.THR_Locked__c == true);
                System.assert(c.THR_Locked_Date__c.date() == Date.today());
            }
        }
        System.assert(newFakeContact.size() == CONTACT_NUMBER);
        System.assert(hiddenContactList.size() == CONTACT_NUMBER);

    }



}