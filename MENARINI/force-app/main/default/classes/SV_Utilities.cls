/*
 *@TestClass  :   SV_Utilities_Test
 */
public inherited sharing class SV_Utilities {

        public static Object getSObjectValue(SObject obj, String field) {
          if(String.isBlank(field) || obj == null) return null;
          else return getSObjectValueWithoutChecks(obj, field, !field.contains('.'));
        }
      
        private static Map<String, String[]> tokensMap = new Map<String, String[]>();
        private static Object getSObjectValueWithoutChecks(SObject obj, String field, Boolean isPlainField) {
          try {
            if(isPlainField) return obj.get(field);
      
            SObject subObj = obj;
            if(!tokensMap.containsKey(field)) tokensMap.put(field, field.split('\\.'));
            String[] tokens = tokensMap.get(field);
            for(Integer i = 0; i < tokens.size() - 1; i++) {
              subObj = subObj.getSObject(tokens[i]);
            }
            return subObj.get(tokens[tokens.size() - 1]);
          } catch(Exception e) {
            return null;
          }
        }
      
        /**
         *  Estrae un set di id da una lista di oggetti
         *  @objList la lista di oggetti
         *  @idField il nome del campo che si vuole estrarre
         */
        public static Set<Id> getIdSet(SObject[] objList, String idField) {
          Set<Id> res = new Set<Id>();
          if(String.isBlank(idField) || objList == null || objList.isEmpty()) return res;
          else {
            Boolean isPlainField = !idField.contains('.');
            for(SObject obj : objList) {
              Object val = getSObjectValueWithoutChecks(obj, idField, isPlainField);
              if(val != null) res.add((Id) val);
            }
            return res;
          }
        }
      
        /**
         *  Estrae un set di stringhe da una lista di oggetti
         *  @objList la lista di oggetti
         *  @field il nome del campo che si vuole estrarre
         */
        public static Set<String> getSet(SObject[] objList, String field) {
          Set<String> res = new Set<String>();
          if(String.isBlank(field) || objList == null || objList.isEmpty()) return res;
          else {
            Boolean isPlainField = !field.contains('.');
            for(SObject obj : objList) {
              Object val = getSObjectValueWithoutChecks(obj, field, isPlainField);
              if(val != null) res.add(String.valueOf(val));
            }
            return res;
          }
        }
      
        /**
         *  Estrae un set di stringhe (ogni stringa è composta da uno o più campi degli oggetti contenuti in objList)
         *  da una lista di oggetti.
         *  @objList La lista di oggetti da cui si vuole creare il set
         *  @keyPattern una stringa contenente uno o più "tag" {nomeCampo} concatenati a piacimento, che rappresenta il formato
         *   che avranno le chiavi della mappa (es: "{name}" , oppure "{firstName}_{lastName}")
         */
        public static Set<String> getSet(SObject[] objList, String keyPattern, Boolean useRegex, Boolean allowNulls) {
          Set<String> res = new Set<String>();
          if(objList == null) return res;
      
          Map<String, String> pattern2FieldMap = new Map<String, String>();
      
          if(useRegex) {
            Pattern pat = Pattern.compile('\\{[^\\}]+\\}');
            Matcher m = pat.matcher(keyPattern);
            while(m.find()) {
              String f = m.group().substringAfter('{').substringBeforeLast('}');
              pattern2FieldMap.put(m.group(), f);
            }
          }
      
          Boolean isPlainField = !keyPattern.contains('.');
      
          for(SObject obj : objList) {
            if(useRegex) {
              String compiledPattern = keyPattern;
              for(String p : pattern2FieldMap.keySet()) {
                Object value = getSObjectValueWithoutChecks(obj, pattern2FieldMap.get(p), !p.contains('.'));
                if(value != null) {
                  compiledPattern = compiledPattern.replace(p, String.valueOf(value));
                } else if(allowNulls) compiledPattern = compiledPattern.replace(p, '');
              }
              res.add(compiledPattern);
            } else {
              Object v = getSObjectValueWithoutChecks(obj, keyPattern, isPlainField);
              if(v != null) res.add(String.valueOf(v));
            }
          }
      
          return res;
        }
      
        /**
         *  Estrae una mappa di SObject la cui chiave è composta da uno o più campi degli oggetti contenuti in objList, e il
         *  valore è l'oggetto. Ne consegue che la chiave della mappa dovrebbe essere univoca, altrimenti come valore sopravvive
         *  solo l'ultimo della lista ad avere tale chiave.
         *  @objList La lista di oggetti da cui si vuole creare la mappa
         *  @keyPattern una stringa contenente uno o più "tag" {nomeCampo} concatenati a piacimento, che rappresenta il formato
         *   che avranno le chiavi della mappa (es: "{name}" , oppure "{firstName}_{lastName}")
         */
        public static Map<String, SObject> keyBy(SObject[] objList, String field) {
          return keyBy(objList, field, false);
        }
      
        public static Map<String, SObject> keyBy(SObject[] objList, String keyPattern, Boolean useRegex) {
          return keyBy(objList, keyPattern, useRegex, false);
        }
      
        public static Map<String, SObject> keyBy(SObject[] objList, String keyPattern, Boolean useRegex, Boolean allowNulls) {
          Map<String, SObject> res = new Map<String, SObject>();
          if(objList == null) return res;
      
          Map<String, String> pattern2FieldMap = new Map<String, String>();
      
          if(useRegex) {
            Pattern pat = Pattern.compile('\\{[^\\}]+\\}');
            Matcher m = pat.matcher(keyPattern);
            while(m.find()) {
              String f = m.group().substringAfter('{').substringBeforeLast('}');
              pattern2FieldMap.put(m.group(), f);
            }
          }
      
          Boolean isPlainField = !keyPattern.contains('.');
      
          for(SObject obj : objList) {
            if(useRegex) {
              String compiledPattern = keyPattern;
              for(String p : pattern2FieldMap.keySet()) {
                Object value = getSObjectValueWithoutChecks(obj, pattern2FieldMap.get(p), !p.contains('.'));
                if(value != null) {
                  compiledPattern = compiledPattern.replace(p, String.valueOf(value));
                } else if(allowNulls) compiledPattern = compiledPattern.replace(p, '');
              }
              res.put(compiledPattern, obj);
            } else {
              Object v = getSObjectValueWithoutChecks(obj, keyPattern, isPlainField);
              if(v != null) res.put(String.valueOf(v), obj);
            }
          }
      
          return res;
        }
      
        /**
         *  Estrae una mappa di SObject la cui chiave è composta dal valore di un campo degli oggetti contenuti in objList,
         *  e il valore è la lista di oggetti aventi tale chiave.
         *  @objList La lista di oggetti da cui si vuole creare la mappa
         *  @field il nome del campo che si vuole estrarre
         */
        public static Map<String, SObject[]> groupBy(SObject[] objList, String field) {
          return groupBy(objList, field, false);
        }
      
        /**
         *  Estrae una mappa di SObject la cui chiave è composta dal valore di un campo (o da una concatenazione del valore
         *  di un numero arbitrario di campi) degli oggetti contenuti in objList, e il valore è la lista di oggetti aventi tale chiave.
         *  @objList La lista di oggetti da cui si vuole creare la mappa
         *  @keyPattern il nome del campo che si vuole estrarre
         *  @useRegex se true keyPattern rappresenta una stringa nella forma {nomeApiCampo}.*{nomeApiCampo2}.*{nomeApiCampoN}
         */
        public static Map<String, SObject[]> groupBy(SObject[] objList, String keyPattern, Boolean useRegex) {
          if(useRegex) return groupByRegex(objList, keyPattern);
      
          Map<String, SObject[]> res = new Map<String, SObject[]>();
          if(objList == null) return res;
      
          Boolean isPlainField = !keyPattern.contains('.');
          for(SObject obj : objList) {
            String v = String.valueOf(getSObjectValueWithoutChecks(obj, keyPattern, isPlainField));
            addToGMap(res, v != null ? v : 'null', obj);
          }
      
          return res;
        }
      
        /**
         *  Estrae una mappa di SObject la cui chiave è composta da una concatenazione del valore di un numero arbitrario di
         *  campi degli oggetti contenuti in objList, e il valore è la lista di oggetti aventi tale chiave.
         *  @objList La lista di oggetti da cui si vuole creare la mappa
         *  @keyPattern una stringa nella forma {nomeApiCampo}.*{nomeApiCampo2}.*{nomeApiCampoN}
         */
        public static Map<String, SObject[]> groupByRegex(SObject[] objList, String keyPattern) {
          Map<String, SObject[]> res = new Map<String, SObject[]>();
          if(objList == null) return res;
      
          Map<String, String> pattern2FieldMap = new Map<String, String>();
      
          Pattern pat = Pattern.compile('\\{[^\\}]+\\}');
          Matcher m = pat.matcher(keyPattern);
          while(m.find()) {
            String f = m.group().substringAfter('{').substringBeforeLast('}');
            pattern2FieldMap.put(m.group(), f);
          }
      
          for(SObject obj : objList) {
            String compiledPattern = keyPattern;
            for(String p : pattern2FieldMap.keySet()) {
              String value = String.valueOf(getSObjectValueWithoutChecks(obj, pattern2FieldMap.get(p), !p.contains('.')));
              compiledPattern = compiledPattern.replace(p, value == null ? 'null' : value);
            }
            addToGMap(res, compiledPattern, obj);
          }
      
          return res;
        }
      
        public static void addToGMap(Map<String, SObject[]> m, String key, SObject value) {
          if(!m.containsKey(key)) m.put(key, new SObject[]{});
          m.get(key).add(value);
        }
      
        public static Object[] reverse(Object[] objList) {
          Object[] res = objList.clone();
          for(Integer i = 0; i < objList.size(); i++) {
            res[objList.size() - 1 - i] = objList[i];
          }
          return res;
        }
      
        /**
         *  Filtra la lista di oggetti in input sulla base del valore di un campo
         *  @coll La lista di oggetti
         *  @field Il nome api del campo
         *  @value il valore del campo
         */
        public static SObject[] filter(SObject[] coll, String field, Object value) {
          return filter(coll, field, value, true);
        }
      
        /**
         *  Filtra la lista di oggetti in input sulla base del valore di un campo
         *  @coll La lista di oggetti
         *  @field Il nome api del campo
         *  @value il valore del campo
         *  @includeOrExclude Se true, l'oggetto è presente nella lista filtrata solo se il valore del campo è uguale a value, se false invece l'oggetto è
         *                    presente solo se il valore del campo NON è uguale a value
         */
        public static SObject[] filter(SObject[] coll, String field, Object value, Boolean includeOrExclude) {
          if(value != null && (value instanceof Set<String> || value instanceof Set<Id>)) {
            return filter(coll, field, (Set<String>) value, includeOrExclude);
          }
          SObject[] res = new SObject[]{};
          if(coll == null) return res;
          for(SObject x : coll) {
            Object val = getSObjectValue(x, field);
            if((value == val && includeOrExclude) || (!includeOrExclude && value != val)) res.add(x);
          }
          return res;
        }
      
        /**
         *  Filtra la lista di oggetti in input sulla base di uno o più valori di un campo
         *  @coll La lista di oggetti
         *  @field Il nome api del campo
         *  @value L'insieme dei valori da controllare. I valori sono messi in OR
         */
        public static SObject[] filter(SObject[] coll, String field, Set<String> value) {
          return filter(coll, field, value, true);
        }
      
        /**
         *  Filtra la lista di oggetti in input sulla base di uno o più valori di un campo
         *  @coll La lista di oggetti
         *  @field Il nome api del campo
         *  @value L'insieme dei valori da controllare. I valori sono messi in OR
         *  @includeOrExclude Se true, l'oggetto è presente nella lista filtrata solo se il valore del campo è uguale a value, se false invece l'oggetto è
         *                    presente solo se il valore del campo NON è uguale a value
         */
        public static SObject[] filter(SObject[] coll, String field, Set<String> value, Boolean includeOrExclude) {
          SObject[] res = new SObject[]{};
          if(coll == null) return res;
          for(SObject x : coll) {
            Object val = getSObjectValue(x, field);
            if((includeOrExclude && value.contains((String) val)) || (!includeOrExclude && !value.contains((String) val))) res.add(x);
          }
          return res;
        }
      
        /**
         *  Restituisce una mappa DeveloperName => RecordType di tutti i recordtypes di un oggetto
         *  @obj Il nome dell'oggetto di cui si vogliono recuperare i recordType
         */
        private static Map<String, Map<String, SObject>> rtCache = new Map<String, Map<String, SObject>>();
        public static Map<String, SObject> getRecordTypes(String sobj) {
          if(!rtCache.containsKey(sobj)) rtCache.put(sobj, keyBy([SELECT
            Id,
            SObjectType,
            toLabel(Name),
            DeveloperName,
            IsActive,
            Description
            FROM RecordType
            WHERE SObjectType = :sobj
          ], 'DeveloperName'));
          return rtCache.get(sobj);
        }
      
        /**
         *  Restituisce un set dato una lista in input
         *  @l Il nome della lista che si vuole convertire
         */
        public static Set<String> toSet(String[] l) {
          Set<String> res = new Set<String>();
          if(l != null) res.addAll(l);
          return res;
        }
      
        /**
         *  Restituisce una lista dato un set in input
         *  @s Il nome del set che si vuole convertire
         */
        public static List<String> toList(Set<String> s) {
          String[] res = new String[]{};
          if(s != null) res.addAll(s);
          return res;
        }
      
        /**
         *  Restituisce una lista dato un set in input
         *  @s Il nome del set che si vuole convertire
         */
        public static List<Id> toIdList(Set<Id> s) {
          Id[] res = new Id[]{};
          if(s != null) res.addAll(s);
          return res;
        }
      
        /**
         *  Valorizza il campo field col valore value per tutta la lista di objs.
         *  Ritorna la lista modificata
         */
        public static SObject[] massSet(SObject[] objs, String field, Object value) {
          for(SObject o : objs) {
            o.put(field, value);
          }
          return objs;
        }
      
        /**
        *  Restituisce una mappa valore => label relativa ad una picklist
        *  @field Il campo picklist di cui si vuole ottenere la mappa
        */
        public static Map<String, String> getPicklistMap(Schema.SObjectField field) {
          return getPicklistMap(field.getDescribe());
        }
      
        public static Map<String,String> getPicklistMap(Schema.DescribeFieldResult dfr) {
          Map<String, String> res = new Map<String,String>();
          Schema.PicklistEntry[] pickValues = dfr.getPickListValues();
          for(Schema.PicklistEntry ple : pickValues) {
            res.put(ple.getValue(), ple.getLabel());
          }
          return res;
        }
      
        /**
         * Restituisce l'indirizzo IP dell'utente connesso
         */
        public static String getUserIPAddress() {
          String ipAddress = '';
          Map<String, String> myMap = Auth.SessionManagement.getCurrentSession();
          ipAddress = myMap.get('SourceIp');
      
          return ipAddress;
        }
      
        public static void setIfEmpty(SObject o, String field, Object value) {
          Object v = o.get(field);
          if(v == null || (v instanceof String && v == '')) o.put(field, value);
        }
      
        public static Boolean isAsync() {
          return System.isBatch() || System.isFuture() || System.isQueueable();
        }
      
        /**
         * Restituisce la somma dei valori del campo field per la lista objList in ingresso
         *  @objList La lista di oggetti di cui si vuole la somma totale dei valori contenuti nel campo field
         *  @field il nome del campo di cui si vuole il totale
         */
        public static Decimal sumBy(SObject[] objList, String field) {
          Decimal tmp = 0;
          for (SObject o : objList) {
            tmp += o.get(field) != null ? (Decimal)o.get(field) : 0;
          }
          return tmp;
        }
      
      
        /**
         * Returns a random string of specified length
         * @param  length
         * @return random string
         */
        public static String generateRandomString(Integer length) {
          final String chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789abcdefghijklmnopqrstuvwxyz';
          String randomString = '';
          while (randomString.length() < length) {
            Integer index = Math.mod(Math.abs(Crypto.getRandomInteger()), chars.length());
            randomString += chars.substring(index, index+1);
          }
          return randomString;
        }
      
          // public static void testLead(String payload) {
          // 	  System.debug('field key is ' + payload);
      
      
        //   // Create an approval request for the Opportunity
        //       Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
        //       req1.setComments('Submitting request for approval automatically using Trigger');
        //       req1.setObjectId('00Q1j000002OGpXEAW');
        //       req1.setNextApproverIds(new Id[] {'04a1j0000008anKAAQ'});
      
        //       // Submit the approval request for the Opportunity
        //       Approval.ProcessResult result = Approval.process(req1);
      
        //       		  System.debug('field key is ' + result);
      
      
          // }
          
          /**
           * Return a query string for the input object
           * with all fields and without where conditions
           **/
          public static String selectAllField ( String ObjectName){
              string res = 'SELECT ';
              
              Map <String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
              Map<String, Schema.SObjectField> fieldMap = schemaMap.get(ObjectName).getDescribe().fields.getMap();
              
              for( String s: fieldMap.KeySet()){
                  res += s + ', ';
              }
              
              return res.removeEnd(', ') + ' FROM ' + ObjectName;        
          }
      
          public static boolean isObjectExist(String ObjectNameParam){
           for (Schema.SObjectType sObjectType : Schema.getGlobalDescribe().values() ) {
              String sobjName = String.valueOf(sObjectType);
              if (sobjName.contains(ObjectNameParam) ) {
                  return true;
              }
           }
           return false;
         }

    	/*
    	 * @Descriiption 	: 	Deto un numero decimale restituisce il numero formattato con il separatore ',' per la parte decimale.
       *                    Nel case c'è solo un decimame o non ne' solo il risultato avra' 2 decimali.
		*/
 /*       public static String formatCommaSepNumWith2Decimal(Decimal num) {
          String res = '';
          if(num == null) {
              res ='0,00';
          } else {
              String num_str = '' + num.format();
              if(num_str.countMatches(',') == 1) { // Number with Comma
                  String tmp = num_str.replace(',', '.');
                  String rev = tmp.reverse();
                  Integer indexDot = rev.indexOf('.');
                  String decimalPart = rev.substring(0, indexDot);
                  String integerPart = rev.substring(indexDot + 1, rev.length());
                  res = integerPart.reverse() + ',' 
                      + ( decimalPart.length() == 1 ? decimalPart.reverse() + '0' : decimalPart.reverse() );
              } else {
                  res = num_str + ',00';
              }
          }
          return res;
      }
    */
    
    /* 
	* @Description - metodo che trasforma un numero decimale in un numero con virgola come separatore dei decimali e il punto per migliaia
	* esempio: 2987.5 con 2 decimali --> 2.987,50
	* @param num il numero da formattare
	* @param numDec il numero di cifre dopo la virgola
	* @return String il numero formattato
	*/
    public static String formatCommaSep(Decimal num, Integer numDec){
        
        if(num == null){num=0;}
        String st='';
        String finalDecimal = '';
        Decimal numStrip = num.setScale(numDec);    
        Decimal numInteger = math.ceil(numStrip); 
        Integer numDecInp = numStrip.scale();
        
        if((numStrip!=numInteger)||((numStrip==numInteger)&&(numDecInp>0))) {
        	numStrip = numStrip.stripTrailingZeros();
			numDecInp = numStrip.scale();
        }
        
        if((numStrip == 0)||(numStrip==numInteger)) numDecInp=0;
        
    	if((numDecInp==0)&&(numDec>0)){
    		finalDecimal += ',';
    	}	        
    	
        for(Integer i=numDecInp; i<numDec; i++){
        	finalDecimal += '0';
        }
	
        st = numStrip.setScale(numDec).format()+finalDecimal;

        return st;
    }

    // MS aggiunto un metodo per trovare un singolo record type per developer name
    public static Id givesRecTypeByDevName(sObject sO, String devName){
    
      Schema.sObjectType entityType = sO.getSObjectType();
      Schema.DescribeSObjectResult d = entityType.getDescribe(); 
      Map<String,Schema.RecordTypeInfo> rtMapByName = d.getRecordTypeInfosByDeveloperName();
      Schema.RecordTypeInfo rtByName =  rtMapByName.get(devName);
      return rtByName.getRecordTypeId(); 
  
  }
}