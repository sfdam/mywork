public without sharing class CalendarController {
    @auraEnabled
    public static List<User> getUsers(){
        return [SELECT Id, Name,LastName, FirstName FROM User WHERE isActive=:true LIMIT 50000];
    }

    @auraEnabled
    public static String getUserId(){   
        return UserInfo.getUserId();
    }


    @AuraEnabled
    public static List<Map<String,String>> getNoteAgentePicklist(){
        List<Map<String,String>> result = new List<Map<String,String>>();
        try {
            Schema.DescribeFieldResult F = Task.Note_Agente__c.getDescribe();
            List<Schema.PicklistEntry> P = F.getPicklistValues();

            for(Schema.PicklistEntry pe : P){
                result.add(
                    new Map<String,String>{
                        'label' => pe.getLabel(),
                        'value' => pe.getValue()
                    }
                );
            }

        } catch (Exception e) {

        }

        return result;
    }


    @auraEnabled
    public static Boolean createNewEvent( String start_time, String end_time, String user_id, String what_id, String sobjectName, 
                                          String title, String note, String noteAgente, String motivazioneChiamata, String location, 
                                          String descrizioneAttivita, String noteAttivita, Id contactId){
        User currUser = [SELECT Id, Name, Societa__c FROM User WHERE Id =: user_id LIMIT 1];
        
        Event e = new Event();
        e.StartDateTime = DateTime.valueOf(start_time);
        e.EndDateTime = DateTime.valueOf(end_time);

        // Innolva
        e.Note_Agente__c = noteAgente;
        e.Motivazione_chiamata__c = motivazioneChiamata;
        e.Location = location;
        e.Descrizione_Attivita__c = descrizioneAttivita;
        e.Note_Attivita__c = noteAttivita;
        
        if(currUser.Societa__c == 'CoMark'){
            if(sobjectName == 'Lead'){
                Lead currLead = [SELECT Id, Name, CoMark_Zona__c, Company FROM Lead WHERE Id =: what_id LIMIT 1];
                e.subject = currLead.Name + ' | '+ currLead.Company + (currLead.CoMark_Zona__c != null ? ' | '+ currLead.CoMark_Zona__c : '');
            }else if(sobjectName == 'Account'){
                Account currAcc = [SELECT Id, Name, CoMark_Zona__c FROM Account WHERE Id =: what_id LIMIT 1];
                e.subject = currAcc.Name +  (currAcc.CoMark_Zona__c != null ? ' | '+ currAcc.CoMark_Zona__c : '');
                //AMS-000006
                e.WhoId = contactId;
            }
        }else if(currUser.Societa__c == 'Warrant'){
            if(sobjectName == 'Lead'){
                Lead currLead = [SELECT Id, Name, country,state,street,Company,PostalCode,City FROM Lead WHERE Id =: what_id LIMIT 1];
                e.subject = currLead.Company + ' - '+ currLead.Name + (currLead.City != null ? ' - '+ currLead.City : '')+(currLead.State != null ? ' - '+ currLead.State : '');
                e.Location = ((currLead.Street != null ? currLead.Street+', ' : '') +
                             (currLead.PostalCode != null ? currLead.PostalCode+', ' : '') +
                             (currLead.City != null ? currLead.City+', ' : '') +
                             (currLead.State != null ? currLead.State+', ' : '') +
                             (currLead.Country != null ? currLead.Country+', ' : '')).removeEnd(', ');
            }else if(sobjectName == 'Account'){
                Account currAcc = [SELECT Id, Name, BillingStreet, BillingPostalCode, BillingCity, BillingState, BillingCountry FROM Account WHERE Id =: what_id LIMIT 1];
                e.subject = currAcc.Name+(currAcc.BillingCity != null ? ' - '+ currAcc.BillingCity : '')+ (currAcc.BillingState != null ? ' - '+ currAcc.BillingState : '');
                e.Location = ((currAcc.BillingStreet != null ? currAcc.BillingStreet+', ' : '') +
                             (currAcc.BillingPostalCode != null ? currAcc.BillingPostalCode+', ' : '') +
                             (currAcc.BillingCity != null ? currAcc.BillingCity+', ' : '') +
                             (currAcc.BillingState != null ? currAcc.BillingState+', ' : '') +
                             (currAcc.BillingCountry != null ? currAcc.BillingCountry+', ' : '')).removeEnd(', ');
            }else if(sobjectName == 'Contact'){
                Contact currCont = [SELECT Id, AccountId, Name FROM Contact WHERE Id =: what_id LIMIT 1];
                Account currAcc = [SELECT Id,Name, BillingStreet, BillingPostalCode, BillingCity, BillingState, BillingCountry FROM Account WHERE Id =: currCont.AccountId LIMIT 1];
                e.subject = currAcc.Name+ ' - '+currCont.Name + (currAcc.BillingCity!=null ? ' - ' + currAcc.BillingCity : '')+ (currAcc.BillingState!=null ? ' - ' + currAcc.BillingState : '');
                e.Location = ((currAcc.BillingStreet != null ? currAcc.BillingStreet+', ' : '') +
                             (currAcc.BillingPostalCode != null ? currAcc.BillingPostalCode+', ' : '') +
                             (currAcc.BillingCity != null ? currAcc.BillingCity+', ' : '') +
                             (currAcc.BillingState != null ? currAcc.BillingState+', ' : '') +
                             (currAcc.BillingCountry != null ? currAcc.BillingCountry+', ' : '')).removeEnd(', ');
            }
            
        }else{
            e.subject = title;
        }

        e.Description = note;
        e.OwnerId = user_id;
        
        if( sobjectName == 'Lead' || sobjectName == 'Contact' ){
            e.whoId = what_id;  
        }
        else{
            e.whatId = what_id; 
        }       
        INSERT e;
        return e.Id != null;
    }

    @auraEnabled
    public static String getEvents( DateTime start_time, DateTime end_time, String user_id ){
        Date dStartDate = Date.valueof(start_time);
        Date dEndDate   = Date.valueof(end_time);

        List<Event> evntList = [ SELECT StartDateTime, EndDateTime, Owner.Name, Subject, WhoId, WhatId, AccountId 
                                 FROM Event
                                 WHERE
                                    ( 
                                    // User selector
                                    OwnerId =: user_id 
                                    ) AND
                                    (
                                    (
                                        // scope contains event
                                        StartDateTime >=: dStartDate AND
                                        EndDateTime <=: dEndDate
                                    ) OR
                                    (
                                        // scope partically contains event
                                        (
                                        StartDateTime >=: dStartDate AND
                                        StartDateTime <=: dEndDate
                                        ) OR
                                        (
                                        EndDateTime >=: dStartDate AND
                                        EndDateTime <=: dEndDate
                                        )
                                    ) OR
                                    (
                                        // event contains scope
                                        StartDateTime <=: dStartDate AND
                                        EndDateTime >=: dEndDate
                                    )
                                    )
                                 LIMIT 50000  
                                ];

        Set<Id> leadListId = new Set<Id>();
        Set<Id> accListId  = new Set<Id>();
        Set<Id> contListId = new Set<Id>();

        for( Event a: evntList){
          if(String.isNotBlank(a.AccountId)) accListId.add(a.AccountId);
          if(String.isNotBlank(a.WhoId) && ((String)a.WhoId).substring(0, 3) == '00Q') leadListId.add(a.WhoId);
          if(String.isNotBlank(a.WhoId) && ((String)a.WhoId).substring(0, 3) == '003')contListId.add(a.WhoId);
        }

        Map<ID, Lead> leadMap = new Map<ID, Lead>([SELECT Id, Name, LastName, Company,PostalCode,City FROM Lead WHERE Id IN : leadListId ]);
        Map<ID, Account> accMap = new Map<ID, Account>([SELECT Id, Name, CAP_Sede_Legale__c, Citta_Sede_Legale__c FROM Account WHERE Id IN : accListId ]);
        Map<Id,Contact> contMap = new Map<ID, Contact>([SELECT Id, Name, AccountId, LastName, MailingCity,MailingPostalCode FROM Contact WHERE Id IN : contListId ]);

        LIST<CustomEvent> listEvent = new LIST<CustomEvent>();
        for( Event a: evntList){
          CustomEvent tmp = new CustomEvent(a, accMap, leadMap,contMap);      
          listEvent.add( tmp );
        }

        return JSON.serialize(listEvent).replace('end_time_x', 'end');      
    }


    public class CustomEvent{
        public String title {get;set;}
        public String start {get;set;}
        public String end_time_x {get;set;}
        public String id {get;set;}
        public String className {get;set;}
        public String objectId {get;set;}
        public String accountName {get;set;}
        public String accountCap {get;set;}
        public String accountCity {get;set;}
        public String leadName {get;set;}
        public String leadCap {get;set;}
        public String leadCity {get;set;}
        public String contName {get;set;}
        public String contCap {get;set;}
        public String contCity {get;set;}

        public CustomEvent( Event e, Map<ID, Account> accMap,  Map<ID, Lead> leadMap, Map<Id,Contact> contMap){
            this.title = e.subject;
            this.start = String.valueof( e.StartDateTime );
            this.end_time_x = String.valueof( e.EndDateTime );
            this.id = e.Id;
            // ACCOUNT

            this.objectId = e.AccountId != NULL ? e.AccountId :  e.WhoId != NULL ? e.WhoId : e.WhatId;
            this.accountName = e.AccountId != NULL ? accMap.get(e.AccountId).Name : NULL;
            this.accountCap = e.AccountId != NULL ? accMap.get(e.AccountId).CAP_Sede_Legale__c : NULL;
            this.accountCity = e.AccountId != NULL ? accMap.get(e.AccountId).Citta_Sede_Legale__c : NULL;
            // LEAD

            if(String.isNotBlank(e.WhoId) && ((String)e.WhoId).substring(0, 3) == '00Q'){
                this.leadName = e.WhoId != NULL ? leadMap.get(e.WhoId).Name : NULL;
                this.leadCap = e.WhoId != NULL ? leadMap.get(e.WhoId).PostalCode : NULL;
                this.leadCity = e.WhoId != NULL ? leadMap.get(e.WhoId).City : NULL;
            }
            if(String.isNotBlank(e.WhoId) && ((String)e.WhoId).substring(0, 3) == '003'){
                this.contName = e.WhoId != NULL ? contMap.get(e.WhoId).Name : NULL;
                this.contCap = e.WhoId != NULL ? contMap.get(e.WhoId).MailingPostalCode : NULL;
                this.contCity = e.WhoId != NULL ? contMap.get(e.WhoId).MailingCity : NULL;
            }
        }
    }

}