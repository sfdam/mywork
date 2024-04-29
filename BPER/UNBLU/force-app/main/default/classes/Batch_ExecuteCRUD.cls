global class Batch_ExecuteCRUD implements Database.Batchable<sObject>,Database.stateful {

    global List<Sobject> sobjectList{get;set;}
    global String query{get;set;}
    global String operation{get;set;}
    global Map<String, Object> fieldValueUpdate{get;set;}

    //variables
    global List<String> ndgBancaList{get;set;}

    global Database.QueryLocator  start(Database.BatchableContext BC) {
        
        /*if(sobjectList != null){
            return sobjectList;
        }else{*/
            System.debug('DK ndgBancaList: ' + JSON.serialize(ndgBancaList));
            return Database.getQueryLocator(query);
        // }
    }

    global void execute(Database.BatchableContext BC, List<sObject> scope) {
        if(fieldValueUpdate != null){
            for(SObject record : scope){
                for(String field : fieldValueUpdate.keySet()){
                    if(SV_Utilities.getType(fieldValueUpdate.get(field)) == 'Boolean'){

                        record.put(field, (Boolean)fieldValueUpdate.get(field));
                    }else if(SV_Utilities.getType(fieldValueUpdate.get(field)) == 'Id' ||
                    SV_Utilities.getType(fieldValueUpdate.get(field)) == 'String'){

                        record.put(field, (String)fieldValueUpdate.get(field));
                    }
                }
            }
        }

        if(operation == 'insert'){
            insert scope;
        }else if(operation == 'upsert'){
            upsert scope;
        }else if(operation == 'delete'){
            delete scope;
        }else if(operation == 'update'){
            update scope;
        }
    }

    global void finish(Database.BatchableContext BC) {
        BloccoIterController.notifyUsers(null, null, true);
   }
}