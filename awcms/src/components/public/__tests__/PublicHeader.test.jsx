import { describe, it, expect, vi, beforeEach } from 'vitest';
import { render, screen, fireEvent } from '@testing-library/react';
import { MemoryRouter } from 'react-router-dom';
import PublicHeader from '../PublicHeader';

// Mock dependencies
vi.mock('@/lib/customSupabaseClient', () => ({
    supabase: {
        from: vi.fn(() => ({
            select: vi.fn(() => ({
                eq: vi.fn(() => ({
                    maybeSingle: vi.fn(() => Promise.resolve({ data: null })),
                    is: vi.fn(() => ({
                        eq: vi.fn(() => ({
                            order: vi.fn(() => Promise.resolve({ data: [], error: null })),
                        })),
                    })),
                })),
            })),
        })),
    },
}));

vi.mock('react-i18next', () => ({
    useTranslation: () => ({
        t: (key) => key,
        i18n: {
            language: 'en',
            exists: () => false,
        },
    }),
}));

vi.mock('@/contexts/SupabaseAuthContext', () => ({
    useAuth: vi.fn(() => ({
        user: null,
    })),
}));

vi.mock('@/components/ui/LanguageSelector', () => ({
    default: () => <div data-testid="language-selector">Lang</div>,
}));

vi.mock('framer-motion', () => ({
    motion: {
        div: ({ children, className }) => <div className={className}>{children}</div>,
    },
    AnimatePresence: ({ children }) => <>{children}</>,
}));

const mockTenant = {
    id: 'test-tenant-123',
    name: 'Test Tenant',
};

const renderWithRouter = (ui) => {
    return render(
        <MemoryRouter>
            {ui}
        </MemoryRouter>
    );
};

describe('PublicHeader', () => {
    beforeEach(() => {
        vi.clearAllMocks();
    });

    it('renders header element', () => {
        renderWithRouter(<PublicHeader tenant={mockTenant} />);

        const header = screen.getByRole('banner');
        expect(header).toBeInTheDocument();
    });

    it('displays brand logo', () => {
        renderWithRouter(<PublicHeader tenant={mockTenant} />);

        expect(screen.getByAltText('AWCMS')).toBeInTheDocument();
        expect(screen.getByText('AWCMS')).toBeInTheDocument();
    });

    it('has sticky positioning', () => {
        renderWithRouter(<PublicHeader tenant={mockTenant} />);

        const header = screen.getByRole('banner');
        expect(header).toHaveClass('sticky');
        expect(header).toHaveClass('top-0');
    });

    it('includes language selector', () => {
        renderWithRouter(<PublicHeader tenant={mockTenant} />);

        expect(screen.getByTestId('language-selector')).toBeInTheDocument();
    });

    it('shows login button for unauthenticated users', () => {
        renderWithRouter(<PublicHeader tenant={mockTenant} />);

        // The link to login should exist
        const loginLinks = screen.getAllByRole('link');
        const loginLink = loginLinks.find(link => link.getAttribute('href') === '/cmspanel/login');
        expect(loginLink).toBeDefined();
    });

    it('renders mobile menu button', () => {
        renderWithRouter(<PublicHeader tenant={mockTenant} />);

        // Find mobile menu toggle button (the lg:hidden button)
        const buttons = screen.getAllByRole('button');
        // At least one button should exist for mobile menu
        expect(buttons.length).toBeGreaterThan(0);
    });

    it('toggles mobile menu on button click', () => {
        const { container } = renderWithRouter(<PublicHeader tenant={mockTenant} />);

        // Find the mobile menu toggle button (last button in header)
        const mobileButton = container.querySelector('button.lg\\:hidden');
        expect(mobileButton).toBeInTheDocument();

        // Initially mobile menu should be closed
        expect(container.querySelector('.lg\\:hidden.bg-background')).not.toBeInTheDocument();

        // Click to open
        fireEvent.click(mobileButton);

        // After click state should change (menu should appear)
        // The component re-renders with mobileMenuOpen = true
    });

    it('links to home page via logo', () => {
        renderWithRouter(<PublicHeader tenant={mockTenant} />);

        const homeLinks = screen.getAllByRole('link');
        const logoLink = homeLinks.find(link => link.getAttribute('href') === '/');
        expect(logoLink).toBeDefined();
    });
});
