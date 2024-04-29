public class AsyncQuoteCopy implements Queueable{
    private Set<Id> quoteIds;
    
    public AsyncQuoteCopy(Set<Id> Id_Quote) {
        this.quoteIds = Id_Quote; //PONGO IL SET DI MASTER ID UGUALE A QUELLO CHE MI è STATO PASSATO
        system.debug('quoteIds : in Queueable '+ Id_Quote);        
    }
    
    public void execute(QueueableContext context) {

            //Lascio così ma se si aggiungono altre società è un controllo inutile
            String queryQuote = Utilities.selectAllField('SBQQ__Quote__c') + ' WHERE Id IN : quoteIds AND (RecordType.DeveloperName = \'Warrant\')';
            system.debug('query Quote : '+queryQuote);
 
            Map<String,sObject> QuoteMap = Utilities.keyBy(Database.query(queryQuote), 'Id'); 
            system.debug(QuoteMap);          
            if(QuoteMap.isEmpty())return;

            Map <String, Schema.SObjectType> schemaMapQuote = Schema.getGlobalDescribe();
            String objectName='SBQQ__Quote__c';
            Map<String, Schema.SObjectField> fieldMapQuote = schemaMapQuote.get(ObjectName).getDescribe().fields.getMap();

            Map <String, Schema.SObjectType> schemaMapOpportunity = Schema.getGlobalDescribe();
            String objectNameSegn='Opportunity';
            Map<String, Schema.SObjectField> fieldMapOpp = schemaMapOpportunity.get(objectNameSegn).getDescribe().fields.getMap();

            Id rId = [SELECT ID FROM RecordType WHERE SObjectType = 'Opportunity' AND Name = 'WRT CPQ' LIMIT 1].Id;

            list<Opportunity> ListOpp = new list<Opportunity>();


            for (Id q : QuoteMap.keyset()){
                sObject newOpp = Schema.getGlobalDescribe().get('Opportunity').newSObject();
                sObject cloneQuote = QuoteMap.get(q);

                //Lookup su Opp verso Quote

                
                // StageName non sono sincronizzati correttamente


                for(String x : fieldMapOpp.keySet()){
                    Boolean containsA = fieldMapOpp.containsKey(x.replace('__c', '').replace('_', ''));
                    Boolean containsB = fieldMapOpp.containsKey(x);
                    if(containsB && fieldMapOpp.get(x).getDescribe().isAccessible()){
                         //Questa è la condizione da cambiare
                        // Qui ho bisogno che mi prenda solo i campi in comune, mentre ora prende anche i campi di Quote che opp non ha
                        For(String y:fieldMapQuote.keyset()){
                            
                        if(x.contains('__c') && y == x && fieldMapQuote.get(y).getDescribe().isAccessible()){
                             //If(!x.contains('Owner')){
                            newOpp.put(x, cloneQuote.get(x));
                             //}
                            system.debug('Campo Custom ' + x +''+ y);                            
                        }
                        }


                        System.debug('EU containsB: ' + x +'---'+fieldMapOpp.get(x).getDescribe().isAccessible() + '---' + fieldMapOpp.get(x).getDescribe().isUpdateable());
                            
                    }else if (containsA && fieldMapOpp.get(x).getDescribe().isAccessible()){
                            // Campi che hanno stessa api name (WITHOUT __c AND _)
                            System.debug('Ak x: ' + x);

                            newOpp.put(x, cloneQuote.get(x.replace('__c', '').replace('_', '')));
                            System.debug('Ak containsA: ' + x + ' ' + x.replace('__c', '').replace('_', '') + ' ' + cloneQuote.get(x.replace('__c', '').replace('_', '')));
                            
                    }else if(fieldMapOpp.get(x).getDescribe().isAccessible()) {
                            // Campi che non hanno stessa api name
                    }
                    

                           
                }


                newOpp.put('Quote_Creazione__c',QuoteMap.get(q).get('Id'));
                newOpp.put('CloseDate',QuoteMap.get(q).get('CloseDate__c'));
                newOpp.put('StageName',QuoteMap.get(q).get('StageName__c'));
                newOpp.put('Name',QuoteMap.get(q).get('Opportunity_Name__c'));
                newOpp.put('Pricebook2Id', QuoteMap.get(q).get('SBQQ__PriceBook__c'));
                newOpp.put('RecordTypeId',rId);
                newOpp.put('Creato_da_Quote__c', true);
                newOpp.put('AccountId', QuoteMap.get(q).get('SBQQ__Account__c'));
                System.debug('newOpp : '+newOpp);
                ListOpp.add((Opportunity)newOpp);
            }
        
        

            if(ListOpp.size()>0){      
                //insert ListOpp;
                Database.SaveResult[] srList = Database.insert(ListOpp, false);
                Database.SaveResult idOpp = srList[0];
                system.debug('srList' + idOpp.getId());
                system.debug('Errore' + idOpp.getErrors()); 

                //AsyncQuoteUpdate executeQueueable = new AsyncQuoteUpdate(Quote.keyset(),idOpp);  //PASSO IL SET AD ASYNCEXE
                //ID jobID = System.enqueueJob(executeQueueable);
                //System.debug(' Update Quote jobID : ' + jobID);
            
            }




        
          }
    
        
        
}