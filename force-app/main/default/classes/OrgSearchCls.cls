/************************************************************************************************
Name            : OrgSearchCls
Author          : Michael Pedro
Last Mod Date   : 05/05/2022
Last Mod By     : Michael Pedro
Description     : Runs org search for available Org Detail records
*************************************************************************************************/

public with sharing class OrgSearchCls {
    public OrgInfo__c OrgInfoResult {get; set;}
    public List<OrgLimit__c> OrgLimitResult {get; set;}
    public List<OrgPackage__c> OrgPackageResult {get; set;}
    public List<OrgSandbox__c> OrgSandboxResult {get; set;}
    public List<OrgProcessor__c> OrgProcessorResult {get; set;}
    public List<OrgProperty__c> OrgPropertyResult {get; set;}
    public List<OrgLicense__c> OrgLicenseResult {get; set;}
    public List<OrgUser__c> OrgUserResult {get; set;}
    public List<OrgProfile__c> OrgProfileResult {get; set;}
    public List<OrgPropertyIntegrationSetting__c> orgPropertyIntegrationSettingResult {get; set;}
    public List<OrgPropMenuItemCount__c> OrgPropMenuItemCountResult {get;set;}
    public List<OrgReportCount__c> OrgReportCountResult {get; set;}
    public List<OrgSetupValue__c> OrgSetupValueResult {get; set;}
    public List<OrgSystem__c> OrgSystemResult {get; set;}
    public List<OrgValidationRule__c> OrgValidationRuleResult {get; set;}
    public List<OrgWorkFlow__c> OrgWorkFlowResult {get; set;}
    public List<OrgPropDocTemplateCount__c> OrgPropDocumentTemplateResult {get; set;}
    public List<OrgApexClass__c> OrgApexClassResult {get; set;}
    public List<OrgApexTrigger__c> OrgApexTriggerResult {get; set;}
    public List<OrgApprovalProcess__c> OrgApprovalProcessResult {get; set;}
    public List<OrgCustomObject__c> OrgCustomObjectResult {get; set;}
    public List<OrgCustomTab__c> OrgCustomTabResult {get; set;}
    public List<OrgProcess__c> OrgProcessResult {get; set;}    
    public List<OrgCustomField__c> OrgCustomFieldResult {get; set;}


    public NI_Org_Details__c orgDetail {get; set;}

    private static final String API_VERSION = 'v54.0';
    private static final String SOQL_ENDPOINT = '/services/data/' + API_VERSION + '/query/?q=';
    private static final String TOOLING_ENDPOINT = '/services/data/' + API_VERSION + '/tooling/query/?q=';
    private static final string AUTH_ENDPOINT = 'https://login.salesforce.com/services/Soap/u/54.0';
    private static final string SB_AUTH_ENDPOINT = 'https://test.salesforce.com/services/Soap/u/54.0';
    private String orgId {get; set;}  
    private String orgLocale {get; set;}  
    private String userId {get; set;}
    private String sessionId { get; set; } 
    public Integer orgVersion {get; set;}
    public string domain {get; set;}

    
    public OrgSearchCls() {}

    public void queryOrg() {
        // login to org via soap api
        boolean credentialsAuthorized = authorizeOrgCredentials();
        // attempt callout to api endpoint
        boolean endpointAuthorized = getOrgInfo();
        if (credentialsAuthorized && endpointAuthorized) {
            // query all org data
            getPackageInfo();
            getPropertyInfo();
            getUserInfo();
            getSupportUser();
            getCustomSettingInfo();
            getOrgLimitInfo();
            getLogCountInfo();
            getByPassInfo();
            getSCPicklistInfo();
            getAccountInfo();
            getContactInfo();
            getOrgLoginInfo();
            getIsPermCountInfo();
            getLicenseInfo();
            getProcessorInfo();
            getPropertyIntegrationInfo();
            getProfileInfo();
            getPropMenuItemCounts();
            getPropDocTemplateCounts();
            getSystemInfo();
            getReportCountInfo();
            getSetupValueInfo();
            getValidationRuleInfo();
            getWorkFlowInfo();
            getApprovalProcessInfo();
            getCustomObjectInfo();
            getCustomTabInfo();
            getProcessInfo();
            getApexClassInfo();
            getCustomFieldInfo();
            getApexTriggerInfo();
            getSandboxInfo();
        }
    }

    public boolean getOrgInfo() {
        try {
            String OrgInfoQuery = constructQueryParams('SELECT Id, Name, InstanceName, DefaultAccountAccess, CreatedDate, LastModifiedDate FROM Organization', null);
            HttpResponse queryResults = getQueryResponse(OrgInfoQuery, SOQL_ENDPOINT);
            OrgSearchDataStructuresCls.OrganizationInfo oi = (OrgSearchDataStructuresCls.OrganizationInfo)Json.Deserialize(queryResults.getBody(), OrgSearchDataStructuresCls.OrganizationInfo.class);
            if (oi != null && oi.records != null) {
                for (OrgSearchDataStructuresCls.OrgInfoRecord record :oi.records) {
                    OrgInfo__c orgInfo = record.createSFObject();
                    orgInfo.AHName__c = orgDetail.Name;
                    orgInfo.AHOrgName__c = orgDetail.Org_Name__c;
                    orgInfo.AHOrgDetailsID__c = orgDetail.Id;
                    orgInfo.AHOrgId__c = orgDetail.Org_ID__c;
                    orgInfo.AHOrgStatus__c = orgDetail.Org_Status__c;
                    orgInfo.AHPrimaryAccountOwner__c = orgDetail.Primary_Account_Owner__r.Name;
                    orgInfo.AHRenewalDate__c = orgDetail.Annual_Salesforce_Renewal_Date__c;
                    orgInfo.AHTemplateName__c = orgDetail.Template__r.Name;
                    orgInfo.InternalOrg__c = orgDetail.Internal_Org__c;
                    OrgInfoResult = orgInfo;
                }
            }
            return true;
        } catch (Exception ex) {
           setOrgInfoError(ex);
           return ex.getMessage().containsIgnoreCase('unauthorized endpoint') ? false : true;
       } 
    }

    public void getIsPermCountInfo() {
        try {
            List<string> whereConditions = new List<string> {
                'SObjectType=' + '\''+ 'nihrm__FunctionRoom__c' + '\'',
                'ParentId IN ( SELECT Id FROM PermissionSet WHERE Label LIKE ' + '\''+ '%25Integration User%25' + '\''+' AND NamespacePrefix='+ '\''+ 'nihrm' + '\''+' )'
            };
            string permCountQuery = constructQueryParams('SELECT PermissionsRead FROM ObjectPermissions', whereConditions);
            HttpResponse queryResults = getQueryResponse(permCountQuery, SOQL_ENDPOINT);
            OrgSearchDataStructuresCls.PermCountInfo permCount = (OrgSearchDataStructuresCls.PermCountInfo)Json.Deserialize(queryResults.getBody(), OrgSearchDataStructuresCls.PermCountInfo.class);
            if (permCount != null && permCount.records != null && OrgInfoResult != null) {
                OrgInfoResult.IsPermCount__c = permCount.records.size();
            }
        } catch (Exception ex) {
            setOrgInfoError(ex);
        } 
    }

    public void getCustomSettingInfo() {
        try {
            List<string> whereConditions = new List<string> {
                'NOT NAME LIKE ' + '\''+ '%25(User)%25' + '\''
            };

            String customSettingQueryString = 'SELECT nihrm__EnableAccountSecurity__c';
            if (orgVersion == 30) {
                customSettingQueryString += ', nihrm__AllowLimitedService__c';
            } 
            if (orgVersion > 30) {
                customSettingQueryString += ', nihrm__AllowLimitedService__c, nihrm__UseCanvasReporting__c';
            }
            if (orgVersion >= 48) {
                customSettingQueryString += ', nihrm__EnableNewGuestRoomExperience__c';
            }
            customSettingQueryString += ' FROM nihrm__NiPublic__c';
            string customSettingQuery = constructQueryParams(customSettingQueryString, whereConditions);
            HttpResponse queryResults = getQueryResponse(customSettingQuery, SOQL_ENDPOINT);
            OrgSearchDataStructuresCls.NIPublicInfo customSettingInfo = (OrgSearchDataStructuresCls.NIPublicInfo)Json.Deserialize(removeSFCharacters(queryResults.getBody()), OrgSearchDataStructuresCls.NIPublicInfo.class);
            if (customSettingInfo != null && customSettingInfo.records != null && OrgInfoResult != null) {
                for ( OrgSearchDataStructuresCls.NIPublicRecord record :customSettingInfo.records) {
                    OrgInfoResult.AllowLimitedService__c = record.AllowLimitedService != null ? record.AllowLimitedService : false;
                    OrgInfoResult.UseCanvasReporting__c = record.UseCanvasReporting != null ? record.UseCanvasReporting : false;
                    OrgInfoResult.EnableAccountSecurity__c = record.EnableAccountSecurity != null ? record.EnableAccountSecurity : false;
                    OrgInfoResult.EnableNewGuestRoomExperience__c = record.EnableNewGuestRoomExperience != null ? record.EnableNewGuestRoomExperience : false;
                }
            }
        } catch (Exception ex) {
            setOrgInfoError(ex);
        } 
    }

    public void getByPassInfo() {
        try {
            List<string> whereConditions = new List<string> {
                'EntityDefinition.QualifiedApiName=' + '\''+ 'User' + '\'',
                'QualifiedApiName=' + '\''+ 'nisc_Bypass_Rules_for_Migrations__c' + '\''
            };
            string fieldDefQuery = constructQueryParams('SELECT QualifiedApiName FROM FieldDefinition', whereConditions);
            HttpResponse queryResults = getQueryResponse(fieldDefQuery, SOQL_ENDPOINT);
            OrgSearchDataStructuresCls.ByPassRuleInfo byPassInfo = (OrgSearchDataStructuresCls.ByPassRuleInfo)Json.Deserialize(queryResults.getBody(), OrgSearchDataStructuresCls.ByPassRuleInfo.class);
            if (byPassInfo != null && byPassInfo.records != null && OrgInfoResult != null) {
                OrgInfoResult.ByPassRules__c = byPassInfo.records.size() > 0 ? true : false;
            }
        } catch (Exception ex) {
            setOrgInfoError(ex);
        } 
    }

    public void getLogCountInfo() {
        try {
            string baseQuery = 'SELECT count(Id) FROM ';
            Map<string, Integer> logTypeValueMap = new Map<string, Integer> {
                'nihrm__ProcessorJob__c' => null, 
                'nihrm__Log__c' => null, 
                'nihrm__Message__c' => null
            };
            // send query for each log count type and save value in map
            for(string logType: logTypeValueMap.keySet()) {
                string logCountQuery = constructQueryParams(baseQuery + logType, null);
                HttpResponse queryResults = getQueryResponse(logCountQuery, SOQL_ENDPOINT);
                OrgSearchDataStructuresCls.LogCountInfo logCount = (OrgSearchDataStructuresCls.LogCountInfo)Json.Deserialize(queryResults.getBody(), OrgSearchDataStructuresCls.LogCountInfo.class);
                if (logCount != null && logCount.records != null) {
                    for (OrgSearchDataStructuresCls.LogCountRecord record :logCount.records) {
                        if (record.expr0 != null) {
                            logTypeValueMap.put(logType, record.expr0);
                        }
                    }
                }
            }
            if (OrgInfoResult != null) {
                OrgInfoResult.ProcessorLogCount__c = logTypeValueMap.get('nihrm__ProcessorJob__c');
                OrgInfoResult.LogCount__c = logTypeValueMap.get('nihrm__ProcessorJob__c');
                OrgInfoResult.MessageLogCount__c = logTypeValueMap.get('nihrm__Message__c');
            }
        } catch (Exception ex) {
            setOrgInfoError(ex);
        } 
    }

    public void getOrgLimitInfo() {
        List<OrgLimit__c> foundLimits = new List<OrgLimit__c>();
        Httprequest request = new HttpRequest();
        HttpResponse result = new HttpResponse();
        string reqURL = domain + 'salesforce.com/services/data/' + API_VERSION + '/limits';
        Http http = new Http();
        request.setMethod('GET');
        request.setEndpoint(reqURL);
        request.setHeader('Content-Type', 'application/json');
        request.setHeader('Accept', 'application/json');
        request.setHeader('Authorization', 'Bearer ' + sessionId);
    
        try {
            result = http.send(request);
            Map<String, OrgSearchDataStructuresCls.OrgLimitRecord> limits = (Map<String, OrgSearchDataStructuresCls.OrgLimitRecord>) JSON.Deserialize(result.getBody(), Map<String,OrgSearchDataStructuresCls.OrgLimitRecord>.class);
            if (limits != null && limits.size() > 0) {
               if (limits.get('DataStorageMB') != null) {
                OrgSearchDataStructuresCls.OrgLimitRecord l = limits.get('DataStorageMB');
                OrgLimit__c orgLimit = l.createSFObject();
                orgLimit.LimitName__c = 'DataStorageMB';
                foundLimits.add(orgLimit);
               }
               if (limits.get('FileStorageMB') != null) {
                OrgSearchDataStructuresCls.OrgLimitRecord l = limits.get('FileStorageMB');
                OrgLimit__c orgLimit = l.createSFObject();
                orgLimit.LimitName__c = 'FileStorageMB';
                foundLimits.add(orgLimit);
               }
               if (limits.get('DailyApiRequests') != null) {
                OrgSearchDataStructuresCls.OrgLimitRecord l = limits.get('DailyApiRequests');
                OrgLimit__c orgLimit = l.createSFObject();
                orgLimit.LimitName__c = 'DailyApiRequests';
                foundLimits.add(orgLimit);
               }
               if (limits.get('HourlyTimeBasedWorkflow') != null) {
                OrgSearchDataStructuresCls.OrgLimitRecord l = limits.get('HourlyTimeBasedWorkflow');
                OrgLimit__c orgLimit = l.createSFObject();
                orgLimit.LimitName__c = 'HourlyTimeBasedWorkflow';
                foundLimits.add(orgLimit);
               }
            }
            if (foundLimits.size() > 0) {
                OrgLimitResult = foundLimits;
            }
        } catch(Exception e) {
            System.debug('Error on Limit Request: '+e.getlinenumber()+'\n\n'+e.getMessage());
            setOrgInfoError(e);
        }
    }

    public void getProcessorInfo() {
        try {
            Map<String, OrgProcessor__c> orgProcessorMap = new Map<string, OrgProcessor__c>();
            List<string> processorWhereConditions = new List<string> {
                'Name LIKE ' + '\''+ '%25NWS%25' + '\''
            };
            String orgProcessorQuery = constructQueryParams('SELECT Id, Name, nihrm__NextJobStart__c FROM nihrm__Processor__c', processorWhereConditions);
            HttpResponse queryResults = getQueryResponse(orgProcessorQuery, SOQL_ENDPOINT);
            OrgSearchDataStructuresCls.OrgProcessorInfo processorInfo = (OrgSearchDataStructuresCls.OrgProcessorInfo)Json.Deserialize(removeSFCharacters(queryResults.getBody()), OrgSearchDataStructuresCls.OrgProcessorInfo.class);
            if (processorInfo != null && processorInfo.records != null) {
                for (OrgSearchDataStructuresCls.OrgProcessorRecord record :processorInfo.records) {
                OrgProcessor__c op = record.createSFObject();
                orgProcessorMap.put(op.ProcessorId__c, op);
                }
                List<string> jobWhereConditions = new List<string> {
                    'nihrm__Processor__r.name LIKE ' + '\''+ '%25NWS%25' + '\''
                };
                string processorJobGroupBy = ' GROUP By nihrm__Processor__c, nihrm__Status__c';
                String OrgProcessorJobQuery = constructQueryParams('SELECT nihrm__Processor__c, max(nihrm__StartDate__c), nihrm__Status__c FROM nihrm__ProcessorJob__c', jobWhereConditions);
                OrgProcessorJobQuery += processorJobGroupBy.replace(' ', '+');
                HttpResponse jobQueryResults = getQueryResponse(OrgProcessorJobQuery, SOQL_ENDPOINT);
                OrgSearchDataStructuresCls.OrgProcessorJobInfo processorJobInfo = (OrgSearchDataStructuresCls.OrgProcessorJobInfo)Json.Deserialize(removeSFCharacters(jobQueryResults.getBody()), OrgSearchDataStructuresCls.OrgProcessorJobInfo.class);
                if (processorJobInfo != null && processorJobInfo.records != null) {
                    for (OrgSearchDataStructuresCls.OrgProcessorJobRecord record :processorJobInfo.records) {
                    if (orgProcessorMap.get(record.Processor) != null) {
                            OrgProcessor__c processor = orgProcessorMap.get(record.Processor);
                            if ((processor.ProcessorStatus__c == null && processor.MaxStartTime__c == null) || (processor.MaxStartTime__c < record.expr0)) {
                                processor.ProcessorStatus__c = record.Status;
                                processor.MaxStartTime__c = record.expr0;
                                orgProcessorMap.put(record.Processor, processor);
                            } 
                    }
                    }
                }
                if (orgProcessorMap.size() > 0) {
                    OrgProcessorResult = orgProcessorMap.values();
                }
            }
        } catch (Exception ex) {
            setOrgInfoError(ex);
        } 
    }

    public void getPackageInfo() {
        try {
            List<OrgPackage__c> orgPackageList = new List<OrgPackage__c>();
            List<string> expectedNamespacePrefixList = new List<string> {'sf_chttr_apps','sf_com_apps','sfadminapps'};        
            String OrgPackageQuery = constructQueryParams('SELECT Id, SubscriberPackageId, SubscriberPackage.NamespacePrefix, SubscriberPackage.Name, SubscriberPackageVersion.Id, SubscriberPackageVersion.IsManaged, SubscriberPackageVersion.Name, SubscriberPackageVersion.MajorVersion, SubscriberPackageVersion.MinorVersion, SubscriberPackageVersion.PatchVersion, SubscriberPackageVersion.BuildNumber FROM InstalledSubscriberPackage', null);
            HttpResponse queryResults = getQueryResponse(OrgPackageQuery, TOOLING_ENDPOINT);
            OrgSearchDataStructuresCls.OrgPackageInfo packageInfo = (OrgSearchDataStructuresCls.OrgPackageInfo)Json.Deserialize(queryResults.getBody(), OrgSearchDataStructuresCls.OrgPackageInfo.class);
            if (packageInfo != null && packageInfo.records != null) {
                for (OrgSearchDataStructuresCls.OrgPackageRecord record :packageInfo.records) {
                    if (record.SubscriberPackage != null && 
                        record.SubscriberPackageVersion != null &&
                        !expectedNamespacePrefixList.contains(record.SubscriberPackage.NamespacePrefix)
                        ) {
                            OrgPackage__c orgPackage = record.SubscriberPackage.createSFObject();
                            orgPackage = record.SubscriberPackageVersion.updatePackageInfo(orgPackage);
                            orgPackageList.add(orgPackage);

                            if (record.SubscriberPackageVersion.Name.contains('Sales & Event Management') && OrgInfoResult != null) {
                                OrgInfoResult.MajorVersion__c = record.SubscriberPackageVersion.Name;
                                if (orgVersion == null) {
                                    orgVersion = setOrgVersion(record.SubscriberPackageVersion.Name);
                                }
                            }
                    }
                }
                if (orgPackageList.size() > 0) {
                    orgPackageResult = orgPackageList;
                }
            }
        } catch (Exception ex) {
            setOrgInfoError(ex);
        } 
    }

    public void getLicenseInfo() {
        try {
            List<OrgLicense__c> orgLicenseList = new List<OrgLicense__c>();
            String orgLicenseQuery = constructQueryParams('SELECT Name, Status, TotalLicenses, UsedLicenses FROM Userlicense', null);
            HttpResponse queryResults = getQueryResponse(orgLicenseQuery, SOQL_ENDPOINT);
            OrgSearchDataStructuresCls.OrgLicenseInfo licenseInfo = (OrgSearchDataStructuresCls.OrgLicenseInfo)Json.Deserialize(queryResults.getBody(), OrgSearchDataStructuresCls.OrgLicenseInfo.class);
            if (licenseInfo != null && licenseInfo.records != null) {
                for ( OrgSearchDataStructuresCls.OrgLicenseRecord record :licenseInfo.records) {
                    OrgLicense__c orgLicense = record.createSFObject();
                    orgLicenseList.add(orgLicense);
                }
                if (orgLicenseList.size() > 0) {
                    OrgLicenseResult = orgLicenseList;
                }
            }
        } catch (Exception ex) {
            setOrgInfoError(ex);
        } 
    }

    public void getSCPicklistInfo() {
        try {
            String scQuery = constructQueryParams('SELECT BillingStateCode FROM Account', null);
            Httprequest request = new HttpRequest();
            HttpResponse queryResults = new HttpResponse();
            string reqURL = domain + 'salesforce.com' + SOQL_ENDPOINT + scQuery;
            Http http = new Http();
            request.setMethod('GET');
            request.setEndpoint(reqURL);
            request.setHeader('Content-Type', 'application/json');
            request.setHeader('Accept', 'application/json');
            request.setHeader('Authorization', 'Bearer ' + sessionId);
            queryResults = http.send(request);
            if (queryResults.getStatusCode() == 200 && OrgInfoResult != null) {
                OrgInfoResult.SCPicklistEnabled__c = true;
            } else {
                OrgInfoResult.SCPicklistEnabled__c = false;
            }
        } catch (Exception ex) {
            setOrgInfoError(ex);
        } 
    }

    public void getPropertyInfo() {
        try {
            Map<String, OrgProperty__c> orgPropertyMap = new Map<String, OrgProperty__c>();
            
            // set query string based on org release version
            String propertyQueryString = 'SELECT Id, Name, nihrm__IsActive__c, nihrm__Abbreviation__c, nihrm__PropertyKey__c, CreatedDate, CreatedBy.Name, LastModifiedDate, LastModifiedBy.Name, nihrm__AvailabilityScreenView__c, nihrm__AddressLine1__c, nihrm__AddressLine2__c, nihrm__AddressLine3__c, nihrm__City__c, nihrm__StateProvince__c, nihrm__CountryCode__c, nihrm__PostalCode__c, nihrm__Phone__c, nihrm__PropertyCode__c';
            if (orgVersion >= 6) {
                propertyQueryString += ', nihrm__DisableBookingDaySnapshot__c';
            } 
            if (orgVersion >= 22) {
                propertyQueryString += ', nihrm__NIHRMMigrations_ExternalID__c, nihrm__EnableHospitalityDiagramming__c';
            }
            if (orgVersion > 30) {
                propertyQueryString += ', nihrm__IsLimitedService__c';
            }   
            if (orgVersion >= 40) {
                propertyQueryString += ', nihrm__ExtractedDate__c';
            }
            propertyQueryString += ' FROM nihrm__Location__c';

            string orgPropertyQuery = constructQueryParams(propertyQueryString, null);
            HttpResponse queryResults = getQueryResponse(orgPropertyQuery, SOQL_ENDPOINT);
            OrgSearchDataStructuresCls.OrgPropertyInfo propertyInfo = (OrgSearchDataStructuresCls.OrgPropertyInfo)Json.Deserialize(removeSFCharacters(queryResults.getBody()), OrgSearchDataStructuresCls.OrgPropertyInfo.class);
            if (propertyInfo != null && propertyInfo.records != null) {
                for (OrgSearchDataStructuresCls.OrgPropertyRecord record :propertyInfo.records) {
                        OrgProperty__c orgProperty = record.createSFObject();
                        orgPropertyMap.put(orgProperty.PropertyId__c, orgProperty);
                }

                // Add number of users to org property records
                List<string> niPublicWhereConditions = new List<string> {
                    'NOT nihrm__DefaultLocationId__c=' + '\''+ '' + '\''
                };
                string niPublicGroupBy = ' GROUP By nihrm__DefaultLocationId__c';
                String niPublicQuery = constructQueryParams('SELECT count(Id), nihrm__DefaultLocationId__c FROM nihrm__NiPublic__c', niPublicWhereConditions);
                niPublicQuery += niPublicGroupBy.replace(' ', '+');
                HttpResponse niPublicQueryResults = getQueryResponse(niPublicQuery, SOQL_ENDPOINT);
                OrgSearchDataStructuresCls.DefaultLocInfo defaultLocInfo = (OrgSearchDataStructuresCls.DefaultLocInfo)Json.Deserialize(removeSFCharacters(niPublicQueryResults.getBody()), OrgSearchDataStructuresCls.DefaultLocInfo.class);
                if (defaultLocInfo != null && defaultLocInfo.records != null) {
                    for (OrgSearchDataStructuresCls.DefaultLocRecord record :defaultLocInfo.records) {
                    if (orgPropertyMap.get(record.DefaultLocationId) != null) {
                            OrgProperty__c prop = orgPropertyMap.get(record.DefaultLocationId);
                            prop.NumberOfUsers__c = record.expr0;
                            orgPropertyMap.put(record.DefaultLocationId, prop);
                    }
                    }
                }

                // Add History Created Date to org property records
                List<string> locHistoryConditions = new List<string> {
                    'field=' + '\''+ 'created' + '\''
                };
                String locHistoryQuery = constructQueryParams('SELECT CreatedDate, ParentId FROM nihrm__Location__HISTORY', locHistoryConditions);
                HttpResponse locHistoryQueryResults = getQueryResponse(locHistoryQuery, SOQL_ENDPOINT);
                OrgSearchDataStructuresCls.LocHistoryInfo locHistoryInfo = (OrgSearchDataStructuresCls.LocHistoryInfo)Json.Deserialize(locHistoryQueryResults.getBody(), OrgSearchDataStructuresCls.LocHistoryInfo.class);
                if (locHistoryInfo != null && locHistoryInfo.records != null) {
                    for (OrgSearchDataStructuresCls.LocHistoryRecord record :locHistoryInfo.records) {
                    if (orgPropertyMap.get(record.ParentId) != null) {
                            OrgProperty__c prop = orgPropertyMap.get(record.ParentId);
                            prop.HistoryCreatedDate__c = record.CreatedDate;
                            orgPropertyMap.put(record.ParentId, prop);
                    }
                    }
                }

                // Add AHWS Status to org property records
                String systemLocQuery = constructQueryParams('SELECT nihrm__IsEnabled__c, nihrm__Location__c FROM nihrm__SystemLocation__c', null);
                HttpResponse systemLocQueryResults = getQueryResponse(systemLocQuery, SOQL_ENDPOINT);
                OrgSearchDataStructuresCls.SystemLocInfo systemLocInfo = (OrgSearchDataStructuresCls.SystemLocInfo)Json.Deserialize(removeSFCharacters(systemLocQueryResults.getBody()), OrgSearchDataStructuresCls.SystemLocInfo.class);
                if (systemLocInfo != null && systemLocInfo.records != null) {
                    for (OrgSearchDataStructuresCls.SystemLocRecord record :systemLocInfo.records) {
                    if (orgPropertyMap.get(record.Location) != null) {
                            OrgProperty__c prop = orgPropertyMap.get(record.Location);
                            prop.AHWSEnabled__c = record.IsEnabled;
                            orgPropertyMap.put(record.Location, prop);
                    }
                    }
                }

                // Add Booking max create/modified dates to org property records
                List<string> locBookingWhereConditions = new List<string> {
                    'NOT nihrm__Location__c=' + '\''+ '' + '\''
                };
                string locBookingGroupBy = ' GROUP By nihrm__Location__c';
                String locBookingQuery = constructQueryParams('SELECT nihrm__Location__c, count(Id), max(CreatedDate), max(LastModifiedDate) FROM nihrm__Booking__c', locBookingWhereConditions);
                locBookingQuery += locBookingGroupBy.replace(' ', '+');
                HttpResponse locBookingQueryResults = getQueryResponse(locBookingQuery, SOQL_ENDPOINT);
                OrgSearchDataStructuresCls.OrgRelatedInfo locRelatedBookingInfo = (OrgSearchDataStructuresCls.OrgRelatedInfo)Json.Deserialize(removeSFCharacters(locBookingQueryResults.getBody()), OrgSearchDataStructuresCls.OrgRelatedInfo.class);
                if (locRelatedBookingInfo != null && locRelatedBookingInfo.records != null) {
                    for (OrgSearchDataStructuresCls.OrgRelatedRecord record :locRelatedBookingInfo.records) {
                    if (orgPropertyMap.get(record.Location) != null) {
                            OrgProperty__c prop = orgPropertyMap.get(record.Location);
                            prop.BookingCount__c = record.expr0;
                            prop.BookingMaxCreateDate__c = record.expr1;
                            prop.BookingMaxModifiedDate__c = record.expr2;
                            orgPropertyMap.put(record.Location, prop);
                    }
                    }
                }

                // Add Event Count to org property records
                List<string> locEventWhereConditions = new List<string> {
                    'NOT nihrm__Location__c=' + '\''+ '' + '\''
                };
                string LocEventGroupBy = ' GROUP By nihrm__Location__c';
                String LocEventQuery = constructQueryParams('select nihrm__Location__c, count(Id) FROM nihrm__BookingEvent__c', LocEventWhereConditions);
                LocEventQuery += LocEventGroupBy.replace(' ', '+');
                HttpResponse LocEventQueryResults = getQueryResponse(LocEventQuery, SOQL_ENDPOINT);
                OrgSearchDataStructuresCls.OrgRelatedInfo locRelatedEventInfo = (OrgSearchDataStructuresCls.OrgRelatedInfo)Json.Deserialize(removeSFCharacters(LocEventQueryResults.getBody()), OrgSearchDataStructuresCls.OrgRelatedInfo.class);
                if (locRelatedEventInfo != null && locRelatedEventInfo.records != null) {
                    for (OrgSearchDataStructuresCls.OrgRelatedRecord record :locRelatedEventInfo.records) {
                    if (orgPropertyMap.get(record.Location) != null) {
                            OrgProperty__c prop = orgPropertyMap.get(record.Location);
                            prop.EventCount__c = record.expr0;
                            orgPropertyMap.put(record.Location, prop);
                    }
                    }
                }

                // Add RFP Count to org property records
                DateTime todayDate = Date.today();
                List<string> locRFPWhereConditions = new List<string> {
                    'nihrm__Location__c!=' + '\''+ '' + '\'',
                    'RecordType.Name=' + '\''+ 'RFP' + '\'',
                    'nihrm__ArrivalDate__c>'+todayDate.format('yyyy-MM-dd'),
                    '( nihrm__Status__c='+ '\''+ 'Open' + '\''+' OR nihrm__Status__c='+ '\''+ 'Working' + '\''+' )',
                    '( nihrm__RfpStatus__c='+ '\''+ 'TurnedDown' + '\''+' OR nihrm__RfpStatus__c='+ '\''+ 'Cancelled' + '\''+' OR nihrm__RfpStatus__c='+ '\''+ 'SelfAwarded' + '\''+' OR nihrm__RfpStatus__c='+ '\''+ 'Awarded' + '\''+' )'
                };
                string locRFPGroupBy = ' GROUP By nihrm__Location__c';
                String locRFPQuery = constructQueryParams('SELECT nihrm__Location__c, count(Id) FROM nihrm__Inquiry__c', locRFPWhereConditions);
                locRFPQuery += locRFPGroupBy.replace(' ', '+');
                HttpResponse locRFPQueryResults = getQueryResponse(locRFPQuery, SOQL_ENDPOINT);
                OrgSearchDataStructuresCls.OrgRelatedInfo locRelatedRFPInfo = (OrgSearchDataStructuresCls.OrgRelatedInfo)Json.Deserialize(removeSFCharacters(locRFPQueryResults.getBody()), OrgSearchDataStructuresCls.OrgRelatedInfo.class);
                if (locRelatedRFPInfo != null && locRelatedRFPInfo.records != null) {
                    for (OrgSearchDataStructuresCls.OrgRelatedRecord record :locRelatedRFPInfo.records) {
                    if (orgPropertyMap.get(record.Location) != null) {
                            OrgProperty__c prop = orgPropertyMap.get(record.Location);
                            prop.DBRFPCount__c = record.expr0;
                            orgPropertyMap.put(record.Location, prop);
                    }
                    }
                }

                if (orgPropertyMap.size() > 0) {
                    OrgPropertyResult = orgPropertyMap.values();
                }
            }
        } catch (Exception ex) {
            setOrgInfoError(ex);
        } 
    }

    public void getPropertyIntegrationInfo() {
        try {
            List<OrgPropertyIntegrationSetting__c> propertyIntegrationList = new List<OrgPropertyIntegrationSetting__c>();
            string propertyIntegrationQuery = constructQueryParams('SELECT Id, nihrm__Location__r.Name, nihrm__Location__r.Id, Name, nihrm__Integration__r.Name, nihrm__IsActive__c, nihrm__IntegrationMode__c, nihrm__DefaultIntegrationTaskType__c, RecordType.Name, nihrm__ChannelLocationId__c, nihrm__SendProspectStatus__c, nihrm__SendTentativeStatus__c, nihrm__OperaOutboundTentativeMapping__c, nihrm__SendDaysDateType__c, nihrm__SendDaysPast__c, nihrm__SendDaysFuture__c, nihrm__SendRateDetail__c, nihrm__OutboundMarketCodeMapping__c, nihrm__OutboundSourceCodeMapping__c, nihrm__OutboundChannelCodeMapping__c, nihrm__OperaSendControlBlockLocally__c, nihrm__SendSecondaryLanguage__c, nihrm__SendEventOnlyBookings__c, nihrm__ExcludedMarketSegments__c, nihrm__ExcludedBookingTypes__c, nihrm__AllowROHOutbound__c, nihrm__UpdatePickupFROMPMSRoomBlocks__c, nihrm__PickupOccDist__c, nihrm__IgnoreNonInitUpdateCode__c, nihrm__AllowCancellations__c, nihrm__AllowCutoffDateChanges__c, nihrm__AllowInboundRohUpdates__c, nihrm__SetResNightRateFROM__c, nihrm__IncludeTentativeNonDeduct__c, nihrm__PmsIdRequired__c, nihrm__PmsIdEnforceUniquePast__c, nihrm__PmsIdRequiredEO__c, nihrm__PmsIdMinLength__c, nihrm__PmsIdMaxLength__c, nihrm__MarkPickupComplete__c, nihrm__DaysAfterDeparture__c, nihrm__PostedRevenueMapping1__c, nihrm__PostedRevenueMapping2__c, nihrm__PostedRevenueMapping3__c, nihrm__PostedRevenueMapping4__c, nihrm__PostedRevenueMapping5__c, nihrm__OperaOutboundSellLimitMapping__c FROM nihrm__LocationIntegrationSettings__c', null);
            HttpResponse queryResults = getQueryResponse(propertyIntegrationQuery, SOQL_ENDPOINT);
            OrgSearchDataStructuresCls.OrgPropertyIntegrationInfo propertyIntegrationInfo = (OrgSearchDataStructuresCls.OrgPropertyIntegrationInfo)Json.Deserialize(removeSFCharacters(queryResults.getBody()), OrgSearchDataStructuresCls.OrgPropertyIntegrationInfo.class);
            if (propertyIntegrationInfo != null && propertyIntegrationInfo.records != null) {
                for (OrgSearchDataStructuresCls.OrgPropertyIntegrationRecord record :propertyIntegrationInfo.records) {
                    OrgPropertyIntegrationSetting__c orgPropertyIntegration = record.createSFObject();
                    propertyIntegrationList.add(orgPropertyIntegration);
                }
                if (propertyIntegrationList.size() > 0) {
                    orgPropertyIntegrationSettingResult = propertyIntegrationList;
                }
            }
        } catch (Exception ex) {
            setOrgInfoError(ex);
        } 
    }

    public void getSandboxInfo() {
        try{
            List<OrgSandbox__c> orgSandboxList = new List<OrgSandbox__c>();
            string orgSandboxQuery = constructQueryParams('SELECT Id, SandboxName, ActivatedDate, Description, SandboxOrganization, Status, LicenseType, EndDate FROM SandboxProcess', null);
            Httprequest request = new HttpRequest();
            HttpResponse queryResults = new HttpResponse();
            string reqURL = domain + 'salesforce.com' + TOOLING_ENDPOINT + orgSandboxQuery;
            Http http = new Http();
            request.setMethod('GET');
            request.setEndpoint(reqURL);
            request.setHeader('Content-Type', 'application/json');
            request.setHeader('Accept', 'application/json');
            request.setHeader('Authorization', 'Bearer ' + sessionId);
            queryResults = http.send(request);
            Integer statusCode = queryResults.getStatusCode();
            if (statusCode == 200) {
                OrgSearchDataStructuresCls.OrgSandboxInfo sbInfo = (OrgSearchDataStructuresCls.OrgSandboxInfo)Json.Deserialize(queryResults.getBody(), OrgSearchDataStructuresCls.OrgSandboxInfo.class);
                if (sbInfo != null && sbInfo.records != null) {
                    for (OrgSearchDataStructuresCls.OrgSandboxRecord record :sbInfo.records) {
                        OrgSandbox__c orgSB = record.createSFObject();
                        orgSandboxList.add(orgSB);
                    }
                    if (orgSandboxList.size() > 0) {
                        OrgSandboxResult = orgSandboxList;
                    }
                }
            }
        } catch (Exception ex) {
            setOrgInfoError(ex);
        } 
    }

    public void getSupportUser() {
        try {
            Map<String, OrgUser__c> orgUserMap = new Map<String, OrgUser__c>();
            Map<string, string> asemPemSetMap = new Map<string, string> {
                'SEU' => 'SEUser', 
                'SEAdmin' => 'SEAdmin', 
                'SCCA' => 'SCCorpAdmin', 
                'SCPA' => 'SCPropertyAdminPlatform', 
                'SCU' => 'SCUserPlatform', 
                'SCVO' => 'SCViewOnlyPermission', 
                'EOCA' => 'EOnlyCorpAdmin', 
                'EOPA' => 'EOnlyPropertyAdminPlatform', 
                'EOU' => 'EOnlyUserPlatform', 
                'EOVO' => 'EOViewOnlyUserPlatform',
                'NWS' => 'OperaIntegrationUserSalesforce'};
            Map<string, string> asemProfileMap = new Map<string, string> {
                'SYSADMIN' => 'System Administrator'};
            List<string> whereConditions = new List<string> {
                'UserType=' + '\''+ 'Standard' + '\'',
                'Profile.Name=' + '\''+ asemProfileMap.get('SYSADMIN') + '\'',
                'Id IN (SELECT AssigneeId FROM PermissionSetAssignment WHERE ( PermissionSet.Name=' + '\''+ asemPemSetMap.get('SEU') + '\'' + ' OR ' + 'PermissionSet.Name=' + '\''+ asemPemSetMap.get('SCCA') + '\'' + ' OR ' + 'PermissionSet.Name=' + '\''+ asemPemSetMap.get('SEAdmin') + '\'' + ' OR ' + 'PermissionSet.Name=' + '\''+ asemPemSetMap.get('SCPA') + '\'' + ' OR ' + 'PermissionSet.Name=' + '\''+ asemPemSetMap.get('SCU') + '\'' + ' OR ' + 'PermissionSet.Name=' + '\''+ asemPemSetMap.get('SCVO') + '\'' + ' OR ' + 'PermissionSet.Name=' + '\''+ asemPemSetMap.get('EOCA') + '\'' + ' OR ' + 'PermissionSet.Name=' + '\''+ asemPemSetMap.get('EOPA') + '\'' + ' OR ' + 'PermissionSet.Name=' + '\''+ asemPemSetMap.get('EOU') + '\'' + ' OR ' + 'PermissionSet.Name=' + '\''+ asemPemSetMap.get('EOVO') + '\'' + ' OR ' + 'PermissionSet.Name=' + '\''+ asemPemSetMap.get('NWS') + '\'' + ' ))'  
    
            };
            string orgUserQuery = constructQueryParams('SELECT Id, IsActive, LastLoginDate, toLabel(LanguageLocaleKey), Profile.Name, UserType, CreateDdate, CreatedBy.Name, LastModifiedDate, LastModifiedBy.Name, FirstName, LastName, Email, TimeZoneSidKey FROM User', whereConditions);
            HttpResponse queryResults = getQueryResponse(orgUserQuery, SOQL_ENDPOINT);
            OrgSearchDataStructuresCls.OrgUserInfo userInfo = (OrgSearchDataStructuresCls.OrgUserInfo)Json.Deserialize(queryResults.getBody(), OrgSearchDataStructuresCls.OrgUserInfo.class);
            if (userInfo != null && userInfo.records != null) {
                for (OrgSearchDataStructuresCls.OrgUserRecord record :userInfo.records) {
                        OrgUser__c orgUser = record.createSFObject();
                        orgUserMap.put(record.Id, orgUser);
                }

                // get user frozen status for org users
                String frozenQuery = constructQueryParams('SELECT UserId, IsFrozen FROM UserLogin', null);
                HttpResponse frozenQueryResult = getQueryResponse(frozenQuery, SOQL_ENDPOINT);
                OrgSearchDataStructuresCls.OrgUserFrozenInfo userFrozenInfo = (OrgSearchDataStructuresCls.OrgUserFrozenInfo)Json.Deserialize(frozenQueryResult.getBody(), OrgSearchDataStructuresCls.OrgUserFrozenInfo.class);
                if (userFrozenInfo != null && userFrozenInfo.records != null) {
                    for (OrgSearchDataStructuresCls.OrgUserFrozenRecord record :userFrozenInfo.records) {
                    if (orgUserMap.get(record.UserId) != null) {
                            OrgUser__c u = orgUserMap.get(record.UserId);
                            u.UserFrozen__c = record.IsFrozen;
                            orgUserMap.put(record.UserId, u);
                    }
                    }
                }

                if (orgVersion >= 45) {
                    String defaultPropQuery = constructQueryParams('SELECT SetupOwnerId, nihrm__DefaultLocationId__c FROM nihrm__ASEMPublicUser__c', null);
                    HttpResponse defaultPropResult = getQueryResponse(defaultPropQuery, SOQL_ENDPOINT);
                    OrgSearchDataStructuresCls.OrgPublicUserInfo defaultPropInfo = (OrgSearchDataStructuresCls.OrgPublicUserInfo)Json.Deserialize(removeSFCharacters(defaultPropResult.getBody()), OrgSearchDataStructuresCls.OrgPublicUserInfo.class);
                    if (defaultPropInfo != null && defaultPropInfo.records != null) {
                        for (OrgSearchDataStructuresCls.OrgPublicUserRecord record :defaultPropInfo.records) {
                        if (orgUserMap.get(record.SetupOwnerId) != null) {
                                OrgUser__c u = orgUserMap.get(record.SetupOwnerId);
                                u = record.updateUserRecord(u);
                                orgUserMap.put(record.SetupOwnerId, u);
                        }
                        }
                    }
                }
                OrgUserResult = OrgUserResult != null ? OrgUserResult : new List<OrgUser__c>();
                if (orgUserMap.size() > 0) {
                    OrgUserResult.addAll(orgUserMap.values());
                }
            }
        } catch (Exception ex) {
            setOrgInfoError(ex);
        } 
    }

    public void getUserInfo() {
        try {
            Map<String, OrgUser__c> orgUserMap = new Map<String, OrgUser__c>();
            Map<string, string> asemProfileMap = new Map<string, string> {
                'SEU' => 'Standard and Essentials User', 
                'SEAdmin' => 'Standard and Essentials Administrator', 
                'SCCA' => 'Sales and Catering Corporate Administrator', 
                'SCPA' => 'Sales and Catering Property Administrator', 
                'SCU' => 'Sales and Catering User', 
                'SCVO' => 'Sales and Catering View Only User', 
                'EOCA' => 'Event Only Corporate Administrator', 
                'EOPA' => 'Event Only Property Administrator', 
                'EOU' => 'Event Only User', 
                'EOVO' => 'Event Only View Only User',
                'NWS' => 'NWS Integration User'};
            List<string> whereConditions = new List<string> {
                'UserType=' + '\''+ 'Standard' + '\'',
                '( Profile.Name=' + '\''+ asemProfileMap.get('SEU') + '\'' + ' OR ' + 'Profile.Name=' + '\''+ asemProfileMap.get('SCCA') + '\'' + ' OR ' + 'Profile.Name=' + '\''+ asemProfileMap.get('SEAdmin') + '\'' + ' OR ' + 'Profile.Name=' + '\''+ asemProfileMap.get('SCPA') + '\'' + ' OR ' + 'Profile.Name=' + '\''+ asemProfileMap.get('SCU') + '\'' + ' OR ' + 'Profile.Name=' + '\''+ asemProfileMap.get('SCVO') + '\'' + ' OR ' + 'Profile.Name=' + '\''+ asemProfileMap.get('EOCA') + '\'' + ' OR ' + 'Profile.Name=' + '\''+ asemProfileMap.get('EOPA') + '\'' + ' OR ' + 'Profile.Name=' + '\''+ asemProfileMap.get('EOU') + '\'' + ' OR ' + 'Profile.Name=' + '\''+ asemProfileMap.get('EOVO') + '\'' + ' OR ' + 'Profile.Name=' + '\''+ asemProfileMap.get('NWS') + '\'' + ' )'  
            };
            string orgUserQuery = constructQueryParams('SELECT Id, IsActive, LastLoginDate, toLabel(LanguageLocaleKey), Profile.Name, UserType, CreateDdate, CreatedBy.Name, LastModifiedDate, LastModifiedBy.Name, FirstName, LastName, Email, TimeZoneSidKey FROM User', whereConditions);
            HttpResponse queryResults = getQueryResponse(orgUserQuery, SOQL_ENDPOINT);
            OrgSearchDataStructuresCls.OrgUserInfo userInfo = (OrgSearchDataStructuresCls.OrgUserInfo)Json.Deserialize(queryResults.getBody(), OrgSearchDataStructuresCls.OrgUserInfo.class);
            if (userInfo != null && userInfo.records != null) {
                for (OrgSearchDataStructuresCls.OrgUserRecord record :userInfo.records) {
                        OrgUser__c orgUser = record.createSFObject();
                        orgUserMap.put(record.Id, orgUser);
                }

                // get user frozen status for org users
                String frozenQuery = constructQueryParams('SELECT UserId, IsFrozen FROM UserLogin', null);
                HttpResponse frozenQueryResult = getQueryResponse(frozenQuery, SOQL_ENDPOINT);
                OrgSearchDataStructuresCls.OrgUserFrozenInfo userFrozenInfo = (OrgSearchDataStructuresCls.OrgUserFrozenInfo)Json.Deserialize(frozenQueryResult.getBody(), OrgSearchDataStructuresCls.OrgUserFrozenInfo.class);
                if (userFrozenInfo != null && userFrozenInfo.records != null) {
                    for (OrgSearchDataStructuresCls.OrgUserFrozenRecord record :userFrozenInfo.records) {
                    if (orgUserMap.get(record.UserId) != null) {
                            OrgUser__c u = orgUserMap.get(record.UserId);
                            u.UserFrozen__c = record.IsFrozen;
                            orgUserMap.put(record.UserId, u);
                    }
                    }
                }

                if (orgVersion >= 45) {
                    String defaultPropQuery = constructQueryParams('SELECT SetupOwnerId, nihrm__DefaultLocationId__c FROM nihrm__ASEMPublicUser__c', null);
                    HttpResponse defaultPropResult = getQueryResponse(defaultPropQuery, SOQL_ENDPOINT);
                    OrgSearchDataStructuresCls.OrgPublicUserInfo defaultPropInfo = (OrgSearchDataStructuresCls.OrgPublicUserInfo)Json.Deserialize(removeSFCharacters(defaultPropResult.getBody()), OrgSearchDataStructuresCls.OrgPublicUserInfo.class);
                    if (defaultPropInfo != null && defaultPropInfo.records != null) {
                        for (OrgSearchDataStructuresCls.OrgPublicUserRecord record :defaultPropInfo.records) {
                        if (orgUserMap.get(record.SetupOwnerId) != null) {
                                OrgUser__c u = orgUserMap.get(record.SetupOwnerId);
                                u = record.updateUserRecord(u);
                                orgUserMap.put(record.SetupOwnerId, u);
                        }
                        }
                    }
                }

                if (orgUserMap.size() > 0) {
                    OrgUserResult = orgUserMap.values();
                }
            }
        } catch (Exception ex) {
            setOrgInfoError(ex);
        } 
    }

    public void getProfileInfo() {
        try {
            List<OrgProfile__c> orgProfileList = new List<OrgProfile__c>();
            List<string> whereConditions = new List<string> {
                '( PermissionsLightningExperienceUser=true OR PermissionsForceTwoFactor=true )'
            };
            String orgProfileQuery = constructQueryParams('SELECT Name, PermissionsLightningExperienceUser, CreatedBy.name, CreatedDate, LastModifiedBy.Name, LastModifiedDate, PermissionsForceTwoFactor FROM Profile', whereConditions);
            HttpResponse queryResults = getQueryResponse(orgProfileQuery, SOQL_ENDPOINT);
            OrgSearchDataStructuresCls.OrgProfileInfo profileInfo = (OrgSearchDataStructuresCls.OrgProfileInfo)Json.Deserialize(queryResults.getBody(), OrgSearchDataStructuresCls.OrgProfileInfo.class);
            if (profileInfo != null && profileInfo.records != null) {
                for (OrgSearchDataStructuresCls.OrgProfileRecord record :profileInfo.records) {
                    OrgProfile__c orgProfile = record.createSFObject();
                    orgProfileList.add(orgProfile);
                }
                if (orgProfileList.size() > 0) {
                    OrgProfileResult = orgProfileList;
                }
            }
        } catch (Exception ex) {
            setOrgInfoError(ex);
        } 
    }

    public void getPropMenuItemCounts() {
        try {
            List<OrgPropMenuItemCount__c> propMenuCountList = new List<OrgPropMenuItemCount__c>();
            List<string> whereConditions = new List<string> {
                'nihrm__IsActive__c=true',
                'nihrm__Location__c!='+ '\''+ '' + '\''
            };
            string propMenuGroupBy = ' GROUP By nihrm__Location__c, RecordType.Name';
            String propMenuCountQuery = constructQueryParams('SELECT count(Id), RecordType.Name, nihrm__Location__c FROM nihrm__Item__c', whereConditions);
            propMenuCountQuery += propMenuGroupBy.replace(' ', '+');
            HttpResponse queryResults = getQueryResponse(propMenuCountQuery, SOQL_ENDPOINT);
            OrgSearchDataStructuresCls.PropMenuItemInfo propMenuInfo = (OrgSearchDataStructuresCls.PropMenuItemInfo)Json.Deserialize(removeSFCharacters(queryResults.getBody()), OrgSearchDataStructuresCls.PropMenuItemInfo.class);
            if (propMenuInfo != null && propMenuInfo.records != null) {
                for (OrgSearchDataStructuresCls.PropMenuItemRecord record :propMenuInfo.records) {
                    OrgPropMenuItemCount__c propMenuCount = record.createSFObject();
                    propMenuCountList.add(propMenuCount);
                }
                if (propMenuCountList.size() > 0) {
                    OrgPropMenuItemCountResult = propMenuCountList;
                }
            }
        } catch (Exception ex) {
            setOrgInfoError(ex);
        } 
    }

    public void getReportCountInfo() {
        try {
            List<OrgReportCount__c> reportCountList = new  List<OrgReportCount__c>();
            List<string> whereConditions = new List<string> {
                'Namespaceprefix='+ '\''+ '' + '\'',
                'createddate = LAST_N_DAYS:30'
            };
            string reportCountGroupBy = ' GROUP By owner.Name';
            string reportCountQuery = constructQueryParams('SELECT count(Id), Owner.Name FROM Report', whereConditions);
            reportCountQuery += reportCountGroupBy.replace(' ', '+');
            HttpResponse queryResults = getQueryResponse(reportCountQuery, SOQL_ENDPOINT);
            OrgSearchDataStructuresCls.ReportInfo reportCountInfo = (OrgSearchDataStructuresCls.ReportInfo)Json.Deserialize(queryResults.getBody(), OrgSearchDataStructuresCls.ReportInfo.class);
            if (reportCountInfo != null && reportCountInfo.records != null) {
                for (OrgSearchDataStructuresCls.ReportRecord record :reportCountInfo.records) {
                    OrgReportCount__c reportCount = record.createSFObject();
                    reportCountList.add(reportCount);
                }
                if (reportCountList.size() > 0) {
                    OrgReportCountResult = reportCountList;
                }
            }
        } catch (Exception ex) {
            setOrgInfoError(ex);
        } 
    }

    public void getSetupValueInfo() {
        try {
            List<OrgSetupValue__c> setupValueList = new List<OrgSetupValue__c>();
            string setupValueQuery = constructQueryParams('Select Name, nihrm__SetupValueType__c, nihrm__Location__r.Name, nihrm__MasterSource__c, nihrm__SortOrder__c, nihrm__IsActive__c, CreatedBy.Name, CreatedDate, LastModifiedBy.Name, LastModifiedDate FROM nihrm__SetupValue__c', null);
            HttpResponse queryResults = getQueryResponse(setupValueQuery, SOQL_ENDPOINT);
            OrgSearchDataStructuresCls.SetupValueInfo setupValueInfo = (OrgSearchDataStructuresCls.SetupValueInfo)Json.Deserialize(removeSFCharacters(queryResults.getBody()), OrgSearchDataStructuresCls.SetupValueInfo.class);
            if (setupValueInfo != null && setupValueInfo.records != null) {
                for (OrgSearchDataStructuresCls.SetupValueRecord record :setupValueInfo.records) {
                    OrgSetupValue__c setupValue = record.createSFObject();
                    setupValueList.add(setupValue);
                }
                if (setupValueList.size() > 0) {
                    OrgSetupValueResult = setupValueList;
                }
            }
        } catch (Exception ex) {
            setOrgInfoError(ex);
        } 
    }

    public void getSystemInfo() {
        try {
            List<OrgSystem__c> systemList = new List<OrgSystem__c>();
            string systemQuery = constructQueryParams('SELECT Name, nihrm__SystemType__r.Name, CreatedDate, CreatedBy.name, LastModifiedDate, LastModifiedBy.Name FROM nihrm__System__c', null);
            HttpResponse queryResults = getQueryResponse(systemQuery, SOQL_ENDPOINT);
            OrgSearchDataStructuresCls.SystemInfo systemInfo = (OrgSearchDataStructuresCls.SystemInfo)Json.Deserialize(removeSFCharacters(queryResults.getBody()), OrgSearchDataStructuresCls.SystemInfo.class);
            if (systemInfo != null && systemInfo.records != null) {
                for (OrgSearchDataStructuresCls.SystemRecord record :systemInfo.records) {
                    OrgSystem__c syst = record.createSFObject();
                    systemList.add(syst);
                }
                if (systemList.size() > 0) {
                    OrgSystemResult = systemList;
                }
            }
        } catch (Exception ex) {
            setOrgInfoError(ex);
        } 
    }

    public void getValidationRuleInfo() {
        try {
            List<OrgValidationRule__c> ruleList = new List<OrgValidationRule__c>();
            List<string> whereConditions = new List<string> {
                'Namespaceprefix='+ '\''+ '' + '\''
            };
            string ruleQuery = constructQueryParams('SELECT ManageableState, NameSpacePrefix, ValidationName, Active, Description, EntityDefinition.DeveloperName, ErrorDisplayField, ErrorMessage, CreatedDate, CreatedBy.Name, LastModifiedDate, LastModifiedBy.Name FROM ValidationRule', whereConditions);
            HttpResponse queryResults = getQueryResponse(ruleQuery, TOOLING_ENDPOINT);
            OrgSearchDataStructuresCls.ValidationRuleInfo ruleInfo = (OrgSearchDataStructuresCls.ValidationRuleInfo)Json.Deserialize(queryResults.getBody(), OrgSearchDataStructuresCls.ValidationRuleInfo.class);
            if (ruleInfo != null && ruleInfo.records != null) {
                for (OrgSearchDataStructuresCls.ValidationRuleRecord record :ruleInfo.records) {
                    OrgValidationRule__c vr = record.createSFObject();
                    ruleList.add(vr);
                }
                if (ruleList.size() > 0) {
                    OrgValidationRuleResult = ruleList;
                }
            }
        } catch (Exception ex) {
            setOrgInfoError(ex);
        } 
    }

    public void getWorkFlowInfo() {
        try {
            List<OrgWorkFlow__c> workflows = new List<OrgWorkFlow__c>();
            List<string> whereConditions = new List<string> {
                'Namespaceprefix='+ '\''+ '' + '\''
            };
            string workflowQuery = constructQueryParams('Select ManageableState, NameSpacePrefix, Name, TableEnumOrId, CreatedDate, CreatedBy.Name, LastModifiedDate, LastModifiedBy.Name FROM WorkFlowRule', whereConditions);
            HttpResponse queryResults = getQueryResponse(workflowQuery, TOOLING_ENDPOINT);
            OrgSearchDataStructuresCls.WorkFlowInfo workflowInfo = (OrgSearchDataStructuresCls.WorkFlowInfo)Json.Deserialize(removeSFCharacters(queryResults.getBody()), OrgSearchDataStructuresCls.WorkFlowInfo.class);
            if (workflowInfo != null && workflowInfo.records != null) {
                for (OrgSearchDataStructuresCls.WorkFlowRecord record :workflowInfo.records) {
                    OrgWorkFlow__c wf = record.createSFObject();
                    workflows.add(wf);
                }
                if (workflows.size() > 0) {
                    OrgWorkFlowResult = workflows;
                }
            }
        } catch (Exception ex) {
            setOrgInfoError(ex);
        } 
    }

    public void getCustomFieldInfo() {
        try {
            List<OrgCustomField__c> orgCustomFieldList = new List<OrgCustomField__c>();
            List<string> whereConditions = new List<string> {
                'Namespaceprefix='+ '\''+ '' + '\'',
                '( '+'( '+'NOT DeveloperName LIKE '+'\''+ '%25_del%25'+'\''+' )'+' OR ' +'( '+'DeveloperName='+ '\''+ 'RohAllowedStatuses' + '\''+' )'+' )'
            };
            String orgCustomFieldQuery = constructQueryParams('Select ManageableState,NameSpacePrefix,DeveloperName,EntityDefinition.Developername,TableEnumOrId, CreatedDate, CreatedBy.Name,LastModifiedDate, LastModifiedBy.Name FROM CustomField', whereConditions);
            HttpResponse queryResults = getQueryResponse(orgCustomFieldQuery, TOOLING_ENDPOINT);
            OrgSearchDataStructuresCls.OrgCustomFieldInfo customFieldInfo = (OrgSearchDataStructuresCls.OrgCustomFieldInfo)Json.Deserialize(queryResults.getBody(), OrgSearchDataStructuresCls.OrgCustomFieldInfo.class);
            if (customFieldInfo != null && customFieldInfo.records != null) {
                for (OrgSearchDataStructuresCls.OrgCustomFieldRecord record :customFieldInfo.records) {
                    OrgCustomField__c orgCustomField = record.createSFObject();
                    orgCustomFieldList.add(orgCustomField);
                }
                if (orgCustomFieldList.size() > 0) {
                    OrgCustomFieldResult = orgCustomFieldList;
                }
            }
        } catch (Exception ex) {
            setOrgInfoError(ex);
        } 
    }

    public void getOrgLoginInfo() {
        try {
            List<string> whereConditions = new List<string> {
                '( NOT User.email=' + '\''+ 'hospitality.delphi.fdc@amadeus.com' + '\'' + ' )',
                '( NOT User.email=' + '\''+ 'delphi.fdc@newmarketinc.com' + '\'' + ' )'
            };
            String orgLoginQuery = constructQueryParams('SELECT max(LastLoginDate) FROM User', whereConditions);
            HttpResponse queryResults = getQueryResponse(orgLoginQuery, SOQL_ENDPOINT);
            OrgSearchDataStructuresCls.OrgLogInInfo orgLoginInfo = (OrgSearchDataStructuresCls.OrgLogInInfo)Json.Deserialize(queryResults.getBody(), OrgSearchDataStructuresCls.OrgLogInInfo.class);
            if (orgLoginInfo != null && orgLoginInfo.records != null && OrgInfoResult != null) {
                for (OrgSearchDataStructuresCls.OrgLoginRecord record :orgLoginInfo.records) {
                    OrgInfoResult.MaxLastLoginDate__c = record.expr0;
                }
            }
        } catch (Exception ex) {
            setOrgInfoError(ex);
        } 
    }

    public void getAccountInfo() {
        try {
            String accountQuery = constructQueryParams('SELECT count(Id), max(CreatedDate), max(LastModifiedDate) FROM Account', null);
            HttpResponse queryResults = getQueryResponse(accountQuery, SOQL_ENDPOINT);
            OrgSearchDataStructuresCls.OrgRelatedInfo accountInfo = (OrgSearchDataStructuresCls.OrgRelatedInfo)Json.Deserialize(queryResults.getBody(), OrgSearchDataStructuresCls.OrgRelatedInfo.class);
            if (accountInfo != null && accountInfo.records != null && OrgInfoResult != null) {
                for (OrgSearchDataStructuresCls.OrgRelatedRecord record :accountInfo.records) {
                    OrgInfoResult.TotalAccounts__c = record.expr0;
                    OrgInfoResult.MaxAccountCreateDate__c = record.expr1;
                    OrgInfoResult.MaxAccountModifiedDate__c = record.expr2;
                }
            }
        } catch (Exception ex) {
            setOrgInfoError(ex);
        } 
    }

    public void getContactInfo() {
        try {
            String accountQuery = constructQueryParams('SELECT count(Id) FROM Contact', null);
            HttpResponse queryResults = getQueryResponse(accountQuery, SOQL_ENDPOINT);
            OrgSearchDataStructuresCls.OrgRelatedInfo contactInfo = (OrgSearchDataStructuresCls.OrgRelatedInfo)Json.Deserialize(queryResults.getBody(), OrgSearchDataStructuresCls.OrgRelatedInfo.class);
            if (contactInfo != null && contactInfo.records != null && OrgInfoResult != null) {
                for (OrgSearchDataStructuresCls.OrgRelatedRecord record :contactInfo.records) {
                    OrgInfoResult.TotalContacts__c = record.expr0;
                }
            }
        } catch (Exception ex) {
            setOrgInfoError(ex);
        } 
    }

    public void getApexClassInfo() {
        try {
            List<OrgApexClass__c> apexClasses = new List<OrgApexClass__c>();
            List<string> whereConditions = new List<string> {
                'ManageableState=\'unmanaged\''
            };
            string apexClassQuery = constructQueryParams('select Name, apiversion, body, status, CreatedDate, Createdby.Name, LastModifiedDate,lastmodifiedby.Name FROM apexclass', whereConditions);
            HttpResponse queryResults = getQueryResponse(apexClassQuery, TOOLING_ENDPOINT);
            OrgSearchDataStructuresCls.ApexClassInfo apexClassInfo = (OrgSearchDataStructuresCls.ApexCLassInfo)Json.Deserialize(queryResults.getBody(), OrgSearchDataStructuresCls.ApexClassInfo.class);
            integer maxSize = 500;
            if (apexClassInfo != null && apexClassInfo.records != null) {
                for (OrgSearchDataStructuresCls.ApexClassRecord record :apexClassInfo.records) {
                    OrgApexClass__c ac = record.createSFObject();
                    apexClasses.add(ac);
                }
                if (apexClasses.size() > 0) {
                    OrgApexClassResult = apexClasses;
                }
            }
        } catch (Exception ex) {
            setOrgInfoError(ex);
        } 
    }

    public void getApexTriggerInfo() {
        try {
            List<OrgApexTrigger__c> apexTriggers = new List<OrgApexTrigger__c>();
            List<string> whereConditions = new List<string> {
                'ManageableState=\'unmanaged\''
            };
            string apexTriggerQuery = constructQueryParams('select Name, apiversion, EntityDefinition.DeveloperName, body, status, CreatedDate, Createdby.Name, LastModifiedDate,lastmodifiedby.Name FROM apextrigger', whereConditions);
            HttpResponse queryResults = getQueryResponse(apexTriggerQuery, TOOLING_ENDPOINT);
            OrgSearchDataStructuresCls.ApexTriggerInfo apexTriggerInfo = (OrgSearchDataStructuresCls.ApexTriggerInfo)Json.Deserialize(queryResults.getBody(), OrgSearchDataStructuresCls.ApexTriggerInfo.class);
            integer maxSize = 500;
            if (apexTriggerInfo != null && apexTriggerInfo.records != null) {
                for (OrgSearchDataStructuresCls.ApexTriggerRecord record :apexTriggerInfo.records) {
                    OrgApexTrigger__c at = record.createSFObject();
                    apexTriggers.add(at);
                }
                if (apexTriggers.size() > 0) {
                    OrgApexTriggerResult = apexTriggers;
                }
            }
        } catch (Exception ex) {
            setOrgInfoError(ex);
        } 
    }

    public void getApprovalProcessInfo() {
        try {
            List<OrgApprovalProcess__c> approvalProcesses = new List<OrgApprovalProcess__c>();
            List<string> whereConditions = new List<string> {
            };
            string ApprovalProcessQuery = constructQueryParams('select Name, Description, state, tableenumorid, CreatedBy.name, CreatedDate, LastModifiedBy.name,  LastModifiedDate FROM processdefinition', whereConditions);
            HttpResponse queryResults = getQueryResponse(ApprovalProcessQuery, SOQL_ENDPOINT);
            
            OrgSearchDataStructuresCls.ApprovalProcessInfo approvalProcessInfo = (OrgSearchDataStructuresCls.ApprovalProcessInfo)Json.Deserialize(removeSFCharacters(queryResults.getBody()), OrgSearchDataStructuresCls.ApprovalProcessInfo.class);
            if (approvalProcessInfo != null && approvalProcessInfo.records != null) {
                for (OrgSearchDataStructuresCls.ApprovalProcessRecord record :approvalProcessInfo.records) {
                    OrgApprovalProcess__c ap = record.createSFObject();
                    approvalProcesses.add(ap);
                }
                if (approvalProcesses.size() > 0) {
                    OrgApprovalProcessResult = approvalProcesses;
                }
            }
        } catch (Exception ex) {
            setOrgInfoError(ex);
        } 
    }

    public void getCustomObjectInfo() {
        try {
            List<OrgCustomObject__c> customObjects = new List<OrgCustomObject__c>();
            List<string> whereConditions = new List<string> {
                        'NameSpacePrefix=\' \''+' OR '+'( '+'NamespacePrefix=\'nihrm\' )'
                    };
            string customObjectQuery = constructQueryParams('select id,DeveloperName, Description, NameSpacePrefix, ManageableState, SharingModel, createddate, createdby.name, lastmodifieddate,lastmodifiedby.name FROM CustomObject', whereConditions);
            HttpResponse queryResults = getQueryResponse(customObjectQuery, TOOLING_ENDPOINT);
            OrgSearchDataStructuresCls.CustomObjectInfo customObjectInfo = (OrgSearchDataStructuresCls.CustomObjectInfo)Json.Deserialize(removeSFCharacters(queryResults.getBody()), OrgSearchDataStructuresCls.CustomObjectInfo.class);
            if (customObjectInfo != null && customObjectInfo.records != null) {
                for (OrgSearchDataStructuresCls.CustomObjectRecord record :customObjectInfo.records) {
                    OrgCustomObject__c ap = record.createSFObject();
                    customObjects.add(ap);
                }
                if (CustomObjects.size() > 0) {
                    OrgCustomObjectResult = CustomObjects;
                }
            }
        } catch (Exception ex) {
            setOrgInfoError(ex);
        } 
    }

    public void getCustomTabInfo() {
        try {
            List<OrgCustomTab__c> customTabs = new List<OrgCustomTab__c>();
            List<string> whereConditions = new List<string> {
                    'NOT ( NamespacePrefix=\'nihrm\' )'
                    };
            string customTabQuery = constructQueryParams('Select description, ManageableState, MasterLabel, NamespacePrefix, Type, Url, CreatedDate, CreatedBy.Name,LastModifiedDate, LastModifiedBy.Name FROM CustomTab', whereConditions);
            HttpResponse queryResults = getQueryResponse(customTabQuery, TOOLING_ENDPOINT);
            
            OrgSearchDataStructuresCls.CustomTabInfo customTabInfo = (OrgSearchDataStructuresCls.CustomTabInfo)Json.Deserialize(removeSFCharacters(queryResults.getBody()), OrgSearchDataStructuresCls.CustomTabInfo.class);
            if (customTabInfo != null && customTabInfo.records != null) {
                for (OrgSearchDataStructuresCls.CustomTabRecord record :customTabInfo.records) {
                    OrgCustomTab__c ap = record.createSFObject();
                    customTabs.add(ap);
                }
                if (CustomTabs.size() > 0) {
                    OrgCustomTabResult = CustomTabs;
                }
            }
        } catch (Exception ex) {
            setOrgInfoError(ex);
        } 
    }

    public void getProcessInfo() {
        try {
            List<OrgProcess__c> Processes = new List<OrgProcess__c>();
            List<string> whereConditions = new List<string> {
                        'processtype =\'Workflow\' '
                    };
            string processQuery = constructQueryParams('Select ManageableState,MasterLabel, VersionNumber, Status, CreatedDate, CreatedBy.Name, LastModifiedDate, LastModifiedBy.Name FROM Flow', whereConditions);
            HttpResponse queryResults = getQueryResponse(ProcessQuery, TOOLING_ENDPOINT);
            
            OrgSearchDataStructuresCls.ProcessInfo processInfo = (OrgSearchDataStructuresCls.ProcessInfo)Json.Deserialize(removeSFCharacters(queryResults.getBody()), OrgSearchDataStructuresCls.ProcessInfo.class);
            if (processInfo != null && processInfo.records != null) {
                for (OrgSearchDataStructuresCls.ProcessRecord record :processInfo.records) {
                    OrgProcess__c ap = record.createSFObject();
                    Processes.add(ap);
                }
                if (Processes.size() > 0) {
                    OrgProcessResult = Processes;
                }
            }
        } catch (Exception ex) {
            setOrgInfoError(ex);
        } 
    }

    public void getPropDocTemplateCounts() {
        try {
            List<OrgPropDocTemplateCount__c> propdocs = new List<OrgPropDocTemplateCount__c>();
            List<string> whereConditions = new List<string> {
                'nihrm__MasterSource__c=\'Property\' ',
                'nihrm__IsActive__c=True' 
            };
            string PropDocTemplateQuery = constructQueryParams('select count(Name),nihrm__Location__c, nihrm__TemplateType__c FROM nihrm__DocumentTemplate__c', whereConditions);
            string PropDocTemplateGroupBy = ' GROUP BY nihrm__Location__c, nihrm__TemplateType__c';
            PropDocTemplateQuery += PropDocTemplateGroupBy.replace(' ', '+');
            HttpResponse queryResults = getQueryResponse(PropDocTemplateQuery, SOQL_ENDPOINT);
            OrgSearchDataStructuresCls.OrgPropDocTemplateCountInfo propDocTemplateCount = (OrgSearchDataStructuresCls.OrgPropDocTemplateCountInfo)Json.Deserialize(removeSFCharacters(queryResults.getBody()), OrgSearchDataStructuresCls.OrgPropDocTemplateCountInfo.class);
            if (PropDocTemplateCount != null && PropDocTemplateCount.records != null) {
                for (OrgSearchDataStructuresCls.OrgPropDocTemplateCountRecord record :PropDocTemplateCount.records) {
                    OrgPropDocTemplateCount__c propDoc = record.createSFObject();
                    propdocs.add(propDoc);
                }
                if (propdocs.size() > 0) {
                    OrgPropDocumentTemplateResult = propdocs;
                }
            }
        } catch (Exception ex) {
            setOrgInfoError(ex);
        } 
    }


    public static Integer setOrgVersion(String majorVersionName) {
        Integer defaultValue = 0;
        String versionString = null;
        String patchVersionPrefix = 'P';
        String majorVersionPrefix = 'Sales & Event Management R';
        if (majorVersionName.contains(majorVersionPrefix)) {
            versionString = majorVersionName.replace(majorVersionPrefix, '');
        }
        if (versionString.contains(patchVersionPrefix)) {
            versionString = versionString.substringBefore(patchVersionPrefix);
        }
        Integer versionNumber = versionString != null 
            ? Integer.valueOf(versionString.trim()) 
            : defaultValue;
        return versionNumber;
    }

    private boolean authorizeOrgCredentials() {
        try {
            OrgSearchRemote.Soap soap = new OrgSearchRemote.Soap();
            string endPoint = orgDetail.Org_Type__c.containsIgnoreCase('salesforce sandbox') ? SB_AUTH_ENDPOINT : AUTH_ENDPOINT;
            OrgSearchRemote.LoginResult loginResult = soap.login(orgDetail.Admin_Login_Name_Encrypted__c, orgDetail.Admin_Password_Encrypted__c.trim() + orgDetail.Security_Token_Encrypted__c.trim(), endPoint);  
            sessionId = loginResult.sessionId; 
            orgId = loginResult.userInfo.organizationId; 
            orgLocale = loginResult.userInfo.userLocale; 
            userId = loginResult.userInfo.userId;
            domain = loginResult.serverUrl.substringBefore('salesforce.com');
            return true;
        } catch (Exception ex) {
            setOrgInfoError(ex);
            return false;
        } 
    }

    private HttpResponse getQueryResponse(string queryParameters, string endpoint){
        Httprequest request = new HttpRequest();
        HttpResponse result = new HttpResponse();
        string reqURL = domain + 'salesforce.com' + endpoint + queryParameters;
        Http http = new Http();
        request.setMethod('GET');
        request.setEndpoint(reqURL);
        request.setHeader('Content-Type', 'application/json');
        request.setHeader('Accept', 'application/json');
        request.setHeader('Authorization', 'Bearer ' + sessionId);
        request.setTimeout(120000);
        result = http.send(request);
        if (result.getStatuscode() != 200) {
            CalloutException ex = new CalloutException();
            ex.setMessage('Error on Http response: ' + result.getBody());
            throw ex;
        }
        return result;
    }
    
    private String constructQueryParams(string soqlQuery, List<string> whereConditions) {
        string result = soqlQuery.replace(' ','+');
        if (whereConditions != null) {
           string formattedWhereClause = '';
            for (string condition :whereConditions) {
                if (formattedWhereClause == '') {
                    formattedWhereClause = '+WHERE+';
                } else {
                    formattedWhereClause += '+AND+';
                }
                formattedWhereClause += condition.replace(' ','+');
            }
            result += formattedWhereClause;
        } 
        return result; 
    }

    public String removeSFCharacters(string json) {
        if (json != null) {
            json = json.replace('__c','');
            json = json.replace('__r','');
            json = json.replace('nihrm__','');
        }
        return json;
    } 

    public void setOrgInfoError(Exception ex) {
        if (OrgInfoResult == null) {
            OrgInfoResult = new OrgInfo__c();
            OrgInfoResult.AHName__c = orgDetail.Name;
            OrgInfoResult.AHOrgName__c = orgDetail.Org_Name__c;
            OrgInfoResult.AHOrgDetailsID__c = orgDetail.Id;
            OrgInfoResult.AHOrgId__c = orgDetail.Org_ID__c;
            OrgInfoResult.AHOrgStatus__c = orgDetail.Org_Status__c;
            OrgInfoResult.AHPrimaryAccountOwner__c = orgDetail.Primary_Account_Owner__r.Name;
            OrgInfoResult.AHRenewalDate__c = orgDetail.Annual_Salesforce_Renewal_Date__c;
            OrgInfoResult.AHTemplateName__c = orgDetail.Template__r.Name;
            OrgInfoResult.InternalOrg__c = orgDetail.Internal_Org__c;
        }
        if (OrgInfoResult.ErrorInfo__c == null || String.isBlank(OrgInfoResult.ErrorInfo__c)) {    
            OrgInfoResult.ErrorInfo__c = ex.getmessage(); 
        } else {
            OrgInfoResult.ErrorInfo__c += '\n' + ex.getmessage();
        }
    }

    public OrgInfoBatch.OrgQueryInfo getBatchQueryInfo() {
        OrgInfoBatch.OrgQueryInfo allQueryData = new OrgInfoBatch.OrgQueryInfo();
        allQueryData.OrgInfoResult = OrgInfoResult;
        allQueryData.OrgLimitResult = OrgLimitResult;
        allQueryData.OrgProcessorResult = OrgProcessorResult;
        allQueryData.OrgPackageResult = OrgPackageResult;
        allQueryData.OrgSandboxResult = OrgSandboxResult;
        allQueryData.OrgPropertyResult = OrgPropertyResult;
        allQueryData.OrgLicenseResult = OrgLicenseResult;
        allQueryData.OrgUserResult = OrgUserResult;
        allQueryData.OrgProfileResult = OrgProfileResult;
        allQueryData.orgPropertyIntegrationSettingResult = orgPropertyIntegrationSettingResult;
        allQueryData.OrgPropertyMenuItemCountsResult = OrgPropMenuItemCountResult;
        allQueryData.OrgPropDocumentTemplateResult = OrgPropDocumentTemplateResult;
        allQueryData.OrgSystemResult = OrgSystemResult;
        allQueryData.OrgReportCountResult = OrgReportCountResult;
        allQueryData.OrgSetupValueResult = OrgSetupValueResult;
        allQueryData.OrgValidationRuleResult = OrgValidationRuleResult;
        allQueryData.OrgWorkflowResult = OrgWorkflowResult;
        allQueryData.OrgApexClassResult = OrgApexClassResult;
        allQueryData.OrgApexTriggerResult = OrgApexTriggerResult;
        allQueryData.OrgApprovalProcessResult = OrgApprovalProcessResult;
        allQueryData.OrgCustomObjectResult = OrgCustomObjectResult;
        allQueryData.OrgCustomTabResult = OrgCustomTabResult;
        allQueryData.OrgProcessResult = OrgProcessResult;
        allQueryData.OrgCustomFieldResult = OrgCustomFieldResult;

        return allQueryData;
    }

}