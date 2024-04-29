@isTest
public without sharing class Batch_CheckAnomaliePrimarioCOTest {
    
    @isTest
    public static void testExecute(){
        Database.executeBatch(new Batch_CheckAnomaliePrimarioCO());
    }
}