<script type="text/javascript">
var ybc_widget_sort_url ='{$baseAdminPath|escape:'html':'UTF-8'}';
</script>
<div class="panel">
    <div class="panel-heading">
        <span class="widget_title"> <i class="icon-AdminAdmin"></i>{l s='Widgets' mod='ybc_widget'}</span>
        <span class="add_new_widget"><a class="label-tooltip" data-toggle="tooltip" data-original-title="{l s ='Add new widget' mod='ybc_widget'}" href="{$baseAdminPath|escape:'html':'UTF-8'}" title=""><i class="process-icon-new "></i></a></span>
    </div>
    <div class="form-wrapper">
        {assign var='i' value=0}
        {if $hooks}
            {foreach from=$hooks item='hook'}
                {assign var='i' value=$i+1}
                {if $i==1}
                    <div class="widget_row">
                {/if}
                <div class="widget_hook" rel="{$hook.hook|escape:'html':'UTF-8'}">
                    <div class="widget_heading widget_{$hook.hook|escape:'html':'UTF-8'}">{$hook.name|escape:'html':'UTF-8'}<a title="{l s='Add a widget to this hook' mod='ybc_widget'}" href="{$baseAdminPath|escape:'html':'UTF-8'}&control=widget&hook={$hook.hook|escape:'html':'UTF-8'}"><i class="process-icon-new"></i></a></div>
                    <ul id="widget_sortable_{$i|escape:'html':'UTF-8'}" class="widget_sortable">
                        {if $hook.widgets}
                            {foreach from=$hook.widgets item='widget'}
                                <li class="widget_item" rel="{$widget.id_widget|escape:'html':'UTF-8'}">
                                    <span class="widget_edit_link">
                                        <a href="{$baseAdminPath|escape:'html':'UTF-8'}&control=widget&id_widget={$widget.id_widget|escape:'html':'UTF-8'}">{$widget.title|escape:'html':'UTF-8'}</a>
                                     </span>
                                     <span class="widget_tool_buttons">
                                         <a onclick="return confirm('{l s='Do you want to delete this?' mod='ybc_widget'}');" href="{$baseAdminPath|escape:'html':'UTF-8'}&control=widget&id_widget={$widget.id_widget|escape:'html':'UTF-8'}&del=true" class="delete"><i class="icon-trash"></i></a>
                                         <a class="enable_disnable" href="{$baseAdminPath|escape:'html':'UTF-8'}&control=widget&id_widget={$widget.id_widget|escape:'html':'UTF-8'}&change_enabled={if $widget.enabled}0{else}1{/if}"><i title="{if $widget.enabled}{l s='Disable this item' mod='ybc_widget'}{else}{l s='Enable this item' mod='ybc_widget'}{/if}" class="{if $widget.enabled}icon-check{else}icon-remove{/if}"></i></a>
                                     </span>
                                </li>
                            {/foreach}
                        {/if}
                    </ul>
                </div>
                {if $i == 3 || $i == 6 || $i == 9 || $i == 11}
                    <div class="ybc_clear"></div></div><div class="widget_row">
                {/if}
                {if $i == 18}
                    <div class="ybc_clear"></div></div>
                {/if}
            {/foreach}
        {/if}
    </div>
</div>
