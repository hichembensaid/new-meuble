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

{if isset($wishlists) && count($wishlists) > 1}
    <div class="line clearfix"></div>
    <div class="buttons_bottom_block no-print panel-product-w-custom">
    	<div id="wishlist_button">
            <span class="control-label">{l s='Wishlist' mod='blockwishlist'}</span>
    		<button class="wishlist_button_extra" onclick="WishlistCart('wishlist_block_list', 'add', '{$id_product|intval}', $('#idCombination').val(), document.getElementById('quantity_wanted').value, $('#idWishlist').val()); return false;"  title="{l s='Add to wishlist' mod='blockwishlist'}">
    			<i class="fa fa-heart-o"></i>{l s='Add to my wishlist' mod='blockwishlist'}
    		</button>
            <select id="idWishlist">
    			{foreach $wishlists as $wishlist}
    				<option value="{$wishlist.id_wishlist|escape:'html':'UTF-8'}">{$wishlist.name|escape:'html':'UTF-8'}</option>
    			{/foreach}
    		</select>
    	</div>
    </div>
{else}
    <div class="line clearfix line_wishlist"></div>
    <div class="panel-product-w-custom">
        <span class="control-label">{l s='Wishlist' mod='blockwishlist'}</span>
    	<a id="wishlist_button" href="#" onclick="WishlistCart('wishlist_block_list', 'add', '{$id_product|intval}', $('#idCombination').val(), document.getElementById('quantity_wanted').value); return false;" rel="nofollow"  title="{l s='Add to my wishlist' mod='blockwishlist'}">
    		<i class="fa fa-heart-o"></i>{l s='Add to wishlist' mod='blockwishlist'}
    	</a>
    </div>
{/if}
