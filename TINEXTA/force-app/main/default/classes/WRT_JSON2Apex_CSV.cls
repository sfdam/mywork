public class WRT_JSON2Apex_CSV {
	public class Owner {
		public String Name;
		public String Id;
	}

	public String ObjectType;
	public String id;
	public String name;
	public String codice_fiscale;
	public String partita_iva;
	public String ownerid;
	public Owner owner;
	public String responsabile;
	public Integer numoppwon;
	public Integer numoppopen;
	public Integer numopplost;
	public Integer numevent;
	public Datetime eventlastdate;

	
	public static List<WRT_JSON2Apex_CSV> parse(String json) {
        system.debug('DENTRO: ' + json);
        json = json.replaceAll('__c', '');
		return (List<WRT_JSON2Apex_CSV>) System.JSON.deserialize(json, List<WRT_JSON2Apex_CSV>.class);
	}
}