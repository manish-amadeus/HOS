/***********************************************************************************************
Name            : AH_PLCM_Calculate_Email_Trigger_Date
Author          : Sanjay Parmar
Created Date    : 04-Oct-2020
Last Mod Date   : 06-Oct-2020
Last Mod By     : Sanjay Parmar
NICC Reference  : 
Description     : Class to calculate migration reminder date
************************************************************************************************/
public class AH_PLCM_Calculate_Email_Trigger_Date {
    public static Date getMigrationRemiderDate(List<Date> lstHolidays, Date migrationDate, integer additionalDays, boolean flagAddDays) {
        Date newDate = null;
        DateTime newDateTime = null;
        try {
            newDate = migrationDate.addDays(additionalDays);
            newDateTime = DateTime.newInstance(newDate.year(), newDate.month(), newDate.day());
            
            integer totalWeekends = 0, intHolidaysCount = 0;
            if(flagAddDays) { //After Case
                totalWeekends = getWeekendBetweenDates(migrationDate, newDate);
                newDate = newDate.addDays(totalWeekends * 2); //Add weekend days in the date
                intHolidaysCount = getHolidaysCountBetweenDates(lstHolidays, migrationDate, newDate);
            }
            else { //Before Case
                totalWeekends = getWeekendBetweenDates(newDate, migrationDate);
                newDate = newDate.addDays(totalWeekends * -2); //Subtract weekend days from the date
                intHolidaysCount = getHolidaysCountBetweenDates(lstHolidays, newDate, migrationDate);
            }
            
            if(intHolidaysCount > 0) {
                //Exclude holidays
                newDate = newDate.addDays(flagAddDays ? intHolidaysCount : (intHolidaysCount * -1));

                //Calling same method reccursively to check if weekends or holidays occurs on new date
                newDate = getMigrationRemiderDate(lstHolidays, newDate, 0, flagAddDays);
            }
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
        List<Date> lstHolidays = null;
        try {
            lstHolidays = new List<Date>();
            
            //Holidays of 2020
            lstHolidays.add(Date.newInstance(2020, 1, 1));
            lstHolidays.add(Date.newInstance(2020, 2, 17));
            lstHolidays.add(Date.newInstance(2020, 5, 25));
            lstHolidays.add(Date.newInstance(2020, 7, 3));
            lstHolidays.add(Date.newInstance(2020, 9, 7));
            lstHolidays.add(Date.newInstance(2020, 11, 26));
            lstHolidays.add(Date.newInstance(2020, 11, 27));
            lstHolidays.add(Date.newInstance(2020, 12, 24));
            lstHolidays.add(Date.newInstance(2020, 12, 25));
            lstHolidays.add(Date.newInstance(2020, 12, 31));
            
            //Holidays of 2021
            lstHolidays.add(Date.newInstance(2021, 1, 1));
            lstHolidays.add(Date.newInstance(2021, 2, 15));
            lstHolidays.add(Date.newInstance(2021, 5, 31));
            lstHolidays.add(Date.newInstance(2021, 7, 5));
            lstHolidays.add(Date.newInstance(2021, 9, 6));
            lstHolidays.add(Date.newInstance(2021, 11, 25));
            lstHolidays.add(Date.newInstance(2021, 11, 26));
            lstHolidays.add(Date.newInstance(2021, 12, 24));
            lstHolidays.add(Date.newInstance(2021, 12, 27));
            lstHolidays.add(Date.newInstance(2021, 12, 31));
            
            return lstHolidays;
        }
        catch(Exception ex) {
            System.debug('Error Occured in getHolidaysList() - ' + String.valueOf(ex));
            throw ex;
        }
        finally {
            lstHolidays = null;
        }
    }
}