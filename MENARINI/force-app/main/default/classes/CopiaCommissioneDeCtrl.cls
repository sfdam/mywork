/**
 * @Name		  : CopiaCommissioneDeCtrl 
 * @CreateDate    : 2023-03-10
 * @Description   : Controller per la pagina VS CopiaCommissioneDe
 * @ClassTest     : CopiaCommissioneDeCtrl_Test
 * ------------------------------------------------
 * @UpdateDate	  : 2023-05-10
 * @LabelUsed 	  : AL 2023-05-10	 
 * @Description   : Modifica dello sconto
 * ------------------------------------------------
 * @UpdateDate	  : 2023-07-05
 * @LabelUsed 	  : AL 2023-07-5	 
 * @Description   : 1) Eliminare la colonna Prezzo Netto
 * 					2) Sostituire Totale Netto con cgcloud__Value__c 
 * ------------------------------------------------
 * @UpdateDate	  : 2023-09-03
 * @LabelUsed 	  : AL 2023-09-03	 
 * @Description   : Aggiunta colonna per sconto 1% per ruolo Pharma (nuovo ruolo per controller) 
 */
public with sharing class CopiaCommissioneDeCtrl {
    
    public class ItemFirstTable {
        public String name_Account { get;set; }
        public String thr_CustomerIdentificationCode_Account { get;set; }
        public String shippingStreet_Account { get;set; }
        public String shippingPostalCode_Account { get;set; }
        public String shippingCity_Account { get;set; }
        public String shippingState_Account { get;set; }
        public String shippingCountry { get;set; }
        public String thr_VATNumber_Account { get;set; } 
        public String thr_CUU_Account { get;set; } 
        public String orderName { get;set; }
        public String orderDate { get;set; }
        public String nameOrderTemplate { get;set; }
        public String orderPhase { get;set; }
        public String art_Delay_days { get;set; }
        public String responsibleName { get;set; }
        public String delivery_Note { get;set; }
        public String labelPrezzo { get;set; }
        
        // Tipologie di template
        public Boolean nameTemplateDirettoFarma { get;set; }
        public Boolean nameTemplateOrdineDirOTC { get;set; }
        public Boolean nameTemplateTO { get;set; }
    }
    
    public class ItemSecondTable {
        public String thr_IndustryStandard_Product { get;set; }
        public String code_Product { get;set; }
        public String name_Product { get;set; }
        public String pricing_Info_1 { get;set; }
        public String quantity { get;set; }
        public String discount { get;set; }
        public String value { get;set; }
        public String sconto1percent { get;set; }
    }
    
    public ItemFirstTable order { get;set; } 
    public List<ItemSecondTable> orderItems { get;set; }
    public String totalValueItem  { get;set; }
    public Integer sizeOrderItems { get;set; }
    
    private String templateName;
    
    public CopiaCommissioneDeCtrl(ApexPages.StandardController controller) {
        
        cgcloud__Order__c curRec = (cgcloud__Order__c) controller.getRecord();        
        // SOQL
        List<cgcloud__Order_Item__c> datas = [
            SELECT Id,
            cgcloud__Product__r.THR_IndustryStandard__c,
            cgcloud__Product__r.ProductCode,
            cgcloud__Product__r.Name,
            cgcloud__Product__r.THR_DiscountSegment__c, 
            cgcloud__Product__r.THR_TaxClassification__c, 
            cgcloud__Product__r.THR_ZLAW__c, 	// AL 2023-05-10 -- Aggiunta del campo
			cgcloud__Product__c,  				// AL 2023-10-03 -- Aggiunta colonna per sconto 1% per ruolo Pharma
            cgcloud__Pricing_Info_1__c,
            cgcloud__Price__c,
            cgcloud__Quantity__c,
            cgcloud__Discount__c,
            cgcloud__Value__c,            
            cgcloud__Order__r.cgcloud__Order_Account__r.Name,
            cgcloud__Order__r.cgcloud__Order_Account__r.THR_CustomerIdentificationCode__c,
            cgcloud__Order__r.cgcloud__Order_Account__r.ShippingStreet,
            cgcloud__Order__r.cgcloud__Order_Account__r.ShippingPostalCode,
            cgcloud__Order__r.cgcloud__Order_Account__r.ShippingCity,
            cgcloud__Order__r.cgcloud__Order_Account__r.ShippingState,
            cgcloud__Order__r.cgcloud__Order_Account__r.ShippingCountry,
            cgcloud__Order__r.cgcloud__Order_Account__r.THR_VATNumber__c,
            cgcloud__Order__r.cgcloud__Order_Account__r.THR_CUU__c,
            cgcloud__Order__r.Name,
            cgcloud__Order__r.cgcloud__Order_Date__c,
            cgcloud__Order__r.cgcloud__Order_Template__r.Name, 
            cgcloud__Order__r.cgcloud__Phase__c,
            cgcloud__Order__r.ART_Delay_days__c,
            cgcloud__Order__r.cgcloud__Responsible__r.Name,
            cgcloud__Order__r.cgcloud__Delivery_Note__c
            FROM cgcloud__Order_Item__c
            WHERE cgcloud__Order__c = :curRec.Id
            ORDER BY cgcloud__Product__r.Name
        ];     
        if(!datas.isEmpty()) {
            cgcloud__Order_Item__c firstElement = datas.get(0);
	        templateName = firstElement.cgcloud__Order__r.cgcloud__Order_Template__r.Name;
            System.debug('templateName ctrl ' + templateName);
            buildFirstWrapper(firstElement);
            buildSecondWrapper(datas);
        }
    }
    
    private void buildFirstWrapper(cgcloud__Order_Item__c data) {
        order = new ItemFirstTable();        
        order.name_Account = data.cgcloud__Order__r.cgcloud__Order_Account__r.Name;
        order.thr_CustomerIdentificationCode_Account = data.cgcloud__Order__r.cgcloud__Order_Account__r.THR_CustomerIdentificationCode__c;
        order.shippingStreet_Account = data.cgcloud__Order__r.cgcloud__Order_Account__r.ShippingStreet;
        order.shippingPostalCode_Account = data.cgcloud__Order__r.cgcloud__Order_Account__r.ShippingPostalCode;
        order.shippingCity_Account = data.cgcloud__Order__r.cgcloud__Order_Account__r.ShippingCity;
        order.shippingState_Account = data.cgcloud__Order__r.cgcloud__Order_Account__r.ShippingState;
        order.shippingCountry = data.cgcloud__Order__r.cgcloud__Order_Account__r.ShippingCountry;
        order.thr_VATNumber_Account = data.cgcloud__Order__r.cgcloud__Order_Account__r.THR_VATNumber__c; 
        order.thr_CUU_Account = data.cgcloud__Order__r.cgcloud__Order_Account__r.THR_CUU__c;
        order.orderName = data.cgcloud__Order__r.Name;
        order.orderDate = data.cgcloud__Order__r.cgcloud__Order_Date__c.format();
        order.nameOrderTemplate = templateName;
        order.orderPhase = data.cgcloud__Order__r.cgcloud__Phase__c;
        order.art_Delay_days = data.cgcloud__Order__r.ART_Delay_days__c;
        order.responsibleName = data.cgcloud__Order__r.cgcloud__Responsible__r.Name;
        order.delivery_Note = data.cgcloud__Order__r.cgcloud__Delivery_Note__c;
        
        // Tipologie di template
        order.nameTemplateDirettoFarma = templateName == 'Ordine Diretto Pharma';
        order.nameTemplateOrdineDirOTC = templateName == 'Ordine Diretto OTC';
        order.nameTemplateTO           = templateName   == 'Transfer Order';
        //order.namePharma               = templateName == 'Pharma'; // AL 2023-10-03 -- Aggiunta colonna per sconto 1% per ruolo Pharma
        if(order.nameTemplateDirettoFarma) {
            order.labelPrezzo = label.Prezzo_Al_Pubblico;
		}else{
            order.labelPrezzo = label.Prezzo_Unitario;
		}
    }
    
    private void buildSecondWrapper(List<cgcloud__Order_Item__c> datas) {
        // AL 2023-10-03 -- Aggiunta colonna per sconto 1% per ruolo Pharma
        Set<Id> productSetZ1=new Set<Id>();
        Set<Id> productsSet = new Set<Id>();
        List<Id> keysMap = null;
        Map<Id, String> mapSconto1percentList = new Map<Id, String>();
        if('Ordine Diretto Pharma' == templateName) {
            for(cgcloud__Order_Item__c data : datas) {
                if(data.cgcloud__Product__c != null) {
                    productsSet.add(data.cgcloud__Product__c);
                }
            }
            for(PricebookEntry pricebookEntryObj : [select Product2Id from PricebookEntry
                                  					where THR_Z1PC__c = 1 and Product2Id IN :productsSet]) {
                productSetZ1.add(pricebookEntryObj.Product2Id);
            }
        }
        // AL 2023-10-03 -- Fine
        orderItems = new List<ItemSecondTable>();
        Decimal totalValueItemNum 	= 0;
        //Decimal val               	= 0; // Prezzo Netto // AL 2023-07-05 -- Eliminare la colonna Prezzo Netto
        Decimal priceInfo1			= 0; // Prezzo al Pubblico
        String thd_discuond = '';
        for(cgcloud__Order_Item__c data : datas) {
            //val = 0; // AL 2023-07-05 -- Eliminare la colonna Prezzo Netto
            priceInfo1 = 0;
            
            ItemSecondTable singleOrder = new ItemSecondTable();
            singleOrder.thr_IndustryStandard_Product = data.cgcloud__Product__r.THR_IndustryStandard__c;
            singleOrder.code_Product = data.cgcloud__Product__r.ProductCode;
            singleOrder.name_Product = data.cgcloud__Product__r.Name;

            // calcolo Prezzo Netto
            if(order.nameTemplateDirettoFarma) {
            	// AL 2023-10-03 -- Aggiunta colonna per sconto 1%
            	singleOrder.sconto1percent = (productSetZ1.contains(data.cgcloud__Product__c) ? '1%' : '');
                // AL 2023-10-03 -- Fine 
                
                priceInfo1 = data.cgcloud__Pricing_Info_1__c; // prezzo al pubblico
                thd_discuond = data.cgcloud__Product__r.THR_DiscountSegment__c;
                if(thd_discuond == 'A' || thd_discuond == 'E') {
                    // AL 2023-07-05 -- Eliminare la colonna Prezzo Netto
                    //val = data.cgcloud__Price__c.setScale(2);
                    //singleOrder.price = SV_Utilities.formatCommaSep(data.cgcloud__Price__c, 2); // prezzo netto
                    singleOrder.discount = SV_Utilities.formatCommaSep(data.cgcloud__Product__r.THR_ZLAW__c, 2);
                    // AL 2023-05-10 -- Fine
                }  else if(thd_discuond == 'C') {                    
                    // AL 2023-05-10 -- Modifica del calcolo dello sconto
                    singleOrder.discount = SV_Utilities.formatCommaSep(data.cgcloud__Discount__c, 2);
                    // AL 2023-05-10 -- Fine
                }
            } else if(order.nameTemplateOrdineDirOTC) {
                priceInfo1 = data.cgcloud__Price__c;                
                singleOrder.discount = SV_Utilities.formatCommaSep(data.cgcloud__Discount__c, 2);
            }
            // AL 2023-10-03 -- Aggiunta colonna per sconto 1% per ruolo Pharma
            /*else if(order.namePharma) {
                singleOrder.sconto1percent = (productSetZ1.contains(data.cgcloud__Product__c) ? '1%' : '');
            }*/
            // AL 2023-10-03 -- Fine
            singleOrder.pricing_Info_1 = SV_Utilities.formatCommaSep(priceInfo1, 2); // Prezzo Unitario/al Pubblico            
            singleOrder.quantity = data.cgcloud__Quantity__c.format();
            //singleOrder.discount = SV_Utilities.formatCommaSep(data.cgcloud__Discount__c, 2); // AL 2023-05-10 -- Modifica del calcolo dello sconto
 			
            // AL 2023-07-05 -- Modifiica totale netto e Sostituire Totale Netto con cgcloud__Value__c 
            // singleOrder.value = SV_Utilities.formatCommaSep(val*data.cgcloud__Quantity__c, 2); //Totale Netto
            singleOrder.value = SV_Utilities.formatCommaSep(data.cgcloud__Value__c, 2); //Totale Netto
            orderItems.add(singleOrder);
            
            //totalValueItemNum = totalValueItemNum + (val * data.cgcloud__Quantity__c).setScale(2); // Totale Netto Ordine 
            totalValueItemNum += data.cgcloud__Value__c;
            // AL 2023-07-05 -- Fine
        }
        totalValueItem = SV_Utilities.formatCommaSep(totalValueItemNum, 2);
        sizeOrderItems = orderItems.size();
	}
}