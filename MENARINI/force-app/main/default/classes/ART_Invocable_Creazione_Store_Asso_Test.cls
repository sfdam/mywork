@isTest
public class ART_Invocable_Creazione_Store_Asso_Test {
    
	 @isTest
    public static void createCSATest(){
        
        cgcloud__Account_Template__c AT=new cgcloud__Account_Template__c();
        AT.name='Clienti Codifi';
        AT.cgcloud__Sales_Org__c='0001';
        insert AT;
    	account a=new Account();
        A.name='Test Account';
        A.ART_Pharma_Order__c=true;
        a.BillingStreet='Via imola';
        a.BillingCountry='Italy';
        a.BillingState='Milano';
        a.BillingCity='Milano';
        a.BillingPostalCode='10088';
        a.cgcloud__Account_Template__c=AT.id;
        insert a;
        cgcloud__Product_Assortment_Template__c PAT=new cgcloud__Product_Assortment_Template__c();
        PAT.name='Codifi Sales Document Assortment Template';
        PAT.cgcloud__Sales_Org__c='0001';
        PAT.cgcloud__Active__c=true;
        insert PAT;
        Assortment assor=new Assortment();
        Assor.Name='pharma';
        Assor.cgcloud__Product_Assortment_Template__c=PAT.Id;
        Assor.cgcloud__Valid_From__c=date.today();
        Assor.cgcloud__Valid_Thru__c=date.today();
        insert Assor;
		test.startTest();
        ART_Invocable_Creazione_Store_Assortment.Params PAr=new ART_Invocable_Creazione_Store_Assortment.Params();
        PAr.AccountId=a.id;
        PAr.Operation='Create';
        PAr.StartDate=date.today();
        PAr.AssortmentId=Assor.Id;
        list<ART_Invocable_Creazione_Store_Assortment.Params> ListPar=new list<ART_Invocable_Creazione_Store_Assortment.Params>();
		ListPar.add(PAr);     
        ART_Invocable_Creazione_Store_Assortment.CallFutureMethod(ListPar);
        listPar.remove(0);
        PAr.Operation='Delete';
        listPar.add(PAr);
        ART_Invocable_Creazione_Store_Assortment.CallFutureMethod(ListPar);
        test.stopTest();
    }
}