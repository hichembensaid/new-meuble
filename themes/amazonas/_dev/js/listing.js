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
import $ from 'jquery';
import prestashop from 'prestashop';
import 'velocity-animate';

import ProductMinitature from './components/product-miniature';

// Cache pour Quick View - Optimisation performance
const quickViewCache = {};
const MAX_CACHE_SIZE = 30;

$(document).ready(() => {
  prestashop.on('clickQuickView', function (elm) {
    // Créer une clé unique pour le cache
    const cacheKey = `${elm.dataset.idProduct}_${elm.dataset.idProductAttribute || '0'}`;
    
    // Vérifier si les données sont en cache
    if (quickViewCache[cacheKey]) {
      console.log('⚡ Quick View depuis le cache!');
      showQuickViewModal(quickViewCache[cacheKey]);
      return;
    }
    
    // Afficher le loader
    let loaderId = 'quickview-loader';
    if (!$('#' + loaderId).length) {
      $('body').append(`
        <div id="${loaderId}" class="quickview-loader-overlay">
          <div class="quickview-spinner">
            <div class="spinner-border" role="status">
              <span class="sr-only">Chargement...</span>
            </div>
          </div>
        </div>
      `);
    }
    $('#' + loaderId).fadeIn(200);
    
    let data = {
      'action': 'quickview',
      'id_product': elm.dataset.idProduct,
      'id_product_attribute': elm.dataset.idProductAttribute,
    };
    $.post(prestashop.urls.pages.product, data, null, 'json').then(function (resp) {
      // Gérer la taille du cache (limiter à MAX_CACHE_SIZE produits)
      const cacheKeys = Object.keys(quickViewCache);
      if (cacheKeys.length >= MAX_CACHE_SIZE) {
        delete quickViewCache[cacheKeys[0]]; // Supprimer le plus ancien
        console.log('🗑️ Cache Quick View nettoyé (limite atteinte)');
      }
      
      // Mettre en cache la réponse
      quickViewCache[cacheKey] = resp;
      console.log(`💾 Quick View mis en cache (${cacheKeys.length + 1}/${MAX_CACHE_SIZE})`);
      
      showQuickViewModal(resp);
    }).fail((resp) => {
      // Masquer le loader en cas d'erreur
      $('#' + loaderId).fadeOut(200, function() {
        $(this).remove();
      });
      prestashop.emit('handleError', {eventType: 'clickQuickView', resp: resp});
    });
  });

  // Fonction helper pour afficher le modal Quick View
  function showQuickViewModal(resp) {
    let loaderId = 'quickview-loader';
    
    $('body').append(resp.quickview_html);
    let productModal = $(`#quickview-modal-${resp.product.id}-${resp.product.id_product_attribute}`);
    
    // Masquer le loader après que le modal soit affiché
    productModal.on('shown.bs.modal', function() {
      $('#' + loaderId).fadeOut(300, function() {
        $(this).remove();
      });
    });
    
    productModal.modal('show');
    productConfig(productModal);
    
    productModal.on('hidden.bs.modal', function () {
      productModal.remove();
      // Au cas où le loader serait encore là
      if ($('#' + loaderId).length) {
        $('#' + loaderId).remove();
      }
    });
  }

  var productConfig = (qv) => {
    const MAX_THUMBS = 4;
    var $arrows = $('.js-arrows');
    var $thumbnails = qv.find('.js-qv-product-images');
    $('.js-thumb').on('click', (event) => {
      if ($('.js-thumb').hasClass('selected')) {
        $('.js-thumb').removeClass('selected');
      }
      $(event.currentTarget).addClass('selected');
      $('.js-qv-product-cover').attr('src', $(event.target).data('image-large-src'));
    });
    if ($thumbnails.find('li').length <= MAX_THUMBS) {
      $arrows.hide();
    } else {
      $arrows.on('click', (event) => {
        if ($(event.target).hasClass('arrow-up') && $('.js-qv-product-images').position().top < 0) {
          move('up');
          $('.arrow-down').css('opacity', '1');
        } else if ($(event.target).hasClass('arrow-down') && $thumbnails.position().top + $thumbnails.height() > $('.js-qv-mask').height()) {
          move('down');
          $('.arrow-up').css('opacity', '1');
        }
      });
    }
    qv.find('#quantity_wanted').TouchSpin({
      verticalbuttons: true,
      verticalupclass: 'material-icons touchspin-up',
      verticaldownclass: 'material-icons touchspin-down',
      buttondown_class: 'btn btn-touchspin js-touchspin',
      buttonup_class: 'btn btn-touchspin js-touchspin',
      min: 1,
      max: 1000000
    });
  };
  var move = (direction) => {
    const THUMB_MARGIN = 20;
    var $thumbnails = $('.js-qv-product-images');
    var thumbHeight = $('.js-qv-product-images li img').height() + THUMB_MARGIN;
    var currentPosition = $thumbnails.position().top;
    $thumbnails.velocity({
      translateY: (direction === 'up') ? currentPosition + thumbHeight : currentPosition - thumbHeight
    }, function () {
      if ($thumbnails.position().top >= 0) {
        $('.arrow-up').css('opacity', '.2');
      } else if ($thumbnails.position().top + $thumbnails.height() <= $('.js-qv-mask').height()) {
        $('.arrow-down').css('opacity', '.2');
      }
    });
  };
  $('body').on('click', '#search_filter_toggler', function () {
    $('#search_filters_wrapper').removeClass('hidden-sm-down');
    $('#content-wrapper').addClass('hidden-sm-down');
    $('#footer').addClass('hidden-sm-down');
  });
  $('#search_filter_controls .clear').on('click', function () {
    $('#search_filters_wrapper').addClass('hidden-sm-down');
    $('#content-wrapper').removeClass('hidden-sm-down');
    $('#footer').removeClass('hidden-sm-down');
  });
  $('#search_filter_controls .ok').on('click', function () {
    $('#search_filters_wrapper').addClass('hidden-sm-down');
    $('#content-wrapper').removeClass('hidden-sm-down');
    $('#footer').removeClass('hidden-sm-down');
  });

  const parseSearchUrl = function (event) {
    if (event.target.dataset.searchUrl !== undefined) {
      return event.target.dataset.searchUrl;
    }

    if ($(event.target).parent()[0].dataset.searchUrl === undefined) {
      throw new Error('Can not parse search URL');
    }

    return $(event.target).parent()[0].dataset.searchUrl;
  };

  $('body').on('change', '#search_filters input[data-search-url]', function (event) {
    prestashop.emit('updateFacets', parseSearchUrl(event));
  });

  $('body').on('click', '.js-search-filters-clear-all', function (event) {
    prestashop.emit('updateFacets', parseSearchUrl(event));
  });

  $('body').on('click', '.js-search-link', function (event) {
    event.preventDefault();
    prestashop.emit('updateFacets',$(event.target).closest('a').get(0).href);
  });

  $('body').on('change', '#search_filters select', function (event) {
    const form = $(event.target).closest('form');
    prestashop.emit('updateFacets', '?' + form.serialize());
  });

  prestashop.on('updateProductList', (data) => {
    updateProductListDOM(data);
  });
});

function updateProductListDOM (data) {
  $('#search_filters').replaceWith(data.rendered_facets);
  $('#js-active-search-filters').replaceWith(data.rendered_active_filters);
  $('#js-product-list-top').replaceWith(data.rendered_products_top);
  $('#js-product-list').replaceWith(data.rendered_products);
  $('#js-product-list-bottom').replaceWith(data.rendered_products_bottom);

  let productMinitature = new ProductMinitature();
  productMinitature.init();

}
