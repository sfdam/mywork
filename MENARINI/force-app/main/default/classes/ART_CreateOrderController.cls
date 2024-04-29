public without sharing class ART_CreateOrderController {
    public ART_CreateOrderController() {

    }

    //DK START DE-067
    @AuraEnabled
    public static Object init(){
        try {

            Set<Id> userIdSet = new Set<Id>();
            User userInfo = [SELECT Id, ProfileId, Profile.Name FROM User WHERE Id =: UserInfo.getUserId()];
            if(userInfo.Profile.Name == 'CGCloud_Sales_Area_Manager'){
                for(cgcloud__Org_Unit_User__c unitUser : [SELECT cgcloud__User__c FROM cgcloud__Org_Unit_User__c WHERE ART_RelationshipType__c = 'WORKPLACE_OWNER' AND cgcloud__User__r.Profile.Name IN ('CGCloud_Area_Manager', 'CGCloud_User_Profile') AND cgcloud__Valid_From__c <= TODAY AND cgcloud__Valid_Thru__c >= TODAY]){
                    userIdSet.add(unitUser.cgcloud__User__c);
                }
            }else if(userInfo.Profile.Name == 'CGCloud_Area_Manager'){
                Set<String> childOrgUnitSet = new Set<String>();
                for(cgcloud__Org_Unit_Hierarchy__c orgUnitHiearchy : [SELECT cgcloud__Child_Org_Unit__c FROM cgcloud__Org_Unit_Hierarchy__c WHERE cgcloud__Parent_Org_Unit__c IN (SELECT cgcloud__Org_Unit__c FROM cgcloud__Org_Unit_User__c WHERE ART_RelationshipType__c = 'WORKPLACE_OWNER' AND cgcloud__User__c =: UserInfo.Id)]){
                    childOrgUnitSet.add(orgUnitHiearchy.cgcloud__Child_Org_Unit__c);
                }
                for(cgcloud__Org_Unit_User__c unitUser : [SELECT cgcloud__User__c FROM cgcloud__Org_Unit_User__c WHERE ART_RelationshipType__c = 'WORKPLACE_OWNER' AND cgcloud__Org_Unit__c IN: childOrgUnitSet AND cgcloud__Valid_From__c <= TODAY AND cgcloud__Valid_Thru__c >= TODAY]){
                    userIdSet.add(unitUser.cgcloud__User__c);
                }
            }else if(userInfo.Profile.Name == 'Contact Center Operator'){

                for(cgcloud__Org_Unit_User__c unitUser : [SELECT cgcloud__User__c FROM cgcloud__Org_Unit_User__c WHERE ART_RelationshipType__c = 'WORKPLACE_OWNER' AND cgcloud__User__r.Profile.Name IN ('Contact Center Operator') AND cgcloud__Valid_From__c <= TODAY AND cgcloud__Valid_Thru__c >= TODAY]){
                    userIdSet.add(unitUser.cgcloud__User__c);
                }
            }
            return new Map<String, Object>{
                'userInfo' => userInfo,
                'userIdSet' => userIdSet
            };
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    //DK END DE-067

    @AuraEnabled
    public static Account getAccountInfo(String accId){
        try {
            return [SELECT id, Name FROM Account WHERE id =: accId];
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    @AuraEnabled
    public static List<String> getAccIdFromManager(){
        System.debug('AT : getAccIdFromManager');
        List<String> accIdsFromManager = new List<String>();
        List<String> accIdsFromExtension = new List<String>();
        List<cgcloud__Product_Assortment_Order_Template__c> cpaotList = new List<cgcloud__Product_Assortment_Order_Template__c>();
        
        try {
            for(cgcloud__Account_Manager__c cam : [SELECT cgcloud__Account__c  
                                                    FROM cgcloud__Account_Manager__c 
                                                    WHERE cgcloud__Active__c  = true
                                                    AND  cgcloud__Management_Type__c = 'Sales' 
                                                    AND cgcloud__User__c = :UserInfo.getUserId()]){
                                                        accIdsFromManager.add(cam.cgcloud__Account__c);  

                                                    }
            for(cgcloud__Account_Extension__c accEx : [SELECT cgcloud__Account__c
                                                    FROM cgcloud__Account_Extension__c
                                                    WHERE cgcloud__Account__c IN :accIdsFromManager
                                                    AND cgcloud__Order_Role_Valid_From__c != null
                                                    AND cgcloud__Order_Role_Valid_Thru__c != null]){
                                                        accIdsFromExtension.add(accEx.cgcloud__Account__c);
                                                    }
                                                    
            
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        System.debug('AT : '+ accIdsFromExtension);
        return accIdsFromExtension;
    }
    @AuraEnabled
    public static List<cgcloud__Product_Assortment_Order_Template__c> getOrderTemplatePicklist(String accId){
        System.debug('AT : '+ accId);

        List<cgcloud__Product_Assortment_Order_Template__c> cpaotList = new List<cgcloud__Product_Assortment_Order_Template__c>();
        
        try {
            
            


            cpaotList =[SELECT cgcloud__Order_Template__c, cgcloud__Order_Template__r.Name
                        FROM  cgcloud__Product_Assortment_Order_Template__c
                        WHERE cgcloud__Product_Assortment__c IN (SELECT AssortmentId
                        FROM StoreAssortment
                        WHERE AccountId = :accId
                        )]; 
            
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        System.debug('AT : '+ cpaotList);
        return cpaotList;
    }

    @AuraEnabled
    public static string insertOrderTemplate(String accId,String orderTempId, String responsabile){

        List<cgcloud__Account_Relationship__c> accList = [SELECT cgcloud__Related_Account__c
                                                            FROM cgcloud__Account_Relationship__c
                                                            WHERE cgcloud__Account__c = :accId
                                                            AND cgcloud__Relationship_Type__c = 'Payer'
                                                            LIMIT 1
                                                            ] ;

        String orderId = '';
        cgcloud__Order__c order =  new cgcloud__Order__c();
        cgcloud__Order__share orderShare;
        try{
            order.cgcloud__Delivery_Recipient__c = accId;
            order.cgcloud__Delivery_Date__c = system.today();
            order.cgcloud__Distribution_Relevant__c = true;
            order.cgcloud__Document_Type__c  = 'OrderEntry';
            order.cgcloud__Mobility_Release__c = false;
            order.cgcloud__Initiation_Date__c  = system.today();
            order.cgcloud__Order_Account__c = accId;
            order.cgcloud__Order_Date__c  = system.today();
            order.cgcloud__Order_Template__c  = orderTempId;
            order.cgcloud__Payer__c  =  (accList.size() == 1) ? accList[0].cgcloud__Related_Account__c : null;
            order.cgcloud__Phase__c  =  'Initial';
            //DK START DE-067
            if(responsabile != null){
                order.cgcloud__Responsible__c  = responsabile;
                orderShare = new cgcloud__Order__share();
                orderShare.ParentId=order.Id;
                orderShare.UserOrGroupId=responsabile;
                orderShare.AccessLevel='Read';
            }else{
                order.cgcloud__Responsible__c = UserInfo.getUserId();
            }
            //DK END DE-067
            order.cgcloud__Accountable__c  = UserInfo.getUserId();

            insert order;
            orderId =  order.Id;
            
            //DK START DE-067
            if(orderShare != null){
                orderShare.ParentId = orderId;
                insert orderShare;
            }
            //DK END DE-067
        }catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        
        return orderId;
    }

}