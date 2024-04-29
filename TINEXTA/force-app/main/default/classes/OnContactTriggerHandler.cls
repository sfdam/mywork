/**
 * Code coverage PrivacyController_Test
 * */
public without sharing class OnContactTriggerHandler {

    public static void checkContitolaritaDatiAccount(Map<Id,Contact> cntMap, map<id, contact> oldmap, boolean isUpdate){
        System.debug('@@@ cntMap ' + JSON.serialize(cntMap));
        set<id> conId = new set<id>();
        if(isUpdate)
        {
            for(contact con : cntMap.values())
            {
                if(con.Contitolarita_Dati_TXT__c != oldmap.get(con.id).Contitolarita_Dati_TXT__c)
                {
                    conId.add(con.id);
                    system.debug('--Updated field---- ');
                }
            }
        }
        else
        {
            conId = cntMap.keySet();
        }
        Map<Id,Account> accMap = new Map<Id,Account>([SELECT Id, Name, Contitolarita_Dati_TXT__c, Data_Contitolarita_Dati_TXT__c FROM Account WHERE Id IN (SELECT AccountId FROM Contact WHERE Id IN: conId)]);
        Map<String,List<SObject>> accIdXCnt = Utilities.groupBy([SELECT Id, AccountId, Contitolarita_Dati_TXT__c, Data_Contitolarita_Dati_TXT__c FROM Contact WHERE AccountId IN : accMap.keySet()], 'AccountId');

        List<Account> accToUpd = new List<Account>();

        for(String idAcc : accIdXCnt.keySet()){
            System.debug('@@@ filter ' + Utilities.filter(accIdXCnt.get(idAcc), 'Contitolarita_Dati_TXT__c', 'SI').isEmpty());
            if(Utilities.filter(accIdXCnt.get(idAcc), 'Contitolarita_Dati_TXT__c', 'SI').isEmpty() && !Utilities.filter(accIdXCnt.get(idAcc), 'Contitolarita_Dati_TXT__c', 'NO').isEmpty()){
                Account acc = accMap.get((Id)idAcc);
                acc.Contitolarita_dati_TXT__c = 'NO';
                acc.Data_Contitolarita_dati_TXT__c = System.Today();
                accToUpd.add(acc);
            } else if(!Utilities.filter(accIdXCnt.get(idAcc), 'Contitolarita_Dati_TXT__c', 'SI').isEmpty()){
                Account acc = accMap.get((Id)idAcc);
                acc.Contitolarita_dati_TXT__c = 'SI';
                acc.Data_Contitolarita_dati_TXT__c = System.Today();
                accToUpd.add(acc);
            } 
        }

        System.debug('@@@ accToUpd ' + JSON.serialize(accToUpd));
        update accToUpd;
    }
}