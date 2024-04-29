trigger BPER_KPI_Presa_in_Carico_TempoMedio_Case on Case (before update) {
    
    //Selecting default business hours (BH) record
    BusinessHours defaultBH = [SELECT Id FROM BusinessHours WHERE Name = 'BPER' Limit 1];
    //Making sure BH record exists
    if(defaultBH != NULL){
        for(Case caseObj : trigger.new ){
            //Making sure that closed date field is populated and is updated
            if(caseObj.Case_End_Escalation_Owner__c != NULL && Trigger.oldMap.get(caseObj.Id).Case_End_Escalation_Owner__c != caseObj.Case_End_Escalation_Owner__c){
                //For BH method we assign (BH record id, start time field, end time field)
                decimal result = BusinessHours.diff(defaultBH.Id, caseObj.Case_Start_Escalation_Date__c, caseObj.Case_End_Escalation_Owner__c );
                //Result from the method is divided by 60*60*100 (milliseconds to be then converted into hours)
                Decimal resultingHours = result/(60*60*1000);
                //Populating result into our custom field & setting number of decimals
                caseObj.KPI_Escalation_Owner_Taking_Charge__c    = resultingHours.setScale(1); 
            }  
        }    
    } 

}