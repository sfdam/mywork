/**
 * Name         :   RedirectUrlController
 * Create Date  :   2020-09-30
 * Author       :   Ezio Dal Bo @TEN
 */
public class RedirectUrlController {
    @AuraEnabled
    public static Map<String,Object> getUrlInfo(Map<String,Object> fullParameters) {
        Map<String,Object> urlInfo = new Map<String,Object>();
        String cmdType = (String)fullParameters.get('c__cmdtype');
        String sObjectName = (String)fullParameters.get('c__sobjectname'); 
        
        Switch on sObjectName {
            when 'Case' {
                Switch on cmdType {
                    when 'BHELP' {
                        urlInfo = getEndPointUrl(cmdType);
                    }
                    when else {
                        throw new AuraHandledException('cmdType \''+cmdType+'\' non previsto');
                    }
                }
            }
            when else {
                throw new AuraHandledException('sObjectName \''+sObjectName+'\' non previsto');
            }
        }
        return urlInfo;
    }
    
    private static Map<String,Object> extractUrlInfo(String url) {
        System.debug('AAA url' + url);
        Map<String,Object> parameters = new Map<String,Object>();
        
        List<String> splitUrl = url.split('\\?');
        parameters.put('c__url',splitUrl.get(0));
        parameters.put('_url_parameters',new Map<String,String>());
        if (splitUrl.size()>1) {
            Map<String,String> params = (Map<String,String>)parameters.get('_url_parameters');
            splitUrl = splitUrl.get(1).split('&');
            for (Integer i=0; i<splitUrl.size(); i++) {
                List<String> splitParam = splitUrl.get(i).split('=');
                params.put(splitParam.get(0),(splitParam.size()>1 ? splitParam.get(1) : ''));
            }
            parameters.put('_url_parameters',params);
        }
        return parameters;
    }
    
    private static Map<String,Object> getEndPointUrl(String epName){
        Map<String,Object> mUrlInfo = new Map<String,Object>{
            'c__url'=>null,
            '_url_parameters'=>new Map<String,String>()
        };
        Map<String,Endpoint__c> ep = Endpoint__c.getAll();
        if (!ep.isEmpty()) {
            String epUrl = (String)ep.get(epName).Endpoint__c;
            if (!String.isEmpty(epUrl)) {
				mUrlInfo = extractUrlInfo(epUrl);
            }
        }
        return mUrlInfo;
    }
}