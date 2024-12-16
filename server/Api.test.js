// Import dependencies
const request = require('supertest');
const mongoose = require('mongoose');
const app = require('./app');
const Trainer = require('./model/product');

// Store server instance
let server;

// Mock mongoose
jest.mock('mongoose', () => ({
  connect: jest.fn().mockResolvedValue({}),
  connection: {
    once: jest.fn(),
    on: jest.fn(),
    db: { collection: jest.fn() }
  },
  Schema: jest.fn(),
  model: jest.fn(),
  disconnect: jest.fn()
}));

// Mock product model
jest.mock('./model/product', () => {
  const mockTrainer = jest.fn().mockImplementation((data) => ({
    ...data,
    save: jest.fn().mockResolvedValue({
      product_code: '123',
      product_name: 'New Product'
    })
  }));

  return Object.assign(mockTrainer, {
    collection: {
      name: 'trainers'
    },
    findOne: jest.fn(),
  });
});

// Test setup
beforeAll(async () => {
  jest.spyOn(console, 'log').mockImplementation(() => {});
  jest.spyOn(console, 'error').mockImplementation(() => {});
  server = app.listen();
});

afterAll(async () => {
  await new Promise(resolve => {
    server.close(resolve);
  });
  console.log.mockRestore();
  console.error.mockRestore();
  await mongoose.disconnect();
});

describe('Product API', () => {
  afterEach(() => {
    jest.clearAllMocks();
  });

  it('should fetch a product by product code', async () => {
    const mockProduct = {
      product_code: '123',
      product_name: 'Test Product',
      image_URL: 'http://example.com/image.jpg'
    };

    Trainer.findOne.mockResolvedValue(mockProduct);

    const res = await request(app).get('/product/123');

    expect(res.statusCode).toBe(200);
    expect(res.body.product_code).toBe('123');
    expect(res.body.product_name).toBe('Test Product');
    expect(Trainer.findOne).toHaveBeenCalledWith({ "trainers.product_code": '123' });
  });

  it('should return 404 if product not found', async () => {
    Trainer.findOne.mockResolvedValue(null);

    const res = await request(app).get('/product/999');

    expect(res.statusCode).toBe(404);
    expect(res.text).toBe('Product not found');
    expect(Trainer.findOne).toHaveBeenCalledWith({ "trainers.product_code": '999' });
  });

  it('should add a new product', async () => {
    const productData = {
      product_code: '123',
      product_name: 'New Product',
      image_URL: 'http://example.com/image.jpg'
    };

    const res = await request(app)
      .post('/product')
      .send(productData);

    expect(res.statusCode).toBe(201);
    expect(res.body.product_code).toBe('123');
    expect(res.body.product_name).toBe('New Product');
  });
});