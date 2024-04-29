@isTest
public class OpportunityErogazioniaSALValTriggerTest {
    
  @isTest
  static void TestEditOneOpportunity() {
    // Test data setup
    // Create an account with an opportunity, and then try to delete it
    Account acct = new Account(Name='Test Account');
    insert acct;
    Opportunity opp = new Opportunity(
      Name=acct.Name + ' Opportunity',
      StageName='In erogazione',
      RecordTypeId =Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Opportunita_Magazzino_Finanziamenti').getRecordTypeId(),
      CloseDate=System.today().addMonths(1),
      CRM_Erogazione_a_SAL__c = true,
      AccountId=acct.Id);
    insert opp;
    /*Forecast_Erogazioni__c forecastRecord = new Forecast_Erogazioni__c(CRM_Opportunity__c=opp.id, CRM_Importo__c =100);
    insert forecastRecord;*/
      system.debug('opt: '+opp);
    // Perform test
    Test.startTest();
      opp.StageName='Chiusa';
      Database.SaveResult result = Database.update(opp, false);
    Test.stopTest();
    // Verify
    // In this case the deletion should have been stopped by the trigger,
    // so verify that we got back an error.
    System.assert(!result.isSuccess());
    System.assert(result.getErrors().size() > 0);
  }

}