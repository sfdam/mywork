public without sharing class QbleArricchimentoErrorScheduler implements Schedulable {

    public void execute(SchedulableContext ctx) {
        System.enqueueJob(new QbleArricchimentoError());
    }
}