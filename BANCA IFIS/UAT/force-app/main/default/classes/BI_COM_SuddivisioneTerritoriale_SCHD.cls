global class BI_COM_SuddivisioneTerritoriale_SCHD implements Schedulable {

	global void execute(SchedulableContext sc) {

		BI_COM_SuddivisioneTerritoriale_BTCH b = new BI_COM_SuddivisioneTerritoriale_BTCH();
		Database.executebatch(b, 200);
	}
}