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
<li class="mm_menus_li item{$menu.id_menu|intval} {if !$menu.enabled}mm_disabled{/if}" data-id-menu="{$menu.id_menu|intval}" data-obj="menu">                        
    <div class="mm_menus_li_content">
        <span class="mm_menu_name mm_menu_toggle">{$menu.title|escape:'html':'UTF-8'}</span>
        <div class="mm_buttons">
            <span class="mm_menu_delete" title="{l s='Delete this item' mod='ets_megamenu'}">{l s='Delete' mod='ets_megamenu'}</span>  
            <span class="mm_duplicate" title="{l s='Duplicate this menu' mod='ets_megamenu'}">{l s='Duplicate' mod='ets_megamenu'}</span>                      
            <span class="mm_menu_edit">{l s='Edit' mod='ets_megamenu'}</span>                
            <span class="mm_menu_toggle mm_menu_toggle_arrow">{l s='Close' mod='ets_megamenu'}</span> 
            <div class="mm_add_column btn btn-default" data-id-menu="{$menu.id_menu|intval}">{l s='Add new column' mod='ets_megamenu'}</div> 
        </div> 
    </div>
    <ul class="mm_columns_ul">
        {if $menu.columns}                            
                {foreach from=$menu.columns item='column'}
                    {hook h='displayMMItemColumn' column=$column}
                {/foreach}                            
        {/if}  
    </ul>   
</li>