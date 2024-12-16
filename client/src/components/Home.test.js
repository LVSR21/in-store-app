import { render, screen, fireEvent, waitFor } from '@testing-library/react';
import { MemoryRouter } from 'react-router-dom';
import Home from './Home';
import axios from 'axios';

// Mock axios to prevent actual API calls during tests
jest.mock('axios');

describe('Home Component', () => {
    // Test to check if the input field and button are rendered correctly
  it('renders input and button', () => {
     // Render the Home component wrapped in MemoryRouter for routing
    render(
      <MemoryRouter>
        <Home />
      </MemoryRouter>
    );

    // Check if the input field with the placeholder "Product-code" is in the document
    expect(screen.getByPlaceholderText(/Product-code/i)).toBeInTheDocument();

    // Check if the button with the text "Go" is in the document
    expect(screen.getByRole('button', { name: /Go/i })).toBeInTheDocument();
  });

  // Test to check the product search functionality
  it('handles product search correctly', async () => {
    // Mock a successful response from the API when axios.get is called
    axios.get.mockResolvedValue({ data: {} });

    // Render the component
    render(
      <MemoryRouter>
        <Home />
      </MemoryRouter>
    );

    // Find the input field and change its value to '12345'
    const input = screen.getByPlaceholderText(/Product-code/i);
    fireEvent.change(input, {
      target: { value: '707948' },
    });

    // Simulate a button click on the "Go" button
    fireEvent.click(screen.getByRole('button', { name: /Go/i }));

    // Use waitFor to ensure that the axios.get method is called with the expected URL
    await waitFor(() => {
      expect(axios.get).toHaveBeenCalledWith('/api/product/707948');
    });
  });
});
