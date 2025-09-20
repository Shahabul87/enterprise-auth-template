
import React from 'react';
import { render, screen } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { Footer } from '@/components/layout/footer';


jest.mock('@/components/ui/button', () => ({
  Button: ({ children, className, variant, size, asChild, ...props }: any) => {
    const { asChild: _, variant: __, size: ___, ...cleanProps } = props;
    if (asChild) {
      return children;
    }
    return (
      <button className={className} {...cleanProps}>
        {children}
      </button>
    );
  },

jest.mock('@/components/ui/separator', () => ({
  Separator: ({ className, orientation, ...props }: any) => (
    <hr className={className} {...props} />
  ),
// Orphaned closing removed
jest.mock('@/components/ui/badge', () => ({
  Badge: ({ children, className, variant, ...props }: any) => (
    <span className={className} {...props}>
      {children}
    </span>
  ),
// Orphaned closing removed
jest.mock('next/link', () => {
  return ({ children, href, ...props }: any) => (
    <a href={href} {...props}>
      {children}
    </a>
  );
});

jest.mock('lucide-react', () => ({
  Github: () => <div data-testid="github-icon" />,
  Twitter: () => <div data-testid="twitter-icon" />,
  Mail: () => <div data-testid="mail-icon" />,
  Heart: () => <div data-testid="heart-icon" />,
  ExternalLink: () => <div data-testid="external-link-icon" />,
  Shield: () => <div data-testid="shield-icon" />,
  Zap: () => <div data-testid="zap-icon" />,
// Orphaned closing removed
/**
 * Footer Component Tests
 * Tests the footer component with proper TypeScript types
 */


// Mock UI components
// Orphaned closing removed
// Mock Next.js Link
// Mock Lucide icons
describe('Footer Component', () => {
  beforeEach(() => {
    jest.clearAllMocks();
  });

describe('Rendering', () => {
    it('should render footer with all sections', () => {
      render(<Footer />);
      // Brand info
      expect(screen.getByText('Enterprise Auth')).toBeInTheDocument();
      expect(screen.getByText(/Secure, scalable authentication/i)).toBeInTheDocument();
      // Footer sections
      expect(screen.getByText('Product')).toBeInTheDocument();
      expect(screen.getByText('Company')).toBeInTheDocument();
      expect(screen.getByText('Support')).toBeInTheDocument();
      expect(screen.getByText('Legal')).toBeInTheDocument();
    });
    it('should render copyright information', () => {
      render(<Footer />);
      expect(screen.getByText(/© 2024 Enterprise Auth Template/i)).toBeInTheDocument();
    });
    it('should apply custom className', () => {
      const { container } = render(<Footer className="custom-footer" />);
      const footer = container.firstChild as HTMLElement;
      expect(footer).toHaveClass('custom-footer');
    });
    it('should render SOC 2 compliance badge', () => {
      render(<Footer />);
      expect(screen.getByText('SOC 2 Compliant')).toBeInTheDocument();
      expect(screen.getByTestId('shield-icon')).toBeInTheDocument();
    });
  });

describe('Links', () => {
    it('should render product links', () => {
      render(<Footer />);
      expect(screen.getByText('Features')).toHaveAttribute('href', '/help');
      expect(screen.getByText('API Documentation')).toHaveAttribute('href', '/help/api');
      expect(screen.getByText('Tutorials')).toHaveAttribute('href', '/help/tutorials');
      expect(screen.getByText('System Status')).toHaveAttribute('href', 'https://status.example.com');
    });
    it('should render company links', () => {
      render(<Footer />);
      expect(screen.getByText('About')).toHaveAttribute('href', '/about');
      expect(screen.getByText('Blog')).toHaveAttribute('href', '/blog');
      expect(screen.getByText('Careers')).toHaveAttribute('href', '/careers');
      expect(screen.getByText('Contact')).toHaveAttribute('href', '/help/contact');
    });
    it('should render support links', () => {
      render(<Footer />);
      expect(screen.getByText('Help Center')).toHaveAttribute('href', '/help');
      expect(screen.getByText('Community')).toHaveAttribute('href', 'https://community.example.com');
      expect(screen.getByText('Contact Support')).toHaveAttribute('href', '/help/contact');
      expect(screen.getByText('Report Issue')).toHaveAttribute('href', '/help/contact?type=bug');
    });
    it('should render legal links', () => {
      render(<Footer />);
      expect(screen.getByText('Privacy Policy')).toHaveAttribute('href', '/privacy');
      expect(screen.getByText('Terms of Service')).toHaveAttribute('href', '/terms');
      expect(screen.getByText('Security')).toHaveAttribute('href', '/security');
      expect(screen.getByText('Compliance')).toHaveAttribute('href', '/compliance');
    });
  });

describe('Social Links', () => {
    it('should render social media links', () => {
      render(<Footer />);
      expect(screen.getByTestId('github-icon')).toBeInTheDocument();
      expect(screen.getByTestId('twitter-icon')).toBeInTheDocument();
      expect(screen.getByTestId('mail-icon')).toBeInTheDocument();
    });
    it('should open social links in new tab', () => {
      render(<Footer />);
      const githubLink = screen.getByTestId('github-icon').closest('a');
      expect(githubLink).toHaveAttribute('target', '_blank');
      expect(githubLink).toHaveAttribute('rel', 'noopener noreferrer');
    });
    it('should have correct social media URLs', () => {
      render(<Footer />);
      const githubLink = screen.getByTestId('github-icon').closest('a');
      const twitterLink = screen.getByTestId('twitter-icon').closest('a');
      const mailLink = screen.getByTestId('mail-icon').closest('a');
      expect(githubLink).toHaveAttribute('href', 'https://github.com/example');
      expect(twitterLink).toHaveAttribute('href', 'https://twitter.com/example');
      expect(mailLink).toHaveAttribute('href', 'mailto:support@example.com');
    });
  });

describe('External Links', () => {
    it('should show external link icons for external URLs', () => {
      render(<Footer />);
      // External links should have the external link icon
      expect(screen.getAllByTestId('external-link-icon')).toHaveLength(2); // System Status and Community
    });
  });

describe('Bottom Section', () => {
    it('should render "Made with heart" message', () => {
      render(<Footer />);
      expect(screen.getByText((content, element) => {
        return element?.textContent === 'Made with  by developers';
      })).toBeInTheDocument();
      expect(screen.getByTestId('heart-icon')).toBeInTheDocument();
    });
    it('should show system status', () => {
      render(<Footer />);
      expect(screen.getByText('All systems operational')).toBeInTheDocument();
    });
  });

describe('Minimal Mode', () => {
    it('should render minimal footer when minimal prop is true', () => {
      render(<Footer minimal={true} />);
      // Should show basic branding and copyright
      expect(screen.getByText('Enterprise Auth Template')).toBeInTheDocument();
      expect(screen.getByText(/© 2024 Enterprise Auth/)).toBeInTheDocument();
      // Should not show other sections
      expect(screen.queryByText('Product')).not.toBeInTheDocument();
      expect(screen.queryByText('Company')).not.toBeInTheDocument();
      expect(screen.queryByText('Support')).not.toBeInTheDocument();
      expect(screen.queryByText('Legal')).not.toBeInTheDocument();
    });
    it('should show zap icon in minimal mode', () => {
      render(<Footer minimal={true} />);
      expect(screen.getByTestId('zap-icon')).toBeInTheDocument();
    });
  });