public with sharing class QuoteSuggestionsController {

    private static final List<String> CSV_COLUMNS = new List<String>{
            'Sales Document Type',
            'Sales Org.',
            'Distr. Channel',
            'Division',
            'Customer purchase order number',
            'Customer purchase order date',
            'Customer purchase order type',
            'Order Reason',
            'Numero ddt di vendita originario',
            'Pricing Date',
            'Shipping Conditions',
            'Sold-to party',
            'SP',
            'Requested delivery date',
            'Ship to Party',
            'STP',
            'Payer',
            'PY',
            'Terms of Payment',
            'Bill to party',
            'BTP',
            'Collaboratore',
            'Azienda Collaboratore',
            'Divisione Collaboratore',
            'Header Discount',
            'Header Discount %',
            'Currency',
            'Shipping type',
            'Complete delivery defined for each sales',
            'HEADER TEXT',
            'Incoterms (Part 1)',
            'Incoterms (Part 2)',
            'Invoice Text',
            'Invoice number',
            'Material code',
            'Item Category',
            'Item number',
            'Quantity',
            'Batch number',
            'Plant',
            'Storage location',
            'Unit of measure',
            'Partial delivery at item level',
            'Requested delivery date',
            'Price',
            'Price Value',
            'Discount %',
            'Discount % Value',
            'Discount 1%',
            'Discount 1 % Value',
            'Discount 2%',
            'Discount 2 % Value',
            'CIG',
            'Terms of Payment',
            'Data ddt di vendita originario',
            'Numero ddt di vendita originario',
            'Pricing Date',
            'Inco1',
            'Inco2',
            'Item Invoice',
            'Acct asgnmt grp',
            'Campaign Name',
            'Campaign ID'
    };

    @AuraEnabled
    public static List<QuoteLineItem> getQuoteLineItems(String quoteId) {
        List<QuoteLineItem> quoteLineItems = [SELECT Id, Product2.Name, Product2.ProductCode, Quantity, Discount, ListPrice, UnitPrice, TotalPrice FROM QuoteLineItem WHERE QuoteId = :quoteId];
        return quoteLineItems;
    }


    @AuraEnabled(Cacheable=true)
    public static String getCsvQuoteLineItems(String quoteId) {
        String csv;

        String query = 'SELECT ' + String.join(QUERY_FIELDS, ', ') + ' FROM QuoteLineItem WHERE QuoteId = :quoteId';
        System.debug('QuoteSuggestionsController getCsvQuoteLineItems query: ' + query);
        List<QuoteLineItem> quoteLineItems = Database.query(query);


        if(quoteLineItems != null && !quoteLineItems.isEmpty()) {
            csv = String.join(CSV_COLUMNS, ';');

            for (QuoteLineItem quoteLineItem : quoteLineItems) {

                List<String> csvLine = new List<String>{
                        quoteLineItem.Quote.THR_Sales_Document_Type__c == null ? '' : String.valueOf(quoteLineItem.Quote.THR_Sales_Document_Type__c),
                        quoteLineItem.Quote.THR_Sales_Organization__c == null ? '' : (String.valueOf(quoteLineItem.Quote.THR_Sales_Organization__c)),
                        quoteLineItem.Quote.THR_Distr_Channel__c == null ? '' : (String.valueOf(quoteLineItem.Quote.THR_Distr_Channel__c)),
                        quoteLineItem.Quote.Division__c == null ? '' : (String.valueOf(quoteLineItem.Quote.Division__c)),
                        quoteLineItem.Quote.THR_Customer_purchase_order_number__c == null ? '' : (String.valueOf(quoteLineItem.Quote.THR_Customer_purchase_order_number__c)),
                        quoteLineItem.Quote.THR_PO_Date__c == null ? '' : (String.valueOf(quoteLineItem.Quote.THR_PO_Date__c)),
                        quoteLineItem.Quote.THR_Customer_purchase_order_type__c == null ? '' : (String.valueOf(quoteLineItem.Quote.THR_Customer_purchase_order_type__c)),
                        quoteLineItem.Quote.Order_Reason__c == null ? '' : String.valueOf(quoteLineItem.Quote.Order_Reason__c),
                        quoteLineItem.Quote.Numero_ddt_di_vendita_originario__c == null ? '' : String.valueOf(quoteLineItem.Quote.Numero_ddt_di_vendita_originario__c),
                        quoteLineItem.Quote.THR_Pricing_DateF__c == null ? '' : (String.valueOf(quoteLineItem.Quote.THR_Pricing_DateF__c)),
                        quoteLineItem.Quote.THR_Shipping_Conditions__c == null ? '' : (String.valueOf(quoteLineItem.Quote.THR_Shipping_Conditions__c)),
                        quoteLineItem.Quote.THR_Sold_to_party__c == null ? '' : (String.valueOf(quoteLineItem.Quote.THR_Sold_to_party__c)),
                        quoteLineItem.Quote.SP__c == null ? '' : (String.valueOf(quoteLineItem.Quote.SP__c)),
                        quoteLineItem.THR_Requested_delivery_date__c == null ? '' : (String.valueOf(quoteLineItem.THR_Requested_delivery_date__c)),
                        quoteLineItem.Quote.Ship_to_Party__c == null ? '' : (String.valueOf(quoteLineItem.Quote.Ship_to_Party__c)),
                        quoteLineItem.Quote.STP__c == null ? '' : (String.valueOf(quoteLineItem.Quote.STP__c)),
                        quoteLineItem.Quote.Payer__c == null ? '' : (String.valueOf(quoteLineItem.Quote.Payer__c)),
                        quoteLineItem.Quote.PY__c == null ? '' : (String.valueOf(quoteLineItem.Quote.PY__c)),
                        quoteLineItem.Quote.THR_Terms_of_Payment__c == null ? '' : (String.valueOf(quoteLineItem.Quote.THR_Terms_of_Payment__c)),
                        quoteLineItem.Quote.Bill_to_party__c == null ? '' : (String.valueOf(quoteLineItem.Quote.Bill_to_party__c)),
                        quoteLineItem.Quote.BTP__c == null ? '' : (String.valueOf(quoteLineItem.Quote.BTP__c)),
                        quoteLineItem.Quote.THR_Collaboratore__c == null ? '' : (String.valueOf(quoteLineItem.Quote.THR_Collaboratore__c)),
                        quoteLineItem.Quote.THR_Azienda_Collaboratore__c == null ? '' : (String.valueOf(quoteLineItem.Quote.THR_Azienda_Collaboratore__c)),
                        quoteLineItem.Quote.THR_Divisione_Collaboratore__c == null ? '' : (String.valueOf(quoteLineItem.Quote.THR_Divisione_Collaboratore__c)),
                        quoteLineItem.Quote.Header_Discount__c == null ? '' : (String.valueOf(quoteLineItem.Quote.Header_Discount__c)),
                        quoteLineItem.Quote.THR_Header_Discount__c == null ? '' : (String.valueOf(quoteLineItem.Quote.THR_Header_Discount__c)),
                        quoteLineItem.Quote.Currency__c == null ? '' : (String.valueOf(quoteLineItem.Quote.Currency__c)),
                        quoteLineItem.Quote.Shipping_type__c == null ? '' : (String.valueOf(quoteLineItem.Quote.Shipping_type__c)),
                        quoteLineItem.Quote.Complete_delivery_defined_for_each_sales__c == null ? '' : (String.valueOf(quoteLineItem.Quote.Complete_delivery_defined_for_each_sales__c)),
                        quoteLineItem.Quote.THR_HEADER_TEXT__c == null ? '' : (String.valueOf(quoteLineItem.Quote.THR_HEADER_TEXT__c)),
                        quoteLineItem.Quote.Incoterms__c == null ? '' : (String.valueOf(quoteLineItem.Quote.Incoterms__c)),
                        quoteLineItem.Quote.Incoterms_Part_2__c == null ? '' : (String.valueOf(quoteLineItem.Quote.Incoterms_Part_2__c)),
                        quoteLineItem.Quote.Invoice_Text__c == null ? '' : (String.valueOf(quoteLineItem.Quote.Invoice_Text__c)),
                        quoteLineItem.Quote.Invoice__c == null ? '' : (String.valueOf(quoteLineItem.Quote.Invoice__c)),
                        quoteLineItem.THR_Material_code__c == null ? '' : (String.valueOf(quoteLineItem.THR_Material_code__c)),
                        quoteLineItem.THR_Item_Category__c == null ? '' : (String.valueOf(quoteLineItem.THR_Item_Category__c)),
                        quoteLineItem.Quote.Item_number__c == null ? '' : (String.valueOf(quoteLineItem.Quote.Item_number__c)),
                        quoteLineItem.Quantity == null ? '' : (String.valueOf(quoteLineItem.Quantity)),
                        quoteLineItem.Quote.Batch__c == null ? '' : (String.valueOf(quoteLineItem.Quote.Batch__c)),
                        quoteLineItem.Quote.Plant__c == null ? '' : (String.valueOf(quoteLineItem.Quote.Plant__c)),
                        quoteLineItem.Quote.Storage_location__c == null ? '' : (String.valueOf(quoteLineItem.Quote.Storage_location__c)),
                        quoteLineItem.Quote.Unit_of_measure__c == null ? '' : (String.valueOf(quoteLineItem.Quote.Unit_of_measure__c)),
                        quoteLineItem.Quote.Partial_delivery_at_item_level__c == null ? '' : (String.valueOf(quoteLineItem.Quote.Partial_delivery_at_item_level__c)),
                        quoteLineItem.Quote.THR_Requested_delivery_dateF__c == null ? '' : (String.valueOf(quoteLineItem.Quote.THR_Requested_delivery_dateF__c)),
                        quoteLineItem.Quote.Price__c == null ? '' : (String.valueOf(quoteLineItem.Quote.Price__c)),
                        quoteLineItem.Quote.Price_value__c == null ? '' : (String.valueOf(quoteLineItem.Quote.Price_value__c)),
                        quoteLineItem.Quote.Discount_1__c == null ? '' : (String.valueOf(quoteLineItem.Quote.Discount_1__c)),
                        quoteLineItem.Quote.THR_Discount_Value__c == null ? '' : (String.valueOf(quoteLineItem.Quote.THR_Discount_Value__c)),
                        quoteLineItem.THR_Discount_1__c == null ? '' : (String.valueOf(quoteLineItem.THR_Discount_1__c)),
                        quoteLineItem.THR_Discount_1_Value__c == null ? '' : (String.valueOf(quoteLineItem.THR_Discount_1_Value__c)),
                        quoteLineItem.THR_Discount_2__c == null ? '' : (String.valueOf(quoteLineItem.THR_Discount_2__c)),
                        quoteLineItem.THR_Discount_2_Value__c == null ? '' : (String.valueOf(quoteLineItem.THR_Discount_2_Value__c)),
                        quoteLineItem.Quote.CIG__c == null ? '' : (String.valueOf(quoteLineItem.Quote.CIG__c)),
                        quoteLineItem.THR_Terms_of_Payment__c == null ? '' : (String.valueOf(quoteLineItem.THR_Terms_of_Payment__c)),
                        quoteLineItem.Quote.Data_ddt_di_vendita_originario__c == null ? '' : (String.valueOf(quoteLineItem.Quote.Data_ddt_di_vendita_originario__c)),
                        quoteLineItem.THR_Numero_ddt_di_vendita_originario__c == null ? '' : (String.valueOf(quoteLineItem.THR_Numero_ddt_di_vendita_originario__c)),
                        quoteLineItem.THR_Pricing_Date__c == null ? '' : (String.valueOf(quoteLineItem.THR_Pricing_Date__c)),
                        quoteLineItem.Quote.Inco1__c == null ? '' : (String.valueOf(quoteLineItem.Quote.Inco1__c)),
                        quoteLineItem.Quote.Inco2__c == null ? '' : (String.valueOf(quoteLineItem.Quote.Inco2__c)),
                        quoteLineItem.Quote.Item_Invoice__c == null ? '' : (String.valueOf(quoteLineItem.Quote.Item_Invoice__c)),
                        quoteLineItem.Quote.Acct_asgnmt_grp__c == null ? '' : (String.valueOf(quoteLineItem.Quote.Acct_asgnmt_grp__c))
                };

                csv += '\n' + String.join(csvLine, ';');
            }
        }

        return csv;
    }    

    private static final List<String> QUERY_FIELDS = new List<String>{
            'Quantity',
            'Quote.Acct_asgnmt_grp__c',
            'Quote.Batch__c',
            'Quote.Bill_to_party__c',
            'Quote.BTP__c',
            'Quote.CIG__c',
            'Quote.Complete_delivery_defined_for_each_sales__c',
            'Quote.Currency__c',
            'Quote.Data_ddt_di_vendita_originario__c',
            'Quote.Discount_1__c',
            'Quote.Division__c',
            'Quote.Header_Discount__c',
            'Quote.Inco1__c',
            'Quote.Inco2__c',
            'Quote.Incoterms__c',
            'Quote.Incoterms_Part_2__c',
            'Quote.Invoice__c',
            'Quote.Invoice_Text__c',
            'Quote.Item_Invoice__c',
            'Quote.Item_number__c',
            'Quote.Numero_ddt_di_vendita_originario__c',
            'Quote.Order_Reason__c',
            'Quote.Partial_delivery_at_item_level__c',
            'Quote.Payer__c',
            'Quote.Plant__c',
            'Quote.Price__c',
            'Quote.Price_value__c',
            'Quote.PY__c',
            'Quote.Ship_to_Party__c',
            'Quote.Shipping_type__c',
            'Quote.SP__c',
            'Quote.Storage_location__c',
            'Quote.STP__c',
            'Quote.THR_Azienda_Collaboratore__c',
            'Quote.THR_Collaboratore__c',
            'Quote.THR_Customer_purchase_order_number__c',
            'Quote.THR_Customer_purchase_order_type__c',
            'Quote.THR_Discount_Value__c',
            'Quote.THR_Distr_Channel__c',
            'Quote.THR_Divisione_Collaboratore__c',
            'Quote.THR_Header_Discount__c',
            'Quote.THR_HEADER_TEXT__c',
            'Quote.THR_PO_Date__c',
            'Quote.THR_Pricing_DateF__c',
            'Quote.THR_Requested_delivery_dateF__c',
            'Quote.THR_Sales_Document_Type__c',
            'Quote.THR_Sales_Organization__c',
            'Quote.THR_Shipping_Conditions__c',
            'Quote.THR_Sold_to_party__c',
            'toLabel(Quote.THR_Terms_of_Payment__c)',
            'Quote.Unit_of_measure__c',
            'THR_Discount_1__c',
            'THR_Discount_1_Value__c',
            'THR_Discount_2__c',
            'THR_Discount_2_Value__c',
            'THR_Item_Category__c',
            'THR_Material_code__c',
            'THR_Numero_ddt_di_vendita_originario__c',
            'THR_Pricing_Date__c',
            'THR_Requested_delivery_date__c',
            'toLabel(THR_Terms_of_Payment__c)'
    };





    @AuraEnabled(Cacheable=true)
    public static String getSbqqCsvQuoteLineItems(String quoteId) {
        String csv;

        String query = 'SELECT ' + String.join(QUERY_FIELDS_SBQQ, ', ') + ' FROM SBQQ__QuoteLine__c WHERE (NOT THR_Material_code__c  LIKE \'%CONTAINER%\') AND SBQQ__Quote__r.Id = :quoteId';
        System.debug('QuoteSuggestionsController getCsvQuoteLineItems query: ' + query);
        List<SBQQ__QuoteLine__c> quoteLineItems = Database.query(query);


        if(quoteLineItems != null && !quoteLineItems.isEmpty()) {
            csv = String.join(CSV_COLUMNS, ';');

            for (SBQQ__QuoteLine__c quoteLineItem : quoteLineItems) {

                List<String> csvLine = new List<String>{
                        quoteLineItem.SBQQ__Quote__r.THR_Sales_Document_Type__c == null ? '' : String.valueOf(quoteLineItem.SBQQ__Quote__r.THR_Sales_Document_Type__c),
                        quoteLineItem.SBQQ__Quote__r.THR_Sales_Organization__c == null ? '' : (String.valueOf(quoteLineItem.SBQQ__Quote__r.THR_Sales_Organization__c)),
                        quoteLineItem.SBQQ__Quote__r.THR_Distr_Channel__c == null ? '' : (String.valueOf(quoteLineItem.SBQQ__Quote__r.THR_Distr_Channel__c)),
                        quoteLineItem.SBQQ__Quote__r.Division__c == null ? '' : (String.valueOf(quoteLineItem.SBQQ__Quote__r.Division__c)),
                        quoteLineItem.SBQQ__Quote__r.THR_Customer_purchase_order_number__c == null ? '' : (String.valueOf(quoteLineItem.SBQQ__Quote__r.THR_Customer_purchase_order_number__c)),
                        quoteLineItem.SBQQ__Quote__r.THR_PO_Date__c == null ? '' : (String.valueOf(quoteLineItem.SBQQ__Quote__r.THR_PO_Date__c)),
                        quoteLineItem.SBQQ__Quote__r.THR_Customer_purchase_order_type__c == null ? '' : (String.valueOf(quoteLineItem.SBQQ__Quote__r.THR_Customer_purchase_order_type__c)),
                        quoteLineItem.SBQQ__Quote__r.Order_Reason__c == null ? '' : String.valueOf(quoteLineItem.SBQQ__Quote__r.Order_Reason__c),
                        quoteLineItem.SBQQ__Quote__r.Numero_ddt_di_vendita_originario__c == null ? '' : String.valueOf(quoteLineItem.SBQQ__Quote__r.Numero_ddt_di_vendita_originario__c),
                        quoteLineItem.SBQQ__Quote__r.THR_Pricing_DateF__c == null ? '' : (String.valueOf(quoteLineItem.SBQQ__Quote__r.THR_Pricing_DateF__c)),
                        quoteLineItem.SBQQ__Quote__r.THR_Shipping_Conditions__c == null ? '' : (String.valueOf(quoteLineItem.SBQQ__Quote__r.THR_Shipping_Conditions__c)),
                        quoteLineItem.SBQQ__Quote__r.THR_Sold_to_party__c == null ? '' : (String.valueOf(quoteLineItem.SBQQ__Quote__r.THR_Sold_to_party__c)),
                        quoteLineItem.SBQQ__Quote__r.SP__c == null ? '' : (String.valueOf(quoteLineItem.SBQQ__Quote__r.SP__c)),
                        quoteLineItem.THR_Requested_delivery_date__c == null ? '' : (String.valueOf(quoteLineItem.THR_Requested_delivery_date__c)),
                        quoteLineItem.SBQQ__Quote__r.Ship_to_Party__c == null ? '' : (String.valueOf(quoteLineItem.SBQQ__Quote__r.Ship_to_Party__c)),
                        quoteLineItem.SBQQ__Quote__r.STP__c == null ? '' : (String.valueOf(quoteLineItem.SBQQ__Quote__r.STP__c)),
                        quoteLineItem.SBQQ__Quote__r.Payer__c == null ? '' : (String.valueOf(quoteLineItem.SBQQ__Quote__r.Payer__c)),
                        quoteLineItem.SBQQ__Quote__r.PY__c == null ? '' : (String.valueOf(quoteLineItem.SBQQ__Quote__r.PY__c)),
                        quoteLineItem.SBQQ__Quote__r.THR_Terms_of_Payment__c == null ? '' : (String.valueOf(quoteLineItem.SBQQ__Quote__r.THR_Terms_of_Payment__c)),
                        quoteLineItem.SBQQ__Quote__r.Bill_to_party__c == null ? '' : (String.valueOf(quoteLineItem.SBQQ__Quote__r.Bill_to_party__c)),
                        quoteLineItem.SBQQ__Quote__r.BTP__c == null ? '' : (String.valueOf(quoteLineItem.SBQQ__Quote__r.BTP__c)),
                        quoteLineItem.SBQQ__Quote__r.THR_Collaboratore__c == null ? '' : (String.valueOf(quoteLineItem.SBQQ__Quote__r.THR_Collaboratore__c)),
                        quoteLineItem.SBQQ__Quote__r.THR_Azienda_Collaboratore__c == null ? '' : (String.valueOf(quoteLineItem.SBQQ__Quote__r.THR_Azienda_Collaboratore__c)),
                        quoteLineItem.SBQQ__Quote__r.THR_Divisione_Collaboratore__c == null ? '' : (String.valueOf(quoteLineItem.SBQQ__Quote__r.THR_Divisione_Collaboratore__c)),
                        quoteLineItem.SBQQ__Quote__r.Header_Discount__c == null ? '' : (String.valueOf(quoteLineItem.SBQQ__Quote__r.Header_Discount__c)),
                        quoteLineItem.SBQQ__Quote__r.THR_Header_Discount__c == null ? '' : (String.valueOf(quoteLineItem.SBQQ__Quote__r.THR_Header_Discount__c)),
                        //quoteLineItem.SBQQ__Quote__r.Currency__c == null ? '' : (String.valueOf(quoteLineItem.SBQQ__Quote__r.Currency__c)),
                        quoteLineItem.SBQQ__Quote__r.CurrencyText__c == null ? '' : (String.valueOf(quoteLineItem.SBQQ__Quote__r.CurrencyText__c)),
                        quoteLineItem.SBQQ__Quote__r.Shipping_type__c == null ? '' : (String.valueOf(quoteLineItem.SBQQ__Quote__r.Shipping_type__c)),
                        quoteLineItem.SBQQ__Quote__r.Complete_delivery_defined_for_each_sales__c == null ? '' : (String.valueOf(quoteLineItem.SBQQ__Quote__r.Complete_delivery_defined_for_each_sales__c)),
                        quoteLineItem.SBQQ__Quote__r.THR_HEADER_TEXT__c == null ? '' : (String.valueOf(quoteLineItem.SBQQ__Quote__r.THR_HEADER_TEXT__c)),
                        quoteLineItem.SBQQ__Quote__r.Incoterms__c == null ? '' : (String.valueOf(quoteLineItem.SBQQ__Quote__r.Incoterms__c)),
                        quoteLineItem.SBQQ__Quote__r.Incoterms_Part_2__c == null ? '' : (String.valueOf(quoteLineItem.SBQQ__Quote__r.Incoterms_Part_2__c)),
                        quoteLineItem.SBQQ__Quote__r.Invoice_Text__c == null ? '' : (String.valueOf(quoteLineItem.SBQQ__Quote__r.Invoice_Text__c)),
                        quoteLineItem.SBQQ__Quote__r.Invoice__c == null ? '' : (String.valueOf(quoteLineItem.SBQQ__Quote__r.Invoice__c)),
                        quoteLineItem.THR_Material_code__c == null ? '' : (String.valueOf(quoteLineItem.THR_Material_code__c)),
                        quoteLineItem.THR_Item_Category__c == null ? '' : (String.valueOf(quoteLineItem.THR_Item_Category__c)),
                        quoteLineItem.SBQQ__Quote__r.Item_number__c == null ? '' : (String.valueOf(quoteLineItem.SBQQ__Quote__r.Item_number__c)),
                        quoteLineItem.SBQQ__Quantity__c == null ? '' : (String.valueOf(quoteLineItem.SBQQ__Quantity__c)),
                        quoteLineItem.SBQQ__Quote__r.Batch_number__c == null ? '' : (String.valueOf(quoteLineItem.SBQQ__Quote__r.Batch_number__c)),
                        quoteLineItem.SBQQ__Quote__r.Plant__c == null ? '' : (String.valueOf(quoteLineItem.SBQQ__Quote__r.Plant__c)),
                        quoteLineItem.SBQQ__Quote__r.Storage_location__c == null ? '' : (String.valueOf(quoteLineItem.SBQQ__Quote__r.Storage_location__c)),
                        quoteLineItem.SBQQ__Quote__r.Unit_of_measure__c == null ? '' : (String.valueOf(quoteLineItem.SBQQ__Quote__r.Unit_of_measure__c)),
                        quoteLineItem.SBQQ__Quote__r.Partial_delivery_at_item_level__c == null ? '' : (String.valueOf(quoteLineItem.SBQQ__Quote__r.Partial_delivery_at_item_level__c)),
                        quoteLineItem.SBQQ__Quote__r.THR_Requested_delivery_dateF__c == null ? '' : (String.valueOf(quoteLineItem.SBQQ__Quote__r.THR_Requested_delivery_dateF__c)),
                        quoteLineItem.SBQQ__Quote__r.Price__c == null ? '' : (String.valueOf(quoteLineItem.SBQQ__Quote__r.Price__c)),
                        quoteLineItem.SBQQ__Quote__r.Price_Value__c == null ? '' : (String.valueOf(quoteLineItem.SBQQ__Quote__r.Price_Value__c)),
                        quoteLineItem.SBQQ__Quote__r.Discount_1__c == null ? '' : (String.valueOf(quoteLineItem.SBQQ__Quote__r.Discount_1__c)),
                        quoteLineItem.SBQQ__Quote__r.THR_Discount_Value__c == null ? '' : (String.valueOf(quoteLineItem.SBQQ__Quote__r.THR_Discount_Value__c)),
                        quoteLineItem.THR_Discount_1__c == null ? '' : (String.valueOf(quoteLineItem.THR_Discount_1__c)),
                        quoteLineItem.THR_Discount_1_Value__c == null ? '' : (String.valueOf(quoteLineItem.THR_Discount_1_Value__c)),
                        quoteLineItem.THR_Discount_2__c == null ? '' : (String.valueOf(quoteLineItem.THR_Discount_2__c)),
                        quoteLineItem.THR_Discount_2_Value__c == null ? '' : (String.valueOf(quoteLineItem.THR_Discount_2_Value__c)),
                        quoteLineItem.SBQQ__Quote__r.CIG__c == null ? '' : (String.valueOf(quoteLineItem.SBQQ__Quote__r.CIG__c)),
                        quoteLineItem.THR_Terms_of_Payment__c == null ? '' : (String.valueOf(quoteLineItem.THR_Terms_of_Payment__c)),
                        quoteLineItem.SBQQ__Quote__r.Data_ddt_di_vendita_originario__c == null ? '' : (String.valueOf(quoteLineItem.SBQQ__Quote__r.Data_ddt_di_vendita_originario__c)),
                        quoteLineItem.THR_Numero_ddt_di_vendita_originario__c == null ? '' : (String.valueOf(quoteLineItem.THR_Numero_ddt_di_vendita_originario__c)),
                        quoteLineItem.THR_Pricing_Date__c == null ? '' : (String.valueOf(quoteLineItem.THR_Pricing_Date__c)),
                        quoteLineItem.SBQQ__Quote__r.Inco1__c == null ? '' : (String.valueOf(quoteLineItem.SBQQ__Quote__r.Inco1__c)),
                        quoteLineItem.SBQQ__Quote__r.Inco2__c == null ? '' : (String.valueOf(quoteLineItem.SBQQ__Quote__r.Inco2__c)),
                        quoteLineItem.SBQQ__Quote__r.Item_Invoice__c == null ? '' : (String.valueOf(quoteLineItem.SBQQ__Quote__r.Item_Invoice__c)),
                        quoteLineItem.SBQQ__Quote__r.Acct_asgnmt_grp__c == null ? '' : (String.valueOf(quoteLineItem.SBQQ__Quote__r.Acct_asgnmt_grp__c)),
                        quoteLineItem.SBQQ__Quote__r.THR_Campaign_Name__c == null ? '' : (String.valueOf(quoteLineItem.SBQQ__Quote__r.THR_Campaign_Name__c)),
                        quoteLineItem.SBQQ__Quote__r.THR_Campaign_ID__c == null ? '' : (String.valueOf(quoteLineItem.SBQQ__Quote__r.THR_Campaign_ID__c))
                };

                csv += '\n' + String.join(csvLine, ';');
            }
        }

        return csv;
    }

    private static final List<String> QUERY_FIELDS_SBQQ = new List<String>{
            'SBQQ__Quantity__c',
            'SBQQ__Quote__r.Acct_asgnmt_grp__c',
            'SBQQ__Quote__r.Batch_number__c',
            'SBQQ__Quote__r.Bill_to_party__c',
            'SBQQ__Quote__r.BTP__c',
            'SBQQ__Quote__r.CIG__c',
            'SBQQ__Quote__r.Complete_delivery_defined_for_each_sales__c',
            'SBQQ__Quote__r.CurrencyText__c',
            'SBQQ__Quote__r.Data_ddt_di_vendita_originario__c',
            'SBQQ__Quote__r.Discount_1__c',
            'SBQQ__Quote__r.Division__c',
            'SBQQ__Quote__r.Header_Discount__c',
            'SBQQ__Quote__r.Inco1__c',
            'SBQQ__Quote__r.Inco2__c',
            'SBQQ__Quote__r.Incoterms__c',
            'SBQQ__Quote__r.Incoterms_Part_2__c',
            'SBQQ__Quote__r.Invoice__c',
            'SBQQ__Quote__r.Invoice_Text__c',
            'SBQQ__Quote__r.Item_Invoice__c',
            'SBQQ__Quote__r.Item_number__c',
            'SBQQ__Quote__r.Numero_ddt_di_vendita_originario__c',
            'SBQQ__Quote__r.Order_Reason__c',
            'SBQQ__Quote__r.Partial_delivery_at_item_level__c',
            'SBQQ__Quote__r.Payer__c',
            'SBQQ__Quote__r.Plant__c',
            'SBQQ__Quote__r.Price__c',
            'SBQQ__Quote__r.Price_Value__c',
            'SBQQ__Quote__r.PY__c',
            'SBQQ__Quote__r.Ship_to_Party__c',
            'SBQQ__Quote__r.Shipping_type__c',
            'SBQQ__Quote__r.SP__c',
            'SBQQ__Quote__r.Storage_location__c',
            'SBQQ__Quote__r.STP__c',
            'SBQQ__Quote__r.THR_Azienda_Collaboratore__c',
            'SBQQ__Quote__r.THR_Collaboratore__c',
            'SBQQ__Quote__r.THR_Customer_purchase_order_number__c',
            'SBQQ__Quote__r.THR_Customer_purchase_order_type__c',
            'SBQQ__Quote__r.THR_Discount_Value__c',
            'SBQQ__Quote__r.THR_Distr_Channel__c',
            'SBQQ__Quote__r.THR_Divisione_Collaboratore__c',
            'SBQQ__Quote__r.THR_Header_Discount__c',
            'SBQQ__Quote__r.THR_HEADER_TEXT__c',
            'SBQQ__Quote__r.THR_PO_Date__c',
            'SBQQ__Quote__r.THR_Pricing_DateF__c',
            'SBQQ__Quote__r.THR_Requested_delivery_dateF__c',
            'SBQQ__Quote__r.THR_Sales_Document_Type__c',
            'SBQQ__Quote__r.THR_Sales_Organization__c',
            'SBQQ__Quote__r.THR_Shipping_Conditions__c',
            'SBQQ__Quote__r.THR_Sold_to_party__c',
            'SBQQ__Quote__r.THR_Terms_of_Payment__c',
            'SBQQ__Quote__r.Unit_of_measure__c',
            'SBQQ__Quote__r.THR_Campaign_Name__c',
            'SBQQ__Quote__r.THR_Campaign_ID__c',
            'THR_Discount_1__c',
            'THR_Discount_1_Value__c',
            'THR_Discount_2__c',
            'THR_Discount_2_Value__c',
            'THR_Item_Category__c',
            'THR_Material_code__c',
            'THR_Numero_ddt_di_vendita_originario__c',
            'THR_Pricing_Date__c',
            'THR_Requested_delivery_date__c',
            'toLabel(THR_Terms_of_Payment__c)'
    };


}