@isTest
public with sharing class AnnullaIterControllerTest {
    
    @TestSetup
    static void makeData(){

        ServiceModel__c personal = new ServiceModel__c(Name = 'Personal',
        PTF_Division__c = 'PE',
        PTF_MacroDivision__c = 'WM');

        ServiceModel__c family = new ServiceModel__c(Name = 'Family',
        PTF_Division__c = 'PE',
        PTF_MacroDivision__c = 'EB');
        insert new List<ServiceModel__c>{personal, family};
        Account banca = AllDataFactory.getAccount('10', 'Banca');
        banca.FinServ__BankNumber__c = '05387';
        insert banca;
        Account dir = AllDataFactory.getAccount('09', 'DirezioneRegionale');
        dir.FinServ__BankNumber__c = '05387';
        dir.parentId = banca.Id;
        dir.PTF_Banca__c = banca.Id;
        insert dir;
        Account area = AllDataFactory.getAccount('08', 'Area');
        area.FinServ__BankNumber__c = '05387';
        area.parentId = dir.Id;
        area.PTF_Banca__c = banca.Id;
        area.PTF_DirezioneRegionale__c = dir.Id;
        insert area;
        Account filiale = AllDataFactory.getAccount('01', 'FilialeDiRelazione');
        filiale.FinServ__BankNumber__c = '05387';
        filiale.parentId = area.Id;
        filiale.PTF_BranchTypology__c = 'A';
        filiale.PTF_Banca__c = banca.Id;
        filiale.PTF_DirezioneRegionale__c = dir.Id;
        filiale.PTF_Area__c = area.Id;

        Account filiale2 = AllDataFactory.getAccount('30', 'FilialeDiRelazione');
        filiale2.FinServ__BankNumber__c = '05387';
        filiale2.parentId = area.Id;
        filiale2.PTF_BranchTypology__c = 'A';
        filiale2.PTF_Banca__c = banca.Id;
        filiale2.PTF_DirezioneRegionale__c = dir.Id;
        filiale2.PTF_Area__c = area.Id;
        insert new List<Account>{filiale, filiale2};
        Wallet__c microPortafoglioFamily = AllDataFactory.getWallet('MicroWallet',  filiale.Id, 'Family');
        Wallet__c microPortafoglioFamily2 = AllDataFactory.getWallet('MicroWallet',  filiale2.Id, 'Family');
        
        Profile profile = [SELECT id FROM Profile WHERE  Name =: Label.System_Administrator LIMIT 1];
        
        User user = AllDataFactory.getUser('10', profile.Id, 'Personal');
        user.FederationIdentifier='10';
        user.Profilo__c = 'ADMIN';
        insert new List<User>{user};
        
        WorkOrder wo = new WorkOrder(Status = 'pending', Queues__c = 'STEP1(NEC_F.1), STEP2(NEC_T.4, NEC_T.4), STEP3(NEC_A.1)', OriginalOwner__c = user.Id, PTF_Origine__c = microPortafoglioFamily.Id, PTF_Destinazione__c = microPortafoglioFamily2.Id);
        insert wo;
        Contact contact = AllDataFactory.getContact('02', user.Id, filiale.id);


        //TEST 
        Date tmpDate = Date.today().addDays(-90);
        Wallet__c wal2=AllDataFactory.getWallet('MicroWallet',  filiale.Id, 'CORPORATE');
        insert wal2;
        Account acc1 = AllDataFactory.getAccount('01', 'PersonAccount');
        acc1.PTF_DeactivationDate__c = tmpDate;
        acc1.PTF_StatoCRM__c ='NATT';
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
        workOrder1.Queues__c = 'STEP1(NEC_F.1), STEP2(NEC_T.4, NEC_T.4), STEP3(NEC_A.1)';
        insert workOrder1;
        WorkOrder workOrder2 = new WorkOrder();
        workOrder2.accountid=acc2.id;
        workOrder2.Status='Pending';
        workOrder2.Queues__c = 'STEP1(NEC_F.1), STEP2(NEC_T.4, NEC_T.4), STEP3(NEC_A.1)';
        insert workOrder2;
        WorkOrder workOrder3 = new WorkOrder();
        workOrder3.accountid=acc3.id;
        workOrder3.Status='Pending';
        workOrder3.Queues__c = 'STEP1(NEC_F.1), STEP2(NEC_T.4, NEC_T.4), STEP3(NEC_A.1)';
        insert workOrder3;


        System.runAs(user){
            
            insert contact;
        }
    }

    @istest
    static void test() {
        User user = [SELECT id FROm user WHERE FederationIdentifier = '10' LIMIT 1];
        
        System.runAs(user){
            Test.startTest();

            WorkOrder wo = [SELECT id From WorkOrder LIMIT 1];
            Boolean response = AnnullaIterController.init(wo.Id);
            Test.setMock(HttpCalloutMock.class, new MockHttpResponse());
            AnnullaIterController.closeIter(wo.Id, '');
            List <WorkOrder> WorkOrderList= [SELECT Id,Status, PTF_NotaAnnullamento__c  
                                            FROM WorkOrder
                                            WHERE Id =: wo.Id AND Status ='Annullato'AND PTF_NotaAnnullamento__c =''];
            Test.stopTest();
            System.assertEquals(True,response);
            System.assert(WorkOrderList.size() != 0);      
          }
  

    }

    @istest
    static void testCloseIterFromResiduale() {
        User user = [SELECT id FROm user WHERE FederationIdentifier = '10' LIMIT 1];
        Map<String, Object> requestBody = new Map<String, Object>();
        List<String> listIdWorkOrder = new List<String>();
        Test.startTest();
        System.runAs(user){

            List<WorkOrder> wo = [SELECT id FROm WorkOrder ];
            for(WorkOrder i: wo)
                listIdWorkOrder.add(i.id);

            Test.setMock(HttpCalloutMock.class, new MockHttpResponse());
            requestBody=AnnullaIterController.closeIterFromResiduale(listIdWorkOrder);
        }
        Test.stopTest();
        System.assert(requestBody.size()==0);
    }
}