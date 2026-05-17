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
{if isset($assigns) && $assigns}
<script type="text/javascript">
    {foreach from=$assigns key='id_key' item='val'}
        var {$id_key|escape:'html':'UTF-8'} = {if $id_key=='ETS_RT_POSITION' || $id_key=='ETS_RT_URL_AJAX'}'{$val|escape:'quotes':'UTF-8'}'{elseif $id_key=='ETS_RT_LOOP_OUT'}{$val|floatval}{else}{$val|intval}{/if};
    {/foreach}
</script>
{/if}