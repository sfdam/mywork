@isTest
public class WGC_Test_ModuloAdeguataVerifica {

    @isTest
    public static void Test_Metodo1(){
        //Creo i dati di test
        //WGC_AllDataFactory.disattivaTrigger();
        WGC_AllDataFactory.createUtenzaDefault();
        //List<AccountContactRelation> listAccContact = WGC_AllDataFactory.creaAccContRel(1,true);   
        //String accId = [SELECT Id, Name FROM Account].Id;
        List<AdeguataVerifica__c> listAV = WGC_AllDataFactory.createAdeguataVerifica(2,false);
        List<Contact> listCont = WGC_AllDataFactory.createContact(1,true);
        Account a = [SELECT Id, Name FROM Account LIMIT 1];
        listAV.get(0).Account__c=a.Id;
        AdeguataVerifica__c mav = new AdeguataVerifica__c(Account__c= a.Id);
        //mav.Name = 'TestMav'+rand;
        
        insert mav;
        System.debug('listAV :'+ listAV);
        //AdeguataVerifica__c mavTest = [SELECT Id, Name FROM AdeguataVerifica__c LIMIT 1];
        String mavTestString = JSON.serialize(listAV);
        

        List<AccountContactRelation> prova = [SELECT Id, AccountId, ContactId FROM AccountContactRelation LIMIT 2];
        
		Map<String,String> datiMav = new Map<String,String>();
		datiMav.put('PaeseCasaMadre__c','');
		datiMav.put('PaeseSvolgimentoAttivitaPrevalente__c','');
		datiMav.put('ProvinciaSvolgimentoAttivitaPrevalente__c','');
		datiMav.put('PaeseRelazioni1__c','');
		datiMav.put('PaeseRelazioni2__c','');
		datiMav.put('PaeseRelazioni3__c','');
		Map<String, String> nazioni = WGC_ModuloAdeguataVerifica.getselectOptions_Nazione();
		Map<String, String> provincie = WGC_ModuloAdeguataVerifica.getselectOptions_Province();
		Account account = WGC_ModuloAdeguataVerifica.getDatiMavAccount(a.Id);
		Map<String, String> scopoFactoring = WGC_ModuloAdeguataVerifica.getScopoFactoring();
		Map<String, String> scopoFinanziamenti = WGC_ModuloAdeguataVerifica.getScopoFinanziamenti();
		Map<String, String> scopoServiziBancari = WGC_ModuloAdeguataVerifica.getScopoServiziBancari();
		Map<String, String> naturaCreditiErariali = WGC_ModuloAdeguataVerifica.getNaturaCreditiErariali();

     	Test.startTest();

		WGC_ModuloAdeguataVerifica.getMAV(a.Id);
        WGC_ModuloAdeguataVerifica.SaveRecord(a.Id, mavTestString,a.id,true, datiMav,'CC', false);
        
        Test.stopTest();
    }

    @isTest
    public static void Test_Metodo2(){
        //Creo i dati di test
        //WGC_AllDataFactory.disattivaTrigger();
        WGC_AllDataFactory.createUtenzaDefault();
        //List<AccountContactRelation> listAccContact = WGC_AllDataFactory.creaAccContRel(1,true);
        
        Integer rand = Integer.valueOf(Math.random());
        Account acc = new Account();
        acc.Name = 'TestAccount'+rand;
        
        insert acc;
        
        Account a = [SELECT id, name FROM Account LIMIT 1];
        
        //String accId = [SELECT Id, Name FROM Account].Id;
        List<AdeguataVerifica__c> listAV = WGC_AllDataFactory.createAdeguataVerifica(2,true);
        AdeguataVerifica__c mav = new AdeguataVerifica__c();
        //mav.Name = 'TestMav'+rand;
        
        insert mav;
        
        //AdeguataVerifica__c mavTest = [SELECT Id, Name FROM AdeguataVerifica__c LIMIT 1];
        String mavTestString = JSON.serialize(listAV.get(0));
        
		Map<String,String> datiMav = new Map<String,String>();
		datiMav.put('PaeseCasaMadre__c','');
		datiMav.put('PaeseSvolgimentoAttivitaPrevalente__c','');
		datiMav.put('ProvinciaSvolgimentoAttivitaPrevalente__c','');
		datiMav.put('PaeseRelazioni1__c','');
		datiMav.put('PaeseRelazioni2__c','');
		datiMav.put('PaeseRelazioni3__c','');

        //Eseguo il test
        Test.startTest();

        WGC_ModuloAdeguataVerifica.getMAV(a.Id);
        WGC_ModuloAdeguataVerifica.SaveRecord(a.Id, mavTestString,a.id,true, datiMav,'CC', true);
        
        Test.stopTest();
    }


    @isTest
    public static void Test_Metodo3(){
        //Creo i dati di test
        //WGC_AllDataFactory.disattivaTrigger();
        WGC_AllDataFactory.createUtenzaDefault();
        
        //List<Account> lstAcc = WGC_AllDataFactory.createAccount(2,true);
        List<Contact> lstCont = WGC_AllDataFactory.createContact(2,true);
        List<AccountContactRelation> accContRel = [SELECT Id,AccountId,ContactId,WGC_Ruolo__c FROM AccountContactRelation LIMIT 2];
        List<Account> lstAcc = [SELECT Id, Name FROM Account];
        accContRel.get(0).WGC_Ruolo__c='J1;Z1';
        accContRel.get(1).WGC_Ruolo__c='J;J1';
        update accContRel;
        System.debug('guarda i ruoli: '+accContRel);

        WGC_Modal_TitolareEsecutore_Controller.listWrapper wrap1 = new WGC_Modal_TitolareEsecutore_Controller.listWrapper();
        wrap1.Name='Test1';
        wrap1.AccountId=accContRel.get(0).AccountId;
        wrap1.ContactId=accContRel.get(0).ContactId;
        wrap1.isRelation=false;
        wrap1.Id=accContRel.get(0).Id;

        
        Schema.DescribeFieldResult fieldResult1 = AccountContactRelation.WGC_Ruolo__c.getDescribe();
        List<PicklistEntry> ple1 = fieldResult1.getPicklistValues();
        List<String> valoriRuolo1 = accContRel.get(0).WGC_Ruolo__c.split(';');
        WGC_Modal_TitolareEsecutore_Controller.P pv1 = new WGC_Modal_TitolareEsecutore_Controller.P();
        pv1.label = '';
        pv1.value = '';
        for( Schema.PicklistEntry pickListVal : ple1){

            for(String valore : valoriRuolo1){
                if(picklistVal.getValue() == valore && picklistVal.isActive()){
                    pv1.label += picklistVal.getLabel() + ' ';
                    pv1.value += picklistVal.getValue() + ';';
                }
            }               
        }
        wrap1.WGC_Ruolo = pv1;


        WGC_Modal_TitolareEsecutore_Controller.listWrapper wrap2 = new WGC_Modal_TitolareEsecutore_Controller.listWrapper();
        wrap2.Name='Test2';
        wrap2.AccountId=accContRel.get(1).AccountId;
        wrap2.ContactId=accContRel.get(1).ContactId;
        wrap2.isRelation=true;
        wrap2.Id=accContRel.get(0).Id;

        
        Schema.DescribeFieldResult fieldResult2 = AccountContactRelation.WGC_Ruolo__c.getDescribe();
        List<Schema.PicklistEntry> ple2 = fieldResult2.getPicklistValues();
        List<String> valoriRuolo2 = accContRel.get(1).WGC_Ruolo__c.split(';');
        WGC_Modal_TitolareEsecutore_Controller.P pv2 = new WGC_Modal_TitolareEsecutore_Controller.P();
        pv2.label = '';
        pv2.value = '';
        for( Schema.PicklistEntry pickListVal : ple2){

            for(String valore : valoriRuolo2){
                if(picklistVal.getValue() == valore && picklistVal.isActive()){
                    pv2.label += picklistVal.getLabel() + ' ';
                    pv2.value += picklistVal.getValue() + ';';
                }
            }               
        }
        wrap2.WGC_Ruolo = pv2;


        List<WGC_Modal_TitolareEsecutore_Controller.listWrapper> listWrap = new List<WGC_Modal_TitolareEsecutore_Controller.listWrapper>();
        listWrap.add(wrap1);
        listWrap.add(wrap2);
        
        // List<AdeguataVerifica__c> listAV = WGC_AllDataFactory.createAdeguataVerifica(2,true);
        AdeguataVerifica__c mav = new AdeguataVerifica__c();
        //mav.Name = 'TestMav'
        
        insert mav;
        String mavTestString = JSON.serialize(mav);
        //AdeguataVerifica__c mavTest = [SELECT Id, Name FROM AdeguataVerifica__c LIMIT 1];
        String recordAccCont = JSON.serialize(listWrap);
        Map<String,String> datiMav = new Map<String,String>();
		datiMav.put('PaeseCasaMadre__c','');
		datiMav.put('PaeseSvolgimentoAttivitaPrevalente__c','');
		datiMav.put('ProvinciaSvolgimentoAttivitaPrevalente__c','');
		datiMav.put('PaeseRelazioni1__c','');
		datiMav.put('PaeseRelazioni2__c','');
		datiMav.put('PaeseRelazioni3__c','');
        //Eseguo il test
        
     	Test.startTest();

        WGC_ModuloAdeguataVerifica.SaveRecord(lstAcc.get(0).Id, mavTestString,recordAccCont,true, datiMav,'CC', false);
        
        accContRel.get(0).WGC_Ruolo__c='J;J1';
        accContRel.get(1).WGC_Ruolo__c='J1;Z1';
        update accContRel;
        WGC_ModuloAdeguataVerifica.SaveRecord(lstAcc.get(0).Id, mavTestString,recordAccCont,true, datiMav,'CC', true);

        accContRel.get(0).WGC_Ruolo__c='J1;Z1';
        accContRel.get(1).WGC_Ruolo__c='J;J1';
        update accContRel;
        WGC_ModuloAdeguataVerifica.SaveRecord(lstAcc.get(0).Id, mavTestString,recordAccCont,true, datiMav,'CC', false);

        Test.stopTest();
    }

    public static void Test_Metodo4(){
        //Creo i dati di test
        //WGC_AllDataFactory.disattivaTrigger();
        WGC_AllDataFactory.createUtenzaDefault();
        
        //List<Account> lstAcc = WGC_AllDataFactory.createAccount(2,true);
        List<Contact> lstCont = WGC_AllDataFactory.createContact(2,true);
        List<AccountContactRelation> accContRel = [SELECT Id,AccountId,ContactId,WGC_Ruolo__c FROM AccountContactRelation LIMIT 2];
        List<Account> lstAcc = [SELECT Id, Name FROM Account];
        accContRel.get(0).WGC_Ruolo__c='J1;Z1';
        accContRel.get(1).WGC_Ruolo__c='J;J1';
        update accContRel;
        System.debug('guarda i ruoli: '+accContRel);

        WGC_Modal_TitolareEsecutore_Controller.listWrapper wrap1 = new WGC_Modal_TitolareEsecutore_Controller.listWrapper();
        wrap1.Name='Test1';
        wrap1.AccountId=accContRel.get(0).AccountId;
        wrap1.ContactId=accContRel.get(0).ContactId;
        wrap1.isRelation=false;
        wrap1.Id=accContRel.get(0).Id;

        
        Schema.DescribeFieldResult fieldResult1 = AccountContactRelation.WGC_Ruolo__c.getDescribe();
        List<PicklistEntry> ple1 = fieldResult1.getPicklistValues();
        List<String> valoriRuolo1 = accContRel.get(0).WGC_Ruolo__c.split(';');
        WGC_Modal_TitolareEsecutore_Controller.P pv1 = new WGC_Modal_TitolareEsecutore_Controller.P();
        pv1.label = '';
        pv1.value = '';
        for( Schema.PicklistEntry pickListVal : ple1){

            for(String valore : valoriRuolo1){
                if(picklistVal.getValue() == valore && picklistVal.isActive()){
                    pv1.label += picklistVal.getLabel() + ' ';
                    pv1.value += picklistVal.getValue() + ';';
                }
            }               
        }
        wrap1.WGC_Ruolo = pv1;


        WGC_Modal_TitolareEsecutore_Controller.listWrapper wrap2 = new WGC_Modal_TitolareEsecutore_Controller.listWrapper();
        wrap2.Name='Test2';
        wrap2.AccountId=accContRel.get(1).AccountId;
        wrap2.ContactId=accContRel.get(1).ContactId;
        wrap2.isRelation=true;
        wrap2.Id=accContRel.get(0).Id;

        
        Schema.DescribeFieldResult fieldResult2 = AccountContactRelation.WGC_Ruolo__c.getDescribe();
        List<Schema.PicklistEntry> ple2 = fieldResult2.getPicklistValues();
        List<String> valoriRuolo2 = accContRel.get(1).WGC_Ruolo__c.split(';');
        WGC_Modal_TitolareEsecutore_Controller.P pv2 = new WGC_Modal_TitolareEsecutore_Controller.P();
        pv2.label = '';
        pv2.value = '';
        for( Schema.PicklistEntry pickListVal : ple2){

            for(String valore : valoriRuolo2){
                if(picklistVal.getValue() == valore && picklistVal.isActive()){
                    pv2.label += picklistVal.getLabel() + ' ';
                    pv2.value += picklistVal.getValue() + ';';
                }
            }               
        }
        wrap2.WGC_Ruolo = pv2;


        List<WGC_Modal_TitolareEsecutore_Controller.listWrapper> listWrap = new List<WGC_Modal_TitolareEsecutore_Controller.listWrapper>();
        listWrap.add(wrap1);
        listWrap.add(wrap2);
        
        // List<AdeguataVerifica__c> listAV = WGC_AllDataFactory.createAdeguataVerifica(2,true);
        AdeguataVerifica__c mav = new AdeguataVerifica__c();
        //mav.Name = 'TestMav'
        
        insert mav;
        String mavTestString = JSON.serialize(mav);
        //AdeguataVerifica__c mavTest = [SELECT Id, Name FROM AdeguataVerifica__c LIMIT 1];
        String recordAccCont = JSON.serialize(listWrap);
        Map<String,String> datiMav = new Map<String,String>();
		datiMav.put('PaeseCasaMadre__c','');
		datiMav.put('PaeseSvolgimentoAttivitaPrevalente__c','');
		datiMav.put('ProvinciaSvolgimentoAttivitaPrevalente__c','');
		datiMav.put('PaeseRelazioni1__c','');
		datiMav.put('PaeseRelazioni2__c','');
		datiMav.put('PaeseRelazioni3__c','');

        //Eseguo il test
        
     	Test.startTest();

        WGC_ModuloAdeguataVerifica.SaveRecord(lstAcc.get(0).Id, mavTestString,recordAccCont,true, datiMav,'CC', false);
    
        Test.stopTest();
    }

}