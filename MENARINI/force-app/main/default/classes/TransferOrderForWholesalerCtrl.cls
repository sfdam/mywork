/**
 * @Author        : Alessandro Lumaca @TEN 
 * @CreateDate    : 2022-12-14
 * @Description   : Controller per la pagina VS TransferOrderForWholesaler  
 * @ClassTest     : TransferOrderForWholesalerCtrl_Test 
 * -------------------------------------------
 * @UpdateDate    : 2023-02-16 
 * @Description   : Format Date in dd/mm/aaaa di cgcloud__Order__r.cgcloud__Delivery_Date__c
 */
public with sharing class TransferOrderForWholesalerCtrl {
    
    public String wholesalerId { get;set; }
    
    //  Wrapper Class
    public class Item {
        public String  name { get;set; }
        public String  thr_IndustryStandard { get;set; }
        public String  productCode { get;set; }
        // public Decimal quantity { get;set; }
        public String quantity { get;set; }
    }
    public class OrdersItemsWrapper {
        public String orderName { get;set; }
        public String orderDelivery_Date { get;set; }
        public String orderDelivery_Recipient{ get;set; }
        public String orderDelivery_Recipient_THR_CustomerIdentificationCode { get;set; }
        public String opderDelivery_Recipient_THR_VATNumber { get;set; }
        public String orderDelivery_Recipient_Name { get;set; }
        public String orderDelivery_Recipient_BillingStreet { get;set; }
        public String orderDelivery_Recipient_BillingCity { get;set; }
        public String orderDelivery_Recipient_BillingState { get;set; }
        public String opderWholesaler_Name { get;set; }
        public String orderWholesaler_ART_Transfer_Order_Delivery_Mode { get;set; }
        public String orderWholesaler_THR_MAIL { get;set; }
        
        public List<Item> items { get;set; }
        public Decimal totalQuantityDec { get;set; }
        public String totalQuantity { get;set; }
    }
    //  Wrapper Class -- Fine

    public List<OrdersItemsWrapper> datas { get;set; }
    public Integer totalOrder { get;set;}

    /** Costruttore */
    public TransferOrderForWholesalerCtrl(ApexPages.StandardController controller) {
        // Parametri della pagine 
        wholesalerId = System.currentPageReference().getParameters().get( 'wholesalerId' );        
        
        List<Cgcloud__Order_Item__c> items = [SELECT id,
            cgcloud__Order__c,
            cgcloud__Order__r.Name,
            cgcloud__Order__r.cgcloud__Delivery_Date__c,
            cgcloud__Order__r.cgcloud__Delivery_Recipient__c,
            cgcloud__Order__r.ART_Order_To_Be_Sent__c,
            cgcloud__Order__r.ART_Order_send_block__c,
            cgcloud__Order__r.cgcloud__Phase__c, 
            cgcloud__Order__r.cgcloud__Delivery_Recipient__r.THR_CustomerIdentificationCode__c,
            cgcloud__Order__r.cgcloud__Delivery_Recipient__r.THR_VATNumber__c,
            cgcloud__Order__r.cgcloud__Delivery_Recipient__r.Name,
            cgcloud__Order__r.cgcloud__Delivery_Recipient__r.BillingStreet, // Part Of BillingAddress
            cgcloud__Order__r.cgcloud__Delivery_Recipient__r.BillingCity,   // Part Of BillingAddress
            cgcloud__Order__r.cgcloud__Delivery_Recipient__r.BillingState,  // Part Of BillingAddress  
            cgcloud__Order__r.cgcloud__Wholesaler__c,   // Account
            cgcloud__Order__r.cgcloud__Wholesaler__r.Name,
            cgcloud__Order__r.cgcloud__Wholesaler__r.ART_Transfer_Order_Delivery_Mode__c,
            cgcloud__Order__r.cgcloud__Wholesaler__r.THR_MAIL__c,
            cgcloud__Product__r.THR_IndustryStandard__c,
            cgcloud__Product__r.Name,
            cgcloud__Product__r.ProductCode,
            cgcloud__Quantity__c
            FROM cgcloud__Order_Item__c 
            WHERE cgcloud__Order__r.cgcloud__Wholesaler__c = :wholesalerId  
                AND cgcloud__Order__r.ART_Order_To_Be_Sent__c = true 
                 AND cgcloud__Order__r.ART_Order_send_block__c = false 
                AND cgcloud__Order__r.cgcloud__Phase__c = 'Ready'
            ORDER BY cgcloud__Order__r.Name
        ];
        if( !items.isEmpty() ) {
            buildDatas(items);
        }        
    }

    private void buildDatas(List<Cgcloud__Order_Item__c> items) {
        
        this.datas = new List<OrdersItemsWrapper>();
        Id preOrder         = items.get(0).cgcloud__Order__c;
        boolean isFirst = true;
        totalOrder          = 0;
        
        for(Cgcloud__Order_Item__c i : items) {
            
            if(i.cgcloud__Order__c != preOrder || isFirst) {

                OrdersItemsWrapper oiw = new OrdersItemsWrapper();
                oiw.orderName = i.cgcloud__Order__r.Name;
                DateTime dt = DateTime.newInstance(  i.cgcloud__Order__r.cgcloud__Delivery_Date__c.year()
                                                   , i.cgcloud__Order__r.cgcloud__Delivery_Date__c.month()
                                                   , i.cgcloud__Order__r.cgcloud__Delivery_Date__c.day());
                oiw.orderDelivery_Date = dt.format('dd/MM/yyyy');                
                oiw.orderDelivery_Recipient = i.cgcloud__Order__r.cgcloud__Delivery_Recipient__c;
                oiw.orderDelivery_Recipient_THR_CustomerIdentificationCode = i.cgcloud__Order__r.cgcloud__Delivery_Recipient__r.THR_CustomerIdentificationCode__c;
                oiw.opderDelivery_Recipient_THR_VATNumber = i.cgcloud__Order__r.cgcloud__Delivery_Recipient__r.THR_VATNumber__c;
                oiw.orderDelivery_Recipient_Name = i.cgcloud__Order__r.cgcloud__Delivery_Recipient__r.Name;
                oiw.orderDelivery_Recipient_BillingStreet = i.cgcloud__Order__r.cgcloud__Delivery_Recipient__r.BillingStreet;
                oiw.orderDelivery_Recipient_BillingCity = i.cgcloud__Order__r.cgcloud__Delivery_Recipient__r.BillingCity;
                oiw.orderDelivery_Recipient_BillingState = i.cgcloud__Order__r.cgcloud__Delivery_Recipient__r.BillingState;
                oiw.opderWholesaler_Name = (i.cgcloud__Order__r.cgcloud__Wholesaler__r.Name != null ? i.cgcloud__Order__r.cgcloud__Wholesaler__r.Name : '' );
                oiw.orderWholesaler_ART_Transfer_Order_Delivery_Mode = i.cgcloud__Order__r.cgcloud__Wholesaler__r.ART_Transfer_Order_Delivery_Mode__c;
                oiw.orderWholesaler_THR_MAIL = i.cgcloud__Order__r.cgcloud__Wholesaler__r.THR_MAIL__c;

                Item item = new Item();
                item.name = i.cgcloud__Product__r.Name;
                item.thr_IndustryStandard = i.cgcloud__Product__r.THR_IndustryStandard__c;
                item.productCode = i.cgcloud__Product__r.ProductCode;
                item.quantity = i.cgcloud__Quantity__c.format();
                
                oiw.items = new List<Item> { item };
                oiw.totalQuantityDec = i.cgcloud__Quantity__c;
                oiw.totalQuantity = oiw.totalQuantityDec.format();
                datas.add(oiw);
                totalOrder += 1;
            } else {

                Item item = new Item();
                item.name = i.cgcloud__Product__r.Name;
                item.thr_IndustryStandard = i.cgcloud__Product__r.THR_IndustryStandard__c;
                item.productCode = i.cgcloud__Product__r.ProductCode;
                item.quantity = i.cgcloud__Quantity__c.format();

                datas.get(datas.size() - 1).totalQuantityDec += i.cgcloud__Quantity__c;
                datas.get(datas.size() - 1).totalQuantity = datas.get(datas.size() - 1).totalQuantityDec.format();
                datas.get(datas.size() - 1).items.add(item);
            }

            preOrder = i.cgcloud__Order__c;
            isFirst = false;
        }
    }
}