public class WGC_MultiSelectController {
    
    @AuraEnabled public String  label  {get; set;}
    @AuraEnabled public String  value  {get; set;}
    @AuraEnabled public Boolean  selected  {get; set;}
    
    public WGC_MultiSelectController( String value, String label, Boolean selected) {
        this(label,value);
        this.selected = selected;
    }
    
    public WGC_MultiSelectController( String value, String label) {
        this.label = label;
        this.value = value;
        this.selected = false;
    }
    
}