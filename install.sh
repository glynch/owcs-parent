#!/bin/bash

cd "$(dirname "$0")" || exit

DIR=$(pwd)

JSK_HOME=$1
if [ -z "$JSK_HOME" ]; then
	echo "Usage: $0 <JSK_HOME>"
	exit 1
fi

if [ ! -d "$JSK_HOME" ]; then
	echo "Directory $JSK_HOME does not exist"
	exit 1
fi

LIB_DIR="${JSK_HOME}/apache-tomcat-7.0.65-sites/webapps/sites/WEB-INF/lib"
if [ ! -d "$LIB_DIR" ]; then
	echo "$LIB_DIR does not exist"
	exit 1
fi

MAVEN=${DIR}/mvnw
if [[ ! (-f "$MAVEN" && -x "$MAVEN") ]]; then
	echo "Maven wrapper not found"
	exit 1
fi

SITES_VERSION="12.2.1.3.0"

declare -a SITES_JARS=(
	"sites-app"
	"sites-asset-api"
	"sites-batch"
	"sites-cache"
	"sites-cas-plugin" 
	"sites-core"
	"sites-cors-filter"
	"sites-cs" 
	"sites-directory"
	"sites-framework"
	"sites-install-bootstrap"
	"sites-integrations" 
	"sites-lucene-search" 
	"sites-monitoring" 
	"sites-msxml" 
	"sites-nio"
	"sites-request-authenticator" 
	"sites-rest-api"
	"sites-rest-local-impl"
	"sites-satellite" 
	"sites-security" 
	"sites-seed"
	"sites-services-api" 
	"sites-services-impl" 
	"sites-sso-api" 
	"sites-sso-cas-impl" 
	"sites-sso-oam-impl" 
	"sites-systemtools" 
	"sites-timezone" 	
	"sites-transformer" 
	"sites-ucm-poller" 
	"sites-ui" 
	"sites-utilities"
	"sites-wurfl"
	)

# Declare an array of JARs to be installed groupId:artifactId:version
declare -a JARS=(
	"com.fatwire:developer-tools-command-line:12.2.1.3.0-SNAPSHOT"
    "com.oracle.database.observability:dms:1.1.0-150521.1418" 
    "com.oracle.sites.sitecapture.webapp:sites-sitecapture-publish-listener:12.2.1.3.0-SNAPSHOT"
    "com.oracle.sites.visitors:visitors-client:12.2.1.3.0-SNAPSHOT"
    "com.oracle.sites:developer-tools-command-line:12.2.1.3.0-SNAPSHOT"
    "com.oracle.sites:sites-contentcloud-integration:12.2.1.3.0-SNAPSHOT"
    "com.oracle.sites:sites-eloqua-integration:12.2.1.3.0-SNAPSHOT"
    "com.oracle.sites:sites-enrichment:12.2.1.3.0-SNAPSHOT"
    "com.oracle.sites:sites-integrations:12.2.1.3.0-SNAPSHOT"
    "com.oracle.sites:sites-monitoring-core:12.2.1.3.0-SNAPSHOT"
    "com.sun.jersey.contribs.jersey-oauth:oauth-signature:1.1.4.1_eloqua" 
    "com.sun.xml.bind:jaxb-xjc:2.2.12-b150206.1749" 
    "javax.annotation:javax-annotation-javax-annotation-api:12.2.1-1680713" 
    "javax.annotation:jsr250-api:1.1" 
    "net.fckeditor:java-core:2.4" "oracle.security.importcert:importcert:11.1.2.3.0" 
    "oracle.annotation.logging:logging-utils:2.0.0-150521.1418" 
    "oracle.i18n.js:orai18n-js:10.1.2.0.0" 
    "oracle.javatools:build-annotations:12.2130.20160817-1301" 
    "oracle.jmx.framework:jmxframework:12.2.1.0.0-20150521.1522" 
    "oracle.jrf:jrf-api:1.1.0-150521.1418" 
    "oracle.ojdl:ojdl:1.1.0-150521.1418" 
    "oracle.security.identitystore:identitystore:2.0.0-150524.0845" 
    "oracle.security.pki:oraclepki:2.0.0-150524.0845" 
    "oracle.security:jps-api:2.0.0-150524.0845" 
    "oracle.security:jps-common:2.0.0-150524.0845" 
    "oracle.security:jps-internal:2.0.0-150524.0845" 
    "oracle.security:jps-unsupported-api:2.0.0-150524.0845" 
    "org.codehaus.jackson:org-codehaus-jackson-jackson-core-asl:12.2.1-1680713" 
    "org.codehaus.jackson:org-codehaus-jackson-jackson-mapper-asl:12.2.1-1680713" 
    "org.docx4j:docx4j:2.1.0"
    "org.glassfish.hk2:org-glassfish-hk2-hk2-api:12.2.1-1680713" 
    "org.glassfish.hk2:org-glassfish-hk2-hk2-locator:12.2.1-1680713" 
    "org.glassfish.hk2:org-glassfish-hk2-hk2-utils:12.2.1-1680713" 
    "org.glassfish.jersey.bundles.repackaged:org-glassfish-jersey-bundles-repackaged-jersey-guava:12.2.1-1680713"
    "org.glassfish.jersey.bundles.repackaged:org-glassfish-jersey-media-jersey-media-multipart:12.2.1-1680713" 
    "tangosol-coherence:coherence:12.2.1-0-0-58138" 
	"com.oracle.sites.visitors:visitors-api:12.2.1.3.0-SNAPSHOT"
	)

for JAR in "${SITES_JARS[@]}"; do
	echo "Installing ${JAR}.jar as com.oracle.sites:${JAR}:${SITES_VERSION}"
    ${MAVEN} --quiet install:install-file -Dfile="${LIB_DIR}/${JAR}.jar" -DgroupId=com.oracle.sites -DartifactId=${JAR} -Dversion=${SITES_VERSION} -Dpackaging=jar
done


for JAR in "${JARS[@]}"; do
	IFS=':' read -r -a array <<< "$JAR"
	GROUP=${array[0]}
	ARTIFACT=${array[1]}
	VERSION=${array[2]}
	if [[ -f "${LIB_DIR}/${ARTIFACT}-${VERSION}.jar" ]]; then
		FILE="${LIB_DIR}/${ARTIFACT}-${VERSION}.jar"
	else
		FILE="${LIB_DIR}/${ARTIFACT}.jar"
	fi
	echo "Installing ${FILE} as ${GROUP}:${ARTIFACT}:${VERSION}"
	${MAVEN} --quiet install:install-file -Dfile="${FILE}" -DgroupId="${GROUP}" -DartifactId="${ARTIFACT}" -Dversion="${VERSION}" -Dpackaging=jar
done

$MAVEN clean install

