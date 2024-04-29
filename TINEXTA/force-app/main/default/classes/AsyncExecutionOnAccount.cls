public class AsyncExecutionOnAccount implements Queueable {
/************************************
* Developer       :       Riccardo@TEN
* Create Date     :       01/07/2019
* Name            :       AsyncExecutionOnAccount
* Dependent Class :       CreateSlaveDataFromAccount
                          GenericDao
* Description     :       Updates account fields
                          Creates Slave_Data__c 
************************************/     
    
    private Set<Id> accountMasterIds;   //CREO SET DI MASTERID
    
    
    public AsyncExecutionOnAccount(Set<Id> Id_Master) {
        this.accountMasterIds = Id_Master; //PONGO IL SET DI MASTER ID UGUALE A QUELLO CHE MI è STATO PASSATO
        system.debug('accountMasterIds : in Queueable '+ accountMasterIds);
        
    }
    public void execute(QueueableContext context) {
      List<Account> accRetrieved = [SELECT Id, Name, temp_prog__c, Codice_Unico_Tinexta__c, Escludi_da_Deduplica__c 
                                   FROM Account 
                                   WHERE Id IN :accountMasterIds];   //PRENDO GLI ACCOUNT DESCRITTI DAGLI ID NEL MASTER
        if(accRetrieved.size() > 0 ){
            for(Account acc : accRetrieved){
                
                acc.temp_prog__c = acc.Codice_Unico_Tinexta__c;           //FACCIO MODIFICHE SU ACCOUNT RICEVUTI ASSEGNANDO CODICE UNICO
                acc.Escludi_da_Deduplica__c  = false;          //PONGO CLONE UGUALE A FALSE (NON CLONATO)
                
                }
            
            update accRetrieved;
            
            List<Slave_Data__c> slaveDataRetrieved = [SELECT Id 
                                                      FROM Slave_Data__c 
                                                      WHERE  Account__c IN :accountMasterIds 
                                                      AND Escludi_da_Deduplica__c = false];       //PRENDO LISTA DI SLAVE DATA CORRISPONDENTI AD ACCOUNT PASSATI ALLA FUNZIONE(NON CLONATI)
            System.debug('slaveDataRetrieved'+slaveDataRetrieved);
            if(slaveDataRetrieved.size() == 0){  //SE NE PRENDO QUALCUNO 
                
                List<Account> cloneMasterAcc  = GenericDao.getAllFieldsResultByCondition('Account', 'Id', accountMasterIds);    //PRENDO TUTTI GLI ACCOUNT DI CUI MI SONO PASSATI GLI ID ATTRAVERSO IL SET INIZIALE
                System.debug('cloneMasterAcc'+cloneMasterAcc);
                CreateSlaveDataFromAccount.CreateSlaveData(cloneMasterAcc);
                
            }
        }

    }
    
}