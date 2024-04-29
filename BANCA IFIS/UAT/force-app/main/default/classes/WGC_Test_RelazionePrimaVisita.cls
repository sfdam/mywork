@isTest
public class WGC_Test_RelazionePrimaVisita {
	
    @isTest
    public static void Test_SalvaRecord(){
        WGC_AllDataFactory.disattivaTrigger();

        Integer rand = Integer.valueOf(Math.random());
        String myId = UserInfo.getUserId();
        Account acc1 = new Account();
        acc1.Name = 'TestAccount'+rand;
        acc1.WGC_Specialista_Factoring__c = myId;
        insert acc1;

        Integer rand2 = Integer.valueOf(Math.random());
        
        Account acc2 = new Account();
        acc2.Name = 'TestAccount'+rand2;
        acc2.WGC_Specialista_Factoring__c = myId;
        insert acc2;
        
        Opportunity opty = new Opportunity();
        opty.Name = 'TestOpty'+rand;
        opty.AccountId = acc1.Id;
        opty.StageName = 'In Lavorazione';
        opty.CloseDate = Date.today();
        
        insert opty;
        
        RelazionePrimaVisita__c rpv1 = new RelazionePrimaVisita__c();
        rpv1.Account__c =acc1.id;
        rpv1.Opportunita__c=opty.Id;
        insert rpv1;
        RelazionePrimaVisita__c rpv2 = new RelazionePrimaVisita__c();
        rpv2.Account__c =acc1.id;
        rpv2.Opportunita__c=opty.Id;
        insert rpv2;
        
        Test.startTest();
        
       

        WGC_RelazionePrimaVisita.SaveRecord(rpv1);
        WGC_RelazionePrimaVisita.SaveRecord(rpv2);
        WGC_RelazionePrimaVisita.getRPV(acc1.Id);
        WGC_RelazionePrimaVisita.getRPV(acc2.id);

        //RelazionePrimaVisita__c rpvResp = WGC_RelazionePrimaVisita.SaveRecord(rpv);
		        
        Test.stopTest();
    }
}