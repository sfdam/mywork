@isTest
public class WGC_PC_CartCreditoDataTracker_Test {

    @TestSetup
    public static void setupData(){
        WGC_AllDataFactory.createUtenzaDefault();

        List<Opportunity> oppList = WGC_AllDataFactory.createOpportunity2(1);
        Insert oppList;
        List<Prodotto__c> prodsProc = WGC_AllDataFactory.createProdotti(1, false);
        prodsProc[0].CodiceUnivoco__c = 'ProceduraConcorsuale';
        Insert prodsProc;
        Linea__c lin = new Linea__c(Opportunity__c = oppList[0].Id, Prodotto__c = prodsProc[0].Id);
        Insert lin;
        List<Credito__c> crediti = WGC_AllDataFactory.createCrediti(1, oppList[0].Id, lin.Id);
        Insert crediti;
        List<NDGLinea__c> attList = WGC_AllDataFactory.createAttori2(1, false);
        attList[0].Account__c = WGC_PC_CartController.idAde;
        attList[0].Opportunita__c = oppList[0].Id;
        Insert attList;
    }

    @isTest
    public static void test1(){
        Credito__c c = [SELECT Id, Name FROM Credito__c LIMIT 1];
		//A.M. Aggiunta opportunità per cambio firma
		Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
        Test.startTest();
        List<WGC_PC_CartCreditoDataTracker__mdt> metadati = WGC_PC_CartCreditoDataTrackerController.getMetadata();
        WGC_Valore_IRR__mdt valoriIrr = WGC_PC_CartCreditoDataTrackerController.getValoriIRR(opp.Id);
        WGC_PC_CartCreditoDataTrackerController.WrapperResponse response = new WGC_PC_CartCreditoDataTrackerController.WrapperResponse();
        response = WGC_PC_CartCreditoDataTrackerController.saveCredito(JSON.serialize(c));
        response = WGC_PC_CartCreditoDataTrackerController.saveCredito(null);
        Test.stopTest();
    }
}