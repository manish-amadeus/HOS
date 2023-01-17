/**********************************************************
Name : SLTC_AgreementTriggerHelper
Author : Gopesh Banker
Created Date : 10/3/2022
Last Mod Date : 12/15/2022
Last Mod By : Japtej Lamba
Description : Helper Class for SLTC_AgreementTriggerHandler. Update Child Effective date, Status and Attachments on child agreement records if the Parent Agreement Record is Activated.
***********************************************************/

public without sharing class SLTC_AgreementTriggerHelper {

    //Method to Filter Activated and Fully Signed SLTC Agreement Records
    public void activateChildAgreements(Map<Id, Apttus__APTS_Agreement__c> mapNewAgreements, Map<Id,Apttus__APTS_Agreement__c> mapOldAgreements){
        Set<Id> setParentAgreementIds = new Set<Id>();
        for(Apttus__APTS_Agreement__c objAgreement : mapNewAgreements.values()){
            //SLTC Agreement is activated and has no parent, meaning this is the parent
            if(objAgreement.Apttus__Status__c == 'Activated' && objAgreement.Apttus__Status_Category__c == 'In Effect' &&
              mapOldAgreements.get(objAgreement.Id).Apttus__Status__c != 'Activated' && mapOldAgreements.get(objAgreement.Id).Apttus__Status_Category__c != 'In Effect' &&
              objAgreement.Apttus__Parent_Agreement__c == null && objAgreement.SLTC_Is_SLTC_Record__c){
                setParentAgreementIds.add(objAgreement.Id);
            }
        }
        
        //execute all logic only if parent agreement status changes to in effect - activated
        if(!setParentAgreementIds.isEmpty()){
            //get all child agreements
            List<Apttus__APTS_Agreement__c> listChildAgreements = [SELECT Id, Apttus__Parent_Agreement__c FROM Apttus__APTS_Agreement__c WHERE Apttus__Parent_Agreement__c IN :setParentAgreementIds];
            //get all parent attachments
            List<Attachment> listAttachment = [SELECT id, name, body, ParentId FROM Attachment WHERE ParentId IN :setParentAgreementIds];
            Map<Id, Attachment> mapAttachment = new Map<Id, Attachment>();
            for(Attachment objAttach : listAttachment){
                //store attachment in parent agreement id --> attachment format
                mapAttachment.put(objAttach.ParentId, objAttach);
            }
            
            List<Attachment> listAttachmentToInsert = new List<Attachment>();
            Set<Id> setChildAgreements = new Set<Id>();
            for(Apttus__APTS_Agreement__c objChildAgreement : listChildAgreements){
                //clone parent attachments to child attachments
                Attachment parentAttachment = mapAttachment.get(objChildAgreement.Apttus__Parent_Agreement__c);
                listAttachmentToInsert.add(new Attachment(name = parentAttachment.name, body = parentAttachment.body, parentid = objChildAgreement.Id));
                objChildAgreement.SLTC_Effective_Date__c = mapNewAgreements.get(objChildAgreement.Apttus__Parent_Agreement__c).SLTC_Effective_Date__c;
                setChildAgreements.add(objChildAgreement.Id);
            }
            if(!listAttachmentToInsert.isEmpty()){
                //insert child attachments
                insert listAttachmentToInsert;
            }

            if(!listChildAgreements.isEmpty()){
                //update effective date on child agreements
                update listChildAgreements;
            }

            Map<Id, Attachment> mapchildAgreementToAttachment = new Map<Id, Attachment>();
            for(Attachment objAttach : listAttachmentToInsert){
                mapChildAgreementToAttachment.put(objAttach.ParentId, objAttach);
            }

            for(Apttus__APTS_Agreement__c objChildAgreement : listChildAgreements){
                try{
                    //call agreement activation api
                    List<String> selectedDocIds = new List<String>();
                    selectedDocIds.add(mapChildAgreementToAttachment.get(objChildAgreement.Id).Id);
                    Apttus.AgreementWebService.activateAgreement(objChildAgreement.Id, selectedDocIds, null);
                }
                catch(Exception ex){
                    //catch exception if any and display on parent agreement
                    mapNewAgreements.get(objChildAgreement.Apttus__Parent_Agreement__c).addError('Exception occurred calling Agreement Activation API- '+ex.getMessage());
                }
            }
        }
    }

    //Method to Filter Fully Signed SLTC Agreement Records
    public void updateAgreementDates(Map<Id, Apttus__APTS_Agreement__c> mapNewAgreements, Map<Id,Apttus__APTS_Agreement__c> mapOldAgreements){
        
        Set<Id> setFullySignedAgreementIds = new Set<Id>();
        for(Apttus__APTS_Agreement__c objAgreement : mapNewAgreements.values()){
            //SLTC Agreement is Fully Signed and has no parent
            if(objAgreement.Apttus__Status__c == 'Fully Signed' && objAgreement.Apttus__Status_Category__c == 'In Signatures' &&
            mapOldAgreements.get(objAgreement.Id).Apttus__Status__c != 'Fully Signed' &&
            objAgreement.Apttus__Parent_Agreement__c == null && objAgreement.SLTC_Is_SLTC_Record__c && !objAgreement.SLTC_Is_Date_Calculation_required__c){
                setFullySignedAgreementIds.add(objAgreement.Id);
            }
        }

        //Logic to Update Dates on Parent and Child Agreements and related Line Items.
        if(!setFullySignedAgreementIds.isEmpty()){

            //Query to fetch Agreement and Related Object Data
            Map<id,Apttus__APTS_Agreement__c> parentAgreementMap = new Map<Id,Apttus__APTS_Agreement__c>([SELECT Id, Apttus__Contract_End_Date__c, Apttus__Contract_Start_Date__c, Apttus__Term_Months__c, Apttus__Parent_Agreement__c, Apttus__Related_Opportunity__r.Target_HRM_Org__c, Apttus__Related_Opportunity__r.Target_HRM_Org__r.Annual_Salesforce_Renewal_Date__c, SLTC_Is_Date_Calculation_required__c, Apttus_QPComply__RelatedProposalId__c,SLTC_Product_Configuration__c,SLTC_Product_Configuration__r.SLTC_Number_of_ASEM_Lines__c,SLTC_Effective_Date__c,SLTC_Min_Lead_Time_Days__c FROM Apttus__APTS_Agreement__c WHERE Id IN:setFullySignedAgreementIds]);

            //Query to fetch Agreement Line Itmes and Related Object Data
            List<Apttus__AgreementLineItem__c> parentAgreementLineItemList = new List<Apttus__AgreementLineItem__c>();
            parentAgreementLineItemList = [SELECT Id,Apttus_CMConfig__PriceGroup__c,Apttus_CMConfig__IsPrimaryRampLine__c,Apttus_CMConfig__LineNumber__c,Apttus_CMConfig__ItemSequence__c,Apttus_CMConfig__StartDate__c,Apttus_CMConfig__EndDate__c,Apttus__AgreementId__c,Apttus_CMConfig__IsPrimaryLine__c,Apttus_CMConfig__LineType__c,Apttus_CMConfig__PriceType__c,Apttus__AgreementId__r.Apttus__Contract_Start_Date__c,Apttus__AgreementId__r.SLTC_Is_Date_Calculation_required__c FROM Apttus__AgreementLineItem__c WHERE Apttus__AgreementId__c IN :parentAgreementMap.keySet() ORDER BY Apttus_CMConfig__LineNumber__c,Apttus_CMConfig__ItemSequence__c,Apttus_CMConfig__PriceGroup__c];

            //Map Agreement Line Items with Parent Agreement Id
            Map<Id,Apttus__AgreementLineItem__c> mapParentAgWithLineItem = new Map<Id,Apttus__AgreementLineItem__c>();

            for(Apttus__AgreementLineItem__c agLineItem : parentAgreementLineItemList){
                mapParentAgWithLineItem.put(agLineItem.Apttus__AgreementId__c, agLineItem);
            }

            //Query to fetch Child Agreements and Related Object Data
            Map<id,Apttus__APTS_Agreement__c> childAgreementMap = new Map<id,Apttus__APTS_Agreement__c>([SELECT Id, Apttus__Contract_End_Date__c, Apttus__Contract_Start_Date__c, Apttus__Term_Months__c, Apttus__Parent_Agreement__c, Apttus__Related_Opportunity__r.Target_HRM_Org__c, Apttus__Related_Opportunity__r.Target_HRM_Org__r.Annual_Salesforce_Renewal_Date__c, SLTC_Is_Date_Calculation_required__c, Apttus_QPComply__RelatedProposalId__c,SLTC_Product_Configuration__c,SLTC_Product_Configuration__r.SLTC_Number_of_ASEM_Lines__c,SLTC_Effective_Date__c,SLTC_Min_Lead_Time_Days__c FROM Apttus__APTS_Agreement__c WHERE Apttus__Parent_Agreement__c IN :parentAgreementMap.keySet()]);

            //Query to fetch Agreement Line Items and Related Object Data for Child Agreements
            List<Apttus__AgreementLineItem__c> childAgreementLineItemList = new List<Apttus__AgreementLineItem__c>();
            childAgreementLineItemList = [SELECT Id,Apttus_CMConfig__PriceGroup__c,Apttus_CMConfig__IsPrimaryRampLine__c,Apttus_CMConfig__LineNumber__c,Apttus_CMConfig__ItemSequence__c,Apttus_CMConfig__StartDate__c,Apttus_CMConfig__EndDate__c,Apttus__AgreementId__c,Apttus_CMConfig__IsPrimaryLine__c,Apttus_CMConfig__LineType__c,Apttus_CMConfig__PriceType__c,Apttus__AgreementId__r.Apttus__Contract_Start_Date__c,Apttus__AgreementId__r.SLTC_Is_Date_Calculation_required__c FROM Apttus__AgreementLineItem__c WHERE Apttus__AgreementId__c IN :childAgreementMap.keySet() ORDER BY Apttus_CMConfig__LineNumber__c,Apttus_CMConfig__ItemSequence__c,Apttus_CMConfig__PriceGroup__c];
            
            //Associate Child and Parent Agreements
            Map<Id,List<Apttus__APTS_Agreement__c>> parentChildAgreementMap = new Map<Id,List<Apttus__APTS_Agreement__c>>();
            for(Apttus__APTS_Agreement__c childAgreement: childAgreementMap.values()){
                List<Apttus__APTS_Agreement__c> tempAgList = new List<Apttus__APTS_Agreement__c>{childAgreement};
                if(parentChildAgreementMap.containsKey(childAgreement.Apttus__Parent_Agreement__c)){
                    tempAgList.addAll(parentChildAgreementMap.get(childAgreement.Apttus__Parent_Agreement__c));
                }
                parentChildAgreementMap.put(childAgreement.Apttus__Parent_Agreement__c,tempAgList);
            }

            //Calculate Dates if list is not empty
            if(!parentAgreementMap.isEmpty()){
                //Call Method to process the dates
                calculateDateForAgreements(parentAgreementMap, parentChildAgreementMap, parentAgreementLineItemList, childAgreementMap, childAgreementLineItemList, mapNewAgreements);
            }
        }

    }
    
    //Method to Calculate Dates for Agreements
    public void calculateDateForAgreements(Map<Id, Apttus__APTS_Agreement__c> parentAgreementMap, Map<Id,List<Apttus__APTS_Agreement__c>> parentChildAgreementMap, List<Apttus__AgreementLineItem__c> parentAgreementLineItemList, Map<Id,Apttus__APTS_Agreement__c> childAgreementMap ,List<Apttus__AgreementLineItem__c> childAgreementLineItemList,Map<Id, Apttus__APTS_Agreement__c> mapNewAgreements){
        
        Map<Id,Date> agreementStartDateMap = new Map<Id,Date>();
        Map<Id,Date> agreementEndDateMap = new Map<Id,Date>();
        Map<Id,Integer> agreementTermMonthsMap = new Map<Id,Integer>();

        List<Apttus__APTS_Agreement__c> agreementUpdateList = new List<Apttus__APTS_Agreement__c>();
        List<Apttus__AgreementLineItem__c> agreementLineUpdateList = new List<Apttus__AgreementLineItem__c>();

        Date agreementStartDate;
        Date agreementEndDate;
        Integer agreementTermMonths;

        for(Apttus__APTS_Agreement__c parentAgreement : parentAgreementMap.values()){
            
            Date effectiveDate = mapNewAgreements.get(parentAgreement.Id).SLTC_Effective_Date__c;
            Integer asemLineCount = parentAgreement.SLTC_Product_Configuration__r.SLTC_Number_of_ASEM_Lines__c==NULL?0:Integer.valueOf(parentAgreement.SLTC_Product_Configuration__r.SLTC_Number_of_ASEM_Lines__c);
            if(parentChildAgreementMap.containsKey(parentAgreement.Id) ){
                for(Apttus__APTS_Agreement__c agreement: parentChildAgreementMap.get(parentAgreement.Id)){
                    asemLineCount+=(agreement.SLTC_Product_Configuration__c!=NULL)?Integer.valueOf(agreement.SLTC_Product_Configuration__r.SLTC_Number_of_ASEM_Lines__c):0;
                }
            }
            //Calculate Dates
            agreementStartDate = calculateStartDate(parentAgreement,effectiveDate);
            agreementEndDate = calculateEndDate(parentAgreement, agreementStartDate, asemLineCount);
            agreementTermMonths = calculateTermMonths(parentAgreement, agreementStartDate, agreementEndDate, asemLineCount);

            //Update Date and Term fields on Agreement Record
            parentAgreement.Apttus__Contract_Start_Date__c = agreementStartDate;
            parentAgreement.Apttus__Contract_End_Date__c = agreementEndDate;
            parentAgreement.Apttus__Term_Months__c = agreementTermMonths;

            //Add agreement record to update list
            agreementUpdateList.add(parentAgreement);
            
            //Map agreement and dates
            agreementStartDateMap.put(parentAgreement.Id,agreementStartDate);
            agreementEndDateMap.put(parentAgreement.Id,agreementEndDate);
            agreementTermMonthsMap.put(parentAgreement.Id,agreementTermMonths);
        }

        if(!childAgreementMap.isEmpty()){
            for(Apttus__APTS_Agreement__c childAgreement: childAgreementMap.values()){
                childAgreement.Apttus__Contract_Start_Date__c=agreementStartDateMap.get(childAgreement.Apttus__Parent_Agreement__c);
                childAgreement.Apttus__Contract_End_Date__c=agreementEndDateMap.get(childAgreement.Apttus__Parent_Agreement__c);
                childAgreement.Apttus__Term_Months__c=agreementTermMonthsMap.get(childAgreement.Apttus__Parent_Agreement__c);

                agreementUpdateList.add(childAgreement);

                //Map child agreement and dates
                agreementStartDateMap.put(childAgreement.Id,agreementStartDate);
                agreementEndDateMap.put(childAgreement.Id,agreementEndDate);
                agreementTermMonthsMap.put(childAgreement.Id,agreementTermMonths);
            }
            //updateChildAgreementDates(childAgreementList);
            
        }

        if(!parentAgreementLineItemList.isEmpty()){
            agreementLineUpdateList.addAll(updateAgreementLineItemDates(parentAgreementLineItemList, agreementStartDateMap, agreementEndDateMap));
        }
        
        if(!childAgreementLineItemList.isEmpty()){
            //reuse parentagreementline code/method
            agreementLineUpdateList.addAll(updateAgreementLineItemDates(childAgreementLineItemList, agreementStartDateMap, agreementEndDateMap));
        }

        //UPDATE RECORDS
        try{
            UPDATE agreementUpdateList;
            UPDATE agreementLineUpdateList;
        } catch (Exception exec) {
            NI_Error_Logger.WriteToLog(exec.getTypeName() +':'+exec.getLineNumber() +':message'+ exec.getMessage(), ' Agreement', 'SLTC_AgreementTriggerHelper-updateAgreementDates', 'UPDATE');
        }

    }

    //Method to Calculate Start Date
    public Date calculateStartDate(Apttus__APTS_Agreement__c parentAgreement, Date effectiveDate){
        Date agreementStartDate;
        if(parentAgreement.SLTC_Is_Date_Calculation_required__c){
            agreementStartDate=parentAgreement.Apttus__Contract_Start_Date__c;
        } else {
            agreementStartDate = (parentAgreement.SLTC_Min_Lead_Time_Days__c!=NULL)?effectiveDate.addDays(Integer.valueOf(parentAgreement.SLTC_Min_Lead_Time_Days__c)):effectiveDate;
        }
        return agreementStartDate;
    }

    //Method to calculate End Date
    public Date calculateEndDate(Apttus__APTS_Agreement__c parentAgreement, Date agreementStartDate, Integer asemLineCount){
        //Calculate End Date
        Date agreementEndDate;
        if( asemLineCount>0 && (parentAgreement.Apttus__Related_Opportunity__r.Target_HRM_Org__c!=NULL ) && (parentAgreement.Apttus__Related_Opportunity__r.Target_HRM_Org__r.Annual_Salesforce_Renewal_Date__c!=NULL) && !parentAgreement.SLTC_Is_Date_Calculation_required__c){
            agreementEndDate = parentAgreement.Apttus__Related_Opportunity__r.Target_HRM_Org__r.Annual_Salesforce_Renewal_Date__c;
        } else {
            agreementEndDate = agreementStartDate.addMonths(Integer.valueOf(parentAgreement.Apttus__Term_Months__c))-1;
        }

        return agreementEndDate;
    }

    //Method to Calculate Term Months
    public Integer calculateTermMonths(Apttus__APTS_Agreement__c parentAgreement, Date startDate, Date endDate, Integer asemLineCount){
        //Calculate Term Months
        Integer agreementTermMonths;
        if( asemLineCount > 0 && (parentAgreement.Apttus__Related_Opportunity__r.Target_HRM_Org__c!=NULL) && (parentAgreement.Apttus__Related_Opportunity__r.Target_HRM_Org__r.Annual_Salesforce_Renewal_Date__c!=NULL) && !parentAgreement.SLTC_Is_Date_Calculation_required__c){
            agreementTermMonths = startDate.monthsBetween(endDate);
            if(endDate.day() > startDate.day()) {agreementTermMonths++;}
        } else{
            agreementTermMonths=Integer.valueOf(parentAgreement.Apttus__Term_Months__c);
        }
        return agreementTermMonths;
    }


    //Method to put Start Date and End Date values on Agreement Line Items
    public List<Apttus__AgreementLineItem__c> updateAgreementLineItemDates (List<Apttus__AgreementLineItem__c> agreementLineItemList, Map<Id,Date> agreementStartDateMap, Map<Id,Date> agreementEndDateMap ){
        List<Apttus__AgreementLineItem__c> returnList = new List<Apttus__AgreementLineItem__c>();
        Map<String,Integer> agreementRampDayMap = new Map<String,Integer>();
        if(!agreementLineItemList.isEmpty()){
            //move this for loop to a method so it can be reused for childagreqementlineitemlist
            for(Apttus__AgreementLineItem__c agreementLine : agreementLineItemList){

                String agreementLineNumberKey = '' + agreementLine.Apttus__AgreementId__c + agreementLine.Apttus_CMConfig__LineNumber__c;
                Integer dayDifference=0;

                //if price and ramp line not covered yet
                if(agreementLine.Apttus_CMConfig__PriceType__c=='Recurring' && agreementLine.Apttus_CMConfig__PriceGroup__c=='Price Ramp' && (agreementRampDayMap==null || !agreementRampDayMap.containsKey(agreementLineNumberKey))){
                    dayDifference= agreementLine.Apttus_CMConfig__StartDate__c.daysBetween(agreementStartDateMap.get(agreementLine.Apttus__AgreementId__c));
                    //add key, ramp day difference to map
                    agreementRampDayMap.put(agreementLineNumberKey,dayDifference);
                    //set line date to agreement start date end date
                    agreementLine.Apttus_CMConfig__StartDate__c= agreementStartDateMap.get(agreementLine.Apttus__AgreementId__c);
                    agreementLine.Apttus_CMConfig__EndDate__c = agreementLine.Apttus_CMConfig__EndDate__c.addDays(agreementRampDayMap.get(agreementLineNumberKey));

                } else if(agreementLine.Apttus_CMConfig__PriceType__c=='Recurring' &&  agreementLine.Apttus_CMConfig__PriceGroup__c=='Price Ramp' && agreementRampDayMap!=null && agreementRampDayMap.containsKey(agreementLineNumberKey)){
                    //line date = line date + get ramp day difference from map
                    agreementLine.Apttus_CMConfig__StartDate__c=agreementLine.Apttus_CMConfig__StartDate__c.addDays(agreementRampDayMap.get(agreementLineNumberKey));
                    agreementLine.Apttus_CMConfig__EndDate__c = agreementLine.Apttus_CMConfig__EndDate__c.addDays(agreementRampDayMap.get(agreementLineNumberKey));
                } else {
                    //set line date to agreement start date end date
                    agreementLine.Apttus_CMConfig__StartDate__c= agreementStartDateMap.get(agreementLine.Apttus__AgreementId__c);
                    agreementLine.Apttus_CMConfig__EndDate__c = agreementEndDateMap.get(agreementLine.Apttus__AgreementId__c);
                }
                returnList.add(agreementLine);
            }
        }
        return returnList;
    }
}