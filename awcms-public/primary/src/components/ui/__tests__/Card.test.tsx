import { describe, it, expect } from 'vitest';
import { render, screen } from '@testing-library/react';
import { Card, CardHeader, CardTitle, CardContent } from '../Card';

describe('Card', () => {
    it('renders with default classes', () => {
        render(<Card data-testid="card">Content</Card>);
        const card = screen.getByTestId('card');
        expect(card).toHaveClass('rounded-xl');
        expect(card).toHaveClass('border');
        expect(card).toHaveClass('shadow');
    });

    it('merges custom className', () => {
        render(<Card className="my-custom-class" data-testid="card">Content</Card>);
        const card = screen.getByTestId('card');
        expect(card).toHaveClass('my-custom-class');
        expect(card).toHaveClass('rounded-xl');
    });

    it('forwards ref correctly', () => {
        const ref = { current: null };
        render(<Card ref={ref}>Content</Card>);
        expect(ref.current).toBeInstanceOf(HTMLDivElement);
    });
});

describe('CardHeader', () => {
    it('renders with default classes', () => {
        render(<CardHeader data-testid="header">Header</CardHeader>);
        const header = screen.getByTestId('header');
        expect(header).toHaveClass('flex');
        expect(header).toHaveClass('flex-col');
        expect(header).toHaveClass('p-6');
    });

    it('merges custom className', () => {
        render(<CardHeader className="gap-4" data-testid="header">Header</CardHeader>);
        const header = screen.getByTestId('header');
        expect(header).toHaveClass('gap-4');
    });
});

describe('CardTitle', () => {
    it('renders as h3 element', () => {
        render(<CardTitle>Title</CardTitle>);
        expect(screen.getByRole('heading', { level: 3 })).toBeInTheDocument();
    });

    it('applies font styling', () => {
        render(<CardTitle data-testid="title">Title</CardTitle>);
        const title = screen.getByTestId('title');
        expect(title).toHaveClass('font-semibold');
    });
});

describe('CardContent', () => {
    it('renders with padding', () => {
        render(<CardContent data-testid="content">Content</CardContent>);
        const content = screen.getByTestId('content');
        expect(content).toHaveClass('p-6');
        expect(content).toHaveClass('pt-0');
    });

    it('renders children', () => {
        render(<CardContent>Card body text</CardContent>);
        expect(screen.getByText('Card body text')).toBeInTheDocument();
    });
});
