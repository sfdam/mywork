public with sharing class lineItemReorderController {
    @AuraEnabled(cacheable = true) 
    public static List<SBQQ__QuoteLine__c> getQuoteLines(string recordId, string groupId){
        if(groupId != null && groupId != ''){
            return [SELECT 	Id,Bundle_Name__c, OptionalLine__c,SVG_Type__c,SBQQ__Product__r.Name,MERGE_Name__c, MERGE_Hide_Line__c,Item_Print_Order__c,MERGE_Hide_Quantity__c,MERGE_Secondary_Name__c,MERGE_Quantity__c,MERGE_Price__c,SBQQ__Quote__r.CurrencyIsoCode
            FROM 	SBQQ__QuoteLine__c WHERE SBQQ__Group__c = :groupId AND SBQQ__Quote__c = :recordId AND HIDE_merged_lines__c=false AND SBQQ__ComponentVisibility__c != 'Never'
            ORDER BY Item_Print_Order__c ASC ];
        }
        else{
            return [SELECT 	Id,Bundle_Name__c ,OptionalLine__c, SVG_Type__c,SBQQ__Product__r.Name,MERGE_Name__c,MERGE_Hide_Line__c, Item_Print_Order__c,MERGE_Hide_Quantity__c,MERGE_Secondary_Name__c,MERGE_Quantity__c,MERGE_Price__c,SBQQ__Quote__r.CurrencyIsoCode
            FROM 	SBQQ__QuoteLine__c WHERE SBQQ__Group__c = null AND SBQQ__Quote__c = :recordId AND HIDE_merged_lines__c=false AND SBQQ__ComponentVisibility__c != 'Never'
            ORDER BY Item_Print_Order__c ASC ];
        }
        
    }
    @AuraEnabled(cacheable = true)
    public static List<SBQQ__QuoteLineGroup__c> getQuoteGroups(string recordId){
        return [SELECT 	Id, SBQQ__Quote__c, Name,Hide_Discount_Price__c,Hide_Total__c 
				FROM 	SBQQ__QuoteLineGroup__c WHERE SBQQ__Quote__c = :recordId 
				ORDER BY SBQQ__Number__c ASC ];
    }

    @AuraEnabled(cacheable = true)
    public static List<SBQQ__QuoteLine__c> getAlternativeLines(string recordId, string selectedLineId, string groupId, boolean opt){
        return [SELECT 	Id, MERGE_Name__c, Item_Print_Order__c, SVG_Type__c 
				FROM 	SBQQ__QuoteLine__c WHERE SBQQ__Quote__c = :recordId AND Id != :selectedLineId AND  HIDE_merged_lines__c = false AND SBQQ__Group__c = :groupId AND OptionalLine__c=:opt
				ORDER BY Item_Print_Order__c ASC ];
    }
    @AuraEnabled
    public static string submit(List<SBQQ__QuoteLine__c> linesToSave){
        try{
            system.debug(linesToSave);
            update linesToSave;
            return 'OK';
        }
        catch(exception e){
            return e.getMessage();
        }
    }
    @AuraEnabled
    public static string changeGroup(string mainLineId, string groupId){
        try{
            SBQQ__QuoteLine__c mainLine = [SELECT Id FROM SBQQ__QuoteLine__c WHERE Id = :mainLineId ];
            mainLine.SBQQ__Group__c = groupId;
            system.debug(mainLine);
            update mainLine;
            return 'OK';
        }
        catch(exception e){
            return e.getMessage();
        }
    }
    @AuraEnabled
    public static string changeGroupName(string newName, string newName2, string groupId, boolean hidePrice, boolean hideDiscount, string totalLabel, string discountLabel){
        try{
            SBQQ__QuoteLineGroup__c QLG =[SELECT 	Id, SBQQ__Quote__c, Name
				FROM 	SBQQ__QuoteLineGroup__c WHERE Id = :groupId ];
            QLG.name = newName;
            QLG.Group_Name_Secondary_Language__c = newName2;
            QLG.Hide_Total__c = hidePrice;
            QLG.Hide_Discount_Price__c = hideDiscount;
            QLG.Total_Label__c = totalLabel;
            QLG.Discount_total_Label__c = discountLabel;
            system.debug(QLG);
            update QLG;
            return 'OK';
        }
        catch(exception e){
            return e.getMessage();
        }
    }
    @AuraEnabled
    public static string submitName(string mainLineId,string lineName, string secondaryName, boolean hideQuantity){
        try{
            SBQQ__QuoteLine__c mainLine = [SELECT Id,MERGE_Hide_Quantity__c,MERGE_Secondary_Name__c,MERGE_Name__c,MERGE_Quantity__c,MERGE_Price__c FROM SBQQ__QuoteLine__c WHERE Id = :mainLineId ];
            mainLine.MERGE_Name__c = lineName;
            mainLine.MERGE_Secondary_Name__c = secondaryName;
            mainLine.MERGE_Hide_Quantity__c = hideQuantity;
            update mainLine;
            return 'OK';
        }
        catch(exception e){
            return e.getMessage();
        }
    }
    @AuraEnabled
    public static string mergeLines(List<string> mergeIds,string mainLineId, string lineName, string secondaryName, boolean hideQuantity){
        List<SBQQ__QuoteLine__c> lines = [SELECT Id,SBQQ__Quantity__c,HIDE_merged_lines__c,SBQQ__Description__c,MERGE_Hide_Quantity__c,Description_Secondary_Lang__c,Material_Price_without_additional_discou__c,Merge_Description__c,Merge_Secondary_Language_Description__c,MERGE_Secondary_Name__c,MERGE_Name__c,MERGE_Quantity__c,MERGE_Price__c FROM SBQQ__QuoteLine__c WHERE Id IN :mergeIds ORDER BY Item_Print_Order__c ASC ];
        SBQQ__QuoteLine__c mainLine = [SELECT Id,SBQQ__Quantity__c,SBQQ__Description__c,Description_Secondary_Lang__c,Material_Price_without_additional_discou__c,MERGE_Hide_Quantity__c,Merge_Description__c,Merge_Secondary_Language_Description__c,MERGE_Secondary_Name__c,MERGE_Name__c,MERGE_Quantity__c,MERGE_Price__c FROM SBQQ__QuoteLine__c WHERE Id = :mainLineId ];
        mainLine.MERGE_Name__c = lineName;
        mainLine.MERGE_Secondary_Name__c = secondaryName;
        mainLine.MERGE_Hide_Quantity__c = hideQuantity;
        mainLine.MERGE_Quantity__c=string.valueOf(Integer.valueOf(mainLine.SBQQ__Quantity__c));
        mainLine.MERGE_Price__c=mainLine.Material_Price_without_additional_discou__c;
        mainLine.Merge_Description__c=mainLine.SBQQ__Description__c;
        mainLine.Merge_Secondary_Language_Description__c=mainLine.Description_Secondary_Lang__c;
        for(SBQQ__QuoteLine__c singleLine : lines){
            singleLine.HIDE_merged_lines__c = true;
            mainLine.MERGE_Quantity__c = mainLine.MERGE_Quantity__c + '+' + singleLine.MERGE_Quantity__c;
            mainLine.MERGE_Price__c=mainLine.MERGE_Price__c + singleLine.MERGE_Price__c;
            if(String.isNotBlank(mainLine.Merge_Description__c)  ){
                if(String.isNotBlank(mainLine.Merge_Description__c)){
                    mainLine.Merge_Description__c=mainLine.Merge_Description__c + '+' + singleLine.Merge_Description__c;
                }else{
                    mainLine.Merge_Description__c=mainLine.Merge_Description__c;
                }
            }else{
                if(String.isNotBlank(mainLine.Merge_Description__c)){
                    mainLine.Merge_Description__c= singleLine.Merge_Description__c;
                }
            }
            if(String.isNotBlank(mainLine.Merge_Secondary_Language_Description__c)  ){
                if(String.isNotBlank(mainLine.Merge_Secondary_Language_Description__c)){
                    mainLine.Merge_Secondary_Language_Description__c=mainLine.Merge_Secondary_Language_Description__c + '+' + singleLine.Merge_Secondary_Language_Description__c;
                }else{
                    mainLine.Merge_Secondary_Language_Description__c=mainLine.Merge_Secondary_Language_Description__c;
                }
            }else{
                if(String.isNotBlank(mainLine.Merge_Secondary_Language_Description__c)){
                    mainLine.Merge_Secondary_Language_Description__c= singleLine.Merge_Secondary_Language_Description__c;
                }
            }
           /*
            if(String.isNotBlank(mainLine.MERGE_Price__c) ){
                if(String.isNotBlank(singleLine.MERGE_Price__c)){
                    mainLine.MERGE_Price__c=mainLine.MERGE_Price__c.replace('.','').replace(',','.');
                    mainLine.MERGE_Price__c=mainLine.MERGE_Price__c.replace('.','').replace(',','.');
                    
                }else{
                    mainLine.MERGE_Price__c=mainLine.MERGE_Price__c;
                }
            } else{
                if(String.isNotBlank(singleLine.MERGE_Price__c)){
                    mainLine.MERGE_Price__c=singleLine.MERGE_Price__c;
                }
            }*/
            
            
            
        }
        system.debug('lines '+lines);
        system.debug('mainLine '+mainLine);
        try{
            update lines;
            update mainLine;
            return 'OK';
        }
        catch(exception e){
            return e.getMessage();
        }
    }
    @AuraEnabled
    public static string unMergeLines(string recordId){
        List<SBQQ__QuoteLine__c> lines = [SELECT Id, SBQQ__Product__r.Name,MERGE_Name__c, Item_Print_Order__c,SBQQ__Quantity__c,SBQQ__NetTotal__c 
        FROM 	SBQQ__QuoteLine__c WHERE SBQQ__Quote__c = :recordId
        ORDER BY Item_Print_Order__c ASC ];
        for(SBQQ__QuoteLine__c singleLine : lines){
            singleLine.MERGE_Name__c = singleLine.SBQQ__Product__r.Name;
            singleLine.MERGE_Secondary_Name__c = singleLine.SBQQ__Product__r.Name;
            singleLine.MERGE_Quantity__c = string.valueof(integer.valueof(singleLine.SBQQ__Quantity__c));
            singleLine.MERGE_Price__c = singleLine.SBQQ__NetTotal__c;
            //singleLine.MERGE_Hide_Line__c = false;
            singleLine.MERGE_Hide_Quantity__c = false;
        }
        try{
            update lines;
            return 'OK';
        }
        catch(exception e){
            return e.getMessage();
        }
    }
}