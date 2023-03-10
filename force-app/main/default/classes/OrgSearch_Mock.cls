/************************************************************************************************
Name            : OrgSearch_Mock - Http Mock Callout
Author          : Michael Pedro
Last Mod Date   : 05/05/2022
Last Mod By     : Michael Pedro
Description     : mock http callout for org search tests
*************************************************************************************************/

@isTest
global class OrgSearch_Mock implements HttpCalloutMock {

    global HTTPResponse respond(HTTPRequest req) {
        string objectType;
        System.assertEquals('GET', req.getMethod());
        System.assert(req.getEndpoint().contains('https://domain.my.salesforce.com/services/data/v54.0/'));
        if (req.getEndpoint().contains('https://domain.my.salesforce.com/services/data/v54.0/limits')) {
            objectType = 'Limit';
        } else {
            objectType = req.getEndpoint().substringAfter('FROM+');
            objectType = objectType.substringBefore('+');
        }
        system.debug(objectType);
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');

        string body;

        switch on (objectType) {
			when 'Organization' {
				body = '{'+
                '"totalSize" : 1,'+
                '"done" : true,'+
                '"records" : [ {'+
                    '"attributes" : {'+
                    '"type" : "Organization",'+
                    '"url" : "/services/data/v54.0/sobjects/Organization/id"'+
                    '},'+
                    '"Id" : "orgId",'+
                    '"Name" : "Test Org",'+
                    '"InstanceName" : "NA123",'+
                    '"DefaultAccountAccess" : "None",'+
                    '"CreatedDate" : "2018-07-30T15:08:54.000+0000",'+
                    '"LastModifiedDate" : "2020-08-14T13:19:28.000+0000"'+
                '} ]'+
                '}';
			}
            when 'InstalledSubscriberPackage' {
                body = '{'+
                    '"size" : 1,'+
                    '"totalSize" : 1,'+
                    '"done" : true,'+
                    '"queryLocator" : null,'+
                    '"entityTypeName" : "InstalledSubscriberPackage",'+
                    '"records" : [ {'+
                      '"attributes" : {'+
                        '"type" : "InstalledSubscriberPackage",'+
                        '"url" : "/services/data/v54.0/tooling/sobjects/InstalledSubscriberPackage/id"'+
                      '},'+
                      '"Id" : "id",'+
                      '"SubscriberPackageId" : "packageId",'+
                      '"SubscriberPackage" : {'+
                        '"attributes" : {'+
                          '"type" : "SubscriberPackage",'+
                          '"url" : "/services/data/v54.0/tooling/sobjects/SubscriberPackage/id"'+
                        '},'+
                        '"NamespacePrefix" : "nihrm",'+
                        '"Name" : "Sales & Event Management"'+
                      '},'+
                      '"SubscriberPackageVersion" : {'+
                        '"attributes" : {'+
                          '"type" : "SubscriberPackageVersion",'+
                          '"url" : "/services/data/v54.0/tooling/sobjects/SubscriberPackageVersion/id"'+
                        '},'+
                        '"Id" : "packageVersionId",'+
                        '"Name" : "Sales & Event Management R44 P1",'+
                        '"MajorVersion" : 1,'+
                        '"MinorVersion" : 2,'+
                        '"PatchVersion" : 0,'+
                        '"BuildNumber" : 1'+
                      '}'+
                    '} ]'+
                  '}';
            }
            when 'nihrm__Location__c' {
                body = '{'+
                    '"totalSize" : 1,'+
                    '"done" : true,'+
                    '"records" : [ {'+
                      '"attributes" : {'+
                        '"type" : "nihrm__Location__c",'+
                        '"url" : "/services/data/v54.0/sobjects/nihrm__Location__c/id"'+
                      '},'+
                      '"Id" : "locId",'+
                      '"Name" : "Test Property",'+
                      '"nihrm__IsActive__c" : true,'+
                      '"nihrm__Abbreviation__c" : null,'+
                      '"nihrm__PropertyKey__c" : null,'+
                      '"CreatedDate" : "2022-02-28T12:22:39.000+0000",'+
                      '"CreatedBy" : {'+
                        '"attributes" : {'+
                          '"type" : "User",'+
                          '"url" : "/services/data/v54.0/sobjects/User/id"'+
                        '},'+
                        '"Name" : "Admin User"'+
                      '},'+
                      '"LastModifiedDate" : "2022-03-08T12:06:25.000+0000",'+
                      '"LastModifiedBy" : {'+
                        '"attributes" : {'+
                          '"type" : "User",'+
                          '"url" : "/services/data/v54.0/sobjects/User/id"'+
                        '},'+
                        '"Name" : "Admin User"'+
                      '},'+
                      '"nihrm__AvailabilityScreenView__c" : null,'+
                      '"nihrm__AddressLine1__c" : "Address 1",'+
                      '"nihrm__AddressLine2__c" : null,'+
                      '"nihrm__AddressLine3__c" : null,'+
                      '"nihrm__City__c" : "pune",'+
                      '"nihrm__StateProvince__c" : null,'+
                      '"nihrm__CountryCode__c" : "US",'+
                      '"nihrm__PostalCode__c" : "411048",'+
                      '"nihrm__Phone__c" : null,'+
                      '"nihrm__PropertyCode__c" : null'+
                    '} ]'+
                  '}';
            }
            when 'nihrm__NiPublic__c' {
                if (req.getEndpoint().contains('GROUP+By')) {
                    body = '{'+
                    '"totalSize" : 1,'+
                    '"done" : true,'+
                    '"records" : [ {'+
                      '"attributes" : {'+
                        '"type" : "AggregateResult"'+
                      '},'+
                      '"expr0" : 1,'+
                      '"nihrm__DefaultLocationId__c" : "locId"'+
                    '} ]'+
                  '}';
                } else {
                    body = '{'+
                    '"totalSize" : 1,'+
                    '"done" : true,'+
                    '"records" : [ {'+
                      '"attributes" : {'+
                        '"type" : "nihrm__NiPublic__c",'+
                        '"url" : "/services/data/v54.0/sobjects/nihrm__NiPublic__c/id"'+
                      '},'+
                      '"nihrm__EnableAccountSecurity__c" : true,'+
                      '"nihrm__AllowLimitedService__c" : true,'+
                      '"nihrm__UseCanvasReporting__c" : true'+
                    '} ]'+
                  '}';
                }
            }
            when 'nihrm__Location__HISTORY' {
                body = '{'+
                    '"totalSize" : 1,'+
                    '"done" : true,'+
                    '"records" : [ {'+
                      '"attributes" : {'+
                        '"type" : "nihrm__Location__History",'+
                        '"url" : "/services/data/v54.0/sobjects/nihrm__Location__History/0175f000070uqf9AAA"'+
                      '},'+
                      '"CreatedDate" : "2022-04-29T06:32:59.000+0000",'+
                      '"ParentId" : "locId"'+
                    '} ]'+
                  '}';
            }
            when 'nihrm__SystemLocation__c' {
                body = '{'+
                    '"totalSize" : 1,'+
                    '"done" : true,'+
                    '"records" : [ {'+
                      '"attributes" : {'+
                        '"type" : "nihrm__SystemLocation__c",'+
                        '"url" : "/services/data/v54.0/sobjects/nihrm__SystemLocation__c/id"'+
                      '},'+
                      '"nihrm__IsEnabled__c" : true,'+
                      '"nihrm__Location__c" : "locId"'+
                    '} ]'+
                  '}';
            }
            when 'nihrm__Booking__c' {
                body = '{'+
                    '"totalSize" : 1,'+
                    '"done" : true,'+
                    '"records" : [ {'+
                      '"attributes" : {'+
                        '"type" : "AggregateResult"'+
                      '},'+
                      '"nihrm__Location__c" : "locId",'+
                      '"expr0" : 1,'+
                      '"expr1" : "2022-03-08T18:27:25.000+0000",'+
                      '"expr2" : "2022-03-08T18:39:50.000+0000"'+
                    '} ]'+
                  '}';
            }
            when 'nihrm__BookingEvent__c', 'nihrm__Inquiry__c' {
                body = '{'+
                    '"totalSize" : 1,'+
                    '"done" : true,'+
                    '"records" : [ {'+
                      '"attributes" : {'+
                        '"type" : "AggregateResult"'+
                      '},'+
                      '"nihrm__Location__c" : "locId",'+
                      '"expr0" : 2'+
                    '} ]'+
                  '}';
            } 
            when 'User' {
                if (req.getEndpoint().contains('max(LastLoginDate)')) {
                    body = '{'+
                        '"totalSize" : 1,'+
                        '"done" : true,'+
                        '"records" : [ {'+
                          '"attributes" : {'+
                            '"type" : "AggregateResult"'+
                          '},'+
                          '"expr0" : "2022-05-04T12:32:39.000+0000"'+
                        '} ]'+
                      '}';
                } else {
                    body = '{'+
                    '"totalSize" : 1,'+
                    '"done" : true,'+
                    '"records" : [ {'+
                      '"attributes" : {'+
                        '"type" : "User",'+
                        '"url" : "/services/data/v54.0/sobjects/User/id"'+
                      '},'+
                      '"Id" : "userId",'+
                      '"IsActive" : true,'+
                      '"LastLoginDate" : null,'+
                      '"LanguageLocaleKey" : "English",'+
                      '"Profile" : null,'+
                      '"UserType" : "AutomatedProcess",'+
                      '"CreatedDate" : "2021-10-29T18:30:03.000+0000",'+
                      '"CreatedBy" : null,'+
                      '"LastModifiedDate" : "2021-10-29T18:30:03.000+0000",'+
                      '"LastModifiedBy" : null,'+
                      '"FirstName" : "Test User",'+
                      '"LastName" : "Last",'+
                      '"Email" : "email@email.com",'+
                      '"TimeZoneSidKey" : "America/Los_Angeles"'+
                    '} ]'+
                  '}';
                }
            }
            when 'UserLogin' {
                body = '{'+
                    '"totalSize" : 1,'+
                    '"done" : true,'+
                    '"records" : [ {'+
                      '"attributes" : {'+
                        '"type" : "UserLogin",'+
                        '"url" : "/services/data/v54.0/sobjects/UserLogin/id"'+
                      '},'+
                      '"UserId" : "userId",'+
                      '"IsFrozen" : false'+
                    '} ]'+
                  '}';
            }
            when 'Profile' {
                body = '{'+
                    '"totalSize" : 1,'+
                    '"done" : true,'+
                    '"records" : [ {'+
                      '"attributes" : {'+
                        '"type" : "Profile",'+
                        '"url" : "/services/data/v54.0/sobjects/Profile/id"'+
                      '},'+
                      '"Name" : "Test Profile",'+
                      '"PermissionsLightningExperienceUser" : true,'+
                      '"CreatedBy" : {'+
                        '"attributes" : {'+
                          '"type" : "User",'+
                          '"url" : "/services/data/v54.0/sobjects/User/id"'+
                        '},'+
                        '"Name" : "QA Sysadmin R44tf"'+
                      '},'+
                      '"CreatedDate" : "2021-12-22T14:55:27.000+0000",'+
                      '"LastModifiedBy" : null,'+
                      '"LastModifiedDate" : "2022-03-09T05:16:46.000+0000",'+
                      '"PermissionsForceTwoFactor" : false'+
                    '} ]'+
                  '}';
            }
            when 'Limit' {
                   body = '{'+
                    '"DailyApiRequests" : {'+
                      '"Max" : 100000,'+
                      '"Remaining" : 96127'+
                    '},'+
                    '"DataStorageMB" : {'+
                      '"Max" : 20640,'+
                      '"Remaining" : 19909'+
                    '},'+
                    '"FileStorageMB" : {'+
                      '"Max" : 52000,'+
                      '"Remaining" : 51907'+
                    '},'+
                    '"HourlyTimeBasedWorkflow" : {'+
                      '"Max" : 1000,'+
                      '"Remaining" : 1000'+
                    '}'+
                  '}';
            }
            when 'nihrm__Log__c', 'nihrm__Message__c' {
                body = '{'+
                    '"totalSize" : 1,'+
                    '"done" : true,'+
                    '"records" : [ {'+
                      '"attributes" : {'+
                        '"type" : "AggregateResult"'+
                      '},'+
                      '"expr0" : 100'+
                    '} ]'+
                  '}';
            }
            when 'FieldDefinition' {
                body = '{'+
                    '"totalSize" : 1,'+
                    '"done" : true,'+
                    '"records" : [ {'+
                      '"attributes" : {'+
                        '"type" : "FieldDefinition",'+
                        '"url" : "/services/data/v54.0/sobjects/FieldDefinition/id"'+
                      '},'+
                      '"QualifiedApiName" : "nisc_Bypass_Rules_for_Migrations__c"'+
                    '} ]'+
                  '}';
            }
            when 'ObjectPermissions' {
                body = '{'+
                    '"totalSize" : 1,'+
                    '"done" : true,'+
                    '"records" : [ {'+
                      '"attributes" : {'+
                        '"type" : "ObjectPermissions",'+
                        '"url" : "/services/data/v54.0/sobjects/ObjectPermissions/1105f000057M8PPAA0"'+
                      '},'+
                      '"PermissionsRead" : true'+
                    '} ]'+
                '}';
            }
            when 'Account' {
                body = '{'+
                    '"totalSize" : 1,'+
                    '"done" : true,'+
                    '"records" : [ {'+
                      '"attributes" : {'+
                        '"type" : "AggregateResult"'+
                      '},'+
                      '"expr0" : 90,'+
                      '"expr1" : "2022-05-03T13:04:42.000+0000",'+
                      '"expr2" : "2022-05-03T13:04:43.000+0000"'+
                    '} ]'+
                  '}';
            }
            when 'Userlicense' {
                body = '{'+
                    '"totalSize" : 1,'+
                    '"done" : true,'+
                    '"records" : [ {'+
                      '"attributes" : {'+
                        '"type" : "UserLicense",'+
                        '"url" : "/services/data/v54.0/sobjects/UserLicense/id"'+
                      '},'+
                      '"Name" : "Salesforce Platform",'+
                      '"Status" : "Active",'+
                      '"TotalLicenses" : 500,'+
                      '"UsedLicenses" : 14'+
                    '} ]'+
                  '}';
            }
            when 'nihrm__Processor__c' {
                body = '{'+
                    '"totalSize" : 1,'+
                    '"done" : true,'+
                    '"records" : [ {'+
                      '"attributes" : {'+
                        '"type" : "nihrm__Processor__c",'+
                        '"url" : "/services/data/v54.0/sobjects/nihrm__Processor__c/id"'+
                      '},'+
                      '"Id" : "processorId",'+
                      '"Name" : "Processor",'+
                      '"nihrm__NextJobStart__c" : null'+
                    '} ]'+
                  '}';
            }
            when 'nihrm__ProcessorJob__c' {
                if (req.getEndpoint().contains('count(Id)')) {
                    body = '{'+
                    '"totalSize" : 1,'+
                    '"done" : true,'+
                    '"records" : [ {'+
                      '"attributes" : {'+
                        '"type" : "AggregateResult"'+
                      '},'+
                      '"expr0" : 100'+
                    '} ]'+
                  '}';
                } else {
                    body = '{'+
                    '"totalSize" : 1,'+
                    '"done" : true,'+
                    '"records" : [ {'+
                      '"attributes" : {'+
                        '"type" : "AggregateResult"'+
                      '},'+
                      '"nihrm__Processor__c" : "processorId",'+
                      '"expr0" : "2022-05-04T10:25:05.000+0000",'+
                      '"nihrm__Status__c" : "Completed"'+
                    '} ]'+
                  '}';
                }
            }
            when 'nihrm__LocationIntegrationSettings__c' {
                body = '{'+
                    '"totalSize" : 1,'+
                    '"done" : true,'+
                    '"records" : [ {'+
                      '"attributes" : {'+
                        '"type" : "nihrm__LocationIntegrationSettings__c",'+
                        '"url" : "/services/data/v54.0/sobjects/nihrm__LocationIntegrationSettings__c/id"'+
                      '},'+
                      '"Id" : "integrationId",'+
                      '"nihrm__Location__r" : {'+
                        '"attributes" : {'+
                          '"type" : "nihrm__Location__c",'+
                          '"url" : "/services/data/v54.0/sobjects/nihrm__Location__c/id"'+
                        '},'+
                        '"Name" : "Test Property",'+
                        '"Id" : "propertyId"'+
                      '},'+
                      '"Name" : "PropertyIntegration",'+
                      '"nihrm__Integration__r" : {'+
                        '"attributes" : {'+
                          '"type" : "nihrm__Integration__c",'+
                          '"url" : "/services/data/v54.0/sobjects/nihrm__Integration__c/id"'+
                        '},'+
                        '"Name" : "Opera"'+
                      '},'+
                      '"nihrm__IsActive__c" : true,'+
                      '"nihrm__IntegrationMode__c" : "Live",'+
                      '"nihrm__DefaultIntegrationTaskType__c" : "PMS Integration",'+
                      '"RecordType" : {'+
                        '"attributes" : {'+
                          '"type" : "RecordType",'+
                          '"url" : "/services/data/v54.0/sobjects/RecordType/id"'+
                        '},'+
                        '"Name" : "Integration"'+
                      '},'+
                      '"nihrm__ChannelLocationId__c" : null,'+
                      '"nihrm__SendProspectStatus__c" : false,'+
                      '"nihrm__SendTentativeStatus__c" : false,'+
                      '"nihrm__OperaOutboundTentativeMapping__c" : "Deduct",'+
                      '"nihrm__SendDaysDateType__c" : "Departure Date",'+
                      '"nihrm__SendDaysPast__c" : 0.0,'+
                      '"nihrm__SendDaysFuture__c" : 9999.0,'+
                      '"nihrm__SendRateDetail__c" : "Exclusive Guestroom",'+
                      '"nihrm__OutboundMarketCodeMapping__c" : "Market Segment",'+
                      '"nihrm__OutboundSourceCodeMapping__c" : "Lead Source",'+
                      '"nihrm__OutboundChannelCodeMapping__c" : "Housing Method",'+
                      '"nihrm__OperaSendControlBlockLocally__c" : false,'+
                      '"nihrm__SendSecondaryLanguage__c" : false,'+
                      '"nihrm__SendEventOnlyBookings__c" : false,'+
                      '"nihrm__ExcludedMarketSegments__c" : null,'+
                      '"nihrm__ExcludedBookingTypes__c" : null,'+
                      '"nihrm__AllowROHOutbound__c" : false,'+
                      '"nihrm__UpdatePickupFromPMSRoomBlocks__c" : false,'+
                      '"nihrm__PickupOccDist__c" : false,'+
                      '"nihrm__IgnoreNonInitUpdateCode__c" : false,'+
                      '"nihrm__AllowCancellations__c" : false,'+
                      '"nihrm__AllowCutoffDateChanges__c" : false,'+
                      '"nihrm__AllowInboundRohUpdates__c" : false,'+
                      '"nihrm__SetResNightRateFrom__c" : "Posted Guestroom Revenue",'+
                      '"nihrm__IncludeTentativeNonDeduct__c" : false,'+
                      '"nihrm__PmsIdRequired__c" : false,'+
                      '"nihrm__PmsIdEnforceUniquePast__c" : false,'+
                      '"nihrm__PmsIdRequiredEO__c" : false,'+
                      '"nihrm__PmsIdMinLength__c" : null,'+
                      '"nihrm__PmsIdMaxLength__c" : null,'+
                      '"nihrm__MarkPickupComplete__c" : false,'+
                      '"nihrm__DaysAfterDeparture__c" : 2.0,'+
                      '"nihrm__PostedRevenueMapping1__c" : "GUESTROOM",'+
                      '"nihrm__PostedRevenueMapping2__c" : "FOOD&BEV",'+
                      '"nihrm__PostedRevenueMapping3__c" : "OTHER",'+
                      '"nihrm__PostedRevenueMapping4__c" : null,'+
                      '"nihrm__PostedRevenueMapping5__c" : null,'+
                      '"nihrm__OperaOutboundSellLimitMapping__c" : "Forecast"'+
                    '} ]'+
                  '}';
            }
            when 'SandboxProcess' {
                body = '{'+
                    '"size" : 1,'+
                    '"totalSize" : 1,'+
                    '"done" : true,'+
                    '"queryLocator" : null,'+
                    '"entityTypeName" : "SandboxProcess",'+
                    '"records" : [ {'+
                      '"attributes" : {'+
                        '"type" : "SandboxProcess",'+
                        '"url" : "/services/data/v54.0/tooling/sobjects/SandboxProcess/id"'+
                      '},'+
                      '"Id" : "sbId",'+
                      '"SandboxName" : "TESTSB",'+
                      '"ActivatedDate" : "2022-04-14T14:17:29.000+0000",'+
                      '"Description" : "a test sandbox for querying records",'+
                      '"SandboxOrganization" : "sbId",'+
                      '"Status" : "Completed",'+
                      '"LicenseType" : "DEVELOPER",'+
                      '"EndDate" : "2022-04-14T14:17:29.000+0000"'+
                    '} ]'+
                  '}';
            }
            when 'nihrm__Item__c' {
                body = '{'+
                    '"totalSize" : 1,'+
                    '"done" : true,'+
                    '"records" : [ {'+
                      '"attributes" : {'+
                        '"type" : "AggregateResult"'+
                      '},'+
                      '"expr0" : 14,'+
                      '"Name" : "Property Item",'+
                      '"nihrm__Location__c" : "a0Y5f000000FX1bEAG"'+
                    '} ]'+
                  '}';
            }
            when 'Report' {
                body = '{'+
                    '"totalSize" : 1,'+
                    '"done" : true,'+
                    '"records" : [ {'+
                      '"attributes" : {'+
                        '"type" : "AggregateResult"'+
                      '},'+
                      '"expr0" : 13,'+
                      '"Name" : "Account/Contact/Activity Reports"'+
                    '} ]'+
                  '}';
            }
            when 'nihrm__SetupValue__c' {
                body = '{'+
                    '"totalSize" : 1,'+
                    '"done" : true,'+
                    '"records" : [ {'+
                      '"attributes" : {'+
                        '"type" : "nihrm__SetupValue__c",'+
                        '"url" : "/services/data/v54.0/sobjects/nihrm__SetupValue__c/id"'+
                      '},'+
                      '"Name" : "SV Name",'+
                      '"nihrm__SetupValueType__c" : "BookingStatusReason",'+
                      '"nihrm__Location__r" : {'+
                        '"attributes" : {'+
                          '"type" : "nihrm__Location__c",'+
                          '"url" : "/services/data/v54.0/sobjects/nihrm__Location__c/id"'+
                        '},'+
                        '"Name" : "S&E ShipIt! Property"'+
                      '},'+
                      '"nihrm__MasterSource__c" : "Property",'+
                      '"nihrm__SortOrder__c" : 0.0,'+
                      '"nihrm__IsActive__c" : true,'+
                      '"CreatedBy" : {'+
                        '"attributes" : {'+
                          '"type" : "User",'+
                          '"url" : "/services/data/v54.0/sobjects/User/id"'+
                        '},'+
                        '"Name" : "SEadmin r44tf"'+
                      '},'+
                      '"CreatedDate" : "2021-11-17T17:09:12.000+0000",'+
                      '"LastModifiedBy" : {'+
                        '"attributes" : {'+
                          '"type" : "User",'+
                          '"url" : "/services/data/v54.0/sobjects/User/id"'+
                        '},'+
                        '"Name" : "SEadmin r44tf"'+
                      '},'+
                      '"LastModifiedDate" : "2022-03-03T10:28:21.000+0000"'+
                    '} ]'+
                  '}';
            }
            when 'nihrm__System__c' {
                body ='{'+
                    '"totalSize" : 1,'+
                    '"done" : true,'+
                    '"records" : [ {'+
                      '"attributes" : {'+
                        '"type" : "nihrm__System__c",'+
                        '"url" : "/services/data/v54.0/sobjects/nihrm__System__c/id"'+
                      '},'+
                      '"Name" : "Test System",'+
                      '"nihrm__SystemType__r" : {'+
                        '"attributes" : {'+
                          '"type" : "nihrm__SystemType__c",'+
                          '"url" : "/services/data/v54.0/sobjects/nihrm__SystemType__c/id"'+
                        '},'+
                        '"Name" : "Test System"'+
                      '},'+
                      '"CreatedDate" : "2021-10-29T18:30:03.000+0000",'+
                      '"CreatedBy" : {'+
                        '"attributes" : {'+
                          '"type" : "User",'+
                          '"url" : "/services/data/v54.0/sobjects/User/id"'+
                        '},'+
                        '"Name" : "Test User"'+
                      '},'+
                      '"LastModifiedDate" : "2022-03-09T07:12:38.000+0000",'+
                      '"LastModifiedBy" : {'+
                        '"attributes" : {'+
                          '"type" : "User",'+
                          '"url" : "/services/data/v54.0/sobjects/User/id"'+
                        '},'+
                        '"Name" : "Test User"'+
                      '}'+
                    '} ]'+
                  '}';
            }
            when 'ValidationRule' {
                body = '{'+
                    '"size" : 1,'+
                    '"totalSize" : 1,'+
                    '"done" : true,'+
                    '"queryLocator" : null,'+
                    '"entityTypeName" : "ValidationRule",'+
                    '"records" : [ {'+
                      '"attributes" : {'+
                        '"type" : "ValidationRule",'+
                        '"url" : "/services/data/v54.0/tooling/sobjects/ValidationRule/id"'+
                      '},'+
                      '"ManageableState" : "installed",'+
                      '"NamespacePrefix" : "nihrm",'+
                      '"ValidationName" : "Test Rule",'+
                      '"Active" : false,'+
                      '"Description" : "Description",'+
                      '"EntityDefinition" : {'+
                        '"attributes" : {'+
                          '"type" : "EntityDefinition",'+
                          '"url" : "/services/data/v54.0/tooling/sobjects/EntityDefinition/id"'+
                        '},'+
                        '"DeveloperName" : "Location"'+
                      '},'+
                      '"ErrorDisplayField" : "Activity Type",'+
                      '"ErrorMessage" : "Error",'+
                      '"CreatedDate" : "2021-10-29T18:30:03.000+0000",'+
                      '"CreatedBy" : {'+
                        '"attributes" : {'+
                          '"type" : "User",'+
                          '"url" : "/services/data/v54.0/tooling/sobjects/User/id"'+
                        '},'+
                        '"Name" : "Test User"'+
                      '},'+
                      '"LastModifiedDate" : "2021-10-29T18:30:03.000+0000",'+
                      '"LastModifiedBy" : {'+
                        '"attributes" : {'+
                          '"type" : "User",'+
                          '"url" : "/services/data/v54.0/tooling/sobjects/User/id"'+
                        '},'+
                        '"Name" : "Test User"'+
                      '}'+
                    '} ]'+
                  '}';
            }
            when 'WorkFlowRule' {
                body = '{'+
                    '"size" : 1,'+
                    '"totalSize" : 1,'+
                    '"done" : true,'+
                    '"queryLocator" : null,'+
                    '"entityTypeName" : "WorkflowRule",'+
                    '"records" : [ {'+
                      '"attributes" : {'+
                        '"type" : "WorkflowRule",'+
                        '"url" : "/services/data/v54.0/tooling/sobjects/WorkflowRule/id"'+
                      '},'+
                      '"ManageableState" : "installed",'+
                      '"NamespacePrefix" : "",'+
                      '"Name" : "WF Rule",'+
                      '"TableEnumOrId" : "nihrm__GuestroomType__c",'+
                      '"CreatedDate" : "2021-10-29T18:30:03.000+0000",'+
                      '"CreatedBy" : {'+
                        '"attributes" : {'+
                          '"type" : "User",'+
                          '"url" : "/services/data/v54.0/tooling/sobjects/User/id"'+
                        '},'+
                        '"Name" : "Test User"'+
                      '},'+
                      '"LastModifiedDate" : "2021-10-29T18:30:03.000+0000",'+
                      '"LastModifiedBy" : {'+
                        '"attributes" : {'+
                          '"type" : "User",'+
                          '"url" : "/services/data/v54.0/tooling/sobjects/User/id"'+
                        '},'+
                        '"Name" : "Test User"'+
                      '}'+
                    '} ]'+
                  '}';
            }
            when 'CustomField' {
                body = '{'+
                    '"size" : 1,'+
                    '"totalSize" : 1,'+
                    '"done" : true,'+
                    '"queryLocator" : null,'+
                    '"entityTypeName" : "CustomField",'+
                    '"records" : [ {'+
                      '"attributes" : {'+
                        '"type" : "CustomField",'+
                        '"url" : "/services/data/v54.0/tooling/sobjects/CustomField/00N5f00000MCj36EAD"'+
                      '},'+
                      '"ManageableState" : "installed",'+
                      '"NamespacePrefix" : "",'+
                      '"DeveloperName" : "Test Name",'+
                      '"EntityDefinition" : {'+
                        '"attributes" : {'+
                          '"type" : "EntityDefinition",'+
                          '"url" : "/services/data/v54.0/tooling/sobjects/EntityDefinition/Account"'+
                        '},'+
                        '"DeveloperName" : "Account"'+
                      '},'+
                      '"TableEnumOrId" : "Account",'+
                      '"CreatedDate" : "2021-10-29T18:30:03.000+0000",'+
                      '"CreatedBy" : {'+
                        '"attributes" : {'+
                          '"type" : "User",'+
                          '"url" : "/services/data/v54.0/tooling/sobjects/User/id"'+
                        '},'+
                        '"Name" : "Test User"'+
                      '},'+
                      '"LastModifiedDate" : "2021-10-29T18:30:03.000+0000",'+
                      '"LastModifiedBy" : {'+
                        '"attributes" : {'+
                          '"type" : "User",'+
                          '"url" : "/services/data/v54.0/tooling/sobjects/User/id"'+
                        '},'+
                        '"Name" : "Test User"'+
                      '}'+
                    '} ]'+
                  '}';
            }
            when 'apexclass' {
                body = '{'+
                    '"size" : 1,'+
                    '"totalSize" : 1,'+
                    '"done" : true,'+
                    '"queryLocator" : null,'+
                    '"entityTypeName" : "ApexClass",'+
                    '"records" : [ {'+
                      '"attributes" : {'+
                        '"type" : "ApexClass",'+
                        '"url" : "/services/data/v54.0/tooling/sobjects/ApexClass/id"'+
                      '},'+
                      '"Name" : "Class Name",'+
                      '"ApiVersion" : 37.0,'+
                      '"Body" : "(hidden)",'+
                      '"Status" : "Active",'+
                      '"CreatedDate" : "2021-10-29T18:30:03.000+0000",'+
                      '"CreatedBy" : {'+
                        '"attributes" : {'+
                          '"type" : "User",'+
                          '"url" : "/services/data/v54.0/tooling/sobjects/User/id"'+
                        '},'+
                        '"Name" : "Test User"'+
                      '},'+
                      '"LastModifiedDate" : "2021-10-29T18:30:03.000+0000",'+
                      '"LastModifiedBy" : {'+
                        '"attributes" : {'+
                          '"type" : "User",'+
                          '"url" : "/services/data/v54.0/tooling/sobjects/User/id"'+
                        '},'+
                        '"Name" : "Test User"'+
                      '}'+
                    '} ]'+
                  '}';
            }
            when 'processdefinition' {
                body = '{'+
                    '"totalSize" : 1,'+
                    '"done" : true,'+
                    '"records" : [ {'+
                      '"attributes" : {'+
                        '"type" : "ProcessDefinition",'+
                        '"url" : "/services/data/v54.0/sobjects/ProcessDefinition/id"'+
                      '},'+
                      '"Name" : "test approval process",'+
                      '"Description" : "This is the description",'+
                      '"State" : "Inactive",'+
                      '"TableEnumOrId" : "WorkPlan",'+
                      '"CreatedBy" : {'+
                        '"attributes" : {'+
                          '"type" : "User",'+
                          '"url" : "/services/data/v54.0/sobjects/User/id"'+
                        '},'+
                        '"Name" : "Test User"'+
                      '},'+
                      '"CreatedDate" : "2022-04-20T18:44:08.000+0000",'+
                      '"LastModifiedBy" : {'+
                        '"attributes" : {'+
                          '"type" : "User",'+
                          '"url" : "/services/data/v54.0/sobjects/User/id"'+
                        '},'+
                        '"Name" : "Test User"'+
                      '},'+
                      '"LastModifiedDate" : "2022-04-21T14:02:53.000+0000"'+
                    '} ]'+
                  '}';
            }
            when 'apextrigger' {
                body = '{'+
                    '"size" : 1,'+
                    '"totalSize" : 1,'+
                    '"done" : true,'+
                    '"queryLocator" : null,'+
                    '"entityTypeName" : "ApexTrigger",'+
                    '"records" : [ {'+
                      '"attributes" : {'+
                        '"type" : "ApexTrigger",'+
                        '"url" : "/services/data/v54.0/tooling/sobjects/ApexTrigger/id"'+
                      '},'+
                      '"Name" : "Test Trigger",'+
                      '"ApiVersion" : 38.0,'+
                      '"EntityDefinition" : {'+
                        '"attributes" : {'+
                          '"type" : "EntityDefinition",'+
                          '"url" : "/services/data/v54.0/tooling/sobjects/EntityDefinition/Account"'+
                        '},'+
                        '"DeveloperName" : "Test Trigger"'+
                      '},'+
                      '"Body" : "(hidden)",'+
                      '"Status" : "Active",'+
                      '"CreatedDate" : "2021-10-29T18:30:03.000+0000",'+
                      '"CreatedBy" : {'+
                        '"attributes" : {'+
                          '"type" : "User",'+
                          '"url" : "/services/data/v54.0/tooling/sobjects/User/id"'+
                        '},'+
                        '"Name" : "Test User"'+
                      '},'+
                      '"LastModifiedDate" : "2021-10-29T18:30:03.000+0000",'+
                      '"LastModifiedBy" : {'+
                        '"attributes" : {'+
                          '"type" : "User",'+
                          '"url" : "/services/data/v54.0/tooling/sobjects/User/id"'+
                        '},'+
                        '"Name" : "Test User"'+
                      '}'+
                    '} ]'+
                  '}';
            }
            when 'CustomObject' {
                body = '{'+
                    '"size" : 1,'+
                    '"totalSize" : 1,'+
                    '"done" : true,'+
                    '"queryLocator" : null,'+
                    '"entityTypeName" : "CustomObject",'+
                    '"records" : [ {'+
                      '"attributes" : {'+
                        '"type" : "CustomObject",'+
                        '"url" : "/services/data/v54.0/tooling/sobjects/CustomObject/id"'+
                      '},'+
                      '"Id" : "id",'+
                      '"DeveloperName" : "Test Object",'+
                      '"Description" : null,'+
                      '"NamespacePrefix" : "",'+
                      '"ManageableState" : "installed",'+
                      '"SharingModel" : "Edit",'+
                      '"CreatedDate" : "2021-10-29T18:30:03.000+0000",'+
                      '"CreatedBy" : {'+
                        '"attributes" : {'+
                          '"type" : "User",'+
                          '"url" : "/services/data/v54.0/tooling/sobjects/User/id"'+
                        '},'+
                        '"Name" : "Test User"'+
                      '},'+
                      '"LastModifiedDate" : "2021-10-29T18:30:03.000+0000",'+
                      '"LastModifiedBy" : {'+
                        '"attributes" : {'+
                          '"type" : "User",'+
                          '"url" : "/services/data/v54.0/tooling/sobjects/User/id"'+
                        '},'+
                        '"Name" : "Test User"'+
                      '}'+
                    '} ]'+
                  '}';
            }
            when 'CustomTab' {
                body = '{'+
                    '"size" : 1,'+
                    '"totalSize" : 1,'+
                    '"done" : true,'+
                    '"queryLocator" : null,'+
                    '"entityTypeName" : "CustomTab",'+
                    '"records" : [ {'+
                      '"attributes" : {'+
                        '"type" : "CustomTab",'+
                        '"url" : "/services/data/v54.0/tooling/sobjects/CustomTab/id"'+
                      '},'+
                      '"Description" : "Test Tab",'+
                      '"ManageableState" : "installed",'+
                      '"MasterLabel" : "Test Tab",'+
                      '"NamespacePrefix" : "nihrm",'+
                      '"Type" : "apexPage",'+
                      '"Url" : null,'+
                      '"CreatedDate" : "2021-10-29T18:30:03.000+0000",'+
                      '"CreatedBy" : {'+
                        '"attributes" : {'+
                          '"type" : "User",'+
                          '"url" : "/services/data/v54.0/tooling/sobjects/User/id"'+
                        '},'+
                        '"Name" : "Test User"'+
                      '},'+
                      '"LastModifiedDate" : "2021-10-29T18:30:03.000+0000",'+
                      '"LastModifiedBy" : {'+
                        '"attributes" : {'+
                          '"type" : "User",'+
                          '"url" : "/services/data/v54.0/tooling/sobjects/User/id"'+
                        '},'+
                        '"Name" : "Test User"'+
                      '}'+
                    '} ]'+
                  '}';
            }
            when 'nihrm__DocumentTemplate__c' {
                body = '{'+
                    '"totalSize" : 1,'+
                    '"done" : true,'+
                    '"records" : [ {'+
                      '"attributes" : {'+
                        '"type" : "AggregateResult"'+
                      '},'+
                      '"expr0" : 2,'+
                      '"nihrm__Location__c" : null,'+
                      '"nihrm__TemplateType__c" : "Advanced Booking"'+
                    '} ]'+
                  '}';
            }
		}

        res.setBody(body);
        res.setStatusCode(200);
        return res;
    }
}