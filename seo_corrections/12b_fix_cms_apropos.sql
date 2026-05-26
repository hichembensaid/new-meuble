USE meuble2_db;
UPDATE ps_cms_lang SET meta_title = "A propos - L'art du meuble Rades Tunisie" WHERE id_cms = 4 AND id_lang = 1;
UPDATE ps_cms_lang SET meta_description = "Decouvrez L'art du meuble Rades : notre histoire, nos valeurs et notre savoir-faire dans la fabrication de meubles en Tunisie depuis des annees." WHERE id_cms = 4 AND id_lang = 1;
SELECT id_cms, link_rewrite, meta_title, CHAR_LENGTH(meta_description) as desc_len FROM ps_cms_lang WHERE id_lang=1;
