/**
 * @group             : tengroup
 * @last modified on  : 12-03-2024
 * @last modified by  : alessandro.dinardo@lutech.it
 * description        : ticket S240304_000163 togliere le modifiche di 'DE-061'
 * --------------------------------------------------------------------
 * @dateUpdate        : 2024-04-08 
 * @description       : Aggiunta metodo orderItemDelete
**/
public with sharing class ART_AdvancedOrderBasketController {
    //public ART_AdvancedOrderBasketController() {

    //}

       // apex method to fetch contact records from salesforce database 
       @AuraEnabled
       public static list<cgcloud__Order_Item__c> fetchCloudOrderItems(String orderId){  
        system.debug('AT  : orderId : '+orderId);   

        list<cgcloud__Order_Item__c> lstObj = new list<cgcloud__Order_Item__c>();
        
        lstObj =  [SELECT id,name,cgcloud__Order__r.Name,cgcloud__Quantity__c,
                        cgcloud__Product__r.Name, cgcloud__Product__r.ProductCode, 
                        cgcloud__Discount__c,cgcloud__Price__c,cgcloud__Value__c,
                        cgcloud__Product__r.THR_DiscountSegment__c, cgcloud__Product__r.THR_IndustryStandard__c, // LV 2023-03-14 DE-014/DE-029
                        cgcloud__Order__r.cgcloud__Order_Account__r.ART_Rural__c, // EDB 2023-03-16 DE-33A
                        cgcloud__Product__r.THR_Plant__c, //Alessandro di nardo @ten 2023-08-21
                        Unite_Price__c, //AD @ten 2023-10-02 DE-089 
                        cgcloud__Value_Receipt__c
                    FROM cgcloud__Order_Item__c
                    WHERE cgcloud__Order__c =: orderId];
            return lstObj;        
       }

       @AuraEnabled
       public static Boolean deleteCloudOrderItem(String orderItemId, List<cgcloud__Order_Item__c> recordsToUpdate){

            System.debug('AD sono in deleteCloudOrderItem');
            ART_FollowUpWork.setIsFromDesktop(); // LV DE-035 - AP-027
            Boolean isDelete = false;
            Id orderId = null;
            try {
                cgcloud__Order_Item__c orderItemrec =   [SELECT id, cgcloud__Order__c
                                                        FROM cgcloud__Order_Item__c 
                                                        WHERE Id = :orderItemId];
                orderId = orderItemrec.cgcloud__Order__c;
                delete orderItemrec;
                // DK aggiunta ricalcolo discount on delete
                if(!recordsToUpdate.isEmpty()){
                    update recordsToUpdate;
                }
                // DK aggiunta ricalcolo discount on delete
                isDelete = true;
                //AD vecchia select sostituita per la task DE-061 - Ordini OTC dilazione di default a 120gg
                //AD 12/03/2024 ticket S240304_000163 togliere la modifica DE-061
                List<AggregateResult> agResList = [
                SELECT SUM(cgcloud__Value_Receipt__c) totaleRiga, SUM(cgcloud__Quantity__c) totaleQuantita
                FROM cgcloud__Order_Item__c
                WHERE cgcloud__Order__c =: orderId];

                /* //AD 12/03/2024 ticket S240304_000163 togliere la modifica DE-061
                //AD inizio
                //AD inizio DE-061 - Ordini OTC dilazione di default a 120gg
                //imposto ART_Delay_days__c a 120 in base a queste condizioni :
                //se l'order tempale è uguale a : 'Ordine Diretto OTC'
                //Quantità totale dei prodotti presenti nel basket che hanno come codice : '9987','9988','9989','9991','9998','9999' sono uguali o maggiori a 12
                //ART_Delay_days__c dell'ordine deve essere vuoto
                System.debug('AD deleteCloudOrderItem identificativo ordine : ' + orderId);
                Set<String> externalMaterialCode = new Set<String>{'9987','9988','9989','9991','9998','9999'};
                Decimal countExternalMaterialCode = 0.0;// variabile usata per la quantità di ogni singolo prodotto raggruppato per il suo THR_ExternalMaterialGroup__c
                Boolean changeDelayDays = false;
                Decimal totaleQuantity = 0.0;// variabile usata per la quantità totale dei prodotti dell'ordine per il campo ART_total_quantity__c
                Decimal totaleValoreRecepito = 0.0; // variabile usata per il valore totale recepito

                List<cgcloud__Order__c> ordineForDelay = [Select ART_Delay_days__c,cgcloud__Order_Template__r.Name from cgcloud__Order__c where id =: orderId];
                String currentDelayDay = ordineForDelay[0].ART_Delay_days__c;
                String currentOrderTemplate = ordineForDelay[0].cgcloud__Order_Template__r.Name;
                System.debug('AD deleteCloudOrderItem currentDelayDay : ' + currentDelayDay);
                System.debug('AD deleteCloudOrderItem currentOrderTemplate : ' + currentOrderTemplate);

                //nuova query per ottenere il totale della riga
                List<AggregateResult> listOrderItem = [SELECT SUM(cgcloud__Quantity__c) totaleQuantita ,cgcloud__Product__r.THR_ExternalMaterialGroup__c, SUM(cgcloud__Value_Receipt__c) totaleRiga
                                                                FROM cgcloud__Order_Item__c  WHERE cgcloud__Order__c =: orderId
                                                                GROUP BY cgcloud__Product__r.THR_ExternalMaterialGroup__c];
                for(AggregateResult orderItem : listOrderItem){
                    totaleValoreRecepito = totaleValoreRecepito +(Decimal)orderItem.get('totaleRiga');
                    totaleQuantity = totaleQuantity + (Decimal)orderItem.get('totaleQuantita');
                    if(externalMaterialCode.contains((String) orderItem.get('THR_ExternalMaterialGroup__c'))){
                        countExternalMaterialCode = countExternalMaterialCode +(Decimal)orderItem.get('totaleQuantita'); 
                    }
                }
                if(currentOrderTemplate == 'Ordine Diretto OTC' && Integer.valueOf((Decimal)countExternalMaterialCode) >= 12 && String.isBlank(currentDelayDay)){
                    System.debug('AD deleteCloudOrderItem imposto ART_Delay_days__c a 120');
                    changeDelayDays=true;
                }

                if(changeDelayDays){

                    update new cgcloud__Order__c(
                        Id = orderId, 
                        cgcloud__Gross_Total_Value__c = (listOrderItem.size()>0 ? (totaleValoreRecepito==null ? 0 : totaleValoreRecepito) : 0), 
                        cgcloud__Value__c = (listOrderItem.size()>0 ? (totaleValoreRecepito==null ? 0 : totaleValoreRecepito) : 0),
                        ART_total_quantity__c = (listOrderItem.size()>0 ? ( Integer.valueOf((Decimal)totaleQuantity)==null ? 0 :  Integer.valueOf((Decimal)totaleQuantity)) : 0),
                        ART_Delay_days__c='120'
                    );

                }else{
                    
                    update new cgcloud__Order__c(
                        Id = orderId, 
                        cgcloud__Gross_Total_Value__c = (listOrderItem.size()>0 ? (totaleValoreRecepito==null ? 0 : totaleValoreRecepito) : 0), 
                        cgcloud__Value__c = (listOrderItem.size()>0 ? (totaleValoreRecepito==null ? 0 : totaleValoreRecepito) : 0),
                        ART_total_quantity__c = (listOrderItem.size()>0 ? ( Integer.valueOf((Decimal)totaleQuantity)==null ? 0 :  Integer.valueOf((Decimal)totaleQuantity)) : 0) 
                    );
                }
                */
                //AD fine DE-061 - Ordini OTC dilazione di default a 120gg

                
                
                
                //AD vecchio update sostituito per la task DE-061 - Ordini OTC dilazione di default a 120gg
                //AD 12/03/2024 ticket S240304_000163 togliere la modifica DE-061
                System.debug('DK agResList' + JSON.serialize(agResList));
                update new cgcloud__Order__c(
                    Id = orderId, 
                    cgcloud__Gross_Total_Value__c = (agResList.size()>0 ? (agResList[0].get('totaleRiga')==null ? 0 : (Decimal)agResList[0].get('totaleRiga')) : 0), 
                    cgcloud__Value__c = (agResList.size()>0 ? (agResList[0].get('totaleRiga')==null ? 0 : (Decimal)agResList[0].get('totaleRiga')) : 0),
                    ART_total_quantity__c = (agResList.size()>0 ? (agResList[0].get('totaleQuantita')==null ? 0 : (Decimal)agResList[0].get('totaleQuantita')) : 0)
                );

            }catch (DMLException ex) {
                throw new AuraHandledException(ex.getMessage().split(',')[1].split(':')[0]);
            }catch (Exception ex) {
                throw new AuraHandledException(ex.getMessage());
            }
            System.debug('isDelete : '+isDelete);


            return isDelete;

       }
    
    //AD START DE-041_042
    @AuraEnabled
    public static Map<String, Object> getOrderListFilter(String orderAccount, String orderTemplate){
        System.debug('AD orderAccount'+ orderAccount);
        System.debug('AD orderTemplate'+ orderTemplate);

        //List<cgcloud__Order_Item__c> orderlist = [Select Id,cgcloud__Order__c,cgcloud__Product__c 
        //from cgcloud__Order_Item__c where cgcloud__Order_Item_Template__c =: orderTemplate ];
        /*Map<String, Object> orderMap = SV_Utilities.keyBy([SELECT Id, (SELECT cgcloud__Product__c, cgcloud__Quantity__c FROM cgcloud__Order_Items__r)
        FROM cgcloud__Order__c
        WHERE cgcloud__Order_Account__c =: orderAccount AND cgcloud__Order_Template__c =: orderTemplate], 'Id');*/
        /*List<cgcloud__Order_Item__c> orderlist = [Select Id,cgcloud__Order__c,cgcloud__Product__c 
        FROM cgcloud__Order_Item__c
        WHERE cgcloud__Order__r.];*/

        /*Set<String> setProductId = new Set<String>();
        for(cgcloud__Order_Item__c o:orderlist){
            setProductId.add(o.cgcloud__Product__c);
        }*/

        // System.debug('AD orderMap'+ orderMap);
    
        // if(!orderMap.isEmpty()){
            return new Map<String, Object>{
                // 'orderMap' => orderMap
                'orderList' => [SELECT Id FROM cgcloud__Order__c WHERE cgcloud__Order_Account__c =: orderAccount AND cgcloud__Order_Template__c =: orderTemplate]
            };
        /*}else{
            return new Map<String, Object>{
                'message' => 'not found old order'
            };
        }*/
    }
    @AuraEnabled
    public static Object getOrderItemsToClone(String orderId, String selectedCustomer){
        Account customer = [SELECT ID, ART_Rural__c, THR_AccountGroup__c, ART_Customer_SubCategory_Description__c FROM Account WHERE ID =: selectedCustomer];
        List<cgcloud__Order_Item__c> recordsToClone = Database.query(SV_Utilities.selectAllField('cgcloud__Order_Item__c').replace('FROM', ', cgcloud__Product__r.THR_DiscountSegment__c, cgcloud__Product__r.ProductCode, cgcloud__Order__r.cgcloud__Order_Template__c, cgcloud__Order__r.cgcloud__Order_Template__r.Name, cgcloud__Order__r.cgcloud__Order_Account__c, cgcloud__Order__r.cgcloud__Order_Account__r.ART_Rural__c, cgcloud__Order__r.cgcloud__Order_Account__r.THR_AccountGroup__c, cgcloud__Order__r.cgcloud__Order_Account__r.ART_Customer_SubCategory_Description__c FROM') + ' WHERE cgcloud__Order__c =: orderId');
        if(recordsToClone.isEmpty()){
            return null;
        }
        system.debug('DK recordsToClone ' + JSON.serialize(recordsToClone));
        List<cgcloud__Product_Assortment_Order_Template__c> paotList = [SELECT cgcloud__Product_Assortment__c, cgcloud__Product_Assortment__r.Name
        FROM cgcloud__Product_Assortment_Order_Template__c 
        WHERE cgcloud__Order_Template__c =: recordsToClone[0].cgcloud__Order__r.cgcloud__Order_Template__c
        AND cgcloud__Product_Assortment__c IN (SELECT AssortmentId FROM StoreAssortment WHERE AccountId =: selectedCustomer)];
        
        if(!paotList.isEmpty()){

            /*List<AssortmentProduct> assortmentProductList = [SELECT ProductId, Product.Name, Product.ProductCode, Product.THR_DiscountSegment__c, 
            Product.THR_IndustryStandard__c, Product.THR_ZLAW__c, Product.THR_TaxClassification__c, // LV 2023-03-14 DE-014/DE-029
            Product.cgcloud__Criterion_4_Product_Description__c, Product.THR_Plant__c, Product.ART_Cluster__c //DK START DE-075
            FROM AssortmentProduct
            WHERE AssortmentId =: paotList[0].cgcloud__Product_Assortment__c];*/
    
            Map<String, SObject> assortmentProductMap = SV_Utilities.keyBy([SELECT ProductId, Product.Name, Product.ProductCode, Product.THR_DiscountSegment__c, 
            Product.THR_IndustryStandard__c, Product.THR_ZLAW__c, Product.THR_TaxClassification__c, // LV 2023-03-14 DE-014/DE-029
            Product.cgcloud__Criterion_4_Product_Description__c, Product.THR_Plant__c, Product.ART_Cluster__c //DK START DE-075
            FROM AssortmentProduct
            WHERE AssortmentId =: paotList[0].cgcloud__Product_Assortment__c], 'ProductId');
    
            Map<String, SObject> productConditionMap = SV_Utilities.keyBy([SELECT cgcloud__Product__c, cgcloud__Value__c, ART_Public_Price__c
            FROM cgcloud__Product_Condition__c
            WHERE cgcloud__Product__c IN: assortmentProductMap.keySet()], 'cgcloud__Product__c');
            system.debug('DK recordsToClone_FINAL ' + JSON.serialize(recordsToClone));
            
            return new Map<String, Object>{
                'templatename' => recordsToClone[0].cgcloud__Order__r.cgcloud__Order_Template__r.Name,
                'rural' => customer.ART_Rural__c,
                'accountGroup' => customer.THR_AccountGroup__c,
                'customerSubCategoryDescription' => customer.ART_Customer_SubCategory_Description__c,
                'recordsToClone' => recordsToClone,
                'paotList' => paotList,
                'assortmentProductMap' => assortmentProductMap,
                'productConditionMap' => productConditionMap
            };
        }else{
            return new Map<String, Object>{
                'message' => 'No template found!!'
            };
        }
    }

    @AuraEnabled
    public static Object cloneOrder(String customerId, String orderId, List<cgcloud__Order_Item__c> orderItems){
        cgcloud__Order__c record = Database.query(SV_Utilities.selectAllField('cgcloud__Order__c').replace('FROM', ',cgcloud__Order_Template__r.Name FROM') + ' WHERE Id =: orderId');
        List<cgcloud__Account_Relationship__c> payer = [SELECT cgcloud__Related_Account__c FROM cgcloud__Account_Relationship__c WHERE cgcloud__Account__c = :customerId AND cgcloud__Relationship_Type__c = 'Payer' LIMIT 1];
        cgcloud__Order__c recordClone = record.clone(false, false, false, false);
        if(record.cgcloud__Order_Template__r.Name == 'Transfer Order')recordClone.cgcloud__Wholesaler__c = null;
        List<cgcloud__Order_Item__c> orderItemsToInsert = new List<cgcloud__Order_Item__c>();
        try {
            Decimal totQuantity = 0;
            Decimal totValue = 0;
            for(cgcloud__Order_Item__c orderItem : orderItems){
                totQuantity+=orderItem.cgcloud__Quantity__c != null ? orderItem.cgcloud__Quantity__c : 0;
                totValue+=orderItem.cgcloud__Value__c != null ? orderItem.cgcloud__Value__c : 0;
            }
            recordClone.OwnerId = UserInfo.getUserId();
            recordClone.cgcloud__Responsible__c = UserInfo.getUserId();
            recordClone.cgcloud__Accountable__c = UserInfo.getUserId();
            recordClone.cgcloud__Order_Account__c = customerId;
            recordClone.cgcloud__Delivery_Recipient__c = customerId;
            recordClone.cgcloud__Phase__c = 'Initial';
            recordClone.cgcloud__Order_Date__c = Date.today();
            recordClone.cgcloud__Delivery_Date__c = Date.today();
            recordClone.ART_total_quantity__c = totQuantity;
            recordClone.cgcloud__Value__c = totValue;
            recordClone.cgcloud__Gross_Total_Value__c = totValue;
            recordClone.cgcloud__Payer__c = !payer.isEmpty() ? payer[0].cgcloud__Related_Account__c : null;
            recordClone.ART_Delay_days__c = null;
            recordClone.ART_Delivery_note__c = null;
            recordClone.ART_Customer_Service_Note__c = null;
            recordClone.ART_Riferimento_Contatto__c = null;
            recordClone.ART_Data_inizio__c = null;
            recordClone.ART_Data_fine__c = null;
            recordClone.ART_Data_inizio_consegna__c = null;
            recordClone.ART_Data_fine_consegna__c = null;
            recordClone.ART_Orario_inizio__c = null;
            recordClone.ART_Orario_fine__c = null;
            recordClone.ART_Giorno_Settimanale__c = null;
            
            recordClone.cgcloud__Initiation_Date__c = Date.today();
            recordClone.ART_Order_Sent_to_SAP__c = false;
            recordClone.ART_Order_To_Be_Sent__c = false;
            recordClone.ART_Payment_Code__c = null;
            recordClone.ART_Sent_to_SAP_date__c = null;
            recordClone.Invio_Copia_Commissione__c = null;
            recordClone.ART_SENDING_MAIL_DATE__c = null;
            recordClone.ART_Data_Trasmissione_a_FTP__c = null;
            recordClone.ART_CIG_Code__c = null;
            recordClone.cgcloud__Customer_Order_Id__c = null;
            recordClone.ART_Order_send_block__c = false;

            insert recordClone;
            for(cgcloud__Order_Item__c orderItem : orderItems){
                cgcloud__Order_Item__c itemToIsert = new cgcloud__Order_Item__c();
                itemToIsert = orderItem.clone(false, false, false, false);
                itemToIsert.cgcloud__Order__c = recordClone.Id;
                orderItemsToInsert.add(itemToIsert);
            }
            if(!orderItemsToInsert.isEmpty()){
                System.debug('DK orderItems: ' + JSON.serialize(orderItemsToInsert));
                insert orderItemsToInsert;
            }
            return recordClone.Id;
        } catch (Exception ex) {
            throw new AuraHandledException(ex.getMessage() + ';at: ' + ex.getStackTraceString());
        }
    }
    //AD END DE-041_042


    @AuraEnabled
    public static Map<String, Object> getProduct(String orderAccount, String orderTemplate){
        System.debug('DK orderAccount'+ orderAccount);
        System.debug('DK orderTemplate'+ orderTemplate);
        List<cgcloud__Product_Assortment_Order_Template__c> paotList = [SELECT cgcloud__Product_Assortment__c, cgcloud__Product_Assortment__r.Name
        FROM cgcloud__Product_Assortment_Order_Template__c 
        WHERE cgcloud__Order_Template__c =: orderTemplate
        AND cgcloud__Product_Assortment__c IN (SELECT AssortmentId FROM StoreAssortment WHERE AccountId =: orderAccount)];
        
        if(!paotList.isEmpty()){

            List<AssortmentProduct> assortmentProductList = [SELECT ProductId, Product.Name, Product.ProductCode, Product.THR_DiscountSegment__c, 
            Product.THR_IndustryStandard__c, Product.THR_ZLAW__c, Product.THR_TaxClassification__c, // LV 2023-03-14 DE-014/DE-029
            Product.cgcloud__Criterion_4_Product_Description__c, Product.THR_Plant__c, Product.ART_Cluster__c //DK START DE-075
            FROM AssortmentProduct
            WHERE AssortmentId =: paotList[0].cgcloud__Product_Assortment__c];
    
            Set<String> productIdSet = SV_Utilities.keyBy(assortmentProductList, 'ProductId').keySet();
    
            Map<String, SObject> productConditionMap = SV_Utilities.keyBy([SELECT cgcloud__Product__c, cgcloud__Value__c, ART_Public_Price__c
            FROM cgcloud__Product_Condition__c
            WHERE cgcloud__Product__c IN: productIdSet], 'cgcloud__Product__c');
            return new Map<String, Object>{
                'paotList' => paotList,
                'assortmentProductList' => assortmentProductList,
                'productConditionMap' => productConditionMap
            };
        }else{
            return new Map<String, Object>{
                'message' => 'No template found!!'
            };
        }
    }
    @AuraEnabled
    public static List<cgcloud__Order_Item__c> saveProduct(String orderId, List<Map<String, Object>> recordList){
        System.debug('AD sono in saveProduct');
        System.debug('AD recordList : ' + recordList);

        String orderTemplateToCheck = (String)recordList[0].get('orderTemplate');//AD DE-061
        System.debug('AD orderTemplateTocheck : ' + orderTemplateTocheck);

        ART_FollowUpWork.setIsFromDesktop(); // LV DE-035 - AP-027
        List<cgcloud__Order_Item__c> ordersToUpsert = new List<cgcloud__Order_Item__c>();
        List<cgcloud__Order_Item__c> ordersToDelete = new List<cgcloud__Order_Item__c>();
        List<cgcloud__Order_Item_Template__c> template = [SELECT Id
        FROM cgcloud__Order_Item_Template__c
        WHERE Name = 'Codifi Standard'];
        //EDB 2023-03-16 DE-33A - start
        // DK START commento
        /*Set<String> productCodes = new Set<String>();
        Map<String,ART_Commercial_Discount_Configuration__c> mCDCByProductCode = new Map<String,ART_Commercial_Discount_Configuration__c>();
        for(Map<String, Object> recordMap : recordList){
            if (recordMap.containsKey('cgcloud__ProductCode')) {
                String productCode = (String)recordMap.get('cgcloud__ProductCode');
                if (!String.isEmpty(productCode) && (Decimal)recordMap.get('cgcloud__Quantity__c') != 0) {
                    productCodes.add(productCode);
                }
            }
        }
        if (!productCodes.isEmpty()) {
            List<ART_Commercial_Discount_Configuration__c> cdcs = [
                SELECT  Id,
                        ART_Min_Qty_Rural_Customer__c, 
                        ART_Discount_Percentage_Rural_Customer__c,
                        ART_Min_Qty_NOT_Rural_Customer__c, 
                        ART_Discount_Percentage_NOT_Rural_Cust__c,
                        ART_Product_Code__c
                FROM ART_Commercial_Discount_Configuration__c
                WHERE ART_Product_Code__c IN:productCodes
            ];
            for (ART_Commercial_Discount_Configuration__c cdc : cdcs) {
                mCDCByProductCode.put(cdc.ART_Product_Code__c,cdc);
            }
        }*/
        // DK END commento
        //EDB 2023-03-16 DE-33A - end
        for(Map<String, Object> recordMap : recordList){
            if((Decimal)recordMap.get('cgcloud__Quantity__c') == 0){
                //START AA - 22/03/2023: Fix per mancata creazione righe ordine
                if(String.isNotBlank((String)recordMap.get('Id'))){
                    ordersToDelete.add(new cgcloud__Order_Item__c(Id = (String)recordMap.get('Id')));
                }
                //END AA - 22/03/2023
            }else{
                // EDB 2023-03-16 DE-33A start
                String productCode = (String)recordMap.get('cgcloud__ProductCode');
                // DK START commento
                /*ART_Commercial_Discount_Configuration__c cdc;
                cdc = (mCDCByProductCode.containsKey(productCode) ? mCDCByProductCode.get(productCode) : null);*/
                // DK END commento
                Decimal discount = (Decimal)recordMap.get('cgcloud__Discount__c');
                Decimal quantity = (Decimal)recordMap.get('cgcloud__Quantity__c');
                Boolean ARTRural = (Boolean)recordMap.get('ART_Rural__c');
                String discountSegment = (String)recordMap.get('THR_DiscountSegment__c');
                Decimal taxClassification = (Decimal)recordMap.get('THR_TaxClassification__c');
                //Decimal pricingInfo = (Decimal)recordMap.get('cgcloud__Value__c');
                Decimal pricingInfo = (Decimal)recordMap.get('prezzoAlPubblico');
                String orderTemplate = (String)recordMap.get('orderTemplate');
                System.debug('************************************************');
                System.debug('********productCode -> ' + productCode);
                System.debug('********discount -> ' + discount);
                System.debug('********quantity -> ' + quantity);
                System.debug('********discountSegment -> ' + discountSegment);
                System.debug('********taxClassification -> ' + taxClassification);
                System.debug('********pricingInfo -> ' + pricingInfo);
                System.debug('********orderTemplate -> ' + orderTemplate);
                // DK START commento
                /*if (cdc!=null) {
                    if (ARTRural) {
                        if (quantity>=cdc.ART_Min_Qty_Rural_Customer__c) {
                            discount = cdc.ART_Discount_Percentage_Rural_Customer__c;
                        }
                    } else {
                        if (quantity>=cdc.ART_Min_Qty_NOT_Rural_Customer__c) {
                            discount = cdc.ART_Discount_Percentage_NOT_Rural_Cust__c;
                        }
                    }
                }*/
                // DK END commento
                // EDB 2023-03-16 DE-33A end
                //Decimal totaleRiga = (Decimal)recordMap.get('cgcloud__Price__c') * (Decimal)recordMap.get('cgcloud__Quantity__c');
                Decimal totaleRiga = orderTemplate == 'Ordine Diretto Pharma' && discountSegment == 'C' ? ((pricingInfo*100)/(100+taxClassification))*quantity : (Decimal)recordMap.get('cgcloud__Price__c') * quantity; // EDB 2023-03-16 DE-33A
                System.debug('********totale riga -> '+ totaleRiga);
                //Decimal totaleRigaCalcolato = totaleRiga - (totaleRiga/100*((Decimal)recordMap.get('cgcloud__Discount__c')));
                Decimal totaleRigaCalcolato = (Boolean)recordMap.get('scontoLegge') ? totaleRiga : totaleRiga - (totaleRiga/100*(discount)); // EDB 2023-03-16 DE-33A
                System.debug('********totaleRigaCalcolato -> '+ totaleRigaCalcolato);
                
                cgcloud__Order_Item__c orderItem = new cgcloud__Order_Item__c(
                Id = (String)recordMap.get('Id'),
                //cgcloud__Discount__c =  (Decimal)recordMap.get('cgcloud__Discount__c'),
                cgcloud__Discount__c =  discount,// EDB 2023-03-16 DE-33A
                //cgcloud__Quantity__c = (Decimal)recordMap.get('cgcloud__Quantity__c'),
                cgcloud__Quantity__c = quantity, // EDB 2023-03-16 DE-33A
                cgcloud__Value__c = totaleRigaCalcolato,
                cgcloud__Value_Receipt__c = totaleRigaCalcolato
                );
                
                if(String.isBlank(orderItem.Id)){
                    
                    orderItem.cgcloud__Order__c = orderId;
                    orderItem.cgcloud__Price__c = (Decimal)recordMap.get('cgcloud__Price__c');
                    orderItem.cgcloud__Base_Price__c = (Decimal)recordMap.get('cgcloud__Price__c');
                    orderItem.cgcloud__Product__c = (String)recordMap.get('productId');
                    orderItem.cgcloud__Order_Item_Template__c = template[0].Id;
                    orderItem.cgcloud__UoM__c = 'ConsumerUnit';
                }
                ordersToUpsert.add(orderItem);
            }
        }
        try{
            if(!ordersToDelete.isEmpty()){
                delete ordersToDelete;
            }
            if(!ordersToUpsert.isEmpty()){
                upsert ordersToUpsert;
            }

            /*AD DE-061 29 11 2023 vecchia query usata per l'update di cgcloud__Order__c*/
            //AD 12/03/2024 ticket S240304_000163 togliere la modifica DE-061
            List<AggregateResult> agResList = [SELECT SUM(cgcloud__Quantity__c) totaleQuantita, SUM(cgcloud__Value_Receipt__c) totaleRiga
            FROM cgcloud__Order_Item__c
            WHERE cgcloud__Order__c =: orderId];

            /*//AD 12/03/2024 ticket S240304_000163 togliere la modifica DE-061
            //AD inizio DE-061 - Ordini OTC dilazione di default a 120gg
            //imposto ART_Delay_days__c a 120 in base a queste condizioni :
            //se l'order tempale è uguale a : 'Ordine Diretto OTC'
            //Quantità totale dei prodotti presenti nel basket che hanno come codice : '9987','9988','9989','9991','9998','9999' sono uguali o maggiori a 12
            //ART_Delay_days__c dell'ordine deve essere vuoto
            System.debug('AD identificativo ordine : ' + orderId);
            Set<String> externalMaterialCode = new Set<String>{'9987','9988','9989','9991','9998','9999'};
            Decimal countExternalMaterialCode = 0.0;// variabile usata per la quantità di ogni singolo prodotto raggruppato per il suo THR_ExternalMaterialGroup__c
            Boolean changeDelayDays = false;
            Decimal totaleQuantity = 0.0;// variabile usata per la quantità totale dei prodotti dell'ordine per il campo ART_total_quantity__c
            Decimal totaleValoreRecepito = 0.0; // variabile usata per il valore totale recepito
            List<cgcloud__Order__c> ordineForDelay = [Select ART_Delay_days__c from cgcloud__Order__c where id =: orderId];
            String currentDelayDay = ordineForDelay[0].ART_Delay_days__c;
            //nuova query per ottenere il totale della riga
            List<AggregateResult> listOrderItem = [SELECT SUM(cgcloud__Quantity__c) totaleQuantita ,cgcloud__Product__r.THR_ExternalMaterialGroup__c, SUM(cgcloud__Value_Receipt__c) totaleRiga
                                                            FROM cgcloud__Order_Item__c  WHERE cgcloud__Order__c =: orderId
                                                            GROUP BY cgcloud__Product__r.THR_ExternalMaterialGroup__c];
            for(AggregateResult orderItem : listOrderItem){
                
                totaleQuantity = totaleQuantity + (Decimal)orderItem.get('totaleQuantita');
                totaleValoreRecepito = totaleValoreRecepito +(Decimal)orderItem.get('totaleRiga');
                if(externalMaterialCode.contains((String) orderItem.get('THR_ExternalMaterialGroup__c'))){
                    countExternalMaterialCode = countExternalMaterialCode +(Decimal)orderItem.get('totaleQuantita'); 
                }
            }
            if(orderTemplateToCheck == 'Ordine Diretto OTC' && Integer.valueOf((Decimal)countExternalMaterialCode) >= 12 && String.isBlank(currentDelayDay)){
                System.debug('AD saveProduct imposto ART_Delay_days__c a 120');
                changeDelayDays=true;
            }

            if(changeDelayDays){
                update new cgcloud__Order__c(Id = orderId, cgcloud__Gross_Total_Value__c = totaleValoreRecepito, cgcloud__Value__c = totaleValoreRecepito, ART_total_quantity__c = Integer.valueOf((Decimal)totaleQuantity),ART_Delay_days__c='120');
            }else{
                update new cgcloud__Order__c(Id = orderId, cgcloud__Gross_Total_Value__c = totaleValoreRecepito, cgcloud__Value__c = totaleValoreRecepito, ART_total_quantity__c = Integer.valueOf((Decimal)totaleQuantity)); 
            }
            */
            //AD fine DE-061 - Ordini OTC dilazione di default a 120gg
            
            //AD DE-061 29 11 2023 vecchio update
            ////AD 12/03/2024 ticket S240304_000163 togliere la modifica DE-061
            update new cgcloud__Order__c(Id = orderId, cgcloud__Gross_Total_Value__c = (Decimal)agResList[0].get('totaleRiga'), cgcloud__Value__c = (Decimal)agResList[0].get('totaleRiga'), ART_total_quantity__c = Integer.valueOf((Decimal)agResList[0].get('totaleQuantita')));
            
            return ordersToUpsert;
        }catch (DMLException ex) {throw new AuraHandledException(ex.getMessage().split(',')[1].split(':')[0]);}
        catch (Exception ex) {throw new AuraHandledException(ex.getMessage() + 'at:' + ex.getStackTraceString());}
    }

    // DK START DE-033A Bis
    @AuraEnabled
    public static Map<String, Object> getBundleDiscounts(String orderItemQuantityMapJSON, String orderTemplateId, String filterMapJSON){
        
        Map<String, Map<String,Object>> bundlesMap = new Map<String, Map<String,Object>>();
        Map<String, Map<String, Object>> productResponseMap = new Map<String, Map<String, Object>>();
        Map<String, Map<String, Object>> minDiscountMap = new Map<String, Map<String, Object>>();
        System.debug('DK getBundleDiscounts.orderItemQuantityMap: ' + orderItemQuantityMapJSON);
        System.debug('DK getBundleDiscounts.orderTemplateId: ' + orderTemplateId);
        System.debug('DK getBundleDiscounts.filterMap: ' + filterMapJSON);
        Map<String, Integer> orderItemQuantityMap = (Map<String, Integer>)JSON.deserialize(orderItemQuantityMapJSON, Map<String, Integer>.class);
        Map<String, String> filterMap = (Map<String, String>)JSON.deserialize(filterMapJSON, Map<String, String>.class);
        Set<String> bundleSet = SV_Utilities.keyBy([SELECT Bundle__c FROM Bundle_Item__c WHERE Product__c IN: orderItemQuantityMap.keySet() AND Bundle__r.Order_Template__c =: orderTemplateId AND Bundle__r.Is_Active__c = true AND (Bundle__r.StartDate__c <= TODAY OR Bundle__r.StartDate__c = NULL) AND (Bundle__r.EndDate__c >= TODAY OR Bundle__r.EndDate__c = NULL)], 'Bundle__c').keySet();
        System.debug('AD bundleSet : ' +  bundleSet );

        for(Bundle_Item__c bundleItem : [SELECT Id, Name, Bundle__c, Product__c, Discount__c, ART_Sconto_Minimo__c, Bundle__r.From__c, Bundle__r.To__c, Bundle__r.Priority__c, Bundle__r.Campo_raggruppamento__c, Bundle__r.Cliente__c 
                                        FROM Bundle_Item__c 
                                        WHERE Bundle__c IN: bundleSet
                                        ORDER BY Bundle__r.Priority__c ASC]){
            
            // Integer orderItemQuantity = orderItemQuantityMap.get(bundleItem.Product__c);
            System.debug('AD bundleItem.Bundle__r.Cliente__c : ' +  bundleItem.Bundle__r.Cliente__c);
            
            List<String> listBundle = !String.isBlank(bundleItem.Bundle__r.Cliente__c) ? bundleItem.Bundle__r.Cliente__c.split(';') : new List<String>();
            
            if(bundleItem.Bundle__r.Campo_raggruppamento__c == 'Nessuno' ||
                    listBundle.contains(filterMap.get(bundleItem.Bundle__r.Campo_raggruppamento__c))){
                
                if(!productResponseMap.containsKey(bundleItem.Product__c)){
                    productResponseMap.put(bundleItem.Product__c, new Map<String, Object>());
                    minDiscountMap.put(bundleItem.Product__c, new Map<String, Object>());         
                }
                productResponseMap.get(bundleItem.Product__c).put(bundleItem.Bundle__r.From__c + '_' + bundleItem.Bundle__r.To__c + '_' + bundleItem.Bundle__c, bundleItem.Discount__c);
                minDiscountMap.get(bundleItem.Product__c).put(bundleItem.Bundle__r.From__c + '_' + bundleItem.Bundle__r.To__c + '_' + bundleItem.Bundle__c, bundleItem.ART_Sconto_Minimo__c);
                
                if(!bundlesMap.containsKey(bundleItem.Bundle__c)){
                    bundlesMap.put(bundleItem.Bundle__c, new Map<String,Object>());
                    bundlesMap.get(bundleItem.Bundle__c).put('productSet', new Set<String>());         
                    bundlesMap.get(bundleItem.Bundle__c).put('discount', bundleItem.Discount__c);         
                }
                ((Set<String>)bundlesMap.get(bundleItem.Bundle__c).get('productSet')).add(bundleItem.Product__c);
            } 
            
            
            
            /*backup Alessandro Di Nardo @ten 2023-08-23
            if(bundleItem.Bundle__r.Campo_raggruppamento__c == 'Nessuno' ||
                filterMap.get(bundleItem.Bundle__r.Campo_raggruppamento__c) == bundleItem.Bundle__r.Cliente__c){
                
                if(!productResponseMap.containsKey(bundleItem.Product__c)){
                    productResponseMap.put(bundleItem.Product__c, new Map<String, Object>());
                    minDiscountMap.put(bundleItem.Product__c, new Map<String, Object>());         
                }
                productResponseMap.get(bundleItem.Product__c).put(bundleItem.Bundle__r.From__c + '_' + bundleItem.Bundle__r.To__c + '_' + bundleItem.Bundle__c, bundleItem.Discount__c);
                minDiscountMap.get(bundleItem.Product__c).put(bundleItem.Bundle__r.From__c + '_' + bundleItem.Bundle__r.To__c + '_' + bundleItem.Bundle__c, bundleItem.ART_Sconto_Minimo__c);
                
                if(!bundlesMap.containsKey(bundleItem.Bundle__c)){
                    bundlesMap.put(bundleItem.Bundle__c, new Map<String,Object>());
                    bundlesMap.get(bundleItem.Bundle__c).put('productSet', new Set<String>());         
                    bundlesMap.get(bundleItem.Bundle__c).put('discount', bundleItem.Discount__c);         
                }
                ((Set<String>)bundlesMap.get(bundleItem.Bundle__c).get('productSet')).add(bundleItem.Product__c);
            } */
        }
        return new Map<String, Object>{
            'productResponseMap' => productResponseMap,
            'minDiscountMap' => minDiscountMap,
            'bundlesMap' => bundlesMap
        };
    }
    // DK END DE-033A Bis


    // AL 2024-04-08 -- Aggiunta metodo orderItemDelete
    @AuraEnabled
    public static Boolean orderItemDelete(List<String> chosenIdsOrderItemToDelete, List<cgcloud__Order_Item__c> recordsToUpdate) {
        Boolean isDelete=false;
        try{ 
            List<cgcloud__Order_Item__c> chosenRecordsToDelete =   [SELECT id, cgcloud__Order__c FROM cgcloud__Order_Item__c WHERE Id IN :chosenIdsOrderItemToDelete];
            delete chosenRecordsToDelete;
            System.debug('Recs eliminati');
            isDelete=true;
            if(!recordsToUpdate.isEmpty()) {
                update recordsToUpdate;
            }
            // Prendere l'ID dell'ordine dall'elemento a posizione 0 perchè sono tutti legati allo stesso order
            String orderId = chosenRecordsToDelete[0].cgcloud__Order__c;
            // Query per avere dati aggregativi dell'item 
            List<AggregateResult> agResList = [SELECT SUM(cgcloud__Value_Receipt__c) totaleRiga, SUM(cgcloud__Quantity__c) totaleQuantita
                                               FROM cgcloud__Order_Item__c
                                               WHERE cgcloud__Order__c = :orderId];
            Boolean agResListNoEmpty=!agResList.isEmpty();
            System.debug('DK agResList' + JSON.serialize(agResList));
            // Update 
            update new cgcloud__Order__c(
                Id = orderId, 
                cgcloud__Gross_Total_Value__c = (agResListNoEmpty&&agResList[0].get('totaleRiga')==null?0:(Decimal)agResList[0].get('totaleRiga')), 
                cgcloud__Value__c = (agResListNoEmpty&&agResList[0].get('totaleRiga')==null? 0 : (Decimal)agResList[0].get('totaleRiga')),
                ART_total_quantity__c = (agResListNoEmpty&&agResList[0].get('totaleQuantita')==null?0:(Decimal)agResList[0].get('totaleQuantita'))
            );
        }catch(System.DMLException ex) {throw new AuraHandledException(ex.getMessage().split(',')[1].split(':')[0]);
        }catch(System.Exception ex) {throw new AuraHandledException(ex.getMessage());}
        return isDelete;
    }
    // AL 2024-04-08 -- Fine 
}