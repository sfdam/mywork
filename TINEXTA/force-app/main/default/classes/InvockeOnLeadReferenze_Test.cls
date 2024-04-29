@isTest(SeeAllData=true)
public class InvockeOnLeadReferenze_Test {

    @isTest static void testSuccess() {
               
        // try
        List<InvocableReferenzeLead.ActionRequest> arList = new List<InvocableReferenzeLead.ActionRequest>();
        InvocableReferenzeLead.ActionRequest arTest = new InvocableReferenzeLead.ActionRequest();

        Id rtId = [SELECT Id from RecordType where Name = 'Warrant' AND SObjectType = 'Lead' LIMIT 1].id;
        
        

                Lead Nuovo = new Lead(LastName = 'TestCompany',
                              FirstName = 'Test',
                              Company = 'TestCompany',
                              Partiva_Iva__c = '00000900000', 
                              Codice_Fiscale__c = '00000900000',
                              Societa_di_riferimento__c ='Warrant',
                              RecordTypeId = rtId);
        
        insert Nuovo;
        
        
        arTest.LeadObject= Nuovo;
        arTest.businessarea = 'FAA';
        arTest.societa='Warrant';
        arTest.statoreferenza='OK';
        arTest.Ruolo='Account';
        arTest.StatoLead='Nuovo Lead';
        arTest.Origine='Referenza';
        arList.add(arTest);
        
        Test.startTest();
        InvocableReferenzeLead.InsertReferenzaDuplicateRules(arList);
        Test.stopTest();
    }
    
    
    @isTest static void testFailure() {
       
              
        //Catch
        
        List<InvocableReferenzeLead.ActionRequest> accList = new List<InvocableReferenzeLead.ActionRequest>();
        InvocableReferenzeLead.ActionRequest accTest = new InvocableReferenzeLead.ActionRequest();
        

        Id rtId = [SELECT Id from RecordType where Name = 'Warrant' AND SObjectType = 'Lead' LIMIT 1].id;
        
        
         Lead dupl = new Lead(LastName = 'TestCompany',
                              FirstName = 'Test',
                              Company = 'TestCompany',
                              Partiva_Iva__c = '00000900000', 
                              Codice_Fiscale__c = '00000900000',
                              Societa_di_riferimento__c ='Warrant',
                              RecordTypeId = rtId);
        
        insert dupl;
        
         Lead Nuovo = new Lead(LastName = 'TestCompany',
                              FirstName = 'Test',
                              Company = 'TestCompany',
                              Partiva_Iva__c = '00000900000', 
                              Codice_Fiscale__c = '00000900000',
                              Societa_di_riferimento__c ='Warrant',
                              RecordTypeId = rtId);
        
        insert Nuovo;
                
        
        accTest.LeadObject= Nuovo;
        //accTest.basket = 'Nessuno';
        accList.add(accTest);

     
        
        Test.startTest();
        InvocableReferenzeLead.InsertReferenzaDuplicateRules(accList);
        Test.stopTest();
    }
    
}