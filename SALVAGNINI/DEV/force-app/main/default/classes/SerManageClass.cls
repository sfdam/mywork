public class SerManageClass {


    public class SerData{
        public Map<Id,SER_Product__c> serProductMap = new Map<Id,SER_Product__c>();
        public Map<Id,Product2> productMap = new Map<Id,Product2>();
        public Map<Id,Account> appBranchMap = new Map<Id,Account>();
    }

    public class SerRoutingData{
        public Map<String,sObject> SerRoutingMapAppStudy = new Map<String,sObject>();
        public Map<String,sObject> SerRoutingMapDemo = new Map<String,sObject>();
        public Map<String,sObject> SalvagniniRoutingMap = new Map<String,sObject>();

    }

    public static SerData getSerData(Map<Id,SER__c> serMap){
        SerData data = new SerData();
        Set<Id> appBranchIdSet = new Set<Id>();
        List<Id> productIds = new List<Id>();
        for(SER__c ser : serMap.values()){
            appBranchIdSet.add(ser.Application_Branch__c);
        }
        data.serProductMap = new Map<Id,SER_Product__c>([SELECT Id,Product__c,SER__c FROM SER_Product__c WHERE SER__c IN :serMap.keyset()]);
        data.appBranchMap = new Map<Id,Account>([SELECT Id,Name,AppTeam__c,AppTeamDemo__c FROM Account WHERE Id IN: appBranchIdSet]);
        for(SER_Product__c serProd : data.serProductMap.values()){
            productIds.add(serProd.Product__c);
        }
        data.productMap = new Map<Id,Product2>([SELECT Id,Name,Sub_Branch_SER__c FROM Product2 WHERE Id IN: productIds]);    
        return data;    

    }

    public static SerRoutingData getSerRoutingData(SerData data, Map<Id,Ser__c> serMap,Boolean isTaskRouting){
        System.debug('RC getSerRoutingData');

        Map<String,String> AppStudyModelToAppBranchMap = new Map<String,String>();
        List<Id> AppStudyModels = new List<Id>();
        List<Id> AppStudyBranches = new List<Id>();
        Map<String,String> DemoModelToAppBranchMap = new Map<String,String>();
        List<Id> DemoModels = new List<Id>();
        List<Id> DemoBranches = new List<Id>();
        Set<Id> SalvagniniModels = new Set<Id>();
        Set<String> SalvaginiSerCountries = new Set<String>();
        SerRoutingData routeData = new SerRoutingData();
        System.debug('serMap: '+serMap);
        System.debug('data: '+data);

        System.debug('isTaskRouting: '+isTaskRouting);
        Account SalvagniniIta = [SELECT Id FROM Account WHERE Name =:'SALVAGNINI ITALIA S.P.A.' LIMIT 1];
        System.debug('MAtteo: '+SalvagniniIta);

        for(SER_Product__c serProd : data.serProductMap.values()){
            SER__c ser = serMap.get(serProd.SER__c);
            Product2 prod = data.productMap.get(serProd.Product__c);
            switch on (String)ser.SER_Type__c{
                when 'Application Study'{
                    if(ser.Application_Branch__c == SalvagniniIta.Id && prod.Sub_Branch_SER__c){
                        SalvagniniModels.add(prod.Id);
                        SalvaginiSerCountries.add((String)ser.Country__c);
                    }else{
                        AppStudyModels.add(serProd.Product__c);
                        AppStudyBranches.add(ser.Application_Branch__c);
                        AppStudyModelToAppBranchMap.put(serProd.Product__c+'_'+ser.Application_Branch__c,ser.Id);
                    }      
                }when else{
                    DemoModels.add(serProd.Product__c);
                    DemoBranches.add(ser.Application_Branch__c);
                    DemoModelToAppBranchMap.put(serProd.Product__c+'_'+ser.Application_Branch__c,ser.Id); 
                }
            }
        }

        System.debug('AppStudyModels: '+AppStudyModels);
        System.debug('AppStudyBranches: '+AppStudyBranches);
        System.debug('AppStudyModelToAppBranchMap: '+AppStudyModelToAppBranchMap);
        System.debug('DemoModels: '+DemoModels);
        System.debug('DemoBranches: '+DemoBranches);
        System.debug('DemoModelToAppBranchMap: '+DemoModelToAppBranchMap);


        if(!AppStudyModels.isEmpty()){
            routeData.SerRoutingMapAppStudy = isTaskRouting ? Utilities.keyBy([SELECT Id, OwnerId,Product__c,SER_Type__c,Application_Branch__c  FROM SER_Routing__c WHERE Product__c IN: AppStudyModels AND SER_Type__c ='Task-Study' AND Application_Branch__c IN: AppStudyBranches],'{Product__c}_{Application_Branch__c}',true) : 
                                                              Utilities.keyBy([SELECT Id, OwnerId,Product__c,SER_Type__c,Application_Branch__c  FROM SER_Routing__c WHERE Product__c IN: AppStudyModels AND SER_Type__c ='Application Study: FMS and Simulation = FALSE' AND Application_Branch__c IN: AppStudyBranches],'{Product__c}_{Application_Branch__c}',true);
        }
        if(!DemoModels.isEmpty()){
            routeData.SerRoutingMapDemo = isTaskRouting ? Utilities.keyBy([SELECT Id, OwnerId,Product__c,SER_Type__c,Application_Branch__c  FROM SER_Routing__c WHERE Product__c IN: DemoModels AND (SER_Type__c ='Task-Demo & Sampling')  AND Application_Branch__c IN: DemoBranches],'{Product__c}_{Application_Branch__c}',true) :
                                                          Utilities.keyBy([SELECT Id, OwnerId,Product__c,SER_Type__c,Application_Branch__c  FROM SER_Routing__c WHERE Product__c IN: DemoModels AND (SER_Type__c ='Demo & Sampling')  AND Application_Branch__c IN: DemoBranches],'{Product__c}_{Application_Branch__c}',true);
        }
        if(!SalvagniniModels.isEmpty()){
            routeData.SalvagniniRoutingMap = isTaskRouting ? Utilities.keyBy([SELECT Id, OwnerId,Product__c,SER_Type__c,Application_Branch__c,Country__c  FROM SER_Routing__c WHERE Product__c IN: SalvagniniModels AND SER_Type__c ='Task-Study' AND Country__c IN:SalvaginiSerCountries AND Application_Branch__c =: SalvagniniIta.Id],'{Product__c}_{Country__c}',true):
                                                             Utilities.keyBy([SELECT Id, OwnerId,Product__c,SER_Type__c,Application_Branch__c,Country__c  FROM SER_Routing__c WHERE Product__c IN: SalvagniniModels AND SER_Type__c ='Application Study: FMS and Simulation = FALSE' AND Country__c IN:SalvaginiSerCountries AND Application_Branch__c =: SalvagniniIta.Id],'{Product__c}_{Country__c}',true);
        }
        return routeData;

    }


    
   
}