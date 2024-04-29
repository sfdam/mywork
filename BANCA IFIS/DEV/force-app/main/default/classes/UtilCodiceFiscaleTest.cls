@IsTest
public class UtilCodiceFiscaleTest {

    public static testMethod void testCalcoloCf(){
      UtilCodiceFiscale u = new UtilCodiceFiscale();
    String cf = u.calculateCodiceFiscale('Disney','Pippo',date.newInstance(1934,1,1),'M','Z404');
    system.assertEquals('DSNPPP34A01Z404D',cf);
    cf = u.calculateCodiceFiscale('Disney','Minny',date.newInstance(1936,6,21),'F','D612');
    system.assertEquals('DSNMNY36H61D612F',cf);
    cf = u.calculateCodiceFiscale('Bar','Foo',date.newInstance(2004,2,29),'M','F704');
    system.assertEquals('BRAFOO04B29F704D',cf);
    cf = u.calculateCodiceFiscale('Bu','Ba',date.newInstance(2013,12,11),'F','Z107');
    system.assertEquals('BUXBAX13T51Z107E',cf);
    }

  public testMethod static void  testCodiceFiscaleControllo(){
        UtilCodiceFiscale cf = new UtilCodiceFiscale();
        System.assertEquals('T', cf.calculateControllo('PPPDNY34A01Z404'));
    }

  public testMethod static void  testCodiceFiscaleData(){
         UtilCodiceFiscale cf = new UtilCodiceFiscale();
         System.assertEquals('78', cf.getYear(date.newInstance(1978, 1, 1)));
         System.assertEquals('A', cf.getMonth(date.newInstance(1978, 1, 1)));
         System.assertEquals('01', cf.getDay(date.newInstance(1978, 1, 1),'M'));
         System.assertEquals('41', cf.getDay(date.newInstance(1978, 1, 1),'F'));
    }

    public testMethod static void  testCodiceFiscaleCognome(){
         UtilCodiceFiscale cf = new UtilCodiceFiscale();
         System.assertEquals('MNT', cf.calculateCognome('MOIANTO'));
         System.assertEquals('MAI', cf.calculateCognome('MAIA'));
         System.assertEquals('MNA', cf.calculateCognome('MANA'));
         System.assertEquals('DRS', cf.calculateCognome('DE ROSSI'));
         System.assertEquals('DEX', cf.calculateCognome('DE'));
    }


    public static testMethod void testOmocodia(){
        String cfCalc = 'DSNPPP34A01Z404D';
        UtilCodiceFiscale cf = new UtilCodiceFiscale();

    // 4 -> Q senza modificare codice di controllo
        String cfNoCalc = 'DSNPPP34A01Z40QD';
        System.assertEquals(false,cf.checkOmocodia(cfNoCalc,cfCalc));

        // 4 -> Q modificando codice di controllo
        cfNoCalc = 'DSNPPP34A01Z40Q';
        cfNoCalc += cf.calculateControllo(cfNoCalc);
        System.assertEquals(true,cf.checkOmocodia(cfNoCalc,cfCalc));
    }

}