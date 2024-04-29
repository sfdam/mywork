/*
Copyright 2016 salesforce.com, inc. All rights reserved.

Use of this software is subject to the salesforce.com Developerforce Terms of Use and other applicable terms that salesforce.com may make available, as may be amended from time to time. You may not decompile, reverse engineer, disassemble, attempt to derive the source code of, decrypt, modify, or create derivative works of this software, updates thereto, or any part thereof. You may not use the software to engage in any development activity that infringes the rights of a third party, including that which interferes with, damages, or accesses in an unauthorized manner the servers, networks, or other properties or services of salesforce.com or any third party.

WITHOUT LIMITING THE GENERALITY OF THE FOREGOING, THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED. IN NO EVENT SHALL SALESFORCE.COM HAVE ANY LIABILITY FOR ANY DAMAGES, INCLUDING BUT NOT LIMITED TO, DIRECT, INDIRECT, SPECIAL, INCIDENTAL, PUNITIVE, OR CONSEQUENTIAL DAMAGES, OR DAMAGES BASED ON LOST PROFITS, DATA OR USE, IN CONNECTION WITH THE SOFTWARE, HOWEVER CAUSED AND, WHETHER IN CONTRACT, TORT OR UNDER ANY OTHER THEORY OF LIABILITY, WHETHER OR NOT YOU HAVE BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGES.
*/

@isTest(SeeAllData=true)
private class SoftphoneProviderControllerTest {
    private static testMethod void testDummyProviderCall() {
        SoftphoneProviderHelper.CallResult expectedResult = new SoftphoneProviderHelper.CallResult();
        expectedResult.status = 'DUMMY_RESPONSE_OK';
        expectedResult.toNumber = 'toNumber';
        expectedResult.fromNumber = 'fromNumber';
        expectedResult.accoundId = 'account';
        expectedResult.provider = 'DUMMY_PROVIDER';
        expectedResult.duration = '10sec';
        // ACT
        SoftphoneProviderHelper.CallResult actualResult = (SoftphoneProviderHelper.CallResult) JSON.deserialize(SoftphoneProviderController.call('DummyProvider', 'account', 'token', 'toNumber', 'fromNumber', 'metadataApiName', 'outsidePrefix'),SoftphoneProviderHelper.CallResult.class);
        System.assert(actualResult.startTime != null, 'Result should contain a startTime');
        actualResult.startTime = null;
        
    }

    private static testMethod void testTwilioCallWhenTwilioNotInstalled() {
        SoftphoneProviderHelper.CallResult expectedResult = new SoftphoneProviderHelper.CallResult();
        expectedResult.status = 'TWILIO_IS_NOT_INSTALLED';
        // ACT
        SoftphoneProviderHelper.CallResult actualResult = (SoftphoneProviderHelper.CallResult) JSON.deserialize(SoftphoneProviderController.call('TwilioProvider', 'account', 'token', 'toNumber', 'fromNumber', 'metadataApiName', 'outsidePrefix'),SoftphoneProviderHelper.CallResult.class);
       
    }
    
    
    private static testMethod void testProviderNotFound() {
        SoftphoneProviderHelper.CallResult expectedResult = new SoftphoneProviderHelper.CallResult();
        expectedResult.status = 'TWILIO_IS_NOT_INSTALLED';
        // ACT
        SoftphoneProviderHelper.CallResult actualResult = (SoftphoneProviderHelper.CallResult) JSON.deserialize(SoftphoneProviderController.call('NotFound', 'account', 'token', 'toNumber', 'fromNumber', 'metadataApiName', 'outsidePrefix'),SoftphoneProviderHelper.CallResult.class);
       
    }
         
    @isTest static  void testVoiperGetCallout() {
        // Create the mock response based on a static resource
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('VoiperTestResource');
        mock.setStatusCode(200);
        mock.setHeader('Content-Type', 'application/json');
        // Associate the callout with a mock response
        Test.setMock(HttpCalloutMock.class, mock);
        // Call method to test

        SoftphoneProviderHelper.CallResult expectedResult = new SoftphoneProviderHelper.CallResult();
        // ACT
        SoftphoneProviderHelper.CallResult actualResult = (SoftphoneProviderHelper.CallResult) JSON.deserialize(SoftphoneProviderController.call('VoiperProvider', 'account', 'token', 'toNumber', 'fromNumber', 'CTI_Setting__mdt', 'outsidePrefix'),SoftphoneProviderHelper.CallResult.class);
       
    }

    @isTest static  void testNexiOpGetCallout() {
        // Create the mock response based on a static resource
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('NexiOpTestResource');
        mock.setStatusCode(200);
        mock.setHeader('Content-Type', 'application/json');
        // Associate the callout with a mock response
        Test.setMock(HttpCalloutMock.class, mock);
        // Call method to test

        Test.startTest();
        SoftphoneProviderHelper.CallResult expectedResult = new SoftphoneProviderHelper.CallResult();
        // ACT
        SoftphoneProviderHelper.CallResult actualResult = (SoftphoneProviderHelper.CallResult) JSON.deserialize(SoftphoneProviderController.call('NexiOpProvider', '', 'token', '3315312356', 'fromNumber', 'CTI_Setting__mdt', 'outsidePrefix'),SoftphoneProviderHelper.CallResult.class);

        Test.stopTest();
       
    }

    @isTest
    private static void nexiOpNeg(){

        Test.setMock(HttpCalloutMock.class, new SoftphoneHttpMock());
        
        Test.startTest();
        SoftphoneProviderHelper.CallResult expectedResult = new SoftphoneProviderHelper.CallResult();
        // ACT
        // SoftphoneProviderHelper.CallResult actualResult = (SoftphoneProviderHelper.CallResult) JSON.deserialize(SoftphoneProviderController.call('NexiOpProvider', '', 'token', '3315312356', 'fromNumber', 'CTI_Setting__mdt', 'outsidePrefix'),SoftphoneProviderHelper.CallResult.class);
        SoftphoneProviderHelper.NexiOpProvider nexiOp = new SoftphoneProviderHelper.NexiOpProvider(); 
        nexiOp.makeCall('', 'token', '3315312356', 'fromNumber', 'CTI_Setting__mdt', 'outsidePrefix');

        Test.stopTest();
    }

    public class SoftphoneHttpMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            // Create a fake response.
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"status": false, "message": "ERROR", "data":{"uuid": "12basakkjbkj-advoasb-asac"}}');
            res.setStatusCode(200);
            return res;
        }
    }
}