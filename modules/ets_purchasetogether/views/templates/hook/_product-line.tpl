{*
* 2007-2015 PrestaShop
*
* NOTICE OF LICENSE
*
* This source file is subject to the Academic Free License (AFL 3.0)
* that is bundled with this package in the file LICENSE.txt.
* It is also available through the world-wide-web at this URL:
* http://opensource.org/licenses/afl-3.0.php
* If you did not receive a copy of the license and are unable to
* obtain it through the world-wide-web, please send an email
* to license@prestashop.com so we can send you a copy immediately.
*
* DISCLAIMER
*
* Do not edit or add to this file if you wish to upgrade PrestaShop to newer
* versions in the future. If you wish to customize PrestaShop for your
* needs please refer to http://www.prestashop.com for more information.
*
*  @author PrestaShop SA <contact@prestashop.com>
*  @copyright  2007-2017 PrestaShop SA
*  @license    http://opensource.org/licenses/afl-3.0.php  Academic Free License (AFL 3.0)
*  International Registered Trademark & Property of PrestaShop SA
*}

<span class="product-quantity">{$product.quantity|intval}</span>
<span class="product-name">{$product.name|escape:'html':'UTF-8'}</span>
<span class="product-price">{$product.price|floatval}</span>
<a  class="remove-from-cart"
    rel="nofollow"
    href="{$product.remove_from_cart_url|escape:'html':'UTF-8'}"
    data-link-action="remove-from-cart"
    title="{l s='remove from cart' mod='ets_purchasetogether'}"
>
    {l s='Remove' mod='ets_purchasetogether'}
</a>
{if $product.customizations|count}
    <div class="customizations">
        <ul>
            {foreach from=$product.customizations item='customization'}
                <li>
                    <span class="product-quantity">{$customization.quantity|intval}</span>
                    <a href="{$customization.remove_from_cart_url|escape:'html':'UTF-8'}" title="{l s='remove from cart' mod='ets_purchasetogether'}" class="remove-from-cart" rel="nofollow">{l s='Remove' mod='ets_purchasetogether'}</a>
                    <ul>
                        {foreach from=$customization.fields item='field'}
                            <li>
                                <span>{$field.label|escape:'html':'UTF-8'}</span>
                                {if $field.type == 'text'}
                                    <span>{$field.text nofilter}</span>
                                {else if $field.type == 'image'}
                                    <img src="{$field.image.small.url|escape:'html':'UTF-8'}">
                                {/if}
                            </li>
                        {/foreach}
                    </ul>
                </li>
            {/foreach}
        </ul>
    </div>
{/if}
