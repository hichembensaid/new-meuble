// Debug pour le menu mobile des catégories
jQuery(document).ready(function($) {
    console.log('=== DEBUG MENU MOBILE CATEGORIES - Version Transform ===');
    
    // OVERRIDE - Forcer notre propre gestionnaire de clic
    $('#menu-icon').off('click'); // Enlever tous les anciens handlers
    
    $('#menu-icon').on('click', function(){
        console.log('NOUVEAU HANDLER - Clic détecté');
        
        if ($(window).width() <= 767){
            var wrapper = $('#mobile-categories-block');
            var overlay = $('#mobile-categories-overlay');
            
            if($(this).hasClass('closed'))
            {
                console.log('Ouverture du menu...');
                $(this).removeClass('closed').addClass('opened');
                
                // Créer l'overlay s'il n'existe pas
                if (overlay.length === 0) {
                    $('body').append('<div id="mobile-categories-overlay"></div>');
                    overlay = $('#mobile-categories-overlay');
                }
                
                // Juste ajouter la classe active - le CSS fait le reste avec transform
                wrapper.addClass('active');
                
                // Forcer le transform en style inline car le CSS ne marche pas
                wrapper[0].style.setProperty('transform', 'translateX(0)', 'important');
                
                overlay.addClass('active');
                
                $('body').css('overflow', 'hidden');
                $('.mm_menus_ul').hide();
                
                console.log('Classes du wrapper:', wrapper.attr('class'));
                console.log('Transform après forçage:', wrapper.css('transform'));
                console.log('Style attribute:', wrapper.attr('style'));
            }
            else
            {
                console.log('Fermeture du menu...');
                $(this).removeClass('opened').addClass('closed');
                wrapper.removeClass('active');
                wrapper[0].style.setProperty('transform', 'translateX(-100%)', 'important');
                overlay.removeClass('active');
                $('body').css('overflow', '');
            }
        }
    });
    
    // Fermeture via bouton
    $(document).on('click', '#mobile-categories-block .close_menu, #mobile-categories-overlay', function(){
        console.log('Fermeture via bouton/overlay');
        $('#menu-icon').removeClass('opened').addClass('closed');
        var wrapper = $('#mobile-categories-block');
        wrapper.removeClass('active');
        wrapper[0].style.setProperty('transform', 'translateX(-100%)', 'important');
        $('#mobile-categories-overlay').removeClass('active');
        $('body').css('overflow', '');
    });
    
    // Vérifier que le bloc mobile existe
    var mobileBlock = $('#mobile-categories-block');
    console.log('Bloc mobile trouvé:', mobileBlock.length > 0);
    
    if (mobileBlock.length > 0) {
        console.log('Nombre de catégories:', mobileBlock.find('.category-top-menu-list > li').length);
        console.log('Position:', mobileBlock.css('position'));
        console.log('Left:', mobileBlock.css('left'));
        console.log('Transform initial:', mobileBlock.css('transform'));
        console.log('Display:', mobileBlock.css('display'));
        console.log('Z-index:', mobileBlock.css('z-index'));
        console.log('Width:', mobileBlock.css('width'));
    }
    
    // Vérifier le bouton menu
    var menuIcon = $('#menu-icon');
    console.log('Bouton menu trouvé:', menuIcon.length > 0);
    console.log('Classes du bouton:', menuIcon.attr('class'));
});
