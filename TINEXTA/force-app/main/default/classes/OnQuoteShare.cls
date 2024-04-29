public class OnQuoteShare {
    
    public static boolean manualShareRead(List <SBQQ__Quote__c>  recordId){
        
        Set<Id> quote = new set<Id>();
        Set <Id> opp = new set<Id>();
        List<SBQQ__Quote__Share> Lista = new List<SBQQ__Quote__Share>();
        
        
        for(SBQQ__Quote__c qq:recordId){
            quote.add(qq.Id);
           // opp.add(qq.SBQQ__Opportunity2__c);
        }
        system.debug('Input' + quote);
        
        List<Opportunity> oppl = New List <Opportunity>([SELECT Id, Quote_Creazione__c FROM Opportunity WHERE Quote_Creazione__c IN:quote]);
        system.debug('opp' + oppl);
        
        set<Id> idopp = new set<Id>();
        for(Opportunity o:oppl){
            idopp.add(o.id);
        }
        
        Map<Id, SBQQ__Quote__Share> ShareMap = new Map <Id,SBQQ__Quote__Share> ([SELECT Id,ParentId,UserOrGroupId  FROM SBQQ__Quote__Share WHERE ParentId IN:quote]);
        Map <Id, OpportunityTeamMember> Team = New Map <Id,OpportunityTeamMember>([SELECT ID, UserId, OpportunityId FROM OpportunityTeamMember WHERE OpportunityId IN: idopp]);
        system.debug('ShareQuoteMap' + ShareMap);
        
        
        for(SBQQ__Quote__c q:recordId){
            for(Id t:Team.keyset()){
                //for(Id m: ShareMap.keyset()){
                // If(q.WRT_Agente3__c != ShareMap.get(m).UserOrGroupId){
                
                SBQQ__Quote__Share jobShr  = new SBQQ__Quote__Share();
                jobShr.ParentId = q.Id;
                //jobShr.UserOrGroupId = q.WRT_Agente3__c;
                jobShr.UserOrGroupId=Team.get(t).UserId;
                jobShr.AccessLevel = 'Read';
                jobShr.RowCause = 'TeamOperativo__c';
                
                Lista.add(jobShr);
                //}
                //}
            }
        }
        
        /*for(SBQQ__Quote__c q:recordId){
for (Id u: Team.keyset()){ 
if(q.WRT_Agente3__c != Team.get(u).UserId){
SBQQ__Quote__Share jobShr  = new SBQQ__Quote__Share();

jobShr.ParentId = q.Id;
jobShr.UserOrGroupId = Team.get(u).Id;
jobShr.AccessLevel = 'Edit';
jobShr.RowCause = 'Manual';

Lista.add(jobShr);
}
}
}*/
        
        
        
        System.debug('Lista' + Lista);
        
        /*if(Lista.size()>0){
Map <Integer,SBQQ__Quote__Share> Definitivo= new map<Integer,SBQQ__Quote__Share>();
Integer intCount = 0;
for(SBQQ__Quote__Share qs:Lista){
for(id ms:ShareMap.keyset()){
If(qs.UserOrGroupId != ShareMap.get(ms).UserOrGroupId){
Definitivo.put(intCount,qs);
intCount++;
}
}
}

Insert Definitivo.values();
System.debug('Definitivo' + Definitivo);
}*/
        
        
        
        
        
        
        
        If(Lista.size()>0){
            Database.SaveResult[] sr = Database.insert(Lista,false);
            return true;
            //insert Definitivo.values();
        }
        else{
            return false;
        }
        
        // Process the save results.
        /* if(sr.isSuccess()){
// Indicates success
return true;
}
else {
// Get first save result error.
Database.Error err = sr.getErrors()[0];

// Check if the error is related to trival access level.
// Access level must be more permissive than the object's default.
// These sharing records are not required and thus an insert exception is acceptable. 
if(err.getStatusCode() == StatusCode.FIELD_FILTER_VALIDATION_EXCEPTION  &&  
err.getMessage().contains('AccessLevel')){
// Indicates success.
return true;
}
else{
// Indicates failure.
return false;
}
}*/
    }


    public static boolean manualShareDelete(List <SBQQ__Quote__c>  recordId, List <User> userlist){
        
        Set<Id> quote = new set<Id>();
        Set <Id> deleteuser = new Set<Id>();
        Set <Id> opp = new set<Id>();

        List<SBQQ__Quote__Share> Lista = new List<SBQQ__Quote__Share>();
        
        
        for(SBQQ__Quote__c qq:recordId){
            quote.add(qq.Id);
        }
        
        system.debug('Lista di Quote' + quote);
        
        for(User u:userlist){
            deleteuser.add(u.Id);
        }
        system.debug('ListaDelete' + deleteuser);
        
        
        Map<Id, SBQQ__Quote__Share> ShareMap = new Map <Id,SBQQ__Quote__Share> ([SELECT Id,ParentId,UserOrGroupId  FROM SBQQ__Quote__Share WHERE ParentId IN:quote AND UserOrGroupId IN: deleteuser]);

        system.debug('Quoteshare' + ShareMap);
   
        
        for(Id s:ShareMap.keyset()){
            system.debug('dentro il for');
            Lista.add(ShareMap.get(s));
        }



        If(Lista.size()>0){
            system.debug('Chiamata Delete');
            delete Lista;
            return true;

        }else{
            return false;
        }
    }
}