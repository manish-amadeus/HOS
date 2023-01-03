// DISABLED "IMT" Implementation Tool designed for IHG 
/****************************************************************************************
Name            : NI_IMT_Assignment_LocalTime_Controller Class
Author          : Damodar Raut
Created Date    : 04/01/2016
Last Mod Date   :  
Last Mod By     : 
NICC Reference  : 
Description     : Controler class for VF Page called: AssignmentLocalTime
				: 
******************************************************************************************/
public class NI_IMT_Assignment_LocalTime_Controller 
{
    
	public String localTime {get; set;}
    private pse__Assignment__c assignment {get; set;}
    private String offset;
    public Decimal freq {set; get;}
    private String sEnd;
    
    public NI_IMT_Assignment_LocalTime_Controller(ApexPages.StandardController controller) 
    {
    	//Fetch country state city and phone info from related property and pass to calculateLocalTime function
        assignment = (pse__Assignment__c)controller.getRecord();
/*        
        pse__Assignment__c assig = [SELECT pse__Project__r.IMT_Property__r.Country__c,
                             	pse__Project__r.IMT_Property__r.State__c,
                             	pse__Project__r.IMT_Property__r.City__c,
                             	pse__Project__r.IMT_Property__r.Phone__c
                             FROM pse__Assignment__c 
                             WHERE id = :assignment.Id];
*/       
pse__Assignment__c assig = assignment;
        calculateLocalTime(assig.pse__Project__r.IMT_Property__r.Country__c, assig.pse__Project__r.IMT_Property__r.State__c, assig.pse__Project__r.IMT_Property__r.City__c, assig.pse__Project__r.IMT_Property__r.Phone__c);

    }
    
    
    // GET THE LOCAL TIME OF THE PROPERTY
    public void calculateLocalTime(String sCountry, String sState, String sCity, String sPhone)
    {        
/*        
        //CALL TO LOCAL TIME APP SERVICE
        String s = tz.LocalTime.CalculateLocalTime(sCountry, sState, sCity, sPhone);
		//PROCESS THE RESULT
        JSONParser parser = JSON.createParser(s);
        parser.nextToken();
        parser.nextValue();
        offset = parser.getText();
        parser.nextToken();
        parser.nextValue();
        sEnd = parser.getText();
        if(sEnd == 'N/A') sEnd = '';
        freq = 60000; // update every minute
*/        
        refreshTime();
    }
    
	//DISPLAY LOCAL TIME AFTER EVERY MINUTE
    public PageReference refreshTime()
    {
/*        
        if(offset!='N/A') localTime = tz.LocalTime.getLocalTimeString(Decimal.valueof(offset)) + ' ' + sEnd;
        else localTime = 'Unknown';
        system.debug('Time is ' + localTime);
*/
        return null;
    } 
    
}