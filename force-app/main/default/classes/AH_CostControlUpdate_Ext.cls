/****************************************************************************************
Name            : AH_CostControlUpdate_Ext Class 
Author          : Cybage
Created Date    : 08/17/2017
Last Mod Date   : 08/17/2017
Last Mod By     : Cybage
NICC Reference  : NICC-023466
Description     : Extention Class for AH_CostControlUpdate VF Page
				: 
				: 
******************************************************************************************/
public class AH_CostControlUpdate_Ext 
{
    
    //Variable declaration 
    public Integer CountTotalRecords {get; set;}
    public List<WrapperUser> usrlst {get; set;}
    public Integer OffsetSize = 0;
    private final Integer QueryLimit = 25;
    
    public AH_CostControlUpdate_Ext(ApexPages.StandardController controller)
    {

        CountTotalRecords = [SELECT COUNT() FROM User WHERE Controlling_Verified__c = false AND IsActive = true AND UserType = 'Standard'];
        
        usrlst = new List<WrapperUser>(); 
        
        for (User usr: [SELECT Id, Name, Email, FirstName, LastName, Department, Title,Manager.Name, Controlling_Verified__c, 
                        FFA_Company__c, FFA_Dimension_2__c, FFA_Dimension_3__c, Cost_Ctr__c 
                        FROM User 
                        WHERE Controlling_Verified__c = false 
                        AND IsActive = true 
                        AND UserType = 'Standard' 
                        ORDER BY LastName, FirstName 
                        LIMIT : QueryLimit 
                        OFFSET : OffsetSize])
        {
            WrapperUser wr = new WrapperUser();
            wr.flag =false;
            wr.usr = usr;	
            usrlst.add(wr);
        }
        
        // For message display
        String messageFail = ApexPages.CurrentPage().GetParameters().Get('Errormessage');
        if (messageFail != null)
        {
            ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Controlling Verified can not be checked if Cost Ctr is null.')); 
        }        
        else
        {
            ApexPages.currentPage().getParameters().put('message', 'Refresh');
            String message = '' + ApexPages.CurrentPage().GetParameters().Get('message');
            String pageHeaderReferer = ApexPages.currentPage().getHeaders().get('Referer'); 
            
            // Use the referrer parameter to only show the message when coming from Page 1
            if (pageHeaderReferer != null && pageHeaderReferer.containsIgnoreCase('/apex/AH_CostControlUpdate') && message != 'null')
            {
                ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM, 'Record updated Successfully. Thank you!'));                 
            }
        }
    }      
    
    // SAVE TO DATABASE
    public PageReference doSave()
    {
        
        List<User> usrs = new List<User>();
        
        try
        {
            for (WrapperUser wr : usrlst)
            {
                if (wr.flag)
                {                   
                    if
                        ((wr.usr.FFA_Company__c == null || wr.usr.FFA_Company__c == '')
                         && (wr.usr.FFA_Dimension_2__c ==null || wr.usr.FFA_Dimension_2__c == '')
                         && (wr.usr.FFA_Dimension_3__c == null || wr.usr.FFA_Dimension_3__c == ''))
                    {
                        wr.usr.Cost_Ctr__c = '';                  
                    }                   
                    usrs.add(wr.usr);    
                }      
            } 
            PageReference pg = null;
            if (!usrs.isEmpty())
            {
                update usrs; 
                pg = new PageReference('/apex/AH_CostControlUpdate');
                pg.getParameters().put('message', 'Save');
                pg.setRedirect(true);
            }
            else
            {                
                ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please select a record and then click save.'));
            }
            
            return pg;
        }
        catch(DMLException e)
        {
            PageReference pg = new PageReference('/apex/AH_CostControlUpdate');
            pg.getParameters().put('Errormessage', 'Record update failed: ' + e.getMessage());
            pg.setRedirect(true);  
            return pg;
        }

    }
    
    // Query again 
    public void queryAgain()
    {
system.debug(' *** OffsetSize = ' + OffsetSize);        
        usrlst = new List<WrapperUser>(); 
        
        for (User usr: [SELECT Id, Name, Email, FirstName, LastName, Department, Title, Manager.Name, Controlling_Verified__c, 
                       FFA_Company__c, FFA_Dimension_2__c, FFA_Dimension_3__c, Cost_Ctr__c 
                       FROM User 
                       WHERE Controlling_Verified__c = false 
                       AND IsActive = true 
                       AND UserType = 'Standard'
                       ORDER BY LastName, FirstName 
                       LIMIT : QueryLimit 
                       OFFSET : OffsetSize])
        {
            WrapperUser wr = new WrapperUser();
            wr.flag =false;
            wr.usr = usr;	
            usrlst.add(wr);
        }
    }
    
    // Pagination 
    public Boolean getDisablePrevious()
    {
        if (OffsetSize > 0)
        {
            return false;
        }
        else 
        {
            return true;
        }
    }
    
    public Boolean getDisableNext() 
    {
        if (OffsetSize + QueryLimit < countTotalRecords)
        {
            return false;
        }
        else 
        {
            return true;
        }
    }
    
    public PageReference Next() 
    {    
        OffsetSize += QueryLimit;
        queryAgain();
        return null;
    }
    
    public PageReference Previous() 
    {
        OffsetSize -= QueryLimit;
        queryAgain();
        return null;
    }
    
    public class WrapperUser 
    {
        public Boolean flag {get; set;}
        public User usr {get; set;}
    }
    
}