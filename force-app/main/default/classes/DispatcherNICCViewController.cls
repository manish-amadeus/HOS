public class DispatcherNICCViewController 
{
 
	public DispatcherNICCViewController(ApexPages.StandardController controller) 
	{
	    this.controller = controller;
	}
 
    public PageReference getRedir() 
    {
 
        NI_Change_Control__c r = [Select id, recordtypeid From NI_Change_Control__c Where Id = :ApexPages.currentPage().getParameters().get('id')];
 
        PageReference newPage;
 
         //if (r.recordtypeid == '012P00000000FG2') 
		if (r.recordtypeid == '01260000000166y')
        {
            newPage = Page.NI_Change_Control_Tabbed_Layout;
        } 
        else 
        {
            newPage = new PageReference('/' + r.id);
            newPage.getParameters().put('nooverride', '1');
        }
 
        newPage.getParameters().put('id', r.id);
        return newPage.setRedirect(true);
 
    }
 
    private final ApexPages.StandardController controller;
 
}