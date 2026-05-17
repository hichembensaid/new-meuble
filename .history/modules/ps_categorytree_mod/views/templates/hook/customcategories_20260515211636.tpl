{function name="categories_custom" nodes=[] depth=0}
  {strip}
    {if $nodes|count}
      <ul class="{if isset($depth) && $depth == 0}category-top-menu-list {/if}category-sub-menu" data-show="{$depth|escape:'html':'UTF-8'}">
        {assign var='i' value=0}
        {foreach from=$nodes item=node}
            {assign var='i' value=$i+1}
          <li {if isset($i) && $i > 10} class="hidden_product"{/if}>
            
                {if $depth===0}
                  <a href="{$node.link|escape:'html':'UTF-8'}">{$node.name|escape:'html':'UTF-8'}</a>
                  {if $node.children}
                    <div class="navbar-toggler collapse-icons" data-toggle="collapse" data-target="#customexCollapsingNavbar{$node.id|escape:'html':'UTF-8'}">
                      <i class="ion-ios-arrow-right add"></i>
                    </div>
                    <div class="collapse sub_cat_hover" id="customexCollapsingNavbar{$node.id|escape:'html':'UTF-8'}">
                      {categories_custom nodes=$node.children depth=$depth+1}
                    </div>
                  {/if}
                {else}
                  <a class="category-sub-link" href="{$node.link|escape:'html':'UTF-8'}">{$node.name|escape:'html':'UTF-8'}</a>
                  {if $node.children}
                    <span class="arrows" data-toggle="collapse" data-target="#customexCollapsingNavbar{$node.id|escape:'html':'UTF-8'}">
                      <i class="ion-ios-arrow-right arrow-right"></i>
                    </span>
                    <div class="collapse sub_cat_hover" id="customexCollapsingNavbar{$node.id|escape:'html':'UTF-8'}">
                      {categories_custom nodes=$node.children depth=$depth+1}
                    </div>
                  {/if}
                {/if}
          </li>
        {/foreach}
      </ul>
    {/if}
  {/strip}
{/function}

{function name="categories_mobile" nodes=[] depth=0}
  {strip}
    {if $nodes|count}
      <ul class="{if isset($depth) && $depth == 0}category-top-menu-list {/if}category-sub-menu" data-show="{$depth|escape:'html':'UTF-8'}">
        {assign var='i' value=0}
        {foreach from=$nodes item=node}
            {assign var='i' value=$i+1}
          <li {if isset($i) && $i > 10} class="hidden_product"{/if}>
            
                {if $depth===0}
                  <a href="{$node.link|escape:'html':'UTF-8'}">{$node.name|escape:'html':'UTF-8'}</a>
                  {if $node.children}
                    <button type="button" class="navbar-toggler collapse-icons" data-toggle="collapse" data-target="#mobileCollapsingNavbar{$node.id|escape:'html':'UTF-8'}" aria-expanded="false">
                      <span class="toggle-arrow"></span>
                    </button>
                    <div class="collapse sub_cat_hover" id="mobileCollapsingNavbar{$node.id|escape:'html':'UTF-8'}">
                      {categories_mobile nodes=$node.children depth=$depth+1}
                    </div>
                  {/if}
                {else}
                  <a class="category-sub-link" href="{$node.link|escape:'html':'UTF-8'}">{$node.name|escape:'html':'UTF-8'}</a>
                  {if $node.children}
                    <button type="button" class="navbar-toggler arrows" data-toggle="collapse" data-target="#mobileCollapsingNavbar{$node.id|escape:'html':'UTF-8'}" aria-expanded="false">
                      <span class="toggle-arrow"></span>
                    </button>
                    <div class="collapse sub_cat_hover" id="mobileCollapsingNavbar{$node.id|escape:'html':'UTF-8'}">
                      {categories_mobile nodes=$node.children depth=$depth+1}
                    </div>
                  {/if}
                {/if}
          </li>
        {/foreach}
      </ul>
    {/if}
  {/strip}
{/function}
<div class="block-categories-custom col-md-3 col-sm-3 col-lg-3 hidden-sm-down" id="desktop-categories-block">
  <div class="block-categories-custom-content">
      <h3 class="block-categories-title"> Categories </h3>
      <div class="category-top-menu-pos">
        {categories_custom nodes=$categories_custom.children}
        <span class="view view_more_cat"><span>{l s='More categories ' d='Shop.Theme'}<i class="fa fa-angle-double-down"></i></span></span>
        <span class="view view_less_cat"><span>{l s='Less categories ' d='Shop.Theme'}<i class="fa fa-angle-double-up"></i></span></span>
      </div>
  </div>
</div>

{* Bloc mobile pour les catégories *}
<div class="block-categories-custom-mobile" id="mobile-categories-block">
  <div class="block-categories-custom-content">
      <ul class="category-top-menu-pos-mobile">
        <li class="close_menu">
            <div class="pull-left">
                <span class="mm_menus_back">
                    <i class="icon-bar"></i>
                    <i class="icon-bar"></i>
                    <i class="icon-bar"></i>
                </span>
                {l s='Categories' d='Shop.Theme'}
            </div>
            <div class="pull-right">
                {l s='Close' d='Shop.Theme'}
            </div>
        </li>
      </ul>
      <div class="category-top-menu-pos">
        {categories_mobile nodes=$categories_custom.children}
      </div>
  </div>
</div>