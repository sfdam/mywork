/**
 * Name         :   OnFinancialAccountTriggerHandler
 * Create date  :   2020-09-25
 * Author       :   Ezio Dal Bo
**/
public class OnFinancialAccountTriggerHandler {

    /**
     * Name         :   beforeInsert
     * Author       :   Ezio Dal Bo @TEN
     * Create Date  :   2020-10-01
     * Description  :   manage before insert trigger event
     */
    public static void beforeInsert(List<FinServ__FinancialAccount__c> newRecords) {
        //applyCorrectRecordType(newRecords,null,'beforeInsert');
    }

    /**
     * Name         :   beforeUpdate
     * Author       :   Ezio Dal Bo @TEN
     * Create Date  :   2020-10-01
     * Description  :   manage before update trigger event
     */
    public static void beforeUpdate(List<FinServ__FinancialAccount__c> newRecords,Map<Id,FinServ__FinancialAccount__c> oldRecords) {
        //applyCorrectRecordType(newRecords,oldRecords,'beforeUpdate');
        for(FinServ__FinancialAccount__c p: newRecords){
            p.Updated__c=true;
        }
    }

    /**
     * Name         :   afterInsert
     * Author       :   Ezio Dal Bo @TEN
     * Create Date  :   2020-09-28
     * Description  :   manage after insert trigger event
     */
    public static void afterInsert(List<FinServ__FinancialAccount__c> newRecords) {
        calculateTotalCreditLineGranted(newRecords,null,'afterInsert');
    }

    /**
     * Name         :   afterUpdate
     * Author       :   Ezio Dal Bo @TEN
     * Create Date  :   2020-09-28
     * Description  :   manage after update trigger event
     */
    public static void afterUpdate(List<FinServ__FinancialAccount__c> newRecords, Map<Id,FinServ__FinancialAccount__c> oldRecords) {
        calculateTotalCreditLineGranted(newRecords,oldRecords,'afterUpdate');
    }
    
    /**
     * Name         :   afterDelete
     * Author       :   Ezio Dal Bo @TEN
     * Create Date  :   2020-09-28
     * Description  :   manage after delete trigger event
     */
    public static void afterDelete(List<FinServ__FinancialAccount__c> oldRecords) {
        calculateTotalCreditLineGranted(oldRecords,null,'afterDelete');
    }

    /**
     * Name         :   applyCorrectRecordType
     * Author       :   Ezio Dal Bo @TEN
     * Create Date  :   2020-10-01
     * Description  :   manage the recordtype of a FinServ_FinancialAccount__c records
     */

    /*private static void applyCorrectRecordType(List<FinServ__FinancialAccount__c> records, Map<Id,FinServ__FinancialAccount__c> oldRecords, String action) {
        Set<Id> idProducts = new Set<Id>();
        Set<Id> idFinancialAccountToUpdate = new Set<Id>();
        Map<Id,Recordtype> mProdsToRecordType = new Map<Id,Recordtype>();
        if ('beforeInsert'.equals(action)) {
            for (FinServ__FinancialAccount__c fa : records) {
                if (fa.FinServ__ProductName__c!=null) {
                    idProducts.add(fa.FinServ__ProductName__c);
                }
            }
            if (idProducts.size()>0) {
                mProdsToRecordType = getRecordTypeByProduct(idProducts);
                if (!mProdsToRecordType.isEmpty()) {
                    for (FinServ__FinancialAccount__c fa : records) {
                        if (fa.FinServ__ProductName__c!=null && mProdsToRecordType.containsKey(fa.FinServ__ProductName__c)) {
                            fa.RecordTypeId = mProdsToRecordType.get(fa.FinServ__ProductName__c).Id;
                        }
                    }
                }
            }
        }
        else if ('beforeUpdate'.equals(action)) {
            for (FinServ__FinancialAccount__c fa : records) {
                FinServ__FinancialAccount__c oFa = oldRecords.get(fa.Id);
                if (fa.FinServ__ProductName__c!=null && fa.FinServ__ProductName__c!=oFa.FinServ__ProductName__c) {
                    idProducts.add(fa.FinServ__ProductName__c);
                    idFinancialAccountToUpdate.add(fa.Id);
                }
            }
            if (idProducts.size()>0) {
                mProdsToRecordType = getRecordTypeByProduct(idProducts);
                if (!mProdsToRecordType.isEmpty()) {
                    for (FinServ__FinancialAccount__c fa : records) {
                        if (idFinancialAccountToUpdate.contains(fa.Id) && mProdsToRecordType.containsKey(fa.FinServ__ProductName__c)) {
                            fa.RecordTypeId = mProdsToRecordType.get(fa.FinServ__ProductName__c).Id;
                        }
                    }
                }
            }
        }
    }*/

     /**
     * Name         :   calculateTotalCreditLineGranted
     * Author       :   Ezio Dal Bo @TEN
     * Create Date  :   2020-09-28
     * Description  :   calculate value to assign to CRM_TotalCreditLineGranted__c field
     */
    private static void calculateTotalCreditLineGranted(List<FinServ__FinancialAccount__c> records, Map<Id,FinServ__FinancialAccount__c> oldRecords, String action) {
        Set<Id> allParents = new Set<Id>();
        String idRecCreditLine = SV_Utilities.getRecordTypeByDeveloperName('FinServ__FinancialAccount__c', 'Credit_Line');

        if ('afterUpdate'.equals(action)) {
            for (FinServ__FinancialAccount__c fa : records) {
                FinServ__FinancialAccount__c oFa = oldRecords.get(fa.Id);
                if (fa.RecordTypeId!=oFa.RecordTypeId) {
                    // è cambiato il recordType
                    if (fa.RecordTypeId==idRecCreditLine && fa.CRM_BankDebitAccount__c!=null) {
                        allParents.add(fa.CRM_BankDebitAccount__c);
                    }
                    else if (fa.RecordTypeId!=idRecCreditLine && oFa.RecordTypeId==idRecCreditLine && oFa.CRM_BankDebitAccount__c!=null) {
                        allParents.add(oFa.CRM_BankDebitAccount__c);
                    }
                }
                else if (fa.CRM_BankDebitAccount__c!=oFa.CRM_BankDebitAccount__c && fa.RecordTypeId==idRecCreditLine) {
                    // campo lookup modificato
                    if (oFa.CRM_BankDebitAccount__c!=null) {
                        allParents.add(oFa.CRM_BankDebitAccount__c);
                    }
                    if (fa.CRM_BankDebitAccount__c!=null) {
                        allParents.add(fa.CRM_BankDebitAccount__c);
                    }
                }
                else if (fa.CRM_CreditLineAmount__c!=oFa.CRM_CreditLineAmount__c && fa.RecordTypeId==idRecCreditLine && fa.CRM_BankDebitAccount__c!=null) {
                    allParents.add(fa.CRM_BankDebitAccount__c);
                }
            }
        }
        else if ('afterDelete'.equals(action) || 'afterInsert'.equals(action)) {
            for (FinServ__FinancialAccount__c fa : records) {
                if (fa.RecordTypeId==idRecCreditLine && fa.CRM_BankDebitAccount__c!=null) {
                    allParents.add(fa.CRM_BankDebitAccount__c);
                }
            }
        }
        if (allParents.size()>0) {
            Map<Id,AggregateResult> mAggregates = caluclateTotalCreditLineAmount(allParents);
            List<FinServ__FinancialAccount__c> finAccs = queryFinancialAccountCreditLine(allParents);
            if (finAccs.size()>0) {
                for (FinServ__FinancialAccount__c fa : finAccs) {
                    AggregateResult ar = mAggregates.get(fa.CRM_BankDebitAccount__c);
                    Decimal sum = (ar==null || ar.get('sum')==null ? 0 : Decimal.valueOf(String.valueOf(ar.get('sum'))));
                    fa.CRM_TotalCreditLineGranted__c = sum;
                }
                update finAccs;
            }
        }        
    }

    /**
     * Name         :   queryFinancialAccountCreditLine
     * Author       :   Ezio Dal Bo @TEN
     * Create Date  :   2020-09-28
     * Description  :   retrieve financialAccount records where RecordType is CrediLine
     */
    private static List<FinServ__FinancialAccount__c> queryFinancialAccountCreditLine(Set<Id> allParents) {
        List<FinServ__FinancialAccount__c> finAcc = null;

        try {
            finAcc = [
                SELECT  Id,
                        CRM_BankDebitAccount__c,
                        CRM_TotalCreditLineGranted__c
                FROM FinServ__FinancialAccount__c
                WHERE RecordType.DeveloperName = 'Credit_Line'
                AND CRM_BankDebitAccount__c IN:allParents
            ];
        }
        catch(Exception exc) {
            throw exc;
        }

        return (finAcc!=null && finAcc.size()>0 ? finAcc : new List<FinServ__FinancialAccount__c>());
    }

    /**
     * Name         :   queryFinancialAccountCreditLine
     * Author       :   Ezio Dal Bo @TEN
     * Create Date  :   2020-09-28
     * Description  :   calculate SUM of CRM_TotalCreditLineAmount__c of record type Credit_Line where CRM_BankDebitAccount__c in parentId set of id
     */
    private static Map<Id,AggregateResult> caluclateTotalCreditLineAmount(Set<Id> allParents) {
        Map<Id,AggregateResult> mAggregates = new Map<Id,AggregateResult>();
        try {
            List<AggregateResult> aggs = [
                    SELECT	SUM(CRM_CreditLineAmount__c) sum,
                            CRM_BankDebitAccount__c
                    FROM FinServ__FinancialAccount__c
                    WHERE CRM_BankDebitAccount__c IN:allParents
                    AND FinServ__Status__c = 'ATTIVO'
                    AND RecordType.DeveloperName = 'Credit_Line'
                    GROUP BY CRM_BankDebitAccount__c
                ];
            if (aggs!=null && aggs.size()>0) {
                for (AggregateResult agg : aggs) {
                    Id parentId = (String)agg.get('CRM_BankDebitAccount__c');
                    mAggregates.put(parentId,agg);
                }
            }
        }
        catch(Exception exc) {
            throw exc;
        }
        return mAggregates;
    }

    /**
     * Name         :   getRecordTypeByProduct
     * Author       :   Ezio Dal Bo @TEN
     * Create Date  :   2020-10-01
     * Description  :   obtain a map contains products linked to your recordType about FinServ_FinancialAccount__c
     */
    /*private static Map<Id,Recordtype> getRecordTypeByProduct(Set<Id> idProducts) {
        Map<Id,RecordType> mIdProdRecordType = new Map<Id,RecordType>();
        Map<String,SObject> mRecordTypes = SV_Utilities.getRecordTypes('FinServ__FinancialAccount__c');

        try {
                Map<String,Set<Id>> mRecTypeDevNameToProd = new Map<String,Set<Id>>();
                List<Product2> prods = [
                    SELECT  Id,
                            RecordType.DeveloperName
                    FROM Product2
                    WHERE Id IN:idProducts
                ];

                if (prods!=null && prods.size()>0) {
                    for (Product2 p : prods) {
                        Set<Id> idProd = (mRecTypeDevNameToProd.containsKey(p.RecordType.DeveloperName) ? mRecTypeDevNameToProd.get(p.RecordType.DeveloperName) : new Set<Id>());
                        idProd.add(p.Id);
                        mRecTypeDevNameToProd.put(p.RecordType.DeveloperName,idProd);
                    }
                    if (!mRecTypeDevNameToProd.isEmpty()) {
                        for (String devName : mRecTypeDevNameToProd.keySet()) {
                            if (mRecordTypes.containsKey(devName)) {
                                Set<Id> idProd = mRecTypeDevNameToProd.get(devName);
                                for (Id idP : idProd) {
                                    mIdProdRecordType.put(idP,(RecordType)mRecordTypes.get(devName));
                                }
                            }
                        }
                    }
                }
        }
        catch(Exception exc) {
            throw exc;
        }
        return mIdProdRecordType;
    }*/

    /*
    public static void publishEvent(List<FinServ__FinancialAccount__c> records, Map<Id,FinServ__FinancialAccount__c> oldMap){
        List<ProductListViewEvent__e> eventList = new List<ProductListViewEvent__e>();
        for(FinServ__FinancialAccount__c p:records){
            ProductListViewEvent__e event = new ProductListViewEvent__e();
            event.ProductId__c=p.Id;
            event.UserId__c=UserInfo.getUserId();
            eventList.add(event);
        }
        EventBus.publish(eventList);
    }
    */
}