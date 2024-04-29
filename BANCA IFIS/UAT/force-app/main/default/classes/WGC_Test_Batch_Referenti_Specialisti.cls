@isTest
public class WGC_Test_Batch_Referenti_Specialisti {
    
    /*@isTest
    public static void Test_WGC_Batch_Referenti_Specialisti(){
        WGC_AllDataFactory.disattivaTrigger();
        //creo i dati di test
        List<Account> lstAcc = new List<Account>();
        List<WGC_Batch_Referenti_Specialisti.WrapperAssegnazione> lstWA = new List<WGC_Batch_Referenti_Specialisti.WrapperAssegnazione>();
        for(Integer i = 0; i < 200 ; i++){
            Account acc = new Account();
            Integer random = Integer.valueOf(Math.random());
            acc.Name = 'TestAccount'+random;
            acc.WGC_Qualifica_Corporate__c = 'Prospect';
            //Dati di test per verificare che non abbia fatto attività da più di 6 mesi
            acc.Data_ultima_attivita_Filo_Diretto__c = Date.today().addDays(-300);
            acc.WGC_Data_ultima_attivita_SvilCommFiliali__c = Date.Today().addDays(-300);            
            //Dati di test per verificare che non abbia fatto attività da più di 24 mesi
            acc.WGC_Data_Ex_Cliente_Filo_Diretto__c = Date.today().addDays(-1000);
            acc.WGC_Data_Ex_Cliente_SvilCommFiliali__c = Date.today().addDays(-1000);
            WGC_Batch_Referenti_Specialisti.WrapperAssegnazione wa = new WGC_Batch_Referenti_Specialisti.WrapperAssegnazione();
            wa.anagrafica = acc;
            wa.isChangedFD = true;
            wa.isChangedFactoring = true;
            lstWA.add(wa);
            lstAcc.add(acc);
        }
        insert lstAcc;
        //eseguo il batch
        Test.startTest();
        WGC_Batch_Referenti_Specialisti batch = new WGC_Batch_Referenti_Specialisti();
        Database.executeBatch(batch, 200);
        List<Account> lst = batch.AssegnazioneTerritoriale(lstWA);
        Test.stopTest();
    }
    */
    
    //Metodo di test per la classe scheduler del batch
    @isTest
    public static void Test_Scheduler(){
        Test.startTest();
        WGC_Scheduler_Referenti_Specialisti scheduler = new WGC_Scheduler_Referenti_Specialisti();
        String sch = '0 0 23 * * ?';
        System.Schedule('Test Referenti Specialisti', sch, scheduler);
        Test.stopTest();
    }

    @isTest
    public static void Test_prova(){
        WGC_AllDataFactory.createUtenzaDefault();
        List<Account> lstAcc = new List<Account>();
        List<WGC_Batch_Referenti_Specialisti.WrapperAssegnazione> lstWA = new List<WGC_Batch_Referenti_Specialisti.WrapperAssegnazione>();
        for(Integer i = 0; i < 4 ; i++){
            Account acc = new Account();
            Integer random = Integer.valueOf(Math.random());
            acc.Name = 'TestAccount'+random;
            switch on i {
                when 1 {
                    acc.WGC_Qualifica_Corporate__c = 'Prospect';
                    acc.WGC_Data_ultima_attivita_SvilCommFiliali__c = Date.today().addDays(-200);
                    acc.WGC_Filo_Diretto_Attivo__c=false;
                }
                when 2 {
                    acc.Data_ultima_attivita_Filo_Diretto__c = Date.today().addDays(-200);
                    acc.WGC_Factoring_Attivo__c= false;
                    acc.WGC_Data_Ex_Cliente_Filo_Diretto__c = Date.today().addDays(-800);
                }
                when 3 {
                    acc.WGC_Data_ultima_attivita_SvilCommFiliali__c = Date.today().addDays(-200);
                    acc.WGC_Filo_Diretto_Attivo__c=false;
                    acc.WGC_Data_Ex_Cliente_SvilCommFiliali__c = Date.today().addDays(-800);
                    
                }
                when else {
                    acc.WGC_Qualifica_Corporate__c = 'Prospect';
                    acc.Data_ultima_attivita_Filo_Diretto__c = Date.today().addDays(-200);
                    acc.WGC_Factoring_Attivo__c= false;
                }
            }
            WGC_Batch_Referenti_Specialisti.WrapperAssegnazione wa = new WGC_Batch_Referenti_Specialisti.WrapperAssegnazione();
            wa.anagrafica = acc;
            wa.isChangedFD = true;
            wa.isChangedFactoring = true;
            lstWA.add(wa);
            lstAcc.add(acc);
        }
        System.debug('@@@ accounts ' + JSON.serialize(lstAcc));
        insert lstAcc;
        WGC_Batch_Referenti_Specialisti batch = new WGC_Batch_Referenti_Specialisti();
        
        
        Test.startTest();
        Database.executeBatch(batch, 200);
        //batch.execute(null,lstAcc);
        
        batch.AssegnazioneTerritoriale(lstWA);
        Test.stopTest();
    }
}