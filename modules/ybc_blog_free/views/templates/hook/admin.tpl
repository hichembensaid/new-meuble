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
{if $ybc_blog_free_error_message}
    {$ybc_blog_free_error_message nofilter}
{/if}
<script type="text/javascript"> 
    var ybc_blog_free_ajax_url = '{$ybc_blog_free_ajax_url nofilter}';
    var ybc_blog_free_default_lang = {$ybc_blog_free_default_lang|intval};
    var ybc_blog_free_is_updating = {$ybc_blog_free_is_updating|intval};
    var ybc_blog_free_is_config_page = {$ybc_blog_free_is_config_page|intval};
    var ybc_blog_free_invalid_file = '{$ybc_blog_free_invalid_file|escape:'html':'UTF-8'}';
</script>
<script type="text/javascript" src="{$ybc_blog_free_module_dir|escape:'html':'UTF-8'}views/js/admin.js"></script>
<div class="bootstrap">
    <div class="row">
        <div class="col-lg-12">
            <div class="row">
                {$ybc_blog_free_sidebar nofilter}
                <div class="blog_center_content col-lg-10">
                    {$ybc_blog_free_body_html nofilter}
                </div>
            </div>
        </div>
    </div>
</div>