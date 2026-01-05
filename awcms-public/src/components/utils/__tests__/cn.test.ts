import { describe, it, expect } from 'vitest';
import { cn } from '../cn';

describe('cn utility', () => {
    it('merges class names', () => {
        expect(cn('foo', 'bar')).toBe('foo bar');
    });

    it('handles undefined values', () => {
        expect(cn('foo', undefined, 'bar')).toBe('foo bar');
    });

    it('handles null values', () => {
        expect(cn('foo', null, 'bar')).toBe('foo bar');
    });

    it('handles conditional classes', () => {
        const isActive = true;
        const isDisabled = false;
        expect(cn('base', isActive && 'active', isDisabled && 'disabled')).toBe('base active');
    });

    it('resolves Tailwind conflicts - last wins', () => {
        // twMerge resolves p-2 and p-4 to p-4 (last one wins)
        expect(cn('p-2', 'p-4')).toBe('p-4');
    });

    it('resolves complex Tailwind conflicts', () => {
        // px-2 and px-4 should resolve to px-4
        expect(cn('px-2 py-1', 'px-4')).toBe('py-1 px-4');
    });

    it('handles empty inputs', () => {
        expect(cn()).toBe('');
    });

    it('handles array inputs', () => {
        expect(cn(['foo', 'bar'])).toBe('foo bar');
    });

    it('handles object inputs', () => {
        expect(cn({ foo: true, bar: false, baz: true })).toBe('foo baz');
    });
});
