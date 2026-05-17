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
{if isset($errors) && $errors}
    <div class="ybc_blog_free_alert error">
        <div class="bootstrap">
            <div class="module_error alert alert-danger">
                <button data-dismiss="alert" class="close" type="button">×</button>
                <ul>
                    {foreach from=$errors item='error'}
                        <li>{$error|escape:'html':'UTF-8'}</li>
                    {/foreach}
                </ul>
            </div>
        </div>
    </div>
{/if}
{if isset($import_ok) && $import_ok}
    <div class="ybc_blog_free_alert success">
        <div class="bootstrap">
            <div class="module_confirmation conf confirm alert alert-success">
                <button data-dismiss="alert" class="close" type="button">×</button>
                    {l s='Import successfull' mod='ybc_blog_free'}
            </div>
        </div>
    </div>
{/if}
<form id="module_form" class="defaultForm form-horizontal" novalidate="" enctype="multipart/form-data" method="post" action="">
    <div id="fieldset_0" class="panel">
        <div class="panel-heading">
            <i class="material-icons"></i>
            {l s='Export/Import' mod='ybc_blog_free'}
        </div>
        <div class="ybc_blog_free_export_form_content">
            <div class="ybc_blog_free_export_option">
                <div class="panel-heading">
                    {l s='Export blog content' mod='ybc_blog_free'}
                </div>
                <button type="submit" name="submitExportBlog" class="submitExportBlog"><i class="icon icon-download"></i>{l s='Export blog' mod='ybc_blog_free'}</button>
                <p class="ybc_blog_free_export_option_note">{l s='Export all blog data including blog images, text, custom CSS and configuration' mod='ybc_blog_free'}</p>
            </div>
            <div class="ybc_blog_free_import_option">
                <div class="panel-heading">
                    {l s='Import blog data' mod='ybc_blog_free'}
                </div>
                <div class="ybc_blog_free_import_option_updata">
                    <label for="blogdata">{l s='Data package' mod='ybc_blog_free'}</label>
                    <input id="blogdata" type="file" name="blogdata" />
                </div>
                <div class="ybc_blog_free_import_option_clean">
                    <input type="checkbox" name="importoverride" id="importoverride" value="1" />
                    <label for="importoverride">{l s='Override existing data' mod='ybc_blog_free'}</label>
                </div>
                <div class="ybc_blog_free_import_option_button">
                    <div class="ybc_blog_free_import_submit">
                        <button type="submit" name="submitImportBlog" class="submitImportBlog"><i class="icon icon-compress"></i>{l s='Import data' mod='ybc_blog_free'}</button>
                    </div>
                </div>
            </div>
    </div>
    </div>
</form>