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
{if isset($slide) && $slide}
    <li class="mls_slides_li item{$slide.id_slide|intval} {if !$slide.enabled}mls_disabled{/if}" data-id-slide="{$slide.id_slide|intval}" data-obj="slide">
         <span class="title-silde" ><span>{if $slide.title}{$slide.title|escape:'html':'UTF-8'}{else}{$slide.id_slide|intval}{/if}</span></span>
         <div class="slide-content">
             <div class="left-block col-lg-9" >
                <div class="left-content">
                    {hook h='displayMLSSlideInner' slide=$slide layout=$mls_layout}               
                </div>
             </div>
             <div class="right-block col-lg-3">
                <h2 data-title="&#xE3C4;">{l s='Layers' mod='ets_multilayerslider'}</h2>
                <div data-title="&#xE145;" class="mls_add_layer btn btn-default" data-id-slide="{$slide.id_slide|intval}">{l s='Add new layer' mod='ets_multilayerslider'}</div>
                <ul id="layers_slide{$slide.id_slide|intval}" class="mls_layers_ul">
                    {if isset($slide.layers) && $slide.layers}
                        {foreach from=$slide.layers item='layer'}
                            {hook h='displayMLSLayerSort' layer=$layer}
                        {/foreach}
                    {/if}
                </ul>
             </div>
         </div>
    </li>
{/if}