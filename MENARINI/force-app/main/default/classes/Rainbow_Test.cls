@IsTest
public class Rainbow_Test {
	    
    @TestSetup
    static void dataInit(){
     Account accIt = THR_TestDataFactory.CreateSingleCompleteAccount('Italy','IT0000002'); 
     Contact cnt= THR_TestDataFactory.CreateSingleCompleteContact(accIt.id);  
	} 	
    
    static testmethod void formatPhoneNumberTest(){
    // String phoneTest = [Select id, phone from Contact LIMIT 1].phone;  
    // phoneTest+= phoneTest;
     String phoneTest ='+18171231234';
	 Test.startTest();
     RainbowConnector.formatPhoneNumber(phoneTest);
	 Test.stopTest();        
    }
    
     static testmethod void getAccountsByPhoneNumberTest(){
      String phoneTest = [Select id,phone from Account LIMIT 1].phone;  
     Test.startTest();
     RainbowConnector.getAccountsByPhoneNumber(phoneTest);
	 Test.stopTest();        
    }
           
     static testmethod void getAccountsByFirstLastNameTest(){
     String firstlastname = [Select id,Name from Account LIMIT 1].name;  
     Test.startTest();
     RainbowConnector.getAccountsByFirstLastName(firstlastname);
	 Test.stopTest();        
    }
    
     static testmethod void getContactsByPhoneNumberTest(){
     Account accL = [Select id, THR_Country__c from Account LIMIT 1]; 
     Contact cnt =  [Select id, phone, otherphone,mobilephone, homephone from Contact LIMIT 1];
   	 String phoneTest = cnt.phone;  
     String otherphoneTest = cnt.otherphone;  
     String mobilephoneTest = cnt.mobilephone;  
     String homephoneTest = cnt.homephone;  
     Test.startTest();
         try{
     RainbowConnector.getContactsByPhoneNumber(phoneTest);
         }Catch(Exception e){
     RainbowConnector.getContactsByPhoneNumber('+18171231234');      
         }
         try{
	 RainbowConnector.getContactsByPhoneNumber(otherphoneTest);
         }Catch(Exception e){
      RainbowConnector.getContactsByPhoneNumber('(817)123-1234');
         }
      Contact cntct2 = new Contact();
       
            cntct2.FirstName= 'NomeContattodDepL';
            cntct2.LastName='CognomeContattoDepL';
            cntct2.AccountId=accL.id;
            cntct2.Email='nomeContattoDepL@test.it'; 
            cntct2.phone='1112233221'; 
            cntct2.otherphone='3333131331';
            cntct2.mobilephone='+18171231234';
            cntct2.homephone='06222222222';
            cntct2.THR_Country__c = accL.THR_Country__c;
       insert  cntct2;
            try{
	 RainbowConnector.getContactsByPhoneNumber(cntct2.MobilePhone);
            }Catch(Exception e){}
         
	 Test.stopTest();        
    }
    
     static testmethod void getContactsByFirstLastNameTest(){
     Contact cnt =  [Select id, LastName, FirstName from Contact LIMIT 1];
     String firstlastname = cnt.LastName;
     Test.startTest();
     RainbowConnector.getContactsByFirstLastName(firstlastname);
	 Test.stopTest();        
    }
    
     static testmethod void getContactsByEmailTest(){
     Contact cnt =  [Select id, email from Contact LIMIT 1];
     String emailTest = cnt.email;    
     Test.startTest();
     RainbowConnector.getContactsByEmail(emailTest);
	 Test.stopTest();        
    }
    
    static testmethod void getContactByRecordIdTest(){
       Contact cnt =  [Select id from Contact LIMIT 1]; 
     Test.startTest();
        RainbowConnector.getContactByRecordId(cnt.id);
     Test.stopTest();
    }
    
    
    
    
    
    
 }