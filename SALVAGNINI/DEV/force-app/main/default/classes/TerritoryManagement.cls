public class TerritoryManagement {

    public static List<Account> handleAccountTerritory(List<Account> accountList) {
        System.debug('accountList: '+accountList);
        List<String> accCountries = new List<String>();
        List<String> detByCountries  = new List<String>();
        List<String> detByStates= new List<String>();
        List<String> detByZips = new List<String>();
        List<Account> updAccountList = new List<Account>();

        for(Account acc : accountList){
            accCountries.add((String)acc.BillingCountryCode);
        }
        
        Map<String,SObject> countryMap = Utilities.keyBy([SELECT Id, Name, Determined_by__c, Country_Code__c FROM Country__c WHERE Country_Code__c IN: accCountries],'Country_Code__c');
        System.debug('RC countryMap: '+countryMap);
        for(Account acc : accountList){
            if(acc.BillingCountryCode != null && countryMap.containsKey(acc.BillingCountryCode)){
                System.debug('RC Determined_by__c 1: '+(String)countryMap.get(acc.BillingCountryCode).get('Determined_by__c'));
                switch on (String)countryMap.get(acc.BillingCountryCode).get('Determined_by__c') {
                    when  'Country'{
                        detByCountries.add((String)acc.BillingCountryCode);
                    }
                    when  'State or Province'{
                       if(acc.BillingStateCode!=null)detByStates.add((String)acc.BillingStateCode);
                    }
                    when  'Zip codes'{
                        System.debug('RC acc.BillingPostalCode: '+acc.BillingPostalCode);

                        detByZips.add((String)acc.BillingCountryCode);
                    }           
                    when else {
                        break;
                    }
                }
            }
        }  
        System.debug('RC detByCountries: '+detByCountries);
        System.debug('RC detByStates: '+detByStates);
        System.debug('RC detByZips: '+detByZips);

 

        Map<String,SObject> territoryCountryMap = Utilities.keyBy([SELECT Id, Name, Territory_Manager__c FROM Territory__c WHERE Area__r.Country_Code__c IN: detByCountries], 'Name');
        Map<String,SObject> territoryStateMap = new Map<String,SObject>();
        if(!detByStates.isEmpty()){
            territoryStateMap = Utilities.keyBy([SELECT Id, Name, Territory_Manager__c,State_Province_abbreviation__c FROM Territory__c WHERE State_Province_abbreviation__c IN: detByStates AND Area__r.Country_Code__c IN: accCountries], 'State_Province_abbreviation__c');
        }
        List<Territory__c> territoryZipList = [SELECT Id, Name, Territory_Manager__c, From_Zip__c, To_Zip__c FROM Territory__c WHERE Area__r.Country_Code__c IN: detByZips ORDER BY From_Zip__c ASC]; 
        System.debug('RC territoryCountryMap: '+territoryCountryMap);
        System.debug('RC territoryStateMap: '+territoryStateMap);
        System.debug('RC territoryZipList: '+territoryZipList);

        for(Account acc : accountList){
            if(acc.BillingCountryCode != null && countryMap.containsKey(acc.BillingCountryCode)){
                System.debug('RC Determined_by__c 2: '+(String)countryMap.get(acc.BillingCountryCode).get('Determined_by__c'));

                switch on (String)countryMap.get(acc.BillingCountryCode).get('Determined_by__c') {
                    when  'Country'{
                        String Country = (String)countryMap.get(acc.BillingCountryCode).get('Name');
                        acc.OwnerId = (Id)territoryCountryMap.get(Country).get('Territory_Manager__c');
                        acc.Territory__c = (Id)territoryCountryMap.get(Country).get('Id');
                    }
                    when  'State or Province'{
                        if(acc.BillingStateCode == null){acc.addError('Billing State/Province is mandatory for the selected country');}
                        if(!territoryStateMap.isEmpty()){
                            acc.OwnerId = (Id)territoryStateMap.get(acc.BillingStateCode).get('Territory_Manager__c');
                            acc.Territory__c = (Id)territoryStateMap.get(acc.BillingStateCode).get('Id');
                        }
                    }
                    when  'Zip codes'{
                        for(Territory__c terr :territoryZipList){
                            if(acc.BillingPostalCode == null){
                                System.debug('RC Error');
                                acc.addError('Billing Postal Code is mandatory for the selected country');
                            }
                            else if(Integer.valueOf(terr.From_Zip__c) <= Integer.valueOf(acc.BillingPostalCode) && Integer.valueOf(acc.BillingPostalCode) <= Integer.valueOf(terr.To_Zip__c)){
                                acc.OwnerId = (Id)(terr.Territory_Manager__c);
                                acc.Territory__c = (Id)terr.Id;
                            }
                        }
                    }           
                    when else {
                        //adderror
                        break;
                    }
                }
                updAccountList.add(acc);
            }
        }
        return updAccountList;
    }

    public static List<Lead> handleLeadTerritory(List<Lead> leadList) {
        System.debug('leadList: '+leadList);
        List<String> leadCountries = new List<String>();
        List<String> detByCountries  = new List<String>();
        List<String> detByStates= new List<String>();
        List<String> detByZips = new List<String>();
        List<Lead> updLeadList = new List<Lead>();

        for(Lead lead : leadList){
            if(lead.CountryCode != null){
                leadCountries.add((String)lead.CountryCode);
            }
            else{
                if(lead.Country != null){
                    Schema.DescribeFieldResult fieldResult = Schema.Lead.Countrycode.getDescribe();
                    List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
                    System.debug('Picklist::'+ple);
                    for( Schema.PicklistEntry f : ple){
                        if(f.getLabel() == lead.Country){
                            System.debug(f.getLabel() +'::'+ f.getValue());
                            leadCountries.add((String)f.getValue());
                            lead.CountryCode = f.getValue();
                        }
                    }
                }
            }
            
        }
        
        Map<String,SObject> countryMap = Utilities.keyBy([SELECT Id, Name, Determined_by__c, Country_Code__c FROM Country__c WHERE Country_Code__c IN: leadCountries],'Country_Code__c');
        System.debug('RC countryMap: '+countryMap);
        for(Lead lead : leadList){
            if(lead.CountryCode != null && countryMap.containsKey(lead.CountryCode)){
                System.debug('RC Determined_by__c 1: '+(String)countryMap.get(lead.CountryCode).get('Determined_by__c'));
                switch on (String)countryMap.get(lead.CountryCode).get('Determined_by__c') {
                    when  'Country'{
                        detByCountries.add((String)lead.CountryCode);
                    }
                    when  'State or Province'{
                        if(lead.StateCode!=null){detByStates.add((String)lead.StateCode);}
                        else{
                            if(lead.State != null){
                                Schema.DescribeFieldResult fieldResult = Schema.Lead.Statecode.getDescribe();
                                List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
                                System.debug('Picklist::'+ple);
                                for( Schema.PicklistEntry f : ple){
                                    if(f.getLabel() == lead.State){
                                        System.debug('STATE:: '+f.getLabel() +'::'+ f.getValue());
                                        detByStates.add((String)f.getValue());
                                        lead.StateCode = f.getValue();
                                    }
                                }
                            }
                        }
                    }
                    when  'Zip codes'{
                        detByZips.add((String)lead.CountryCode);
                    }           
                    when else {
                        break;
                    }
                }
            }
        }  
        System.debug('RC detByCountries: '+detByCountries);
        System.debug('RC detByStates: '+detByStates);
        System.debug('RC detByZips: '+detByZips);

 

        Map<String,SObject> territoryCountryMap = new Map<String,SObject>();
        if(!detByCountries.isEmpty()){
            territoryCountryMap = Utilities.keyBy([SELECT Id, Name, Territory_Manager__c FROM Territory__c WHERE Area__r.Country_Code__c IN: detByCountries], 'Name');
        }
        Map<String,SObject> territoryStateMap = Utilities.keyBy([SELECT Id, Name, Territory_Manager__c,State_Province_abbreviation__c FROM Territory__c WHERE State_Province_abbreviation__c IN: detByStates AND Area__r.Country_Code__c IN: leadCountries], 'State_Province_abbreviation__c');
        List<Territory__c> territoryZipList = [SELECT Id, Name, Territory_Manager__c, From_Zip__c, To_Zip__c FROM Territory__c WHERE Area__r.Country_Code__c IN: detByZips ORDER BY From_Zip__c ASC];
        
        System.debug('RC territoryCountryMap: '+territoryCountryMap);
        System.debug('RC territoryStateMap: '+territoryStateMap);
        System.debug('RC territoryZipList: '+territoryZipList);

        for(Lead lead : leadList){
            if(lead.CountryCode != null && countryMap.containsKey(lead.CountryCode)){
                System.debug('RC Determined_by__c 2: '+(String)countryMap.get(lead.CountryCode).get('Determined_by__c'));

                switch on (String)countryMap.get(lead.CountryCode).get('Determined_by__c') {
                    when  'Country'{
                        String Country = (String)countryMap.get(lead.CountryCode).get('Name');
                        lead.OwnerId = (Id)territoryCountryMap.get(Country).get('Territory_Manager__c');
                        lead.Territory__c = (Id)territoryCountryMap.get(Country).get('Id');
                    }
                    when  'State or Province'{
                        if(lead.StateCode == null){lead.addError('State/Province is mandatory for the selected country');}
                        if(!territoryStateMap.isEmpty()){
                            lead.OwnerId = (Id)territoryStateMap.get(lead.StateCode).get('Territory_Manager__c');
                            lead.Territory__c = (Id)territoryStateMap.get(lead.StateCode).get('Id');
                        }
                    }
                    when  'Zip codes'{
                        for(Territory__c terr :territoryZipList){
                            if(lead.PostalCode == null){
                                lead.addError('Postal Code is mandatory for the selected country');
                            }
                            else if(Integer.valueOf(terr.From_Zip__c) <= Integer.valueOf(lead.PostalCode) && Integer.valueOf(lead.PostalCode) <= Integer.valueOf(terr.To_Zip__c)){
                                lead.OwnerId = (Id)(terr.Territory_Manager__c);
                                lead.Territory__c = (Id)terr.Id;
                            }
                        }
                    }           
                    when else {
                        //adderror
                        break;
                    }
                }
                updLeadList.add(lead);
            }
        }
        return updLeadList;
    }
}