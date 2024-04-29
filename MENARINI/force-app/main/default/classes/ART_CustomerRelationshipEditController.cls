public class ART_CustomerRelationshipEditController {

    @AuraEnabled
    public static List<cgcloud__Account_Relationship__c> selectCustomerRelationship(String customerRelationshipID){

        System.debug('AD selectCustomerRelationship');

        String accRelationShip='';
        List<cgcloud__Account_Relationship__c> cgAccount = new List<cgcloud__Account_Relationship__c>();
        try{

            cgAccount = [SELECT cgcloud__Account__c,cgcloud__Related_Account__c,ART_Customer_identification_code__c,
                                cgcloud__Account__r.Name,cgcloud__Related_Account__r.Name,
                                cgcloud__Relationship_Type__c,cgcloud__Start_Date__c,cgcloud__End_Date__c 
                                FROM cgcloud__Account_Relationship__c where Id =: customerRelationshipID];

            
        }catch(Exception e){
            accRelationShip='';
            System.debug('AD exception insertCustomer '+e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }


        return cgAccount;

    }
    
    @AuraEnabled
    public static void updateCustomerRelationship(String selectedCustomerId,String relatedCustomer,String relationshipType,String currentStartDate,String currentEndDate,String recordID){

        try{
            
            update new cgcloud__Account_Relationship__c(
                Id = recordID,
                cgcloud__Account__c            =selectedCustomerId,
                cgcloud__Related_Account__c    =relatedCustomer,
                cgcloud__Relationship_Type__c  =relationshipType,
                cgcloud__Start_Date__c = date.valueOf(currentStartDate),
                cgcloud__End_Date__c = date.valueOf(currentEndDate)
            ); 

        }catch(Exception e){
            System.debug('AD exception updateCustomerRelationship '+e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }

    }
}