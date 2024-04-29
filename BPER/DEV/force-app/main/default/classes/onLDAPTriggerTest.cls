@isTest
private class onLDAPTriggerTest {
    
    @isTest
    static void StrutturaBancaTest() {
        Struttura_Banca__c sb = new Struttura_Banca__c(Stato__c = 'A');
        Test.startTest();
        	insert sb;
        	update sb;
        Test.stopTest();
    }
    @isTest
    static void LDAPTest() {
        LDAP__c ldap = new LDAP__c(
            idced__c='1234',
            Ruolo_LDAP__c='000',
            Attivo__c = true,
            Matricola__c='U1234'
        );
        LDAP__c ldap2 = new LDAP__c(
            idced__c='1235',
            Attivo__c = true,
            Matricola__c='U1235'
        );
        Test.startTest();
        insert new List<LDAP__c>{ldap,ldap2};
        update new List<LDAP__c>{ldap,ldap2};
        ldap2.Ruolo_LDAP__c='000';
        ldap2.IDCed__c='8400';
        update new List<LDAP__c>{ldap,ldap2};
        Test.stopTest();
    }
}