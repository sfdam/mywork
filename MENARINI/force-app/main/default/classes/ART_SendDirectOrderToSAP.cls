public class ART_SendDirectOrderToSAP implements Database.Batchable<SObject>, Database.Stateful, Database.AllowsCallouts {

    public Map<String, List<String>> deliveryNoteDependencyMap {
        get{
            if(deliveryNoteDependencyMap != null)return deliveryNoteDependencyMap;
            deliveryNoteDependencyMap = new Map<String, List<String>>();
            Map<String,SObject> response = ART_CustomMetadataUtility.getMapByMetadataName('ART_AdvancedOrderLayout__mdt');
            for(LayoutColumn columnField : (List<LayoutColumn>) System.JSON.deserialize((String)response.get('Base').get('left_column__c'), List<LayoutColumn>.class)){
                if(String.isNotBlank(columnField.dependency) && columnField.dependency == 'ART_Delivery_note__c'){
                    if(!deliveryNoteDependencyMap.containsKey(columnField.valueDependent))deliveryNoteDependencyMap.put(columnField.valueDependent, new List<String>());
                    deliveryNoteDependencyMap.get(columnField.valueDependent).add(columnField.fieldName);
                }
            }
            return deliveryNoteDependencyMap;
        } set;
    }
    /** Metodi di interface Database.Batchable<SObject> */
    public Database.QueryLocator start(Database.BatchableContext BC) {  
        
        String query = 'SELECT Id, ART_Division_Code__c,cgcloud__Delivery_Note__c, ART_Class_C__c, ART_CPY_REP_CODE__c, Name, cgcloud__Payer__r.THR_CustomerIdentificationCode__c, cgcloud__Delivery_Recipient__r.THR_CustomerIdentificationCode__c, ART_UserMatricola__c, ART_DIV_REP_CODE__c, ART_Payment_Code__c, ART_Order_Type__c, cgcloud__Order_Date__c, ART_CIG_Code__c, cgcloud__Delivery_Date__c,'+
            ' ART_Delivery_note__c, ART_Customer_Service_Note__c, ART_Riferimento_Contatto__c, ART_Data_inizio__c, ART_Data_fine__c, ART_Data_inizio_consegna__c, ART_Data_fine_consegna__c, ART_Orario_inizio__c, ART_Orario_fine__c, ART_Giorno_Settimanale__c, ART_total_quantity__c, ' +
            ' (SELECT Id, cgcloud__Product__r.ProductCode, cgcloud__Quantity__c, cgcloud__Discount__c, cgcloud__Product__r.THR_MaterialGroup__c FROM cgcloud__Order_Items__r)'+
            ' FROM cgcloud__Order__c'+
            ' WHERE ART_Order_Sent_to_SAP__c = false'+
            ' AND ART_Order_To_Be_Sent__c = true'+
            ' AND ART_Order_send_block__c = false'+
            ' AND cgcloud__Phase__c = \'Ready\''+
            ' AND cgcloud__Order_Template__r.Name != \'Transfer Order\'';
        return Database.getQueryLocator(query); 
    }

    public class LayoutColumn {

        public String fieldName{get;set;}
        // public Boolean required{get;set;}
        // public Boolean editable{get;set;}
        // public Boolean custom{get;set;}
        // public String label{get;set;}
        // public Boolean isText{get;set;}
        // public Boolean showLabel{get;set;}
        // public Boolean isMultiPicklist{get;set;}
        public String dependency{get;set;}
        public String valueDependent{get;set;}
        // public Boolean hidden{get;set;}
    }

    public void execute(Database.BatchableContext BC, List<cgcloud__Order__c> scope){

        //List<cgcloud__Order__c> scopeToUpdate = new List<cgcloud__Order__c>();
        List<ART_DirectOrdersWS.row_element> orderItemList = new List<ART_DirectOrdersWS.row_element>();
        for(cgcloud__Order__c order : scope){
            Map<String, List<String>> deliveryNoteMap = new Map<String, List<String>>();
            String deliveryNoteString = '';
            if(String.isNotBlank(order.ART_Delivery_note__c)){
                deliveryNoteMap = new Map<String, List<String>>();
                for(string deliveryNote : order.ART_Delivery_note__c.split(';')){
                    System.debug('DK deliveryNote: ' + deliveryNote);
                    deliveryNoteMap.put(deliveryNote, new List<String>());
                    if(deliveryNoteDependencyMap.containsKey(deliveryNote)){
                        for(String field : deliveryNoteDependencyMap.get(deliveryNote)){
                            if(order.get(field) != null){
                                deliveryNoteMap.get(deliveryNote).add(
                                    order.get(field) instanceof Date ? ((Datetime)order.get(field)).format('dd-MM-yyy') : 
                                    order.get(field) instanceof Time ? String.valueOf(order.get(field)).substring(0,5) : String.valueOf(order.get(field))
                                );
                            }else{
                                deliveryNoteMap.get(deliveryNote).add('');
                            }
                        }
                    }
                }
                System.debug('DK deliveryNoteMap: ' + JSON.serialize(deliveryNoteMap));
                for(String deliveryNote : deliveryNoteMap.keySet()){
                    System.debug('DK deliveryNote: ' + deliveryNote);
                    if(deliveryNote == 'Consegnare nella fascia oraria il giorno'){
                        String stringFInale = deliveryNote.replace('oraria', 'oraria ' + deliveryNoteMap.get(deliveryNote)[0] + '/' + deliveryNoteMap.get(deliveryNote)[1]);
                        stringFInale = String.isNotBlank(deliveryNoteMap.get(deliveryNote)[2]) ? stringFInale +  ' ' + deliveryNoteMap.get(deliveryNote)[2] : stringFInale.replace('il giorno', '');
                        deliveryNoteString += stringFInale + '. ';
                    }else{
                        deliveryNoteString += deliveryNote + (!deliveryNoteMap.get(deliveryNote).isEmpty() ? ' ' + String.join(deliveryNoteMap.get(deliveryNote), '/') : '') + '. ';
                    }
                }
                deliveryNoteString = deliveryNoteString.removeEnd(' ');
            }
            System.debug('DK deliveryNoteString: ' + deliveryNoteString);
            for(cgcloud__Order_Item__c orderItem : order.cgcloud__Order_Items__r){

                ART_DirectOrdersWS.row_element item = new ART_DirectOrdersWS.row_element();
                //DE-009 modifica Campo Delivery Note
                item.ORDER_AM_NOTE = deliveryNoteString;
                /////
                item.DIV_ORD_CODE = order.ART_Division_Code__c;
                item.ART_CLASSE_C = order.ART_Class_C__c ? 'CLASSE C' : '';
                item.CPY_ORD_CODE = order.ART_CPY_REP_CODE__c;
                item.ORD_NUMBER = order.Name;
                item.CUS_INV_CODE = order.cgcloud__Payer__r.THR_CustomerIdentificationCode__c;
                item.CUS_DEL_CODE = order.cgcloud__Delivery_Recipient__r.THR_CustomerIdentificationCode__c;
                item.ORD_REF_NUMBER = order.Id;
                item.REP_CODE = order.ART_UserMatricola__c;
                item.DIV_REP_CODE = order.ART_DIV_REP_CODE__c;
                item.PAY_CODE = order.ART_Payment_Code__c;
                item.ORD_TYP_CODE = order.ART_Order_Type__c;
                item.ORD_DATE = order.cgcloud__Order_Date__c; //date yyyyMMdd
                item.ORD_CIG_CODE = order.ART_CIG_Code__c;
                item.ORD_DEL_DATE = order.cgcloud__Delivery_Date__c; //date yyyyMMdd
                item.PAC_CODE = orderItem.cgcloud__Product__r.ProductCode;
                item.ORD_QTY = Integer.valueOf(orderItem.cgcloud__Quantity__c);
                item.ORD_PRODUCT_DISCOUNT = (orderItem.cgcloud__Discount__c > 0) ? String.valueOf(orderItem.cgcloud__Discount__c) : '0';
                item.SPECIAL_ORDER = (String.isNotBlank(orderItem.cgcloud__Product__r.THR_MaterialGroup__c) && orderItem.cgcloud__Product__r.THR_MaterialGroup__c.equalsIgnoreCase('MPRF'))  ? 'Y' : 'N';
                orderItemList.add(item);
            }
            //AA 26/05/2023 - Rimosso per nuova comunicazione Async con SAP-PO. Ci penserà lui ad aggiornare gli ordini
            //scopeToUpdate.add(new cgcloud__Order__c(id = order.Id, ART_Order_Sent_to_SAP__c = true, cgcloud__Phase__c = 'Submitted', ART_Sent_to_SAP_date__c = Date.today()));
            //FINE AA 26/06/2023
        }
        ART_DirectOrdersWS.DT_SFDC_ORDER_ACKNOWLEDGEMENT response;
        ART_DirectOrdersWS.HTTPS_Port container = new ART_DirectOrdersWS.HTTPS_Port();
        try {
            container.timeout_x = 10000;            
            response = container.SI_SFDC_ORDER_out(orderItemList);
            //AA 26/05/2023 - Rimosso per nuova comunicazione Async con SAP-PO. Ci penserà lui ad aggiornare gli ordini
            /*if(response.actionCode == '200'){
                
                update scopeToUpdate;
            }*/
            //FINE AA 26/06/2023
            List<Map<String,Object>> deserializedRows = new List<Map<String,Object>>();
            for(ART_DirectOrdersWS.row_element item : orderItemList){
                Map<String, Object> values = (Map<String, Object>)JSON.deserializeUntyped(JSOn.serialize(item));
                for(String key : values.keySet()){
                    if(key.contains('type_info'))values.put(key, null);
                }
                deserializedRows.add(values);
            }
            ART_DirectOrdersWS.DT_SFDC_ORDER request_x = new ART_DirectOrdersWS.DT_SFDC_ORDER();
            request_x.row = (List<ART_DirectOrdersWS.row_element>)JSON.deserialize(JSOn.serialize(deserializedRows), List<ART_DirectOrdersWS.row_element>.class);
            writeLog(
                'SAP_PO',
                'SOAP',
                JSON.serialize(request_x, true), //requestbody
                response.actionCode,
                response.message,
                JSON.serialize(response),//responsetbody
                container.inputHttpHeaders_x,//requestheader
                container.outputHttpHeaders_x,//responseheader
                '',// endpoint
                ''
            );
        } catch (Exception ex) {
            ART_DirectOrdersWS.DT_SFDC_ORDER request_x = new ART_DirectOrdersWS.DT_SFDC_ORDER();
            List<Map<String,Object>> deserializedRows = new List<Map<String,Object>>();
            for(ART_DirectOrdersWS.row_element item : orderItemList){
                Map<String, Object> values = (Map<String, Object>)JSON.deserializeUntyped(JSOn.serialize(item));
                for(String key : values.keySet()){
                    if(key.contains('type_info'))values.put(key, null);
                }
                deserializedRows.add(values);
            }
            request_x.row = (List<ART_DirectOrdersWS.row_element>)JSON.deserialize(JSOn.serialize(deserializedRows), List<ART_DirectOrdersWS.row_element>.class);
            writeLog(
                'SAP_PO',
                'SOAP',
                JSON.serialize(request_x, true), //requestbody
                String.isNotBlank(response?.actionCode) ? response?.actionCode : '500',
                'KO',
                response != null ? JSON.serialize(response) : '',//responsetbody
                container.inputHttpHeaders_x,//requestheader
                container.outputHttpHeaders_x,//responseheader
                '',// endpoint
                ex.getMessage()
            );
        }
    }
    public static void writeLog(String apiRequestName, String method, String input, String code, String status, String output,  Map<String,String> reqHeader, Map<String,String> resHeader, String endpoint, String errorMessage){
        String inputPretty = input;
        String outputPretty = output;

        String reqHeaderPretty ;
        String resHeaderPretty ;

        List<String> path = endpoint.split('\\?');
        
        try {
            inputPretty = JSON.serializePretty(JSON.deserializeUntyped(input));
        } catch (Exception e) {}
    
        try {
            outputPretty = JSON.serializePretty(JSON.deserializeUntyped(output));
        } catch (Exception e) {}

        try {
            reqHeaderPretty = JSON.serializePretty(reqHeader);
        } catch (Exception e) {}

        try {
            resHeaderPretty = JSON.serializePretty(resHeader);
        } catch (Exception e) {}

        system.debug('@@@@@@@@ resHeader: '+resHeader);
        insert new SV_Log__c(
            Source__c = apiRequestName,
            Method__c = method,
            Code__c = code,
            Status__c = status,
            Input_Payload__c = inputPretty != null && inputPretty.length() >= 131071 ? inputPretty.substring(0, 131071) : inputPretty,
            Output_Payload__c = outputPretty != null && outputPretty.length() >= 131071 ? outputPretty.substring(0, 131071) : outputPretty,
            Success__c = code == '200' ? true : false,
            ErrorMessage__c = errorMessage,
            ResponseHeader__c=resHeaderPretty,
            RequestHeader__c=reqHeaderPretty,
            Endpoint__c = path[0],
            Parameters__c = path.size() > 1 ? path[1] : '',
            Date__c = Datetime.now()

        );
    }
    public void finish(Database.BatchableContext BC){

    }
}