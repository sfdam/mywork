public class NewOpportunityController {
	@AuraEnabled
    public static List<String> getRecordTypes(){
        List<String> listOfRecordTypes = new List<String>();
        
        List<SelectOption> recordTypes = new List<SelectOption>();
        for(RecordTypeInfo info: Opportunity.SObjectType.getDescribe().getRecordTypeInfos()) {
            if(info.isAvailable()) {
                recordTypes.add(new SelectOption(info.getRecordTypeId(), info.getName()));
            }
        }
        System.debug('DEBUG***** recordTypes is: '+recordTypes);
        //listOfRecordTypes = [SELECT Id,SobjectType,DeveloperName FROM RecordType WHERE SobjectType = 'Opportunity'];
        for( SelectOption selopt: recordTypes ) {
            System.debug( 'DEBUG***************** '+selopt.getLabel() + ',' + selopt.getValue() );
            if(selopt.getLabel() != 'Master' && selopt.getLabel() != 'Principale'){
                listOfRecordTypes.add(selopt.getLabel());
            }
            
        }
        
        System.debug( 'DEBUG***************** listOfRecordTypes is: '+listOfRecordTypes);
        return listOfRecordTypes;
    }

    @AuraEnabled
    public static String getRecordtypeSelected(String recordType){
        String idRecordType;

        String result = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get(recordType).getRecordTypeId();
        System.debug( 'DEBUG***************** result is: '+result);

        idRecordType = result;


        return idRecordType;
    }
}