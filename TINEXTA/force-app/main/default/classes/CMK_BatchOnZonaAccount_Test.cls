@isTest
private class CMK_BatchOnZonaAccount_Test {
    
    static testmethod void test() {  
        

		User testUser2 = [select name,id from user where name = 'Nicola Gotti'];
        User testUser = [select name,id from user where name = 'Thea Sicilia'];
        
        
        
        Zona_CoMark__c testZona = new Zona_CoMark__c(Agente_Mandatario_CoMark__c = testUser.Id,
                                                     CAP_CoMark__c = '38123',
                                                     Comune_CoMark__c = 'TRENTO',
                                                     Name = 'TestZona');
        System.runAs(testUser2) {
        insert testZona;
        }
        
        List<Account> accounts = TestDataFactory.createAccounts(1);
        accounts[0].CAP_Sede_Operativa_comark__c = '38123';
        accounts[0].agentezona_comark__c = testUser2.Id;
        accounts[0].zona_comark__c = testZona.Id;
        accounts[0].Citta_Sede_Operativa_comark__c='TRENTO';
        System.runAs(testUser2) {
        insert accounts;
        }
        // find the account just inserted. add contact for each

       
        Sedi__c SedeNew = new Sedi__c(Account__c = accounts[0].id,
                                    CAP__c = '38123',
                                    Citta__c='TRENTO',
                                    Tipo_indirizzo__c = 'Sede Operativa'
                                     );
		System.runAs(testUser2) {
        insert SedeNew;
        }
        
        testZona.Agente_Mandatario_CoMark__c =testUser2.Id;
        System.runAs(testUser2) {
        update testZona;
        }
		
        

        Test.startTest();
        CMK_BatchOnZonaAccount bza = new CMK_BatchOnZonaAccount();
        Id batchId = Database.executeBatch(bza);
        Test.stopTest();
        // after the testing stops, assert records were updated properly
        
    }
    
}