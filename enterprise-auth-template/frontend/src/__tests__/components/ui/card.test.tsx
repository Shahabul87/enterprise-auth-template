
import React from 'react';
import { render, screen, fireEvent } from '@testing-library/react';
import '@testing-library/jest-dom';


/**
 * @jest-environment jsdom
 */
import {
  Card,
  CardContent,
  CardDescription,
  CardFooter,
  CardHeader,
  CardTitle
} from '@/components/ui/card';
describe('Card Component', () => {
  describe('Card Container', () => {
    it('should render card container', () => {
      render(<Card data-testid="test-card">Card Content</Card>);
      const card = screen.getByTestId('test-card');
      expect(card).toBeInTheDocument();
      expect(card).toHaveTextContent('Card Content');
    });

    it('should apply custom className', () => {
      render(<Card className="custom-card-class" data-testid="custom-card">Content</Card>);
      const card = screen.getByTestId('custom-card');
      expect(card).toHaveClass('custom-card-class');
    });

    it('should have default card styles', () => {
      render(<Card data-testid="styled-card">Content</Card>);
      const card = screen.getByTestId('styled-card');
      expect(card.className).toContain('rounded');
      expect(card.className).toContain('border');
      expect(card.className).toContain('bg-card');
      expect(card.className).toContain('text-card-foreground');
      expect(card.className).toContain('shadow-sm');
    });

    it('should forward ref correctly', () => {
      const ref = React.createRef<HTMLDivElement>();
      render(<Card ref={ref}>Content</Card>);
      expect(ref.current).toBeInstanceOf(HTMLDivElement);
    });
  });

describe('CardHeader', () => {
    it('should render card header', () => {
      render(
        <Card>
          <CardHeader data-testid="card-header">Header Content</CardHeader>
        </Card>
      );
      const header = screen.getByTestId('card-header');
      expect(header).toBeInTheDocument();
      expect(header).toHaveTextContent('Header Content');
    });

    it('should apply custom className to header', () => {
      render(
        <Card>
          <CardHeader className="custom-header-class" data-testid="custom-header">Header</CardHeader>
        </Card>
      );
      const header = screen.getByTestId('custom-header');
      expect(header).toHaveClass('custom-header-class');
    });

    it('should have default header styles', () => {
      render(
        <Card>
          <CardHeader data-testid="styled-header">Header</CardHeader>
        </Card>
      );
      const header = screen.getByTestId('styled-header');
      expect(header.className).toContain('flex');
      expect(header.className).toContain('flex-col');
      expect(header.className).toContain('space-y-1.5');
      expect(header.className).toContain('p-6');
    });
  });

describe('CardTitle', () => {
    it('should render card title', () => {
      render(
        <Card>
          <CardHeader>
            <CardTitle>Test Title</CardTitle>
          </CardHeader>
        </Card>
      );
      expect(screen.getByText('Test Title')).toBeInTheDocument();
    });

    it('should apply custom className to title', () => {
      render(
        <Card>
          <CardHeader>
            <CardTitle className="custom-title-class">Title</CardTitle>
          </CardHeader>
        </Card>
      );
      const title = screen.getByText('Title');
      expect(title).toHaveClass('custom-title-class');
    });

    it('should have default title styles', () => {
      render(
        <Card>
          <CardHeader>
            <CardTitle>Styled Title</CardTitle>
          </CardHeader>
        </Card>
      );
      const title = screen.getByText('Styled Title');
      expect(title.className).toContain('text-2xl');
      expect(title.className).toContain('font-semibold');
      expect(title.className).toContain('leading-none');
      expect(title.className).toContain('tracking-tight');
    });

    it('should render as h3 element by default', () => {
      render(
        <Card>
          <CardHeader>
            <CardTitle>Heading Title</CardTitle>
          </CardHeader>
        </Card>
      );
      const title = screen.getByText('Heading Title');
      expect(title.tagName).toBe('H3');
    });
  });

describe('CardDescription', () => {
    it('should render card description', () => {
      render(
        <Card>
          <CardHeader>
            <CardDescription>Test Description</CardDescription>
          </CardHeader>
        </Card>
      );
      expect(screen.getByText('Test Description')).toBeInTheDocument();
    });

    it('should apply custom className to description', () => {
      render(
        <Card>
          <CardHeader>
            <CardDescription className="custom-desc-class">
              Description
            </CardDescription>
          </CardHeader>
        </Card>
      );
      const description = screen.getByText('Description');
      expect(description).toHaveClass('custom-desc-class');
    });

    it('should have default description styles', () => {
      render(
        <Card>
          <CardHeader>
            <CardDescription>Styled Description</CardDescription>
          </CardHeader>
        </Card>
      );
      const description = screen.getByText('Styled Description');
      expect(description.className).toContain('text-sm');
      expect(description.className).toContain('text-muted-foreground');
    });

    it('should render as p element by default', () => {
      render(
        <Card>
          <CardHeader>
            <CardDescription>Paragraph Description</CardDescription>
          </CardHeader>
        </Card>
      );
      const description = screen.getByText('Paragraph Description');
      expect(description.tagName).toBe('P');
    });
  });

describe('CardContent', () => {
    it('should render card content', () => {
      render(
        <Card>
          <CardContent data-testid="card-content">
            <p>Content Text</p>
          </CardContent>
        </Card>
      );
      const content = screen.getByTestId('card-content');
      expect(content).toBeInTheDocument();
      expect(screen.getByText('Content Text')).toBeInTheDocument();
    });

    it('should apply custom className to content', () => {
      render(
        <Card>
          <CardContent className="custom-content-class" data-testid="custom-content">Content</CardContent>
        </Card>
      );
      const content = screen.getByTestId('custom-content');
      expect(content).toHaveClass('custom-content-class');
    });

    it('should have default content styles', () => {
      render(
        <Card>
          <CardContent data-testid="styled-content">Content</CardContent>
        </Card>
      );
      const content = screen.getByTestId('styled-content');
      expect(content.className).toContain('p-6');
      expect(content.className).toContain('pt-0');
    });
  });

describe('CardFooter', () => {
    it('should render card footer', () => {
      render(
        <Card>
          <CardFooter data-testid="card-footer">
            <button>Action</button>
          </CardFooter>
        </Card>
      );
      const footer = screen.getByTestId('card-footer');
      expect(footer).toBeInTheDocument();
      expect(screen.getByText('Action')).toBeInTheDocument();
    });

    it('should apply custom className to footer', () => {
      render(
        <Card>
          <CardFooter className="custom-footer-class" data-testid="custom-footer">Footer</CardFooter>
        </Card>
      );
      const footer = screen.getByTestId('custom-footer');
      expect(footer).toHaveClass('custom-footer-class');
    });

    it('should have default footer styles', () => {
      render(
        <Card>
          <CardFooter data-testid="styled-footer">Footer</CardFooter>
        </Card>
      );
      const footer = screen.getByTestId('styled-footer');
      expect(footer.className).toContain('flex');
      expect(footer.className).toContain('items-center');
      expect(footer.className).toContain('p-6');
      expect(footer.className).toContain('pt-0');
    });
  });

describe('Complete Card', () => {
    it('should render complete card with all sections', () => {
      render(
        <Card>
          <CardHeader>
            <CardTitle>Complete Card Title</CardTitle>
            <CardDescription>Complete card description text</CardDescription>
          </CardHeader>
          <CardContent>
            <p>Main content of the card goes here</p>
          </CardContent>
          <CardFooter>
            <button>Primary Action</button>
            <button>Secondary Action</button>
          </CardFooter>
        </Card>
      );

      expect(screen.getByText('Complete Card Title')).toBeInTheDocument();
      expect(screen.getByText('Complete card description text')).toBeInTheDocument();
      expect(screen.getByText('Main content of the card goes here')).toBeInTheDocument();
      expect(screen.getByText('Primary Action')).toBeInTheDocument();
      expect(screen.getByText('Secondary Action')).toBeInTheDocument();
    });

    it('should render card with only some sections', () => {
      render(
        <Card>
          <CardHeader>
            <CardTitle>Minimal Card</CardTitle>
          </CardHeader>
          <CardContent>
            <p>Just the essentials</p>
          </CardContent>
        </Card>
      );

      expect(screen.getByText('Minimal Card')).toBeInTheDocument();
      expect(screen.getByText('Just the essentials')).toBeInTheDocument();
    });

    it('should handle nested cards', () => {
      render(
        <Card data-testid="outer-card">
          <CardContent>
            <Card data-testid="inner-card">
              <CardContent>Nested Card Content</CardContent>
            </Card>
          </CardContent>
        </Card>
      );

      expect(screen.getByTestId('outer-card')).toBeInTheDocument();
      expect(screen.getByTestId('inner-card')).toBeInTheDocument();
      expect(screen.getByText('Nested Card Content')).toBeInTheDocument();
    });
  });

describe('Edge Cases', () => {
    it('should handle empty card', () => {
      const { container } = render(<Card />);
      expect(container.firstChild).toBeInTheDocument();
    });

    it('should handle card with only title', () => {
      render(
        <Card>
          <CardHeader>
            <CardTitle>Only Title</CardTitle>
          </CardHeader>
        </Card>
      );
      expect(screen.getByText('Only Title')).toBeInTheDocument();
    });

    it('should handle card with only description', () => {
      render(
        <Card>
          <CardHeader>
            <CardDescription>Only Description</CardDescription>
          </CardHeader>
        </Card>
      );
      expect(screen.getByText('Only Description')).toBeInTheDocument();
    });

    it('should handle long content', () => {
      const longText = 'Very long content '.repeat(100);
      render(
        <Card>
          <CardContent>{longText}</CardContent>
        </Card>
      );
      expect(screen.getByText(longText.trim())).toBeInTheDocument();
    });

    it('should handle HTML attributes', () => {
      render(
        <Card
          id="test-card"
          data-testid="card"
          aria-label="Test Card"
          role="article"
        >
          Content
        </Card>
      );
      const card = screen.getByTestId('card');
      expect(card).toHaveAttribute('id', 'test-card');
      expect(card).toHaveAttribute('aria-label', 'Test Card');
      expect(card).toHaveAttribute('role', 'article');
    });

    it('should handle event handlers', () => {
      const handleClick = jest.fn();
      const handleMouseEnter = jest.fn();
      const handleMouseLeave = jest.fn();

      render(
        <Card
          onClick={handleClick}
          onMouseEnter={handleMouseEnter}
          onMouseLeave={handleMouseLeave}
          data-testid="interactive-card"
        >
          Interactive Card
        </Card>
      );

      const card = screen.getByTestId('interactive-card');

      fireEvent.click(card);
      expect(handleClick).toHaveBeenCalledTimes(1);

      fireEvent.mouseEnter(card);
      expect(handleMouseEnter).toHaveBeenCalledTimes(1);

      fireEvent.mouseLeave(card);
      expect(handleMouseLeave).toHaveBeenCalledTimes(1);
    });

    it('should handle complex card layouts', () => {
      render(
        <Card>
          <CardHeader>
            <div className="flex justify-between">
              <CardTitle>Complex Layout</CardTitle>
              <span>Badge</span>
            </div>
            <CardDescription>With custom structure</CardDescription>
          </CardHeader>
          <CardContent>
            <div className="grid grid-cols-2 gap-4">
              <div>Column 1</div>
              <div>Column 2</div>
            </div>
          </CardContent>
          <CardFooter className="justify-between">
            <span>Left content</span>
            <span>Right content</span>
          </CardFooter>
        </Card>
      );

      expect(screen.getByText('Complex Layout')).toBeInTheDocument();
      expect(screen.getByText('Badge')).toBeInTheDocument();
      expect(screen.getByText('Column 1')).toBeInTheDocument();
      expect(screen.getByText('Column 2')).toBeInTheDocument();
      expect(screen.getByText('Left content')).toBeInTheDocument();
      expect(screen.getByText('Right content')).toBeInTheDocument();
    });
  });
});