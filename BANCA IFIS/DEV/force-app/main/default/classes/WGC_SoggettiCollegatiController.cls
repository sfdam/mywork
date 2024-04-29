public class WGC_SoggettiCollegatiController {

    @AuraEnabled
    public static WrapperResponse getSogettiCollegati(String accountId, String type) {
        
        WrapperResponse result = new WrapperResponse();
        Integer counter = 0;

        try{

            //A.M. CR334 -> Start
            //Account acc = [ SELECT Id, Ateco__c, BillingPostalCode, CodiceIstituto3N__c, NDGGruppoGiuridico__c, Filiale__c, Fatturato__c FROM Account WHERE Id =: accountId];
            Account acc = [ SELECT Id, Ateco__c, BillingPostalCode, CodiceIstituto3N__c, NDGGruppoGiuridico__c, Filiale__c, Fatturato__c, BillingState FROM Account WHERE Id =: accountId];
	        //A.M. CR334 -> End

            switch on type {
                when 'Competitors' {
                    // code block 1
					//adione - CR ID82 - fasce di Fatturato per report Competitor
					Integer midFatt=10000; //10 milioni in migliaia
					Integer maxFatt=50000; //50 milioni in migliaia
					Integer min,max=0;
					if (acc.Fatturato__c >= maxFatt) {
						min=midFatt;
						max=maxFatt;
					} else if (acc.Fatturato__c >= midFatt) {
						min=midFatt;
						max=maxFatt;
					} else {
						min=0;
						max=midFatt;
					}
                    //A.M. CR334 -> Start
                    //counter = [ SELECT COUNT() FROM Account WHERE Ateco__c =: acc.Ateco__c AND RecordType.DeveloperName != 'WGC_Tribunale' AND CodiceIstituto3N__c =: acc.CodiceIstituto3N__c AND Ateco__c != '' AND Id !=: accountId AND Filiale__c =: acc.Filiale__c AND Fatturato__c >= :min AND Fatturato__c <= :max];
                    counter = [ SELECT COUNT() FROM Account WHERE Ateco__c =: acc.Ateco__c AND RecordType.DeveloperName != 'WGC_Tribunale' AND CodiceIstituto3N__c =: acc.CodiceIstituto3N__c AND Ateco__c != '' AND Id !=: accountId AND BillingState =: acc.BillingState AND Fatturato__c >= :min AND Fatturato__c <= :max];
                    //A.M. CR334 -> End 
                }	
                when 'Vicinanza geografica' {
                    // code block 2
                    counter = [ SELECT COUNT() FROM Account WHERE BillingPostalCode =: acc.BillingPostalCode AND RecordType.DeveloperName != 'WGC_Tribunale' AND CodiceIstituto3N__c =: acc.CodiceIstituto3N__c AND BillingPostalCode != '' AND Id !=: accountId ];
                }
                when 'Tribunali' {
                    // code block 3
                    List<AggregateResult> tribList = new  List<AggregateResult>([ SELECT Assuntore__c FROM Opportunity WHERE Assuntore__c != '' AND RecordType.DeveloperName = 'IFISOpportunitaFastFinance' AND AccountId =: accountId GROUP BY  Assuntore__c ]);

                    counter = tribList.size();
                }
                when 'Gruppi' {
                    // code block 4
                    counter = [ SELECT COUNT() FROM Account WHERE NDGGruppoGiuridico__c =: acc.NDGGruppoGiuridico__c AND RecordType.DeveloperName != 'WGC_Tribunale' AND CodiceIstituto3N__c =: acc.CodiceIstituto3N__c AND NDGGruppoGiuridico__c != '' AND Id !=: accountId ];
                }
                when else {		  // default block, optional
                    // code block 5
                }
            }

            result.data = counter;

        } catch(Exception e){
            result.success = false;
            result.msg = e.getMessage();
            return result;
        }
        
        return result;
        
    }

    /*..........................................*/
    /* Wrapper class to display Response       */
    /*.........................................*/
    
    public class WrapperResponse {
        
        @AuraEnabled public Boolean success;
        @AuraEnabled public String msg;
        @AuraEnabled public Integer data;
        
        public WrapperResponse(){
            success = true;
            msg = '';
        }
    }

}