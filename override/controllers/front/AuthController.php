<?php
/**
 * Override AuthController
 * Redirige toute tentative d'accès à la connexion/inscription vers la page d'accueil.
 * Le site fonctionne uniquement via le bouton "Commander rapidement" (sans compte).
 */
class AuthController extends AuthControllerCore
{
    public function init()
    {
        parent::init();
        Tools::redirect('index.php');
    }
}
