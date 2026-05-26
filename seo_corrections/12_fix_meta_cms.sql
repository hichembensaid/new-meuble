USE meuble2_db;

-- Page "Nos Ateliers" (id_cms=6) : meta_description vide
UPDATE ps_cms_lang SET
  meta_description = "Découvrez les ateliers de fabrication de L'art du meuble Radès. Savoir-faire tunisien, menuiserie et ébénisterie de qualité en Tunisie."
WHERE id_cms = 6 AND id_lang = 1;

-- Page "Présentation" (id_cms=7) : meta_description trop longue (106 chars)
UPDATE ps_cms_lang SET
  meta_description = CONCAT(SUBSTRING(meta_description, 1, 157), '...')
WHERE id_cms = 7 AND id_lang = 1 AND CHAR_LENGTH(meta_description) > 160;

-- Page "A propos" (id_cms=4) : meta_title générique "A propos" → enrichir
UPDATE ps_cms_lang SET
  meta_title = "À propos - L'art du meuble Radès Tunisie"
WHERE id_cms = 4 AND id_lang = 1;

-- Page "Paiement sécurisé" (id_cms=5) : contenu très court (140 chars)
-- À enrichir manuellement dans le Back-office

-- Page "Mentions légales" (id_cms=2) : meta_description trop courte (16 chars)
UPDATE ps_cms_lang SET
  meta_description = "Mentions légales de L'art du meuble Radès - informations légales, conditions générales, RGPD Tunisie."
WHERE id_cms = 2 AND id_lang = 1;

-- Vérification
SELECT id_cms, link_rewrite, meta_title, CHAR_LENGTH(meta_description) as desc_len
FROM ps_cms_lang WHERE id_lang=1;
