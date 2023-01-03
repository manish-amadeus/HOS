public class NI_LocalTime_IMTContactCtrl {
    
    private String offset;
    public Decimal freq {set;get;}
    private String sEnd;
    public String ctTime {set;get;} 
    
    public NI_LocalTime_IMTContactCtrl(ApexPages.StandardController stdController) {                
        NI_IMT_Contact__c rec = (NI_IMT_Contact__c) stdController.getRecord();
        // the fields needs to be outputted first in the visualforce page so that they
        // can be used here.
        // <apex:outputText value="{!NI_IMT_Property__c.Country__c}" rendered="false"/>
        // <apex:outputText value="{!NI_IMT_Property__c.State__c}" rendered="false"/>
        // <apex:outputText value="{!NI_IMT_Property__c.City__c}" rendered="false"/>
        // <apex:outputText value="{!NI_IMT_Property__c.Phone__c}" rendered="false"/>
        // Otherwise you need to do an explicty query for these fields
        CalculateLocalTime(rec.Country__c, rec.State__c, rec.City__c, rec.Phone__c);        
    }
    
    private void CalculateLocalTime(String sCountry, String sState, String sCity, String sPhone) {        
        String s = tz.LocalTime.CalculateLocalTime(sCountry, sState, sCity, sPhone);

        JSONParser parser = JSON.createParser(s);

        parser.nextToken();
        parser.nextValue();
        offset = parser.getText();

        parser.nextToken();
        parser.nextValue();
        sEnd = parser.getText();

        if(sEnd == 'N/A') sEnd = '';  

        freq = tz.LocalTime.getFrequency(); // update every minute
        refreshTime();
    }

    public PageReference refreshTime() {
        if(offset!='N/A') ctTime = tz.LocalTime.getLocalTimeString(Decimal.valueof(offset)) + ' ' + sEnd;
        else ctTime = 'Unknown';     
        return null;
    }           
}