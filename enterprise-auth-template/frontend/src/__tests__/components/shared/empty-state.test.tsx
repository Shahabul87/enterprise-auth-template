
import React from 'react';
import { render, screen, fireEvent } from '@testing-library/react';
import '@testing-library/jest-dom';
import { EmptyState, NoDataFound, NoSearchResults } from '@/components/shared/empty-state';


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
    const { container } = render(
      <EmptyState
        title="No data"
        description="No data available"
        icon="search"
      />
    );
    // Check for the search icon SVG element
    const svgElement = container.querySelector('svg');
    expect(svgElement).toBeInTheDocument();
  });

  it('should render action button', () => {
    const handleAction = jest.fn();
    render(
      <EmptyState
        title="No items"
        description="No items available"
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
    const { container } = render(
      <EmptyState
        title="Empty"
        description="Empty state"
        className="custom-empty-state"
      />
    );
    // Find the card element with the custom class
    const card = container.querySelector('.custom-empty-state');
    expect(card).toBeInTheDocument();
  });

  it('should render NoDataFound variant', () => {
    const onCreate = jest.fn();
    render(
      <NoDataFound entity="users" onCreate={onCreate} />
    );

    expect(screen.getByText('No users found')).toBeInTheDocument();
    expect(screen.getByText('There are no users items to display at the moment.')).toBeInTheDocument();

    const addButton = screen.getByRole('button', { name: /Add users/i });
    fireEvent.click(addButton);
    expect(onCreate).toHaveBeenCalled();
  });

  it('should render NoSearchResults variant', () => {
    const onClearSearch = jest.fn();
    render(
      <NoSearchResults searchTerm="test search" onClearSearch={onClearSearch} />
    );

    expect(screen.getByText('No results found')).toBeInTheDocument();
    expect(screen.getByText(/We couldn't find any results for "test search"/)).toBeInTheDocument();

    const clearButton = screen.getByRole('button', { name: /Clear search/i });
    fireEvent.click(clearButton);
    expect(onClearSearch).toHaveBeenCalled();
  });
});
