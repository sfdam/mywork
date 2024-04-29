public class WGC_Header_News_Controller {

    @AuraEnabled
    public static WrapperResponse getNews(){
        WrapperResponse wrap = new WrapperResponse();

        List<WGC_News__c> listaNews = new List<WGC_News__c>();
        listaNews = [SELECT Id, Breve_Descrizione__c, Titolo__c, Data_News__c 
                     FROM WGC_News__c 
                     WHERE Stato__c = 'Attiva' 
                     ORDER BY Data_News__c
                     LIMIT 25];
        System.debug('@@@ lista news ' + listaNews);
        
        if(!listaNews.isEmpty()){
            wrap.data = listaNews;
        }
        else{
            wrap.message = 'Nessuna News da visualizzare';
        }

        return wrap;
    }

    public class WrapperResponse{
        @AuraEnabled
        public List<Object> data;
        @AuraEnabled
        public String message;
        @AuraEnabled
        public Boolean success;

        public WrapperResponse(){
            this.data = new List<Object>();
            this.message = '';
            this.success = true;
        }
    }
}