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

{extends file="helpers/form/form.tpl"}
{block name="field"}
    {if $input.type == 'optionslist'}
        <div class="col-lg-9">
            <ul style="float: left; padding: 0; margin-top: 5px;">
                {if $input.options}
                    {foreach from=$input.options.query item='option'}
                        <li class="ets-purchase-type-show" style="list-style: none; padding-bottom: 5px">
                            <input {if in_array($option.value, $fields_value[$input.name])} checked="checked" {/if} style="margin: 2px 7px 0 5px; float: left;" 
                            type="radio" 
                            value="{$option.value|escape:'html':'UTF-8'}" 
                            name="{$input.name|escape:'html':'UTF-8'}" />
                            <img src="{$option.image|escape:'html':'UTF-8'}" height="{if isset($option.height)}{$option.heigh|intval}px{/if}" width="{if isset($option.width)}{$option.width|intval}px{/if}" alt="{$option.label|escape:'html':'UTF-8'}" title="{$option.label|escape:'html':'UTF-8'}" />
                            <p class="help-block">{$option.label|escape:'html':'UTF-8'}</p>
                        </li>
                    {/foreach}
                {/if}
            </ul>
        </div>
    {elseif $input.type == 'checkboxoptions'}
        <div class="col-lg-9">
            <ul style="float: left; padding: 0; margin-top: 5px;">
                {if $input.options}
                    {foreach from=$input.options.query item='option'}
                        <li style="list-style: none; padding-bottom: 5px">
                            <input {if $fields_value[$option.id]} checked="checked" {/if} style="margin: 2px 7px 0 5px; float: left;" 
                            type="checkbox"
                            id="{$option.id|escape:'html':'UTF-8'}"
                            name="{$option.id|escape:'html':'UTF-8'}" />
                            <label for="{$option.id|escape:'html':'UTF-8'}">{$option.label|escape:'html':'UTF-8'}</label>
                        </li>
                    {/foreach}
                {/if}
            </ul>
        </div>
    {/if}
    {$smarty.block.parent}
{/block}

{block name="footer"}
    {capture name='form_submit_btn'}{counter name='form_submit_btn'}{/capture}
	{if isset($fieldset['form']['submit']) || isset($fieldset['form']['buttons'])}
		<div class="panel-footer">
            {if isset($cancel_url) && $cancel_url}
                <a class="btn btn-default" href="{$cancel_url|escape:'html':'UTF-8'}"><i class="process-icon-cancel"></i>Cancel</a>
            {/if}
            {if isset($fieldset['form']['submit']) && !empty($fieldset['form']['submit'])}
			<button type="submit" value="1"	id="{if isset($fieldset['form']['submit']['id'])}{$fieldset['form']['submit']['id']|escape:'html':'UTF-8'}{else}{$table|escape:'html':'UTF-8'}_form_submit_btn{/if}{if $smarty.capture.form_submit_btn > 1}_{($smarty.capture.form_submit_btn - 1)|intval}{/if}" name="{if isset($fieldset['form']['submit']['name'])}{$fieldset['form']['submit']['name']|escape:'html':'UTF-8'}{else}{$submit_action|escape:'html':'UTF-8'}{/if}{if isset($fieldset['form']['submit']['stay']) && $fieldset['form']['submit']['stay']|escape:'html':'UTF-8'}AndStay{/if}" class="{if isset($fieldset['form']['submit']['class'])}{$fieldset['form']['submit']['class']|escape:'html':'UTF-8'}{else}btn btn-default pull-right{/if}">
				<i class="{if isset($fieldset['form']['submit']['icon'])}{$fieldset['form']['submit']['icon']|escape:'html':'UTF-8'}{else}process-icon-save{/if}"></i> {$fieldset['form']['submit']['title']|escape:'html':'UTF-8'}
			</button>
			{/if}
		</div>
	{/if}
{/block}