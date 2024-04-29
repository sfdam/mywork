public without sharing class HandleIterConfigurationsController {
    public HandleIterConfigurationsController() {

    }

    @AuraEnabled
    public static List<IterConfiguration__c> getIterConfigurations ()
    {
        //nomeUnita = '%'+nomeUnita+'%';
        return [SELECT Id, UnitaOrganizzativa__r.Name, UnitaOrganizzativa__r.PTF_DirezioneRegionale__r.Name, UnitaOrganizzativa__r.RecordType.Name, TipoSpostamento__c, GiorniAnnullamento__c, Abi__c FROM IterConfiguration__c];
    }

    @AuraEnabled
    public static void createIterConfiguration (Account unitaOrganizzativa, String tipoSpostamento, Integer giorniAnnullamento)
    {   
        List<IterConfiguration__c> iterConfigToInsert = new List<IterConfiguration__c>();
        if(unitaOrganizzativa.RecordTypeName__c == 'Filiale di Relazione'){

            iterConfigToInsert.add(new IterConfiguration__c(
                UnitaOrganizzativa__c = unitaOrganizzativa.Id,
                TipoSpostamento__c = tipoSpostamento,
                GiorniAnnullamento__c = giorniAnnullamento
            ));
        }else{
            for(Account filiale : [SELECT Id FROM Account WHERE PTF_DataChiusura__c = NULL AND PTF_DirezioneRegionale__c =: unitaOrganizzativa.Id AND RecordTypeName__c = 'Filiale di Relazione' AND Id NOT IN (SELECT UnitaOrganizzativa__c FROM IterConfiguration__c WHERE TipoSpostamento__c =: tipoSpostamento)]){
                iterConfigToInsert.add(new IterConfiguration__c(
                    UnitaOrganizzativa__c = filiale.Id,
                    TipoSpostamento__c = tipoSpostamento,
                    GiorniAnnullamento__c = giorniAnnullamento
                ));
            }
        }
        insert iterConfigToInsert;
    }

    @AuraEnabled
    public static void saveIterConfigurations (List<IterConfiguration__c> iterConfigs)
    {
        update iterConfigs;
    }

    @AuraEnabled
    public static List<String> getUsedTipiConfigurazione (Account unitaOrganizzativa, Boolean isFiliale)
    {
        List<String> usedTipi = new List<String>();
        Integer countFiliali = 0;
        String unitaOrganizzativaId = unitaOrganizzativa.Id;
        if(!isFiliale){
            List<AggregateResult> result = [SELECT count(Id) FROM Account WHERE PTF_DataChiusura__c = NULL AND PTF_DirezioneRegionale__c =: unitaOrganizzativaId AND RecordTypeName__c = 'Filiale di Relazione'];
            System.debug('DK result: ' + JSON.serialize(result));
            countFiliali = (Integer)result[0].get('expr0');
        }
        System.debug('DK countFiliali: ' + countFiliali);
        String query = 'SELECT TipoSpostamento__c' + (!isFiliale ? ' ,count(UnitaOrganizzativa__c) ' : '') + ' FROM IterConfiguration__c WHERE ' + (isFiliale ? ' UnitaOrganizzativa__c = :unitaOrganizzativaId ' : ' UnitaOrganizzativa__r.PTF_DirezioneRegionale__c = :unitaOrganizzativaId ') + ' GROUP BY TipoSpostamento__c';
        for (AggregateResult iterConfig : Database.query(query))
        {   
            if(isFiliale){
                usedTipi.add((String)iterConfig.get('TipoSpostamento__c'));
            }else{
                System.debug('DK active: ' + (Integer)iterConfig.get('expr0'));
                if(countFiliali <= (Integer)iterConfig.get('expr0')){
                    usedTipi.add((String)iterConfig.get('TipoSpostamento__c'));
                }
            }
        }
        
        return usedTipi;
    }

    @AuraEnabled
    public static void deleteIterConfigurations (List<IterConfiguration__c> iterConfigs)
    {
        delete iterConfigs;
    }
}