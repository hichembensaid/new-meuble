# Manuel d'Installation - Déploiement sur Serveur OVH

## Prérequis

- Accès SSH au serveur OVH
- Git installé sur le serveur
- PHP 7.1+ (recommandé PHP 7.4 ou 8.0)
- MySQL 5.6+ ou MariaDB 10.0+
- Composer installé
- Apache ou Nginx configuré

## 1. Connexion au Serveur OVH

```bash
ssh votre_utilisateur@votre_serveur.ovh.net
```

## 2. Cloner le Projet

```bash
# Se placer dans le répertoire web (généralement /var/www ou ~/www)
cd /var/www

# Cloner le repository
git clone https://github.com/hichembensaid/new-meuble.git

# Se déplacer dans le répertoire du projet
cd new-meuble

# ⚠️ À ce stade, le dossier vendor n'existe PAS encore
# Il sera créé à l'étape 5 avec "composer install"
```

## 3. Configuration des Permissions

```bash
# Donner les droits appropriés
chmod 755 -R ./
chmod 777 -R ./var/cache
chmod 777 -R ./var/logs
chmod 777 -R ./img
chmod 777 -R ./upload
chmod 777 -R ./download
chmod 777 -R ./mails
chmod 777 -R ./modules
chmod 777 -R ./themes
chmod 777 -R ./translations
chmod 777 -R ./app/config
chmod 777 -R ./app/Resources/translations
```

## 4. Fichiers à Configurer

### 4.1. Configuration Base de Données - `app/config/parameters.php`

**Ce fichier doit être créé/modifié avec vos informations de base de données OVH :**

```php
<?php
return array(
    'parameters' => array(
        'database_host' => 'votre_serveur_mysql.mysql.db',  // Ex: mysql51-123.perso
        'database_port' => '3306',
        'database_name' => 'votre_base_de_donnees',
        'database_user' => 'votre_utilisateur_mysql',
        'database_password' => 'votre_mot_de_passe_mysql',
        'database_prefix' => 'ps_',
        'database_engine' => 'InnoDB',
        'mailer_transport' => 'smtp',
        'mailer_host' => '127.0.0.1',
        'mailer_user' => null,
        'mailer_password' => null,
        'secret' => 'VotreClefSecreteAleatoire123456789',
        'ps_caching' => 'CacheMemcache',
        'ps_cache_enable' => false,
        'ps_creation_date' => 'now',
        'locale' => 'fr-FR',
        'use_debug_toolbar' => false,
        'cookie_key' => 'VotreCookieKeyAleatoire',
        'cookie_iv' => 'VotreCookieIVAleatoire',
        'new_cookie_key' => 'VotreNouveauCookieKeyAleatoire',
    ),
);
```

### 4.2. Configuration PrestaShop - `config/settings.inc.php`

**Vérifier et ajuster ce fichier :**

```php
<?php
define('_DB_SERVER_', 'votre_serveur_mysql.mysql.db');
define('_DB_NAME_', 'votre_base_de_donnees');
define('_DB_USER_', 'votre_utilisateur_mysql');
define('_DB_PASSWD_', 'votre_mot_de_passe_mysql');
define('_DB_PREFIX_', 'ps_');
define('_MYSQL_ENGINE_', 'InnoDB');
define('_PS_CACHING_SYSTEM_', 'CacheMemcache');
define('_PS_CACHE_ENABLED_', '0');
define('_COOKIE_KEY_', 'VotreCookieKeyAleatoire');
define('_COOKIE_IV_', 'VotreCookieIVAleatoire');
define('_PS_CREATION_DATE_', 'YYYY-MM-DD');
define('_PS_VERSION_', '1.7.x.x');

// Mode développement (à désactiver en production)
define('_PS_MODE_DEV_', false);
```

### 4.3. Fichier .htaccess (Racine du projet)

**S'assurer que le fichier `.htaccess` existe à la racine :**

```apache
# Configuration pour PrestaShop
<IfModule mod_rewrite.c>
    RewriteEngine on
    RewriteCond %{REQUEST_URI} !^/index\.php
    RewriteCond %{REQUEST_FILENAME} !-f
    RewriteCond %{REQUEST_FILENAME} !-d
    RewriteRule . index.php [L]
</IfModule>

# Protection des fichiers sensibles
<FilesMatch "\.(htaccess|ini|log|sh|inc|conf|sql|zip|tar|gz)$">
    Order Allow,Deny
    Deny from all
</FilesMatch>
```

### 4.4. Configuration du domaine

**Fichier à créer : `app/config/parameters.yml` (si nécessaire)**

```yaml
parameters:
    domain: votre-domaine.fr
    shop_url: https://votre-domaine.fr
```

## 5. Installation des Dépendances

**⚠️ IMPORTANT : Le dossier `vendor` n'est PAS dans Git !**

Le dossier `vendor` contient les dépendances PHP et est généré par Composer. Il doit être créé sur le serveur.

### Option 1 : Utiliser Composer en local sur le serveur OVH

```bash
# Télécharger Composer localement (sans droits root)
cd /var/www/new-meuble
php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
php composer-setup.php
php -r "unlink('composer-setup.php');"

# Utiliser Composer local pour installer les dépendances
php composer.phar install --no-dev --optimize-autoloader
```

### Option 2 : Générer vendor en local et l'uploader (SI Option 1 ne fonctionne pas)

**Sur votre machine locale (Windows) :**

```powershell
# Dans votre projet local
cd d:\projets\new-meuble

# Installer les dépendances
composer install --no-dev --optimize-autoloader

# Créer une archive du dossier vendor
Compress-Archive -Path vendor -DestinationPath vendor.zip
```

**Puis sur le serveur OVH via FTP/SFTP :**
1. Uploader le fichier `vendor.zip` vers `/var/www/new-meuble/`
2. Se connecter en SSH et décompresser :

```bash
cd /var/www/new-meuble

# Option 1 : Avec unzip (si disponible)
unzip vendor.zip
rm vendor.zip

# Option 2 : Si unzip n'est pas disponible, utiliser PHP
php -r "
\$zip = new ZipArchive;
if (\$zip->open('vendor.zip') === TRUE) {
    \$zip->extractTo('./');
    \$zip->close();
    echo 'Extraction réussie\n';
    unlink('vendor.zip');
} else {
    echo 'Erreur lors de l\'extraction\n';
}
"

# Option 3 : Uploader directement le dossier vendor via FTP/SFTP (plus lent mais fonctionne toujours)
# Utilisez FileZilla ou WinSCP pour uploader le dossier vendor/ complet
```

### Option 3 : Utiliser le composer.phar déjà présent (si disponible)

```bash
# Vérifier si composer.phar existe déjà dans le projet
cd /var/www/new-meuble
ls -la composer.phar

# Si oui, l'utiliser directement
php composer.phar install --no-dev --optimize-autoloader
```

### Option 4 : Ajouter vendor dans Git (Solution pour hébergement sans Composer)

**⚠️ NON RECOMMANDÉ en général, MAIS fonctionnel et simple pour OVH mutualisé**

Si vous n'avez pas accès à Composer sur votre hébergement OVH, vous pouvez versionner le dossier `vendor` dans Git.

**Étape 1 : Sur votre machine locale Windows**

```powershell
# Ouvrir le terminal PowerShell
cd d:\projets\new-meuble

# Générer le dossier vendor avec toutes les dépendances
composer install --no-dev --optimize-autoloader

# Vérifier que le dossier vendor est créé
ls vendor

# Modifier le fichier .gitignore pour autoriser vendor
# Ouvrir .gitignore et commenter ou supprimer cette ligne : /vendor
```

**Étape 2 : Éditer le fichier `.gitignore`**

Ouvrez `d:\projets\new-meuble\.gitignore` et modifiez :

```gitignore
# AVANT :
/vendor

# APRÈS (commenter la ligne) :
# /vendor
```

**Étape 3 : Ajouter vendor dans Git**

```powershell
# Ajouter tous les fichiers du dossier vendor
git add vendor/

# Vérifier ce qui va être ajouté
git status

# Créer le commit
git commit -m "Add vendor directory for OVH deployment without Composer"

# Pousser vers GitHub
git push origin main
```

**Étape 4 : Sur le serveur OVH via SSH**

```bash
# Le dossier vendor sera maintenant automatiquement cloné avec le projet
cd /var/www
git clone https://github.com/hichembensaid/new-meuble.git
cd new-meuble

# Vérifier que vendor existe
ls -la vendor/

# C'est tout ! Pas besoin de composer install
```

**📊 Avantages :**
- ✅ Déploiement ultra-simple (juste un git clone)
- ✅ Fonctionne sur n'importe quel hébergement
- ✅ Pas besoin de Composer sur le serveur
- ✅ Pas de problème de compatibilité PHP

**⚠️ Inconvénients :**
- ❌ Repository beaucoup plus lourd (100-200 Mo au lieu de quelques Mo)
- ❌ Git clone plus long
- ❌ Difficile de voir vos vrais changements dans les diffs
- ❌ Mises à jour des dépendances plus complexes

**🔄 Pour mettre à jour les dépendances plus tard :**

```powershell
# Sur votre machine locale
composer update --no-dev --optimize-autoloader
git add vendor/
git commit -m "Update vendor dependencies"
git push origin main

# Sur le serveur OVH
cd /var/www/new-meuble
git pull origin main
```

### Dépendances Node.js (optionnel)

```bash
# Si vous avez des dépendances Node.js
npm install
npm run build
```

**Note** : Choisissez l'option qui correspond à votre environnement OVH. L'option 1 ou 2 est recommandée.

## 6. Import de la Base de Données

```bash
# Se connecter à MySQL
mysql -h votre_serveur_mysql.mysql.db -u votre_utilisateur -p

# Créer la base si elle n'existe pas
CREATE DATABASE IF NOT EXISTS votre_base_de_donnees CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE votre_base_de_donnees;

# Importer votre base de données
SOURCE /var/www/new-meuble/new\ db.sql;

# Ou via la ligne de commande directement
mysql -h votre_serveur_mysql.mysql.db -u votre_utilisateur -p votre_base_de_donnees < "new db.sql"
```

## 7. Configuration du Serveur Web

### Pour Apache (VirtualHost)

Créer/éditer : `/etc/apache2/sites-available/new-meuble.conf`

```apache
<VirtualHost *:80>
    ServerName votre-domaine.fr
    ServerAlias www.votre-domaine.fr
    
    DocumentRoot /var/www/new-meuble
    
    <Directory /var/www/new-meuble>
        Options -Indexes +FollowSymLinks
        AllowOverride All
        Require all granted
    </Directory>
    
    ErrorLog ${APACHE_LOG_DIR}/new-meuble-error.log
    CustomLog ${APACHE_LOG_DIR}/new-meuble-access.log combined
</VirtualHost>
```

Activer le site :
```bash
sudo a2ensite new-meuble.conf
sudo systemctl reload apache2
```

### Pour Nginx

Créer/éditer : `/etc/nginx/sites-available/new-meuble`

```nginx
server {
    listen 80;
    server_name votre-domaine.fr www.votre-domaine.fr;
    
    root /var/www/new-meuble;
    index index.php;
    
    location / {
        try_files $uri $uri/ /index.php?$args;
    }
    
    location ~ \.php$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:/var/run/php/php7.4-fpm.sock;
        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
        include fastcgi_params;
    }
    
    location ~ /\. {
        deny all;
    }
}
```

## 8. Mise à Jour des URLs dans la Base de Données

```sql
-- Se connecter à la base de données
mysql -h votre_serveur_mysql.mysql.db -u votre_utilisateur -p votre_base_de_donnees

-- Mettre à jour les URLs du shop
UPDATE ps_shop_url SET domain = 'votre-domaine.fr', domain_ssl = 'votre-domaine.fr' WHERE id_shop = 1;

-- Mettre à jour les URLs de configuration
UPDATE ps_configuration SET value = 'https://votre-domaine.fr' WHERE name = 'PS_SHOP_DOMAIN';
UPDATE ps_configuration SET value = 'https://votre-domaine.fr' WHERE name = 'PS_SHOP_DOMAIN_SSL';
```

## 9. Configuration SSL (Recommandé)

```bash
# Installer Certbot pour Let's Encrypt
sudo apt-get install certbot python3-certbot-apache  # Pour Apache
# ou
sudo apt-get install certbot python3-certbot-nginx   # Pour Nginx

# Obtenir le certificat SSL
sudo certbot --apache -d votre-domaine.fr -d www.votre-domaine.fr
# ou
sudo certbot --nginx -d votre-domaine.fr -d www.votre-domaine.fr
```

## 10. Vider les Caches

```bash
cd /var/www/new-meuble

# Vider le cache Symfony
php bin/console cache:clear --env=prod

# Vider le cache PrestaShop
rm -rf var/cache/*
rm -rf cache/class_index.php
```

## 11. Configuration du Back-Office

1. Accéder au back-office : `https://votre-domaine.fr/psadmin` (ou le nom de votre dossier admin)
2. Se connecter avec vos identifiants
3. Aller dans **Paramètres de la boutique** > **Trafic & SEO**
4. Vérifier que l'URL de votre boutique est correcte
5. Activer SSL si configuré
6. Régénérer le fichier `.htaccess` si nécessaire

## 12. Sécurité Post-Installation

```bash
# Renommer le dossier d'administration (important !)
mv psadmin admin_votrenomsecurise

# Supprimer le dossier d'installation si présent
rm -rf install

# Protéger les fichiers sensibles
chmod 644 app/config/parameters.php
chmod 644 config/settings.inc.php

# Désactiver le mode développement
# Dans config/defines.inc.php, s'assurer que :
# define('_PS_MODE_DEV_', false);
```

## 13. Fichiers à NE PAS Versionner (.gitignore)

**Ces fichiers/dossiers ne sont PAS dans Git et c'est normal :**

```gitignore
# Dépendances (à générer avec composer install)
/vendor/
/node_modules/

# Configuration locale (à créer manuellement sur le serveur)
/app/config/parameters.php
/config/settings.inc.php

# Cache et logs
/var/cache/*
!/var/cache/.gitkeep
/var/logs/*
!/var/logs/.gitkeep

# Fichiers uploadés
/upload/*
/download/*
/img/tmp/*
/img/p/*
/img/c/*

# Fichiers système
.DS_Store
.idea/
.vscode/
composer.phar
composer.lock
package-lock.json

# Fichiers sensibles
*.log
*.sql
```

**À faire sur le serveur après le clone :**

1. ✅ Lancer `composer install` pour créer le dossier `vendor`
2. ✅ Créer/configurer `app/config/parameters.php`
3. ✅ Créer/configurer `config/settings.inc.php`
4. ✅ Créer les dossiers manquants si nécessaire

## 14. Vérifications Finales

- [ ] La page d'accueil s'affiche correctement
- [ ] Le back-office est accessible
- [ ] Les images s'affichent
- [ ] Les modules sont actifs
- [ ] Les emails de test fonctionnent
- [ ] Le mode maintenance est désactivé
- [ ] SSL est configuré et actif
- [ ] Les redirections fonctionnent

## 15. Commandes Utiles

```bash
# Voir les logs d'erreurs
tail -f /var/www/new-meuble/var/logs/prod.log

# Mettre à jour le projet depuis Git
cd /var/www/new-meuble
git pull origin main
composer install --no-dev --optimize-autoloader
php bin/console cache:clear --env=prod

# Backup de la base de données
mysqldump -h votre_serveur_mysql.mysql.db -u votre_utilisateur -p votre_base_de_donnees > backup_$(date +%Y%m%d).sql
```

## Support et Dépannage

### Erreur 500
- Vérifier les logs : `var/logs/prod.log`
- Vérifier les permissions des dossiers
- Vérifier la configuration PHP (memory_limit, max_execution_time)

### Page blanche
- Activer temporairement le mode debug dans `config/defines.inc.php`
- Vérifier les logs Apache/Nginx

### Problèmes de connexion base de données
- Vérifier les identifiants dans `app/config/parameters.php`
- Tester la connexion MySQL depuis le serveur
- Vérifier que le serveur MySQL autorise les connexions

---

**Note importante** : Remplacez toutes les valeurs `votre_*` par vos vraies informations de serveur OVH.
