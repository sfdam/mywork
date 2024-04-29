@isTest
public class WGC_TrgAssegnazioneAnagrafica_Test {
    
    @isTest
    public static void test_ricalcoloAssegnazioneAnagrafica_New(){
        WGC_AllDataFactory.createUtenzaDefault();
        Id userId = UserInfo.getUserId();
        Comune__c c = WGC_AllDataFactory.createComune('PADOVA','PD','35100');
        AssegnazioneAnagrafica__c aa = new AssegnazioneAnagrafica__c(); 
        insert aa;
        aa.Comune__c = c.Id;
        update aa;
        AssegnazioneAnagrafica__c a = [SELECT Id FROM AssegnazioneAnagrafica__c];
        System.debug('@Stampa: '+a);
    }
}