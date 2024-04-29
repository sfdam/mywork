@isTest
public class scheduledJobTriggerHandler_Test {
    
    @TestSetup
    public static void createRecords(){
        User u = TestDataFactorySSO.createUser();
        insert u;
    }
    
    @isTest
    public static void creaScheduledJobTest(){
        List<User> lUser = new List<User>();
        lUser.add(TestDataFactorySSO.createUser());
        insert lUser;
        ScheduledJob__c sh = TestDataFactorySSO.creaScheduledJobs('Batchable','test','test_caso_impossibile',lUser.get(0));
        insert sh;
        try{
        	ScheduledJob__c sh2 = TestDataFactorySSO.creaScheduledJobsFrequenzaSettimanale('Batchable','test2','testClass1',lUser.get(0));
            insert sh2;
        }
        catch(Exception e){
            
        }
        try{
        	ScheduledJob__c sh2 = TestDataFactorySSO.creaScheduledJobsFrequenzaGiornaliera('Batchable','test2','testClass1',lUser.get(0));
            insert sh2;
        }
        catch(Exception e){
            
        }
        try{
        	ScheduledJob__c sh3 = TestDataFactorySSO.creaScheduledJobsFrequenzaMensile('Batchable','test2','testClass1',lUser.get(0));
            insert sh3;
        }
        catch(Exception e){
            
        }
        try{
        	ScheduledJob__c sh4 = TestDataFactorySSO.creaScheduledJobsFrequenzaAnnuale('Batchable','test2','testClass1',lUser.get(0));
            insert sh4;
        }
        catch(Exception e){
            
        }

        update sh;
        sh.Utente__c =null;
        sh.Trigger__c = false;
        try{
            update sh; 
        }
        catch(Exception e){}

        
        sh.Frequenza__c =null;
        sh.Trigger__c = false;
        try{
            update sh; 
        }
        catch(Exception e){}
        sh.Nome_Classe__c = 'test_caso_impossibile';
        sh.Attivo__c = true;
        sh.Utente__c = lUser.get(0).id;
        sh.Ordine_Di_Esecuzione__c = '2rrrl';
        sh.Martedi__c = true;
        sh.Frequenza__c = 'Settimanale';
        try{
            update sh; 
        }
        catch(Exception e){}
        
        sh.Data_Fine_Validit__c = null;
        sh.Trigger__c = false;
            
        try{
            update sh; 
        }
        catch(Exception e){}
        
        sh.Trigger__c = false;
        sh.Data_Fine_Validit__c = Date.today().addDays(2);
        sh.Data_Inzio_Validit__c = Date.today().addDays(3);
        try{
            update sh; 
        }
        catch(Exception e){}
		
        sh.Trigger__c = true;
        sh.Codice_Gruppo__c = null;
        try{
            update sh; 
        }
        catch(Exception e){}
    } 
    
    @isTest static void testCreaElaborazioneShare() {
        List<User> lUser = new List<User>();        
        lUser.add(TestDataFactorySSO.createUser());
        insert lUser;
        List<ScheduledJob__c> lScheduledJob = new List<ScheduledJob__c>();
        lScheduledJob.add(TestDataFactorySSO.creaScheduledJobs('Batchable','test1','Batch_VisibilityAccountGroup',lUser.get(0)));
        insert lScheduledJob;
        List<Elaborazione_Processo__c> lElaborazioneProcesso = new List<Elaborazione_Processo__c>();
        lElaborazioneProcesso.add(TestDataFactorySSO.creaElaborazioneProcesso(lScheduledJob.get(0).Codice_Gruppo__c));
        insert lElaborazioneProcesso;
        JobRunner jr = new JobRunner(); 
        String sch = '0 55 23 * * ?';
        String jobID = system.schedule('Job_runner_test', sch, jr);
    }
    
    @isTest static void testUnit2() {
        Datetime dtt=DateTime.now();
        Date dt2=dtt.Date();
        String hour;
        String minute;
        if(dtt.hour()<10)
            hour='0'+String.valueOf(dtt.hour());
        else
            hour=String.valueOf(dtt.hour());
        if(dtt.minute()<10)
            minute='0'+String.valueOf(dtt.minute());
        else
            minute=String.valueOf(dtt.minute());
        String currentTime=+hour+':'+minute;
        List<User> lUser = new List<User>();
        lUser.add(TestDataFactorySSO.createUser());
        insert lUser;
        List<ScheduledJob__c> lScheduledJob = new List<ScheduledJob__c>();
        lScheduledJob.add(TestDataFactorySSO.creaScheduledJobs('Batchable','TEST','Batch_DelAccountShare',lUser.get(0)));
        lScheduledJob.add(TestDataFactorySSO.creaScheduledJobs('Schedulable','TEST2','Test2',lUser.get(0)));
        insert lScheduledJob;
        TestDataFactorySSO.aggiornaScheduledJob(lScheduledJob.get(0), currentTime, 'Giornaliera');
		TestDataFactorySSO.aggiornaScheduledJob(lScheduledJob.get(0), currentTime, 'Giornaliera');        
        JobRunner jr = new JobRunner();
        jr.execute(NULL) ;
       
    }

}