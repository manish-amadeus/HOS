/***********************************************************************************************
  Name            : AH_UDC_DateFormat
  Author          : Tushar Gupta
  Created Date    : 18-Mar-2021
  Last Mod Date   : 18-Mar-2021
  Last Mod By     : Tushar Gupta
  NICC Reference  : 
  Description     : Date format based on local
  Change History  :599332 - Workbook due date on Workbook Send screen should format according to Workbook User's locale
 ************************************************************************************************/
public with sharing class AH_UDC_DateFormat {
   //returns the properly formatted datetime value
   public Static String GetDateFormat() {
      Map<String, String> mappedValues = null;
      String user_locale = '';
      try {
         mappedValues = new Map<String, String> (); //map for holding locale to datetime format
         mappedValues = MapValues(); //populate the map with all the locale specific datetime formats
         user_locale = UserInfo.getLocale(); //grab the locale of the user
         String datetime_format = 'mm/dd/yy'; //variable for the datetime format defaulted to the US format
         if (mappedValues.containsKey(user_locale)) { //if the map contains the correct datetime format
            datetime_format = mappedValues.get(user_locale); //grab the datetime format for the locale
         }
         return datetime_format; //return the string
      }
      catch(Exception ex) {
         system.debug('Error occurred : ' + ex.getMessage() + ' at Line Number ' + ex.getLineNumber());
         ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, System.Label.AH_UDC_Common_Error_Message));
         return '';
      }
      finally {
         mappedValues = null;
         user_locale = '';
      }
   }

   //populate a map with locale values and corresponding datetime formats
   private Static Map<String, String> MapValues() {
      try {
         Map<String, String> locale_map = new Map<String, String> (); //holds the locale to timedate formats
         locale_map.put('af_ZA', 'yy-mm-dd');
         locale_map.put('af', 'yy-mm-dd');
         locale_map.put('ar', 'dd/mm/yy');
         locale_map.put('ar_AE', 'dd/mm/yy');
         locale_map.put('ar_BH', 'dd/mm/yy');
         locale_map.put('ar_DZ', 'dd/mm/yy');
         locale_map.put('ar_EG', 'dd/mm/yy');
         locale_map.put('ar_IQ', 'dd/mm/yy');
         locale_map.put('ar_JO', 'dd/mm/yy');
         locale_map.put('ar_KW', 'dld/mm/yy');
         locale_map.put('ar_LB', 'dd/mm/yy');
         locale_map.put('ar_LY', 'dd/mm/yy');
         locale_map.put('ar_MA', 'dd/mm/yy');
         locale_map.put('ar_OM', 'dd/mm/yy');
         locale_map.put('ar_QA', 'dd/mm/yy');
         locale_map.put('ar_SA', 'dd/mm/yy');
         locale_map.put('ar_SD', 'dd/mm/yy');
         locale_map.put('ar_SY', 'dd/mm/yy');
         locale_map.put('ar_TN', 'dd/mm/yy');
         locale_map.put('ar_YE', 'dd/mm/yy');
         locale_map.put('az_AZ', 'dd.mm.yy');
         locale_map.put('be_BY', 'dd.mm.yy');
         locale_map.put('bg_BG', 'dd.mm.yy');
         locale_map.put('bn_BD', 'dd/mm/yy');
         locale_map.put('bn_IN', 'dd/mm/yy');
         locale_map.put('bs_BA', 'dd.mm.yy.');
         locale_map.put('bs', 'dd.mm.yy.');
         locale_map.put('ca_ES', 'dd/mm/yy');
         locale_map.put('ca_ES_EURO', 'dd/mm/yy');
         locale_map.put('cs_CZ', 'dd.mm.yy');
         locale_map.put('cy_GB', 'dd/mm/yy');
         locale_map.put('da_DK', 'dd-mm-yy');
         locale_map.put('de', 'dd.mm.yy');
         locale_map.put('de_AT', 'dd.mm.yy');
         locale_map.put('de_AT_EURO', 'dd.mm.yy');
         locale_map.put('de_BE', 'dd.mm.yy');
         locale_map.put('de_DE', 'dd.mm.yy');
         locale_map.put('de_DE_EURO', 'dd.mm.yy');
         locale_map.put('de_LU', 'dd.mm.yy');
         locale_map.put('de_LU_EURO', 'dd.mm.yy');
         locale_map.put('de_CH', 'dd.mm.yy');
         locale_map.put('dz_BT', 'yy-mm-dd');
         locale_map.put('el_GR', 'dd/mm/yy');
         locale_map.put('en_AG', 'dd/mm/yy');
         locale_map.put('en', 'dd/mm/yy');
         locale_map.put('en_AU', 'dd/mm/yy');
         locale_map.put('en_BB', 'dd/mm/yy');
         locale_map.put('en_BS', 'dd/mm/yy');
         locale_map.put('en_BZ', 'dd/mm/yy');
         locale_map.put('en_BM', 'dd/mm/yy');
         locale_map.put('en_BW', 'dd/mm/yy');
         locale_map.put('en_CA', 'dd/mm/yy');
         locale_map.put('en_CM', 'dd/mm/yy');
         locale_map.put('en_KY', 'dd/mm/yy');
         locale_map.put('en_ER', 'dd/mm/yy');
         locale_map.put('en_FK', 'dd/mm/yy');
         locale_map.put('en_FJ', 'dd/mm/yy');
         locale_map.put('en_GM', 'dd/mm/yy');
         locale_map.put('en_GH', 'dd/mm/yy');
         locale_map.put('en_GI', 'dd/mm/yy');
         locale_map.put('en_GY', 'dd/mm/yy');
         locale_map.put('en_HK', 'dd/mm/yy');
         locale_map.put('en_IN', 'dd/mm/yy');
         locale_map.put('en_ID', 'dd/mm/yy');
         locale_map.put('en_IE', 'dd/mm/yy');
         locale_map.put('en_IE_EURO', 'dd/mm/yy');
         locale_map.put('en_JM', 'dd/mm/yy');
         locale_map.put('en_KE', 'dd/mm/yy');
         locale_map.put('en_LR', 'dd/mm/yy');
         locale_map.put('en_MG', 'dd/mm/yy');
         locale_map.put('en_MW', 'dd/mm/yy');
         locale_map.put('en_MY', 'dd/mm/yy');
         locale_map.put('en_MU', 'dd/mm/yy');
         locale_map.put('en_NA', 'dd/mm/yy');
         locale_map.put('en_NZ', 'dd/mm/yy');
         locale_map.put('en_NG', 'dd/mm/yy');
         locale_map.put('en_PK', 'dd/mm/yy');
         locale_map.put('en_PG', 'dd/mm/yy');
         locale_map.put('en_PH', 'mm/dd/yy');
         locale_map.put('en_RW', 'dd/mm/yy');
         locale_map.put('en_SH', 'dd/mm/yy');
         locale_map.put('en_WS', 'dd/mm/yy');
         locale_map.put('en_SC', 'dd/mm/yy');
         locale_map.put('en_SL', 'dd/mm/yy');
         locale_map.put('en_SG', 'dd/mm/yy');
         locale_map.put('en_SX', 'dd/mm/yy');
         locale_map.put('en_SB', 'dd/mm/yy');
         locale_map.put('en_ZA', 'yy/mm/dd');
         locale_map.put('en_SZ', 'dd/mm/yy');
         locale_map.put('en_TZ', 'dd/mm/yy');
         locale_map.put('en_TO', 'dd/mm/yy');
         locale_map.put('en_TT', 'dd/mm/yy');
         locale_map.put('en_UG', 'dd/mm/yy');
         locale_map.put('en_GB', 'dd/mm/yy');
         locale_map.put('en_US', 'mm/dd/yy');
         locale_map.put('en_VU', 'dd/mm/yy');
         locale_map.put('es', 'dd/mm/yy');
         locale_map.put('es_AR', 'dd/mm/yy');
         locale_map.put('es_BO', 'dd-mm-yy');
         locale_map.put('es_CL', 'dd-mm-yy');
         locale_map.put('es_CO', 'dd/mm/yy');
         locale_map.put('es_CR', 'dd/mm/yy');
         locale_map.put('es_CU', 'dd/M/yy');
         locale_map.put('es_DO', 'dd/mm/yy');
         locale_map.put('es_EC', 'dd/mm/yy');
         locale_map.put('es_ES', 'dd/mm/yy');
         locale_map.put('es_ES_EURO', 'dd/mm/yy');
         locale_map.put('es_GT', 'dd/mm/yy');
         locale_map.put('es_HN', 'mm-dd-yy');
         locale_map.put('es_MX', 'dd/mm/yy');
         locale_map.put('es_NI', 'mm-dd-yy');
         locale_map.put('es_PA', 'mm/dd/yy');
         locale_map.put('es_PE', 'dd/mm/yy');
         locale_map.put('es_PR', 'mm-dd-yy');
         locale_map.put('es_PY', 'dd/mm/yy');
         locale_map.put('es_SV', 'mm-dd-yy');
         locale_map.put('es_US', 'mm/dd/yy');
         locale_map.put('es_UY', 'dd/mm/yy');
         locale_map.put('es_VE', 'dd/mm/yy');
         locale_map.put('et_EE', 'dd.mm.yy');
         locale_map.put('eu_ES', 'yy/mm/d');
         locale_map.put('fa_IR', 'yy/mm/d');
         locale_map.put('fi', 'dd.mm.yy');
         locale_map.put('fi_FI', 'dd.mm.yy');
         locale_map.put('fi_FI_EURO', 'dd.M.yy');
         locale_map.put('fr', 'dd/mm/yy');
         locale_map.put('fr_BE', 'dd/mm/yy');
         locale_map.put('fr_CA', 'yy-mm-dd');
         locale_map.put('fr_KM', 'dd/mm/yy');
         locale_map.put('fr_FR', 'dd/mm/yy');
         locale_map.put('fr_FR_EURO', 'dd/mm/yy');
         locale_map.put('fr_GN', 'dd/mm/yy');
         locale_map.put('fr_HT', 'dd/mm/yy');
         locale_map.put('fr_LU', 'dd/mm/yy');
         locale_map.put('fr_MR', 'dd/mm/yy');
         locale_map.put('fr_MC', 'dd/mm/yy');
         locale_map.put('fr_CH', 'dd.mm.yy');
         locale_map.put('fr_WF', 'dd/mm/yy');
         locale_map.put('ga_IE', 'dd/mm/yy');
         locale_map.put('gu_IN', 'dd/mm/yy');
         locale_map.put('hi_IN', 'd/mm/yy');
         locale_map.put('hr_HR', 'dd.mm.yy');
         locale_map.put('hu_HU', 'yy.mm.dd');
         locale_map.put('hy_AM', 'dd.mm.yy');
         locale_map.put('hy', 'dd.mm.yy');
         locale_map.put('in_ID', 'dd/mm/yy');
         locale_map.put('is_IS', 'dd.mm.yy');
         locale_map.put('it_CH', 'dd.mm.yy');
         locale_map.put('it_IT', 'dd/mm/yy');
         locale_map.put('iw_IL', 'HH:mm dd/mm/yy');
         locale_map.put('ja_JP', 'yy/mm/dd');
         locale_map.put('ka_GE', 'dd.mm.yy');
         locale_map.put('kk_KZ', 'dd.mm.yy');
         locale_map.put('km_KH', 'dd/mm/yy');
         locale_map.put('kn_IN', 'dd/mm/yy');
         locale_map.put('ko_KP', 'yy.mm.dd');
         locale_map.put('ko_KR', 'yy.mm.dd');
         locale_map.put('ky_KG', 'dd/mm/yy');
         locale_map.put('lb_LU', 'dd.mm.yy');
         locale_map.put('lo_LA', 'dd/mm/yy');
         locale_map.put('lt_LT', 'yy.mm.dd');
         locale_map.put('lu_CD', 'dd/mm/yy');
         locale_map.put('lv_LV', 'dd.mm.yy');
         locale_map.put('mk_MK', 'dd.mm.yy');
         locale_map.put('ml_IN', 'dd/mm/yy');
         locale_map.put('mr_IN', 'dd/mm/yy');
         locale_map.put('ms_BN', 'dd/mm/yy');
         locale_map.put('bn', 'dd/mm/yy');
         locale_map.put('ms_MY', 'dd/mm/yy');
         locale_map.put('mt_MT', 'dd/mm/yy');
         locale_map.put('my_mm', 'dd-mm-yy');
         locale_map.put('ne_NP', 'yy/mm/dd');
         locale_map.put('nl', 'dd-mm-yy');
         locale_map.put('nl_AW', 'dd-mm-yy');
         locale_map.put('nl_BE', 'dd/mm/yy');
         locale_map.put('nl_NL', 'dd-mm-yy');
         locale_map.put('nl_SR', 'dd-mm-yy');
         locale_map.put('no_NO', 'dd.mm.yy');
         locale_map.put('pl_PL', 'dd.mm.yy');
         locale_map.put('ps_AF', 'yy/M/dd');
         locale_map.put('pt', 'dd/mm/yy');
         locale_map.put('pt_AO', 'dd/mm/yy');
         locale_map.put('pt_BR', 'dd/mm/yy');
         locale_map.put('pt_CV', 'dd/mm/yy');
         locale_map.put('pt_MZ', 'dd/mm/yy');
         locale_map.put('pt_PT', 'dd-mm-yy');
         locale_map.put('pt_ST', 'dd/mm/yy');
         locale_map.put('rm_CH', 'dd-mm-yy');
         locale_map.put('rn_BI', 'dd/mm/yy');
         locale_map.put('ro_MD', 'dd.mm.yy');
         locale_map.put('ro_RO', 'dd.mm.yy');
         locale_map.put('ru_KZ', 'dd.mm.yy');
         locale_map.put('ru_RU', 'dd.mm.yy');
         locale_map.put('sh_BA', 'dd.mm.yy');
         locale_map.put('sh', 'dd.mm.yy');
         locale_map.put('sh_CS', 'dd.mm.yy');
         locale_map.put('sh_ME', 'dd.mm.yy');
         locale_map.put('sk_SK', 'dd.mm.yy');
         locale_map.put('sl_SI', 'dd.mm.yy');
         locale_map.put('so_DJ', 'dd/mm/yy');
         locale_map.put('so_SO', 'dd/mm/yy');
         locale_map.put('sr_BA', 'yy-mm-dd');
         locale_map.put('sr_CS', 'dd.mm.yy');
         locale_map.put('sr_RS', 'dd.mm.yy');
         locale_map.put('sq_AL', 'yy-mm-dd');
         locale_map.put('sv_SE', 'yy-mm-dd');
         locale_map.put('sw_KE', 'dd/mm/yy');
         locale_map.put('ta', 'dd/mm/yy');
         locale_map.put('ta_IN', 'dd/mm/yy');
         locale_map.put('ta_LK', 'dd/mm/yy');
         locale_map.put('te_IN', 'dd-mm-yy');
         locale_map.put('tg_TJ', 'dd/mm/yy');
         locale_map.put('th_TH', 'dd/mm/yy');
         locale_map.put('ti_ET', 'dd/mm/yy');
         locale_map.put('am_ET', 'dd/mm/yy');
         locale_map.put('tl_PH', 'mm/dd/yy');
         locale_map.put('tr_TR', 'dd.mm.yy');
         locale_map.put('uk_UA', 'dd.mm.yy');
         locale_map.put('ur_PK', 'dd/mm/yy');
         locale_map.put('uz_LATN_UZ', 'dd/mm/yy');
         locale_map.put('vi_VN', 'HH:mm dd/mm/yy');
         locale_map.put('yo_BJ', 'dd/mm/yy');
         locale_map.put('xh_ZA', 'mm/dd/yy');
         locale_map.put('zh', 'yy-mm-dd');
         locale_map.put('zh_CN', 'yy-mm-dd');
         locale_map.put('zh_CN_PINYIN', 'yy-mm-dd');
         locale_map.put('zh_CN_STROKE', 'yy-mm-dd');
         locale_map.put('zh_HK', 'yy年m月d日');
         locale_map.put('zh_HK_STROKE', 'yy年m月d日');
         locale_map.put('zh_MO', 'dd/mm/yy');
         locale_map.put('zh_SG', 'dd/mm/yy');
         locale_map.put('zh_TW', 'yy/mm/dd');
         locale_map.put('zh_TW_STROKE', 'yy/mm/dd');
         locale_map.put('zu_ZA', 'mm/dd/yy');
         locale_map.put('in', 'yy/mm/dd');
         locale_map.put('sq', 'yy-mm-dd');
         locale_map.put('am', 'dd/mm/yy');
         return locale_map; //return the map
      }
      catch(Exception ex) {
         System.debug('Error occurred in FillWorkbookList() => ' + String.valueOf(ex) + ' at Line Number ' + ex.getLineNumber());
         throw ex;
      }
   }
}