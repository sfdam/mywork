@isTest(SeeAllData=true)
public class InvockeOnLeadWRTORIGINE_Test {

    @isTest static void testSuccess() {
               
        // try
        List<InvockeOnLeadWRTORIGINE.ActionRequest> arList = new List<InvockeOnLeadWRTORIGINE.ActionRequest>();
        InvockeOnLeadWRTORIGINE.ActionRequest arTest = new InvockeOnLeadWRTORIGINE.ActionRequest();

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
        arTest.basket = 'Mercato Potenziale';
        arList.add(arTest);
        
        Test.startTest();
        InvockeOnLeadWRTORIGINE.Origine_WRT(arList);
        Test.stopTest();
    }
    
    
    @isTest static void testFailure() {
       
              
        //Catch
        
        List<InvockeOnLeadWRTORIGINE.ActionRequest> accList = new List<InvockeOnLeadWRTORIGINE.ActionRequest>();
        InvockeOnLeadWRTORIGINE.ActionRequest accTest = new InvockeOnLeadWRTORIGINE.ActionRequest();
        

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
        InvockeOnLeadWRTORIGINE.Origine_WRT(accList);
        Test.stopTest();
    }
    
}