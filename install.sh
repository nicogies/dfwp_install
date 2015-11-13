#!/bin/bash
#
# Automatize WordPress installation
# bash install.sh
#
# Author: Nicolas Gies <nicolas.gies@digitaslbi.fr>
#
# Inspirated from Maxime BJ & Clément Biron
# https://bitbucket.org/maximebj/wippy-spread
# https://github.com/posykrat/dfwp_install

#  ==============================
#  ECHO COLORS, FUNCTIONS AND VARS
#  ==============================
bggreen='\033[42m'
bgred='\033[41m'
bold='\033[1m'
black='\033[30m'
gray='\033[37m'
normal='\033[0m'

# Jump a line
function line {
	echo " "
}

# Basic echo
function bot {
	line
	echo -e "$1 ${normal}"
}

# Error echo
function error {
	line
	echo -e "${bgred}${bold}${gray} $1 ${normal}"
}

# Success echo
function success {
	line
	echo -e "${bggreen}${bold}${gray} $1 ${normal}"
}

#  ==============================
#  VARS
#  ==============================


# On récupère le titre du site
# Si pas de valeur renseignée, message d'erreur et exit
title="Projet 1"
read -e -i "$title" -p "Titre du projet ? " input
title="${input:-$title}"
if [ -z "$title" ]
	then
		error 'Renseigner un titre pour le site'
		exit
fi

# On récupère le nom du dossier (généré d'après le titre du projet)
# Si pas de valeur renseignée, message d'erreur et exit
# first, strip underscores, replace spaces with underscores, clean out anything that's not alphanumeric or an underscore and finally , lowercase with TR
SANITIZED_TITLE=${title//_/}
SANITIZED_TITLE=${title// /_}
SANITIZED_TITLE=${title//[^a-zA-Z0-9_]/}
SANITIZED_TITLE=`echo -n $SANITIZED_TITLE | tr A-Z a-z`
foldername=$SANITIZED_TITLE
read -e -i "$foldername" -p "Nom du dossier ? " input
foldername="${input:-$foldername}"
if [ -z $foldername ]
	then
		error 'Renseigner un nom de dossier'
		exit
fi

# On récupère l'url (généré d'après le folder)	
# Si pas de valeur renseignée, message d'erreur et exit
url="http://localhost/${foldername}"
read -e -i "$url" -p "Url du projet ? " input
url="${input:-$url}"
if [ -z $url ]
	then
		error 'Renseigner une url'
		exit
fi

# On récupère l'adminemail
# Si pas de valeur renseignée, message d'erreur et exit
adminemail="nicolas.gies@digitaslbi.fr"
read -e -i "$adminemail" -p "Email admin ? " input
adminemail="${input:-$adminemail}"
if [ -z $adminemail ]
	then
		error 'Renseigner un email'
		exit
fi

# Database host
dbhost="localhost"
read -e -i "$dbhost" -p "Database host ? " input
dbhost="${input:-$dbhost}"
if [ -z $dbhost ]
	then
		error 'Renseigner le host de la BDD'
		exit
fi

# Database name
dbname=$foldername
read -e -i "$foldername" -p "Database name ? " input
dbname="${input:-$dbname}"
if [ -z $dbname ]
	then
		error 'Renseigner le nom de la BDD'
		exit
fi

# Database user
dbuser="root"
read -e -i "root" -p "Database user ? " input
dbuser="${input:-$dbuser}"
if [ -z $dbuser ]
	then
		error 'Renseigner le nom de la BDD'
		exit
fi

# Database password
dbpass="root"
read -e -i "root" -p "Database password ? " input
dbpass="${input:-$dbpass}"
if [ -z $dbpass ]
	then
		error 'Renseigner le nom de la BDD'
		exit
fi

# On récupère la clé acf 
# Si pas de valeur renseignée, message d'erreur 
read -p "Clé ACF pro ? " acfkey;
if [ -z $acfkey ]
	then
		error 'ACF pro ne sera pas installé'
fi

read -p "Secure wp-admin with htdigest/htaccess [y/n]" answer
if [[ $answer = y ]] ; then
		securewpadmin="yes"
	else
		securewpadmin="no"
fi

# Paths
rootpath="/var/www/"

# Path for public plugins list
publicpluginsfilepath="${rootpath}wp_install/plugins-public-list.txt"
	
# Path for pro plugins folder (zip files)
propluginsfilepath="${rootpath}wp_install/plugins-pro/"

# Theme installation
# Public theme : themetoinstall = (theme slug) // e.g. "university"
# Pro theme : themetoinstall = (path to a local zip file, or URL to a remote zip file) // e.g. "${rootpath}wp_install/themes-pro/theme.zip"
themetoinstall="${rootpath}wp_install/themes-pro/route.zip"
# No need to edit themefile & themename
themefile=${themetoinstall##*/}
themename=${themefile%%.*}

# Path for the wordpress installation
pathtoinstall="${rootpath}${foldername}"

# Path to a Wordpress XML Dump to import
wordpressdump="$pathtoinstall/wp-content/themes/$themename/cs-framework/config/dump/dump.xml"

# Wordpress Locale
locale=en_US

# Admin login
adminlogin="${foldername}_admin"
# Admin password : Generate a random one
adminpass=`< /dev/urandom tr -dc _A-Z-a-z-0-9 | head -c${1:-16}`

# DB
dbhost=localhost
dbname=$foldername
dbuser=root
dbpass=root
dbprefix="$foldername"_
	
success "Récap"
echo "--------------------------------------"
echo -e "Url			: ${bold} $url ${normal}"
echo -e "Foldername		: ${bold} $foldername ${normal}"
echo -e "Titre du projet		: ${bold} $title ${normal}"
echo -e "Docroot			: ${bold} $pathtoinstall ${normal}"
echo -e "Wordpress locale	: ${bold} $locale ${normal}"
echo -e "Admin login		: ${bold} $adminlogin ${normal}"
echo -e "Admin pass		: ${bold} $adminpass ${normal}"
echo -e "Admin email		: ${bold} $adminemail ${normal}"
echo -e "Secure wp-admin		: ${bold} $securewpadmin ${normal}"
echo -e "DB host 		: ${bold} $dbhost ${normal}"
echo -e "DB name 		: ${bold} $dbname ${normal}"
echo -e "DB user 		: ${bold} $dbuser ${normal}"
echo -e "DB pass 		: ${bold} $dbpass ${normal}"
echo -e "DB prefix		: ${bold} $dbprefix ${normal}"
echo -e "Thème à installer	: ${bold} $themename ${normal}"
if [ -n "$wordpressdump" ]
	then
		echo -e "Import des contenus	: ${bold} $wordpressdump ${normal}"
fi

echo -e "Liste des plugins publics à installer depuis la liste $publicpluginsfilepath :"
while read line || [ -n "$line" ]
do
	echo -e "- ${bold}$line ${normal}"
done < $publicpluginsfilepath
echo -e "Liste des plugins pros à installer depuis le dossier $propluginsfilepath : ${bold}"
ls -1 $propluginsfilepath | grep .zip | sed 's/.*/- &/'
if [ -n "$acfkey" ]
	then
		echo -e "${normal}- ${bold}advanced-custom-fields-pro${normal} (key : $acfkey)${normal}"
fi
echo "--------------------------------------"
#  ==============================
#  = The show is about to begin =
#  ==============================

# Welcome !
success "L'installation va pouvoir commencer"
echo "--------------------------------------"
read -p "Appuyez sur une touche pour continuer"

# CHECK :  Directory doesn't exist
cd $rootpath

# Check if provided folder name already exists
if [ -d $pathtoinstall ] && [  -f "$pathtoinstall/wp-config.php" ]
	then
		error "Le dossier $pathtoinstall existe déjà et wp-config.php est présent. Par sécurité, je ne vais pas plus loin pour ne rien écraser."
		exit 1
fi

# Create directory
if [ ! -d $foldername ]
	then
		bot "Je crée le dossier : $foldername"
		mkdir $foldername
fi

cd $foldername

bot "Je crée le fichier de configuration wp-cli.yml"
echo "
# Configuration de wpcli
# Voir http://wp-cli.org/config/

# Les modules apaches à charger
apache_modules:
	- mod_rewrite
" >> wp-cli.yml

# Download WP
bot "Je télécharge la dernière version de WordPress ($locale)..."
wp core download --locale=$locale --force

# Check version
bot "J'ai récupéré cette version :"
wp core version

# Create base configuration
bot "Je lance la configuration"
wp core config --dbhost=$dbhost --dbname=$dbname --dbuser=$dbuser --dbpass=$dbpass --dbprefix=$dbprefix --extra-php <<PHP
// Désactiver l'éditeur de thème et de plugins en administration
define('DISALLOW_FILE_EDIT', true);

// Changer le nombre de révisions de contenus
define('WP_POST_REVISIONS', 3);

// Supprimer automatiquement la corbeille tous les 7 jours
define('EMPTY_TRASH_DAYS', 7);

//Mode debug
define('WP_DEBUG', true);

//To avoid error notice messages with WP-CLI
//if ( defined( 'WP_CLI' ) ) $_SERVER['HTTP_HOST'] = $_SERVER['SERVER_NAME'] = '';
PHP

# Replace some settings to avoid WP-CLI fails when parsing custom wp-config.php
# https://github.com/wp-cli/wp-cli/issues/1631#issuecomment-127960241
#sed_source="require_once(ABSPATH . 'wp-settings.php');"
#sed_replacement="if(!function_exists('wp_unregister_GLOBALS')) require_once(ABSPATH . 'wp-settings.php');"
#sed -i "s/$sed_source/$sed_replacement/g" "$pathtoinstall/wp-config.php"

# Create database
bot "Je crée la base de données"
wp db create

# Launch install
bot "J'installe WordPress..."
wp core install --url=$url --title="$title" --admin_user=$adminlogin --admin_email=$adminemail --admin_password=$adminpass

# Public Plugins install
bot "J'installe les plugins publics à partir de la liste"
while read line || [ -n "$line" ]
do
	bot "-> Plugin $line"
    wp plugin install $line
done < $publicpluginsfilepath

# Pro Plugins install
cd $propluginsfilepath
shopt -s nullglob
for f in *.zip;
	do
		bot "-> Plugin $f"
		cd $pathtoinstall
		wp plugin install $propluginsfilepath$f
done

# Pro Plugins install : ACF PRO Download with Key
if [ -n "$acfkey" ]
	then
		bot "-> J'installe la version pro de ACF"
		cd $pathtoinstall/wp-content/plugins/
		curl -L -v 'http://connect.advancedcustomfields.com/index.php?p=pro&a=download&k='$acfkey > advanced-custom-fields-pro.zip
		wp plugin install advanced-custom-fields-pro.zip
		rm advanced-custom-fields-pro.zip
fi

bot "-> Installation du thème $themename"
cd $pathtoinstall
wp theme install $themetoinstall


bot "Création du thème child depuis $themename vers $foldername"
cd $pathtoinstall/wp-content/themes
mkdir $foldername

# Création de style.css
bot "Je modifie le fichier style.css du thème $foldername"
echo "/* 
	Theme Name: $title
	Description: $title child theme based on $themename Theme
	Version: 1.0 
	Template: $themename
*/" > $foldername/style.css

# Création de fonction.php
bot "Création de functions.php pour le thème $foldername"
cat <<"PHP" > $foldername/functions.php
<?php
/* Enqueuing the parent theme stylesheet */
function theme_enqueue_styles() {

	$parent_style = 'parent-style';

	wp_enqueue_style( $parent_style, get_template_directory_uri() . '/style.css' );
	wp_enqueue_style( 'child-style',
		get_stylesheet_directory_uri() . '/style.css',
		array( $parent_style )
	);
}
add_action( 'wp_enqueue_scripts', 'theme_enqueue_styles' );

/* Hide WP version strings from scripts and styles
 * @return {string} $src
 * @filter script_loader_src
 * @filter style_loader_src
 */
function wp_remove_wp_version_strings( $src ) {
     global $wp_version;
     parse_str(parse_url($src, PHP_URL_QUERY), $query);
     if ( !empty($query['ver']) && $query['ver'] === $wp_version ) {
          $src = remove_query_arg('ver', $src);
     }
     return $src;
}
add_filter( 'script_loader_src', 'wp_remove_wp_version_strings' );
add_filter( 'style_loader_src', 'wp_remove_wp_version_strings' );

/* Hide WP version strings from generator meta tag */
function wp_remove_version() {
return '';
}
add_filter('the_generator', 'wp_remove_version');
PHP

# Activate theme
bot "J'active le thème $foldername:"
wp theme activate $foldername

# Misc cleanup
bot "Je supprime les posts, comments et terms"
wp site empty --yes

bot "Je supprime Hello dolly et les themes de bases"
wp plugin delete hello
wp theme delete twentyfourteen
wp theme delete twentythirteen
wp theme delete twentyfifteen
wp option update blogdescription ''

line
# If Dump XML is filled, ask user for content import
if [ -f $wordpressdump ]
	then
		read -p "Importer les contenus depuis $wordpressdump (y/n)?" yn
fi

case $yn in
	[Yy]* ) bot "Importation des contenus de démo de $themename..."
		wp plugin activate wordpress-importer
		wp import $wordpressdump --authors=skip
		wp menu location assign main primary
		;;
	* ) bot "Pas d'importation de contenus"
		# Create standard pages
		bot "Création d'une page Home vide"
		wp post create --post_type=page --post_title='Home' --post_status=publish
		;;
esac

# Assignation de la page Home comme homepage
bot "Configuration de la page Home"
wp option update show_on_front 'page'
wp option update page_on_front $(wp post list --post_type=page --post_status=publish --posts_per_page=1 --pagename=Home --field=ID --format=ids)

# Permalinks to /%postname%/
bot "J'active la structure des permaliens /%postname%/ et génère le fichier .htaccess"
wp rewrite structure "/%postname%/" --hard
wp rewrite flush --hard

#Modifier le fichier htaccess
bot "J'ajoute des règles de sécurité dans le fichier htaccess"
cd $pathtoinstall
echo "
#Interdire le listage des repertoires
Options All -Indexes

#Interdire l'accès au fichier wp-config.php
<Files wp-config.php>
 	order allow,deny
	deny from all
</Files>

#Intedire l'accès au fichier htaccess lui même
<Files .htaccess>
	order allow,deny 
	deny from all 
</Files>

<FilesMatch \"^(README|readme|changelog)\.(txt|html|htm)$\">
order allow,deny
deny from all
</FilesMatch>

# Block the include-only files.
<IfModule mod_rewrite.c>
RewriteEngine On
RewriteBase /
RewriteRule ^wp-admin/includes/ - [F,L]
RewriteRule !^wp-includes/ - [S=3]
RewriteRule ^wp-includes/[^/]+\.php$ - [F,L]
RewriteRule ^wp-includes/js/tinymce/langs/.+\.php - [F,L]
RewriteRule ^wp-includes/theme-compat/ - [F,L]
</IfModule>
" >> .htaccess

if [ $securewpadmin == "yes" ]
then
bot "Génération d'un fichier .htdigest dans wp-admin"
# Wp-Admin secure with htdigest
echo ${adminlogin}:realm:$(printf "${adminlogin}:realm:${adminpass}" | md5sum - | sed -e 's/\s\+-//') > $pathtoinstall/wp-admin/.htdigest

#Modifier le fichier wp-admin/.htaccess
bot "Ajout des règles htaccess dans wp-admin"
cd $pathtoinstall
echo "
<Files admin-ajax.php>
Order allow,deny
Allow from all
Satisfy any
</Files>
AuthType Digest
AuthDigestProvider file
AuthUserFile \"$pathtoinstall/wp-admin/.htdigest\"
AuthName Limited!
require valid-user
" >> wp-admin/.htaccess
fi

#Options de sécurité, juste au cas où
bot "Désactivation enregistrements des utilisateurs publics"
wp option update users_can_register 0
	
#Activation des plugins
bot "Activation de tous les plugins..."
#wp plugin activate --all
bot "L'activation est plugins "
error "/!\ Les plugins n'ont pas été activés : register_activation_hook ne fonctionne pas avec tous les plugins lorsque WP-CLI effectue l'activation"
error "RDV à l'adresse $url/wp-admin/plugins.php?plugin_status=inactive pour les activer"
	
#Créer la page de la pattern library
#bot "Je crée la page pattern et l'associe au template adéquat."
#wp post create --post_type=page --post_title='Pattern' --post_status=publish --page_template='page-pattern.php'

# Finish !
success "L'installation est terminée !"
echo "--------------------------------------"
echo -e "Url			: ${bold} $url ${normal}"
echo -e "Path			: ${bold} $pathtoinstall ${normal}"
echo -e "Admin login		: ${bold} $adminlogin ${normal}"
echo -e "Admin pass		: ${bold} $adminpass ${normal}"
echo -e "Admin email		: ${bold} $adminemail ${normal}"
echo -e "DB host 		: ${bold} $dbhost ${normal}"
echo -e "DB name 		: ${bold} $dbname ${normal}"
echo -e "DB user 		: ${bold} dbuser ${normal}"
echo -e "DB pass 		: ${bold} $dbpass ${normal}"
echo -e "DB prefix 		: ${bold} $dbprefix ${normal}"
echo -e "WP_DEBUG 		: ${bold} TRUE ${normal}"
echo "--------------------------------------"

# Si on veut versionner le projet sur Gitlab
read -p "Versionner le projet sur Gitlab (y/n) ? " yn
case "$yn" in
    y ) 

		# On supprime le dossier git présent dans le dossier du thème
		rm -rf $pathtoinstall/wp-content/themes/$foldername/.git
	
		# On récupère les infos nécessaire
		read -p "SSH GIT du dépôt ? " adresse_git_ssh
	    
	    # Init git et lien avec le dépôt
	    git init 
	    git remote add upstream $adresse_git_ssh

		#TODO : GITIGNORE
		
	    # Ajouter les fichiers untracked, commit et push toussa
	    git add -A 
	    git commit -m 'first commit'
	    git push -u upstream master

	    success "OK ! Projet disponible sur $adresse_git_ssh";;
    n ) 
		echo "Tans pis !";;
esac




# Menu stuff
# echo -e "Je crée le menu principal, assigne les pages, et je lie l'emplacement du thème : "
# wp menu create "Menu Principal"
# wp menu item add-post menu-principal 3
# wp menu item add-post menu-principal 4
# wp menu item add-post menu-principal 5
# wp menu location assign menu-principal main-menu

# Git project
# REQUIRED : download Git at http://git-scm.com/downloads
# echo -e "Je Git le projet :"
# cd ../..
# git init    # git project
# git add -A  # Add all untracked files
# git commit -m "Initial commit"   # Commit changes
