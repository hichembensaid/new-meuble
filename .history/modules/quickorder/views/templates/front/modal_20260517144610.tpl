{**
 * modal.tpl - Modal uniquement (sans bouton)
 * Injecté via hookDisplayFooter, hors zone AJAX du thème.
 *
 * Variables injectées :
 *   - {$quickorder_ajax_url}
 *   - {$quickorder_token}
 *}

{* ── Modal Bootstrap ────────────────────────────────────────────────────── *}
<div
    class="modal fade"
    id="quickOrderModal"
    tabindex="-1"
    role="dialog"
    aria-labelledby="quickOrderModalTitle"
    aria-modal="true"
>
    <div class="modal-dialog modal-dialog-centered" role="document">
        <div class="modal-content">

            {* En-tête *}
            <div class="modal-header quickorder-modal__header">
                <h5 class="modal-title quickorder-modal__title" id="quickOrderModalTitle">
                    <i class="material-icons quickorder-modal__icon" aria-hidden="true">&#xe558;</i>
                    {l s='Commande Rapide' mod='quickorder'}
                </h5>
                <p class="quickorder-modal__subtitle">
                    {l s='Livraison et paiement à domicile – aucun compte requis' mod='quickorder'}
                </p>
                <button
                    type="button"
                    class="close quickorder-modal__close"
                    data-dismiss="modal"
                    aria-label="{l s='Fermer' mod='quickorder'}"
                >
                    <span aria-hidden="true">&times;</span>
                </button>
            </div>

            {* Corps : formulaire *}
            <div class="modal-body">

                {* Résumé produit *}
                <div class="quickorder-product-summary alert alert-info" role="status" aria-live="polite">
                    <strong>{l s='Produit :' mod='quickorder'}</strong>
                    <span id="qo-product-name">{$quickorder_product_name|escape:'html':'UTF-8'}</span>
                </div>

                {* Message d'alerte (erreur / succès) *}
                <div id="qo-alert" class="alert" style="display:none" role="alert" aria-live="assertive"></div>

                {* Formulaire principal *}
                <form
                    id="quickOrderForm"
                    novalidate
                    data-ajax-url="{$quickorder_ajax_url|escape:'html':'UTF-8'}"
                    data-token="{$quickorder_token|escape:'html':'UTF-8'}"
                    data-product-id="{if isset($quickorder_product_id)}{$quickorder_product_id|intval}{else}0{/if}"
                    data-product-attr="0"
                    data-qty="1"
                >
                    <div class="row">
                        {* Prénom *}
                        <div class="col-sm-6 form-group">
                            <label for="qo-firstname" class="form-control-label">
                                {l s='Prénom' mod='quickorder'} <span class="required" aria-hidden="true">*</span>
                            </label>
                            <input
                                type="text"
                                id="qo-firstname"
                                name="firstname"
                                class="form-control"
                                autocomplete="given-name"
                                maxlength="32"
                                required
                                placeholder="{l s='Votre prénom' mod='quickorder'}"
                                aria-required="true"
                            >
                            <div class="invalid-feedback"></div>
                        </div>

                        {* Nom *}
                        <div class="col-sm-6 form-group">
                            <label for="qo-lastname" class="form-control-label">
                                {l s='Nom' mod='quickorder'} <span class="required" aria-hidden="true">*</span>
                            </label>
                            <input
                                type="text"
                                id="qo-lastname"
                                name="lastname"
                                class="form-control"
                                autocomplete="family-name"
                                maxlength="32"
                                required
                                placeholder="{l s='Votre nom' mod='quickorder'}"
                                aria-required="true"
                            >
                            <div class="invalid-feedback"></div>
                        </div>
                    </div>{* /.row *}

                    {* Téléphone *}
                    <div class="form-group">
                        <label for="qo-phone" class="form-control-label">
                            {l s='Téléphone' mod='quickorder'} <span class="required" aria-hidden="true">*</span>
                        </label>
                        <input
                            type="tel"
                            id="qo-phone"
                            name="phone"
                            class="form-control"
                            autocomplete="tel"
                            maxlength="20"
                            required
                            placeholder="{l s='Ex : 06 12 34 56 78' mod='quickorder'}"
                            aria-required="true"
                        >
                        <div class="invalid-feedback"></div>
                    </div>

                    {* Adresse *}
                    <div class="form-group">
                        <label for="qo-address" class="form-control-label">
                            {l s='Adresse de livraison' mod='quickorder'} <span class="required" aria-hidden="true">*</span>
                        </label>
                        <input
                            type="text"
                            id="qo-address"
                            name="address1"
                            class="form-control"
                            autocomplete="street-address"
                            maxlength="128"
                            required
                            placeholder="{l s='Numéro et nom de rue' mod='quickorder'}"
                            aria-required="true"
                        >
                        <div class="invalid-feedback"></div>
                    </div>

                    <div class="row">
                        {* Ville *}
                        <div class="col-sm-7 form-group">
                            <label for="qo-city" class="form-control-label">
                                {l s='Ville' mod='quickorder'} <span class="required" aria-hidden="true">*</span>
                            </label>
                            <input
                                type="text"
                                id="qo-city"
                                name="city"
                                class="form-control"
                                autocomplete="address-level2"
                                maxlength="64"
                                required
                                placeholder="{l s='Votre ville' mod='quickorder'}"
                                aria-required="true"
                            >
                            <div class="invalid-feedback"></div>
                        </div>

                        {* Code postal *}
                        <div class="col-sm-5 form-group">
                            <label for="qo-postcode" class="form-control-label">
                                {l s='Code postal' mod='quickorder'} <span class="required" aria-hidden="true">*</span>
                            </label>
                            <input
                                type="text"
                                id="qo-postcode"
                                name="postcode"
                                class="form-control"
                                autocomplete="postal-code"
                                maxlength="10"
                                required
                                placeholder="{l s='Ex : 75001' mod='quickorder'}"
                                aria-required="true"
                            >
                            <div class="invalid-feedback"></div>
                        </div>
                    </div>{* /.row *}

                    {* Commentaire *}
                    <div class="form-group">
                        <label for="qo-comment" class="form-control-label">
                            {l s='Commentaire (optionnel)' mod='quickorder'}
                        </label>
                        <textarea
                            id="qo-comment"
                            name="comment"
                            class="form-control"
                            rows="3"
                            maxlength="500"
                            placeholder="{l s='Informations complémentaires pour la livraison…' mod='quickorder'}"
                        ></textarea>
                    </div>

                    {* Mention RGPD *}
                    <p class="quickorder-rgpd text-muted small">
                        <i class="material-icons small" aria-hidden="true">&#xe88e;</i>
                        {l s='Vos données sont utilisées uniquement pour traiter votre commande.' mod='quickorder'}
                    </p>

                </form>{* /#quickOrderForm *}
            </div>{* /.modal-body *}

            {* Pied de modal *}
            <div class="modal-footer quickorder-modal__footer">
                <button
                    type="button"
                    class="btn btn-outline-secondary"
                    data-dismiss="modal"
                >
                    {l s='Annuler' mod='quickorder'}
                </button>
                <button
                    type="button"
                    id="qo-submit"
                    class="btn btn-warning quickorder-submit"
                >
                    <span class="qo-submit__label">
                        <i class="material-icons small" aria-hidden="true">&#xe558;</i>
                        {l s='Confirmer ma commande' mod='quickorder'}
                    </span>
                    <span class="qo-submit__loading" style="display:none" aria-hidden="true">
                        <span class="spinner-border spinner-border-sm" role="status"></span>
                        {l s='Envoi en cours…' mod='quickorder'}
                    </span>
                </button>
            </div>{* /.modal-footer *}

        </div>{* /.modal-content *}
    </div>{* /.modal-dialog *}
</div>{* /#quickOrderModal *}
