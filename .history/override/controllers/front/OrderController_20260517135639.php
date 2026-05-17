<?php
/**
 * Override OrderController
 * Redirige toute tentative d'accès au checkout vers la page d'accueil.
 * Le site fonctionne uniquement via le bouton "Commander rapidement".
 */
class OrderController extends OrderControllerCore
{
    public function init()
    {
        parent::init();
        Tools::redirect('index.php');
    }
}
