public class OnRiportafogliazioneTriggerHandler {
    public static void populateLookup(List<Riportafogliazione__c> newRecords, Map<Id,Riportafogliazione__c> oldMap, String operation){
        Set<String> ndwSet = new Set<String>();
        Set<String> IdCedSet = new Set<String>();
        Set<String> walletSet = new Set<String>();

        if(operation.equals('Insert')){
            for(Riportafogliazione__c obj:newRecords){

                ndwSet.add(obj.ABI__c+'_'+obj.NDG__c);
                IdCedSet.add(obj.ABI__c+obj.Id_Ced_Di_Partenza__c);
                IdCedSet.add(obj.ABI__c+obj.Id_Ced_Di_Destinazione__c);
                walletSet.add(obj.Portafoglio_Di_Partenza__c);
                walletSet.add(obj.Portafoglio_Di_Destinazione__c);
            }
        }
        else if(operation.equals('Update')){
            for(Riportafogliazione__c obj:newRecords){
                if(obj.Id_Ced_Di_Partenza__c!=oldMap.get(obj.Id).Id_Ced_Di_Partenza__c 
                    || obj.Id_Ced_Di_Destinazione__c!=oldMap.get(obj.Id).Id_Ced_Di_Destinazione__c
                    ||obj.Portafoglio_Di_Partenza__c!=oldMap.get(obj.Id).Portafoglio_Di_Partenza__c
                    ||obj.Portafoglio_Di_Destinazione__c!=oldMap.get(obj.Id).Portafoglio_Di_Destinazione__c){
                    ndwSet.add(obj.ABI__c+'_'+obj.NDG__c);
                    IdCedSet.add(obj.ABI__c+obj.Id_Ced_Di_Partenza__c);
                    IdCedSet.add(obj.ABI__c+obj.Id_Ced_Di_Destinazione__c);
                    walletSet.add(obj.Portafoglio_Di_Partenza__c);
                    walletSet.add(obj.Portafoglio_Di_Destinazione__c);
                }
                
            }
        }

        Map<String,SObject> ndgMap= SV_Utilities.keyBy([SELECT Id, NDW_ExternalId__c FROM Account WHERE NDW_ExternalId__c IN:ndwSet ], 'NDW_ExternalId__c');
        Map<String,SObject> filialiMap= SV_Utilities.keyBy([SELECT Id, PTF_ABICED__c, PTF_Banca__c, PTF_DirezioneRegionale__c, PTF_Area__c FROM Account WHERE PTF_ABICED__c IN:IdCedSet AND RecordType.DeveloperName='FilialeDiRelazione' ], 'PTF_ABICED__c');
        Map<String,SObject> walletMap= SV_Utilities.keyBy([SELECT Id, Name FROM Wallet__c WHERE Name IN:walletSet ], 'Name');
        for(Riportafogliazione__c obj:newRecords){
            if(ndgMap.containsKey(obj.ABI__c+'_'+obj.NDG__c)){
                obj.NDGId__c=(Id) ndgMap.get(obj.ABI__c+'_'+obj.NDG__c).get('Id');
            }
            if(filialiMap.containsKey(obj.ABI__c+obj.Id_Ced_Di_Partenza__c)){
                obj.Filiale_Old__c=(Id) filialiMap.get(obj.ABI__c+obj.Id_Ced_Di_Partenza__c).get('Id');
                obj.Banca__c=(Id) filialiMap.get(obj.ABI__c+obj.Id_Ced_Di_Partenza__c).get('PTF_Banca__c');
                obj.Direzione_Regionale__c=(Id) filialiMap.get(obj.ABI__c+obj.Id_Ced_Di_Partenza__c).get('PTF_DirezioneRegionale__c');
                obj.Area__c=(Id) filialiMap.get(obj.ABI__c+obj.Id_Ced_Di_Partenza__c).get('PTF_Area__c');
            }
            if(filialiMap.containsKey(obj.ABI__c+obj.Id_Ced_Di_Destinazione__c)){
                obj.Filiale_New__c=(Id) filialiMap.get(obj.ABI__c+obj.Id_Ced_Di_Destinazione__c).get('Id');
            }
            if(walletMap.containsKey(obj.Portafoglio_Di_Destinazione__c)){
                obj.Portafoglio_New__c=(Id) walletMap.get(obj.Portafoglio_Di_Destinazione__c).get('Id');
            }
            if(walletMap.containsKey(obj.Portafoglio_Di_Partenza__c)){
                obj.Portafoglio_Old__c=(Id) walletMap.get(obj.Portafoglio_Di_Partenza__c).get('Id');
            }
        }

    }
}