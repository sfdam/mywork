@isTest
public class WGC_QbleAggiornaAssegnazioneAnag_Test {
    @isTest
    public static void test_WGC_QbleAggiornaAssegnazioneAnagrafica(){
        WGC_AllDataFactory.createUtenzaDefault();
        List<Account> listAcc = WGC_AllDataFactory.createAccount(1,true);
        List<User> listUSer = [SELECT ID FROM User WHERE Id=: UserInfo.getUserId()];
        Map<Id,AssegnazioneAnagrafica__c> oldmap = new Map<Id,AssegnazioneAnagrafica__c>();
        AssegnazioneAnagrafica__c aa = new AssegnazioneAnagrafica__c(); 
        insert aa;
        oldmap.put(aa.ID,aa);


        Map<Id,AssegnazioneAnagrafica__c> newmap = new Map<Id,AssegnazioneAnagrafica__c>();
        Comune__c c = WGC_AllDataFactory.createComune('PADOVA','PD','35100');
        aa.Comune__c = c.Id;
        update aa;
        newmap.put(aa.ID,aa);
        // WGC_QbleAggiornaAssegnazioneAnagrafica test = new WGC_QbleAggiornaAssegnazioneAnagrafica(oldmap,newmap,listAcc,listUSer);
        WGC_QbleAggiornaAssegnazioneAnagrafica test = new WGC_QbleAggiornaAssegnazioneAnagrafica(listAcc);
        // Test.startTest();
        System.enqueueJob(test);
        // Test.stopTest();
    }

}