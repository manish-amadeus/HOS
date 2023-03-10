global class INIT_MassUpdateContactEmailsBatch implements Database.Batchable<sObject>
{

   global final String query;
   global final String SPECIAL_CHAR_PATTERN = '[^\\w\\*]';
   global Database.QueryLocator start(Database.BatchableContext BC)
   {
       String orgAbbreviation = '.' + UserInfo.getUserName().substringAfterLast('.');
       return Database.getQueryLocator('SELECT Id, Email FROM Contact WHERE Email != NULL AND FirstName != NULL AND Status__c = \'Active\' AND (NOT Email LIKE \'%.' + orgAbbreviation + '\')');
   }

   global void execute(Database.BatchableContext BC, List<SObject> scope)
   {
       List<Contact> lstContacts = new List<Contact>();
       String orgAbbreviation = '.' + UserInfo.getUserName().substringAfterLast('.');
       if (orgAbbreviation == '.com')
       {
           return;
       }
       
       for (Sobject s : scope)
       {
           Contact a = (Contact) s;
           if (a.Email != NULL && !checkSpecialCharacter(a.Email))
           {
               if (a.Email.countMatches(orgAbbreviation) == 2)
               {
                   a.Email = a.Email.replace(orgAbbreviation + orgAbbreviation, orgAbbreviation);
               }
               else if(a.Email.countMatches(orgAbbreviation) == 3)
               {   
                   a.Email = a.Email.replace(orgAbbreviation + orgAbbreviation + orgAbbreviation, orgAbbreviation);
               }
               else if(a.Email.countMatches(orgAbbreviation) == 4)
               {
                   a.Email = a.Email.replace(orgAbbreviation + orgAbbreviation + orgAbbreviation + orgAbbreviation, orgAbbreviation);
               }
               else if(a.Email.countMatches(orgAbbreviation) == 0)
               {
                   a.Email = a.Email + orgAbbreviation;
               }
               lstContacts.add(a);   
           }
       }
       //Update lstContacts;
       database.update(lstContacts, false);
   }

   global Boolean checkSpecialCharacter(String email)
   {
       Boolean isSpecial = false;
       Pattern p = Pattern.compile(SPECIAL_CHAR_PATTERN);
       Matcher pm = p.matcher(email);
       while (pm.find())
       {
           if (pm.group(0) != '.' && pm.group(0) != '@')
           {
               isSpecial = true;  
           }
       }
       return isSpecial;
   }

   global void finish(Database.BatchableContext BC)
   {
   }   
  

}