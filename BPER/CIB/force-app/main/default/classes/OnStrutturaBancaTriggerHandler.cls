public class OnStrutturaBancaTriggerHandler {

    public static void beforeInsert(List<Struttura_Banca__c> newRecords) {
        impostaCambioStato(newRecords,null,'onInsert');
    }
    
    public static void beforeUpdte(List<Struttura_Banca__c> newRecords, Map<Id,Struttura_Banca__c> oldRecords) {
        impostaCambioStato(newRecords,oldRecords,'onUpdate');
    }
    
    private static void impostaCambioStato(List<Struttura_Banca__c> newRecords,Map<Id,Struttura_Banca__c> oldRecords, string operation) {
        
        
        for (Struttura_Banca__c sb : newRecords) {
            if ('onInsert'.equals(operation)) {
            	sb.Cambio_Stato__c = ('A'.equals(sb.Stato__c) || 'D'.equals(sb.Stato__c) ? true : sb.Cambio_Stato__c);
            	sb.Da_Elaborare__c = (sb.Cambio_Stato__c ? true : sb.Da_Elaborare__c);
            }
            if ('onUpdate'.equals(operation)) { 
                Struttura_Banca__c sbOld = oldRecords.get(sb.Id);
                sb.Cambio_Stato__c = ((sb.Stato__c!=sbOld.Stato__c || sb.IDCed_Padre__c!=sbOld.IDCed_Padre__c || sb.IDCED_UffPrivate__c!=sbOld.IDCED_UffPrivate__c) ? true : sb.Cambio_Stato__c);
                sb.Da_Elaborare__c = (sb.Cambio_Stato__c ? true : sb.Da_Elaborare__c);
            }
        }
    }
}