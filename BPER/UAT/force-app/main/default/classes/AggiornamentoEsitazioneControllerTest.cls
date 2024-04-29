/**
 * @description       : 
 * @author            : simone.viglianti@tengroup.it
 * @group             : 
 * @last modified on  : 10-28-2021
 * @last modified by  : simone.viglianti@tengroup.it
**/
@isTest
public class AggiornamentoEsitazioneControllerTest {
    @TestSetup
    static void setup(){
        Endpoint__c endPoint = new Endpoint__c();
        endPoint.Name = 'salvaEsitazioneAzioniNec';
        endPoint.Method__c = 'POST';
        endPoint.Timeout__c = 120000;
        endPoint.Endpoint__c = 'https://apigw-test.bper.it:443/gateway/CrmAPI/v1/crm/salva-esitazione-azioni-nec';
        insert endPoint;

        Opportunity opp = new Opportunity();
        opp.Name = 'Test';
        opp.CloseDate = Date.today();
        opp.StageName = 'Qualification';
        insert opp;
    }

    @isTest
    public static void getPicklistValueTest(){
        String objApiName = 'Opportunity';
        String fieldName = 'StageName';

        Test.startTest();
        List<Map<String,String>> output = AggiornamentoEsitazioneController.getPickListValues(objApiName, fieldName);
        Test.stopTest();
        System.debug('output ' + output);
        System.assertEquals('Qualification',output[0].get('label'));
        System.assertEquals('Qualification',output[0].get('value'));
    }

    @isTest
    public static void getFieldNameTest(){
        String objApiName = 'Opportunity';
        String note = 'Description';
        String stato = 'StageName';

        Test.startTest();
        Map<String,String> output = AggiornamentoEsitazioneController.getFieldName(objApiName, stato, note);
        Test.stopTest();
        System.assertEquals('Stage', output.get('stato'));
        System.assertEquals('Description', output.get('note'));
        
    }

    @isTest
    public static void updateRecordTest(){
        Opportunity opp = [SELECT Id, StageName, Description FROM Opportunity LIMIT 1];
        String stato = 'StageName';
        String note = 'Description';
        String selectedOption = 'Needs Analysis';
        String noteValue= 'test';
        String oggetto = 'Opportunity';
        String apiRequestName = 'salvaEsitazioneAzioniNec';
        String certificationName = 'salesforceprodclient2024';
        Boolean disableLog = false;
        String runAsUserId = null;
        String dataFineAzione = String.valueOf(Date.today().addDays(30));
        String jsonParam = '{"statoAzione" : "StageName" , "nota" : "Description", "banca" : "PTF_ABICED__c", "ndg" : "CRM_FormulaAccountNDG__c", "codiceAzione" : "CodiceAzione__c", "codiceAzioneUtente" : "CodiceAzioneUtente__c", "motivo" : "CRM_Motivo__c", "nomeAzione" : "", "esito" : "CRM_Esito__c", "matricolaAutore" : "MatricolaAutore__c", "matricolaReferente" : "MatricolaReferente__c", "autore" : "Autore__c", "referente" : "CRM_Referente__c", "unitaOrganizzativa" : "UnitaOrganizzativa__c", "mds" : "DescrizioneMds__c"}';

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse());
        AggiornamentoEsitazioneController.updateRecord(opp.Id, stato, note, selectedOption, noteValue, oggetto,apiRequestName,certificationName,disableLog,runAsUserId,jsonParam);
        Test.stopTest();
        Opportunity opp1 = [SELECT Id, StageName, Description FROM Opportunity LIMIT 1];
        System.assertEquals('Needs Analysis', opp1.StageName);
    }
}