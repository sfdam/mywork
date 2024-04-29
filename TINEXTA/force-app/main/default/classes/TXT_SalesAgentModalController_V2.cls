public class TXT_SalesAgentModalController_V2 {
    
    @AuraEnabled
    public static WrapperResponse getAgents(String recordId, String societa){
        
        WrapperResponse result = new WrapperResponse();
       
        system.debug('RC societa:'+societa);
        switch on societa{
            when 'Innolva'{
     			 try{                             
        			 list<Lead> LeadCAP = [SELECT PostalCode FROM Lead WHERE id=:recordId];        
           			 result.data= [ SELECT Titolare__c, Name, Citta__c, Favourite_Agent_for_CAP__c 
                           			FROM Anagrafica_Venditori__c 
                           			WHERE CAP__c =: LeadCAP[0].PostalCode ];
                    result.objType = 'Anagrafica_Venditori__c';
            
       			 } catch (Exception e){
            			result.success = false; 
            			result.msg = e.getMessage();
       			 }        					                
            }
            when 'Warrant'{
                    try{
                        switch on (recordId.substring(0,3)){
                            when '001'{
                                Account currAcc = [SELECT Id,Name,Responsabile_WarrantHub__c FROM Account WHERE id=:recordId LIMIT 1];
                                result.data= [ SELECT Id, Name 
                                                FROM User 
                                                WHERE Id =: currAcc.Responsabile_WarrantHub__c];
                                result.data.addAll([ SELECT Id, Name 
                                                     FROM User 
                                                     WHERE Warrant_customer_service__c =: UserInfo.getUserId() 
                                                     AND Id != : currAcc.Responsabile_WarrantHub__c]);
                            }
                            when '003'{
                                Contact currCont = [SELECT Id,Name,AccountId FROM Contact WHERE id=:recordId LIMIT 1];
                                Account currAcc = [SELECT Id,Name,Responsabile_WarrantHub__c FROM Account WHERE id=:currCont.AccountId LIMIT 1];
                                result.data= [ SELECT Id, Name 
                                                FROM User 
                                                WHERE Id =: currAcc.Responsabile_WarrantHub__c];
                                result.data.addAll([ SELECT Id, Name 
                                                     FROM User 
                                                     WHERE Warrant_customer_service__c =: UserInfo.getUserId() 
                                                     AND Id != : currAcc.Responsabile_WarrantHub__c]);
                            }
                            when '00Q'{
                                Lead currLead = [SELECT Id,Name, OwnerId FROM Lead WHERE id=:recordId LIMIT 1];
                                result.data = ([SELECT Id, Name 
                                                FROM User
                                                WHERE Id =: currLead.OwnerId]);
                                result.data.addAll([ SELECT Id, Name 
                                                FROM User 
                                                WHERE Warrant_customer_service__c =: UserInfo.getUserId() AND 
                                                 Id != : currLead.OwnerId]);
                                
                            }
                        }
                        result.objType = 'User';
            
        			} catch (Exception e){
            				result.success = false; 
            				result.msg = e.getMessage();
        			}
            	}
            when 'CoMark'{
                  try{
                      	switch on (recordId.substring(0,3)){
                            when '001'{
                                Account currAcc = [SELECT Id,Name,agentezona_comark__c FROM Account WHERE id=:recordId LIMIT 1];
                                result.data= [  SELECT Id, Name 
                           				        FROM User 
                           				        WHERE Id =: currAcc.agentezona_comark__c]; 
                            }
                            when '00Q'{
                                Lead currLead = [SELECT Id,Name,agentezona_comark__c FROM Lead WHERE id=:recordId LIMIT 1];
                                result.data= [  SELECT Id, Name 
                           				        FROM User 
                           				        WHERE Id =: currLead.agentezona_comark__c]; 
                            }
                          }
                       
                        result.objType = 'User';   
            
        			} catch (Exception e){
            				result.success = false; 
            				result.msg = e.getMessage();
        			}

            }
            when else{
                 try{                             
        			 list<Lead> LeadCAP = [SELECT PostalCode FROM Lead WHERE id=:recordId];        
           			 result.data= [ SELECT Titolare__c, Name, Citta__c, Favourite_Agent_for_CAP__c 
                           			FROM Anagrafica_Venditori__c 
                           			WHERE CAP__c =: LeadCAP[0].PostalCode ];
            
       			 	} catch (Exception e){
            			result.success = false; 
            			result.msg = e.getMessage();
       			 	}        					                
            }
            
    }
        	return result;   
        
    }
    

    @AuraEnabled
    public static User getUserInfo(){
        return [ SELECT Id, Name, Societa__c, Agent_List_Access__c, Agent_Selected_Access__c, Profile.Name FROM User WHERE Id =: UserInfo.getUserId() ];
        
    }
    
    /*..........................................*/
    /* Wrapper class to display Response       */
    /*.........................................*/
    
    public class WrapperResponse {
        
        @AuraEnabled public Boolean success;
        @AuraEnabled public String msg;
        @AuraEnabled public List<Object> data;
        @AuraEnabled public String objType;
        
        public WrapperResponse(){
            success = true;
            msg = '';
            data = new List<Object>();
            objType = '';
        }
    }

}