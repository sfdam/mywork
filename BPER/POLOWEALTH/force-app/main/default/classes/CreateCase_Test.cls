@isTest
public class CreateCase_Test {
    
    @isTest
    static void testCreateCaseUnblu(){
        
        Map<String,Object> result = new Map<String,Object>();
        result.put('CRM_CodiceFiscalePartitaIva__c','tesrtsdfs');
        result.put('CRM_CryptoString__c','');
        result.put('CRM_MotivoDellaChat__c','test');
        result.put('CRM_WebChannelEmail__c','test@test.it');
        result.put('CRM_WebChannelName__c','unblu');
        result.put('Data_di_nascita__c','2023/01/12');
        
        Map<String,Object> result1 = new Map<String,Object>();
        result1.put('visitorData',result);
        result1.put('id','unbluid');
        
        Map<String,Object> result2 = new Map<String,Object>();
        result2.put('id','unbluid');
        result2.put('conversation',result1);
        
        
        
        Test.startTest();
        CreateCase.createCaseFromUnbluChat(result2);
        Test.stopTest();
        
    }
    
}