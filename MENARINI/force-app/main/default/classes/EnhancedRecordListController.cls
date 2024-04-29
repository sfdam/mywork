public inherited sharing class EnhancedRecordListController {

    public class EnhancedRecordList {
        @AuraEnabled public String objectName { get; set; }
        @AuraEnabled public String objectLabel { get; set; }
        @AuraEnabled public String objectLabelPlural { get; set; }
        @AuraEnabled public List<Column> columns { get; set; }
        @AuraEnabled public List<SObject> rows { get; set; }
    }

    public class Column {
        @AuraEnabled public String fieldName { get; set; }
        @AuraEnabled public String label { get; set; }
        @AuraEnabled public String type { get; set; }
        @AuraEnabled public Boolean sortable { get; set; }
        @AuraEnabled public Boolean searchable { get; set; }
        @AuraEnabled public Boolean isLinkable { get; set; }
        @AuraEnabled public String fieldUrl { get; set; }
        @AuraEnabled public String tooltipLabel { get; set; }
        @AuraEnabled public Boolean wrapText { get; set; }

        public Column(String fieldName, String label, String type, Boolean sortable, Boolean searchable, Boolean isLinkable, String fieldUrl, String tooltipLabel, Boolean wrapText) {
            this.fieldName = fieldName;
            this.label = label;
            this.type = type;
            this.sortable = sortable;
            this.searchable = searchable;
            this.isLinkable = isLinkable;
            this.fieldUrl = fieldUrl;
            this.tooltipLabel = tooltipLabel;
            this.wrapText = wrapText;
        }
    }

    public class TargetField {
        @AuraEnabled public String fieldName { get; set; }
        @AuraEnabled public String customLabel { get; set; }
        @AuraEnabled public Boolean isLinkable { get; set; }
        @AuraEnabled public String fieldUrl { get; set; }
        @AuraEnabled public String tooltipLabel { get; set; }
        @AuraEnabled public Boolean toLabel { get; set; }
        @AuraEnabled public Boolean wrapText { get; set; }
    }

    public class Filter {
        @AuraEnabled public String fieldName { get; set; }
        @AuraEnabled public Object fieldValue { get; set; }
        @AuraEnabled public String filterType { get; set; }
    }

    public class FilterGroup {
        @AuraEnabled public List<Filter> filters { get; set; }
        @AuraEnabled public String logicalOperator { get; set; }
    }

    @AuraEnabled
    public static Integer getTotalRecords(String targetObject, List<FilterGroup> filterGroups) {
        String query = 'SELECT COUNT()';
        query += ' FROM ' + targetObject;
        query += ' WHERE Id != NULL';
        query += getQueryFilters(targetObject, filterGroups);
        System.debug('EnhancedRecordListController getTotalRecords query: ' + query);
        return Database.countQuery(query);
    }

    @AuraEnabled
    public static EnhancedRecordList getEnhancedRecordList(String targetObject, List<TargetField> targetFields, List<FilterGroup> filterGroups, String distinctTargetOrderByField, String targetOrderByField, Boolean ascending, Integer entriesForPage, List<Filter> firstValueOfSortedFields, List<Filter> lastValueOfSortedFields, Boolean nullsFirst) {
        EnhancedRecordList enhancedRecordList = new EnhancedRecordList();
        enhancedRecordList.objectName = targetObject;
        enhancedRecordList.columns = new List<Column>();
        enhancedRecordList.rows = new List<SObject>();

        Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        SObjectField sObjectField;
        DescribeFieldResult describeFieldResult;
        SObjectType sObjectType = schemaMap.get(targetObject);
        DescribeSObjectResult describeSObjectResult = sObjectType != null ? sObjectType.getDescribe() : null;

        if(describeSObjectResult != null && describeSObjectResult.isAccessible()) {
            enhancedRecordList.objectLabel = describeSObjectResult.getLabel();
            enhancedRecordList.objectLabelPlural = describeSObjectResult.getLabelPlural();

            for(TargetField field : targetFields) {
                sObjectField = describeSObjectResult.fields.getMap().get(field.fieldName);
                describeFieldResult = sObjectField != null ? sObjectField.getDescribe() : null;

                if(describeFieldResult != null && describeFieldResult.isAccessible()) {
                    enhancedRecordList.columns.add(new Column(
                            field.fieldName,
                            String.isBlank(field.customLabel) ? describeFieldResult.getLabel() : field.customLabel,
                            getType(describeFieldResult),
                            describeFieldResult.isSortable(),
                            describeFieldResult.isFilterable(),
                            field.isLinkable,
                            field.fieldUrl,
                            field.tooltipLabel,
                            field.wrapText
                    ));
                }
                else {
                    throw new EnhancedRecordListControllerException('Invalid \'' + field + '\' field');
                }
            }

            sObjectField = describeSObjectResult.fields.getMap().get(distinctTargetOrderByField);
            describeFieldResult = sObjectField != null ? sObjectField.getDescribe() : null;
            if(describeFieldResult == null || !describeFieldResult.isAccessible()) {
                throw new EnhancedRecordListControllerException('Invalid \'' + distinctTargetOrderByField + '\' distinct Order By field');
            }

            sObjectField = describeSObjectResult.fields.getMap().get(targetOrderByField);
            describeFieldResult = sObjectField != null ? sObjectField.getDescribe() : null;
            if(describeFieldResult == null || !describeFieldResult.isAccessible()) {
                throw new EnhancedRecordListControllerException('Invalid \'' + targetOrderByField + '\' distinct Order By field');
            }

            if(filterGroups != null) {
                for (FilterGroup filterGroup : filterGroups) {
                    if(filterGroup != null) {
                        for (Filter filter : filterGroup.filters) {
                            sObjectField = describeSObjectResult.fields.getMap().get(filter.fieldName);
                            describeFieldResult = sObjectField != null ? sObjectField.getDescribe() : null;

                            if (describeFieldResult == null || !describeFieldResult.isAccessible()) {
                                throw new EnhancedRecordListControllerException('Invalid \'' + filter.fieldName + '\' filter');
                            }
                        }
                    }
                }
            }

            if(firstValueOfSortedFields != null) {
                for (Filter filter : firstValueOfSortedFields) {
                    sObjectField = describeSObjectResult.fields.getMap().get(filter.fieldName);
                    describeFieldResult = sObjectField != null ? sObjectField.getDescribe() : null;

                    if (describeFieldResult == null || !describeFieldResult.isAccessible()) {
                        throw new EnhancedRecordListControllerException('Invalid \'' + filter.fieldName + '\' first value of sorted field');
                    }
                }
            }

            if(lastValueOfSortedFields != null) {
                for (Filter filter : lastValueOfSortedFields) {
                    sObjectField = describeSObjectResult.fields.getMap().get(filter.fieldName);
                    describeFieldResult = sObjectField != null ? sObjectField.getDescribe() : null;

                    if (describeFieldResult == null || !describeFieldResult.isAccessible()) {
                        throw new EnhancedRecordListControllerException('Invalid \'' + filter.fieldName + '\' last value of sorted field');
                    }
                }
            }
        }
        else {
            throw new EnhancedRecordListControllerException('Invalid \'' + targetObject + '\' Object');
        }

        enhancedRecordList.rows = getRecords(targetObject, targetFields, filterGroups, distinctTargetOrderByField, targetOrderByField, ascending, entriesForPage, firstValueOfSortedFields, lastValueOfSortedFields, nullsFirst);
        return  enhancedRecordList;
    }

    private static List<SObject> getRecords(String targetObject, List<TargetField> targetFields, List<FilterGroup> filterGroups, String distinctTargetOrderByField, String targetOrderByField, Boolean ascending, Integer entriesForPage, List<Filter> firstValueOfSortedFields, List<Filter> lastValueOfSortedFields, Boolean nullsFirst) {
        Set<String> fields = new Set<String>{distinctTargetOrderByField, targetOrderByField};

        for(TargetField targetField : targetFields) {
            if(fields.contains(targetField.fieldName)) {
                fields.remove(targetField.fieldName);
            }

            fields.add(targetField.toLabel == true ? ('toLabel(' + targetField.fieldName + ')') : targetField.fieldName);
        }

        String query = 'SELECT ' + String.join(new List<String>(fields), ',');
        query += ' FROM ' + targetObject;
        query += ' WHERE Id != NULL';

        query += getQueryFilters(targetObject, filterGroups);

        String orderDirection = ascending ? 'ASC' : 'DESC';
        String sortOperator = ascending ? ' > ' : ' < ';
        String nullsOrder = nullsFirst ?  ' NULLS FIRST ' : ' NULLS LAST ';
        List<Filter> valueOfSortedFields;

        if(lastValueOfSortedFields != null && !lastValueOfSortedFields.isEmpty()) {
            valueOfSortedFields = lastValueOfSortedFields;
        }
        else if(firstValueOfSortedFields != null && !firstValueOfSortedFields.isEmpty()) {
            valueOfSortedFields = firstValueOfSortedFields;
            orderDirection = ascending ? 'DESC' : 'ASC';
            sortOperator = ascending ? ' < ' : ' > ';
        }

        if(valueOfSortedFields != null) {
            Filter distinctOrderFilter;
            Filter orderFilter;

            for (Filter filter : valueOfSortedFields) {

                if(filter.fieldName == distinctTargetOrderByField) {
                    distinctOrderFilter = filter;
                }

                if(filter.fieldName == targetOrderByField) {
                    orderFilter = filter;
                }
            }

            if(distinctOrderFilter.fieldValue != null && orderFilter.fieldValue != null) {
                query += ' AND (' + orderFilter.fieldName + sortOperator + getOrderByFieldValue(targetObject, orderFilter);
                query += ' OR (' + orderFilter.fieldName + ' = ' + getOrderByFieldValue(targetObject, orderFilter) + ' AND ' + distinctOrderFilter.fieldName + sortOperator + getOrderByFieldValue(targetObject, distinctOrderFilter) + ')';
                query += ' OR (' + orderFilter.fieldName + ' = NULL  AND ' + distinctOrderFilter.fieldName + sortOperator + getOrderByFieldValue(targetObject, distinctOrderFilter) + '))';
            }
            else if(distinctOrderFilter.fieldValue != null && orderFilter.fieldValue == null) {
                query += ' AND (' + orderFilter.fieldName + ' = NULL AND ';
                query += distinctOrderFilter.fieldName + sortOperator + getOrderByFieldValue(targetObject, distinctOrderFilter) + ')';
            }
            else {
                throw new EnhancedRecordListControllerException('Missing order by filters');
            }
        }

        query += ' ORDER BY ' + targetOrderByField + ' ' + orderDirection + nullsOrder + ', ' + distinctTargetOrderByField + ' ' + orderDirection + nullsOrder + 'LIMIT ' + entriesForPage;

        System.debug('EnhancedRecordListController getRecords query: ' + query);
        List<SObject> result = Database.query(query);

        return result;
    }

    @TestVisible
    private static String getType(DescribeFieldResult describeFieldResult) {
        String result = 'text';

        if(describeFieldResult != null) {
            switch on describeFieldResult.getType() {
                when ID, STRING, TIME, COMBOBOX, PICKLIST, MULTIPICKLIST, DATACATEGORYGROUPREFERENCE, REFERENCE, TEXTAREA, ANYTYPE, ENCRYPTEDSTRING, COMPLEXVALUE, ADDRESS, SOBJECT, JSON {
                    result = 'text';
                }
                when BOOLEAN {
                    result = 'boolean';
                }
                when INTEGER, DOUBLE, LONG {
                    result = 'number';
                }
                when PERCENT {
                    result = 'percent';
                }
                when CURRENCY {
                    result = 'currency';
                }
                when DATE {
                    result = 'date-local';
                }
                when DATETIME {
                    result = 'date';
                }
                when PHONE {
                    result = 'phone';
                }
                when URL {
                    result = 'url';
                }
                when EMAIL {
                    result = 'email';
                }
            }
        }

        return result;
    }

    @TestVisible
    private static String getFilterOperator(String filterType) {
        switch on filterType {
            when 'EQUAL' {
                return ' = ';
            }
            when 'NOT_EQUAL' {
                return ' != ';
            }
            when 'IN' {
                return ' IN ';
            }
            when 'LIKE' {
                return ' LIKE ';
            }
            when else {
                throw new EnhancedRecordListControllerException('Invalid filter');
            }
        }
    }

    @TestVisible
    private static String getQueryFilter(DescribeFieldResult describeFieldResult, Filter filter) {
        String result = '';

        if(describeFieldResult != null && String.isNotBlank(filter.filterType)) {
            switch on describeFieldResult.getType() {
                when ID, STRING, TIME, COMBOBOX, PICKLIST, MULTIPICKLIST, DATACATEGORYGROUPREFERENCE, REFERENCE, TEXTAREA, ANYTYPE, ENCRYPTEDSTRING, COMPLEXVALUE, ADDRESS, SOBJECT, JSON, PHONE, URL, EMAIL {
                    if (filter.filterType == 'EQUAL' || filter.filterType == 'NOT_EQUAL') {
                        result = filter.fieldName + getFilterOperator(filter.filterType) + (filter.fieldValue != null ? ('\'' + String.escapeSingleQuotes((String) filter.fieldValue)+ '\'') : 'NULL');
                    }
                    else if (filter.filterType == 'IN' && filter.fieldValue != null) {
                        List<Object> fieldValueObjects = (List<Object>) filter.fieldValue;

                        if(fieldValueObjects != null && !fieldValueObjects.isEmpty()) {
                            result = filter.fieldName + getFilterOperator(filter.filterType) + '(\'';

                            for(Integer i = 0; i < fieldValueObjects.size(); i++) {
                                result += String.escapeSingleQuotes((String) fieldValueObjects[i]);

                                if(i < fieldValueObjects.size() - 1) {
                                    result += '\',\'';
                                }
                            }

                            result += '\')';
                        }
                    }
                    else if (filter.filterType == 'LIKE' && filter.fieldValue != null) {
                        result = filter.fieldName + getFilterOperator(filter.filterType) + '\'%' + String.escapeSingleQuotes((String) filter.fieldValue) + '%\'';
                    }
                    else {
                        throw new EnhancedRecordListControllerException('Invalid filter');
                    }
                }
                when BOOLEAN, INTEGER, DOUBLE, LONG, PERCENT, CURRENCY, DATE {
                    if (filter.filterType == 'EQUAL' || filter.filterType == 'NOT_EQUAL') {
                        result = filter.fieldName + getFilterOperator(filter.filterType) + (filter.fieldValue != null ? String.escapeSingleQuotes(String.valueOf(filter.fieldValue)) : 'NULL');
                    }
                    else if (filter.filterType == 'IN' && filter.fieldValue != null) {
                        List<Object> fieldValueObjects = (List<Object>) filter.fieldValue;

                        if(fieldValueObjects != null && !fieldValueObjects.isEmpty()) {
                            result = filter.fieldName + getFilterOperator(filter.filterType) + '(';

                            for(Integer i = 0; i < fieldValueObjects.size(); i++) {
                                result += String.escapeSingleQuotes(String.valueOf(fieldValueObjects[i]));

                                if(i < fieldValueObjects.size() - 1) {
                                    result += ',';
                                }
                            }

                            result += ')';
                        }
                    }
                    else {
                        throw new EnhancedRecordListControllerException('Invalid filter');
                    }
                }
                when DATETIME {
                    if (filter.filterType == 'EQUAL' || filter.filterType == 'NOT_EQUAL') {
                        result = filter.fieldName + getFilterOperator(filter.filterType) + (filter.fieldValue != null ? ((Datetime) filter.fieldValue).formatGmt('yyyy-MM-dd\'T\'HH:mm:ss+00:00') : 'NULL');
                    }
                    else if (filter.filterType == 'IN' && filter.fieldValue != null) {
                        List<Object> fieldValueObjects = (List<Object>) filter.fieldValue;

                        if(fieldValueObjects != null && !fieldValueObjects.isEmpty()) {
                            result = filter.fieldName + getFilterOperator(filter.filterType) + '(';

                            for(Integer i = 0; i < fieldValueObjects.size(); i++) {
                                result += ((Datetime) fieldValueObjects[i]).formatGmt('yyyy-MM-dd\'T\'HH:mm:ss+00:00');

                                if(i < fieldValueObjects.size() - 1) {
                                    result += ',';
                                }
                            }

                            result += ')';
                        }
                    }
                    else {
                        throw new EnhancedRecordListControllerException('Invalid filter');
                    }
                }
            }
        }
        else {
            throw new EnhancedRecordListControllerException('Invalid filter');
        }

        return result;
    }

    private static String getQueryFilters(String targetObject, List<FilterGroup> filterGroups) {
        String queryFilter = '';

        if(filterGroups != null) {
            for(FilterGroup filterGroup : filterGroups) {
                if(filterGroup != null && filterGroup.filters != null && !filterGroup.filters.isEmpty()) {
                    queryFilter += ' AND (';
                    List<String> filters = new List<String>();

                    for (Filter filter : filterGroup.filters) {
                        Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
                        SObjectType sObjectType = schemaMap.get(targetObject);
                        DescribeSObjectResult describeSObjectResult = sObjectType != null ? sObjectType.getDescribe() : null;

                        if (describeSObjectResult != null && describeSObjectResult.isAccessible()) {
                            SObjectField sObjectField = describeSObjectResult.fields.getMap().get(filter.fieldName);
                            DescribeFieldResult describeFieldResult = sObjectField != null ? sObjectField.getDescribe() : null;

                            if (describeFieldResult != null && describeFieldResult.isAccessible()) {
                                String filterString = getQueryFilter(describeFieldResult, filter);
                                if(String.isNotBlank(filterString)) {
                                    filters.add(filterString);
                                }
                            }
                        }
                    }

                    queryFilter += String.join(filters, String.isNotBlank(filterGroup.logicalOperator) && filterGroup.logicalOperator.trim() == 'OR' ? ' OR ' : ' AND ');
                    queryFilter += ')';
                }
            }
        }

        return queryFilter;
    }

    @TestVisible
    private static String getOrderByFieldValue(String targetObject, Filter filter) {
        String result = '';

        if(targetObject != null && String.isNotBlank(targetObject) && filter != null) {
            Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
            SObjectType sObjectType = schemaMap.get(targetObject);
            DescribeSObjectResult describeSObjectResult = sObjectType != null ? sObjectType.getDescribe() : null;
            SObjectField sObjectField = describeSObjectResult.fields.getMap().get(filter.fieldName);
            DescribeFieldResult describeFieldResult = sObjectField != null ? sObjectField.getDescribe() : null;

            if(describeFieldResult != null && filter.fieldValue != null) {
                switch on describeFieldResult.getType() {
                    when ID, STRING, TIME, COMBOBOX, PICKLIST, MULTIPICKLIST, DATACATEGORYGROUPREFERENCE, REFERENCE, TEXTAREA, ANYTYPE, ENCRYPTEDSTRING, COMPLEXVALUE, ADDRESS, SOBJECT, JSON, PHONE, URL, EMAIL {
                        result = '\'' + String.escapeSingleQuotes((String) filter.fieldValue) + '\'';
                    }
                    when BOOLEAN, INTEGER, DOUBLE, LONG, PERCENT, CURRENCY, DATE {
                        result = String.escapeSingleQuotes(String.valueOf(filter.fieldValue));
                    }
                    when DATETIME {
                        //System.debug('----> filter.fieldValue: ' + filter.fieldValue );
                        //System.debug('----> filter.fieldValue: ' + (filter.fieldValue instanceof String ));
                        //result = ((Datetime) filter.fieldValue).formatGmt('yyyy-MM-dd\'T\'HH:mm:ss+00:00');
                        result = String.valueOf(filter.fieldValue);
                    }
                    when else {
                        throw new EnhancedRecordListControllerException('Invalid filter');
                    }
                }
            }
        }
        else {
            throw new EnhancedRecordListControllerException('Invalid filter');
        }

        return result;
    }

    public class EnhancedRecordListControllerException extends Exception{}
}