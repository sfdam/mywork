/**
 * Name         :   GenericCanvasController 
 * Author       :   Ezio Dal Bo @TEN
 * Create Date  :   2020-9-10
 * Description  :   Manage Canvas, retrieving information and parameters
 * Lightning    :   Used as Controller by GenericCanvas component
**/

public class GenericCanvasController {
    /****
     * Name         :   getCanvas
     * Author       :   Ezio Dal Bo @TEN
     * Create Date  :   2020-09-10
     ****/
    @AuraEnabled
    public static Map<String,Object> getCanvas(String devName,String sObjectName, Id sObjectId) {
        Map<String,Object> mCanvas = new Map<String,Object>(); 
        Map<String,Set<String>> mFieldsToQuery = new Map<String,Set<String>>();
        Boolean showCanvas = true;
        try {
            String whereCondition = ' WHERE DeveloperName =\''+String.escapeSingleQuotes(devName)+'\'';
            Map<String,Object> result = makeQueryMap('Canvas__mdt', whereCondition);
            Map<String,String> mParameters = new Map<String,String>();
            mCanvas.put('result',result);
            System.debug('result '+result);
            Boolean checkShowCanvas = (Boolean)result.get('check_show_canvas__c');
            String CheckCondition = (String)result.get('check_show_canvas_condition__c');
            if (checkShowCanvas && !String.isEmpty(CheckCondition)) {
                String mUserValue = null;
                String mSobjectValue = null;
                List<String> conditions = CheckCondition.split(';');
                System.debug('AAA conditions '+conditions);
                for (String key : conditions) {
                    if (key.startsWith('{$') && key.endsWith('$}')) {
                        key = key.subString(2);
                        key = key.substring(0,key.length()-2);
                        List<String> params = key.split('\\.');
                        String field = key.substring(params.get(0).length()+1);
                        System.debug('AAA field'+field);
                        System.debug('AAA key'+key);
                        mFieldsToQuery.put(params.get(0),new Set<String>{field});
                        System.debug('AAA mFieldsToQuery'+mFieldsToQuery);
                    }
                }
                Map<String,Object> mSObject = new Map<String,Object>();
                Map<String,Object> mUser = new Map<String,Object>();
                if (mFieldsToQuery.containsKey(sObjectName)) {
                    whereCondition = ' WHERE Id =\''+String.escapeSingleQuotes(sObjectId)+'\'';
                    mSObject = makeQueryMap(sObjectName,whereCondition,mFieldsToQuery.get(sObjectName));
                }
                if (mFieldsToQuery.containsKey('User')) {
                    whereCondition = ' WHERE Id =\''+String.escapeSingleQuotes(UserInfo.getUserId())+'\'';
                    mUser = makeQueryMap('User',whereCondition,mFieldsToQuery.get('User'));
                }
                for (String key : mSObject.keySet()) {
                    mSobjectValue = (String)mSObject.get(key);
                }
                for (String key : mUser.keySet()) {
                    mUserValue = (String)mUser.get(key);
                }
                System.debug('AAA mSobject'+mSobject);
                System.debug('AAA mUser'+mUser);
                showCanvas = false;
                if (!String.isEmpty(mSobjectValue) || !String.isEmpty(mUserValue)) {
                    showCanvas = (mSobjectValue==mUserValue);
                }
            }
            mCanvas.put('showCanvas',showCanvas);
            mFieldsToQuery.clear();
            if (result.containsKey('url_parameters__c') && showCanvas) {
                String urlParameters = (String)result.get('url_parameters__c');
                if (!String.isEmpty(urlParameters)) {
                    List<String> split_urlParameters = null;
                    split_urlParameters = urlParameters.split('&');
                    for (String s : split_urlParameters) {
                        List<String> values = s.split('=');
                        mParameters.put(values.get(0),(values.size()>1 ? values.get(1) : ''));
                        if (values.size()>1 && values.get(1).startsWith('{$') && values.get(1).endsWith('$}')) {
                            mParameters.put(values.get(0),values.get(1));
                            String param = values.get(1).subString(2);
                            param = param.substring(0,param.length()-2);
                            if (!String.isEmpty(param)) {
                                List<String> params = param.split('\\.');
                                Set<String> fields = (mFieldsToQuery.containsKey(params.get(0)) ? mFieldsToQuery.get(params.get(0)) : new Set<String>());
                                String f = param.substring(params.get(0).length()+1);
                                fields.add(f);
                                mFieldsToQuery.put(params.get(0),fields);
                            }
                            else {
                                mParameters.put(values.get(0),'');
                            }
                        }
                    }
                    if (!mFieldsToQuery.isEmpty()) {
                        Map<String,Object> mSObject = new Map<String,Object>();
                        Map<String,Object> mUser = new Map<String,Object>();
                        if (mFieldsToQuery.containsKey(sObjectName)) {
                            whereCondition = ' WHERE Id =\''+String.escapeSingleQuotes(sObjectId)+'\'';
                            mSObject = makeQueryMap(sObjectName,whereCondition,mFieldsToQuery.get(sObjectName));
                        }
                        if (mFieldsToQuery.containsKey('User')) {
                            whereCondition = ' WHERE Id =\''+String.escapeSingleQuotes(UserInfo.getUserId())+'\'';
                            mUser = makeQueryMap('User',whereCondition,mFieldsToQuery.get('User'));
                        }
                        System.debug('AAA mFieldsToQuery '+mFieldsToQuery);
                        for (String key : mParameters.keySet()) {
                            String param = mParameters.get(key);
                            if (param.startsWith('{$') && param.endsWith('$}')) {
                                param = param.subString(2);
                                param = param.substring(0,param.length()-2);
                                List<String> params = param.split('\\.');
                                String value = '';
                                if (params.get(0).equals(sObjectName)) {
                                    param = param.substring(params.get(0).length()+1);
                                    value = (mSObject.containsKey(param) ? (String)mSObject.get(param) : '');
                                }
                                if (params.get(0).equals('User')) {
                                    param = param.substring(params.get(0).length()+1);
                                    value = (mUser.containsKey(param) ? (String)mUser.get(param) : '');
                                }
                                mParameters.put(key,value);
                            }
                        }
                    }
                    mCanvas.put('url_parameters',mParameters);
                }
            }
        }
        catch(Exception exc) {
            System.debug('An exception occurred '+exc.getMessage());
            throw new AuraHandledException(exc.getMessage());
        }
        
        return mCanvas;
    }
    
    /****
     * Name         :   getMetadataFields
     * Author       :   Ezio Dal Bo @TEN
     * Create Date  :   2020-09-10
     ****/
    private static List<String> getMetadataFields(String metadataName) {
        List<Schema.DescribeSObjectResult> dsrs = Schema.describeSObjects(new List<String>{metadataName});
        Schema.DescribeSObjectResult sr = dsrs.get(0);
        Map<String,Schema.SObjectField> mfr = sr.fields.getMap();
        return (mfr!=null && mfr.size()>0 ? new List<String>(mfr.keySet()) : new List<String>());
    }
    
    /****
     * Name         :   makeQuery
     * Author       :   Ezio Dal Bo @TEN
     * Create Date  :   2020-09-10
     ****/
    public static List<Sobject> makeQuery(String metadataName, String whereCondition,List<String> queryFields) {
        List<SObject> result = null;
       
        String query = 'SELECT '+ String.escapeSingleQuotes(String.join(queryFields, ',')) +' FROM '+ metadataName +' ';
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
     * Name         :   makeQueryMap
     * Author       :   Ezio Dal Bo @TEN
     * Create Date  :   2020-09-10
     ****/
    public static Map<String,Object> makeQueryMap(String metadataName, String whereCondition) {
        Map<String,Object> mResult = new Map<String,Object>();
        List<String> metadataFields = getMetadataFields(metadataName);
        try {
            List<Sobject> result = makeQuery(metadataName,whereCondition,metadataFields);
            if (result!=null && result.size()>0) {
                for (Sobject r : result) {
                    for (String f : metadataFields) {
                        mResult.put(f,r.get(f));
                    }
                }
            }
        }
        catch(Exception exc) {
            System.debug('An exception occurred 1'+exc.getMessage());
            throw exc;
        }
        return mResult;
    }
    /****
     * Name         :   makeQueryMap
     * Author       :   Ezio Dal Bo @TEN
     * Create Date  :   2020-09-22
     ****/   
    public static Map<String,Object> makeQueryMap(String sObjectName, String whereCondition,Set<String> fields) {
        Map<String,Object> mResult = new Map<String,Object>();
        List<String> sObjectFields = new List<String>();
        sObjectFields.addAll(fields);
        try {
            List<Sobject> result = makeQuery(sObjectName,whereCondition,sObjectFields);
            
            if (result!=null && result.size()>0) {
                for (Sobject r : result) {
                    for (String f : sObjectFields) {
                        if (f.contains('.')) {
                            List<String> sf = f.split('\\.');
                            Sobject rObj = r;
                            for (Integer i=0; i<sf.size()-1; i++) {
                                System.debug('AAA 123 '+sf.get(i));
                                rObj = rObj.getSObject(sf.get(i));
                            }
                            System.debug('AAA 123 '+rObj);
                            mResult.put(f,rObj.get(sf.get(sf.size()-1)));
                        }
                        else {
                           mResult.put(f,r.get(f)); 
                        }
                    }
                }
            }
        }
        catch(Exception exc) {
            System.debug('An exception occurred 2'+exc.getMessage());
            throw exc;
        }
        System.debug('AAA mResult' + mResult);
        return mResult;
    }
}