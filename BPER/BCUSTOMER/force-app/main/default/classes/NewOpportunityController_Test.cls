@isTest
public class NewOpportunityController_Test {
	
    @isTest
    static void getRecordTypes_Test(){
        List<String> currentList = new List<String>();
        String currentRecordType = 'Structured Finance';
        currentList.add(currentRecordType);

        NewOpportunityController.getRecordTypes();
        NewOpportunityController.getRecordtypeSelected(currentRecordType);


    }

}