public class THR_Spain_Utils {

    //elimina le informazioni del contatto
    public static Contact hideContactInfo(Contact c) {
        //assign null to specified fields
        c.FirstName = 'Contacto';
        c.LastName = 'Bloqueado';
        c.Phone = null;
        c.Email = null;
        c.MailingStreet = null;
        c.MailingCity = null;
        c.MailingPostalCode = null;
        c.MailingCountry = null;
        c.MailingCountryCode = null;
        c.MailingState = null;
        c.MailingStateCode = null;
        c.THR_NIF__c = null;
        c.THR_VAT_Number__c = null;
        c.MobilePhone = null;
        c.Mobile_2__c = null;

        return c;
    }

    //crea un contatto clone
    public static THR_FakeContact__c newFakeContact(Contact c) {
        //copy all fields from Contact to the new THR_FakeContact__c
        THR_FakeContact__c fc = new THR_FakeContact__c();
        fc.AccountId__c = c.AccountId;
        fc.AssistantName__c = c.AssistantName;
        fc.AssistantPhone__c = c.AssistantPhone;
        fc.Availability_time__c = c.Availability_time__c;
        fc.Birthdate__c = fc.Birthdate__c;
        fc.Community_Email__c = c.Community_Email__c;
        fc.CreatedById__c = c.CreatedById;
        fc.CreatedDate__c = c.CreatedDate;
        fc.Department__c = c.Department;
        fc.Description__c = c.Description;
        fc.DoNotCall__c = c.DoNotCall;
        fc.Druggist_s_shelves_number__c = c.Druggist_s_shelves_number__c;
        fc.Email__c = c.Email;
        fc.Email_2__c = c.Email_2__c;
        fc.Fax__c = c.Fax;
        fc.FirstName__c = c.FirstName;
        fc.ContactId__c = c.Id;
        fc.Jigsaw__c = c.Jigsaw;
        fc.JigsawContactId__c = c.JigsawContactId;
        fc.LastActivityDate__c = c.LastActivityDate;
        fc.LastCURequestDate__c = c.LastCURequestDate;
        fc.LastCUUpdateDate__c = c.LastCUUpdateDate;
        fc.LastModifiedDate__c = c.LastModifiedDate;
        fc.LastModifiedById__c = c.LastModifiedById;
        fc.LastName__c = c.LastName;
        fc.LastReferencedDate__c = c.LastReferencedDate;
        fc.LastViewedDate__c = c.LastViewedDate;
        fc.LeadSource__c = c.LeadSource;
        fc.MailingCity__c = c.MailingCity;
        fc.MailingCountry__c = c.MailingCountry;
        fc.MailingCountryCode__c = c.MailingCountryCode;
        fc.MailingPostalCode__c = c.MailingPostalCode;
        fc.MailingState__c = c.MailingState;
        fc.MailingStateCode__c = c.MailingStateCode;
        fc.MailingStreet__c = c.MailingStreet;
        fc.MiddleName__c = c.MiddleName;
        fc.MobilePhone__c = c.MobilePhone;
        fc.Mobile_2__c = c.Mobile_2__c;
        fc.THR_NIF__c = c.THR_NIF__c;
        fc.Name = c.Name;
        fc.Number_of_Cash_Desk__c = c.Number_of_Cash_Desk__c;
        fc.OwnerId__c = c.OwnerId;
        fc.Phone__c = c.Phone;
        fc.Phone_2__c = c.Phone_2__c;
        fc.Privacy_Consensus_Shared_Date__c = c.Privacy_Consensus_Shared_Date__c;
        fc.Privacy_Consensus__c = c.Privacy_Consensus__c;
        fc.Ref_2__c = c.Ref_2__c;
        fc.ReportsToId__c = c.ReportsToId;
        fc.Salutation__c = c.Salutation;
        fc.Suffix__c = c.Suffix;
        fc.THR_Country__c = c.THR_Country__c;
        fc.THR_ExternelContactKey__c = c.THR_ExternelContactKey__c;
        fc.THR_IdentificationCode__c = c.THR_IdentificationCode__c;
        fc.THR_Normalized_center_code_CNN__c = c.THR_Normalized_center_code_CCN__c;
        fc.Title__c = c.Title;
        fc.VAT_number__c = c.THR_VAT_Number__c;
        return fc;
    }

    //blocca un case quando il prodotto associato ha terminato il periodo di commercio (isActive = false)
    public static void THR_LockCaseDiscProdSpain(List<Case> caseList) {
        System.debug('@@@ THR_LockCaseDiscProdSpain START');
        Id Deleted_ContactId = [SELECT Id FROM Contact WHERE LastName = 'Bloqueado' LIMIT 1].Id;
        List<String> lstFieldNames = new List<String>(Contact.SObjectType.getDescribe().fields.getMap().keySet());
        Set<Id> contactIds = new Set<Id>();
        Map<Id, THR_FakeContact__c> oldConId_FakeCon = new Map<Id, THR_FakeContact__c>();

        for (Case c : caseList) {
            if(c.THR_Locked__c == false && c.THR_Contact__c == null) {
                contactIds.add(c.ContactId);
            }
        }
        List<Contact> contactList = Database.query('SELECT ' + String.join(lstFieldNames, ',')  + ' FROM Contact WHERE Id IN :contactIds');
        System.debug([SELECT Id, FirstName, LastName FROM Contact]);

        //crea un oggetto fakeContact e "sbianca" le informazioni del contatto
        for(Contact con : contactList) {
            oldConId_FakeCon.put(con.Id, newFakeContact(con));
            con = hideContactInfo(con);
        }
        insert oldConId_FakeCon.values(); //inserisce i nuovi contatti fake

        for(Case c : caseList) {
            if(oldConId_FakeCon.containsKey(c.ContactId)) {
                THR_FakeContact__c fc = oldConId_FakeCon.get(c.ContactId);
                //aggiorna il Case con l'Id del fakeContact
                c.THR_Contact__c = fc.Id;
                //assegna l'Id di "Contacto Bloqueado" al ContactId del Case
                c.ContactId = Deleted_ContactId;
                c.THR_Locked__c = true;
                c.THR_Locked_Date__c = Datetime.now();
            }
        }
        update contactList;
        update caseList;
        System.debug('@@@ THR_LockCaseDiscProdSpain END');

    }

}