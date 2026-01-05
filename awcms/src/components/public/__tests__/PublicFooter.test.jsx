import { describe, it, expect, vi, beforeEach } from 'vitest';
import { render, screen } from '@testing-library/react';
import { MemoryRouter } from 'react-router-dom';
import PublicFooter from '../PublicFooter';

// Mock dependencies
vi.mock('@/lib/customSupabaseClient', () => ({
    supabase: {
        from: vi.fn(() => ({
            select: vi.fn(() => ({
                eq: vi.fn(() => ({
                    eq: vi.fn(() => ({
                        eq: vi.fn(() => ({
                            is: vi.fn(() => ({
                                order: vi.fn(() => Promise.resolve({ data: [], error: null })),
                            })),
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

describe('PublicFooter', () => {
    beforeEach(() => {
        vi.clearAllMocks();
    });

    it('renders footer element', () => {
        renderWithRouter(<PublicFooter tenant={mockTenant} />);

        const footer = screen.getByRole('contentinfo');
        expect(footer).toBeInTheDocument();
    });

    it('displays brand logo and name', () => {
        renderWithRouter(<PublicFooter tenant={mockTenant} />);

        expect(screen.getByText('AWCMS')).toBeInTheDocument();
        expect(screen.getByAltText('AWCMS')).toBeInTheDocument();
    });

    it('displays copyright with current year', () => {
        renderWithRouter(<PublicFooter tenant={mockTenant} />);

        const currentYear = new Date().getFullYear();
        expect(screen.getByText(new RegExp(`© ${currentYear}`))).toBeInTheDocument();
    });

    it('displays contact information section', () => {
        renderWithRouter(<PublicFooter tenant={mockTenant} />);

        expect(screen.getByText('public.contact_us')).toBeInTheDocument();
    });

    it('displays footer navigation links', () => {
        renderWithRouter(<PublicFooter tenant={mockTenant} />);

        expect(screen.getByText('public.privacy_policy')).toBeInTheDocument();
        expect(screen.getByText('public.terms_of_service')).toBeInTheDocument();
        expect(screen.getByText('public.sitemap')).toBeInTheDocument();
    });

    it('displays social media buttons', () => {
        renderWithRouter(<PublicFooter tenant={mockTenant} />);

        // Check for social media icon buttons (4 buttons for Facebook, Twitter, Instagram, LinkedIn)
        const allButtons = screen.getAllByRole('button');
        // Should have at least 4 social buttons
        expect(allButtons.length).toBeGreaterThanOrEqual(4);
    });

    it('has proper footer styling', () => {
        renderWithRouter(<PublicFooter tenant={mockTenant} />);

        const footer = screen.getByRole('contentinfo');
        expect(footer).toHaveClass('bg-muted/80');
        expect(footer).toHaveClass('border-t');
    });
});
