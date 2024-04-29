global class BI_CRM_CaricamentoMassivoDebitori_SCHD  implements Schedulable {
    global void execute(SchedulableContext ctx) {
        go();        
    }        
    public void go() {       
        System.debug('(**) go() - START');        
            
        BI_CRM_CaricamentoMassivoDebitori_BTCH adc = new BI_CRM_CaricamentoMassivoDebitori_BTCH();
        Id batchId = Database.executeBatch(adc, 1);
        System.debug('(***) Database.executeBatch id: ' + batchId);
    }  
}