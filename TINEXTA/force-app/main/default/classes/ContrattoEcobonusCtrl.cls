public without sharing class ContrattoEcobonusCtrl {
    
    public String pdfData {get;set;}
    public String[] fields = new String[]{'oppName','oppAmount','AccountName'}; 


    public ContrattoEcobonusCtrl(){
        String id = ApexPages.currentPage().getParameters().get('id');

       

        Opportunity opp = [SELECT Id, Name, Amount, Account.Name, WRT_Tipologia_Prodotto_Ecobonus__c FROM Opportunity WHERE Id =: id];
        OpportunityLineItem opli = [SELECT Id, Prezzo_con_IVA__c FROM OpportunityLineItem WHERE OpportunityId =: opp.Id];

        String body = [SELECT Id, Body FROM StaticResource WHERE Name =:opp.WRT_Tipologia_Prodotto_Ecobonus__c].Body.toString();

        // Map<String,String> dynamicFields = new Map<String,String>{'AccountName' => opp.Account.Name, 'oppName' => opp.Id, 'oppAmount' => String.valueOf(opp.Amount)};
        Map<String,String> dynamicFields = new Map<String,String>{'AccountName' => opp.Account.Name, 'oppName' => opp.Id, 'oppAmount' => String.valueOf(opli.Prezzo_con_IVA__c)};

        System.debug('@@@ opp ' + opp);

        for(String field : this.fields){
            body = body.replace('{'+field+'}', dynamicFields.get(field));
        }

        this.pdfData = body;
    }

    @AuraEnabled
    public static String getContratto(String contactId, String oppId){
        try {

            Contact c = [SELECT Id, Name, AccountId FROM Contact WHERE Id =: contactId];
            Opportunity opp = [SELECT Id, Name, WRT_Tipologia_Prodotto_Ecobonus__c FROM Opportunity WHERE Id =: oppId AND AccountId =: c.AccountId];

            return opp.Name;

        } catch(QueryException e){
            throw new AuraHandledException('Contratto non trovato');
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static String getContrattoBlob(String contactId, String oppId){
        try {

            Contact c = [SELECT Id, Name, AccountId FROM Contact WHERE Id =: contactId];
            Opportunity opp = [SELECT Id, Name, Account.Name, Amount, WRT_Tipologia_Prodotto_Ecobonus__c FROM Opportunity WHERE Id =: oppId AND AccountId =: c.AccountId];
            OpportunityLineItem opli = [SELECT Id, Prezzo_con_IVA__c FROM OpportunityLineItem WHERE OpportunityId =: opp.Id];

            String body = [SELECT Id, Body FROM StaticResource WHERE Name =:opp.WRT_Tipologia_Prodotto_Ecobonus__c].Body.toString();

            List<String> fields = new List<String>{'oppName','oppAmount','AccountName'};
            // Map<String,String> dynamicFields = new Map<String,String>{'AccountName' => opp.Account.Name, 'oppName' => opp.Id, 'oppAmount' => String.valueOf(opp.Amount)};
            Map<String,String> dynamicFields = new Map<String,String>{'AccountName' => opp.Account.Name, 'oppName' => opp.Id, 'oppAmount' => String.valueOf(opli.Prezzo_con_IVA__c)};
    
            System.debug('@@@ opp ' + opp);
    
            for(String field : fields){
                body = body.replace('{'+field+'}', dynamicFields.get(field));
            }

            //Blob bodyBlob = Blob.valueOf(body);

            return body;

        } catch(QueryException e){
            throw new AuraHandledException('Contratto non trovato');
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}