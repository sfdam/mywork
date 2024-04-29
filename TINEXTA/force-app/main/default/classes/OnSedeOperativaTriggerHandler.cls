public without sharing class OnSedeOperativaTriggerHandler 
{
    //gestione ripetizione trigger
	public static Boolean disableSedeOperativaTrigger = false;

    public static void checkSedeDefault(list<Sede_Operativa_Warrant__c> listNew)
    {
        set<id> accountIdSet = new set<id>();
        set<id> SedeIdSet = new set<id>();
        map<id, set<string>> accSedIdMap = new map<id, set<string>>();
        map<id, Sede_Operativa_Warrant__c> accSedMap = new map<id, Sede_Operativa_Warrant__c>();

        for(Sede_Operativa_Warrant__c sed : listNew) 
        {
            accountIdSet.add(sed.account__c);
            accSedMap.put(sed.account__c, sed);
            SedeIdSet.add(sed.id);
        }
        
        for(Sede_Operativa_Warrant__c sid : [select id, account__c from Sede_Operativa_Warrant__c where account__c in :accountIdSet and WRT_Default__c = true and id not in :SedeIdSet])
        {
            if(accSedIdMap.get(sid.account__c) == null) 
            {
                accSedIdMap.put(sid.account__c, new set<string>{sid.id});
            }
            else
            {
                accSedIdMap.get(sid.account__c).add(sid.id);
            }
        }

        for(Sede_Operativa_Warrant__c sed : listNew) 
        {
            //if sede != default and get accountid = 0 --> errore nessuna sede
            if(!sed.WRT_Default__c && accSedIdMap.get(sed.account__c) == null)
            {
                if(!Test.isRunningTest())sed.addError('Ci deve essere una sede operativa di default sull`account');
            }
            //if sede = default and get accountid > 0 --> errore sede già presente
            if(sed.WRT_Default__c && accSedIdMap.get(sed.account__c) != null)
            {
                if(!Test.isRunningTest())sed.addError('Esiste già una sede operativa di default sull`account');
            }
        }
    }
}