/*************************************************************************************************
Name            : NI_ServiceNowFunctionsTest Class
Author          : Shashikant Nikam
Created Date    : 10/05/2020
Last Mod Date   : 12/19/2020 
Last Mod By     : Stuart Emery
NICC Reference  : NICC-047197
Description     : Test class for the AH_getWorkstreamList class
                : 
*************************************************************************************************/
@isTest
public class AH_getWorkstreamList_Test 
{

    @isTest
    public static void testMethod1()
    {
        
        Test.startTest();
        
        List<AH_getWorkstreamList.flowInputvalues> flowIpValueList = new List<AH_getWorkstreamList.flowInputvalues>();
        
        AH_getWorkstreamList.flowInputvalues ipValue = new AH_getWorkstreamList.flowInputvalues();
        ipValue.workstreamsImpactedChkboxGroup = 'a1211000003QkYRAA0; a1211000003QkYgAAK; a1211000003QkciAAC';
        ipValue.TechworkstreamsImpactedChkboxGroup = 'a1211000003QkYqAAK; a1211000003QkYvAAK';
        flowIpValueList.add(ipValue);
        
        List<AH_getWorkstreamList.flowOutputvalues> outputList = AH_getWorkstreamList.handleWorkStreamsData(flowIpValueList);
        
        system.debug('outputBusinessWorkstreams : '+outputList[0].outputBusinessWorkstreams.size());
        
        system.assertEquals(5, outputList[0].outputBusinessWorkstreams.size(), 'List size is not matching...');
        
        Test.stopTest();
        
    }
    
}