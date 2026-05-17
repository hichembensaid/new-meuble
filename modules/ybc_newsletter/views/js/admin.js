/**
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
 * needs please contact us for extra customization service at an affordable price
 *
 *  @author ETS-Soft <etssoft.jsc@gmail.com>
 *  @copyright  2007-2022 ETS-Soft
 *  @license    Valid for 1 website (or project) for each purchase of license
 *  International Registered Trademark & Property of ETS-Soft
 */
$(document).ready(function(){
    if($('select[name="YBC_NEWSLETTER_PAGE[]"] option[value="all"]').is(':selected'))
        $('select[name="YBC_NEWSLETTER_PAGE[]"] option').prop('selected',true);
    $('select[name="YBC_NEWSLETTER_PAGE[]"] option').click(function(){
        if($(this).val()=='all' && !$('select[name="YBC_NEWSLETTER_PAGE[]"][value="all"]').is(':selected'))
            $('select[name="YBC_NEWSLETTER_PAGE[]"] option').prop('selected',true);
    });
    $('select[name="YBC_NEWSLETTER_TEMPLATE"]').change(function(){
        if(confirm('Do you want to load new template?'))
        {
            window.location = $('#module_form').attr('action')+'&loadteamplate='+$(this).val();
        }
        else
            return false;
    });
    $(document).on('click','.ybc_newsletter_form_tab > li',function(){
        if(!$(this).hasClass('active'))
        {
            $('.ybc_newsletter_form > div, .ybc_newsletter_form_tab > li').removeClass('active');
            $(this).addClass('active');
            $('.ybc_newsletter_form > div.ybc_newsletter_form_'+$(this).attr('data-tab')).addClass('active');
        }        
    });
    $('.ybc-templates').click(function(){       
       $.fancybox({
         'autoScale': true,
         'transitionIn': 'elastic',
         'transitionOut': 'elastic',
         'speedIn': 500,
         'speedOut': 300,
         'autoDimensions': true,
         'centerOnScroll': true,
         'href' : ybc_newsletter_module_path+'views/img/preview/'+$('#YBC_NEWSLETTER_TEMPLATE').val()+'.png',
      }); 
    });
});