@IsTest
public with sharing class BloccaSpostamentiFilialeControllerTest {
    
    @TestSetup
    static void makeData(){
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
        insert filiale;
    }

    @IsTest
    static void test(){
        
        String accountId = [SELECT ID FROM Account WHERE RecordTypeName__c = 'Filiale Di Relazione' LIMIT 1].Id;
        Test.startTest();
        Account filiale = BloccaSpostamentiFilialeController.getRecord(accountId);
        BloccaSpostamentiFilialeController.updateRecord(filiale.Id, 'BloccaSpostamentiInFiliale', true);
        Test.stopTest();

        System.assert([SELECT ID, PTF_BloccaSpostamentiInFiliale__c FROM Account WHERE RecordTypeName__c = 'Filiale Di Relazione' LIMIT 1].PTF_BloccaSpostamentiInFiliale__c, 'Update Fallito');
    }
}