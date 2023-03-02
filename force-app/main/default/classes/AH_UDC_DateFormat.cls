<<<<<<< HEAD
<<<<<<< HEAD
/*
  Name            : AH_UDC_DateFormat
  Author          : George Tasker (george.tasker@amadeus.com   
  Created Date    : 2021-Sep-23
  Description     : Date formatting based on Current User locale
 */
public class AH_UDC_DateFormat {

   public static final String DEFAULT_DATE_FORMAT = 'yyyy-MM-dd';

   private static Integer TEST_YEAR = 2021;
   private static Integer TEST_MONTH = 1;
   private static Integer TEST_DAY = 2;

   private static String m_dateSeparator = null;
   private static String m_dateFormat = null;

   public static String DateSeparator() {
      if (m_dateSeparator != null) return m_dateSeparator;

      // 2021 January 2nd
      Date dt = date.newInstance(TEST_YEAR, TEST_MONTH, TEST_DAY);

      // Gives a string version of the date formatted in the current user's locale
      String dtString = dt.format();

      // Determine the separator character the current user's locale requires
      String sep = '';
      for (Integer i=0; i<dtString.length()-1; i++) {
         // Find the first non-numeric character in the string
         if (!dtString.substring(i, i+1).isNumeric()) {
            // Some locales use more than one character as the separator (e.g. Korean uses ". ")
            while (i<dtString.length()-1 && !dtString.substring(i, i+1).isNumeric()) {
               sep += dtString.substring(i, i+1);
               i++;
            }
            break;
         }
      }
      return sep;
   }

   public static String DateFormatString() {
      if (m_dateFormat != null) return m_dateFormat;

      // 2021 January 2nd
      Date dt = Date.newInstance(TEST_YEAR, TEST_MONTH, TEST_DAY);
      // Gives a string version of the date formatted in the current user's locale
      String dtString = dt.format();

      String sep = DateSeparator();
      string[] parts = dtString.split((sep == '.') ? '\\.' : sep);

      string format = '';
      // Search each part of the split string to find the Year, Month, and Day that was 
      // specified in the example date to determine the formatting string sequence
      for (string p : parts) {
         if (p != parts[0]) format += sep;
         if (p == String.valueOf(TEST_YEAR)) { format += 'yyyy'; continue; }
         if (p == String.valueOf(TEST_MONTH)) { format += 'M'; continue; }
         if (p == String.valueOf(TEST_MONTH).leftPad(2, '0')) { format += 'MM'; continue; }
         if (p == String.valueOf(TEST_DAY)) { format += 'd'; continue; }
         if (p == String.valueOf(TEST_DAY).leftPad(2, '0')) { format += 'dd'; continue; }
      }

      return format;
   }
=======
/*
  Name            : AH_UDC_DateFormat
  Author          : George Tasker (george.tasker@amadeus.com   
  Created Date    : 2021-Sep-23
  Description     : Date formatting based on Current User locale
 */
public class AH_UDC_DateFormat {

   public static final String DEFAULT_DATE_FORMAT = 'yyyy-MM-dd';

   private static Integer TEST_YEAR = 2021;
   private static Integer TEST_MONTH = 1;
   private static Integer TEST_DAY = 2;

   private static String m_dateSeparator = null;
   private static String m_dateFormat = null;

   public static String DateSeparator() {
      if (m_dateSeparator != null) return m_dateSeparator;

      // 2021 January 2nd
      Date dt = date.newInstance(TEST_YEAR, TEST_MONTH, TEST_DAY);

      // Gives a string version of the date formatted in the current user's locale
      String dtString = dt.format();

      // Determine the separator character the current user's locale requires
      String sep = '';
      for (Integer i=0; i<dtString.length()-1; i++) {
         // Find the first non-numeric character in the string
         if (!dtString.substring(i, i+1).isNumeric()) {
            // Some locales use more than one character as the separator (e.g. Korean uses ". ")
            while (i<dtString.length()-1 && !dtString.substring(i, i+1).isNumeric()) {
               sep += dtString.substring(i, i+1);
               i++;
            }
            break;
         }
      }
      return sep;
   }

   public static String DateFormatString() {
      if (m_dateFormat != null) return m_dateFormat;

      // 2021 January 2nd
      Date dt = Date.newInstance(TEST_YEAR, TEST_MONTH, TEST_DAY);
      // Gives a string version of the date formatted in the current user's locale
      String dtString = dt.format();

      String sep = DateSeparator();
      string[] parts = dtString.split((sep == '.') ? '\\.' : sep);

      string format = '';
      // Search each part of the split string to find the Year, Month, and Day that was 
      // specified in the example date to determine the formatting string sequence
      for (string p : parts) {
         if (p != parts[0]) format += sep;
         if (p == String.valueOf(TEST_YEAR)) { format += 'yyyy'; continue; }
         if (p == String.valueOf(TEST_MONTH)) { format += 'M'; continue; }
         if (p == String.valueOf(TEST_MONTH).leftPad(2, '0')) { format += 'MM'; continue; }
         if (p == String.valueOf(TEST_DAY)) { format += 'd'; continue; }
         if (p == String.valueOf(TEST_DAY).leftPad(2, '0')) { format += 'dd'; continue; }
      }

      return format;
   }
>>>>>>> be8f81a97d079e6e4c45f805d88969f9bcae9d8a
=======
/*
  Name            : AH_UDC_DateFormat
  Author          : George Tasker (george.tasker@amadeus.com   
  Created Date    : 2021-Sep-23
  Description     : Date formatting based on Current User locale
 */
public class AH_UDC_DateFormat {

   public static final String DEFAULT_DATE_FORMAT = 'yyyy-MM-dd';

   private static Integer TEST_YEAR = 2021;
   private static Integer TEST_MONTH = 1;
   private static Integer TEST_DAY = 2;

   private static String m_dateSeparator = null;
   private static String m_dateFormat = null;

   public static String DateSeparator() {
      if (m_dateSeparator != null) return m_dateSeparator;

      // 2021 January 2nd
      Date dt = date.newInstance(TEST_YEAR, TEST_MONTH, TEST_DAY);

      // Gives a string version of the date formatted in the current user's locale
      String dtString = dt.format();

      // Determine the separator character the current user's locale requires
      String sep = '';
      for (Integer i=0; i<dtString.length()-1; i++) {
         // Find the first non-numeric character in the string
         if (!dtString.substring(i, i+1).isNumeric()) {
            // Some locales use more than one character as the separator (e.g. Korean uses ". ")
            while (i<dtString.length()-1 && !dtString.substring(i, i+1).isNumeric()) {
               sep += dtString.substring(i, i+1);
               i++;
            }
            break;
         }
      }
      return sep;
   }

   public static String DateFormatString() {
      if (m_dateFormat != null) return m_dateFormat;

      // 2021 January 2nd
      Date dt = Date.newInstance(TEST_YEAR, TEST_MONTH, TEST_DAY);
      // Gives a string version of the date formatted in the current user's locale
      String dtString = dt.format();

      String sep = DateSeparator();
      string[] parts = dtString.split((sep == '.') ? '\\.' : sep);

      string format = '';
      // Search each part of the split string to find the Year, Month, and Day that was 
      // specified in the example date to determine the formatting string sequence
      for (string p : parts) {
         if (p != parts[0]) format += sep;
         if (p == String.valueOf(TEST_YEAR)) { format += 'yyyy'; continue; }
         if (p == String.valueOf(TEST_MONTH)) { format += 'M'; continue; }
         if (p == String.valueOf(TEST_MONTH).leftPad(2, '0')) { format += 'MM'; continue; }
         if (p == String.valueOf(TEST_DAY)) { format += 'd'; continue; }
         if (p == String.valueOf(TEST_DAY).leftPad(2, '0')) { format += 'dd'; continue; }
      }

      return format;
   }
>>>>>>> be8f81a97d079e6e4c45f805d88969f9bcae9d8a
}