public class AsyncLeadCopy implements Queueable{
    private Set<Id> leadIds;
    
    public AsyncLeadCopy(Set<Id> Id_Leads) {
        this.leadIds = Id_Leads; //PONGO IL SET DI MASTER ID UGUALE A QUELLO CHE MI è STATO PASSATO
        system.debug('leadIds : in Queueable '+ leadIds);        
    }
    
    public void execute(QueueableContext context) {

            //Lascio così ma se si aggiungono altre società è un controllo inutile
            String queryLead = Utilities.selectAllField('Lead') + ' WHERE Id IN : leadIds AND (RecordType.DeveloperName = \'Warrant\' OR RecordType.DeveloperName = \'CoMark\')';
            system.debug('queryleadWRT : '+querylead);
 
            Map<String,sObject> leadMap = Utilities.keyBy(Database.query(queryLead), 'Id');           
            if(leadMap.isEmpty())return;

            Map <String, Schema.SObjectType> schemaMapLead = Schema.getGlobalDescribe();
            String objectName='Lead';
            Map<String, Schema.SObjectField> fieldMapLead = schemaMapLead.get(ObjectName).getDescribe().fields.getMap();

            Map <String, Schema.SObjectType> schemaMapSegnalazioni = Schema.getGlobalDescribe();
            String objectNameSegn='Segnalazioni__c';
            Map<String, Schema.SObjectField> fieldMapSegnalazioni = schemaMapSegnalazioni.get(objectNameSegn).getDescribe().fields.getMap();

            list<Segnalazioni__c> ListSegn          = new list<Segnalazioni__c>();

        //RecordType?
            for (String leadId : leadMap.keyset()){
                sObject newSegn = Schema.getGlobalDescribe().get('Segnalazioni__c').newSObject();
                sObject clonedLead = leadMap.get(leadId);
                newSegn.put('Lead_Di_Riferimento__c',leadId);
                for(String x : fieldMapSegnalazioni.keySet()){
                    Boolean containsA = fieldMapLead.containsKey(x.replace('__c', '').replace('_', ''));
                    Boolean containsB = fieldMapLead.containsKey(x);
                    if(containsB && fieldMapSegnalazioni.get(x).getDescribe().isAccessible()){
                        if(x == 'Name')newSegn.put(x, clonedLead.get(x));
                        if(x.contains('__c')){
                            newSegn.put(x, clonedLead.get(x));                            
                        }

                        System.debug('SV containsB: ' + x +'---'+fieldMapSegnalazioni.get(x).getDescribe().isAccessible() + '---' + fieldMapSegnalazioni.get(x).getDescribe().isUpdateable());
                            
                    }else if (containsA && fieldMapSegnalazioni.get(x).getDescribe().isAccessible()){
                            // Campi che hanno stessa api name (WITHOUT __c AND _)
                            System.debug('Ak x: ' + x);

                            newSegn.put(x, clonedLead.get(x.replace('__c', '').replace('_', '')));
                            System.debug('Ak containsA: ' + x + ' ' + x.replace('__c', '').replace('_', '') + ' ' + clonedLead.get(x.replace('__c', '').replace('_', '')));
                            
                    }else if(fieldMapSegnalazioni.get(x).getDescribe().isAccessible()) {
                            // Campi che non hanno stessa api name
                    }
                    

                           
                }
            
                System.debug('newSegn : '+newSegn);
                ListSegn.add((Segnalazioni__c)newSegn);
            }

            if(ListSegn.size()>0){      
                insert ListSegn;
            }
        
          }
    
        
        
}