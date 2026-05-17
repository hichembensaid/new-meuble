{**
 * button.tpl - Bouton déclencheur uniquement
 * Le modal est injecté dans hookDisplayFooter (hors zone AJAX du thème)
 *
 * Variables :
 *   - {$quickorder_product_id}
 *   - {$quickorder_product_name}
 *}
<button
    type="button"
    class="btn btn-primary quickorder-btn"
    data-toggle="modal"
    data-target="#quickOrderModal"
    data-product-id="{$quickorder_product_id|intval}"
    data-product-name="{$quickorder_product_name|escape:'html':'UTF-8'}"
    aria-label="{l s='Commander rapidement - paiement à la livraison' mod='quickorder'}"
>
    <i class="fa fa-truck" aria-hidden="true"></i>
    {l s='Commander rapidement' mod='quickorder'}
</button>
