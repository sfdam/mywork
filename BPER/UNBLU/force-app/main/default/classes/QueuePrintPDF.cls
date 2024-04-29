public without sharing class QueuePrintPDF implements Queueable {

    public Account currentAccount {get;set;}
    public List<Map<String,Object>> promiseArray {get;set;}
    public Map<String,String> mappaSezioni {get;set;}
    public String rootXml {get;set;}
    public String recordTypeDeveloperName {get;set;}
    public String tipoStampa {get;set;}
    public Boolean print{get;set;}
    
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
        
        List<Map<String,Object>> promiseArrayAsynch = new List<Map<String,Object>>();
        List<Map<String,String>> result = new List<Map<String,String>>();
        for(Map<String,Object> execution : promiseArray){
            if(execution != null && !execution.isEmpty()){

                PDFConfigurator__mdt meta = (PDFConfigurator__mdt)JSON.deserialize(JSON.serialize(execution.get('meta')), PDFConfigurator__mdt.class);
                if((String)execution.get('method') == 'getXMLFromQuery4PromiseData'){
                    promiseArrayAsynch.add(PrintPDFController.getXMLFromQuery4PromiseData(meta, currentAccount));
                }else if((String)execution.get('method') == 'getXMLFromMethods4PromiseData'){
                    promiseArrayAsynch.add(PrintPDFController.getXMLFromMethods4PromiseData(meta, currentAccount));
                }else if((String)execution.get('method') == 'replaceFieldsWithData4Promise'){
                    promiseArrayAsynch.add(execution);
                }
            }
        }

        String dataMapJSON = JSON.serialize(new Map<String, Object>{
            'currentAccount' => currentAccount,
            'promiseArray' => promiseArrayAsynch,
            'mappaSezioni' => mappaSezioni,
            'rootXml' => rootXml,
            'recordTypeDeveloperName' => recordTypeDeveloperName,
            'tipoStampa' => tipoStampa,
            'print' => print
        });
        PrintPDFController.generatePDFAsynch(dataMapJSON);
    }
}