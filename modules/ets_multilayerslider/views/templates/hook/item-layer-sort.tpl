{*
* 2007-2022 ETS-Soft
*
* NOTICE OF LICENSE
*
* This file is not open source! Each license that you purchased is only available for 1 wesite only.
* If you want to use this file on more websites (or projects), you need to purchase additional licenses.
* You are not allowed to redistribute, resell, lease, license, sub-license or offer our resources to any third party.
*
* DISCLAIMER
*
* Do not edit or add to this file if you wish to upgrade PrestaShop to newer
* versions in the future. If you wish to customize PrestaShop for your
* needs, please contact us for extra customization service at an affordable price
*
*  @author ETS-Soft <etssoft.jsc@gmail.com>
*  @copyright  2007-2022 ETS-Soft
*  @license    Valid for 1 website (or project) for each purchase of license
*  International Registered Trademark & Property of ETS-Soft
*}
{if isset($layer) && $layer}
    <li data-id-layer="{$layer.id_layer|intval}" class="mls_layers_li item{$layer.id_layer|intval}" data-obj="layer">
        {if $layer.layer_type=='image'}
            <img src="{$layer.link_image|escape:'html':'UTF-8'}" width="40px" />
        {elseif $layer.content_layer|strip_tags|trim|escape:'html':'UTF-8'}
            {$layer.content_layer|strip_tags|truncate:25:"..."|escape:'html':'UTF-8'}
        {else}
            #{$layer.id_layer|intval}
        {/if}
        <span data-title="&#xE14D;" class="mls_layer_duplicate" title="{l s='Duplicate this layer' mod='ets_multilayerslider'}">{l s='Duplicate' mod='ets_multilayerslider'}</span>
        <span data-title="&#xE872;" class="mls_layer_delete" title="{l s='Delete this layer' mod='ets_multilayerslider'}">{l s='Delete' mod='ets_multilayerslider'}</span>
        <span data-title="&#xE150;" class="mls_layer_edit" title="{l s='Edit this layer' mod='ets_multilayerslider'}">{l s='Edit' mod='ets_multilayerslider'}</span>
    </li>
{/if}