@isTest 
public class BI_COM_EnqueueLead_TEST {

	@IsTest
	public static void ex_test() {
		User usr = [SELECT Id, Name FROM User WHERE UserRoleId != null AND isActive = true LIMIT 1];
		System.RunAs(usr) {
			BI_COM_EnqueueLead_SCHD sh1 = new BI_COM_EnqueueLead_SCHD();
			String sch = '0 30 * * * ?';
			System.schedule('Test for BI_COM_EnqueueLead_SCHD', sch, sh1);
		}
	}
}