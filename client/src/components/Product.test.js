// Product.test.js
import React from 'react';
import { render, screen, fireEvent, waitFor } from '@testing-library/react';
import { MemoryRouter } from 'react-router-dom';
import Product from './Product';
import axios from 'axios';

// Mock axios to prevent actual API calls during tests
jest.mock('axios');

// This is a mock function for fetching product data
export const fetchProduct = async (product_code) => {
  try {
    const response = await axios.get(`/api/product/${product_code}`);
    return response.data.trainers; // Assuming the product data is under `trainers`
  } catch (error) {
    throw error; // Throw the error to be handled by the calling function
  }
};

// Jest test cases for the fetchProduct function
describe('fetchProduct function', () => {

  // Test to check if product data is fetched successfully
  it('fetches product data successfully', async () => {
    const mockProductData = {
      trainers: {
        product_name: 'Test Product',
        image_URL: 'test_image_url',
        price: '100',
      },
    };

    // Mock axios to return the expected product data
    axios.get = jest.fn().mockResolvedValueOnce({ data: mockProductData });

    // Call the fetchProduct function with a valid product code
    const result = await fetchProduct('707948');

    // Assertions to check if the data was fetched correctly
    expect(result).toEqual(mockProductData.trainers);
    expect(axios.get).toHaveBeenCalledWith('/api/product/707948');
  });

  // Test to check if an error is thrown when the product is not found
  it('throws an error when the product is not found', async () => {
    // Mock axios to simulate a 404 error
    axios.get = jest.fn().mockRejectedValueOnce({ response: { status: 404 } });

    // Check if the fetchProduct function throws an error for an invalid product code
    await expect(fetchProduct('invalid_code')).rejects.toEqual({ response: { status: 404 } });
    expect(axios.get).toHaveBeenCalledWith('/api/product/invalid_code');
  });
});

// Jest test cases for the Product component
describe('Product Component', () => {

  // Test to check if the loading state is rendered initially
  it('renders loading state initially', () => {
    render(
      <MemoryRouter>
        <Product />
      </MemoryRouter>
    );

    // Check if "Loading..." is displayed
    expect(screen.getByText(/loading/i)).toBeInTheDocument();
  });
});
