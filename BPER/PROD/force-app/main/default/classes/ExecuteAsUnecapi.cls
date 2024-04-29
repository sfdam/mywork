@RestResource(urlMapping='/executeasunecapi')
global class ExecuteAsUnecapi {
    @HttpPost
    global static String executeDML(){

        try {
            
            System.debug('DK START executeDML');
            RestRequest req = RestContext.request;
            System.debug('DK req.requestBody.toString(): ' + req.requestBody);
            Map<String, Object> bodyMap = (Map<String, Object>)JSON.deserializeUntyped(req.requestBody.toString());
            List<SObject> recordList = (List<SObject>)JSON.deserialize(JSON.serialize(bodyMap.get('recordList')), List<SObject>.class);
            String operation = (String)bodyMap.get('operation');
    
            if(operation == 'insert'){
                insert recordList;
            }else if(operation == 'update'){
                update recordList;
            }else if(operation == 'upsert'){
                upsert recordList;
            }else if(operation == 'delete'){
                delete recordList;
            }
    
            return JSON.serialize(new Map<String, Object>{
                'recordList' => recordList
            });
        } catch (Exception ex) {
            return JSON.serialize(new Map<String, Object>{
                'errorMessage' => 'Error: ' + ex.getMessage() + '; at: ' + ex.getStackTraceString()
            });
        }
    }
}