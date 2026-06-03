<?php
/**
 * QuickOrderService – Logique métier de la commande rapide
 *
 * Compatible PrestaShop 8 / PHP 7.4+
 */

namespace QuickOrder\Service;

use Address;
use Cart;
use Configuration;
use Context;
use Country;
use Currency;
use Customer;
use Module;
use Order;
use OrderHistory;
use PrestaShopLogger;
use Product;
use Tools;
use Validate;

class QuickOrderService
{
    /** Préfixe e-mail technique pour les clients ghost */
    private const GUEST_EMAIL_PREFIX = 'guest.quickorder.';

    /** Domaine e-mail fictif pour les guests */
    private const GUEST_EMAIL_DOMAIN = '@quickorder.internal';

    /** @var Context */
    private $context;

    /** @var Module */
    private $module;

    public function __construct(
        Context $context,
        Module  $module
    ) {
        $this->context = $context;
        $this->module  = $module;
    }

    /* -----------------------------------------------------------------------
     * Point d'entrée public
     * -------------------------------------------------------------------- */

    /**
     * Crée une commande complète à partir des données du formulaire.
     *
     * @param array<string, mixed> $data Données validées du formulaire
     *
     * @throws \RuntimeException Si la commande ne peut pas être créée
     */
    public function createOrder(array $data): Order
    {
        // --- 1. Client guest ------------------------------------------------
        $customer = $this->createGuestCustomer(
            $data['firstname'],
            $data['lastname']
        );

        // --- 2. Adresse -----------------------------------------------------
        $address = $this->createAddress($customer, $data);

        // --- 3. Panier ------------------------------------------------------
        $cart = $this->createCart($customer, $address, $data);

        // --- 4. Commande ----------------------------------------------------
        $order = $this->validateCart($cart, $data['comment'] ?? '');

        // --- 5. Journalisation ---------------------------------------------
        PrestaShopLogger::addLog(
            sprintf(
                $order->reference,
                $data['firstname'],
                $data['lastname'],
                $data['phone']
            ),
            1,
            null,
            'Order',
            (int) $order->id,
            true
        );

        return $order;
    }

    /* -----------------------------------------------------------------------
     * Étape 1 : Créer le client guest
     * -------------------------------------------------------------------- */

    private function createGuestCustomer(string $firstname, string $lastname): Customer
    {
        $customer = new Customer();

        // E-mail unique et imperceptible dans le front
        $uniqueHash = substr(bin2hex(random_bytes(8)), 0, 12);
        $email      = self::GUEST_EMAIL_PREFIX . $uniqueHash . self::GUEST_EMAIL_DOMAIN;

        $customer->firstname  = $this->sanitizeName($firstname);
        $customer->lastname   = $this->sanitizeName($lastname);
        $customer->email      = $email;
        $customer->passwd     = Tools::encrypt(bin2hex(random_bytes(16)));
        $customer->is_guest   = 1;
        $customer->active     = 1;
        $customer->id_default_group = (int) Configuration::get('PS_GUEST_GROUP');
        $customer->id_shop    = (int) $this->context->shop->id;
        $customer->id_lang    = (int) $this->context->language->id;

        // Groupe invité uniquement
        $customer->groupBox   = [(int) Configuration::get('PS_GUEST_GROUP')];

        if (!$customer->add()) {
            throw new \RuntimeException('Impossible de créer le client guest.');
        }

        return $customer;
    }

    /* -----------------------------------------------------------------------
     * Étape 2 : Créer l'adresse
     * -------------------------------------------------------------------- */

    /**
     * @param array<string, mixed> $data
     */
    private function createAddress(Customer $customer, array $data): Address
    {
        // Récupérer l'ID pays par défaut
        $idCountry = (int) Configuration::get('PS_COUNTRY_DEFAULT');

        $address = new Address();
        $address->id_customer = (int) $customer->id;
        $address->id_country  = $idCountry;
        $address->alias       = 'Commande rapide';
        $address->firstname   = $this->sanitizeName($data['firstname']);
        $address->lastname    = $this->sanitizeName($data['lastname']);
        $address->phone       = $this->sanitizePhone($data['phone']);
        $address->phone_mobile = $this->sanitizePhone($data['phone']);
        $address->address1    = pSQL($data['address1']);
        $address->city        = pSQL($data['city'] ?? 'N/A');
        $address->postcode    = pSQL($data['postcode'] ?? '00000');
        $address->active      = 1;
        $address->deleted     = 0;

        if (!$address->add()) {
            throw new \RuntimeException('Impossible de créer l\'adresse client.');
        }

        return $address;
    }

    /* -----------------------------------------------------------------------
     * Étape 3 : Créer le panier
     * -------------------------------------------------------------------- */

    /**
     * @param array<string, mixed> $data
     */
    private function createCart(Customer $customer, Address $address, array $data): Cart
    {
        $cart = new Cart();
        $cart->id_shop_group      = (int) $this->context->shop->id_shop_group;
        $cart->id_shop            = (int) $this->context->shop->id;
        $cart->id_lang            = (int) $this->context->language->id;
        $cart->id_currency        = (int) Configuration::get('PS_CURRENCY_DEFAULT');
        $cart->id_customer        = (int) $customer->id;
        $cart->id_guest           = 0;
        $cart->id_address_delivery = (int) $address->id;
        $cart->id_address_invoice  = (int) $address->id;
        $cart->secure_key         = md5(uniqid((string) rand(), true));
        $cart->allow_seperated_package = false;

        // Sélectionner automatiquement le premier transporteur disponible
        $cart->recyclable   = 0;
        $cart->gift         = 0;

        if (!$cart->add()) {
            throw new \RuntimeException('Impossible de créer le panier.');
        }

        // Mettre à jour le contexte
        $this->context->cart     = $cart;
        $this->context->customer = $customer;

        // Ajouter le produit — forcer l'autorisation hors stock pour QuickOrder
        // (le client commande même si le stock est épuisé, livraison à domicile)
        $previousOosp = Configuration::get('PS_ORDER_OUT_OF_STOCK');
        Configuration::updateValue('PS_ORDER_OUT_OF_STOCK', 1);

        // Forcer l'autorisation hors stock sur le produit lui-même
        $product = new Product((int) $data['id_product']);
        
        // Vérifier si le produit existe et est valide
        if (!\Validate::isLoadedObject($product)) {
            throw new \RuntimeException('Produit introuvable (ID: ' . $data['id_product'] . ').');
        }
        
        // Vérifier si le produit est actif
        if (!$product->active) {
            throw new \RuntimeException('Ce produit n\'est plus disponible.');
        }
        
        $previousProductOosp = $product->out_of_stock;
        if ($product->out_of_stock == 0) {
            $product->out_of_stock = 1;
            $product->save();
        }

        // Vérifier si la combinaison existe (si spécifiée)
        $idProductAttr = (int) $data['id_product_attr'];
        if ($idProductAttr > 0) {
            $combination = new \Combination($idProductAttr);
            if (!\Validate::isLoadedObject($combination)) {
                $idProductAttr = 0; // Utiliser le produit sans combinaison
            }
        }

        // Méthode alternative plus fiable pour ajouter le produit
        $cartProduct = [
            'id_product' => (int) $data['id_product'],
            'id_product_attribute' => $idProductAttr,
            'quantity' => (int) $data['qty'],
            'id_customization' => 0,
        ];

        // Essayer d'abord avec updateQty
        $added = $cart->updateQty(
            $data['qty'],
            (int) $data['id_product'],
            $idProductAttr ?: null,
            false,
            'up',
            0,
            new \Shop((int) $this->context->shop->id),
            true, // auto_add_cart_rule
            true  // skip_quantity_check - Ignorer la vérification de stock
        );

        // Si updateQty échoue, essayer avec la méthode directe
        if (!$added) {
            // Ajouter manuellement dans la table ps_cart_product
            $sql = 'INSERT INTO `' . _DB_PREFIX_ . 'cart_product` 
                    (`id_cart`, `id_product`, `id_product_attribute`, `id_shop`, `quantity`, `date_add`) 
                    VALUES 
                    (' . (int)$cart->id . ', ' . (int)$data['id_product'] . ', ' . (int)$idProductAttr . ', 
                     ' . (int)$this->context->shop->id . ', ' . (int)$data['qty'] . ', NOW())
                    ON DUPLICATE KEY UPDATE 
                    `quantity` = `quantity` + ' . (int)$data['qty'] . ', 
                    `date_add` = NOW()';
            
            $added = \Db::getInstance()->execute($sql);
            
            if ($added) {
                // Rafraîchir le cache du panier
                \Cache::clean('Cart::nbProducts_' . $cart->id . '*');
                \Cache::clean('objectmodel_Cart_' . $cart->id . '*');
            }
        }

        // Restaurer les valeurs d'origine
        Configuration::updateValue('PS_ORDER_OUT_OF_STOCK', $previousOosp);
        if ($previousProductOosp != $product->out_of_stock) {
            $product->out_of_stock = $previousProductOosp;
            $product->save();
        }

        if (!$added) {
            // Log détaillé pour déboguer
            $errorMsg = 'Impossible d\'ajouter le produit au panier. ';
            $errorMsg .= 'Produit ID: ' . $data['id_product'] . ', ';
            $errorMsg .= 'Combinaison: ' . ($idProductAttr ?: 'aucune') . ', ';
            $errorMsg .= 'Quantité: ' . $data['qty'] . ', ';
            $errorMsg .= 'Panier ID: ' . $cart->id . ', ';
            $errorMsg .= 'Produit actif: ' . ($product->active ? 'oui' : 'non') . ', ';
            $errorMsg .= 'Stock disponible: ' . \StockAvailable::getQuantityAvailableByProduct($data['id_product'], $idProductAttr);
            
            PrestaShopLogger::addLog(
                '[QuickOrder] ' . $errorMsg,
                3,
                null,
                'Cart',
                (int) $cart->id,
                true
            );
            
            throw new \RuntimeException($errorMsg);
        }

        // Attacher le transporteur par défaut
        $this->attachDefaultCarrier($cart);

        return $cart;
    }

    /**
     * Attache le premier transporteur disponible au panier.
     */
    private function attachDefaultCarrier(Cart $cart): void
    {
        $deliveryOptionList = $cart->getDeliveryOptionList();

        if (empty($deliveryOptionList)) {
            return;
        }

        // Prendre la première option de livraison disponible
        $deliveryOptions = [];
        foreach ($deliveryOptionList as $idAddress => $options) {
            $firstKey = !empty($options) ? array_keys($options)[0] : null;
            if ($firstKey !== null) {
                $deliveryOptions[$idAddress] = $firstKey;
            }
        }

        if (!empty($deliveryOptions)) {
            $cart->setDeliveryOption($deliveryOptions);
        }

        $cart->save();
    }

    /* -----------------------------------------------------------------------
     * Étape 4 : Valider le panier → Créer la commande
     * -------------------------------------------------------------------- */

    private function validateCart(Cart $cart, string $comment): Order
    {
        $codModuleName = Configuration::get(QuickOrderValidator::CONFIG_COD_MODULE ?? 'QUICKORDER_COD_MODULE');

        if (empty($codModuleName)) {
            $codModuleName = 'cod';
        }

        /** @var \PaymentModule|null $paymentModule */
        $paymentModule = Module::getInstanceByName($codModuleName);

        if (!$paymentModule || !$paymentModule->active) {
            throw new \RuntimeException(
                sprintf('Le module de paiement "%s" est introuvable ou inactif.', $codModuleName)
            );
        }

        // Calculer le total du panier
        $totalAmount = (float) $cart->getOrderTotal(true, Cart::BOTH);

        // Valider la commande via l'API PrestaShop
        $validated = $paymentModule->validateOrder(
            (int) $cart->id,
            (int) Configuration::get('PS_OS_PREPARATION'),   // Statut initial : En cours de préparation
            $totalAmount,
            $paymentModule->displayName,
            $comment ?: null,
            [],                        // extra vars pour l'email
            null,                      // id_currency (null = défaut)
            false,                     // don't use order payment
            $cart->secure_key
        );

        if (!$validated) {
            throw new \RuntimeException('La validation de la commande a échoué (validateOrder returned false).');
        }

        // Récupérer l'objet Order créé
        $idOrder = (int) Order::getIdByCartId((int) $cart->id);

        if (!$idOrder) {
            throw new \RuntimeException('Commande introuvable après validateOrder.');
        }

        $order = new Order($idOrder);

        if (!Validate::isLoadedObject($order)) {
            throw new \RuntimeException('Impossible de charger l\'objet Order.');
        }

        return $order;
    }

    /* -----------------------------------------------------------------------
     * Helpers sanitize
     * -------------------------------------------------------------------- */

    private function sanitizeName(string $value): string
    {
        // Nettoyer et valider le nom
        $cleaned = trim($value);
        
        // Si vide après trim, retourner un nom par défaut
        if (empty($cleaned)) {
            return 'Client';
        }
        
        // Supprimer les caractères non autorisés (garder lettres, espaces, tirets, apostrophes)
        $cleaned = preg_replace('/[^a-zA-Z\s\-\'àâäéèêëïîôöùûüÿçÀÂÄÉÈÊËÏÎÔÖÙÛÜŸÇ]/u', '', $cleaned);
        
        // Si vide après nettoyage, retourner un nom par défaut
        if (empty($cleaned)) {
            return 'Client';
        }
        
        // Limiter la longueur (max 32 caractères pour PrestaShop)
        $cleaned = mb_substr($cleaned, 0, 32);
        
        return pSQL(ucfirst(strtolower($cleaned)));
    }

    private function sanitizePhone(string $phone): string
    {
        // Conserver uniquement chiffres, +, espaces, tirets
        return preg_replace('/[^0-9+\s\-]/', '', $phone) ?? $phone;
    }
}
