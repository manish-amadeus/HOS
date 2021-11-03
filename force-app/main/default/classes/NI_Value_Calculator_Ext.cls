/****************************************************************************************
Name            : NI_Value_Calculator_Ext Class
Author          : Sean Harris
Created Date    : 08/13/14
Last Mod Date   : 
Last Mod By     : 
NICC Reference  : NICC-011403 Newmarket Value Calculator 
Description     : 
                : 
                : 
******************************************************************************************/
public with sharing class NI_Value_Calculator_Ext 
{

    private NI_Value_Calculator__c nvc;
    private Apexpages.StandardController ctrl;

    public NI_Value_Calculator_Ext(ApexPages.StandardController controller) 
    {
        this.ctrl = controller;
    }

    public PageReference save() 
    {
        this.ctrl.save();
        this.nvc = (NI_Value_Calculator__c)ctrl.getRecord(); 
        string strUrl = '/apex/NI_Value_Calculator?id=' + nvc.Id;              
        
        //PageReference newPage = New PageReference('/apex/NI_Value_Calculator');
        //newPage.getParameters().put('id', nvc.Id);
        
        PageReference newPage = new PageReference(strUrl);  
        newPage.setRedirect(true);
        return newPage;
    }

}