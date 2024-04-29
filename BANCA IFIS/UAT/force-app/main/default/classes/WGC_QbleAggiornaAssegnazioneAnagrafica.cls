public class WGC_QbleAggiornaAssegnazioneAnagrafica implements Queueable {
	
    Map<Id,AssegnazioneAnagrafica__c> oldmap = new Map<Id,AssegnazioneAnagrafica__c>();
    Map<Id,AssegnazioneAnagrafica__c> newmap = new Map<Id,AssegnazioneAnagrafica__c>();
    List<Account> listAcc = new List<Account>();
    List<User> utenti = new List<User>();

    // public WGC_QbleAggiornaAssegnazioneAnagrafica(Map<Id,AssegnazioneAnagrafica__c> oldmap, Map<Id,AssegnazioneAnagrafica__c> newmap, List<Account> listAcc, List<User> utenti){
    //     this.oldmap=oldmap;
    //     this.newmap=newmap;
    //     this.listAcc=listAcc;
    //     this.utenti = utenti; 
    // }

    // public void execute(QueueableContext context){
        
    //     System.debug('@@@ accounts ' + this.listAcc);
    //     //Set di id degli utenti attivi
    //     Set<Id> activeUserId = new Set<Id>();
    //     for(User u : this.utenti){
    //         activeUserId.add(u.Id);
    //     }

    //     List<Account> toUpd = new List<Account>();

    //     //Controllo tutti gli account
    //     for(Account a : this.listAcc){
    //         Boolean needsUpdate = false;
    //         for(AssegnazioneAnagrafica__c ass : newMap.values()){
    //             //Se il cap corrisponde tra anagrafica e record di assegnazione allora modifico lo specialista filo diretto
    //             if(a.BillingPostalCode == ass.Cap__c && ass.FiloDiretto__c){
    //                 a.WGC_Specialista_Filo_Diretto__c = ass.IdUtente__c;
    //                 needsUpdate = true;
    //             }

    //             //Se il cap corrisponde e WGC_Factoring_Attivo = false e l'assegnazione non è di filo diretto allora modifico lo specialista factoring
    //             //Oppure
    //             //Se il cap corrisponde e WGC_Factoring_Attivo = true e l'assegnazione non è di filo diretto, e l'utente è disattivo allora modifico lo specialista factoring
    //             if((a.BillingPostalCode == ass.Cap__c && !a.WGC_Factoring_Attivo__c && !ass.FiloDiretto__c) || 
    //                 (a.BillingPostalCode == ass.Cap__c && a.WGC_Factoring_Attivo__c && !activeUserId.contains(ass.IdUtente__c) && !ass.FiloDiretto__c)){
                    
    //                 a.WGC_Specialista_Factoring__c = ass.IdUtente__c;
    //                 needsUpdate = true;
    //             }

    //             if(needsUpdate){
    //                 toUpd.add(a);
    //             }
    //         }
    //     }

    //     System.debug('@@@ toUpdate ' + JSON.serialize(toUpd));
    //     update toUpd;
    // }

    public WGC_QbleAggiornaAssegnazioneAnagrafica(List<Account> accToUpdt){
        this.listAcc = accToUpdt;
    }

    public void execute(QueueableContext context){
        List<Account> newListAcc = new List<Account>();

        if(this.listAcc.size() > 0){
            for(Integer i = 0; i < 1000; i++){
                if(this.listAcc.size() > i){
                    newListAcc.add(this.listAcc[i]);
                    this.listAcc.remove(i);
                }
                else{
                    break;
                }
            }
        }

        if(!newListAcc.isEmpty())
            update newListAcc;

        if(!this.listAcc.isEmpty() && !Test.isRunningTest()){
            System.enqueueJob(new WGC_QbleAggiornaAssegnazioneAnagrafica(this.listAcc));
        }
    }
}