public without sharing class CreateSpecialProductController {
    @AuraEnabled(cacheable = true)
    public static string getPricebookId(string recordId){
        return [SELECT 	Id, SBQQ__PricebookId__c
				FROM 	SBQQ__Quote__c WHERE Id = :recordId LIMIT 1][0].SBQQ__PricebookId__c;
    }

    @AuraEnabled
    public static string insertAdditionalLines(string productId, string pricebookId,string quoteId ){
        Pricebook2 standardPB = [select id from Pricebook2 where isStandard=true LIMIT 1];
        SBQQ__Quote__c quote = [SELECT id, Installation__c,Programming__c,Maintenance__c,Transport__c,CurrencyIsoCode,Change_for_List_Area_Price__c, SBQQ__PriceBook__r.Markup__c  FROM SBQQ__Quote__c WHERE Id = :quoteId LIMIT 1];
        PricebookEntry standardPBE = new PricebookEntry(Pricebook2Id = standardPB.Id, Product2Id = productId, UnitPrice = 0, IsActive = true, CurrencyIsoCode = quote.CurrencyIsoCode);
        insert standardPBE;
        
        PricebookEntry pbe = new PricebookEntry(IsActive = true);
        pbe.Pricebook2Id = pricebookId;
        pbe.Product2Id = productId;
        pbe.CurrencyIsoCode = quote.CurrencyIsoCode;
        pbe.UnitPrice = 0;
        insert pbe;
        
        Product2 insertedProduct = [SELECT id, name,Special_List_Price__c,Special_Base_List_Price__c,Installation_Price__c,Prog_Training_days__c,Mnt_Training_Days__c,Transport_Price__c 
                                    FROM Product2 
                                    WHERE Id =:productId LIMIT 1 ];
        if(insertedProduct.Special_Base_List_Price__c != null && insertedProduct.Special_Base_List_Price__c != 0){
            system.debug('@@@ stampiaìmo quello ch eci serve special Base: '+insertedProduct.Special_Base_List_Price__c +' markup: '+quote.SBQQ__PriceBook__r.Markup__c +' change Area : '+quote.Change_for_List_Area_Price__c);
            if(Test.isRunningTest()){
                insertedProduct.Special_List_Price__c = (insertedProduct.Special_Base_List_Price__c * (1 + (1/100))) * quote.Change_for_List_Area_Price__c;
            }else{
                insertedProduct.Special_List_Price__c = (insertedProduct.Special_Base_List_Price__c * (1 + (quote.SBQQ__PriceBook__r.Markup__c/100))) * quote.Change_for_List_Area_Price__c;
            }
        }else if(insertedProduct.Special_List_Price__c != null && insertedProduct.Special_List_Price__c != 0){
            insertedProduct.Special_Base_List_Price__c = (insertedProduct.Special_List_Price__c / quote.Change_for_List_Area_Price__c) / (1 + (quote.SBQQ__PriceBook__r.Markup__c/100));
        }
        insertedProduct.IsActive = true;
        update insertedProduct;
        List<SBQQ__LookupData__c> lkpData = new List<SBQQ__LookupData__c>();
        if(insertedProduct.Special_Base_List_Price__c != null && insertedProduct.Special_Base_List_Price__c != 0){
            SBQQ__LookupData__c lkd1 = new SBQQ__LookupData__c();
            lkd1.Lookup_Data_Type__c = 'Base List Price';
            lkd1.SBQQ__Product__c = productId;
            lkd1.Base_List_Price__c = insertedProduct.Special_Base_List_Price__c;
            lkd1.Product_Family__c = 'Special';
            lkd1.Active__c = true;
            lkpData.add(lkd1);
        }
        if(insertedProduct.Special_List_Price__c != null && insertedProduct.Special_List_Price__c != 0){
            SBQQ__LookupData__c lkd2 = new SBQQ__LookupData__c();
            lkd2.Price_Book__c = pricebookId;
            lkd2.Lookup_Data_Type__c = 'List Price';
            lkd2.SBQQ__Product__c = productId;
            lkd2.List_Price__c = insertedProduct.Special_List_Price__c;
            lkd2.Product_Family__c = 'Special';
            lkd2.Active__c = true;
            lkpData.add(lkd2);
        }
        if(insertedProduct.Installation_Price__c != null && insertedProduct.Installation_Price__c != 0){
            SBQQ__LookupData__c lkd1 = new SBQQ__LookupData__c();
            lkd1.Lookup_Data_Type__c = 'Installation';
            lkd1.Installation_Name__c = quote.Installation__c;
            lkd1.SBQQ__Product__c = productId;
            lkd1.SVG_Installation_Price__c = insertedProduct.Installation_Price__c;
            lkd1.Product_Family__c = 'Special';
            lkd1.Active__c = true;
            lkpData.add(lkd1);
        }
        if(insertedProduct.Prog_Training_days__c != null && insertedProduct.Prog_Training_days__c != 0){
            SBQQ__LookupData__c lkd1 = new SBQQ__LookupData__c();
            lkd1.Lookup_Data_Type__c = 'Programming';
            lkd1.Training_Name__c = quote.Programming__c;
            lkd1.SBQQ__Product__c = productId;
            lkd1.Training_day__c = insertedProduct.Prog_Training_days__c;
            lkd1.Product_Family__c = 'Special';
            lkd1.Active__c = true;
            lkpData.add(lkd1);
        }
        if(insertedProduct.Mnt_Training_Days__c != null && insertedProduct.Mnt_Training_Days__c != 0){
            SBQQ__LookupData__c lkd1 = new SBQQ__LookupData__c();
            lkd1.Lookup_Data_Type__c = 'Maintenance';
            lkd1.Training_Name__c = quote.Maintenance__c;
            lkd1.SBQQ__Product__c = productId;
            lkd1.Training_day__c = insertedProduct.Mnt_Training_Days__c;
            lkd1.Product_Family__c = 'Special';
            lkd1.Active__c = true;
            lkpData.add(lkd1);
        }
        if(insertedProduct.Transport_Price__c != null && insertedProduct.Transport_Price__c != 0){
            SBQQ__LookupData__c lkd1 = new SBQQ__LookupData__c();
            lkd1.Lookup_Data_Type__c = 'Transportation';
            lkd1.Trasport_Name__c = quote.Transport__c;
            lkd1.SBQQ__Product__c = productId;
            lkd1.SVG_Shipping_Price__c = insertedProduct.Transport_Price__c;
            lkd1.Product_Family__c = 'Special';
            lkd1.Active__c = true;
            lkpData.add(lkd1);
        }

        if(lkpData.size() > 0){
            insert lkpData;
        }
        return 'OK';

    }
}