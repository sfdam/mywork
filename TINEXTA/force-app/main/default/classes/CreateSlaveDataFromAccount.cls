public class CreateSlaveDataFromAccount {
/************************************
* Developer       :       Riccardo@TEN
* Create Date     :       01/07/2019
* Name            :       CreateSlaveDataFromAccount
* Dependent Class : 	  
* Description     :       Creates Slave_Data__c 
************************************/ 

    public static void CreateSlaveData(List<Account> accountListToBeCloned){
        
        // Creo uma mappa di tutti i fields disponibili sia su Account che su Slave_Data__c
        Map <String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        String objectName='Account';
        Map<String, Schema.SObjectField> fieldMap = schemaMap.get(ObjectName).getDescribe().fields.getMap();
        
        Map <String, Schema.SObjectType> schemaMapSlave = Schema.getGlobalDescribe();
        String objectNameSlave='Slave_Data__c';
        Map<String, Schema.SObjectField> fieldMapSlave = schemaMapSlave.get(objectNameSlave).getDescribe().fields.getMap();
        
        set<string> AccountIds                  = new set<string>();
        map<string, Account> MapAccount         = new map<string, Account>();
        list<Slave_Data__c> ListSlave           = new list<Slave_Data__c>();
      
        set<string> MasterAccountIds            = new set<string>();
        
        // Ciclo tutte le anagrafiche da clonare      
        for(Account a: accountListToBeCloned){
            // Popolo un set di id da utilizzare come filtro nella query per recuperare i master record
            AccountIds.add(a.id);
            // Popolo la mappa con i dati delle anagrafiche da clonare
            MapAccount.put(a.id,a);
        }
        System.debug('accountListToBeCloned'+accountListToBeCloned);
        
        // Query per recuprerare gli id delle anagrafiche a partire 
        // dall'oggetto Map_Slave__c che la deduplica a correlato ai master
        list<Map_Slave__c> listMapSlave = [ SELECT Name, Account__c, Id_Account__c                                        
                                            FROM Map_Slave__c 
                                            WHERE Name IN:AccountIds ];
        System.debug('listMapSlave'+listMapSlave);

        for(Map_Slave__c m : listMapSlave){
    		System.debug('AK MapAccount: ' + m);
            if(MapAccount.containsKey(m.Name)){
        
                // Creo il nuovo record con i dati dello slave correlato al master
                
                sObject slave = Schema.getGlobalDescribe().get('Slave_Data__c').newSObject();
                sObject acc   = MapAccount.get(m.Id_Account__c);
                
                /* Loop dinamico per popolare campi Slave */
                               
                for(String x : fieldMapSlave.keySet()){
                    System.debug('RC string x:'+x +'---'+fieldMapSlave.get(x).getDescribe().isAccessible() + '---' + fieldMapSlave.get(x).getDescribe().isUpdateable());
                    
                    Boolean containsA = fieldMap.containsKey(x.replace('__c', '').replace('_', ''));
                    Boolean containsB = fieldMap.containsKey(x);
                    
                    if(containsB && fieldMapSlave.get(x).getDescribe().isAccessible()){
                        // Campi che hanno stessa api name (WITH __c)
                        // if(x == 'Name'){
                        //     //slave.put(x,  acc.get('Name'));
                        //     System.debug('SV NAME AUTOPOPOLATO');
                        // } else {
                        //     if(x != 'isdeleted'){
                        //         slave.put(x, acc.get(x));   

                        //     }
                        // }
                        if(x.contains('__c')){
                            if(x == 'Rating__c'){
                                slave.put(x, acc.get('Rating'));
                            } else {
                                slave.put(x, acc.get(x));
                            }
                        }

                        System.debug('SV containsB: ' + x +'---'+fieldMapSlave.get(x).getDescribe().isAccessible() + '---' + fieldMapSlave.get(x).getDescribe().isUpdateable());
                        
                    } else if (containsA && fieldMapSlave.get(x).getDescribe().isAccessible()){
                        // Campi che hanno stessa api name (WITHOUT __c AND _)
                        System.debug('Ak x: ' + x);

                        slave.put(x, acc.get(x.replace('__c', '').replace('_', '')));
                        System.debug('Ak containsA: ' + x + ' ' + x.replace('__c', '').replace('_', '') + ' ' + acc.get(x.replace('__c', '').replace('_', '')));
                        
                    } else if(fieldMapSlave.get(x).getDescribe().isAccessible()) {
                        // Campi che non hanno stessa api name
                        System.debug('Ak NOT A AND NOT B: ' + x);
                        if(x == 'Id_Account__c'){
                            slave.put(x, m.Account__c);
                        }
                        if(x == 'Account__c'){
                            slave.put(x, m.Account__c);
                        }
                        if(x == 'RatingC__c'){
                            slave.put(x, acc.get('Rating__c'));
                        }
                    }
                }
        
                /* Loop dinamico per popolare campi Slave */        
        
                ListSlave.add((Slave_Data__c)slave);
                MasterAccountIds.add(m.Account__c);
      
            }
    
        }
       System.debug('AK LIST: Before ' + ListSlave);
        if(ListSlave.size()>0){      
           // inserisco i dati degli slave
            insert ListSlave;
            System.debug('AK LIST: ' + ListSlave[0].Id);
            System.debug('AK LIST: ' + ListSlave);
        }
      
    }
}