/****************************************************************************************
Name            : AH_Rally_UserStoryDetails (TC Org Name: UserStoryDetails)
Author          : Valerie Gallardo
Created Date    : 01/21/2014
Last Mod Date   : 11/25/2020
Last Mod By     : Sean Harris
NICC Reference  : NICC-
Description     : 
				: 
******************************************************************************************/
public class AH_Rally_UserStoryDetails 
{
    
    static
    {
        if (Test.isRunningTest())
        {
            ReleaseofUS Release1 = new ReleaseofUS();
            OwnerofUS Owner1 = new OwnerofUS();
            ProjectofUS Project1 = new ProjectofUS();
            SalesforceCaseId CaseId1 = new SalesforceCaseId();
        }
    }

    public String ref;
    public String ObjectID;
    public String FormattedID;
    public String LastUpdateDate;
    public ReleaseofUS Release;
    public ProjectofUS Project;
    public OwnerofUS Owner;
    public String L3KanbanStage;
    public String RetentionRisk;
    public string TargetCompletionDate;
    public String TargetReleaseQuarter; //US118032
    public string SalesforcePriority;    
    public SalesforceCaseId SalesforceCase;

    public class OwnerofUS
    {
        public String ref;
        public String refObjectName;
    }
    
    public class ProjectofUS
    {
        public String ref;
        public String refObjectName;
    }
    
    public class ReleaseofUS
    {
        public String ref;
        public String refObjectName;
    }
    
    public class SalesforceCaseId
    {
        public String LinkID;
        public String DisplayString;
    }
    
}