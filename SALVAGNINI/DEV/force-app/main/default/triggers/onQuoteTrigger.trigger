trigger onQuoteTrigger on SBQQ__Quote__c (after update, after insert, before insert) {
    
        if(Trigger.isUpdate){
            if(!CongaTermCreator.hasAlreadyRan){
                CongaTermCreator.hasAlreadyRan = true;
                system.debug('createConditions '+CongaTermCreator.hasAlreadyRan);
                CongaTermCreator.createConditions(JSON.serialize(Trigger.new[0]), Trigger.newMap.keyset());
            }
        }
        if(Trigger.isInsert && Trigger.isBefore){
            string country = [SELECT BillingCountry FROM Account WHERE Id = :Trigger.new[0].SBQQ__Account__c LIMIT 1].BillingCountry ;
            List<SBQQ__LookupData__c> lkData= [SELECT Price_Book__c, Price_Book__r.Type__c,Price_Book__r.Change__c FROM SBQQ__LookupData__c WHERE Active__c = true AND Default__c = true AND SVG_Country__c = :country AND Lookup_Data_Type__c = 'Price Book Assignment' ];
            List<String> PBIds = new List<String>();
            String uRoleId = UserInfo.getUserRoleId();
            String roleName = [SELECT Name FROM UserRole WHERE Id = :uRoleId]?.Name;
            //List<Pricebook2> PBList = [SELECT Id,Type__c FROM Pricebook2 Where Id IN :PBIds AND IsActive = true AND Default__c = true] ;
            if(lkData.size() > 0){
                string pbId = lkData[0].Price_Book__c;
                decimal change = lkData[0].Price_Book__r.Change__c;
                system.debug('LISTA PB: '+lkData);
                if(roleName != null && roleName.contains('PM Corporate')){
                    for(SBQQ__LookupData__c singlePB : lkData){
                        if(singlePB.Price_Book__r.Type__c == 'IC'){
                            pbId = singlePB.Price_Book__c;
                            change = singlePB.Price_Book__r.Change__c;
                        }   
                    }
                }   
                Trigger.new[0].SBQQ__PriceBookId__c = pbId;
                Trigger.new[0].Change_for_List_Area_Price__c = change;
            }

        }
        if(Trigger.isInsert && Trigger.isAfter){
            SharepointHandler.sendQuotestoSharepoint(Trigger.newMap);
        }
    
}