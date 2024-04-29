/**
 * @Author        : Alessandro Lumaca @TEN 
 * @CreateDate    : 2022-12-14
 * @Description   : Batchable per inviare una mail giornaliare con il PDF implementato nella pagina VS TransferOrderForWholesaler  
 * @ClassTest     : TransferOrdersViaMail_Batch_Test 
 * -------------------------------------------
 * @UpdateDate    : 2023-02-16 
 * @Description   : Aggiunta di Utility_mdt, calcolo mapNumberOrder, calcolo del bodyMail 
 */
global class TransferOrdersViaMail_Batch implements Database.Batchable<SObject>, Schedulable, Database.Stateful {
    // MS - Query globale per recuperare i metadati con le email
   	global List<Utility__mdt> uts = [SELECT Id, ValoreStringa__c, CampoMail__c, DeveloperName FROM Utility__mdt WHERE DeveloperName = 'TransferOrderInTO' OR DeveloperName = 'TransferOrderInCC'];
    global String query;
    private static final String subject = Label.Oggetto_Mail_Ordini.replace( '{!TODAY}', '' + Date.today().format());
	public static String CRON_EXP       = '0 0 0 4 9 ? 2100';
    
    /** Metodi di interface Database.Batchable<SObject> */
    global Iterable<sObject> start(Database.BatchableContext BC) { 

        Set<String> emailFields = new Set<String>();
        //emailFields.Add('cgcloud__Wholesaler__r.Email_2__c Email_2__c');
        
        // MS - Lista dei campi email
        for(Utility__mdt ut : uts)
        {
            if(!String.isEmpty(ut.CampoMail__c))
            {
                emailFields.addAll(ut.CampoMail__c.split(';'));
            }
        }

        // MS - Spostato il testo della query in start e aggiunti campi dinamici presi dai metadata
        query = 
            'SELECT cgcloud__Wholesaler__c'
        	+ ', cgcloud__Wholesaler__r.ART_Transfer_Order_Delivery_Mode__c ART_Transfer_Order_Delivery_Mode__c';
        
            for (String emailField : emailFields)
            {
                query += ', ' + emailField;
            }

            query += ', cgcloud__Wholesaler__r.Name WholeName'
        	+ ', ART_Order_send_block__c, cgcloud__Phase__c'
        	+ ', ART_Order_To_Be_Sent__c, ART_SENDING_MAIL_DATE__c '
        + ' FROM cgcloud__Order__c'
        + ' WHERE cgcloud__Wholesaler__c != null'
        	+ ' AND cgcloud__Wholesaler__r.ART_Transfer_Order_Delivery_Mode__c = \'Email\''
        	+ ' AND ART_Order_To_Be_Sent__c = true AND ART_Order_send_block__c = false'
        	+ ' AND cgcloud__Phase__c = \'Ready\''
        + ' GROUP BY cgcloud__Wholesaler__c, cgcloud__Wholesaler__r.ART_Transfer_Order_Delivery_Mode__c'
        	//+ ', cgcloud__Wholesaler__r.Email_2__c'
            + ', cgcloud__Wholesaler__r.Name'
        	+ ', ART_Order_To_Be_Sent__c, ART_Order_send_block__c, cgcloud__Phase__c, ART_SENDING_MAIL_DATE__c';
                
            for (String emailField : emailFields)
            {
                query += ', ' + emailField.split(' ')[0];
            }
        
        query +=  ' ORDER BY cgcloud__Wholesaler__c '
        ;
		System.debug(query);
            
        Iterable<sObject> result = new AggregateResultIterable(query); 
        AggregateResultIterator r = (AggregateResultIterator) result.Iterator();
        Integer numRecords = r.total();
		
        return result; 
    }
    
    global void execute(Database.BatchableContext BC, List<AggregateResult> scope) {
        List<OrgWideEmailAddress> owdEmail = [select Id from OrgWideEmailAddress WHERE Address = 'transferorder@codifi.it'];
        Set<id> ordersId = new Set<id>();
        for(AggregateResult order : scope) {
            ordersId.add( (Id) order.get('cgcloud__Wholesaler__c') );   
        }
        
        Map<Id, Integer> mapNumberOrder = new Map<Id, Integer>();
        List<cgcloud__order__c> toUpd = new List<cgcloud__order__c>();        
        for(cgcloud__order__c order : [
            SELECT Id, cgcloud__Wholesaler__c, ART_Order_To_Be_Sent__c, ART_SENDING_MAIL_DATE__c 
             FROM cgcloud__Order__c
             WHERE cgcloud__Wholesaler__c IN :ordersId
     		   AND cgcloud__Wholesaler__r.ART_Transfer_Order_Delivery_Mode__c = 'Email'
     		   AND cgcloud__Wholesaler__r.Email_2__c  != null
			   AND ART_Order_To_Be_Sent__c = true AND ART_Order_send_block__c = false
     		   AND cgcloud__Phase__c = 'Ready']
           ) {
            order.ART_Order_To_Be_Sent__c  = false;
            order.ART_SENDING_MAIL_DATE__c  = Date.today();
            toUpd.add(order);
            if(mapNumberOrder.containsKey(order.cgcloud__Wholesaler__c)) {
                mapNumberOrder.put(order.cgcloud__Wholesaler__c, mapNumberOrder.get(order.cgcloud__Wholesaler__c) + 1);
            } else {
                mapNumberOrder.put(order.cgcloud__Wholesaler__c, 1);
            }
        }
        // update toUpd;

        String wholesalerId = '';
        String correctSubject = '';
        String bodyMail = '';
        Blob content = null;
        
        for(AggregateResult order : scope) {
            
        // MS - aggiunti destinatari presi dinamicamente dai campi tramite metadata
        List<String> toTO = new List<String>();
        List<String> toCC = new List<String>();
        List<String> toTOFields = new List<String>();
        List<String> toCCFields = new List<String>();

        for(Utility__mdt ut : uts)
        {
            if (ut.DeveloperName == 'TransferOrderInTO')
            {
                if(!String.isEmpty(ut.ValoreStringa__c))
            	{
                	toTO = ut.ValoreStringa__c.split(';');
                }
                if(!String.isEmpty(ut.CampoMail__c))
            	{
                	toTOFields = ut.CampoMail__c.split(';');
                }
            }
            else if (ut.DeveloperName == 'TransferOrderInCC')
            {
                if(!String.isEmpty(ut.ValoreStringa__c))
            	{
                	toCC = ut.ValoreStringa__c.split(';');
                }
                if(!String.isEmpty(ut.CampoMail__c))
            	{
                	toCCFields = ut.CampoMail__c.split(';');
                }
            }
        }
            
            wholesalerId = (String)order.get('cgcloud__Wholesaler__c');
            Pagereference pdf = new Pagereference('/apex/TransferOrderForWholesaler?wholesalerId=' + wholesalerId); // VF Page
            Messaging.EmailFileAttachment attachment = new Messaging.EmailFileAttachment();
            attachment.setContentType('application/pdf');
            attachment.setFileName( wholesalerId + '.pdf');
            content = ( Test.isRunningTest() ? Blob.valueOf('UNIT.TEST') : pdf.getContentAsPDF() );
            attachment.setBody(content);
            
            List<Messaging.EmailFileAttachment> rep = new List<Messaging.EmailFileAttachment> { attachment };
                
            Messaging.reserveSingleEmailCapacity(1);            
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();

            if(!owdEmail.isEmpty()){
                mail.setOrgWideEmailAddressId(owdEmail[0].Id); 
            }

            //MS - Aggiunge le mail del TO prese dai campi dinamici solo se le email non sono vuote
            for (String field : toToFields)
            {
                List<String> fieldList = field.split(' ');
                String email = (String)order.get(fieldList[1]);
                if(!String.isEmpty(email))
                {
                    toTO.Add(email);
                }                          
            }

            //MS - Aggiunge le mail del CC prese dai campi dinamici solo se le email non sono vuote
            for (String field : toCCFields)
            {
                List<String> fieldList = field.split(' ');
                String email = (String)order.get(fieldList[1]);
                if(!String.isEmpty(email))
                {
                    toCC.Add(email);
                } 
            }
            
            if(!toTO.isEmpty()){
                mail.setToAddresses(toTo);
            }

            if(!toCC.isEmpty()){
                mail.setCcAddresses(toCC);
            }
            
            mail.setSaveAsActivity(false);
            // mail.setReplyTo('?');
            correctSubject = subject.replace('{!WHOLESALER}', (String) order.get('WholeName'));
            mail.setSubject(correctSubject);
            mail.setBccSender(false);
            mail.setUseSignature(false);
            mail.setFileAttachments( rep ); // Add PDF file
            bodyMail = Label.Body_Mail_Ordini;
            bodyMail  = bodyMail.replace('nOrdini', '' + mapNumberOrder.get(wholesalerId));
            mail.setHtmlBody(bodyMail); // Add Body Mail
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail }); // Send a single mail
            //ordersId.add( (Id)order.get('cgcloud__Wholesaler__c') );               
        }
        /*
        for(cgcloud__order__c order : [
            SELECT Id, ART_Order_To_Be_Sent__c, ART_SENDING_MAIL_DATE__c 
             FROM cgcloud__Order__c
             WHERE cgcloud__Wholesaler__c IN :ordersId
     		   AND cgcloud__Wholesaler__r.ART_Transfer_Order_Delivery_Mode__c = 'Email'
     		   AND cgcloud__Wholesaler__r.THR_MAIL__c  != null
			   AND ART_Order_To_Be_Sent__c = true AND ART_Order_send_block__c = false
     		   AND cgcloud__Phase__c = 'Ready']
           ) {
                   
            order.ART_Order_To_Be_Sent__c  = false;
            order.ART_SENDING_MAIL_DATE__c  = Date.today();
            toUpd.add(order);
        }
		*/
		 
        update toUpd;
    }
    
    global void finish(Database.BatchableContext BC) {}
    global void execute(System.SchedulableContext sc) {
        TransferOrdersViaMail_Batch batchTO = new TransferOrdersViaMail_Batch();
        Database.executeBatch(batchTO,10);
    }
}