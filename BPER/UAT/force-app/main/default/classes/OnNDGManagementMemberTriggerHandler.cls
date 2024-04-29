public with sharing class OnNDGManagementMemberTriggerHandler {
    public static void setStoricoCampi(List<NDGManagementMember__c> ListNDGMember){

        try
        {
            List<String> listIDGestori = new List<String>();
            for(NDGManagementMember__c ndgMbm:ListNDGMember)
            {
                listIDGestori.add(ndgMbm.PTF_Gestore__c);
            }

            List<Contact> gestore = [SELECT id,PTF_TipologiaRuolo__c, PTF_Ruolo__c FROM Contact where id in :listIDGestori];

            List<RoleTypology__c> listaRuoli = [SELECT id,name FROM RoleTypology__c];

            Map<Id,Contact> mappaContatti = new Map<Id,Contact>();
            for(Contact con: gestore )
                mappaContatti.put(con.id,con);

            Map<Id,String> mappaRuoli = new Map<Id,String>();
            for(RoleTypology__c roles: listaRuoli )
                mappaRuoli.put(roles.id,roles.name);


            for(NDGManagementMember__c referente: ListNDGMember)
            {
                if(mappaContatti.containsKey(referente.PTF_Gestore__c))
                {
                    referente.PTF_HistoryRole__c=mappaRuoli.get(mappaContatti.get(referente.PTF_Gestore__c).PTF_TipologiaRuolo__c);
                    referente.PTF_HistoryRoleCode__c =mappaContatti.get(referente.PTF_Gestore__c).PTF_Ruolo__c;

                    System.debug('Titolare '+referente.PTF_HistoryRole__c +' '+ mappaRuoli.get(mappaContatti.get(referente.PTF_Gestore__c).PTF_TipologiaRuolo__c));
                    System.debug(referente.PTF_HistoryRoleCode__c +' '+ mappaContatti.get(referente.PTF_Gestore__c).PTF_Ruolo__c);                 
                }
            }     
            
        }
        catch(Exception e)
        {
            System.debug(e.getMessage());
        }
        
       
    }
}