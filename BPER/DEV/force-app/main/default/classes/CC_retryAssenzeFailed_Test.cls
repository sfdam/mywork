@isTest
public class CC_retryAssenzeFailed_Test {

    public static final string PROFILE_NAME_LIKE = '%Contact Center';
    @isTest
    static void testScheduleBatchJob() {
        
        // Crea dati di esempio per la tua query
        Profile profile = [SELECT id FROM Profile WHERE Name LIKE :PROFILE_NAME_LIKE LIMIT 1];
        User user = AllDataFactory.getUser('01', profile.Id, 'CORPORATE');
        user.CRM_GenesysID__c = 'test';
        user.CRM_BusinessUnitID__c = '123';
        insert user;
        
        CRM_Assenze__c assenza = new CRM_Assenze__c(
            CRM_User__c = user.Id,
            CRM_SyncGenesys__c = false
        );
        insert assenza;
        
        // Imposta il mock del processo batch
        Test.startTest();
        //Test.setMock(Database.BatchableContext.class, new MockBatchableContext());
        
        // Crea un oggetto ScheduleBatchJob
        CC_retryAssenzeFailed job = new CC_retryAssenzeFailed();
        
        // Esegui il metodo execute
        job.execute(null);
        
        Test.stopTest();
        
        // Verifica che il processo batch sia stato avviato correttamente (puoi utilizzare il tuo sistema di logging per ulteriori verifiche)
    }
}