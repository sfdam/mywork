@isTest
public class ConnectorPushToGenesysCloud_Test {
	static testMethod void myUnitTest() {
        Object o;
        ConnectorPushToGenesysCloud cptgc = new ConnectorPushToGenesysCloud(o);
        
        List<String> objId = new List<String>();
        objId.add('123123');
        Test.startTest();
        ConnectorPushToGenesysCloud.pushToGcWithTId(objId); 
        Test.stopTest();  
    }
}