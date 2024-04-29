/**
* Controller of multipleAssignement LWC
*
* @author  Dam Kebe @Lutech
* @version 1.0
* @since   2020-07-27
*/
@isTest
public class Batch_CalcoloReferentiTest {
    // @isTest
    // public static void testGetMicroPortafoglio(){

    //     List<Wallet__c> microPortafoglio = [SELECT id, PTF_Filiale__c, PTF_ModelloDiServizio__c FROM Wallet__c LIMIT 1];
    //     Wallet__c retrievedMW = ManageGestoriController.getMicroPortafoglio(microPortafoglio[0].Id);
    //     System.assert(microPortafoglio[0].Id == retrievedMW.Id, 'error');
    // }

   @isTest(SeeAllData=true)
   private static void testExecute(){
       Database.executeBatch(new Batch_CalcoloReferenti(),1000);
   }
}