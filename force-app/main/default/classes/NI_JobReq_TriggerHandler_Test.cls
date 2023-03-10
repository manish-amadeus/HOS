/************************************************************************************************
Name            : NI_JobReq_TriggerHandler_Test Class
Author          : Stuart Emery
Created Date    : 3/13/2015
Last Mod Date   : 5/4/2015
Last Mod By     : Stuart Emery
NICC Reference  : 
Description     : Class that handles all trigger code for the NI_JobReq_TriggerHandler Class
                :
*************************************************************************************************/
@isTest (SeeAllData=false)
private class NI_JobReq_TriggerHandler_Test 
{
    
    
    static testMethod void myUnitTest() 
    {
        NI_TestClassData.createTestWinaproachServiceNowSettings();
        
        NI_JobReq_TriggerHandler handler = new NI_JobReq_TriggerHandler(true);
        boolean IsTriggerContext = handler.IsTriggerContext;
        
        //GET THE JOB REQUISITION RECORD TYPE ID FOR THE "Standard - Open" RECORD TYPE
        Id rtIdStandard = NI_TestClassData.getRecordTypeId('NI_Job_Requisition__c', 'Standard');
        System.Debug('rtIdStandard: ' + rtIdStandard);
        
        //GET THE JOB REQUISITION RECORD TYPE ID FOR THE "STANDARD - OPEN" RECORD TYPE
        Id rtIdRemoveUser = NI_TestClassData.getRecordTypeId('NI_Job_Requisition__c', 'Standard Remove User');
        System.Debug('rtIdRemoveUser: ' + rtIdRemoveUser);
        
        //GET THE JOB REQUISITION RECORD TYPE ID FOR THE "Offshore Contractor - Open" RECORD TYPE
        Id rtIdOffShore = NI_TestClassData.getRecordTypeId('NI_Job_Requisition__c', 'Offshore Contractor - Open');
        
        //LIST OF CUSTOM SETTINGS RECORDS TO INSERT  
        List<NI_Job_Req_RecordType_Trigger_Handler__c> lstCsToInsert = new List<NI_Job_Req_RecordType_Trigger_Handler__c>();
        
        //INSERT A TEST RECORD INTO THE NI_Job_Req_RecordType_Trigger_Handler__c CUSTOM SETTING. THE CUSTOM SETTING NEEDS TO EXIST  
        NI_Job_Req_RecordType_Trigger_Handler__c csFields = new NI_Job_Req_RecordType_Trigger_Handler__c();
        csFields.Name = 'Standard';
        csFields.Exec_Approver__c = True;
        
        lstCsToInsert.add(csFields);
        
        insert csFields;
        
        List<NI_Job_Req_RecordType_Trigger_Handler__c> lstInsertedCS = [SELECT Id, Name, Exec_Approver__C 
                                                                        FROM NI_Job_Req_RecordType_Trigger_Handler__c
                                                                        WHERE Exec_Approver__c = true];
        System.assertEquals(1, lstInsertedCS.size());    
        
        //CREATE A TEST NI DEPARTMENT RECORD  
        NI_Departments__c d = NI_TestClassData.createTestNI_Department(1);
        insert d;
        
        //CREATE A SECOND TEST NI DEPARTMENT RECORD  
        NI_Departments__c d2 = NI_TestClassData.createTestNI_Department(2);
        insert d2;
        
        //CREATE A TEST NI LOCATION RECORD  
        NI_Location__c l = NI_TestClassData.createTestNI_Location(1);
        insert l;
        
        //CREATE A SECOND TEST NI LOCATION RECORD  
        NI_Location__c l2 = NI_TestClassData.createTestNI_Location(2);
        insert l2;
        
        //CREATE A TEST NI OFFICE RECORD
        NI_Office__c o = NI_TestClassData.createTestNI_Office(1);
        insert o;
        
        //CREATE A TEST USER RECORD FOR THE EXEC MEMBER ROLE IN THE DEPARTMENT TO LOCATION TEST RECORD
        User execMember = NI_TestClassData.createTestUser(1, 'NI Administrator');
        execMember.DepartmentCode__c = d.Name;
        execMember.NI_Location__c = l.Name;
        execMember.NI_Office__c = o.Name;
        insert execMember;
        
        //CREATE A SECOND TEST USER RECORD FOR THE EXEC MEMBER ROLE IN THE DEPARTMENT TO LOCATION TEST RECORD
        User execMember2 = NI_TestClassData.createTestUser(6, 'NI Administrator');
        execMember2.DepartmentCode__c = d2.Name;
        execMember2.NI_Location__c = l2.Name;
        insert execMember2;
        
        //CREATE A TEST DEPARTMENT TO LOCATION RECORD
        NI_Department_to_Location__c d2l = NI_TestClassData.createTestNI_DepartmentToLocation(1,d.Id,l.Id,execMember.Id,'Exec Member');
        insert d2l;
        
        //CREATE A SECOND TEST DEPARTMENT TO LOCATION RECORD
        NI_Department_to_Location__c d2l2 = NI_TestClassData.createTestNI_DepartmentToLocation(1,d2.Id,l2.Id,execMember2.Id,'Exec Member');
        insert d2l2;
        
        //CREATE A USER FOR THE JOB REQUISITION OWNER
        User owner = NI_TestClassData.createTestUser(2, 'NI Administrator');
        owner.DepartmentCode__c = d.Name;
        owner.NI_Location__c = l.Name;
        owner.NI_Office__c = o.Name;
        insert owner;
        test.startTest();
        //CREATE A USER FOR THE JOB REQUISITION MANAGER
        User mgr = NI_TestClassData.createTestUser(3, 'NI Administrator');
        mgr.DepartmentCode__c = d.Name;
        mgr.NI_Location__c = l.Name;
        mgr.NI_Office__c = o.Name;
        insert mgr;
        
        //CREATE A SECOND USER FOR THE JOB REQUISITION MANAGER
        User mgr2 = NI_TestClassData.createTestUser(4, 'NI Administrator');
        mgr2.DepartmentCode__c = d.Name;
        mgr2.NI_Location__c = l.Name;
        insert mgr2;
        
        //CREATE A USER TO DISBLE
        User uDisable = NI_TestClassData.createTestUser(5, 'NI Administrator');
        insert uDisable;
        
        //CREATE A TEST JOB REQUISITION RECORD
        
        
        NI_Job_Requisition__c j = NI_TestClassData.createTestNI_Job_Requisition(1,owner.Id,rtIdStandard);
        j.Department__c = d.Id;
        j.NI_Location__c = l.Id;
        j.Manager__c = mgr.Id;
        insert j;
        
        test.stopTest();
        
        
        //GET THE EXEC APPROVER OF THE INSERTED RECORD TO VERIFY THE METHOD THAT SETS THE EXEC APPROVER VALUE
        NI_Job_Requisition__c insertedJR = [SELECT Id,Exec_Approver__c FROM NI_Job_Requisition__c
                                            WHERE id =: j.Id];
        
        //VERIFY THE EXEC APPROVER HAS BEEN SET CORRECTLY
        System.assertEquals(insertedJR.Exec_Approver__c, execMember.Id);
        
        //====================================TEST UPDATE LOGIC==========================================================================       
        //CREATE A TEST ATTACHMENT RECORD 
        Attachment attach = NI_TestClassData.createTestAttachment(j.Id);
        insert attach;
        
        //CHANGE THE MANAGER              
        j.Manager__c = mgr2.Id;
        j.Exec_Approver__c = execMember2.Id;
        update j;
        
        
        //CREATE A LIST OF JOB REQUISITION SHARE RECORDS TO VERIFY THE MANAGER AND EXEC MEMBER SHARE METHODS
        List<NI_Job_Requisition__Share> lstJobShare = [SELECT Id, UserOrGroupId, RowCause 
                                                       FROM NI_Job_Requisition__Share
                                                       WHERE ParentId =: j.Id
                                                       AND 
                                                       (UserOrGroupId =: mgr2.Id
                                                        OR UserOrGroupId =: execMember2.Id)];
        //VERIFY THERE THE LIST CONTAINS 2 RECORDS 
        System.assertEquals(2,lstJobShare.size());
        
        //GET THE VALUE OF THE HAS ATTACHMENT FIELD ON THE JOB REQUISITION RECORD
        NI_Job_Requisition__c updatedJR = [SELECT Id,Has_Attachment__c FROM NI_Job_Requisition__c
                                           WHERE id =: j.Id];
        
        //VERIFY THE HAS ATTACHMENT FIELD HAS BEEN SET TO TRUE
        System.assertEquals(updatedJR.Has_Attachment__c, true);
        
        //==========================================TEST REMOVE USER LOGIC=================================================================  
        
        system.runAs(owner)
        {
            NI_Job_Requisition__c j2 = NI_TestClassData.createTestNI_Job_Requisition(1,owner.Id,rtIdRemoveUser);
            j2.Employee_to_Disable__c = uDisable.Id;
            j2.Employee_Disable_Date__c = datetime.now();
            insert j2;
        }
        //GET THE INSERTED JOB REQUISITION RECORD
        NI_Job_Requisition__c insertedJR2 = [SELECT Id, Employee_to_Disable__c,Employee_Disable_Date__c 
                                             FROM NI_Job_Requisition__c
                                             WHERE RecordTypeId =: rtIdRemoveUser];
        
        //GET THE VALUE OF THE EXPIRATION DATE OF THE USER TO DISABLE ON THE JOB REQUISITION RECORD
        User updatedUser = [SELECT Id, Name, Expiration_Date__c FROM User
                            WHERE Id =: uDisable.Id];
        
        
        //VERIFY THE EXPIRATION DATE OF THE USER HAS BEEN SET TO THE EMPLOYEE DISABLE DATE OF THE JOB REQUISITION
        System.assertEquals(updatedUser.Expiration_Date__c,  insertedJR2.Employee_Disable_Date__c);        
    }
    
}