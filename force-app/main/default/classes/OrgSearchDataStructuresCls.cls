/************************************************************************************************
Name            : OrgSearchDataStructureCls
Author          : Michael Pedro
Last Mod Date   : 05/05/2022
Last Mod By     : Michael Pedro
Description     : Models for org search json responses
*************************************************************************************************/

public with sharing class OrgSearchDataStructuresCls {

    public class Attributes {
        public String type;
        public String url;
    }

    public class RelatedRecord {
        public Attributes attributes;
        public String Name;
        public String Id;
    }

    public class OrganizationInfo {
        public Integer totalSize;
        public Boolean done;
        public List<OrgInfoRecord> records;
    }

    public class OrgInfoRecord {
        public Attributes attributes;
        public String Id;
        public String Name;
        public String InstanceName;
        public String DefaultAccountAccess;
        public DateTime CreatedDate;
        public DateTime LastModifiedDate;

        public OrgInfo__c createSFObject() {
            OrgInfo__c info = new OrgInfo__c();
            info.OrgId__c = this.Id;
            info.OrgName__c = this.Name;
            info.InstanceName__c = this.InstanceName;
            info.DefaultAccountAccess__c = this.DefaultAccountAccess;
            info.OrgCreatedDate__c = this.CreatedDate;
            info.OrgLastModifiedDate__c = this.LastModifiedDate;

            return info;
        }
    }

    public class ByPassRuleInfo {
        public Integer totalSize;
        public Boolean done;
        public List<ByPassRecord> records;
    }

    public class ByPassRecord {
        public Attributes attributes;
        public String QualifiedApiName;
    }

    public class PermCountInfo {
        public Integer totalSize;
        public Boolean done;
        public List<PermCountRecord> records;
    }

    public class PermCountRecord {
        public Attributes attributes;
        public Boolean PermissionsRead;
    }

    public class LogCountInfo {
        public Integer totalSize;
        public Boolean done;
        public List<LogCountRecord> records;
    }

    public class LogCountRecord {
        public Attributes attributes;
        public Integer expr0;
    }

    public class NIPublicInfo {
        public Integer totalSize;
        public Boolean done;
        public List<NIPublicRecord> records;
    }

    public class NIPublicRecord {
        public Attributes attributes;
        public Boolean EnableAccountSecurity;
        public Boolean AllowLimitedService;
        public Boolean UseCanvasReporting;
        public Boolean EnableNewGuestRoomExperience;
    }

    public class DefaultLocInfo {
        public Integer totalSize;
        public Boolean done;
        public List<DefaultLocRecord> records;
    }

    public class DefaultLocRecord {
        public Attributes attributes;
        public Integer expr0;
        public String DefaultLocationId;
    }

    public class LocHistoryInfo {
        public Integer totalSize;
        public Boolean done;
        public List<LocHistoryRecord> records;
    }

    public class LocHistoryRecord {
        public Attributes attributes;
        public DateTime CreatedDate;
        public String ParentId;
    }

    public class SystemLocInfo {
        public Integer totalSize;
        public Boolean done;
        public List<SystemLocRecord> records;
    }

    public class SystemLocRecord {
        public Attributes attributes;
        public Boolean IsEnabled;
        public String Location;
    }

    public class OrgRelatedInfo {
        public Integer totalSize;
        public Boolean done;
        public List<OrgRelatedRecord> records;
    }

    public class OrgRelatedRecord {
        public Attributes attributes;
        public String Location;
        public Integer expr0;
        public DateTime expr1;
        public DateTime expr2;
    }

    public class OrgLogInInfo {
        public Integer totalSize;
        public Boolean done;
        public List<OrgLoginRecord> records;
    }

    public class OrgLoginRecord {
        public Attributes attributes;
        public DateTime expr0;
    }

    public class OrgLimitRecord {
        public Integer Max {get; set;}
        public Integer Remaining {get; set;}

        public OrgLimit__c createSFObject() {
            OrgLimit__c l = new OrgLimit__c();
            l.MaxAllowed__c = this.Max;
            l.RemainingForLimit__c = this.Remaining;
            return l;
        }
    }

    public class OrgProcessorInfo {
        public Integer totalSize;
        public Boolean done;
        public List<OrgProcessorRecord> records;
    }

    public class OrgProcessorRecord {
        public Attributes attributes;
        public String Id;
        public String Name;
        public DateTime NextJobStart;

        public OrgProcessor__c createSFObject() {
            OrgProcessor__c op = new OrgProcessor__c();
            op.ProcessorId__c = this.Id;
            op.NextJobStart__c = this.NextJobStart;
            op.ProcessorName__c = this.Name;

            return op;
        }
    }

    public class OrgProcessorJobInfo {
        public Integer totalSize;
        public Boolean done;
        public List<OrgProcessorJobRecord> records;
    }

    public class OrgProcessorJobRecord {
        public Attributes attributes;
        public String Processor;
        public DateTime expr0;
        public String Status;
    }

    public class OrgSandboxInfo {
        public Integer size;
        public Integer totalSize;
        public Boolean done;
        public Object queryLocator;
        public String entityTypeName;
        public List<OrgSandboxRecord> records;
    }

    public class OrgSandboxRecord {
        public String Id;
        public String SandboxName;
        public string Description;
        public string Status;
        public string LicenseType;
        public DateTime ActivatedDate;

        public OrgSandbox__c createSFObject() {
            OrgSandbox__c sb = new OrgSandbox__c();
            sb.ActivatedDate__c = this.ActivatedDate;
            sb.Description__c = this.Description;
            sb.LicenseType__c = this.LicenseType;
            sb.SandboxName__c = this.SandboxName;
            sb.SandboxStatus__c = this.Status;
            sb.SandboxId__c = this.Id;

            return sb;
        }
    }

    public class OrgPackageInfo {
        public Integer size;
        public Integer totalSize;
        public Boolean done;
        public Object queryLocator;
        public String entityTypeName;
        public List<OrgPackageRecord> records;
    }

    public class OrgPackageRecord {
        public Attributes attributes;
        public String Id;
        public String SubscriberPackageId;
        public SubscriberPackageInfo SubscriberPackage;
        public SubscriberPackageVersionInfo SubscriberPackageVersion;
    }
    
    public class SubscriberPackageInfo {
        public Attributes attributes;
        public String NamespacePrefix;
        public String Name;

        public OrgPackage__c createSFObject() {
            OrgPackage__c orgPack = new OrgPackage__c();
            orgPack.PackageName__c = this.Name;
            orgPack.NamespacePrefix__c = this.NamespacePrefix;
            return orgPack;
        }
    }

    public class SubscriberPackageVersionInfo {
        public Attributes attributes;
        public String Id;
        public String Name;
        public boolean IsManaged;
        public Integer MajorVersion;
        public Integer MinorVersion;
        public Integer PatchVersion;
        public Integer BuildNumber;

        public OrgPackage__c updatePackageInfo(OrgPackage__c orgPack) {
            orgPack.VersionName__c = this.Name;
            orgPack.MinorVersion__c = this.MinorVersion;
            orgPack.MajorVersion__c = this.MajorVersion;
            orgPack.IsManaged__c = this.IsManaged;
            return orgPack;
        }
    }

    public class OrgPublicUserInfo {
        public Integer totalSize;
        public Boolean done;
        public List<OrgPublicUserRecord> records;   
    }
    
    public class OrgPublicUserRecord {
            public Attributes attributes;
            public String SetupOwnerId;
            public String DefaultLocationId;

            public OrgUser__c updateUserRecord(OrgUser__c u) {
                u.UserDefaultProperty__c = this.DefaultLocationId;
                return u;
            }
        }
    

    public class OrgPropertyInfo {
        public Integer totalSize;
        public Boolean done;
        public List<OrgPropertyRecord> records;
    }

    public class OrgPropertyRecord {
        public Attributes attributes;
        public String Id;
        public String Name;
        public Boolean IsActive;
        public Boolean DisableBookingDaySnapshot;
        public Boolean IsLimitedService;
        public String Abbreviation;
        public String PropertyKey;
        public DateTime CreatedDate;
        public RelatedRecord CreatedBy;
        public DateTime LastModifiedDate;
        public DateTime ExtractedDate;
        public RelatedRecord LastModifiedBy;
        public String NIHRMMigrations_ExternalID;
        public String AvailabilityScreenView;
        public String AddressLine1;
        public String AddressLine2;
        public String AddressLine3;
        public String City;
        public String StateProvince;
        public String CountryCode;
        public String PostalCode;
        public String Phone;
        public String PropertyCode;
        public Boolean EnableHospitalityDiagramming;

        public OrgProperty__c createSFObject() {
            OrgProperty__c prop = new OrgProperty__c();
            prop.PropertyName__c = this.Name;
            prop.PropertyId__c = this.Id;
            prop.Active__c = this.IsActive;
            prop.CendynId__c = this.PropertyKey;
            prop.ExtractedDate__c = this.ExtractedDate;
            prop.Abbreviation__c = this.Abbreviation;
            prop.AddressLine1__c = this.AddressLine1;
            prop.AddressLine2__c = this.AddressLine2;
            prop.AddressLine3__c = this.AddressLine3;
            prop.AHDEnabled__c = this.EnableHospitalityDiagramming;
            prop.AvailabilityScreenView__c = this.AvailabilityScreenView;
            prop.DisableBookingDaySnapshot__c = this.DisableBookingDaySnapshot;
            prop.IsLimitedService__c = this.IsLimitedService != null ? this.IsLimitedService : false;
            prop.CreatedDate__c = this.CreatedDate;
            prop.CreatedBy__c = this.CreatedBy.Name;
            prop.LastModifiedDate__c = this.LastModifiedDate;
            prop.LastModifiedBy__c = this.LastModifiedBy.Name;
            prop.MigrationExternalId__c = this.NIHRMMigrations_ExternalID;
            prop.City__c = this.City;
            prop.Phone__c = this.Phone;
            prop.PostalCode__c = this.PostalCode;
            prop.CountryCode__c = this.CountryCode;
            prop.StateProvince__c = this.StateProvince;
            prop.PMSLocationCode__c = this.PropertyCode;

            return prop;
        }
    }

    public class OrgLicenseInfo {
        public Integer totalSize;
        public Boolean done;
        public List<OrgLicenseRecord> records;
    }

    public class OrgLicenseRecord {
        public Attributes attributes;
        public String Name;
        public String Status;
        public Integer TotalLicenses;
        public Integer UsedLicenses;

        public OrgLicense__c createSFObject() {
            OrgLicense__c license = new OrgLicense__c();
            license.LicenseName__c = this.Name;
            license.LicenseStatus__c = this.Status;
            license.TotalLicenses__c = this.TotalLicenses;
            license.UsedLicenses__c = this.UsedLicenses;

            return license;
        }
    }

    public class OrgUserFrozenInfo {
        public Integer totalSize;
        public Boolean done;
        public List<OrgUserFrozenRecord> records;
    }

    public class OrgUserFrozenRecord {
        public Attributes attributes;
        public String UserId;
        public Boolean IsFrozen;
    }

    public class OrgUserInfo {
        public Integer totalSize;
        public Boolean done;
        public List<OrgUserRecord> records;
       
    }

    public class OrgUserRecord {
        public Attributes attributes;
        public String Id;
        public Boolean IsActive;
        public DateTime LastLoginDate;
        public string LanguageLocaleKey;
        public RelatedRecord Profile;
        public String UserType;
        public DateTime CreatedDate;
        public RelatedRecord CreatedBy;
        public DateTime LastModifiedDate;
        public RelatedRecord LastModifiedBy;
        public String DefaultProperty;
        public String FirstName;
        public String LastName;
        public String Email;
        public String TimeZoneSidKey;


        public OrgUser__c createSFObject() {
            OrgUser__c user = new OrgUser__c();
            user.Email__c = this.Email;
            user.FirstName__c = this.FirstName;
            user.LastName__c = this.LastName;
            user.UserLastLoginDate__c = this.LastLoginDate;
            user.Language__c = this.LanguageLocaleKey;
            if (this.Profile != null) {
                user.ProfileName__c = this.Profile.Name;
            }
            user.UserId__c = this.Id;
            user.UserType__c = this.UserType;
            user.UserTimeZone__c = this.TimeZoneSidKey;
            user.UserActive__c = this.IsActive;
            if (this.LastModifiedBy != null) {
                user.UserLastModifiedBy__c = this.LastModifiedBy.Name;
            }
            user.UserLastModifiedDate__c = this.LastModifiedDate;
            if (this.CreatedBy != null) {
                user.UserCreatedBy__c = this.CreatedBy.Name;
            }
            user.UserCreatedDate__c = this.CreatedDate;

            return user;
        }
    }

    public class OrgProfileInfo {
        public Integer totalSize;
        public Boolean done;
        public List<OrgProfileRecord> records;
    }

    public class OrgProfileRecord {
        public Attributes attributes;
        public String Name;
        public Boolean PermissionsLightningExperienceUser;
        public RelatedRecord CreatedBy;
        public Datetime CreatedDate;
        public RelatedRecord LastModifiedBy;
        public Datetime LastModifiedDate;
        public Boolean PermissionsForceTwoFactor;

        public OrgProfile__c createSFObject() {
            OrgProfile__c op = new OrgProfile__c();
            op.ProfileName__c = this.Name;
            if (this.LastModifiedBy != null) {
                op.ProfileLastModifiedBy__c = this.LastModifiedBy.Name;
            }
            op.ProfileCreatedBy__c = this.CreatedBy.Name;
            op.EnableLightningExperience__c = this.PermissionsLightningExperienceUser;
            op.EnableTwoFactorAuth__c = this.PermissionsForceTwoFactor;
            op.ProfileCreatedDate__c = this.CreatedDate;
            op.ProfileLastModifiedDate__c = this.LastModifiedDate;

            return op;
        }
    }

    public class OrgPropertyIntegrationInfo {
        public Integer totalSize;
        public Boolean done;
        public List<OrgPropertyIntegrationRecord> records;
    }

    public class OrgPropertyIntegrationRecord {
        public Attributes attributes;
        public String Id;
        public RelatedRecord Location;
        public String Name;
        public RelatedRecord Integration;
        public Boolean IsActive;
        public String IntegrationMode;
        public String DefaultIntegrationTaskType;
        public RelatedRecord RecordType;
        public String ChannelLocationId;
        public Boolean SendProspectStatus;
        public Boolean SendTentativeStatus;
        public String OperaOutboundTentativeMapping;
        public String SendDaysDateType;
        public Decimal SendDaysPast;
        public Decimal SendDaysFuture;
        public String SendRateDetail;
        public String OutboundMarketCodeMapping;
        public String OutboundSourceCodeMapping;
        public String OutboundChannelCodeMapping;
        public Boolean OperaSendControlBlockLocally;
        public Boolean SendSecondaryLanguage;
        public Boolean SendEventOnlyBookings;
        public String ExcludedMarketSegments;
        public String ExcludedBookingTypes;
        public Boolean AllowROHOutbound;
        public Boolean UpdatePickupFromPMSRoomBlocks;
        public Boolean PickupOccDist;
        public Boolean IgnoreNonInitUpdateCode;
        public Boolean AllowCancellations;
        public Boolean AllowCutoffDateChanges;
        public Boolean AllowInboundRohUpdates;
        public String SetResNightRateFrom;
        public Boolean IncludeTentativeNonDeduct;
        public Boolean PmsIdRequired;
        public Boolean PmsIdEnforceUniquePast;
        public Boolean PmsIdRequiredEO;
        public Decimal PmsIdMinLength;
        public Decimal PmsIdMaxLength;
        public Boolean MarkPickupComplete;
        public Decimal DaysAfterDeparture;
        public String PostedRevenueMapping1;
        public String PostedRevenueMapping2;
        public String PostedRevenueMapping3;
        public String PostedRevenueMapping4;
        public String PostedRevenueMapping5;
        public String OperaOutboundSellLimitMapping;

        public OrgPropertyIntegrationSetting__c createSFObject() {
            OrgPropertyIntegrationSetting__c setting = new OrgPropertyIntegrationSetting__c();
            setting.Active__c = this.IsActive;
            setting.AllowCancellations__c = this.AllowCancellations;
            setting.AllowCutoffDateChanges__c = this.AllowCutoffDateChanges;
            setting.AllowInboundRohUpdates__c = this.AllowInboundRohUpdates;
            setting.AllowOutboundROHRoomNights__c = this.AllowROHOutbound;
            setting.ChannelLocationId__c = this.ChannelLocationId;
            setting.DaysAfterDeparture__c = (Integer)this.DaysAfterDeparture;
            setting.DefaultIntegrationTaskType__c = this.DefaultIntegrationTaskType;
            setting.ExcludedMarketSegments__c = this.ExcludedMarketSegments;
            setting.ExcludedBookingTypes__c = this.ExcludedBookingTypes;
            setting.IgnoreNonInitialUpdateBlockCode__c = this.IgnoreNonInitUpdateCode;
            setting.IncludeTentativeNonDeduct__c = this.IncludeTentativeNonDeduct;
            setting.Integration__c = this.Integration != null ? this.Integration.Name : null;
            setting.IntegrationMode__c = this.IntegrationMode;
            setting.IntegrationName__c = this.Name;
            setting.MarkPickupComplete__c = this.MarkPickupComplete;
            setting.OperaOutboundSellLimitMapping__c = this.OperaOutboundSellLimitMapping;
            setting.OutboundTentativeMapping__c = this.OperaOutboundTentativeMapping;
            setting.OutboundMarketCodeMapping__c = this.OutboundMarketCodeMapping;
            setting.OutboundChannelOriginMapping__c = this.OutboundChannelCodeMapping;
            setting.OutboundSourceCodeMapping__c = this.OutboundSourceCodeMapping;
            setting.PickupOccupancyDistribution__c = this.PickupOccDist;
            setting.PMSIDGroupCodeEnforceUniquePast__c = this.PmsIdEnforceUniquePast;
            setting.PMSIDGroupCodeMaxLength__c = (Integer)this.PmsIdMaxLength;
            setting.PMSIDGroupCodeMinLength__c = (Integer)this.PmsIdMinLength;
            setting.PMSIDGroupCodeRequired__c = this.PmsIdRequired;
            setting.PMSIDGroupCodeRequiredEOBookings__c = this.PmsIdRequiredEO;
            setting.PostedFBRevenueMapping2__c = this.PostedRevenueMapping2;
            setting.PostedGuestroomRevenueMapping1__c = this.PostedRevenueMapping1;
            setting.PostedOtherRevenueMapping3__c = this.PostedRevenueMapping3;
            setting.PostedRevenueMapping4__c = this.PostedRevenueMapping4;
            setting.PostedRevenueMapping5__c = this.PostedRevenueMapping5;
            setting.PropertyId__c = this.Location.Id;
            setting.PropertyName__c = this.Location.Name;
            setting.RecordType__c = this.RecordType.Name;
            setting.SendControlBlockLocallyFlag__c = this.OperaSendControlBlockLocally;
            setting.SendDaysDateType__c = this.SendDaysDateType;
            setting.SendDaysFuture__c = (Integer)this.SendDaysFuture;
            setting.SendDaysPast__c = (Integer)this.SendDaysPast;
            setting.SendEventOnlyBookings__c = this.SendEventOnlyBookings;
            setting.SendProspectStatus__c = this.SendProspectStatus;
            setting.SendRateDetail__c = this.SendRateDetail;
            setting.SendTentativeStatus__c = this.SendTentativeStatus;
            setting.SetReservationNightRateFrom__c = this.SetResNightRateFrom;
            setting.UpdatePickupfromPMSRoomBlocks__c = this.UpdatePickupFromPMSRoomBlocks;

            return setting;
        }
    }

    public class ApexClassInfo {
        public Integer size;
        public Integer totalSize;
        public Boolean done;
        public Object queryLocator;
        public String entityTypeName;
        public List<ApexClassRecord> records;
    }

	public class ApexClassRecord {
        public Attributes attributes;
		public String Name;
		public Double ApiVersion;
		public String Body;
		public String Status;
		public DateTime CreatedDate;
		public RelatedRecord CreatedBy;
		public DateTime LastModifiedDate;
		public RelatedRecord LastModifiedBy;

        public OrgApexClass__c createSFObject() {
            OrgApexClass__c ac = new OrgApexClass__c();
            ac.APIVersion__c = this.APIVersion;
            ac.Body__c = this.Body?.length() >131070?this.Body.substring(0,131070):this.Body;
            ac.ClassCreatedBy__c = this.CreatedBy.Name;
            ac.ClassCreatedDate__c = this.CreatedDate;
            if (this.LastModifiedBy != null) {
                ac.ClassLastModifiedBy__c = this.LastModifiedBy.Name;
            }
            ac.ClassLastModifiedDate__c = this.LastModifiedDate;
            ac.ClassName__c = this.Name;
            ac.ClassStatus__c = this.Status;
            
            return ac;
        }
    }

    public class ApexTriggerInfo {
        public Integer size;
        public Integer totalSize;
        public Boolean done;
        public Object queryLocator;
        public String entityTypeName;
        public List<ApexTriggerRecord> records;
    }        
        
    public class ApexTriggerRecord {
        public Attributes attributes;
		public String Name;
		public Double ApiVersion;
		public EntityDefinition EntityDefinition;
		public String Body;
		public String Status;
		public DateTime CreatedDate;
		public RelatedRecord CreatedBy;
		public DateTime LastModifiedDate;
		public RelatedRecord LastModifiedBy;
        
        public OrgApexTrigger__c createSFObject() {
            OrgApexTrigger__c at = new OrgApexTrigger__c();
            at.APIVersion__c = this.APIVersion;
            at.Body__c = this.Body?.length() >131070?this.Body.substring(0,131070):this.Body;
            at.TriggerCreatedBy__c = this.CreatedBy.Name;
            at.TriggerCreatedDate__c = this.CreatedDate;
            if (this.LastModifiedBy != null) {
                at.TriggerLastModifiedBy__c = this.LastModifiedBy.Name;
            }
            at.TriggerLastModifiedDate__c = this.LastModifiedDate;
            at.TriggerName__c = this.Name;
            at.TriggerStatus__c = this.Status;
            
            return at;
        }
    }

    public class ApprovalProcessInfo {
        public Integer totalSize;
        public Boolean done;
        public List<ApprovalProcessRecord> records;
    }

    public class ApprovalProcessRecord {
        public Attributes attributes;
		public String Name;
		public String Description;
		public String State;
		public String TableEnumOrId;
		public RelatedRecord CreatedBy;
		public DateTime CreatedDate;
		public RelatedRecord LastModifiedBy;
		public DateTime LastModifiedDate;

        public OrgApprovalProcess__c createSFObject() {
            OrgApprovalProcess__c ap = new OrgApprovalProcess__c();
            ap.Description__c = this.Description;
            ap.ApprovalProcessObject__c = this.TableEnumOrId;
            ap.ApprovalProcessCreatedBy__c = this.CreatedBy.Name;
            ap.ApprovalProcessCreatedDate__c = this.CreatedDate;
            if (this.LastModifiedBy != null) {
                ap.ApprovalProcessLastModifiedBy__c = this.LastModifiedBy.Name;
            }
            ap.ApprovalProcessLastModifiedDate__c = this.LastModifiedDate;
            ap.ApprovalProcessName__c = this.Name;
            ap.ApprovalProcessState__c = this.State;
            
            return ap;
        }
    }

    public class CustomTabInfo {
        public Integer size;
        public Integer totalSize;
        public Boolean done;
        public Object queryLocator;
        public String entityTypeName;
        public List<CustomTabRecord> records;
    }        
        
    public class CustomTabRecord {
        public Attributes attributes;
		public String FullName;
		public String Description;
		public String ManageableState;
		public String MasterLabel;
		public String NamespacePrefix;
		public String Type;
		public String Url;
		public DateTime CreatedDate;
		public RelatedRecord CreatedBy;
		public DateTime LastModifiedDate;
		public RelatedRecord LastModifiedBy;
        
        public OrgCustomTab__c createSFObject() {
            OrgCustomTab__c ct = new OrgCustomTab__c();
            ct.FullName__c = this.FullName;
            ct.Description__c = this.Description;
            ct.ManageableState__c = this.ManageableState;
            ct.MasterLabel__c = this.MasterLabel;
            ct.NamespacePrefix__c = this.NamespacePrefix;
            ct.TabCreatedBy__c = this.CreatedBy.Name;
            ct.TabCreatedDate__c = this.CreatedDate;
            if (this.LastModifiedBy != null) {
                ct.TabLastModifiedBy__c = this.LastModifiedBy.Name;
            }
            ct.TabLastModifiedDate__c = this.LastModifiedDate;
            ct.Type__c = this.Type;
            ct.Url__c = this.Url;
            return ct;
        }
    }

    public class CustomObjectInfo {
        public Integer size;
        public Integer totalSize;
        public Boolean done;
        public Object queryLocator;
        public String entityTypeName;
        public List<CustomObjectRecord> records;
    }        
        
    public class CustomObjectRecord {
        public Attributes attributes;
		public String Id;
		public String DeveloperName;
		public String Description;
		public String NamespacePrefix;
		public String ManageableState;
		public String SharingModel;
		public DateTime CreatedDate;
		public RelatedRecord CreatedBy;
		public DateTime LastModifiedDate;
		public RelatedRecord LastModifiedBy;
        
        public OrgCustomObject__c createSFObject() {
            OrgCustomObject__c co = new OrgCustomObject__c();
            co.Description__c = this.Description?.length() >32766?this.Description.substring(0,32766):this.Description;
            co.NamespacePrefix__c = this.NamespacePrefix;
            co.ObjectName__c = this.DeveloperName;
            co.ManageableState__c = this.ManageableState;
            co.SharingModel__c = this.SharingModel;
            co.ObjectCreatedBy__c = this.CreatedBy.Name;
            co.ObjectCreatedDate__c = this.CreatedDate;
            if (this.LastModifiedBy != null) {
                co.ObjectLastModifiedBy__c = this.LastModifiedBy.Name;
            }
            co.ObjectLastModifiedDate__c = this.LastModifiedDate;
            
            return co;
        }
    }

    public class Value {
		public Object color {get;set;} 
		public Boolean default_Z {get;set;} // in json: default
		public Object description {get;set;} 
		public Object isActive {get;set;} 
		public String label {get;set;} 
		public Object urls {get;set;} 
		public String valueName {get;set;} 
    }

    public class ValueSetDefinition {
		public Boolean sorted {get;set;} 
		public List<Value> value {get;set;} 
    }

    public class ValueSet {
		public Object controllingField {get;set;} 
		public Object restricted {get;set;} 
		public ValueSetDefinition valueSetDefinition {get;set;} 
		public Object valueSetName {get;set;} 
		public Object valueSettings {get;set;} 
    }
    
    public class OrgCustomFieldInfo {
        public Integer size;
        public Integer totalSize;
        public Boolean done;
        public Object queryLocator;
        public String entityTypeName;
        public List<OrgCustomFieldRecord> records;
    }        
   
    public class OrgCustomFieldRecord {
        public Attributes attributes;
		public String ManageableState;
		public String NamespacePrefix;
		public String DeveloperName;
		public EntityDefinition EntityDefinition;
		public String TableEnumOrId;
		public DateTime CreatedDate;
		public RelatedRecord CreatedBy;
		public DateTime LastModifiedDate;
		public RelatedRecord LastModifiedBy;
   
        public OrgCustomField__c createSFObject() {
            OrgCustomField__c cf = new OrgCustomField__c();
            cf.ManageableState__c = this.ManageableState;
            cf.NamespacePrefix__c = this.NamespacePrefix;
            cf.Object__c = this.EntityDefinition != null?this.EntityDefinition.DeveloperName:this.TableEnumOrId;
            cf.FieldCreatedBy__c = this.CreatedBy.Name;
            cf.FieldCreatedDate__c = this.CreatedDate;
            cf.FieldName__c = this.DeveloperName;
            if (this.LastModifiedBy != null) {
                cf.FieldLastModifiedBy__c = this.LastModifiedBy.Name;
            }
            cf.FieldLastModifiedDate__c = this.LastModifiedDate;
            
            return cf;
        }
    }

    public class ProcessInfo {
        public Integer size;
        public Integer totalSize;
        public Boolean done;
        public Object queryLocator;
        public String entityTypeName;
        public List<ProcessRecord> records;
    }

    public class ProcessRecord {
        public Attributes attributes;
		public String ManageableState;
		public String MasterLabel;
		public Integer VersionNumber;
		public String Status;
		public DateTime CreatedDate;
		public RelatedRecord CreatedBy;
		public DateTime LastModifiedDate;
		public RelatedRecord LastModifiedBy;

        public OrgProcess__c createSFObject() {
            OrgProcess__c ap = new OrgProcess__c();
            ap.ManageableState__c = this.ManageableState;
            ap.ProcessName__c = this.MasterLabel;
            ap.Version__c = String.ValueOf(this.VersionNumber);
            ap.Status__c = this.Status;
            ap.ProcessCreatedBy__c = this.CreatedBy.Name;
            ap.ProcessCreatedDate__c = this.CreatedDate;
            if (this.LastModifiedBy != null) {
                ap.ProcessLastModifiedBy__c = this.LastModifiedBy.Name;
            }
            ap.ProcessLastModifiedDate__c = this.LastModifiedDate;
            
            return ap;
        }
    }

    public class OrgPropDocTemplateCountInfo {
        public Integer totalSize;
        public Boolean done;
        public List<OrgPropDocTemplateCountRecord> records;
    }

    public class OrgPropDocTemplateCountRecord {
        public Attributes attributes;
		public Integer expr0;
		public String Location;
		public String TemplateType;

        public OrgPropDocTemplateCount__c createSFObject() {
            OrgPropDocTemplateCount__c pdtc = new OrgPropDocTemplateCount__c();
            pdtc.Count__c = this.expr0;
            pdtc.PropertyId__c = this.Location;
            pdtc.TemplateType__c = this.TemplateType;
                        
            return pdtc;
        }
    }

/*

    public class EntityInfo {

        public Integer size;
        public Integer totalSize;
        public Boolean done;
        public Object queryLocator;
        public String entityTypeName;
        public List<Records> records;
    
        public class EntityRecord {
            public Attributes attributes;
            public String Label;
            public Integer Max;
            public Integer Remaining;
        }
    
        public OrgCustomTab__c createSFObject() {
            OrgCustomTab__c at = new OrgCustomTab__c();
            at.APIVersion__c = this.APIVersion;
            at.Body__c = this.Body;
            at.CustomTabCreatedBy__c = this.CreatedBy.Name;
            at.CustomTabCreatedDate__c = this.CreatedDate;
            if (this.LastModifiedBy != null) {
                at.CustomTabLastModifiedBy__c = this.LastModifiedBy.Name;
            }
            at.CustomTabLastModifiedDate__c = this.LastModifiedDate;
            at.CustomTabName__c = this.Name;
            at.CustomTabStatus__c = this.Status;
            at.CustomTabId__c = this.Id;

            return at;
        }
    }
*/


    public class OrgCustObjLimitInfo {
        public Integer size;
        public Integer totalSize;
        public Boolean done;
        public Object queryLocator;
        public String entityTypeName;
        public List<OrgCustObjLimitRecord> records;

    }

    public class OrgCustObjLimitRecord {
        public Attributes attributes;
		public String Id;
		public String DeveloperName;
		public String Description;
		public String NamespacePrefix;
		public String ManageableState;
		public String SharingModel;
		public DateTime CreatedDate;
		public RelatedRecord CreatedBy;
		public DateTime LastModifiedDate;
		public RelatedRecord LastModifiedBy;
        
        
     /*   public String Id;
        public String APIName;
        public String CustomObjId;
        public String Decimal;
        public String DefaultValued;
        public String DeleteConstraint;
        public String Description;
        public String FieldName;
        public String Formula;
        public String HelpText;
        public String Length;
        public string LimitCreatedBy;
        public DateTime LimitCreatedDate;
        public string LimitModifiedBy;
        public DateTime LimitModifiedDate;
        public string LimitName;
        public string ManageableState;
        public string Max;
        public string NamespacePrefix;
        public string Obect;
        public string PicklistValues;
        public string RelatedTo;
        public string Remaining;
        public string Type;*/

        public OrgCustObjLimit__c createSFObject() {
            OrgCustObjLimit__c col = new OrgCustObjLimit__c();
          /*  col.APIName__c = this.APIName;
            col.CustomObjId__c = this.CustomObjId;
            col.Decimal__c = this.Decimal;
            col.DefaultValued__c = this.DefaultValued;
            col.DeleteConstraint__c = this.DeleteConstraint;
            col.Description__c = this.Description;
            col.FieldName__c = this.FieldName;
            col.Formula__c = this.Formula;
            col.HelpText__c = this.HelpText;
            col.Length__c = this.Length;
            col.LimitCreatedBy__c = this.LimitCreatedBy;
            col.LimitCreatedDate__c = this.LimitCreatedDate;
            col.LimitModifiedBy__c = this.LimitModifiedBy;
            col.LimitModifiedDate__c = this.LimitModifiedDate;
            col.LimitName__c = this.LimitName;
            col.ManageableState__c = this.ManageableState;
            col.Max__c = this.Max;
            col.NamespacePrefix__c = this.NamespacePrefix;
            col.Obect__c = this.Obect;
            col.PicklistValues__c = this.PicklistValues;
            col.RelatedTo__c = this.RelatedTo;
            col.Remaining__c = this.Remaining;
            col.Type__c = this.Type;
            col.CustObjLimitId__c = this.Id;*/

            return col;
        }
    }
    public class PropMenuItemInfo {
        public Integer totalSize;
        public Boolean done;
        public List<PropMenuItemRecord> records;
    }

    public class PropMenuItemRecord {
        public Attributes attributes;
        public Integer expr0;
        public String Name;
        public String Location;

        public OrgPropMenuItemCount__c createSFObject() {
            OrgPropMenuItemCount__c miCount = new OrgPropMenuItemCount__c();
            miCount.Count__c = this.expr0;
            miCount.PropertyId__c = this.Location;
            miCount.RecordType__c = this.Name;
            return miCount;
        }
    }

    public class ReportInfo {
        public Integer totalSize;
        public Boolean done;
        public List<ReportRecord> records;      
    }
         
    public class ReportRecord {
        public Attributes attributes;
        public Integer expr0;
        public String Name;

        public OrgReportCount__c createSFObject() {
            OrgReportCount__c rc = new OrgReportCount__c();
            rc.Count__c = this.expr0;
            rc.Folder__c = this.Name;
            return rc;
        }
    }

    public class SetupValueInfo {
        public Integer totalSize;
        public Boolean done;
        public List<SetupValueRecord> records;
    }

    public class SetupValueRecord {
        public Attributes attributes;
        public String Name;
        public String SetupValueType;
        public RelatedRecord Location;
        public String MasterSource;
        public Decimal SortOrder;
        public Boolean IsActive;
        public RelatedRecord CreatedBy;
        public DateTime CreatedDate;
        public RelatedRecord LastModifiedBy;
        public DateTime LastModifiedDate;

        public OrgSetupValue__c createSFObject() {
            OrgSetupValue__c sv = new OrgSetupValue__c();
            sv.Active__c = this.IsActive;
            sv.MasterSource__c = this.MasterSource;
            sv.PropertyName__c = this.Location?.Name;
            sv.SetupValueCreatedBy__c = this.CreatedBy.Name;
            sv.SetupValueCreatedDate__c = this.CreatedDate;
            if (this.LastModifiedBy != null) {
                sv.SetupValueLastModifiedBy__c = this.LastModifiedBy.Name;
            }
            sv.SetupValueLastModifiedDate__c = this.LastModifiedDate;
            sv.SetupValueName__c = this.Name;
            sv.SortOrder__c = (Integer)this.SortOrder;
            sv.Type__c = this.SetupValueType;

            return sv;
        }
    }

    public class SystemInfo {
        public Integer totalSize;
        public Boolean done;
        public List<SystemRecord> records;
    }

    public class SystemRecord {
        public Attributes attributes;
        public String Name;
        public RelatedRecord SystemType;
        public DateTime CreatedDate;
        public RelatedRecord CreatedBy;
        public DateTime LastModifiedDate;
        public RelatedRecord LastModifiedBy;

        public OrgSystem__c createSFObject() {
            OrgSystem__c sys = new OrgSystem__c();
            sys.SystemCreatedBy__c = this.CreatedBy.Name;
            sys.SystemCreatedDate__c = this.CreatedDate;
            if (this.LastModifiedBy != null) {
                sys.SystemLastModifiedBy__c = this.LastModifiedBy.Name;
            }
            sys.SystemLastModifiedDate__c = this.LastModifiedDate;
            sys.SystemName__c = this.Name;
            sys.SystemType__c = this.SystemType.Name;

            return sys;
        } 
    }

    public class EntityDefinition {
        public Attributes attributes;
        public String DeveloperName;
    }

    public class ValidationRuleInfo {
        public Integer size;
        public Integer totalSize;
        public Boolean done;
        public String queryLocator;
        public String entityTypeName;
        public List<ValidationRuleRecord> records;
    }

    public class ValidationRuleRecord {
        public Attributes attributes;
        public String ManageableState;
        public string NamespacePrefix;
        public String ValidationName;
        public Boolean Active;
        public String Description;
        public EntityDefinition EntityDefinition;
        public String ErrorDisplayField;
        public String ErrorMessage;
        public DateTime CreatedDate;
        public RelatedRecord CreatedBy;
        public DateTime LastModifiedDate;
        public RelatedRecord LastModifiedBy;

        public OrgValidationRule__c createSFObject() {
            OrgValidationRule__c rule = new OrgValidationRule__c();
            rule.Active__c = this.Active;
            rule.Description__c = this.Description;
            rule.ErrorDisplayField__c = this.ErrorDisplayField;
            rule.ErrorMessage__c = this.ErrorMessage;
            rule.ManageableState__c = this.ManageableState;
            rule.NamespacePrefix__c = this.NamespacePrefix;
            rule.ValidationRuleCreatedBy__c = this.CreatedBy.Name;
            rule.ValidationRuleCreatedDate__c = this.CreatedDate;
            if (this.LastModifiedBy != null) {
                rule.ValidationRuleLastModifiedBy__c  = this.LastModifiedBy.Name;
            }
            rule.ValidationRuleLastModifiedDate__c = this.LastModifiedDate;
            rule.ValidationRuleName__c = this.ValidationName;
            rule.ValidationRuleObject__c = this.EntityDefinition.DeveloperName;

            return rule;
        }
    }

    public class WorkFlowInfo {
        public Integer size;
        public Integer totalSize;
        public Boolean done;
        public String queryLocator;
        public String entityTypeName;
        public List<WorkFlowRecord> records;
    }

    public class WorkFlowRecord {
        public Attributes attributes;
        public String ManageableState;
        public String NamespacePrefix;
        public String Name;
        public String TableEnumOrId;
        public DateTime CreatedDate;
        public RelatedRecord CreatedBy;
        public DateTime LastModifiedDate;
        public RelatedRecord LastModifiedBy;

        public OrgWorkFlow__c createSFObject() {
            OrgWorkFlow__c wf = new OrgWorkFlow__c();
            wf.ManageableState__c = this.ManageableState;
            wf.NamespacePrefix__c = this.NamespacePrefix;
            wf.WorkflowName__c = this.Name;
            wf.WorkflowObject__c = this.TableEnumOrId;
            wf.WorkFlowLastModifiedDate__c = this.LastModifiedDate;
            if (this.LastModifiedBy != null) {
                wf.WorkFlowLastModifiedBy__c  = this.LastModifiedBy.Name;
            }
            wf.WorkFlowCreatedBy__c = this.CreatedBy.Name;
            wf.WorkFlowCreatedDate__c = this.CreatedDate;
            wf.TriggerType__c = this.attributes.type;
            return wf;
        }
    }




}