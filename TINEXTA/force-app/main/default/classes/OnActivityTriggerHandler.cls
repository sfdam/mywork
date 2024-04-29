public class OnActivityTriggerHandler {
    
    public static void validateDelete(List<sObject> actList){

        User currUser = [ SELECT Id, Profile.Name FROM User WHERE Id =: UserInfo.getUserId() ];
        System.debug('currUser.Profile.Name: '+currUser.Profile.Name);
		
        if (currUser.Profile.Name == 'Innolva - Partner Community Sales' || currUser.Profile.Name == 'Innolva - Sales Partner' || currUser.Profile.Name == 'Innolva - Sales Interno') {
			
        	for (Sobject act : actList){
				System.debug('act.get(CreatedById): '+ act.get('CreatedById'));
				System.debug('(UserInfo.getUserId(): '+ UserInfo.getUserId());
            	if(UserInfo.getUserId() != act.get('CreatedById')){
					act.addError(System.Label.OnActivityTriggerHandler_Error);
            	}        
    		}
   		}
   	}
	
	public static void alignOutcome(Boolean isInsert, Map<Id,sObject> actMap, Map<Id,sObject> oldactMap){

		system.debug('newactMap:'+actMap);
		system.debug('oldactMap:'+oldactMap);
		
        Boolean lead_update = false;
		Boolean account_update = false;
        Boolean contact_update = false;
		User currUser = [ SELECT Id, Societa__c,Profile.Name FROM User WHERE Id =: UserInfo.getUserId() ];
      	if(currUser.Societa__c == 'CoMark'){
			Map<Id,Id> AccountIds = new Map<Id,Id>();
			Map<Id,Id> WhoIds = new Map<Id,Id>();
			Set<Id> UserIdsSet = new Set<Id>();

			for(sObject act : actMap.values()){
				if(act.get('AccountId')!= null){
					AccountIds.put((Id)act.get('Id'),(Id)act.get('AccountId'));
				}
				if(act.get('WhoId')!=null) {
					WhoIds.put((Id)act.get('Id'),(Id)act.get('WhoId'));
					UserIdsSet.add((Id)act.get('OwnerId'));
				}

			}

			system.debug('AccountIds: '+AccountIds);
			system.debug('WhoIds: '+WhoIds);
			
            Map<String,sObject> accMap = Utilities.keyBy([SELECT Id,Name, Esito_Comark__c,Causale_Esito_Comark__c,Note_esito_comark__c, Data_ultimo_esito_comark__c FROM Account WHERE Id IN: AccountIds.values()],'Id');
			Map<String,sObject> leadMap = Utilities.keyBy([SELECT Id,Name, OwnerId, Esito_Comark__c,Causale_Esito_Comark__c,Note_esito_comark__c, IsUnreadByOwner,Data_ultimo_esito_comark__c FROM Lead WHERE Id IN : WhoIds.values()],'Id');
			Map<String,sObject> contMap = Utilities.keyBy([SELECT Id, Name, Ripristinato_lavorabile_CMK__c FROM Contact WHERE Id IN : WhoIds.values()],'Id');
            Map<String,sObject> usrMap = Utilities.keyBy([ SELECT Id, Societa__c, Agente_CoMark__c FROM User WHERE Id IN : UserIdsSet ],'Id');

			system.debug('accMap: '+accMap);
			system.debug('leadMap: '+leadMap);
            system.debug('contactMap:'+contMap);
            
			if(!AccountIds.isEmpty() && !accmap.isEmpty()){
                system.debug('dentro primo If');
				for(Id actId : AccountIds.keySet()){
					System.debug('(String)actMap.get(actId).get(Esito_Comark__c) : '+(String)actMap.get(actId).get('Esito_Comark__c'));
					if((isInsert && actMap.get(actId).get('Esito_Comark__c')!= null) ||
						 (!isInsert && (actMap.get(actId).get('Esito_Comark__c')!= oldactMap.get(actId).get('Esito_Comark__c')))){
						account_update = true;
						accMap.get((String)AccountIds.get(actId)).put('Esito_Comark__c',(String)actMap.get(actId).get('Esito_Comark__c'));
						accMap.get((String)AccountIds.get(actId)).put('Data_ultimo_esito_comark__c', Date.today());
					}
					System.debug('(String)actMap.get(actId).get(Causale_Esito_Comark__c) : '+(String)actMap.get(actId).get('Causale_Esito_Comark__c'));
					if(actMap.get(actId).get('Causale_Esito_Comark__c')!= null){
						accMap.get((String)AccountIds.get(actId)).put('Causale_Esito_Comark__c',(String)actMap.get(actId).get('Causale_Esito_Comark__c'));
						account_update = true;
					} 
					System.debug('(String)actMap.get(actId).get(Note_esito_comark__c) : '+(String)actMap.get(actId).get('Note_esito_comark__c'));
					if((isInsert) || (!isInsert && (actMap.get(actId).get('Note_esito_comark__c')!= oldactMap.get(actId).get('Note_esito_comark__c')))) {
						account_update = true;
						accMap.get((String)AccountIds.get(actId)).put('Note_esito_comark__c',(String)actMap.get(actId).get('Note_esito_comark__c'));
				}
			}
		}
			if(!WhoIds.isEmpty() && !leadMap.isEmpty()){
                system.debug('dentro secondo If');
				for(Id actId : WhoIds.keySet()){
					System.debug('(String)actMap.get(actId).get(Esito_Comark__c) : '+(String)actMap.get(actId).get('Esito_Comark__c'));
					if( (isInsert && actMap.get(actId).get('Esito_Comark__c')!= null) ||
						(!isInsert && (actMap.get(actId).get('Esito_Comark__c')!= oldactMap.get(actId).get('Esito_Comark__c')))){
						lead_update = true;
						leadMap.get(WhoIds.get(actId)).put('Esito_Comark__c',(String)actMap.get(actId).get('Esito_Comark__c'));
						leadMap.get(WhoIds.get(actId)).put('Data_ultimo_esito_comark__c',Date.today());
					}
					System.debug('(String)actMap.get(actId).get(Causale_Esito_Comark__c) : '+(String)actMap.get(actId).get('Causale_Esito_Comark__c'));
					if(actMap.get(actId).get('Causale_Esito_Comark__c')!= null){
						lead_update = true;
						leadMap.get(WhoIds.get(actId)).put('Causale_Esito_Comark__c',(String)actMap.get(actId).get('Causale_Esito_Comark__c'));
					}
					System.debug('(String)actMap.get(actId).get(Note_esito_comark__c) : '+(String)actMap.get(actId).get('Note_esito_comark__c'));
					if((isInsert) || (!isInsert && (actMap.get(actId).get('Note_esito_comark__c')!= oldactMap.get(actId).get('Note_esito_comark__c')))) {
						lead_update = true;
						leadMap.get(WhoIds.get(actId)).put('Note_esito_comark__c',(string)actMap.get(actId).get('Note_esito_comark__c'));
					}

					if(leadMap.get(WhoIds.get(actId)).get('IsUnreadByOwner')==true){
						lead_update = true;
						leadMap.get(WhoIds.get(actId)).put('IsUnreadByOwner',false);
					}

					if(actMap.get(actId).get('OwnerId') != leadMap.get(WhoIds.get(actId)).get('OwnerId') 
						&& isInsert && (Boolean)usrMap.get((Id)actMap.get(actId).get('OwnerId')).get('Agente_CoMark__c') 
						&& (currUser.Profile.Name == 'CoMark - Operatore Contact Center' 
							||currUser.Profile.Name == 'CoMark - Responsabile Contact Center')){
								lead_update = true;
								leadMap.get(WhoIds.get(actId)).put('OwnerId',actMap.get(actId).get('OwnerId'));
					}
				}
			}
            if(!WhoIds.isEmpty() && !contMap.isEmpty()){
                system.debug('dentro terzo If');
                for(Id actId : WhoIds.keySet()){					
					if((isInsert && actMap.get(actId).get('Esito_Comark__c')!= null) ||
						(!isInsert && (actMap.get(actId).get('Esito_Comark__c')!=null && oldactMap.get(actId).get('Esito_Comark__c')==null))){
						contact_update = true;
						contMap.get(WhoIds.get(actId)).put('Ripristinato_lavorabile_CMK__c', false);						
					}                
            	}
            }
            if(!accmap.isEmpty() && account_update){
                system.debug('aggiorno account');
                update accmap.values();
            }
            if(!leadMap.isEmpty() && lead_update){
                system.debug('aggiorno lead');
                update leadMap.values();
            }
            if(!contMap.isEmpty() && contact_update){
                system.debug('aggiorno contatto');
                update contMap.values();
            }
		  }
	}

	public static void setEventLocation(List<Event> eventList){
		User currUser = [SELECT Id, Societa__c FROM User WHERE Id =: UserInfo.getUserId() ];
		List<Id> LeadIds = new List<Id>();
		List<Id> AccountIds = new List<Id>();
		Set<Id> ContactIds = new Set<Id>();
		Map<String,sObject> leadMap = new Map<String,sObject>();
		Map<String,sObject> accMap = new Map<String,sObject>();
		Map<String,SObject> cntMap = new Map<String,SObject>();
		List<Event> toUpdateEvt = new List<Event>();

		if(currUser.Societa__c == 'CoMark'){
			for(Event evt : eventList){
				if(evt.Location == null){
					if(evt.WhoId != null && ((String)evt.WhoId).substring(0,3) == '00Q'){
						LeadIds.add(evt.WhoId);
					}
					else if(evt.WhatId != null && ((String)evt.WhatId).substring(0,3) == '001'){
						AccountIds.add(evt.WhatId);
					} else if(evt.WhoId != null && evt.WhoId.getSObjectType().getDescribe().getName() == 'Contact'){
						ContactIds.add(evt.WhoId);
					}
					toUpdateEvt.add(evt);
				}
			}
			leadMap = Utilities.keyBy([SELECT Id, Name, via_sedeoperativa_comark__c,cap_sedeoperativa_comark__c, citta_sedeoperativa_comark__c, provincia_sedeoperativa_comark__c, nazione_sedeoperativa_comark__c
									   FROM Lead 
									   WHERE Id IN : LeadIds ],'Id');
			accMap = Utilities.keyBy([SELECT Id, Name, Via_Sede_Operativa_comark__c, CAP_Sede_Operativa_comark__c, Citta_Sede_Operativa_comark__c, Provincia_Sede_Operativa_comark__c, Paese_Sede_Operativa_comark__c
									  FROM Account 
									  WHERE Id IN : AccountIds ],'Id');
			cntMap = Utilities.keyBy([SELECT Id, Name, Account.Via_Sede_Operativa_comark__c, Account.CAP_Sede_Operativa_comark__c, Account.Citta_Sede_Operativa_comark__c, Account.Provincia_Sede_Operativa_comark__c, Account.Paese_Sede_Operativa_comark__c
										FROM Contact 
										WHERE Id IN : ContactIds ],'Id');

			for(Event evt : toUpdateEvt){
				if(evt.WhoId != null && ((String)evt.WhoId).substring(0,3) == '00Q'){
					sObject tempLead = leadMap.get(evt.WhoId);
					system.debug('tempLead: '+ tempLead);
					
					evt.Location =  ((tempLead.get('citta_sedeoperativa_comark__c') != null ? (String)tempLead.get('citta_sedeoperativa_comark__c') + ', ' : '') +
									(tempLead.get('provincia_sedeoperativa_comark__c') != null ? (String)tempLead.get('provincia_sedeoperativa_comark__c') + ', ' : '')+
									(tempLead.get('via_sedeoperativa_comark__c') != null ?  (String)tempLead.get('via_sedeoperativa_comark__c') + ', ' : '' ) +
									// (tempLead.get('nazione_sedeoperativa_comark__c')!= null ? (String)tempLead.get('nazione_sedeoperativa_comark__c') + ', ' : '') + 
									(tempLead.get('cap_sedeoperativa_comark__c') != null ? (String)tempLead.get('cap_sedeoperativa_comark__c') + ', ' : '')).removeEnd(', ');

					// evt.Location =  ((tempLead.get('via_sedeoperativa_comark__c') != null ?  (String)tempLead.get('via_sedeoperativa_comark__c')+ ', ' : '' )
					// 				+(tempLead.get('cap_sedeoperativa_comark__c') != null ? (String)tempLead.get('cap_sedeoperativa_comark__c') + ', ' : '')
					// 				+(tempLead.get('citta_sedeoperativa_comark__c') != null ? (String)tempLead.get('citta_sedeoperativa_comark__c') + ', ' : '')
					// 				+(tempLead.get('provincia_sedeoperativa_comark__c') != null ? (String)tempLead.get('provincia_sedeoperativa_comark__c')+ ', ' : '')
					// 				+(tempLead.get('nazione_sedeoperativa_comark__c')!= null ? (String)tempLead.get('nazione_sedeoperativa_comark__c') : '')).removeEnd(', ');
					
						
				}
				else if(evt.WhatId != null && ((String)evt.WhatId).substring(0,3) == '001'){
					sObject tempAcc = accMap.get(evt.WhatId);
					system.debug('tempAcc: '+ tempAcc);

					evt.Location =   (( tempAcc.get('Citta_Sede_Operativa_comark__c') != null ? (String)tempAcc.get('Citta_Sede_Operativa_comark__c') + ', ' : '') +
									(tempAcc.get('Provincia_Sede_Operativa_comark__c') != null ? (String)tempAcc.get('Provincia_Sede_Operativa_comark__c') + ', ' : '') +
									( tempAcc.get('Via_Sede_Operativa_comark__c') != null ?  (String)tempAcc.get('Via_Sede_Operativa_comark__c') + ', ' : '' ) +									
									// (tempAcc.get('Paese_Sede_Operativa_comark__c')!= null ? (String)tempAcc.get('Paese_Sede_Operativa_comark__c') + ', ' : '') + 
									(tempAcc.get('CAP_Sede_Operativa_comark__c') != null ? (String)tempAcc.get('CAP_Sede_Operativa_comark__c') + ', ' : '')).removeEnd(', ');

					// evt.Location =   (( tempAcc.get('Via_Sede_Operativa_comark__c') != null ?  (String)tempAcc.get('Via_Sede_Operativa_comark__c')+ ', ' : '' )
					// 				+ (tempAcc.get('CAP_Sede_Operativa_comark__c') != null ? (String)tempAcc.get('CAP_Sede_Operativa_comark__c') + ', ' : '')
					// 				+( tempAcc.get('Citta_Sede_Operativa_comark__c') != null ? (String)tempAcc.get('Citta_Sede_Operativa_comark__c') + ', ' : '')
					// 				+ (tempAcc.get('Provincia_Sede_Operativa_comark__c') != null ? (String)tempAcc.get('Provincia_Sede_Operativa_comark__c')+ ', ' : '')
					// 				+ (tempAcc.get('Paese_Sede_Operativa_comark__c')!= null ? (String)tempAcc.get('Paese_Sede_Operativa_comark__c') : '')).removeEnd(', ');
									
				} else if(evt.WhoId != null && evt.WhoId.getSObjectType().getDescribe().getName() == 'Contact'){
					// SObject tmpCnt = cntMap.get(evt.WhoId);
					Contact tmpCnt = (Contact)cntMap.get(evt.WhoId);
					System.debug('tmpCnt: ' + tmpCnt);

					evt.Location = ((tmpCnt.Account.Citta_Sede_Operativa_comark__c != null ? tmpCnt.Account.Citta_Sede_Operativa_comark__c + ', ' : '') +
									(tmpCnt.Account.Provincia_Sede_Operativa_comark__c != null ? tmpCnt.Account.Provincia_Sede_Operativa_comark__c + ', ' : '')+
									(tmpCnt.Account.Via_Sede_Operativa_comark__c != null ? tmpCnt.Account.Via_Sede_Operativa_comark__c + ', ' : '') +
									// (tmpCnt.Account.Paese_Sede_Operativa_comark__c != null ? tmpCnt.Account.Paese_Sede_Operativa_comark__c + ', ' : '') + 
									(tmpCnt.Account.CAP_Sede_Operativa_comark__c != null ? tmpCnt.Account.CAP_Sede_Operativa_comark__c + ', ' : '')).removeEnd(', ');
				}
			}
		}
	}

	public static void setEventSubject(List<Event> eventList){
		User currUser = [SELECT Id, Societa__c FROM User WHERE Id =: UserInfo.getUserId() ];
		List<Id> LeadIds = new List<Id>();
		List<Id> AccountIds = new List<Id>();
		Set<Id> ContactIds = new Set<Id>();
		Map<String,sObject> leadMap = new Map<String,sObject>();
		Map<String,sObject> accMap = new Map<String,sObject>();
		Map<String,SObject> cntMap = new Map<String,SObject>();
		List<Event> toUpdateEvt = new List<Event>();

		if(currUser.Societa__c == 'CoMark'){
			for(Event evt : eventList){
				if(evt.Subject == null){
					if(evt.WhoId != null && evt.WhoId.getSObjectType().getDescribe().getName() == 'Lead'){
						LeadIds.add(evt.WhoId);
					}
					else if(evt.WhatId != null && evt.WhatId.getSObjectType().getDescribe().getName() == 'Account' ){
						AccountIds.add(evt.WhatId);
					} else if(evt.WhoId != null && evt.WhoId.getSObjectType().getDescribe().getName() == 'Contact'){
						ContactIds.add(evt.WhoId);
					}
					toUpdateEvt.add(evt);
				}
			}
			leadMap = Utilities.keyBy([SELECT Id, Name, Company, Zona_CoMark__c, Zona_CoMark__r.Name
									   FROM Lead 
									   WHERE Id IN : LeadIds ],'Id');
			accMap = Utilities.keyBy([SELECT Id, Name, Zona_CoMark__c, Zona_CoMark__r.Name
									  FROM Account 
									  WHERE Id IN : AccountIds ],'Id');
			cntMap = Utilities.keyBy([SELECT Id, Name, Account.Name, Account.Zona_CoMark__c, Account.Zona_CoMark__r.Name
										FROM Contact 
										WHERE Id IN : ContactIds ],'Id');

			for(Event evt : toUpdateEvt){
				if(evt.WhoId != null && evt.WhoId.getSObjectType().getDescribe().getName() == 'Lead'){
					Lead tempLead = (Lead)leadMap.get(evt.WhoId);
					system.debug('tempLead: '+ tempLead);
					
					evt.Subject = tempLead.Name + ' | '+ tempLead.Company + (tempLead.Zona_CoMark__c != null ? ' | '+ tempLead.Zona_CoMark__r.Name : '');
						
				}
				else if(evt.WhatId != null && evt.WhatId.getSObjectType().getDescribe().getName() == 'Account'){
					Account tempAcc = (Account)accMap.get(evt.WhatId);
					system.debug('tempAcc: '+ tempAcc);

					evt.Subject = tempAcc.Name +  (tempAcc.Zona_CoMark__c != null ? ' | '+ tempAcc.Zona_CoMark__r.Name : '');
									
				} else if(evt.WhoId != null && evt.WhoId.getSObjectType().getDescribe().getName() == 'Contact'){
					Contact tmpCnt = (Contact)cntMap.get(evt.WhoId);
					System.debug('tmpCnt: ' + tmpCnt);

					evt.Subject = tmpCnt.Name + ' | ' + tmpCnt.Account.Name +  (tmpCnt.Account.Zona_CoMark__c != null ? ' | '+ tmpCnt.Account.Zona_CoMark__r.Name : '');
				}
			}

		}
	}

	public static void alignLookups(List<sObject> actList){
		Set<Id> ContactIds = new Set<Id>();
		Set<Id> OpportunityIds = new Set<Id>();

		for(sObject act : actList){
			system.debug('WhoID: '+(String)act.get('WhoId'));
			system.debug('whatId: '+(String)act.get('whatId'));
			act.put('Account__c','');
			act.put('Contact__c','');
			act.put('Lead__c','');
			if(act.get('WhoId')!= null && ((String)act.get('WhoId')).substring(0,3)== '003'){
				ContactIds.add((Id)act.get('WhoId'));
				act.put('Contact__c',act.get('WhoId'));
				
			}else if(act.get('WhoId')!= null && ((String)act.get('WhoId')).substring(0,3)== '00Q'){
				act.put('Lead__c',act.get('WhoId'));
			}

			if(act.get('WhatId')!= null && ((String)act.get('WhatId')).substring(0,3)== '001'){
				act.put('Account__c',act.get('WhatId'));
			}else if(act.get('WhatId')!= null && ((String)act.get('WhatId')).substring(0,3)== '006'){
				OpportunityIds.add((Id)act.get('WhatId'));
                act.put('Opportunity__c',act.get('WhatId'));
			}
		}
			Map<String,sObject> optMap = Utilities.keyBy([SELECT Id, Name, AccountId FROM Opportunity WHERE Id IN: OpportunityIds],'Id');
			System.debug('optMap: '+optMap);

			Map<String,sObject> contMap = Utilities.keyBy([SELECT Id, Name, AccountId FROM Contact WHERE Id IN: ContactIds],'Id');
			System.debug('contMap: '+contMap);
		for(sObject act : actList){
			if(act.get('WhoId')!= null && ((String)act.get('WhoId')).substring(0,3)== '003'){
				if(!contMap.isEmpty()){
					act.put('Account__c',(Id)contmap.get((Id)act.get('WhoId')).get('AccountId'));
				}
			}
			
			if(act.get('WhatId')!= null && ((String)act.get('WhatId')).substring(0,3)== '006'){
				if(!optMap.isEmpty()){
					act.put('Account__c',optMap.get((Id)act.get('WhatId')).get('AccountId'));
				}
			}
		}
	}
  /*  public static void automappedRelatedTo(List<sObject> actList){
        User currUser = [ SELECT Id, Profile.Name, Societa__c FROM User WHERE Id =: UserInfo.getUserId() ];
        System.debug('currUser.Profile.Name: '+currUser.Profile.Name);
        Set<Id> ContactIds = new Set<Id>();
        for(sObject act : actList){
            ContactIds.add((Id)act.get('WhoId'));
        }
		
       Map<String,sObject> contMap = Utilities.keyBy([SELECT Id, Name, AccountId FROM Contact WHERE Id IN: ContactIds],'Id');
			System.debug('contMap: '+contMap);

        if (currUser.Profile.Name == 'System Administrator' || currUser.Societa__c=='Warrant') {
        	for (Sobject act : actList){
                for(Sobject c:contMap.values()){
            	if((String)act.get('whatId') == null){
					act.put('WhatId',(Id)contmap.get((Id)act.get('WhoId')).get('AccountId'));
            	}        
    		}
          }
   		}
   	}*/

public static void UpdateLeadReferenza(List<sObject> actList){
        User currUser = [ SELECT Id, Profile.Name, Societa__c FROM User WHERE Id =: UserInfo.getUserId() ];
        System.debug('currUser Società: '+currUser.Societa__c);
    
      if(currUser.Societa__c != 'Warrant'){
            System.debug('SV LEAD NON PROCESSATI PERCHE NON SONO WARRANT');
            return;
        } else {
            System.debug('SV LEAD DI WARRANT');
        }


        Set<Id> LeadIds = new Set<Id>();
        for(sObject act : actList){
            LeadIds.add((Id)act.get('Lead__c'));
        }
		
       Map<Id,Lead> leadMap = new Map <Id, Lead>([SELECT Id, Name, Stato_Referenza__c,Referenza__c FROM Lead WHERE Id IN: LeadIds AND Referenza__c != null]);
			System.debug('LeadMap: '+leadMap);

        if (currUser.Societa__c=='Warrant') {
        	for (Sobject act : actList){
                for(Id c:leadMap.keyset()){
                    if((String)act.get('Lead__c') != null ){
                    If(leadMap.get(c).Stato_Referenza__c != 'OK' && leadMap.get(c).Stato_Referenza__c != 'KO'){
						leadMap.get(c).Stato_Referenza__c = 'In gestione';
                    }       
                       }
    		}
          }
   		}
    
        update leadMap.values();
    	system.debug('PROVA'+ leadMap.values());
   	}
    
    
    public static void UpdateAccountReferenza(List<sObject> actList){
        User currUser = [ SELECT Id, Profile.Name, Societa__c FROM User WHERE Id =: UserInfo.getUserId() ];
        System.debug('currUser Società: '+currUser.Societa__c);
		
         if(currUser.Societa__c != 'Warrant'){
            System.debug('SV LEAD NON PROCESSATI PERCHE NON SONO WARRANT');
            return;
        } else {
            System.debug('SV LEAD DI WARRANT');
        }
        
        Set<Id> AccountIds = new Set<Id>();
        for(sObject act : actList){
            AccountIds.add((Id)act.get('Account__c'));
        }
		
       /*Map<Id,Account> AccMap = new Map <Id, Account>([SELECT Id, Name, Stato_Referenza__c,Referenza__c FROM Account WHERE Id IN: AccountIds AND Referenza__c != null]);
			System.debug('AccMap: '+ AccMap);

        if (currUser.Societa__c=='Warrant') {
        	for (Sobject act : actList){
                for(Id c:AccMap.keyset()){
            	    if((String)act.get('Account__c') != null && (AccMap.get(c).Stato_Referenza__c != 'OK' || AccMap.get(c).Stato_Referenza__c!= 'KO')){
					AccMap.get(c).Stato_Referenza__c = 'In gestione';
            	}        
    		}
          }
   		}
    
        update AccMap.values(); */
   	}
    
   public static void InsertDataVisita (List<sObject> actList){

	User currUser = [ SELECT Id, Profile.Name, Societa__c FROM User WHERE Id =: UserInfo.getUserId() ];
    System.debug('currUser Società: '+currUser.Societa__c);
            

	Set<Id> LeadIds = new Set<Id>();
	Set<Id> AccountIds = new Set<Id>();
	Set<Id> ContactId = new Set<Id>();

	//Ottimizzazione            
      if(currUser.Societa__c != 'Warrant'){
            System.debug('SV LEAD NON PROCESSATI PERCHE NON SONO WARRANT');
            return;
        } else {
            System.debug('SV LEAD DI WARRANT');
        }
	

        for(sObject act : actList){
			If(act.get('WhoId')!= null && ((String)act.get('WhoId')).substring(0,3)== '00Q'){
            LeadIds.add((Id)act.get('WhoId'));
			}
			if(act.get('WhatId')!= null && ((String)act.get('WhatId')).substring(0,3)== '001'){
			AccountIds.add((Id) act.get('WhatId'));
			}
			/*if(act.get('WhoId')!= null && act.get('WhatId') == null && ((String)act.get('WhoId')).substring(0,3)== '003'){
				ContactId.add((Id) act.get('WhoId'));
			}*/
        }
            
		//Map<Id,Contact> ContactMap = new Map <Id, Contact>([SELECT Id, AccountId,Account.WRT_Data_ultima_visita__c, Account.WRT_Data_prima_visita__c FROM Contact WHERE Id IN: ContactId]);
		//System.debug('ContactMap: '+ ContactMap);
                    
            
            
		Map<Id,Lead> leadMap = new Map <Id, Lead>([SELECT Id, Name, WRT_Data_ultima_visita__c,WRT_Data_prima_visita__c FROM Lead WHERE Id IN: LeadIds]);
		System.debug('LeadMap: '+leadMap);

		Map<Id,Account> AccountMap = new Map <Id, Account>([SELECT Id, Name, WRT_Data_ultima_visita__c,WRT_Data_prima_visita__c FROM Account WHERE Id IN: AccountIds]);
		System.debug('AccountMap: '+AccountMap);


        

		if (currUser.Societa__c=='Warrant') {
        	for (Sobject act : actList){
                for(Id c:leadMap.keyset()){
					IF(act.get('WhoId') == leadMap.get(c).Id && (leadMap.get(c).WRT_Data_ultima_visita__c == null || leadMap.get(c).WRT_Data_ultima_visita__c< (Datetime)act.get('StartDateTime')) ){
					leadMap.get(c).WRT_Data_ultima_visita__c = (Datetime) act.get('StartDateTime');
					system.debug('Dentro Lead');
            		}
                    IF(act.get('WhoId') == leadMap.get(c).Id && (leadMap.get(c).WRT_Data_prima_visita__c == null || leadMap.get(c).WRT_Data_prima_visita__c > (Datetime)act.get('StartDateTime')) ){
					leadMap.get(c).WRT_Data_prima_visita__c = (Datetime) act.get('StartDateTime');
					system.debug('Dentro Lead');
            		}
				}        
          }
   		}

		if (currUser.Societa__c=='Warrant') {
        	for (Sobject act : actList){
                for(Id a:AccountMap.keyset()){
					If(act.get('WhatId') == AccountMap.get(a).Id && ( AccountMap.get(a).WRT_Data_ultima_visita__c == null ||AccountMap.get(a).WRT_Data_ultima_visita__c <(Datetime) act.get('StartDateTime'))){
					AccountMap.get(a).WRT_Data_ultima_visita__c = (Datetime) act.get('StartDateTime');
					system.debug('Dentro Account');
            		}
                    
                    If(act.get('WhatId') == AccountMap.get(a).Id && ( AccountMap.get(a).WRT_Data_prima_visita__c == null || AccountMap.get(a).WRT_Data_prima_visita__c >(Datetime)act.get('StartDateTime'))){
					AccountMap.get(a).WRT_Data_prima_visita__c = (Datetime) act.get('StartDateTime');
					system.debug('Dentro Account');
            		}
				
				}        
          }
  		}

		List<Account> Acc = new list <Account>(); 

		/*if (currUser.Societa__c=='Warrant') {
        	for (Sobject act : actList){
                for(Id m:ContactMap.keyset()){
					If(act.get('WhoId') == ContactMap.get(m).Id && (ContactMap.get(m).Account.WRT_Data_ultima_visita__c == null ||ContactMap.get(m).Account.WRT_Data_ultima_visita__c <(Datetime) act.get('StartDateTime'))){
						ContactMap.get(m).Account.WRT_Data_ultima_visita__c = (Datetime) act.get('StartDateTime');
                        Acc.add(ContactMap.get(m).Account);
					system.debug('Dentro Contatto');
            		}
                    
                    If(act.get('WhoId') == ContactMap.get(m).Id && (ContactMap.get(m).Account.WRT_Data_prima_visita__c == null || ContactMap.get(m).Account.WRT_Data_prima_visita__c>(Datetime) act.get('StartDateTime') )){
						ContactMap.get(m).Account.WRT_Data_prima_visita__c = (Datetime) act.get('StartDateTime');
                     	Acc.add(ContactMap.get(m).Account);
					system.debug('Dentro Contatto');
            		}
				
				}        
          }
   		}*/



if (currUser.Societa__c=='Warrant') {
		   if(leadMap.size()>0){
			update leadMap.values();
		   }

		   if(AccountMap.size()>0){
			update AccountMap.values();
		   }
           
           /* if(ContactMap.size()>0){
             update acc; 
            }*/
}


}

}