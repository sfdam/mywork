@isTest
public class TestDataFactory {
    
    public static List<Account> createAccounts(Integer numAccts) {
        List<Account> accts = new List<Account>();
        
        for(Integer i=0;i<numAccts;i++) {
            Account a = new Account(Name='Test Account'+i,
                                   Partita_iva__c = '0000000000'+i,
                                   Codice_fiscale__c = '0000000000'+i,                                   
                                   Industry = 'Altro',
                                   Societa_su_CTM__c = 'Innolva',
                                   Censimento_Manuale__c  = true
                                   );
            accts.add(a);
        }
        return accts; 
    }

    public static List<Account> updateAccounts(List<Account> accList) {       
        for(Account acc : accList) {
            acc.Societa_su_CTM__c = 'Infocert';            
        }
        return accList; 
    }
     public static List<Lead> createLeadsCoMark(Integer numLeads) {
                Id rid= [SELECT Id from RecordType where Name = 'CoMark' AND SObjectType = 'Lead' LIMIT 1].Id;

        List<Lead> leads = new List<Lead>();
        for(Integer i=0;i<numLeads;i++) {
            Lead l = new Lead(LastName = 'Test Lead',
                              FirstName = 'Test',
                              RecordTypeId = rid,
                              Company = 'Centidel',
                              Partiva_Iva__c = '00000'+i+'00000', 
                              Codice_Fiscale__c = '00000'+i+'00000',
                              Societa_di_riferimento__c ='CoMark'
                              );
            leads.add(l);
        }
        
        return leads; 
    }
    
    
    
     public static List<Lead> createLeads(Integer numLeads) {
                Id rid= [SELECT Id from RecordType where Name = 'Warrant' AND SObjectType = 'Lead' LIMIT 1].Id;

        List<Lead> leads = new List<Lead>();
        for(Integer i=0;i<numLeads;i++) {
            Lead l = new Lead(LastName = 'Test Lead',
                              FirstName = 'Test',
                              RecordTypeId = rid,
                              Company = 'Centidel',
                              Partiva_Iva__c = '00000'+i+'00000', 
                              Codice_Fiscale__c = '00000'+i+'00000',
                              Societa_di_riferimento__c ='Warrant'
                              );
            leads.add(l);
        }
        
        return leads; 
    }
         
    
    public static List<Lead> createLeadsInnolva(Integer numLeads) {
                Id rid= [SELECT Id from RecordType where Name = 'Innolva' AND SObjectType = 'Lead' LIMIT 1].Id;

        List<Lead> leads = new List<Lead>();
        for(Integer i=0;i<numLeads;i++) {
            Lead l = new Lead(LastName = 'Test Lead',
                              FirstName = 'Test',
                              RecordTypeId = rid,
                              Company = 'Centidel',
                              Partiva_Iva__c = '00000'+i+'00000', 
                              Codice_Fiscale__c = '00000'+i+'00000',
                              Societa_di_riferimento__c ='Innolva'
                              );
            leads.add(l);
        }
        
        return leads; 
    }
    
 public static List<Lead> createWarrantLeads(Integer numLeads, Id rId ) {
        List<Lead> leads = new List<Lead>();
        Account acc= new Account(Name='Test Account',
                                   Partita_iva__c = '00000000001',
                                   Codice_fiscale__c = '00000000001',                                   
                                   Industry = 'Altro',
                                   Societa_su_CTM__c = 'Warrant',
                                 	Censimento_Manuale__c  = true
                                );
             insert acc;
        for(Integer i=0;i<numLeads;i++) {
            Lead l = new Lead(LastName = 'Test Lead',
                              FirstName = 'Test',
                              Company = 'Centidel',
                              Partiva_Iva__c = '00000'+i+'00000', 
                              Codice_Fiscale__c = '00000'+i+'00000',
                              Societa_di_riferimento__c ='Warrant',
                              Status='Nuovo Lead',
                              AccountSegnalatore__c=acc.Id,
                              RecordTypeId = rId,
                              //Data_inserimento_segnalazione__c = system.today()-100,
                              Mail_personale_Warrant__c = 'test@test.com'
                              );
            leads.add(l);
        }
        
        return leads; 
    }
    
       public static List<Filiale__c> createWarrantFiliale(List<Account> aId) {
        List<Filiale__c> filiale = new List<Filiale__c>();
                   Filiale__c f = new Filiale__c(Name = 'Test Filiale',
                            Ricerca_Account__c = aId[0].Id
                              );
            filiale.add(f);
                
        return filiale; 
    }

     public static Lead convertLeads(Lead l) {      
            Database.LeadConvert lc = new database.LeadConvert();
            lc.setLeadId(l.id); 
            LeadStatus convertStatus = [SELECT Id, MasterLabel,ApiName FROM LeadStatus WHERE isConverted=:true LIMIT 1];
            lc.setConvertedStatus('Convertito');

            Database.LeadConvertResult lcr = Database.convertLead(lc);
            System.assert(lcr.isSuccess());

       
        
        return l; 
    }
    
    public static Slave_Data__c getSlave(Account acc) {
       
        
        Slave_Data__c slvList = [SELECT Id,Name, Name__c, Societa_di_riferimento__c, Id_Esterno__c 
                                       FROM Slave_Data__c 
                                       WHERE Account__c=: acc.Id];
        return slvList;
    }

     public static List<Coverage_Team_Member__c> createCoverageTeamMember (List<Account> accList){
         List<Coverage_Team_Member__c> ctmList = new  List<Coverage_Team_Member__c>();
         User usr = new user(UserName = 'Testusr@test.it',
                             Societa__c = 'Infocert',              
                             Alias = 'Test',                   
                             ProfileId = UserInfo.getProfileId(),                          
                            Email='TestIFIS@testorg.com',
            				EmailEncodingKey='UTF-8',
                             LastName='Testing',
                             LanguageLocaleKey='en_US',
                             LocaleSidKey='en_US',
            				TimeZoneSidKey='America/Los_Angeles');
         insert usr;
         
         
         for (Account a : accList){	
         	Coverage_Team_Member__c newctm = new Coverage_Team_Member__c(Account__c = a.Id,
                                                                         User__c= usr.Id );
             ctmList.add(newctm);
     	}
         return ctmList;
     }
    
    public static List<Coverage_Team_Member__c> updateCoverageTeamMember (List<Coverage_Team_Member__c> ctmList){
		Integer rand;
        List <Coverage_Team_Member__c> newList= new List <Coverage_Team_Member__c>();
        User usr = [SELECT Id,Name FROM User WHERE isActive =: true AND Societa__c = 'Infocert' LIMIT 1];
        System.debug('usrList : ' +usr );
        for (Coverage_Team_Member__c ctm : ctmList){
            
            ctm.User__c = usr.Id;
            newList.add(ctm);
        }
        return newList;        
    }

     public static List<Opportunity> createOpportunity(List<Account> accList) {
        List<Opportunity> opps = new List<Opportunity>();
        //Integer count = [SELECT COUNT() FROM RecordType];
        Integer rand;
        Integer i = 0;

        for (Account acc : accList){
            Opportunity newOpp = new Opportunity(AccountId= acc.Id,
                                                 Name = 'Test Opportunity '+i,
                                                 StageName= 'Potenziali',
                                                 CloseDate = Date.today() );
            opps.add(newOpp);                                     
            i++;
        }
        System.debug('RC opps: '+opps);        
        return opps; 
    }
    
    public static List<Task> createTask(List<Account> accList) {
        List<Task> taskList = new List<Task>();
        for (Account acc :accList){
            Task newTask = new Task(WhatId = acc.Id,
                                    Status = 'In corso');
            taskList.add(newTask);           
        }
        return taskList;        
    }
    
    public static List<Event> createEvent(List<Account> accList) {
        List<Event> EventList = new List<Event>();
        for (Account acc :accList){
            Event newEvent = new Event(WhatId = acc.Id,
                                       StartDateTime = Date.today(),
                                       EndDateTime = Date.today()+1);
            EventList.add(newEvent);           
        }
        return EventList;        
    }

    public static User create_User(string TestProfileId) {
        User result = new User(																				
			LastName					= 'Utente Test',										
			CommunityNickname			= 'communitynicknameTest',	 				   			
			Alias						= 'UserTest',																										
			ProfileId					=  TestProfileId,							
		    Email						= 'test@test.com',																											
			Username					= 'test.User@testr.name',						
			EmailEncodingKey			= 'ISO-8859-1',				    
			TimeZoneSidKey				= 'Europe/Rome',						
			LanguageLocaleKey			= 'it',					
			LocaleSidKey				= 'it_IT',	
            Societa__c                  = 'Infocert',
            ManagerId 					= UserInfo.getUserId()
        );
        return result;
    }

    public static Contact create_Contact() {
        Contact result = new Contact(																				
			FirstName='fname',
            LastName = 'lname',
            Email = 'email@gmail.com',
            Phone = '9743800309'					 	
        );
        return result;
    }

    public static List<Account> create_Account() {
        
        List<Account> result = new List<Account> ();
         Account a = new Account( Name = 'TestName',
            Phone = '12345679',
            Partita_iva__c = '10000000000',
            Codice_fiscale__c = '10000000000',                                   
            Industry = 'Altro',
           	Societa_su_CTM__c = 'Innolva',
            Censimento_Manuale__c  = true);
        result.add(a);
        return result;
    }
    

        public static List<Segnalazioni__c> create_segnalazionipartner(List<Account> accList) {
        
        List<Segnalazioni__c> result = new List<Segnalazioni__c> ();
         Segnalazioni__c s = new Segnalazioni__c( Name = 'TestName',
            										Fonte_Segnalatore__c = 'Banca',
            										Stato_Segnalazione_Warrant__c = 'In lavorazione',
            										AccountSegnalatore__c = accList[0].id,                                   
            										Mail_personale_Warrant__c = 'mail@mail.invalid'
           										);
        result.add(s);
        return result;
    }
    
            public static List<Segnalazioni__c> create_segnalazionipartnerLead(Lead leadlist) {
        
        List<Segnalazioni__c> result = new List<Segnalazioni__c> ();
         Segnalazioni__c s = new Segnalazioni__c( Name = 'TestName',
            										Fonte_Segnalatore__c = 'Banca',
            										Stato_Segnalazione_Warrant__c = 'In lavorazione',
            										//AccountSegnalatore__c = accList[0].id,
            										Lead_Di_Riferimento__c = leadlist.id,                                   
            										Mail_personale_Warrant__c = 'mail@mail.invalid'
           										);
        result.add(s);
        return result;
    }
    
    
         public static List<Opportunity> createOpportunityWarrant(List<Account> accList) {
        List<Opportunity> opps = new List<Opportunity>();
        //Integer count = [SELECT COUNT() FROM RecordType];
        Id rid= [SELECT Id from RecordType where Name = 'Warrant' AND SObjectType = 'Opportunity' LIMIT 1].Id;
        Integer rand;
        Integer i = 0;

        for (Account acc : accList){
            Opportunity newOpp = new Opportunity(AccountId= acc.Id,
                                                 Name = 'Test Opportunity '+i,
                                                 StageName= 'Offerta',
                                                 CloseDate = Date.today(),
                                                 RecordTypeId=rid);
            opps.add(newOpp);                                     
            i++;
        }
        System.debug('RC opps: '+opps);        
        return opps; 
    }
}