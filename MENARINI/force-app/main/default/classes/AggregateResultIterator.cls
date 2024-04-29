/**
 * @Author        : Alessandro Lumaca @TEN 
 * @CreateDate    : 2022-12-20
 * @Description   : Classe helper usata da AggregateResultIterable
 * @TestClass     : TransferOrdersViaMail_Batch_Test  
*/ 

global class AggregateResultIterator implements Iterator<sObject> {
    AggregateResult [] results { get;set; }
    Integer index              { get;set; } 
    
    /** Constructor */
    global AggregateResultIterator(String query) {
        index = 0;
        results = Database.query(query);  
    } 
    
    global boolean hasNext(){ 
        return results != null && !results.isEmpty() && index < results.size(); 
    }    
    
    global AggregateResult next(){        
        return results[index++];            
    }
    
    global Integer total() {
        return (results !=null ? results.size() : 0); 
    }
}