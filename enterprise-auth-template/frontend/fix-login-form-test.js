#!/usr/bin/env node

const fs = require('fs');
const path = require('path');

const testFile = path.join(__dirname, 'src/__tests__/components/login-form.test.tsx');

let content = fs.readFileSync(testFile, 'utf8');

// Fix the useFormErrorHandler mock to return proper error object
const errorHandlerMock = `jest.mock('@/hooks/use-error-handler', () => ({
  useFormErrorHandler: () => ({
    handleFormError: jest.fn((error) => ({
      userMessage: error?.message || 'An error occurred',
      field: null,
      details: {}
    })),
    clearAllErrors: jest.fn(),
    errors: {},
  }),
}));`;

// Replace the existing mock
content = content.replace(
  /jest\.mock\('@\/hooks\/use-error-handler', \(\) => \(\{[\s\S]*?\}\)\);/,
  errorHandlerMock
);

// Also wrap the handleSubmit in the useAuthForm mock with proper act()
const improvedHandleSubmitMock = `  handleSubmit: (onSubmit) => {
    return async (e) => {
      if (e) e.preventDefault();
      setIsSubmitting(true);
      try {
        const result = await onSubmit(values);
        return result;
      } catch (error) {
        // Handle error properly
        return false;
      } finally {
        setIsSubmitting(false);
      }
    };
  },`;

// Replace the handleSubmit in useAuthForm mock
content = content.replace(
  /handleSubmit: async \(onSubmit\) => \{[\s\S]*?\},/,
  improvedHandleSubmitMock
);

// Also ensure the login mock returns proper response
const loginMockPattern = /const mockLogin = jest\.fn\(\)\.mockResolvedValue\(\{[^}]*\}\);/;
if (loginMockPattern.test(content)) {
  content = content.replace(
    loginMockPattern,
    `const mockLogin = jest.fn().mockResolvedValue({
  success: true,
  data: { user: { id: '1', email: 'test@example.com' }, token: 'mock-token' }
});`
  );
} else {
  // Add the login mock if it doesn't exist
  const mockDependenciesIndex = content.indexOf('// Mock dependencies');
  if (mockDependenciesIndex > -1) {
    const insertPoint = content.indexOf('\n', mockDependenciesIndex) + 1;
    content = content.substring(0, insertPoint) +
      `const mockLogin = jest.fn().mockResolvedValue({
  success: true,
  data: { user: { id: '1', email: 'test@example.com' }, token: 'mock-token' }
});\n` +
      content.substring(insertPoint);
  }
}

// Also fix the act() warnings by properly wrapping async operations
const testPattern = /it\('should handle successful login', async \(\) => \{[\s\S]*?\}\);/;
if (testPattern.test(content)) {
  const improvedTest = `it('should handle successful login', async () => {
    const onSuccess = jest.fn();
    mockLogin.mockResolvedValue({
      success: true,
      data: { user: { id: '1', email: 'test@example.com' }, token: 'mock-token' }
    });

    const { getByRole, getByPlaceholderText } = render(<LoginForm onSuccess={onSuccess} />);

    const emailInput = getByPlaceholderText(/email/i) || getByRole('textbox', { name: /email/i });
    const passwordInput = getByPlaceholderText(/password/i);
    const submitButton = getByRole('button', { name: /sign in/i });

    await act(async () => {
      fireEvent.change(emailInput, { target: { value: 'test@example.com' } });
      fireEvent.change(passwordInput, { target: { value: 'password123' } });
    });

    await act(async () => {
      fireEvent.click(submitButton);
    });

    await waitFor(() => {
      expect(mockLogin).toHaveBeenCalledWith({
        email: 'test@example.com',
        password: 'password123'
      });
    });
  });`;

  content = content.replace(testPattern, improvedTest);
}

fs.writeFileSync(testFile, content, 'utf8');
console.log('✓ Fixed login-form test');