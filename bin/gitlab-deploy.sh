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

if [ -n "$SVN_USERNAME" ] && [ -n "$SVN_PASSWORD" ] && [ -n "$SVN_REPO_URL" ]; then

# main config
export DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )"/.. && pwd )"
export PLUGINSLUG="$(basename $DIR)"  #must match with wordpress.org plugin slug
export MAINFILE="barebone.php" # this should be the name of your main php file in the wordpress plugin

GITPATH="$DIR/" # this file should be in the base of your git repository

SVNPATH="/tmp/$PLUGINSLUG"
SVNTRUNK="$SVNPATH/trunk"
SVNTAGS="$SVNPATH/tags"
SVNASSETS="$SVNPATH/assets"
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

echo "Git status"
git remote -v
git config --list

echo "Creating local copy of SVN repo ..."
yes yes | svn co $SVNURL $SVNPATH --quiet --username=$SVN_USERNAME --password=$SVN_PASSWORD

if [ ! -d "$SVNPATH" ]; then echo "Could not checkout from SVN"; exit 1; fi

cd $SVNPATH
if [ ! -d "$SVNTRUNK" ]; then 
echo "Creating trunk..."
mkdir $SVNTRUNK
svn add $SVNTRUNK
svn commit -m "Adding Trunk directory" --username=$SVN_USERNAME --password=$SVN_PASSWORD
fi

if [ ! -d "$SVNTAGS" ]; then
echo "Creating tags..."
mkdir $SVNTAGS
svn add $SVNTAGS
svn commit -m "Adding Tags directory" --username=$SVN_USERNAME --password=$SVN_PASSWORD
fi

if [ ! -d "$SVNASSETS" ]; then
echo "Creating assets directory..."
mkdir $SVNASSETS
svn add $SVNASSETS
svn commit -m "Adding assets directory" --username=$SVN_USERNAME --password=$SVN_PASSWORD
fi

cd $GITPATH
echo "Exporting the HEAD of master from git to the trunk of SVN"
git checkout-index -a -f --prefix=$SVNTRUNK/

# If assets directory is there in git repo, try to create assets in SVN
if [ -d "$GITPATH/assets" ]; then
echo "Exporting Assets"
rm -rf $SVNASSETS/*
cp $GITPATH/assets/* $SVNASSETS/
# Check if there are any files to commit before running svn add
cd $SVNASSETS
if [[ $(svn status) ]]; then
# Add all new files that are not set to be ignored
echo "Committing assets"
svn status | grep -v "^.[ \t]*\..*" | grep "^?" | awk '{print $2}' | xargs svn add
yes yes | svn commit -m "Adding/updating assets" --username=$SVN_USERNAME --password=$SVN_PASSWORD
else
echo "No new assets to commit"
fi
fi

echo "Ignoring git specific files and deployment script"
svn propset svn:ignore "deploy.sh
deploy-common.sh
readme.sh
README.md
bin
assets
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
.phpcs.xml.dist
.phpcs.xml
package-lock.json
node_modules
.sass-cache
.gitlab-ci.yml
.travis.yml" "$SVNPATH/trunk/"

echo "Changing directory to SVN Trunk"
cd $SVNTRUNK

# Check if there are any files to commit before running svn add
if [[ $(svn status) ]]; then
echo "Committing to trunk"
# Add all new files that are not set to be ignored
svn status | grep -v "^.[ \t]*\..*" | grep "^?" | awk '{print $2}' | xargs svn add
yes yes | svn commit -m "Tagging version $NEWVERSION1" --username=$SVN_USERNAME --password=$SVN_PASSWORD
else
echo "Nothing new to commit in trunk"
fi

# Check if tag already exists in SVN, if not, then create new
if [ ! -d "$SVNTAGS/$NEWVERSION1" ]; then
echo "Creating new SVN tag & committing it"
cd $SVNPATH
svn copy trunk/ tags/$NEWVERSION1/
cd $SVNPATH/tags/$NEWVERSION1
yes yes | svn commit -m "Tagging version $NEWVERSION1" --username=$SVN_USERNAME --password=$SVN_PASSWORD
else
echo "$NEWVERSION1 Tag already exists, skipping new tag creation"
fi

echo "Deployment Done :) "

else
echo "No SVN Credentials sent"
fi