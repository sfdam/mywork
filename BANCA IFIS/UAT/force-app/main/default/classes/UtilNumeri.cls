/**
* Progetto:         Banca IFIS
* Sviluppata il:    27/01/2016
* Developer:        Giuliani Luigi
*/

public with sharing class UtilNumeri {
  private UtilNumeri() {}

  public static String convertiInLettere(Double num) {
    if(num == null) return null;
    //se la parte decimale è minore di 10, aggiungo uno zero davanti
    String decimalString = String.valueOf(((num - num.longValue())*100).round()).leftPad(2, '0');
    String integerString = num.longValue()!=0 ? convertiRicorsivo(num.longValue()).toUpperCase() : 'ZERO';

    //formato EURO aaaaaaaa/bb con aaaaaaaa =  parte intera in lettere maiuscole e bb = prime due cifre decimali in cifre
    return 'EURO ' + integerString + '/' +  decimalString;
  }

    //converte un numero di tipo Long in lettere. Massimo numero inseribile 999999999999
    public static String convertiRicorsivo(Long num) {
        string result = '';
        long mod = 0;
        long i = 0;
        string[] unita = new List<String>{'zero', 'uno', 'due', 'tre', 'quattro', 'cinque', 'sei', 'sette', 'otto', 'nove', 'dieci', 'undici', 'dodici', 'tredici', 'quattordici', 'quindici', 'sedici', 'diciassette', 'diciotto', 'diciannove'};
        string[] decine = new List<String>{'', 'dieci', 'venti', 'trenta', 'quaranta', 'cinquanta', 'sessanta', 'settanta', 'ottanta', 'novanta' };
        if (num>0 && num < 20)
        {
            result = unita[(Integer)num];
        }
        else
        {
            if (num < 100)
            {
                mod = math.mod(num,10);
                i = num / 10;
                if(mod == 0) {
                    result = decine[(Integer)i];
                } else if(mod==1 || mod ==8) {
                    result = decine[(Integer)i].Substring(0, decine[(Integer)i].Length() - 1) + unita[(Integer)mod];
                } else {
                    result = decine[(Integer)i] + unita[(Integer)mod];
                }
            }
            else
            {
                if (num < 1000)
                {
                    mod = math.mod(num,100);
                    i = (num - mod) / 100;
                    if(i==1) {
                        result = 'cento';
                    } else {
                        result = unita[(Integer)i] + 'cento';
                    }

                    result = result + convertiRicorsivo(mod);
                }
                else
                {
                    if (num < 10000)
                    {
                        mod = math.mod(num,1000);
                        i = (num - mod) / 1000;
                        if(i==1) {
                            result = 'mille';
                        } else {
                            result = unita[(Integer)i] + 'mila';
                        }

                        result = result + convertiRicorsivo(mod);
                    }
                    else
                    {
                        if (num < 1000000)
                        {
                            mod = math.mod(num,1000);
                            i = (num - mod) / 1000;
                            if (i < 20) {
                                result = unita[(Integer)i] + 'mila';
                            } else {
                                result = convertiRicorsivo(i) + 'mila';
                            }

                            result = result + convertiRicorsivo(mod);
                        }
                        else
                        {
                            if (num < 1000000000)
                            {
                                mod = math.mod(num,1000000);
                                i = (num - mod) / 1000000;
                                if(i==1) {
                                    result = 'unmilione';
                                 } else {
                                    result = convertiRicorsivo(i) + 'milioni';
                                 }

                                result = result + convertiRicorsivo(mod);
                            }
                            else
                            {
                                //trucco per non incorrere nel problema dell'integer troppo lungo
                                Long bigNum = 1000000;
                                bigNum = bigNum * 1000000;
                                if (num < bigNum)
                                {
                                    mod = math.mod(num,1000000000);
                                    i = (num - mod) / 1000000000;
                                    if(i==1) {
                                        result = 'unmiliardo';
                                    } else {
                                        result = convertiRicorsivo(i) + 'miliardi';
                                    }

                                    result = result + convertiRicorsivo(mod);
                                }
                            }
                        }
                    }
                }
            }
        }

        return result;
    }
}