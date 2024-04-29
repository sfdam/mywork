public class INN_SalesAgentModalController_V2 {
    @AuraEnabled 
    public static WrapperResponse getAgent(String recordId){
    	  WrapperResponse result = new WrapperResponse();
          try{  
                if(recordId.substring(0,3) == '00Q'){                           
        			list<Lead> currLead = [SELECT CAP_Sede_Operativa_innolva__c,Utente_Titolare_Innolva__c, Agente_Titolare_Innolva__c FROM Lead WHERE id=:recordId];        
           			result.pickData =   [SELECT Id, Titolare__c, Name, Citta__c, Favourite_Agent_for_CAP__c
                                        FROM  Anagrafica_Venditori__c
                                        WHERE Id =: currLead[0].Agente_Titolare_Innolva__c ];
                    result.pickData.addAll([SELECT Id, Titolare__c, Name, Citta__c, Favourite_Agent_for_CAP__c 
                           			        FROM Anagrafica_Venditori__c 
                           			        WHERE CAP__c =: currLead[0].CAP_Sede_Operativa_innolva__c
                                            AND Id !=: currLead[0].Agente_Titolare_Innolva__c]);

                    result.lookData = [SELECT Id,Name,FirstName, LastName FROM User WHERE Id =: currLead[0].Utente_Titolare_Innolva__c];                
                }else if(recordId.substring(0,3) == '001'){
                    list<Account> currAcc = [SELECT CAP_Sede_Operativa_innolva__c, BillingPostalCode, Utente_Titolare_Innolva__c, Agente_Titolare_Innolva__c FROM Account WHERE id=:recordId];        

                    List<Sedi__c> sedi = new List<Sedi__c>([SELECT Id, Sede_Primaria__c, Tipo_indirizzo__c, Societa_di_riferimento__c, CAP__c FROM Sedi__c WHERE Account__c =: recordId AND Societa_di_riferimento__c = 'Innolva' AND Tipo_indirizzo__c = 'Sede Operativa' ]);
                    String cap;
                    if(!sedi.isEmpty() && sedi.size() > 1){
                        for(Sedi__c s : sedi){
                            if(s.Sede_Primaria__c)
                                cap = s.CAP__c;
                        }
                    } else if(!sedi.isEmpty() && sedi.size() == 1){
                        cap = sedi[0].CAP__c;
                    } else {
                        cap = currAcc[0].BillingPostalCode;
                    }

           			result.pickData =   [SELECT Id, Titolare__c, Name, Citta__c, Favourite_Agent_for_CAP__c
                                        FROM  Anagrafica_Venditori__c
                                        WHERE Id =: currAcc[0].Agente_Titolare_Innolva__c ];
                    result.pickData.addAll([SELECT Id, Titolare__c, Name, Citta__c, Favourite_Agent_for_CAP__c 
                           			        FROM Anagrafica_Venditori__c 
                           			        // WHERE CAP__c =: currAcc[0].CAP_Sede_Operativa_innolva__c
                                            WHERE CAP__c =: cap
                                            AND Id !=: currAcc[0].Agente_Titolare_Innolva__c]);

                    result.lookData = [SELECT Id,Name,FirstName, LastName FROM User WHERE Id =: currAcc[0].Utente_Titolare_Innolva__c];
                }

       		} catch (Exception e){
            			result.success = false; 
            			result.msg = e.getMessage();
       			 }  
         return result;         					                
    }

    @AuraEnabled
    public static User getUserInfo(){
        return [ SELECT Id, Name, Societa__c, Agent_List_Access__c, Agent_Selected_Access__c, Profile.Name FROM User WHERE Id =: UserInfo.getUserId() AND isActive = true ];
        
    }

    @AuraEnabled
    public static WrapperResponse updateLead(String recordId, sObject pickSelected, sObject lookSelected){
        system.debug('recordId '+recordId);
        system.debug('pickSelected '+pickSelected);
        system.debug('lookSelected '+lookSelected);
         WrapperResponse result = new WrapperResponse();
        try{
            if(recordId.substring(0,3) == '00Q'){
                Lead l = [SELECT Id, Name, Utente_Titolare_Innolva__c, Agente_Titolare_Innolva__c FROM Lead WHERE Id =: recordId LIMIT 1];
                l.Agente_Titolare_Innolva__c = pickSelected != null ? (Id)pickSelected.get('Id') : l.Agente_Titolare_Innolva__c;
                l.Utente_Titolare_Innolva__c = lookSelected != null ? (Id)lookSelected.get('Id') : null;
                update l;
            }else if(recordId.substring(0,3) == '001'){
                Account a = [SELECT Id, Name, Utente_Titolare_Innolva__c, Agente_Titolare_Innolva__c FROM Account WHERE Id =: recordId LIMIT 1];
                a.Agente_Titolare_Innolva__c = pickSelected != null ? (Id)pickSelected.get('Id') : a.Agente_Titolare_Innolva__c;
                a.Utente_Titolare_Innolva__c = lookSelected != null ? (Id)lookSelected.get('Id') : null;
                update a;
            }
        } catch (Exception e){
            result.success = false; 
            result.msg = e.getMessage();
            throw new AuraHandledException(e.getMessage());
        }
        return result;
    }
    
    public class WrapperResponse {
        
        @AuraEnabled public Boolean success;
        @AuraEnabled public String msg;
        @AuraEnabled public List<Object> pickData;
        @AuraEnabled public List<Object> lookData;
        
        public WrapperResponse(){
            success = true;
            msg = '';
            pickData = new List<Object>();
            lookData = new List<Object>();
        }
    }

}