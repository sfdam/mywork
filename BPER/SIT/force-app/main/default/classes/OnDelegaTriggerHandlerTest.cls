@isTest
public class OnDelegaTriggerHandlerTest {
    
    @testSetup static void methodNameSetUp() {
        Profile profile = [SELECT id FROM Profile WHERE  Name =  'NEC_A.1' LIMIT 1];  //delegato
        User NECF1 = AllDataFactory.getUser('14', profile.Id, 'CORPORATE');
        NECF1.FederationIdentifier = '14';
        NECF1.abi__c='01015';
        NECF1.Profilo__c='NEC_A.1';
        insert NECF1;

        profile = [SELECT id FROM Profile WHERE  Name =: Label.System_Administrator LIMIT 1];//delegante
        User NECF2 = AllDataFactory.getUser('13', profile.Id, 'CORPORATE');
        NECF2.FederationIdentifier = '13';
        NECF2.Profilo__c = 'NEC_D.0';
        insert NECF2;
        
	}
    
    //Classe di test senza delega attiva
    @isTest
	public static void handleBeforeInsertTestOk(){
        
        Date dataInizio = date.today();
        Date dataFine = date.today().addDays(7);
       	
        User userDelegato = [SELECT id FROM User WHERE FederationIdentifier='14' LIMIT 1 ];  //delegato
        User userDelegante = [SELECT id FROM User WHERE FederationIdentifier='13' LIMIT 1]; //delegante

        Test.startTest();
        System.runAs(userDelegante){
        Delega__c delega = new Delega__c(StartDate__c = dataInizio, 
                                             EndDate__c = dataFine, 
                                             Delegato__c = userDelegato.id, 
                                             Delegante__c = userDelegante.id);
        insert delega;
        }
        Test.stopTest();
        //Assert
        Delega__c del= [SELECT id,Delegante__c,Delegato__c FROM Delega__c where Delegato__c=:userDelegato.id];
       	System.assert(del.Delegato__c==userDelegato.id);
        System.assert(del.Delegante__c==userDelegante.id);
    }
    
    //classe di test che senza delega attiva
    @isTest
	public static void handleBeforeInsertTestErrore(){
        
        Date dataInizio = date.today();
        Date dataFine = date.today().addDays(7);
       
        User userDelegato = [SELECT id FROM User WHERE FederationIdentifier='14' LIMIT 1 ];  //delegato
        User userDelegante = [SELECT id FROM User WHERE FederationIdentifier='13' LIMIT 1]; //delegante

        //Inserisco delega
        Test.startTest();
        System.runAs(userDelegante){
        Delega__c delega = new Delega__c(StartDate__c = dataInizio, 
                                             EndDate__c = dataFine, 
                                             Delegato__c = userDelegato.id, 
                                             Delegante__c = userDelegante.id);
        insert delega;
        }

        Delega__c delega = new Delega__c(StartDate__c = dataInizio, 
                                         EndDate__c = dataFine, 
                                         Delegato__c = userDelegato.id, 
                                         Delegante__c = userDelegante.id);
        List<Delega__c> listaD =new List<Delega__c>();
        listaD.add(delega);
        
        Database.SaveResult [] result = Database.insert(listaD,false);  
        
        Test.stopTest();
        System.assert(result[0].getErrors().size() > 0);    
    }

     //classe di test che senza delega attiva test2
    @isTest
	public static void handleBeforeInsertTestErrore2(){
        

        Date dataInizioEsistente = date.today();
        Date dataFineEsistente = date.today()+5;
       
        User userDelegato = [SELECT id FROM User WHERE FederationIdentifier='14' LIMIT 1 ];  //delegato
        User userDelegante = [SELECT id FROM User WHERE FederationIdentifier='13' LIMIT 1]; //delegante

        //Inserisco delega
        Test.startTest();
        System.runAs(userDelegante){
        Delega__c delega = new Delega__c(StartDate__c = dataInizioEsistente, 
                                             EndDate__c = dataFineEsistente, 
                                             Delegato__c = userDelegato.id, 
                                             Delegante__c = userDelegante.id);
        insert delega;
        }

        Date dataInizio = date.today();
        Date dataFine = date.today().addDays(7);

        Delega__c delega = new Delega__c(StartDate__c = dataInizio, 
                                         EndDate__c = dataFine, 
                                         Delegato__c = userDelegato.id, 
                                         Delegante__c = userDelegante.id);
        List<Delega__c> listaD =new List<Delega__c>();
        listaD.add(delega);
        
        Database.SaveResult [] result = Database.insert(listaD,false);  
        
        Test.stopTest();
        System.assert(result[0].getErrors().size() > 0);    
    }

    @isTest
	public static void handleCancell(){
        
        Date dataInizio = date.today();
        Date dataFine = date.today().addDays(7);
       	
        User userDelegato = [SELECT id FROM User WHERE FederationIdentifier='14' LIMIT 1 ];  //delegato
        User userDelegante = [SELECT id FROM User WHERE FederationIdentifier='13' LIMIT 1]; //delegante

        Test.startTest();
        Delega__c delega = new Delega__c(StartDate__c = dataInizio, 
                                             EndDate__c = dataFine, 
                                             Delegato__c = userDelegato.id, 
                                             Delegante__c = userDelegante.id);
        System.runAs(userDelegante){
        insert delega;
        delega.Cancelled__c = true;
        update delega;
        }
        Test.stopTest();
    }
}