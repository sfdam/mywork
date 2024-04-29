@isTest
public with sharing class indicatoriKPI_Controller_Test {
    @isTest
    static void testGetNdgOFS() {
        Account accNDG = new Account(Name = 'Test Account');
        Boolean result = indicatoriKPI_Controller.getNdgOFS(accNDG.id);    
    }
}