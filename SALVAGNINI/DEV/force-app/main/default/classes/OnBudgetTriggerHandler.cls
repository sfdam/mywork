public class OnBudgetTriggerHandler {
    public static void fillYearOnInsert(List<Budget__c> newBudgetList) {
        for(Budget__c b : newBudgetList ){
            b.Year_Trigger__c = Date.today().month()< 9 ? String.valueOf(Date.today().year()) : String.valueOf(Date.today().year()+1);
        }
    }


    public static void insertBudgetLines(List<Budget__c> newBudgetList) {
        List<Product2> productList = [SELECT Id, Name FROM Product2 WHERE Product_Type__c = 'System PA Budget' AND Enable_for_Budget__c = true];
        List<Budget_Line__c> lineList = new List<Budget_Line__c>();
        for(Budget__c b : newBudgetList){
            for(Product2 prod : productList){
                Budget_Line__c line = new Budget_Line__c(Name = prod.Name,
                                                         Budget__c = b.Id,
                                                         Product__c = prod.Id);
                lineList.add(line);
            }
        }
        insert lineList;
    }
}