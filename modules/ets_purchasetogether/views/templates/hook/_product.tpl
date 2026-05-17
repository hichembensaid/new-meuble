{**
 * 2007-2017 PrestaShop
 *
 * NOTICE OF LICENSE
 *
 * This source file is subject to the Open Software License (OSL 3.0)
 * that is bundled with this package in the file LICENSE.txt.
 * It is also available through the world-wide-web at this URL:
 * http://opensource.org/licenses/osl-3.0.php
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
 * @author    PrestaShop SA <contact@prestashop.com>
 * @copyright 2007-2017 PrestaShop SA
 * @license   http://opensource.org/licenses/osl-3.0.php Open Software License (OSL 3.0)
 * International Registered Trademark & Property of PrestaShop SA
 *}
 
{block name='product_miniature_item'}
  <article class="product-miniature js-product-miniature item actived" data-id-product="{$product.id_product|intval}" data-id-product-attribute="{$product.id_product_attribute|intval}" itemscope itemtype="http://schema.org/Product">
    <div class="thumbnail-container">
      {block name='product_thumbnail'}
        <a href="{$product.url|escape:'html':'UTF-8'}" class="thumbnail product-thumbnail">
          <img
            src="{$link->getImageLink($product.link_rewrite, $product.id_image, 'home_default') nofilter}"
            alt="{if !empty($product.legend)}{$product.legend nofilter}{else}{$product.name_attribute nofilter}{/if}"
           />
        </a>
      {/block}
      <div class="product-description">
        {block name='product_name'}
          <h1 class="h3 product-title" itemprop="name">
            <a href="{$product.url|escape:'html':'UTF-8'}">{$product.name_attribute|truncate:30:'...'|escape:'html':'UTF-8'}</a></h1>
        {/block}
      </div>
    </div>
  </article>
{/block}
