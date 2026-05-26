USE meuble2_db;

-- Corriger le nom de boutique (encodage corrompu "Rad??s")
UPDATE ps_configuration SET value="L'art du meuble Rades" WHERE name='PS_SHOP_NAME';

-- Ajouter l'adresse physique (essentiel pour le SEO local)
UPDATE ps_configuration SET value='Zone Industrielle Rades, Route de Tunis' WHERE name='PS_SHOP_ADDR1';
UPDATE ps_configuration SET value='L''art du meuble - Vente meubles Tunisie' WHERE name='PS_SHOP_DETAILS';

-- Corriger le numéro de téléphone (format international pour schema.org)
-- UPDATE ps_configuration SET value='+216 97 603 211' WHERE name='PS_SHOP_PHONE';

-- Activer Google Analytics (à renseigner avec votre ID GA4 réel)
-- UPDATE ps_configuration SET value='G-XXXXXXXXXX' WHERE name='GA_ACCOUNT_ID';

-- Vérification NAP
SELECT name, value FROM ps_configuration 
WHERE name IN ('PS_SHOP_NAME','PS_SHOP_ADDR1','PS_SHOP_CITY','PS_SHOP_CODE','PS_SHOP_COUNTRY','PS_SHOP_PHONE','PS_SHOP_EMAIL');
