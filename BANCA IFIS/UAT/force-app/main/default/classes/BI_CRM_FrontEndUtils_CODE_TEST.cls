@isTest 
private class BI_CRM_FrontEndUtils_CODE_TEST {

	@isTest
	private static void testgetCCIAA_ATECO_Conf() {
		String naturaGiuridica = 'SRL';
		String sae = '430';
		BI_CRM_FrontEndUtils_CODE.getCCIAA_ATECO_Conf(naturaGiuridica, sae, '0018E00001DmIcfQAF', 'Account');

	}

	@isTest
	private static void testgetselectOptions_SAE() {
		BI_CRM_FrontEndUtils_CODE.getselectOptions_SAE('Account');
	}

	@isTest
	private static void testAnagraficaCompleta() {
		List<String> inp = new List<String>();
		List<Boolean> res = BI_CRM_FrontEndUtils_CODE.anagraficaCompleta(inp);

		System.assertEquals(false, res[0]);

		List<Account> accs = WGC_AllDataFactory.createAccount(1, true);
		inp.add(accs[0].Id);
		res = BI_CRM_FrontEndUtils_CODE.anagraficaCompleta(inp);
		System.assertEquals(false, res[0]);
	}

	
}