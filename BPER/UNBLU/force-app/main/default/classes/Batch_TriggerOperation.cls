/***
 * Name			:	Batch_TriggerOperation
 * Author		:	Ezio Dal Bo @TEN
 * Create Date	:	2020-12-01
 * --------
 * Modify date	:	2021-03-09
 * Author		:	Ezio Dal Bo @TEN
 * Modify		:	Aggiunta logica per gestire 50000+ record
 ***/

global class Batch_TriggerOperation implements Database.Batchable<sObject>, Database.Stateful {
    
    global String sObjectType = '';
    global String operationType = '';
    global List<Sobject> sObjList = new List<SObject>();
    global List<List<Sobject>> objs = new List<List<SObject>>();
    
    global List<sObject> start(Database.BatchableContext BC) {
        operationType = operationType.toLowerCase();
        List<sObject> sobjectToManage = new List<sObject>();
        if (sObjList.size()>0) {
            do {
                List<sObject> lobjs = new List<sObject>();
                do {
                    sObject so = sObjList.remove(0);
                    lobjs.add(so);
                } while(sobjList.size()>0 && lobjs.size()<50000);
                objs.add(lobjs);
            }while(sObjList.size()>0);
        }
        sObjList = (objs.size()>0 ? objs.remove(0) : new List<sObject>());
        return sObjList;
    }
    
    global void execute(Database.BatchableContext BC, List<sObject> scope) {
        if ('delete'.equals(operationType)) {
            Database.delete(scope, false);
            //delete scope;
        }
        if ('insert'.equals(operationType)) {
            Database.insert(scope,false);
            //insert scope;
        }
        if ('update'.equals(operationType)) {
            Database.update(scope, false);
            //update scope;
        }
        
    }
    
    global void finish(Database.BatchableContext BC) {
        
        if (objs.size()>0 && !Test.isRunningTest()) {
            Batch_TriggerOperation bto = new Batch_TriggerOperation();
            bto.sObjectType = sObjectType;
            bto.operationType = operationType;
            //bto.sObjList = sObjList;
            bto.objs = objs;
            Database.executeBatch(bto,200);
        }
    }
}