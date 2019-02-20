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

# main config
export DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )"/.. && pwd )"
export PLUGINSLUG="$(basename $DIR)"  #must match with wordpress.org plugin slug
export MAINFILE="barebone.php" # this should be the name of your main php file in the wordpress plugin

GITPATH="$DIR/" # this file should be in the base of your git repository

SVNPATH="/tmp/$PLUGINSLUG"
SVNTRUNK="$SVNPATH/trunk"
SVNURL="$SVN_REPO_URL"

# Let's begin...
echo ".........................................."
echo
echo "Preparing to deploy wordpress plugin"
echo
echo ".........................................."
echo

# Check version in readme.txt is the same as plugin file
NEWVERSION1=`grep "^Stable tag" $GITPATH/readme.txt | awk -F' ' '{print $3}'`
echo "readme version: $NEWVERSION1"
NEWVERSION2=`grep -i "Version" $GITPATH/$MAINFILE | head -n1 | awk -F':' '{print $2}' | awk -F' ' '{print $1}'`
echo "$MAINFILE version: $NEWVERSION2"

# Exit if versions don't match
if [ "$NEWVERSION1" != "$NEWVERSION2" ]; then echo "Versions don't match. Exiting...."; exit 1; fi

echo "Versions match in readme.txt and PHP file. Let's proceed..."

cd $GITPATH

echo "Creating local copy of SVN repo ..."
yes yes | svn co $SVNURL $SVNPATH

if [ ! -d "$SVNPATH" ]; then echo "Could not checkout from SVN"; exit 1; fi

if [ ! -d "$SVNTRUNK" ]; then mkdir $SVNTRUNK; echo "Creating trunk..."; fi
if [ ! -d "$SVNPATH/tags" ]; then mkdir "$SVNPATH/tags"; echo "Creating tags..."; fi

echo "Exporting the HEAD of master from git to the trunk of SVN"
git checkout-index -a -f --prefix=$SVNTRUNK/

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
cd $SVNTRUNK

# Add all new files that are not set to be ignored
svn status | grep -v "^.[ \t]*\..*" | grep "^?" | awk '{print $2}' | xargs svn add
svn commit -m "Tagging version $NEWVERSION1"

echo "Creating new SVN tag & committing it"
cd $SVNPATH
svn copy trunk/ tags/$NEWVERSION1/
cd $SVNPATH/tags/$NEWVERSION1
svn commit -m "Tagging version $NEWVERSION1"

else
echo "No SVN Credentials sent"
fi