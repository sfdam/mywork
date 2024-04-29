public without sharing class ViewinBrowser {
    
    public String pdfData {get;set;}
    public String[] fields = new String[]{'FirstName','LastName', 'ContactId'}; 


    public ViewinBrowser(){
        String id = ApexPages.currentPage().getParameters().get('id');
        string body='';

        	WRT_Transazione__c trans = [SELECT Id, Nome_del_Cliente__c, Cognome_del_Cliente__c,ContactId__c, Opportunit__r.WRT_TagDinamica__c,Opportunit__r.WRT_Tipologia_Prodotto_Ecobonus__c  FROM WRT_Transazione__c WHERE Id =: id];

        If(trans.Opportunit__r.WRT_TagDinamica__c == 'Ecobonus Privato - con acquisto'){
            If(trans.Opportunit__r.WRT_Tipologia_Prodotto_Ecobonus__c == 'PrivatoGREEN110POSITIONINGPREFATTIBILITA'){
        		body = [SELECT Id, Body FROM StaticResource WHERE Name =: 'Privato2'].Body.toString();
            }
            else if(trans.Opportunit__r.WRT_Tipologia_Prodotto_Ecobonus__c == 'CondominioPrivatoGREEN110POSITIONING'){
                body = [SELECT Id, Body FROM StaticResource WHERE Name =: 'Privato1'].Body.toString();
            }
        }
        else{
             body = [SELECT Id, Body FROM StaticResource WHERE Name =: 'NonPrivato'].Body.toString();
        }

        // Map<String,String> dynamicFields = new Map<String,String>{'AccountName' => opp.Account.Name, 'oppName' => opp.Id, 'oppAmount' => String.valueOf(opp.Amount)};
        Map<String,String> dynamicFields = new Map<String,String>{'FirstName' => trans.Nome_del_Cliente__c, 'LastName' => trans.Cognome_del_Cliente__c, 'ContactId'=> trans.ContactId__c};

        System.debug('@@@ transazione ' + trans);

        for(String field : this.fields){
            body = body.replace('{'+field+'}', dynamicFields.get(field));
        }

        this.pdfData = body;
    }

/*    @AuraEnabled
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
    }*/
}