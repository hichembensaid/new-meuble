// Debug pour le menu mobile des catégories
jQuery(document).ready(function($) {
    console.log('=== DEBUG MENU MOBILE CATEGORIES ===');
    
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
                
                wrapper.addClass('active');
                // FORCER le style inline
                wrapper.attr('style', 'position: fixed; top: 0; left: 0px !important; width: 85%; max-width: 320px; height: 100%; background: #fff; z-index: 9999; overflow-y: auto; display: block; visibility: visible;');
                overlay.addClass('active');
                
                $('body').css('overflow', 'hidden');
                $('.mm_menus_ul').hide();
                
                console.log('Left forcé à:', wrapper.css('left'));
            }
            else
            {
                console.log('Fermeture du menu...');
                $(this).removeClass('opened').addClass('closed');
                wrapper.removeClass('active');
                wrapper.css('left', '-100%');
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
        wrapper.removeClass('active').css('left', '-100%');
        $('#mobile-categories-overlay').removeClass('active');
        $('body').css('overflow', '');
    });
    
    // Vérifier que le bloc mobile existe
    var mobileBlock = $('#mobile-categories-block');
    console.log('Bloc mobile trouvé:', mobileBlock.length > 0);
    
    if (mobileBlock.length > 0) {
        console.log('HTML du bloc mobile:', mobileBlock.html());
        console.log('Nombre de catégories:', mobileBlock.find('.category-top-menu-list > li').length);
        
        // Debug CSS
        console.log('Position:', mobileBlock.css('position'));
        console.log('Left:', mobileBlock.css('left'));
        console.log('Display:', mobileBlock.css('display'));
        console.log('Visibility:', mobileBlock.css('visibility'));
        console.log('Z-index:', mobileBlock.css('z-index'));
        console.log('Width:', mobileBlock.css('width'));
        
        // Forcer les styles en cas de problème
        mobileBlock.css({
            'position': 'fixed',
            'display': 'block',
            'visibility': 'visible',
            'z-index': '9999'
        });
        
        console.log('Après correction - Left:', mobileBlock.css('left'));
    }
    
    // Vérifier le bouton menu
    var menuIcon = $('#menu-icon');
    console.log('Bouton menu trouvé:', menuIcon.length > 0);
    console.log('Classes du bouton:', menuIcon.attr('class'));
});
