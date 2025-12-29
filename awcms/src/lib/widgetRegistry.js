// Basic Widget Registry
// In the future, this can be extended by plugins calling registerWidget()

/*
  Widget Interface:
  {
    type: 'core/text',
    name: 'Text Widget',
    icon: IconComponent,
    component: ReactComponent, // The component to render in the editor/frontend
    defaultConfig: {},
    schema: {} // Zod schema for config
  }
*/

import { Type, Image, Link, List } from 'lucide-react';

export const CORE_WIDGETS = [
    {
        type: 'core/text',
        name: 'Text / HTML',
        icon: Type,
        defaultConfig: { content: '', isHtml: false }
    },
    {
        type: 'core/image',
        name: 'Image',
        icon: Image,
        defaultConfig: { url: '', alt: '' }
    },
    {
        type: 'core/menu',
        name: 'Navigation Menu',
        icon: List,
        defaultConfig: { menuId: '' }
    },
    {
        type: 'core/button',
        name: 'Button',
        icon: Link,
        defaultConfig: { text: 'Click Me', url: '#' }
    }
];

// Global registry (in-memory)
const registry = [...CORE_WIDGETS];

export const getWidgets = () => registry;

export const registerWidget = (widgetDef) => {
    // Check for duplicate
    if (registry.find(w => w.type === widgetDef.type)) {
        console.warn(`Widget ${widgetDef.type} already registered.`);
        return;
    }
    registry.push(widgetDef);
};

export const getWidgetByType = (type) => registry.find(w => w.type === type);
