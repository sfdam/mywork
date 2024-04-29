@isTest
public class ART_AdvancedOrderTriggerHandlerTest {
	
    @isTest 
    static void test()
    { 
        
    	Test.startTest();
        
        cgcloud__Order_Template__c orderTemplateOTC = new cgcloud__Order_Template__c
        (
            Name = 'Ordine Diretto OTC'
        );
        insert orderTemplateOTC;
        
        cgcloud__Order_Template__c orderTemplateDerma = new cgcloud__Order_Template__c
        (
            Name = 'Ordine Diretto Derma'
        );
        insert orderTemplateDerma;
        
        cgcloud__Order_Template__c orderTemplatePharma = new cgcloud__Order_Template__c
        (
            Name = 'Ordine Diretto Pharma'
        );
        insert orderTemplatePharma;
        
        Account payer = new Account
        (
            Name = 'payer',
            ART_PaymentCondition_OTC__c = 'RIMESSA DIRETTA 90 GG.',
            BillingCountry = 'Italy',
            BillingState = 'Milano',
            BillingStreet = 'VIALE LOMBARDIA 8'
        );
        insert payer;
        
        Account ruralPayer = new Account
        (
            Name = 'ruralPayer',
            ART_PaymentCondition_OTC__c = 'RIMESSA DIRETTA 90 GG.',
            BillingCountry = 'Italy',
            BillingState = 'Milano',
            BillingStreet = 'VIALE LOMBARDIA 8',
            ART_Rural__c = true
        );
        insert ruralPayer;
        
        Account recipient = new Account
        (
            Name = 'recipient',
            BillingCountry = 'Italy',
            BillingState = 'Milano',
            BillingStreet = 'VIALE LOMBARDIA 8'
        );
        insert recipient;
        
        List<cgcloud__Order__c> orders = new List<cgcloud__Order__c>();
        
        orders.add(
        new cgcloud__Order__c(
        	cgcloud__Phase__c = 'Released',
            cgcloud__Mobility_Release__c = True,
            cgcloud__Order_Template__c = orderTemplateOTC.Id,
            ART_Delay_days__c = '90',
            cgcloud__Payer__c = payer.Id,
            ART_Payment_Code__c = 'test',
            cgcloud__Delivery_Recipient__c = recipient.Id
        ));
        orders.add(
        new cgcloud__Order__c(
        	cgcloud__Phase__c = 'Released',
            cgcloud__Mobility_Release__c = True,
            cgcloud__Order_Template__c = orderTemplateOTC.Id,
            cgcloud__Payer__c = payer.Id,
            ART_Payment_Code__c = 'test',
            cgcloud__Delivery_Recipient__c = recipient.Id
        ));
        orders.add(
        new cgcloud__Order__c(
        	cgcloud__Phase__c = 'Released',
            cgcloud__Mobility_Release__c = True,
            cgcloud__Order_Template__c = orderTemplateDerma.Id,
            ART_Delay_days__c = '90',
            cgcloud__Payer__c = payer.Id,
            ART_Payment_Code__c = 'test',
            cgcloud__Delivery_Recipient__c = recipient.Id
        ));
        orders.add(
        new cgcloud__Order__c(
        	cgcloud__Phase__c = 'Released',
            cgcloud__Mobility_Release__c = True,
            cgcloud__Order_Template__c = orderTemplateDerma.Id,
            cgcloud__Payer__c = payer.Id,
            ART_Payment_Code__c = 'test',
            cgcloud__Delivery_Recipient__c = recipient.Id
        ));
        orders.add(
        new cgcloud__Order__c(
        	cgcloud__Phase__c = 'Released',
            cgcloud__Mobility_Release__c = True,
            cgcloud__Order_Template__c = orderTemplatePharma.Id,
            ART_Delay_days__c = '90',
            cgcloud__Payer__c = payer.Id,
            ART_Payment_Code__c = 'test',
            cgcloud__Delivery_Recipient__c = recipient.Id
        ));
        orders.add(
        new cgcloud__Order__c(
        	cgcloud__Phase__c = 'Released',
            cgcloud__Mobility_Release__c = True,
            cgcloud__Order_Template__c = orderTemplatePharma.Id,
            ART_Delay_days__c = '90',
            cgcloud__Payer__c = ruralPayer.Id,
            ART_Payment_Code__c = 'test',
            cgcloud__Delivery_Recipient__c = recipient.Id,
            ART_Dilazione_da_approvare__c = true
        ));

        System.debug('DK Test_orders: ' + JSOn.serialize(orders));
        insert orders;
        List<cgcloud__Order_Item__c> orderItemToInsertList = new List<cgcloud__Order_Item__c>();
        for(cgcloud__Order__c order : orders){

            cgcloud__Order_Item__c orderItem = new cgcloud__Order_Item__c
            (
                cgcloud__Order__c = order.Id
            );
            orderItemToInsertList.add(orderItem);
        }
        insert orderItemToInsertList;

    
        try {
            ART_AdvancedOrderTriggerHandler.submitForApproval(orders[5]);
        } catch (Exception ex) {}
        // oliList.add(orderItem);
        // ART_AdvancedOrderTriggerHandler.resetRowsIndexAfterDelete(oliList);
        
		//Update orders;
        //ART_AdvancedOrderTriggerHandler.dilazionePagamentoBeforeInsert(orders);
        
        Test.stopTest();
		
    }
}