public class FollowUpGruppiByPB {
    @InvocableMethod(label='Abilita/Disabilita gruppi' description='')
    public static void setFlag(List<String> value) {
        FollowUp.invokeFutureGruppi = Boolean.valueOf(value.get(0));
    }
}