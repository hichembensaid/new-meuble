<?php
/**
 * Override MyAccountController
 * Redirige toute tentative d'accès à "Mon compte" vers la page d'accueil.
 */
class MyAccountController extends MyAccountControllerCore
{
    public function init()
    {
        parent::init();
        Tools::redirect('index.php');
    }
}
