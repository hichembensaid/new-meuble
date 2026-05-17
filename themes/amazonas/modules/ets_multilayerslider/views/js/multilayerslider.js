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
var mslFullSliderEnabled = false;
$(document).ready(function(){
    if($('.mls_slider').length > 0)
    {
        if($('.mls_slider').attr('data-slider-type')=='full' && $('.mls_slider').parents('#columns').length > 0)
        {
            $('.mls_slider').parents('#columns').eq(0).before($('.ets_multilayerslider'));
            $('.ets_multilayerslider').removeClass('hidden');     
            mslFullSliderEnabled = true;   
        }
        else if($('.mls_slider').attr('data-slider-type')=='full' && $('.mls_slider').parents('#wrapper').length > 0)
        {
            $('.mls_slider').parents('#wrapper').eq(0).prepend($('.ets_multilayerslider'));
            $('.ets_multilayerslider').removeClass('hidden');     
            mslFullSliderEnabled = true;   
        }
        else if($('.ets_multilayerslider').length > 0)
            $('.ets_multilayerslider').removeClass('hidden');
        $('.mls_slider').mls_slider({
            enableNav: parseInt($('.mls_slider').attr('data-enable-next-prev')),
            enablePagination: parseInt($('.mls_slider').attr('data-enable-pagination')),
            moveIn: parseInt($('.mls_slider').attr('data-move-in')),
            moveOut: parseInt($('.mls_slider').attr('data-move-out')),
            stand: parseInt($('.mls_slider').attr('data-stand-duration')),
            loop: parseInt($('.mls_slider').attr('data-loop')),
            autoPlay: parseInt($('.mls_slider').attr('data-auto-play')),
            pauseOnHover: parseInt($('.mls_slider').attr('data-pause-on-hover')),
            enableLoading: parseInt($('.mls_slider').attr('data-enable-loading-icon')),
            enableRunningBar: parseInt($('.mls_slider').attr('data-enable-running-bar')),
        });
        
        ScaleSlider();
        
        $(window).on('resize',function(e){
            ScaleSlider();
        });   
    }
});
 
function ScaleSlider(){
    var ratio = $('.mls_slides').width()/width_slider;
    var height = ratio*height_slider;
    if ( ratio <= 1 ){
        var buttonscale = 2 - ratio;
    } else {
        var buttonscale = 1- (ratio - 1);
    }
    if($('.mls_slides').width() < width_slider || mslFullSliderEnabled || $('.mls_slider').attr('data-slider-type')=='auto')
        {            
            $('.ets_multilayerslider').css('height',height+'px');
            $('.ets_multilayerslider .mls_slides').css('transform', 'scale('+ratio+')');
            $('.mls_nav > div').css('transform', 'scale('+buttonscale+') ');
            $('.mls_loading_icon img').css('transform', 'scale('+buttonscale+') translate3d(-50%, -50%, 0px)');
            $('.mls_pagination').css('transform', 'scale('+buttonscale+') translateX(-50%)');
            
        }
        else
        {
            $('.ets_multilayerslider .mls_slides').css('transform', 'scale(1)');
            $('.ets_multilayerslider').css('height','auto');
        }
}








