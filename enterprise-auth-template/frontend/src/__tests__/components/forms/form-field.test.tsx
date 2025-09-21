
import React from 'react';
import { render, screen } from '@testing-library/react';
import '@testing-library/jest-dom';
import {
  TextField,
  TextareaField,
  SelectField,
  SwitchField,
  CheckboxField,
  MultiSelectField
} from '@/components/forms/form-field';
describe('Form Field Components', () => {
  describe('TextField', () => {
    const defaultProps = {
      label: 'Test Label',
      id: 'testField',
      placeholder: 'Enter value',
    };

    it('should render text field with label', () => {
      render(<TextField {...defaultProps} />);
      expect(screen.getByLabelText('Test Label')).toBeInTheDocument();
    });

    it('should render required indicator when required', () => {
      render(<TextField {...defaultProps} required />);
      expect(screen.getByText('*')).toBeInTheDocument();
    });

    it('should render error message when error prop is provided', () => {
      render(<TextField {...defaultProps} error="This field is required" />);
      expect(screen.getByText('This field is required')).toBeInTheDocument();
    });

    it('should render description text when provided', () => {
      render(<TextField {...defaultProps} description="This is help text" />);
      expect(screen.getByText('This is help text')).toBeInTheDocument();
    });

    it('should handle different input types', () => {
      const types: Array<'text' | 'email' | 'password' | 'number'> = ['text', 'email', 'password', 'number'];
      types.forEach(type => {
        const { container } = render(<TextField {...defaultProps} type={type} key={type} />);
        const input = container.querySelector(`input[type="${type}"]`);
        expect(input).toBeInTheDocument();
      });
    });
  });

  describe('TextareaField', () => {
    it('should render textarea with label', () => {
      render(<TextareaField label="Comments" id="comments" />);
      expect(screen.getByLabelText('Comments')).toBeInTheDocument();
    });

    it('should show character count when enabled', () => {
      render(
        <TextareaField
          label="Description"
          value="Test"
          maxLength={100}
          showCharCount
        />
      );
      expect(screen.getByText('4/100')).toBeInTheDocument();
    });
  });

  describe('SelectField', () => {
    const options = [
      { label: 'Option 1', value: 'opt1' },
      { label: 'Option 2', value: 'opt2' },
    ];

    it('should render select field with options', () => {
      render(
        <SelectField
          label="Choose Option"
          id="select"
          options={options}
        />
      );
      expect(screen.getByLabelText('Choose Option')).toBeInTheDocument();
    });

    it('should render error state', () => {
      render(
        <SelectField
          label="Select"
          options={options}
          error="Please select an option"
        />
      );
      expect(screen.getByText('Please select an option')).toBeInTheDocument();
    });
  });

  describe('CheckboxField', () => {
    it('should render checkbox with label', () => {
      render(<CheckboxField label="Agree to terms" id="terms" />);
      expect(screen.getByLabelText('Agree to terms')).toBeInTheDocument();
    });

    it('should show required indicator', () => {
      render(<CheckboxField label="Required field" required />);
      expect(screen.getByText('*')).toBeInTheDocument();
    });
  });

  describe('MultiSelectField', () => {
    const options = [
      { label: 'Tag 1', value: 'tag1' },
      { label: 'Tag 2', value: 'tag2' },
      { label: 'Tag 3', value: 'tag3' },
    ];

    it('should render multi-select field', () => {
      render(
        <MultiSelectField
          label="Select Tags"
          id="tags"
          options={options}
        />
      );
      expect(screen.getByText('Select Tags')).toBeInTheDocument();
    });

    it('should display selected count when maxItems is set', () => {
      render(
        <MultiSelectField
          label="Tags"
          options={options}
          value={['tag1']}
          maxItems={3}
        />
      );
      expect(screen.getByText('1/3')).toBeInTheDocument();
    });
  });
});
