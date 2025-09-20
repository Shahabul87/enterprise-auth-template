#!/bin/bash

# This script creates all the remaining test files for frontend components
# It's generated to save time and ensure all components have proper tests

echo "Creating remaining test files for frontend components..."

# Form Components Tests
cat > src/__tests__/components/forms/form-field.test.tsx << 'EOF'
import React from 'react';
import { render, screen } from '@testing-library/react';
import '@testing-library/jest-dom';
import { FormField } from '@/components/forms/form-field';

describe('FormField Component', () => {
  const defaultProps = {
    label: 'Test Label',
    name: 'testField',
    type: 'text' as const,
    placeholder: 'Enter value',
  };

  it('should render form field with label', () => {
    render(<FormField {...defaultProps} />);
    expect(screen.getByLabelText('Test Label')).toBeInTheDocument();
  });

  it('should render required indicator when required', () => {
    render(<FormField {...defaultProps} required />);
    expect(screen.getByText('*')).toBeInTheDocument();
  });

  it('should render error message when error prop is provided', () => {
    render(<FormField {...defaultProps} error="This field is required" />);
    expect(screen.getByText('This field is required')).toBeInTheDocument();
  });

  it('should render help text when provided', () => {
    render(<FormField {...defaultProps} helpText="This is help text" />);
    expect(screen.getByText('This is help text')).toBeInTheDocument();
  });

  it('should handle different input types', () => {
    const types: Array<'text' | 'email' | 'password' | 'number'> = ['text', 'email', 'password', 'number'];
    types.forEach(type => {
      const { container } = render(<FormField {...defaultProps} type={type} />);
      const input = container.querySelector(`input[type="${type}"]`);
      expect(input).toBeInTheDocument();
    });
  });
});
EOF

cat > src/__tests__/components/forms/form-section.test.tsx << 'EOF'
import React from 'react';
import { render, screen } from '@testing-library/react';
import '@testing-library/jest-dom';
import { FormSection } from '@/components/forms/form-section';

describe('FormSection Component', () => {
  it('should render section title', () => {
    render(
      <FormSection title="Personal Information">
        <div>Content</div>
      </FormSection>
    );
    expect(screen.getByText('Personal Information')).toBeInTheDocument();
  });

  it('should render section description', () => {
    render(
      <FormSection title="Section" description="This is a description">
        <div>Content</div>
      </FormSection>
    );
    expect(screen.getByText('This is a description')).toBeInTheDocument();
  });

  it('should render children content', () => {
    render(
      <FormSection title="Section">
        <div>Child content</div>
      </FormSection>
    );
    expect(screen.getByText('Child content')).toBeInTheDocument();
  });

  it('should apply custom className', () => {
    render(
      <FormSection title="Section" className="custom-class">
        <div>Content</div>
      </FormSection>
    );
    const section = screen.getByText('Section').closest('div');
    expect(section?.parentElement).toHaveClass('custom-class');
  });
});
EOF

# Navigation Components Tests
cat > src/__tests__/components/navigation/breadcrumbs.test.tsx << 'EOF'
import React from 'react';
import { render, screen } from '@testing-library/react';
import '@testing-library/jest-dom';
import { Breadcrumbs } from '@/components/navigation/breadcrumbs';

describe('Breadcrumbs Component', () => {
  const items = [
    { label: 'Home', href: '/' },
    { label: 'Settings', href: '/settings' },
    { label: 'Profile', href: '/settings/profile' },
  ];

  it('should render all breadcrumb items', () => {
    render(<Breadcrumbs items={items} />);
    items.forEach(item => {
      expect(screen.getByText(item.label)).toBeInTheDocument();
    });
  });

  it('should render links for non-current items', () => {
    render(<Breadcrumbs items={items} />);
    const homeLink = screen.getByRole('link', { name: 'Home' });
    expect(homeLink).toHaveAttribute('href', '/');
  });

  it('should render current item without link', () => {
    render(<Breadcrumbs items={items} />);
    const profileItem = screen.getByText('Profile');
    expect(profileItem.closest('a')).not.toBeInTheDocument();
  });

  it('should render separators between items', () => {
    render(<Breadcrumbs items={items} />);
    const separators = screen.getAllByText('/');
    expect(separators).toHaveLength(items.length - 1);
  });

  it('should handle single item', () => {
    render(<Breadcrumbs items={[{ label: 'Home', href: '/' }]} />);
    expect(screen.getByText('Home')).toBeInTheDocument();
    expect(screen.queryByText('/')).not.toBeInTheDocument();
  });
});
EOF

cat > src/__tests__/components/navigation/nav-menu.test.tsx << 'EOF'
import React from 'react';
import { render, screen, fireEvent } from '@testing-library/react';
import '@testing-library/jest-dom';
import { NavMenu } from '@/components/navigation/nav-menu';

describe('NavMenu Component', () => {
  const menuItems = [
    { label: 'Dashboard', href: '/dashboard', icon: 'home' },
    { label: 'Profile', href: '/profile', icon: 'user' },
    { label: 'Settings', href: '/settings', icon: 'settings' },
  ];

  it('should render all menu items', () => {
    render(<NavMenu items={menuItems} />);
    menuItems.forEach(item => {
      expect(screen.getByText(item.label)).toBeInTheDocument();
    });
  });

  it('should highlight active item', () => {
    render(<NavMenu items={menuItems} activeItem="/profile" />);
    const profileItem = screen.getByText('Profile').closest('a');
    expect(profileItem).toHaveClass('active');
  });

  it('should handle item click', () => {
    const handleClick = jest.fn();
    render(<NavMenu items={menuItems} onItemClick={handleClick} />);

    fireEvent.click(screen.getByText('Dashboard'));
    expect(handleClick).toHaveBeenCalledWith('/dashboard');
  });

  it('should render icons when provided', () => {
    render(<NavMenu items={menuItems} />);
    const icons = screen.getAllByTestId(/icon-/);
    expect(icons).toHaveLength(menuItems.length);
  });
});
EOF

# Chart Components Tests
cat > src/__tests__/components/charts/bar-chart.test.tsx << 'EOF'
import React from 'react';
import { render, screen } from '@testing-library/react';
import '@testing-library/jest-dom';
import { BarChart } from '@/components/charts/bar-chart';

describe('BarChart Component', () => {
  const mockData = [
    { label: 'Jan', value: 100 },
    { label: 'Feb', value: 200 },
    { label: 'Mar', value: 150 },
  ];

  it('should render chart container', () => {
    render(<BarChart data={mockData} />);
    const chart = screen.getByTestId('bar-chart');
    expect(chart).toBeInTheDocument();
  });

  it('should render with custom dimensions', () => {
    render(<BarChart data={mockData} width={600} height={400} />);
    const chart = screen.getByTestId('bar-chart');
    expect(chart).toHaveAttribute('width', '600');
    expect(chart).toHaveAttribute('height', '400');
  });

  it('should handle empty data', () => {
    render(<BarChart data={[]} />);
    expect(screen.getByText('No data available')).toBeInTheDocument();
  });

  it('should apply custom colors', () => {
    render(<BarChart data={mockData} color="#FF5733" />);
    const bars = screen.getAllByTestId('bar');
    bars.forEach(bar => {
      expect(bar).toHaveStyle('fill: #FF5733');
    });
  });
});
EOF

cat > src/__tests__/components/charts/line-chart.test.tsx << 'EOF'
import React from 'react';
import { render, screen } from '@testing-library/react';
import '@testing-library/jest-dom';
import { LineChart } from '@/components/charts/line-chart';

describe('LineChart Component', () => {
  const mockData = [
    { x: 0, y: 10 },
    { x: 1, y: 20 },
    { x: 2, y: 15 },
  ];

  it('should render chart container', () => {
    render(<LineChart data={mockData} />);
    const chart = screen.getByTestId('line-chart');
    expect(chart).toBeInTheDocument();
  });

  it('should render with custom dimensions', () => {
    render(<LineChart data={mockData} width={800} height={600} />);
    const chart = screen.getByTestId('line-chart');
    expect(chart).toHaveAttribute('width', '800');
    expect(chart).toHaveAttribute('height', '600');
  });

  it('should handle empty data', () => {
    render(<LineChart data={[]} />);
    expect(screen.getByText('No data available')).toBeInTheDocument();
  });

  it('should show data points when enabled', () => {
    render(<LineChart data={mockData} showPoints />);
    const points = screen.getAllByTestId('data-point');
    expect(points).toHaveLength(mockData.length);
  });
});
EOF

# Modal Components Tests
cat > src/__tests__/components/modals/user-modal.test.tsx << 'EOF'
import React from 'react';
import { render, screen, fireEvent } from '@testing-library/react';
import '@testing-library/jest-dom';
import { UserModal } from '@/components/modals/user-modal';

describe('UserModal Component', () => {
  const mockUser = {
    id: '1',
    name: 'John Doe',
    email: 'john@example.com',
    role: 'admin',
  };

  it('should render modal when open', () => {
    render(<UserModal isOpen={true} user={mockUser} onClose={jest.fn()} />);
    expect(screen.getByText('User Details')).toBeInTheDocument();
  });

  it('should not render when closed', () => {
    render(<UserModal isOpen={false} user={mockUser} onClose={jest.fn()} />);
    expect(screen.queryByText('User Details')).not.toBeInTheDocument();
  });

  it('should display user information', () => {
    render(<UserModal isOpen={true} user={mockUser} onClose={jest.fn()} />);
    expect(screen.getByText('John Doe')).toBeInTheDocument();
    expect(screen.getByText('john@example.com')).toBeInTheDocument();
    expect(screen.getByText('admin')).toBeInTheDocument();
  });

  it('should call onClose when close button is clicked', () => {
    const handleClose = jest.fn();
    render(<UserModal isOpen={true} user={mockUser} onClose={handleClose} />);

    fireEvent.click(screen.getByRole('button', { name: 'Close' }));
    expect(handleClose).toHaveBeenCalledTimes(1);
  });

  it('should handle edit mode', () => {
    const handleSave = jest.fn();
    render(
      <UserModal
        isOpen={true}
        user={mockUser}
        mode="edit"
        onSave={handleSave}
        onClose={jest.fn()}
      />
    );

    expect(screen.getByLabelText('Name')).toHaveValue('John Doe');
    expect(screen.getByRole('button', { name: 'Save' })).toBeInTheDocument();
  });
});
EOF

cat > src/__tests__/components/modals/confirm-modal.test.tsx << 'EOF'
import React from 'react';
import { render, screen, fireEvent } from '@testing-library/react';
import '@testing-library/jest-dom';
import { ConfirmModal } from '@/components/modals/confirm-modal';

describe('ConfirmModal Component', () => {
  const defaultProps = {
    isOpen: true,
    title: 'Confirm Action',
    message: 'Are you sure you want to proceed?',
    onConfirm: jest.fn(),
    onCancel: jest.fn(),
  };

  it('should render modal when open', () => {
    render(<ConfirmModal {...defaultProps} />);
    expect(screen.getByText('Confirm Action')).toBeInTheDocument();
    expect(screen.getByText('Are you sure you want to proceed?')).toBeInTheDocument();
  });

  it('should not render when closed', () => {
    render(<ConfirmModal {...defaultProps} isOpen={false} />);
    expect(screen.queryByText('Confirm Action')).not.toBeInTheDocument();
  });

  it('should call onConfirm when confirm button is clicked', () => {
    const handleConfirm = jest.fn();
    render(<ConfirmModal {...defaultProps} onConfirm={handleConfirm} />);

    fireEvent.click(screen.getByRole('button', { name: 'Confirm' }));
    expect(handleConfirm).toHaveBeenCalledTimes(1);
  });

  it('should call onCancel when cancel button is clicked', () => {
    const handleCancel = jest.fn();
    render(<ConfirmModal {...defaultProps} onCancel={handleCancel} />);

    fireEvent.click(screen.getByRole('button', { name: 'Cancel' }));
    expect(handleCancel).toHaveBeenCalledTimes(1);
  });

  it('should render with danger variant', () => {
    render(<ConfirmModal {...defaultProps} variant="danger" />);
    const confirmButton = screen.getByRole('button', { name: 'Confirm' });
    expect(confirmButton).toHaveClass('bg-red-600');
  });
});
EOF

# Shared Components Tests
cat > src/__tests__/components/shared/data-table.test.tsx << 'EOF'
import React from 'react';
import { render, screen, fireEvent } from '@testing-library/react';
import '@testing-library/jest-dom';
import { DataTable } from '@/components/shared/data-table';

describe('DataTable Component', () => {
  const columns = [
    { key: 'id', label: 'ID', sortable: true },
    { key: 'name', label: 'Name', sortable: true },
    { key: 'email', label: 'Email', sortable: false },
  ];

  const data = [
    { id: '1', name: 'John Doe', email: 'john@example.com' },
    { id: '2', name: 'Jane Smith', email: 'jane@example.com' },
    { id: '3', name: 'Bob Johnson', email: 'bob@example.com' },
  ];

  it('should render table with headers', () => {
    render(<DataTable columns={columns} data={data} />);
    columns.forEach(column => {
      expect(screen.getByText(column.label)).toBeInTheDocument();
    });
  });

  it('should render all data rows', () => {
    render(<DataTable columns={columns} data={data} />);
    data.forEach(row => {
      expect(screen.getByText(row.name)).toBeInTheDocument();
      expect(screen.getByText(row.email)).toBeInTheDocument();
    });
  });

  it('should handle sorting', () => {
    const handleSort = jest.fn();
    render(<DataTable columns={columns} data={data} onSort={handleSort} />);

    fireEvent.click(screen.getByText('Name'));
    expect(handleSort).toHaveBeenCalledWith('name', 'asc');
  });

  it('should handle row selection', () => {
    const handleSelect = jest.fn();
    render(<DataTable columns={columns} data={data} selectable onSelect={handleSelect} />);

    const checkboxes = screen.getAllByRole('checkbox');
    fireEvent.click(checkboxes[1]);
    expect(handleSelect).toHaveBeenCalledWith(['1']);
  });

  it('should handle empty data', () => {
    render(<DataTable columns={columns} data={[]} emptyMessage="No data found" />);
    expect(screen.getByText('No data found')).toBeInTheDocument();
  });
});
EOF

cat > src/__tests__/components/shared/empty-state.test.tsx << 'EOF'
import React from 'react';
import { render, screen, fireEvent } from '@testing-library/react';
import '@testing-library/jest-dom';
import { EmptyState } from '@/components/shared/empty-state';

describe('EmptyState Component', () => {
  it('should render title and description', () => {
    render(
      <EmptyState
        title="No results found"
        description="Try adjusting your filters"
      />
    );
    expect(screen.getByText('No results found')).toBeInTheDocument();
    expect(screen.getByText('Try adjusting your filters')).toBeInTheDocument();
  });

  it('should render icon when provided', () => {
    render(
      <EmptyState
        title="No data"
        icon="search"
      />
    );
    expect(screen.getByTestId('empty-state-icon')).toBeInTheDocument();
  });

  it('should render action button', () => {
    const handleAction = jest.fn();
    render(
      <EmptyState
        title="No items"
        action={{
          label: 'Add Item',
          onClick: handleAction,
        }}
      />
    );

    const button = screen.getByRole('button', { name: 'Add Item' });
    expect(button).toBeInTheDocument();

    fireEvent.click(button);
    expect(handleAction).toHaveBeenCalledTimes(1);
  });

  it('should apply custom className', () => {
    render(
      <EmptyState
        title="Empty"
        className="custom-empty-state"
      />
    );
    const container = screen.getByText('Empty').parentElement;
    expect(container).toHaveClass('custom-empty-state');
  });
});
EOF

echo "Test files created successfully!"
echo "To run all tests, use: npm test"