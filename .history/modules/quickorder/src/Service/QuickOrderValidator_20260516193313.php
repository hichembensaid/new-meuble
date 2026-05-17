<?php
/**
 * QuickOrderValidator – Validation des données du formulaire
 *
 * Compatible PrestaShop 8 / PHP 8.2
 */

declare(strict_types=1);

namespace QuickOrder\Service;

use Symfony\Component\Translation\TranslatorInterface;

class QuickOrderValidator
{
    /** Clé de configuration du module COD (partagée avec QuickOrderService) */
    public const CONFIG_COD_MODULE = 'QUICKORDER_COD_MODULE';

    /** @var TranslatorInterface|null */
    private $translator;

    public function __construct(
        ?TranslatorInterface $translator = null
    ) {
        $this->translator = $translator;
    }

    /**
     * Valide les données du formulaire.
     *
     * @param array<string, mixed> $data
     *
     * @return string[] Liste d'erreurs (vide si tout est valide)
     */
    public function validate(array $data): array
    {
        $errors = [];

        // Produit
        if (empty($data['id_product']) || $data['id_product'] <= 0) {
            $errors[] = $this->t('Produit invalide.');
        }

        // Prénom
        if (empty($data['firstname']) || mb_strlen($data['firstname']) < 2) {
            $errors[] = $this->t('Le prénom est requis (2 caractères minimum).');
        } elseif (mb_strlen($data['firstname']) > 32) {
            $errors[] = $this->t('Le prénom ne peut pas dépasser 32 caractères.');
        }

        // Nom
        if (empty($data['lastname']) || mb_strlen($data['lastname']) < 2) {
            $errors[] = $this->t('Le nom est requis (2 caractères minimum).');
        } elseif (mb_strlen($data['lastname']) > 32) {
            $errors[] = $this->t('Le nom ne peut pas dépasser 32 caractères.');
        }

        // Téléphone : au moins 8 chiffres
        if (empty($data['phone'])) {
            $errors[] = $this->t('Le numéro de téléphone est requis.');
        } elseif (!preg_match('/^[0-9+\s\-]{8,20}$/', $data['phone'])) {
            $errors[] = $this->t('Le numéro de téléphone n\'est pas valide.');
        }

        // Adresse
        if (empty($data['address1']) || mb_strlen($data['address1']) < 5) {
            $errors[] = $this->t('L\'adresse est requise (5 caractères minimum).');
        } elseif (mb_strlen($data['address1']) > 128) {
            $errors[] = $this->t('L\'adresse ne peut pas dépasser 128 caractères.');
        }

        // Commentaire (optionnel mais limité)
        if (!empty($data['comment']) && mb_strlen($data['comment']) > 500) {
            $errors[] = $this->t('Le commentaire ne peut pas dépasser 500 caractères.');
        }

        return $errors;
    }

    private function t(string $message): string
    {
        if ($this->translator !== null) {
            return $this->translator->trans($message, [], 'Modules.Quickorder.Front');
        }

        return $message;
    }
}
