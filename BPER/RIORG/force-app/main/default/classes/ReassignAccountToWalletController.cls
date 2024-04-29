public class ReassignAccountToWalletController {
    public virtual class BaseException extends Exception {}
    public class OtherException extends BaseException {}


    @AuraEnabled
    public static Map<String, SObject> getAssignData(String recordId){
        System.debug('SV getAssignData recordId: ' + recordId);
        
        Map<String, SObject> accMap = new Map<String, SObject>();

        try{
            
            Wallet__c port = [SELECT PTF_ModelloDiServizio__c, PTF_Filiale__c FROM Wallet__c WHERE Id=:recordId];

            accMap = SV_Utilities.keyBy([ SELECT RecordType.DeveloperName, Id, OwnerId, IsDeleted, Name, 
                                                    RecordTypeId, CreatedDate, CreatedById, LastModifiedDate, 
                                                    LastModifiedById, SystemModstamp, LastActivityDate, LastViewedDate,
                                                    PTF_Portafoglio__c, PTF_CoerenzaGruge__c, CRM_NDG__c, CRM_VAT__c,
                                                    PTF_NaturaGiuridica__c, PTF_GruppoGestionale__c, PTF_GruppoComportamentale__c
                                                FROM Account
                                                WHERE PTF_Portafoglio__c !=:recordId 
                                                AND PTF_Portafoglio__r.PTF_ModelloDiServizio__c=:port.PTF_ModelloDiServizio__c 
                                                AND PTF_Portafoglio__r.PTF_Filiale__c=:port.PTF_Filiale__c ], 'Id', false);
            System.debug('SV AssignAccMap: ' + accMap);                                    
        }

        catch(System.CalloutException e){

            System.debug('SV CalloutException ' + e);

        }

        catch(BaseException e){

            System.debug('SV BaseException ' + e);

        }

        return accMap;

    }

    @AuraEnabled
    public static Map<String, SObject> getAllData(String recordId){
        System.debug('SV getAllData recordId: ' + recordId);

        Map<String, SObject> accMap = new Map<String, SObject>();

        try {

            accMap = SV_Utilities.keyBy([ SELECT RecordType.DeveloperName, Id, OwnerId, IsDeleted, Name, 
                                                        RecordTypeId, CreatedDate, CreatedById, LastModifiedDate, 
                                                        LastModifiedById, SystemModstamp, LastActivityDate, LastViewedDate,
                                                        PTF_Portafoglio__c, PTF_CoerenzaGruge__c, CRM_NDG__c, CRM_VAT__c,
                                                        PTF_NaturaGiuridica__c, PTF_GruppoGestionale__c, PTF_GruppoComportamentale__c
                                                    FROM Account
                                                    WHERE PTF_Portafoglio__c =: recordId ], 'Id', false);
            System.debug('SV financialAccMap: ' + accMap);

            

        } catch(System.CalloutException e) { 
            //Exception handling goes here.... retry the call, whatever 
            System.debug('SV CalloutException ' + e);
 
        } catch (BaseException e) {  
            // This catches the OtherException
            System.debug('SV BaseException ' + e);

        } 

        return accMap;

    }

    @AuraEnabled
    public static Map<String, SObject> getMW(String recordId){
        System.debug('SV getMW recordId: ' + recordId);

        Map<String, SObject> accMap = new Map<String, SObject>();
        Map<String, SObject> mwMap = new Map<String, SObject>();

        try {

            accMap = SV_Utilities.keyBy([ SELECT RecordType.DeveloperName, Id, OwnerId, IsDeleted, Name, 
                                                        RecordTypeId, CreatedDate, CreatedById, LastModifiedDate, 
                                                        LastModifiedById, SystemModstamp, LastActivityDate, LastViewedDate,
                                                        PTF_Portafoglio__c, PTF_CoerenzaGruge__c, CRM_NDG__c, CRM_VAT__c,
                                                        PTF_NaturaGiuridica__c, PTF_GruppoGestionale__c, PTF_GruppoComportamentale__c
                                                    FROM Account
                                                    WHERE PTF_Portafoglio__c =: recordId ], 'Id', false);
            System.debug('SV financialAccMap: ' + accMap);

            mwMap = SV_Utilities.keyBy([ SELECT id, Name, PTF_Filiale__c, PTF_ModelloDiServizio__c 
                                         FROM Wallet__c 
                                         WHERE Id !=: recordId AND PTF_DeletionDate__c=null], 'Id');


        } catch(System.CalloutException e) { 
            //Exception handling goes here.... retry the call, whatever 
            System.debug('SV CalloutException ' + e);
 
        } catch (BaseException e) {  
            // This catches the OtherException
            System.debug('SV BaseException ' + e);

        } 

        return mwMap;

    }

    @AuraEnabled
    public static Boolean assignSelectedAccounts(String recordId, List<String> accounts){
        List<Account> accToAssign= new List<Account>();
        try{
            System.debug('SV assignSelectedAccount recordId: ' + recordId);
            for(String accountId : accounts){
                Account acc = new Account();
                acc.Id=accountId;
                acc.PTF_Portafoglio__c=recordId;
                accToAssign.add(acc);
            }
            update accToAssign;
        }
        catch(System.CalloutException e) { 
            //Exception handling goes here.... retry the call, whatever 
            System.debug('SV CalloutException ' + e);
            throw new AuraHandledException(e.getMessage());
        }
        catch(BaseException e) { 
            //Exception handling goes here.... retry the call, whatever 
            System.debug('SV BaseException ' + e);
            throw new AuraHandledException(e.getMessage());
        }
        return true;
    }

    @AuraEnabled
    public static Boolean reassignSelectedAccount(String x_from, List<String> accounts, String x_to){
        System.debug('SV reassignSelectedAccount x_from: ' + x_from);
        System.debug('SV reassignSelectedAccount accounts: ' + accounts);
        System.debug('SV reassignSelectedAccount x_to: ' + x_to);

        try {
            Wallet__c fromMW = [ SELECT id, Name, PTF_Filiale__c, PTF_ModelloDiServizio__c FROM Wallet__c WHERE Id =: x_from ];
            Wallet__c toMW = [ SELECT id, Name, PTF_Filiale__c, PTF_ModelloDiServizio__c FROM Wallet__c WHERE Id =: x_to ];

            List<Account> accs = [ SELECT Id, PTF_Portafoglio__c FROM Account WHERE Id IN : accounts ];
            if(fromMW.PTF_Filiale__c == toMW.PTF_Filiale__c && 
               fromMW.PTF_ModelloDiServizio__c == toMW.PTF_ModelloDiServizio__c){
                for(Account a : accs){
                    if(a.PTF_Portafoglio__c == x_from){
                        a.PTF_Portafoglio__c = x_to;
                    }
                }    

                update accs;

            } else {
                throw new AuraHandledException('Selezionato un Portafoglio con Filiale e/o Modello di servizio diversi');
            }
        
        } catch(System.CalloutException e) { 
            //Exception handling goes here.... retry the call, whatever 
            System.debug('SV CalloutException ' + e);
            throw new AuraHandledException(e.getMessage());

        } catch (BaseException e) {  
            // This catches the OtherException
            System.debug('SV BaseException ' + e);
            throw new AuraHandledException(e.getMessage());

        } 

        return true;

    }


}