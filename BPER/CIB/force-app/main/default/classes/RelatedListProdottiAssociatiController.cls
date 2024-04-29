public class RelatedListProdottiAssociatiController {

    @AuraEnabled
    public static List<productCampaign> getProdottiAssociati(String campaignId){
        List<productCampaign> associatedProductList = new List<productCampaign>();
        Map<Integer, List<String>> mapCodeLevel = new Map<Integer, List<String>>();
        Map<Integer, Map<String, SObject>> mapCodeProd = new Map<Integer, Map<String, SObject>>();

        try {

            List<String> productIdList = new List<String>();
            List<CRM_AssociazioneProdottiCampagna__c> junctionList = [SELECT CRM_LivelloProdotto__c, CRM_CodiceProdotto__c, CRM_DescrizioneProdotto__c, CRM_Prodotto__r.Id,CRM_Prodotto__r.CRM_Bisogno__c, CRM_Prodotto__r.CRM_Group__c, CRM_Prodotto__r.CRM_ProductCategory__c, CRM_Prodotto__r.CRM_SubGroup__c, CRM_Prodotto__r.CRM_MacroGroup__c, CRM_Prodotto__r.Name  FROM CRM_AssociazioneProdottiCampagna__c WHERE CRM_Campagna__r.Id = :campaignId];

            //costruisco mappa livello prodotto - lista di codici prodotto
            for(CRM_AssociazioneProdottiCampagna__c junct : junctionList){
                if(junct.CRM_Prodotto__c==null){
                    System.debug('Step1: '+Integer.ValueOf(junct.CRM_LivelloProdotto__c));
                    if(!mapCodeLevel.containsKey(Integer.ValueOf(junct.CRM_LivelloProdotto__c)))
                        mapCodeLevel.put(Integer.ValueOf(junct.CRM_LivelloProdotto__c),new List<String>{junct.CRM_CodiceProdotto__c} );
                    else
                        mapCodeLevel.get(Integer.ValueOf(junct.CRM_LivelloProdotto__c)).add(junct.CRM_CodiceProdotto__c);
                        System.debug('Step2');
                    }
                    System.debug('Step3: '+mapCodeLevel);
            }
            
            /*if(!mapCodeLevel.isEmpty())
                mapCodeProd = getStructureProduct(mapCodeLevel);*/

            for(CRM_AssociazioneProdottiCampagna__c junct : junctionList){
                
                productCampaign pcTemp = new productCampaign();
                if(junct.CRM_Prodotto__c!=null){
                    pcTemp.prodName = junct.CRM_Prodotto__r.Name;
                    pcTemp.prodSottogruppo = junct.CRM_Prodotto__r.CRM_SubGroup__c;
                    pcTemp.prodGruppo = junct.CRM_Prodotto__r.CRM_Group__c;
                    pcTemp.prodMacrogruppo = junct.CRM_Prodotto__r.CRM_MacroGroup__c;
                    pcTemp.prodCategoria = junct.CRM_Prodotto__r.CRM_ProductCategory__c;
                    pcTemp.prodBisogno = junct.CRM_Prodotto__r.CRM_Bisogno__c;
                } else {
                    if(Integer.ValueOf(junct.CRM_LivelloProdotto__c) == 1){
                        pcTemp.prodBisogno = junct.CRM_DescrizioneProdotto__c;
                    }
                    if(Integer.ValueOf(junct.CRM_LivelloProdotto__c) == 2){
                        pcTemp.prodCategoria = junct.CRM_DescrizioneProdotto__c;
                    }
                    if(Integer.ValueOf(junct.CRM_LivelloProdotto__c) == 3){
                        pcTemp.prodMacrogruppo = junct.CRM_DescrizioneProdotto__c;
                    }
                    if(Integer.ValueOf(junct.CRM_LivelloProdotto__c) == 4){
                        pcTemp.prodGruppo = junct.CRM_DescrizioneProdotto__c;
                    }
                    if(Integer.ValueOf(junct.CRM_LivelloProdotto__c) == 5){
                        pcTemp.prodSottogruppo = junct.CRM_DescrizioneProdotto__c;
                    }
                    if(Integer.ValueOf(junct.CRM_LivelloProdotto__c) == 6){
                        pcTemp.prodName = junct.CRM_DescrizioneProdotto__c;
                    }
                    /*System.debug('Step4: '+mapCodeProd.containsKey(Integer.ValueOf(junct.CRM_LivelloProdotto__c)));
                    System.debug('Step5: '+mapCodeProd.get(Integer.ValueOf(junct.CRM_LivelloProdotto__c)).containsKey(junct.CRM_CodiceProdotto__c));
                    if(mapCodeProd.containsKey(Integer.ValueOf(junct.CRM_LivelloProdotto__c)) && 
                        mapCodeProd.get(Integer.ValueOf(junct.CRM_LivelloProdotto__c)).containsKey(junct.CRM_CodiceProdotto__c)){
                        Product2 prod = (Product2)mapCodeProd.get(Integer.ValueOf(junct.CRM_LivelloProdotto__c)).get(junct.CRM_CodiceProdotto__c);
                        pcTemp.prodName = prod.Name;
                        pcTemp.prodSottogruppo = prod.CRM_SubGroup__c;
                        pcTemp.prodGruppo = prod.CRM_Group__c;
                        pcTemp.prodMacrogruppo = prod.CRM_MacroGroup__c;
                        pcTemp.prodCategoria = prod.CRM_ProductCategory__c;
                        pcTemp.prodBisogno = prod.CRM_Bisogno__c;
                    }*/
                    
                }
                

                associatedProductList.add(pcTemp);
            }
            
            /*
            associatedProductList = [SELECT CRM_Bisogno__c, CRM_Group__c, CRM_ProductCategory__c, CRM_SubGroup__c, CRM_MacroGroup__c, Name
                                    FROM Product2 WHERE id IN :productIdList];*/

            return associatedProductList;
            
        } catch (Exception e) {
            System.debug('AdF getProdottiAssociati exception: ' + e.getMessage()+' '+e.getStackTraceString());
            throw new AuraHandledException(e.getMessage());
        }

    }

    @AuraEnabled
    public static List<Product2> getProdottiAssociabili(String campaignId, String bisogno, String gruppo,
                                                        String categoria, String sottogruppo, String macrogruppo,
                                                        String elementare, List<Product2> coupledProduct){
        List<Product2> associableProductList = new List<Product2>();

        try {

            List<String> productIdList = new List<String>();
            for(Product2 product : coupledProduct){
                productIdList.add(product.Id);
            }

            String query = 'SELECT CRM_Bisogno__c, CRM_Group__c, CRM_ProductCategory__c, CRM_SubGroup__c, CRM_MacroGroup__c, Name FROM Product2';
            
            query += (productIdList.size() > 0) ? ' WHERE Id NOT IN :productIdList' : ' WHERE Id != null';
            
            if(String.isNotBlank(bisogno)){
                query += ' AND CRM_Bisogno__c LIKE \'%' + String.escapeSingleQuotes(bisogno) + '%\'';
            }
            if(String.isNotBlank(gruppo)){
                query += ' AND CRM_Group__c LIKE \'%' + String.escapeSingleQuotes(gruppo) + '%\'';
            }
            if(String.isNotBlank(categoria)){
                query += ' AND CRM_ProductCategory__c LIKE \'%' + String.escapeSingleQuotes(categoria) + '%\'';
            }
            if(String.isNotBlank(sottogruppo)){
                query += ' AND CRM_SubGroup__c LIKE \'%' + String.escapeSingleQuotes(sottogruppo) + '%\'';
            }
            if(String.isNotBlank(macrogruppo)){
                query += ' AND CRM_MacroGroup__c LIKE \'%' + String.escapeSingleQuotes(macrogruppo) + '%\'';
            }
            if(String.isNotBlank(elementare)){
                query += ' AND Name LIKE \'%' + String.escapeSingleQuotes(elementare) + '%\'';
            }

            query += ' LIMIT 500';

            associableProductList = Database.query(query);

            return associableProductList;

        } catch (Exception e) {
            System.debug('AdF getProdottiAssociabili exception: ' + e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static boolean removeProdotto(String campaignId, String productId){
        Boolean hasNoError = false;

        try {

            List<CRM_AssociazioneProdottiCampagna__c> junctionList = [SELECT Id FROM CRM_AssociazioneProdottiCampagna__c WHERE CRM_Campagna__r.Id = :campaignId AND CRM_Prodotto__r.Id = :productId LIMIT 1];
            delete junctionList;
            hasNoError = true;

            return hasNoError;

        } catch (Exception e) {
            System.debug('AdF removeProdotto exception: ' + e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static boolean associateProducts(String campaignId, List<String> selectedProductIdList){
        Boolean hasNoError = false;
        List<CRM_AssociazioneProdottiCampagna__c> junctionList = new List<CRM_AssociazioneProdottiCampagna__c>();

        try {

            for(String productId : selectedProductIdList){
                CRM_AssociazioneProdottiCampagna__c junct = new CRM_AssociazioneProdottiCampagna__c(CRM_Campagna__c = Id.valueOf(campaignId), CRM_Prodotto__c = Id.valueOf(productId));
                junctionList.add(junct);
            }

            insert junctionList;
            hasNoError = true;

            return hasNoError;
            
        } catch (Exception e) {
            System.debug('AdF associateProducts exception: ' + e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }
    }
    @AuraEnabled
    public static User getUserInfo(){
        return [SELECT id, Profile.Name FROM User WHERE id =:UserInfo.getUserId()];
    }
    
   

    public class productCampaign{
        @AuraEnabled 
        public String prodName {get;set;}
        @AuraEnabled 
        public String prodSottogruppo {get;set;}
        @AuraEnabled 
        public String prodGruppo {get;set;}
        @AuraEnabled 
        public String prodMacrogruppo {get;set;}
        @AuraEnabled 
        public String prodCategoria {get;set;}
        @AuraEnabled 
        public String prodBisogno {get;set;}


        public productCampaign(){
            this.prodName = '';
            this.prodSottogruppo = '';
            this.prodGruppo = '';
            this.prodMacrogruppo = '';
            this.prodCategoria = '';
            this.prodBisogno = '';
        }

        
       
    }

}