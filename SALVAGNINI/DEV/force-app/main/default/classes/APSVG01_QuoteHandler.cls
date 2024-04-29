public class APSVG01_QuoteHandler {
    
    //CB CHECK RICORSIONE
    public static boolean recursion = false;
    
    public static void handleTrigger(List<SBQQ__Quote__c> newQuotes, Map<Id, SBQQ__Quote__c> oldQuotesMap, System.TriggerOperation triggerEvent) {
        
        switch on triggerEvent {

            when BEFORE_INSERT {
                
                setPrintLabelDefaults_BeforeInsert(newQuotes);
                    
                manageLanguageChange(newQuotes, oldQuotesMap);
                
                manageLegalInfo(newQuotes, oldQuotesMap);
                
            }

            when BEFORE_UPDATE {
                manageStatusChange(newQuotes, oldQuotesMap);
                
                lockRecordWhilePendingApproval(newQuotes);
                
                manageLanguageChange(newQuotes, oldQuotesMap);
                
                manageOrderOCSignature(newQuotes, oldQuotesMap);
                
                manageLegalInfo(newQuotes, oldQuotesMap);
            }

            when AFTER_INSERT {
            }

            // 
            when AFTER_UPDATE {
                autoStartApprovalProcess(newQuotes);
            }
            when else {
                //do nothing for other events
            }
        }
        
    }
    
    private static void manageStatusChange(List<SBQQ__Quote__c> newQuotes, Map<Id, SBQQ__Quote__c> oldQuotesMap) {
        for (SBQQ__Quote__c q : newQuotes) {
            SBQQ__Quote__c oldQ = oldQuotesMap.get(q.Id);
            if (oldQ == null || q.ApprovalStatus__c != oldQ.ApprovalStatus__c) {
                if (q.ApprovalStatus__c == 'Pending' && q.SBQQ__Status__c != 'Approval') {
                    q.SBQQ__Status__c = 'Approval';
                }
                if (q.ApprovalStatus__c == 'Rejected' && q.SBQQ__Status__c != 'Review') {
                    q.SBQQ__Status__c = 'Review';
                }
                if (q.ApprovalStatus__c == 'Approved' && q.SBQQ__Status__c != 'Approved') {
                    q.SBQQ__Status__c = 'Approved';
                }
            }
            
            // Blocco cambi di stato se non è stata richiesta l'approvazione
            if (oldQ == null || q.SBQQ__Status__c != oldQ.SBQQ__Status__c) {
                /*if (q.SBQQ__Status__c != 'Draft' && q.SBQQ__Status__c != 'Approval') {
                    if (q.ApprovalStatus__c != 'Approved') {
                        q.SBQQ__Status__c.addError('Please submit Quote for approval');
                    }
                }*/
                if (q.SBQQ__Status__c == 'Draft') { // Non è mai concesso tornare a Draft
                    q.SBQQ__Status__c.addError('Status not permitted');
                } else if (q.SBQQ__Status__c == 'Approval') { // Non è mai concesso tornare a Draft
                    if (q.ApprovalStatus__c != 'Pending') { // Ma se lo stato approvazione è Pending significa che ci è andato per via del processo
                    	q.SBQQ__Status__c.addError('Please submit Quote for approval');
                    }
                } else if (q.SBQQ__Status__c == 'Approved') {
                    if ((oldQ.SBQQ__Status__c != 'Approval' && oldQ.SBQQ__Status__c != 'Draft') || q.ApprovalStatus__c != 'Approved') { // Solo da Approval si può andare verso Approved (ma solo se è stata approvata)
                        q.SBQQ__Status__c.addError('Please submit Quote for approval');
                    }
                }  else if (q.SBQQ__Status__c == 'Review') {
                    if (oldQ.SBQQ__Status__c != 'Approval' || q.ApprovalStatus__c != 'Rejected') { // Solo da Approval si può andare verso Approved (ma solo se è stata rifiutata)
                        q.SBQQ__Status__c.addError('Status not permitted');
                    }
                } else if (q.SBQQ__Status__c == 'Presented') {
                    if (oldQ.SBQQ__Status__c != 'Approved') { // Solo da Approved si può andare verso Presented
                        q.SBQQ__Status__c.addError('Please submit Quote for approval');
                    }
                } else if (q.SBQQ__Status__c == 'Canceled') {
                    if (oldQ.SBQQ__Status__c != 'Draft' && oldQ.SBQQ__Status__c != 'Approved') { // Solo da Draft o Approved si può andare verso Canceled
                        q.SBQQ__Status__c.addError('Status not permitted');
                    }
                } 
            }
        }
    }
    
    private static void lockRecordWhilePendingApproval(List<SBQQ__Quote__c> newQuotes) {
        List<User> isUserAdmin = [SELECT Name FROM User WHERE Profile.PermissionsModifyAllData = true AND Id = :UserInfo.getUserId()];
        if (isUserAdmin != null && !isUserAdmin.isEmpty()) {
            return;
        }
        
        Set<Id> quoteIdSet = new Set<Id>();
        Set<Id> quoteIdToLock = new Set<Id>();
        for (SBQQ__Quote__c q : newQuotes) {
            if (q.ApprovalStatus__c == 'Pending') {
            	quoteIdSet.add(q.Id);
                quoteIdToLock.add(q.Id);
            }
        }
        if (quoteIdSet != null && !quoteIdSet.isEmpty()) {
            for (sbaa__Approval__c a : [SELECT Quote__c FROM sbaa__Approval__c WHERE Quote__c IN :quoteIdSet AND sbaa__Approver__r.sbaa__User__c = :UserInfo.getUserId()]) {
                quoteIdToLock.remove(a.Quote__c);
            }
            for (Id idToLock : quoteIdToLock) {
                for (SBQQ__Quote__c q : newQuotes) {
                    if (q.Id == idToLock) {
                        q.SBQQ__Status__c.addError('Pending Approval'); // prevent update
                    }
                }
            }
        }
    }
    
    private static void autoStartApprovalProcess(List<SBQQ__Quote__c> newQuotes) {
        for (SBQQ__Quote__c q : newQuotes) {
            if (q.SBQQ__Status__c == 'Approval' && q.ApprovalStatus__c != 'Pending') {
                system.debug('Auto starting approval');
                SBAA.ApprovalAPI.submit(q.Id, SBAA__Approval__c.Quote__c);
            }
        }
    }
    
    private static void manageLanguageChange(List<SBQQ__Quote__c> newQuotes, Map<Id, SBQQ__Quote__c> oldQuotesMap) {
        Set<String> langSet = new Set<String>();
        Set<SBQQ__Quote__c> quotePrimaryLang = new Set<SBQQ__Quote__c>();
        Set<SBQQ__Quote__c> quoteSecondaryLang = new Set<SBQQ__Quote__c>();
        
        for (SBQQ__Quote__c q : newQuotes) {
            // Primary Language
            SBQQ__Quote__c oldQ = oldQuotesMap != null ? oldQuotesMap.get(q.Id) : null;
            if (oldQ == null || q.SBQQ__QuoteLanguage__c != oldQ.SBQQ__QuoteLanguage__c || q.SBQQ__Type__c != oldQ.SBQQ__Type__c || q.SVG_IsSalesProposal__c != oldQ.SVG_IsSalesProposal__c) {
                langSet.add(q.SBQQ__QuoteLanguage__c);
                quotePrimaryLang.add(q);
            }
            
            // Secondary Language
            if (oldQ == null || q.Quote_Secondary_Language__c != oldQ.Quote_Secondary_Language__c || q.SBQQ__Type__c != oldQ.SBQQ__Type__c || q.SVG_IsSalesProposal__c != oldQ.SVG_IsSalesProposal__c) {
                langSet.add(q.Quote_Secondary_Language__c);
                quoteSecondaryLang.add(q);
            }
        }
        if (langSet != null && !langSet.isEmpty()) {
            Map<String, SVG_Print_Language__c> languageMaps = new Map<String, SVG_Print_Language__c>();
            for (SVG_Print_Language__c l : [SELECT Id, Language__c, PrefaceDescription__c, FirstPageQuotationLabel__c, FirstPageOrderConfirmation_Label__c, FirstPageSalesProposalLabel__c FROM SVG_Print_Language__c WHERE Language__c IN :langSet]) {
                languageMaps.put(l.Language__c, l);
            }
            
            for (SBQQ__Quote__c q : quotePrimaryLang) {
                SVG_Print_Language__c lang = languageMaps.get(q.SBQQ__QuoteLanguage__c);
                if (lang != null) {
                    q.Print_Language__c = lang.Id;
                    q.SVG_PrimaryLanguageIntroduction__c = lang.PrefaceDescription__c;
                    if (q.SBQQ__Type__c == 'Quote') {
                        q.SVG_PrintTitleTranslation__c = lang.FirstPageQuotationLabel__c;
                    } else if (!q.SVG_IsSalesProposal__c) {
                        q.SVG_PrintTitleTranslation__c = lang.FirstPageOrderConfirmation_Label__c;
                    } else {
                        q.SVG_PrintTitleTranslation__c = lang.FirstPageSalesProposalLabel__c;
                    }
                }
            }
            
            for (SBQQ__Quote__c q : quoteSecondaryLang) {
                SVG_Print_Language__c lang = languageMaps.get(q.Quote_Secondary_Language__c);
                if (lang != null) {
                    q.SVG_SecondaryPrintLanguage__c = lang.Id;
                    q.SVG_SecondaryLanguageIntroduction__c = lang.PrefaceDescription__c;
                    if (q.SBQQ__Type__c == 'Quote') {
                        q.SVG_PrintTitleTranslation2__c = lang.FirstPageQuotationLabel__c;
                    } else if (!q.SVG_IsSalesProposal__c) {
                        q.SVG_PrintTitleTranslation2__c = lang.FirstPageOrderConfirmation_Label__c;
                    } else {
                        q.SVG_PrintTitleTranslation2__c = lang.FirstPageSalesProposalLabel__c;
                    }
                }
            }
        }
        
        
        
        // Traduzioni Labels
        Set<Id> langIdSet = new Set<Id>();
        Set<Id> labelPrimarySet = new Set<Id>();
        Set<SBQQ__Quote__c> quotePrimaryLabels = new Set<SBQQ__Quote__c>();
        Set<SBQQ__Quote__c> quoteSecondaryLabels = new Set<SBQQ__Quote__c>();
        
        for (SBQQ__Quote__c q : newQuotes) {
            SBQQ__Quote__c oldQ = oldQuotesMap != null ? oldQuotesMap.get(q.Id) : null;
            
            // Primary Language
            if (oldQ == null || q.SVG_BundleLabelLk__c != oldQ.SVG_BundleLabelLk__c) {
                quotePrimaryLang.add(q);
                langIdSet.add(q.Print_Language__c);
                labelPrimarySet.add(q.SVG_BundleLabelLk__c);
                quotePrimaryLabels.add(q);
            }
            if (oldQ == null || q.SVG_DiscountLabelLk__c != oldQ.SVG_DiscountLabelLk__c) {
                quotePrimaryLang.add(q);
                langIdSet.add(q.Print_Language__c);
                labelPrimarySet.add(q.SVG_DiscountLabelLk__c);
                quotePrimaryLabels.add(q);
            }
            if (oldQ == null || q.SVG_DiscountBundleLabelLk__c != oldQ.SVG_DiscountBundleLabelLk__c) {
                quotePrimaryLang.add(q);
                langIdSet.add(q.Print_Language__c);
                labelPrimarySet.add(q.SVG_DiscountBundleLabelLk__c);
                quotePrimaryLabels.add(q);
            }
            if (oldQ == null || q.SVG_DiscountTotalLabelLk__c != oldQ.SVG_DiscountTotalLabelLk__c) {
                quotePrimaryLang.add(q);
                langIdSet.add(q.Print_Language__c);
                labelPrimarySet.add(q.SVG_DiscountTotalLabelLk__c);
                quotePrimaryLabels.add(q);
            }
            if (oldQ == null || q.SVG_TotalLabelLk__c != oldQ.SVG_TotalLabelLk__c) {
                quotePrimaryLang.add(q);
                langIdSet.add(q.Print_Language__c);
                labelPrimarySet.add(q.SVG_TotalLabelLk__c);
                quotePrimaryLabels.add(q);
            }
            
            // Secondary Language
            if (oldQ == null || q.SVG_BundleLabelLk__c != oldQ.SVG_BundleLabelLk__c) {
                quoteSecondaryLang.add(q);
                langIdSet.add(q.SVG_SecondaryPrintLanguage__c);
                labelPrimarySet.add(q.SVG_BundleLabelLk__c);
                quoteSecondaryLabels.add(q);
            }
            if (oldQ == null || q.SVG_DiscountLabelLk__c != oldQ.SVG_DiscountLabelLk__c) {
                quoteSecondaryLang.add(q);
                langIdSet.add(q.SVG_SecondaryPrintLanguage__c);
                labelPrimarySet.add(q.SVG_DiscountLabelLk__c);
                quoteSecondaryLabels.add(q);
            }
            if (oldQ == null || q.SVG_DiscountBundleLabelLk__c != oldQ.SVG_DiscountBundleLabelLk__c) {
                quoteSecondaryLang.add(q);
                langIdSet.add(q.SVG_SecondaryPrintLanguage__c);
                labelPrimarySet.add(q.SVG_DiscountBundleLabelLk__c);
                quoteSecondaryLabels.add(q);
            }
            if (oldQ == null || q.SVG_DiscountTotalLabelLk__c != oldQ.SVG_DiscountTotalLabelLk__c) {
                quoteSecondaryLang.add(q);
                langIdSet.add(q.SVG_SecondaryPrintLanguage__c);
                labelPrimarySet.add(q.SVG_DiscountTotalLabelLk__c);
                quoteSecondaryLabels.add(q);
            }
            if (oldQ == null || q.SVG_TotalLabelLk__c != oldQ.SVG_TotalLabelLk__c) {
                quoteSecondaryLang.add(q);
                langIdSet.add(q.SVG_SecondaryPrintLanguage__c);
                labelPrimarySet.add(q.SVG_TotalLabelLk__c);
                quoteSecondaryLabels.add(q);
            }
        }
        if (langIdSet != null && !langIdSet.isEmpty() && labelPrimarySet != null && !labelPrimarySet.isEmpty()) {
            Map<Id, Map<Id, SVG_Label_Translation__c>> languageMaps = new Map<Id, Map<Id, SVG_Label_Translation__c>>();
            for (SVG_Label_Translation__c lt : [SELECT Id, PrintLanguage__c, Print_Label__c, Name FROM SVG_Label_Translation__c WHERE PrintLanguage__c IN :langIdSet AND Print_Label__c IN :labelPrimarySet]) {
                //Map<String, SVG_Label_Translation__c> labelsMap = languageMaps.get(lt.PrintLanguage__c);
                if (!languageMaps.containsKey(lt.PrintLanguage__c)) {
                    Map<Id, SVG_Label_Translation__c> lm = new Map<Id, SVG_Label_Translation__c>();
                    languageMaps.put(lt.PrintLanguage__c, lm);
                }
                
                Map<Id, SVG_Label_Translation__c> labelsMap = languageMaps.get(lt.PrintLanguage__c);
                
                if (!labelsMap.containsKey(lt.Print_Label__c)) {
                    labelsMap.put(lt.Print_Label__c, lt);
                }
            }
            
            for (SBQQ__Quote__c q : quotePrimaryLabels) {
                Map<Id, SVG_Label_Translation__c> labelsMap = languageMaps.get(q.Print_Language__c);
                if (labelsMap != null) {
                    SVG_Label_Translation__c lBundle = labelsMap.get(q.SVG_BundleLabelLk__c);
                    if (lBundle != null) {
                    	q.SVG_BundleLabelTranslationLk__c = lBundle.Name;
                    }
                    SVG_Label_Translation__c lDiscount = labelsMap.get(q.SVG_DiscountLabelLk__c);
                    if (lDiscount != null) {
                    	q.SVG_DiscountLabelTranslation__c = lDiscount.Name;
                    }
                    SVG_Label_Translation__c lDiscountB = labelsMap.get(q.SVG_DiscountBundleLabelLk__c);
                    if (lDiscountB != null) {
                    	q.SVG_DiscountBundleLabelTranslation__c = lDiscountB.Name;
                    }
                    SVG_Label_Translation__c lDiscountT = labelsMap.get(q.SVG_DiscountTotalLabelLk__c);
                    if (lDiscountT != null) {
                    	q.SVG_DiscountTotalLabelTranslation__c = lDiscountT.Name;
                    }
                    SVG_Label_Translation__c lTotal = labelsMap.get(q.SVG_TotalLabelLk__c);
                    if (lTotal != null) {
                    	q.SVG_TotalLabelTranslation__c = lTotal.Name;
                    }
                }
            }
            
            for (SBQQ__Quote__c q : quoteSecondaryLang) {
                Map<Id, SVG_Label_Translation__c> labelsMap = languageMaps.get(q.SVG_SecondaryPrintLanguage__c);
                if (labelsMap != null) {
                    SVG_Label_Translation__c lBundle = labelsMap.get(q.SVG_BundleLabelLk__c);
                    if (lBundle != null) {
                    	q.SVG_BundleLabelTranslation2__c = lBundle.Name;
                    }
                    SVG_Label_Translation__c lDiscount = labelsMap.get(q.SVG_DiscountLabelLk__c);
                    if (lDiscount != null) {
                    	q.SVG_DiscountLabelTranslation2__c = lDiscount.Name;
                    }
                    SVG_Label_Translation__c lDiscountB = labelsMap.get(q.SVG_DiscountBundleLabelLk__c);
                    if (lDiscountB != null) {
                    	q.SVG_DiscountedBundleLabelTranslation2__c = lDiscountB.Name;
                    }
                    SVG_Label_Translation__c lDiscountT = labelsMap.get(q.SVG_DiscountTotalLabelLk__c);
                    if (lDiscountT != null) {
                    	q.SVG_DiscountedTotalLabelTranslation2__c = lDiscountT.Name;
                    }
                    SVG_Label_Translation__c lTotal = labelsMap.get(q.SVG_TotalLabelLk__c);
                    if (lTotal != null) {
                    	q.SVG_FinalTotalLabelTranslation2__c = lTotal.Name;
                    }
                }
            }
        }
    }
    
    private static void setPrintLabelDefaults_BeforeInsert(List<SBQQ__Quote__c> newQuotes) {
        Map<String, Id> defaultLabels = new Map<String, Id>();
        for (SVG_Print_Label__c pl : [SELECT Id, Category__c FROM SVG_Print_Label__c WHERE Default__c = true]) {
            if (!defaultLabels.containsKey(pl.Category__c)) {
                defaultLabels.put(pl.Category__c, pl.Id);
            }
        }
        
        for (SBQQ__Quote__c q : newQuotes) {
            q.SVG_BundleLabelLk__c = defaultLabels.get('TL');
            q.SVG_DiscountLabelLk__c = defaultLabels.get('DL');
            q.SVG_DiscountBundleLabelLk__c = defaultLabels.get('FL');
            q.SVG_DiscountTotalLabelLk__c = defaultLabels.get('FQ');
            q.SVG_TotalLabelLk__c = defaultLabels.get('TQ');
        }
    }
    
    private static void manageOrderOCSignature(List<SBQQ__Quote__c> newQuotes, Map<Id, SBQQ__Quote__c> oldQuotesMap) {
        for (SBQQ__Quote__c q : newQuotes) {
            SBQQ__Quote__c oldQ = oldQuotesMap.get(q.Id);
            if (oldQ == null || q.SBQQ__Type__c != oldQ.SBQQ__Type__c || q.Main_Contractor__c != oldQ.Main_Contractor__c || q.Total_Order_Price__c != oldQ.Total_Order_Price__c) {
                if (q.SBQQ__Type__c != 'Quote') {
                    List<SVG_OC_Signature__c> signatures = [SELECT Id, MainContractor__c, Type__c, ManagerJobTitle__c, ManagerName__c FROM SVG_OC_Signature__c WHERE MainContractor__c = :q.Main_Contractor__c OR (MainContractor__c = NULL AND Type__c <> NULL)];
                    if (signatures != null) {
                        Boolean signatureFound = false;
                        for (SVG_OC_Signature__c sig : signatures) {
                            if (q.Main_Contractor__c != null && q.Main_Contractor__c == sig.MainContractor__c) {
                                q.SVG_OCSignature__c = sig.Id;
                                q.SVG_ManagerJobTitle__c = sig.ManagerJobTitle__c;
                                q.SVG_ManagerName__c = sig.ManagerName__c;
                                signatureFound = true;
                                break;
                            }
                        }
                        
                        if (!signatureFound) {
                            String typeToFind = q.Total_Order_Price__c <= 1500000 && q.EU_Country__c ? 'Europe1M5' : 'Other';
                            for (SVG_OC_Signature__c sig : signatures) {
                                if (sig.MainContractor__c == null && sig.Type__c == typeToFind) {
                                    q.SVG_OCSignature__c = sig.Id;
                                    q.SVG_ManagerJobTitle__c = sig.ManagerJobTitle__c;
                                    q.SVG_ManagerName__c = sig.ManagerName__c;
                                    signatureFound = true;
                                    break;
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    private static void manageLegalInfo(List<SBQQ__Quote__c> newQuotes, Map<Id, SBQQ__Quote__c> oldQuotesMap) {
        for (SBQQ__Quote__c q : newQuotes) {
            SBQQ__Quote__c oldQ = oldQuotesMap != null ? oldQuotesMap.get(q.Id) : null;
            if (q.Main_Contractor__c != null && (oldQ == null || q.Main_Contractor__c != oldQ.Main_Contractor__c)) {
                list<Account> mainContractors = [SELECT Id, Language__c, Company_Legal_Info__c, Company_Legal_Info_eng__c FROM Account WHERE Id = :q.Main_Contractor__c];
                if (mainContractors != null && !mainContractors.isEmpty()) {
                    //if (q.SBQQ__QuoteLanguage__c == mainContractors[0].Language__c) {
                        q.SVG_LastPageLegalInfos__c = mainContractors[0].Company_Legal_Info__c;
                    //} else {
                        //q.SVG_LastPageLegalInfos__c = mainContractors[0].Company_Legal_Info_eng__c;
                    //}
                }
            }
        }
        
    }
    
}