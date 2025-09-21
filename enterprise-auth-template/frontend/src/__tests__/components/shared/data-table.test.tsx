
import React from 'react';
import { render, screen, fireEvent } from '@testing-library/react';
import '@testing-library/jest-dom';
import { DataTable } from '@/components/shared/data-table';
describe('DataTable Component', () => {
  const columns = [
    {
      accessorKey: 'id',
      header: 'ID',
    },
    {
      accessorKey: 'name',
      header: 'Name',
    },
    {
      accessorKey: 'email',
      header: 'Email',
    },
  ];

  const data = [
    { id: '1', name: 'John Doe', email: 'john@example.com' },
    { id: '2', name: 'Jane Smith', email: 'jane@example.com' },
    { id: '3', name: 'Bob Johnson', email: 'bob@example.com' },
  ];

  it('should render the data table component with toolbar', () => {
    render(<DataTable columns={columns} data={data} />);

    // Check for search input
    expect(screen.getByPlaceholderText('Search...')).toBeInTheDocument();

    // Check for columns dropdown
    expect(screen.getByText('Columns')).toBeInTheDocument();
  });

  it('should render loading state', () => {
    render(<DataTable columns={columns} data={data} isLoading={true} />);
    expect(screen.getByText('Loading...')).toBeInTheDocument();
  });

  it('should render empty state when no data', () => {
    render(<DataTable columns={columns} data={[]} />);
    expect(screen.getByText('No results found.')).toBeInTheDocument();
  });

  it('should handle global search input', () => {
    render(<DataTable columns={columns} data={data} />);

    const searchInput = screen.getByPlaceholderText('Search...');
    fireEvent.change(searchInput, { target: { value: 'test search' } });

    expect(searchInput).toHaveValue('test search');
  });

  it('should show refresh button when enabled', () => {
    const onRefresh = jest.fn();
    render(<DataTable columns={columns} data={data} showRefresh={true} onRefresh={onRefresh} />);

    const refreshButton = screen.getByText('Refresh');
    expect(refreshButton).toBeInTheDocument();

    fireEvent.click(refreshButton);
    expect(onRefresh).toHaveBeenCalled();
  });

  it('should show export button when enabled', () => {
    const onExport = jest.fn();
    render(<DataTable columns={columns} data={data} showExport={true} onExport={onExport} />);

    const exportButton = screen.getByText('Export');
    expect(exportButton).toBeInTheDocument();

    fireEvent.click(exportButton);
    expect(onExport).toHaveBeenCalled();
  });

  it('should render search key input when provided', () => {
    render(<DataTable columns={columns} data={data} searchKey="name" />);

    expect(screen.getByPlaceholderText('Filter by name...')).toBeInTheDocument();
  });

  it('should handle custom search placeholder', () => {
    render(<DataTable columns={columns} data={data} searchPlaceholder="Find items..." />);

    expect(screen.getByPlaceholderText('Find items...')).toBeInTheDocument();
  });

  it('should disable refresh button when loading', () => {
    const onRefresh = jest.fn();
    render(<DataTable columns={columns} data={data} showRefresh={true} onRefresh={onRefresh} isLoading={true} />);

    const refreshButton = screen.getByText('Refresh');
    expect(refreshButton).toBeDisabled();
  });
});
