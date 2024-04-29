@isTest
public class OnSerTriggerHandlerTest {
    @TestSetup
    static void makeData(){
        TestUtils.SERcontext context = TestUtils.createSerContext();
        RecordType recordType = [SELECT Id FROM RecordType WHERE SObjectType = 'Account' AND DeveloperName = 'Account'];
        Account salvagniniAccountIta = new Account(
            Name = 'SALVAGNINI ITALIA S.P.A.',
            BillingCountryCode = 'IT',
            BillingStateCode = 'VI',
            BillingPostalCode = '36040',
            RecordTypeId = recordType.Id,
            Primary_Industry__c = 'Agricultural Technologies',
            Type = 'Branch',
            Ser_Branch__c = true
        );
        insert salvagniniAccountIta;

        Account salvagniniAccountAmerica = new Account(
            Name = 'SALVAGNINI AMERICA INC.',
            BillingCountryCode = 'US',
            BillingStateCode = 'MI',
            BillingPostalCode = 'MI',
            RecordTypeId = recordType.Id,
            Type = 'Customer',
            Ser_Branch__c = true
        );
        insert salvagniniAccountAmerica;


        SER_Routing__c routing = new SER_Routing__c(
            Product__c = context.product.Product__c,
            SER_Type__c = 'Task-Study',
            Application_Branch__c = context.applicationBranch.Id
        );
        insert routing;

        
    }

    @isTest 
    static void SerStatus(){
        SER__c ser = [SELECT Id,Status__c, Application_Branch__c FROM SER__c];
        id IdSalvagniniItalia= [SELECT Id FROM Account WHERE Name =:'SALVAGNINI ITALIA S.P.A.' LIMIT 1].id;
        system.debug('l\'account da associare come application Branch è '+  IdSalvagniniItalia);
        ser.Status__c = 'Draft';
        ser.Application_Branch__c=IdSalvagniniItalia;
        ser.Simulation__c =true;
        update ser;
       
    }

    @isTest
    static void testUpdate () {

        system.debug ('Vado in testUpdate');
        SER__c ser = [SELECT Id,Status__c,Application_Branch__c, Simulation__c  FROM SER__c];
        Account Acc =[Select id, name from Account where id=:ser.Application_Branch__c];
        Account SalvagniniIta = [SELECT Id , name FROM Account WHERE Name =:'SALVAGNINI ITALIA S.P.A.' LIMIT 1];
       
    Test.startTest();
       system.debug ('la SER che passa in Analysis e poi in progress ha Status '+ ser.Status__c + ' e app Branch '+ Acc.name + 'con Simulation '+ ser.Simulation__c);
       system.debug ('confronto ID '+ SalvagniniIta.id + ' name '+SalvagniniIta.Name+' l\'app Branch è '+ acc.id+ ' name '+Acc.Name);
       ser.Status__c = 'Analysis';
       update ser;

       
       ser.Status__c = 'In Progress';
       ser.Simulation__c =true;
       update ser;
       system.debug ('New Simulation Status  '+ ser.Simulation__c);
       ser.Status__c = 'Validated';
       update ser;
       Test.stopTest();  
    }
   
}