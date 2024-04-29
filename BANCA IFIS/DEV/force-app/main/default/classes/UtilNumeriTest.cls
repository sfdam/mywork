/**
* Progetto:         Banca IFIS
* Sviluppata il:    27/01/2016
* Developer:        Giuliani Luigi
*/

@isTest
public with sharing class UtilNumeriTest {

    @isTest
    static void TestConvertiInLettere() {
        Double num = 3.5;
        String res = UtilNumeri.convertiInLettere(num);
        System.assertEquals('EURO TRE/50',res);
        num = 37.32;
        res = UtilNumeri.convertiInLettere(num);
        System.assertEquals('EURO TRENTASETTE/32',res);
        num = 181;
        res = UtilNumeri.convertiInLettere(num);
        System.assertEquals('EURO CENTOOTTANTUNO/00',res);
        num = 0.01;
        res = UtilNumeri.convertiInLettere(num);
        System.assertEquals('EURO ZERO/01',res);
        num = 1000;
        res = UtilNumeri.convertiInLettere(num);
        System.assertEquals('EURO MILLE/00',res);
        num = 1001;
        res = UtilNumeri.convertiInLettere(num);
        System.assertEquals('EURO MILLEUNO/00',res);
        num = 1000000;
        res = UtilNumeri.convertiInLettere(num);
        System.assertEquals('EURO UNMILIONE/00',res);
        num = 1000000000;
        res = UtilNumeri.convertiInLettere(num);
        System.assertEquals('EURO UNMILIARDO/00',res);
        num = 123456789123.45;
        res = UtilNumeri.convertiInLettere(num);
        System.assertEquals('EURO CENTOVENTITREMILIARDIQUATTROCENTOCINQUANTASEIMILIONISETTECENTOOTTANTANOVEMILACENTOVENTITRE/45',res);
    }
}