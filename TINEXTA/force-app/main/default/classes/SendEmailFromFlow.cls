public class SendEmailFromFlow {
    @InvocableMethod
    public static void SendEmail (List<list<String>> DataListList) {
        list<String> DataList = new list<String>(DataListList.get(0));
        list<String> EmailList = new list<String>();
        /* per allegare file alla mail
        list<String> ContentDocumentLinkList = new list<String>();
        list<String> FileIdList = new list<String>();*/
        String AddressCC = DataList.get(0);
        list<String> listCC =  new list<String>(AddressCC.split(','));
        String Subject = DataList.get(1);
        String Body = DataList.get(2);        
        String Address = DataList.get(3);
        //String OpportunityProductId = DataList.get(4);
        EmailList.add(Address);
        
        /* Nel caso in cui volessi allegare file alla mail
        map<id,Variante__c> VarianteMap = new Map<Id,Variante__c>([select id from Variante__c where Opportunita__c =:OpportunityId]);
        if(VarianteMap.size()>0){
            for(ContentDocumentLink Doc :[select id,ContentDocumentId,LinkedEntityId from ContentDocumentLink where LinkedEntityId in :VarianteMap.keySet()]){
                ContentDocumentLinkList.add(Doc.ContentDocumentId);
            }
            for(ContentVersion CV:[SELECT id,VersionData FROM ContentVersion WHERE ContentDocumentId in: ContentDocumentLinkList]){
                FileIdList.add(CV.id);
            }
        }*/
        OrgWideEmailAddress OrgWideEmail = [select id,Address, DisplayName from OrgWideEmailAddress where DisplayName = 'Test Flow'];
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setOrgWideEmailAddressId(OrgWideEmail.Id);
        mail.setToAddresses(EmailList);
        mail.setSubject(Subject);
        mail.setCharset('UTF-8');
        mail.setHTMLBody(Body);
        //mail.setWhatId(OpportunityProductId);
        mail.setCcAddresses(listCC);
        /* Sempre per gli allegati
        iF(FileIdList.size()>0){
        mail.setEntityAttachments(FileIdList);
        } */
        if(!Test.isRunningTest()) Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        
    }
}