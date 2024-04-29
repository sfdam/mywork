@isTest
private class TaCtrlTestiTest {
    
    @TestSetup
    public static void setup() {
        List<TestiTa__c> testi = new List<TestiTa__c>();
        
        testi.add(new TestiTa__c(Titolo__c='Titolo1',Testo__c = 'Testo1', Tipo__c=TaCtrlTesti.TIPO_FAQ,Ordinamento__c=1));
        testi.add(new TestiTa__c(Titolo__c='Titolo2',Testo__c = 'Testo2', Tipo__c=TaCtrlTesti.TIPO_FAQ,Ordinamento__c=2));
        testi.add(new TestiTa__c(Titolo__c='Titolo3',Testo__c = 'Testo3', Tipo__c=TaCtrlTesti.TIPO_AREACLIENTI,Ordinamento__c=3));
        insert testi;
    }
    
    @isTest static void testCaricaFaq() {
        Test.startTest();
        List<TestiTa__c> testi = TaCtrlTesti.fetchFAQ();
        Test.stopTest();
        
        System.assertEquals(3, testi.size());
        System.assertEquals('Titolo2', testi[1].Titolo__c);
    }
    
    @isTest static void testCaricaTipo() {
        Test.startTest();
        List<TestiTa__c> testi = TaCtrlTesti.fetchTesti(new List<String> {TaCtrlTesti.TIPO_AREACLIENTI});
        Test.stopTest();
        
        System.assertEquals(1, testi.size());
        System.assertEquals('Titolo3', testi[0].Titolo__c);
    }
    
}