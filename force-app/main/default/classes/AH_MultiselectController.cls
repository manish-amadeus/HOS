/****************************************************************************************
Name            : AH_MultiselectController Class
Author          : Cybage Developer - Shashikant Nikam
Created Date    : 01/15/2018
Last Mod Date   : 04/18/2018
Last Mod By     : Cybage Developer - Ria Chawla
NICC Reference  : NICC-026092
Description     : Controller for AH_MultiselectPicklist VF component.
                :
*****************************************************************************************/
public with sharing class AH_MultiselectController 
{
    
    //  SelectOption LISTS FOR PUBLIC CONSUMPTION
    public SelectOption[] leftOptions1 { get; set; } 
    public SelectOption[] rightOptions1 { get; set; }
    
    // PARSE & SEPARATED VALUES AND LABELS FROM VALUE AND PUT THEM IN OPTION
    private void setOptions(SelectOption[] options, String value) 
    {
        options.clear();
        String[] parts = value.split('&');
        for (Integer i=0; i<parts.size()/2; i++) 
        {
            options.add(new SelectOption(EncodingUtil.urlDecode(parts[i*2], 'UTF-8'), 
                                         EncodingUtil.urlDecode(parts[(i*2)+1], 'UTF-8')));
        }
    }
    
    // BACKING FOR HIDDEN TEXT FIELD CONTAINING THE OPTIONS FROM THE LEFT LIST
    public String leftOptionsHidden { get; set {
            leftOptionsHidden = value;
            setOptions(leftOptions1, value);
        }
    }
    
    // BACKING FOR HIDDEN TEXT FIELD CONTAINING THE OPTIONS FROM THE RIGHT LIST
    public String rightOptionsHidden { get; set {
            rightOptionsHidden = value;
            setOptions(rightOptions1, value);
        }
    }
    
}