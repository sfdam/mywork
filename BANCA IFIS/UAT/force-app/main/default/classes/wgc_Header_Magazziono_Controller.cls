public  with sharing class wgc_Header_Magazziono_Controller {
    
    @AuraEnabled
    public static Integer countMagazzionoAperto(){
        DateTime dtime = system.now();
        DateTime oldDateTime = dtime.addYears(-1);
        Date dt = system.today();
        Date oldDate = dt.addMonths(-3);
        Integer count =  0;
        List<Account> accOpsList = [SELECT Id,
                                        (SELECT Id,Name,CreatedDate  
                                         FROM Opportunities 
                                         WHERE CreatedDate >= :oldDateTime  
                                         AND CreatedDate <= :dtime 
                                         AND StageName !='Vinta' AND StageName !='Persa' 
                                         AND RecordType.DeveloperName = 'IFISOpportunitaFactoring'
                                         ORDER BY CreatedDate LIMIT 1 ) 
                                    FROM Account 
                                    WHERE WGC_Qualifica_Corporate__c != null 
                                    AND WGC_Specialista_Factoring__c!= null 
                                    AND Id IN (SELECT AccountId  
                                               FROM opportunity 
                                               WHERE  CreatedDate >= :oldDateTime  
                                         	   AND CreatedDate <= :dtime   
                                               AND StageName !='Vinta' AND StageName !='Persa'
                                               AND RecordType.DeveloperName = 'IFISOpportunitaFactoring')];
        List<Account> accTaskList = [SELECT Id, 
                                         (SELECT Esito__c, DataOraEsitazione__c,
                                          DataRicontatto__c,AccountId,Account.Name
                                          FROM Tasks 
                                          WHERE  Account.WGC_Qualifica_Corporate__c != null 
                                          AND Account.WGC_Specialista_Factoring__c!= null
                                          AND DataOraEsitazione__c >= :oldDateTime  
                                          AND DataOraEsitazione__c <= :dtime  
                                          AND (Esito__c='Positivo' OR Esito__c='Neutro')  
                                          AND DataRicontatto__c >= :oldDate 
                                          AND DataRicontatto__c <= :dt 
                                          ORDER BY CreatedDate 
                                          LIMIT 1)
                                     FROM Account 
                                     WHERE  WGC_Qualifica_Corporate__c != null
                                     AND WGC_Specialista_Factoring__c!= null];
        system.debug('count : '+count);
        
        for(Account acc : accOpsList){
            for(Opportunity opp :acc.Opportunities){
                if(opp != null && opp.Id != null){
                    count += 1;
                }
            }
        }
        system.debug('count : '+count);
        for(Account acc : accTaskList){
            for(Task ta :acc.Tasks){
                if(ta != null && ta.Id != null){
                    count += 1;
                }
            }
        }

       system.debug('count : '+count);

        return count;
    }

}