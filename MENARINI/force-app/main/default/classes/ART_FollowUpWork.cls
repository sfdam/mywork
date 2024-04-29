public class ART_FollowUpWork
{
    private static boolean fromDesktop = false;
	
	public static boolean isItFromDesktop()
    {
        return fromDesktop;
    }
	
    public static void setIsFromDesktop()
    {
        fromDesktop = true;
    }
}