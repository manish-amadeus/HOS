/************************************************************************************************
Name            : NI_Pager_Bonus_TriggerHandler_Test Class
Author          : Stuart Emery
Created Date    : 5/22/2014
Last Mod Date   : 5/22/2014
Last Mod By     : Stuart Emery
NICC Reference  : 
Description     : Test Class For NI_Pager_Bonus_TriggerHandler Class
                : 
                : 
*************************************************************************************************/
@isTest (SeeAllData=false)
public class NI_Pager_Bonus_TriggerHandler_Test
{

    public static testMethod void singleInsertTest() 
    {
         //CREATE A TEST USER THAT WILL BE USED AS THE MANAGER FOR ANOTHER USER  
           User usrMgr = NI_TestClassData.createTestUser(1, 'NI Administrator'); 
           insert usrMgr;
           
         //CREATE A TEST USER THAT WILL BE USED TO CREATE A PAGER BONUS RECORD  
           User usr = NI_TestClassData.createTestUser(2, 'NI Administrator');
           usr.ManagerId = usrMgr.Id; 
           insert usr;
           
         Test.startTest();
         //CREATE A PAGER BONUS RECORD
           System.runAs(usr)
              {
                NI_Pager_Bonus__C pb = new NI_Pager_Bonus__c();
                pb.Pager_Week_Ending__c = Date.today();
                insert pb;
              }
          Test.stopTest();
          
        //QUERY THE NI PAGER BONUS OBJECT FOR THE INSERTED RECORD  
          NI_Pager_Bonus__c insertedPB = [SELECT Id, Employee_Name__c, Final_Approver__c FROM NI_Pager_Bonus__c];
          
        //VERIFY THAT THE EMPLOYEE NAME IS SET TO THE TEST USR RECORD  
          System.assertEquals(usr.Id,insertedPB.Employee_Name__c);
          
        //VERIFY THAT THE FINAL APPROVER IS SET TO THE TEST USRMGR RECORD  
          System.assertEquals(usr.ManagerId,insertedPB.Final_Approver__c);
          
        
        //QUERY THE NI PAGER BONUS SHARE OBJECT FOR THE FINAL APPROVER RECORD  
          NI_Pager_Bonus__Share shareFinalApprover = [SELECT Id, UserOrGroupId 
                                                      FROM NI_Pager_Bonus__Share
                                                      WHERE RowCause = 'Final_Approver__c'];
        
        //VERIFY THAT THE FINAL APPROVER IS IN THE SHARE  
          System.assertEquals(usrMgr.Id,shareFinalApprover.UserOrGroupId);             
           
    }
    
//================================================================================================
    public static testMethod void singleUpdateTest() 
        {
             //CREATE A TEST USER THAT WILL BE USED AS THE MANAGER FOR ANOTHER USER  
               User usrMgr = NI_TestClassData.createTestUser(1, 'NI Administrator'); 
               insert usrMgr;
               
             //CREATE A TEST USER THAT WILL BE USED AS THE MANAGER OF THE SECOND USER  
               User usrMgr2 = NI_TestClassData.createTestUser(2, 'NI Administrator'); 
               insert usrMgr2;  
               
             //CREATE A TEST USER THAT WILL BE USED TO CREATE A PAGER BONUS RECORD  
               User usr = NI_TestClassData.createTestUser(3, 'NI Administrator');
               usr.ManagerId = usrMgr.Id; 
               insert usr;
               
             //CREATE A TEST USER THAT WILL BE USED TO REASSIGN THE PAGER BONUS RECORD  
               User usr2 = NI_TestClassData.createTestUser(4, 'NI Administrator');
               usr2.ManagerId = usrMgr2.Id; 
               insert usr2;
               
             //CREATE A SECOND TEST USER THAT WILL BE USED TO REASSIGN THE PAGER BONUS RECORD  
               User usr3 = NI_TestClassData.createTestUser(5, 'NI Administrator'); 
               insert usr3;            
             
             //CREATE A PAGER BONUS RECORD
               System.runAs(usr)
                  {
                    NI_Pager_Bonus__C pb = new NI_Pager_Bonus__c();
                    pb.Employee_Name__c = usr3.Id;
                    pb.Pager_Week_Ending__c = Date.today();
                    insert pb;
                  }
              
               Test.startTest();
               //UPDATE THE PAGER BONUS RECORD
                 NI_Pager_Bonus__c insertedPB = [SELECT Id, Employee_Name__C FROM NI_Pager_Bonus__C];
                 insertedPB.Employee_Name__c = usr2.Id;
                 update insertedPB;
                  
                Test.stopTest();
                
              //QUERY THE NI PAGER BONUS OBJECT FOR THE UPDATED RECORD  
                NI_Pager_Bonus__c updatedPB = [SELECT Id, Employee_Name__c, Final_Approver__c FROM NI_Pager_Bonus__c];
          
              //VERIFY THAT THE FINAL APPROVER IS SET TO THE TEST USRMGR2 RECORD  
                System.assertEquals(usr2.ManagerId,updatedPB.Final_Approver__c);
          
        
              //QUERY THE NI PAGER BONUS SHARE OBJECT FOR THE FINAL APPROVER RECORD  
                NI_Pager_Bonus__Share shareFinalApprover = [SELECT Id, UserOrGroupId 
                                                            FROM NI_Pager_Bonus__Share
                                                            WHERE RowCause = 'Final_Approver__c'];
        
              //VERIFY THAT THE FINAL APPROVER IS IN THE SHARE  
                System.assertEquals(usrMgr2.Id,shareFinalApprover.UserOrGroupId);
                
              
              //QUERY THE NI PAGER BONUS SHARE OBJECT FOR THE EMPLOYEE NAME RECORD  
                NI_Pager_Bonus__Share shareEmployee = [SELECT Id, UserOrGroupId 
                                                       FROM NI_Pager_Bonus__Share
                                                       WHERE RowCause = 'Employee__c'];
        
              //VERIFY THAT THE EMPLOYEE NAME IS IN THE SHARE  
                System.assertEquals(usr2.Id,shareEmployee.UserOrGroupId);                                  
               
        }
        
//========================================================================================================
  public static testMethod void singleUpdateEmployeeNameTest() 
        {
             //CREATE A TEST USER THAT WILL BE USED AS THE MANAGER FOR ANOTHER USER  
               User usrMgr = NI_TestClassData.createTestUser(1, 'NI Administrator'); 
               insert usrMgr;
               
             //CREATE A TEST USER THAT WILL BE USED AS THE MANAGER OF THE SECOND USER  
               User usrMgr2 = NI_TestClassData.createTestUser(2, 'NI Administrator'); 
               insert usrMgr2;
               
             //CREATE A TEST USER THAT WILL BE USED AS THE MANAGER OF THE SECOND USER  
               User usrMgr3 = NI_TestClassData.createTestUser(3, 'NI Administrator'); 
               insert usrMgr3;    
               
             //CREATE A TEST USER THAT WILL BE USED TO CREATE A PAGER BONUS RECORD  
               User usr = NI_TestClassData.createTestUser(4, 'NI Administrator');
               usr.ManagerId = usrMgr.Id; 
               insert usr;
               
             //CREATE A TEST USER THAT WILL BE USED TO REASSIGN THE PAGER BONUS RECORD  
               User usr2 = NI_TestClassData.createTestUser(5, 'NI Administrator');
               usr2.ManagerId = usrMgr2.Id; 
               insert usr2;
               
             //CREATE A SECOND TEST USER THAT WILL BE USED TO REASSIGN THE PAGER BONUS RECORD  
               User usr3 = NI_TestClassData.createTestUser(6, 'NI Administrator');
               usr3.ManagerId = usrMgr3.Id; 
               insert usr3;            
             
             //CREATE A PAGER BONUS RECORD
               System.runAs(usr)
                  {
                    NI_Pager_Bonus__C pb = new NI_Pager_Bonus__c();
                    pb.Employee_Name__c = usr2.Id;
                    pb.Pager_Week_Ending__c = Date.today();
                    insert pb;
                  }
              
               Test.startTest();
               //UPDATE THE PAGER BONUS RECORD
                 NI_Pager_Bonus__c insertedPB = [SELECT Id, Employee_Name__C FROM NI_Pager_Bonus__C];
                 insertedPB.Employee_Name__c = usr3.Id;
                 update insertedPB;
                  
                Test.stopTest();
                
              //QUERY THE NI PAGER BONUS OBJECT FOR THE UPDATED RECORD  
                NI_Pager_Bonus__c updatedPB = [SELECT Id, Employee_Name__c, Final_Approver__c FROM NI_Pager_Bonus__c];
          
              //VERIFY THAT THE FINAL APPROVER IS SET TO THE TEST USRMGR2 RECORD  
                System.assertEquals(usr3.ManagerId,updatedPB.Final_Approver__c);
          
        
              //QUERY THE NI PAGER BONUS SHARE OBJECT FOR THE FINAL APPROVER RECORD  
                NI_Pager_Bonus__Share shareFinalApprover = [SELECT Id, UserOrGroupId 
                                                            FROM NI_Pager_Bonus__Share
                                                            WHERE RowCause = 'Final_Approver__c'];
        
              //VERIFY THAT THE FINAL APPROVER IS IN THE SHARE  
                System.assertEquals(usrMgr3.Id,shareFinalApprover.UserOrGroupId);
                
              
              //QUERY THE NI PAGER BONUS SHARE OBJECT FOR THE EMPLOYEE NAME RECORD  
                NI_Pager_Bonus__Share shareEmployee = [SELECT Id, UserOrGroupId 
                                                       FROM NI_Pager_Bonus__Share
                                                       WHERE RowCause = 'Employee__c'];
        
              //VERIFY THAT THE EMPLOYEE NAME IS IN THE SHARE  
                System.assertEquals(usr3.Id,shareEmployee.UserOrGroupId);                                     
               
        }

//======================================================================================================================================

     public static testMethod void singleUpdateNoFinalApproverTest() 
        {          
             //CREATE A TEST USER THAT WILL BE USED TO CREATE A PAGER BONUS RECORD  
               User usr = NI_TestClassData.createTestUser(4, 'NI Administrator');
               insert usr;
               
             //CREATE A TEST USER THAT WILL BE USED TO REASSIGN THE PAGER BONUS RECORD  
               User usr2 = NI_TestClassData.createTestUser(5, 'NI Administrator');
               insert usr2;            
             
             //CREATE A PAGER BONUS RECORD
               System.runAs(usr)
                  {
                    NI_Pager_Bonus__C pb = new NI_Pager_Bonus__c();
                    pb.Pager_Week_Ending__c = Date.today();
                    insert pb;
                  }
              
               Test.startTest();
               //UPDATE THE PAGER BONUS RECORD
                 NI_Pager_Bonus__c insertedPB = [SELECT Id, Employee_Name__C FROM NI_Pager_Bonus__C];
                 insertedPB.Employee_Name__c = usr2.Id;
                 update insertedPB;
                  
                Test.stopTest();
                
              //QUERY THE NI PAGER BONUS OBJECT FOR THE UPDATED RECORD  
                NI_Pager_Bonus__c updatedPB = [SELECT Id, Employee_Name__c, Final_Approver__c FROM NI_Pager_Bonus__c];
          
              //VERIFY THAT THE FINAL APPROVER IS SET TO THE TEST USRMGR2 RECORD  
                System.assertEquals(null,updatedPB.Final_Approver__c);
          
        
              //QUERY THE NI PAGER BONUS SHARE OBJECT FOR THE FINAL APPROVER RECORD  
                List<NI_Pager_Bonus__Share> lstShareFinalApprover = [SELECT Id, UserOrGroupId 
                                                            FROM NI_Pager_Bonus__Share
                                                            WHERE RowCause = 'Final_Approver__c'];
        
              //VERIFY THAT THE THERE ARE NOT RECORDS IN THE SHARE LIST  
                System.assertEquals(0,lstShareFinalApprover.size());
               
        }
        
//=======================================================================================================================

   public static testMethod void bulkInsertTest() 
        {
             //CREATE A TEST USER THAT WILL BE USED AS THE MANAGER FOR ANOTHER USER  
               User usrMgr = NI_TestClassData.createTestUser(1, 'NI Administrator'); 
               insert usrMgr;
               
             //CREATE A TEST USER THAT WILL BE USED TO CREATE A PAGER BONUS RECORD  
               User usr = NI_TestClassData.createTestUser(4, 'NI Administrator');
               usr.ManagerId = usrMgr.Id; 
               insert usr;
             
             //CREATE 200 PAGER BONUS RECORDS
               Test.startTest();
               
               List<NI_Pager_Bonus__C> lstPagerBonusToInsert = new List<NI_Pager_Bonus__C>();
               System.runAs(usr)
                  {  
                    for (Integer j=0;j<200;j++) 
                        {
                           NI_Pager_Bonus__C pb = new NI_Pager_Bonus__c();
                           pb.Pager_Week_Ending__c = Date.today();
                           lstPagerBonusToInsert.add(pb);
                        }
                     Database.insert(lstPagerBonusToInsert);
                   }     
                Test.stopTest();
                
              //QUERY THE NI PAGER BONUS OBJECT FOR THE UPDATED RECORD  
                List<NI_Pager_Bonus__c> lstInsertedPB = [SELECT Id, Final_Approver__c 
                                                         FROM NI_Pager_Bonus__c
                                                         WHERE Employee_Name__c =: usr.Id
                                                         AND Final_Approver__c =: usrMgr.Id];
          
              //VERIFY THAT THERE ARE 200 RECORDS  
                System.assertEquals(200,lstInsertedPB.size());
          
        
              //QUERY THE NI PAGER BONUS SHARE OBJECT FOR THE FINAL APPROVER RECORD  
                List<NI_Pager_Bonus__Share> lstInsertedShares = [SELECT Id, UserOrGroupId 
                                                        FROM NI_Pager_Bonus__Share
                                                        WHERE UserOrGroupId =: usrMgr.Id
                                                        AND RowCause = 'Final_Approver__c'];
        
              //VERIFY THAT THE FINAL APPROVER IS IN THE SHARE  
                System.assertEquals(200,lstInsertedShares.size());
                                     
               
        }                        
                
    
}