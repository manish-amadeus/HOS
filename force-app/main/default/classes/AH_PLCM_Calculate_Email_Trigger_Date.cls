/***********************************************************************************************
Name            : AH_PLCM_Calculate_Email_Trigger_Date
Author          : Sanjay Parmar
Created Date    : 04-Oct-2020
Last Mod Date   : 14-Sep-2022
Last Mod By     : Hardik Doshi - Modified as per new requirement to consider Reminder date2, Reminder date3
NICC Reference  : 
Description     : Class to calculate migration reminder date
************************************************************************************************/
public class AH_PLCM_Calculate_Email_Trigger_Date {
    public static Date getMigrationRemiderDate(Date migrationDate, integer additionalDays, boolean flagAddDays) {
        Date newDate = null;
        DateTime newDateTime = null;
        try {
            newDate = migrationDate.addDays(additionalDays);
            //Get amadeus holidays list
            List<Date> lstHolidays = getHolidaysList();
            integer totalWeekends = 0, intHolidaysCount = 0;
            if(flagAddDays) { //After Case
                totalWeekends = getWeekendBetweenDates(migrationDate, newDate);
                newDate = newDate.addDays(totalWeekends * 2); //Add weekend days in the date
                intHolidaysCount = getHolidaysCountBetweenDates(lstHolidays, migrationDate, newDate);
            }
            else { //Before Case
                totalWeekends = getWeekendBetweenDates(newDate, migrationDate);
                newDate = newDate.addDays(totalWeekends * -2); //Subtract weekend days from the date
                intHolidaysCount = getHolidaysCountBetweenDates(lstHolidays, newDate, migrationDate.addDays(-1));
            }
            
            if(intHolidaysCount > 0) {
                //Exclude holidays
                integer intTotalHolidays = flagAddDays ? intHolidaysCount : (intHolidaysCount * -1);
                //Calling same method reccursively to check if weekends or holidays occurs on new date
                newDate = getMigrationRemiderDate(newDate, intTotalHolidays, flagAddDays);
            }
            System.debug('Final newDate: ' + newDate);
            return newDate;
        }
        catch(Exception ex) {
            System.debug('Error Occured in getMigrationRemiderDate() - ' + String.valueOf(ex));
            throw ex;
        }
        finally {
            newDate = null;
            newDateTime = null;
        }
    }
    
    //Get total number of weekends between two dates
    public static integer getWeekendBetweenDates(Date startDate, Date endDate) {
        Date dt = null;
        DateTime dtTime = null;
        String strWeekDay = null;
        try {
            integer totalWeekends = 0;
            dt = Date.newInstance(startDate.year(), startDate.month(), startDate.day()); //Start loop with startDate

            while(dt <= endDate) {
                dtTime = DateTime.newInstance(dt.year(), dt.month(), dt.day());

                strWeekDay = dtTime.format('E');
                if(strWeekDay.toLowerCase() == 'sat' || strWeekDay.toLowerCase() == 'sun') {
                    totalWeekends++;
                    if(strWeekDay.toLowerCase() == 'sat') {
                        dt = dt.addDays(1); //Skip Sunday
                    }
                }
                dt = dt.addDays(1); //Set next date
            }
            return totalWeekends;
        }
        catch(Exception ex) {
            System.debug('Error Occured in getWeekendBetweenDates() - ' + String.valueOf(ex));
            throw ex;
        }
        finally {
            dt = null;
            dtTime = null;
            strWeekDay = null;
        }
    }
    
    //Get total holidays between two dates
    public static integer getHolidaysCountBetweenDates(List<Date> lstHolidays, Date startDate, Date endDate) {
        try {
            integer intCount = 0;
            if(lstHolidays != null && startDate != null && endDate != null) {
                for(Date dt : lstHolidays) {
                    if(dt >= startDate && dt <= endDate) {
                        intCount++;
                    }
                }
            }
            return intCount;
        }
        catch(Exception ex) {
            System.debug('Error Occured in getHolidaysCountBetweenDates() - ' + String.valueOf(ex));
            throw ex;
        }
    }
    
    //Get amadeus holidays list
    public static List<Date> getHolidaysList() {
        List<Date> lstHolidayDates = null;
        try {
            lstHolidayDates = new List<Date>();
            List<pse__HolidayObj__c> lstHolidays = [SELECT pse__Date__c FROM pse__HolidayObj__c];
            for(pse__HolidayObj__c objHoliday : lstHolidays) {
               lstHolidayDates.add(objHoliday.pse__Date__c);
            }
            
            return lstHolidayDates;
        }
        catch(Exception ex) {
            System.debug('Error Occured in getHolidaysList() - ' + String.valueOf(ex));
            throw ex;
        }
        finally {
            lstHolidayDates = null;
        }
    }
}