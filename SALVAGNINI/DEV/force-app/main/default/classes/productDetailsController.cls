public with sharing class productDetailsController {
    
    public static map<string,string> langKeys = new Map<string,string> {'zh_CN' => 'CHN', 'zh_TW' => 'CHN', 'fr' => 'FRA', 'de' => 'DEU', 'it' => 'ITA', 'ru' => 'RUS', 'en_GB' => 'ENG', 'en_US' => 'ENG', 'es' => 'ESP', 'pl' => 'POL', 'pt_PT' => 'PT', 'pt_BR' => 'PT'};
    
    @AuraEnabled
    public static Map<String, List<String>> getDescriptions(string recordId){
        Map<String, List<String>> langToDescMap = new Map<String, List<String>>();
        
        SBQQ__ProductOption__c prodOp = [SELECT Id, SVG_Technical_Description_HTML__c,
                                            Additional_Description_CHN__c,Additional_Description_DEU__c,Additional_Description_ENG__c,
                                            Additional_Description_ESP__c,Additional_Description__c,Additional_Description_ITA__c,
                                            Additional_Description_POL__c,Additional_Description_PT__c,Additional_Description_RUS__c,
                                            SBQQ__OptionalSKU__r.Technical_Description_CH__c,SBQQ__OptionalSKU__r.Technical_Description_DEU__c,
                                            SBQQ__OptionalSKU__r.Technical_Description_ENG__c,SBQQ__OptionalSKU__r.Technical_Description_SPA__c,
                                            SBQQ__OptionalSKU__r.Technical_Description__c,SBQQ__OptionalSKU__r.SVG_Technical_Description_HTML__c,
                                            SBQQ__OptionalSKU__r.Technical_Description_POL__c,SBQQ__OptionalSKU__r.Technical_Description_PT__c,
                                            SBQQ__OptionalSKU__r.Technical_Description_RUS__c,
                                            SBQQ__OptionalSKU__r.Product_Description_CHN__c, SBQQ__OptionalSKU__r.Product_Description_DEU__c, SBQQ__OptionalSKU__r.Product_Description_ENG__c,
                                            SBQQ__OptionalSKU__r.Product_Description_ESP__c, SBQQ__OptionalSKU__r.Product_Description_FRA__c, SBQQ__OptionalSKU__r.Product_Description_ITA__c, 
                                            SBQQ__OptionalSKU__r.Product_Description_POL__c, SBQQ__OptionalSKU__r.Product_Description_PT__c, SBQQ__OptionalSKU__r.Product_Description_RUS__c,
                                            SBQQ__OptionalSKU__r.SVG_Image_URL__c, SBQQ__OptionalSKU__r.Name
                                        FROM SBQQ__ProductOption__c 
                                        WHERE Id = :recordId];

        langToDescMap.put('CHN', new List<String>{
            (prodOp.SBQQ__OptionalSKU__r.Name + ' - ' + prodOp.SBQQ__OptionalSKU__r.Product_Description_CHN__c).remove('null'),
            (prodOp.SBQQ__OptionalSKU__r.Technical_Description_CH__c + prodOp.Additional_Description_CHN__c).remove('null')
        });
        langToDescMap.put('DEU', new List<String>{
            (prodOp.SBQQ__OptionalSKU__r.Name + ' - ' + prodOp.SBQQ__OptionalSKU__r.Product_Description_DEU__c).remove('null'),
            (prodOp.SBQQ__OptionalSKU__r.Technical_Description_DEU__c + prodOp.Additional_Description_DEU__c).remove('null')
                                                    
        });
        langToDescMap.put('ENG', new List<String>{
            (prodOp.SBQQ__OptionalSKU__r.Name + ' - ' + prodOp.SBQQ__OptionalSKU__r.Product_Description_ENG__c).remove('null'),
            (prodOp.SBQQ__OptionalSKU__r.Technical_Description_ENG__c + prodOp.Additional_Description_ENG__c).remove('null')
        });
        langToDescMap.put('ESP', new List<String>{
            (prodOp.SBQQ__OptionalSKU__r.Name + ' - ' + prodOp.SBQQ__OptionalSKU__r.Product_Description_ESP__c).remove('null'),
            (prodOp.SBQQ__OptionalSKU__r.Technical_Description_SPA__c + prodOp.Additional_Description_ESP__c).remove('null')
        });
        langToDescMap.put('FRA', new List<String>{
            (prodOp.SBQQ__OptionalSKU__r.Name + ' - ' + prodOp.SBQQ__OptionalSKU__r.Product_Description_FRA__c).remove('null'),
            (prodOp.SBQQ__OptionalSKU__r.Technical_Description__c + prodOp.Additional_Description__c).remove('null')
        });
        langToDescMap.put('ITA', new List<String>{
            (prodOp.SBQQ__OptionalSKU__r.Name + ' - ' + prodOp.SBQQ__OptionalSKU__r.Product_Description_ITA__c).remove('null'),
            (prodOp.SBQQ__OptionalSKU__r.SVG_Technical_Description_HTML__c + prodOp.Additional_Description_ITA__c).remove('null')
        });
        langToDescMap.put('POL', new List<String>{
            (prodOp.SBQQ__OptionalSKU__r.Name + ' - ' + prodOp.SBQQ__OptionalSKU__r.Product_Description_POL__c).remove('null'),
            (prodOp.SBQQ__OptionalSKU__r.Technical_Description_POL__c + prodOp.Additional_Description_POL__c).remove('null')
        });
        langToDescMap.put('PT', new List<String>{
            (prodOp.SBQQ__OptionalSKU__r.Name + ' - ' + prodOp.SBQQ__OptionalSKU__r.Product_Description_PT__c).remove('null'),
            (prodOp.SBQQ__OptionalSKU__r.Technical_Description_PT__c+prodOp.Additional_Description_PT__c).remove('null')
        });
        langToDescMap.put('RUS', new List<String>{
            (prodOp.SBQQ__OptionalSKU__r.Name + ' - ' + prodOp.SBQQ__OptionalSKU__r.Product_Description_RUS__c).remove('null'),
            (prodOp.SBQQ__OptionalSKU__r.Technical_Description_RUS__c+prodOp.Additional_Description_RUS__c).remove('null')
        });

        langToDescMap.put('IMG_URL', new List<String>{prodOp.SBQQ__OptionalSKU__r.SVG_Image_URL__c});
 
        langToDescMap.put('USER', new List<String>{langKeys.get([SELECT LanguageLocaleKey FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1].LanguageLocaleKey)});
        
        return langToDescMap;
    }

    
}