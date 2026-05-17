<?php
/**
 * Module QuickOrder - Commande Rapide avec paiement à la livraison
 *
 * @author    Votre Nom
 * @copyright 2026
 * @license   MIT
 *
 * Compatible PrestaShop 8 / PHP 8.2
 */

declare(strict_types=1);

if (!defined('_PS_VERSION_')) {
    exit;
}

// Autoload PSR-4 pour les classes du module
$autoload = __DIR__ . '/vendor/autoload.php';
if (file_exists($autoload)) {
    require_once $autoload;
}

use QuickOrder\Service\QuickOrderService;

class QuickOrder extends Module
{
    public const HOOK_PRODUCT_ACTIONS = 'displayProductActions';
    public const HOOK_HEADER          = 'displayHeader';
    public const HOOK_FOOTER          = 'displayFooter';

    /** Identifiant du mode de paiement COD enregistré en configuration */
    public const CONFIG_COD_MODULE = 'QUICKORDER_COD_MODULE';

    public function __construct()
    {
        $this->name                   = 'quickorder';
        $this->tab                    = 'front_office_features';
        $this->version                = '1.0.0';
        $this->author                 = 'Votre Nom';
        $this->need_instance          = 0;
        $this->ps_versions_compliancy = ['min' => '8.0.0', 'max' => _PS_VERSION_];
        $this->bootstrap              = true;

        parent::__construct();

        $this->displayName = $this->trans(
            'Commande Rapide',
            [],
            'Modules.Quickorder.Admin'
        );
        $this->description = $this->trans(
            'Permet au client de commander rapidement avec paiement à la livraison sans créer de compte.',
            [],
            'Modules.Quickorder.Admin'
        );
    }

    /* -----------------------------------------------------------------------
     * Install / Uninstall
     * -------------------------------------------------------------------- */

    public function install(): bool
    {
        return parent::install()
            && $this->registerHook(self::HOOK_PRODUCT_ACTIONS)
            && $this->registerHook(self::HOOK_HEADER)
            && $this->registerHook(self::HOOK_FOOTER)
            && $this->installConfiguration();
    }

    public function uninstall(): bool
    {
        return parent::uninstall()
            && $this->uninstallConfiguration();
    }

    private function installConfiguration(): bool
    {
        // Par défaut on utilise "cod" (Cash on Delivery) – adaptez selon votre install
        return Configuration::updateValue(self::CONFIG_COD_MODULE, 'cod');
    }

    private function uninstallConfiguration(): bool
    {
        return Configuration::deleteByName(self::CONFIG_COD_MODULE);
    }

    /* -----------------------------------------------------------------------
     * Hooks
     * -------------------------------------------------------------------- */

    /**
     * Hook header : conservé pour compatibilité thèmes qui utilisent registerJavascript.
     */
    public function hookDisplayHeader(array $params): void
    {
        if ($this->context->controller->php_self !== 'product') {
            return;
        }

        $this->context->controller->registerStylesheet(
            'quickorder-css',
            'modules/' . $this->name . '/views/css/quickorder.css',
            ['media' => 'all', 'priority' => 200]
        );

        $this->context->controller->registerJavascript(
            'quickorder-js',
            'modules/' . $this->name . '/views/js/quickorder.js',
            ['position' => 'bottom', 'priority' => 200]
        );
    }

    /**
     * Affiche UNIQUEMENT le bouton sur la fiche produit.
     * Le modal est injecté séparément dans hookDisplayFooter pour éviter
     * qu'il soit supprimé lors du rechargement AJAX de la zone produit.
     */
    public function hookDisplayProductActions(array $params): string
    {
        $product = $params['product'] ?? null;

        $productId   = 0;
        $productName = '';

        if (is_object($product)) {
            $productId   = (int) $product->id;
            $productName = (string) $product->name;
        } elseif (is_array($product)) {
            $productId   = (int) ($product['id_product'] ?? 0);
            $productName = (string) ($product['name'] ?? '');
        }

        if (!$productId && isset($this->context->controller->id_product)) {
            $productId = (int) $this->context->controller->id_product;
        }
        if (!$productId) {
            $productId = (int) Tools::getValue('id_product');
        }
        if (!$productId) {
            return '';
        }

        if (empty($productName)) {
            $p           = new Product($productId, false, $this->context->language->id);
            $productName = $p->name ?? '';
        }

        $this->context->smarty->assign([
            'quickorder_product_id'   => $productId,
            'quickorder_product_name' => $productName,
        ]);

        return $this->fetch('module:quickorder/views/templates/front/button.tpl');
    }

    /**
     * Injecte le modal HTML + CSS + JS en bas de page (une seule fois).
     * Placé ici pour ne pas être affecté par les rechargements AJAX du thème.
     */
    public function hookDisplayFooter(array $params): string
    {
        if ($this->context->controller->php_self !== 'product') {
            return '';
        }

        $ajaxUrl = $this->context->link->getModuleLink($this->name, 'ajax', [], true);
        $token   = Tools::getToken(false);

        $this->context->smarty->assign([
            'quickorder_ajax_url' => $ajaxUrl,
            'quickorder_token'    => $token,
        ]);

        $base   = __PS_BASE_URI__;
        $cssUrl = $base . 'modules/' . $this->name . '/views/css/quickorder.css?v=' . $this->version;
        $jsUrl  = $base . 'modules/' . $this->name . '/views/js/quickorder.js?v=' . $this->version;

        $html  = '<link rel="stylesheet" href="' . $cssUrl . '">';
        $html .= $this->fetch('module:quickorder/views/templates/front/modal.tpl');
        $html .= '<script src="' . $jsUrl . '"></script>';

        return $html;
    }

    /* -----------------------------------------------------------------------
     * Back-office : page de configuration
     * -------------------------------------------------------------------- */

    public function getContent(): string
    {
        $output = '';

        if (Tools::isSubmit('submitQuickOrderConfig')) {
            $codModule = Tools::getValue('QUICKORDER_COD_MODULE');

            if (empty($codModule)) {
                $output .= $this->displayError(
                    $this->trans('Le nom du module COD est requis.', [], 'Modules.Quickorder.Admin')
                );
            } else {
                Configuration::updateValue(self::CONFIG_COD_MODULE, pSQL($codModule));
                $output .= $this->displayConfirmation(
                    $this->trans('Configuration enregistrée.', [], 'Modules.Quickorder.Admin')
                );
            }
        }

        return $output . $this->renderConfigForm();
    }

    private function renderConfigForm(): string
    {
        $fieldsForm = [
            'form' => [
                'legend' => [
                    'title' => $this->trans('Paramètres', [], 'Modules.Quickorder.Admin'),
                    'icon'  => 'icon-cogs',
                ],
                'input' => [
                    [
                        'type'     => 'text',
                        'label'    => $this->trans('Nom du module de paiement COD', [], 'Modules.Quickorder.Admin'),
                        'name'     => 'QUICKORDER_COD_MODULE',
                        'size'     => 40,
                        'required' => true,
                        'desc'     => $this->trans(
                            'Nom technique du module paiement à la livraison (ex: cod, cashondelivery).',
                            [],
                            'Modules.Quickorder.Admin'
                        ),
                    ],
                ],
                'submit' => [
                    'title' => $this->trans('Enregistrer', [], 'Admin.Actions'),
                ],
            ],
        ];

        $helper                           = new HelperForm();
        $helper->show_toolbar             = false;
        $helper->table                    = $this->table;
        $helper->module                   = $this;
        $helper->default_form_language    = $this->context->language->id;
        $helper->identifier               = $this->identifier;
        $helper->submit_action            = 'submitQuickOrderConfig';
        $helper->currentIndex             = $this->context->link->getAdminLink('AdminModules', false)
            . '&configure=' . $this->name;
        $helper->token                    = Tools::getAdminTokenLite('AdminModules');
        $helper->tpl_vars                 = [
            'fields_value' => [
                'QUICKORDER_COD_MODULE' => Configuration::get(self::CONFIG_COD_MODULE),
            ],
            'languages'    => $this->context->controller->getLanguages(),
            'id_language'  => $this->context->language->id,
        ];

        return $helper->generateForm([$fieldsForm]);
    }
}
