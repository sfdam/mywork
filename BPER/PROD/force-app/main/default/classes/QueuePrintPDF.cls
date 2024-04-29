public without sharing class QueuePrintPDF implements Queueable {

    public String currentAccountQuery {get;set;}
    public Account currentAccount {get;set;}
    public List<Map<String,Object>> promiseArray {get;set;}
    public Map<String,String> mappaSezioni {get;set;}
    public String rootXml {get;set;}
    public String recordTypeDeveloperName {get;set;}
    public String tipoStampa {get;set;}
    public Boolean print{get;set;}

    /*public QueuePrintPDF(String currentAccountQuery, List<Map<String,Object>> promiseArray, Map<String,String> mappaSezioni, String rootXml, String recordTypeDeveloperName, String tipoStampa ) {
        this.currentAccountQuery = currentAccountQuery;
        this.promiseArray = promiseArray;
        this.mappaSezioni = mappaSezioni;
        this.rootXml = rootXml;
        this.recordTypeDeveloperName = recordTypeDeveloperName;
        this.tipoStampa = tipoStampa;
        this.print = true;
    }*/

    public QueuePrintPDF(Account currentAccount, List<Map<String,Object>> promiseArray, Map<String,String> mappaSezioni, String rootXml, String recordTypeDeveloperName, String tipoStampa ) {
        this.currentAccount = currentAccount;
        this.promiseArray = promiseArray;
        this.mappaSezioni = mappaSezioni;
        this.rootXml = rootXml;
        this.recordTypeDeveloperName = recordTypeDeveloperName;
        this.tipoStampa = tipoStampa;
        this.print = true;
    }

    public void execute(QueueableContext context) {
        // Account currentAccount = Database.query(currentAccountQuery);
        try {
            System.debug('DK HeapSize_START: ' + Limits.getHeapSize());
            // System.debug('DK this.promiseArray: ' + JSOn.serialize(this.promiseArray));
            List<Map<String,Object>> promiseArrayAsynch = new List<Map<String,Object>>();
            // for(Integer i=(this.promiseArray.size()-1); i>=0; i--){
                for (Integer i = 0 ; i < this.promiseArray.size() ; i++){
                if(this.promiseArray[i] != null && !this.promiseArray[i].isEmpty()){
                    
                    System.debug('DK HeapSize_CURRENTITERATION_' + i + ': ' + Limits.getHeapSize());
                    // PDFConfigurator__mdt meta = (PDFConfigurator__mdt)JSON.deserialize(JSON.serialize(this.promiseArray[i].get('meta')), PDFConfigurator__mdt.class);
                    if((String)this.promiseArray[i].get('method') == 'getXMLFromQuery4PromiseData'){
                        promiseArrayAsynch.add(PrintPDFController.getXMLFromQuery4PromiseData((String)this.promiseArray[i].get('meta'), this.currentAccount));
                    }else if((String)this.promiseArray[i].get('method') == 'getXMLFromMethods4PromiseData'){
                        promiseArrayAsynch.add(PrintPDFController.getXMLFromMethods4PromiseData((String)this.promiseArray[i].get('meta'), this.currentAccount));
                    }else if((String)this.promiseArray[i].get('method') == 'replaceFieldsWithData4Promise'){
                        promiseArrayAsynch.add(this.promiseArray[i]);
                    }
                }
                // this.promiseArray.remove(i);
            }

            for (Integer i = (promiseArray.size()-1) ; i>= 0 ; i--){

                this.promiseArray.remove(i);
            }
    
            /*String dataMapJSON = JSON.serialize(new Map<String, Object>{
                'currentAccount' => this.currentAccount,
                'promiseArray' => promiseArrayAsynch,
                'mappaSezioni' => this.mappaSezioni,
                'rootXml' => this.rootXml,
                'recordTypeDeveloperName' => this.recordTypeDeveloperName,
                'tipoStampa' => this.tipoStampa,
                'print' => this.print
            });*/
            System.debug('DK HeapSize_FINAL: ' + Limits.getHeapSize());
            PrintPDFController.generatePDFAsynch(JSON.serialize(new Map<String, Object>{
                'currentAccount' => this.currentAccount,
                'promiseArray' => promiseArrayAsynch,
                'mappaSezioni' => this.mappaSezioni,
                'rootXml' => this.rootXml,
                'recordTypeDeveloperName' => this.recordTypeDeveloperName,
                'tipoStampa' => this.tipoStampa,
                'print' => this.print
            }));
        } catch (Exception ex) {
            System.debug('Error: ' +  ex.getMessage() + '; at: ' + ex.getStackTraceString());
            if(!print){
                update new Account(id = currentAccount.Id, CRM_PEF_PDFBase64Split1__c = 'KO');
            }
        }
    }
}