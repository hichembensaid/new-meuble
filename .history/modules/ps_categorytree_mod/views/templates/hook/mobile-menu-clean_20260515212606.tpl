{* Menu Mobile Catégories - Version Propre *}
<div class="mobile-category-menu" id="mobileCategoryMenu">
    <div class="mobile-menu-header">
        <h3 class="mobile-menu-title">{l s='Categories' d='Shop.Theme'}</h3>
        <button class="mobile-menu-close" id="mobileMenuClose">×</button>
    </div>
    
    <ul class="mobile-menu-list">
        {foreach from=$categories_custom.children item=category}
            <li class="mobile-menu-item">
                <a href="{$category.link}" class="mobile-menu-link">{$category.name}</a>
                {if $category.children}
                    <button class="mobile-menu-toggle" data-target="submenu-{$category.id}">+</button>
                    <ul class="mobile-submenu" id="submenu-{$category.id}">
                        {foreach from=$category.children item=subcategory}
                            <li class="mobile-menu-item">
                                <a href="{$subcategory.link}" class="mobile-menu-link">{$subcategory.name}</a>
                            </li>
                        {/foreach}
                    </ul>
                {/if}
            </li>
        {/foreach}
    </ul>
</div>

<div class="mobile-menu-overlay" id="mobileMenuOverlay"></div>

<script>
(function() {
    const menu = document.getElementById('mobileCategoryMenu');
    const overlay = document.getElementById('mobileMenuOverlay');
    const menuIcon = document.getElementById('menu-icon');
    const closeBtn = document.getElementById('mobileMenuClose');
    
    // Ouvrir le menu
    if (menuIcon) {
        menuIcon.addEventListener('click', function(e) {
            if (window.innerWidth <= 767) {
                e.preventDefault();
                menu.classList.add('open');
                overlay.classList.add('show');
                document.body.style.overflow = 'hidden';
            }
        });
    }
    
    // Fermer le menu
    function closeMenu() {
        menu.classList.remove('open');
        overlay.classList.remove('show');
        document.body.style.overflow = '';
    }
    
    if (closeBtn) closeBtn.addEventListener('click', closeMenu);
    if (overlay) overlay.addEventListener('click', closeMenu);
    
    // Toggle sous-menus
    document.querySelectorAll('.mobile-menu-toggle').forEach(function(btn) {
        btn.addEventListener('click', function(e) {
            e.preventDefault();
            e.stopPropagation();
            
            const targetId = this.getAttribute('data-target');
            const submenu = document.getElementById(targetId);
            
            if (submenu.classList.contains('show')) {
                submenu.classList.remove('show');
                this.textContent = '+';
            } else {
                submenu.classList.add('show');
                this.textContent = '−';
            }
        });
    });
})();
</script>
