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

```bash
# Installer Composer si ce n'est pas déjà fait
curl -sS https://getcomposer.org/installer | php
mv composer.phar /usr/local/bin/composer

# Installer les dépendances PHP
composer install --no-dev --optimize-autoloader

# Si vous avez des dépendances Node.js
npm install
npm run build
```

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

Assurez-vous que votre `.gitignore` contient :

```
/app/config/parameters.php
/config/settings.inc.php
/var/cache/*
/var/logs/*
/upload/*
/download/*
/img/tmp/*
.DS_Store
composer.phar
```

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
