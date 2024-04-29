public class WGC_QuestionarioQualitativo {

    //prendo i dati di account e chiamo i ws per costruire il questionario con le varie domande e possibili risposte
    @AuraEnabled
    public static String getData(String recordId){
        Account a = [SELECT Id, Name, NDGGruppo__c, Fatturato__c  FROM Account WHERE Id=:recordId];
        List<QuestionarioQualitativo__c> qq = new List<QuestionarioQualitativo__c>();
        qq = [SELECT Id, Name, AccountNDG__c, Payload__c, NomeModello__c FROM QuestionarioQualitativo__c WHERE Account__c =: recordId ORDER BY CreatedDate DESC LIMIT 1];
        System.debug('@@@ account ' + a);
        System.debug('@@@ qq ' + qq);
        //oggetto wrapper per recuperare i qq
        CtrlCompilazioneQQ.InputObj input;

        String modelloAcc;
        //se è vuota la lista lo genero da zero
        if(qq.isEmpty()){
            input = new CtrlCompilazioneQQ.InputObj(recordId, '');
        }
        //se non è vuota la lista prendo il qq già registrato
        else{
            modelloAcc = CtrlCompilazioneQQ.getNomeModello(a.Fatturato__c);
            if(modelloAcc == qq.get(0).NomeModello__c){
                input = new CtrlCompilazioneQQ.InputObj(recordId, qq.get(0).Id);
            }
            else{
                //delete qq.get(0);
                input = new CtrlCompilazioneQQ.InputObj(recordId, '');
            }
           
        }
        CtrlCompilazioneQQ.OutputObj output;
        String returnData;
        //Chiamata al servizio che restituisce un oggetto wrapper
        output = CtrlCompilazioneQQ.fetchQQ(input);

        returnData = JSON.serialize(output);
        System.debug('@@@ returnData ' + returnData);
        return returnData;
    }

    //salvataggio 
    @AuraEnabled
    public static void salvaQQ(String domande, String qq){
        System.debug('@@@ domande json ' + domande);
        System.debug('@@@ qq json ' + qq);
        CtrlCompilazioneQQ.Domanda[] dm = (CtrlCompilazioneQQ.Domanda[]) JSON.deserialize(domande, CtrlCompilazioneQQ.Domanda[].Class);
        QuestionarioQualitativo__c qs = (QuestionarioQualitativo__c) JSON.deserialize(qq, QuestionarioQualitativo__c.Class);
        System.debug('@@@ domande ' + dm);
        System.debug('@@@ qq ' + qs);

        Account a = [SELECT Id, Name, NDGGruppo__c FROM Account WHERE Id =: qs.Account__c];

        //costruisco i parametri per la chiamata per l'inserimento del qq
        String nomeM = CtrlCompilazioneQQ.getNomeModello(qs.Account__r.Fatturato__c);
        Integer[] lstSez = CtrlCompilazioneQQ.getListaSezioni(nomeM);

        Map<Integer, CtrlCompilazioneQQ.Domanda[]> parametri = new Map<Integer, CtrlCompilazioneQQ.Domanda[]>();

        Map<Integer, List<Integer>> mappaSezPar = CtrlCompilazioneQQ.getModelloModulo(nomeM);

        List<CtrlCompilazioneQQ.Domanda> lst1 = new List<CtrlCompilazioneQQ.Domanda>();
        List<CtrlCompilazioneQQ.Domanda> lst2 = new List<CtrlCompilazioneQQ.Domanda>();
        List<CtrlCompilazioneQQ.Domanda> lst3 = new List<CtrlCompilazioneQQ.Domanda>();
        List<CtrlCompilazioneQQ.Domanda> lst4 = new List<CtrlCompilazioneQQ.Domanda>();
        List<CtrlCompilazioneQQ.Domanda> lst5 = new List<CtrlCompilazioneQQ.Domanda>();
        List<CtrlCompilazioneQQ.Domanda> lst6 = new List<CtrlCompilazioneQQ.Domanda>();

        List<List<CtrlCompilazioneQQ.Domanda>> lstTotal = new List<List<CtrlCompilazioneQQ.Domanda>>();
        
        for(CtrlCompilazioneQQ.Domanda item : dm){
            if(item.codiceModulo == Integer.valueOf('2801') || item.codiceModulo == Integer.valueOf('2901')){
                lst1.add(item);
            }
            else if(item.codiceModulo == Integer.valueOf('2802') || item.codiceModulo == Integer.valueOf('2902')){
                lst2.add(item);  
            }
            else if(item.codiceModulo == Integer.valueOf('2803') || item.codiceModulo == Integer.valueOf('2903')){
                lst3.add(item);
            }
            else if(item.codiceModulo == Integer.valueOf('2804') || item.codiceModulo == Integer.valueOf('2904')){
                lst4.add(item);
            }
            else if(item.codiceModulo == Integer.valueOf('2805') || item.codiceModulo == Integer.valueOf('2905')){
                lst5.add(item);
            }
            else if(item.codiceModulo == Integer.valueOf('2806') || item.codiceModulo == Integer.valueOf('2906')){
                lst6.add(item);
            }
        }

        lstTotal.add(lst1);
        lstTotal.add(lst2);
        lstTotal.add(lst3);
        lstTotal.add(lst4);
        lstTotal.add(lst5);
        lstTotal.add(lst6);

        for(Integer i = 0; i < lstSez.size(); i++){
            parametri.put(lstSez[i], lstTotal.get(i));
        }

        CtrlCompilazioneQQ.aggiornaQQServizi(a.NDGGruppo__c, qs.NomeModello__c, parametri);

        if(qs.Stato__c == 'CONFERMATO'){
            qs.DataCompilazione__c = System.Today();
        }

        CtrlCompilazioneQQ.Domanda[] payload = new List<CtrlCompilazioneQQ.Domanda>();
        for(CtrlCompilazioneQQ.Domanda[] sez : parametri.values()) {
            payload.addAll(sez);
        }

        qs.Payload__c = JSON.serialize(payload);

        System.debug('@@@ mappa parametri ' + parametri);
        System.debug('@@@ questionario ' + qs);
        Id returnedId = CtrlCompilazioneQQ.salvaQQ(parametri, qs);
        update qs;
    }

}