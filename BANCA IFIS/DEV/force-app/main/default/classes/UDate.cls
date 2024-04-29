public with sharing class UDate {
  public static Datetime getDatetimeValue(Long timestamp) {
    return timestamp == null ? null : Datetime.newInstance(timestamp);
  }

  public static Date getDateValue(Long timestamp) {
    Datetime tmp = getDatetimeValue(timestamp);
    return tmp == null ? null : tmp.date();
  }

  public static Long getLongValue(Date data) {
    if(data == null) return null;
    Datetime tmp = Datetime.newInstance(data, Time.newInstance(0, 0, 0, 0));
    return tmp == null ? null : tmp.getTime();
  }

  //20170125
  public static Date parseDateYYYYMMDD(String strDate) {
    if (String.isBlank(strDate)) return null;
    if (strDate.length() < 8) {
      throw new Ex.GenericException('data non valida');
    }
    Integer year = Integer.valueOf(strDate.substring(0, 4));
    Integer month = Integer.valueOf(strDate.substring(4, 6));
    Integer day = Integer.valueOf(strDate.substring(6, 8));
    return Date.newInstance(year, month, day);
  }

    public static String formatDate(Date d, String format) {
    if (d == null) return null;
    Datetime tmp = Datetime.newInstance(d, Time.newInstance(0, 0, 0, 0));
    return tmp.format(format);
  }

  public static String getStringDateDDMMYYY(Date d) {
    return formatDate(d, 'ddMMyyyy');
  }
}