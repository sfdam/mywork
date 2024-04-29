@IsTest
public class WRT_JSON2Apex_Lead_Test {
	
	static testMethod void testParse() {
		String json = '[{\"iva\":\"12894181002\",\"cf\":\"97799150582\",\"nome\":\"giorgio\",\"cognome\":\"bello\",\"company\":\"23423\"},{\"iva\":\"pippo\",\"cf\":\"pluto\",\"nome\":\"giorgio\",\"cognome\":\"bello\",\"company\":\"xxx\"}]';
		List<WRT_JSON2Apex_Lead> obj = WRT_JSON2Apex_Lead.parse(json);
		System.assert(obj != null);
	}
}