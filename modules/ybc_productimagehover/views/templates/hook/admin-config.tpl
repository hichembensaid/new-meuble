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
{if $setting_updated}
    <div class="alert alert-success">{l s='Setting updated' mod='ybc_productimagehover'}</div>
{/if}
<form class="defaultForm form-horizontal" enctype="multipart/form-data" method="post" action="{$postUrl|escape:'html':'UTF-8'}">
    <div class="panel">
        <div class="panel-heading"><i class="icon-cogs"></i> {l s='Setting' mod='ybc_productimagehover'}</div>
        <div class="form-wrapper">
            <div class="form-group">
                <label class="control-label col-lg-3" for="transition-effect">{l s='Transition effect' mod='ybc_productimagehover'}</label>
                <div class="col-lg-9">
                    <select id="transition-effect" class="fixed-width-xl" name="YBC_PI_TRANSITION_EFFECT">
                        {foreach from=$effects item='effect'}
                            <option {if $effect.id == $YBC_PI_TRANSITION_EFFECT}selected="selected"{/if} value="{$effect.id|escape:'html':'UTF-8'}">{$effect.name|escape:'html':'UTF-8'}</option>
                        {/foreach}
                    </select>
                </div>
            </div>
            <div class="form-group">
                <label class="control-label col-lg-3" for="those-pages">{l s='Apply transition effect on those pages' mod='ybc_productimagehover'}</label>
                <div class="col-lg-9">
                    <select id="those-pages" class="fixed-width-xl" name="YBC_PI_THOSE_PAGES[]" multiple size="6">
                        {foreach from=$those_pages item='page'}
                            <option {if in_array('allpage', $YBC_PI_THOSE_PAGES) || in_array($page.id, $YBC_PI_THOSE_PAGES)}selected="selected"{/if} value="{$page.id|escape:'html':'UTF-8'}">{$page.name|escape:'html':'UTF-8'}</option>
                        {/foreach}
                    </select>
                </div>
            </div>
        </div>
        <div class="panel-footer">
            <button class="btn btn-default pull-right" name="submitUpdate" id="module_form_submit_btn" value="1" type="submit">
    		  <i class="process-icon-save"></i> {l s='Save' mod='ybc_productimagehover'}
    	    </button>																								
        </div>
    </div>
</form>