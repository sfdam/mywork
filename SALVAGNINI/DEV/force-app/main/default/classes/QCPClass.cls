global with sharing class QCPClass implements SBQQ.QuoteCalculatorPlugin, SBQQ.QuoteCalculatorPlugin2 {

    /* NOTE: the getReferencedFields method is no longer required if you use the ReferencedFields field set on
 the Quote Line object. 
             This field set must be created as it's not a managed one.
       NOTE: if you need to access Quote fields, you can create the ReferencedFields field set on the Quote object as well.
       NOTE: if you do not use the getReferencedFields method, you can remove SBQQ.QuoteCalculatorPlugin2 from the class declaration.
    */
    global Set<String> getReferencedFields() {
        return new Set<String>{
            /* Note: add fields using the following format - Only add fields referenced
                               
               by the plugin and not in the Line Editor field set on the Quote Line object
            String.valueOf(SBQQ__QuoteLine__c.My_Field_API_Name__c)
            */
            String.valueOf(SBQQ__QuoteLine__c.Package_Transport__c),
            
            String.valueOf(SBQQ__QuoteLine__c.Transportation_Price__c),
            String.valueOf(SBQQ__QuoteLine__c.SBQQ__PriorQuantity__c),
            String.valueOf(SBQQ__QuoteLine__c.SBQQ__PricingMethod__c),
            String.valueOf(SBQQ__QuoteLine__c.SBQQ__DiscountScheduleType__c),
            String.valueOf(SBQQ__QuoteLine__c.SBQQ__Renewal__c),
            String.valueOf(SBQQ__QuoteLine__c.SBQQ__Existing__c),
            String.valueOf(SBQQ__QuoteLine__c.SBQQ__SubscriptionPricing__c)
        };
    }

    global void onBeforePriceRules(SObject quote, SObject[] lines) {
    }
    
    global void onAfterPriceRules(SObject quote, SObject[] lines) {
    }
    
    global void onBeforeCalculate(SObject quote, SObject[] lines) {
    }
    
    global void onAfterCalculate(SObject quote, SObject[] lines) {
        for(SObject line : lines) {
            SObject parent = line.getSObject(SBQQ__QuoteLine__c.SBQQ__RequiredBy__c.getDescribe().getRelationshipName());
            if(parent != null) {
              Decimal pComponentCustomTotal = (Decimal)parent.get(String.valueOf(SBQQ__QuoteLine__c.Package_Transport__c));
              
              Decimal cListPrice = (Decimal)line.get(String.valueOf(SBQQ__QuoteLine__c.Transportation_Price__c));
              Decimal cQuantity = (Decimal)line.get(String.valueOf(SBQQ__QuoteLine__c.SBQQ__Quantity__c));
              Decimal cPriorQuantity = (Decimal)line.get(String.valueOf(SBQQ__QuoteLine__c.SBQQ__PriorQuantity__c));
              String cPricingMethod = (String)line.get(String.valueOf(SBQQ__QuoteLine__c.SBQQ__PricingMethod__c));
              String cDiscountScheduleType = (String)line.get(String.valueOf(SBQQ__QuoteLine__c.SBQQ__DiscountScheduleType__c));
              Boolean cRenewal = (Boolean)line.get(String.valueOf(SBQQ__QuoteLine__c.SBQQ__Renewal__c));
              Boolean cExisting = (Boolean)line.get(String.valueOf(SBQQ__QuoteLine__c.SBQQ__Existing__c));
              String cSubscriptionPricing = (String)line.get(String.valueOf(SBQQ__QuoteLine__c.SBQQ__SubscriptionPricing__c));
              
              pComponentCustomTotal = (pComponentCustomTotal == null) ? 0 : pComponentCustomTotal;
              
              cListPrice = (cListPrice == null) ? 0 : cListPrice;
              cQuantity = (cQuantity == null) ? 1 : cQuantity;
              cPriorQuantity = (cPriorQuantity == null) ? 0 : cPriorQuantity;
              cPricingMethod = (cPricingMethod == null) ? 'List' : cPricingMethod;
              cDiscountSCheduleType = (cDiscountSCheduleType == null) ? '' : cDiscountSCheduleType;
              cRenewal = (cRenewal == null) ? false : cRenewal;
              cExisting = (cExisting == null) ? false : cExisting;
              cSubscriptionPricing = (cSubscriptionPricing == null) ? '' : cSubscriptionPricing;
              
              Decimal cTotalPrice = getTotal(cListPrice, cQuantity, cPriorQuantity, cPricingMethod, cDiscountScheduleType, cRenewal, cExisting, cSubscriptionPricing, cListPrice);
              pComponentCustomTotal += cTotalPrice;
              
              parent.put(SBQQ__QuoteLine__c.Package_Transport__c, pComponentCustomTotal);
              
            }
        }
    }
    
    global void onInit(SObject[] lines) {
        for(SObject line : lines) {
            line.put(SBQQ__QuoteLine__c.Package_Transport__c, 0);
        }
    }
    
    private Decimal getTotal(Decimal price, Decimal quantity, Decimal priorQuantity, String pricingMethod, String discountScheduleType, Boolean renewal, Boolean existing, String subscriptionPricing, Decimal ListPrice) {
        price = (price == null) ? 0 : price;
        renewal = (renewal == null) ? false : renewal;
        existing = (existing == null) ? false : existing;
        
        if(renewal == true && existing == false && priorQuantity == null) {
            return 0;
        } else {
            return price * getEffectiveQuantity(quantity, priorQuantity, pricingMethod, discountScheduleType, renewal, existing, subscriptionPricing, listPrice);
        }
        
    }
    
    private Decimal getEffectiveQuantity(Decimal quantity, Decimal priorQuantity, String pricingMethod, String discountScheduleType, Boolean renewal, Boolean existing, String subscriptionPricing, Decimal ListPrice) {
        Decimal result = 0;
        Decimal deltaQuantity = 0;
        
        quantity = (quantity == null) ? 0 : quantity;
        priorQuantity = (priorQuantity == null) ? 0 : priorQuantity;
        pricingMethod = (pricingMethod == null) ? '' : pricingMethod;
        discountScheduleType = (discountScheduleType == null) ? '' : discountScheduleType;
        subscriptionPricing = (subscriptionPricing == null) ? '' : subscriptionPricing;
        renewal = (renewal == null) ? false : renewal;
        existing = (existing == null) ? false : existing;
        listPrice = (listPrice == null) ? 0 : listPrice;
        
        deltaQuantity = quantity - priorQuantity;
        
        if(pricingMethod == 'Block' && deltaQuantity == 0) {
            result = 0;
        } else {
            if(pricingMethod == 'Block') {
                result = 1;
            } else {
                if(discountScheduleType == 'Slab' && (deltaQuantity == 0 || (quantity == 0 && renewal == true))) {
                    result = 0;
                } else {
                    if(discountScheduleType == 'Slab') {
                        result = 1;
                    } else {
                        if(existing == true && subscriptionPricing == '' && deltaQuantity < 0) {
                            result = 0;
                        } else {
                            if(existing == true && subscriptionPricing == 'Percent Of Total' && listPrice != 0 && deltaQuantity >= 0) {
                                result = quantity;
                            } else {
                                if(existing == true) {
                                    result = deltaQuantity;
                                } else {
                                    result = quantity;
                                }
                            }
                        }
                    }
                }
            }
        }
        
        return result;
    }
    
}