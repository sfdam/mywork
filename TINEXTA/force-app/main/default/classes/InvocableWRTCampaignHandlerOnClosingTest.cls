@isTest
public class InvocableWRTCampaignHandlerOnClosingTest 
{
	@isTest
    public static void testMet()
    {
        string dateToday = String.valueOf(system.now());
        Invocable_WRTCampaignHandlerOnClosing.Invocable_WRTCampaignHandlerOnClosing(new list<string>{'12345,'+dateToday+','+dateToday+','});
    }
}