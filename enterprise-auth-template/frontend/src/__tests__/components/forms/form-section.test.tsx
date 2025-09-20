
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
