<?php
/**
 * Script pour réparer l'arbre de catégories PrestaShop
 * Régénère les valeurs nleft et nright
 */

// Configuration
define('_PS_ROOT_DIR_', __DIR__);
require_once(_PS_ROOT_DIR_.'/config/config.inc.php');

echo "=================================================================\n";
echo "RÉPARATION DE L'ARBRE DE CATÉGORIES\n";
echo "=================================================================\n\n";

try {
    // Régénérer l'arbre de catégories
    echo "1. Régénération de l'arbre de catégories (nested set)...\n";
    
    // Utiliser la méthode PrestaShop pour régénérer l'arbre
    Category::regenerateEntireNtree();
    
    echo "   ✓ Arbre de catégories régénéré avec succès!\n\n";
    
    // Vérifier les résultats
    echo "2. Vérification des résultats:\n";
    echo "-------------------------------\n";
    
    $homeCategory = Configuration::get('PS_HOME_CATEGORY');
    $category = new Category($homeCategory);
    
    echo "   Catégorie HOME (ID: $homeCategory):\n";
    echo "   - Nom: " . $category->name[1] . "\n";
    echo "   - nleft: " . $category->nleft . "\n";
    echo "   - nright: " . $category->nright . "\n";
    echo "   - level_depth: " . $category->level_depth . "\n\n";
    
    // Compter les enfants
    $children = $category->getSubCategories(1, true);
    echo "   Nombre de sous-catégories: " . count($children) . "\n\n";
    
    echo "=================================================================\n";
    echo "✓ RÉPARATION TERMINÉE AVEC SUCCÈS!\n";
    echo "=================================================================\n\n";
    
    echo "PROCHAINES ÉTAPES:\n";
    echo "1. Videz le cache: Paramètres avancés > Performances > Vider le cache\n";
    echo "2. Actualisez votre page d'accueil\n";
    echo "3. Les catégories devraient maintenant s'afficher!\n\n";
    
} catch (Exception $e) {
    echo "❌ ERREUR: " . $e->getMessage() . "\n";
    echo "   Trace: " . $e->getTraceAsString() . "\n";
    exit(1);
}
