/****************************************************************************************
Name            : NI_PermissionsAuditorController Class 
Author          : Cybage
Created Date    : 6/30/2016
Last Mod Date   : 10/15/2016
Last Mod By     : Stuart Emery
NICC Reference  : NICC-018245
Description     :  This class is used as the Controller for the NI_PermissionsAuditor VF Page
                :  It is used to audit object and field level permissions
                : 
                : 
******************************************************************************************/
public class NI_PermissionsAuditorController{
    
    @RemoteAction
    public static List<SFObjects> findObjectList(){
        List<Schema.SObjectType> objectDesc = Schema.getGlobalDescribe().Values();     
        List<SFObjects> objList = new List<SFObjects>();
        
        for(Schema.SObjectType obj : objectDesc)
        { 
            objList.add(new SFObjects(obj.getDescribe().getName(), obj.getDescribe().getLabel()+' : '+ obj.getDescribe().getName()));
        }
        System.debug('*** objList size *** '+objList.size());
        return objList;
    }
    
    @RemoteAction
    public static List<ProfilePermissionSetDetails> findFieldLevelPermissions(String objectName, String fieldName, List<ProfilePermissionSetDetails> permissionsList){
        
        List<ProfilePermissionSetDetails> returnList = new List<ProfilePermissionSetDetails>();
        //List<FieldPermissions> fpList = new List<FieldPermissions>();
        Map<Id, Permissions> permMap = permissionsList[0].permissionsMap;
        Map<Id, FieldPermissions> fieldPermissionMap = new Map<Id, FieldPermissions>();
        System.debug('*** Profile Id *** '+permMap.keySet());
        Integer cnt = 0;
        for(FieldPermissions fp: [SELECT Id, ParentId, Parent.Name, Parent.Profile.Name, Parent.ProfileId, PermissionsRead, 
                                PermissionsEdit 
                                FROM FieldPermissions
                                WHERE 
                                (ParentId IN: permMap.keySet() OR Parent.ProfileId IN: permMap.keySet()) 
                                AND SobjectType=: objectName 
                                AND Field =: objectName+'.'+fieldName
                                AND (PermissionsEdit = true OR PermissionsRead = true)
                                ]){
    
            if(fp.Parent.ProfileId == null){
                fieldPermissionMap.put(fp.ParentId, fp);
            }
            else{
                fieldPermissionMap.put(fp.Parent.ProfileId, fp);
            }
            cnt++;
            //fpList.add(fp);
        }
        System.debug('*** cnt *** '+cnt);
        
        List<Permissions> profileList = permissionsList[0].permissionsObj;
        List<Permissions> permissionSetList = permissionsList[1].permissionsObj;
        List<SFObjectFields> fieldsList = permissionsList[0].fieldsList;
        List<UserInfo> usersList = permissionsList[0].userInfoList;
        Map<Id, Permissions> permissionsMap = new Map<Id, Permissions>();
        Set<Id> profileIdSet = new Set<Id>();
        Set<Id> psetIdSet = new Set<Id>();
        
        for(Permissions permObj: profileList){
            //Update field Permissions
            if(fieldPermissionMap != null && !fieldPermissionMap.isEmpty()){
                FieldPermissions fpObj = fieldPermissionMap.get(permObj.Id);
                if(fpObj != null){
                    permObj.permissionFieldRead = fpObj.PermissionsRead;
                    permObj.permissionFieldEdit = fpObj.PermissionsEdit;
                }
            }
            profileIdSet.add(permObj.Id);
            permissionsMap.put(permObj.Id, permObj);
        }
        
        for(Permissions permObj: permissionSetList){
            //Update field Permissions
            if(fieldPermissionMap != null && !fieldPermissionMap.isEmpty()){
                FieldPermissions fpObj = fieldPermissionMap.get(permObj.Id);
                if(fpObj != null){
                    permObj.permissionFieldRead = fpObj.PermissionsRead;
                    permObj.permissionFieldEdit = fpObj.PermissionsEdit;
                }
            }
            psetIdSet.add(permObj.Id);
            permissionsMap.put(permObj.Id, permObj);
        }
        
        ProfilePermissionSetDetails profileObj = new ProfilePermissionSetDetails(profileList, fieldsList, usersList);
        profileObj.permissionsMap = permissionsMap;
        ProfilePermissionSetDetails psetObj = new ProfilePermissionSetDetails(permissionSetList, null, null);
        returnList.add(profileObj);
        returnList.add(psetObj);
        System.debug('*** end time *** '+System.now());
        return returnList;
    }
    
    @RemoteAction
    public static List<UserInfo> updateUsersPermissions(Map<Id, Permissions> permissionsMap, List<UserInfo> usersList){
        List<UserInfo> userInfoList = new List<UserInfo>();
        System.debug('*** IN updateUsersPermissions Profile Id *** '+permissionsMap.keySet());
        for(UserInfo usr: usersList){
            List<Permissions> permissionList = new List<Permissions>();
            for(Permissions per: usr.permissionsList){
                Permissions p = permissionsMap.get(per.Id);
                permissionList.add(p);
            }
            UserInfo user = new UserInfo(usr.id, usr.userName, usr.profileName, usr.profileId, permissionList);
            userInfoList.add(user);
        }
        
        return userInfoList;
    }
    
    @RemoteAction
    public Static List<ProfilePermissionSetDetails> findObjectPermissions(String objectName){
        
        List<ProfilePermissionSetDetails> returnList = new List<ProfilePermissionSetDetails>();
        returnList = getObjectAndFieldPermissions(objectName);
        
        return returnList;
    }
    
    //public static List<ProfilePermissionSetDetails> getObjectAndFieldPermissions(String objectName, Map<Id, FieldPermissions> fieldPermMap){
    public static List<ProfilePermissionSetDetails> getObjectAndFieldPermissions(String objectName){
        List<Permissions> profileList = new List<Permissions>();
        List<Permissions> permissionSetList = new List<Permissions>();
        List<ProfilePermissionSetDetails> returnList = new List<ProfilePermissionSetDetails>();
        Map<Id, Permissions> permissionsMap = new Map<Id, Permissions>();
        Set<Id> profileIdSet = new Set<Id>();
        Set<Id> psetIdSet = new Set<Id>();
        for(ObjectPermissions op: [SELECT Id, ParentId, Parent.Name, Parent.Profile.Name, Parent.ProfileId, PermissionsRead, PermissionsCreate,
                                    PermissionsEdit, PermissionsDelete, PermissionsViewAllRecords, PermissionsModifyAllRecords 
                                    FROM ObjectPermissions
                                    WHERE SobjectType=: objectName 
                                    AND (PermissionsCreate = true OR PermissionsDelete = true OR PermissionsEdit = true 
                                    OR PermissionsModifyAllRecords = true OR PermissionsRead = true OR PermissionsViewAllRecords = true)
                                     ]){
        
            Permissions permObj = new Permissions();
            permObj.permissionRead = op.PermissionsRead;
            permObj.permissionCreate = op.PermissionsCreate;
            permObj.permissionEdit = op.PermissionsEdit;
            permObj.permissionDelete = op.PermissionsDelete;
            permObj.permissionViewAll = op.PermissionsViewAllRecords;
            permObj.permissionModifyAll = op.PermissionsModifyAllRecords;
            permObj.permissionFieldRead = false;
            permObj.permissionFieldEdit = false;
                
            Boolean isProfile = true;
            if(op.Parent.ProfileId == null){
                permObj.id = op.ParentId;
                permObj.name = op.Parent.Name;
                permObj.type = 'Permission Set';
                isProfile = false;   
                psetIdSet.add(op.ParentId);
            }
            else{
                permObj.id = op.Parent.ProfileId;          
                permObj.name = op.Parent.Profile.Name;
                permObj.type = 'Profile';
                profileIdSet.add(op.Parent.ProfileId);
            }
            
            if(isProfile){
                profileList.add(permObj);
            }
            else{
                permissionSetList.add(permObj);
            }
            
            permissionsMap.put(permObj.Id, permObj);
        } 
       
        ProfilePermissionSetDetails profileObj = new ProfilePermissionSetDetails(profileList, findObjectFields(objectName), createUserInfoObjects(profileIdSet, psetIdSet, permissionsMap));
        profileObj.permissionsMap = permissionsMap;
        ProfilePermissionSetDetails psetObj = new ProfilePermissionSetDetails(permissionSetList, null, null);
        returnList.add(profileObj);
        returnList.add(psetObj);
        
        return returnList;
    }
    
    public static List<UserInfo> createUserInfoObjects(Set<Id> profileIdSet, Set<Id> psetIdSet, Map<Id, Permissions> permissionsMap){
        List<UserInfo> userInfoList = new List<UserInfo>();
        if(!profileIdSet.isEmpty() || !psetIdSet.isEmpty()){
            
            for(User user: [SELECT Id, Name, ProfileId, Profile.Name, 
                            (SELECT Id, PermissionSetId, PermissionSet.Name from PermissionSetAssignments 
                            WHERE PermissionSetId IN: psetIdSet) 
                            FROM User WHERE ProfileId IN: profileIdSet AND IsActive = true limit 10000]){
                List<Permissions> permissionsList = new List<Permissions>();
                for(PermissionSetAssignment psa: user.PermissionSetAssignments){
                    if(permissionsMap.containsKey(psa.PermissionSetId)){
                        permissionsList.add(permissionsMap.get(psa.PermissionSetId));
                    }
                }
                if(permissionsMap.containsKey(user.ProfileId)){
                    permissionsList.add(permissionsMap.get(user.ProfileId));
                }
                UserInfo userInfoObj = new UserInfo(user.Id, user.Name, user.Profile.Name, user.profileId, permissionsList);
                userInfoList.add(userInfoObj);
            }                            
        }
        return userInfoList;
    }
    
    
    public static List<SFObjectFields> findObjectFields(String objectName){
        System.debug('*** inside findObjectFields *** '+objectName);
        List<SFObjectFields> fieldsList = new List<SFObjectFields>();
        
        Map<String, Schema.SObjectType> objectDescMap = Schema.getGlobalDescribe();
        Map <String, Schema.SObjectField> fieldMap = objectDescMap.get(objectName).getDescribe().fields.getMap();
        
        for(Schema.SObjectField sfield : fieldMap.Values()){
            schema.describefieldresult dfield = sfield.getDescribe();
            fieldsList.add(new SFObjectFields(objectName, dfield.getName(), dfield.getLabel()+' : '+dfield.getName()));
        }
        
        return fieldsList;
    }
    
    public class SFObjects{
        public String objectName{ get; set; }
        public String objectLabel{ get; set; }
        public SFObjects(String objectName, String objectLabel){
            this.objectName = objectName;
            this.objectLabel = objectLabel;
        }
    }
    
    public class Permissions{
      public String name{ get; set; }
      public String id{ get; set; }
      public String type{ get; set; }
      public Boolean permissionRead{ get; set; }
      public Boolean permissionCreate{ get; set; }
      public Boolean permissionEdit{ get; set; }
      public Boolean permissionDelete{ get; set; }
      public Boolean permissionViewAll{ get; set; }
      public Boolean permissionModifyAll{ get; set; }
      public Boolean permissionFieldRead{ get; set; }
      public Boolean permissionFieldEdit{ get; set; }
    }
    
    public class SFObjectFields{
        public String objectName{ get; set; }
        public String fieldName{ get; set; }
        public String fieldLabel{ get; set; }
        
        public SFObjectFields(String objectName, String fieldName, String fieldLabel){
            this.objectName = objectName;
            this.fieldName = fieldName;
            this.fieldLabel = fieldLabel;
        }
    }
    
    public class UserInfo{
        public String userName{ get; set; }
        public String id{ get; set; }
        public String profileName{ get; set; }
        public String profileId{ get; set; }
        public List<Permissions> permissionsList{ get; set; }
        public UserInfo(String id, String userName, String profileName, String profileId, List<Permissions> permissionsList){
            this.id = id;
            this.userName = userName;
            this.profileName = profileName;
            this.profileId = profileId;
            this.permissionsList = permissionsList;
        }
    }
    
    public class ProfilePermissionSetDetails{
      public List<SFObjectFields> fieldsList{ get; set; }
      public List<Permissions> permissionsObj{ get; set; }
      public List<UserInfo> userInfoList{ get; set; }
      public Map<Id, Permissions> permissionsMap{ get; set; }
      public ProfilePermissionSetDetails(List<Permissions> permissionsObj, List<SFObjectFields> fieldsList, List<UserInfo> userInfoList){
        this.permissionsObj = permissionsObj;
        this.fieldsList = fieldsList;
        this.userInfoList = userInfoList;
      }
      
    }
    
}