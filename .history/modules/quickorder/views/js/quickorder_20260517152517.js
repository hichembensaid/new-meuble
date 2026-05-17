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
            if (errors.length) { showAlert('danger', errors.join('<br>')); return; }
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
                setLoading(btn, false);
                var data;
                try { data = JSON.parse(text); } catch (e) { showAlert('danger', 'Erreur serveur (' + r.status + '). Voir console F12.'); return; }
                if (data.success) {
                    form.style.display = 'none';
                    var footer = document.querySelector(MODAL_ID + ' .modal-footer');
                    if (footer) footer.style.display = 'none';
                    showAlert('success', data.message || 'Commande enregistree !');
                    setTimeout(function () {
                        if (window.$ && typeof window.$.fn.modal === 'function') window.$(MODAL_ID).modal('hide');
                        form.reset(); form.style.display = '';
                        clearAlert();
                        if (footer) footer.style.display = '';
                    }, 4000);
                } else {
                    showAlert('danger', data.message || 'Une erreur est survenue.');
                }
            });
        })
        .catch(function (err) { setLoading(btn, false); showAlert('danger', 'Erreur reseau: ' + err.message); });
    }

    function validateForm(form) {
        var errors = [];
        clearFieldErrors(form);
        var f = form.querySelector('[name="firstname"]');
        var l = form.querySelector('[name="lastname"]');
        var p = form.querySelector('[name="phone"]');
        var a = form.querySelector('[name="address1"]');
        var c = form.querySelector('[name="city"]');
        var z = form.querySelector('[name="postcode"]');
        if (!f || f.value.trim().length < 2) { if (f) setFieldError(f, 'Prenom requis.'); errors.push('Prenom.'); }
        if (!l || l.value.trim().length < 2) { if (l) setFieldError(l, 'Nom requis.'); errors.push('Nom.'); }
        if (!p || !PHONE_REGEX.test(p.value.trim())) { if (p) setFieldError(p, 'Telephone invalide.'); errors.push('Tel.'); }
        if (!a || a.value.trim().length < 5) { if (a) setFieldError(a, 'Adresse requise.'); errors.push('Adresse.'); }
        if (!c || !c.value.trim()) { if (c) setFieldError(c, 'Ville requise.'); errors.push('Ville.'); }
        if (!z || !z.value.trim()) { if (z) setFieldError(z, 'Code postal requis.'); errors.push('CP.'); }
        return errors;
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
        if (label)   label.style.display   = loading ? 'none'        : '';
        if (spinner) spinner.style.display = loading ? 'inline-flex' : 'none';
    }

    function bindModalReset() {
        if (window.$) {
            window.$(document).on('hidden.bs.modal', MODAL_ID, function () {
                var form = document.querySelector(FORM_ID);
                if (!form) return;
                form.reset(); form.style.display = '';
                clearFieldErrors(form); clearAlert();
                var footer = document.querySelector(MODAL_ID + ' .modal-footer');
                if (footer) footer.style.display = '';
            });
        }
    }

})();
