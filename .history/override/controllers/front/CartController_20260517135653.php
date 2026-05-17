<?php
/**
 * Override CartController
 * Redirige toute tentative d'accès au panier vers la page d'accueil.
 * Le site fonctionne uniquement via le bouton "Commander rapidement".
 */
class CartController extends CartControllerCore
{
    public function init()
    {
        parent::init();
        Tools::redirect('index.php');
    }
}
