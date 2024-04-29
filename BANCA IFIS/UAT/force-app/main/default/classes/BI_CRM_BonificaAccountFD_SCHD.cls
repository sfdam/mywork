global class BI_CRM_BonificaAccountFD_SCHD implements Schedulable {

    global void execute(SchedulableContext ctx) {
        go();        
    }        
    public void go() {       
        System.debug('(**) go() - START');        
            
        BI_CRM_BonificaAccountFD_BTCH adc = new BI_CRM_BonificaAccountFD_BTCH();
        Id batchId = Database.executeBatch(adc, 100); // qui metti il numero che ritieni più opportuno
        System.debug('(***) Database.executeBatch id: ' + batchId);
    }  

}