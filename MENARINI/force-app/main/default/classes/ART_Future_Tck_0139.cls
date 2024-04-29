public class ART_Future_Tck_0139 {

    @future
    public static void doUpdate(String serializedCustomerList){
        List<cgcloud__Account_Org_Unit__c> customerList = (List<cgcloud__Account_Org_Unit__c>)JSON.deserialize(serializedCustomerList, List<cgcloud__Account_Org_Unit__c>.class);

        update customerList;
    }

}