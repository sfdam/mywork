@isTest
private class INF_ChangeOwnerLead_Test {
     @testSetup 
    static void setup() {
        List<Lead> leadtest=TestDataFactory.createLeads(1);
        leadtest[0].OwnerId='0052X000008vbxHQAQ';
        leadtest[0].Stato_Trasferimento__c= false;
        insert leadtest;
    }
    
@isTest static void testget(){
        Lead l = [SELECT Id,OwnerId,Stato_Trasferimento__c FROM Lead WHERE LastName='Test Lead' LIMIT 1];   
        INF_CustomChangeOwnerLead.WrapperResponse wr = new INF_CustomChangeOwnerLead.WrapperResponse();
         wr = INF_CustomChangeOwnerLead.getLead(l.Id);
    }   
    
    @isTest static void testgeteccezione(){
        INF_CustomChangeOwnerLead.WrapperResponse wr = new INF_CustomChangeOwnerLead.WrapperResponse();
         wr = INF_CustomChangeOwnerLead.getLead('005w00000045VR1AAM');
    }  

    
 @isTest static void testchange(){
        Lead l = [SELECT Id,OwnerId,Stato_Trasferimento__c FROM Lead WHERE LastName='Test Lead' LIMIT 1];   
        INF_CustomChangeOwnerLead.WrapperResponse wr = new INF_CustomChangeOwnerLead.WrapperResponse();
         wr = INF_CustomChangeOwnerLead.saveLead(l.Id);
    }
    
        @isTest static void testsaveeccezione(){
       INF_CustomChangeOwnerLead.WrapperResponse wr = new INF_CustomChangeOwnerLead.WrapperResponse();
         wr = INF_CustomChangeOwnerLead.saveLead('005w00000045VR1AAM');
    }  


}