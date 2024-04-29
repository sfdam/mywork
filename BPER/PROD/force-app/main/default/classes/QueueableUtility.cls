public class QueueableUtility implements System.Queueable
{

    private List<String> userIdList;

    public QueueableUtility(List<String> userIdList) {
        this.userIdList = userIdList;
    }

    public void execute(System.QueueableContext objContext)
    {
        List<CampaignMember> cmList = [SELECT Id, CRM_Assegnatario__c FROM CampaignMember WHERE CRM_Assegnatario__c IN: userIdList];
        for(CampaignMember cm : cmList){
            cm.CRM_Assegnatario__c = null;
        }
        update cmList;
    }

}