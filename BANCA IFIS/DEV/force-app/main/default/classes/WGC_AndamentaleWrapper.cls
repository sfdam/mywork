global class WGC_AndamentaleWrapper implements Comparable {

	public WGC_Andamentale__c andamentale;

	public WGC_AndamentaleWrapper(WGC_Andamentale__c andam) {
		andamentale = andam;
	}

	global Integer compareTo(Object compareTo) {
        WGC_AndamentaleWrapper compareToAndamentale = (WGC_AndamentaleWrapper)compareTo;
        
        Integer returnValue = 0;

        if (andamentale.Operatore__r.Name > compareToAndamentale.andamentale.Operatore__r.Name) {

            returnValue = 1;

        } else if (andamentale.Operatore__r.Name < compareToAndamentale.andamentale.Operatore__r.Name) {
            
            returnValue = -1;
        } 
        return returnValue;       
    }
}