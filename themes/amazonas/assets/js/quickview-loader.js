/**
 * ========================================
 * LOADER PREMIUM QUICK VIEW
 * Affichage IMMÉDIAT au clic
 * ========================================
 */

// Attendre que jQuery soit chargé
if (typeof jQuery === 'undefined') {
    console.warn('⚠️ jQuery not loaded yet, waiting...');
    document.addEventListener('DOMContentLoaded', function() {
        if (typeof jQuery !== 'undefined') {
            initQuickViewLoaderScript();
        } else {
            console.error('❌ jQuery is still not available after DOMContentLoaded');
        }
    });
} else {
    initQuickViewLoaderScript();
}

function initQuickViewLoaderScript() {
(function($) {
    'use strict';

    var loaderShown = false;

    /**
     * Initialisation au chargement du DOM
     */
    $(document).ready(function() {
        initQuickViewLoader();
    });

    /**
     * Fonction principale
     */
    function initQuickViewLoader() {


        // INTERCEPTER LE CLIC AVANT PRESTASHOP - Priorité maximale
        $(document).on('click.quickviewLoader', '.quick-view', function(e) {
            
            // Afficher le loader immédiatement
            showLoaderOverlay();
            loaderShown = true;
        });

        // Surveiller l'apparition de la modal dans le DOM
        observeModalCreation();

        // Écouter l'événement PrestaShop
        if (typeof prestashop !== 'undefined') {
            prestashop.on('updateProduct', function() {
                setTimeout(hideLoaderOverlay, 300);
            });
        }
    }

    /**
     * Afficher un loader en overlay IMMÉDIAT
     */
    function showLoaderOverlay() {
        // Supprimer tout loader existant
        $('#quickview-loader-overlay').remove();
        
        // Créer le loader overlay
        var overlayHTML = `
            <div id="quickview-loader-overlay" style="
                position: fixed;
                top: 0;
                left: 0;
                right: 0;
                bottom: 0;
                background: rgba(70, 44, 29, 0.85);
                z-index: 9999;
                display: flex;
                align-items: center;
                justify-content: center;
            ">
                <div style="text-align: center;">
                    <div class="quickview-loading">
                        <div class="loading-text">Chargement du produit...</div>
                    </div>
                </div>
            </div>
        `;
        
        $('body').append(overlayHTML);
    }

    /**
     * Masquer le loader overlay
     */
    function hideLoaderOverlay() {
        var $overlay = $('#quickview-loader-overlay');
        
        if ($overlay.length > 0) {
            
            $overlay.fadeOut(300, function() {
                $(this).remove();
                loaderShown = false;
            });
        }
    }

    /**
     * Observer l'apparition de la modal dans le DOM
     */
    function observeModalCreation() {
        // MutationObserver pour détecter l'ajout de la modal
        var observer = new MutationObserver(function(mutations) {
            mutations.forEach(function(mutation) {
                if (mutation.addedNodes.length > 0) {
                    mutation.addedNodes.forEach(function(node) {
                        if (node.nodeType === 1) {
                            var $node = $(node);
                            
                            // Vérifier si c'est une modal quickview
                            if ($node.hasClass('modal') && 
                                ($node.hasClass('quickview') || $node.find('.quickview').length > 0)) {    
                                // Attendre que le contenu soit chargé
                                watchModalContent($node);
                            }
                        }
                    });
                }
            });
        });
        
        // Observer le body pour l'ajout d'éléments
        observer.observe(document.body, {
            childList: true,
            subtree: false
        });
    }

    /**
     * Surveiller le chargement du contenu de la modal
     */
    function watchModalContent($modal) {
        var checkAttempts = 0;
        var maxAttempts = 25; // 5 secondes max
        
        var checkInterval = setInterval(function() {
            checkAttempts++;
            
            if (isModalReady($modal)) {
                clearInterval(checkInterval);
                hideLoaderOverlay();
            } else if (checkAttempts >= maxAttempts) {
                clearInterval(checkInterval);
                hideLoaderOverlay();
            }
        }, 200);
    }

    /**
     * Vérifier si la modal est prête
     */
    function isModalReady($modal) {
        var $modalBody = $modal.find('.modal-body');
        
        if ($modalBody.length === 0) return false;
        
        var hasTitle = $modal.find('.product-title, h1.h1').filter(function() {
            return $(this).text().trim().length > 3;
        }).length > 0;
        
        var hasPrice = $modal.find('.price, .product-price').length > 0;
        var hasImage = $modal.find('img[src*="http"]').length > 0;
        
        return hasTitle && hasPrice && hasImage;
    }

    /**
     * Nettoyer à la fermeture de la modal
     */
    $(document).on('hidden.bs.modal', '.modal', function() {
        hideLoaderOverlay();
    });

    /**
     * Gérer le loader sur les boutons
     */
    $(document).on('click', '.add-to-cart, button[data-button-action="add-to-cart"]', function() {
        var $btn = $(this);
        $btn.addClass('btn-loading');
        
        setTimeout(function() {
            $btn.removeClass('btn-loading');
        }, 3000);
    });

    if (typeof prestashop !== 'undefined') {
        prestashop.on('updateCart', function() {
            $('.btn-loading').removeClass('btn-loading');
        });
    }

})(jQuery);
}
