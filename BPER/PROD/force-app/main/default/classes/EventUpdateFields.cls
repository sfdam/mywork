public class EventUpdateFields {
    @InvocableMethod(label ='EventUpdateFields')
    
    public static void updateEvent (List<Event> inputEvents){
        
        String campagneConcat;
    	String opportunityConcat;
        String alertConcatAnticipi;
        String alertConcatPortafoglio;
        String alertConcatProdotti;
        String customerInterviewConcat;
        String altroAppointmentConcat;
        String risObbligatoriaConcat;
        String risOpzionaleConcat;
       
        
        System.debug('FFF - Eventi : '+inputEvents);
		List<Event> eventFlagTrue = new List<Event>();
        List<Id> Ids = new List<Id>();
        //Set<Id> Ids = new Set<Id>();
        Map<Id,Id> mapEvent_To_Appointment = new Map<Id,id>();
		List<Event> listtoupdate = new List<Event>();
		for(Event singleEvent : inputEvents ){
            
			//if(singleEvent.EventAppointmentFlag__c){

			System.debug('Aggiungo il seguente Event : '+singleEvent);
			//eventFlagTrue.add(singleEvent);
            if(!Test.isRunningTest()){
               ids.add(singleEvent.ServiceAppointmentId); 
                mapEvent_To_Appointment.put(singleEvent.id,singleEvent.ServiceAppointmentId);
                }
            else{
               ids.add(singleEvent.whatId); 
                system.debug(singleEvent.id);
                mapEvent_To_Appointment.put(singleEvent.id,singleEvent.whatId);
            }
			
			//mapEvent_To_Appointment.put(singleEvent.ServiceAppointmentId,singleEvent.id);
			
                system.debug('**** Ids : '+ids +'mappa:' +mapEvent_To_Appointment);
            system.debug('****Trigger.New : ' +singleEvent);
			//}
			
        }
		
        List <CampaignMember> ourCampaignList = [ select id, name,CRM_ServiceAppointment__c, Campaign.name
                                                 from CampaignMember where CRM_ServiceAppointment__c = : ids];
        system.debug('****ourCampaignList : '+ourCampaignList );
        
        List <Opportunity> ourOppoList = [ select id, CRM_ServiceAppointment__c, name, CRM_Oggetto__c 
                                          from Opportunity where CRM_ServiceAppointment__c =: ids];
        system.debug('****ourOppoList : '+ourOppoList );
        
        List <FinServ__Alert__c> ourAlertList = [ select id, Name, RecordType.DeveloperName, CRM_ServiceAppointment__c, CRM_Prodotto__r.name  
                                                 from FinServ__Alert__c where CRM_ServiceAppointment__c =: ids];
        system.debug('****ourAlertList '+ourAlertList );
        
        List <CRM_CustomerInterview__c> ourCustomerInterviewList = [ select id, name, CRM_ServiceAppointment__c 
                                                                    from CRM_CustomerInterview__c where CRM_ServiceAppointment__c =: ids ];
        system.debug('****ourCustomerInterviewList '+ourCustomerInterviewList );
       

        ServiceAppointment appointment = [select id, CRM_IncontroCongiuntoAreaManager__c, CRM_IncontroIniziativaBanca__c, CRM_IncontroIniziativaCliente__c, CRM_IncontroPrivateWealth__c, 
                                          CRM_IncontroSocietaProdotto__c,CRM_IncontroSpecialistaAssicurativo__c,
                                          CRM_IncontroSpecialistaEstero__c, CRM_Canale__c, CRM_Note__c
                                          from ServiceAppointment
                                           where id=:ids];
        system.debug('****appointment '+appointment ); 
        
        List<Definizione_Appuntamento__mdt> metadataIncontroApp = [select id, label, QualifiedApiName, API_Name__c 
                                                                   from Definizione_Appuntamento__mdt ]; 
        List<AssignedResource> resourcesList = [select Id, IsDeleted, AssignedResourceNumber, CreatedDate, CreatedById, LastModifiedDate, LastModifiedById, SystemModstamp, ServiceAppointmentId,
                                                ServiceResourceId, IsRequiredResource, Role, IsPrimaryResource, CRM_Data__c, CRM_Durata__c, CRM_LinkAccount__c, CRM_LinkSA__c, CRM_NDG__c,
                                                CRM_NomeAppuntamento__c, CRM_NomeCliente__c, CRM_NomeGestore__c, CRM_OraFine__c, CRM_OraInizio__c, CRM_RisorsaObbligatoria__c, CRM_Slot__c,
                                                CRM_UserEmail__c from AssignedResource where ServiceAppointmentId =: appointment.id];
        system.debug('****metadataIncontroApp '+metadataIncontroApp ); 
        
        
        
        Set <Id> eventset = new Set<Id>();
        eventset = mapEvent_To_Appointment.keySet();
		//for(Id singleid : ids) {
        for(Id singleidevt : eventset) {
        
        String singleid = mapEvent_To_Appointment.get(singleidevt);
        system.debug('****Id Evento '+ singleidevt); 
		Event ev = new Event(); 
        if(!ourCampaignList.isEmpty()) {
            for (CampaignMember currentCampaign : ourCampaignList ){
                if(currentCampaign.Campaign.name != null && currentCampaign.CRM_ServiceAppointment__c==singleid){
                    
                    if(campagneConcat==null ){
                        campagneConcat = currentCampaign.Campaign.name+'';
                    }else{
                    	campagneConcat += ', ' + currentCampaign.Campaign.name+'';
                    }
                    //ev.Id = mapEvent_To_Appointment.get(singleid);
                    
                    ev.Id = singleidevt;
                    system.debug('****Id Evento2 '+ ev.Id);
                    system.debug('****Id Evento '+ singleidevt); 
                	ev.SAppointment_Campaign__c = campagneConcat;
                }  
           
        }
          /*  if(campagneConcat.endsWith(',')){
                        campagneConcat.removeEnd(',');
						ev.Id = mapEvent_To_Appointment.get(singleid);
                		ev.SAppointment_Campaign__c = campagneConcat;
                
                    }*/
            
        }else{
            
        }
    integer i=0;
            
       if(!ourOppoList.isEmpty()) {
             System.debug(' ourOppoList is not empty: '+ourOppoList); 
            for (Opportunity currentOpportunity : ourOppoList ){
                if(currentOpportunity.CRM_Oggetto__c != null && currentOpportunity.CRM_ServiceAppointment__c==singleid){
                    if(opportunityConcat==null ){
                        opportunityConcat = currentOpportunity.CRM_Oggetto__c+'';
                    }else{
                    	opportunityConcat += ', ' + currentOpportunity.CRM_Oggetto__c+'';
                    }
                  //  ev.Id = mapEvent_To_Appointment.get(singleid);
                    ev.Id = singleidevt;
                	ev.SAppointtment_Opportunity__c = opportunityConcat;
                    
                    
                    System.debug('@@-@@riga 60 currentOpportunity: '+currentOpportunity);
                    System.debug('@@-@@riga 61 opportunityConcat: '+opportunityConcat);
                    i++;
                    System.debug('@@-@@riga 63 i: '+i);
                       }  
           
        }
           System.debug('@@-@@riga 75 opportunityConcat: '+opportunityConcat);
           /* if(opportunityConcat.endsWith(',')){
                        opportunityConcat.removeEnd(',');
						ev.Id = mapEvent_To_Appointment.get(singleid);
                		ev.SAppointtment_Opportunity__c = opportunityConcat;
                
                    }*/
            
        }else{           
        }
            
       if(!ourAlertList.isEmpty()){
                 System.debug('@@-@@riga 110 currentOpportunity: SONOA  RIGA 101 DOPO IF !ourAlertList.isEmpty()');
                 for (FinServ__Alert__c currentAlert : ourAlertList ){
                     System.debug('@@-@@riga currentAlert.CRM_Prodotto__r.name: '+currentAlert.CRM_Prodotto__r.name);
                     System.debug('@@-@@riga currentAlert.CRM_ServiceAppointment__c: '+currentAlert.CRM_ServiceAppointment__c);
                     System.debug('@@-@@riga currentAlert.RecordType.DeveloperName: '+currentAlert.RecordType.DeveloperName);
                     System.debug('@@-@@riga singleid: '+singleid);
                if(currentAlert.CRM_Prodotto__r.name != null && currentAlert.CRM_ServiceAppointment__c==singleid && currentAlert.RecordType.DeveloperName == 'Scadenziario_Anticipi'){
                    
                    if(alertConcatAnticipi==null ){
                        alertConcatAnticipi = currentAlert.CRM_Prodotto__r.name+'';
                    }else{
                    	alertConcatAnticipi += ', ' + currentAlert.CRM_Prodotto__r.name+'';
                    }
                   // ev.Id = mapEvent_To_Appointment.get(singleid);
                	 ev.Id = singleidevt;
                    ev.SApp_AlertAnticipi__c = alertConcatAnticipi;
                    
                    
                    System.debug('@@-@@riga 110 currentOpportunity: '+currentAlert);
                   
                }else if(currentAlert.CRM_Prodotto__r.name != null && currentAlert.CRM_ServiceAppointment__c==singleid && currentAlert.RecordType.DeveloperName == 'Scadenziario_Portafoglio'){
                    if(alertConcatPortafoglio==null ){
                        alertConcatPortafoglio = currentAlert.CRM_Prodotto__r.name+'';
                    }else{
                    	alertConcatPortafoglio += ', ' + currentAlert.CRM_Prodotto__r.name+'';
                    }
                  //  ev.Id = mapEvent_To_Appointment.get(singleid);
                	 ev.Id = singleidevt;
                    ev.SApp_AlertPortafoglio__c = alertConcatPortafoglio;
                    
                }else if(currentAlert.CRM_Prodotto__r.name != null && currentAlert.CRM_ServiceAppointment__c==singleid && currentAlert.RecordType.DeveloperName == 'Scadenziario_Prodotti'){
                    System.debug('@@-@@riga 127 currentOpportunity SONO IN IF SCADENZIARIO PRODOTTI: ');
                    if(alertConcatProdotti==null ){
                        alertConcatProdotti = currentAlert.CRM_Prodotto__r.name+'';
                    }else{
                    	alertConcatProdotti += ', ' + currentAlert.CRM_Prodotto__r.name+'';
                    }
                    
                   // ev.Id = mapEvent_To_Appointment.get(singleid);
                	 ev.Id = singleidevt;
                    ev.SApp_AlertProdotti__c = alertConcatProdotti;
                    
                }
                             
        }
                
            }else{            
        }
       if(!ourCustomerInterviewList.isEmpty()){
           for (CRM_CustomerInterview__c currentInterview : ourCustomerInterviewList ){
               if(currentInterview.name != null && currentInterview.CRM_ServiceAppointment__c==singleid){
                   if(customerInterviewConcat==null ){
                        customerInterviewConcat = currentInterview.name+'';
                    }else{
                    	customerInterviewConcat += ', ' + currentInterview.name+'';
                    }
                  //  ev.Id = mapEvent_To_Appointment.get(singleid);
                	 ev.Id = singleidevt;
                   ev.SAppointment_Interview__c = customerInterviewConcat; 
                       }  
           
        }
                
            }else{}
            if(appointment != null){
            for(Definizione_Appuntamento__mdt altro : metadataIncontroApp){
                
            system.debug('il campo è ' + altro.API_Name__c);
            system.debug('il campo vale ' + appointment.get(altro.API_Name__c));
                
            if(appointment.get(altro.API_Name__c) == true){
                system.debug('il campo ' + altro.API_Name__c+ ' è true');
                
                if(altroAppointmentConcat==null ){
                        altroAppointmentConcat = altro.Label+'';
                    }else{
                    	altroAppointmentConcat += ', ' + altro.Label+'';
                    }             
            }
            }
          //   ev.Id = mapEvent_To_Appointment.get(singleid);
             ev.SAppointment_Incontri__c = altroAppointmentConcat; 
            if(appointment.CRM_Canale__c != null){
                ev.SAppointment_Canale__c = appointment.CRM_Canale__c;
            }
            if(appointment.CRM_Note__c  != null){
                ev.CRM_Notes__c = appointment.CRM_Note__c ;
            }
        } 
       for(AssignedResource singleResource : resourcesList) {
             if(!resourcesList.isEmpty()){
                 
                  if(singleResource.CRM_RisorsaObbligatoria__c){                      
                       if(risObbligatoriaConcat==null ){
                        risObbligatoriaConcat = singleResource.CRM_NomeGestore__c+'';
                           ev.SAppointment_Organizzatore__c = singleResource.CRM_NomeGestore__c;
                    }else{
                    	risObbligatoriaConcat += ', ' + singleResource.CRM_NomeGestore__c+'';
                    }
               
                  }else{
                        if(risOpzionaleConcat==null ){
                        risOpzionaleConcat = singleResource.CRM_NomeGestore__c+'';
                    }else{
                    	risOpzionaleConcat += ', ' + singleResource.CRM_NomeGestore__c+'';
                    }
                      
                  }
                 
             }
          //  ev.Id = mapEvent_To_Appointment.get(singleid);
          
          		    ev.Id = singleidevt;
                    system.debug('****Id Evento '+ singleidevt); 
                	ev.SAppointment_RisObbligatoria__c = risObbligatoriaConcat;
           ev.SAppointment_RisOpzionale__c = risOpzionaleConcat;
           
          
            }
           system.debug('sto aggiungendo l evento alla lista: ' + ev.id);
      listtoupdate.add(ev);
	}
	
	if(!listtoupdate.isEmpty()){
	System.debug('Visualizzo la lista degli eventi da aggiornare : '+listtoupdate);
	update listtoupdate;

	}
	
    }
}