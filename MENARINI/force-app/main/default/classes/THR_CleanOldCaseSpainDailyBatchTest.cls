@IsTest
public with sharing class THR_CleanOldCaseSpainDailyBatchTest {
    private static final String REGULATORY = 'THR_Regulatory_es';
    private static final String QUALITY = 'THR_Quality_es';
    private static final String MEDICAL = 'THR_Medical_and_Pharmacovigilance_ES';
    private static final String PHARMA = 'THR_Pharmacovigilance';
    private static final String CLAIM = 'THR_ClaimEs';
    private static final String FINANCE = 'THR_Finance_es';
    private static final String TRADE = 'THR_Trade_es';
    private static final String LOGISTIC = 'THR_Logistic_ES';
    private static final Integer CONTACT_NUMBER = 10;

    @TestSetup
    public static void setup() {
        Map<String, SObject> accCont = THR_TestDataFactory.createGenericPatientAndContactSpain();
        Account genericPatient = (Account) accCont.get('Account');
        Contact deleteContact = (Contact) accCont.get('Contact');
        List<Contact> contactList = THR_TestDataFactory.createNContactSpain(genericPatient.Id, CONTACT_NUMBER);
        Map<Id, THR_FakeContact__c> oldConId_FakeCon = new Map<Id, THR_FakeContact__c>();
        for(Contact con : contactList) {
            oldConId_FakeCon.put(con.Id, THR_Spain_Utils.newFakeContact(con));
            con = THR_Spain_Utils.hideContactInfo(con);
        }
        List<Case> caseList = new List<Case>();

        for(Integer i = 0; i < CONTACT_NUMBER; i++) {
            if(i==1) {
                caseList.add(THR_TestDataFactory.createSpainCaseForBatch(REGULATORY, genericPatient.Id, deleteContact.Id));
            } else if(i==2) {
                caseList.add(THR_TestDataFactory.createSpainCaseForBatch(QUALITY, genericPatient.Id, deleteContact.Id));
            } else if(i==3) {
                caseList.add(THR_TestDataFactory.createSpainCaseForBatch(MEDICAL, genericPatient.Id, deleteContact.Id));
            } else if(i==4) {
                caseList.add(THR_TestDataFactory.createSpainCaseForBatch(PHARMA, genericPatient.Id, deleteContact.Id));
            } else if(i==5) {
                caseList.add(THR_TestDataFactory.createSpainCaseForBatch(FINANCE, genericPatient.Id, deleteContact.Id));
            } else if(i==6) {
                caseList.add(THR_TestDataFactory.createSpainCaseForBatch(TRADE, genericPatient.Id, deleteContact.Id));
            } else if(i==7) {
                caseList.add(THR_TestDataFactory.createSpainCaseForBatch(LOGISTIC, genericPatient.Id, deleteContact.Id));
            } else {
                caseList.add(THR_TestDataFactory.createSpainCaseForBatch(CLAIM, genericPatient.Id, deleteContact.Id));
            }
        }
        insert oldConId_FakeCon.values();
        for(Integer i=0;i<caseList.size(); i++) {
            caseList[i].THR_Contact__c = oldConId_FakeCon.values()[i].Id;
        }
        update caseList;
        update contactList;
    }

    @IsTest
    static void DeletedContactsGenericPatientTest() {
        Id genericPatientID = [SELECT Id FROM Account WHERE Name = 'PACIENTE GENERICO'].Id;
        Integer caseListSize = [SELECT Id, AccountId, LastModifiedDate, THR_Locked__c, THR_Locked_Date__c, THR_Country__c, ContactId, ContactEmail, ContactPhone, ContactMobile FROM Case WHERE THR_Country__c = 'ES' AND AccountId =: genericPatientID].size();

        Test.startTest();
        Database.executeBatch(new THR_CleanOldCaseSpainDailyBatch());
        Test.stopTest();

        List<Case> caseList = [SELECT Id, AccountId, LastModifiedDate, THR_Locked__c, THR_Locked_Date__c, THR_Country__c, ContactId, ContactEmail, ContactPhone, ContactMobile FROM Case WHERE THR_Country__c = 'ES' AND AccountId =: genericPatientID];
        List<Contact> hiddenContactList = [SELECT Id, Name, LastName, FirstName, MailingStreet, Phone, MobilePhone, THR_Country__c, Email, AccountId FROM Contact WHERE THR_Country__c = 'ES' AND LastName = 'Eliminado'];
        List<THR_FakeContact__c> fakeContactList = [SELECT Id FROM THR_FakeContact__c];

        for(Contact con : hiddenContactList) {
//            System.debug('### Contact ID: "' +con.Id+'", Name: "' + con.Name + '"');
        }
        System.assert(caseList.size()==caseListSize, 'All Generic Patient related cases are not been deleted');
        System.assert(hiddenContactList.size()==0, 'All Contacts that were related to cases are been deleted');
        System.assert(fakeContactList.size()==0, 'All Fake Contact that were related to cases are been deleted');
    }
}