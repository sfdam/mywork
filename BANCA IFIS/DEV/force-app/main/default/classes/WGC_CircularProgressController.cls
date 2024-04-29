public class WGC_CircularProgressController {    
    @AuraEnabled
    public static Integer computePercentage(String sObjectName, String recordId, String totalValueFieldName, String actualValueFieldName){
        Integer retVal = 0 ;
        String query = null;
        
        if(totalValueFieldName != null && totalValueFieldName.trim() != '' &&  actualValueFieldName != null && actualValueFieldName.trim() != '' ){
            query = 'SELECT '+totalValueFieldName+', '+actualValueFieldName+' FROM '+sObjectName+' WHERE Id =: recordId';
        }
        else if (actualValueFieldName != null && actualValueFieldName.trim() != '' ) {
            query = 'SELECT '+actualValueFieldName+' FROM '+sObjectName+' WHERE Id =: recordId';
        }
        
        if(query != null){
            try{
                List<SOBject> lstObj = Database.query(query);
                if(lstObj.size() > 0){
                    Decimal totalVal = 0;
                    Decimal actualVal = 0; 
                    
                    if(totalValueFieldName != null && totalValueFieldName.trim() != ''){ 
                        totalVal = Decimal.valueOf(String.valueOf(lstObj[0].get(totalValueFieldName)));
                    } 
                    actualVal = Decimal.valueOf(String.valueOf(lstObj[0].get(actualValueFieldName)));                     
                    //Means only 1 API Name was supplied and field type is percentage
                    if(totalVal == 0){
                        retVal = Integer.valueOf(actualVal );
                    }else if (actualVal > 0){
                        retVal = Integer.valueOf( ( actualVal / totalVal ) * 100 );  
                    } 
                }
            }catch(Exception e){}
            
        }         
        return retVal;        
    }
}