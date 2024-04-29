@isTest private class CalcolaAccountOwnerInvocable_Test {
    @isTest static void testGetAccountOwnerId(){
        Account[] acc = TestDataFactory.createAccounts(1);
        insert acc;
        List<CalcolaAccountOwnerInvocable.ActionRequest> actReq = new List<CalcolaAccountOwnerInvocable.ActionRequest>();
        CalcolaAccountOwnerInvocable.ActionRequest a = new CalcolaAccountOwnerInvocable.ActionRequest();
        a.UserId = UserInfo.getUserId();
        a.AccountId = acc[0].Id;
        actReq.add(a);
        String[] res = new List<String>();
        res = CalcolaAccountOwnerInvocable.getAccountOwnerId(actReq);
    }
        

}