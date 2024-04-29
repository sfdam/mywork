@isTest
public class FeedbackControllerTest {

    @TestSetup
    static void makeData(){
        Account acc = new Account(Name = 'TestAccountFeedback', Data_Ultimo_Arricchimento__c = System.Today());
        insert acc;
        Insert new Event(Subject = 'Test', StartDateTime = System.Now(), EndDateTime = System.Now().addHours(2), WhatId = acc.Id);
        Insert new Product2(Name = 'TestProdFeedback');
    }

    @isTest
    public static void testSaveFeedbacks(){
        Event e = [SELECT Id, WhatId, Subject, AccountId FROM Event LIMIT 1];
        Product2 p = [SELECT Id FROM Product2 LIMIT 1];
        Feedback__c parentFeedback = new Feedback__c(IdEvento__c = e.Id);
        List<FeedbackController.ChildFeedbackWrapper> childFeedbacks = new List<FeedbackController.ChildFeedbackWrapper>();
        FeedbackController.ChildFeedbackWrapper child1 = new FeedbackController.ChildFeedbackWrapper();
        child1.createOpty = true;
        child1.childFeedback = new Feedback__c(Articolo__c = p.Id);
        child1.task = new Task(Subject = 'Test', Description = 'Test', ActivityDate = System.Today());
        FeedbackController.ChildFeedbackWrapper child2 = new FeedbackController.ChildFeedbackWrapper();
        child2.createOpty = false;
        child2.childFeedback = new Feedback__c();
        child2.task = new Task(Subject = 'Test', Description = 'Test', ActivityDate = System.Today());

        childFeedbacks.add(child1);
        childFeedbacks.add(child2);

        Test.startTest();
            FeedbackController.saveFeedback(e.Id, parentFeedback, childFeedbacks, new Task(Subject = 'Test', Description = 'Test', ActivityDate = System.Today()), new Event(Subject = 'Test', Description = 'Test', StartDateTime = System.now(), EndDateTime = System.now().addHours(1)));
            List<Feedback__c> children = new Feedback__c[]{new Feedback__c(ParentFeedback__c = parentFeedback.Id), new Feedback__c(ParentFeedback__c = parentFeedback.Id)};
            FeedbackController.saveChildFeedbacks(children);
            FeedbackController.getFeedbacks(parentFeedback.Id);
            FeedbackController.getParentEvent(e.Id);
            update parentFeedback;
        Test.stopTest();
    }

}