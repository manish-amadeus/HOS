#!groovy
// Based on: https://github.com/forcedotcom/sfdx-jenkins-org
// Please refer to the following links that may contain usefull information:
// - https://developer.salesforce.com/docs/atlas.en-us.sfdx_dev.meta/sfdx_dev/sfdx_dev_ci_jenkins.htm 
// - https://plugins.jenkins.io/bitbucket-push-and-pull-request/
node {
    String SDWORK_ID
    String JOBIDDEPLOY
    def SCMVARS
    def SF_USERNAME
    def SF_TARGET_ENV
    def SF_INSTANCE_URL
    def SF_CONSUMER_KEY
    def SF_CONSUMER_SERVER_KEY
	def RUNTYPETEST
    def START_TIME = new Date().format("yyyy-MM-dd'T'HH:mm:ss.SSSZ")
    def INSTANCEURL = "https://login.salesforce.com"
    env.LANG    = "en_US.UTF-8"
    try {
         // ----------------------------------------------------------------------------------
        // Run all the enclosed stages with access to the Salesforce
        // JWT key credentials.
        // ----------------------------------------------------------------------------------
        withEnv(["HOME=${env.WORKSPACE}"]) {
			// Based on the source and target branches, set SF_* variables for authentication withing sfdx
            if ( ("${env.BITBUCKET_SOURCE_BRANCH}".contains("release/") || "${env.BITBUCKET_SOURCE_BRANCH}".contains("bugfix/") ) && ("${env.BITBUCKET_TARGET_BRANCH}".contains("master"))) {
                SF_USERNAME = "ENV_HOS_SF_PROD_USERNAME"
                SF_CONSUMER_KEY = "ENV_HOS_SF_PROD_CONSUMERKEY"
                SF_CONSUMER_SERVER_KEY = "ENV_HOS_SF_SECRETKEY"
            } else {
              error 'Please check the branches on your PR. (source branch should be: release/*or bugfix/*) (target branch should be: master)'
            }
			String CURRENT_BRANCH   = "${env.BITBUCKET_SOURCE_BRANCH}"
            SDWORK_ID = CURRENT_BRANCH.substring(CURRENT_BRANCH.indexOf('/') + 1, CURRENT_BRANCH.length())
            // ----------------------------------------------------------------------------------
            // Get server key file to connect with the connected app.
            // ----------------------------------------------------------------------------------
			withCredentials([
                file(credentialsId: "${SF_CONSUMER_SERVER_KEY}", variable: 'CONSUMER_SERVER_KEY'),
                string(credentialsId: "${SF_USERNAME}", variable: 'USERNAME'),
                string(credentialsId: "${SF_CONSUMER_KEY}", variable: 'CONSUMER_KEY')
            ]){
				// ----------------------------------------------------------------------------------
                // Set the target org, instance URL to be used. Clone the repo and authorize 
                // connection to SF org.
                // ----------------------------------------------------------------------------------
                stage('Prepare (current build, target org, instance url)') {
					// Define target org/env and instance URL
                    if ( ("${env.BITBUCKET_SOURCE_BRANCH}".contains("release/")) && "${env.BITBUCKET_TARGET_BRANCH}".contains("master")) {
                        SF_TARGET_ENV = "PROD"
                        currentBuild.description = "Deployment to PROD - ${SDWORK_ID}"
                    } 
					// Print some usefull info
                    echo "Salesforce target env: ${SF_TARGET_ENV}"
                    echo "Bitbucket source branch: ${env.BITBUCKET_SOURCE_BRANCH}"
                    echo "Bitbucket target branch: ${env.BITBUCKET_TARGET_BRANCH}"
                    String SFDX_CLI_VERSION = commandOutput "sfdx --version"
                    echo "SFDX CLI version: ${SFDX_CLI_VERSION}"
                    // Clone repo and checkout to desired 
					SCMVARS = checkout([
                        $class: 'GitSCM', 
                        branches: [[name: "${env.BITBUCKET_SOURCE_BRANCH}"]], 
                        extensions: [[$class: 'WipeWorkspace']],
                        userRemoteConfigs: [[
                            credentialsId: 'ENV_MANISH_GIT_CRED',
                            url: 'https://mkumar7@rndwww.nce.amadeus.net/git/scm/ahsf/salesforce.git'
                        ]]
                    ])
					// Configure git variables using the ones from Jenkins global config
                    commandOutput "git config user.email \"$SCMVARS.GIT_AUTHOR_EMAIL\""
                    commandOutput "git config user.name \"$SCMVARS.GIT_AUTHOR_NAME\""
                    // Authorize connections through sfdx to Salesforce org
					rc = commandStatus "sfdx auth:jwt:grant --instanceurl ${INSTANCEURL} --clientid ${CONSUMER_KEY} --jwtkeyfile ${CONSUMER_SERVER_KEY} --username ${USERNAME} --setalias ${SF_TARGET_ENV}"
                    if (rc != 0) {
                        error 'Salesforce org authorization failed.'
                    }
				}
				// Checkout to target branch and merge source into target. This helps making sure that we're validating/deploying the components without 
                // overriding anything 
                // E.g.: Deployed PR 790 and then 792. Both changes the same file but no conflicts were reported. During deployment, 792 overwrited the 
                // changes of 790 since the branch was created before 790 was merged into develop
                stage('Merge branches') {
					// Merge the PR on BitBucket
                    // Checkout to source branch (so we can have a local copy)
                    rc = commandStatus "git checkout ${BITBUCKET_SOURCE_BRANCH}"
					if (rc != 0) {
                        error 'Failed to checkout to source branch.'
                    }
					// Checkout to target branch
                    rc = commandStatus "git checkout ${BITBUCKET_TARGET_BRANCH}"
                    if (rc != 0) {
                        error 'Failed to checkout to target branch.'
                    }
					// Merge source branch into target branch.
                    rc = commandStatus "git merge ${BITBUCKET_SOURCE_BRANCH}"
                    if (rc != 0) {
                        error 'Failed to merge source branch into target branch.'
                    }
				}
				// ----------------------------------------------------------------------------------
                // Run the LocalTests on the Salesforce org for a given SDWORK_ID
                // ----------------------------------------------------------------------------------
		        stage('Validate (RunLocalTests, jest)') {
                    def RunTesttype
                    def SpecifiedTestClass 
                    env.WORKSPACE = pwd()
                    def list = readFile("${env.WORKSPACE}/manifest/${SDWORK_ID}/package.xml").readLines().collect()
                    for (item in list){
                    if (item.contains('Test')||item.contains('test')||item.contains('TesT')||item.contains('TEST')){
                     def ExtractedVal = (item =~ />(.*)</)
                     ExtractedVal =ExtractedVal[0][1]
                     if (SpecifiedTestClass == null){
                        SpecifiedTestClass= ExtractedVal
                      }
                     else {
                     SpecifiedTestClass= SpecifiedTestClass+","+ExtractedVal
                      }
                     }
                     
                    }
					echo "Specified test classes are : ${SpecifiedTestClass}"
					if(SpecifiedTestClass == null){
					RunTesttype = "NoTestRun"
                    RUNTYPETEST = RunTesttype
                    }
                    else{
                    RunTesttype = "RunSpecifiedTests -r ${SpecifiedTestClass}"
                    }
                    
		            String JOB = commandOutput "sfdx force:source:deploy -u ${SF_TARGET_ENV} -l ${RunTesttype} -w 40 -c -x manifest/${SDWORK_ID}/package.xml"
		            echo "JOB: ${JOB}"
                    //String JOB = commandOutput "sfdx force:source:deploy -u ${SF_TARGET_ENV} -l RunLocalTests -w 40 -c -x manifest/package.xml"
                    //String JOB = commandOutput "sfdx force:source:deploy -u ${SF_TARGET_ENV} -l RunSpecifiedTests -r DevOpsClass_Test -w 40 -c -x manifest/package.xml"
                    String JOB = commandOutput "sfdx force:source:deploy -u ${SF_TARGET_ENV} -l ${RunTesttype} -w 40 -c -x manifest/${SDWORK_ID}/package.xml"
                      echo "JOB: ${JOB}"
                    def idPosition = JOB.indexOf("Job ID") + 9
                    JOBIDDEPLOY =  JOB.substring(idPosition,idPosition+15).trim()
                    echo "JOBIDDEPLOY: ${idPosition}  :  ${JOBIDDEPLOY}"
                    if ("${JOB}".contains("Success")) {
						JOBIDDEPLOY =  JOB.substring(idPosition,idPosition+15).trim()
                        echo "JOBIDDEPLOY: ${idPosition}  :  ${JOBIDDEPLOY}"
					} else if ("${JOB}".contains("Failed")) {
                        error 'Salesforce RunLocalTests failed.'
                    }
					
				}
				// ----------------------------------------------------------------------------------
                // Deploy the package previously validated on stage "Run Test (RunLocalTests, jest)"
                // ----------------------------------------------------------------------------------
                stage('Promote to PROD (deploy package + validation)') {
				 if (RunTesttype == "NoTestRun"){
					rc = commandStatus "sfdx force:source:deploy -u ${SF_TARGET_ENV} -w 10 -x manifest/${SDWORK_ID}/package.xml"
					if (rc != 0) {
                        error 'Salesforce deployment failed.'
                    }
				}
				 else{
                  rc = commandStatus "sfdx force:source:deploy -u ${SF_TARGET_ENV} -w 10 -q ${JOBIDDEPLOY}"
					if (rc != 0) {
                        error 'Salesforce deployment failed.'
                    }
				// ----------------------------------------------------------------------------------
                // Merging Source branch into the Target branch
                // ----------------------------------------------------------------------------------
                stage('Logout & Close PR') {
					// Logout from SFDX
                    rc = commandStatus "sfdx auth:logout -p --targetusername ${SF_TARGET_ENV}"
                    if (rc != 0) {
                        error 'Salesforce logout failed.'
                    }
					// Push changes (merging) back to BitBucket to complete the PR
                    withCredentials([usernamePassword(credentialsId: 'ENV_MANISH_GIT_CRED', passwordVariable: 'GIT_PASSWORD', usernameVariable: 'GIT_USERNAME')]) {
						//rc = commandStatus "git push https://${GIT_USERNAME}:${GIT_PASSWORD}@rndwww.nce.amadeus.net/git/scm/ahsf/salesforce.git"
                        rc = commandStatus "git push https://mkumar7@rndwww.nce.amadeus.net/git/scm/ahsf/salesforce.git"
                        if (rc != 0) {
							error 'Failed to push merge to BitBucket.'
						}
					
					}
				}
			}
			
		}
		env.BUILD_NUMBER.result="SUCCESS"
      }
	} catch (e) {
	 env.BUILD_NUMBER.result="FAILURE"
        throw e
    } finally {
        // Send email. Uses the configs from Manage Jenkins > Configure System > Extended E-mail Notification
        //emailext recipientProviders: [developers()], subject: "Job '${JOB_NAME}' (${BUILD_NUMBER}) finished with result: ${currentBuild.result}" , body: "The build #${BUILD_NUMBER} finished with status ${currentBuild.currentResult} and contains the logs attached.", attachLog: true
	emailext recipientProviders: [developers()], subject: "Job '${JOB_NAME}' (${BUILD_NUMBER}) finished with result: ${currentBuild.result}" , to:'manish.kumar7@amadeus.com,geetha.amalraj@amadeus.com,sean.harris@amadeus.com',body: "The build #${BUILD_NUMBER} finished with status ${currentBuild.result} and contains the logs attached.", attachLog: true
        // TODO MS Teams
        //office365ConnectorSend message: "<Your message>", status:"${RESULT}", webhookUrl:'<The connector webhook url>'
        // Clean workspace (remove files used for this build)
        cleanWs()
    }

}

// ----------------------------------------------------------------------------------
// Run a command and return the status code
// ----------------------------------------------------------------------------------
def commandStatus(script) {
    if (isUnix()) {
        return sh(returnStatus: true, script: script);
    } else {
        return bat(returnStatus: true, script: script);
    }
}
// ----------------------------------------------------------------------------------
// Run a command and return the output generated
// ----------------------------------------------------------------------------------
def commandOutput(script) {
    if (isUnix()) {
        return sh(returnStdout: true, script: script);
    } else {
        return bat(returnStdout: true, script: script);
    }
}
// ----------------------------------------------------------------------------------
// Run a command and return if folder exist
// ----------------------------------------------------------------------------------
def doesFolderExist(folder) {
    if (isUnix()) {
        return sh(returnStatus: true, script: "test -d ${folder}")
    } else {
        return bat(returnStatus: true, script: "dir ${folder}")
    }
}
// ----------------------------------------------------------------------------------
// Run a command and return if file exist
// ----------------------------------------------------------------------------------
def doesFileExist(filePath) {
    if (isUnix()) {
        return sh(returnStatus: true, script: "test -f ${filePath}")
    } else {
        return bat(returnStatus: true, script: "dir ${filePath}")
    }
}
// ----------------------------------------------------------------------------------
// Run a command and return an object with the result
// ----------------------------------------------------------------------------------
def shCommandOutput(script) {
    def json
    if (isUnix()) {
        json = sh(returnStdout: true, script: script);
    } else {
        json = bat(returnStdout: true, script: script);
    }
    def startPos = json.indexOf("{")
    String finalJson =  json.substring(startPos,json.size()).trim()
    def object = readJSON text: finalJson
    return object
}

