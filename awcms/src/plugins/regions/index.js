
import RegionsManager from './RegionsManager';
import manifest from './plugin.json';

// Export components
export const components = {
    RegionsManager
};

// Export manifest
export { manifest };

// Register hooks
export const register = ({ addFilter }) => {
    // Menu Item
    addFilter('admin_menu_items', 'regions_menu', (items) => {
        return [...items, {
            id: 'regions',
            label: manifest.menu.label,
            icon: manifest.menu.icon,
            path: manifest.menu.path,
            parent: manifest.menu.parent,
            order: manifest.menu.order,
            permission: 'tenant.region.read'
        }];
    });

    // Routes
    addFilter('admin_routes', 'regions_routes', (routes) => {
        return [...routes, {
            path: 'regions', // This should match what MainRouter expects for children
            element: RegionsManager,
            permission: 'tenant.region.read'
        }];
    });
};
