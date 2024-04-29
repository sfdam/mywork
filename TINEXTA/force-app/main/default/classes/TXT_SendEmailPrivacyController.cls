public without sharing class TXT_SendEmailPrivacyController {

    @AuraEnabled
    public static Boolean userHasAccess() {
        User currentUser = [SELECT Id, Country_comark__c FROM User WHERE Id =: UserInfo.getUserId()];
        if(currentUser.Country_comark__c == 'Queryo' || currentUser.Country_comark__c == 'ES') {
            return false;
        }

        return true;
    }

    @AuraEnabled
    public static List<EmailTemplate> getEmailTemplate(){
        List<EmailTemplate> results = new List<EmailTemplate>([SELECT Id, Name, Body FROM EmailTemplate WHERE DeveloperName = 'TXT_informativa_privacy_contitolari' /*OR DeveloperName = 'TXT_informativa_privacy'*/]);
        return results;
    }

    @AuraEnabled
    public static String sendEmail(Id templateId, String body, Id recordId, String objectName){
        Savepoint sp = Database.setSavepoint();
        try {
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();

            // List<String> toAddresses = new List<String>{'simone.martinello@tengroup.it'};
            // mail.setToAddresses(toAddresses);
        
            // Specify the name used as the display name.
            // mail.setSenderDisplayName(UserInfo.getName());
            
            // Specify the subject line for your email address.
            //mail.setSubject('Privacy Cliente');
            User u = [SELECT Id, Societa__c FROM User WHERE Id =: UserInfo.getUserId()];
            EmailTemplate em = [SELECT Id, DeveloperName FROM EmailTemplate WHERE Id =: templateId];

            String subject = u.Societa__c + ': ';
            if(em.DeveloperName == 'TXT_informativa_privacy_contitolari')
                subject += 'Informativa di contitolarità e consensi marketing';
            else
                subject += 'Informativa di contitolarità';

            mail.setSubject(subject);
            // mail.setTemplateId(templateId);
            mail.setTargetObjectId(recordId);
            mail.setTreatTargetObjectAsRecipient(true);
            String displayName = u.Societa__c;
            mail.setOrgWideEmailAddressId([SELECT Id FROM OrgWideEmailAddress WHERE DisplayName =: displayName].Id);


            //Eseguo il merge del template con il record associato
            List<Messaging.RenderEmailTemplateBodyResult> bodies = Messaging.renderEmailTemplate(UserInfo.getUserId(), null, new List<String>{body});

            //Se viene rilevato un errore durante il merge blocco l'invio
            if(bodies[0].getErrors() != null)
                throw new AuraHandledException('Errore');

            mail.setPlainTextBody(bodies[0].getMergedBody().replace('RecordId', recordId));
            // Send the email you have created.

            SObject record = recordId.getSobjectType().newSObject(recordId);
            record.put('Contitolarita_dati_TXT__c', 'SI');
            record.put('Data_Contitolarita_dati_TXT__c', Date.today());

            if(recordId.getSObjectType().getDescribe().getName() == 'Contact'){
                Contact cnt = [SELECT Id, AccountId, Email FROM Contact WHERE Id =: recordId];
                mail.setToAddresses(new String[]{cnt.Email});
                // SM - Privacy gestita solo sui singoli contatti
                // Account acc = [SELECT Id, Contitolarita_dati_TXT__c, Data_Contitolarita_dati_TXT__c FROM Account WHERE Id =: cnt.AccountId];

                // acc.Contitolarita_dati_TXT__c = 'SI';
                // acc.Data_Contitolarita_dati_TXT__c = Date.today();

                // update acc;
            } else {
                Lead l = [SELECT Id, Email FROM Lead WHERE Id =: recordId];
                mail.setToAddresses(new String[]{l.Email});
            }

            update record;

            Messaging.SendEmailResult[] res = Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });

        } catch (Exception e) {
            Database.rollback(sp);
            System.debug('@@@ error ' + e.getMessage());
            return e.getMessage() + ' -- ' + e.getStackTraceString();
        }

        return null;
    }

}