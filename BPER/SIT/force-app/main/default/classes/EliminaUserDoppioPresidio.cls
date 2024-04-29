public with sharing class EliminaUserDoppioPresidio {

    //Eliminazione logica, valorizzo il campo PTF_EndDate__c con la data odierna 
    public static void eliminaUtenti(List<String> listUsersId){  

        List<NDGManagementMember__c > listMemberToUpdate = new List<NDGManagementMember__c >();
        List<NDGManagementMember__c > listUserMember = new List<NDGManagementMember__c >();
        List<Contact> listContact = new List<Contact>();

        if(listUsersId.size()>0)
        {
           
            listUserMember = [select id,PTF_EndDate__c from NDGManagementMember__c where PTF_Gestore__r.PTF_User__c in:listUsersId and 
                RecordType.DeveloperName='DoppioPresidio' and PTF_ModelloDiServizio__c in ('Private','Key Client Privati')];
        
            Date todaysDate = Date.today();
            Datetime todaysDateTime = Datetime.now();

            for(NDGManagementMember__c  m:  listUserMember){
                m.PTF_EndDate__c=todaysDate;
                m.PTF_EndDate_DT__c=todaysDateTime;
                listMemberToUpdate.add(m);
            }

            try
            {
                update listMemberToUpdate; 
            }
            catch(Exception ex) 
            {
                System.debug('DK Exception: ' + ex  + '; Stacktrace: ' + ex.getStackTraceString());
            }
            
        }   
    }
}