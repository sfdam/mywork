@isTest 
private class SchCalcoloPreventivoTest {

	@isTest 
	static void testSchedule() {
		User usr = [SELECT Id, Name FROM User WHERE UserRoleId != null AND isActive = true LIMIT 1];
		System.RunAs(usr) {
			SchCalcoloPreventivo sh1 = new SchCalcoloPreventivo();
			String sch = '0 30 * * * ?';
			System.schedule('Test for SchCalcoloPreventivo', sch, sh1);
		}
	}
}