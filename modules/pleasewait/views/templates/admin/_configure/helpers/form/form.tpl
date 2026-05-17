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
{extends file="helpers/form/form.tpl"}
{block name="field"}
    {$smarty.block.parent}
    {if $input.name == 'PLW_SPINNER_TYPE'}
        <div class="col-lg-3"></div>
        <div class="col-lg-9">
            <div class="plw_preview" style="cursor: pointer;text-decoration: underline; font-style: italic; margin-top: 4px; color: #00aff0;">
                {l s='View all loading icon types' mod='pleasewait'}
            </div>
        </div>
    {/if}
{/block}