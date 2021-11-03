/****************************************************************************************
Name            : ParentSolutionController 
Author          : Black Iron Group
Created Date    : 07/18/2010 
Last Mod Date   : 04/25/2017 
Last Mod By     : Sean Harris
NICC Reference  : 
Description     : This class is an extention controller for a VF Page called ParentSolution
                : 
				: 
****************************************************************************************/
public with sharing class ParentSolutionController 
{

	public PageReference case() 
    {
		return new PageReference('/'+ ApexPages.CurrentPage().getParameters().get('id') + '?nooverride=1');
	}

}