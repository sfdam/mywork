global without sharing class BatchCreateAssortmentProduct implements Database.Batchable<SObject>,Schedulable{
   
        public final static String pricebookPH = 'ITDST1FA';
        public final static String pricebookOT = 'ITDST1OT';
        global Database.QueryLocator start(Database.BatchableContext BC) {
        
            return Database.getQueryLocator(  
                [SELECT id,name,THR_MaterialGroup__c,THR_Plant__c,THR_XPlantMaterialStatus__c,THR_Division__c,cgcloud__Product_Template__c
                FROM Product2]);
           
        }

        global void execute(SchedulableContext SC) {
            BatchCreateAssortmentProduct batchCreateAssortment = new BatchCreateAssortmentProduct();
            Database.executeBatch(batchCreateAssortment);
        }

        global void execute(Database.BatchableContext BC, List<sObject> scope) {

            Map<id,PricebookEntry> MapIdProdIdPEntry = new Map<id,PricebookEntry>();
            for (PricebookEntry PE : [select Id, product2id, Pricebook2id, Pricebook2.name from PricebookEntry where Pricebook2.name in ('pricebookPH', 'pricebookOT')]){
                MapIdProdIdPEntry.put(PE.product2id,PE);
            }

            Map<String,assortment> MapAss = new Map<String,assortment>();
            for( assortment a : [select id, name from Assortment]){
                MapAss.put(a.name,a);
            }
            
            List<AssortmentProduct> AssProdToInsert = new    List<AssortmentProduct>();
            for(Product2 prod : (List <product2>)scope){
                //TO da rivedere un attimo
                // if((prod.THR_MaterialGroup__c =='PFPI' || prod.THR_MaterialGroup__c =='FDEP' || (prod.THR_MaterialGroup__c =='MPRF' && prod.THR_Plant__c == 'FIR1')) && prod.THR_XPlantMaterialStatus__c !='3' && ((prod.THR_Division__c =='OT' && prod.THR_Plant__c == 'FIR1') || (prod.THR_Division__c =='FA' && (prod.THR_Plant__c == 'FIR1' || prod.THR_Plant__c == 'GDT1' || prod.THR_Plant__c == 'MEN1' || prod.THR_Plant__c == 'LUS1' || prod.THR_Plant__c == 'MLS1'))) && (prod.cgcloud__Product_Template__c !=null) && (MapIdProdIdPEntry.get(prod.id).Pricebook2.name =='ITDST1FA' || MapIdProdIdPEntry.get(prod.id).Pricebook2.name == 'ITDST1OT') && (prod.THR_MaterialGroup__c == 'MPRF')) {
                    
                //     AssProdToInsert.add(
                //         new AssortmentProduct(
                //         Product2id = prod.id,
                //         cgcloud__Active__c = true,
                //         cgcloud__Valid_From__c = date.newinstance(2023,01,01),
                //         cgcloud__Valid_Thru__c = date.newinstance(2099,12,12),
                //         AssortmentId = MapAss.get('Pharma').id
                //     ));
                // }
                //PHARMA
                if((prod.THR_MaterialGroup__c =='PFPI' || prod.THR_MaterialGroup__c =='FDEP' || (prod.THR_MaterialGroup__c =='MPRF' && prod.THR_Plant__c == 'FIR1')) && prod.THR_XPlantMaterialStatus__c !='3' && (prod.THR_Division__c =='FA' && (prod.THR_Plant__c =='FIR1' || prod.THR_Plant__c =='GDT1'||prod.THR_Plant__c =='MEN1' || prod.THR_Plant__c =='LUS1' || prod.THR_Plant__c =='MLS1' )) && prod.cgcloud__Product_Template__c != null && (prod.cgcloud__Product_Template__c !=null) && (MapIdProdIdPEntry.get(prod.id).Pricebook2.name =='ITDST1FA')){
                    AssProdToInsert.add(
                        new AssortmentProduct(
                        ProductId = prod.id,
                        cgcloud__Active__c = true,
                        cgcloud__Valid_From__c = date.newinstance(2023,01,01),
                        cgcloud__Valid_Thru__c = date.newinstance(2099,12,12),
                        AssortmentId = MapAss.get('Pharma').id
                    ));

                    if(prod.Transfer_Order__c == true){
                        AssProdToInsert.add(
                        new AssortmentProduct(
                        ProductId = prod.id,
                        cgcloud__Active__c = true,
                        cgcloud__Valid_From__c = date.newinstance(2023,01,01),
                        cgcloud__Valid_Thru__c = date.newinstance(2099,12,12),
                        AssortmentId = MapAss.get('Transfer Order').id
                    ));
                    }
                }
                //OTC
                if((prod.THR_MaterialGroup__c =='PFPI' || prod.THR_MaterialGroup__c =='FDEP' || (prod.THR_MaterialGroup__c =='MPRF' && prod.THR_Plant__c == 'FIR1')) && prod.THR_XPlantMaterialStatus__c !='3'&& ((prod.THR_Division__c == 'OT' && prod.THR_Plant__c == 'FIR1')) && prod.cgcloud__Product_Template__c != null && (MapIdProdIdPEntry.get(prod.id).Pricebook2.name =='ITDST1OT' || prod.THR_MaterialGroup__c == 'MPRF')){
                    AssProdToInsert.add(
                        new AssortmentProduct(
                        ProductId = prod.id,
                        cgcloud__Active__c = true,
                        cgcloud__Valid_From__c = date.newinstance(2023,01,01),
                        cgcloud__Valid_Thru__c = date.newinstance(2099,12,12),
                        AssortmentId = MapAss.get('OTC').id
                    ));

                    if(prod.Transfer_Order__c == true){
                        AssProdToInsert.add(
                        new AssortmentProduct(
                        ProductId = prod.id,
                        cgcloud__Active__c = true,
                        cgcloud__Valid_From__c = date.newinstance(2023,01,01),
                        cgcloud__Valid_Thru__c = date.newinstance(2099,12,12),
                        AssortmentId = MapAss.get('Transfer Order').id
                    ));
                    }
                 }

            }
            AssProdToInsert.sort();
            insert AssProdToInsert;
        }

        global void finish(Database.BatchableContext BC) {
            System.debug('Price Updated');
    
        }
}

/**
     * @description Batch per creazione Assortment product per sostituzione Flow
     
     */