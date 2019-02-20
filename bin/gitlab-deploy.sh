#!/bin/bash
echo "Running Deployment"

echo "Current Working directory:"
pwd

if [ -n "$PRIV_KEY" ]; then
mkdir -p ~/.ssh
echo "${PRIV_KEY}" | tr "," "\n" > ~/.ssh/id_rsa
chmod 600 ~/.ssh/id_rsa
echo "Added Private key"
else
echo "Private Key not defined"
fi

alias svn='svn --username=$SVN_USERNAME --password=$SVN_PASSWORD'

if [ -n "$SVN_USERNAME" ] && [ -n "$SVN_PASSWORD" ] && [ -n "$SVN_REPO_URL" ]; then

# Check version in readme.txt is the same as plugin file
NEWVERSION1=`grep "^Stable tag" readme.txt | awk -F' ' '{print $3}'`
echo "readme version: $NEWVERSION1"
NEWVERSION2=`grep -i "Version" barebone.php | head -n1 | awk -F':' '{print $2}' | awk -F' ' '{print $1}'`
echo "$MAINFILE version: $NEWVERSION2"

# Exit if versions don't match
if [ "$NEWVERSION1" != "$NEWVERSION2" ]; then echo "Versions don't match. Exiting...."; exit 1; fi

echo "Versions match in readme.txt and PHP file. Let's proceed..."

SVNPATH="/tmp/plugin-svn/"
echo "Creating local copy of SVN repo ..."
yes yes | svn co $SVN_REPO_URL $SVNPATH

echo "Exporting the HEAD of master from git to the trunk of SVN"
git checkout-index -a -f --prefix=$SVNPATH/trunk/

echo "Ignoring github specific files and deployment script"
svn propset svn:ignore "deploy.sh
deploy-common.sh
readme.sh
README.md
bin
.git
.gitattributes
.gitignore
.editorconfig
map.conf
nginx.log
tests
Gruntfile.js
package.json
phpunit.xml
phpunit.xml.dist
package-lock.json
node_modules
.sass-cache
.gitlab-ci.yml
.travis.yml" "$SVNPATH/trunk/"

echo "Changing directory to SVN and committing to trunk"
cd $SVNPATH/trunk/

# Add all new files that are not set to be ignored
svn status | grep -v "^.[ \t]*\..*" | grep "^?" | awk '{print $2}' | xargs svn add
svn commit --username=$SVNUSER -m "$COMMITMSG"

echo "Creating new SVN tag & committing it"
cd $SVNPATH
svn copy trunk/ tags/$NEWVERSION1/
cd $SVNPATH/tags/$NEWVERSION1
svn commit --username=$SVNUSER -m "Tagging version $NEWVERSION1"

else
echo "No SVN Credentials sent"
fi