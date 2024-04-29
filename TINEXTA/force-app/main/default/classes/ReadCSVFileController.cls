public class ReadCSVFileController {

    // @AuraEnabled
    // public static list<Account> readCSVFile(Id idContentDocument){
    //     list<Account> lstAccsToInsert = new list<Account>();
    //     if(idContentDocument != null) {
            
    //         // getting File Data based on document id 
    //         ContentVersion objVersion = [SELECT Id, VersionData FROM ContentVersion WHERE ContentDocumentId =:idContentDocument];
    //         // split the file data
    //         list<String> lstCSVLines = objVersion.VersionData.toString().split('\n');

    //         for(Integer i = 1; i < lstCSVLines.size(); i++){
    //             Account objAcc = new Account();
    //             list<String> csvRowData = lstCSVLines[i].split(',');
    //             System.debug('csvRowData====> '+csvRowData);
    //             objAcc.Partita_iva__c = csvRowData[0]; // accName
    //             objAcc.Codice_fiscale__c = csvRowData[1];
    //             lstAccsToInsert.add(objAcc);
    //         }

    //         System.debug('lstAccsToInsert====> '+lstAccsToInsert);


    //         // try{    
    //         //     if(!lstAccsToInsert.isEmpty()) {
    //         //         insert lstAccsToInsert;
    //         //     }
    //         // }
    //         // catch (Exception ex) {
    //         //     throw new AuraHandledException(ex.getMessage());
    //         // } 
    //     }
    //     return lstAccsToInsert;    
    
    // }

    @AuraEnabled
    public static WrapperObj getDate(List<String> idCF_PIvaList){

        // List<Account> accs = Database.query('SELECT Id, Name, Codice_fiscale__c, Partita_iva__c, (SELECT Id, Name FROM Event WHERE CreatedDate >= LAST_N_MONTHS:6) FROM Account WHERE Codice_fiscale__c IN: idCFList OR Partita_iva__c IN: idPIvaList');
        // Map<String, SObject> accMap  = Utilities.keyBy(accs, 'Id');

        System.debug('SV idCF_PIvaList: ' + idCF_PIvaList);
        WrapperObj response = new WrapperObj();

        try{

            List<String> idPIvaList = new List<String>();
            List<String> idCFList = new List<String>();
            String sQueryAccount = 'SELECT Id, Name, Codice_fiscale__c, Partita_iva__c, Owner.Name FROM Account ';
            String sQueryLead = 'SELECT Id, Name, Codice_Fiscale__c, Partiva_Iva__c, Owner.Name FROM Lead ';
            String sQueryWhereConditionAccount = '';
            String sQueryWhereConditionLead = '';
            Integer count = 0;
            for (String element : idCF_PIvaList) {
                List<String> x = element.split('_');
                // System.debug('@@@ x ' + x);
                // System.debug('@@@ x ' + x[0]);
                if(!x.isEmpty()){
                    idCFList.add(x[0]);
                    idPIvaList.add(x[1]);
                    if(count == 0){
                        sQueryWhereConditionAccount = 'WHERE (Codice_fiscale__c = \'' + x[0] + '\' AND Partita_iva__c = \'' + x[1] + '\') ';
                        sQueryWhereConditionLead    = 'WHERE (Codice_Fiscale__c = \'' + x[0] + '\' AND Partiva_Iva__c = \'' + x[1] + '\' AND IsConverted = FALSE) ';
                    } else {
                        sQueryWhereConditionAccount = 'OR (Codice_fiscale__c = \'' + x[0] + '\' AND Partita_iva__c = \'' + x[1] + '\') ';
                        sQueryWhereConditionLead    = 'OR (Codice_Fiscale__c = \'' + x[0] + '\' AND Partiva_Iva__c = \'' + x[1] + '\' AND IsConverted = FALSE) ';
                    }

                    sQueryAccount = sQueryAccount + sQueryWhereConditionAccount;
                    sQueryLead    = sQueryLead + sQueryWhereConditionLead;
                }
                count++;
            }

            System.debug('SV sQueryAccount: ' + sQueryAccount);
            System.debug('SV sQueryLead: ' + sQueryLead);
            List < sObject > lstOfAccounts = Database.query(sQueryAccount);
            List < sObject > lstOfLeads = Database.query(sQueryLead);

            System.debug('SV lstOfAccounts: ' + lstOfAccounts);
            System.debug('SV lstOfLeads: ' + lstOfLeads);

            Map<String, SObject> accMap  = Utilities.keyBy(lstOfAccounts, 'Id');

            List<Id> accIdList = new List<Id>();
            for(String key : accMap.keySet()){
                accIdList.add(key);
            }

            Map<String, SObject> oppToAccMap  = Utilities.keyBy([ SELECT Id, Name, AccountId, StageName, IsWon, IsClosed, (SELECT Id, ProductName__c FROM OpportunityLineItems) 
                                                            FROM Opportunity 
                                                            WHERE AccountId IN: accIdList ], '{AccountId}_{Id}', true);
            response.oppToAccMap = oppToAccMap;

            Map<String, SObject> eToAccMap  = Utilities.keyBy([ SELECT Id, AccountId, ActivityDateTime
                                                            FROM Event 
                                                            WHERE AccountId IN: accIdList
                                                            ORDER BY ActivityDateTime DESC ], '{AccountId}_{Id}', true);
            response.eToAccMap = eToAccMap;

            Map<String, SObject> leadsMap  = Utilities.keyBy(lstOfLeads, 'Id');

            List<Id> leadIdList = new List<Id>();
            for(String key : leadsMap.keySet()){
                leadIdList.add(key);
            }
                                                                
            Map<String, SObject> eToLeadMap  = Utilities.keyBy([ SELECT Id, WhoId, ActivityDateTime
                                                            FROM Event 
                                                            WHERE WhoId IN: leadIdList 
                                                            ORDER BY ActivityDateTime DESC ], '{WhoId}_{Id}', true);
            response.eToLeadMap = eToLeadMap;

            Map<String, SObject> mergeMap = new Map<String, SObject>();
            for (Id key : accMap.keySet()) {
                // The "key" variable is also available inside the loop
                mergeMap.put(key, accMap.get(key));
                // ... emailing logic
            }
            for (Id key : leadsMap.keySet()) {
                // The "key" variable is also available inside the loop
                mergeMap.put(key, leadsMap.get(key));
                // ... emailing logic
            }                         

            response.mergeMap = mergeMap;
                                                                
            System.debug(idCFList);
            System.debug(idPIvaList);
            System.debug(response);

        } catch (Exception e){
            throw new AuraHandledException(e.getMessage());       
        }

        return response;

    }

    @AuraEnabled
    public static WrapperResponse saveRecords(String records){
        System.debug('SV Obj List: ' + records);
        WrapperResponse result = new WrapperResponse();

        try {
            List<WRT_JSON2Apex_CSV> c = WRT_JSON2Apex_CSV.parse(records);
            System.debug('SV Obj List: ' + c);

            List<WRT_CSV_File__c> csvElementList = new List<WRT_CSV_File__c>();
            for (WRT_JSON2Apex_CSV thisFieldObject : c) {
                WRT_CSV_File__c csvElement = new WRT_CSV_File__c(); 
                csvElement.Name =  thisFieldObject.name;
                csvElement.Numero_Opp_Vinte__c =  thisFieldObject.numoppwon;
                csvElement.Numero_Opp_Aperte__c =  thisFieldObject.numoppopen;
                csvElement.Numero_Opp_Perse__c =  thisFieldObject.numopplost;
                csvElement.Numero_Eventi__c =  thisFieldObject.numevent;
                csvElement.Data_Ultimo_Evento__c =  thisFieldObject.eventlastdate;
                // csvElement.Responsabile__c =  thisFieldObject.ownerid;

                if(thisFieldObject.ObjectType == 'Account'){
                    csvElement.Account__c =  thisFieldObject.id;
                } else {
                    csvElement.Lead__c =  thisFieldObject.id;
                }
                
                csvElementList.add(csvElement);
            }

            insert csvElementList;
            System.debug('SV csvElementList: ' + csvElementList);

            result.data = csvElementList;

        } catch (Exception e) {
            result.success = false;
            result.msg = e.getMessage();
        }

        return result;
        
    }

    @AuraEnabled
    public static WrapperResponse saveLeads(String leads){
        System.debug('SV Obj List: ' + leads);
        WrapperResponse result = new WrapperResponse();

        try {
            List<WRT_JSON2Apex_Lead> c = WRT_JSON2Apex_Lead.parse(leads);
            System.debug('SV Obj List: ' + c);

            List<Lead> csvLeadList = new List<Lead>();
            for (WRT_JSON2Apex_Lead thisFieldObject : c) {
                Lead csvLead = new Lead();
                csvLead.FirstName = thisFieldObject.nome;
                csvLead.LastName = thisFieldObject.cognome;
                csvLead.Company = thisFieldObject.company;
                csvLead.Partiva_Iva__c = thisFieldObject.iva;
                csvLead.Codice_Fiscale__c = thisFieldObject.cf;

                csvLead.Stato_Segnalazione_Warrant__c = WRN_ReadCSVFile__c.getInstance().Stato_Segnalazione__c;
                csvLead.AccountSegnalatore__c = WRN_ReadCSVFile__c.getInstance().Id_Segnalatore__c;
                
                csvLeadList.add(csvLead);
            }
            
            insert csvLeadList;
            System.debug('SV csvLeadList: ' + csvLeadList);

            result.data = csvLeadList;

        } catch (Exception e) {
            result.success = false;
            result.msg = e.getMessage();          
        }

        return result;

    }
    
    public class WrapperObj {
        @AuraEnabled public Map<String, SObject> mergeMap;
        @AuraEnabled public Map<String, SObject> oppToAccMap;
        @AuraEnabled public Map<String, SObject> eToAccMap;
        @AuraEnabled public Map<String, SObject> eToLeadMap;        
    
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