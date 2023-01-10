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