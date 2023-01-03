/****************************************************************************************
Name            : AH_CC_Alerts
Author          : Sean Harris
Created Date    : 12/10/2019
Last Mod Date   : 12/10/2019
Last Mod By     : Sean Harris
NICC Reference  : 
Description     : Controller class for AH_CC_Alerts VF page
                : 
******************************************************************************************/
public class AH_CC_Alerts 
{
    
    public List<message> lstMsgs {get; set;}  
    public boolean hasMsgs {get; set;}  
    
    public AH_CC_Alerts()
    {   
        
        hasMsgs = false;
        
        List<Customer_Community_Alerts__c> lst = new List<Customer_Community_Alerts__c>(
            [SELECT Alert_Message__c, Font_Color__c, Font_Size__c 
             FROM Customer_Community_Alerts__c 
             WHERE Show_in_Community__c = true]);
        
        if (!lst.isEmpty()) 
        {
            
            hasMsgs = true;
            lstMsgs = new List<message>();
            
            for (Customer_Community_Alerts__c x : lst)
            {
                message msg = new message(x.Alert_Message__c, x.Font_Size__c, x.Font_Color__c);
                lstMsgs.add(msg);
            }            
            
        }

    }    
    
    public class message
    {  
    	public String strMessage {get; set;}
        public String strFontSize {get; set;} 
        public String strFontColor {get; set;}

        public message(String p1, String p2, String p3)
        {
            this.strMessage = p1;
            this.strFontSize = p2;
            this.strFontColor = p3;
        }
    }
    
}