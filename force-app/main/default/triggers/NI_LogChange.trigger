/************************************************************************************************
Name            : NI_LogChange Trigger
Author          : Stuart Emery
Created Date    : 10/20/2016
Last Mod Date   : 10/20/2016
Last Mod By     : Stuart Emery
NICC Reference  : 
Description     : Trigger for the MTech_Saas_Subscription__c Object
                :
*************************************************************************************************/
trigger NI_LogChange on MTech_Saas_Subscription__c (after insert, after update) 
{
    
    if (!NI_FUNCTIONS.bypassTriggerCode('MTECH SaaS'))
    { 
        string ErrorMsg = '';
        string Reason;
        decimal OldQty;
        decimal OldPrice;
        date OldExpiration;
        decimal OldABR;
        boolean OldIsDeleted;
        decimal NewQty;
        decimal NewPrice;
        date NewExpiration;
        decimal NewABR;
        boolean NewIsDeleted;
        decimal NetABRchange;
        
        // validate modification reason
        
        for (MTech_SaaS_Subscription__c ssub : Trigger.new) {
            
            // get new values
            NewQty = Trigger.newMap.get(ssub.Id).quantity__c;
            NewPrice = Trigger.newMap.get(ssub.Id).unit_price__c;
            NewExpiration = Trigger.newMap.get(ssub.Id).price_expiration_date__c;
            NewIsDeleted = Trigger.newMap.get(ssub.Id).is_deleted__c;
            NewABR = NewQty * NewPrice;
            Reason = ssub.Modification_Reason__c;
            
            if (Trigger.isinsert) {
                
                // INSERT - set old values
                OldQty = null;
                OldPrice = null;
                OldExpiration = null;
                OldIsDeleted = false;
                OldABR = 0;
                
                // validate new subscription reason
                if (ssub.Modification_Reason__c == 'Lost Account') ErrorMsg = 'Invalid Reason for a new Subscription';
                else if (Reason == 'Legacy Start') ErrorMsg = 'Invalid Reason for a new Subscription';
                else if (Reason == 'Subscription Dropped') ErrorMsg = 'Invalid Reason for a new Subscription';
                else if (Reason == 'Qty Increased') ErrorMsg = 'Invalid Reason for a new Subscription';
                else if (Reason == 'Qty Decreased') ErrorMsg = 'Invalid Reason for a new Subscription';
                else if (Reason == 'Price Increased') ErrorMsg = 'Invalid Reason for a new Subscription';
                else if (Reason == 'Price Decreased') ErrorMsg = 'Invalid Reason for a new Subscription';
                else if (Reason == 'Qty and Price Changed') ErrorMsg = 'Invalid Reason for a new Subscription';
                else if (Reason == 'Expiration Change Only') ErrorMsg = 'Invalid Reason for a new Subscription';
                
            }   
            else {
                
                //UPDATE - get old values
                OldQty = Trigger.oldMap.get(ssub.Id).quantity__c;
                OldPrice = Trigger.oldMap.get(ssub.Id).unit_price__c;
                OldExpiration = Trigger.oldMap.get(ssub.Id).price_expiration_date__c;
                OldIsDeleted = Trigger.oldMap.get(ssub.Id).is_deleted__c;
                OldABR = OldQty * OldPrice;
                
                // validate updated subscription reason 
                if (Reason == 'Legacy Start') ErrorMsg = 'Invalid Reason for an existing Subscription';
                else if (Reason == 'New Account') ErrorMsg = 'Invalid Reason for an existing Subscription';
                if (NewIsDeleted && !OldIsDeleted) {
                    // subscription is being deleted
                    if (Reason == 'Subscription Added') ErrorMsg = 'Invalid Reason for deleting subscription';
                    if (Reason == 'Quantity Increased') ErrorMsg = 'Invalid Reason for deleting subscription';
                    if (Reason == 'Quantity Decreased') ErrorMsg = 'Invalid Reason for deleting subscription';
                    if (Reason == 'Price Increased') ErrorMsg = 'Invalid Reason for deleting subscription';
                    if (Reason == 'Price Decreased') ErrorMsg = 'Invalid Reason for deleting subscription';
                    if (Reason == 'Quantity and Price Changed') ErrorMsg = 'Invalid Reason for deleting subscription';
                    if (Reason == 'Expiration Change Only') ErrorMsg = 'Invalid Reason for deleting subscription';
                }
                if (OldIsDeleted && !NewIsDeleted) {
                    // subscription is being undeleted
                    if (Reason != 'Subscription Added') ErrorMsg = 'Reason for undeleting subscription must be Subscription Added';
                }
                if ((!OldIsDeleted && !NewIsDeleted) || (OldIsDeleted && NewIsDeleted)) {
                    // subscription deleted status is unchanged
                    if ((NewQty != OldQty) && (Reason == 'Subscription Dropped')) ErrorMsg = 'Invalid Reason for changed quantity';
                    if ((NewQty != OldQty) && (Reason == 'Price Increased')) ErrorMsg = 'Invalid Reason for changed quantity';
                    if ((NewQty != OldQty) && (Reason == 'Price Decreased')) ErrorMsg = 'Invalid Reason for changed quantity';
                    if ((NewQty > OldQty) && (Reason == 'Quantity Decreased')) ErrorMsg = 'Invalid Reason for increased quantity';
                    if ((NewQty < OldQty) && (Reason == 'Quantity Increased')) ErrorMsg = 'Invalid Reason for decreased quantity';
                    if ((NewPrice != OldPrice) && (Reason == 'Subscription Dropped')) ErrorMsg = 'Invalid Reason for changed price';
                    if ((NewPrice != OldPrice) && (Reason == 'Quantity Increased')) ErrorMsg = 'Invalid Reason for changed price';
                    if ((NewPrice != OldPrice) && (Reason == 'Quantity Decreased')) ErrorMsg = 'Invalid Reason for changed price';
                    if ((NewPrice > OldPrice) && (Reason == 'Price Decreased')) ErrorMsg = 'Invalid Reason for increased price';
                    if ((NewPrice < OldPrice) && (Reason == 'Price Increased')) ErrorMsg = 'Invalid Reason for decreased price';
                    if (((NewPrice != OldPrice) || (NewQty != OldQty)) && (OldExpiration == NewExpiration) && (Reason == 'Expiration Change Only')) ErrorMsg = 'Invalid Reason for changed price and/or quantity';
                    if ((NewPrice != OldPrice) && (NewQty != OldQty) && (Reason != 'Quantity and Price Changed')) ErrorMsg = 'Reason must be Quantity and Price Changed';
                    if (((NewPrice == OldPrice) || (NewQty == OldQty)) && (Reason == 'Quantity and Price Changed')) ErrorMsg = 'Invalid Reason when either quantity or price is not changed';
                }
            }
            
            // calculate net ABR change
            
            if (OldIsDeleted == true) OldABR = 0;
            if (NewIsDeleted == true) NewABR = 0;
            NetABRchange = NewABR - OldABR;
            
            // create SaaS Log record
            
            if (ErrorMsg == '') {
                
                List<MTech_Saas_log__c> slog = new List<MTech_Saas_log__c>();
                
                slog.add(new MTech_Saas_log__c (  MTech_SaaS_Subscription__c = ssub.ID,
                                                Account__c = ssub.Account__c,
                                                Old_Qty__c = OldQty,
                                                New_Qty__c = NewQty,
                                                Old_Price__c = OldPrice,
                                                New_Price__c = NewPrice,
                                                Old_Expiration__c = OldExpiration,
                                                New_Expiration__c = NewExpiration,
                                                Net_ABR_Change__c = NetABRchange,
                                                Reason__c = ssub.Modification_Reason__c));
                insert slog;
                
            }
            else {
                
                ssub.Modification_Reason__c.addError(ErrorMsg);
                
            }
        }
    }
}