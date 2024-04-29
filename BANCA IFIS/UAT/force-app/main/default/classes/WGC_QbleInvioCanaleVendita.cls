public class WGC_QbleInvioCanaleVendita implements Queueable, Database.AllowsCallouts {
	
    List<WGC_WsUtils_Cart.PEF40Input> lineeCanaleVendita = new List<WGC_WsUtils_Cart.PEF40Input>();

    public WGC_QbleInvioCanaleVendita(List<WGC_WsUtils_Cart.PEF40Input> lineeCredito){
        this.lineeCanaleVendita = lineeCredito;     
    }


    public void execute(QueueableContext context){
        if(this.lineeCanaleVendita.isEmpty()) return;

        WGC_WsUtils_Cart.PEF40Input lineaCredito = this.lineeCanaleVendita.remove(0);

        WsRestInput input = new WsRestInput(lineaCredito);
        System.debug('@@@ input ' + input.toJSONString());

        WGC_WsUtils_Cart.PEF40Output output = WGC_WsUtils_Cart.PEF40(lineaCredito);
        System.debug('@@@ output callout PEF40 ' + JSON.serialize(output));

        if(!this.lineeCanaleVendita.isEmpty() && !Test.isRunningTest()){
            System.enqueueJob(new WGC_QbleInvioCanaleVendita(this.lineeCanaleVendita));
        }
    }
}