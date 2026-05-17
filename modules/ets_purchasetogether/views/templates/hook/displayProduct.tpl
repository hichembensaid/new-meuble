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

{if isset($combinations) && $combinations && isset($purchase_togethers) && $purchase_togethers && count($purchase_togethers) != $alldisabled}
<script type="text/javascript">
var pc_ets_attribute_small=[], pc_ets_image=[], pc_ets_price=[], pc_ets_old_price=[], pc_ets_reduction=[];
{foreach from=$combinations item=combination}
pc_ets_attribute_small[{$combination.id_product_attribute|intval}] = '{$combination.attribute_small|escape:'html':'UTF-8'}';
pc_ets_image[{$combination.id_product_attribute|intval}] = '{$link->getImageLink($combination.link_rewrite, $combination.id_image, 'home_default')|escape:'html':'UTF-8'}';
pc_ets_price[{$combination.id_product_attribute|intval}] = '{convertPrice price=$combination.price}';
pc_ets_old_price[{$combination.id_product_attribute|intval}] = '{if isset($combination.price_without_reduction) && $combination.price_without_reduction}{displayWtPrice p=$combination.price_without_reduction}{else}0{/if}';
pc_ets_reduction[{$combination.id_product_attribute|intval}] = '{if isset($combination.specific_prices.reduction_type) && $combination.specific_prices.reduction_type}-{$combination.specific_prices.reduction * 100|floatval}%{else}0{/if}';
{/foreach}
</script>
{/if}
{if isset($configs.ETS_PT_HOOK_TO) && $configs.ETS_PT_HOOK_TO == 'displayFooterProduct'}
    <div id="ets_purchasetogether" class="ets_purchase_footerproduct">
{else if isset($configs.ETS_PT_HOOK_TO) && $configs.ETS_PT_HOOK_TO == 'displayProductAdditionalInfo'}
    <div id="ets_purchasetogether" class="ets_purchase_productaddition">
{else}
    <div id="ets_purchasetogether" class="ets_purchase_centercolumn">
{/if}
{if isset($configs.ETS_PT_DISPLAY_TYPE) && $configs.ETS_PT_DISPLAY_TYPE == 1}
    {if isset($purchase_togethers) && $purchase_togethers && count($purchase_togethers) != $alldisabled}
        <h2 class="ets_purchase_title">{$configs.ETS_PT_TITLE|escape:'html':'UTF-8'}</h2>
        <ul class="ets-list-purchase-together ets-list-purchase-type-grid">
            {foreach from=$purchase_togethers item=product}
                {if isset($product.disabled) && !$product.disabled}
                    <li class="ajax_block_product actived" data-id-product="{$product.id_product|intval}" data-id-product-attribute="{$product.id_product_attribute|intval}">
            			<div class="product-container" itemscope itemtype="https://schema.org/Product">
            				<div class="left-block">
            					<div class="product-image-container">
                                    <div class="product-image-container">
                						<a class="product_img_link" href="{$product.link|escape:'html':'UTF-8'}" title="{$product.name_attribute|escape:'html':'UTF-8'}" itemprop="url">
                							<img class="replace-2x img-responsive" src="{$link->getImageLink($product.link_rewrite, $product.id_image, 'home_default')|escape:'html':'UTF-8'}" alt="{if !empty($product.legend)}{$product.legend|escape:'html':'UTF-8'}{else}{$product.name_attribute|escape:'html':'UTF-8'}{/if}" title="{if !empty($product.legend)}{$product.legend|escape:'html':'UTF-8'}{else}{$product.name_attribute|escape:'html':'UTF-8'}{/if}" {if isset($homeSize)} width="{$homeSize.width|escape:'html':'UTF-8'}" height="{$homeSize.height|escape:'html':'UTF-8'}"{/if} itemprop="image" />
                						</a>
                                    </div>
            					</div>
            				</div>
                            <div class="right-block">
            					<h5 itemprop="name">
            						<a class="product-name" href="{$product.link|escape:'html':'UTF-8'}" title="{$product.name_attribute|escape:'html':'UTF-8'}" itemprop="url" >
            							{$product.name_attribute|truncate:45:'...'|escape:'html':'UTF-8'}
            						</a>
            					</h5>
                            </div>
            			</div>
                        <!-- .product-container> -->
            		</li>
                {/if}
            {/foreach}
        </ul>
        <div class="clear"></div>
        <ul class="ets-list-checkbox-product ets-list-checkbox-type-grid">
            {*Display current product*}
            {if (isset($configs.ETS_PT_EXCLUDE_CURRENT_PRODUCT) && !$configs.ETS_PT_EXCLUDE_CURRENT_PRODUCT) 
                && !(isset($configs.ETS_PT_EXCLUDE_OUT_OF_STOCK) && $configs.ETS_PT_EXCLUDE_OUT_OF_STOCK && $quantity_available <= 0)}
                <li class="item-product this-product">
                    <div class="row-product">
                    <div class="ets_purchase_item_image">
                        <input class="{if isset($configs.ETS_PT_REQUIRE_CURRENT_PRODUCT) && $configs.ETS_PT_REQUIRE_CURRENT_PRODUCT}required{/if}"
                            id="product_{$currProduct.id_product|intval}_{$currProduct.id_product_attribute|intval}"
                            type="checkbox" 
                            checked="checked" 
                            name="product_current" />
                    </div>
                    <div class="ets_purchase_item_des ets-list-purchase-type-grid">
                        <label for="">{*product_{$currProduct.id_product|intval}_{$currProduct.id_product_attribute|intval}*}
                            <a class="product-name product-name-checkbox">
                                {l s='This current product' mod='ets_purchasetogether'} ({$currProduct.name|escape:'html':'UTF-8'})
                            </a>
                        </label>
                        <div class="price">
                			{if !isset($restricted_country_mode) && isset($configs.ETS_PT_DISPLAY_PRODUCT_PRICE) && $configs.ETS_PT_DISPLAY_PRODUCT_PRICE}
        						<span itemprop="price" class="price product-price">
        							{hook h="displayProductPriceBlock" product=$currProduct type="before_price"}
                                    {if !$priceDisplay}{convertPrice price=$currProduct.price}{else}{convertPrice price=$currProduct.price_tax_exc}{/if}
        						</span>
        						<meta itemprop="priceCurrency" content="{$currency->iso_code|escape:'html':'UTF-8'}" />
        						{if $currProduct.price_without_reduction > 0 && isset($currProduct.specific_prices) && $currProduct.specific_prices && isset($currProduct.specific_prices.reduction) && $currProduct.specific_prices.reduction > 0}
        							{if isset($configs.ETS_PT_DISPLAY_OLD_PRICE) && $configs.ETS_PT_DISPLAY_OLD_PRICE}
                                        {hook h="displayProductPriceBlock" product=$currProduct type="old_price"}
        								<span class="old-price product-price">
        									{displayWtPrice p=$currProduct.price_without_reduction}
        								</span>
                                    {/if}
                            		{if $currProduct.specific_prices.reduction_type == 'percentage' && isset($configs.ETS_PT_DISPLAY_DISCOUNT) && $configs.ETS_PT_DISPLAY_DISCOUNT}
        								<span class="price-percent-reduction">-{$currProduct.specific_prices.reduction * 100|floatval}%</span>
        							{/if}
        						{/if}
        					{/if}
                        </div>
                        <div class="description">
                            {if isset($configs.ETS_PT_DISPLAY_PRODUCT_DESCRIPTION) && $configs.ETS_PT_DISPLAY_PRODUCT_DESCRIPTION}
                                <div  class="">{if isset($currProduct.description_short) && $currProduct.description_short}{$currProduct.description_short|truncate:$configs.ETS_PT_MAX_DESCRIPTION_LENGHT:'...'}
                                    {else}{$currProduct.description|truncate:$configs.ETS_PT_MAX_DESCRIPTION_LENGHT:'...'}{/if}</div>
                            {/if} 
                        </div>
                        {if isset($configs.ETS_PT_DISPLAY_RATING) && $configs.ETS_PT_DISPLAY_RATING}
                            <div class="hook-reviews">
                                {hook h='displayProductListReviews' product=$currProduct}
                            </div>
                        {/if}
                    </div>
                    </div>                    
                </li>
            {/if}
            {foreach from=$purchase_togethers item=product}
                {if isset($product.disabled) && !$product.disabled}
                    <li class="item-product">
                        <div class="row-product">
                            <div class="ets_purchase_item_image">
                                <input type="checkbox" class=""
                                    checked="checked"
                                    data-id="{$product.id_product|intval}"
                                    data-attribute="{$product.id_product_attribute|intval}"
                                    data-qty="{if isset($configs.ETS_PT_DEFAULT_QUANTITY_ADDED_TO_CART) && $configs.ETS_PT_DEFAULT_QUANTITY_ADDED_TO_CART}{$configs.ETS_PT_DEFAULT_QUANTITY_ADDED_TO_CART|intval}{else}1{/if}"
                                    id="purchase_{$product.id_product|intval}_{$product.id_product_attribute|intval}" 
                                    name="purchase_together[]" />
                            </div>
                            <div class="ets_purchase_item_des">
                                <label for="purchase_{$product.id_product|intval}_{$product.id_product_attribute|intval}">
                                    <a class="product-name product-name-checkbox" href="{$product.link|escape:'html':'UTF-8'}" title="{$product.name_attribute|escape:'html':'UTF-8'}" itemprop="url" >
                						{$product.name_attribute|truncate:45:'...'|escape:'html':'UTF-8'}
                					</a>
                                </label>
                                <span class="price">
                        			{if isset($product.show_price) && $product.show_price && !isset($restricted_country_mode) && isset($configs.ETS_PT_DISPLAY_PRODUCT_PRICE) && $configs.ETS_PT_DISPLAY_PRODUCT_PRICE}
            							<span itemprop="price" class="price product-price">
            								{hook h="displayProductPriceBlock" product=$product type="before_price"}
                                            {if !$priceDisplay}{convertPrice price=$product.price}{else}{convertPrice price=$product.price_tax_exc}{/if}
            							</span>
            							<meta itemprop="priceCurrency" content="{$currency->iso_code|escape:'html':'UTF-8'}" />
            							{if $product.price_without_reduction > 0 && isset($product.specific_prices) && $product.specific_prices && isset($product.specific_prices.reduction) && $product.specific_prices.reduction > 0}
            								{if isset($configs.ETS_PT_DISPLAY_OLD_PRICE) && $configs.ETS_PT_DISPLAY_OLD_PRICE}
                                                {hook h="displayProductPriceBlock" product=$product type="old_price"}
                								<span class="old-price product-price">
                									{displayWtPrice p=$product.price_without_reduction}
                								</span>
                                            {/if}
                                    		{if $product.specific_prices.reduction_type == 'percentage' && isset($configs.ETS_PT_DISPLAY_DISCOUNT) && $configs.ETS_PT_DISPLAY_DISCOUNT}
            									<span class="price-percent-reduction">-{$product.specific_prices.reduction * 100|floatval}%</span>
            								{/if}
            							{/if}
            						{/if}
                                </span>
                                <p class="attribute-small">{if isset($product.attribute_small) && $product.attribute_small}{$product.attribute_small|escape:'html':'UTF-8'}{/if}</p>  
                                
                                <div class="description">
                                    {if isset($configs.ETS_PT_DISPLAY_PRODUCT_DESCRIPTION) && $configs.ETS_PT_DISPLAY_PRODUCT_DESCRIPTION}
                                        <div  class="">{if isset($product.description_short) && $product.description_short}{$product.description_short|truncate:$configs.ETS_PT_MAX_DESCRIPTION_LENGHT:'...' nofilter}
                                            {else}{$product.description|truncate:$configs.ETS_PT_MAX_DESCRIPTION_LENGHT:'...' nofilter}{/if}</div>
                                    {/if} 
                                </div>
                                {if isset($configs.ETS_PT_DISPLAY_RATING) && $configs.ETS_PT_DISPLAY_RATING}
                                    <div class="hook-reviews">
                                        {hook h='displayProductListReviews' product=$product}
                                    </div>
                                {/if}
                            </div>
                        </div>
                    </li>
                {/if}
            {/foreach}
        </ul>
    	<div class="button-container box-info-product {if count($purchase_togethers) == $alldisabled}disabled{/if}">
    		<a class="ets_ajax_add_to_cart_button exclusive" href="{$ajax_cart|escape:'html':'UTF-8'}" rel="nofollow" title="{l s='Add all products to cart' mod='ets_purchasetogether'}">
    			<span>{l s='Add all products to cart' mod='ets_purchasetogether'}</span>
    		</a>
    	</div>
    {/if}
{else}
{if isset($purchase_togethers) && $purchase_togethers && count($purchase_togethers) != $alldisabled}
        <h2 class="ets_purchase_title">{$configs.ETS_PT_TITLE|escape:'html':'UTF-8'}</h2>
        <ul class="ets-list-checkbox-product">
            {*Display current product*}
            {if (isset($configs.ETS_PT_EXCLUDE_CURRENT_PRODUCT) && !$configs.ETS_PT_EXCLUDE_CURRENT_PRODUCT)
                && !(isset($configs.ETS_PT_EXCLUDE_OUT_OF_STOCK) && $configs.ETS_PT_EXCLUDE_OUT_OF_STOCK && $quantity_available <= 0)}
                <li class="item-product this-product">
                    <div class="row-product">
                    <div class="ets_purchase_item_image">
                        <input class="{if isset($configs.ETS_PT_REQUIRE_CURRENT_PRODUCT) && $configs.ETS_PT_REQUIRE_CURRENT_PRODUCT}required{/if}"
                            id="product_{$currProduct.id_product|intval}_{$id_product_attribute_default|intval}" 
                            type="checkbox" 
                            checked="checked"
                            name="product_current" />
                        <div class="product-image">
                            <a class="product_img_link" href="{$currProduct.link|escape:'html':'UTF-8'}" title="{$currProduct.name|escape:'html':'UTF-8'}" itemprop="url">
            					<img id="pc_ets_img" class="replace-2x img-responsive" src="{$link->getImageLink($currProduct.link_rewrite, $currProduct.id_image, 'medium_default')|escape:'html':'UTF-8'}" alt="{if !empty($currProduct.legend)}{$currProduct.legend|escape:'html':'UTF-8'}{else}{$currProduct.name|escape:'html':'UTF-8'}{/if}" title="{if !empty($currProduct.legend)}{$currProduct.legend|escape:'html':'UTF-8'}{else}{$currProduct.name|escape:'html':'UTF-8'}{/if}" {if isset($homeSize)} width="{$homeSize.width|escape:'html':'UTF-8'}" height="{$homeSize.height|escape:'html':'UTF-8'}"{/if} itemprop="image" />
            				</a>
                        </div>
                    </div>
                    <div class="ets_purchase_item_des">                    
                        <label for="">
                            <a class="product-name product-name-checkbox">
                            {l s='This product' mod='ets_purchasetogether'} (<b>{$currProduct.name|escape:'html':'UTF-8'}</b>)
                            </a>
                        </label>{*product_{$currProduct.id_product|intval}_{$currProduct.id_product_attribute|intval}*}
                        <span class="price">
                			{if !isset($restricted_country_mode) && isset($configs.ETS_PT_DISPLAY_PRODUCT_PRICE) && $configs.ETS_PT_DISPLAY_PRODUCT_PRICE}
        						<span itemprop="price" class="price product-price">
        							{hook h="displayProductPriceBlock" product=$currProduct type="before_price"}
                                    {if !$priceDisplay}{convertPrice price=$currProduct.price}{else}{convertPrice price=$currProduct.price_tax_exc}{/if}
        						</span>
        						<meta itemprop="priceCurrency" content="{$currency->iso_code|escape:'html':'UTF-8'}" />
        						{if $currProduct.price_without_reduction > 0 && isset($currProduct.specific_prices) && $currProduct.specific_prices && isset($currProduct.specific_prices.reduction) && $currProduct.specific_prices.reduction > 0}
        							{if isset($configs.ETS_PT_DISPLAY_OLD_PRICE) && $configs.ETS_PT_DISPLAY_OLD_PRICE}
                                        {hook h="displayProductPriceBlock" product=$currProduct type="old_price"}
        								<span class="old-price product-price">
        									{displayWtPrice p=$currProduct.price_without_reduction}
        								</span>
                                    {/if}
                            		{if $currProduct.specific_prices.reduction_type == 'percentage' && isset($configs.ETS_PT_DISPLAY_DISCOUNT) && $configs.ETS_PT_DISPLAY_DISCOUNT}
        								<span class="price-percent-reduction">-{$currProduct.specific_prices.reduction * 100|floatval}%</span>
        							{/if}
        						{/if}
        					{/if}
                        </span>
                        <p class="attribute_small">{if isset($currProduct.attribute_small) && $currProduct.attribute_small}{$currProduct.attribute_small|escape:'html':'UTF-8'}{/if}</p>
                        
                        <div class="description">
                            {if isset($configs.ETS_PT_DISPLAY_PRODUCT_DESCRIPTION) && $configs.ETS_PT_DISPLAY_PRODUCT_DESCRIPTION}
                                <div  class="">{if isset($currProduct.description_short) && $currProduct.description_short}{$currProduct.description_short|truncate:$configs.ETS_PT_MAX_DESCRIPTION_LENGHT:'...'}
                                    {else}{$currProduct.description|truncate:$configs.ETS_PT_MAX_DESCRIPTION_LENGHT:'...'}{/if}</div>
                            {/if} 
                        </div>
                        {if isset($configs.ETS_PT_DISPLAY_RATING) && $configs.ETS_PT_DISPLAY_RATING}
                            <div class="hook-reviews">
                                {hook h='displayProductListReviews' product=$currProduct}
                            </div>
                        {/if}
                    </div> 
                    </div>                
                </li>
            {/if}
            {foreach from=$purchase_togethers item=product}
                {if isset($product.disabled) && !$product.disabled}
                    <li class="item-product">
                        <div class="row-product">
                            <div class="ets_purchase_item_image">
                                <input type="checkbox" class=""
                                    checked="checked"
                                    data-id="{$product.id_product|intval}"
                                    data-attribute="{$product.id_product_attribute|intval}"
                                    data-qty="{if isset($configs.ETS_PT_DEFAULT_QUANTITY_ADDED_TO_CART) && $configs.ETS_PT_DEFAULT_QUANTITY_ADDED_TO_CART}{$configs.ETS_PT_DEFAULT_QUANTITY_ADDED_TO_CART|intval}{else}1{/if}"
                                    id="purchase_{$product.id_product|intval}_{$product.id_product_attribute|intval}" 
                                    name="purchase_together[]" />
                                <div class="product-image">
                                    <a class="product_img_link" href="{$product.link|escape:'html':'UTF-8'}" title="{$product.name_attribute|escape:'html':'UTF-8'}" itemprop="url">
            							<img class="replace-2x img-responsive" src="{$link->getImageLink($product.link_rewrite, $product.id_image, 'medium_default')|escape:'html':'UTF-8'}" alt="{if !empty($product.legend)}{$product.legend|escape:'html':'UTF-8'}{else}{$product.name_attribute|escape:'html':'UTF-8'}{/if}" title="{if !empty($product.legend)}{$product.legend|escape:'html':'UTF-8'}{else}{$product.name_attribute|escape:'html':'UTF-8'}{/if}" {if isset($homeSize)} width="{$homeSize.width|escape:'html':'UTF-8'}" height="{$homeSize.height|escape:'html':'UTF-8'}"{/if} itemprop="image" />
            						</a>
                                </div>
                            </div>
                            <div class="ets_purchase_item_des">
                                <label for="purchase_{$product.id_product|intval}_{$product.id_product_attribute|intval}">
                                    <a class="product-name product-name-checkbox" href="{$product.link|escape:'html':'UTF-8'}" title="{$product.name_attribute|escape:'html':'UTF-8'}" itemprop="url" >
                						{$product.name_attribute|truncate:45:'...'|escape:'html':'UTF-8'}
                					</a>
                                </label>
                                <div class="price">
                        			{if isset($product.show_price) && $product.show_price && !isset($restricted_country_mode) && isset($configs.ETS_PT_DISPLAY_PRODUCT_PRICE) && $configs.ETS_PT_DISPLAY_PRODUCT_PRICE}
            							<span itemprop="price" class="price product-price">
            								{hook h="displayProductPriceBlock" product=$product type="before_price"}
                                            {if !$priceDisplay}{convertPrice price=$product.price}{else}{convertPrice price=$product.price_tax_exc}{/if}
            							</span>
            							<meta itemprop="priceCurrency" content="{$currency->iso_code|escape:'html':'UTF-8'}" />
            							{if $product.price_without_reduction > 0 && isset($product.specific_prices) && $product.specific_prices && isset($product.specific_prices.reduction) && $product.specific_prices.reduction > 0}
            								{if isset($configs.ETS_PT_DISPLAY_OLD_PRICE) && $configs.ETS_PT_DISPLAY_OLD_PRICE}
                                                {hook h="displayProductPriceBlock" product=$product type="old_price"}
                								<span class="old-price product-price">
                									{displayWtPrice p=$product.price_without_reduction}
                								</span>
                                            {/if}
                                    		{if $product.specific_prices.reduction_type == 'percentage' && isset($configs.ETS_PT_DISPLAY_DISCOUNT) && $configs.ETS_PT_DISPLAY_DISCOUNT}
            									<span class="price-percent-reduction">-{$product.specific_prices.reduction * 100|floatval}%</span>
            								{/if}
            							{/if}
            						{/if}
                                </div>
                                <p class="attribute-small">{if isset($product.attribute_small) && $product.attribute_small}{$product.attribute_small|escape:'html':'UTF-8'}{/if}</p>
                                
                                <div class="description">
                                    {if isset($configs.ETS_PT_DISPLAY_PRODUCT_DESCRIPTION) && $configs.ETS_PT_DISPLAY_PRODUCT_DESCRIPTION}
                                        <div  class="">{if isset($product.description_short) && $product.description_short}{$product.description_short|truncate:$configs.ETS_PT_MAX_DESCRIPTION_LENGHT:'...' nofilter}
                                            {else}{$product.description|truncate:$configs.ETS_PT_MAX_DESCRIPTION_LENGHT:'...' nofilter}{/if}</div>
                                    {/if} 
                                </div>
                                {if isset($configs.ETS_PT_DISPLAY_RATING) && $configs.ETS_PT_DISPLAY_RATING}
                                    <div class="hook-reviews">
                                        {hook h='displayProductListReviews' product=$product}
                                    </div>
                                {/if}
                            </div>
                        </div>
                    </li>
                {/if}
            {/foreach}
        </ul>
    	<div class="button-container box-info-product {if count($purchase_togethers) == $alldisabled}disabled{/if}">
    		<a class="ets_ajax_add_to_cart_button exclusive" href="{$ajax_cart|escape:'html':'UTF-8'}" rel="nofollow" title="{l s='Add all products to cart' mod='ets_purchasetogether'}">
    			<span>{l s='Add all products to cart' mod='ets_purchasetogether'}</span>
    		</a>
    	</div>
    {/if}
    
{/if}
<div class="clearfix"></div>
{if isset($configs.ETS_PT_HOOK_TO) && $configs.ETS_PT_HOOK_TO == 'displayFooterProduct'}
    </div>
{else if isset($configs.ETS_PT_HOOK_TO) && $configs.ETS_PT_HOOK_TO == 'displayProductAdditionalInfo'}
    </div>
{else}
    </div>
{/if}
    