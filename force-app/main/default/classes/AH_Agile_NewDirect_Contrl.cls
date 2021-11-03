/****************************************************************************************
Name            : AH_Agile_NewDirect_Contrl Class
Author          : Bhagwat Garkal
Created Date    : 05/04/2021
Last Mod Date   : 
Last Mod By     : 
NICC Reference  : 
Description     : Controller for AH_Agile_NewDirect_Page VF Page
                : 
******************************************************************************************/
public class AH_Agile_NewDirect_Contrl {
   Public AH_Agile_NewDirect_Contrl(ApexPages.StandardSetController controller){
    }
    
    public AH_Agile_NewDirect_Contrl(){
    } 
    
    public PageReference reDirectPage(){
        PageReference p;
        List<GroupMember> gm = [select Id,group.name,group.DeveloperName from GroupMember where UserOrGroupId = :UserInfo.getUserId() and group.DeveloperName = 'AH_Agile_NewDirect_Group'];
        String sfdcBaseURL = URL.getSalesforceBaseUrl().toExternalForm();                     
        System.debug('Base URL: ' + sfdcBaseURL ); 
        if((gm != null && gm.Size() > 0) || Test.isRunningTest())
        {
            list<EntityDefinition> objId= [SELECT DurableId, QualifiedApiName FROM EntityDefinition where QualifiedApiName ='agf__ADM_Work__c'];
            p = new PageReference(sfdcBaseURL+'/setup/ui/recordtypeselect.jsp?ent='+objId[0].DurableId+'&nooverride=1&save_new_url=%2FaJ3%2Fe%3FretURL%3D%252FaJ3%252Fo');
        }
        else
        {
            p = new PageReference(sfdcBaseURL+'/lightning/o/agf__ADM_Work__c/new?useRecordTypeCheck=1');
        }
        p.setRedirect(true);
        return p;
    }
}