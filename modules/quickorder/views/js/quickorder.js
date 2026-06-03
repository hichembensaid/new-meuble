/**
 * quickorder.js - Frontend Commande Rapide
 * Compatible ES5+ / PHP 7.4
 */

'use strict';

console.log('[QuickOrder] JS charge OK');

(function () {

    var MODAL_ID    = '#quickOrderModal';
    var FORM_ID     = '#quickOrderForm';
    var ALERT_ID    = '#qo-alert';
    var SUBMIT_ID   = '#qo-submit';
    var BTN_CLASS   = '.quickorder-btn';
    var PHONE_REGEX = /^[0-9+\s\-]{8,20}$/;

    document.addEventListener('DOMContentLoaded', function () {
        console.log('[QuickOrder] DOM ready');
        bindTriggerButton();
        bindSubmitButton();
        bindModalReset();
        var form = document.querySelector(FORM_ID);
        if (form) bindLiveValidation(form);
    });

    function bindTriggerButton() {
        document.addEventListener('click', function (e) {
            var btn = e.target.closest ? e.target.closest(BTN_CLASS) : null;
            if (!btn) return;
            console.log('[QuickOrder] Ouverture modal, product_id=' + btn.dataset.productId);

            // Fermer tout modal Bootstrap ouvert (quickview, etc.) avant d'ouvrir le quickorder
            var openModals = document.querySelectorAll('.modal.show, .modal.in');
            openModals.forEach(function (m) {
                if (m.id !== 'quickOrderModal') {
                    if (window.$ || window.jQuery) {
                        (window.$ || window.jQuery)(m).modal('hide');
                    } else {
                        m.classList.remove('show', 'in');
                        m.style.display = 'none';
                    }
                }
            });
            // Supprimer les backdrops résiduels
            document.querySelectorAll('.modal-backdrop').forEach(function (bd) {
                bd.parentNode && bd.parentNode.removeChild(bd);
            });
            document.body.classList.remove('modal-open');

            var nameEl = document.getElementById('qo-product-name');
            if (nameEl) nameEl.textContent = btn.dataset.productName || '';

            var form = document.querySelector(FORM_ID);
            if (form) {
                form.dataset.productId = btn.dataset.productId || '0';
                var attrInput = document.getElementById('idCombination') || document.getElementById('product_attribute_id') || document.querySelector('input[name="id_product_attribute"]');
                if (attrInput) form.dataset.productAttr = attrInput.value || '0';
                var qtyInput = document.getElementById('quantity_wanted') || document.querySelector('input[name="qty"]');
                var qty = qtyInput ? (parseInt(qtyInput.value) || 1) : 1;
                form.dataset.qty = qty;

                // --- Remplir prix, quantité, total dans le résumé ---
                var qtyEl   = document.getElementById('qo-product-qty');
                var priceEl = document.getElementById('qo-product-price');
                var totalEl = document.getElementById('qo-product-total');

                if (qtyEl) qtyEl.textContent = qty;

                // Récupérer le prix depuis la page (span.price ou span.product-price)
                var priceSpan = document.querySelector('.product-prices .price, .price[itemprop="price"], span.price');
                if (priceSpan && priceEl) {
                    var priceText = priceSpan.textContent.trim();
                    priceEl.textContent = priceText;

                    // Calculer le total : extraire la valeur numérique
                    if (totalEl) {
                        var numericPrice = parseFloat(priceText.replace(/[^\d,\.]/g, '').replace(',', '.'));
                        if (!isNaN(numericPrice)) {
                            var total = (numericPrice * qty).toFixed(3);
                            // Remettre le format avec la devise
                            var currency = priceText.replace(/[\d\s,\.]+/, '').trim();
                            totalEl.textContent = total.replace('.', ',') + '\u00a0' + currency;
                        } else {
                            totalEl.textContent = '—';
                        }
                    }
                }
            }
        });
    }

    function bindSubmitButton() {
        document.addEventListener('click', function (e) {
            var btn = e.target.closest ? e.target.closest(SUBMIT_ID) : null;
            if (!btn) return;
            console.log('[QuickOrder] Confirmer clique');
            e.preventDefault();
            e.stopPropagation();
            var form = document.querySelector(FORM_ID);
            if (!form) { console.error('[QuickOrder] Formulaire introuvable'); return; }
            clearAlert();
            var errors = validateForm(form);
            if (errors.length) {
                showAlert('danger', '<strong>Veuillez corriger les champs suivants :</strong><ul class="mb-0 mt-1">' +
                    errors.map(function (e) { return '<li>' + e + '</li>'; }).join('') + '</ul>');
                return;
            }
            submitOrder(form, btn);
        });
    }

    function submitOrder(form, btn) {
        setLoading(btn, true);
        var fd = new FormData(form);
        var payload = {
            action:               'submitOrder',
            token:                form.dataset.token || '',
            id_product:           form.dataset.productId || '0',
            id_product_attribute: form.dataset.productAttr || '0',
            qty:                  form.dataset.qty || '1',
            firstname:            fd.get('firstname') || '',
            lastname:             fd.get('lastname')  || '',
            phone:                fd.get('phone')     || '',
            address1:             fd.get('address1')  || '',
            city:                 fd.get('city')      || '',
            postcode:             fd.get('postcode')  || '',
            comment:              fd.get('comment')   || ''
        };
        console.log('[QuickOrder] Envoi vers', form.dataset.ajaxUrl, payload);
        fetch(form.dataset.ajaxUrl, {
            method: 'POST',
            headers: { 'Content-Type': 'application/x-www-form-urlencoded', 'X-Requested-With': 'XMLHttpRequest' },
            body: new URLSearchParams(payload).toString(),
            credentials: 'same-origin'
        })
        .then(function (r) {
            return r.text().then(function (text) {
                console.log('[QuickOrder] Reponse brute:', text.substring(0, 500));
                var data;
                try { data = JSON.parse(text); } catch (e) { 
                    setLoading(btn, false); 
                    showAlert('danger', 'Erreur serveur (' + r.status + '). Voir console F12.'); 
                    return; 
                }
                if (data.success) {
                    // Cacher le formulaire mais garder les boutons
                    form.style.display = 'none';
                    showAlert('success', data.message || 'Commande enregistree !');
                    
                    // Transformer le bouton "Confirmer" en bouton "Fermer"
                    setLoading(btn, false); // Arrêter le spinner
                    var label = btn.querySelector('.qo-submit__label');
                    if (label) {
                        label.innerHTML = '<i class="material-icons small" aria-hidden="true">&#xe5cd;</i> Fermer';
                    }
                    btn.classList.remove('btn-warning', 'quickorder-submit');
                    btn.classList.add('btn-secondary');
                    
                    // Cacher le bouton Annuler
                    var cancelBtn = document.querySelector(MODAL_ID + ' .btn-outline-secondary');
                    if (cancelBtn) cancelBtn.style.display = 'none';
                    
                    // Le bouton "Fermer" fermera le modal au clic
                    btn.onclick = function() {
                        if (window.$ && typeof window.$.fn.modal === 'function') {
                            window.$(MODAL_ID).modal('hide');
                        }
                    };
                    
                    // NE PAS fermer automatiquement
                } else {
                    setLoading(btn, false); // Réactiver seulement en cas d'erreur
                    showAlert('danger', data.message || 'Une erreur est survenue.');
                }
            });
        })
        .catch(function (err) { setLoading(btn, false); showAlert('danger', 'Erreur reseau: ' + err.message); });
    }

    /* ── Règles de validation centralisées ─────────────────────────────────── */
    var FIELD_RULES = [
        {
            name:    'firstname',
            label:   'Prénom',
            test:    function (v) { return v.trim().length >= 2; },
            msg:     'Veuillez saisir votre prénom (min. 2 caractères).'
        },
        {
            name:    'lastname',
            label:   'Nom',
            test:    function (v) { return v.trim().length >= 2; },
            msg:     'Veuillez saisir votre nom de famille (min. 2 caractères).'
        },
        {
            name:    'phone',
            label:   'Téléphone',
            test:    function (v) { return PHONE_REGEX.test(v.trim()); },
            msg:     'Numéro de téléphone invalide (ex : 98 000 000).'
        },
        {
            name:    'address1',
            label:   'Adresse',
            test:    function (v) { return v.trim().length >= 5; },
            msg:     'Veuillez saisir votre adresse de livraison complète.'
        },
        {
            name:    'city',
            label:   'Ville',
            test:    function (v) { return v.trim().length > 0; },
            msg:     'Veuillez indiquer votre ville.'
        },
        {
            name:    'postcode',
            label:   'Code postal',
            test:    function (v) { return v.trim().length > 0; },
            msg:     'Veuillez saisir votre code postal.'
        }
    ];

    function validateForm(form) {
        var errors = [];
        clearFieldErrors(form);
        FIELD_RULES.forEach(function (rule) {
            var input = form.querySelector('[name="' + rule.name + '"]');
            if (!input || !rule.test(input.value)) {
                if (input) setFieldError(input, rule.msg);
                errors.push('<strong>' + rule.label + '</strong> — ' + rule.msg);
            }
        });
        return errors;
    }

    /* ── Validation en temps réel : mise à jour de l'alerte au fur et à mesure ─ */
    function bindLiveValidation(form) {
        FIELD_RULES.forEach(function (rule) {
            var input = form.querySelector('[name="' + rule.name + '"]');
            if (!input) return;
            input.addEventListener('input', function () { refreshAlert(form); });
            input.addEventListener('change', function () { refreshAlert(form); });
        });
    }

    function refreshAlert(form) {
        /* Ne rien faire si l'alerte n'est pas visible (pas encore soumis) */
        var alertEl = document.querySelector(ALERT_ID);
        if (!alertEl || alertEl.style.display === 'none') return;
        /* Recalculer les erreurs restantes sans ré-afficher les invalid-feedback déjà visibles */
        var remaining = [];
        FIELD_RULES.forEach(function (rule) {
            var input = form.querySelector('[name="' + rule.name + '"]');
            if (!input) return;
            if (!rule.test(input.value)) {
                remaining.push('<strong>' + rule.label + '</strong> — ' + rule.msg);
                input.classList.add('is-invalid');
                var fb = input.nextElementSibling;
                if (fb && fb.classList.contains('invalid-feedback')) fb.textContent = rule.msg;
            } else {
                input.classList.remove('is-invalid');
                input.classList.add('is-valid');
                var fb2 = input.nextElementSibling;
                if (fb2 && fb2.classList.contains('invalid-feedback')) fb2.textContent = '';
            }
        });
        if (remaining.length === 0) {
            clearAlert();
        } else {
            showAlert('danger', '<strong>Veuillez corriger les champs suivants :</strong><ul class="mb-0 mt-1">' +
                remaining.map(function (e) { return '<li>' + e + '</li>'; }).join('') + '</ul>');
        }
    }

    function setFieldError(input, msg) {
        input.classList.add('is-invalid');
        var fb = input.nextElementSibling;
        if (fb && fb.classList.contains('invalid-feedback')) fb.textContent = msg;
    }

    function clearFieldErrors(form) {
        var els = form.querySelectorAll('.is-invalid');
        for (var i = 0; i < els.length; i++) els[i].classList.remove('is-invalid');
        var fbs = form.querySelectorAll('.invalid-feedback');
        for (var j = 0; j < fbs.length; j++) fbs[j].textContent = '';
    }

    function showAlert(type, message) {
        var el = document.querySelector(ALERT_ID);
        if (!el) return;
        el.className = 'alert alert-' + type;
        el.innerHTML = message;
        el.style.display = 'block';
    }

    function clearAlert() {
        var el = document.querySelector(ALERT_ID);
        if (!el) return;
        el.className = 'alert';
        el.innerHTML = '';
        el.style.display = 'none';
    }

    function setLoading(btn, loading) {
        if (!btn) return;
        btn.disabled = loading;
        var label   = btn.querySelector('.qo-submit__label');
        var spinner = btn.querySelector('.qo-submit__loading');
        if (label)   label.style.display   = loading ? 'none'        : 'inline-flex';
        if (spinner) spinner.style.display = loading ? 'inline-flex' : 'none';
    }

    function bindModalReset() {
        if (window.$) {
            window.$(document).on('hidden.bs.modal', MODAL_ID, function () {
                var form = document.querySelector(FORM_ID);
                if (!form) return;
                form.reset(); form.style.display = '';
                clearFieldErrors(form); clearAlert();
                
                var btn = document.querySelector(SUBMIT_ID);
                if (btn) {
                    // Réinitialiser complètement le bouton
                    setLoading(btn, false);
                    var label = btn.querySelector('.qo-submit__label');
                    if (label) {
                        label.innerHTML = '<i class="material-icons small" aria-hidden="true">&#xe558;</i> Confirmer ma commande';
                    }
                    btn.classList.remove('btn-secondary');
                    btn.classList.add('btn-warning', 'quickorder-submit');
                    btn.onclick = null; // Retirer le handler de fermeture
                }
                
                // Réafficher le bouton Annuler
                var cancelBtn = document.querySelector(MODAL_ID + ' .btn-outline-secondary');
                if (cancelBtn) cancelBtn.style.display = '';
            });
        }
    }

})();
