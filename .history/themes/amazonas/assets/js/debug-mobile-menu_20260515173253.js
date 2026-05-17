// Debug pour le menu mobile des catégories
jQuery(document).ready(function($) {
    console.log('=== DEBUG MENU MOBILE CATEGORIES ===');
    
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
    
    // Test du clic
    menuIcon.on('click', function() {
        console.log('Clic sur le bouton menu');
        console.log('Largeur fenêtre:', $(window).width());
        console.log('Classes après clic:', $(this).attr('class'));
        console.log('Bloc mobile visible:', $('#mobile-categories-block').is(':visible'));
        console.log('Classes du bloc:', $('#mobile-categories-block').attr('class'));
        console.log('Left après clic:', $('#mobile-categories-block').css('left'));
        console.log('Computed style left:', window.getComputedStyle($('#mobile-categories-block')[0]).left);
    });
    
    // Vérifier le bouton de fermeture
    $(document).on('click', '#mobile-categories-block .close_menu', function() {
        console.log('Clic sur le bouton de fermeture');
    });
});
