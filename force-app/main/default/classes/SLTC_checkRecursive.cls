/****************************************************************************************
Name            : SLTC_checkRecursive 
Author          : Heema solanki
Created Date    : 02/06/2022
Last Mod Date   : 
Last Mod By     : 
NICC Reference  : 
Description     : Class for recursive check flag
****************************************************************************************/

public Class SLTC_checkRecursive{
    private static boolean isRun = true;
    public static boolean runOnce(){
        if(isRun){
            isRun=false;
            return true;
        }else{
            return isRun;
        }
    }
}