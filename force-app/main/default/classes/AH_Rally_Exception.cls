/****************************************************************************************
Name            : AH_Rally_Exception (TC Org Name: MyException) 
Author          : Valerie Gallardo
Created Date    : 01/21/2014
Last Mod Date   : 11/25/2020
Last Mod By     : Sean Harris
NICC Reference  : NICC-047046
Description     : 
				: 
				: 
******************************************************************************************/
public class AH_Rally_Exception extends Exception 
{
    public String getCustomMessage()
    {
    	return 'CustomMessage';
    }
}