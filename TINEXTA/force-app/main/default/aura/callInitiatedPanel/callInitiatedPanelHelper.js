/*
Copyright 2016 salesforce.com, inc. All rights reserved.

Use of this software is subject to the salesforce.com Developerforce Terms of Use and other applicable terms that salesforce.com may make available, as may be amended from time to time. You may not decompile, reverse engineer, disassemble, attempt to derive the source code of, decrypt, modify, or create derivative works of this software, updates thereto, or any part thereof. You may not use the software to engage in any development activity that infringes the rights of a third party, including that which interferes with, damages, or accesses in an unauthorized manner the servers, networks, or other properties or services of salesforce.com or any third party.

WITHOUT LIMITING THE GENERALITY OF THE FOREGOING, THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED. IN NO EVENT SHALL SALESFORCE.COM HAVE ANY LIABILITY FOR ANY DAMAGES, INCLUDING BUT NOT LIMITED TO, DIRECT, INDIRECT, SPECIAL, INCIDENTAL, PUNITIVE, OR CONSEQUENTIAL DAMAGES, OR DAMAGES BASED ON LOST PROFITS, DATA OR USE, IN CONNECTION WITH THE SOFTWARE, HOWEVER CAUSED AND, WHETHER IN CONTRACT, TORT OR UNDER ANY OTHER THEORY OF LIABILITY, WHETHER OR NOT YOU HAVE BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGES.
*/

({
    // get call center settings, to get the information about the call provider
    // then use open CTI to screen pop to the record, and runApex() to make a call
    screenPopAndCall : function(cmp) {
        cmp.getEvent('getSettings').setParams({
            callback: function(settings) {
                sforce.opencti.screenPop({
                    type : sforce.opencti.SCREENPOP_TYPE.SOBJECT,
                    params : { recordId : cmp.get('v.recordId') },
                    callback : function(response) {
                        cmp.getEvent('editPanel').setParams({
                            label : 'CTI: ' + cmp.get('v.state')
                        }).fire();
                        var providerClass = settings['/reqPhoneSettings/reqProvider'];
                        var account = settings['/reqPhoneSettings/reqProviderAccount'];
                        var token = settings['/reqPhoneSettings/reqProviderAuthToken'];
                        var fromNumber = settings['/reqPhoneSettings/reqProviderCallerNumber'];
                        var metadataApiName = settings['/reqPhoneSettings/reqProviderMetadataApiName'];
                        var prefix = cmp.get('v.outsideCall') ? settings['/reqDialingOptions/reqOutsidePrefix'] : settings['/reqDialingOptions/reqInsidePrefix'];


                        if(prefix == undefined) prefix = '';
                        
                        let phone = cmp.get('v.phone');
                        let recordName = cmp.get('v.recordName');
                        let outsideCall = cmp.get('v.outsideCall');
                        
                        var toNumber;
                        if(phone){
                            toNumber = phone;
                        } else {
                            toNumber = recordName;
                        }

                        //Aggiunti username e password per Warrant
                        //let username = cmp.get("v.username");
                        //let password = cmp.get("v.password");

                        console.log('SV OPTION TO CALL: ', toNumber, recordName, outsideCall);
                        var accountId = '';
                        if($A.util.isEmpty(cmp.get("v.recordId")))
                            accountId = $A.util.isEmpty(cmp.get("v.account")) ? '' : typeof cmp.get("v.account") == 'string' ? cmp.get("v.account") : cmp.get("v.account").Id;
                        else
                            accountId = cmp.get("v.recordId");

                        console.log('@@@ accountId ' , accountId);
                        
                        sforce.opencti.runApex({
                            apexClass : 'SoftphoneProviderController',
                            methodName : 'call',
                            methodParams : 'providerClass=' + providerClass + '&account=' + accountId + '&token='+ token + '&fromNumber=' + String(fromNumber).replace(' ', '') + '&toNumber=' + String(toNumber).replace(' ', '') + '&metadataApiName=' + metadataApiName + '&outsidePrefix=' + prefix /*+ '&username=' + username + '&password=' + password*/,
                            //Aggiunti username e password per warrant
                            callback : function(result) {
                                console.log('SV result runApex: ', result);
                                if (result.success) {
                                    setTimeout(function () {
                                        cmp.getEvent('renderPanel').setParams({
                                            type : 'c:phonePanel',
                                            toast : {'type': 'success', 'message': $A.get("$Label.c.CTI_PanelHelper_ToastSuccess")},
                                            attributes : { presence : cmp.get('v.presence') /*username: username, password: password*/}
                                        }).fire();

                                        //SM - TEN
                                        //Apro il task solo per Warrant
                                        let parsedResponse = JSON.parse(result.returnValue.runApex);
                                        if(parsedResponse.status == 'NEXIOP_RESPONSE_OK' && parsedResponse.uniqueID.startsWith('00T')){
                                            sforce.opencti.screenPop({
                                                type : sforce.opencti.SCREENPOP_TYPE.SOBJECT,
                                                params : { recordId : parsedResponse.uniqueID },
                                                callback : function(response) {
                                                }
                                            });

                                            if(cmp.get("v.recordId") == undefined && $A.util.isEmpty(parsedResponse.accoundId)){
                                                sforce.opencti.screenPop({
                                                    type : sforce.opencti.SCREENPOP_TYPE.SOBJECT,
                                                    params : { recordId : parsedResponse.accoundId },
                                                    callback : function(response) {
                                                    }
                                                });
                                            }
                                        }
                                        //SM - TEN END
                                    }, 3000);
                                } else {
                                    cmp.getEvent('renderPanel').setParams({
                                        type : 'c:phonePanel',
                                        toast : {'type': 'error', 'message': $A.get("$Label.c.CTI_PanelHelper_ToastError")},
                                        attributes : { presence : cmp.get('v.presence') /*username: username, password: password*/}
                                    }).fire();
                                }
                            }
                        });
                    }
                })
             }
        }).fire();
    },

    // on Accept, accept the call by bringing up the Connected Panel
    renderConnectedPanel : function(cmp){
        var recordId = cmp.get('v.recordId');
        var account = cmp.get('v.account');
        cmp.getEvent('renderPanel').setParams({
            type : 'c:connectedPanel',
            attributes : {
                showDialPad : false,
                recordId : recordId,
                callType : 'Inbound',
                account : account,
                recordName: cmp.get('v.recordName'),
                presence : cmp.get('v.presence'),
                //username: cmp.get("v.username"),
                //password: cmp.get("v.password")
            }
        }).fire();
    }
})