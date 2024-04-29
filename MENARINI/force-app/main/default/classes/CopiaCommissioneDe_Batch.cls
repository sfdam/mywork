/*
 * @Name		  : CopiaCommissioneDe_Batch 
 * @CreateDate    : 2023-02-20
 * @Description   : Classe Batch per inviare il PDF per mail generato con la pagina VS CopiaCommissioneDe.
 * 					La Batch e' resa dinamiche per i campo mail da utillizzare, sono storicizzato nell'mdt Utility__mdt dell'Orgsnization.
 * @ClassTest     : CopiaCommissioneDe_Batch_Test 
 */
global with sharing class CopiaCommissioneDe_Batch implements Database.Batchable<SObject>, Database.Stateful, Schedulable {
    
    private static List<String> queryFields = new List<String> {
        'Id', 'cgcloud__Phase__c', 'Invio_Copia_Commissione__c', 'cgcloud__Order_Date__c'
        , 'cgcloud__Order_Id__c', 'cgcloud__Mobility_Release__c'
        , 'cgcloud__Responsible__r.Profile.Name prof'
    };
        
    public Boolean TestMode = false;
    public static String CRON_EXP = '0 0 0 4 9 ? 2050';
    private static String query = 'SELECT ' + String.join(queryFields, ', ');
    private Map<String, Utility__mdt> mInfoByUtility = null;
    private Map<String, List<String>> mAlias  = new Map<String, List<String>>();
    private Map<Id, String> mOrderName = new Map<Id, String>();
    private static List<Messaging.SingleEmailMessage> allMails = new List<Messaging.SingleEmailMessage>();
    private List<String> addressTO = null;
    private List<String> addressCC = null;
    global Map<String, ART_SalesRepProfile__mdt> mapSalesProfiles = new Map<String, ART_SalesRepProfile__mdt>();
    global set<String> setSalesRepProfiles = new set<String>();
    private String bodyMailLabel = Label.Body_Mail_CopiaCommissioneDe;
    private static String subjectMail   = Label.Subject_Mail_CopiaCommissioneDe;     

    global void execute(SchedulableContext SC) {
        if(!this.TestMode){
            CopiaCommissioneDe_Batch copiaComBatch = new CopiaCommissioneDe_Batch();
            ID batchprocessid = Database.executeBatch(copiaComBatch, 1);
        }
    }
    
    global Iterable<sObject> start(Database.BatchableContext BC) {
        
        System.debug('Query iniziale ' + query);
        
        // estrae tutti i campi che contengono gli eventuali destinatari
        mInfoByUtility = ART_SOQLUtilityFunctions.givesUtlGrouppedDevName(new List<String> {
        				'CopiaCommissioneDeFROM', 'CopiaCommissioneDeInTO', 'CopiaCommissioneDeInCC', 'CopiaCommissioneALWAYSinCCAddresses' });
        addressTO = mInfoByUtility.get('CopiaCommissioneDeInTO').CampoMail__c.split(';');
        addressCC = mInfoByUtility.get('CopiaCommissioneDeInCC').CampoMail__c.split(';');
        
        // estrae tutti i profili salesRep
        mapSalesProfiles = ART_SOQLUtilityFunctions.givesAllSalesRepProfiles();
        for(ART_SalesRepProfile__mdt p:mapSalesProfiles.values()){
            setSalesRepProfiles.add(p.ART_ProfileName__c);
        }
        
        Integer i = 0;        
        mAlias.put('TO', new List<String>());
        mAlias.put('CC', new List<String>());
        String alias = '';
        for(String address : addressTO) {
            queryFields.add(address);
            alias = 'Alias' + i;
            mAlias.get('TO').add(alias);
            query += ', ' + address + ' ' + alias;
            i += 1;
        }
        for(String address : addressCC) {
            queryFields.add(address);
            alias = 'Alias' + i;
            mAlias.get('CC').add(alias);
            query += ', ' + address + ' ' + alias;
            i += 1;
        }
        //R.M S230918_000050 --> Aggiunta filtro in Stato Submitted e data Modifica Oggi,in quanto alcuni ordini vengono elaborati manualmente tra batch (ripescaggio 17)
        query += ' FROM cgcloud__Order__c WHERE cgcloud__Order_Account__r.THR_MAIL__c != \'\' AND Invio_Copia_Commissione__c = NULL AND (cgcloud__Phase__c = \'Ready\' OR (cgcloud__Phase__c = \'Submitted\'  AND LastModifiedDate = TODAY))';
        query += ' GROUP BY ';
        for(String campo:queryFields){
            query +=  campo.substringBefore(' ') + ', ';
        }
        query = query.substringBeforeLast(',');
        System.debug('Query ' + query);
		
        return new AggregateResultIterable(query); 
    }
    
    global void execute(Database.BatchableContext BC, List<AggregateResult> scope) {
        
        System.debug('Exsecute method -- datas ' + scope);
        /*
        Date tod             = Date.today();
        DateTime dt 		 = DateTime.newInstance(tod.year(), tod.month(), tod.day());
        String oggi 		 = '' + dt.format('dd/MM/yyyy');    
		*/
        String oggi 		 = '' + (Datetime.now()).format('dd/MM/yyyy'); 
        bodyMailLabel 	  	 = bodyMailLabel.replace('[cgcloud__Order__c.cgcloud__Order_Date__c]',  oggi);
        String idOrder	     = '';
        Blob content         = null;
        Set<Id> ids 		 = new Set<Id>();
        List<String> adderessCC_insert = new List<String>();
        List<String> addressValues 	   = null;
        
        // Recupero degli IDs
        for(AggregateResult order : scope) { 
            ids.add((id) order.get('Id'));
        }
        
        List<cgcloud__Order__c> toUpd = new List<cgcloud__Order__c>();
        
        // Recupero dei Nomi + update field
        for(cgcloud__Order__c order : Database.query('SELECT Id, Name, Invio_Copia_Commissione__c FROM cgcloud__Order__c WHERE Id IN :ids')) {
            mOrderName.put(order.Id, order.Name);
            order.Invio_Copia_Commissione__c = Date.today();
            toUpd.add(order);
        }
		System.debug('mOrderName ' + mOrderName);
        // Send Mails
        for(AggregateResult order : scope) {
            
            idOrder = (String) order.get('Id');         
            Pagereference pdf = new Pagereference('/apex/CopiaCommissioneDe?id=' + idOrder); // VF Page
            
            Messaging.EmailFileAttachment attachment = new Messaging.EmailFileAttachment();	 // Creazione allegato
            attachment.setContentType('application/pdf');
            attachment.setFileName( idOrder + '.pdf');
            content = ( Test.isRunningTest() ? Blob.valueOf('UNIT.TEST') : pdf.getContentAsPDF() );
            attachment.setBody(content);
            
            List<Messaging.EmailFileAttachment> rep = new List<Messaging.EmailFileAttachment> { attachment };
            Messaging.reserveSingleEmailCapacity(1);
            
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();	// Creazione Mail
            mail.setOrgWideEmailAddressId(mInfoByUtility.get('CopiaCommissioneDeFROM').CampoMail__c);
            mail.setSaveAsActivity(false);
            // Set TO Address
            try {
                addressValues = getValueFieldsFromMetadata(order, 'TO');
            } catch(IllegalArgumentException e) {
                System.debug(e.getMessage());
            }
            mail.setToAddresses( addressValues );
            // Set CC Address 
            /*
            if(order.get('cgcloud__Order_Id__c') != null) {
                // Questa si traduce in: se cgcloud__Order_Id__c != null allora in CC va cgcloud__Responsible__r.Email
            	try {
                    addressValues = getValueFieldsFromMetadata(order, 'CC');
                } catch(IllegalArgumentException e) {
                    System.debug(e.getMessage());
                }	
                adderessCC_insert.addAll( addressValues );
            }
            if( ( (Boolean) order.get('cgcloud__Mobility_Release__c') ) ) {
                // Qesta si traduce in: se cgcloud__Mobility_Release__c = True in cc va contactcenter@codifi.it
				adderessCC_insert.add(mInfoByUtility.get('CopiaCommissioneDeInCC').ValoreStringa__c);
            }
*/
            // se è un profilo Sale Reps in cc va cgcloud__Responsible__r.Email, altrimenti contactcenter@codifi.it
            if(setSalesRepProfiles.contains((String) order.get('prof'))) {
            	try {
                    addressValues = getValueFieldsFromMetadata(order, 'CC');
                } catch(IllegalArgumentException e) {
                    System.debug(e.getMessage());
                }	
                adderessCC_insert.addAll( addressValues );             
            } else {
                adderessCC_insert.addAll((mInfoByUtility.get('CopiaCommissioneDeInCC').ValoreStringa__c).split(';'));
            }
            adderessCC_insert.addAll((mInfoByUtility.get('CopiaCommissioneALWAYSinCCAddresses').ValoreStringa__c).split(';'));
            if(!adderessCC_insert.isEmpty()) {
            	mail.setCcAddresses( adderessCC_insert );  
            }
            
            mail.setBccSender(false);
            mail.setUseSignature(false);
            mail.setSubject(subjectMail);
            mail.setFileAttachments( rep ); // Add PDF file
            system.debug('mOrderName.get(idOrder): ' + mOrderName.get(idOrder));
            System.debug('bodyMailLabel ' + bodyMailLabel);
            String orderBodyMail = bodyMailLabel.replace('[cgcloud__Order__c.Name]', mOrderName.get(idOrder));  // Sostisuzione dei valori di campi in bodyMail
            system.debug('bodyMail: ' + orderBodyMail);
            mail.setHtmlBody(orderBodyMail); // Add Body Mail
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });  
        }
        // Messaging.sendEmail( allMails ); // Send a single mail
        update toUpd;		// DML
    }
    global void finish(Database.BatchableContext BC) {}
    
    // A partire da una key della mappa mAlias restituiosce i valore dei campi dell'oggetto ar di tipo String
    private List<String> getValueFieldsFromMetadata(AggregateResult ar, String classTomAlias) {
        
        List<String> values = new List<String>();        
        List<String> fields = new List<String>(); 
        List<String> apiFields = null;
        if(!mAlias.containsKey(classTomAlias)) {
            throw new IllegalArgumentException('Key not Found');
        } else {
            apiFields = mAlias.get(classTomAlias);
            /*
            for(String alias : apiFields) {
                fields.add( alias );
            }
            for(String a : fields) {
                values.add( (String) ar.get(a) );
            }
*/
            for(String alias : apiFields) {
                values.add( (String) ar.get(alias) );
            }           
            return values;
        }
    }
}