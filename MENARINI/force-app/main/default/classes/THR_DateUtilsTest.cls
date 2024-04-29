/**
 * Created by ssalaris on 12/08/2021.
 */
@isTest
public with sharing class THR_DateUtilsTest {

    @IsTest
    public static void checkBusinessDay_test() {

        Date myDate = Date.newInstance( 2020, 12, 25 );
        Test.startTest();
        THR_DateUtils.checkBusinessDay(myDate, 'ES');
        Test.stopTest();
    }

    @IsTest
    public static void getDatesDifference_test() {

        Datetime created = System.now().addMonths(-5);
        Datetime closed = System.now();

        Test.startTest();
        THR_DateUtils.getDatesDifference(created, closed, 'ES');
        Test.stopTest();
    }

}