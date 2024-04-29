@isTest
public class DataFactoryNew 
{
    public static Funzionalita__c createCustomSettings() 
    {
        Funzionalita__c im = new Funzionalita__c();
        im.SetupOwnerId = UserInfo.getOrganizationId();
        
        insert im;
        return im;
    }
    public static List<Account> createAccounts(Integer numAccts) 
    {
        List<Account> accts = new List<Account>();
        
        for(Integer i=0;i<numAccts;i++) {
            Account a = new Account(Name='Test Account'+i,
                                   Partita_iva__c = '0000000000'+i,
                                   Codice_fiscale__c = '0000000000'+i,                                   
                                   Industry = 'Altro',
                                   Societa_su_CTM__c = 'Warrant',
                                   Censimento_Manuale__c  = true
                                   );
            accts.add(a);
        }
        insert accts;
        return accts; 
    }
    public static List<Opportunity> createOpportunityWarrant(List<Account> accList) 
    {
        List<Opportunity> opps = new List<Opportunity>();
        //Integer count = [SELECT COUNT() FROM RecordType];
        Id rid= [SELECT Id from RecordType where Name = 'WRT CPQ' AND SObjectType = 'Opportunity' LIMIT 1].Id;
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
        insert opps;
        return opps; 
    }
    public static List<Account> create_Account() 
    {
        
        List<Account> result = new List<Account> ();
         Account a = new Account( Name = 'TestName',
            Phone = '12345679',
            Partita_iva__c = '10000000000',
            Codice_fiscale__c = '10000000000',                                   
            Industry = 'Altro',
           	Societa_su_CTM__c = 'Innolva',
            Censimento_Manuale__c  = true);
        result.add(a);
        
        insert result;
        return result;
    }
    public static User create_User(string TestProfileId) 
    {
        User result = new User(																				
			LastName					= 'Utente Test',										
			CommunityNickname			= 'communitynicknameTest',	 				   			
			Alias						= 'UserTest',																										
			ProfileId					=  TestProfileId,		//UserInfo.getProfileId()					
		    Email						= 'test@test.com',																											
			Username					= 'test.User@testr.name',						
			EmailEncodingKey			= 'ISO-8859-1',				    
			TimeZoneSidKey				= 'Europe/Rome',						
			LanguageLocaleKey			= 'it',					
			LocaleSidKey				= 'it_IT',	
            Societa__c                  = 'Infocert',
            ManagerId 					= UserInfo.getUserId()
        );
        
        insert result;
        return result;
    }
    public static workOrder createWO(account acc, opportunity opp)
    {
        Id rid= [SELECT Id from RecordType where Name = 'Driver' AND SObjectType = 'WorkOrder' LIMIT 1].Id;
		workorder wok = new workorder(
            status = 'New',
            accountid = acc.id,
            WRT_Opportunity__c = opp.id,
            WRT_Automatically_created__c = true,
            RecordTypeId = rid
        	);
        
        insert wok;
        return wok;
    }
    public static Product2 createProductDriver()
    {
        
        Product2 prodotto = new Product2(name = 'FAA - CERTIFICAZIONE PROGETTI R&D - DRIVER - STANDARD',
                                         Nome_Vero__c = 'FAA - CERTIFICAZIONE PROGETTI R&D',
                                         isActive = true,
                                         ProductCode = 'Pr-',
                                         WRT_Product_Type__c = 'Driver',
                                         WRT_Business_Line__c = 'FA AUTOMATICA',
                                         Societ__c = 'WarrantHub',
                                         Cluster_Tagetik__c = 'KNOWLEDGE'
                                        );
        
        insert prodotto;
        return prodotto;
    }
    public static list<PricebookEntry> createPricebookEntry(Product2 prodotti)
    {
        list<PricebookEntry> voci_Listinoprezzi = new list<PricebookEntry>();
        
        // Id pricebookId = Test.getStandardPricebookId();
        Pricebook2 standardPricebook = new Pricebook2(Id = Test.getStandardPricebookId(),IsActive = true);
        update standardPricebook;
        
        PricebookEntry standardPrice = new PricebookEntry(Pricebook2Id = standardPricebook.Id, 
                                                          Product2Id = prodotti.Id,
                                                          UnitPrice = 10000, 
                                                          IsActive = true);
        voci_Listinoprezzi.add(standardPrice);
        
        insert voci_Listinoprezzi;
        return voci_Listinoprezzi;
    }
    public static opportunitylineitem createProdOpp(opportunity opp, Product2 prod)
    {
        opportunitylineitem oppLine = new opportunitylineitem(
            OpportunityId = opp.id,
            Product2id = prod.id,
            quantity = 1,
            unitprice = 1000
        );
        
        insert oppLine;
        return oppLine;
    }
    public static ServiceAppointment createSA(workorder wok)
    {
        ServiceAppointment serv = new ServiceAppointment(
            Subject = 'Test',
            ParentRecordId = wok.Id,
            DueDate = Datetime.valueOf('2050-05-05 02:00:00')
        );
        
        insert serv;
        return serv;
    }
    public static workorderlineitem[] createWoli(workorder wok)
    {
        Id woliRecordTypeId = Schema.SObjectType.WorkOrderLineItem.getRecordTypeInfosbyDeveloperName().get('WRT_Task').getRecordTypeId();
        workorderlineitem[] woliList = new workorderlineitem[]{};
        
        workorderlineitem woli1 = new workorderlineitem(
            Status = 'Nuovo',
            WorkOrderId = wok.id,
            WRT_Work_Order_Status__c = 'New',
            WRT_Required__c = true,
            RecordTypeId = woliRecordTypeId,
            WRT_Record_Type_Name__c = 'Driver',
            WRT_Subject__c = 'ASSIGN ACCOUNTING TEAM'
        );
        woliList.add(woli1);
        
        insert woliList;
        return woliList;
    }
    public static WRT_FSL_Supplier__c[] createSupp()
    {
        //add more supp
        WRT_FSL_Supplier__c[] suppList = new WRT_FSL_Supplier__c[]{};
        Id supRecordTypeId = Schema.SObjectType.WRT_FSL_Supplier__c.getRecordTypeInfosbyDeveloperName().get('SupplierCFG').getRecordTypeId();
        WRT_FSL_Supplier__c supp = new WRT_FSL_Supplier__c(
            WRT_Supplier__c = 'Praxi Bologna',
            WRT_Geographic_Area__c = 'Lombardia|Veneto|Piemonte|Emilia Romagna|Marche|Sardegna|Friuli Venezia Giulia',
            WRT_Calculation_Type__c = 'A',
            WRT_Type__c = 'Iper',
            WRT_Investment_from__c = 0,
            WRT_Investment_to__c = 1000,
            WRT_Amount__c = 3500,
            WRT_Visit_Amount__c = 350,
            WRT_Visits__c = 3
        );
        suppList.add(supp);
        
        WRT_FSL_Supplier__c supp1 = new WRT_FSL_Supplier__c(
            WRT_Supplier__c = 'Dnv',
            WRT_Geographic_Area__c = 'Italia',
            WRT_Calculation_Type__c = 'B',
            WRT_Type__c = 'Iper',
            WRT_Investment_from__c = 0,
            WRT_Investment_to__c = 500000,
            WRT_Amount__c = 2500,
            WRT_Visit_Amount__c = 350,
            WRT_Visits__c = 1,
            WRT_Premiality_of_goods_amount__c = 150,
            WRT_Premiality_of_goods_greater_than__c = 5
        );
        suppList.add(supp1);
        
        WRT_FSL_Supplier__c supp2 = new WRT_FSL_Supplier__c(
            WRT_Supplier__c = 'Fabrizio Fraternali',
            WRT_Geographic_Area__c = 'Italia',
            WRT_Calculation_Type__c = 'D',
            WRT_Type__c = 'Iper',
            WRT_Investment_from__c = 0,
            WRT_Investment_to__c = 1000000,
            WRT_Amount__c = 2500,
            WRT_Visit_Amount__c = 350,
            WRT_Visits__c = 3,
            WRT_Premiality_of_goods_amount__c = 150,
            WRT_Premiality_of_goods_to__c = 2,
            WRT_Premiality_of_goods_from__c = 0
        );
        suppList.add(supp2);
        
        WRT_FSL_Supplier__c supp3 = new WRT_FSL_Supplier__c(
            WRT_Supplier__c = 'Fiaschè',
            WRT_Geographic_Area__c = 'Italia',
            WRT_Calculation_Type__c = 'E',
            WRT_Type__c = 'Iper',
            WRT_Investment_from__c = 0,
            WRT_Investment_to__c = 500000,
            WRT_Amount__c = 2500,
            WRT_Visit_Amount__c = 350,
            WRT_Visits__c = 3,
            WRT_Premiality_of_goods_amount__c = 150,
            WRT_Premiality_of_goods_to__c = 2,
            WRT_Premiality_of_goods_from__c = 0
        );
        suppList.add(supp3);
        
        WRT_FSL_Supplier__c supp4 = new WRT_FSL_Supplier__c(
            WRT_Supplier__c = 'Carlo Buttasi',
            WRT_Geographic_Area__c = 'Italia',
            WRT_Calculation_Type__c = 'F',
            WRT_Type__c = 'Iper',
            WRT_Investment_from__c = 0,
            WRT_Investment_to__c = 500000,
            WRT_Amount__c = 2500,
            WRT_Visit_Amount__c = 350,
            WRT_Visits__c = 3,
            WRT_Premiality_of_goods_amount__c = 150,
            WRT_Premiality_of_goods_to__c = 2,
            WRT_Premiality_of_goods_from__c = 0
        );
        suppList.add(supp4);
        
        WRT_FSL_Supplier__c supp5 = new WRT_FSL_Supplier__c(
            WRT_Supplier__c = 'Fabio Venturini',
            WRT_Geographic_Area__c = 'Italia',
            WRT_Calculation_Type__c = 'G',
            WRT_Type__c = 'Iper',
            WRT_Investment_from__c = 0,
            WRT_Investment_to__c = 500000,
            WRT_Amount__c = 2500,
            WRT_Visit_Amount__c = 350,
            WRT_Visits__c = 3,
            WRT_Premiality_of_goods_amount__c = 150,
            WRT_Premiality_of_goods_to__c = 2,
            WRT_Premiality_of_goods_from__c = 0,
            WRT_Down_Payment__c = 1300,
            WRT_Minimum_Payoff__c = 5000,
            WRT_Payoff__c = 0
        );
        suppList.add(supp5);
        
        WRT_FSL_Supplier__c supp6 = new WRT_FSL_Supplier__c(
            WRT_Supplier__c = 'Lloyds',
            WRT_Geographic_Area__c = 'Italia',
            WRT_Calculation_Type__c = 'H',
            WRT_Type__c = 'Iper',
            WRT_Investment_from__c = 0,
            WRT_Investment_to__c = 500000,
            WRT_Amount__c = 2500,
            WRT_Visit_Amount__c = 350,
            WRT_Visits__c = 3,
            WRT_Premiality_of_goods_amount__c = 150,
            WRT_Premiality_of_goods_to__c = 2,
            WRT_Premiality_of_goods_from__c = 0
        );
        suppList.add(supp6);
        
        WRT_FSL_Supplier__c supp7 = new WRT_FSL_Supplier__c(
            WRT_Supplier__c = 'Interni Iper',
            WRT_Geographic_Area__c = 'Italia',
            WRT_Calculation_Type__c = 'I',
            WRT_Type__c = 'Iper',
            WRT_Investment_from__c = 0,
            WRT_Investment_to__c = 500000,
            WRT_Amount__c = 2500,
            WRT_Visit_Amount__c = 350,
            WRT_Visits__c = 3,
            WRT_Premiality_of_goods_amount__c = 150,
            WRT_Premiality_of_goods_to__c = 2,
            WRT_Premiality_of_goods_from__c = 0
        );
        suppList.add(supp7);
        
        insert suppList;
        return suppList;
    }
    public static Sede_Operativa_Warrant__c createSedeOperativa(account acc)
    {
        Sede_Operativa_Warrant__c sed = new Sede_Operativa_Warrant__c(
            name = 'Sede Operativa di Test',
            Account__c = acc.id,
            City__c = 'Milano',
            Country__c = 'Italia',
            Postal_Code__c = '00110',
            State_Province__c = 'MI:',
            Street__c = 'via',
            WRT_Default__c = true,
            WRT_Region__c = 'Lombardia'
        );

        insert sed;
        return sed;
    }
    public static SBQQ__Quote__c createQuote(account acc)
    {
        SBQQ__Quote__c quote = new SBQQ__Quote__c(
        	SBQQ__Account__c = acc.id,
            Opportunity_Name__c = 'Test opp',
            WH_Business_Area__c	= '1104244169',
            SBQQ__Primary__c = true
        );
        
        insert quote;
        return quote;
    }
}