//@TestClass: ART_AdvancedOrderItemTriggerHandlerTest
public class ART_AdvancedOrderItemTriggerHandler {
    public static void setRowIndex(List<cgcloud__Order_Item__c> triggerNewList){
        Map<String, String> orderId_orderName_map = new Map<String, String>();
        Map<String, ART_AdvancedOrderItemRowIndex__c> csName_cs_map = new Map<String, ART_AdvancedOrderItemRowIndex__c>();
        Set<String> ordersId = new Set<String>();
        
        //Vado a recuperare tutti gli Id delle testate ordini così da poter fare un'unica query per recuperare i name
        for(cgcloud__Order_Item__c aoi : triggerNewList){
            ordersId.add(aoi.cgcloud__Order__c);
        }
        //Popolo la mappa Order Id - Order Name che userò per recuperare i custom settings
        for(cgcloud__Order__c order : [SELECT Id, Name FROM cgcloud__Order__c WHERE Id IN :ordersId] ){
            orderId_orderName_map.put(order.Id, order.Name);
        }
        //Popolo la mappa dei custom setting così da poterla utilizzare per recuperare eventuali valori esistenti o aggiungere i nuovi
        for(ART_AdvancedOrderItemRowIndex__c cs : [SELECT Name, ART_RowIndex__c FROM ART_AdvancedOrderItemRowIndex__c WHERE Name IN :orderId_orderName_map.values()]){
            csName_cs_map.put(cs.Name, cs);
        }
        
        for(cgcloud__Order_Item__c aoi : triggerNewList){
            ART_AdvancedOrderItemRowIndex__c cs = csName_cs_map.get(orderId_orderName_map.get(aoi.cgcloud__Order__c));
            aoi.ART_Row_index__c = (cs != null) ? cs.ART_RowIndex__c + 1 : 1;
            
            if(cs == null) cs = new ART_AdvancedOrderItemRowIndex__c(Name=orderId_orderName_map.get(aoi.cgcloud__Order__c));
            cs.ART_RowIndex__c = aoi.ART_Row_index__c;
            csName_cs_map.put(cs.Name, cs);
        }
        upsert csName_cs_map.values() Name; 
    }
    
    public static void resetRowsIndexAfterDelete(List<cgcloud__Order_Item__c> triggerOldList){
        //Mappa che contiene i custom setting degli ordini ai quali è stato cancellato un order item
        Map<String, ART_AdvancedOrderItemRowIndex__c> csName_cs_map = new Map<String, ART_AdvancedOrderItemRowIndex__c>();
        //Lista di orders name che servirà per recuperare i custom setting
        Set<String> ordersName = new Set<String>();
        //Lista di orders id che servirà per recuperare tutti gli order items a cui aggiornare l'index
        Set<String> ordersId = new Set<String>();
        //Lista di Order items a cui aggiornare la row index
        List<cgcloud__Order_Item__c> aoiToUpdate = new List<cgcloud__Order_Item__c>();
        
        //Recuperare per ogni record la testata ordine relazionata
        for(cgcloud__Order_Item__c aoi : triggerOldList){
            ordersId.add(aoi.cgcloud__Order__c);            
        }
        //Per ogni testata ordine recuperata, retrievare tutti gli order item ad esso associati ordinati per row index
        List<cgcloud__Order__c> orders = [SELECT Id, Name, (SELECT Id, ART_Row_index__c FROM cgcloud__Order_Items__r ORDER BY ART_Row_index__c) FROM cgcloud__Order__c WHERE Id IN :ordersId];
        //Vado a popolarmi la lista di orders name così da poter recuperare i custom setting, non viene fatto tramite aoi.cgcloud__Order__r.Name poichè non valorizzata in after delete
        for(cgcloud__Order__c order : orders){
        	ordersName.add(order.Name);
        }
        //Recuperare i custom setting per i quali bisognerà aggiornare l'index
        for(ART_AdvancedOrderItemRowIndex__c cs : [SELECT Name, ART_RowIndex__c FROM ART_AdvancedOrderItemRowIndex__c WHERE Name IN :ordersName]){
            csName_cs_map.put(cs.Name, cs);
        }        
        //Per ogni order item recuperato, settare un nuovo valore della row index
        for(cgcloud__Order__c order : orders){
			Integer newIndex = 1;
            for(cgcloud__Order_Item__c aoi : order.cgcloud__Order_Items__r){
                aoi.ART_Row_index__c = newIndex;
                newIndex ++;
                aoiToUpdate.add(aoi);
            }
            ART_AdvancedOrderItemRowIndex__c cs = csName_cs_map.get(order.Name);
            if(cs == null) cs = new ART_AdvancedOrderItemRowIndex__c(Name = order.Name);
            cs.ART_RowIndex__c = newIndex;
            csName_cs_map.put(cs.Name, cs);
		}
        if(!aoiToUpdate.isEmpty()){
            update aoiToUpdate;
        }
        //Aggiornare eventuale custom setting
        upsert csName_cs_map.values() Name;
    }
}