/**
     * Per far girare la presente classe di TEST è necessario disattivare i due FLOW 
     * il cui API_name è qui sotto
        ART_Product_Activation_to_CG_Cloud
        Product_After_Insert
     */
@isTest
public with sharing class BatchCreateAssortmentProduct_Test {
    @TestSetup
   static void makeData(){

        cgcloud__Product_Template__c PT = new cgcloud__Product_Template__c(
            Name ='Codifi Product',
            CurrencyIsoCode ='EUR',
            cgcloud__Active__c =true,
            cgcloud__Sales_Org__c ='0001',
            cgcloud__Description_Language_1__c ='Codifi Product'
        );
        insert PT;

        cgcloud__Product_Assortment_Template__c PAT = new cgcloud__Product_Assortment_Template__c(
            cgcloud__Sales_Org__c ='0001',
            cgcloud__Description_Language_1__c ='Sales Document Assortment Template',
            Name = 'Sales Document Assortment Template'
        );
        insert PAT;

        Assortment  ass = new Assortment (
            Name ='OTC',
            cgcloud__Valid_From__c = system.today(),
            cgcloud__Valid_Thru__c = system.today()+1,
            cgcloud__Product_Assortment_Template__c = PAT.id
        );
        insert ass;

        Assortment  ass1 = new Assortment (
            Name ='Pharma',
            cgcloud__Valid_From__c = system.today(),
            cgcloud__Valid_Thru__c = system.today()+1,
            cgcloud__Product_Assortment_Template__c = PAT.id
            
        );
        insert ass1;

        Assortment  ass2 = new Assortment (
            Name ='Transfer Order',
            cgcloud__Valid_From__c = system.today(),
            cgcloud__Valid_Thru__c = system.today()+1,
            cgcloud__Product_Assortment_Template__c = PAT.id
        );
        insert ass2;
/////////////////////////////////////////////////////////////////////////////////////
        Product2 prod = new Product2 (
            name ='Prodotto Base Codifi',
            THR_MaterialGroup__c='MPRF',
            THR_Plant__c='FIR1',
            THR_XPlantMaterialStatus__c='1',
            THR_Division__c='FA',
            cgcloud__Product_Template__c=PT.id,
            Transfer_Order__c=true,
            THR_MaterialKey__c='IT000000000000756077',
            ProductCode ='CodProd0001',
            IsActive = true
        );

        insert prod;

        // Product2 prod1 = new Product2 (
        //     name ='Prodotto Base Codifi',
        //     THR_MaterialGroup__c='PFPI',
        //     THR_Plant__c='LUS1',
        //     THR_XPlantMaterialStatus__c='1',
        //     THR_Division__c='FA',
        //     cgcloud__Product_Template__c=PT.id,
        //     Transfer_Order__c=false,
        //     THR_MaterialKey__c='IT000000000000756078',
        //     ProductCode ='CodProd0002',
        //     IsActive = true
        // );

        // insert prod1;

        Product2 prod2 = new Product2 (
            name ='Prodotto Base Codifi',
            THR_MaterialGroup__c='MPRF',
            THR_Plant__c='FIR1',
            THR_XPlantMaterialStatus__c='1',
            THR_Division__c='OT',
            cgcloud__Product_Template__c=PT.id,
            Transfer_Order__c=true,
            THR_MaterialKey__c='IT000000000000756079',
            ProductCode ='CodProd0003',
            IsActive = true
        );

        insert prod2;

        ///////////////////////////////////////////////////////////////
        Pricebook2 standardPricebook = new Pricebook2(
            Id = Test.getStandardPricebookId(),
            IsActive = true
        );
        //Update standardPricebook;

        Pricebook2 currPricebook = new Pricebook2();
        currPricebook.Name = 'ITDST1FA';
        insert currPricebook;

        PricebookEntry PBE = new PricebookEntry(
            Pricebook2Id = standardPricebook.id,
            Product2Id =prod.id,
            UnitPrice = 0
        );
        insert PBE;

        PricebookEntry PBEPA = new PricebookEntry(
            Pricebook2Id = currPricebook.id,
            Product2Id =prod.id,
            UnitPrice = 0
        );
        insert PBEPA;

        Pricebook2 currPricebook1 = new Pricebook2();
        currPricebook1.Name = 'ITDST1OT';
        insert currPricebook1;

        PricebookEntry PBE2 = new PricebookEntry(
            Pricebook2Id = standardPricebook.id,
            Product2Id =prod2.id,
            UnitPrice = 0
        );
        insert PBE2;

        PricebookEntry PBEOT = new PricebookEntry(
            Pricebook2Id = currPricebook1.id,
            Product2Id =prod2.id,
            UnitPrice = 0
        );
        insert PBEOT;
        

        // PricebookEntry PBE1 = new PricebookEntry(
        //     Pricebook2Id = standardPricebook.id,
        //     Product2Id =prod1.id,
        //     UnitPrice = 0
        // );
        // insert PBE1;

        // PricebookEntry PBE2 = new PricebookEntry(
        //     Pricebook2Id = standardPricebook.id,
        //     Product2Id =prod2.id,
        //     UnitPrice = 0
        // );
        // insert PBE2;
    }

    

    @isTest
    static void myTestMethod() {        
        Test.startTest();
        BatchCreateAssortmentProduct myClass = new BatchCreateAssortmentProduct();  
        //myClass.sobjectName = 'AssortmentProduct'; 
        String hour = String.valueOf(Datetime.now().hour());
        String min = String.valueOf(Datetime.now().minute() + 1);
        String ss = String.valueOf(Datetime.now().second());
        String chron = ss + ' ' + min + ' ' + hour + ' * * ?';
        
        //String chron = '0 0 * 1/1 * ? *';  
        //0 0 * * *    every day at midnight  
        System.schedule('BatchCreateAssortmentProduct_Test', chron, myClass);
        //Database.executeBatch(myClass);
        Test.stopTest();
   }
}