import { describe, it, expect, vi } from 'vitest';
import { render, screen } from '@testing-library/react';
import { TipTapRenderer } from '../TipTapRenderer';

describe('TipTapRenderer', () => {
    it('renders empty wrapper for empty content', () => {
        const { container } = render(<TipTapRenderer doc={{ type: 'doc', content: [] }} />);
        // Returns wrapper div with no content
        expect(container.querySelector('.tiptap-doc')).toBeEmptyDOMElement();
    });

    it('returns null for null doc', () => {
        const { container } = render(<TipTapRenderer doc={null as any} />);
        expect(container.firstChild).toBeNull();
    });

    it('renders paragraph', () => {
        const doc = {
            type: 'doc',
            content: [
                { type: 'paragraph', content: [{ type: 'text', text: 'Hello world' }] }
            ]
        };
        render(<TipTapRenderer doc={doc} />);
        expect(screen.getByText('Hello world')).toBeInTheDocument();
    });

    it('renders headings at different levels', () => {
        const doc = {
            type: 'doc',
            content: [
                { type: 'heading', attrs: { level: 1 }, content: [{ type: 'text', text: 'Heading 1' }] },
                { type: 'heading', attrs: { level: 2 }, content: [{ type: 'text', text: 'Heading 2' }] }
            ]
        };
        render(<TipTapRenderer doc={doc} />);
        expect(screen.getByRole('heading', { level: 1, name: 'Heading 1' })).toBeInTheDocument();
        expect(screen.getByRole('heading', { level: 2, name: 'Heading 2' })).toBeInTheDocument();
    });

    it('renders bullet list', () => {
        const doc = {
            type: 'doc',
            content: [{
                type: 'bulletList',
                content: [
                    { type: 'listItem', content: [{ type: 'paragraph', content: [{ type: 'text', text: 'Item 1' }] }] },
                    { type: 'listItem', content: [{ type: 'paragraph', content: [{ type: 'text', text: 'Item 2' }] }] }
                ]
            }]
        };
        render(<TipTapRenderer doc={doc} />);
        expect(screen.getByText('Item 1')).toBeInTheDocument();
        expect(screen.getByText('Item 2')).toBeInTheDocument();
    });

    it('renders blockquote', () => {
        const doc = {
            type: 'doc',
            content: [{
                type: 'blockquote',
                content: [{ type: 'paragraph', content: [{ type: 'text', text: 'Quote text' }] }]
            }]
        };
        render(<TipTapRenderer doc={doc} />);
        expect(screen.getByText('Quote text')).toBeInTheDocument();
    });

    it('renders bold text', () => {
        const doc = {
            type: 'doc',
            content: [{
                type: 'paragraph',
                content: [{ type: 'text', text: 'Bold text', marks: [{ type: 'bold' }] }]
            }]
        };
        render(<TipTapRenderer doc={doc} />);
        const boldText = screen.getByText('Bold text');
        expect(boldText.closest('strong')).toBeInTheDocument();
    });

    it('renders italic text', () => {
        const doc = {
            type: 'doc',
            content: [{
                type: 'paragraph',
                content: [{ type: 'text', text: 'Italic text', marks: [{ type: 'italic' }] }]
            }]
        };
        render(<TipTapRenderer doc={doc} />);
        const italicText = screen.getByText('Italic text');
        expect(italicText.closest('em')).toBeInTheDocument();
    });

    it('renders link', () => {
        const doc = {
            type: 'doc',
            content: [{
                type: 'paragraph',
                content: [{
                    type: 'text',
                    text: 'Click here',
                    marks: [{ type: 'link', attrs: { href: 'https://example.com', target: '_blank' } }]
                }]
            }]
        };
        render(<TipTapRenderer doc={doc} />);
        const link = screen.getByRole('link', { name: 'Click here' });
        expect(link).toHaveAttribute('href', 'https://example.com');
        expect(link).toHaveAttribute('target', '_blank');
    });

    it('renders code block', () => {
        const doc = {
            type: 'doc',
            content: [{
                type: 'codeBlock',
                content: [{ type: 'text', text: 'const x = 1;' }]
            }]
        };
        render(<TipTapRenderer doc={doc} />);
        expect(screen.getByText('const x = 1;')).toBeInTheDocument();
    });

    it('warns on unsupported node type', () => {
        const consoleSpy = vi.spyOn(console, 'warn').mockImplementation(() => { });
        const doc = {
            type: 'doc',
            content: [{ type: 'unknownType' }]
        };
        render(<TipTapRenderer doc={doc} />);
        expect(consoleSpy).toHaveBeenCalledWith('[TipTapRenderer] Unsupported node type: unknownType');
        consoleSpy.mockRestore();
    });
});
