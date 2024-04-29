/**
 * @Author        : Alessandro Lumaca @TEN 
 * @CreateDate    : 2023-08-31
 * @Description   : metodo getRelatedCustomer : prelievo dato cgcloud__Account__c da cgcloud__Account_Extension__c in base al relationshipType
 * @Description   : metodo insertCustomer : creazione relazione "cgcloud__Account_Relationship__c" in base ai dati passati

 */
public class ART_CustomerRelationshipNewController {
    

    @AuraEnabled
    public static List<cgcloud__Account_Extension__c> getRelatedCustomer(String relationshipType){
        
        List<cgcloud__Account_Extension__c> accList = new List<cgcloud__Account_Extension__c>();

        try {

            String query = '';

            switch on relationshipType {
                when 'Payer' {
                    query = 'SELECT cgcloud__Account__c from cgcloud__Account_Extension__c where cgcloud__Payer_Role_Valid_From__c <= TODAY AND cgcloud__Payer_Role_Valid_Thru__c >= TODAY';

                }
                when 'Wholesaler' {
                    query = 'SELECT cgcloud__Account__c from cgcloud__Account_Extension__c where cgcloud__Broker_Role_Valid_From__c <= TODAY AND cgcloud__Broker_Role_Valid_Thru__c >= TODAY';

                }
            }


            accList = Database.query(query);
        } catch (Exception e) {
            System.debug('AD exception occurred '+e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }

        //if(accList.size()>0){}
            return accList;
        
    }

    @AuraEnabled
    public static String insertCustomer(String selectedCustomerId,String relatedCustomer,String relationshipType,String currentStartDate,String currentEndDate){

        System.debug('AD insertCustomer');
        System.debug('AD insertCustomer selectedCustomerId : ' + selectedCustomerId);
        System.debug('AD insertCustomer relatedCustomer : ' + relatedCustomer);
        System.debug('AD insertCustomer relationshipType : ' + relationshipType);
        System.debug('AD insertCustomer currentStartDate : ' + currentStartDate);
        System.debug('AD insertCustomer currentEndDate : ' + currentEndDate);

        System.debug('AD insertCustomer date.parse(currentStartDate) : ' + date.valueOf(currentStartDate));
        System.debug('AD insertCustomer  date.parse(currentEndDate) : ' +  date.valueOf(currentEndDate));
        

        String accRelationShip='';
        try{

            cgcloud__Account_Relationship__c cgAccount = new cgcloud__Account_Relationship__c();

            cgAccount.cgcloud__Account__c            =selectedCustomerId;
            cgAccount.cgcloud__Related_Account__c    =relatedCustomer;
            cgAccount.cgcloud__Relationship_Type__c  =relationshipType;
            cgAccount.cgcloud__Start_Date__c = date.valueOf(currentStartDate);
            cgAccount.cgcloud__End_Date__c = date.valueOf(currentEndDate);

            insert cgAccount;
            accRelationShip = cgAccount.id;
            /*  
            Database.SaveResult sr = Database.Insert(cgAccount);
            if(sr.isSuccess()){
                checkSave=true;

            }*/



        }catch(Exception e){
            accRelationShip='';
            System.debug('AD exception insertCustomer '+e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }


        return accRelationShip;

    }
}