public with sharing class QuoteTriggerHandler {

    public static boolean skipTrigger = false;

    public static Set<String> dapCountrySet = new Set<String> {'Spain', 'France', 'Portugal'};
    public static Set<String> ddpCountrySet = new Set<String> {'P.R. China', 'India'};
    
    public static Set<String> ttCountrySet = new Set<String> {'Austria', 'France', 'Germany', 'Italy', 'Liechtenstein', 'Switzerland'};
    public static Set<String> ttNoCountrySet = new Set<String> {'Denmark', 'Sweden', 'Norway'};
    
    public static Set<String> typeSet = new Set<String> {'Order Confirmation', 'Quote'};
    public static Map<String, String> lawStateMap = new Map<String, String> {
        'SALVAGNINI ITALIA S.P.A.' => 'Italy', 
        'SALVAGNINI MASCHINENBAU GMBH' => 'Austria'
    };

    public static Map<String, String> countryVoltageMap = new Map<String, String> {
        'Argentina' => '380 Volts - 50 Hz', 
        'Australia' => '415 V / 50 Hz',
        'Azerbaijan' => '380 Volts - 50 Hz',
        'Brazil' => '380 Volts - 60 Hz',
        'Chile' => '380 Volts - 50 Hz',
        'Egypt' => '380 Volts - 50 Hz',
        'Japan' => '3-phase, 200 V. 50Hz',
        'Morocco' => '380 Volts - 50 Hz',
        'Peru' => '380 Volts - 60 Hz',
        'Philippines' => '220 Volts - 60 Hz',
        'Korea, Republic of' => '380 Volts - 60 Hz',
        'Korea, Democratic People\'s Republic of' => '380 Volts - 60 Hz',
        'Syrian Arab Republic' => '380 Volts - 50 Hz',
        'Taiwan' => '220 Volts - 60 Hz',
        'United States of America' => '460 Volts - 60 Hz',
        'Uruguay' => '380 Volts - 50 Hz',
        'Vietnam' => '380 Volts - 50 Hz',
        'P.R.China' => '380 Volts - 50 Hz'
    };

    public static void handleBeforeInsert(List<SBQQ__Quote__c> newList) {

        System.debug('DK START QuoteTriggerHandler.handleBeforeInsert');
        // DK START OLD BEFORE INSERT
        string country = [SELECT BillingCountry FROM Account WHERE Id = :newList[0].SBQQ__Account__c LIMIT 1].BillingCountry ;
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
            newList[0].SBQQ__PriceBookId__c = pbId;
            newList[0].Change_for_List_Area_Price__c = change;
        }
        
        setFieldsBeforeInsert(newList);
    }

    public static void handleBeforeUpdate(Map<Id, SBQQ__Quote__c> newMap, Map<Id, SBQQ__Quote__c> oldMap) {

        System.debug('DK START QuoteTriggerHandler.handleBeforeUpdate');
        // DK START OLD BEFORE UPDATE
        if(!CongaTermCreator.hasAlreadyRan){
            CongaTermCreator.hasAlreadyRan = true;
            system.debug('createConditions '+CongaTermCreator.hasAlreadyRan);
            CongaTermCreator.createConditions(JSON.serialize(newMap.values()[0]), newMap.keyset());
        }

        setFieldsBeforeUpdate(newMap, oldMap);
    }

    public static void setFieldsBeforeInsert(List<SBQQ__Quote__c> newList){

        Set<String> opportunityIdSet = new Set<String>();
        Set<String> accountIdSet = new Set<String>();
        Set<String> priceBookIdSet = new Set<String>();
        
        for(SBQQ__Quote__c quote: newList){
            priceBookIdSet.add(quote.SBQQ__PriceBook__c);
            opportunityIdSet.add(quote.SBQQ__Opportunity2__c);
            accountIdSet.add(quote.SBQQ__Account__c);
            // accountIdSet.add(quote.Billing_Account__c);
            // accountIdSet.add(quote.Shipping_Account__c);
            // accountIdSet.add(quote.Installation_Account__c)
        }

        Map<ID, Pricebook2> priceBookMap = new Map<ID, Pricebook2>([SELECT ID, CurrencyIsoCode FROM Pricebook2 WHERE Id IN: priceBookIdSet]);
        Map<ID, Opportunity> opportunityMap = new Map<ID, Opportunity>([SELECT ID, Projectmanager__c, Account.Sales_Branch__c FROM Opportunity WHERE ID IN: opportunityIdSet]);
        Map<ID, Account> accountMap = new Map<ID, Account>([SELECT ID, Name, BillingCity, BillingCountry, BillingPostalCode, BillingStateCode, BillingStreet, Territory__c, Territory__r.Area__c FROM Account WHERE ID IN: accountIdSet]);
        //AA START 2023-06-17 - Creates a map to save Main Contractor account CRM Code based on Country dependency
        Map<String, String> mainContractorCRMCodeMapByCountry = new Map<String, String>();
        for(Main_Contractor__mdt mc : [SELECT Country_dependency__c, AccountId__c FROM Main_Contractor__mdt]){
            mainContractorCRMCodeMapByCountry.put(mc.Country_dependency__c, mc.AccountId__c);
        }
        //AA END 2023-06-17 - Creates a map to save Main Contractor account CRM Code based on Country dependency
        for(SBQQ__Quote__c quote : newList){

            // DK START Sales Condition - Dual use Laser update Quote
            if(quote.Rollup_Is_Laser__c == 0 &&
            quote.Rollup_Laser_Source_mag_3__c == 0 &&
            quote.Rollup_Laser_Source_min_3__c == 0){
                quote.Dual_Use_Laser__c = 'No Laser';
            }else if(quote.Rollup_Laser_Source_min_3__c >= 1 ){
                quote.Dual_Use_Laser__c = '< 3';
            }else if(quote.Rollup_Laser_Source_mag_3__c >= 1 ){
                quote.Dual_Use_Laser__c = '>= 3';
            }
            // DK END Sales Condition - Dual use Laser update Quote

            // DK START Update currency iso code
            quote.CurrencyIsoCode = priceBookMap.containsKey(quote.SBQQ__PriceBook__c) ? priceBookMap.get(quote.SBQQ__PriceBook__c).CurrencyIsoCode : null;
            // DK END Update currency iso code

            // DK START Mapping Main Contractor Sales Branch and PM from Opp to Quote
            //AA 2023-06-17 - Main_Contractor commented to implement new logic based on Custom Metadata and Country
            //quote.Main_Contractor__c = opportunityMap.get(quote.SBQQ__Opportunity2__c).Account.Sales_Branch__c;
            quote.PM__c = opportunityMap.get(quote.SBQQ__Opportunity2__c).Projectmanager__c;
            // DK END Mapping Main Contractor Sales Branch and PM from Opp to Quote

            // DK START Populate Quote Address
            quote.Billing_Account__c = quote.SBQQ__Account__c;
            quote.Installation_Account__c = quote.SBQQ__Account__c;
            quote.Shipping_Account__c = quote.SBQQ__Account__c;
            if(accountMap.containsKey(quote.SBQQ__Account__c)){

                quote.Install_To_City__c = accountMap.get(quote.SBQQ__Account__c).BillingCity;
                quote.Install_To_Country__c = accountMap.get(quote.SBQQ__Account__c).BillingCountry;
                quote.Install_To_Name__c = accountMap.get(quote.SBQQ__Account__c).Name;
                quote.Install_To_Postal_Code__c = accountMap.get(quote.SBQQ__Account__c).BillingPostalCode;
                quote.Install_To_State__c = accountMap.get(quote.SBQQ__Account__c).BillingStateCode;
                quote.Install_To_Street__c = accountMap.get(quote.SBQQ__Account__c).BillingStreet;
                quote.SBQQ__BillingCity__c = accountMap.get(quote.SBQQ__Account__c).BillingCity;
                quote.SBQQ__BillingCountry__c = accountMap.get(quote.SBQQ__Account__c).BillingCountry;
                quote.SBQQ__BillingName__c = accountMap.get(quote.SBQQ__Account__c).Name;
                quote.SBQQ__BillingPostalCode__c = accountMap.get(quote.SBQQ__Account__c).BillingPostalCode;
                quote.SBQQ__BillingState__c = accountMap.get(quote.SBQQ__Account__c).BillingStateCode;
                quote.SBQQ__BillingStreet__c = accountMap.get(quote.SBQQ__Account__c).BillingStreet;
                quote.SBQQ__ShippingCity__c = accountMap.get(quote.SBQQ__Account__c).BillingCity;
                quote.SBQQ__ShippingCountry__c = accountMap.get(quote.SBQQ__Account__c).BillingCountry;
                quote.SBQQ__ShippingName__c = accountMap.get(quote.SBQQ__Account__c).Name;
                quote.SBQQ__ShippingPostalCode__c = accountMap.get(quote.SBQQ__Account__c).BillingPostalCode;
                quote.SBQQ__ShippingState__c = accountMap.get(quote.SBQQ__Account__c).BillingStateCode;
                quote.SBQQ__ShippingStreet__c = accountMap.get(quote.SBQQ__Account__c).BillingStreet;

                quote.Installation_Account_Text__c = accountMap.get(quote.SBQQ__Account__c).Name;
                quote.Invoice_Account_Text__c = accountMap.get(quote.SBQQ__Account__c).Name;
                quote.Shipping_Account_Text__c = accountMap.get(quote.SBQQ__Account__c).Name;
            }else{

                quote.Install_To_City__c = null;
                quote.Install_To_Country__c = null;
                quote.Install_To_Name__c = null;
                quote.Install_To_Postal_Code__c = null;
                quote.Install_To_State__c = null;
                quote.Install_To_Street__c = null;
                quote.SBQQ__BillingCity__c = null;
                quote.SBQQ__BillingCountry__c = null;
                quote.SBQQ__BillingName__c = null;
                quote.SBQQ__BillingPostalCode__c = null;
                quote.SBQQ__BillingState__c = null;
                quote.SBQQ__BillingStreet__c = null;
                quote.SBQQ__ShippingCity__c = null;
                quote.SBQQ__ShippingCountry__c = null;
                quote.SBQQ__ShippingName__c = null;
                quote.SBQQ__ShippingPostalCode__c = null;
                quote.SBQQ__ShippingState__c = null;
                quote.SBQQ__ShippingStreet__c = null;

                quote.Installation_Account_Text__c = null;
                quote.Invoice_Account_Text__c = null;
                quote.Shipping_Account_Text__c = null;
            }
            // DK END Populate Quote Address
            //START AA 2023-06-22 - Come da richiesta di Ivan Ruozi, vado a valorizzare il campo SVG_AccountCountry__c sulla quote con quanto contenuto nel campo SBQQ__Account__r.Territory__r.Area__c
            if(String.isNotBlank(accountMap.get(quote.SBQQ__Account__c).Territory__c) && String.isNotBlank(accountMap.get(quote.SBQQ__Account__c).Territory__r.Area__c)){
                quote.SVG_AccountCountry__c = accountMap.get(quote.SBQQ__Account__c).Territory__r.Area__c;
            }
            //END AA 2023-06-22

            // DK START Sales Conditions - Update field depending on other values
            quote.Country_dependency__c = quote.Install_To_Country__c;
            //AA START 2023-06-17 - Set the Main Contractor based on Quote Field "Country_dependency__c"
            String countryToSearch = (String.isNotBlank(quote.Country_dependency__c) && (quote.Country_dependency__c.equalsIgnoreCase('United States of America') || quote.Country_dependency__c.equalsIgnoreCase('JAPAN'))) 
                                        ? quote.Country_dependency__c
                                        : 'Italy';
            quote.Main_Contractor__c = mainContractorCRMCodeMapByCountry.get(countryToSearch);
            //AA END START 2023-06-17 - Set the Main Contractor

            if(dapCountrySet.contains(quote.Country_dependency__c) &&
            typeSet.contains(quote.SBQQ__Type__c)){
                quote.Delivery_Replacement_Parts__c = 'DAP customer\'s works (Incoterms® 2010)';
            }

            if(ddpCountrySet.contains(quote.Country_dependency__c) &&
            quote.SBQQ__Type__c == 'Order Confirmation'){
                quote.Delivery_Replacement_Parts__c = 'DDP customer\'s works (Incoterms® 2010)';
            }

            if(quote.Law_Values__c == 'Standard' &&
            !String.isBlank(quote.Main_Contractor_Name__c)){
                if(lawStateMap.containsKey(quote.Main_Contractor_Name__c)){
                    quote.Law_State__c = lawStateMap.get(quote.Main_Contractor_Name__c);
                }
            }
            
            if(!ttNoCountrySet.contains(quote.Country_dependency__c) && ((ttCountrySet.contains(quote.Country_dependency__c) && !quote.Are_there_Press_Brakes__c && quote.SBQQ__Type__c == 'Quote') || (!quote.Are_there_Press_Brakes__c && quote.SBQQ__Type__c == 'Order Confirmation'))){
                quote.Payment_OC__c = 'TT 30/50/20 Cust';
                quote.Payment_QT__c = 'TT 30/50/20 Cust';
            }else if(ttNoCountrySet.contains(quote.Country_dependency__c)){
                quote.Payment_OC_Press_Brakes__c = 'TT 30/60/10';
                quote.Payment_OC__c = 'TT 30/60/10';
                quote.Payment_QT_Press_Brakes__c = 'TT 30/60/10';
                quote.Payment_QT__c = 'TT 30/60/10';
            }else if(quote.SBQQ__Type__c == 'Quote' && !ttNoCountrySet.contains(quote.Country_dependency__c) && quote.Are_there_Press_Brakes__c){
                    quote.Payment_OC_Press_Brakes__c = 'TT 30/70 Cust';
                    quote.Payment_QT_Press_Brakes__c = 'TT 30/70 Cust';
            }else if(quote.SBQQ__Type__c == 'Quote' && !ttNoCountrySet.contains(quote.Country_dependency__c) && quote.Only_Press_Brakes__c){
                    quote.Payment_OC_Press_Brakes__c = 'TT 30/70 Cust';
                    quote.Payment_QT_Press_Brakes__c = 'TT 30/70 Cust';
                    quote.Payment_OC__c = '';
                    quote.Payment_QT__c = '';
            }else if(!quote.Are_there_Press_Brakes__c && quote.SBQQ__Type__c == 'Quote' && !ttCountrySet.contains(quote.Country_dependency__c)){
                quote.Payment_OC_Press_Brakes__c = 'Pay LC';
                quote.Payment_QT_Press_Brakes__c = 'Pay LC';
                quote.Payment_OC__c = 'Pay LC';
                quote.Payment_QT__c = 'Pay LC';
            }
            // DK END Sales Conditions - Update field depending on other values
        }
    }

    public static void setFieldsBeforeUpdate(Map<Id, SBQQ__Quote__c> newMap, Map<Id, SBQQ__Quote__c> oldMap){
        Set<String> quoteIdSet = new Set<String>();
        Set<String> opportunityIdSet = new Set<String>();
        Set<String> accountIdSet = new Set<String>();
        Set<String> priceBookIdSet = new Set<String>();
        Set<String> addressIdSet = new Set<String>();
        Map<String, List<SBQQ__QuoteLine__c>> quoteLineItemMap = new Map<String, List<SBQQ__QuoteLine__c>>();
        Map<String, List<SBQQ__QuoteLine__c>> onSiteMap = new Map<String, List<SBQQ__QuoteLine__c>>();
        List<SBQQ__QuoteLine__c> quoteLineListToUpdate = new List<SBQQ__QuoteLine__c>();
        for(SBQQ__Quote__c quote: newMap.values()){
            opportunityIdSet.add(quote.SBQQ__Opportunity2__c);
            accountIdSet.add(quote.SBQQ__Account__c);
            accountIdSet.add(quote.Billing_Account__c);
            accountIdSet.add(quote.Shipping_Account__c);
            accountIdSet.add(quote.Installation_Account__c);
            addressIdSet.add(quote.Address__c);
            addressIdSet.add(quote.Shipping_Address__c);
            addressIdSet.add(quote.Installation_Address__c);
            priceBookIdSet.add(quote.SBQQ__PriceBook__c);
            quoteIdSet.add(quote.Id);
        }
        // Map<ID, Contact> m = new Map<ID, Contact>([SELECT Id, LastName FROM Contact]);
        Map<ID, Pricebook2> priceBookMap = new Map<ID, Pricebook2>([SELECT ID, CurrencyIsoCode FROM Pricebook2 WHERE Id IN: priceBookIdSet]);
        Map<ID, Opportunity> opportunityMap = new Map<ID, Opportunity>([SELECT ID, Projectmanager__c, Account.Sales_Branch__c FROM Opportunity WHERE ID IN: opportunityIdSet]);
        Map<ID, Account> accountMap = new Map<ID, Account>([SELECT ID, Name, BillingCity, BillingCountry, BillingPostalCode, BillingStateCode, BillingStreet, Territory__c, Territory__r.Area__c FROM Account WHERE ID IN: accountIdSet]);
        Map<ID, Address__c> addressMap = new Map<ID, Address__c>([SELECT ID, Name, City__c, Country__c, Zip_Postal_Code__c, State_Province__c, Street__c FROM Address__c WHERE ID IN: addressIdSet]);
        
        /*for(SBQQ__QuoteLine__c quoteLine : [SELECT ID, SBQQ__Quote__c, SBQQ__Description__c, SVG_Additional_Description__c, SVG_Technical_Description_HTML__c, 
        SBQQ__Product__r.Name, SBQQ__Product__r.kW__c, SBQQ__Product__r.Family, Product_Name_Text__c, SVG_Special_Item__c, kW__c, SBQQ__ProductName__c,
        SBQQ__Product__r.Product_Description_ENG__c, SBQQ__ProductOption__r.Additional_Description_ENG__c, SBQQ__Product__r.Technical_Description_ENG__c,
        SBQQ__Product__r.Product_Description_ITA__c, SBQQ__ProductOption__r.Additional_Description_ITA__c, SBQQ__Product__r.SVG_Technical_Description_HTML__c,
        SBQQ__Product__r.Product_Description_DEU__c, SBQQ__ProductOption__r.Additional_Description_DEU__c, SBQQ__Product__r.Technical_Description_DEU__c,
        SBQQ__Product__r.Product_Description_FRA__c, SBQQ__ProductOption__r.Additional_Description__c, SBQQ__Product__r.Technical_Description__c,
        SBQQ__Product__r.Product_Description_ESP__c, SBQQ__ProductOption__r.Additional_Description_ESP__c, SBQQ__Product__r.Technical_Description_SPA__c,
        SBQQ__Product__r.Product_Description_CHN__c, SBQQ__ProductOption__r.Additional_Description_CHN__c, SBQQ__Product__r.Technical_Description_CH__c,
        SBQQ__Product__r.Product_Description_RUS__c, SBQQ__ProductOption__r.Additional_Description_RUS__c, SBQQ__Product__r.Technical_Description_RUS__c,
        SBQQ__Product__r.Product_Description_POL__c, SBQQ__ProductOption__r.Additional_Description_POL__c, SBQQ__Product__r.Technical_Description_POL__c,
        SBQQ__Product__r.Product_Description_PT__c, SBQQ__ProductOption__r.Additional_Description_PT__c, SBQQ__Product__r.Technical_Description_PT__c
        FROM SBQQ__QuoteLine__c WHERE SBQQ__Quote__c IN: quoteIdSet]){

            if(!quoteLineItemMap.containsKey(quoteLine.SBQQ__Quote__c)){
                quoteLineItemMap.put(quoteLine.SBQQ__Quote__c, new List<SBQQ__QuoteLine__c>());
            }
            quoteLineItemMap.get(quoteLine.SBQQ__Quote__c).add(quoteLine);
            if(quoteLine.Product_Name_Text__c == 'PT on site'){
                if(!onSiteMap.containsKey(quoteLine.SBQQ__Quote__c)){

                    onSiteMap.put(quoteLine.SBQQ__Quote__c, new List<SBQQ__QuoteLine__c>());
                }
                onSiteMap.get(quoteLine.SBQQ__Quote__c).add(quoteLine);
            }
        }*/

        for(SBQQ__Quote__c quote: newMap.values()){

            String billingAccountName = accountMap.containsKey(quote.Billing_Account__c) ? accountMap.get(quote.Billing_Account__c).Name : null;
            String shippingAccountName = accountMap.containsKey(quote.Shipping_Account__c) ? accountMap.get(quote.Shipping_Account__c).Name : null;
            String installAccountName = accountMap.containsKey(quote.Installation_Account__c) ? accountMap.get(quote.Installation_Account__c).Name : null;
            // DK START Sales Condition - Dual use Laser update Quote
            if(quote.Rollup_Is_Laser__c == 0 &&
            quote.Rollup_Laser_Source_mag_3__c == 0 &&
            quote.Rollup_Laser_Source_min_3__c == 0){
                quote.Dual_Use_Laser__c = 'No Laser';
            }else if(quote.Rollup_Laser_Source_min_3__c >= 1 ){
                quote.Dual_Use_Laser__c = '< 3';
            }else if(quote.Rollup_Laser_Source_mag_3__c >= 1 ){
                quote.Dual_Use_Laser__c = '>= 3';
            }
            // DK END Sales Condition - Dual use Laser update Quote  
            
            // DK START Update currency iso code
            quote.CurrencyIsoCode = priceBookMap.containsKey(quote.SBQQ__PriceBook__c) ? priceBookMap.get(quote.SBQQ__PriceBook__c).CurrencyIsoCode : null;
            // DK END Update currency iso code

            // DK START Populate Quote Address
            if( (quote.Billing_Address_Type__c != oldMap.get(quote.Id).Billing_Address_Type__c || quote.Billing_Account__c != oldMap.get(quote.Id).Billing_Account__c ) 
                && quote.Billing_Address_Type__c == 'Main' ){

                quote.SBQQ__BillingName__c = billingAccountName;
                if(accountMap.containsKey(quote.Billing_Account__c)){

                    quote.SBQQ__BillingCity__c = accountMap.get(quote.Billing_Account__c).BillingCity;
                    quote.SBQQ__BillingCountry__c = accountMap.get(quote.Billing_Account__c).BillingCountry;
                    quote.SBQQ__BillingPostalCode__c = accountMap.get(quote.Billing_Account__c).BillingPostalCode;
                    quote.SBQQ__BillingStreet__c = accountMap.get(quote.Billing_Account__c).BillingStreet;
                    //In caso di Billing_Address_Type = main, vado a sbiancare il campo lookup other address
                }else{
                    quote.SBQQ__BillingCity__c = null;
                    quote.SBQQ__BillingCountry__c = null;
                    quote.SBQQ__BillingName__c = null;
                    quote.SBQQ__BillingPostalCode__c = null;
                    quote.SBQQ__BillingState__c = null;
                    quote.SBQQ__BillingStreet__c = null;
                }
                quote.SBQQ__BillingState__c = accountMap.containsKey(quote.SBQQ__Account__c) ? accountMap.get(quote.SBQQ__Account__c).BillingStateCode : null;
                quote.Address__c = null;
            }else{

                if(quote.Address__c != null && quote.Address__c != oldMap.get(quote.Id).Address__c 
                    && quote.Billing_Address_Type__c == 'Other'){
                    if(addressMap.containsKey(quote.Address__c)){

                        quote.SBQQ__BillingCity__c = addressMap.get(quote.Address__c).City__c;
                        quote.SBQQ__BillingCountry__c = addressMap.get(quote.Address__c).Country__c;
                        quote.SBQQ__BillingName__c = billingAccountName;
                        quote.SBQQ__BillingPostalCode__c = addressMap.get(quote.Address__c).Zip_Postal_Code__c;
                        quote.SBQQ__BillingState__c = addressMap.get(quote.Address__c).State_Province__c;
                        quote.SBQQ__BillingStreet__c = addressMap.get(quote.Address__c).Street__c;
                    }else{
                        quote.SBQQ__BillingCity__c = null;
                        quote.SBQQ__BillingCountry__c = null;
                        quote.SBQQ__BillingPostalCode__c = null;
                        quote.SBQQ__BillingState__c = null;
                        quote.SBQQ__BillingStreet__c = null;
                    }
                }
            }
            //SHIPPING
            if( (quote.Shipping_Address_Type__c != oldMap.get(quote.Id).Shipping_Address_Type__c || quote.Shipping_Account__c != oldMap.get(quote.Id).Shipping_Account__c) 
            && quote.Shipping_Address_Type__c == 'Main'){

                if(accountMap.containsKey(quote.Shipping_Account__c)){
                    quote.SBQQ__ShippingCity__c = accountMap.get(quote.Shipping_Account__c).BillingCity;
                    quote.SBQQ__ShippingCountry__c = accountMap.get(quote.Shipping_Account__c).BillingCountry;
                    quote.SBQQ__ShippingName__c = shippingAccountName;
                    quote.SBQQ__ShippingPostalCode__c = accountMap.get(quote.Shipping_Account__c).BillingPostalCode;
                    quote.SBQQ__ShippingState__c = accountMap.get(quote.Shipping_Account__c).BillingStateCode;
                    quote.SBQQ__ShippingStreet__c = accountMap.get(quote.Shipping_Account__c).BillingStreet;
                    //In caso di Shipping_Address_Type__c = main, vado a sbiancare il campo lookup other address
                }else{

                    quote.SBQQ__ShippingCity__c = null;
                    quote.SBQQ__ShippingCountry__c = null;
                    quote.SBQQ__ShippingName__c = null;
                    quote.SBQQ__ShippingPostalCode__c = null;
                    quote.SBQQ__ShippingState__c = null;
                    quote.SBQQ__ShippingStreet__c = null;
                    //In caso di Shipping_Address_Type__c = main, vado a sbiancare il campo lookup other address
                }
                quote.Shipping_Address__c = null;
            }else{
                if(quote.Shipping_Address__c != null && quote.Shipping_Address__c != oldMap.get(quote.Id).Shipping_Address__c 
                && quote.Shipping_Address_Type__c == 'Other'){
                    if(addressMap.containsKey(quote.Shipping_Address__c)){
                        
                        quote.SBQQ__ShippingCity__c = addressMap.get(quote.Shipping_Address__c).City__c;
                        quote.SBQQ__ShippingCountry__c = addressMap.get(quote.Shipping_Address__c).Country__c;
                        quote.SBQQ__ShippingName__c = shippingAccountName;
                        quote.SBQQ__ShippingPostalCode__c = addressMap.get(quote.Shipping_Address__c).Zip_Postal_Code__c;
                        quote.SBQQ__ShippingState__c = addressMap.get(quote.Shipping_Address__c).State_Province__c;
                        quote.SBQQ__ShippingStreet__c = addressMap.get(quote.Shipping_Address__c).Street__c;
                    }else{
                        quote.SBQQ__ShippingCity__c = null;
                        quote.SBQQ__ShippingCountry__c = null;
                        quote.SBQQ__ShippingName__c = null;
                        quote.SBQQ__ShippingPostalCode__c = null;
                        quote.SBQQ__ShippingState__c = null;
                        quote.SBQQ__ShippingStreet__c = null;
                    }
                }
            }

            //INSTALL
            if( (quote.Installation_Address_Type__c != oldMap.get(quote.Id).Installation_Address_Type__c || quote.Installation_Account__c != oldMap.get(quote.Id).Installation_Account__c)
            && quote.Installation_Address_Type__c == 'Main'){

                if(accountMap.containsKey(quote.Installation_Account__c)){
                    quote.Install_To_City__c = accountMap.get(quote.Installation_Account__c).BillingCity;
                    quote.Install_To_Country__c = accountMap.get(quote.Installation_Account__c).BillingCountry;
                    quote.Install_To_Name__c = installAccountName;
                    quote.Install_To_Postal_Code__c = accountMap.get(quote.Installation_Account__c).BillingPostalCode;
                    quote.Install_To_State__c = accountMap.get(quote.Installation_Account__c).BillingStateCode;
                    quote.Install_To_Street__c = accountMap.get(quote.Installation_Account__c).BillingStreet;
                    //In caso di Installation_Address_Type__c = main, vado a sbiancare il campo lookup other address
                }else{
                    quote.Install_To_City__c = null;
                    quote.Install_To_Country__c = null;
                    quote.Install_To_Name__c = null;
                    quote.Install_To_Postal_Code__c = null;
                    quote.Install_To_State__c = null;
                    quote.Install_To_Street__c = null;
                    //In caso di Installation_Address_Type__c = main, vado a sbiancare il campo lookup other address
                }
                quote.Installation_Address__c = null;
            }else{

                if(quote.Installation_Address__c != null && quote.Installation_Address__c != oldMap.get(quote.Id).Installation_Address__c 
                    && quote.Installation_Address_Type__c == 'Other'){
                    if(addressMap.containsKey(quote.Installation_Address__c)){

                        quote.Install_To_City__c = addressMap.get(quote.Installation_Address__c).City__c;
                        quote.Install_To_Country__c = addressMap.get(quote.Installation_Address__c).Country__c;
                        quote.Install_To_Name__c = installAccountName;
                        quote.Install_To_Postal_Code__c = addressMap.get(quote.Installation_Address__c).Zip_Postal_Code__c;
                        quote.Install_To_State__c = addressMap.get(quote.Installation_Address__c).State_Province__c;
                        quote.Install_To_Street__c = addressMap.get(quote.Installation_Address__c).Street__c;
                    }else{
                        quote.Install_To_City__c = null;
                        quote.Install_To_Country__c = null;
                        quote.Install_To_Name__c = null;
                        quote.Install_To_Postal_Code__c = null;
                        quote.Install_To_State__c = null;
                        quote.Install_To_Street__c = null;
                    }
                }
            }
            // DK END Populate Quote Address
            //START AA 2023-06-22 - Come da richiesta di Ivan Ruozi, vado a valorizzare il campo SVG_AccountCountry__c sulla quote con quanto contenuto nel campo SBQQ__Account__r.Territory__r.Area__c
            if(quote.SBQQ__Account__c != null && quote.SBQQ__Account__c != oldMap.get(quote.Id).SBQQ__Account__c){
                quote.SVG_AccountCountry__c = (String.isNotBlank(accountMap.get(quote.SBQQ__Account__c).Territory__c) && String.isNotBlank(accountMap.get(quote.SBQQ__Account__c).Territory__r.Area__c)) ? accountMap.get(quote.SBQQ__Account__c).Territory__r.Area__c : null;
            }else{
                quote.SVG_AccountCountry__c = null;
            }
            //END AA 2023-06-22

            // DK START Sales Conditions - Assign Voltage
            if(String.isBlank(quote.Voltage_and_Frequency__c)){
                quote.Voltage_and_Frequency__c = (countryVoltageMap.get(quote.Country_dependency__c) != null) ? countryVoltageMap.get(quote.Country_dependency__c) : '400 V / 50 Hz';
            }
            // DK END Sales Conditions - Assign Voltage

            // DK START Sales Conditions - Approval
            quote.ApprovalForNonStdSalesConditions__c = quote.Requested_Despatch__c != 'To Be Defined' ||
                (quote.SW_Installation__c != oldMap.get(quote.Id).SW_Installation__c &&
                quote.SW_Installation__c == 'Included')
                ||
                (quote.Competent_Court__c != oldMap.get(quote.Id).Competent_Court__c &&
                quote.Competent_Court__c != 'Competent court')
                ||
                (quote.Law_Values__c != oldMap.get(quote.Id).Law_Values__c &&
                quote.Law_Values__c != 'Vienna Convention')
                ||
                (quote.Payment_Details__c != oldMap.get(quote.Id).Payment_Details__c &&
                String.isBlank(quote.Payment_Details__c));
            // DK END Sales Conditions - Approval

            // DK START Sales Conditions - Update field depending on other values
            quote.Country_dependency__c = quote.Install_To_Country__c;
            quote.Installation_Account_Text__c = installAccountName;
            quote.Invoice_Account_Text__c = billingAccountName;
            quote.Shipping_Account_Text__c = shippingAccountName;

            if(dapCountrySet.contains(quote.Country_dependency__c) &&
            typeSet.contains(quote.SBQQ__Type__c)){
                quote.Delivery_Replacement_Parts__c = 'DAP customer\'s works (Incoterms® 2010)';
            }

            if(ddpCountrySet.contains(quote.Country_dependency__c) &&
            quote.SBQQ__Type__c == 'Order Confirmation'){
                quote.Delivery_Replacement_Parts__c = 'DDP customer\'s works (Incoterms® 2010)';
            }

            if(quote.Law_Values__c == 'Standard' &&
            !String.isBlank(quote.Main_Contractor_Name__c)){
                if(lawStateMap.containsKey(quote.Main_Contractor_Name__c)){
                    quote.Law_State__c = lawStateMap.get(quote.Main_Contractor_Name__c);
                }
            }

            /*if(!ttNoCountrySet.contains(quote.Country_dependency__c) &&
                ((ttCountrySet.contains(quote.Country_dependency__c) &&
                !quote.Are_there_Press_Brakes__c && quote.SBQQ__Type__c == 'Quote') 
                || (!quote.Are_there_Press_Brakes__c && quote.SBQQ__Type__c == 'Quote'))
            ){

                quote.Payment_OC__c = 'TT 30/50/20 Cust';
                quote.Payment_QT__c = 'TT 30/50/20 Cust';
            }

            if(ttNoCountrySet.contains(quote.Country_dependency__c)){
                quote.Payment_OC__c = 'TT 30/60/10';
                quote.Payment_QT__c = 'TT 30/60/10';
                quote.Payment_OC__c = 'TT 30/60/10';
                quote.Payment_OC__c = 'TT 30/60/10';
            }

            if(quote.SBQQ__Type__c == 'Quote' &&
            !ttNoCountrySet.contains(quote.Country_dependency__c)){

                if(quote.Are_there_Press_Brakes__c){
                    quote.Payment_OC_Press_Brakes__c = 'TT 30/70 Cust';
                    quote.Payment_QT_Press_Brakes__c = 'TT 30/70 Cust';
                }

                if(quote.Only_Press_Brakes__c){
                    quote.Payment_OC_Press_Brakes__c = 'TT 30/70 Cust';
                    quote.Payment_QT_Press_Brakes__c = 'TT 30/70 Cust';
                    quote.Payment_OC__c = '';
                    quote.Payment_QT__c = '';
                }
            }

            if(!quote.Are_there_Press_Brakes__c &&
            quote.SBQQ__Type__c == 'Quote' &&
            !ttCountrySet.contains(quote.Country_dependency__c)){
                quote.Payment_OC_Press_Brakes__c = 'Pay LC';
                quote.Payment_QT_Press_Brakes__c = 'Pay LC';
                quote.Payment_OC__c = 'Pay LC';
                quote.Payment_QT__c = 'Pay LC';
            }*/
            // DK END Sales Conditions - Update field depending on other values

            // DK START Sales Condition - Loop On Quote Line To Concatenate
            /*String concatFamilyName = '';
            String concatKW = '';
            Decimal sumKW = 0;
            // DK END Sales Condition - Loop On Quote Line To Concatenate
            if(quoteLineItemMap.containsKey(quote.Id)){

                for(SBQQ__QuoteLine__c quoteLine : quoteLineItemMap.get(quote.Id)){
                    // DK START Quote Line Language_1
                    if(!quoteLine.SVG_Special_Item__c){ 
                        switch on quote.SBQQ__QuoteLanguage__c {
                            when 'English' {
                                quoteLine.SBQQ__Description__c = quoteLine.SBQQ__Product__r.Product_Description_ENG__c;
                                quoteLine.SVG_Additional_Description__c = quoteLine.SBQQ__ProductOption__r.Additional_Description_ENG__c;
                                quoteLine.SVG_Technical_Description_HTML__c = quoteLine.SBQQ__Product__r.Technical_Description_ENG__c;
                            }	
                            when 'Italian' {
                                quoteLine.SBQQ__Description__c = quoteLine.SBQQ__Product__r.Product_Description_ITA__c;
                                quoteLine.SVG_Additional_Description__c = quoteLine.SBQQ__ProductOption__r.Additional_Description_ITA__c;
                                quoteLine.SVG_Technical_Description_HTML__c = quoteLine.SBQQ__Product__r.SVG_Technical_Description_HTML__c;
                            }
                            when 'German' {
                                quoteLine.SBQQ__Description__c = quoteLine.SBQQ__Product__r.Product_Description_DEU__c;
                                quoteLine.SVG_Additional_Description__c = quoteLine.SBQQ__ProductOption__r.Additional_Description_DEU__c;
                                quoteLine.SVG_Technical_Description_HTML__c = quoteLine.SBQQ__Product__r.Technical_Description_DEU__c;
                            }
                            when 'French' {		  
                                quoteLine.SBQQ__Description__c = quoteLine.SBQQ__Product__r.Product_Description_FRA__c;
                                quoteLine.SVG_Additional_Description__c = quoteLine.SBQQ__ProductOption__r.Additional_Description__c;
                                quoteLine.SVG_Technical_Description_HTML__c = quoteLine.SBQQ__Product__r.Technical_Description__c;
                            }
                            when 'Spanish' {		  
                                quoteLine.SBQQ__Description__c = quoteLine.SBQQ__Product__r.Product_Description_ESP__c;
                                quoteLine.SVG_Additional_Description__c = quoteLine.SBQQ__ProductOption__r.Additional_Description_ESP__c;
                                quoteLine.SVG_Technical_Description_HTML__c = quoteLine.SBQQ__Product__r.Technical_Description_SPA__c;
                            }
                            when 'Chinese' {		  
                                quoteLine.SBQQ__Description__c = quoteLine.SBQQ__Product__r.Product_Description_CHN__c;
                                quoteLine.SVG_Additional_Description__c = quoteLine.SBQQ__ProductOption__r.Additional_Description_CHN__c;
                                quoteLine.SVG_Technical_Description_HTML__c = quoteLine.SBQQ__Product__r.Technical_Description_CH__c;
                            }
                            when 'Russian' {		  
                                quoteLine.SBQQ__Description__c = quoteLine.SBQQ__Product__r.Product_Description_RUS__c;
                                quoteLine.SVG_Additional_Description__c = quoteLine.SBQQ__ProductOption__r.Additional_Description_RUS__c;
                                quoteLine.SVG_Technical_Description_HTML__c = quoteLine.SBQQ__Product__r.Technical_Description_RUS__c;
                            }
                            when 'Polish' {		  
                                quoteLine.SBQQ__Description__c = quoteLine.SBQQ__Product__r.Product_Description_POL__c;
                                quoteLine.SVG_Additional_Description__c = quoteLine.SBQQ__ProductOption__r.Additional_Description_POL__c;
                                quoteLine.SVG_Technical_Description_HTML__c = quoteLine.SBQQ__Product__r.Technical_Description_POL__c;
                            }
                            when 'Portuguese' {		  
                                quoteLine.SBQQ__Description__c = quoteLine.SBQQ__Product__r.Product_Description_PT__c;
                                quoteLine.SVG_Additional_Description__c = quoteLine.SBQQ__ProductOption__r.Additional_Description_PT__c;
                                quoteLine.SVG_Technical_Description_HTML__c = quoteLine.SBQQ__Product__r.Technical_Description_PT__c;
                            }
                        }
                        quoteLineListToUpdate.add(quoteLine);
                    }
                    // DK END Quote Line Language_1
    
                    // DK START Sales Condition - Loop On Quote Line To Concatenate
                    if(!String.IsBlank(quoteLine.SBQQ__Product__r.Name)){
                        concatFamilyName += quoteLine.SBQQ__Product__r.Family;
                    }
                    if(quoteLine.SBQQ__Product__r.kW__c > 0){
                        concatKW += quoteLine.SBQQ__Product__r.Name + ' (' + quoteLine.SBQQ__Product__r.kW__c + ') ';
                        sumKW += quoteLine.SBQQ__Product__r.kW__c;
                    }
                    // DK END Sales Condition - Loop On Quote Line To Concatenate
                }
            }*/

            // DK START Sales Condition - Loop On Quote Line To Concatenate
            /*quote.Contains_Family_Not_Press_Brakes__c = concatFamilyName.contains('Punching machines') || concatFamilyName.contains('Laser machines') || concatFamilyName.contains('Panel benders');
            //quote.Electrical_Consumpiton_Concatenated__c = 'kWh ' + sumKW + ': ' + concatKW;
            if(concatFamilyName.contains('Press Breaks') && concatFamilyName != 'Press Breaks' &&
            quote.Contains_Family_Not_Press_Brakes__c){

                quote.Are_there_Press_Brakes__c = true;
                quote.Only_Press_Brakes__c = false;
            }else if(concatFamilyName.equalsIgnoreCase('Press Breaks') ||
            (!quote.Contains_Family_Not_Press_Brakes__c && concatFamilyName.contains('Press Breaks'))){
                
                quote.Are_there_Press_Brakes__c = false;
                quote.Only_Press_Brakes__c = true;
            }else{
                quote.Are_there_Press_Brakes__c = false;
                quote.Only_Press_Brakes__c = false;
            }
            // DK END Sales Condition - Loop On Quote Line To Concatenate

            // DK START Sales Conditions - Update Fields on Quote Line
            if(onSiteMap.containsKey(quote.Id)){
                String tipeString = onSiteMap.get(quote.Id)[0].SVG_Type__c.replaceAll('[^a-zA-Z0-9\\s+]', '');
                switch on tipeString {
                    when 'ourour'{
                        quote.Programming_Course_Site_Charge__c = 'our';
                        quote.Programming_Course_Site_Works__c = 'our works or at one of our subsidiaries';
                    }
                    when 'yourour'{
                        quote.Programming_Course_Site_Charge__c = 'our';
                        quote.Programming_Course_Site_Works__c = 'your works';
                    }
                    when 'ouryour'{
                        quote.Programming_Course_Site_Charge__c = 'your';
                        quote.Programming_Course_Site_Works__c = 'our works or at one of our subsidiaries';
                    }
                    when 'youryour'{
                        quote.Programming_Course_Site_Charge__c = 'your';
                        quote.Programming_Course_Site_Works__c = 'your works';
                    }
                }
            }*/
            // DK END Sales Conditions - Update Fields on Quote Line
        }

        /*if(!quoteLineListToUpdate.isEmpty()){

            // QuoteLineTriggerHandler
            update quoteLineListToUpdate;
        }*/
    }

    // ----------------------------------------------------------------------------------------------------
    // ----------------------------------------------------------------------------------------------------
    // ----------------------------------------------------------------------------------------------------
    // ----------------------------------------------------------------------------------------------------
    // ----------------------------------------------------------------------------------------------------
    // ----------------------------------------------------------------------------------------------------
    // ----------------------------------------------------------------------------------------------------
    // ----------------------------------------------------------------------------------------------------
    // DK START COPY APSVG01_QuoteHandler

    //CB CHECK RICORSIONE
    public static boolean recursion = false;
    
    
    public static void manageStatusChange(List<SBQQ__Quote__c> newQuotes, Map<Id, SBQQ__Quote__c> oldQuotesMap) {
        for (SBQQ__Quote__c q : newQuotes) {
            SBQQ__Quote__c oldQ = oldQuotesMap.get(q.Id);
            if (oldQ == null || q.ApprovalStatus__c != oldQ.ApprovalStatus__c) {
                if (q.ApprovalStatus__c == 'Pending' && q.SBQQ__Status__c != 'Approval') {
                    q.SBQQ__Status__c = 'Approval';
                }
                if (q.ApprovalStatus__c == 'Rejected' && q.SBQQ__Status__c != 'Review') {
                    q.SBQQ__Status__c = 'Review';
                }
                if (q.ApprovalStatus__c == 'Approved' && q.SBQQ__Status__c != 'Approved') {
                    q.SBQQ__Status__c = 'Approved';
                }
            }
            
            // Blocco cambi di stato se non è stata richiesta l'approvazione
            if (oldQ == null || q.SBQQ__Status__c != oldQ.SBQQ__Status__c) {
                /*if (q.SBQQ__Status__c != 'Draft' && q.SBQQ__Status__c != 'Approval') {
                    if (q.ApprovalStatus__c != 'Approved') {
                        q.SBQQ__Status__c.addError('Please submit Quote for approval');
                    }
                }*/
                if (q.SBQQ__Status__c == 'Draft') { // Non è mai concesso tornare a Draft
                    q.SBQQ__Status__c.addError('Status not permitted');
                } else if (q.SBQQ__Status__c == 'Approval') { // Non è mai concesso tornare a Draft
                    if (q.ApprovalStatus__c != 'Pending') { // Ma se lo stato approvazione è Pending significa che ci è andato per via del processo
                    	q.SBQQ__Status__c.addError('Please submit Quote for approval');
                    }
                } else if (q.SBQQ__Status__c == 'Approved') {
                    if ((oldQ.SBQQ__Status__c != 'Approval' && oldQ.SBQQ__Status__c != 'Draft') || q.ApprovalStatus__c != 'Approved') { // Solo da Approval si può andare verso Approved (ma solo se è stata approvata)
                        q.SBQQ__Status__c.addError('Please submit Quote for approval');
                    }
                }  else if (q.SBQQ__Status__c == 'Review') {
                    if (oldQ.SBQQ__Status__c != 'Approval' || q.ApprovalStatus__c != 'Rejected') { // Solo da Approval si può andare verso Approved (ma solo se è stata rifiutata)
                        q.SBQQ__Status__c.addError('Status not permitted');
                    }
                } else if (q.SBQQ__Status__c == 'Presented') {
                    if (oldQ.SBQQ__Status__c != 'Approved') { // Solo da Approved si può andare verso Presented
                        q.SBQQ__Status__c.addError('Please submit Quote for approval');
                    }
                } else if (q.SBQQ__Status__c == 'Canceled') {
                    if (oldQ.SBQQ__Status__c != 'Draft' && oldQ.SBQQ__Status__c != 'Approved') { // Solo da Draft o Approved si può andare verso Canceled
                        q.SBQQ__Status__c.addError('Status not permitted');
                    }
                } 
            }
        }
    }
    
    public static void lockRecordWhilePendingApproval(List<SBQQ__Quote__c> newQuotes, Map<Id, SBQQ__Quote__c> oldQuotesMap) {
        List<User> isUserAdmin = [SELECT Name FROM User WHERE Profile.PermissionsModifyAllData = true AND Id = :UserInfo.getUserId()];
        if (isUserAdmin != null && !isUserAdmin.isEmpty()) {
            return;
        }
        
        Set<Id> quoteIdSet = new Set<Id>();
        Set<Id> quoteIdToLock = new Set<Id>();
        for (SBQQ__Quote__c q : newQuotes) {
            SBQQ__Quote__c oldQ = oldQuotesMap.get(q.Id);
            if (q.ApprovalStatus__c == 'Pending' && (oldQ != null && oldQ.ApprovalStatus__c == q.ApprovalStatus__c)) {
            	quoteIdSet.add(q.Id);
                quoteIdToLock.add(q.Id);
            }
        }
        
        if (quoteIdSet != null && !quoteIdSet.isEmpty()) {
            for (sbaa__Approval__c a : [SELECT Quote__c FROM sbaa__Approval__c WHERE sbaa__Status__c = 'Assigned' AND Quote__c IN :quoteIdSet AND sbaa__Approver__r.sbaa__User__c = :UserInfo.getUserId()]) {
                quoteIdToLock.remove(a.Quote__c);
            }
            for (Id idToLock : quoteIdToLock) {
                for (SBQQ__Quote__c q : newQuotes) {
                    if (q.Id == idToLock) {
                        q.SBQQ__Status__c.addError('Pending Approval'); // prevent update
                    }
                }
            }
        }
    }
    
    public static void autoStartApprovalProcess(List<SBQQ__Quote__c> newQuotes) {
        for (SBQQ__Quote__c q : newQuotes) {
            if (q.SBQQ__Status__c == 'Approval' && q.ApprovalStatus__c != 'Pending') {
                system.debug('Auto starting approval');
                SBAA.ApprovalAPI.submit(q.Id, SBAA__Approval__c.Quote__c);
            }
        }
    }
    
    public static void manageLanguageChange(List<SBQQ__Quote__c> newQuotes, Map<Id, SBQQ__Quote__c> oldQuotesMap) {
        Set<String> langSet = new Set<String>();
        Set<SBQQ__Quote__c> quotePrimaryLang = new Set<SBQQ__Quote__c>();
        Set<SBQQ__Quote__c> quoteSecondaryLang = new Set<SBQQ__Quote__c>();
        
        for (SBQQ__Quote__c q : newQuotes) {
            // Primary Language
            SBQQ__Quote__c oldQ = oldQuotesMap != null ? oldQuotesMap.get(q.Id) : null;
            if (oldQ == null || q.SBQQ__QuoteLanguage__c != oldQ.SBQQ__QuoteLanguage__c || q.SBQQ__Type__c != oldQ.SBQQ__Type__c || q.SVG_IsSalesProposal__c != oldQ.SVG_IsSalesProposal__c) {
                langSet.add(q.SBQQ__QuoteLanguage__c);
                quotePrimaryLang.add(q);
            }
            
            // Secondary Language
            if (oldQ == null || q.Quote_Secondary_Language__c != oldQ.Quote_Secondary_Language__c || q.SBQQ__Type__c != oldQ.SBQQ__Type__c || q.SVG_IsSalesProposal__c != oldQ.SVG_IsSalesProposal__c) {
                langSet.add(q.Quote_Secondary_Language__c);
                quoteSecondaryLang.add(q);
            }
        }
        if (langSet != null && !langSet.isEmpty()) {
            Map<String, SVG_Print_Language__c> languageMaps = new Map<String, SVG_Print_Language__c>();
            for (SVG_Print_Language__c l : [SELECT Id, Language__c, PrefaceDescription__c, FirstPageQuotationLabel__c, FirstPageOrderConfirmation_Label__c, FirstPageSalesProposalLabel__c FROM SVG_Print_Language__c WHERE Language__c IN :langSet]) {
                languageMaps.put(l.Language__c, l);
            }
            
            for (SBQQ__Quote__c q : quotePrimaryLang) {
                SVG_Print_Language__c lang = languageMaps.get(q.SBQQ__QuoteLanguage__c);
                if (lang != null) {
                    q.Print_Language__c = lang.Id;
                    q.SVG_PrimaryLanguageIntroduction__c = lang.PrefaceDescription__c;
                    if (q.SBQQ__Type__c == 'Quote') {
                        q.SVG_PrintTitleTranslation__c = lang.FirstPageQuotationLabel__c;
                    } else if (!q.SVG_IsSalesProposal__c) {
                        q.SVG_PrintTitleTranslation__c = lang.FirstPageOrderConfirmation_Label__c;
                    } else {
                        q.SVG_PrintTitleTranslation__c = lang.FirstPageSalesProposalLabel__c;
                    }
                }
            }
            
            for (SBQQ__Quote__c q : quoteSecondaryLang) {
                SVG_Print_Language__c lang = languageMaps.get(q.Quote_Secondary_Language__c);
                if (lang != null) {
                    q.SVG_SecondaryPrintLanguage__c = lang.Id;
                    q.SVG_SecondaryLanguageIntroduction__c = lang.PrefaceDescription__c;
                    if (q.SBQQ__Type__c == 'Quote') {
                        q.SVG_PrintTitleTranslation2__c = lang.FirstPageQuotationLabel__c;
                    } else if (!q.SVG_IsSalesProposal__c) {
                        q.SVG_PrintTitleTranslation2__c = lang.FirstPageOrderConfirmation_Label__c;
                    } else {
                        q.SVG_PrintTitleTranslation2__c = lang.FirstPageSalesProposalLabel__c;
                    }
                }
            }
        }
        
        
        
        // Traduzioni Labels
        Set<Id> langIdSet = new Set<Id>();
        Set<Id> labelPrimarySet = new Set<Id>();
        Set<SBQQ__Quote__c> quotePrimaryLabels = new Set<SBQQ__Quote__c>();
        Set<SBQQ__Quote__c> quoteSecondaryLabels = new Set<SBQQ__Quote__c>();
        
        for (SBQQ__Quote__c q : newQuotes) {
            SBQQ__Quote__c oldQ = oldQuotesMap != null ? oldQuotesMap.get(q.Id) : null;
            
            // Primary Language
            if (oldQ == null || q.SVG_BundleLabelLk__c != oldQ.SVG_BundleLabelLk__c) {
                quotePrimaryLang.add(q);
                langIdSet.add(q.Print_Language__c);
                labelPrimarySet.add(q.SVG_BundleLabelLk__c);
                quotePrimaryLabels.add(q);
            }
            if (oldQ == null || q.SVG_DiscountLabelLk__c != oldQ.SVG_DiscountLabelLk__c) {
                quotePrimaryLang.add(q);
                langIdSet.add(q.Print_Language__c);
                labelPrimarySet.add(q.SVG_DiscountLabelLk__c);
                quotePrimaryLabels.add(q);
            }
            if (oldQ == null || q.SVG_DiscountBundleLabelLk__c != oldQ.SVG_DiscountBundleLabelLk__c) {
                quotePrimaryLang.add(q);
                langIdSet.add(q.Print_Language__c);
                labelPrimarySet.add(q.SVG_DiscountBundleLabelLk__c);
                quotePrimaryLabels.add(q);
            }
            if (oldQ == null || q.SVG_DiscountTotalLabelLk__c != oldQ.SVG_DiscountTotalLabelLk__c) {
                quotePrimaryLang.add(q);
                langIdSet.add(q.Print_Language__c);
                labelPrimarySet.add(q.SVG_DiscountTotalLabelLk__c);
                quotePrimaryLabels.add(q);
            }
            if (oldQ == null || q.SVG_TotalLabelLk__c != oldQ.SVG_TotalLabelLk__c) {
                quotePrimaryLang.add(q);
                langIdSet.add(q.Print_Language__c);
                labelPrimarySet.add(q.SVG_TotalLabelLk__c);
                quotePrimaryLabels.add(q);
            }
            
            // Secondary Language
            if (oldQ == null || q.SVG_BundleLabelLk__c != oldQ.SVG_BundleLabelLk__c) {
                quoteSecondaryLang.add(q);
                langIdSet.add(q.SVG_SecondaryPrintLanguage__c);
                labelPrimarySet.add(q.SVG_BundleLabelLk__c);
                quoteSecondaryLabels.add(q);
            }
            if (oldQ == null || q.SVG_DiscountLabelLk__c != oldQ.SVG_DiscountLabelLk__c) {
                quoteSecondaryLang.add(q);
                langIdSet.add(q.SVG_SecondaryPrintLanguage__c);
                labelPrimarySet.add(q.SVG_DiscountLabelLk__c);
                quoteSecondaryLabels.add(q);
            }
            if (oldQ == null || q.SVG_DiscountBundleLabelLk__c != oldQ.SVG_DiscountBundleLabelLk__c) {
                quoteSecondaryLang.add(q);
                langIdSet.add(q.SVG_SecondaryPrintLanguage__c);
                labelPrimarySet.add(q.SVG_DiscountBundleLabelLk__c);
                quoteSecondaryLabels.add(q);
            }
            if (oldQ == null || q.SVG_DiscountTotalLabelLk__c != oldQ.SVG_DiscountTotalLabelLk__c) {
                quoteSecondaryLang.add(q);
                langIdSet.add(q.SVG_SecondaryPrintLanguage__c);
                labelPrimarySet.add(q.SVG_DiscountTotalLabelLk__c);
                quoteSecondaryLabels.add(q);
            }
            if (oldQ == null || q.SVG_TotalLabelLk__c != oldQ.SVG_TotalLabelLk__c) {
                quoteSecondaryLang.add(q);
                langIdSet.add(q.SVG_SecondaryPrintLanguage__c);
                labelPrimarySet.add(q.SVG_TotalLabelLk__c);
                quoteSecondaryLabels.add(q);
            }
        }
        if (langIdSet != null && !langIdSet.isEmpty() && labelPrimarySet != null && !labelPrimarySet.isEmpty()) {
            Map<Id, Map<Id, SVG_Label_Translation__c>> languageMaps = new Map<Id, Map<Id, SVG_Label_Translation__c>>();
            for (SVG_Label_Translation__c lt : [SELECT Id, PrintLanguage__c, Print_Label__c, Name FROM SVG_Label_Translation__c WHERE PrintLanguage__c IN :langIdSet AND Print_Label__c IN :labelPrimarySet]) {
                //Map<String, SVG_Label_Translation__c> labelsMap = languageMaps.get(lt.PrintLanguage__c);
                if (!languageMaps.containsKey(lt.PrintLanguage__c)) {
                    Map<Id, SVG_Label_Translation__c> lm = new Map<Id, SVG_Label_Translation__c>();
                    languageMaps.put(lt.PrintLanguage__c, lm);
                }
                
                Map<Id, SVG_Label_Translation__c> labelsMap = languageMaps.get(lt.PrintLanguage__c);
                
                if (!labelsMap.containsKey(lt.Print_Label__c)) {
                    labelsMap.put(lt.Print_Label__c, lt);
                }
            }
            
            for (SBQQ__Quote__c q : quotePrimaryLabels) {
                Map<Id, SVG_Label_Translation__c> labelsMap = languageMaps.get(q.Print_Language__c);
                if (labelsMap != null) {
                    SVG_Label_Translation__c lBundle = labelsMap.get(q.SVG_BundleLabelLk__c);
                    if (lBundle != null) {
                    	q.SVG_BundleLabelTranslationLk__c = lBundle.Name;
                    }
                    SVG_Label_Translation__c lDiscount = labelsMap.get(q.SVG_DiscountLabelLk__c);
                    if (lDiscount != null) {
                    	q.SVG_DiscountLabelTranslation__c = lDiscount.Name;
                    }
                    SVG_Label_Translation__c lDiscountB = labelsMap.get(q.SVG_DiscountBundleLabelLk__c);
                    if (lDiscountB != null) {
                    	q.SVG_DiscountBundleLabelTranslation__c = lDiscountB.Name;
                    }
                    SVG_Label_Translation__c lDiscountT = labelsMap.get(q.SVG_DiscountTotalLabelLk__c);
                    if (lDiscountT != null) {
                    	q.SVG_DiscountTotalLabelTranslation__c = lDiscountT.Name;
                    }
                    SVG_Label_Translation__c lTotal = labelsMap.get(q.SVG_TotalLabelLk__c);
                    if (lTotal != null) {
                    	q.SVG_TotalLabelTranslation__c = lTotal.Name;
                    }
                }
            }
            
            for (SBQQ__Quote__c q : quoteSecondaryLang) {
                Map<Id, SVG_Label_Translation__c> labelsMap = languageMaps.get(q.SVG_SecondaryPrintLanguage__c);
                if (labelsMap != null) {
                    SVG_Label_Translation__c lBundle = labelsMap.get(q.SVG_BundleLabelLk__c);
                    if (lBundle != null) {
                    	q.SVG_BundleLabelTranslation2__c = lBundle.Name;
                    }
                    SVG_Label_Translation__c lDiscount = labelsMap.get(q.SVG_DiscountLabelLk__c);
                    if (lDiscount != null) {
                    	q.SVG_DiscountLabelTranslation2__c = lDiscount.Name;
                    }
                    SVG_Label_Translation__c lDiscountB = labelsMap.get(q.SVG_DiscountBundleLabelLk__c);
                    if (lDiscountB != null) {
                    	q.SVG_DiscountedBundleLabelTranslation2__c = lDiscountB.Name;
                    }
                    SVG_Label_Translation__c lDiscountT = labelsMap.get(q.SVG_DiscountTotalLabelLk__c);
                    if (lDiscountT != null) {
                    	q.SVG_DiscountedTotalLabelTranslation2__c = lDiscountT.Name;
                    }
                    SVG_Label_Translation__c lTotal = labelsMap.get(q.SVG_TotalLabelLk__c);
                    if (lTotal != null) {
                    	q.SVG_FinalTotalLabelTranslation2__c = lTotal.Name;
                    }
                }
            }
        }
    }
    
    public static void setPrintLabelDefaults_BeforeInsert(List<SBQQ__Quote__c> newQuotes) {
        Map<String, Id> defaultLabels = new Map<String, Id>();
        for (SVG_Print_Label__c pl : [SELECT Id, Category__c FROM SVG_Print_Label__c WHERE Default__c = true]) {
            if (!defaultLabels.containsKey(pl.Category__c)) {
                defaultLabels.put(pl.Category__c, pl.Id);
            }
        }
        
        for (SBQQ__Quote__c q : newQuotes) {
            q.SVG_BundleLabelLk__c = defaultLabels.get('TL');
            q.SVG_DiscountLabelLk__c = defaultLabels.get('DL');
            q.SVG_DiscountBundleLabelLk__c = defaultLabels.get('FL');
            q.SVG_DiscountTotalLabelLk__c = defaultLabels.get('FQ');
            q.SVG_TotalLabelLk__c = defaultLabels.get('TQ');
        }
    }
    
    public static void manageOrderOCSignature(List<SBQQ__Quote__c> newQuotes, Map<Id, SBQQ__Quote__c> oldQuotesMap) {
        for (SBQQ__Quote__c q : newQuotes) {
            SBQQ__Quote__c oldQ = oldQuotesMap.get(q.Id);
            if (oldQ == null || q.SBQQ__Type__c != oldQ.SBQQ__Type__c || q.Main_Contractor__c != oldQ.Main_Contractor__c || q.Total_Order_Price__c != oldQ.Total_Order_Price__c) {
                if (q.SBQQ__Type__c != 'Quote') {
                    List<SVG_OC_Signature__c> signatures = [SELECT Id, MainContractor__c, Type__c, ManagerJobTitle__c, ManagerName__c FROM SVG_OC_Signature__c WHERE MainContractor__c = :q.Main_Contractor__c OR (MainContractor__c = NULL AND Type__c <> NULL)];
                    if (signatures != null) {
                        Boolean signatureFound = false;
                        for (SVG_OC_Signature__c sig : signatures) {
                            if (q.Main_Contractor__c != null && q.Main_Contractor__c == sig.MainContractor__c) {
                                q.SVG_OCSignature__c = sig.Id;
                                q.SVG_ManagerJobTitle__c = sig.ManagerJobTitle__c;
                                q.SVG_ManagerName__c = sig.ManagerName__c;
                                signatureFound = true;
                                break;
                            }
                        }
                        
                        if (!signatureFound) {
                            String typeToFind = q.SVG_TotalOrderPriceEUR__c <= 1500000 && q.EU_Country__c ? 'Europe1M5' : 'Other';
                            for (SVG_OC_Signature__c sig : signatures) {
                                if (sig.MainContractor__c == null && sig.Type__c == typeToFind) {
                                    q.SVG_OCSignature__c = sig.Id;
                                    q.SVG_ManagerJobTitle__c = sig.ManagerJobTitle__c;
                                    q.SVG_ManagerName__c = sig.ManagerName__c;
                                    signatureFound = true;
                                    break;
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    public static void manageLegalInfo(List<SBQQ__Quote__c> newQuotes, Map<Id, SBQQ__Quote__c> oldQuotesMap) {
        Set<Id> mainContractorIdSet = new Set<Id>();
        for (SBQQ__Quote__c q : newQuotes) {
            SBQQ__Quote__c oldQ = oldQuotesMap != null ? oldQuotesMap.get(q.Id) : null;
            if (q.Main_Contractor__c != null && (oldQ == null || q.Main_Contractor__c != oldQ.Main_Contractor__c)) {
                mainContractorIdSet.add(q.Main_Contractor__c);
            }
        }
        
        if (mainContractorIdSet != null && !mainContractorIdSet.isEmpty()) {
            Map<Id, Account> mainContractors = new Map<Id, Account>([SELECT Id, Company_Legal_Info__c FROM Account WHERE Id = :mainContractorIdSet]);
            
            for (SBQQ__Quote__c q : newQuotes) {
                Account mainContractor = mainContractors.get(q.Main_Contractor__c);
                if (mainContractor != null) {
                    q.SVG_LastPageLegalInfos__c = mainContractor.Company_Legal_Info__c;
                }
            }
        }
        
    }
}