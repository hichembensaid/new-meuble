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

<div id="wishlist_block" class="block account">
	<h4 class="title_block">
		<a href="{$link->getModuleLink('blockwishlist', 'mywishlist', array(), true)|addslashes}" title="{l s='My wishlists' mod='blockwishlist'}" rel="nofollow">{l s='Wishlist' mod='blockwishlist'}</a>
	</h4>
	<div class="block_content">
		<div id="wishlist_block_list" class="expanded">
		{if $wishlist_products}
			<dl class="products">
			{foreach from=$wishlist_products item=product name=i}
				<dt class="{if $smarty.foreach.i.first}first_item{elseif $smarty.foreach.i.last}last_item{else}item{/if}">
					<span class="quantity-formated"><span class="quantity">{$product.quantity|intval}</span>x</span>
					<a class="cart_block_product_name"
					href="{$link->getProductLink($product.id_product, $product.link_rewrite, $product.category_rewrite)|escape:'html'}" title="{$product.name|escape:'html':'UTF-8'}">{$product.name|truncate:30:'...'|escape:'html':'UTF-8'}</a>
					<a class="ajax_cart_block_remove_link" href="javascript:;" onclick="javascript:WishlistCart('wishlist_block_list', 'delete', '{$product.id_product|escape:'html':'UTF-8'}', {$product.id_product_attribute|escape:'html':'UTF-8'}, '0', '{if isset($token)}{$token|escape:'html':'UTF-8'}{/if}');" title="{l s='remove this product from my wishlist' mod='blockwishlist'}" rel="nofollow"><img src="{$img_dir|escape:'html':'UTF-8'}icon/delete.gif" width="12" height="12" alt="{l s='Delete'}" class="icon" /></a>
				</dt>
				{if isset($product.attributes_small)}
				<dd class="{if $smarty.foreach.i.first}first_item{elseif $smarty.foreach.i.last}last_item{else}item{/if}">
					<a href="{$link->getProductLink($product.id_product, $product.link_rewrite, $product.category_rewrite)|escape:'html'}" title="{l s='Product detail'}">{$product.attributes_small|escape:'html':'UTF-8'}</a>
				</dd>
				{/if}
			{/foreach}
			</dl>
		{else}
			<dl class="products">
				<dt>{l s='No products' mod='blockwishlist'}</dt>
			</dl>
		{/if}
		</div>
		<p class="lnk">
		{if $wishlists}
			<select name="wishlists" id="wishlists" onchange="WishlistChangeDefault('wishlist_block_list', $('#wishlists').val());">
			{foreach from=$wishlists item=wishlist name=i}
				<option value="{$wishlist.id_wishlist|escape:'html':'UTF-8'}"{if $id_wishlist eq $wishlist.id_wishlist or ($id_wishlist == false and $smarty.foreach.i.first)} selected="selected"{/if}>{$wishlist.name|truncate:22:'...'|escape:'html':'UTF-8'}</option>
			{/foreach}
			</select>
		{/if}
			<a href="{$link->getModuleLink('blockwishlist', 'mywishlist', array(), true)|addslashes}" title="{l s='My wishlists' mod='blockwishlist'}" rel="nofollow">&raquo; {l s='My wishlists' mod='blockwishlist'}</a>
		</p>
	</div>
</div>
