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

{if !$PS_CATALOG_MODE}
	<div id="layer_cart_purchase" style="display:none">
        <div class="layer_cart_purchase_content">
		<div class="clearfix">
			<div class="layer_cart_product col-xs-12 col-md-6">
				<span class="cross" title="{l s='Close window' mod='ets_purchasetogether'}"></span>
				<span class="title">
					<i class="icon-check"></i>{l s='Product successfully added to your shopping cart' mod='ets_purchasetogether'}
				</span>
                <div id="product_list"></div>
			</div>
			<div class="layer_cart_cart col-xs-12 col-md-6">
				<span class="title">
					<!-- Plural Case [both cases are needed because page may be updated in Javascript] -->
					<span class="ajax_cart_product_txt_s {if $cart_qties < 2} unvisible{/if}">
						{l s='There are [1]%d[/1] items in your cart.' mod='ets_purchasetogether' sprintf=[$cart_qties] tags=['<span class="ajax_cart_quantity">']}
					</span>
					<!-- Singular Case [both cases are needed because page may be updated in Javascript] -->
					<span class="ajax_cart_product_txt {if $cart_qties > 1} unvisible{/if}">
						{l s='There is 1 item in your cart.' mod='ets_purchasetogether'}
					</span>
				</span>
				<div class="layer_cart_row">
					<strong class="dark">
						{l s='Total products' mod='ets_purchasetogether'}
						{if $use_taxes && $display_tax_label && $show_tax}
							{if $priceDisplay == 1}
								{l s='(tax excl.)' mod='ets_purchasetogether'}
							{else}
								{l s='(tax incl.)' mod='ets_purchasetogether'}
							{/if}
						{/if}
					</strong>
					<span class="ajax_block_products_total">
						{if $cart_qties > 0}
							{convertPrice price=$cart->getOrderTotal(false, Cart::ONLY_PRODUCTS)}
						{/if}
					</span>
				</div>

				{if $show_wrapping}
					<div class="layer_cart_row">
						<strong class="dark">
							{l s='Wrapping' mod='ets_purchasetogether'}
							{if $use_taxes && $display_tax_label && $show_tax}
								{if $priceDisplay == 1}
									{l s='(tax excl.)' mod='ets_purchasetogether'}
								{else}
									{l s='(tax incl.)' mod='ets_purchasetogether'}
								{/if}
							{/if}
						</strong>
						<span class="price cart_block_wrapping_cost">
							{if $priceDisplay == 1}
								{convertPrice price=$cart->getOrderTotal(false, Cart::ONLY_WRAPPING)}
							{else}
								{convertPrice price=$cart->getOrderTotal(true, Cart::ONLY_WRAPPING)}
							{/if}
						</span>
					</div>
				{/if}
				<div class="layer_cart_row">
					<strong class="dark{if $shipping_cost_float == 0 && (!$cart_qties || $cart->isVirtualCart() || !isset($cart->id_address_delivery) || !$cart->id_address_delivery)} unvisible{/if}">
						{l s='Total shipping' mod='ets_purchasetogether'}&nbsp;{if $use_taxes && $display_tax_label && $show_tax}{if $priceDisplay == 1}{l s='(tax excl.)' mod='ets_purchasetogether'}{else}{l s='(tax incl.)' mod='ets_purchasetogether'}{/if}{/if}
					</strong>
					<span class="ajax_cart_shipping_cost{if $shipping_cost_float == 0 && (!$cart_qties || $cart->isVirtualCart() || !isset($cart->id_address_delivery) || !$cart->id_address_delivery)} unvisible{/if}">
						{if $shipping_cost_float == 0}
							 {if (!isset($cart->id_address_delivery) || !$cart->id_address_delivery)}{l s='To be determined' mod='ets_purchasetogether'}{else}{l s='Free shipping!' mod='ets_purchasetogether'}{/if}
						{else}
							{$shipping_cost|escape:'html':'UTF-8'}
						{/if}
					</span>
				</div>
				{if $show_tax && isset($tax_cost)}
					<div class="layer_cart_row">
						<strong class="dark">{l s='Tax' mod='ets_purchasetogether'}</strong>
						<span class="price cart_block_tax_cost ajax_cart_tax_cost">{$tax_cost|escape:'html':'UTF-8'}</span>
					</div>
				{/if}
				<div class="layer_cart_row">
					<strong class="dark">
						{l s='Total' mod='ets_purchasetogether'}
						{if $use_taxes && $display_tax_label && $show_tax}
							{if $priceDisplay == 1}
								{l s='(tax excl.)' mod='ets_purchasetogether'}
							{else}
								{l s='(tax incl.)' mod='ets_purchasetogether'}
							{/if}
						{/if}
					</strong>
					<span class="ajax_block_cart_total">
						{if $cart_qties > 0}
							{if $priceDisplay == 1}
								{convertPrice price=$cart->getOrderTotal(false)}
							{else}
								{convertPrice price=$cart->getOrderTotal(true)}
							{/if}
						{/if}
					</span>
				</div>
				<div class="button-container">
					<span class="continue btn btn-default button exclusive-medium btn-continue" title="{l s='Continue shopping' mod='ets_purchasetogether'}">
						<span>
							<i class="icon-chevron-left left"></i>{l s='Continue shopping' mod='ets_purchasetogether'}
						</span>
					</span>
					<a class="btn btn-default button button-medium"	href="{$link->getPageLink("$order_process", true)|escape:"html":"UTF-8"}" title="{l s='Proceed to checkout' mod='ets_purchasetogether'}" rel="nofollow">
						<span>
							{l s='Proceed to checkout' mod='ets_purchasetogether'}<i class="icon-chevron-right right"></i>
						</span>
					</a>
				</div>
			</div>
		</div>
		{*}<div class="crossseling"></div>
        </div>{*}
	</div> <!-- #layer_cart -->
	<div class="layer_cart_overlay"></div>
{/if}
