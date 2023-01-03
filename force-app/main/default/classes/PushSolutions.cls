/****************************************************************************************
Name            : PushSolutions 
Author          : Black Iron Group
Created Date    : 07/18/2010 
Last Mod Date   : 04/25/2017 
Last Mod By     : Sean Harris
NICC Reference  : 
Description     : This class is an extention controller for a VF Page called PushSolutions
                : 
				: 
****************************************************************************************/
public with sharing class PushSolutions 
{
    
    ApexPages.Standardsetcontroller con;
    public Case parent {get;set;}
    
    public PushSolutions(ApexPages.StandardSetController controller) 
    {
        con = controller;
    }
    
    public PageReference load() 
    {
        if (con.getSelected().size() != 0) 
        {
            List<Case> cases = (List<Case>)con.getSelected();
            String parentId = cases[0].ParentId;
            parent = [SELECT Id, Status, Resolution_Type__c FROM Case WHERE Id = :parentId];
            
            List<CaseSolution> insertSols = new List<CaseSolution>();
            
            for (CaseSolution[] cs : [Select CaseId, SolutionId from CaseSolution where CaseId = :parent.Id]) 
            {
                for (CaseSolution s : cs) 
                {
                    for (Case c : (List<Case>) con.getSelected()) 
                    {
                        insertSols.add(new CaseSolution(CaseId = c.Id, SolutionId = s.SolutionId));
                    }
                }
            }
            
            List<CaseSolution> tempList = new List<CaseSolution>();
            
            for (Integer i = 0; i < insertSols.size(); i += 200) 
            {
                tempList.clear();
                for(Integer j = i; j < insertSols.size() && j < i + 200 ; j++) 
                {
                    tempList.add(insertSols[j]);
                }
                insert tempList;
            }
            
            List<Id> caseIds = new List<Id>();
            
            for (Case c : cases) 
            {
                caseIds.add(c.Id);
            }
    
      
            Solution_count__c[] updateSolutionCounts = new Solution_count__c[0];
            Solution_count__c[] insertSolutionCounts = new Solution_Count__c[0];
            Map<Id, Solution_count__c> scMap = new Map<Id, Solution_count__c>();
            
            for (Solution_count__c[] scs : [Select Id, Case__c from Solution_Count__c where Case__c in :caseIds]) 
            {
                for (Solution_count__c sc :scs) 
                {
                    scMap.put(sc.Case__c, sc);
                }   
            } 
            
            for (Case[] cs : [Select Id, (Select Id from CaseSolutions) from Case where Id in :caseIds]) 
            {
                for (Case c : cs) 
                {
                    if (scMap.containsKey(c.Id)) 
                    {
                        Solution_count__c tempSC = scMap.get(c.Id);
                        tempSC.Number_of_Solutions__c = c.caseSolutions.size();
                        updateSolutionCounts.add(tempSC);
                    }
                    else 
                    {
                        Solution_count__c tempNewSC = new Solution_count__c(Case__c = c.Id, Number_of_Solutions__c = c.caseSolutions.size());
                        insertSolutionCounts.add(tempNewSC);
                    }
                }
            }
                
            try 
            {
                Database.update(updateSolutionCounts, false);
            }
            catch (Exception ex) 
            {               
            }
            
            try 
            {
                Database.insert(insertSolutionCounts, false);
            }
            catch (Exception ex) 
            {               
            }
        
        }
      
        return new PageReference(ApexPages.currentPage().getParameters().get('retURL'));
        
    }   
    
    
}