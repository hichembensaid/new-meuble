USE meuble2_db;

UPDATE ps_product_lang SET meta_title = "Meuble d'entree ASTRO | L'art du meuble" WHERE id_product IN (275,320) AND id_lang=1;
UPDATE ps_product_lang SET meta_title = "Banquette bois BLENZ Elegance - Canape massif" WHERE id_product IN (538,599) AND id_lang=1;
UPDATE ps_product_lang SET meta_title = "Meuble TV Living ARDO - Table TV salon" WHERE id_product=369 AND id_lang=1;
UPDATE ps_product_lang SET meta_title = "Meuble TV Living ALPHA - Table TV salon" WHERE id_product=370 AND id_lang=1;
UPDATE ps_product_lang SET meta_title = "Meuble TV SWITCH - Element TV Living" WHERE id_product=359 AND id_lang=1;
UPDATE ps_product_lang SET meta_title = "Meuble TV ADANA - Element TV Living" WHERE id_product=362 AND id_lang=1;
UPDATE ps_product_lang SET meta_title = "Meuble TV ASTRO - Element TV Living" WHERE id_product=366 AND id_lang=1;
UPDATE ps_product_lang SET meta_title = "Fauteuil de bureau ergonomique AVION tetiere Caramel" WHERE id_product=703 AND id_lang=1;
UPDATE ps_product_lang SET meta_title = "Fauteuil de bureau ergonomique AVION tetiere Grege" WHERE id_product=702 AND id_lang=1;
UPDATE ps_product_lang SET meta_title = "Fauteuil de direction LEONARDO avec accoudoirs reglable" WHERE id_product=583 AND id_lang=1;
UPDATE ps_product_lang SET meta_title = "TABLE TRETEAU - Bureau en bois structure hetre" WHERE id_product=204 AND id_lang=1;
UPDATE ps_product_lang SET meta_title = "Meuble d'entree CARLLA - Rangement decoration" WHERE id_product=340 AND id_lang=1;
UPDATE ps_product_lang SET meta_title = "Chaise Salle de Fete VIGO - acier epoxy" WHERE id_product=600 AND id_lang=1;
UPDATE ps_product_lang SET meta_title = "Salle a manger Square en hetre 6 places Blenz" WHERE id_product=534 AND id_lang=1;
UPDATE ps_product_lang SET meta_title = "Chambre a coucher Valentino - Suite parentale" WHERE id_product=589 AND id_lang=1;
UPDATE ps_product_lang SET meta_title = "Tabouret Architecte confort - cuisine assise" WHERE id_product=592 AND id_lang=1;
UPDATE ps_product_lang SET meta_title = "CHAMBRE A COUCHER LEONELLA - Lit Garde Robe" WHERE id_product=388 AND id_lang=1;
UPDATE ps_product_lang SET meta_title = "Table enseignement 110x37 - Plateau MDF metal" WHERE id_product=437 AND id_lang=1;
UPDATE ps_product_lang SET meta_title = "Porte manteau bois Hetre - patere arcboutant" WHERE id_product=195 AND id_lang=1;
UPDATE ps_product_lang SET meta_title = "Chaise DENIZ Metallica polypropylene design" WHERE id_product=506 AND id_lang=1;

SELECT COUNT(*) as encore_trop_longs FROM ps_product_lang WHERE id_lang=1 AND LENGTH(meta_title) > 70;
