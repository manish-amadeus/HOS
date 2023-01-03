/*
 * Name         : AH_UDC_Constants.cls
 * Created By   : George Tasker (george.tasker@amadeus.com)
 * Created Date : 2021-Jul-03
 * Description  : Contains definitions of constant strings and numbers that are used throughout the application
 *                all stored under one class for ease in changing values used in multiple places, and to 
 *                provide a consistent source of where these defaults/strings can be stored
 * Dependencies : None
 * Test Class   : N/A
 */
public class AH_UDC_Constants {

   public static final String FORM_TOKEN_PREFIX = '{TOKEN}';

   //public static final String WORKBOOK_AKA = 'Workbook';

   public static final String APPLICATION_NAME = 'Unified Data Collection';
   public static final String APPLICATION_PREFIX = '';

   public static final String CONFIG_KEY_COMMUNITY_PROFILE_WITH_CHATTER = 'AH_UDC_CommunityProfileWithChatter';
   public static final String CONFIG_KEY_COMMUNITY_PROFILE_WITHOUT_CHATTER = 'AH_UDC_CommunityProfileNoChatter';
   public static final String CONFIG_KEY_PSA_SF_LIGHTNING = 'AH_UDC_PSAProfile';

   public static final String DEFAULT_COMMUNITY_USER_NAME_POSTFIX = '.ahcc';

   public static final String PROFILE_DEFAULT_NAME_COMMUNITY_PLUS_LOGIN_WITH_CHATTER = 'AH Customer Community Plus Login User';
   public static final String PROFILE_DEFAULT_NAME_COMMUNITY_PLUS_LOGIN_WITHOUT_CHATTER = 'AH Customer Community Plus Login - No Chatter';
   public static final String PROFILE_DEFAULT_NAME_PSA_SF_LIGHTNING = 'AH PSA T&E - SF - Lightning';

   public static final String STEP_STATUS_NEW = 'New';
   public static final String STEP_STATUS_LOCKED = 'Locked';
   public static final String STEP_STATUS_IN_PROGRESS = 'In Progress';
   public static final String STEP_STATUS_COMPLETED = 'Completed';

   public static final String SENT_STATUS_NEW = 'New';
   public static final String SENT_STATUS_IN_PROGRESS = 'In Progress';
   public static final String SENT_STATUS_COMPLETE_LOCKED = 'Completed/Locked';
   public static final String SENT_STATUS_FAILED_TO_SEND = 'Failed To Send';

   public static final String RECORD_TYPE_WORKBOOK = 'AH_UDC_Workbook';
   public static final String RECORD_TYPE_WORKBOOK_SENT = 'AH_UDC_WorkbookSent';
   public static final String RECORD_TYPE_WORKBOOK_STEP = 'AH_UDC_WorkbookStep';
   public static final String RECORD_TYPE_WORKBOOK_STEP_SENT = 'AH_UDC_WorkbookStepSent';
   public static final String RECORD_TYPE_RESPONSE_FORM_ASSEMBLY = 'AH_UDC_ResponseFormAssembly';
   public static final String RECORD_TYPE_RESPONSE_QA_FORM_ASSEMBLY = 'AH_UDC_ResponseQAFormAssembly';

   public static final String PERMISSIONSET_DEFAULT_NAME_UDC_SYSTEM_ADMIN = 'AH_UDC_SystemAdministrator';
   public static final String PERMISSIONSET_DEFAULT_NAME_UDC_WORKBOOK_ADMIN = 'AH_UDC_WorkbookAdministrator';
   public static final String PERMISSIONSET_DEFAULT_NAME_UDC_WORKBOOK_USER = 'AH_UDC_WorkbookUser';
   public static final String PERMISSIONSET_DEFAULT_NAME_UDC_COMMUNITY_USER = 'AH_UDC_CommunityUser';
   public static final String PERMISSIONSET_DEFAULT_NAME_UDC_SERVICE = 'AH_UDC_Service';

   public static final String FORM_TYPE_CENTRAL = 'Central';
   public static final String FORM_TYPE_SHARED = 'Shared';
   public static final String FORM_TYPE_PRODUCT = 'Product';

   public static List<String> SOLUTION_DELIVERY_PREFIXES = new List<String> { 'ahsvc_', 'nisvc_', 'AH_UDC_' };

}