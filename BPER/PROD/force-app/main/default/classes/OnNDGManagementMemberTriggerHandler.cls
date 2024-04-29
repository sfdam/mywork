public with sharing class OnNDGManagementMemberTriggerHandler {
    public static void setStoricoCampi(List<NDGManagementMember__c> ListNDGMember){

        try
        {
            List<String> listIDGestori = new List<String>();

            //GR 71522 START
            List<String> listIDNdg = new List<String>();
            //GR END

            for(NDGManagementMember__c ndgMbm:ListNDGMember)
            {
                listIDGestori.add(ndgMbm.PTF_Gestore__c);

                //GR 71522 START
                listIDNdg.add(ndgMbm.PTF_NDG__c);
                //GR END
            }
            
            List<Contact> gestore = [SELECT id,PTF_TipologiaRuolo__c, PTF_Ruolo__c, PTF_CodiceRuolo__c FROM Contact where id in :listIDGestori];

            //GR 71522 START
            List<Account> ndg = [SELECT id ,CRM_ReferenteNameFormula__c FROM Account where Id in : listIDNdg];
            //GR END

            List<RoleTypology__c> listaRuoli = [SELECT id,name FROM RoleTypology__c];

            Map<Id,Account> mappaAccount = new Map<Id,Account>();
            for(Account acc: ndg )
                mappaAccount.put(acc.id,acc);

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
                    //GR 71522 START
                    referente.PTF_ReferenteToNdg__c = mappaAccount.get(referente.PTF_NDG__c).CRM_ReferenteNameFormula__c;
                    //GR END
                    referente.PTF_HistoryRole__c=mappaRuoli.get(mappaContatti.get(referente.PTF_Gestore__c).PTF_TipologiaRuolo__c);
                    referente.PTF_HistoryRoleCode__c =mappaContatti.get(referente.PTF_Gestore__c).PTF_CodiceRuolo__c;


                    System.debug('Titolare '+referente.PTF_HistoryRole__c +' '+ mappaRuoli.get(mappaContatti.get(referente.PTF_Gestore__c).PTF_TipologiaRuolo__c));
                    System.debug(referente.PTF_HistoryRoleCode__c +' '+ mappaContatti.get(referente.PTF_Gestore__c).PTF_CodiceRuolo__c);                 
                }
            }     
            
        }
        catch(Exception e)
        {
            System.debug(e.getMessage());
        }
        
       
    }
}