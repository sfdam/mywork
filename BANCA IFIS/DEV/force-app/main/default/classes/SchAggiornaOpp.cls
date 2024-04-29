/**
 * Progetto:         Banca IFIS
 * Developer:        Dario Mapelli
 * Description:      Classe schedulabile che invoca il batch "Aggiorna Opportunita" per tutte le opportunità
 */
global class SchAggiornaOpp implements Schedulable {

	global void execute(SchedulableContext sc) {

		BtcAggiornaOpp b = new BtcAggiornaOpp(false);
    Database.executebatch(b, 50);
	}
}