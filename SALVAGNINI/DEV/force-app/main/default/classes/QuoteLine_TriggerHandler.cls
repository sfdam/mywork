public class QuoteLine_TriggerHandler {
    
    // public static boolean skipTrigger = false;
    public static set<String> setQLUsed = new set<String>(); // CM
    
    public static void handleTrigger(List<SBQQ__QuoteLine__c> newQuoteLines, Map<Id, SBQQ__QuoteLine__c> oldQuoteLinesMap, System.TriggerOperation triggerEvent) {
        
        switch on triggerEvent {
            
            when BEFORE_INSERT {
                System.debug('DK START QuoteLine_TriggerHandler.BEFORE_INSERT');
                lockRecordWhilePendingApproval(newQuoteLines);
                setFieldsBeforeInsert(newQuoteLines);
                
                setParentBundle(newQuoteLines, null, true);
            }

            when BEFORE_UPDATE {
                System.debug('DK START QuoteLine_TriggerHandler.BEFORE_UPDATE');
                lockRecordWhilePendingApproval(newQuoteLines);
                setFieldsBeforeUpdate(newQuoteLines, oldQuoteLinesMap);
                setParentBundle(newQuoteLines, oldQuoteLinesMap, false);
            }

            when AFTER_INSERT {
                System.debug('DK START QuoteLine_TriggerHandler.AFTER_INSERT');
                //manageOptionalsFlag(newQuoteLines, oldQuoteLinesMap, true);
            }

            when AFTER_UPDATE {
                System.debug('DK START QuoteLine_TriggerHandler.AFTER_UPDATE');
                //manageOptionalsFlag(newQuoteLines, oldQuoteLinesMap, false);
            }
            when AFTER_DELETE {
                System.debug('DK START QuoteLine_TriggerHandler.AFTER_DELETE');
                //manageOptionalsFlag(newQuoteLines, oldQuoteLinesMap, false);
            }
            when AFTER_UNDELETE {
                System.debug('DK START QuoteLine_TriggerHandler.AFTER_UNDELETE');
                //manageOptionalsFlag(newQuoteLines, oldQuoteLinesMap, false);
            }
        }
    }
    //nuovo metodo per lo spostamento dei flow trigger
    private static void setFieldsBeforeInsert(List<SBQQ__QuoteLine__c> newQuoteLines) {
        Set<Id> productIdSet = new Set<Id>();
        Set<Id> quoteIdSet = new Set<Id>();
        Set<Id> productOptionIdSet = new Set<Id>();
        for(SBQQ__QuoteLine__c ql : newQuoteLines){
           productIdSet.add(ql.SBQQ__Product__c);
           quoteIdSet.add(ql.SBQQ__Quote__c);
           productOptionIdSet.add(ql.SBQQ__ProductOption__c);
        }

        
        Map<Id,Product2> productMap = new Map<Id,Product2>([SELECT Id, Manufacturer__c, Name, Product_Description_ENG__c, Technical_Description_ENG__c, Product_Description_ITA__c, SVG_Technical_Description_HTML__c, Product_Description_DEU__c, Technical_Description_DEU__c, Product_Description_FRA__c, Technical_Description__c, Product_Description_ESP__c, Technical_Description_SPA__c, Product_Description_CHN__c, Technical_Description_CH__c, Product_Description_RUS__c, Technical_Description_RUS__c, Product_Description_POL__c, Technical_Description_POL__c, Product_Description_PT__c, Technical_Description_PT__c FROM Product2 WHERE Id IN :productIdSet]);
        Map<Id,SBQQ__Quote__c> quoteMap = new Map<Id,SBQQ__Quote__c>([SELECT Id, SBQQ__QuoteLanguage__c, Quote_Secondary_Language__c, Programming_Course_Site_Charge__c, Programming_Course_Site_Works__c, Is_Panel_for_Ennsdorf__c FROM SBQQ__Quote__c WHERE Id IN :quoteIdSet]);
        Map<Id,SBQQ__ProductOption__c> productOptionMap = new Map<Id,SBQQ__ProductOption__c>([SELECT Id,Additional_Description_ENG__c, Additional_Description_DEU__c, Additional_Description__c, Additional_Description_ESP__c, Additional_Description_RUS__c, Additional_Description_POL__c, Additional_Description_ITA__c, Additional_Description_PT__c FROM SBQQ__ProductOption__c WHERE Id IN :productOptionIdSet]);
        List<SBQQ__Quote__c> quoteToUpdate = new List<SBQQ__Quote__c>();
        for(SBQQ__QuoteLine__c ql : newQuoteLines){
            /* AA MM 2023-06-19 - Commentata valorizzazione di questi 3 campi poichè gestita dalla Price Rule "Update special item description"
            ql.SVG_Special_Item_Description__c = ql.SBQQ__Description__c;
            ql.Special_Item_Full_Description__c = ql.SVG_Technical_Description_HTML__c;
            ql.Special_item_Name__c = productMap != null && productMap.get(ql.SBQQ__Product__c) != null ? productMap.get(ql.SBQQ__Product__c).Name : '';
            */
            ql.MERGE_Name__c = (ql.SVG_Special_Item__c) ? ql.Special_item_Name__c : (productMap != null && productMap.get(ql.SBQQ__Product__c) != null) ? productMap.get(ql.SBQQ__Product__c).Name : '';
            ql.MERGE_Price__c = ql.Material_Price_without_additional_discou__c;
            ql.MERGE_Quantity__c = String.valueOf(ql.SBQQ__Quantity__c);
            ql.Merge_Description__c = (ql.SVG_Special_Item__c) ? ql.SVG_Special_Item_Description__c : ql.SBQQ__Description__c;
            ql.Merge_Secondary_Language_Description__c = ql.Description_Secondary_Lang__c;
            ql.Product_Name_Text__c = productMap != null && productMap.get(ql.SBQQ__Product__c) != null ? productMap.get(ql.SBQQ__Product__c).Name : '';
            // setto lingua primaria
            if(quoteMap != null && quoteMap.get(ql.SBQQ__Quote__c) != null && String.isNotBlank(quoteMap.get(ql.SBQQ__Quote__c).SBQQ__QuoteLanguage__c) && quoteMap.get(ql.SBQQ__Quote__c).SBQQ__QuoteLanguage__c.equals('Italian') && !ql.SVG_Special_Item__c){
                ql.SBQQ__Description__c = productMap != null && productMap.get(ql.SBQQ__Product__c) != null ? productMap.get(ql.SBQQ__Product__c).Product_Description_ITA__c : '';
                ql.SVG_Technical_Description_HTML__c = productMap != null && productMap.get(ql.SBQQ__Product__c) != null ? productMap.get(ql.SBQQ__Product__c).SVG_Technical_Description_HTML__c : '';
                ql.SVG_Additional_Description__c = productOptionMap != null && productOptionMap.get(ql.SBQQ__ProductOption__c) != null ? productOptionMap.get(ql.SBQQ__ProductOption__c).Additional_Description_ITA__c : '';
            }
            else if(quoteMap != null && quoteMap.get(ql.SBQQ__Quote__c) != null && String.isNotBlank(quoteMap.get(ql.SBQQ__Quote__c).SBQQ__QuoteLanguage__c) && quoteMap.get(ql.SBQQ__Quote__c).SBQQ__QuoteLanguage__c.equals('English') && !ql.SVG_Special_Item__c){
                ql.SBQQ__Description__c = productMap != null && productMap.get(ql.SBQQ__Product__c) != null ? productMap.get(ql.SBQQ__Product__c).Product_Description_ENG__c : '';
                ql.SVG_Technical_Description_HTML__c = productMap != null && productMap.get(ql.SBQQ__Product__c) != null ? productMap.get(ql.SBQQ__Product__c).Technical_Description_ENG__c : '';
                ql.SVG_Additional_Description__c = productOptionMap != null && productOptionMap.get(ql.SBQQ__ProductOption__c) != null ? productOptionMap.get(ql.SBQQ__ProductOption__c).Additional_Description_ENG__c : '';
            }
            else if(quoteMap != null && quoteMap.get(ql.SBQQ__Quote__c) != null && String.isNotBlank(quoteMap.get(ql.SBQQ__Quote__c).SBQQ__QuoteLanguage__c) && quoteMap.get(ql.SBQQ__Quote__c).SBQQ__QuoteLanguage__c.equals('German') && !ql.SVG_Special_Item__c){
                ql.SBQQ__Description__c = productMap != null && productMap.get(ql.SBQQ__Product__c) != null ? productMap.get(ql.SBQQ__Product__c).Product_Description_DEU__c : '';
                ql.SVG_Technical_Description_HTML__c = productMap != null && productMap.get(ql.SBQQ__Product__c) != null ? productMap.get(ql.SBQQ__Product__c).Technical_Description_DEU__c : '';
                ql.SVG_Additional_Description__c = productOptionMap != null && productOptionMap.get(ql.SBQQ__ProductOption__c) != null ? productOptionMap.get(ql.SBQQ__ProductOption__c).Additional_Description_DEU__c : '';
            }
            else if(quoteMap != null && quoteMap.get(ql.SBQQ__Quote__c) != null && String.isNotBlank(quoteMap.get(ql.SBQQ__Quote__c).SBQQ__QuoteLanguage__c) && quoteMap.get(ql.SBQQ__Quote__c).SBQQ__QuoteLanguage__c.equals('French') && !ql.SVG_Special_Item__c){
                ql.SBQQ__Description__c = productMap != null && productMap.get(ql.SBQQ__Product__c) != null ? productMap.get(ql.SBQQ__Product__c).Product_Description_FRA__c : '';
                ql.SVG_Technical_Description_HTML__c = productMap != null && productMap.get(ql.SBQQ__Product__c) != null ? productMap.get(ql.SBQQ__Product__c).Technical_Description__c : '';
                ql.SVG_Additional_Description__c = productOptionMap != null && productOptionMap.get(ql.SBQQ__ProductOption__c) != null ? productOptionMap.get(ql.SBQQ__ProductOption__c).Additional_Description__c : '';
            }
            else if(quoteMap != null && quoteMap.get(ql.SBQQ__Quote__c) != null && String.isNotBlank(quoteMap.get(ql.SBQQ__Quote__c).SBQQ__QuoteLanguage__c) && quoteMap.get(ql.SBQQ__Quote__c).SBQQ__QuoteLanguage__c.equals('Spanish')  && !ql.SVG_Special_Item__c){
                ql.SBQQ__Description__c = productMap != null && productMap.get(ql.SBQQ__Product__c) != null ? productMap.get(ql.SBQQ__Product__c).Product_Description_ESP__c : '';
                ql.SVG_Technical_Description_HTML__c = productMap != null && productMap.get(ql.SBQQ__Product__c) != null ? productMap.get(ql.SBQQ__Product__c).Technical_Description_SPA__c : '';
                ql.SVG_Additional_Description__c = productOptionMap != null && productOptionMap.get(ql.SBQQ__ProductOption__c) != null ? productOptionMap.get(ql.SBQQ__ProductOption__c).Additional_Description_ESP__c : '';
            }
            else if(quoteMap != null && quoteMap.get(ql.SBQQ__Quote__c) != null && String.isNotBlank(quoteMap.get(ql.SBQQ__Quote__c).SBQQ__QuoteLanguage__c) && quoteMap.get(ql.SBQQ__Quote__c).SBQQ__QuoteLanguage__c.equals('Chinese') && !ql.SVG_Special_Item__c){
                ql.SBQQ__Description__c = productMap != null && productMap.get(ql.SBQQ__Product__c) != null ? productMap.get(ql.SBQQ__Product__c).Product_Description_CHN__c : '';
                ql.SVG_Technical_Description_HTML__c = productMap != null && productMap.get(ql.SBQQ__Product__c) != null ? productMap.get(ql.SBQQ__Product__c).Technical_Description_CH__c : '';
                ql.SVG_Additional_Description__c = productOptionMap != null && productOptionMap.get(ql.SBQQ__ProductOption__c) != null ? productOptionMap.get(ql.SBQQ__ProductOption__c).Additional_Description_CHN__c : '';
            }
            else if(quoteMap != null && quoteMap.get(ql.SBQQ__Quote__c) != null && String.isNotBlank(quoteMap.get(ql.SBQQ__Quote__c).SBQQ__QuoteLanguage__c) && quoteMap.get(ql.SBQQ__Quote__c).SBQQ__QuoteLanguage__c.equals('Russian') && !ql.SVG_Special_Item__c){
                ql.SBQQ__Description__c = productMap != null && productMap.get(ql.SBQQ__Product__c) != null ? productMap.get(ql.SBQQ__Product__c).Product_Description_RUS__c : '';
                ql.SVG_Technical_Description_HTML__c = productMap != null && productMap.get(ql.SBQQ__Product__c) != null ? productMap.get(ql.SBQQ__Product__c).Technical_Description_RUS__c : '';
                ql.SVG_Additional_Description__c = productOptionMap != null && productOptionMap.get(ql.SBQQ__ProductOption__c) != null ? productOptionMap.get(ql.SBQQ__ProductOption__c).Additional_Description_RUS__c : '';
            }
            else if(quoteMap != null && quoteMap.get(ql.SBQQ__Quote__c) != null && String.isNotBlank(quoteMap.get(ql.SBQQ__Quote__c).SBQQ__QuoteLanguage__c) && quoteMap.get(ql.SBQQ__Quote__c).SBQQ__QuoteLanguage__c.equals('Polish') && !ql.SVG_Special_Item__c){
                ql.SBQQ__Description__c = productMap != null && productMap.get(ql.SBQQ__Product__c) != null ? productMap.get(ql.SBQQ__Product__c).Product_Description_POL__c : '';
                ql.SVG_Technical_Description_HTML__c = productMap != null && productMap.get(ql.SBQQ__Product__c) != null ? productMap.get(ql.SBQQ__Product__c).Technical_Description_POL__c : '';
                ql.SVG_Additional_Description__c = productOptionMap != null && productOptionMap.get(ql.SBQQ__ProductOption__c) != null ? productOptionMap.get(ql.SBQQ__ProductOption__c).Additional_Description_POL__c : '';
            }
            else if(quoteMap != null && quoteMap.get(ql.SBQQ__Quote__c) != null && String.isNotBlank(quoteMap.get(ql.SBQQ__Quote__c).SBQQ__QuoteLanguage__c) && quoteMap.get(ql.SBQQ__Quote__c).SBQQ__QuoteLanguage__c.equals('Portuguese') && !ql.SVG_Special_Item__c){
                ql.SBQQ__Description__c = productMap != null && productMap.get(ql.SBQQ__Product__c) != null ? productMap.get(ql.SBQQ__Product__c).Product_Description_PT__c : '';
                ql.SVG_Technical_Description_HTML__c = productMap != null && productMap.get(ql.SBQQ__Product__c) != null ? productMap.get(ql.SBQQ__Product__c).Technical_Description_PT__c : '';
                ql.SVG_Additional_Description__c = productOptionMap != null && productOptionMap.get(ql.SBQQ__ProductOption__c) != null ? productOptionMap.get(ql.SBQQ__ProductOption__c).Additional_Description_PT__c : '';
            }
            //setto lingua secondaria
            if(quoteMap != null && quoteMap.get(ql.SBQQ__Quote__c) != null && String.isNotBlank(quoteMap.get(ql.SBQQ__Quote__c).Quote_Secondary_Language__c) && quoteMap.get(ql.SBQQ__Quote__c).Quote_Secondary_Language__c.equals('Italian') && !ql.SVG_Special_Item__c){
                ql.Additional_Description_Secondary_Lang__c = productOptionMap != null && productOptionMap.get(ql.SBQQ__ProductOption__c) != null ? productOptionMap.get(ql.SBQQ__ProductOption__c).Additional_Description_ITA__c : '';
                ql.Description_Secondary_Lang__c = productMap != null && productMap.get(ql.SBQQ__Product__c) != null ? productMap.get(ql.SBQQ__Product__c).Product_Description_ITA__c : '';
                ql.Technical_Description_Secondary_Languag__c = productMap != null && productMap.get(ql.SBQQ__Product__c) != null ? productMap.get(ql.SBQQ__Product__c).SVG_Technical_Description_HTML__c : '';
            }
            else if(quoteMap != null && quoteMap.get(ql.SBQQ__Quote__c) != null && String.isNotBlank(quoteMap.get(ql.SBQQ__Quote__c).Quote_Secondary_Language__c) && quoteMap.get(ql.SBQQ__Quote__c).Quote_Secondary_Language__c.equals('English') && !ql.SVG_Special_Item__c){
                ql.Additional_Description_Secondary_Lang__c = productOptionMap != null && productOptionMap.get(ql.SBQQ__ProductOption__c) != null ? productOptionMap.get(ql.SBQQ__ProductOption__c).Additional_Description_ENG__c : '';
                ql.Description_Secondary_Lang__c = productMap != null && productMap.get(ql.SBQQ__Product__c) != null ? productMap.get(ql.SBQQ__Product__c).Product_Description_ENG__c : '';
                ql.Technical_Description_Secondary_Languag__c = productMap != null && productMap.get(ql.SBQQ__Product__c) != null ? productMap.get(ql.SBQQ__Product__c).Technical_Description_ENG__c : '';
            }
            else if(quoteMap != null && quoteMap.get(ql.SBQQ__Quote__c) != null && String.isNotBlank(quoteMap.get(ql.SBQQ__Quote__c).Quote_Secondary_Language__c) && quoteMap.get(ql.SBQQ__Quote__c).Quote_Secondary_Language__c.equals('Spanish') && !ql.SVG_Special_Item__c){
                ql.Additional_Description_Secondary_Lang__c = productOptionMap != null && productOptionMap.get(ql.SBQQ__ProductOption__c) != null ? productOptionMap.get(ql.SBQQ__ProductOption__c).Additional_Description_ESP__c : '';
                ql.Description_Secondary_Lang__c = productMap != null && productMap.get(ql.SBQQ__Product__c) != null ? productMap.get(ql.SBQQ__Product__c).Product_Description_ESP__c : '';
                ql.Technical_Description_Secondary_Languag__c = productMap != null && productMap.get(ql.SBQQ__Product__c) != null ? productMap.get(ql.SBQQ__Product__c).Technical_Description_SPA__c : '';
            }
            else if(quoteMap != null && quoteMap.get(ql.SBQQ__Quote__c) != null && String.isNotBlank(quoteMap.get(ql.SBQQ__Quote__c).Quote_Secondary_Language__c) && quoteMap.get(ql.SBQQ__Quote__c).Quote_Secondary_Language__c.equals('German') && !ql.SVG_Special_Item__c){
                ql.Additional_Description_Secondary_Lang__c = productOptionMap != null && productOptionMap.get(ql.SBQQ__ProductOption__c) != null ? productOptionMap.get(ql.SBQQ__ProductOption__c).Additional_Description_DEU__c : '';
                ql.Description_Secondary_Lang__c = productMap != null && productMap.get(ql.SBQQ__Product__c) != null ? productMap.get(ql.SBQQ__Product__c).Product_Description_DEU__c : '';
                ql.Technical_Description_Secondary_Languag__c = productMap != null && productMap.get(ql.SBQQ__Product__c) != null ? productMap.get(ql.SBQQ__Product__c).Technical_Description_DEU__c : '';
            }
            else if(quoteMap != null && quoteMap.get(ql.SBQQ__Quote__c) != null && String.isNotBlank(quoteMap.get(ql.SBQQ__Quote__c).Quote_Secondary_Language__c) && quoteMap.get(ql.SBQQ__Quote__c).Quote_Secondary_Language__c.equals('French') && !ql.SVG_Special_Item__c){
                ql.Additional_Description_Secondary_Lang__c = productOptionMap != null && productOptionMap.get(ql.SBQQ__ProductOption__c) != null ? productOptionMap.get(ql.SBQQ__ProductOption__c).Additional_Description__c : '';
                ql.Description_Secondary_Lang__c = productMap != null && productMap.get(ql.SBQQ__Product__c) != null ? productMap.get(ql.SBQQ__Product__c).Product_Description_FRA__c : '';
                ql.Technical_Description_Secondary_Languag__c = productMap != null && productMap.get(ql.SBQQ__Product__c) != null ? productMap.get(ql.SBQQ__Product__c).Technical_Description__c : '';
            }
            else if(quoteMap != null && quoteMap.get(ql.SBQQ__Quote__c) != null && String.isNotBlank(quoteMap.get(ql.SBQQ__Quote__c).Quote_Secondary_Language__c) && quoteMap.get(ql.SBQQ__Quote__c).Quote_Secondary_Language__c.equals('Russian') && !ql.SVG_Special_Item__c){
                ql.Additional_Description_Secondary_Lang__c = productOptionMap != null && productOptionMap.get(ql.SBQQ__ProductOption__c) != null ? productOptionMap.get(ql.SBQQ__ProductOption__c).Additional_Description_RUS__c : '';
                ql.Description_Secondary_Lang__c = productMap != null && productMap.get(ql.SBQQ__Product__c) != null ? productMap.get(ql.SBQQ__Product__c).Product_Description_RUS__c : '';
                ql.Technical_Description_Secondary_Languag__c = productMap != null && productMap.get(ql.SBQQ__Product__c) != null ? productMap.get(ql.SBQQ__Product__c).Technical_Description_RUS__c : '';
            }
            else if(quoteMap != null && quoteMap.get(ql.SBQQ__Quote__c) != null && String.isNotBlank(quoteMap.get(ql.SBQQ__Quote__c).Quote_Secondary_Language__c) && quoteMap.get(ql.SBQQ__Quote__c).Quote_Secondary_Language__c.equals('Chinese') && !ql.SVG_Special_Item__c){
                ql.Additional_Description_Secondary_Lang__c = productOptionMap != null && productOptionMap.get(ql.SBQQ__ProductOption__c) != null ? productOptionMap.get(ql.SBQQ__ProductOption__c).Additional_Description_CHN__c : '';
                ql.Description_Secondary_Lang__c = productMap != null && productMap.get(ql.SBQQ__Product__c) != null ? productMap.get(ql.SBQQ__Product__c).Product_Description_CHN__c : '';
                ql.Technical_Description_Secondary_Languag__c = productMap != null && productMap.get(ql.SBQQ__Product__c) != null ? productMap.get(ql.SBQQ__Product__c).Technical_Description_CH__c : '';
            }
            else if(quoteMap != null && quoteMap.get(ql.SBQQ__Quote__c) != null && String.isNotBlank(quoteMap.get(ql.SBQQ__Quote__c).Quote_Secondary_Language__c) && quoteMap.get(ql.SBQQ__Quote__c).Quote_Secondary_Language__c.equals('Polish') && !ql.SVG_Special_Item__c){
                ql.Additional_Description_Secondary_Lang__c = productOptionMap != null && productOptionMap.get(ql.SBQQ__ProductOption__c) != null ? productOptionMap.get(ql.SBQQ__ProductOption__c).Additional_Description_POL__c : '';
                ql.Description_Secondary_Lang__c = productMap != null && productMap.get(ql.SBQQ__Product__c) != null ? productMap.get(ql.SBQQ__Product__c).Product_Description_POL__c : '';
                ql.Technical_Description_Secondary_Languag__c = productMap != null && productMap.get(ql.SBQQ__Product__c) != null ? productMap.get(ql.SBQQ__Product__c).Technical_Description_POL__c : '';
            }
            else if(quoteMap != null && quoteMap.get(ql.SBQQ__Quote__c) != null && String.isNotBlank(quoteMap.get(ql.SBQQ__Quote__c).Quote_Secondary_Language__c) && quoteMap.get(ql.SBQQ__Quote__c).Quote_Secondary_Language__c.equals('Portuguese') && !ql.SVG_Special_Item__c){
                ql.Additional_Description_Secondary_Lang__c = productOptionMap != null && productOptionMap.get(ql.SBQQ__ProductOption__c) != null ? productOptionMap.get(ql.SBQQ__ProductOption__c).Additional_Description_PT__c : '';
                ql.Description_Secondary_Lang__c = productMap != null && productMap.get(ql.SBQQ__Product__c) != null ? productMap.get(ql.SBQQ__Product__c).Product_Description_PT__c : '';
                ql.Technical_Description_Secondary_Languag__c = productMap != null && productMap.get(ql.SBQQ__Product__c) != null ? productMap.get(ql.SBQQ__Product__c).Technical_Description_PT__c : '';
            }

            ql.Sales_Condition_Is_Laser__c = ql.Product_Name_Text__c.equals('L3-30') || ql.Product_Name_Text__c.equals('L3-40') || ql.Product_Name_Text__c.equals('L5-30') || ql.Product_Name_Text__c.equals('L5-40') || ql.Product_Name_Text__c.equals('L3-4020') || ql.Product_Name_Text__c.equals('L3-6020') ? true : ql.Sales_Condition_Is_Laser__c;
            ql.Sales_Condition_Source_mag_3__c = ql.Product_Name_Text__c.equals('FLR30U') || ql.Product_Name_Text__c.equals('FLR30R') || ql.Product_Name_Text__c.equals('FLR40U') || ql.Product_Name_Text__c.equals('FLR60LU') || ql.Product_Name_Text__c.equals('FLR80LU') || ql.Product_Name_Text__c.equals('FLR100U') ? true : ql.Sales_Condition_Source_mag_3__c;
            ql.Sales_Condition_Source_min_3__c = ql.Product_Name_Text__c.equals('FLR20U') || ql.Product_Name_Text__c.equals('FLR20R') ?  true : ql.Sales_Condition_Source_min_3__c;
            ql.Is_Test_at_manif__c = ql.Product_Name_Text__c.equals('Test at manuf.') ? true : ql.Is_Test_at_manif__c;
            ql.Is_MV_MBT__c = ql.Product_Name_Text__c.startsWithIgnoreCase('MVc') ? true : ql.Is_MV_MBT__c;
            ql.Is_Press_Brakes__c = ql.Product_Name_Text__c.startsWithIgnoreCase('B3') ? true : ql.Is_Press_Brakes__c;
            ql.Is_Hotel_Expenses__c = ql.Product_Name_Text__c.equals('Hotel Expenses') ? true : ql.Is_Hotel_Expenses__c;
            ql.Office_Software__c = ql.Product_Name_Text__c.equals('Office Software') ? true : false;
            ql.SY_SupportYou__c = ql.Product_Name_Text__c.equals('SY') ? true : ql.SY_SupportYou__c;

            /*SBQQ__Quote__c q = quoteMap.get(ql.SBQQ__Quote__c);

            if(ql.Product_Name_Text__c.equals('PT on site')){    
                q.Programming_Course_Site_Charge__c =ql.SVG_Type__c.equals('our/our') ? 'our' : '';
                q.Programming_Course_Site_Works__c = ql.SVG_Type__c.equals('our/our') ? 'our works or at one of our subsidiaries' : '';
                q.Programming_Course_Site_Charge__c = ql.SVG_Type__c.equals('your/our') ? 'our' : '';
                q.Programming_Course_Site_Works__c = ql.SVG_Type__c.equals('your/our') ? 'your works' : '';
                q.Programming_Course_Site_Charge__c = ql.SVG_Type__c.equals('our/your') ? 'your' : '';
                q.Programming_Course_Site_Works__c = ql.SVG_Type__c.equals('our/your') ? 'our works or at one of our subsidiaries' : '';             
                q.Programming_Course_Site_Charge__c = ql.SVG_Type__c.equals('your/your') ? 'your' : '';
                q.Programming_Course_Site_Works__c = ql.SVG_Type__c.equals('your/your') ? 'your works' : '';
                quoteToUpdate.add(q);
            }
            if(ql.Product_Name_Text__c.equals('FLRP2L-212030U') || ql.Product_Name_Text__c.equals('P2L-2520') || (ql.Product_Name_Text__c.equals('P4L') && productMap != null && productMap.get(ql.SBQQ__Product__c) != null && productMap.get(ql.SBQQ__Product__c).Manufacturer__c.equals('Austria')) || ql.Product_Name_Text__c.equals('P1')){
                q.Is_Panel_for_Ennsdorf__c = true;
                quoteToUpdate.add(q);
            }*/
        }
        //update quoteToUpdate;
    }

    //gestione campi before update
    private static void setFieldsBeforeUpdate(List<SBQQ__QuoteLine__c> newQuoteLines, Map<Id, SBQQ__QuoteLine__c> oldMap){
        for(SBQQ__QuoteLine__c ql : newQuoteLines){
            //Se cambia il campo Special_item_Name__c ed è una quote line Speciale (SVG_Special_Item__c = true), vado ad aggiornare il campo MERGE_Name__c
            ql.MERGE_Name__c = (ql.Special_item_Name__c != oldMap.get(ql.Id)?.Special_item_Name__c && ql.SVG_Special_Item__c) ? ql.Special_item_Name__c : ql.MERGE_Name__c;
            //Se cambia il campo SVG_Special_Item_Description__c ed è una quote line Speciale (SVG_Special_Item__c = true), vado ad aggiornare il campo Merge_Description__c
            ql.Merge_Description__c = (ql.SVG_Special_Item_Description__c != oldMap.get(ql.Id)?.SVG_Special_Item_Description__c && ql.SVG_Special_Item__c) ? ql.SVG_Special_Item_Description__c : ql.Merge_Description__c;
        }
    }
 
    private static void lockRecordWhilePendingApproval(List<SBQQ__QuoteLine__c> newQuoteLines) {
        List<User> isUserAdmin = [SELECT Name FROM User WHERE Profile.PermissionsModifyAllData = true AND Id = :UserInfo.getUserId()];
        if (isUserAdmin != null && !isUserAdmin.isEmpty()) {
            return;
        }
        
        Set<Id> quoteIdSet = new Set<Id>();
        for (SBQQ__QuoteLine__c ql : newQuoteLines) {
            quoteIdSet.add(ql.SBQQ__Quote__c);
        }
        
        Set<Id> quoteIdToLock = new Set<Id>();
        for (SBQQ__Quote__c q : [SELECT Id FROM SBQQ__Quote__c WHERE ApprovalStatus__c = 'Pending' AND Id IN :quoteIdSet]) {
            quoteIdToLock.add(q.Id);
        }
        
        if (quoteIdToLock != null && !quoteIdToLock.isEmpty()) {
            for (sbaa__Approval__c a : [SELECT Quote__c FROM sbaa__Approval__c WHERE Quote__c IN :quoteIdSet AND sbaa__Approver__r.sbaa__User__c = :UserInfo.getUserId()]) {
                quoteIdToLock.remove(a.Quote__c);
            }
            for (Id idToLock : quoteIdToLock) {
                for (SBQQ__QuoteLine__c ql : newQuoteLines) {
                    if (ql.SBQQ__Quote__c == idToLock) {
                        ql.SBQQ__Quote__c.addError('Pending Approval'); // prevent update
                    }
                }
            }
        }
    }
    
    private static void setParentBundle(List<SBQQ__QuoteLine__c> newQuoteLines, Map<Id, SBQQ__QuoteLine__c> oldQuoteLinesMap, Boolean isInsert) {
        //Set<Id> quoteIdSet = new Set<Id>();
        Set<Id> qlWithRequiredBy = new Set<Id>();
        for (SBQQ__QuoteLine__c ql : newQuoteLines) {
            SBQQ__QuoteLine__c oldQl = oldQuoteLinesMap != null ? oldQuoteLinesMap.get(ql.Id) : null;
            if (isInsert || (oldQl != null && ql.SBQQ__RequiredBy__c != oldQl.SBQQ__RequiredBy__c)) { // mdaolio 20230616 - Resetto ParentBundle se si tratta di insert (bug sul clona Quote)
                ql.SVG_ParentBundle__c = null;
            }
            
            if (ql.Bundle_Name__c != null && ql.Bundle_Name__c != '' && !ql.SVG_OfficeSoftwareForPrint__c && ql.SVG_ParentBundle__c == null && ql.SBQQ__RequiredBy__c != null) {
                //quoteIdSet.add(ql.Id);
                qlWithRequiredBy.add(ql.SBQQ__RequiredBy__c);
            }
        }
        
        //if (!isInsert && quoteIdSet != null && !quoteIdSet.isEmpty()) {
        if (qlWithRequiredBy != null && !qlWithRequiredBy.isEmpty()) {
            //Map<Id, SBQQ__QuoteLine__c> qlWithParents = new Map<Id, SBQQ__QuoteLine__c>([SELECT Id, SBQQ__Quote__c, SBQQ__Quote__r.SBQQ__Source__c, SBQQ__RequiredBy__c, SBQQ__RequiredBy__r.SBQQ__Quote__c, SBQQ__RequiredBy__r.SBQQ__RequiredBy__c, SBQQ__RequiredBy__r.SBQQ__RequiredBy__r.SBQQ__Quote__c, SBQQ__RequiredBy__r.SVG_OfficeSoftwareForPrint__c FROM SBQQ__QuoteLine__c WHERE Id IN :quoteIdSet]);
            Map<Id, SBQQ__QuoteLine__c> qlRequiredBy = new Map<Id, SBQQ__QuoteLine__c>([SELECT Id, SBQQ__RequiredBy__c, SVG_OfficeSoftwareForPrint__c FROM SBQQ__QuoteLine__c WHERE Id IN :qlWithRequiredBy]);
            for (SBQQ__QuoteLine__c ql : newQuoteLines) {
                //SBQQ__QuoteLine__c qlRef = qlWithParents.get(ql.Id);
                SBQQ__QuoteLine__c qlRequired = qlRequiredBy.get(ql.SBQQ__RequiredBy__c);
                //if (qlRef != null) {
                if (qlRequired != null) {
                    //if (qlRef.SBQQ__RequiredBy__r != null && qlRef.SBQQ__RequiredBy__r.SBQQ__RequiredBy__c != null && !qlRef.SBQQ__RequiredBy__r.SVG_OfficeSoftwareForPrint__c) {
                    if (qlRequired.SBQQ__RequiredBy__c != null && !qlRequired.SVG_OfficeSoftwareForPrint__c) {
                        ql.SVG_ParentBundle__c = qlRequired.SBQQ__RequiredBy__c;
                    } else {
                        ql.SVG_ParentBundle__c = qlRequired.Id;
                    }
                }
            }
        }
    }
    
      // DEPRECATED - mdaolio 20230619 - Spostata questa gestione nel custom script
//    private static void manageOptionalsFlag(List<SBQQ__QuoteLine__c> newQuoteLines, Map<Id, SBQQ__QuoteLine__c> oldQuoteLinesMap, Boolean isInsert) {
//        
//        Set<Id> bundles = new Set<Id>();
//        
//        if (newQuoteLines != null) {
//            // INSERT or UPDATES or UNDELETE
//            for (SBQQ__QuoteLine__c ql : newQuoteLines) {
//                if (ql.SBQQ__RequiredBy__c != null) {
//                    SBQQ__QuoteLine__c oldQl = oldQuoteLinesMap != null ? oldQuoteLinesMap.get(ql.Id) : null;
//                    Boolean optionalsRefresh = (oldQl == null && ql.OptionalLine__c) || (oldQl != null && ql.OptionalLine__c != oldQl.OptionalLine__c && (ql.OptionalLine__c || oldQl.OptionalLine__c));
//                    Boolean alternativeRefresh = (oldQl == null && ql.Alternative__c) || (oldQl != null && ql.Alternative__c != oldQl.Alternative__c && (ql.Alternative__c || oldQl.Alternative__c));
//                    if (optionalsRefresh || alternativeRefresh) {
//                    	bundles.add(ql.SBQQ__RequiredBy__c);
//                    }
//                }
//            }
//        } else {
//            // DELETE
//            for (SBQQ__QuoteLine__c ql : oldQuoteLinesMap.values()) {
//                Boolean optionalsRefresh = ql.SBQQ__RequiredBy__c != null && ql.OptionalLine__c;
//                Boolean alternativeRefresh = ql.SBQQ__RequiredBy__c != null && ql.Alternative__c;
//                if (optionalsRefresh || alternativeRefresh) {
//                    bundles.add(ql.SBQQ__RequiredBy__c);
//                }
//            }
//        }
//        
//        Map<Id, Set<SBQQ__QuoteLine__c>> optionalsByBundle = new Map<Id, Set<SBQQ__QuoteLine__c>>();
//        Map<Id, Set<SBQQ__QuoteLine__c>> alternativeByBundle = new Map<Id, Set<SBQQ__QuoteLine__c>>();
//        
//        Set<SBQQ__QuoteLine__c> qlToUpdate = new Set<SBQQ__QuoteLine__c>();
//        
//        // Cerco opzionali per ogni bundle
//        if (bundles != null && !bundles.isEmpty()) {
//            for (SBQQ__QuoteLine__c ql : [SELECT Id, SBQQ__RequiredBy__c FROM SBQQ__QuoteLine__c WHERE OptionalLine__c = true AND SBQQ__RequiredBy__c IN :bundles]) {
//                if (!optionalsByBundle.containsKey(ql.SBQQ__RequiredBy__c)) {
//                    optionalsByBundle.put(ql.SBQQ__RequiredBy__c, new Set<SBQQ__QuoteLine__c>());
//                }
//                Set<SBQQ__QuoteLine__c> optionals = optionalsByBundle.get(ql.SBQQ__RequiredBy__c);
//                optionals.add(ql);
//            }
//            // Cerco alternativi per ogni bundle
//            for (SBQQ__QuoteLine__c ql : [SELECT Id, SBQQ__RequiredBy__c FROM SBQQ__QuoteLine__c WHERE Alternative__c = true AND SBQQ__RequiredBy__c IN :bundles]) {
//                if (!alternativeByBundle.containsKey(ql.SBQQ__RequiredBy__c)) {
//                    alternativeByBundle.put(ql.SBQQ__RequiredBy__c, new Set<SBQQ__QuoteLine__c>());
//                }
//                Set<SBQQ__QuoteLine__c> alternatives = alternativeByBundle.get(ql.SBQQ__RequiredBy__c);
//                alternatives.add(ql);
//            }
//            
//            for (SBQQ__QuoteLine__c ql : [SELECT Id, SVG_HasOptionals__c, SVG_HasAlternatives__c FROM SBQQ__QuoteLine__c WHERE Id IN :bundles]) {
//                //List<SBQQ__QuoteLine__c> optionals = [SELECT Id FROM SBQQ__QuoteLine__c WHERE OptionalLine__c = true AND SBQQ__RequiredBy__c = :ql.Id];
//                //Boolean hasOptionals = optionals != null && !optionals.isEmpty();
//                
//                Set<SBQQ__QuoteLine__c> optionals = optionalsByBundle.get(ql.Id);
//                Boolean hasOptionals = optionals != null && !optionals.isEmpty();
//                if (ql.SVG_HasOptionals__c != hasOptionals) {
//                    /*if (isInsert) {
//    UpdateQLFutureHasOptionals(String.valueOf(ql.Id));
//    } else {*/
//                    ql.SVG_HasOptionals__c = hasOptionals;
//                    qlToUpdate.add(ql);
//                    //}
//                }
//                
//                Set<SBQQ__QuoteLine__c> alternatives = alternativeByBundle.get(ql.Id);
//                Boolean hasAlternatives = alternatives != null && !alternatives.isEmpty();
//                if (ql.SVG_HasAlternatives__c != hasAlternatives) {
//                    /*if (isInsert) {
//    UpdateQLFutureHasOptionals(String.valueOf(ql.Id));
//    } else {*/
//                    ql.SVG_HasAlternatives__c = hasAlternatives;
//                    qlToUpdate.add(ql);
//                    //}
//                }
//            }
//        }
//        
//        //if (!isInsert && qlToUpdate != null && !qlToUpdate.isEmpty()) {
//        if (qlToUpdate != null && !qlToUpdate.isEmpty()) {
//            List<SBQQ__QuoteLine__c> qlList = new List<SBQQ__QuoteLine__c>(qlToUpdate);
//            update qlList;
//        }
//    }
    
    /*
    @future
    private static void UpdateQLFutureHasOptionals(String qlId) {
        SBQQ__QuoteLine__c ql = [SELECT Id, SVG_HasOptionals__c FROM SBQQ__QuoteLine__c WHERE Id = :qlId];
        ql.SVG_HasOptionals__c = true;
        update ql;
    }*/
}