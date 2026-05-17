<?php
/**
 * Contrôleur AJAX front - QuickOrder
 * Route : /module/quickorder/ajax
 *
 * Compatible PrestaShop 8 / PHP 7.4+
 */

use QuickOrder\Service\QuickOrderService;
use QuickOrder\Service\QuickOrderValidator;

class QuickOrderAjaxModuleFrontController extends ModuleFrontController
{
    /** @var bool Forcer le rendu JSON */
    public $ajax = true;

    public function __construct()
    {
        parent::__construct();
        $this->content_only = true;
    }

    /* -----------------------------------------------------------------------
     * Point d'entrée unique
     * -------------------------------------------------------------------- */

    public function postProcess(): void
    {
        // Accepte uniquement POST
        if (!$_SERVER || strtoupper($_SERVER['REQUEST_METHOD'] ?? '') !== 'POST') {
            $this->sendJson(false, 'Méthode non autorisée.', 405);
        }

        // Vérification CSRF
        if (!$this->validateToken()) {
            $this->sendJson(false, 'Token invalide.', 403);
        }

        // Dispatch selon l'action
        $action = Tools::getValue('action');

        switch ($action) {
            case 'submitOrder':
                $this->handleSubmitOrder();
                break;
            default:
                $this->sendJson(false, 'Action inconnue.', 400);
        }
    }

    /* -----------------------------------------------------------------------
     * Action : soumettre la commande rapide
     * -------------------------------------------------------------------- */

    private function handleSubmitOrder(): void
    {
        // ---- 1. Récupération & nettoyage des données ----------------------
        $data = [
            'id_product'      => (int) Tools::getValue('id_product'),
            'id_product_attr' => (int) Tools::getValue('id_product_attribute', 0),
            'qty'             => max(1, (int) Tools::getValue('qty', 1)),
            'firstname'       => trim(Tools::getValue('firstname', '')),
            'lastname'        => trim(Tools::getValue('lastname', '')),
            'phone'           => trim(Tools::getValue('phone', '')),
            'address1'        => trim(Tools::getValue('address1', '')),
            'city'            => trim(Tools::getValue('city', '')),
            'postcode'        => trim(Tools::getValue('postcode', '')),
            'comment'         => trim(Tools::getValue('comment', '')),
        ];

        // ---- 2. Validation -----------------------------------------------
        $validator = new QuickOrderValidator($this->module->getTranslator());
        $errors    = $validator->validate($data);

        if (!empty($errors)) {
            $this->sendJson(false, implode('<br>', $errors), 422);
        }

        // ---- 3. Traitement métier ----------------------------------------
        try {
            $service = new QuickOrderService(
                $this->context,
                $this->module
            );

            $order = $service->createOrder($data);

            $this->sendJson(true, $this->module->trans(
                'Votre commande #%s a bien été enregistrée ! Nous vous contacterons prochainement.',
                [$order->reference],
                'Modules.Quickorder.Front'
            ), 200, ['order_reference' => $order->reference]);
        } catch (Throwable $e) {
            PrestaShopLogger::addLog(
                '[QuickOrder] Erreur création commande : ' . $e->getMessage()
                . ' | Trace : ' . $e->getTraceAsString(),
                3,
                null,
                'QuickOrder',
                0,
                true
            );

            $this->sendJson(false, $this->module->trans(
                'Une erreur est survenue. Veuillez réessayer ou nous contacter.',
                [],
                'Modules.Quickorder.Front'
            ), 500);
        }
    }

    /* -----------------------------------------------------------------------
     * Helpers
     * -------------------------------------------------------------------- */

    /**
     * Valide le token CSRF transmis dans le corps de la requête.
     */
    private function validateToken(): bool
    {
        $token = Tools::getValue('token');

        if (empty($token)) {
            return false;
        }

        return $token === Tools::getToken(false);
    }

    /**
     * Envoie une réponse JSON et termine l'exécution.
     *
     * @param array<string, mixed> $extra
     */
    private function sendJson(
        bool   $success,
        string $message,
        int    $httpCode = 200,
        array  $extra    = []
    ): void {
        http_response_code($httpCode);
        header('Content-Type: application/json; charset=utf-8');

        echo json_encode(array_merge(
            [
                'success' => $success,
                'message' => $message,
            ],
            $extra
        ), JSON_UNESCAPED_UNICODE);

        exit;
    }
}
