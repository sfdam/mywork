public without sharing class FeedbackController {

    @AuraEnabled
    public static List<Feedback__c> saveFeedback(Id recordId, Feedback__c feedback, List<ChildFeedbackWrapper> childFeedbacks, Task task, Event event){
        Savepoint sp = Database.setSavepoint();
        try{
            Id rtWarrantHubFeedback_Padre = Schema.SObjectType.Feedback__c.getRecordTypeInfosByName().get('Warrant_Padre').getRecordTypeId();
            Id rtWarrantHubFeedback_Figlio = Schema.SObjectType.Feedback__c.getRecordTypeInfosByName().get('Warrant_Figlio').getRecordTypeId(); 
            feedback.RecordTypeId = rtWarrantHubFeedback_Padre;

            //Solo per recuparare i veri dati dal padre
            Event parentEvent = [SELECT Id, WhatId, What.Name, WhoId, AccountId, Subject, Feedback_inserito__c, IsReminderSet, OwnerId, StartDateTime, WRT_Data_Feedback__c FROM Event WHERE Id =: recordId];

            //Solo se è un contact viene popolato
            Contact parentAccount;
            // Id contactId;
            String sobjectType;
            if(parentEvent.WhoId != null){
                sobjectType = parentEvent.WhoId.getSObjectType().getDescribe().getName();
                if(sobjectType == 'Contact')
                    parentAccount = [SELECT Id, AccountId FROM Contact WHERE Id =: parentEvent.WhoId LIMIT 1];
            }

            Boolean isAccount = parentEvent.WhatId != null ? parentEvent.WhatId.getSObjectType().getDescribe().getName() == 'Account' : false;

            feedback.Referente__c = parentAccount != null ? parentEvent.WhoId : null;
            feedback.Account__c = parentEvent.WhatId != null ? ( isAccount ? parentEvent.WhatId : null) : parentAccount?.AccountId;
            feedback.Lead__c = parentAccount == null ? parentEvent.WhoId : null;
            feedback.Data_Visita__c = parentEvent.StartDateTime;
            Insert feedback;

            //record padre da cui derivano gli eventi figli che vedono i vari partecipanti
            List<Event> childs = [SELECT Id, WhatId, What.Name, Subject, Feedback_inserito__c, IsReminderSet, OwnerId, isChild, WRT_Data_Feedback__c FROM Event WHERE WhatId =: parentEvent.WhatId AND WhoId =: parentEvent.WhoId AND Subject =: parentEvent.Subject AND IsChild = false AND StartDateTime =: parentEvent.StartDateTime];

            for(Event child : childs){
                child.Feedback__c = feedback.Id;
                child.Feedback_inserito__c = true;
                child.WRT_Data_Feedback__c = System.Now();
                child.WRT_Feedback_Modalita_Visita__c = feedback.Tipo_Visita__c == 'Da remoto' ? feedback.Tipo_Visita__c + ' (call/videoconf)' : feedback.Tipo_Visita__c;
            }

            Update childs;

            parentEvent.WRT_Data_Feedback__c = System.Now();
            parentEvent.Feedback_Inserito__c = true;
            parentEvent.WRT_Feedback_Modalita_Visita__c = feedback.Tipo_Visita__c == 'Da remoto' ? feedback.Tipo_Visita__c + ' (call/videoconf)' : feedback.Tipo_Visita__c;
            parentEvent.WRT_Stato_visita__c = feedback.Stato_visita__c;
            Update parentEvent;

            if(task != null){
                task.Esito_Chiamata__c = null;
                Insert task;
            }
            if(event != null){
                event.IsReminderSet = parentEvent.IsReminderSet;
                event.Esito_Chiamata__c = null;
                Insert event;
            }

            Date endQuarter = [SELECT EndDate FROM Period WHERE type = 'Quarter' and StartDate = THIS_FISCAL_QUARTER].EndDate;
            
            List<Feedback__c> newChildFeedbacks = new List<Feedback__c>();
            List<Opportunity> newOptys = new List<Opportunity>();
            List<Task> newTasks = new List<Task>();
            List<Event> newEvents = new List<Event>();
            List<FeedbackWrapper> feedbackWrapperList = new List<FeedbackWrapper>();

            //Recuper il record type per Warrant
            Schema.DescribeSObjectResult d = Schema.SObjectType.Opportunity; 
            Map<String,Schema.RecordTypeInfo> rtMapByName = d.getRecordTypeInfosByName();

            // if(parentEvent.WhatId != null){
            //     sobjectType = parentEvent.WhatId.getSObjectType().getDescribe().getName();
            //     System.debug('@@@ type ' + sobjectType);
            // } else if(parentEvent.WhoId != null){
            //     sobjectType = parentEvent.WhoId.getSObjectType().getDescribe().getName();
            //     System.debug('@@@ type ' + sobjectType);
            // }
            
            for(ChildFeedbackWrapper cfw : childFeedbacks){
                FeedbackWrapper feedWrap = new FeedbackWrapper();
                cfw.childFeedback.ParentFeedback__c = feedback.Id;
                cfw.childFeedback.RecordTypeId = rtWarrantHubFeedback_Figlio;
                cfw.childFeedback.Referente__c = parentAccount != null ? parentEvent.WhoId : null;
                // cfw.childFeedback.Account__c = parentEvent.WhatId != null ? parentEvent.WhatId : parentAccount?.AccountId;
                cfw.childFeedback.Account__c = parentEvent.WhatId != null ? ( isAccount ? parentEvent.WhatId : null) : parentAccount?.AccountId;
                cfw.childFeedback.Lead__c = parentAccount == null ? parentEvent.WhoId : null;
                cfw.childFeedback.Data_Visita__c = parentEvent.StartDateTime;

                
                if(cfw.createOpty){               
                    System.debug('@@@ parentEvent.WhatId ' + parentEvent.WhatId);
                    System.debug('@@@ parentEvent.WhatId ' + parentEvent.AccountId);
                    System.debug('@@@ cfw.childFeedback.Articolo__r.Name ' + cfw.childFeedback.Articolo__c);

                    Opportunity opp = new Opportunity(AccountId = parentEvent.WhatId != null ? ( isAccount ? parentEvent.WhatId : null) : parentAccount?.AccountId,
                        Name = 'FEED - ' + cfw.childFeedback.Articolo__r.Name,
                        StageName = 'Potenziali', 
                        CloseDate = endQuarter, 
                        RecordTypeId = rtMapByName.get('Warrant').getRecordTypeId(),
                        WH_Business_Area__c = cfw.childFeedback.Business_Area__c, 
                        TXT_ForecastCategory__c = 'None', 
                        OwnerId = UserInfo.getUserId(), 
                        Probability = 10);
                    newOptys.add(opp);
                    feedWrap.opportunity = opp;
                }

                if(cfw.task != null){
                    cfw.task.Esito_Chiamata__c = null;
                    newTasks.add(cfw.task);
                    feedWrap.task = cfw.task;
                }

                // if(cfw.event != null){
                //     cfw.event.WhatId = parentEvent.WhatId;
                //     cfw.event.IsReminderSet = parentEvent.IsReminderSet;
                //     cfw.event.Esito_Chiamata__c = null;
                //     newEvents.add(cfw.event);
                //     feedWrap.event = cfw.event;
                // }

                newChildFeedbacks.add(cfw.childFeedback);
                feedWrap.feedback = cfw.childFeedback;
                feedbackWrapperList.add(feedWrap);
            }

            if(!newOptys.isEmpty())
                Insert newOptys;
            if(!newTasks.isEmpty())
                Insert newTasks;
            // if(!newEvents.isEmpty())
            //     Insert newEvents;

            newChildFeedbacks.clear();
            for(FeedbackWrapper feedWrap : feedbackWrapperList){
                if(feedWrap.opportunity != null)
                    feedWrap.feedback.Opportunita__c = feedWrap.opportunity.Id;
                
                if(feedWrap.task != null)
                    feedWrap.feedback.IdTask__c = feedWrap.task.Id;

                newChildFeedbacks.add(feedWrap.feedback);
            }

            return newChildFeedbacks;

        } catch (Exception e){
            Database.rollback(sp);
            System.debug('@@@ Errore ' + e.getStackTraceString() + ' -- ' + e.getCause() + ' -- ' + e.getMessage());
            throw new AuraHandledException(e.getStackTraceString() + ' -- ' + e.getCause() + ' -- ' + e.getMessage());
        }
    }

    @AuraEnabled
    public static List<FeedbackWrapper> getFeedbacks(Id recordId){
        List<Feedback__c> feedbacks = new List<Feedback__c>();
        List<FeedbackWrapper> wrapper = new List<FeedbackWrapper>();
        if(recordId != null){
            feedbacks = [SELECT Id, Name, ParentFeedback__c, ParentFeedback__r.Name, Stato_visita__c, Tipo_Visita__c, Esito__c, Business_Area__c, Target__c, Opportunita__c, Opportunita__r.Name, IdTask__c, Articolo__c, Articolo__r.Name FROM Feedback__c WHERE ParentFeedback__c =: recordId ORDER BY CreatedDate DESC];
            Set<Id> idsTask = new Set<Id>();
            for(Feedback__c f : feedbacks){
                idsTask.add((Id)f.IdTask__c);
            }
            Map<Id,Task> task = new Map<Id,Task>([SELECT Id, Subject FROM Task WHERE Id IN: idsTask]);

            for(Feedback__c f : feedbacks){
                FeedbackWrapper newWrapper = new FeedbackWrapper();
                newWrapper.feedback = f;
                newWrapper.task = task.get((Id)f.IdTask__c);
                wrapper.add(newWrapper);
            }
        }

        return wrapper;
    }

    @AuraEnabled
    public static Event getParentEvent(Id recordId){
        return [SELECT WhatId, What.Name, WhoId, Who.Name, Subject, Feedback__c, Feedback__r.Name, Feedback__r.Stato_visita__c, Feedback__r.Esito__c, StartDateTime, Feedback__r.Tipo_Visita__c, Feedback__r.Business_Area__c, Feedback__r.Target__c FROM Event WHERE Id =: recordId];
    }

    @AuraEnabled
    public static void saveChildFeedbacks(List<Feedback__c> feedbacks){
        try{
            Insert feedbacks;
        } catch(Exception e){
            System.debug('@@@ exc ' + e.getStackTraceString());
        }
    }

    public class ChildFeedbackWrapper{
        @AuraEnabled public Feedback__c childFeedback {get;set;}
        @AuraEnabled public Boolean createOpty {get;set;}
        @AuraEnabled public Task task {get;set;}
        @AuraEnabled public Event event {get;set;}
    }

    public class FeedbackWrapper{
        @AuraEnabled public Feedback__c feedback;
        @AuraEnabled public Opportunity opportunity;
        @AuraEnabled public Task task;
        @AuraEnabled public Event event;
    }
}