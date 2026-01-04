import { describe, it, expect, vi, beforeEach } from 'vitest';
import { udm } from './UnifiedDataManager';

// Use vi.hoisted to ensure mocks are available before vi.mock calls
const mocks = vi.hoisted(() => {
    const mockSelectBuilder = {
        select: vi.fn(),
        insert: vi.fn(),
        update: vi.fn(),
        delete: vi.fn(),
        eq: vi.fn(),
        order: vi.fn(),
        range: vi.fn(),
        single: vi.fn().mockReturnThis(),
        limit: vi.fn(),
        then: vi.fn(),
    };

    // Chainables
    mockSelectBuilder.select.mockReturnValue(mockSelectBuilder);
    mockSelectBuilder.insert.mockReturnValue(mockSelectBuilder);
    mockSelectBuilder.update.mockReturnValue(mockSelectBuilder);
    mockSelectBuilder.delete.mockReturnValue(mockSelectBuilder);
    mockSelectBuilder.eq.mockReturnValue(mockSelectBuilder);
    mockSelectBuilder.order.mockReturnValue(mockSelectBuilder);
    mockSelectBuilder.range.mockReturnValue(mockSelectBuilder);
    mockSelectBuilder.limit.mockReturnValue(mockSelectBuilder);

    // Default promise resolution
    mockSelectBuilder.then.mockImplementation((resolve) => resolve({ data: [], error: null }));

    const mockFrom = vi.fn(() => mockSelectBuilder);

    return {
        mockSelectBuilder,
        mockFrom
    };
});

vi.mock('@/lib/customSupabaseClient', () => {
    return {
        supabase: {
            from: mocks.mockFrom,
        },
    };
});

vi.mock('../offline/db', () => ({
    runQuery: vi.fn(),
}));

vi.mock('../offline/SyncEngine', () => ({
    syncEngine: {
        queueMutation: vi.fn(),
    },
}));

describe('UnifiedDataManager', () => {
    beforeEach(() => {
        vi.clearAllMocks();
        Object.defineProperty(navigator, 'onLine', {
            writable: true,
            value: true,
        });
    });

    describe('Online Mode', () => {
        it('fetches data from Supabase when online', async () => {
            // Setup specific return
            mocks.mockSelectBuilder.then.mockImplementation((resolve) => resolve({
                data: [{ id: 1, title: 'Test' }],
                error: null
            }));

            const result = await udm.from('articles').select('*');

            expect(mocks.mockFrom).toHaveBeenCalledWith('articles');
            expect(result.data).toEqual([{ id: 1, title: 'Test' }]);
        });
    });

    describe('Offline Mode', () => {
        it('does not call Supabase when offline', async () => {
            Object.defineProperty(navigator, 'onLine', {
                writable: true,
                value: false,
            });

            try {
                await udm.from('articles').select('*');
            } catch (e) {
                // consume
            }

            expect(mocks.mockFrom).not.toHaveBeenCalled();
        });
    });
});
