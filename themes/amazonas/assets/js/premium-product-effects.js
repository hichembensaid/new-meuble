/**
 * ========================================
 * EFFETS PREMIUM POUR LISTING PRODUITS
 * Design Haute Ébénisterie / Luxe
 * ========================================
 */

(function($) {
    'use strict';

    /**
     * Initialisation au chargement du DOM
     */
    $(document).ready(function() {
        initPremiumProductEffects();
    });

    /**
     * Fonction principale d'initialisation
     */
    function initPremiumProductEffects() {
        // 0. DÉSACTIVER OWL CAROUSEL ET FORCER GRILLE
        destroyOwlCarouselAndEnableGrid();
        
        // 1. Lazy loading images avec effet fade
        initLazyLoadingImages();
        
        // 2. Animation d'entrée des cartes
        initCardAnimations();
        
        // 3. Effet parallaxe subtil sur hover
        initParallaxEffect();
        
        // 4. Amélioration des boutons d'action
        enhanceActionButtons();
        
        // 5. Ajout du badge "Création Exclusive" si applicable
        addExclusiveBadges();
        
        // 6. Gestion du wishlist premium
        enhanceWishlist();
        
        // 7. Effet sonore subtil (optionnel)
        // initSoundEffects();
    }

    /**
     * 0. DÉSACTIVER OWL CAROUSEL ET FORCER GRILLE CSS
     */
    function destroyOwlCarouselAndEnableGrid() {

        
        // Attendre que Owl soit complètement initialisé
        setTimeout(function() {
            // Sélectionner tous les carousels de produits
            var $owlCarousels = $('.products.owl-carousel');
            

            
            if ($owlCarousels.length > 0) {
                $owlCarousels.each(function() {
                    var $carousel = $(this);

                    
                    // Détruire Owl Carousel si initialisé
                    if ($carousel.hasClass('owl-loaded')) {

                        $carousel.trigger('destroy.owl.carousel');
                        $carousel.removeClass('owl-loaded owl-drag owl-grab');
                        
                        // Extraire les articles du wrapper Owl
                        var $articles = $carousel.find('article');

                        
                        // Retirer toute la structure Owl
                        $carousel.find('.owl-stage-outer').remove();
                        $carousel.find('.owl-nav, .owl-dots').remove();
                        
                        // Remettre les articles directement dans le conteneur
                        $carousel.empty().append($articles);
                        
                        // Nettoyer les styles inline des articles
                        $articles.each(function() {
                            $(this).removeAttr('style');
                        });
                        
                        // Forcer la classe CSS Grid
                        $carousel.addClass('premium-grid-layout').removeClass('owl-carousel product_list');
                        
                    } 
                });
            } 
        }, 1000); // Attendre 1 seconde que Owl soit initialisé
    }

    /**
     * 1. Lazy Loading avec effet fade-in élégant
     */
    function initLazyLoadingImages() {
        // Vérifier si IntersectionObserver est supporté
        if (!('IntersectionObserver' in window)) {
            // Fallback : afficher toutes les images immédiatement
            document.querySelectorAll('.product-miniature img').forEach(img => {
                img.style.opacity = '1';
            });
            return;
        }

        const imageObserver = new IntersectionObserver((entries, observer) => {
            entries.forEach(entry => {
                if (entry.isIntersecting) {
                    const img = entry.target;
                    
                    // Si l'image a déjà un src, on l'affiche
                    if (img.src && img.src !== '') {
                        img.style.opacity = '1';
                    }
                    
                    // Vérifier data-src pour lazy loading
                    const dataSrc = img.getAttribute('data-src');
                    if (dataSrc && dataSrc !== img.src) {
                        img.src = dataSrc;
                    }
                    
                    img.addEventListener('load', function() {
                        img.classList.add('loaded');
                        img.style.opacity = '1';
                    });
                    
                    // Afficher l'image après un court délai si elle ne charge pas
                    setTimeout(() => {
                        img.style.opacity = '1';
                    }, 100);
                    
                    observer.unobserve(img);
                }
            });
        }, {
            rootMargin: '50px'
        });

        document.querySelectorAll('.product-miniature img').forEach(img => {
            // Ne pas masquer les images qui ont déjà un src
            if (!img.src || img.src === '') {
                img.style.opacity = '0';
            } else {
                img.style.opacity = '1';
            }
            img.style.transition = 'opacity 0.6s cubic-bezier(0.4, 0, 0.2, 1)';
            imageObserver.observe(img);
        });
    }

    /**
     * 2. Animation d'entrée progressive des cartes
     */
    function initCardAnimations() {
        const cards = document.querySelectorAll('.product-miniature');
        
        const cardObserver = new IntersectionObserver((entries) => {
            entries.forEach((entry, index) => {
                if (entry.isIntersecting) {
                    setTimeout(() => {
                        entry.target.style.opacity = '1';
                        entry.target.style.transform = 'translateY(0)';
                    }, index * 100); // Délai progressif
                    
                    cardObserver.unobserve(entry.target);
                }
            });
        }, {
            threshold: 0.1
        });

        cards.forEach((card, index) => {
            card.style.opacity = '0';
            card.style.transform = 'translateY(30px)';
            card.style.transition = 'opacity 0.6s ease, transform 0.6s ease';
            cardObserver.observe(card);
        });
    }

    /**
     * 3. Effet parallaxe subtil sur l'image
     */
    function initParallaxEffect() {
        $('.product-miniature').on('mousemove', function(e) {
            if (window.innerWidth < 768) return; // Désactivé sur mobile
            
            const $card = $(this);
            const $img = $card.find('.thumbnail.product-thumbnail img');
            
            const cardWidth = $card.width();
            const cardHeight = $card.height();
            const mouseX = e.pageX - $card.offset().left;
            const mouseY = e.pageY - $card.offset().top;
            
            const rotateX = ((mouseY / cardHeight) - 0.5) * 5; // Max 5deg
            const rotateY = ((mouseX / cardWidth) - 0.5) * -5;
            
            $img.css({
                'transform': `scale(1.05) rotateX(${rotateX}deg) rotateY(${rotateY}deg)`,
                'transition': 'transform 0.3s ease'
            });
        });

        $('.product-miniature').on('mouseleave', function() {
            $(this).find('.thumbnail.product-thumbnail img').css({
                'transform': 'scale(1) rotateX(0) rotateY(0)',
                'transition': 'transform 0.6s ease'
            });
        });
    }

    /**
     * 4. Amélioration des boutons d'action avec feedback
     */
    function enhanceActionButtons() {
        $('.product-miniature .highlighted-informations a, .product-miniature .highlighted-informations button').each(function() {
            const $btn = $(this);
            
            // Effet ripple au clic
            $btn.on('click', function(e) {
                const $ripple = $('<span class="ripple-effect"></span>');
                const btnOffset = $btn.offset();
                const x = e.pageX - btnOffset.left;
                const y = e.pageY - btnOffset.top;
                
                $ripple.css({
                    position: 'absolute',
                    top: y + 'px',
                    left: x + 'px',
                    width: '0',
                    height: '0',
                    borderRadius: '50%',
                    background: 'rgba(255, 255, 255, 0.6)',
                    transform: 'translate(-50%, -50%)',
                    animation: 'ripple-animation 0.6s ease-out',
                    pointerEvents: 'none',
                    zIndex: '10'
                });
                
                $btn.css('position', 'relative').append($ripple);
                
                setTimeout(() => $ripple.remove(), 600);
            });

            // Tooltip élégant
            const tooltips = {
                'search': 'Voir les détails',
                'visibility': 'Aperçu rapide',
                'favorite': 'Ajouter aux favoris',
                'shopping_cart': 'Ajouter au panier'
            };

            const iconClass = $btn.find('i').text().trim();
            if (tooltips[iconClass]) {
                $btn.attr('data-tooltip', tooltips[iconClass]);
                $btn.attr('aria-label', tooltips[iconClass]);
            }
        });

        // CSS pour l'animation ripple
        if (!$('#ripple-animation-style').length) {
            $('head').append(`
                <style id="ripple-animation-style">
                    @keyframes ripple-animation {
                        to {
                            width: 100px;
                            height: 100px;
                            opacity: 0;
                        }
                    }
                    
                    [data-tooltip] {
                        position: relative;
                    }
                    
                    [data-tooltip]::after {
                        content: attr(data-tooltip);
                        position: absolute;
                        bottom: 120%;
                        left: 50%;
                        transform: translateX(-50%) translateY(-5px);
                        padding: 8px 12px;
                        background: rgba(44, 44, 44, 0.95);
                        color: #D4AF37;
                        font-size: 11px;
                        font-family: 'Montserrat', sans-serif;
                        font-weight: 500;
                        letter-spacing: 0.5px;
                        white-space: nowrap;
                        border-radius: 4px;
                        pointer-events: none;
                        opacity: 0;
                        transition: all 0.3s ease;
                        z-index: 1000;
                    }
                    
                    [data-tooltip]::before {
                        content: '';
                        position: absolute;
                        bottom: 100%;
                        left: 50%;
                        transform: translateX(-50%);
                        border: 6px solid transparent;
                        border-top-color: rgba(44, 44, 44, 0.95);
                        opacity: 0;
                        transition: all 0.3s ease;
                        z-index: 1000;
                    }
                    
                    [data-tooltip]:hover::after,
                    [data-tooltip]:hover::before {
                        opacity: 1;
                        transform: translateX(-50%) translateY(0);
                    }
                </style>
            `);
        }
    }

    /**
     * 5. Ajout automatique du badge "Création Exclusive"
     */
    function addExclusiveBadges() {
        $('.product-miniature').each(function() {
            const $card = $(this);
            const $description = $card.find('.product-description');
            
            // Ajouter seulement si pas déjà présent
            if (!$description.find('.exclusive-badge').length) {
                // Vérifier si c'est un produit premium (vous pouvez adapter la condition)
                const isExclusive = $card.find('.product-flags .new').length > 0 || 
                                   $card.data('exclusive') === true;
                
                if (isExclusive) {
                    const $badge = $('<div class="exclusive-badge">Une création exclusive</div>');
                    $description.find('.product-title').after($badge);
                }
            }
            
            // Ajouter un séparateur décoratif
            if (!$description.find('.product-separator').length) {
                const $separator = $('<div class="product-separator"></div>');
                $description.append($separator);
            }
        });
    }

    /**
     * 6. Amélioration du wishlist avec animation
     */
    function enhanceWishlist() {
        $(document).on('click', '.wishlist-button-add, .addToWishlist', function(e) {
            const $btn = $(this);
            const $icon = $btn.find('i');
            
            // Animation coeur qui bat
            $icon.css({
                'animation': 'heartbeat 0.6s ease',
                'color': '#EE6751'
            });
            
            setTimeout(() => {
                $icon.css('animation', '');
            }, 600);
        });

        // CSS pour l'animation heartbeat
        if (!$('#heartbeat-animation-style').length) {
            $('head').append(`
                <style id="heartbeat-animation-style">
                    @keyframes heartbeat {
                        0%, 100% { transform: scale(1); }
                        25% { transform: scale(1.3); }
                        50% { transform: scale(1.1); }
                        75% { transform: scale(1.4); }
                    }
                </style>
            `);
        }
    }

    /**
     * 7. Effet sonore subtil (optionnel - à activer si souhaité)
     */
    function initSoundEffects() {
        // Son subtil lors du hover (très discret)
        const hoverSound = new Audio('data:audio/wav;base64,UklGRnoGAABXQVZFZm10IBAAAAABAAEAQB8AAEAfAAABAAgAZGF0YQoGAACBhYqFbF1fdJivrJBhNjVgodDbq2EcBj+a2/LDciUFLIHO8tiJNwgZaLvt559NEAxQp+PwtmMcBjiR1/LMeSwFJHfH8N2QQAoUXrTp66hVFApGn+DyvmwhBi+J0fPTgDcHHm7A7+OZVRE=');
        hoverSound.volume = 0.1;
        
        $('.product-miniature').on('mouseenter', function() {
            if (window.innerWidth >= 768) {
                // hoverSound.currentTime = 0;
                // hoverSound.play().catch(() => {}); // Silently fail si autoplay bloqué
            }
        });
    }

    /**
     * Optimisation des performances - Throttle des événements
     */
    function throttle(func, delay) {
        let timeoutId;
        let lastExecTime = 0;
        
        return function(...args) {
            const currentTime = Date.now();
            const timeSinceLastExec = currentTime - lastExecTime;
            
            if (timeSinceLastExec >= delay) {
                func.apply(this, args);
                lastExecTime = currentTime;
            } else {
                clearTimeout(timeoutId);
                timeoutId = setTimeout(() => {
                    func.apply(this, args);
                    lastExecTime = Date.now();
                }, delay - timeSinceLastExec);
            }
        };
    }

    /**
     * Ajout de la signature "Banquette & Cie" (comme sur la maquette)
     */
    function addBrandSignature() {
        $('.product-miniature .product-description').each(function() {
            if (!$(this).find('.brand-signature').length) {
                // $(this).append('<div class="brand-signature">◆</div>');
            }
        });
    }

    /**
     * Export pour utilisation externe
     */
    window.PremiumProductEffects = {
        init: initPremiumProductEffects,
        refresh: function() {
            // Réinitialiser après un chargement AJAX
            setTimeout(initPremiumProductEffects, 100);
        }
    };

    /**
     * Réinitialiser après chargement AJAX (pagination, filtres, etc.)
     */
    if (typeof prestashop !== 'undefined') {
        prestashop.on('updatedProductList', function() {
            setTimeout(initPremiumProductEffects, 200);
        });
    }

})(jQuery);
