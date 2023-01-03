/************************************************************************************************
Name            : AH_UTIL_FileHandler_Test
Author          : Sean Harris
Created Date    : 05/16/2019
Last Mod Date   : 05/16/2019
Last Mod By     : Sean Harris
NICC Reference  : 
Description     : Test class for AH_UTIL_FileHandler 
                : 
                : 
*************************************************************************************************/
@isTest
public class AH_UTIL_FileHandler_Test 
{
    
    // ======================================================================================================================================= 
    // = TEST METHOD 1: 
    // =======================================================================================================================================     
    @isTest static void test1() 
    {    
        
        test.startTest();    
        
        // PREPARE FILE PARAMS
        
        // BUILD UNIQUE FILENAME
        DateTime dt = system.now();
        String strFileName = 'ApexTestExport-';
        strFileName += String.valueOf(dt.Year()) + String.valueOf(dt.Month()) + String.valueOf(dt.Day()) + '-';
        strFileName += String.valueOf(dt.Hour()) + String.valueOf(dt.Minute()) + String.valueOf(dt.Second());
                
        // BUILD CSV HEADERS
        String strHeader = '';
        strHeader += 'Id,';
        strHeader += 'Name,';
		strHeader += 'Created Date';
        
        // BUILD CSV ROWS
        List<String> lst = new List<String>();        
        String strRow1 = '1234567890ABCDEFGH, ApexTest1, 2019-01-01';
        lst.add(strRow1);
        String strRow2 = '1234567890ABCDEFGI, ApexTest2, 2019-01-02';
        lst.add(strRow2);
        String strRow3 = '1234567890ABCDEFGJ, ApexTest3, 2019-01-03';
        lst.add(strRow3);        
        
        // UNIT TEST #1
        Id testId1 = AH_UTIL_FileHandler.createCSV_File(strFileName, strHeader, lst, null, null);
        system.assertNotEquals(null, testId1);
        
        // CREATE ACCOUNT TEST RECORD
        Account a = NI_TestClassData.createTestAccount(1);
        insert a;        

        // UNIT TEST #2
        Id testId2 = AH_UTIL_FileHandler.createCSV_File(strFileName, strHeader, lst, a.Id, null);
        system.assertNotEquals(null, testId2);

        // GET PARTNER CENTRAL COMMUNITY ID
        Id communityID = [SELECT Id FROM Network WHERE Name = 'PartnerCentral' LIMIT 1].Id;
        
        // UNIT TEST #3
        Id testId3 = AH_UTIL_FileHandler.createCSV_File(strFileName, strHeader, lst, a.Id, communityID);
//        system.assertNotEquals(null, testId3);

        test.stopTest();
        
    }    
    
}