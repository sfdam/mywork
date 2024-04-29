public class WRT_JSON2Apex_Lead {

	public String iva;
	public String cf;
	public String nome;
	public String cognome;
	public String company;

	
	public static List<WRT_JSON2Apex_Lead> parse(String json) {
        system.debug('DENTRO: ' + json);
        json = json.replaceAll('__c', '');
		return (List<WRT_JSON2Apex_Lead>) System.JSON.deserialize(json, List<WRT_JSON2Apex_Lead>.class);
	}
}