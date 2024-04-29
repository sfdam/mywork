/**
 * @description       : 
 * @author            : simone.viglianti@accenture.com
 * @group             : 
 * @last modified on  : 08-28-2020
 * @last modified by  : simone.viglianti@accenture.com
 * Modifications Log 
 * Ver   Date         Author                           Modification
 * 1.0   08-14-2020   simone.viglianti@accenture.com   Initial Version
**/
public with sharing class THR_CreateCaseItemsController {
 
    @AuraEnabled
    public static List<THR_InvoiceItem__c> searchInvoice(Date ddtDate, String ddtNumber, String caseId, String country, String accountId){
        System.debug(LoggingLevel.DEBUG,'date: '+ddtDate);
        System.debug(LoggingLevel.DEBUG,'number: '+ddtNumber);
        List<THR_InvoiceItem__c> itemList = new List<THR_InvoiceItem__c>();
        if(accountId != null && !String.isBlank(accountId)){
           itemList = [SELECT Id, 
                            THR_DateDDT__c, 
                            THR_DDT__c,
                            THR_Quantity__c, 
                            THR_InvoiceNumber__r.Id,
                            THR_InvoiceNumber__r.Net_Value_RU__c,
                            THR_ProductName__c,
                            THR_EndCustomerName__c,
                            THR_MaterialDescription__c,
                            THR_BatchNumber__c,
                            THR_MaterialID__c,
                            THR_NetValue__c
                        FROM THR_InvoiceItem__c 
                        WHERE THR_DateDDT__c = :ddtDate 
                        AND THR_DDT__c = :ddtNumber
                        AND THR_InvoiceItem_Country__c = :country
                        AND ( THR_InvoiceNumber__r.THR_SendTo__c = :accountId 
                            	  OR
                             	THR_InvoiceNumber__r.THR_Payer__c = :accountId 
                            
                            ) 
                     	ORDER BY THR_ProductName__c];
        }else{
             itemList = [SELECT Id, 
                                THR_DateDDT__c, 
                                THR_DDT__c,
                                THR_Quantity__c, 
                                THR_InvoiceNumber__r.Id,
                                THR_ProductName__c,
                                THR_BatchNumber__c,
                                THR_MaterialID__c,
                        		THR_NetValue__c
                         FROM THR_InvoiceItem__c 
                         WHERE THR_DateDDT__c = :ddtDate 
                         AND THR_DDT__c = :ddtNumber
                         AND THR_InvoiceItem_Country__c = :country
                         ORDER BY THR_ProductName__c];
        }
        
        System.debug(LoggingLevel.INFO,'Item List: '+itemList);

        List<THR_Related_Object__c> caseItems = [SELECT THR_InvoiceItem__c 
                                                 FROM THR_Related_Object__c 
                                                 WHERE THR_Case_Related__c = :caseId];

        System.debug(LoggingLevel.INFO,'lista case items: '+caseItems);                            

        if(!caseItems.isEmpty()){
            Map<String,String> caseItemsMap = new Map<String,String>();
            for(THR_Related_Object__c obj : caseItems){
                caseItemsMap.put(obj.THR_InvoiceItem__c,obj.THR_InvoiceItem__c);
            }
            Integer i = 0;
            while(i< itemList.size()){
                if(caseItemsMap.get(itemList[i].id) != null){
                    itemList.remove(i);
                }else{
                    i++;
                }
            }
        }

        System.debug(LoggingLevel.DEBUG,'List Invoice Item: '+itemList);
  		return itemList;
    }
    @AuraEnabled
    public static String createItem(List<THR_InvoiceItem__c> itemId, Id caseId, List<THR_InvoiceItem__c> itemOriginal, String ddtNumber, Date ddtDate){
        System.debug(LoggingLevel.DEBUG,'@@@@createItem lista: '+itemId);
        System.debug(LoggingLevel.DEBUG,'@@@@createItem lista originale: '+itemOriginal);
        System.debug(LoggingLevel.DEBUG,'@@@@createItem caseId: '+caseId);
        System.debug(LoggingLevel.DEBUG,'@@@@createItem ddtNumber: '+ddtNumber);
        System.debug(LoggingLevel.DEBUG,'@@@@createItem ddtDate: '+ddtDate);
        String val = '';
        String ddtdat = String.valueOf(ddtDate);
        ddtdat = ddtdat.substringBefore('00:');
        Boolean allDDT = true;
        Boolean allDDTexist = false;
        
        Map<Id, Integer> prIdToQuantitySelectedItem = new Map<Id, Integer>();
        Map<Id, Integer> prIdToQuantityOriginal = new Map<Id, Integer>();
        
        
        System.debug('date: '+ddtdat);
        List<THR_Related_Object__c> caseItemList = new List<THR_Related_Object__c>();
        
                        Product2 prod = [SELECT Id,
                                        Name 
                                 FROM Product2 
                                 WHERE THR_MaterialKey__c = 'FK0001'];
        
        
        system.debug('@@@@createItem prod is '+prod);
        List<THR_Related_Object__c> caseItems = [SELECT ID,
                                                         THR_Product__c,
                                                         THR_Product_Quantity__c,
                                                         THR_InvoiceItem__c 
                                                         FROM THR_Related_Object__c 
                                                         WHERE THR_Case_Related__c = :caseId
                                                         AND  THR_Product__c != null];
        system.debug('@@@@createItem caseItems is '+caseItems);

        try{
            
             for(THR_InvoiceItem__c item : itemId){
                 
                 if(!prIdToQuantitySelectedItem.containsKey(item.THR_MaterialID__c)){
						prIdToQuantitySelectedItem.put(item.THR_MaterialID__c, 0);                 
                 }
                 System.debug('@@@ creating map from invItem : [' + item.THR_MaterialID__c + ']  | Actual :' + prIdToQuantitySelectedItem.get(item.THR_MaterialID__c) + 'to Add : ' + (Integer) item.THR_Quantity__c );
                 prIdToQuantitySelectedItem.put(item.THR_MaterialID__c, prIdToQuantitySelectedItem.get(item.THR_MaterialID__c) + (Integer) item.THR_Quantity__c);                 
  				
                 System.debug('@@@ creating map from invItem : [' + item.THR_MaterialID__c + ']  | Added ' + prIdToQuantitySelectedItem.get(item.THR_MaterialID__c)  );
             }
            
             for(THR_Related_Object__c item : caseItems){
                 
                 if(prod.Id.equals(item.THR_Product__c) ){
                     allDDTexist = true;
                 }
                 
                 if(!prIdToQuantitySelectedItem.containsKey(item.THR_Product__c)){
						prIdToQuantitySelectedItem.put(item.THR_Product__c, 0);           
                 }
                 System.debug('@@@ creating map from caseItem : [' + item.THR_Product__c + ']  | Actual :' + prIdToQuantitySelectedItem.get(item.THR_Product__c) + ' to Add : ' + (Integer) item.THR_Product_Quantity__c );

                 prIdToQuantitySelectedItem.put(item.THR_Product__c, prIdToQuantitySelectedItem.get(item.THR_Product__c) + (Integer) item.THR_Product_Quantity__c);                 
  				 System.debug('@@@ creating map from caseItem : [' + item.THR_Product__c + ']  | Added ' + prIdToQuantitySelectedItem.get(item.THR_Product__c)  );
             }
               
                               
             for(THR_InvoiceItem__c item : [SELECT Id, 
                                                    THR_DateDDT__c, 
                                                    THR_DDT__c,
                                                    THR_Quantity__c, 
                                                    THR_MaterialID__r.Name,
                                                    THR_BatchNumber__c,
                                                    THR_MaterialID__c,
                                             		THR_NetValue__c
                                             FROM THR_InvoiceItem__c 
                                             WHERE THR_DateDDT__c = :itemOriginal[0].THR_DateDDT__c
                                             AND THR_DDT__c = :itemOriginal[0].THR_DDT__c
                                             AND THR_InvoiceNumber__c = :itemOriginal[0].THR_InvoiceNumber__c]){
                 
                 if(!prIdToQuantityOriginal.containsKey(item.THR_MaterialID__c)){
						prIdToQuantityOriginal.put(item.THR_MaterialID__c, 0);                 
                 }
                 prIdToQuantityOriginal.put(item.THR_MaterialID__c, prIdToQuantityOriginal.get(item.THR_MaterialID__c) + (Integer) item.THR_Quantity__c);                 
                 
             }
            
  
            for( Id key : prIdToQuantityOriginal.keySet() ){
                
                
                System.debug('@@@ Using Key : [' + key + '] Orininal ' + prIdToQuantityOriginal.get(key) + ' | selected + items ' + prIdToQuantitySelectedItem.get(key)  );
                
                if(!prIdToQuantitySelectedItem.containsKey(key)){
                    allDDT = false;
                   
                }else{
                    if(prIdToQuantitySelectedItem.get(key) != prIdToQuantityOriginal.get(key) ){
                         allDDT = false;
                    	 
                    }
                }
                
                
            }
            
            if(allDDT || allDDTExist){
            //if(itemId.size() == itemOriginal.size()){
               
                List<String> invoiceId = new List<String>();
                Double Net_Value_Invoice ;
                for(THR_InvoiceItem__c item : itemOriginal){
                    invoiceId.add(item.THR_InvoiceNumber__r.Id);
                    Net_Value_Invoice = item.THR_InvoiceNumber__r.Net_Value_RU__c;
                }      
                if(!caseItems.isEmpty() && caseItems != null){
                    delete caseItems;   
                }                                   
                                                      


                THR_Related_Object__c obj = new THR_Related_Object__c();
                //obj.THR_Batch__c = itemId.get(0).THR_BatchNumber__c;
                obj.THR_Product__c = prod.Id;
                obj.THR_Invoice__c = invoiceId.get(0);
                obj.THR_Related_Object__c = 'Product';
                obj.THR_Product_Quantity__c = 1;
                 obj.THR_ProductUnitPrice__c =Net_Value_Invoice;
                obj.THR_Case_Related__c = caseId;
                obj.THR_Description__c = prod.Name+': '+ddtNumber+' del '+ddtdat;
                caseItemList.add(obj);
            }else{
                for(THR_InvoiceItem__c itemInvoice : itemId){
                    THR_Related_Object__c obj = new THR_Related_Object__c();
                    obj.THR_Batch__c = itemInvoice.THR_BatchNumber__c;
                    obj.THR_Product__c = itemInvoice.THR_MaterialID__c;
                    obj.THR_Product_Quantity__c = itemInvoice.THR_Quantity__c;
                    //obj.THR_ProductUnitPrice__c = itemInvoice.THR_NetValue__c;
                    obj.THR_Invoice__c = itemInvoice.THR_InvoiceNumber__r.Id;
                    obj.THR_Case_Related__c = caseId;
                    obj.THR_Related_Object__c = 'Product';
                    obj.THR_InvoiceItem__c = itemInvoice.id;
                    caseItemList.add(obj);
                }
            }
        	if(!caseItemList.isEmpty()){
            	insert caseItemList;
            	val='OK';
        	}
        }catch(Exception e){
            System.debug(e.getMessage());
        }
    	
        return val;
    }

    @AuraEnabled
    public static Map<Id,Decimal> updateInvoiceItem(Date ddtDate, String ddtNumber){
        
        List<THR_InvoiceItem__c> itemList = [SELECT Id, 
                                                    THR_DateDDT__c, 
                                                    THR_DDT__c,
                                                    THR_Quantity__c, 
                                                    THR_MaterialID__r.Name,
                                                    THR_BatchNumber__c,
                                                    THR_MaterialID__c,
                                             		THR_NetValue__c
                                             FROM THR_InvoiceItem__c 
                                             WHERE THR_DateDDT__c = :ddtDate 
                                             AND THR_DDT__c = :ddtNumber];
        
        Map<Id,Decimal> quantityMap = new Map<Id,Decimal>();
        for(THR_InvoiceItem__c item : itemList){
            quantityMap.put(item.Id,item.THR_Quantity__c);
        }
        System.debug('Map: '+quantityMap);
        return quantityMap;    
    }

    @AuraEnabled
    public static Case retrieveCaseField(String caseId){
        Case cs = [SELECT THR_DDTdate__c, 
                          THR_DDTNumber__c, 
                          THR_Country__c,
                          AccountId,
                          Account.Name
                   FROM Case 
                   WHERE Id =:caseId];
        System.debug('Case' +cs);
        return cs;           
    }
}