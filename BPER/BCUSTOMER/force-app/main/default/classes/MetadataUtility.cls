/****
 * Name			:	MetadataUtility
 * Author		:	Ezio Dal Bo @TEN
 * Create Date	:	2020-10-26
 ****/
public class MetadataUtility {

    /****
     * Name			:	getMetadataFields
     * Author		:	Ezio Dal Bo @TEN
     * Create Date	:	2020-10-26
     ****/
    private static List<String> getMetadataFields(String metadataName) {
        List<Schema.DescribeSObjectResult> dsrs = Schema.describeSObjects(new List<String>{metadataName});
        Schema.DescribeSObjectResult sr = dsrs.get(0);
        Map<String,Schema.SObjectField> mfr = sr.fields.getMap();
        return (mfr!=null && mfr.size()>0 ? new List<String>(mfr.keySet()) : new List<String>());
    }
    
    /****
     * Name			:	makeQuery
     * Author		:	Ezio Dal Bo @TEN
     * Create Date	:	2020-10-26
     ****/
    public static List<Sobject> makeQuery(String metadataName, String whereCondition,List<String> queryFields) {
        List<SObject> result = null;
       
        String query = 'SELECT '+String.escapeSingleQuotes(String.join(queryFields, ','))+' FROM '+ metadataName+' ';
        query += (!String.isEmpty(WhereCondition) ? WhereCondition : '');
        try {
            result = Database.query(query);
        }
        catch(Exception exc) {
            System.debug('An exception occurred '+exc.getMessage());
            result = null;
            throw exc;
        }
        
        return (result!=null && result.size()>0 ? result : new List<SObject>());
    }
    
    /****
     * Name			:	makeQuery
     * Author		:	Ezio Dal Bo @TEN
     * Create Date	:	2020-10-26
     ****/
    public static List<Sobject> makeQuery(String metadataName, String whereCondition) {
        List<String> queryFields = getMetadataFields(metadataName);
        List<SObject> result = null;
       
        String query = 'SELECT '+String.escapeSingleQuotes(String.join(queryFields, ','))+' FROM '+metadataName+' ';
        query += (!String.isEmpty(WhereCondition) ? WhereCondition : '');
        try {
            result = Database.query(query);
        }
        catch(Exception exc) {
            System.debug('An exception occurred '+exc.getMessage());
            result = null;
            throw exc;
        }
        
        return (result!=null && result.size()>0 ? result : new List<SObject>());
    }
    
    /****
     * Name			:	getAllByMetadataName
     * Author		:	Ezio Dal Bo @TEN
     * Create Date	:	2020-10-26
     ****/
    public static Map<String,SObject> getAllByMetadataName(String metadataName) {
        List<String> metadataFields = getMetadataFields(metadataName);
        Map<String,SObject> mResult = new Map<String,SObject>();
        try { 
        	List<Sobject> result = makeQuery(metadataName,null,metadataFields);
            if (result!=null && result.size()>0) {
                for (SObject so : result) {
                    mResult.put((String)so.get('DeveloperName'),so);
                }
            }
        }
        catch(Exception exc) {
            throw exc;
        }
        
        return mResult;
    }
    
    /****
     * Name			:	getAllByMetadataName
     * Author		:	Ezio Dal Bo @TEN
     * Create Date	:	2020-10-26
     ****/
    public static SObject getRecordByName(String metadataName, String name) {
        List<String> metadataFields = getMetadataFields(metadataName);
        SObject soResult = null;
        String whereCondition = ' WHERE DeveloperName =\''+String.escapeSingleQuotes(name)+'\'';
        try { 
        	List<Sobject> result = makeQuery(metadataName,whereCondition,metadataFields);
            if (result!=null && result.size()>0) {
                soResult = result.get(0);
            }
        }
        catch(Exception exc) {
            throw exc;
        }
        
        return soResult;
    }
    
    /****
     * Name			:	getRecordByPrefix
     * Author		:	Ezio Dal Bo @TEN
     * Create Date	:	2020-10-26
     ****/
    public static List<SObject> getRecordByPrefix(String metadataName, String prefix) {
        List<String> metadataFields = getMetadataFields(metadataName);
        String key = prefix+'%';
        List<Sobject> result  = null;
        String whereCondition = ' WHERE DeveloperName LIKE \''+String.escapeSingleQuotes(key)+'\'';
        try { 
        	result = makeQuery(metadataName,whereCondition,metadataFields);
        }
        catch(Exception exc) {
            throw exc;
        }
        
        return result;
    }
}