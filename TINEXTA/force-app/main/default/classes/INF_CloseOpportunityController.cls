public class INF_CloseOpportunityController {
    @AuraEnabled
    public static WrapperResponse getCodes(String accountId) {
        WrapperResponse resp = new WrapperResponse();
        try{
            User currUsr = [SELECT Id, Societa__c FROM User WHERE Id =: UserInfo.getUserId()];
            Account acc = [SELECT Id, Codice_Cliente_Camerfirma__c, Codice_Cliente_Sixtema__c, Codice_Cliente_X3__c FROM Account WHERE Id =: accountId ];
            List<Slave_Data__c> slaveList = [SELECT Id, Codice_Cliente_Camerfirma__c, Codice_Cliente_Sixtema__c, Codice_Cliente_X3__c FROM Slave_Data__c WHERE Account__c =: accountId];
            System.debug('acc: '+acc);
            System.debug('slaveList: '+slaveList);
            System.debug('currUsr.Societa__c: '+currUsr.Societa__c);

            switch on currUsr.Societa__c {
                when  'Sixtema'{
                    if(acc.Codice_Cliente_Sixtema__c!= null && !resp.codesList.contains(acc.Codice_Cliente_Sixtema__c))resp.codesList.add(acc.Codice_Cliente_Sixtema__c);
                }
                when 'Infocert' {
                    if(acc.Codice_Cliente_X3__c!= null && !resp.codesList.contains(acc.Codice_Cliente_X3__c))resp.codesList.add(acc.Codice_Cliente_X3__c);
                }
                //when 'Luxtrust' {
                    //if(acc.Codice_Cliente_Luxtrust__c!= null && !resp.codesList.contains(acc.Codice_Cliente_Luxtrust__c))resp.codesList.add(acc.Codice_Cliente_Luxtrust__c);
                //}
                when 'Camerfirma' {
                    if(acc.Codice_Cliente_Camerfirma__c!= null && !resp.codesList.contains(acc.Codice_Cliente_Camerfirma__c))resp.codesList.add(acc.Codice_Cliente_Camerfirma__c);
                }
            }

            System.debug('@@@ resp codesList ' + resp.codesList);
            for(Slave_Data__c slv : slaveList){
                switch on currUsr.Societa__c {
                    when  'Sixtema'{
                        if(slv.Codice_Cliente_Sixtema__c != null && !resp.codesList.contains(slv.Codice_Cliente_Sixtema__c))resp.codesList.add(slv.Codice_Cliente_Sixtema__c);
                    }
                    when 'Infocert' {
                        if(slv.Codice_Cliente_X3__c != null && !resp.codesList.contains(slv.Codice_Cliente_X3__c))resp.codesList.add(slv.Codice_Cliente_X3__c);
                    }
                    //when 'Luxtrust' {
                        //if(slv.Codice_Cliente_Luxtrust__c != null && !resp.codesList.contains(slv.Codice_Cliente_Luxtrust__c))resp.codesList.add(slv.Codice_Cliente_Luxtrust__c);
                    //}
                    when 'Camerfirma' {
                        if(slv.Codice_Cliente_Camerfirma__c != null && !resp.codesList.contains(slv.Codice_Cliente_Camerfirma__c))resp.codesList.add(slv.Codice_Cliente_Camerfirma__c);
                    }
                }
            }

            System.debug('@@@ resp codesList final ' + resp.codesList);
            resp.success = true;
        
        }catch(Exception e){
            resp.success = false;
            resp.message = e.getMessage();
            //throw new AuraHandledException(e.getMessage());  
        }
        return resp;        
    }

    @AuraEnabled
    public static WrapperResponse getCodesNew(String optyId){
        WrapperResponse resp = new WrapperResponse();

        try {
            System.debug('@@@ getCodesNew ' + optyId);
            User currUsr = [SELECT Id, Societa__c FROM User WHERE Id =: UserInfo.getUserId()];

            Opportunity opp = [SELECT Id, Codice_Cliente__c, Codice_Cliente__r.Name FROM Opportunity WHERE Id =: optyId];

            if(opp.Codice_Cliente__c != null)
                resp.codesList.add(opp.Codice_Cliente__r.Name);

            System.debug('@@@ resp codesList final ' + resp.codesList);
            resp.success = true;
        
        }catch(Exception e){
            resp.success = false;
            resp.message = e.getMessage();
            //throw new AuraHandledException(e.getMessage());  
        }
        return resp; 
    }

    // @AuraEnabled
    // public static WrapperResponse updateRecord(String recordId, String newCode) {
    //     WrapperResponse resp = new WrapperResponse();
    //     try{
    //         Opportunity opp = [Select Id, INF_CodiceClienteOpportunity__c FROM Opportunity WHERE Id =: recordId];
    //         opp.INF_CodiceClienteOpportunity__c = newCode;
    //         update opp;
    //         resp.success = true;
    //     }catch(Exception e){
    //         resp.success = false;
    //         resp.message = e.getMessage();
    //         //throw new AuraHandledException(e.getMessage());  
    //     }
    //     return resp;       
    // }

    public class WrapperResponse {        
        @AuraEnabled public Boolean success;
        @AuraEnabled public String message;
        @AuraEnabled public List<String> codesList;
        public WrapperResponse(){
            success = true;
            message = '';
            codesList = new List<String>();
        }
    }

}