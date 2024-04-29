/**
 * @group             : tengroup
 * @last modified on  : 12-03-2024
 * @last modified by  : alessandro.dinardo@lutech.it
 * 
 * description        : ticket S240304_000163 
**/
public without sharing class ART_AdvancedOrderTriggerHandler {

    public static void dilazionePagamentoBeforeInsert(List<cgcloud__Order__c> orders)
    {
        /* AA 2023 07 11 Commentata logica non più utilizzata per evitare bug DE-065.1. La logica sotto, serviva per gestire la corretta valorizzazione del campo Payment code per gli ordini provenienti da app
        Set<Id> payerIds = new Set<Id>();
        Set<Id> templateIds = new Set<Id>();
        for(cgcloud__Order__c order : orders)
        {
            payerIds.add(order.cgcloud__Payer__c);
            templateIds.add(order.cgcloud__Order_Template__c);
        }
        
        Map<Id, Account> payerAccMap = new Map<Id, Account>();
        for(Account acc : 
       [SELECT
        Id,
		ART_PaymentCondition_OTC__c,
		ART_PaymentCondition_DERMA__c,
        ART_PaymentCondition_Farma__c
        FROM Account WHERE Id in : payerIds]
        ){
            payerAccMap.put(acc.Id, acc);
        }
		
       Map<Id, cgcloud__Order_Template__c> templateMap = new Map<Id, cgcloud__Order_Template__c>();
       for(cgcloud__Order_Template__c template : 
       [SELECT
        Id,
		Name
        FROM cgcloud__Order_Template__c WHERE Id in : templateIds]
        ){
            templateMap.put(template.Id, template);
        }
        
        List<ART_PaymentConditions__mdt> paymentConditions = [ 
             SELECT ART_PaymentConditionClassCode__c, ART_PaymentConditionName__c, ART_DelayDay__c, ART_PaymentConditionCode__c
             FROM ART_PaymentConditions__mdt];

        for(cgcloud__Order__c order : orders)
        {
            if (order.cgcloud__Phase__c == 'Released' && order.cgcloud__Mobility_Release__c == True && templateMap.get(order.cgcloud__Order_Template__c).Name != 'Transfer Order')
        	{
                //System.debug('payer: ' + order.cgcloud__Payer__c);
                String paymentConditionCode;

           		if(!String.isBlank(order.ART_Delay_days__c))
                {
                    String paymentConditionClassCode;
                    for (ART_PaymentConditions__mdt paymentCondition : paymentConditions)
        			{
                    	if(
                          (templateMap.get(order.cgcloud__Order_Template__c).Name == 'Ordine Diretto OTC' && paymentCondition.ART_PaymentConditionName__c == payerAccMap.get(order.cgcloud__Payer__c).ART_PaymentCondition_OTC__c)
                        ||(templateMap.get(order.cgcloud__Order_Template__c).Name == 'Ordine Diretto Derma' && paymentCondition.ART_PaymentConditionName__c == payerAccMap.get(order.cgcloud__Payer__c).ART_PaymentCondition_DERMA__c)
                        ||(templateMap.get(order.cgcloud__Order_Template__c).Name == 'Ordine Diretto Pharma' && paymentCondition.ART_PaymentConditionName__c == payerAccMap.get(order.cgcloud__Payer__c).ART_PaymentCondition_Farma__c))
                    	{
                            paymentConditionClassCode = paymentCondition.ART_PaymentConditionClassCode__c;
                            break;
                        }
                    }
                    for (ART_PaymentConditions__mdt paymentCondition2 : paymentConditions)
        			{
                        if (paymentCondition2.ART_PaymentConditionClassCode__c == paymentConditionClassCode && paymentCondition2.ART_DelayDay__c == Integer.valueOf(order.ART_Delay_days__c))
                        {
                            paymentConditionCode = paymentCondition2.ART_PaymentConditionCode__c;
                            break;
                        }
                    }
                }
                else
                {
                    for (ART_PaymentConditions__mdt paymentCondition : paymentConditions)
        			{
                        if(
                          (templateMap.get(order.cgcloud__Order_Template__c).Name == 'Ordine Diretto OTC' && paymentCondition.ART_PaymentConditionName__c == payerAccMap.get(order.cgcloud__Payer__c).ART_PaymentCondition_OTC__c)
                        ||(templateMap.get(order.cgcloud__Order_Template__c).Name == 'Ordine Diretto Derma' && paymentCondition.ART_PaymentConditionName__c == payerAccMap.get(order.cgcloud__Payer__c).ART_PaymentCondition_DERMA__c)
                        ||(templateMap.get(order.cgcloud__Order_Template__c).Name == 'Ordine Diretto Pharma' && paymentCondition.ART_PaymentConditionName__c == payerAccMap.get(order.cgcloud__Payer__c).ART_PaymentCondition_Farma__c))
                        {
                            paymentConditionCode = paymentCondition.ART_PaymentConditionCode__c;
                            break;
                        }
                    }
                }

                if(!String.isBlank(paymentConditionCode))
                {
                    order.ART_Payment_Code__c = paymentConditionCode;
                }
                else
                {
                    order.cgcloud__Phase__c = 'Rejected';
                }
            }
        }*/
    }
    
    public static void dilazionePagamentoBeforeUpdate(List<cgcloud__Order__c> orders, Map<Id, cgcloud__Order__c> ordersOldMap)
    {
        Set<Id> payerIds = new Set<Id>();
        Set<Id> templateIds = new Set<Id>();
        for(cgcloud__Order__c order : orders)
        {
            payerIds.add(order.cgcloud__Payer__c);
            payerIds.add(order.cgcloud__Order_Account__c); // MS
            templateIds.add(order.cgcloud__Order_Template__c);
        }
        
        Map<Id, Account> payerAccMap = new Map<Id, Account>();
        for(Account acc : 
       [SELECT
        Id,
		ART_PaymentCondition_OTC__c,
		ART_PaymentCondition_DERMA__c,
		ART_PaymentCondition_Farma__c,
        ART_Rural__c // MS
        FROM Account WHERE Id in : payerIds]
        ){
            payerAccMap.put(acc.Id, acc);
        }
		
       Map<Id, cgcloud__Order_Template__c> templateMap = new Map<Id, cgcloud__Order_Template__c>();
       for(cgcloud__Order_Template__c template : 
       [SELECT
        Id,
		Name
        FROM cgcloud__Order_Template__c WHERE Id in : templateIds]
        ){
            templateMap.put(template.Id, template);
        }

        List<ART_PaymentConditions__mdt> paymentConditions = [ 
             SELECT ART_PaymentConditionClassCode__c, ART_PaymentConditionName__c, ART_DelayDay__c, ART_PaymentConditionCode__c
             FROM ART_PaymentConditions__mdt];

        // MS
        // lista di Items per ogni Order
        map<String, list<cgcloud__Order_Item__c>> mapOrderListLineItems = new map<String, list<cgcloud__Order_Item__c>>();
        for(cgcloud__Order_Item__c item:[
            SELECT id, cgcloud__Order__c, cgcloud__Product__r.THR_Plant__c, cgcloud__Quantity__c, cgcloud__Product__r.THR_MaterialGroup__c
            	, cgcloud__Product__r.THR_ExternalMaterialGroup__c
             FROM cgcloud__Order_Item__c
             WHERE cgcloud__Order__c IN :orders
             ORDER BY cgcloud__Order__c, id]){
            
                 if(!mapOrderListLineItems.containsKey(item.cgcloud__Order__c)){
                     mapOrderListLineItems.put(item.cgcloud__Order__c, new list<cgcloud__Order_Item__c>());
                 }
                 mapOrderListLineItems.get(item.cgcloud__Order__c).add(item);
        }
        
        List<Task> rejectedTasks = new List<Task>();// MS
        String userNot = SV_Utilities.givesRecTypeByDevName(new Task(), 'User_Notification');// MS
        
        // MS
        Set<Id> orderIds = new Set<Id>();
        for(cgcloud__Order__c order : orders){
            orderIds.add(order.Id);
        }
        List<cgcloud__Order__c> queriedOrders = [SELECT Id, cgcloud__Payer__r.THR_CustomerSubcategory__c, cgcloud__Order_Template__c, cgcloud__Payer__r.ART_Rural__c, ART_Delay_days__c, cgcloud__Phase__c FROM cgcloud__Order__c WHERE Id in :orderIds];

        for(cgcloud__Order__c order : queriedOrders)
        {
        	/* AA 2023 07 11 Commentata logica non più utilizzata per evitare bug DE-065.1. La logica sotto, serviva per gestire la corretta valorizzazione del campo Payment code per gli ordini provenienti da app
            if(order.cgcloud__Phase__c == 'Released' && 
               order.cgcloud__Mobility_Release__c == True && 
               order.cgcloud__Order_Template__r.Name != 'Transfer Order' && 
          	   order.cgcloud__Phase__c != ordersOldMap.get(order.Id).cgcloud__Phase__c)
        	{
                //System.debug('payer: ' + order.cgcloud__Payer__c);
                String paymentConditionCode;

           		if(!String.isBlank(order.ART_Delay_days__c))
                {
                    String paymentConditionClassCode;
                    for (ART_PaymentConditions__mdt paymentCondition : paymentConditions)
        			{
                        if(
                          (templateMap.get(order.cgcloud__Order_Template__c).Name == 'Ordine Diretto Pharma' && paymentCondition.ART_PaymentConditionName__c == payerAccMap.get(order.cgcloud__Payer__c).ART_PaymentCondition_Farma__c)
                        ||(templateMap.get(order.cgcloud__Order_Template__c).Name == 'Ordine Diretto OTC' && paymentCondition.ART_PaymentConditionName__c == payerAccMap.get(order.cgcloud__Payer__c).ART_PaymentCondition_OTC__c))
                    	{
                            paymentConditionClassCode = paymentCondition.ART_PaymentConditionClassCode__c;
                            break;
                        }
                    	else if
                        (templateMap.get(order.cgcloud__Order_Template__c).Name == 'Ordine Diretto Derma' && paymentCondition.ART_PaymentConditionName__c == payerAccMap.get(order.cgcloud__Payer__c).ART_PaymentCondition_DERMA__c)
                    	{
                            paymentConditionClassCode = paymentCondition.ART_PaymentConditionClassCode__c;
                            break;
                        }
                    }
                    for (ART_PaymentConditions__mdt paymentCondition2 : paymentConditions)
        			{
                        if (paymentCondition2.ART_PaymentConditionClassCode__c == paymentConditionClassCode && paymentCondition2.ART_DelayDay__c == Integer.valueOf(order.ART_Delay_days__c))
                        {
                            paymentConditionCode = paymentCondition2.ART_PaymentConditionCode__c;
                            break;
                        }
                    }
                }
                else
                {
                    for (ART_PaymentConditions__mdt paymentCondition : paymentConditions)
        			{
                        if(
                          (templateMap.get(order.cgcloud__Order_Template__c).Name == 'Ordine Diretto OTC' && paymentCondition.ART_PaymentConditionName__c == payerAccMap.get(order.cgcloud__Payer__c).ART_PaymentCondition_OTC__c)
                        ||(templateMap.get(order.cgcloud__Order_Template__c).Name == 'Ordine Diretto Derma' && paymentCondition.ART_PaymentConditionName__c == payerAccMap.get(order.cgcloud__Payer__c).ART_PaymentCondition_DERMA__c)
                        ||(templateMap.get(order.cgcloud__Order_Template__c).Name == 'Ordine Diretto Pharma' && paymentCondition.ART_PaymentConditionName__c == payerAccMap.get(order.cgcloud__Payer__c).ART_PaymentCondition_Farma__c))
                        {
                            paymentConditionCode = paymentCondition.ART_PaymentConditionCode__c;
                            break;
                        }
                    }
                }

                if(!String.isBlank(paymentConditionCode))
                {
                    order.ART_Payment_Code__c = paymentConditionCode;
                }
                else
                {
                    order.cgcloud__Phase__c = 'Rejected';
                }
            }*/
            // MS - Inizio validazione dilazione pagamento
            if(!String.isBlank(order.ART_Delay_days__c) && order.cgcloud__Phase__c != 'Ready' && order.cgcloud__Phase__c != 'Submitted')
            {
                Integer delayDays = Integer.valueOf(order.ART_Delay_days__c);
                if(
                    (templateMap.get(order.cgcloud__Order_Template__c).Name == 'Ordine Diretto Pharma')
                  ||(templateMap.get(order.cgcloud__Order_Template__c).Name == 'Ordine Diretto OTC'))
                {
                    Boolean rejected = false;

                    rejected = checkSendForApproval(order, mapOrderListLineItems);
                    /*if (templateMap.get(order.cgcloud__Order_Template__c).Name == 'Ordine Diretto Pharma')
                    {  
                        Set<String> aziende = new Set<String>();
                        Integer numeroAziende = 0;
                        Integer totaleQuantity = 0;
                        
                        if(mapOrderListLineItems.containsKey(order.Id)){
                            for (cgcloud__Order_Item__c orderItem : mapOrderListLineItems.get(order.Id))
                            {
                                aziende.add(orderItem.cgcloud__Product__r.THR_Plant__c);
                                totaleQuantity += (Integer)orderItem.cgcloud__Quantity__c;
                            }
                            numeroAziende = aziende.size();
                        }
                        System.debug('DK DelayDays_payerAccMap.get(order.cgcloud__Payer__c).ART_Rural__c:' + payerAccMap.get(order.cgcloud__Payer__c).ART_Rural__c);
                        System.debug('DK DelayDays_numeroAziende:' + numeroAziende);
                        System.debug('DK DelayDays_totaleQuantity:' + totaleQuantity);
                        System.debug('DK DelayDays_delayDays:' + delayDays);
                        if (!payerAccMap.get(order.cgcloud__Payer__c).ART_Rural__c)
                        {	
                            if (numeroAziende >= 1){
                                if(totaleQuantity >= 120 && delayDays > 90){
                                	rejected = true;
                            	}
                                if(totaleQuantity < 120 && delayDays > 30){
                                	rejected = true;
                            	}                                
                            }else{
                                if(totaleQuantity >= 120 && delayDays > 60){
                                	rejected = true;
                            	}
                                if(totaleQuantity < 120 && delayDays > 30){
                                	rejected = true;
                            	}                                 
                            }
                        }
                        else
                        {
                            if (numeroAziende >= 1){
                                if(totaleQuantity >= 70 && delayDays > 90){
                                	rejected = true;
                            	}
                                if(totaleQuantity < 70 && totaleQuantity >= 50 && delayDays > 60){
                                	rejected = true;
                            	}
                                if(totaleQuantity < 50 && delayDays > 30){
                                	rejected = true;
                            	}                                
                            }else{
                                if(totaleQuantity >= 50 && delayDays > 60){
                                	rejected = true;
                            	}
                                if(totaleQuantity < 50 && delayDays > 30){
                                	rejected = true;
                            	}                                  
                            }
                         }
                    }
                    else if (templateMap.get(order.cgcloud__Order_Template__c).Name == 'Ordine Diretto OTC')
                    {
                        Integer kaleidonQuantity = 0;
                        Integer novalacQuantity = 0;
						
                        if(mapOrderListLineItems.containsKey(order.Id)){
                            for (cgcloud__Order_Item__c orderItem : mapOrderListLineItems.get(order.Id))
                            {
                                if (orderItem.cgcloud__Product__r.THR_ExternalMaterialGroup__c == '1320')
                                {
                                    kaleidonQuantity += (Integer)orderItem.cgcloud__Quantity__c;
                                }
                                else if (orderItem.cgcloud__Product__r.THR_ExternalMaterialGroup__c == '1310')
                                {
                                    novalacQuantity += (Integer)orderItem.cgcloud__Quantity__c;
                                }
                            }
                        }

                        //AD ticket S240304_000163 kaleidonQuantity da 5 a 6
                        System.debug('AD kaleidonQuantity:' + kaleidonQuantity);
                        System.debug('AD delayDays:' + delayDays);
                        System.debug('AD novalacQuantity:' + novalacQuantity);

                        if (kaleidonQuantity >= 6  && delayDays > 120)
                        {
                            rejected = true;
                        }
                        else if (novalacQuantity >= 12  && delayDays > 120)
                        {
                            rejected = true;
                        }
                        else if (delayDays > 90 && kaleidonQuantity < 6 && novalacQuantity < 12)
                        {
                            rejected = true;
                        }
                    }*/
                    System.debug('DK rejected:' + rejected);

                    order.ART_Dilazione_da_approvare__c = rejected;
                    /* AA 2023 07 11 Commentata logica non più utilizzata per evitare bug DE-065.1. La logica sotto, serviva per gestire la corretta valorizzazione del campo Payment code per gli ordini provenienti da app
                    if(rejected)
                    {
                        if(ART_FollowUpWork.isItFromDesktop())
                        {
                            //DK START DE-072
                            // order.addError(label.ART_ErroreDilazione);
                            //DK END DE-072
                        }
                        else 
                        {
                            order.cgcloud__Phase__c = 'Rejected';
                            Task rejectedTask = new Task
                            (
                                RecordTypeId = userNot,
                                Subject = 'Ordine ' + order.Name + ' Rifiutato',
                                OwnerId = UserInfo.getUserId(),
                                Description = 'L\'ordine ' + order.Name + ' è stato rifiutato per dilazione pagamento non valida.',
                                ActivityDate = System.today(),
                                Status = 'Open',
                                Priority = 'High'
                            );
                            rejectedTasks.add(rejectedTask);
                        }
                    }
                    */
                }
            }
            // MS - Fine validazione pagamento
        }

        if(!rejectedTasks.isEmpty()) // MS
        {
            Insert(rejectedTasks);
        }
    }

    public static Boolean checkSendForApproval(cgcloud__Order__c order, map<String, list<cgcloud__Order_Item__c>> mapOrderListLineItems){
        Integer delayDays = Integer.valueOf(order.ART_Delay_days__c);
        
        //ciclare orderItem per recuperare le quantity necessarie

        // fare query per recuperare i record di subcategorycheck
        // se esiste almenno un elemento ciclare i figli e fare i controlli sui valori
        // all'interno del ciclo sui figli ciclare orderItem per recuperare le quantity necessarie
        // se ART_Material_Group_Filter__c o ART_Material_Group_Filter2__c sono valorizzati va effettuato un filtro sulla product family

        //Map<String, Integer> quantities = new Map<String, Integer>();
        System.debug('MS Order: ' + JSON.Serialize(order));

        ART_SubcategoryTemplate__c template;
        try{
            template = [SELECT Id, Name, ART_SubcategoryTemplate__c, ART_Subcategory__c, (SELECT Id, Name, ART_SubcategoryTemplate__c, ART_CheckRural__c, ART_isRural__c, ART_Quantita_Min__c, ART_Quantita_max__c, ART_Material_Group_Filter__c, ART_Quantita_min2__c, ART_Quantita_max2__c, ART_Material_Group_Filter2__c, ART_Delay_Days_min__c, ART_Delay_Days_max__c FROM Subcategory_Template_Checks__r) FROM ART_SubcategoryTemplate__c WHERE ART_SubcategoryTemplate__c = :order.cgcloud__Order_Template__c AND ART_Subcategory__c INCLUDES(:order.cgcloud__Payer__r.THR_CustomerSubcategory__c)];
        }
        catch(Exception e){
            System.debug('MS ERROR: No template');
            return false;
        }

        for(ART_SubcategoryTemplateCheck__c templateCheck: template.Subcategory_Template_Checks__r){
            
            // se checkrural=true e checkrural!=isrural, salta il templatecheck
            if(templateCheck.ART_CheckRural__c && templateCheck.ART_isRural__c != order.cgcloud__Payer__r.ART_Rural__c){
                continue;
            }

            Boolean rejected = null;

            if(String.isEmpty(templateCheck.ART_Delay_Days_min__c) && String.isEmpty(templateCheck.ART_Delay_Days_max__c) && templateCheck.ART_Quantita_max__c==null && templateCheck.ART_Quantita_min__c==null && String.isEmpty(templateCheck.ART_Material_Group_Filter2__c)){
                continue;
            }

            // controllo su delay days
            if ((String.isNotEmpty(templateCheck.ART_Delay_Days_min__c) && delayDays < Integer.valueOf(templateCheck.ART_Delay_Days_min__c)) || 
                (String.isNotEmpty(templateCheck.ART_Delay_Days_max__c) && delayDays > Integer.valueOf(templateCheck.ART_Delay_Days_max__c))){
                continue;
            }
            
            // controllo su filter quantity 1
            Integer quantity = 0;
            for (cgcloud__Order_Item__c orderItem : mapOrderListLineItems.get(order.Id)){
                if(String.isEmpty(templateCheck.ART_Material_Group_Filter__c) || orderItem.cgcloud__Product__r.THR_ExternalMaterialGroup__c == templateCheck.ART_Material_Group_Filter__c){
                    quantity += Integer.valueOf(orderItem.cgcloud__Quantity__c);
                }
            }
            if ((templateCheck.ART_Quantita_min__c!=null && quantity < templateCheck.ART_Quantita_min__c) ||
                (templateCheck.ART_Quantita_max__c!=null && quantity > templateCheck.ART_Quantita_max__c)){
                continue;
            }
            // controllo su filter quantity 2
            if(String.isNotEmpty(templateCheck.ART_Material_Group_Filter2__c)){
                Integer quantity2 = 0;
                for (cgcloud__Order_Item__c orderItem : mapOrderListLineItems.get(order.Id)){
                    if(orderItem.cgcloud__Product__r.THR_ExternalMaterialGroup__c == templateCheck.ART_Material_Group_Filter2__c){
                        quantity2 += Integer.valueOf(orderItem.cgcloud__Quantity__c);
                    }
                }
                if ((templateCheck.ART_Quantita_min2__c!=null && quantity2 < Integer.valueOf(templateCheck.ART_Quantita_min2__c)) ||
                    (templateCheck.ART_Quantita_max2__c!=null && quantity2 > Integer.valueOf(templateCheck.ART_Quantita_max2__c))){
                    continue;
                }
            }
            return true;
        }
        /*if(mapOrderListLineItems.containsKey(order.Id)){
            for (cgcloud__Order_Item__c orderItem : mapOrderListLineItems.get(order.Id))
            {
                if (orderItem.cgcloud__Product__r.THR_ExternalMaterialGroup__c == '1320')
                {
                    kaleidonQuantity += (Integer)orderItem.cgcloud__Quantity__c;
                }
                else if (orderItem.cgcloud__Product__r.THR_ExternalMaterialGroup__c == '1310')
                {
                    novalacQuantity += (Integer)orderItem.cgcloud__Quantity__c;
                }
            }
        }*/
        // all'interno del ciclo sui figli ciclare orderItem per recuperare le quantity necessarie
        // se ART_Material_Group_Filter__c o ART_Material_Group_Filter2__c sono valorizzati va effettuato un filtro sulla product family
        // eseguire check sui valori per capire se va mandato in approvazione (return true) oppure no (return false)
        //se la query non da risultati o non ci sono figli return false
        return false;
    }
    
    public static void dilazionePagamentoAfterInsert(List<cgcloud__Order__c> orders)
    {
        /* AA 2023 07 11 Commentata logica non più utilizzata per evitare bug DE-065.1. La logica sotto, serviva per gestire la corretta valorizzazione del campo Payment code per gli ordini provenienti da app
        for(cgcloud__Order__c order : orders)
        {
        	if ((order.cgcloud__Phase__c == 'Released' &&
                 order.cgcloud__Mobility_Release__c == True &&
				 order.cgcloud__Order_Template__r.Name != 'Transfer Order' &&
				 !String.isBlank(order.ART_Payment_Code__c)) || (
                 order.cgcloud__Phase__c == 'Released' &&
                 order.cgcloud__Mobility_Release__c == True &&
				 order.cgcloud__Order_Template__r.Name == 'Transfer Order'))
        	{
            	submitForApproval(order);
        	}
        }*/
    }
    
    public static void dilazionePagamentoAfterUpdate(List<cgcloud__Order__c> orders, Map<Id, cgcloud__Order__c> ordersOldMap)
    {
        /* AA 2023 07 11 Commentata logica non più utilizzata per evitare bug DE-065.1. La logica sotto, serviva per gestire la corretta valorizzazione del campo Payment code per gli ordini provenienti da app
        orders = 
       [SELECT Id, ART_Payment_Code__c, cgcloud__Mobility_Release__c, cgcloud__Order_Template__r.Name, cgcloud__Phase__c, ART_Dilazione_da_approvare__c
        FROM cgcloud__Order__c
        WHERE Id in :orders];
        
        for(cgcloud__Order__c order : orders)
        {
			if ((order.cgcloud__Phase__c == 'Released' &&
				 order.cgcloud__Mobility_Release__c == True &&
				 order.cgcloud__Order_Template__r.Name != 'Transfer Order' &&
				 order.cgcloud__Phase__c != ordersOldMap.get(order.Id).cgcloud__Phase__c &&
				 !String.isBlank(order.ART_Payment_Code__c)) || (
                 order.cgcloud__Phase__c == 'Released' &&
				 order.cgcloud__Mobility_Release__c == True &&
				 order.cgcloud__Order_Template__r.Name == 'Transfer Order' &&
				 order.cgcloud__Phase__c != ordersOldMap.get(order.Id).cgcloud__Phase__c))
        	{
				submitForApproval(order);
        	}
        }*/
    }

    public static void submitForApproval(SObject record)
    {
        Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
		req1.setComments('Submitting request for approval.');
		req1.setObjectId(record.Id);
		req1.setSubmitterId(UserInfo.getUserId());
		Approval.ProcessResult result = Approval.process(req1);
		if (!result.isSuccess())
		{
			List<Database.Error> errors = result.getErrors();
			Database.Error error = errors[0];
			String errorMessage = error.getMessage();
			throw new AdvancedOrderException(errorMessage);
		}
    }
    public class AdvancedOrderException extends Exception {}
}