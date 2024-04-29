public class OnSlaveDataTriggerHandler {

    public static void UpdateFieldsToAccount(String triggerType, List <Slave_Data__c> slaveList){

        Set <Id> accIdFromSlave = new Set<id>();
        for (Slave_Data__c slave : slaveList){
            accIdFromSlave.add(slave.Account__c);        
        }

        Map<String, SObject> associatedAccountMap = Utilities.keyBy([SELECT  Id, Name, Societa_su_Slave__c  
                                                                     FROM Account 
                                                                     WHERE id 
                                                                     IN : accIdFromSlave ], 'Id');

        Map<String, SObject> slaveMap = Utilities.keyBy([SELECT  Id, Societa_di_riferimento__c, Id_Esterno__c, Account__c
                                                                     FROM Slave_Data__c 
                                                                     WHERE Account__c 
                                                                     IN : accIdFromSlave ], 'Id');

        List<sObject> accList = new List<sObject>();
        if(triggerType == 'isUpsert'){

            sObject acc;
            String val;
            String idExt;
            String isNull;

            for (Slave_Data__c slave : slaveList){
                acc = associatedAccountMap.get(slave.Account__c);

                val = '';
                idExt = '';
                // concatenazione società
                // concatenazione id esterno
                for (String key : slaveMap.keySet()){
                    if((String)slaveMap.get(key).get('Account__c') == (String)acc.get('Id')){
                        isNull  = (String)slaveMap.get(key).get('Societa_di_riferimento__c')==null ? '' : (String)slaveMap.get(key).get('Societa_di_riferimento__c');
                        val = val + isNull + ';';
                        
                        isNull  = (String)slaveMap.get(key).get('Id_Esterno__c')==null ? '' : (String)slaveMap.get(key).get('Id_Esterno__c');
                        idExt = idExt + isNull + ';';
                    }
                }

                val = val.removeEnd(';');
                idExt=idExt.removeEnd(';');   

                acc.put('Societa_su_Slave__c', val);
                acc.put('Id_esterni_Slave__c', idExt); 

                if(slave.Codice_Cliente_X3__c != null) acc.put('Codice_Cliente_X3__c', slave.Codice_Cliente_X3__c);
                if(slave.Codice_Cliente_Sixtema__c != null) acc.put('Codice_Cliente_Sixtema__c', slave.Codice_Cliente_Sixtema__c);
                //if(slave.Codice_Cliente_Luxtrust__c != null) acc.put('Codice_Cliente_Luxtrust__c', slave.Codice_Cliente_Luxtrust__c);
                //if(slave.Codice_Cliente_Camerfirma__c != null) acc.put('Codice_Cliente_Camerfirma__c', slave.Codice_Cliente_Camerfirma__c);

                if(val.contains('Sixtema')){
                    acc.put('Censito_Sixtema__c', (Boolean)True); 
                } else {
                    acc.put('Censito_Sixtema__c', (Boolean)False); 
                }

                if(val.contains('Infocert')){
                    acc.put('Censito_InfoCert__c', (Boolean)True); 
                } else {
                    acc.put('Censito_InfoCert__c', (Boolean)False); 
                }

                if(val.contains('Camerfirma')){
                    acc.put('Censito_in_Camerfirma__c', (Boolean)True); 
                } else {
                    acc.put('Censito_in_Camerfirma__c', (Boolean)False); 
                }

                if(val.contains('Luxtrust')){
                    acc.put('Censito_Luxtrust__c', (Boolean)True); 
                } else {
                    acc.put('Censito_Luxtrust__c', (Boolean)False); 
                }

                if(val.contains('Warrant')){
                    acc.put('Censito_Warrant__c', (Boolean)True); 
                } else {
                    acc.put('Censito_Warrant__c', (Boolean)False); 
                } 

                if(val.contains('CoMark')){
                    acc.put('Censito_Comark__c', (Boolean)True); 
                } else {
                    acc.put('Censito_Comark__c', (Boolean)False); 
                }

                if(val.contains('Innolva')){
                    acc.put('Censito_Innolva__c', (Boolean)True); 
                } else {
                    acc.put('Censito_Innolva__c', (Boolean)False); 
                }

                //SM - TEN - REVALUTA
                if(val.contains('ReValuta'))
                    acc.put('Censito_ReValuta__c', (Boolean) true);
                else
                    acc.put('Censito_ReValuta__c', (Boolean) false);

                if(val.contains('Corvallis'))
                    acc.put('Censito_Corvallis__c', (Boolean) true);
                else
                    acc.put('Censito_Corvallis__c', (Boolean) false);

                if(val.contains('Swascan'))
                    acc.put('Censito_Swascan__c', (Boolean) true);
                else
                    acc.put('Censito_Swascan__c', (Boolean) false);

                if(val.contains('Visura'))
                    acc.put('Censito_Visura__c', (Boolean) true);
                else
                    acc.put('Censito_Visura__c', (Boolean) false);

                if(val.contains('Yoroi'))
                    acc.put('Censito_Yoroi__c', (Boolean) true);
                else
                    acc.put('Censito_Yoroi__c', (Boolean) false);

                accList.add(acc);

            }

        } else {

        }

        System.debug('RC before Update Account: ' + accList);
        update accList;

    }



   
                
}