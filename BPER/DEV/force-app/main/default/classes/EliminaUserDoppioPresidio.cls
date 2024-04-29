public with sharing class EliminaUserDoppioPresidio {

    //Eliminazione logica, valorizzo il campo PTF_EndDate__c con la data odierna 
    public static void eliminaUtenti(List<String> listUsersId){  

        List<NDGManagementMember__c > listMemberToUpdate = new List<NDGManagementMember__c >();
        List<NDGManagementMember__c > listUserMember = new List<NDGManagementMember__c >();
        List<NDGManagementMember__c > doppiPresidiToCreate = new List<NDGManagementMember__c >();
        Id recTypeId = SV_Utilities.getRecordTypeByDeveloperName('NDGManagementMember__c', 'DoppioPresidio');
        List<Contact> listContact = new List<Contact>();

        if(listUsersId.size()>0)
        {
           
            listUserMember = [select id,PTF_NDG__c,PTF_EndDate__c,PTF_NDG__r.PTF_Filiale__c from NDGManagementMember__c where PTF_Gestore__r.PTF_User__c in:listUsersId and 
                RecordType.DeveloperName='DoppioPresidio' and PTF_ModelloDiServizio__c in ('Private','Key Client Privati')];
        
            Date todaysDate = Date.today();
            Datetime todaysDateTime = Datetime.now();

            List<String> filiali = new List<String>();
            for(NDGManagementMember__c  m:  listUserMember){
                filiali.add(m.PTF_NDG__r.PTF_Filiale__c);
                m.PTF_EndDate__c=todaysDate;
                m.PTF_EndDate_DT__c=todaysDateTime;
                listMemberToUpdate.add(m);    
            }
            List<Contact> contacts = [SELECT Id,AccountId FROM Contact WHERE PTF_Ruolo__c='100' and PTF_Closed_Date_Referente__c =NULL AND AccountId in:filiali];
            Map<String,SObject> contactMap = SV_Utilities.keyBy(contacts, 'AccountId'); 
            System.debug('Contact Map '+contactMap);
            for(NDGManagementMember__c  m:  listUserMember)
            {
                NDGManagementMember__c ndgM = new NDGManagementMember__c();
                ndgM=m.clone(false, true, false, true);
                if(contactMap.containsKey(m.PTF_NDG__r.PTF_Filiale__c))
                    ndgM.PTF_Gestore__c=(String)contactMap.get(m.PTF_NDG__r.PTF_Filiale__c).get('Id');
                ndgM.RecordTypeId = recTypeId;
                ndgM.PTF_StartDate__c = Date.today();
                ndgM.PTF_StartDate_DT__c = Datetime.now();
                ndgM.PTF_EndDate__c=null;
                ndgM.PTF_EndDate_DT__c=null;
                ndgM.PTF_NDG__c=m.PTF_NDG__c;
                
                doppiPresidiToCreate.add(ndgM);
            }
            System.debug(doppiPresidiToCreate);

            try
            {
                update listMemberToUpdate; 
                insert doppiPresidiToCreate;
            }
            catch(Exception ex) 
            {
                System.debug('DK Exception: ' + ex  + '; Stacktrace: ' + ex.getStackTraceString());
            }
            
        }   
    }
}