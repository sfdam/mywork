/****
 * Name			:	Batch_SpostaInResiduale
 * Create Date	:	2021-03-11
 * Author 		:	Giorgio Bonifazi @TEN
 ****/

@isTest
public  class Batch_SpostaInResidualeTest {

    @TestSetup
    public static void setup(){


        Date tmpDate = Date.today().addDays(-90);

        Account filiale = AllDataFactory.getAccount('01', 'FilialeDiRelazione');
        filiale.PTF_BranchTypology__c = 'A';
        insert filiale;

        Wallet__c wal1=AllDataFactory.getWallet('MicroWallet',  filiale.Id, 'Residuale');

        insert wal1;

        Wallet__c wal2=AllDataFactory.getWallet('MicroWallet',  filiale.Id, 'CORPORATE');

        insert wal2;
        Account acc1 = AllDataFactory.getAccount('01', 'PersonAccount');
        acc1.PTF_DeactivationDate__c = tmpDate;
        acc1.PTF_StatoCRM__c ='EST';
        acc1.ModelloDiServizio__c = 'Personal';
        acc1.PTF_Portafoglio__c = wal2.id;
        acc1.PTF_Filiale__c = filiale.Id;
        insert acc1;

        Account acc2 = AllDataFactory.getAccount('01', 'IndustriesBusiness');
        acc2.PTF_DeactivationDate__c = tmpDate;
        acc2.PTF_StatoCRM__c ='NATT';
        acc2.ModelloDiServizio__c = 'Private';
        acc1.PTF_Portafoglio__c = wal2.id;
        acc1.PTF_Filiale__c = filiale.Id;
        insert acc2;

        Account acc3 = AllDataFactory.getAccount('01', 'IndustriesBusiness');
        acc3.PTF_DeactivationDate__c = tmpDate;
        acc3.PTF_StatoCRM__c ='NATT';
        acc3.ModelloDiServizio__c = 'Consulenti Finanziari';
        acc1.PTF_Portafoglio__c = wal2.id;
        acc1.PTF_Filiale__c = filiale.Id;
        insert acc3;

        WorkOrder workOrder1 = new WorkOrder();
        workOrder1.accountid=acc1.id;
        workOrder1.Status='Pending';
        insert workOrder1;
        WorkOrder workOrder2 = new WorkOrder();
        workOrder2.accountid=acc2.id;
        workOrder2.Status='Pending';
        insert workOrder2;
        WorkOrder workOrder3 = new WorkOrder();
        workOrder3.accountid=acc3.id;
        workOrder3.Status='Pending';
        insert workOrder3;

        
    }

    @isTest
    public static void testExecute(){
        
        Test.startTest();
        Database.executeBatch(new Batch_SpostaInResiduale(),200);
        Test.StopTest();
        
    }

    
    
    
}