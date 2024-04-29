/**
 * @Author        : Alessandro Lumaca @TEN 
 * @CreateDate    : 2022-12-20
 * @Description   : Classe di records Aggregativi da usare nelle classi Batchable dove ci sono query con aggregation--opetrators 
 * @TestClass     : TransferOrdersViaMail_Batch_Test  
 */

global class AggregateResultIterable implements Iterable<sObject> {
    private String query;
    
    /** Constructor */
    global AggregateResultIterable(String query) {
        this.query = query;
    }
    
    /** Metodo di interfaccia 
     *  da utilizzare per la fase di quering nelle Batch--Class */
    global Iterator<sObject> iterator() {
        return new AggregateResultIterator(query);
    }
}