@IsTest
public class AggiungiMassivamenteNucleiControllerTest {
    @TestSetup
    static void setup(){
        Funzionalita__c x = new Funzionalita__c();
        x.Disable_Trigger__c =true;
        insert x;
        Account filiale= new Account();
        filiale.Name='Filiale';
        filiale.RecordTypeId=Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('FilialeDiRelazione').getRecordTypeId();
        filiale.FinServ__BankNumber__c ='05387';
        filiale.PTF_OFS__c =True;
        insert filiale;
       
        
        Account filiale3= new Account();
        filiale3.Name='Filiale';
        filiale3.RecordTypeId=Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('FilialeDiRelazione').getRecordTypeId();
        filiale3.FinServ__BankNumber__c ='05387';
        filiale3.PTF_OFS__c =True;
        filiale3.PTF_IdCED__c = '7113';
        insert filiale3;
        
        Wallet__c microPortafoglio1 = AllDataFactory.getWallet('MicroWallet',  'Filiale', 'Personal');
        microPortafoglio1.Name = 'wallet1';
        microPortafoglio1.PTF_Filiale__c=filiale.Id;
        microPortafoglio1.PTF_Banca__c = filiale.Id;
        insert microPortafoglio1;
        
        Wallet__c microPortafoglio2 = AllDataFactory.getWallet('MicroWallet',  'Filiale', 'Personal');
        microPortafoglio2.PTF_Filiale__c=filiale.Id;
        insert microPortafoglio2;
        
        Wallet__c microPortafoglio3 = AllDataFactory.getWallet('MicroWallet',  'Filiale', 'Personal');
        microPortafoglio3.Name = 'wallet3';
        microPortafoglio3.PTF_Filiale__c=filiale3.Id;
        microPortafoglio3.PTF_Banca__c = filiale3.Id;
        
        
        insert microPortafoglio3;
        List<Nucleo__c> nucToInsert = new List<Nucleo__c>();
        for (Integer i=0; i<3 ; i++){
            Nucleo__c nucleo= new Nucleo__c();
            nucToInsert.add(nucleo);
        }
        insert nucToInsert;
        List<Account> accToInsert= new List<Account>();
        Id rt=Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('PersonAccount').getRecordTypeId();
        for(Integer i=0; i<3 ; i++){
            Account a = new Account();
            a.PTF_Portafoglio__c=microPortafoglio2.Id;
            a.PTF_Nucleo__c=nucToInsert[0].Id;
            if(i==0){
                a.PTF_Caponucleo__c=true;
            }
            if(i<2){
                a.LastName='SI';
            }
            else{
                a.LastName='NO';
            }
            accToInsert.add(a);
        }

        for(Integer i=0; i<3 ; i++){
            Account a = new Account();
            a.PTF_Portafoglio__c=microPortafoglio2.Id;
            a.PTF_Nucleo__c=nucToInsert[1].Id;
            
            if(i==0){
                a.LastName='SI';
                a.PTF_Caponucleo__c=true;
            }
            else{
                a.LastName='NO';
            }
            accToInsert.add(a);
        }

        for(Integer i=0; i<3 ; i++){
            Account a = new Account();
            a.PTF_Portafoglio__c=microPortafoglio2.Id;
            a.PTF_Nucleo__c=nucToInsert[2].Id;
            
            if(i==0){
                a.LastName='NO';
                a.PTF_Caponucleo__c=true;
            }
            else{
                a.LastName='SI';
            }
            accToInsert.add(a);
        }

        

        
        insert accToInsert;
        /*for(Account a: accToInsert){
            System.debug('@@@@ acctoInsert: '+JSON.serialize(a));
        }*/
        

        
    }
    @isTest
    static void testInit(){
        Contact c= new Contact(LastName='test', PTF_User__c=UserInfo.getUserId());
        insert c;
        Wallet__c mp=[SELECT Id, Name, PTF_ModelloDiServizio__c,
        PTF_Filiale__c, PTF_Filiale__r.PTF_BranchTypeDesc__c, PTF_Filiale__r.PTF_BranchTypologyMap__c, PTF_Filiale__r.Name, PTF_FIliale__r.PTF_IdCed__c, PTF_Capofila__c, PTF_Capofila__r.PTF_IdCed__c,
        PTF_Banca__c, PTF_Banca__r.FinServ__BankNumber__c, PTF_Banca__r.PTF_DowngradeReqStartDate__c, PTF_Banca__r.PTF_DowngradeReqEndDate__c, PTF_Banca__r.PTF_IdCed__c,
        PTF_DirezioneRegionale__r.PTF_IdCed__c, PTF_Area__r.PTF_IdCed__c, PTF_DirezioneRegionale__c, PTF_Area__c, Owner.Name, PTF_Fatturato__c, PTF_Patrimonio__c, PTF_Utilizzato__c, PTF_Accordato__c,
        PTF_DirezioneRegionale__r.PTF_DowngradeReqStartDate__c, PTF_DirezioneRegionale__r.PTF_DowngradeReqEndDate__c, PTF_Pool__c, PTF_Filiale__r.PTF_DowngradeReqStartDate__c, PTF_Filiale__r.PTF_DowngradeReqEndDate__c,
        (SELECT id, PTF_Gestore__c, PTF_Gestore__r.PTF_OFS__c, PTF_Gestore__r.Name FROM Backup_Assignments__r )
        FROM Wallet__c LIMIT 1];
        Map<String, Object> output = AggiungiMassivamenteNucleiController.init(mp.Id);
        System.debug('output '+ AggiungiMassivamenteNucleiController.init(mp.Id) );
        System.assertEquals(False,output.get('hasOFS'));
        System.assertEquals([SELECT Id, Profile.Name, Profilo__c, PTF_RuoloLDAP__c, idced__c, PTF_IdCEDPadre__c, banca__c FROM User WHERE id =: UserInfo.getUserId()],output.get('currentUser'));
        
    }

    @isTest
    static void testLoadUpdate(){
        Test.startTest();
        List<Wallet__c> mp=[SELECT Id, PTF_Filiale__c, PTF_Filiale__r.PTF_BranchTypeDesc__c, PTF_Banca__r.FinServ__BankNumber__c, PTF_ModelloDiServizio__c FROM Wallet__c ORDER BY CreatedDate asc LIMIT 2];     
        List<String> rt= new List<String>();
        rt.add('TechnicalWallet');
        Map<String,Object> loadMwListOut=AggiungiMassivamenteNucleiController.loadMwList(mp[0].PTF_Filiale__c, 'Personal', null, mp[0].Id, 0, 5, rt);
        System.Debug('loadMwListOut '+loadMwListOut);
        Map<String,Object> loadNdgListOut = AggiungiMassivamenteNucleiController.loadNdgList(mp[1], 'Test',  null, 0, 5, mp[0]);
        System.Debug('loadNdgListOut '+loadNdgListOut);
        List<Account> ndgList = [SELECT Id, PTF_Nucleo__c ,LastName FROM Account WHERE LastName='SI' ];
        List<String> ndgIdList = new List<String>();
        for(Account a:ndgList){
            ndgIdList.add(a.Id);
            system.debug('@@@: '+a.LastName+'_'+a.PTF_Nucleo__c);
        }
    

        AggiungiMassivamenteNucleiController.moveNdgsToWallet(mp[0].Id, ndgIdList, mp[1].Id);
        Test.stopTest();
    }
    
    
    @isTest
    static void testcheckEligible(){
        Test.startTest();
        Contact c= new Contact(LastName='test', PTF_User__c=UserInfo.getUserId());
        insert c;
        List<Wallet__c> mp=[SELECT Id, PTF_Filiale__c, PTF_Filiale__r.PTF_BranchTypeDesc__c, PTF_Banca__r.FinServ__BankNumber__c, PTF_ModelloDiServizio__c FROM Wallet__c where  Name =: 'wallet1'  LIMIT 1];
        List<String> rt= new List<String>();
        rt.add('TechnicalWallet');
        Map<String,Object> loadMwListOut=AggiungiMassivamenteNucleiController.loadMwList(mp[0].PTF_Filiale__c, 'Personal', null, mp[0].Id, 0, 5, rt);
        Account acc = [SELECT Id ,PTF_OFS__c,LastName,FinServ__BankNumber__c FROM Account WHERE FinServ__BankNumber__c ='05387' limit 1];
        
        ConfigurazioneSpostamenti__mdt cs= [SELECT Id, MasterLabel, PTF_MDS_End__c, PTF_MDS_Start__c,
                                PTF_Abi__c, Finestra_Temporale__c, Iter_Approvativo__c,
                                PTF_Filiale_End__c, PTF_Filiale_Start__c, PTF_Filiale_StessaArea__c, PTF_Filiale_StessaDR__c,
                                PTF_Filiale_StessoMicroMercato__c, PTF_JSON_Approvatori__c, PTF_StessoReferente__c,
                                PTF_CheckNaturaGiuridica__c, PTF_CheckTipologiaFilialeDestinazione__c,
                                PTF_CheckCedSpecifico__c, PTF_CheckTipologiaFilialePartenza__c, Tipo_di_Spostamento__c
                                ,PTF_SuperUsers__c
                                FROM ConfigurazioneSpostamenti__mdt
                                WHERE Tipo_di_Spostamento__c = 'Referenti' AND
                                PTF_MDS_Start__c ='Personal' and PTF_MDS_End__c ='Personal' AND PTF_IsActive__c = true and PTF_Abi__c= '05387' limit 1];
        
		
        AggiungiMassivamenteNucleiController.checkEligible(mp[0],acc , mp[0]);
        Test.stopTest();
    }
    
   
}