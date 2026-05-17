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
    if($('select[name="ETS_RT_PAGE[]"] option[value="all"]').is(':selected'))
        $('select[name="ETS_RT_PAGE[]"] option').prop('selected',true);
    $('select[name="ETS_RT_PAGE[]"] option').click(function(){
        if($(this).val()=='all' && !$('select[name="ETS_RT_PAGE[]"][value="all"]').is(':selected'))
            $('select[name="ETS_RT_PAGE[]"] option').prop('selected',true);
    });
    if($('select[name="ETS_RT_ORDER_STATES[]"] option[value="0"]').is(':selected'))
        $('select[name="ETS_RT_ORDER_STATES[]"] option').prop('selected',true);
    $('select[name="ETS_RT_ORDER_STATES[]"] option').click(function(){
        if($(this).val()=='0' && !$('select[name="ETS_RT_ORDER_STATES[]"][value="0"]').is(':selected'))
            $('select[name="ETS_RT_ORDER_STATES[]"] option').prop('selected',true);
    });
    $(document).on('click','.rt_form_tab > li',function(){
        if(!$(this).hasClass('active'))
        {
            $('.rt_form > div, .rt_form_tab > li').removeClass('active');
            $(this).addClass('active');
            $('.rt_form > div.rt_form_'+$(this).attr('data-tab')).addClass('active');
        }        
    });
});