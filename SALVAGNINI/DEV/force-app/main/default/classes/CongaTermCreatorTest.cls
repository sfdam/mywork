@isTest
public with sharing class CongaTermCreatorTest {
    @isTest 
    static void TestCongaTerms(){
        Account acc1 = new Account(
            Name = 'TestAccount01',
            BillingCountry = 'Italy'
        );
        insert acc1;   

        Profile p = [SELECT Id FROM Profile WHERE Name='Sales Assistant']; 
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com',
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                          LocaleSidKey='en_US', ProfileId = p.Id, 
                          TimeZoneSidKey='America/Los_Angeles', UserName='accounttriggerSalvaTestMAt@test.com');
        insert u;

        Opportunity testOpp = new Opportunity(Name = 'TEST', AccountId = acc1.Id, StageName = 'Qualification', CloseDate = system.today(), Projectmanager__c=u.id);
        insert testOpp;

        Product2 p1 = new Product2(
            Name = 'Product1',
            Special_Base_List_Price__c =2,
            Special_List_Price__c =1,
            Installation_Price__c=1,
            Prog_Training_days__c=1,
            Mnt_Training_Days__c =1,
            Transport_Price__c=1,
            isActive = true
        );
        insert p1;
        
        Pricebook2 PB = new Pricebook2();
            PB.name='Test';
            PB.Markup__c=0.1;
         //PB.isStandard=true;
         insert PB; 

        Id pricebookIdstd = Test.getStandardPricebookId();
        
        Pricebook2 PBS = new Pricebook2(
        Id = pricebookIdstd,
        IsActive = true
        );
        update PBS;

        system.debug('@@@ IsStandard: '+ PB.IsStandard);

        //inserimento Quote
        SBQQ__Quote__c q1 = new SBQQ__Quote__c(
            //SBQQ__Status__c = 'Draft',
            SBQQ__QuoteLanguage__c = 'English',
            Quote_Secondary_Language__c ='Italian',
            SBQQ__Account__c = acc1.Id,
            Change_for_List_Area_Price__c= 3,
            SBQQ__PriceBook__c=PBS.id,
            Install_To_State__c='SBQQ__ListAmount__c',
            SBQQ__Opportunity2__c= testOpp.id
            );
            insert q1;

        SBQQ__Quote__c q2 = new SBQQ__Quote__c(
        //SBQQ__Status__c = 'Draft',
            SBQQ__QuoteLanguage__c = 'Italian',
            Quote_Secondary_Language__c ='English',
            SBQQ__Account__c = acc1.Id,
            Change_for_List_Area_Price__c= 3,
            SBQQ__PriceBook__c=PBS.id,
            Install_To_State__c='SBQQ__ListAmount__c',
            SBQQ__Opportunity2__c= testOpp.id
            );
            insert q2;

        SBQQ__Quote__c q3 = new SBQQ__Quote__c(
            //SBQQ__Status__c = 'Draft',
            SBQQ__QuoteLanguage__c = 'Spanish',
            Quote_Secondary_Language__c ='German',
            SBQQ__Account__c = acc1.Id,
            Change_for_List_Area_Price__c= 3,
            SBQQ__PriceBook__c=PBS.id,
            Install_To_State__c='SBQQ__ListAmount__c'
            );
            insert q3;

        SBQQ__Quote__c q4= new SBQQ__Quote__c(
        //SBQQ__Status__c = 'Draft',
        SBQQ__QuoteLanguage__c = 'German',
        Quote_Secondary_Language__c ='Spanish',
        SBQQ__Account__c = acc1.Id,
        Change_for_List_Area_Price__c= 3,
        SBQQ__PriceBook__c=PBS.id,
        Install_To_State__c='SBQQ__ListAmount__c'
        );
        insert q4;

        SBQQ__Quote__c q5= new SBQQ__Quote__c(
            //SBQQ__Status__c = 'Draft',
            SBQQ__QuoteLanguage__c = 'French',
            Quote_Secondary_Language__c ='Russian',
            SBQQ__Account__c = acc1.Id,
            Change_for_List_Area_Price__c= 3,
            SBQQ__PriceBook__c=PBS.id,
            Install_To_State__c='SBQQ__ListAmount__c'
            );
            insert q5;

        SBQQ__Quote__c q6= new SBQQ__Quote__c(
            //SBQQ__Status__c = 'Draft',
            SBQQ__QuoteLanguage__c = 'Russian',
            Quote_Secondary_Language__c ='French',
            SBQQ__Account__c = acc1.Id,
            Change_for_List_Area_Price__c= 3,
            SBQQ__PriceBook__c=PBS.id,
            Install_To_State__c='SBQQ__ListAmount__c'
            );
            insert q6;

        SBQQ__Quote__c q7= new SBQQ__Quote__c(
            //SBQQ__Status__c = 'Draft',
            SBQQ__QuoteLanguage__c = 'Chinese',
            Quote_Secondary_Language__c ='Polish',
            SBQQ__Account__c = acc1.Id,
            Change_for_List_Area_Price__c= 3,
            SBQQ__PriceBook__c=PBS.id,
            Install_To_State__c='SBQQ__ListAmount__c'
            );
            insert q7;

        SBQQ__Quote__c q8= new SBQQ__Quote__c(
            //SBQQ__Status__c = 'Draft',
            SBQQ__QuoteLanguage__c = 'Polish',
            Quote_Secondary_Language__c ='Chinese',
            SBQQ__Account__c = acc1.Id,
            Change_for_List_Area_Price__c= 3,
            SBQQ__PriceBook__c=PBS.id,
            Install_To_State__c='SBQQ__ListAmount__c'
            );
            insert q8;

        SBQQ__Quote__c q9= new SBQQ__Quote__c(
            //SBQQ__Status__c = 'Draft',
            SBQQ__QuoteLanguage__c = 'Portuguese',
            Quote_Secondary_Language__c ='Chinese',
            SBQQ__Account__c = acc1.Id,
            Change_for_List_Area_Price__c= 3,
            SBQQ__PriceBook__c=PBS.id,
            Install_To_State__c='SBQQ__ListAmount__c'
            );
            insert q9;



        //inserimento quoteTerm
        SBQQ__QuoteTerm__c QT = new SBQQ__QuoteTerm__c(
            Term_Name__c= 'TEST',
            SBQQ__Status__c = 'Approved',
            SBQQ__PrintOrder__c = 2,
            SBQQ__ConditionsMet__c ='Any',
            SBQQ__Active__c= true,
            Body_ITA__c = '{|Port_Name__c|}',
            SBQQ__Body__c = '{|Port_Name__c|}',
            SBQQ__Quote__c= q1.id
        );
        insert QT;

       
        SBQQ__QuoteTerm__c QT2 = new SBQQ__QuoteTerm__c(
            Term_Name__c= 'TEST1',
            SBQQ__Status__c = 'Approved',
            SBQQ__PrintOrder__c = 2,
            SBQQ__ConditionsMet__c ='Any',
            SBQQ__Active__c= true,
            SBQQ__Body__c = '{|Port_Name__c|}',
            SBQQ__Quote__c= q2.id
        );
        insert QT2;

        SBQQ__QuoteTerm__c QT3 = new SBQQ__QuoteTerm__c(
            Term_Name__c= 'TEST3',
            SBQQ__Status__c = 'Approved',
            SBQQ__PrintOrder__c = 2,
            SBQQ__ConditionsMet__c ='Any',
            SBQQ__Active__c= true,
            SBQQ__Body__c = '{|Port_Name__c|}',
            SBQQ__Quote__c= q3.id
        );
        insert QT3;


        //inserimento Quote Term Condition
        SBQQ__TermCondition__c QTC1 = new SBQQ__TermCondition__c(
            SBQQ__QuoteTerm__c = QT3.id,
            SBQQ__TestedField__c ='SBQQ__ListAmount__c',
            Tested_Object__c ='SBQQ__Quote__c',
            SBQQ__Operator__c='equals',
            SBQQ__Value__c = 'SBQQ__ListAmount__c'
        );
        insert QTC1;

        


        SBQQ__TermCondition__c QTC2 = new SBQQ__TermCondition__c(
            SBQQ__QuoteTerm__c = QT2.id,
            SBQQ__TestedField__c ='SBQQ__ListAmount__c',
            Tested_Object__c ='SBQQ__Quote__c',
            SBQQ__Operator__c='not equals',
            SBQQ__Value__c = 'Test2'
        );
        insert QTC2;
     

        SBQQ__TermCondition__c QTC3 = new SBQQ__TermCondition__c(
            SBQQ__QuoteTerm__c = QT3.id,
            SBQQ__TestedField__c ='SBQQ__ListAmount__c',
            Tested_Object__c ='SBQQ__Quote__c',
            SBQQ__Operator__c='less or equals',
            SBQQ__Value__c = '6'
        );
        insert QTC3;

        SBQQ__TermCondition__c QTC4 = new SBQQ__TermCondition__c(
            SBQQ__QuoteTerm__c = QT.id,
            SBQQ__TestedField__c ='SBQQ__ListAmount__c',
            Tested_Object__c ='SBQQ__Quote__c',
            SBQQ__Operator__c='less than',
            SBQQ__Value__c = '5'
        );
        insert QTC4;

        SBQQ__TermCondition__c QTC5 = new SBQQ__TermCondition__c(
            SBQQ__QuoteTerm__c = QT.id,
            SBQQ__TestedField__c ='SBQQ__ListAmount__c',
            Tested_Object__c ='SBQQ__Quote__c',
            SBQQ__Operator__c='greater than',
            SBQQ__Value__c = '4'
        );
        insert QTC5;

        SBQQ__TermCondition__c QTC6 = new SBQQ__TermCondition__c(
            SBQQ__QuoteTerm__c = QT.id,
            SBQQ__TestedField__c ='SBQQ__ListAmount__c',
            Tested_Object__c ='SBQQ__Quote__c',
            SBQQ__Operator__c='greater or equals',
            SBQQ__Value__c = '5'
        );
        insert QTC6;

        SBQQ__TermCondition__c QTC7 = new SBQQ__TermCondition__c(
            SBQQ__QuoteTerm__c = QT.id,
            SBQQ__TestedField__c ='SBQQ__DeliveryMethod__c',
            Tested_Object__c ='SBQQ__Quote__c',
            SBQQ__Operator__c='starts with',
            SBQQ__Value__c = 'Test'
        );
        insert QTC7;

        SBQQ__TermCondition__c QTC8 = new SBQQ__TermCondition__c(
            SBQQ__QuoteTerm__c = QT.id,
            SBQQ__TestedField__c ='SBQQ__DeliveryMethod__c',
            Tested_Object__c ='SBQQ__Quote__c',
            SBQQ__Operator__c='ends with',
            SBQQ__Value__c = 'Test'
        );
        insert QTC8;

        SBQQ__TermCondition__c QTC9 = new SBQQ__TermCondition__c(
            SBQQ__QuoteTerm__c = QT.id,
            SBQQ__TestedField__c ='SBQQ__DeliveryMethod__c',
            Tested_Object__c ='SBQQ__Quote__c',
            SBQQ__Operator__c='contains',
            SBQQ__Value__c = 'Test'
        );
        insert QTC9;

        
        String myJson =  JSON.serialize(q1);
        String myJson2 =  JSON.serialize(q2);
        String myJson3 =  JSON.serialize(q3);
        String myJson4 =  JSON.serialize(q4);
        String myJson5 =  JSON.serialize(q5);
        String myJson6 =  JSON.serialize(q6);
        String myJson7 =  JSON.serialize(q7);
        String myJson8 =  JSON.serialize(q8);
        String myJson9 =  JSON.serialize(q9);
        
        Set<id> QuotSet = new Set<id>();
        QuotSet.add(q1.id);
        QuotSet.add(q2.id);
        QuotSet.add(q3.id);
        QuotSet.add(q4.id);
        QuotSet.add(q5.id);
        QuotSet.add(q6.id);
        QuotSet.add(q7.id);
        QuotSet.add(q8.id);
        QuotSet.add(q9.id);

        

        CongaTermCreator.createConditions(myJson, QuotSet);
        CongaTermCreator.createConditions(myJson2, QuotSet);
        CongaTermCreator.createConditions(myJson3, QuotSet);
        CongaTermCreator.createConditions(myJson4, QuotSet);
        CongaTermCreator.createConditions(myJson5, QuotSet);
        CongaTermCreator.createConditions(myJson6, QuotSet);
        CongaTermCreator.createConditions(myJson7, QuotSet);
        CongaTermCreator.createConditions(myJson8, QuotSet);
        CongaTermCreator.createConditions(myJson9, QuotSet);

    }

    
}