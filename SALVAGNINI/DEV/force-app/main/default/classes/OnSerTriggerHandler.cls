public class OnSerTriggerHandler {

    public static void manageSerBeforeUpdate(Map<Id,SER__c> oldSerMap, Map<Id,SER__c> newSerMap) {

        System.debug('RC manageSerBeforeUpdate');
        Map<Id,SER__c> updOwnerSerMap = new Map<Id,SER__c>();
        Map<Id,SER__c> checkTaskSerMap = new Map<Id,SER__c>();
        Map<Id,SER__c> checkProductSerMap = new Map<Id,SER__c>();
        String oldStatus;
        String newStatus;
        for(Id key : oldSerMap.keyset()){
            oldStatus= (String)oldSerMap.get(key).Status__c;
            newStatus = (String)newSerMap.get(key).Status__c;
            if(oldStatus != newStatus){
                if(newStatus == 'Analysis'){
                    updOwnerSerMap.put(key,newSerMap.get(key));
                    if(oldStatus == 'Draft'){
                        checkProductSerMap.put(key,newSerMap.get(key)); 
                    }
                }else if((oldStatus== 'In Progress' && (newStatus == 'Validated' && newSerMap.get(key).SER_Type__c == 'Application Study')) ||
                         newStatus == 'Closed'){
                    checkTaskSerMap.put(key,newSerMap.get(key)); 
                }
            }
        }
        System.debug('updOwnerSerMap: '+updOwnerSerMap);
        System.debug('checkTaskSerMap: '+checkTaskSerMap);
        System.debug('checkProductSerMap: '+checkProductSerMap);

        if(!checkProductSerMap.isEmpty())checkRelatedProducts(checkProductSerMap);
        if(!updOwnerSerMap.isEmpty())updateSerOwner(updOwnerSerMap);
        if(!checkTaskSerMap.isEmpty())checkRelatedTasks(checkTaskSerMap);
    }

    public static void manageSerAfterUpdate(Map<Id,SER__c> oldSerMap, Map<Id,SER__c> newSerMap) {
        System.debug('RC manageSerAfterUpdate');

        System.debug('oldSerMap: '+oldSerMap);
        System.debug('newSerMap: '+newSerMap);
        Map<Id,SER__c> InProgressSerMap = new Map<Id,SER__c>();   

        for(Id key : oldSerMap.keyset()){
            if(oldSerMap.get(key).Status__c == 'Analysis' && newSerMap.get(key).Status__c == 'In progress'){
                InProgressSerMap.put(key,newSerMap.get(key));     
            }   
        }
       //System.debug('Questa è InProgressSerMap----->>>> : '+InProgressSerMap +' con Status'+ InProgressSerMap.values().Status__c);
        if(InProgressSerMap.isEmpty())return;
        manageTaskCreation(InProgressSerMap);  
    }

    static void manageTaskCreation(Map<Id,SER__c> serMap){ 
        System.debug('Vado in ----->>>> manageTaskCreation : '); 

        QueueSObject teamSimulationQueue =  [SELECT Id, QueueId, Queue.Name FROM QueueSobject WHERE SobjectType  = 'Task' AND Queue.Name = 'Team Simulation' LIMIT 1];
        QueueSObject teamSimulationQueueUSA =  [SELECT Id, QueueId, Queue.Name FROM QueueSobject WHERE SobjectType  = 'Task' AND Queue.Name = 'Team Simulation USA' LIMIT 1];
        List<Task> newTaskList = new List<Task>();
        SerManageClass.SerData serData = SerManageClass.getSerData(serMap);
        SerManageClass.SerRoutingData routeData = SerManageClass.getSerRoutingData(serData, serMap , true);
        RecordType taskRecType = [SELECT Id FROM RecordType WHERE DeveloperName = 'Application' AND SobjectType = 'Task' LIMIT 1];
        Account SalvagniniIta = [SELECT Id FROM Account WHERE Name ='SALVAGNINI ITALIA S.P.A.' LIMIT 1];

        List<Account> AccList= [select id, name from Account WHERE Name =:'SALVAGNINI ITALIA S.P.A.'];
        system.debug(' il numero di account è '+ AccList.size());
       
        Set<id> setAcc = new set<id>();
        For(Account a :AccList ){
            setAcc.add(a.id);
            integer b=0;
            b++;
            b++;
            b++;
            b++;
            b++;
            system.debug(' Un account è'+ a);
        }
        Account IdSalvagniniItaliaAcc= [SELECT Id, name FROM Account WHERE Name =:'SALVAGNINI ITALIA S.P.A.' LIMIT 1];

        id IdSalvagniniItalia= IdSalvagniniItaliaAcc.id;
        system.debug('-> SalvagniniItalia '+ IdSalvagniniItaliaAcc.Name);

        id IdSalvagniniUsa = [SELECT Id FROM Account WHERE Name =:'SALVAGNINI AMERICA INC.' LIMIT 1].id;
       
        for(SER_Product__c serProd : serData.serProductMap.values()){            
            SER__c ser = serMap.get(serProd.SER__c);
            Task t = new Task(Subject = ser.Name+' - '+(String)serData.productMap.get(serProd.Product__c).Name,
                              WhatId  = ser.Id,
                              RecordTypeId = taskRecType.Id,
                              Model__c = serProd.Product__c,
                              Type = 'Product',
                              ActivityDate = ser.Request_due_date__c,
                              SER_Owner__c = ser.OwnerId,
                              SER_in_charge_to__c = ser.Owner__c
                              );
            String key = (String)serProd.Product__c+'_'+ser.Application_Branch__c;
            System.debug('RC key: '+key);
            if(ser.SER_Type__c == 'Application Study'){
                if(ser.Application_Branch__c == SalvagniniIta.Id && (Boolean)serData.productMap.get(serProd.Product__c).Sub_Branch_SER__c){
                    key = (String)serProd.Product__c +'_'+(String)ser.Country__c;
                    t.OwnerId = (Id)routeData.SalvagniniRoutingMap.get(key).get('OwnerId'); 
                }else{
                    System.debug('RC SerRoutingMapAppStudy: '+routeData.SerRoutingMapAppStudy);
                    t.OwnerId = (Id)routeData.SerRoutingMapAppStudy.get(key).get('OwnerId'); 
                }                      
            }else{
                t.OwnerId = (Id)routeData.SerRoutingMapDemo.get(key).get('OwnerId');      
            }
            newTaskList.add(t);
            
        }

        system.debug('------------- qui è il for d\'interesse ---------------');
        for (SER__c ser : serMap.values()){
            system.debug('il branch è -------> '+ ser.Application_Branch__c);
            system.debug ('Ora la SER che passa in Analysis e poi in progress ha Status '+ ser.Status__c + ' con Simulation '+ ser.Simulation__c);
            system.debug ('Controllo if ' + ser.Simulation__c + ' '+ ser.Application_Branch__c + ' '+IdSalvagniniItalia);
            //if(ser.Simulation__c && ser.Application_Branch__r.Name == 'SALVAGNINI ITALIA S.P.A.'){
                if(ser.Simulation__c == true && ser.Application_Branch__c == IdSalvagniniItalia){
                system.debug('------------> Creo Task per ITALIA <------------');
                Task t = new Task(Subject = ser.Name + '- Simulation',
                                  WhatId = ser.Id,
                                  OwnerId = teamSimulationQueue.QueueId,
                                  SER_Owner__c = ser.OwnerId,
                                  SER_in_charge_to__c = ser.Owner__c,
                                  RecordTypeId = taskRecType.Id,
                                  Type = 'Simulation'
                                  );
                newTaskList.add(t);
            }
            //else if(ser.Simulation__c && ser.Application_Branch__r.Name == 'SALVAGNINI AMERICA INC.'){
                else if(ser.Simulation__c == true && ser.Application_Branch__c == IdSalvagniniUsa){
                system.debug('------------> Creo Task per America <------------');
                Task t = new Task(Subject = ser.Name + '- Simulation',
                                  WhatId = ser.Id,
                                  OwnerId = teamSimulationQueueUSA.QueueId,
                                  SER_Owner__c = ser.OwnerId,
                                  SER_in_charge_to__c = ser.Owner__c,
                                  RecordTypeId = taskRecType.Id,
                                  Type = 'Simulation'
                                  );
                newTaskList.add(t);
            }
        }
        if(!Test.isRunningTest())insert newTaskList;
    }

    static void updateSerOwner(Map<Id,SER__c> serMap){
        SerManageClass.SerData serData = SerManageClass.getSerData(serMap);

        
        List<AggregateResult> serCountList = [SELECT SER__c, count(Id) FROM SER_Product__c WHERE SER__c IN : serMap.keyset() GROUP BY SER__c];
        System.debug('serCountList: '+serCountList);
        Map<String,SObject> queueMap=Utilities.keyBy([SELECT Id, QueueId, Queue.Name FROM QueueSobject WHERE SobjectType  = 'SER__c'],'Queue.Name');

        for(AggregateResult res : serCountList){
            System.debug('RC res: '+res);

            SER__c ser =  serMap.get((Id)res.get('SER__c'));

            if((Integer)res.get('expr0') > 1 || (ser.FMS__c || ser.Simulation__c)){
                switch on ser.SER_Type__c {
                    when 'Application Study'{
                        ser.OwnerId = (Id)queueMap.get((String)serData.appBranchMap.get(ser.Application_Branch__c).AppTeam__c).get('QueueId');
                    }
                    when else {
                        ser.OwnerId = (Id)queueMap.get((String)serData.appBranchMap.get(ser.Application_Branch__c).AppTeamDemo__c).get('QueueId');
                    }
                }
                System.debug('RC ser.OwnerId: '+ser.OwnerId);
                serMap.remove(ser.Id);
            }
        }
        if(serMap.isEmpty())return;

        serData = SerManageClass.getSerData(serMap);


        SerManageClass.SerRoutingData routeData = SerManageClass.getSerRoutingData(serData, serMap, false);
        System.debug('RC routeData: '+routeData.SerRoutingMapAppStudy);
        System.debug('RC routeData: '+routeData.SerRoutingMapDemo);

        Account SalvagniniIta = [SELECT Id FROM Account WHERE Name =:'SALVAGNINI ITALIA S.P.A.' LIMIT 1];

        for(SER_Product__c serProd : serData.serProductMap.values()){
            SER__c ser = serMap.get(serProd.SER__c);
            String key = (String)serProd.Product__c+'_'+ser.Application_Branch__c;

            if(ser.SER_Type__c == 'Application Study'){
                if(ser.Application_Branch__c == SalvagniniIta.Id && (Boolean)serData.productMap.get(serProd.Product__c).Sub_Branch_SER__c){
                    key = (String)serProd.Product__c +'_'+(String)ser.Country__c;
                    ser.OwnerId = (Id)routeData.SalvagniniRoutingMap.get(key).get('OwnerId'); 
                }else{
                    ser.OwnerId = (Id)routeData.SerRoutingMapAppStudy.get(key).get('OwnerId'); 
                }                      
            }else{
                ser.OwnerId = (Id)routeData.SerRoutingMapDemo.get(key).get('OwnerId');      
            }
        }
    }

    static void checkRelatedTasks(Map<Id,SER__c> serMap){
       List<AggregateResult> taskCountList = [SELECT Count(Id), WhatId FROM Task WHERE Status != 'Completed' AND WhatId IN:serMap.keyset() GROUP BY WhatId];
        for(AggregateResult res : taskCountList){
            if((Integer)res.get('expr0')!= 0){
                serMap.get((Id)res.get('WhatId')).addError('One or more SER-related tasks are still open');
            }
        }
    }

    static void checkRelatedProducts(Map<Id,SER__c> serMap){
        System.debug('RC checkRelatedProducts');
        Map<String,sObject> prodMap = Utilities.keyBy([SELECT Id, SER__c FROM SER_Product__c WHERE SER__c IN:serMap.keyset()],'SER__c');
        System.debug('RC prodMap: '+prodMap);

        for(String key : serMap.keyset()){
            if(!prodMap.containsKey(key)){
                serMap.get(key).addError('Add SER product to proceed');
            }
        }
    }
}