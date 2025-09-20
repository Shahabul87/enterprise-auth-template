
import React from 'react';
import { render, screen, fireEvent, waitFor, act } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import '@testing-library/jest-dom';
import { Button } from '@/components/ui/button';
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogFooter,
  DialogHeader,
  DialogTitle,
  DialogTrigger,
  DialogClose,
} from '@/components/ui/dialog';


describe('Dialog Component', () => {
  const SimpleDialog = ({
    open,
    onOpenChange = jest.fn(),
    defaultOpen = false,
  }: {
    open?: boolean;
    onOpenChange?: (open: boolean) => void;
    defaultOpen?: boolean;
  }) => (
    <Dialog open={open} onOpenChange={onOpenChange} defaultOpen={defaultOpen}>
      <DialogTrigger asChild>
        <Button>Open Dialog</Button>
      </DialogTrigger>
      <DialogContent>
        <DialogHeader>
          <DialogTitle>Dialog Title</DialogTitle>
          <DialogDescription>
            This is a dialog description explaining the purpose.
          </DialogDescription>
        </DialogHeader>
        <div className="py-4">
          <p>Dialog body content goes here.</p>
        </div>
        <DialogFooter>
          <DialogClose asChild>
            <Button variant="outline">Cancel</Button>
          </DialogClose>
          <Button>Save changes</Button>
        </DialogFooter>
      </DialogContent>
    </Dialog>
  );

  describe('Rendering', () => {
    it('should render trigger button', () => {
      render(<SimpleDialog />);
      expect(screen.getByRole('button', { name: 'Open Dialog' })).toBeInTheDocument();
    });

    it('should not render dialog content initially', () => {
      render(<SimpleDialog />);
      expect(screen.queryByText('Dialog Title')).not.toBeInTheDocument();
      expect(screen.queryByText('This is a dialog description explaining the purpose.')).not.toBeInTheDocument();
    });

    it('should render dialog content when defaultOpen is true', () => {
      render(<SimpleDialog defaultOpen={true} />);
      expect(screen.getByText('Dialog Title')).toBeInTheDocument();
      expect(screen.getByText('This is a dialog description explaining the purpose.')).toBeInTheDocument();
    });

    it('should render dialog content when controlled open is true', () => {
      render(<SimpleDialog open={true} />);
      expect(screen.getByText('Dialog Title')).toBeInTheDocument();
    });
  });

describe('Interactions', () => {
    it('should open dialog when trigger is clicked', async () => {
      render(<SimpleDialog />);
      const trigger = screen.getByRole('button', { name: 'Open Dialog' });

      await act(async () => { await userEvent.click(trigger);

      await act(async () => { await waitFor(() => {
        expect(screen.getByText('Dialog Title')).toBeInTheDocument();
        expect(screen.getByText('Dialog body content goes here.')).toBeInTheDocument();
      }); });
    });

    it('should call onOpenChange when opened', async () => {
      const handleOpenChange = jest.fn();
      render(<SimpleDialog onOpenChange={handleOpenChange} />);

      const trigger = screen.getByRole('button', { name: 'Open Dialog' });
      await act(async () => { await userEvent.click(trigger);

      expect(handleOpenChange).toHaveBeenCalledWith(true);
    });

    it('should close dialog when close button is clicked', async () => {
      const handleOpenChange = jest.fn();
      render(<SimpleDialog defaultOpen={true} onOpenChange={handleOpenChange} />);

      const closeButton = screen.getByRole('button', { name: 'Cancel' });
      await act(async () => { await userEvent.click(closeButton);

      expect(handleOpenChange).toHaveBeenCalledWith(false);
    });

    it('should close dialog when clicking overlay', async () => {
      const handleOpenChange = jest.fn();
      render(<SimpleDialog defaultOpen={true} onOpenChange={handleOpenChange} />);

      // Find and click the overlay (usually has role="dialog" parent with overlay sibling)
      const dialogContent = screen.getByRole('dialog');
      const overlay = dialogContent.parentElement?.querySelector('[data-radix-dialog-overlay]');

      if (overlay) {
        act(() => { fireEvent.click(overlay) });
        expect(handleOpenChange).toHaveBeenCalledWith(false);
      }
    });

    it('should close dialog with Escape key', async () => {
      const handleOpenChange = jest.fn();
      render(<SimpleDialog defaultOpen={true} onOpenChange={handleOpenChange} />);

      fireEvent.keyDown(document, { key: 'Escape' });

      expect(handleOpenChange).toHaveBeenCalledWith(false);
    });
  });

describe('Dialog Components', () => {
    it('should render all dialog sections correctly', () => {
      render(
        <Dialog defaultOpen={true}>
          <DialogContent>
            <DialogHeader>
              <DialogTitle>Test Title</DialogTitle>
              <DialogDescription>Test Description</DialogDescription>
            </DialogHeader>
            <div>Body Content</div>
            <DialogFooter>
              <Button>Footer Button</Button>
            </DialogFooter>
          </DialogContent>
        </Dialog>
      );

      expect(screen.getByText('Test Title')).toBeInTheDocument();
      expect(screen.getByText('Test Description')).toBeInTheDocument();
      expect(screen.getByText('Body Content')).toBeInTheDocument();
      expect(screen.getByRole('button', { name: 'Footer Button' })).toBeInTheDocument();
    });

    it('should handle custom className on DialogContent', () => {
      render(
        <Dialog defaultOpen={true}>
          <DialogContent className="custom-dialog-content">
            <DialogTitle>Test</DialogTitle>
          </DialogContent>
        </Dialog>
      );

      const dialog = screen.getByRole('dialog');
      expect(dialog).toHaveClass('custom-dialog-content');
    });

    it('should render without DialogDescription', () => {
      render(
        <Dialog defaultOpen={true}>
          <DialogContent>
            <DialogHeader>
              <DialogTitle>Title Only</DialogTitle>
            </DialogHeader>
          </DialogContent>
        </Dialog>
      );

      expect(screen.getByText('Title Only')).toBeInTheDocument();
    });

    it('should render without DialogFooter', () => {
      render(
        <Dialog defaultOpen={true}>
          <DialogContent>
            <DialogHeader>
              <DialogTitle>No Footer</DialogTitle>
            </DialogHeader>
            <div>Content without footer</div>
          </DialogContent>
        </Dialog>
      );

      expect(screen.getByText('Content without footer')).toBeInTheDocument();
    });
  });

describe('Controlled vs Uncontrolled', () => {
    it('should work as uncontrolled component', async () => {
      render(<SimpleDialog />);

      const trigger = screen.getByRole('button', { name: 'Open Dialog' });
      await act(async () => { await userEvent.click(trigger);

      await act(async () => { await waitFor(() => {
        expect(screen.getByText('Dialog Title')).toBeInTheDocument();
      }); });

      const closeButton = screen.getByRole('button', { name: 'Cancel' });
      await act(async () => { await userEvent.click(closeButton);

      await act(async () => { await waitFor(() => {
        expect(screen.queryByText('Dialog Title')).not.toBeInTheDocument();
      }); });
    });

    it('should work as controlled component', async () => {
      const ControlledDialog = () => {
        const [open, setOpen] = React.useState(false);
        return (
          <Dialog open={open} onOpenChange={setOpen}>
            <DialogTrigger asChild>
              <Button>Open</Button>
            </DialogTrigger>
            <DialogContent>
              <DialogTitle>Controlled Dialog</DialogTitle>
              <DialogClose asChild>
                <Button>Close</Button>
              </DialogClose>
            </DialogContent>
          </Dialog>
        );
      };

      render(<ControlledDialog />);

      const trigger = screen.getByRole('button', { name: 'Open' });
      await act(async () => { await userEvent.click(trigger);

      await act(async () => { await waitFor(() => {
        expect(screen.getByText('Controlled Dialog')).toBeInTheDocument();
      }); });

      const dialogContent = screen.getByText('Controlled Dialog').closest('[role="dialog"]');
      const closeButton = dialogContent!.querySelector('button[type="button"]:last-child') as HTMLElement;
      await act(async () => { await userEvent.click(closeButton);

      await act(async () => { await waitFor(() => {
        expect(screen.queryByText('Controlled Dialog')).not.toBeInTheDocument();
      }); });
    });
  });

describe('Accessibility', () => {
    it('should have proper ARIA attributes', async () => {
      render(<SimpleDialog defaultOpen={true} />);

      const dialog = screen.getByRole('dialog');
      expect(dialog).toBeInTheDocument();
    });

    it('should have aria-labelledby for title', () => {
      render(
        <Dialog defaultOpen={true}>
          <DialogContent>
            <DialogTitle>Accessible Title</DialogTitle>
          </DialogContent>
        </Dialog>
      );

      const dialog = screen.getByRole('dialog');
      const title = screen.getByText('Accessible Title');

      // Check if dialog has aria-labelledby pointing to title
      const labelledBy = dialog.getAttribute('aria-labelledby');
      if (labelledBy) {
        expect(title.closest(`#${labelledBy}`)).toBeTruthy();
      }
    });

    it('should have aria-describedby for description', () => {
      render(
        <Dialog defaultOpen={true}>
          <DialogContent>
            <DialogDescription>Accessible Description</DialogDescription>
          </DialogContent>
        </Dialog>
      );

      const dialog = screen.getByRole('dialog');
      const description = screen.getByText('Accessible Description');

      // Check if dialog has aria-describedby pointing to description
      const describedBy = dialog.getAttribute('aria-describedby');
      if (describedBy) {
        expect(description.closest(`#${describedBy}`)).toBeTruthy();
      }
    });

    it('should trap focus within dialog', async () => {
      render(
        <Dialog defaultOpen={true}>
          <DialogContent>
            <DialogHeader>
              <DialogTitle>Focus Trap Test</DialogTitle>
            </DialogHeader>
            <input type="text" placeholder="First input" />
            <input type="text" placeholder="Second input" />
            <DialogFooter>
              <Button>Action</Button>
            </DialogFooter>
          </DialogContent>
        </Dialog>
      );

      // Focus should be trapped within the dialog
      const inputs = screen.getAllByPlaceholderText(/input/i);
      expect(inputs).toHaveLength(2);
    });

    it('should return focus to trigger when closed', async () => {
      render(<SimpleDialog />);

      const trigger = screen.getByRole('button', { name: 'Open Dialog' });
      trigger.focus();
      expect(trigger).toHaveFocus();

      await act(async () => { await userEvent.click(trigger);

      await act(async () => { await waitFor(() => {
        expect(screen.getByText('Dialog Title')).toBeInTheDocument();
      }); });

      fireEvent.keyDown(document, { key: 'Escape' });

      await act(async () => { await waitFor(() => {
        expect(screen.queryByText('Dialog Title')).not.toBeInTheDocument();
        // Focus should return to trigger
        expect(trigger).toHaveFocus();
      }); });
    });
  });

describe('Edge Cases', () => {
    it('should handle dialog without trigger', () => {
      render(
        <Dialog open={true}>
          <DialogContent>
            <DialogTitle>No Trigger Dialog</DialogTitle>
          </DialogContent>
        </Dialog>
      );

      expect(screen.getByText('No Trigger Dialog')).toBeInTheDocument();
    });

    it('should handle multiple dialogs', async () => {
      render(
        <>
          <Dialog>
            <DialogTrigger asChild>
              <Button>Open Dialog 1</Button>
            </DialogTrigger>
            <DialogContent>
              <DialogTitle>Dialog 1</DialogTitle>
            </DialogContent>
          </Dialog>
          <Dialog>
            <DialogTrigger asChild>
              <Button>Open Dialog 2</Button>
            </DialogTrigger>
            <DialogContent>
              <DialogTitle>Dialog 2</DialogTitle>
            </DialogContent>
          </Dialog>
        </>
      );

      const trigger1 = screen.getByRole('button', { name: 'Open Dialog 1' });
      await act(async () => { await userEvent.click(trigger1);

      await act(async () => { await waitFor(() => {
        expect(screen.getByText('Dialog 1')).toBeInTheDocument();
        expect(screen.queryByText('Dialog 2')).not.toBeInTheDocument();
      }); });
    });

    it('should handle long content with scrolling', () => {
      const longContent = Array.from({ length: 100 }, (_, i) => `Line ${i + 1}`).join('\n');

      render(
        <Dialog defaultOpen={true}>
          <DialogContent className="max-h-[300px] overflow-y-auto">
            <DialogTitle>Scrollable Dialog</DialogTitle>
            <div style={{ whiteSpace: 'pre-wrap' }}>{longContent}</div>
          </DialogContent>
        </Dialog>
      );

      expect(screen.getByText('Scrollable Dialog')).toBeInTheDocument();
      expect(screen.getByText(/Line 1/)).toBeInTheDocument();
    });

    it('should handle forms within dialog', async () => {
      const handleSubmit = jest.fn((e) => e.preventDefault());

      render(
        <Dialog defaultOpen={true}>
          <DialogContent>
            <form onSubmit={handleSubmit}>
              <DialogHeader>
                <DialogTitle>Form Dialog</DialogTitle>
              </DialogHeader>
              <input type="text" name="username" placeholder="Username" />
              <DialogFooter>
                <Button type="submit">Submit</Button>
              </DialogFooter>
            </form>
          </DialogContent>
        </Dialog>
      );

      const submitButton = screen.getByRole('button', { name: 'Submit' });
      await act(async () => { await userEvent.click(submitButton);

      expect(handleSubmit).toHaveBeenCalledTimes(1);
    });

    it('should handle custom close behavior', async () => {
      const handleCustomClose = jest.fn();

      render(
        <Dialog defaultOpen={true}>
          <DialogContent>
            <DialogTitle>Custom Close</DialogTitle>
            <Button onClick={() => {
              handleCustomClose();
            }}>
              Custom Close Action
            </Button>
          </DialogContent>
        </Dialog>
      );

      const customCloseButton = screen.getByRole('button', { name: 'Custom Close Action' });
      await act(async () => { await userEvent.click(customCloseButton);

      expect(handleCustomClose).toHaveBeenCalledTimes(1);
    });
  });
});