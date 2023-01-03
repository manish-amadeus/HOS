global class MigrationPortalURLRewriter implements Site.UrlRewriter {
    String URLTOREWRITE = '/page/';
    String REWRITETO = '/MigrationPortalPage?pageid=';
    global PageReference mapRequestUrl(PageReference pr) {
        String url = pr.getUrl();
        String remainder = url.substring(URLTOREWRITE.length(),
                    url.length())
                    .replace('?','&');
                    
        PageReference outpr=null;
        if(url.startsWith(URLTOREWRITE)){
            outpr = new PageReference(REWRITETO+remainder);
        }
        return outpr;
    }
    global List<PageReference> generateUrlFor(List<PageReference> prs){
        /*
        List<PageReference> outprs = new List<PageReference>();
        for(PageReference pr: prs){
            String url = pr.getUrl();
            if(url.startsWith(REWRITETO)) {
                String remainder = url.substring(REWRITETO.length(), url.length());
                outprs.add(
                    new PageReference(URLTOREWRITE+remainder)
                );
            }
        }
        return outprs;
        */
        return null;
    }
}