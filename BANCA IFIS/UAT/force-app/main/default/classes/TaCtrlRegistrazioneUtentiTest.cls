@isTest
private class TaCtrlRegistrazioneUtentiTest {
    
    @testSetup
    public static void setupData() {
        Funzionalita__c f = Funzionalita__c.getInstance();
        f.DisabilitaControlloCambioFaseOpp__c = true;
        f.DisabilitaNamingAutomaticaOpportunita__c = true;
        f.WGC_disabilita_per_batch__c = true; //adione-crm20
        upsert f;
        WGC_AllDataFactory.createUtenzaDefault();
        Account a = TestUtils.creaAccount('AccountTest');
        insert new Prodotto__c(CodiceUnivoco__c = 'ATDTiAnticipo');
        Cessione__c[] cessioni = new Cessione__c[] {};
            for (Integer i = 0; i < 5; i++) {
                cessioni.add(new Cessione__c(Name = 'test', Account__c = a.Id));
            }
        insert cessioni;
    }
    
    @isTest
    static void testFetchContacts() {
        try {
            TaCtrlRegistrazioneUtenti.fetchContacts();
        } catch (Exception e) {}
    }
    
    @isTest
    static void testAddContactAllegato () {
        Contact c = new Contact(FirstName = 'Paolo', LastName = 'Rossi');
        
        ContentVersion cv = new ContentVersion(Title = 'test', ContentURL = 'http://www.google.com/');
        insert cv;
        
        TaCtrlRegistrazioneUtenti.addContactAllegato(JSON.serialize(c), cv.Id);
    }
    
    @isTest
    static void testModifyContactAllegato() {
        Contact c = new Contact(FirstName = 'Paolo', LastName = 'Rossi');
        insert c;
        
        ContentVersion cv = new ContentVersion(Title = 'test', ContentURL = 'http://www.google.com/');
        insert cv;
        Cessione__c cessione = [SELECT Id, Account__c FROM Cessione__c LIMIT 1];
        TaCtrlRegistrazioneUtenti.modifyContactAllegato(JSON.serialize(c), cv.Id, cessione.id);
        
        c.CF__c='RSSPLA81A01G224W';
        c.Birthdate = Date.newInstance(1981, 1, 1);
        c.Sesso__c = 'M';
        c.LuogoNascita__c = 'PADOVA';
        c.ProvinciaNascita__c = 'PD';
        c.CodCatastaleLocNascita__c = 'G224';
        
        upsert c;
        TaCtrlRegistrazioneUtenti.modifyContactAllegato(JSON.serialize(c), cv.Id, cessione.id);
    }
    
    @IsTest
    static void testRemoveContact() {
        Contact c = new Contact(FirstName = 'Paolo', LastName = 'Rossi');
        insert c;
        TaCtrlRegistrazioneUtenti.removeContact(c.Id);
    }
    
    
    @isTest
    static void testAggiungiAttore () {
        Cessione__c cessione = [SELECT Id, Account__c FROM Cessione__c LIMIT 1];
        Contact c = new Contact(FirstName = 'Paolo', LastName = 'Rossi', AccountId = cessione.Account__c);
        insert c;
        
        TaCtrlRegistrazioneUtenti.aggiungiAttore(cessione.Id, c.Id, 'Titolare effettivo adeguata verifica');
    }
    
    @isTest
    static void testfetchAttoriCessione() {
        Cessione__c c = [SELECT Id, Account__c FROM Cessione__c LIMIT 1];
        NDGLinea__c l = new NDGLinea__c(
            Tipo__c = 'Esecutore adeguata verifica',
            Cessione__c = c.Id,
            Account__c = c.Account__c
        );
        
        TaCtrlRegistrazioneUtenti.fetchAttoriCessione(c.Id);
    }
    
    @isTest
    static void testrimuoviAttore() {
        Cessione__c cessione = [SELECT Id FROM Cessione__c LIMIT 1];
        Contact c = new Contact(FirstName = 'Paolo', LastName = 'Rossi');
        insert c;
        
        TaCtrlRegistrazioneUtenti.rimuoviAttore(cessione.Id, c.Id, 'Titolare effettivo adeguata verifica');
    }  
 
    @Istest
    static void testQueableAllegato() {
        Contact c = new Contact(FirstName = 'Paolo', LastName = 'Rossi');
        insert c;          
        ContentVersion cv = new ContentVersion(Title = 'test', ContentURL = 'http://www.google.com/');
        insert cv;        
        TaCtrlRegistrazioneUtenti.QueableAllegato qa = new TaCtrlRegistrazioneUtenti.QueableAllegato(c, cv.Id);
        qa.execute(null);
    }
    
}