@isTest
public with sharing class WGC_AttivitaOdierneControllerTest {
    
    @isTest
    public static void testInit(){
        Object response = WGC_AttivitaOdierneController.init();
        List<AggregateResult> responseAgg = WGC_AttivitaOdierneController.getPieChartValues();
    }
}