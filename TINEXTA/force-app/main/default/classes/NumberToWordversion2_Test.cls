@istest
public class NumberToWordversion2_Test {

    
@istest
  public static void ConvertTest() {
  
        Funzionalita__c x= new Funzionalita__c();
        x.Disabilita_tutti_i_trigger__c=true;
        x.Disabilita_Integrazione__c = true;
        x.Disabilita_tutti_i_process_builder__c=true;
      	x.Bypass_Validation_Rules__c=true;
        insert x;
      
      
      Decimal i = 11000;
      String iLettere=NumberToWordversion2.convert((double)i);
      
      decimal j=100;
      String jLettere=NumberToWordversion2.convert((double)j);
      
      decimal k=1100;
      String kLetter=NumberToWordversion2.convert((double)k);
      
      decimal z=50.35;
      String zLetter = NumberToWordversion2.convert((double)z);
      
      decimal m=152345;
      String mLetter=NumberToWordversion2.convert((double)m);
      
  }
    

}