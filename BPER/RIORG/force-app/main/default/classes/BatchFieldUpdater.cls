/* BatchRecordUpdate will update any 1 field on any 1 object.
 * 
 * String values must be set to Object, Field and Value to be added to Field.
 * 
 * Query can be modified to limit records updated.
 * Example below excludes records for which Degree Offering already equals the new value.
 * 
 * All 4 strings' values must be set to operate when executed.
 * 
 * Execute in Anonymous Apex.
 * 
 * By Default it will run 200 records at at a time.
 * CODE TO RUN IN ANONYMOUS APEX
	String e = 'Lead'; // Object to be updated
	String f = 'LeadSource'; // field to be updated.
	String v = 'DarkWeb'; // value with which field will be populated.
	String q = 'SELECT ' + f + ' FROM ' + e; // Query to which more filters can be added like: + 'AND IsConverted = false';
	Id batchInstanceId1 = Database.executeBatch(new BatchFieldUpdater(q,e,f,v));
 *
 *  Different Batch Sizes can be set by modifying the final line to add batch size after the list of arguments.
 * Example: Id batchInstanceId1 = Database.executeBatch(new BatchRecordUpdater(q,e,f,v),1);
 */

global class BatchFieldUpdater  implements Database.Batchable<sObject>{
   global final String Query;
   global final String Entity;
   global final String Field;
   global final String Value;

   global BatchFieldUpdater(String q, String e, String f, String v){
             Query=q; Entity=e; Field=f;Value=v;
   }

   global Database.QueryLocator start(Database.BatchableContext BC){
      return Database.getQueryLocator(query);
   }

   global void execute(Database.BatchableContext BC, 
                       List<sObject> scope){
      for(Sobject s : scope){s.put(Field,Value); 
      }      update scope;
   }

   global void finish(Database.BatchableContext BC){

   }

}