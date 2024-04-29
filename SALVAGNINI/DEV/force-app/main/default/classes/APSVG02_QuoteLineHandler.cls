public class APSVG02_QuoteLineHandler {
    
    //CB CHECK RICORSIONE
    public static boolean recursion = false;
    
    public static void handleTrigger(List<SBQQ__QuoteLine__c> newQuoteLines, Map<Id, SBQQ__QuoteLine__c> oldQuoteLinesMap, System.TriggerOperation triggerEvent) {
        
        switch on triggerEvent {

            when BEFORE_INSERT {
                lockRecordWhilePendingApproval(newQuoteLines);
            }

            when BEFORE_UPDATE {
                lockRecordWhilePendingApproval(newQuoteLines);
                
                setParentBundle(newQuoteLines);
            }

            when AFTER_INSERT {
                manageOptionalsFlag(newQuoteLines, oldQuoteLinesMap, true);
            }

            // 
            when AFTER_UPDATE {
                manageOptionalsFlag(newQuoteLines, oldQuoteLinesMap, false);
            }
            when AFTER_DELETE {
                manageOptionalsFlag(newQuoteLines, oldQuoteLinesMap, false);
            }
            when AFTER_UNDELETE {
                manageOptionalsFlag(newQuoteLines, oldQuoteLinesMap, false);
            }
            when else {
                //do nothing for other events
            }
            
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
    
    private static void setParentBundle(List<SBQQ__QuoteLine__c> newQuoteLines) {
        Set<Id> quoteIdSet = new Set<Id>();
        for (SBQQ__QuoteLine__c ql : newQuoteLines) {
            if (ql.Bundle_Name__c != null && ql.Bundle_Name__c != '' && !ql.SVG_OfficeSoftwareForPrint__c && ql.SVG_ParentBundle__c == null) {
                quoteIdSet.add(ql.Id);
            }
        }
        
        if (quoteIdSet != null && !quoteIdSet.isEmpty()) {
            Map<Id, SBQQ__QuoteLine__c> qlWithParents = new Map<Id, SBQQ__QuoteLine__c>([SELECT Id, SBQQ__RequiredBy__c, SBQQ__RequiredBy__r.SBQQ__RequiredBy__c, SBQQ__RequiredBy__r.SVG_OfficeSoftwareForPrint__c FROM SBQQ__QuoteLine__c WHERE Id IN :quoteIdSet]);
            for (SBQQ__QuoteLine__c ql : newQuoteLines) {
                SBQQ__QuoteLine__c qlRef = qlWithParents.get(ql.Id);
                if (qlRef != null) {
                    if (qlRef.SBQQ__RequiredBy__r != null && qlRef.SBQQ__RequiredBy__r.SBQQ__RequiredBy__c != null && !qlRef.SBQQ__RequiredBy__r.SVG_OfficeSoftwareForPrint__c) {
                        ql.SVG_ParentBundle__c = qlRef.SBQQ__RequiredBy__r.SBQQ__RequiredBy__c;
                    } else {
                        ql.SVG_ParentBundle__c = qlRef.SBQQ__RequiredBy__c;
                    }
                }
            }
        }
    }
    
    private static void manageOptionalsFlag(List<SBQQ__QuoteLine__c> newQuoteLines, Map<Id, SBQQ__QuoteLine__c> oldQuoteLinesMap, Boolean isInsert) {
        
        Set<Id> bundles = new Set<Id>();
        
        if (newQuoteLines != null) {
            // INSERT or UPDATES or UNDELETE
            for (SBQQ__QuoteLine__c ql : newQuoteLines) {
                if (ql.SBQQ__RequiredBy__c != null) {
                    SBQQ__QuoteLine__c oldQl = oldQuoteLinesMap != null ? oldQuoteLinesMap.get(ql.Id) : null;
                    Boolean optionalsRefresh = (oldQl == null && ql.OptionalLine__c) || (oldQl != null && ql.OptionalLine__c != oldQl.OptionalLine__c && (ql.OptionalLine__c || oldQl.OptionalLine__c));
                    Boolean alternativeRefresh = (oldQl == null && ql.Alternative__c) || (oldQl != null && ql.Alternative__c != oldQl.Alternative__c && (ql.Alternative__c || oldQl.Alternative__c));
                    if (optionalsRefresh || alternativeRefresh) {
                    	bundles.add(ql.SBQQ__RequiredBy__c);
                    }
                }
            }
        } else {
            // DELETE
            for (SBQQ__QuoteLine__c ql : oldQuoteLinesMap.values()) {
                Boolean optionalsRefresh = ql.SBQQ__RequiredBy__c != null && ql.OptionalLine__c;
                Boolean alternativeRefresh = ql.SBQQ__RequiredBy__c != null && ql.Alternative__c;
                if (optionalsRefresh || alternativeRefresh) {
                    bundles.add(ql.SBQQ__RequiredBy__c);
                }
            }
        }
        
        Map<Id, Set<SBQQ__QuoteLine__c>> optionalsByBundle = new Map<Id, Set<SBQQ__QuoteLine__c>>();
        Map<Id, Set<SBQQ__QuoteLine__c>> alternativeByBundle = new Map<Id, Set<SBQQ__QuoteLine__c>>();
        
        Set<SBQQ__QuoteLine__c> qlToUpdate = new Set<SBQQ__QuoteLine__c>();
        
        // Cerco opzionali per ogni bundle
        if (bundles != null && !bundles.isEmpty()) {
            for (SBQQ__QuoteLine__c ql : [SELECT Id, SBQQ__RequiredBy__c FROM SBQQ__QuoteLine__c WHERE OptionalLine__c = true AND SBQQ__RequiredBy__c IN :bundles]) {
                if (!optionalsByBundle.containsKey(ql.SBQQ__RequiredBy__c)) {
                    optionalsByBundle.put(ql.SBQQ__RequiredBy__c, new Set<SBQQ__QuoteLine__c>());
                }
                Set<SBQQ__QuoteLine__c> optionals = optionalsByBundle.get(ql.SBQQ__RequiredBy__c);
                optionals.add(ql);
            }
            // Cerco alternativi per ogni bundle
            for (SBQQ__QuoteLine__c ql : [SELECT Id, SBQQ__RequiredBy__c FROM SBQQ__QuoteLine__c WHERE Alternative__c = true AND SBQQ__RequiredBy__c IN :bundles]) {
                if (!alternativeByBundle.containsKey(ql.SBQQ__RequiredBy__c)) {
                    alternativeByBundle.put(ql.SBQQ__RequiredBy__c, new Set<SBQQ__QuoteLine__c>());
                }
                Set<SBQQ__QuoteLine__c> alternatives = alternativeByBundle.get(ql.SBQQ__RequiredBy__c);
                alternatives.add(ql);
            }
            
            for (SBQQ__QuoteLine__c ql : [SELECT Id, SVG_HasOptionals__c, SVG_HasAlternatives__c FROM SBQQ__QuoteLine__c WHERE Id IN :bundles]) {
                //List<SBQQ__QuoteLine__c> optionals = [SELECT Id FROM SBQQ__QuoteLine__c WHERE OptionalLine__c = true AND SBQQ__RequiredBy__c = :ql.Id];
                //Boolean hasOptionals = optionals != null && !optionals.isEmpty();
                
                Set<SBQQ__QuoteLine__c> optionals = optionalsByBundle.get(ql.Id);
                Boolean hasOptionals = optionals != null && !optionals.isEmpty();
                if (ql.SVG_HasOptionals__c != hasOptionals) {
                    /*if (isInsert) {
    UpdateQLFutureHasOptionals(String.valueOf(ql.Id));
    } else {*/
                    ql.SVG_HasOptionals__c = hasOptionals;
                    qlToUpdate.add(ql);
                    //}
                }
                
                Set<SBQQ__QuoteLine__c> alternatives = alternativeByBundle.get(ql.Id);
                Boolean hasAlternatives = alternatives != null && !alternatives.isEmpty();
                if (ql.SVG_HasAlternatives__c != hasAlternatives) {
                    /*if (isInsert) {
    UpdateQLFutureHasOptionals(String.valueOf(ql.Id));
    } else {*/
                    ql.SVG_HasAlternatives__c = hasAlternatives;
                    qlToUpdate.add(ql);
                    //}
                }
            }
        }
        
        //if (!isInsert && qlToUpdate != null && !qlToUpdate.isEmpty()) {
        if (qlToUpdate != null && !qlToUpdate.isEmpty()) {
            List<SBQQ__QuoteLine__c> qlList = new List<SBQQ__QuoteLine__c>(qlToUpdate);
            update qlList;
        }
    }
    
    /*
    @future
    private static void UpdateQLFutureHasOptionals(String qlId) {
        SBQQ__QuoteLine__c ql = [SELECT Id, SVG_HasOptionals__c FROM SBQQ__QuoteLine__c WHERE Id = :qlId];
        ql.SVG_HasOptionals__c = true;
        update ql;
    }*/

}