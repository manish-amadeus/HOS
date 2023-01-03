/*************************************************************************************************
Name            : NI_Search_IT_Request_Test Class
Author          : Swapnil Patil
Created Date    : 02/17/2017
Last Mod Date   : 05/26/2017
Last Mod By     : Stuart Emery
NICC Reference  : 
Description     : Test Class for the NI_Search_IT_Request Class
                : 
*************************************************************************************************/

@isTest
public class NI_Search_IT_Request_Test {

    @testSetup static void createTestData(){
        
        //Creating Custom Setting named as Default 
        NI_Search_IT_Request__c group_Cust_Setting = new NI_Search_IT_Request__c();
        group_Cust_Setting.Name='Default';
        group_Cust_Setting.Group_ID__c='0F95B00000006tL';
     
        //Custom Setting Inserted
        insert group_Cust_Setting;
    }
    
    @isTest static void search_IT_Request_Test() 
    {
    
    NI_Search_IT_Request request=new NI_Search_IT_Request();
    }
}