public class OnOpportunityTeamTriggerHandler {
    
    public static void QuoteSharing (List<OpportunityTeamMember> newline){
        
        User currUser = [ SELECT Id, Societa__c, UserRole.Name, Profile.Name FROM User WHERE Id =: UserInfo.getUserId() ];
        system.debug('currUser.Societa__c: '+currUser.Societa__c);  
        
        Set<Id> OppList = new Set <Id>();
               
        if(currUser.Societa__c == 'Warrant'){
            
            for(OpportunityTeamMember op:newline){
                OppList.add(op.OpportunityId );
                
            }
            system.debug('Id opp' + OppList);
            
        	List<Opportunity> OppMap = new List <Opportunity>([SELECT Id,Quote_Creazione__c FROM Opportunity WHERE Id IN:OppList]);
        	system.debug('OppMap' + OppMap);
        
        	
        	List<Id> qlist = new List <Id>();
        	
        	for(Opportunity o:OppMap){
             qlist.add(o.Quote_Creazione__c);
        	}


        	system.debug('qlist' + qlist);
        
            List<SBQQ__Quote__c> quoteMap = new List <SBQQ__Quote__c> ([SELECT Id,OwnerId, WRT_Agente3__c, SBQQ__Opportunity2__c FROM SBQQ__Quote__c WHERE Id IN:qlist]);
            
            system.debug('quoteMap' + quoteMap);
            boolean risultato=false;
            
            
            risultato = OnQuoteShare.manualShareRead(quoteMap);
            
            If(risultato == true && currUser.Profile.Name != 'Warrant - Integration Profile'){
                For(SBQQ__Quote__c q:quoteMap){
                        if(q.OwnerId != q.WRT_Agente3__c && q.WRT_Agente3__c != null){
                            q.OwnerId = q.WRT_Agente3__c;
                            q.SharingModel__c=true;
                        }
      
                    if(quoteMap.size()>0){
                        update quoteMap;
                    }
                }
            }
            
        }
    }


    public static void QuoteSharingDelete (List<OpportunityTeamMember> newline){

        User currUser = [ SELECT Id, Societa__c, UserRole.Name, Profile.Name FROM User WHERE Id =: UserInfo.getUserId() ];
        system.debug('currUser.Societa__c: '+currUser.Societa__c);  
        
        Set<Id> OppList = new Set <Id>();
        Set<Id> UserDelete = new Set<Id>();
        
        
        if(currUser.Societa__c == 'Warrant'){
            
            for(OpportunityTeamMember op:newline){
                OppList.add(op.OpportunityId );
                UserDelete.add(op.UserId);
            }
        
            system.debug('Id opp' + OppList);
        	system.debug('id user' + UserDelete);

            List<Opportunity> OppMap = new List <Opportunity>([SELECT Id,SBQQ__PrimaryQuote__c FROM Opportunity WHERE Id IN:OppList]);
        	system.debug('OppMap' + OppMap);
        
        	
        	List<Id> qlist = new List <Id>();
        	
        	for(Opportunity o:OppMap){
             qlist.add(o.SBQQ__PrimaryQuote__c);
        	}
        	
        	system.debug('qlist' + qlist);
        
            List<SBQQ__Quote__c> quoteMap = new List <SBQQ__Quote__c> ([SELECT Id,OwnerId, WRT_Agente3__c, SBQQ__Opportunity2__c FROM SBQQ__Quote__c WHERE Id IN:qlist]);
            List<User> UserList= new List <User>([SELECT Id FROM User WHERE Id IN:UserDelete]);

            system.debug('quoteMap' + quoteMap);
        	system.debug('UserList' + UserList);	
        
            boolean risultato=false;
            boolean response=false;
            
            for(OpportunityTeamMember op:newline){
                for(SBQQ__Quote__c qq:quoteMap){
                    if(op.UserId != qq.WRT_Agente3__c){
                        risultato=true;
                        system.debug('dentro if risultato');
                    } else{
                        op.adderror('Non è possibile eliminare questo utente perchè è agente della Quote');
                    }
                
                }
            }

            
            If(risultato == true){
            response = OnQuoteShare.manualShareDelete(quoteMap,UserList);
            }
            system.debug('Respons ELE' + response);
    	}
    }
}