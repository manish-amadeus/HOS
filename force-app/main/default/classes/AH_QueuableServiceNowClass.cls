/************************************************************************************************
                  INTEGRATION CLASS - DO NOT ALTER!!!
*************************************************************************************************
Name            : AH_QueuableServiceNowClass Class
Integration     : Win@pproach / Service Now
Author          : Ria Chawla
Created Date    : 07/28/2017
Last Mod Date   : 08/08/2017 
Last Mod By     : Stuart Emery
NICC Reference  : NICC-023347
Description     : 
                : 
*************************************************************************************************/
public class AH_QueuableServiceNowClass implements Queueable {
    public Set<Id> csIds = new Set<Id>();
    
    public AH_QueuableServiceNowClass(Set<Id> caseIds){
        this.csIds = caseIds;
    }
    public void execute(QueueableContext context){
        
        List<Casecomment> caseComtList		= new List<Casecomment>();
        Map<Id, Attachment> snAttMap = new Map<Id, Attachment>();
 
        if(!csIds.isEmpty()){
            caseComtList = [SELECT Id, ParentId,CommentBody,CreatedBy.Name, IsPublished 
                            FROM CaseComment WHERE ParentId IN :csIds];
            snAttMap = new Map<Id, Attachment>([SELECT Id, Name FROM Attachment WHERE //Id IN :attachIdSet AND
                                                parentID IN :csIds]);
        }
        
         system.debug('caseComtList'+caseComtList);
        SYSTEM.debug('snAttMap'+snAttMap);
        if(!caseComtList.isEmpty()){
            NI_ServicenowIntegration.updateIncidents(caseComtList, new Set<String>(NI_WinaproachService.caseFieldsForComments));
        }
        if(!snAttMap.isEmpty()){
            NI_ServicenowFunctions.attachment_Callout(snAttMap.keySet());
        }
        
    }
}