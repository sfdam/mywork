public class WGC_OpportunityController {
    static final AggregateResult[] opptyYearQuery = [SELECT count(Id), sum(Amount)
                        FROM Opportunity 
                        WHERE StageName != 'In Istruttoria'
                            AND OwnerId =: UserInfo.getUserId()
                            AND Data_Inizio__c = THIS_YEAR
                            AND (NOT (IsClosed = true AND IsWon = false))];
    static final AggregateResult[] opptyMonthQuery = [SELECT count(Id), sum(Amount)
                        FROM Opportunity 
                        WHERE StageName != 'In Istruttoria'
                            AND OwnerId =: UserInfo.getUserId()
                            AND Data_Inizio__c = THIS_MONTH
                            AND (NOT (IsClosed = true AND IsWon = false))];
    static final Opportunity[] totalQuery = [ SELECT Amount, Probability, CreatedDate
                        FROM Opportunity 
                        WHERE OwnerId =: UserInfo.getUserId()
                            AND StageName NOT IN ('Vinta', 'Persa') ];

    public class ResponseWrapper {
        @AuraEnabled public String message;
        @AuraEnabled public Boolean success;
        @AuraEnabled public List<Object> data;

        public ResponseWrapper() {
            message = '';
            success = true;
            data = new List<Object>();
        }
    }

    public class YearAndMonthDataWrapper {
        @AuraEnabled public Integer budgetYear;
        @AuraEnabled public Integer currentYear;
        @AuraEnabled public Decimal accordatoYear;
        @AuraEnabled public Integer budgetMonth;
        @AuraEnabled public Integer currentMonth;
        @AuraEnabled public Decimal accordatoMonth;
    }

    public class TotalAndPerMonthDataWrapper {
        @AuraEnabled public Decimal totaleAccordato;
        @AuraEnabled public Integer totaleOppty;
		@AuraEnabled public Decimal totaleAccordatoPesato;
		@AuraEnabled public List<PerMonthDataWrapper> perMonthData;
    }

    public class PerMonthDataWrapper {
        @AuraEnabled public Integer month;
        @AuraEnabled public Decimal amount;
		@AuraEnabled public Integer opptyNum;
		@AuraEnabled public Decimal pesato;
        
        public PerMonthDataWrapper() {
            amount = 0;
            opptyNum = 0;
            pesato = 0;
        }
    }


    @AuraEnabled
    public static ResponseWrapper getCurrentYearAndMonthData(){
        ResponseWrapper result = new ResponseWrapper();
        YearAndMonthDataWrapper data = new YearAndMonthDataWrapper();

        try {
            // YEAR FUNCTIONS
            data.budgetYear = WGC_OpportunityController.getBudgetYear();
            data.currentYear = WGC_OpportunityController.getCurrentYear();
            data.accordatoYear = WGC_OpportunityController.getAccordatoYear();
            
            // MONTH FUNCTIONS
            data.budgetMonth = WGC_OpportunityController.getBudgetMonth();
            data.currentMonth = WGC_OpportunityController.getCurrentMonth();
            data.accordatoMonth = WGC_OpportunityController.getAccordatoMonth();

            result.data.add((Object) data);
        } catch (Exception e) {
            result.success = false;
            result.message = e.getMessage();
        }

        return result;
    }
    
    @AuraEnabled
    public static ResponseWrapper getTotalAndPerMonthData(){
        ResponseWrapper result = new ResponseWrapper();
        TotalAndPerMonthDataWrapper data = new TotalAndPerMonthDataWrapper();
        PerMonthDataWrapper pmd = new PerMonthDataWrapper();

        try {
            // TOTAL FUNCTIONS
            data.totaleAccordato = WGC_OpportunityController.getTotaleAccordato();
            data.totaleOppty = WGC_OpportunityController.getTotaleOppty();
            data.totaleAccordatoPesato = WGC_OpportunityController.getTotalePesato();
            
            // MONTHs FUNCTIONS
            data.perMonthData = WGC_OpportunityController.getPerMonthData();

            result.data.add((Object) data);
            
        } catch (Exception e) {
            result.success = false;
            result.message = e.getMessage();
        }

        return result;
    }
    
    
    private static Integer getBudgetYear() {
        return ((Decimal) WGC_OpportunityController.getAggResult([ SELECT SUM(Pratiche_presentate__c)
                                            FROM WGC_Budget__c
                                            WHERE OwnerId =: UserInfo.getUserId()
                                                AND Anno__c =: String.valueOf(Date.Today().year()) ], 'expr0')[0]).intValue();
    }
    private static Integer getCurrentYear() {
        return (Integer) WGC_OpportunityController.getAggResult(opptyYearQuery, 'expr0')[0];
    }
    private static Decimal getAccordatoYear() {
        return (Decimal) WGC_OpportunityController.getAggResult(opptyYearQuery, 'expr1')[0];
    }
    private static Integer getBudgetMonth() {
        return ((Decimal) WGC_OpportunityController.getAggResult([ SELECT SUM(Pratiche_presentate__c)
                                           FROM WGC_Budget__c
                                           WHERE OwnerId =: UserInfo.getUserId()
                                               AND Anno__c =: String.valueOf(Date.Today().year())
                                               AND Mese__c =: String.valueOf(Date.Today().month()) ], 'expr0')[0]).intValue();
    }
    private static Integer getCurrentMonth() {
        return (Integer) WGC_OpportunityController.getAggResult(opptyMonthQuery, 'expr0')[0];
    }
    private static Decimal getAccordatoMonth() {
        return (Decimal) WGC_OpportunityController.getAggResult(opptyMonthQuery, 'expr1')[0];
    }
    private static Decimal getTotaleAccordato() {
        Decimal res = 0;
        for (Opportunity o : totalQuery)
            if (o.Amount != null)
                res += o.Amount;
        return res;
    }
    private static Integer getTotaleOppty() {
        return totalQuery.size();
    }
    private static Decimal getTotalePesato() {
        Decimal res = 0;
        for (Opportunity o : totalQuery)
            if (o.Amount != null && o.Probability != null)
                res += (o.Amount * (o.Probability / 100));
        return res;
    }
    private static List<PerMonthDataWrapper> getPerMonthData() {
        Map<Integer, PerMonthDataWrapper> pmdwMap = new Map<Integer, PerMonthDataWrapper>();

        for (Opportunity o : totalQuery) {
            if (!pmdwMap.containsKey(o.CreatedDate.month())) {
                pmdwMap.put(o.CreatedDate.month(), new PerMonthDataWrapper());
                pmdwMap.get(o.CreatedDate.month()).month = o.CreatedDate.month();
            }

            if (o.Amount != null)
                pmdwMap.get(o.CreatedDate.month()).amount += o.Amount;
            
            if (o.Amount != null && o.Probability != null)
                pmdwMap.get(o.CreatedDate.month()).pesato += (o.Amount * (o.Probability / 100));
            
            pmdwMap.get(o.CreatedDate.month()).opptyNum++;
        }

        return pmdwMap.values();
    }

    // UTILITY FUNCTION TO MANAGE AGGREGATE RESULT
    private static List<Object> getAggResult(AggregateResult[] groupedResults, String groupKey) {
        List<Object> result = new List<Object>();
        
        for (AggregateResult ar : groupedResults)  {
            result.add((ar.get(groupKey) != null && ar.get(groupKey) != '') ? ar.get(groupKey) : 0);
        }

        return result;
    }

}