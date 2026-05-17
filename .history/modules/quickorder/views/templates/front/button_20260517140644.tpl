{**
 * button.tpl - Bouton déclencheur uniquement
 * Copie exacte du style "Ajouter au panier" du thème Amazonas
 *}
<button
    type="button"
    class="btn btn-warning quickorder-btn"
    data-toggle="modal"
    data-target="#quickOrderModal"
    data-product-id="{$quickorder_product_id|intval}"
    data-product-name="{$quickorder_product_name|escape:'html':'UTF-8'}"
>
    <i class="fa fa-truck" aria-hidden="true"></i>
    {l s='Commander' mod='quickorder'}
</button>
