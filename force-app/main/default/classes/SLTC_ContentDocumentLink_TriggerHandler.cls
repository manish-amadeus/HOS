/**********************************************************
*************************************
Name : SLTC_ContentDocumentLink_TriggerHandler
Author : Japtej Lamba
Created Date : 4/1/2022
Last Mod Date : 12/5/2022
Last Mod By : Japtej Lamba
NICC Reference :
Description : Handler Class for SLTC_ContentDocumentLink Trigger. Update Status and Effective date of Agreement when Signed document is uploaded to the record.
*************************************/

public class SLTC_ContentDocumentLink_TriggerHandler {

    private NI_TriggerBypassSwitches__c bpSwitch;
        
    public SLTC_ContentDocumentLink_TriggerHandler(){
        bpSwitch = NI_TriggerBypassSwitches__c.getOrgDefaults();         
    }
    
    public void onAfterInsert(List<ContentDocumentLink> newTrigger){
        if (!bpSwitch.Bypass_SLTC_ContentDocLink_AfterInsert__c){
            updateAgreementForSignedDocuments(newTrigger);
        }
        
    }

    //Update Status and Effective date of Agreement if Signed document is uploaded to the record
    private void updateAgreementForSignedDocuments(List<ContentDocumentLink> newTrigger){
        List<id> linkedEntityIdList = new List<ID>();
        
        for (ContentDocumentLink docLink : newTrigger){
            linkedEntityIdList.add(docLink.linkedEntityId);
        }

        List<ContentDocumentLink> contentDocLinkList = [SELECT contentdocumentid, contentdocument.title, contentdocument.createddate, linkedentityid FROM contentdocumentlink WHERE contentdocument.title like '%_Signed%' AND linkedentityid IN (SELECT id FROM Apttus__APTS_Agreement__c WHERE id IN :linkedEntityIdList)];

        if(!contentDocLinkList.isEmpty()){
            List<Apttus__APTS_Agreement__c> agList = new List<Apttus__APTS_Agreement__c>();
            for(ContentDocumentLink contentDocLink : contentDocLinkList){
                Apttus__APTS_Agreement__c ag = new Apttus__APTS_Agreement__c(id=contentDocLink.linkedEntityId,Apttus__Status_Category__c='In Signatures',Apttus__Status__c='Fully Signed',SLTC_Effective_Date__c = contentDocLink.contentdocument.createddate.date());
                agList.add(ag);
            }
            if(!agList.isEmpty()){
                try{
                    UPDATE agList;
                } catch (Exception exec) {
                    NI_Error_Logger.WriteToLog(exec.getTypeName() +':'+exec.getLineNumber() +':message'+ exec.getMessage(), ' ContentDocumentLink', 'SLTC_ContentDocumentLink_TriggerHandler-updateAgreementForSignedDocuments', 'UPDATE');
                }
                
            }   
        }        
    }
}