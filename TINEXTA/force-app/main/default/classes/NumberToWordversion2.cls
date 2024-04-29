public with sharing class NumberToWordversion2 {

     static String[] to_19 = new string[]{ 'zero', 'uno',  'due', 'tre', 'quattro',  'cinque',  'sei',  
    'sette', 'otto', 'nove', 'dieci',  'undici', 'dodici', 'tredici','quattordici', 'quindici', 'sedici', 'deciasette', 'diciotto', 'diciannove' };  
    static String[] tens = new string[]{ 'venti', 'trenta', 'quaranta', 'cinquanta', 'sessanta', 'settanta', 'ottanta', 'novanta'};  
    static String[] denom = new string[]{ '',  
      'mila',   'milioni', 'miliardi' };  
   // convert a value < 100 to English.    
      public static String convert_nn(integer val) {  
      if (val < 20)  
        return to_19[val];  
      if(val == 100)  
          return 'Cento';
      for (integer v = 0; v < tens.size(); v++) {  
        String dcap = tens[v];  
        integer dval = 20 + 10 * v;  
        if (dval + 10 > val) {  
          if (Math.Mod(val,10) != 0)  
            return dcap + '' + to_19[Math.Mod(val,10)];  
          return dcap;  
       }      
     }  
      return 'Error';  
    }  
    // convert a value < 1000 to english, special cased because it is the level that kicks   
    // off the < 100 special case. The rest are more general. This also allows you to  
    // get strings in the form of "forty-five hundred" if called directly.
    
     public static String convert_nnn(integer val) {  
      String word = '';  
      integer rem = val / 100;  
      integer mod = Math.mod(val,100); 
         
      if (rem > 1) {
         system.debug('rem'+ rem);
        word = to_19[rem] + 'cento';  
        if (mod > 0) {
          system.debug('mod'+mod); 
          word += '';  
        }  
      }else if (rem==1){
          word='cento';
        if (mod > 0) {
          system.debug('mod'+mod); 
          word += '';  
        }
      } 
         
      if (mod > 0) {  
        word += convert_nn(mod);  
      }  
      return word;  
    }
    
    
    public static String convert(double val2) {  
        
      //logica virgole 
             
        string istringa = string.valueOf(val2);
        system.debug ('istringa:'+istringa);
        long val = val2.intValue();
        system.debug ('val:'+ val);
        string dopovirgola = istringa.substringAfter('.');
        system.debug ('dopovirgola:'+dopovirgola);
        string finalstring = '' ;
        
        if (dopovirgola != '0'){
            finalstring = ','+ dopovirgola ;
            system.debug ('final:' + finalstring);
                       
        }  
        
        
        
      if (val < 100) {  
        return convert_nn(val.intValue())+ finalstring;  
      }  
      if (val < 1000) {  
        return convert_nnn(val.intValue())+ finalstring;  
      } 
        
       
      for (integer v = 0; v < denom.size(); v++) {  
        integer didx = v - 1;  
         system.debug('didx' +didx); 
        integer dval = (integer)Math.pow(1000, v);  
          system.debug('dval'+ dval);
        if (dval > val) {  
          integer mod = (integer)Math.pow(1000, didx); 
          system.debug('mod'+mod);  
          integer l = (integer) val / mod;
           system.debug('l'+l);
          integer r = (integer) val - (l * mod); 
           system.debug('r' + r);
           
            String ret='';
            if(l>1){
          		 ret = convert_nnn(l) + '' + denom[didx];  
            }else if(l==1 && mod==1000){
                 ret = 'mille';
            }else if(l==1 && mod>1000){
                ret='unmilione';
            }
          if (r > 0) {  
            ret +=convert(r);  
          }  
          return ret + finalstring;  
        }  
      }  
      return 'Non riesco a convertire un numero troppo grande';  
    }
    
}