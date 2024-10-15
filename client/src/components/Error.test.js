import { render, screen } from '@testing-library/react';
import { MemoryRouter } from 'react-router-dom';
import Error from './Error';
import axios from 'axios';

// Mock axios to prevent actual API calls during tests
jest.mock('axios');

describe('Error Component', () => {
  // Test to check if the "Product Not Found" message is displayed
  it('displays the "Product Not Found" message', () => {
    render(
      <MemoryRouter>
        <Error />
      </MemoryRouter>
    );

    // Check if the heading "Product Not Found" is in the document
    expect(screen.getByText('Product Not Found')).toBeInTheDocument();

    // Check if the instruction text is in the document
    expect(screen.getByText('Please check the product code you entered and try again.')).toBeInTheDocument();
  });
});

describe('Error Component', () => {
    // Test to check if the input field and button are rendered correctly
    it('renders input and button', () => {
      render(
        <MemoryRouter>
          <Error />
        </MemoryRouter>
      );
  
      // Check if the input field with the placeholder "Product-code" is in the document
      expect(screen.getByPlaceholderText(/Product-code/i)).toBeInTheDocument();
  
      // Check if the button with the text "Go" is in the document
      expect(screen.getByRole('button', { name: /Go/i })).toBeInTheDocument();
    });
  });

  describe('Error Component', () => {
    // Test to check if the logo is rendered and links to the home page
    it('renders logo and links to the home page', () => {
      render(
        <MemoryRouter>
          <Error />
        </MemoryRouter>
      );
  
      // Find the logo element by its alt text
      const logo = screen.getByAltText('JD Sports Logo');
  
      // Check if the logo is in the document
      expect(logo).toBeInTheDocument();
  
      // Check if the logo links to the home page ("/")
      expect(logo.closest('a')).toHaveAttribute('href', '/');
    });
  });