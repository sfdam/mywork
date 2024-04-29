/**
 * Created by ssalaris on 10/08/2021.
 */

public class THR_DateUtils {

    public static Boolean checkBusinessDay (Date day, String country){

        Date tod = day;
        Boolean isBusiness = true;
        for(Holiday h : [SELECT Id, ActivityDate, Description FROM Holiday where Description = :country or Description = '']) {
            if(tod.day() == h.ActivityDate.day() && tod.month() == h.ActivityDate.month()) {
                isBusiness = false;
                break;
            }
        }

        Datetime myDateTime = (Datetime) tod;
        String dayOfWeek = myDateTime.format('u');
        if(dayOfWeek== '6' || dayOfWeek== '7') {
            isBusiness = false;
        }

        return isBusiness;
    }

    public static Decimal getDatesDifference (Datetime created, Datetime closed, String country){

        Decimal days = closed.getTime() - created.getTime();
        days = days / 86400000;
        Map<String, Holiday> holidaysMap = new Map<String, Holiday>();
        for (Holiday currHoliday : [Select ActivityDate, RecurrenceType, Description from Holiday where RecurrenceType != 'RecursWeekly' and (Description = :country or Description = '')]) {
            if(!holidaysMap.containsKey(currHoliday.ActivityDate.day() + '|' + currHoliday.ActivityDate.month())) {
                holidaysMap.put(currHoliday.ActivityDate.day() + '|' + currHoliday.ActivityDate.month(), currHoliday);
            }
        }
        Date dt;
        DateTime currDate;
        String todayDay;
        for (integer i=0; i <= Date.valueOf(created).daysBetween(Date.valueOf(closed)); i++) {
            dt = Date.valueOf(created) + i;
            currDate = DateTime.newInstance(dt.year(), dt.month(), dt.day());
            todayDay = currDate.format('EEEE');
            if (todayDay == 'Saturday' || todayDay =='Sunday' || holidaysMap.containsKey(dt.day() + '|'+ dt.month())) {
                days -= 1;
            }
        }
        return days.setScale(2);
    }


}