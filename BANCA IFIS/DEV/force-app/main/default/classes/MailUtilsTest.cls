/**
 * Created by ccardinale on 19/05/2017.
 */

/**
 * Questa classe chiama soltanto i metodi senza fare assert
 **/
@IsTest
private class MailUtilsTest {
  @IsTest
  static void testInviaMail(){
    MailUtils.inviaMail('aaa', 'bb');
  }

  @IsTest
  static void testInviaMaildaTaskEventi(){
    MailUtils.inviaMaildaTaskEventi(new List<Sobject>(), 'SegnalazioneNPL'); //TODO fare meglio con lista piena
  }

  @IsTest
  static void testInviaMailApex(){
    MailUtils.inviaMailApex('SegnalazioneNPL', 'aaa', new List<String>{'aaa'} ,new List<String>{'aaa'}, new Map<String, String>{'a'=>'b'});
  }

  @IsTest
  static void testInviaMailApexHTML(){
    MailUtils.inviaMailApexHTML('SegnalazioneNPL', 'aaa', new List<String>{'aaa'} ,new List<String>{'aaa'},new List<String>{'aaa'}, new Map<String, String>{'a'=>'b'});
  }

  // @IsTest
  // static void testCreaMailApexHTML(){
  //   MailUtils.creaMailApexHTML('SegnalazioneNPL', 'aaa', new List<String>{'aaa'} ,new List<String>{'aaa'},new List<String>{'aaa'}, new Map<String, String>{'a'=>'b'});
  // }

  @IsTest
  static void testCreaMailApexHTMLSostituzioni(){
    MailUtils.creaMailApexHTMLSostituzioni('<html></html>', 'subject', 'sender', null, null, new List<String>{'to'}, new List<String>{'cc'}, new List<String>{'ccn'}, new Map<String, String>{'a'=>'b'});
  }
}