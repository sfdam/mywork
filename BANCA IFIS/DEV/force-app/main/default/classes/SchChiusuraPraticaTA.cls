global class SchChiusuraPraticaTA implements Schedulable{

    global void execute(SchedulableContext sc){
        BtcChiusuraPraticaTA btc = new BtcChiusuraPraticaTA();
        Database.executeBatch(btc);
    }
}