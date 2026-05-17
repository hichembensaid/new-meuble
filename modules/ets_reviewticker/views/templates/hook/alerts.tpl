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
{if isset($reviews) && $reviews}
    <ul class="ets_reviewticker {if $ETS_RT_RTL}rt_rtl{/if} {if $ETS_RT_HIDE_ON_MOBILE}rt_hide_on_mobile{/if} rt_pos_{if $ETS_RT_POSITION}{$ETS_RT_POSITION|escape:'html':'UTF-8'}{else}botton_left{/if} rt_tran_{if $ETS_RT_TRANSITION}{$ETS_RT_TRANSITION|escape:'html':'UTF-8'}{else}slide_up{/if}">
        {foreach from=$reviews item='review'}
            {if $review.alert}
                <li data-id-order-detail="{$review.id_product_comment|intval}">
                    {if $review.image}<a href="{$review.product_link|escape:'html':'UTF-8'}">
                    <img alt="{$review.name|escape:'html':'UTF-8'}" src="{$review.image|escape:'html':'UTF-8'}" /></a>{/if}
                    <div class="rt_alert_content">{$review.alert nofilter}</div>
                    {if $ETS_RT_ALLOW_CLOSE}<div class="ets_rt_close"><span>{l s='Close' mod='ets_reviewticker'}</span></div>{/if}
                </li>
            {/if}
        {/foreach}
    </ul>
{/if}