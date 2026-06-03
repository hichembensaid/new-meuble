/**
 * CACHE QUICK VIEW - Version standalone
 * À ajouter dans themes/amazonas/assets/js/custom.js
 * 
 * Ce script ajoute un système de cache pour les Quick View
 * sans avoir besoin de recompiler tout le thème.
 */

(function($) {
  'use strict';
  
  // Cache pour Quick View
  const quickViewCache = {};
  const MAX_CACHE_SIZE = 30;
  
  // Sauvegarder la fonction originale prestashop.on
  const originalPrestashopOn = prestashop.on;
  
  // Intercepter les événements clickQuickView
  prestashop.on = function(eventName, callback) {
    if (eventName === 'clickQuickView') {
      // Remplacer par notre version avec cache
      originalPrestashopOn.call(prestashop, eventName, function(elm) {
        handleQuickViewWithCache(elm, callback);
      });
    } else {
      // Autres événements : comportement normal
      originalPrestashopOn.call(prestashop, eventName, callback);
    }
  };
  
  function handleQuickViewWithCache(elm, originalCallback) {
    // Créer une clé unique pour le cache
    const cacheKey = `${elm.dataset.idProduct}_${elm.dataset.idProductAttribute || '0'}`;
    
    // Vérifier si les données sont en cache
    if (quickViewCache[cacheKey]) {
      console.log('⚡ Quick View depuis le cache! Produit:', cacheKey);
      showQuickViewFromCache(quickViewCache[cacheKey]);
      return;
    }
    
    console.log('📡 Quick View chargement Ajax... Produit:', cacheKey);
    
    // Afficher le loader
    let loaderId = 'quickview-loader-cache';
    if (!$('#' + loaderId).length) {
      $('body').append(`
        <div id="${loaderId}" class="quickview-loader-overlay" style="
          position: fixed;
          top: 0;
          left: 0;
          width: 100%;
          height: 100%;
          background: rgba(0,0,0,0.5);
          z-index: 9999;
          display: flex;
          align-items: center;
          justify-content: center;
        ">
          <div class="quickview-spinner">
            <div class="spinner-border text-light" role="status">
              <span class="sr-only">Chargement...</span>
            </div>
          </div>
        </div>
      `);
    }
    $('#' + loaderId).fadeIn(200);
    
    // Faire la requête Ajax
    let data = {
      'action': 'quickview',
      'id_product': elm.dataset.idProduct,
      'id_product_attribute': elm.dataset.idProductAttribute,
    };
    
    $.post(prestashop.urls.pages.product, data, null, 'json')
      .then(function(resp) {
        // Gérer la taille du cache
        const cacheKeys = Object.keys(quickViewCache);
        if (cacheKeys.length >= MAX_CACHE_SIZE) {
          const oldestKey = cacheKeys[0];
          delete quickViewCache[oldestKey];
          console.log('🗑️ Cache Quick View nettoyé:', oldestKey);
        }
        
        // Mettre en cache
        quickViewCache[cacheKey] = resp;
        console.log(`💾 Quick View mis en cache (${Object.keys(quickViewCache).length}/${MAX_CACHE_SIZE})`);
        
        showQuickViewFromCache(resp);
      })
      .fail(function(xhr) {
        $('#' + loaderId).fadeOut(200, function() {
          $(this).remove();
        });
        console.error('❌ Erreur Quick View:', xhr);
      });
  }
  
  function showQuickViewFromCache(resp) {
    let loaderId = 'quickview-loader-cache';
    
    // Afficher le modal
    $('body').append(resp.quickview_html);
    let productModal = $(`#quickview-modal-${resp.product.id}-${resp.product.id_product_attribute}`);
    
    // Masquer le loader
    productModal.on('shown.bs.modal', function() {
      $('#' + loaderId).fadeOut(300, function() {
        $(this).remove();
      });
    });
    
    productModal.modal('show');
    
    // Initialiser les contrôles du modal
    if (typeof window.productConfig === 'function') {
      window.productConfig(productModal);
    }
    
    // Nettoyer à la fermeture
    productModal.on('hidden.bs.modal', function() {
      productModal.remove();
      if ($('#' + loaderId).length) {
        $('#' + loaderId).remove();
      }
    });
  }
  
  // Debug: Voir le contenu du cache
  window.viewQuickViewCache = function() {
    console.log('📦 Cache Quick View:', quickViewCache);
    console.log('📊 Produits en cache:', Object.keys(quickViewCache).length);
    return quickViewCache;
  };
  
  // Debug: Vider le cache manuellement
  window.clearQuickViewCache = function() {
    Object.keys(quickViewCache).forEach(key => delete quickViewCache[key]);
    console.log('🗑️ Cache Quick View vidé');
  };
  
  console.log('✅ Cache Quick View activé!');
  
})(jQuery);
