/****
 * Name			:	OnFinancialAccountTransanctionTrigger
 * Create date	:	2020-09-25
 * Author		:	Ezio Dal Bo @TEN
 * Description	:	Manage events of trigger
 ****/
public class OnFinAccountTransanctionTriggerHandler {
    
    public static void afterInsert(List<FinServ__FinancialAccountTransaction__c> newRecords) { 
        Set<Id> allParents = new Set<Id>();
        
        for (FinServ__FinancialAccountTransaction__c fat: newRecords) {
            if (
                ('Pending'.equals(fat.FinServ__TransactionStatus__c) && 'Debit'.equals(fat.FinServ__TransactionType__c) && fat.FinServ__FinancialAccount__c!=null) || 
                ('Pending'.equals(fat.FinServ__TransactionStatus__c) && 'Credit'.equals(fat.FinServ__TransactionType__c) && fat.FinServ__FinancialAccount__c!=null) 
            )
            { 
                allParents.add(fat.FinServ__FinancialAccount__c);
            }
        }
        
        List<FinServ__FinancialAccount__c> finAccs = calculateTotalAmountInOut(allParents);
        if (finAccs.size()>0) {
            update finAccs;
        }
        
    }
    
    public static void afterUpdate(List<FinServ__FinancialAccountTransaction__c> newRecords, Map<Id,FinServ__FinancialAccountTransaction__c> oldRecords) {
        Set<Id> allParents = new Set<Id>();
        for (FinServ__FinancialAccountTransaction__c fat : newRecords) {
            FinServ__FinancialAccountTransaction__c oFat = oldRecords.get(fat.Id);
            // avvenuto cambio di type
            if ( (fat.FinServ__Amount__c!=oFat.FinServ__Amount__c) ||
                 (fat.FinServ__TransactionStatus__c==oFat.FinServ__TransactionStatus__c && 'Pending'.equals(fat.FinServ__TransactionStatus__c) && fat.FinServ__TransactionType__c!=oFat.FinServ__TransactionType__c)  ||
                 (fat.FinServ__TransactionStatus__c!=oFat.FinServ__TransactionStatus__c && ('Pending'.equals(fat.FinServ__TransactionStatus__c) ||  'Pending'.equals(oFat.FinServ__TransactionStatus__c)))
            )
            {
                if ('Debit'.equals(fat.FinServ__TransactionType__c) || 'Credit'.equals(fat.FinServ__TransactionType__c) || 'Debit'.equals(oFat.FinServ__TransactionType__c) || 'Credit'.equals(oFat.FinServ__TransactionType__c)) {
                    allParents.add(fat.FinServ__FinancialAccount__c);
                }
            }
        }

        List<FinServ__FinancialAccount__c> finAccs = calculateTotalAmountInOut(allParents);
        if (finAccs.size()>0) {
            update finAccs;
        }
    }
    
    public static void afterDelete(List<FinServ__FinancialAccountTransaction__c> oldRecords) {
        Set<Id> allParents = new Set<Id>();
        
        for (FinServ__FinancialAccountTransaction__c fat: oldRecords) {
            if (
                ('Pending'.equals(fat.FinServ__TransactionStatus__c) && 'Debit'.equals(fat.FinServ__TransactionType__c) && fat.FinServ__FinancialAccount__c!=null) ||
                ('Pending'.equals(fat.FinServ__TransactionStatus__c) && 'Credit'.equals(fat.FinServ__TransactionType__c) && fat.FinServ__FinancialAccount__c!=null)
            ) 
            {
                allParents.add(fat.FinServ__FinancialAccount__c);
            }
        }
        
        List<FinServ__FinancialAccount__c> finAccs = calculateTotalAmountInOut(allParents);
        if (finAccs.size()>0) {
            update finAccs;
        }
    }

    private static List<FinServ__FinancialAccount__c> calculateTotalAmountInOut(Set<Id> allParents) {
        List<FinServ__FinancialAccount__c> finAccounts = new List<FinServ__FinancialAccount__c>();

        if (allParents.size()>0) {
            Map<Id,List<AggregateResult>> mAggregates  = caluclateTotalAmount(allParents);
            finAccounts = queryFinancialAccountById(allParents);
            if (finAccounts.size()>0) {
                for (FinServ__FinancialAccount__c fat :finAccounts) {
                    fat.CRM_TotalTransactionPendingIn__c = 0;
                    fat.CRM_TotalTransactionPendingOut__c = 0;
                    if (mAggregates.containsKey(fat.Id)) {
                        List<AggregateResult> aggRes = mAggregates.get(fat.Id);
                        for (AggregateResult res : aggRes) {
                            Decimal sum = (res.get('sum')==null ? 0 : Decimal.valueOf(String.valueOf(res.get('sum'))));
                            String type = (string)res.get('FinServ__TransactionType__c');
                            if ('Debit'.equals(type)) {
                                fat.CRM_TotalTransactionPendingOut__c = sum;
                            }
                            if ('Credit'.equals(type)) {
                                fat.CRM_TotalTransactionPendingIn__c = sum;
                            }
                        }
                    }
                }
            }
        }

        return finAccounts;
    }
    
    private static Map<Id,List<AggregateResult>> caluclateTotalAmount(Set<Id> parentId) {
        Map<Id,List<AggregateResult>> mAggregates = new Map<Id,List<AggregateResult>>();
        try {
            List<AggregateResult> aggs = [
                SELECT	SUM(FinServ__Amount__c) sum,
                        FinServ__TransactionStatus__c,
                        FinServ__TransactionType__c,
                		FinServ__FinancialAccount__c
                FROM FinServ__FinancialAccountTransaction__c
                WHERE FinServ__FinancialAccount__c IN:parentId
                AND FinServ__TransactionStatus__c = 'Pending'
                AND FinServ__TransactionType__c IN ('Debit','Credit')
                GROUP BY FinServ__FinancialAccount__c , FinServ__TransactionStatus__c, FinServ__TransactionType__c
            ];

            if (aggs!=null && aggs.size()>0) {
                for (AggregateResult agg : aggs) {
                    Id finAccId = (String)agg.get('FinServ__FinancialAccount__c');
                    List<AggregateResult> aggr = (mAggregates.containsKey(finAccId) ? mAggregates.get(finAccId) : new List<AggregateResult>());
                    aggr.add(agg);
                    mAggregates.put(finAccId,aggr);
                }
            }
        }
        catch(Exception exc) {
            throw exc;
        }

        return mAggregates;
    }

    private static List<FinServ__FinancialAccount__c> queryFinancialAccountById(Set<Id> parentId) {
        List<FinServ__FinancialAccount__c> finAccounts = null;

        try {
            finAccounts = [
                SELECT  Id,
                        CRM_TotalTransactionPendingOut__c,
                        CRM_TotalTransactionPendingIn__c
                FROM FinServ__FinancialAccount__c
                WHERE Id IN:parentId
            ];
        }
        catch(Exception exc) {
            throw exc;
        }

        return (finAccounts!=null && finAccounts.size()>0 ? finAccounts : new List<FinServ__FinancialAccount__c>());
    }
}