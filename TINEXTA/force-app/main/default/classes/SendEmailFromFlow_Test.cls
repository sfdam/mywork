@IsTest
public class SendEmailFromFlow_Test {
    @IsTest
    static void SendEmail() {
        list<String> DataList = new list<String>();
        list<List<String>> DataListList = new list<list<String>>();
                
        DataList.add('ciaocc@tengroup.it');
        DataList.add('oggetto email');
        DataList.add('testo email');
        //OpportunityLineItem opp = [select id from opportunityLineItem];
        //DataList.add(opp.Id);
        DataList.add('ciao@tengroup.it');
        DataListList.add(DataList);        
        SendEmailFromFlow.SendEmail(DataListList);
    }
}