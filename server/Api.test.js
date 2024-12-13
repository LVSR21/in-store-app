// Import dependencies
const request = require('supertest');
const mongoose = require('mongoose'); // Import mongoose to manage connection
const app = require('./app'); // Adjust the path as necessary
const Trainer = require('./model/product'); // Mongoose model

// At the top of Api.test.js
jest.mock('mongoose', () => ({
  connect: jest.fn().mockResolvedValue({}),
  connection: {
    once: jest.fn(),
    on: jest.fn(),
    db: { collection: jest.fn() }
  },
  Schema: jest.fn(),
  model: jest.fn()
}));

// Mock the product model
jest.mock('./model/product', () => ({
  collection: {
    name: 'trainers'
  },
  findOne: jest.fn(),
  prototype: {
    save: jest.fn().mockResolvedValue({
      product_code: '123',
      product_name: 'New Product'
    })
  }
}));

// Mock console methods
beforeAll(() => {
  jest.spyOn(console, 'log').mockImplementation(() => {});
  jest.spyOn(console, 'error').mockImplementation(() => {});
});

// Cleanup after tests
afterAll(done => {
  console.log.mockRestore();
  console.error.mockRestore();
  done();
});

describe('Product API', () => {
  afterEach(() => {
    jest.clearAllMocks(); // Clear mock history after each test
  });

  it('should fetch a product by product code', async () => {
    // Define the mock implementation for findOne
    const mockProduct = {
      product_code: '123',
      product_name: 'Test Product',
      image_URL: 'http://example.com/image.jpg',
      // Add other fields as necessary
    };

    Trainer.findOne.mockResolvedValue(mockProduct); // Mock findOne to return the mockProduct

    // Perform the GET request
    const res = await request(app).get('/product/123');

    // Assertions
    expect(res.statusCode).toBe(200);
    expect(res.body.product_code).toBe('123');
    expect(res.body.product_name).toBe('Test Product');

    // Verify that findOne was called with the correct parameters
    expect(Trainer.findOne).toHaveBeenCalledWith({ "trainers.product_code": '123' });
  });

  it('should return 404 if product not found', async () => {
    // Mock findOne to return null (product not found)
    Trainer.findOne.mockResolvedValue(null);

    // Perform the GET request
    const res = await request(app).get('/product/999');

    // Assertions
    expect(res.statusCode).toBe(404);
    expect(res.text).toBe('Product not found'); // Ensure error message matches

    // Verify that findOne was called with the correct parameters
    expect(Trainer.findOne).toHaveBeenCalledWith({ "trainers.product_code": '999' });
  });

  it('should add a new product', async () => {
    // Define the mock product that should be returned after saving
    const mockProduct = {
      product_code: '123',
      product_name: 'New Product',
      // Add other fields as necessary
      save: jest.fn().mockResolvedValue({ 
        product_code: '123', 
        product_name: 'New Product'
      }), // Mock the save method
    };
  
    // Mock the Trainer constructor to return the mockProduct
    Trainer.mockImplementation(() => mockProduct);
  
    // Define the product data to send in the POST request
    const productData = {
      product_code: '123',
      product_name: 'New Product',
      // Add other necessary fields
    };
  
    // Perform the POST request
    const res = await request(app).post('/product').send(productData);
  
    // Assertions
    expect(res.statusCode).toBe(201);
    expect(res.body.product_code).toBe('123'); // This should now pass
  
    // Verify that the save method was called
    expect(mockProduct.save).toHaveBeenCalled();
  });
});