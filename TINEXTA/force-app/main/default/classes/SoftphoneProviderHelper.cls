/*
Copyright 2016 salesforce.com, inc. All rights reserved.

Use of this software is subject to the salesforce.com Developerforce Terms of Use and other applicable terms that salesforce.com may make available, as may be amended from time to time. You may not decompile, reverse engineer, disassemble, attempt to derive the source code of, decrypt, modify, or create derivative works of this software, updates thereto, or any part thereof. You may not use the software to engage in any development activity that infringes the rights of a third party, including that which interferes with, damages, or accesses in an unauthorized manner the servers, networks, or other properties or services of salesforce.com or any third party.

WITHOUT LIMITING THE GENERALITY OF THE FOREGOING, THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED. IN NO EVENT SHALL SALESFORCE.COM HAVE ANY LIABILITY FOR ANY DAMAGES, INCLUDING BUT NOT LIMITED TO, DIRECT, INDIRECT, SPECIAL, INCIDENTAL, PUNITIVE, OR CONSEQUENTIAL DAMAGES, OR DAMAGES BASED ON LOST PROFITS, DATA OR USE, IN CONNECTION WITH THE SOFTWARE, HOWEVER CAUSED AND, WHETHER IN CONTRACT, TORT OR UNDER ANY OTHER THEORY OF LIABILITY, WHETHER OR NOT YOU HAVE BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGES.
*/

public class SoftphoneProviderHelper {
	public class ProviderFactory
    {
        public ProviderFactory(){}
        public SoftphoneProviderHelper.SoftphoneProvider newProvider(String className)
        {
            Type providerImpl = Type.forName(className);

            System.debug('SV providerImpl: ' + providerImpl);

            if (providerImpl == null){
                return null;
            }
            return (SoftphoneProviderHelper.SoftphoneProvider) providerImpl.newInstance();
        }
    }

    public class CallResult {
        // STANDARD
        public String status;
        public Boolean success;
        public String error;
        public String toNumber;
        public String fromNumber;
        public String accoundId;
        public String provider;
        public String duration;
        public DateTime startTime;

        public String uniqueID;
        // public DateTime startTime;
        // public String toNumber;
        // public String fromNumber;
        // public Object responseObj;
    }    

    public class VoiperResponse {
        public String date_time;
        public Boolean error;
        public String errorDescription;
        public String statusCall;
        public String uniqueID;
        public String statusCallVerbose;
    }

    public interface SoftphoneProvider {
      CallResult makeCall(String account, String token, String toNumber, String fromNumber, String metadataApiName, String outsidePrefix/*, String username, String password*/);
    }

    /*
     * Example of a call provider, using the Twilio Helper Package
     */
    public class TwilioProvider implements SoftphoneProvider {
      public CallResult makeCall(String account, String token, String toNumber, String fromNumber, String metadataApiName, String outsidePrefix/*, String username, String password*/) {
          /* uncomment this code once you installed the Twilio Helper Package in your org
           * more info here: https://www.twilio.com/docs/libraries/salesforce#installation


          TwilioRestClient client = new TwilioRestClient(account, token);

          Map<String,String> params = new Map<String,String> {
                  'To'   => toNumber,
                  'From' => fromNumber,
                  'Url' => 'http://twimlets.com/holdmusic?Bucket=com.twilio.music.ambient'
              };
          TwilioCall call = client.getAccount().getCalls().create(params);
          CallResult result = new CallResult();
          result.status = call.getStatus();
          return result;

          */
          CallResult result = new CallResult();
          result.status = 'TWILIO_IS_NOT_INSTALLED';
          result.success = true;
          return result;
        }
    }

    public class DummyProvider implements SoftphoneProvider {
      public CallResult makeCall(String account, String token, String toNumber, String fromNumber, String metadataApiName, String outsidePrefix/*, String username, String password*/) {
            CallResult result = new CallResult();
            result.status = 'DUMMY_RESPONSE_OK';
            result.toNumber = toNumber;
            result.fromNumber = fromNumber;
            result.accoundId = account;
            result.provider = 'DUMMY_PROVIDER';
            result.duration = '10sec';
            result.startTime = DateTime.now();
          	result.success= true;
            return result;
        }
    }

    public class VoiperProvider implements SoftphoneProvider {
      public CallResult makeCall(String account, String token, String toNumber, String fromNumber, String metadataApiName, String outsidePrefix/*, String username, String password*/) {

            toNumber = outsidePrefix != 'null' ? outsidePrefix + toNumber : toNumber;
            User usr = [ SELECT Id, Name, CTI_Sede__c, CTI_Interno__c, Societa__c FROM User WHERE Id =: UserInfo.getUserId() ];

            if((usr.CTI_Sede__c == null || usr.CTI_Sede__c == '') && !Test.isRunningTest()){
                throw new CalloutException(System.Label.CTI_ProviderHelper_ErroreSede);
            }

            if((usr.CTI_Interno__c == null || usr.CTI_Interno__c == '') && !Test.isRunningTest()){
                throw new CalloutException(System.Label.CTI_ProviderHelper_ErroreInterno);
            }

            String sedeCTI = Test.isRunningTest() ? 'Udine' : usr.CTI_Sede__c;

            String objectFields = 'Id, Host__c, Area__c';
            String sQuery = 'SELECT ' + objectFields + ' FROM ' + metadataApiName;
            sQuery = sQuery + ' WHERE Area__c =\'' + sedeCTI + '\' AND Societa__c = \''+ usr.Societa__c + '\' LIMIT 1';
            System.debug('SV sQuery: ' + sQuery);

            List < sObject > lstOfMetadataRecords = Database.query(sQuery);

            HttpRequest request = new HttpRequest();
            //request.setEndpoint('https://putsreq.com/UpBJ8gDxKWpTN7nz3KFA?function=dial&interno=' + '337' + '&esterno=' + toNumber);

            String internoCTI = Test.isRunningTest() ? '1234' : usr.CTI_Interno__c;

            request.setEndpoint((String)lstOfMetadataRecords[0].get('Host__c') + '/click2callplus.php?function=dial&interno=' + internoCTI + '&esterno=' + toNumber);
            // request.setEndpoint('http://requestbin.net/r/1b3dze21');
            request.setHeader('Content-Type', 'application/json');
            request.setMethod('GET');
            request.setTimeout(120000);
            //Content-Type

            HTTPResponse response = null;
            CallResult result = new CallResult();

            System.debug('SV request: ' + request);

            try{
                
                Http http = new Http();
                response = http.send(request);
                System.debug('SV response: ' + response.getBody());
                VoiperResponse x = new VoiperResponse();
                x = (VoiperResponse)JSON.deserializeStrict(response.getBody().replace('datetime', 'date_time'), VoiperResponse.class);
                System.debug('SV response: ' + x);

                result.status = 'VOIPER_RESPONSE_OK';
                result.success = x.statusCall == 'Success' ? true : false;
                result.error = x.error ? x.errorDescription : null;
                result.toNumber = toNumber;
                result.fromNumber = fromNumber;
                result.accoundId = account;
                result.uniqueID = x.uniqueID;
                result.provider = 'VOIPER_PROVIDER';
                result.startTime = DateTime.now();
            
            } catch (System.CalloutException e){
                System.debug('ERROR TEN:' + e);

                result.status = 'VOIPER_RESPONSE_KO';
                result.success = false;
                result.error = e.getMessage();
                result.toNumber = toNumber;
                result.fromNumber = fromNumber;
                result.accoundId = account;
                result.provider = 'VOIPER_PROVIDER';
                result.startTime = DateTime.now();
            }
            
            return result;
        }
    }

    //SM implementazione nexiop provider
    public class NexiOpResponse {
        public Boolean status;
        public String message;
        public NexiOpData data; // "uuid":"..."
    }

    public class NexiOpData{
        public String uuid;
    }

    public class NexiOpProvider implements SoftphoneProvider {
        public CallResult makeCall(String account, String token, String toNumber, String fromNumber, String metadataApiName, String outsidePrefix/*, String username, String password*/) {
  
              toNumber = outsidePrefix != 'null' ? outsidePrefix + toNumber : toNumber;
              User usr = [ SELECT Id, Name, CTI_Sede__c, CTI_Interno__c, CTI_Password_Warrant__c, Societa__c FROM User WHERE Id =: UserInfo.getUserId() ];
  
            //   if((usr.CTI_Sede__c == null || usr.CTI_Sede__c == '') && !Test.isRunningTest()){
            //       throw new CalloutException(System.Label.CTI_ProviderHelper_ErroreSede);
            //   }
  
            //   if((usr.CTI_Interno__c == null || usr.CTI_Interno__c == '') && !Test.isRunningTest()){
            //       throw new CalloutException(System.Label.CTI_ProviderHelper_ErroreInterno);
            //   }
  
            //   String sedeCTI = Test.isRunningTest() ? 'Udine' : usr.CTI_Sede__c;
  
              String objectFields = 'Id, Host__c, Area__c';
              String sQuery = 'SELECT ' + objectFields + ' FROM ' + metadataApiName;
              sQuery = sQuery + ' WHERE Societa__c = \''+ usr.Societa__c + '\' LIMIT 1';
              //Area__c =\'' + sedeCTI + '\' AND
              System.debug('SV sQuery: ' + sQuery);
  
              List < sObject > lstOfMetadataRecords = Database.query(sQuery);
  
              HttpRequest request = new HttpRequest();  
              String internoCTI = Test.isRunningTest() ? '1234' : usr.CTI_Interno__c;
  
              request.setEndpoint((String)lstOfMetadataRecords[0].get('Host__c'));
              request.setHeader('Content-Type', 'application/json');

              //Utenza di test
              //'890' username
              //'44auWnnDGp' password

              Blob headerValue = Blob.valueOf(usr.CTI_Interno__c+':'+usr.CTI_Password_Warrant__c);
              String authorizationHeader = 'Basic ' +
              EncodingUtil.base64Encode(headerValue);
              request.setHeader('Authorization', authorizationHeader);         

              request.setMethod('POST');
              request.setTimeout(120000);

            //   List<List<SObject>> recordsSosl = [FIND :toNumber IN ALL FIELDS RETURNING Account(Id, Name), Contact(Id, Name), Lead(Id, Name)];
            List<Contact> contacts = new List<Contact>();
            List<Account> accounts = new List<Account>();
            List<Lead> leads = new List<Lead>();

            String recordName;
            Id parentRecordId;
            String sobjectType;

            if(String.isBlank(account)){
              contacts = [SELECT Id, Name FROM Contact WHERE Phone =: toNumber OR Telefono_personale_Warrant__c =: toNumber OR MobilePhone =: toNumber];
              accounts = [SELECT Id, Name FROM Account WHERE Phone =: toNumber OR Phone_Warrant__c =: toNumber];
              leads = [SELECT Id, Name FROM Lead WHERE  Phone =: toNumber OR Telefono_personale_Warrant__c =: toNumber OR MobilePhone =: toNumber OR Telefono__c =: toNumber];

              // Id parentRecordId;
              // String recordName;

              if(!contacts.isEmpty()){
                parentRecordId = contacts[0].Id;
                recordName = contacts[0].Name;
              } else if(!accounts.isEmpty() && parentRecordId == null){
                parentRecordId = accounts[0].Id;
                recordName = accounts[0].Name;
              } else if(!leads.isEmpty() && parentRecordId == null){
                parentRecordId = leads[0].Id;
                recordName = leads[0].Name;
              }

              // String sobjectType;
              if(parentRecordId != null)
                sobjectType = String.valueOf(parentRecordId.getSobjectType());
            } else {
              System.debug('@@@ account ' + account);
              parentRecordId = (Id) account;
              sobjectType = String.valueOf(parentRecordId.getSObjectType());
              List<SObject> records = Database.query('SELECT Name FROM ' + sobjectType + ' WHERE Id = \'' + parentRecordId + '\'');
              recordName = String.valueOf(records[0].get('Name'));
            }
              
              Map<String,Object> bodyParams = new Map<String,Object>{ 
                  'source' => usr.CTI_Interno__c,
                  'number' => toNumber, //Required
                  'external_accountcode' => parentRecordId,
                  'auto_answer' => false,//'true',
                  'tag' => 'SF'}; //Fisso per i report sull'applicativo di destinazione
              request.setBody(JSON.serialize(bodyParams));
              //Content-Type
              System.debug('@@@ body ' + JSON.serialize(bodyParams));
              HTTPResponse response = null;
              CallResult result = new CallResult();
  
              System.debug('SV request: ' + request);
              try{
                  
                  Http http = new Http();
                  response = http.send(request);
                  System.debug('SV response: ' + response.getBody());
                  NexiOpResponse x = new NexiOpResponse();
                  x = (NexiOpResponse)JSON.deserializeStrict(response.getBody(), NexiOpResponse.class);
                  System.debug('SV response: ' + JSON.serialize(x));

                  if(!x.status)
                    throw new System.CalloutException(x.message);

                Task t;
                if(parentRecordId != null){
                  t = new Task(
                      Subject = 'Call ' + recordName, 
                      WhatId = sobjectType == 'Account' ? parentRecordId : null,
                      WhoId = sobjectType == 'Contact' || sobjectType == 'Lead' ? parentRecordId : null,
                      ActivityDate = System.Today(),
                      CallType = 'Outbound',
                      TaskSubtype = 'Call');
                  insert t;
                }
  
                  result.status = 'NEXIOP_RESPONSE_OK';
                  result.success = x.status;
                  result.error = x.message;
                  result.toNumber = toNumber;
                  result.fromNumber = fromNumber;
                  result.accoundId = parentRecordId; //Record del parent del task
                  //result.uniqueID = String.valueOf(x.data.uuid);
                  result.uniqueID = t != null ? String.valueOf(t.Id) : String.valueOf(x.data.uuid);
                  result.provider = 'NEXIOP_PROVIDER';
                  result.startTime = DateTime.now();
              
              } catch (System.CalloutException e){
                  System.debug('ERROR TEN:' + e);
  
                  result.status = 'NEXIOP_RESPONSE_KO';
                  result.success = false;
                  result.error = e.getMessage();
                  result.toNumber = toNumber;
                  result.fromNumber = fromNumber;
                  result.accoundId = account;
                  result.provider = 'NEXIOP_PROVIDER';
                  result.startTime = DateTime.now();
              }
              
              return result;
          }
      }
}