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

    setTimeout(function(){
        $('.ybc-newsletter-popup').addClass('active'); 
        $('.ybc_nlt_content').addClass(YBC_NEWSLETTER_POPUP_TYPE_SHOW);
    }, parseInt(YBC_NEWSLETTER_POPUP_DELAY) > 1000 ? parseInt(YBC_NEWSLETTER_POPUP_DELAY) : 2000);
    
    if($('.ybc-newsletter-popup').length > 0)
    {
        $('.ybc-newsletter-popup').fadeIn();
    }
    $('.ynp-submit').click(function(){        
        var npemail = $(this).prev('.ynp-email-input').val();
        var npaction = $('.ynp-form').attr('action');
        $('.ynp-alert').remove();
        $('.ynp-loading-div').show();
        var ybcmailForm = $(this).parents('.ybc-mail-wrapper');
        $.ajax({
            url : npaction,
            type : 'post',
            dataType : 'json',
            data : {
                npemail : npemail
            },
            success: function(json){
                if(!json['thank_you'])
                    $('.ybc-newsletter-popup').fadeOut();
                else
                {
                    $('.ynp-loading-div').hide();
                    if(json['success'])
                    {
                        ybcmailForm.find('.ynp-form').after('<div class="ynp-alert alert alert-success">'+json['success']+'</div>');
                        $('.ynp-form-popup').hide(); 
                        $('.img_bg').hide();
                        $('.ynp-div-l3').addClass('ybc_form_success');                    
                        $('.ynp-email-input').val('');
                    }
                    else
                    {
                        ybcmailForm.find('.ynp-input-row').after('<div class="ynp-alert alert alert-danger">'+json['error']+'</div>');                    
                    }
                }               
                
            },
            error: function(){
                $('.ynp-loading-div').hide();
            }
        });
        return false;
    });
    $('.ynp-close').click(function(){
        var npemail = $('#ynp-email-input').val();
        var npaction = $('.ynp-form').attr('action');
        if($('#ynp-input-dont-show').is(':checked')|| YBC_NEWSLETTER_CLOSE_PERMANAL)
        {
            $.ajax({
                url : npaction,
                type : 'post',                
                data : {
                    donotshowagain : $('#ynp-input-dont-show').is(':checked') ? 1 : 0,
                    close: 1,
                }
            });
        }
        $('.ybc-newsletter-popup').hide();
    });
    $(document).keyup(function(e) {      
      if (e.keyCode === 27 && $('.ynp-form').length>0 && $('.ynp-close').length>0  )
      {
        $('.ynp-close').click();
      }
    });
    $(document).mouseup(function (e)
    {
        var container = $(".ybc_nlt_content");
        if (!container.is(e.target) && container.has(e.target).length === 0&& $('.ynp-form').length>0 && $('.ynp-close').length>0 )
        {
            $('.ynp-close').click();
        }
    });
    $(document).on('click', '.ynp-alert.alert-danger, .ybc-newsletter-home .alert-success', function(){
        $(this).remove();
    });
});