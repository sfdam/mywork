public class OnSegnalazioniPartnerTriggerHandler {
    
public static void aggiornanumerosegnalazione(List<Segnalazioni__c> segnalazione){
     Set<String> Segn = new Set<String>();
     Set<String> Lead = new Set<String>();
     //List <Lead> LeadUpdate = new List<Lead>();
     List <Lead> Leadadd = new List<Lead>();
                       
    for (Segnalazioni__c s : segnalazione){
            Segn.add(s.id);  
            Lead.add(s.Lead_Di_Riferimento__c);
         }
         
    Map <Id,Lead> LeadUpdate = new Map <Id,Lead>([SELECT Id,Numero_S__c FROM Lead WHERE Id IN:Lead]);
         
     for (Segnalazioni__c s:segnalazione){
             for(Id l:LeadUpdate.keyset()){
                 if(LeadUpdate.get(l).Numero_S__c == null){
                     LeadUpdate.get(l).Numero_S__c = s.id;
                    }
             }
         
        update LeadUpdate.values();
         }
         
     }
   
  /*  public static void changestatusaccountcreate(List<Segnalazioni__c> segnalazione){
    
      Set<String> Segn = new Set<String>();
      Set<String> Accountconver = new Set<String>();
      List <Account> AccountUpdate = new List<Account>();
      List <Segnalazioni__c> SegnAccUpdate = new List<Segnalazioni__c>();
      Map <String, Segnalazioni__c> mtpsegnaccup = new Map<String, Segnalazioni__c>();
        
       for (Segnalazioni__c s : segnalazione){  
           if(s.Stato_Segnalazione_Warrant__c == 'Positivo' && s.Account__c!=null){
            Segn.add(s.id);  
           Accountconver.add(s.Account__c);
           }
         }
        
        system.debug('Segnalazioni' + Segn);
        system.debug('Lead di riferimento' + Accountconver);
        
       //AccountUpdate = [SELECT Id,AccountSegnalatore__c FROM Account WHERE Id IN:Accountconver];
        
       map <Id,Segnalazioni__c> SegnAcc = new map <Id, Segnalazioni__c>([SELECT Id, Account__c FROM Segnalazioni__c WHERE Account__c IN:Accountconver]);
        system.debug('Segnacc' + SegnAcc.size());
    
      for(Segnalazioni__c s : segnalazione){
         Boolean find = false;
         for(id sl : SegnAcc.keyset()){
           if(SegnAcc.get(sl).id != s.Id && SegnAcc.get(sl).Account__c == s.Account__c){
                //system.debug('EU dentro');
                find = true;   
               }
            }
            if(find){
                //system.debug('find true');
               mtpsegnaccup.put(s.Id, s);        
            }    
        }
        
        system.debug('segnupdate' + mtpsegnaccup.size() );
        
        for (Id key:mtpsegnaccup.keyset()){
			mtpsegnaccup.get(key).Stato_Segnalazione_Warrant__c = 'Negativo';
            mtpsegnaccup.get(key).Note_KO__c='Sostituito da altra fonte';
        }
        
		update mtpsegnaccup.values(); 

    }
        
    
    public static void changestatuslead(List<Segnalazioni__c> segnalazione){
    
      Set<String> Segn = new Set<String>();
      Set<String> Lead = new Set<String>();
      List <Segnalazioni__c> LeadUpdate = new List<Segnalazioni__c>();
      Map <String, Segnalazioni__c> mtpsegnleadup = new Map<String, Segnalazioni__c>();
        
       for (Segnalazioni__c s : segnalazione){  
           if(s.Stato_Segnalazione_Warrant__c == 'Positivo' && s.Lead_Di_Riferimento__c!= null){
            	Segn.add(s.id);  
            	Lead.add(s.Lead_Di_Riferimento__c);
               }
         }
        
        system.debug('Segnalazioni' + Segn);
        system.debug('Lead di riferimento' + Lead);
                
       //LeadUpdate = [SELECT Id,Numero_S__c,IsConverted FROM Lead WHERE Id IN:Lead AND IsConverted = false];
       
      map <Id,Segnalazioni__c> SegnLead = new map <Id, Segnalazioni__c>([SELECT Id,Lead_Di_Riferimento__c FROM Segnalazioni__c WHERE Lead_Di_Riferimento__c IN:Lead]);
      system.debug('SegnLead' + SegnLead.size());       
        
      for(Segnalazioni__c s : segnalazione){
         Boolean find = false;
         for(id sl : SegnLead.keyset()){
           if(s.Id != SegnLead.get(sl).id   && s.Lead_Di_Riferimento__c  == SegnLead.get(sl).Lead_Di_Riferimento__c){
                //system.debug('EU dentro');
                find = true;   
               }
            }
            if(find){
                //system.debug('find true');
               mtpsegnleadup.put(s.Id, s);  
                LeadUpdate.add(new Segnalazioni__c (Id = s.id));
            }
            
        }
        
        system.debug('segnupdate' + mtpsegnleadup.size() );
        
        //for (Id key:mtpsegnleadup.keyset()){
			//mtpsegnleadup.get(key).Stato_Segnalazione_Warrant__c = 'Negativo';
            //mtpsegnleadup.get(key).Note_KO__c='Sostituito da altra fonte';
        //}
        //
        for (Segnalazioni__c l:LeadUpdate){
			l.Stato_Segnalazione_Warrant__c = 'Negativo';
            l.Note_KO__c='Sostituito da altra fonte';
        }
        
        try{
		//update mtpsegnleadup.values(); 
		update LeadUpdate;
        } catch(DMlException de){
            system.debug('catch' );
        }
    }
    
     /*public static void changestatusaccountupdate(List<Segnalazioni__c> segnalazione){
    
      Set<String> Segn = new Set<String>();
      Set<String> Accountconver = new Set<String>();
      List <Account> AccountUpdate = new List<Account>();
      List <Segnalazioni__c> SegnAcc = new List<Segnalazioni__c>();
      List <Segnalazioni__c> SegnAccUpdate = new List<Segnalazioni__c>();
        
       for (Segnalazioni__c s : segnalazione){  
           if(s.Stato_Segnalazione_Warrant__c == 'Positivo'){
            Segn.add(s.id);  
           Accountconver.add(s.Account__c);
           }
         }
        
       AccountUpdate = [SELECT Id FROM Account WHERE Id IN:Accountconver];
        
       SegnAcc = [SELECT Id,CheckTrigger__c,Lead_Di_Riferimento__c,Segnalazione_Relativa_a_Lead__c FROM Segnalazioni__c WHERE Account__c IN:Accountconver AND Segnalazione_Relativa_a_Lead__c = false];
        
    
        for(Segnalazioni__c s : segnalazione){
            for(Segnalazioni__c sa : SegnAcc){
                if(sa.id != s.Id && sa.Lead_Di_Riferimento__c == null){
                    sa.Stato_Segnalazione_Warrant__c='Negativo';
                    sa.Note_KO__c='Sostituita da altra fonte';
                    SegnAccUpdate.add(sa);
                }
            }
            
        }
        if(SegnAccUpdate.size() > 0){
		update SegnAccUpdate;
        }
    }*/
}