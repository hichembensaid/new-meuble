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
{if $YBC_NEWSLETTER_TEMPLATE == 'ynpt1'}
    {include file="$YBC_NEWSLETTER_TPL/hook/template1.tpl"}
{elseif $YBC_NEWSLETTER_TEMPLATE == 'ynpt2'}
    {include file="$YBC_NEWSLETTER_TPL/hook/template2.tpl"}
{elseif $YBC_NEWSLETTER_TEMPLATE == 'ynpt3'}
    {include file="$YBC_NEWSLETTER_TPL/hook/template3.tpl"}
{elseif $YBC_NEWSLETTER_TEMPLATE == 'ynpt4'}
    {include file="$YBC_NEWSLETTER_TPL/hook/template4.tpl"}
{elseif $YBC_NEWSLETTER_TEMPLATE == 'ynpt5'}
    {include file="$YBC_NEWSLETTER_TPL/hook/template5.tpl"}
{elseif $YBC_NEWSLETTER_TEMPLATE == 'ynpt6'}
    {include file="$YBC_NEWSLETTER_TPL/hook/template6.tpl"}
{elseif $YBC_NEWSLETTER_TEMPLATE == 'ynpt8'}
    {include file="$YBC_NEWSLETTER_TPL/hook/template8.tpl"}       
{/if}
<script type="text/javascript">
    var YBC_NEWSLETTER_POPUP_DELAY ={$YBC_NEWSLETTER_POPUP_DELAY|escape:'html':'UTF-8'};
    var YBC_NEWSLETTER_POPUP_TYPE_SHOW = 'ybc_type_{$YBC_NEWSLETTER_POPUP_TYPE_SHOW|escape:'html':'UTF-8'}';
    var YBC_NEWSLETTER_POPUP_TYPE_SHOW_PARENT = 'ybc_parent_type_{$YBC_NEWSLETTER_POPUP_TYPE_SHOW|escape:'html':'UTF-8'}';
    var YBC_NEWSLETTER_CLOSE_PERMANAL ={$YBC_NEWSLETTER_CLOSE_PERMANAL|intval};
</script>