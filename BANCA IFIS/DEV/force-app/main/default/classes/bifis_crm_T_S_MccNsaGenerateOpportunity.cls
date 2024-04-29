@isTest 
private class bifis_crm_T_S_MccNsaGenerateOpportunity {

	@isTest(seeAllData=true)
	static void testSchedule() {
		User usr = [SELECT Id, Name FROM User WHERE UserRoleId != null AND isActive = true LIMIT 1];
		System.RunAs(usr) {
			bifis_crm_b_S_MccNsaGenerateOpportunity sh1 = new bifis_crm_b_S_MccNsaGenerateOpportunity();
			String sch = '0 30 * * * ?';
			System.schedule('Test for bifis_crm_b_S_MccNsaGenerateOpportunity', sch, sh1);
		}
	}
}