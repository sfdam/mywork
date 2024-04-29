@IsTest
public with sharing class CRM_WS_Predial_Test {
    @TestSetup
    public static void setup(){

        Account acc=AllDataFactory.getAccount('01', 'PersonAccount');
        insert acc;
        Account ac=[SELECT PersonContactId FROM Account WHERE Id=: acc.Id];

        Profile profile = [SELECT id FROM Profile WHERE  Name =: Label.System_Administrator LIMIT 1];

        User titolare = AllDataFactory.getUser('14', profile.Id, 'CORPORATE');
        titolare.FederationIdentifier = '14';
        titolare.Profilo__c = 'NEC_F.1';
        insert titolare;

        String recordTypeTopDownMono = Schema.SObjectType.Campaign.getRecordTypeInfosByName().get('Top-Down - Monostep').getRecordTypeId();

        Account acct = new Account (Name = 'ACE Chemicals', ModelloDiServizio__c = 'Family', CRM_NDG__c = '112358',CRM_Privacy_1Level__c = 'Yes');
        insert acct;

        Contact cntct = new Contact();
        cntct.FirstName = 'Bruce';
        cntct.LastName = 'Wayne';
        cntct.AccountId = acct.Id;
        insert cntct;

        Campaign cmpgn = AllDataFactory.getCampaign('02', titolare.Id, recordTypeTopDownMono);
        cmpgn.CRM_NomeAttributo1__c =null;
        cmpgn.CRM_NomeAttributo2__c =null;
        cmpgn.CRM_TipologiaOutboundContactCenter__c ='Progressive';
        cmpgn.CRM_EsclusioneLivelloPrivacyMulti__c = 'Privacy Livello 1';
        insert cmpgn;

        CampaignMember cmpMember = new CampaignMember(Status = 'Da contattare');
        cmpMember.ContactId = cntct.id; 
        cmpMember.CampaignId = cmpgn.id;
        cmpMember.CRM_Assegnatario__c = UserInfo.getUserId();
        cmpMember.CRM_StatoAssegnazione__c = 'Assegnato';
        cmpMember.CRM_NumeroTentativi__c = 3;
        cmpMember.LastModifiedDate = Datetime.now().addMinutes(-60);
        cmpMember.CreatedDate = Datetime.now().addDays(-1);
        insert cmpMember;
    }

    @IsTest
    public static void retrieveIsContactable(){
        Test.startTest();
        CampaignMember cmpMember = [Select id from campaignMember limit 1];
        CRM_WS_Predial.retrieveIsContactable(cmpMember.Id);
        Test.stopTest();
        System.assertEquals(true, (CRM_WS_Predial.retrieveIsContactable(cmpMember.Id))!= null);
    }
}