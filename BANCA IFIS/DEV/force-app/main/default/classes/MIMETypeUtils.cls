public with sharing class MIMETypeUtils {
  private MIMETypeUtils() {}

  private static Map<String, String> mimeTypeMap {
    get {
      if(mimeTypeMap == null) {
        StaticResource mt = [SELECT Id, Body FROM StaticResource WHERE Name = 'MimeTypes'];
        mimeTypeMap = (Map<String, String>) JSON.deserialize(mt.Body.toString(), Map<String, String>.class);
      }
      return mimeTypeMap;
    }
    private set;
  }

  public static String getMIMETypeFromExtension(String extension) {
    return String.isBlank(extension) ? null : mimeTypeMap.get('.' + extension.replace('.', ''));
  }
}