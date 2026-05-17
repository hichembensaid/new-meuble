/**
 * quickorder.js – Frontend Commande Rapide
 */

'use strict';

console.log('[QuickOrder] ✅ JS chargé');

(function () {

    var MODAL_ID   = '#quickOrderModal';
    var FORM_ID    = '#quickOrderForm';
    var ALERT_ID   = '#qo-alert';
    var SUBMIT_ID  = '#qo-submit';
    var BTN_CLASS  = '.quickorder-btn';
    var PHONE_REGEX = /^[0-9+\s\-]{8,20}$/;

    /* -----------------------------------------------------------------------
     * Init
     * -------------------------------------------------------------------- */

    document.addEventListener('DOMContentLoaded', function () {
        console.log('[QuickOrder] DOM ready');
        bindTriggerButton();
        bindSubmitButton();
        bindModalReset();
    });

    /* -----------------------------------------------------------------------
     * 1. Bouton "Commander rapidement" → sync produit dans le formulaire
     * -------------------------------------------------------------------- */

    function bindTriggerButton() {
        document.addEventListener('click', function (e) {
            var btn = e.target.closest ? e.target.closest(BTN_CLASS) : null;
            if (!btn) return;

            console.log('[QuickOrder] Bouton déclencheur cliqué, product_id=' + btn.dataset.productId);

            var nameEl = document.getElementById('qo-product-name');
            if (nameEl) nameEl.textContent = btn.dataset.productName || '';

            var form = document.querySelector(FORM_ID);
            if (form) {
                form.dataset.productId = btn.dataset.productId || '0';
                syncProductAttribute(form);
            }
        });
    }

    function syncProductAttribute(form) {
        var attrInput = document.getElementById('idCombination')
            || document.getElementById('product_attribute_id')
            || document.querySelector('input[name="id_product_attribute"]');
        if (attrInput) form.dataset.productAttr = attrInput.value || '0';

        var qtyInput = document.getElementById('quantity_wanted')
            || document.querySelector('input[name="qty"]');
        if (qtyInput) form.dataset.qty = qtyInput.value || '1';
    }

    /* -----------------------------------------------------------------------
     * 2. Clic sur "Confirmer ma commande" → validation + AJAX
     * -------------------------------------------------------------------- */

    function bindSubmitButton() {
        // Écoute sur le document pour être sûr que le bouton est dans le DOM
        document.addEventListener('click', function (e) {
            var btn = e.target.closest ? e.target.closest(SUBMIT_ID) : null;
            if (!btn) return;

            console.log('[QuickOrder] Bouton confirmer cliqué');
            e.preventDefault();
            e.stopPropagation();

            var form = document.querySelector(FORM_ID);
            if (!form) {
                console.error('[QuickOrder] Formulaire introuvable !');
                return;
            }

            clearAlert();
            var errors = validateForm(form);

            if (errors.length) {
                showAlert('danger', errors.join('<br>'));
                return;
            }

            submitOrder(form, btn);
        });
    }

    function submitOrder(form, submitBtn) {
        setLoading(submitBtn, true);

        var payload = buildPayload(form);

        console.log('[QuickOrder] Envoi AJAX vers ' + form.dataset.ajaxUrl, payload);

        fetch(form.dataset.ajaxUrl, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/x-www-form-urlencoded',
                'X-Requested-With': 'XMLHttpRequest'
            },
            body: new URLSearchParams(payload).toString(),
            credentials: 'same-origin'
        })
        .then(function (response) {
            return response.text().then(function (text) {
                console.log('[QuickOrder] Réponse brute :', text);
                var data;
                try {
                    data = JSON.parse(text);
                } catch (e) {
                    showAlert('danger', 'Erreur serveur (code ' + response.status + '). Voir la console.');
                    return;
                }
                if (data.success) {
                    handleSuccess(form, data);
                } else {
                    showAlert('danger', data.message || 'Une erreur est survenue.');
                }
            });
        })
        .catch(function (err) {
            console.error('[QuickOrder] Erreur réseau :', err);
            showAlert('danger', 'Erreur réseau : ' + err.message);
        })
        .finally(function () {
            setLoading(submitBtn, false);
        });
    }

    function buildPayload(form) {
        var fd = new FormData(form);
        return {
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
    }

    /* -----------------------------------------------------------------------
     * 3. Succès
     * -------------------------------------------------------------------- */

    function handleSuccess(form, data) {
        form.style.display = 'none';
        var footer = document.querySelector(MODAL_ID + ' .modal-footer');
        if (footer) footer.style.display = 'none';
        showAlert('success', data.message || 'Commande enregistrée !');
        setTimeout(function () {
            closeModal();
            resetModal(form);
        }, 4000);
    }

    /* -----------------------------------------------------------------------
     * 4. Validation
     * -------------------------------------------------------------------- */

    function validateForm(form) {
        var errors = [];
        clearFieldErrors(form);

        var firstname = form.querySelector('[name="firstname"]');
        var lastname  = form.querySelector('[name="lastname"]');
        var phone     = form.querySelector('[name="phone"]');
        var address1  = form.querySelector('[name="address1"]');
        var city      = form.querySelector('[name="city"]');
        var postcode  = form.querySelector('[name="postcode"]');

        if (!firstname || !firstname.value.trim() || firstname.value.trim().length < 2) {
            if (firstname) setFieldError(firstname, 'Le prénom est requis (min. 2 caractères).');
            errors.push('Prénom invalide.');
        }
        if (!lastname || !lastname.value.trim() || lastname.value.trim().length < 2) {
            if (lastname) setFieldError(lastname, 'Le nom est requis (min. 2 caractères).');
            errors.push('Nom invalide.');
        }
        if (!phone || !phone.value.trim() || !PHONE_REGEX.test(phone.value.trim())) {
            if (phone) setFieldError(phone, 'Téléphone invalide.');
            errors.push('Téléphone invalide.');
        }
        if (!address1 || !address1.value.trim() || address1.value.trim().length < 5) {
            if (address1) setFieldError(address1, 'L\'adresse est requise.');
            errors.push('Adresse invalide.');
        }
        if (!city || !city.value.trim()) {
            if (city) setFieldError(city, 'La ville est requise.');
            errors.push('Ville invalide.');
        }
        if (!postcode || !postcode.value.trim()) {
            if (postcode) setFieldError(postcode, 'Le code postal est requis.');
            errors.push('Code postal invalide.');
        }

        return errors;
    }

    function setFieldError(input, message) {
        input.classList.add('is-invalid');
        var fb = input.nextElementSibling;
        if (fb && fb.classList.contains('invalid-feedback')) fb.textContent = message;
    }

    function clearFieldErrors(form) {
        form.querySelectorAll('.is-invalid').forEach(function (el) { el.classList.remove('is-invalid'); });
        form.querySelectorAll('.invalid-feedback').forEach(function (el) { el.textContent = ''; });
    }

    /* -----------------------------------------------------------------------
     * 5. Helpers UI
     * -------------------------------------------------------------------- */

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

    function closeModal() {
        if (window.bootstrap && window.bootstrap.Modal) {
            var modalEl = document.querySelector(MODAL_ID);
            var m = window.bootstrap.Modal.getInstance(modalEl);
            if (m) { m.hide(); return; }
        }
        if (window.$ && typeof window.$.fn.modal === 'function') {
            window.$(MODAL_ID).modal('hide');
        }
    }

    function resetModal(form) {
        form.reset();
        form.style.display = '';
        clearFieldErrors(form);
        clearAlert();
        var footer = document.querySelector(MODAL_ID + ' .modal-footer');
        if (footer) footer.style.display = '';
        form.querySelectorAll('.is-valid').forEach(function (el) { el.classList.remove('is-valid'); });
    }

    function bindModalReset() {
        document.addEventListener('hidden.bs.modal', function (e) {
            if (e.target.id !== 'quickOrderModal') return;
            var form = document.querySelector(FORM_ID);
            if (form) resetModal(form);
        });
        if (window.$) {
            window.$(document).on('hidden.bs.modal', MODAL_ID, function () {
                var form = document.querySelector(FORM_ID);
                if (form) resetModal(form);
            });
        }
    }

})();

    /** Regex téléphone : 8 à 20 caractères parmi 0-9, +, espace, tiret */
    const PHONE_REGEX = /^[0-9+\s\-]{8,20}$/;

    /* -----------------------------------------------------------------------
     * Initialisation au chargement du DOM
     * -------------------------------------------------------------------- */

    document.addEventListener('DOMContentLoaded', () => {
        bindTriggerButton();
        bindFormSubmit();
        bindModalReset();
        bindRealtimeValidation();
    });

    /* -----------------------------------------------------------------------
     * 1. Bouton déclencheur → met à jour les données produit dans le modal
     * -------------------------------------------------------------------- */

    function bindTriggerButton() {
        document.addEventListener('click', (e) => {
            const btn = e.target.closest(BTN_CLASS);
            if (!btn) return;

            const productId   = btn.dataset.productId;
            const productName = btn.dataset.productName;

            // Mettre à jour le résumé du produit dans la modale
            const nameEl = document.getElementById('qo-product-name');
            if (nameEl) nameEl.textContent = productName || '';

            // Stocker l'id produit dans le formulaire
            const form = document.querySelector(FORM_ID);
            if (form) {
                form.dataset.productId = productId;
            }

            // Lire la combinaison sélectionnée sur la page produit (si présent)
            syncProductAttribute(form);
        });
    }

    /**
     * Lit l'attribut sélectionné depuis l'input caché de PrestaShop (id_product_attribute).
     */
    function syncProductAttribute(form) {
        if (!form) return;

        // PrestaShop injecte souvent un input hidden #idCombination ou #product_attribute_id
        const attrInput = document.getElementById('idCombination')
            || document.getElementById('product_attribute_id')
            || document.querySelector('input[name="id_product_attribute"]');

        if (attrInput) {
            form.dataset.productAttr = attrInput.value || '0';
        }

        // Quantité
        const qtyInput = document.getElementById('quantity_wanted')
            || document.querySelector('input[name="qty"]');

        if (qtyInput) {
            form.dataset.qty = qtyInput.value || '1';
        }
    }

    /* -----------------------------------------------------------------------
     * 2. Soumission du formulaire → validation + AJAX
     * -------------------------------------------------------------------- */

    function bindFormSubmit() {
        document.addEventListener('submit', async (e) => {
            const form = e.target.closest(FORM_ID);
            if (!form) return;

            e.preventDefault();

            clearAlert();

            const errors = validateForm(form);

            if (errors.length) {
                showAlert('danger', errors.join('<br>'));
                return;
            }

            await submitOrder(form);
        });
    }

    async function submitOrder(form) {
        const submitBtn = document.querySelector(SUBMIT_ID);
        setLoading(submitBtn, true);

        const payload = buildPayload(form);

        try {
            const response = await fetch(form.dataset.ajaxUrl, {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/x-www-form-urlencoded',
                    'X-Requested-With': 'XMLHttpRequest',
                },
                body: new URLSearchParams(payload).toString(),
                credentials: 'same-origin',
            });

            let data;
            const rawText = await response.text();

            try {
                data = JSON.parse(rawText);
            } catch (_) {
                // Le serveur a retourné du HTML (erreur PHP, page d'erreur PrestaShop…)
                console.error('[QuickOrder] Réponse non-JSON :', rawText.substring(0, 500));
                showAlert('danger', 'Erreur serveur (code ' + response.status + '). Consultez les logs PrestaShop.');
                return;
            }

            if (data.success) {
                handleSuccess(form, data);
            } else {
                showAlert('danger', data.message || 'Une erreur est survenue.');
            }
        } catch (err) {
            console.error('[QuickOrder] Erreur réseau :', err);
            showAlert('danger', 'Erreur réseau : ' + err.message);
        } finally {
            setLoading(submitBtn, false);
        }
    }

    /**
     * Construit l'objet de données à envoyer au serveur.
     */
    function buildPayload(form) {
        const fd = new FormData(form);

        return {
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
            comment:              fd.get('comment')   || '',
        };
    }

    /* -----------------------------------------------------------------------
     * 3. Gestion du succès
     * -------------------------------------------------------------------- */

    function handleSuccess(form, data) {
        // Masquer le formulaire
        form.style.display = 'none';

        // Masquer les boutons du footer
        const footer = document.querySelector(`${MODAL_ID} .modal-footer`);
        if (footer) footer.style.display = 'none';

        // Afficher le message de succès
        showAlert('success', data.message || 'Commande enregistrée !');

        // Fermeture automatique après 4 secondes
        setTimeout(() => {
            closeModal();
            // Réinitialiser le formulaire pour une future utilisation
            resetModal(form);
        }, 4000);
    }

    /* -----------------------------------------------------------------------
     * 4. Validation client-side
     * -------------------------------------------------------------------- */

    function validateForm(form) {
        const errors = [];

        clearFieldErrors(form);

        const firstname = form.querySelector('[name="firstname"]');
        const lastname  = form.querySelector('[name="lastname"]');
        const phone     = form.querySelector('[name="phone"]');
        const address1  = form.querySelector('[name="address1"]');
        const city      = form.querySelector('[name="city"]');
        const postcode  = form.querySelector('[name="postcode"]');

        if (!firstname.value.trim() || firstname.value.trim().length < 2) {
            setFieldError(firstname, 'Le prénom est requis (min. 2 caractères).');
            errors.push('Prénom invalide.');
        }

        if (!lastname.value.trim() || lastname.value.trim().length < 2) {
            setFieldError(lastname, 'Le nom est requis (min. 2 caractères).');
            errors.push('Nom invalide.');
        }

        if (!phone.value.trim() || !PHONE_REGEX.test(phone.value.trim())) {
            setFieldError(phone, 'Téléphone invalide (ex : 06 12 34 56 78).');
            errors.push('Téléphone invalide.');
        }

        if (!address1.value.trim() || address1.value.trim().length < 5) {
            setFieldError(address1, 'L\'adresse est requise (min. 5 caractères).');
            errors.push('Adresse invalide.');
        }

        if (!city.value.trim() || city.value.trim().length < 2) {
            setFieldError(city, 'La ville est requise.');
            errors.push('Ville invalide.');
        }

        if (!postcode.value.trim()) {
            setFieldError(postcode, 'Le code postal est requis.');
            errors.push('Code postal invalide.');
        }

        return errors;
    }

    function setFieldError(input, message) {
        input.classList.add('is-invalid');
        const fb = input.nextElementSibling;
        if (fb && fb.classList.contains('invalid-feedback')) {
            fb.textContent = message;
        }
    }

    function clearFieldErrors(form) {
        form.querySelectorAll('.is-invalid').forEach(el => el.classList.remove('is-invalid'));
        form.querySelectorAll('.invalid-feedback').forEach(el => (el.textContent = ''));
    }

    /* -----------------------------------------------------------------------
     * 5. Validation en temps réel (blur)
     * -------------------------------------------------------------------- */

    function bindRealtimeValidation() {
        document.addEventListener('blur', (e) => {
            const input = e.target;
            if (!input.closest(FORM_ID)) return;
            if (!input.required && input.tagName !== 'INPUT') return;

            // Retirer l'erreur si le champ est maintenant valide
            if (input.value.trim().length >= (parseInt(input.minLength) || 1)) {
                input.classList.remove('is-invalid');
                input.classList.add('is-valid');
            }
        }, true);
    }

    /* -----------------------------------------------------------------------
     * 6. Helpers UI
     * -------------------------------------------------------------------- */

    function showAlert(type, message) {
        const alertEl = document.querySelector(ALERT_ID);
        if (!alertEl) return;

        alertEl.className = 'alert alert-' + type;
        alertEl.innerHTML = message;
        alertEl.style.display = 'block';
        alertEl.scrollIntoView({ behavior: 'smooth', block: 'nearest' });
    }

    function clearAlert() {
        const alertEl = document.querySelector(ALERT_ID);
        if (alertEl) {
            alertEl.className = 'alert';
            alertEl.innerHTML = '';
            alertEl.style.display = 'none';
        }
    }

    function setLoading(btn, loading) {
        if (!btn) return;

        const label   = btn.querySelector('.qo-submit__label');
        const spinner = btn.querySelector('.qo-submit__loading');

        btn.disabled = loading;

        if (label)   label.style.display   = loading ? 'none'         : '';
        if (spinner) spinner.style.display = loading ? 'inline-flex'  : 'none';
    }

    function closeModal() {
        const modalEl = document.querySelector(MODAL_ID);
        if (!modalEl) return;

        // Bootstrap 5
        if (window.bootstrap && window.bootstrap.Modal) {
            const modal = window.bootstrap.Modal.getInstance(modalEl);
            if (modal) modal.hide();
            return;
        }

        // Bootstrap 4 via jQuery (chargé par PrestaShop)
        if (window.$ && typeof window.$.fn.modal === 'function') {
            window.$(MODAL_ID).modal('hide');
        }
    }

    function resetModal(form) {
        form.reset();
        form.style.display = '';
        clearFieldErrors(form);
        clearAlert();

        const footer = document.querySelector(`${MODAL_ID} .modal-footer`);
        if (footer) footer.style.display = '';

        // Supprimer les classes de validation Bootstrap
        form.querySelectorAll('.is-valid').forEach(el => el.classList.remove('is-valid'));
    }

    function bindModalReset() {
        document.addEventListener('hidden.bs.modal', (e) => {
            if (e.target.id !== 'quickOrderModal') return;
            const form = document.querySelector(FORM_ID);
            if (form) resetModal(form);
        });

        // Bootstrap 4
        if (window.$) {
            window.$(document).on('hidden.bs.modal', MODAL_ID, () => {
                const form = document.querySelector(FORM_ID);
                if (form) resetModal(form);
            });
        }
    }

})();
