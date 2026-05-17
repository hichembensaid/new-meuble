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
<style>
    {literal}#ynp-submit, .ybc-newsletter-popup:not(.ynpt6) #ynp-close{background:{/literal}{$color_button|escape:'html':'UTF-8'}{literal};}{/literal}
    {literal}.ynpt6 .ynp-email-input{border-bottom-color: {/literal}{$color_button|escape:'html':'UTF-8'}{literal};}{/literal}
    {literal}.alert-success span{color:{/literal}{$color_button|escape:'html':'UTF-8'}{literal};}{/literal}
    {literal}#uniform-ynp-input-dont-show > span.checked::before{color:{/literal}{$color_button|escape:'html':'UTF-8'}{literal};}{/literal}
    {literal}#ynp-submit:hover, .ybc-newsletter-popup:not(.ynpt6) #ynp-close:hover{background:{/literal}{$color_hover|escape:'html':'UTF-8'}{literal};}{/literal}
    {if $template=='ynpt1' && $image}
        {literal}.ynp-div-l3{background: url('{/literal}{$image|escape:'html':'UTF-8'}{literal}') top left no-repeat;}{/literal}      
    {/if}
{literal}</style>{/literal}