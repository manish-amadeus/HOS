/************************************************************************************************
Name            : OrgInfoBatch - Batch Class
Author          : Michael Pedro
Last Mod Date   : 05/05/2022
Last Mod By     : Michael Pedro
Description     : Master detail batch class for org search
*************************************************************************************************/

global class OrgInfoBatch implements Database.Batchable<NI_Org_Details__c>, Database.AllowsCallouts 
{   
    global OrgQueryInfo OrgQueryInfo;
    global Boolean isTest { get; set; } 
    private string[] ids { get; set;} 
      
    global OrgInfoBatch(string[] ids) 
    {
        isTest = false;
        this.ids = ids;
            
    }
   
    
    
    global NI_Org_Details__c[] start(Database.BatchableContext bc) 
    {    
        OrgSecurityLog__c securityLog = new OrgSecurityLog__c (
            Source__c = 'ASEM Polling',
            EventType__c = 'Logging Event', // Category of event
            Severity__c = 'Warning', // Security level of event
            Description__c = 'Polling Search Initiated', // High level description
            Details__c = String.format(
                'User ID: {0} ',new List<String>{UserInfo.getUserId()}) + 
                String.format(
                'Org ID: {0}', this.ids)
            );

            OrgSecurityLogCls.EnableSecurityLogCreation = true;        
            insert securityLog;
            OrgSecurityLogCls.EnableSecurityLogCreation = false;
              
        String OrgDetailQueryString = 'SELECT Id, Template__r.Name, Internal_Org__c, Org_Status__c, Primary_Account_Owner__r.Name, Annual_Salesforce_Renewal_Date__c, Salesforce_Instance__c, '+
                                    'Name, Org_ID__c, Org_Type__c, Org_Name__c,Admin_Login_Name_Encrypted__C, Admin_Password_Encrypted__c, Security_Token_Encrypted__c '+
                                    'From NI_Org_Details__c WHERE Org_ID__c != null AND Inactive__c = False AND Org_Type__c LIKE :orgType AND Org_Status__c NOT IN :inactive AND RecordTypeId = :recordTypeId';
        List<NI_Org_Details__c> orgDetailRecords = Data.read( OrgDetailQueryString, 
                                                                new Map<String, Object>{
                                                                    'orgType' => 'Salesforce Production', 
                                                                    'inactive' => new List<String>{'Cancelled','Not Active'}, 
                                                                    'recordTypeId' => '01260000000DnbPAAS'
                                                                });
        
                                                                return orgDetailRecords;
        
        
    }

    global void execute(Database.BatchableContext bc, List<NI_Org_Details__c> allOrgDetails) 
    {
        // batches will run one record at a time     
        NI_Org_Details__c orgForSearch = allOrgDetails[0];   
        OrgSearchCls search = new OrgSearchCls();
        search.orgDetail = orgForSearch;
      
        if (!isTest) {
            search.queryOrg();
            this.orgQueryInfo = search.getBatchQueryInfo();
        }
        if (this.OrgQueryInfo.OrgInfoResult != null) {

            Map<String, Object> queryArgs = new Map<String, Object>{
                'ahOrgId' => search.OrgInfoResult.AHOrgId__c, 
                'ahOrgName' => search.OrgInfoResult.AHOrgName__c
            };

            string orgInfoQuery = 'SELECT Id FROM OrgInfo__c WHERE AHOrgId__c = :ahOrgId AND AHOrgName__c = :ahOrgName';
            List<sObject> existingRecords = Data.read(orgInfoQuery, queryArgs);
            if (existingRecords != null && existingRecords.size() > 0) {
                Data.remove(existingRecords);
            }

            OrgInfo__c oi = this.OrgQueryInfo.OrgInfoResult;
            Data.create(oi);
    
            // Upsert of installed packages in org 
            if (this.OrgQueryInfo.OrgPackageResult != null) {
                List<OrgPackage__c> packagesForUpsert = new List<OrgPackage__c>();
                for (sObject packageInfo :this.OrgQueryInfo.OrgPackageResult) {
                    OrgPackage__c nextPackage = (OrgPackage__c)packageInfo;
                    nextPackage.OrgInfo__c = this.OrgQueryInfo.OrgInfoResult.Id;
                    packagesForUpsert.add(nextPackage);
                }
                OrgNi.insertWithRetry(packagesForUpsert,3);
            }

            if (this.OrgQueryInfo.OrgPropertyResult != null) {
                List<OrgProperty__c> propsForUpsert = new List<OrgProperty__c>();
                for (OrgProperty__c p :this.OrgQueryInfo.OrgPropertyResult) {
                    p.OrgInfo__c = this.OrgQueryInfo.OrgInfoResult.Id;
                    propsForUpsert.add(p);
                }
                OrgNi.insertWithRetry(propsForUpsert,3);
            }

            if (this.OrgQueryInfo.orgPropertyIntegrationSettingResult != null) {
                List<OrgPropertyIntegrationSetting__c> propertyIntForUpsert = new List<OrgPropertyIntegrationSetting__c>();
                for (OrgPropertyIntegrationSetting__c pi :this.OrgQueryInfo.orgPropertyIntegrationSettingResult) {
                    pi.OrgInfo__c = this.OrgQueryInfo.OrgInfoResult.Id;
                    propertyIntForUpsert.add(pi);
                }
                OrgNi.insertWithRetry(propertyIntForUpsert,3);
            }

            if (this.OrgQueryInfo.OrgSetupValueResult != null) {
                List<OrgSetupValue__c> svs = new List<OrgSetupValue__c>();
                for (OrgSetupValue__c sv :this.OrgQueryInfo.OrgSetupValueResult) {
                    sv.OrgInfo__c = this.OrgQueryInfo.OrgInfoResult.Id;
                    svs.add(sv);
                }
                OrgNi.insertWithRetry(svs,3);
            }

            // upsert all users with asem profiles
            if (this.OrgQueryInfo.OrgUserResult != null) {
                List<OrgUser__c> usersForUpsert = new List<OrgUser__c>();
                for (OrgUser__c u :this.OrgQueryInfo.OrgUserResult) {
                    u.OrgInfo__c = this.OrgQueryInfo.OrgInfoResult.Id;
                    usersForUpsert.add(u);
                }
                OrgNi.insertWithRetry(usersForUpsert,3);
            }

            // Upsert profiles 
            if (this.OrgQueryInfo.OrgProfileResult != null) {
                List<OrgProfile__c> profilesForUpsert = new List<OrgProfile__c>();
                for (OrgProfile__c p :this.OrgQueryInfo.OrgprofileResult) {
                    p.OrgInfo__c = this.OrgQueryInfo.OrgInfoResult.Id;
                    profilesForUpsert.add(p);
                }
                OrgNi.insertWithRetry(profilesForUpsert,3);
            }
    
            // upsert of NIHRM processors 
            if (this.OrgQueryInfo.OrgProcessorResult != null) {
                List<OrgProcessor__c> processorsForUpsert = new List<OrgProcessor__c>();
                for (sObject processorInfo :this.OrgQueryInfo.OrgProcessorResult) {
                    OrgProcessor__c nextProcessor = (OrgProcessor__c)processorInfo;
                    nextProcessor.OrgInfo__c = this.OrgQueryInfo.OrgInfoResult.Id;
                    processorsForUpsert.add(nextProcessor);
                }
                OrgNi.insertWithRetry(processorsForUpsert,3);
            }
    
            // upsert Salesforce licenses
            if (this.OrgQueryInfo.OrgLicenseResult != null) {
                List<OrgLicense__c> licensesForUpsert = new List<OrgLicense__c>();
                for (sObject licenseInfo :this.OrgQueryInfo.OrgLicenseResult) {
                    OrgLicense__c nextLicense = (OrgLicense__c)licenseInfo;
                    nextLicense.OrgInfo__c = this.OrgQueryInfo.OrgInfoResult.Id;
                    licensesForUpsert.add(nextLicense);
                }
                OrgNi.insertWithRetry(licensesForUpsert,3);
            }

            // upsert of org limits - 4 records max: DataStorageMB, FileStorageMB, DailyApiRequests, HourlyTimeBasedWorkflow
            if (this.OrgQueryInfo.OrgLimitResult != null) {
                List<OrgLimit__c> limitsForUpsert = new List<OrgLimit__c>();
                for (sObject limitInfo :this.OrgQueryInfo.OrgLimitResult) {
                    OrgLimit__c nextLimit = (OrgLimit__c)limitInfo;
                    nextLimit.OrgInfo__c = this.OrgQueryInfo.OrgInfoResult.Id;
                    limitsForUpsert.add(nextLimit);
                }
                OrgNi.insertWithRetry(limitsForUpsert,3);
            }

            //upsert system info
            if (this.OrgQueryInfo.OrgSystemResult != null) {
                List<OrgSystem__c> SysForInsert = new List<OrgSystem__c>();
                for (sObject sysInfo :this.OrgQueryInfo.OrgSystemResult) {
                    OrgSystem__c nextSystem = (OrgSystem__c)sysInfo;
                    nextSystem.OrgInfo__c = this.OrgQueryInfo.OrgInfoResult.Id;
                    SysForInsert.add(nextSystem);
                }
                OrgNi.insertWithRetry(SysForInsert,3);
            }

            //upsert report count
            if (this.OrgQueryInfo.OrgReportCountResult != null) {
                List<OrgReportCount__c> rCounts = new List<OrgReportCount__c>();
                for (sObject rCount: this.OrgQueryInfo.OrgReportCountResult) {
                    OrgReportCount__c report = (OrgReportCount__c)rCount;
                    report.OrgInfo__c = this.OrgQueryInfo.OrgInfoResult.Id;
                    rCounts.add(report);
                }
                OrgNi.insertWithRetry(rCounts,3);
            }

            // upsert sandboxes
            if (this.OrgQueryInfo.OrgSandboxResult != null) {
                List<OrgSandbox__c> SBForUpsert = new List<OrgSandbox__c>();
                for (sObject sbInfo :this.OrgQueryInfo.OrgSandboxResult) {
                    OrgSandbox__c nextSB = (OrgSandbox__c)sbInfo;
                    nextSB.OrgInfo__c = this.OrgQueryInfo.OrgInfoResult.Id;
                    SBForUpsert.add(nextSB);
                }
            OrgNi.insertWithRetry(SBForUpsert,3);
            }
    
            //upsert ValidationRule
            // if (this.OrgQueryInfo.OrgValidationRuleResult != null) {
            //     List<OrgValidationRule__c> validationRules = new List<OrgValidationRule__c>();
            //     for (sObject vr: this.OrgQueryInfo.OrgValidationRuleResult) {
            //         OrgValidationRule__c validationRule = (OrgValidationRule__c)vr;
            //         validationRule.OrgInfo__c = this.OrgQueryInfo.OrgInfoResult.Id;
            //         validationRules.add(validationRule);
            //     }
            //     OrgNi.insertWithRetry(validationRules,3);
            // }

            //upsert Workflow
            // if (this.OrgQueryInfo.OrgWorkflowResult != null) {
            //     List<OrgWorkflow__c> workflows = new List<OrgWorkflow__c>();
            //     for (sObject wf: this.OrgQueryInfo.OrgWorkflowResult) {
            //         OrgWorkflow__c workflow = (OrgWorkflow__c)wf;
            //         workflow.OrgInfo__c = this.OrgQueryInfo.OrgInfoResult.Id;
            //         workflows.add(workflow);
            //     }
            //     OrgNi.insertWithRetry(workflows,3);
            // }

            //upsert process
            // if (this.OrgQueryInfo.OrgProcessResult != null) {
            //     List<OrgProcess__c> processes = new List<OrgProcess__c>();
            //     for (sObject proc: this.OrgQueryInfo.OrgProcessResult) {
            //         OrgProcess__c process = (OrgProcess__c)proc;
            //         process.OrgInfo__c = this.OrgQueryInfo.OrgInfoResult.Id;
            //         processes.add(process);
            //     }
            //     OrgNi.insertWithRetry(processes,3);
            // }

        }
       
    }
    
    global void finish(Database.BatchableContext bc)
    {
        system.debug('org search batch finished');
    }

    global class OrgQueryInfo {
        global OrgInfo__c OrgInfoResult {get; set;}
        global List<OrgLimit__c> OrgLimitResult {get; set;}
        global List<OrgPackage__c> OrgPackageResult {get; set;}
        global List<OrgSandbox__c> OrgSandboxResult {get; set;}
        global List<OrgProcessor__c> OrgProcessorResult {get; set;}
        global List<OrgLicense__c> OrgLicenseResult {get; set;}
        global List<OrgUser__c> OrgUserResult {get; set;}
        global List<OrgProfile__c> OrgProfileResult {get; set;}
        global List<OrgProperty__c> OrgPropertyResult {get; set;}
        global List<OrgPropertyIntegrationSetting__c> orgPropertyIntegrationSettingResult {get; set;}
        global List<OrgSystem__c> OrgSystemResult {get; set;}
        global List<OrgReportCount__c> OrgReportCountResult {get; set;}
        global List<OrgSetupValue__c> OrgSetupValueResult {get; set;}

        // global List<OrgPropMenuItemCount__c> OrgPropertyMenuItemCountsResult {get;set;}
        // global List<OrgPropDocTemplateCount__c> OrgPropDocumentTemplateResult {get; set;}

        // global List<OrgValidationRule__c> OrgValidationRuleResult {get; set;}
        // global List<OrgWorkflow__c> OrgWorkflowResult {get; set;}
        // global List<OrgApexClass__c> OrgApexClassResult {get; set;}
        // global List<OrgApexTrigger__c> OrgApexTriggerResult {get; set;}
        // global List<OrgApprovalProcess__c> OrgApprovalProcessResult {get; set;}
        // global List<OrgCustomObject__c> OrgCustomObjectResult {get; set;}
        // global List<OrgCustomTab__c> OrgCustomTabResult {get; set;}
        // global List<OrgProcess__c> OrgProcessResult {get; set;}
        // global List<OrgCustomField__c> OrgCustomFieldResult {get; set;}
    }
    
}